#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RevisionLayout:
    container: str
    mapper: int
    mirroring: str
    header_size: int
    prg_size: int
    cpu_start: int
    prg_mirrored: bool
    chr_size: int
    ppu_start: int


@dataclass(frozen=True)
class Revision:
    profile_id: str
    rom: str
    sha1: str
    sha256: str = ""
    ca65_revision: int = 0
    chr_source: str = "generated"
    runtime_smoke: str = ""
    input_contracts: tuple[str, ...] = ()
    layout_contract: str = ""
    output_contract: str = ""
    capabilities: tuple[str, ...] = ()
    artifact_id: str = ""
    output_path: str = ""
    output_size: int = 0
    identity: str = ""
    source_entrypoint: str = ""
    linker_config: str = ""
    generated_chr: str = ""
    layout: RevisionLayout | None = None


def _require_mapping(value: object, field: str) -> dict[str, object]:
    if not isinstance(value, dict):
        raise ValueError(f"{field} must be an object")
    return value


def _load_profile_contracts(
    document: dict[str, object], project_root: Path,
) -> dict[str, dict[str, object]] | None:
    version = document.get("profile_contract_version")
    if version is None:
        return None
    if version != 1:
        raise ValueError("unsupported profile contract version")
    contracts = _require_mapping(document.get("profile_contracts"), "profile_contracts")
    if set(contracts) != {"inputs", "layouts", "outputs", "capabilities"}:
        raise ValueError(
            "profile_contracts needs inputs, layouts, outputs, and capabilities"
        )
    catalogs = {
        name: _require_mapping(contracts[name], f"profile_contracts.{name}")
        for name in ("inputs", "layouts", "outputs", "capabilities")
    }
    if any(not catalog for catalog in catalogs.values()):
        raise ValueError("profile contract catalogs must not be empty")

    private_input = _require_mapping(
        catalogs["inputs"].get("private_reference_rom"),
        "private_reference_rom input contract",
    )
    if private_input != {
        "kind": "ines-rom",
        "tracked": False,
        "required_profile_fields": ["rom", "sha1", "sha256"],
    }:
        raise ValueError("private reference ROM input contract is invalid")
    source_input = _require_mapping(
        catalogs["inputs"].get("canonical_shared_source"),
        "canonical_shared_source input contract",
    )
    for field in ("entrypoint", "linker_config", "generated_chr"):
        value = source_input.get(field)
        if not isinstance(value, str) or not value:
            raise ValueError(f"canonical source input lacks {field}")
        relative = Path(value)
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"canonical source input must stay in the project: {value}")
        if field != "generated_chr" and not (project_root / relative).is_file():
            raise ValueError(f"canonical source input does not exist: {value}")
    if source_input.get("revision_define") != "PACMAN_REVISION":
        raise ValueError("canonical source input has an invalid revision define")

    layout = _require_mapping(
        catalogs["layouts"].get("nes_nrom128"), "nes_nrom128 layout contract",
    )
    expected_layout = {
        "container": "ines-1.0",
        "mapper": 0,
        "mirroring": "horizontal",
        "header_size": 16,
        "prg": {"size": 16384, "cpu_start": "0xC000", "mirrored": True},
        "chr": {"size": 8192, "ppu_start": "0x0000"},
    }
    if layout != expected_layout:
        raise ValueError("nes_nrom128 layout contract is invalid")

    output = _require_mapping(
        catalogs["outputs"].get("byte_identical_revision_rom"),
        "byte_identical_revision_rom output contract",
    )
    if output != {
        "artifact_id_template": "pacman_{profile_id}",
        "path_template": "build/revisions/{profile_id}/pacman.nes",
        "size": 24592,
        "identity": "byte-identical",
    }:
        raise ValueError("byte-identical revision output contract is invalid")

    for capability_id, capability in catalogs["capabilities"].items():
        if not isinstance(capability_id, str) or not capability_id:
            raise ValueError("profile capability ID must be a non-empty string")
        row = _require_mapping(capability, f"capability {capability_id}")
        if row.get("status") != "supported" or not isinstance(row.get("target"), str):
            raise ValueError(f"profile capability is invalid: {capability_id}")
    return catalogs


def load_manifest(path: Path) -> tuple[str, list[Revision]]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("format") != 2:
        raise ValueError("unsupported revision manifest format")
    default_profile = document.get("default_profile")
    rows = document.get("profiles")
    if not isinstance(default_profile, str) or not isinstance(rows, list) or not rows:
        raise ValueError("manifest needs default_profile and a non-empty profiles list")
    contracts = _load_profile_contracts(document, path.resolve().parent.parent)

    revisions: list[Revision] = []
    seen_ids: set[str] = set()
    seen_ca65_revisions: set[int] = set()
    seen_artifacts: set[str] = set()
    seen_outputs: set[str] = set()
    for row in rows:
        try:
            input_contracts = tuple(row.get("input_contracts", ()))
            capabilities = tuple(row.get("capabilities", ()))
            layout_contract = row.get("layout_contract", "")
            output_contract = row.get("output_contract", "")
            artifact_id = ""
            output_path = ""
            output_size = 0
            identity = ""
            source_entrypoint = ""
            linker_config = ""
            generated_chr = ""
            revision_layout = None
            if contracts is not None:
                if not input_contracts or any(
                    not isinstance(value, str) or value not in contracts["inputs"]
                    for value in input_contracts
                ):
                    raise ValueError("invalid input contract references")
                if len(input_contracts) != len(set(input_contracts)):
                    raise ValueError("duplicate input contract reference")
                if (
                    not isinstance(layout_contract, str)
                    or layout_contract not in contracts["layouts"]
                ):
                    raise ValueError("invalid layout contract reference")
                if (
                    not isinstance(output_contract, str)
                    or output_contract not in contracts["outputs"]
                ):
                    raise ValueError("invalid output contract reference")
                if not capabilities or any(
                    not isinstance(value, str) or value not in contracts["capabilities"]
                    for value in capabilities
                ):
                    raise ValueError("invalid capability references")
                if len(capabilities) != len(set(capabilities)):
                    raise ValueError("duplicate capability reference")
                output = contracts["outputs"][output_contract]
                if not isinstance(output, dict):
                    raise ValueError("invalid output contract")
                artifact_id = str(output["artifact_id_template"]).format(
                    profile_id=row["id"]
                )
                output_path = str(output["path_template"]).format(
                    profile_id=row["id"]
                )
                output_size = int(output["size"])
                identity = str(output["identity"])
                source_input = contracts["inputs"]["canonical_shared_source"]
                if not isinstance(source_input, dict):
                    raise ValueError("invalid canonical source input contract")
                source_entrypoint = str(source_input["entrypoint"])
                linker_config = str(source_input["linker_config"])
                generated_chr = str(source_input["generated_chr"])
                layout = contracts["layouts"][layout_contract]
                if not isinstance(layout, dict):
                    raise ValueError("invalid profile layout contract")
                prg = layout["prg"]
                chr_region = layout["chr"]
                if not isinstance(prg, dict) or not isinstance(chr_region, dict):
                    raise ValueError("invalid profile layout regions")
                revision_layout = RevisionLayout(
                    str(layout["container"]), int(layout["mapper"]),
                    str(layout["mirroring"]), int(layout["header_size"]),
                    int(prg["size"]), int(str(prg["cpu_start"]), 16),
                    bool(prg["mirrored"]), int(chr_region["size"]),
                    int(str(chr_region["ppu_start"]), 16),
                )
            revision = Revision(
                row["id"], row["rom"], row["sha1"].lower(),
                row["sha256"].lower(), row["ca65_revision"], row["chr_source"],
                row["runtime_smoke"], input_contracts, layout_contract,
                output_contract, capabilities, artifact_id, output_path,
                output_size, identity, source_entrypoint, linker_config,
                generated_chr, revision_layout,
            )
        except (KeyError, TypeError, AttributeError) as exc:
            raise ValueError(
                "each profile needs id, rom, sha1, sha256, ca65_revision, "
                "chr_source, runtime_smoke, and valid contract references"
            ) from exc
        if not all(
            isinstance(value, str) and value
            for value in (
                revision.profile_id, revision.rom, revision.sha1,
                revision.sha256, revision.runtime_smoke,
            )
        ):
            raise ValueError(
                "profile id, rom, sha1, sha256, and runtime_smoke "
                "must be non-empty strings"
            )
        if revision.profile_id in seen_ids:
            raise ValueError(f"duplicate revision profile: {revision.profile_id}")
        if not isinstance(revision.ca65_revision, int) or revision.ca65_revision < 0:
            raise ValueError(f"invalid ca65_revision for {revision.profile_id}")
        if revision.ca65_revision in seen_ca65_revisions:
            raise ValueError(f"duplicate ca65_revision: {revision.ca65_revision}")
        if revision.chr_source not in {"generated", "reference"}:
            raise ValueError(f"invalid chr_source for {revision.profile_id}")
        if len(revision.sha1) != 40 or any(
            char not in "0123456789abcdef" for char in revision.sha1
        ):
            raise ValueError(f"invalid SHA1 for {revision.profile_id}")
        if len(revision.sha256) != 64 or any(
            char not in "0123456789abcdef" for char in revision.sha256
        ):
            raise ValueError(f"invalid SHA256 for {revision.profile_id}")
        if contracts is not None:
            required_capabilities = {"build", "byte_identity", "direct_runtime_smoke"}
            if not required_capabilities.issubset(revision.capabilities):
                raise ValueError(
                    f"required capabilities are missing for {revision.profile_id}"
                )
            canonical_only = {"deep_runtime_evidence", "canonical_relocation"}
            if revision.profile_id == default_profile:
                if not canonical_only.issubset(revision.capabilities):
                    raise ValueError("default profile lacks deep evidence capabilities")
            elif canonical_only.intersection(revision.capabilities):
                raise ValueError(
                    f"non-default profile overclaims capabilities: {revision.profile_id}"
                )
            if revision.artifact_id in seen_artifacts:
                raise ValueError(f"duplicate output artifact: {revision.artifact_id}")
            if revision.output_path in seen_outputs:
                raise ValueError(f"duplicate output path: {revision.output_path}")
            seen_artifacts.add(revision.artifact_id)
            seen_outputs.add(revision.output_path)
        seen_ids.add(revision.profile_id)
        seen_ca65_revisions.add(revision.ca65_revision)
        revisions.append(revision)
    if default_profile not in seen_ids:
        raise ValueError(f"default profile is not declared: {default_profile}")
    return default_profile, revisions


def select_revision(path: Path, profile_id: str) -> Revision:
    _, revisions = load_manifest(path)
    for revision in revisions:
        if revision.profile_id == profile_id:
            return revision
    raise ValueError(f"unknown revision profile: {profile_id}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Read Pac-Man revision metadata.")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--profile")
    parser.add_argument("--print-default", action="store_true")
    parser.add_argument("--print-output-dir", action="store_true")
    args = parser.parse_args()
    try:
        default_profile, revisions = load_manifest(args.manifest)
        selected = None
        if args.profile is not None:
            selected = next(
                (row for row in revisions if row.profile_id == args.profile), None,
            )
            if selected is None:
                raise ValueError(f"unknown revision profile: {args.profile}")
        if args.print_output_dir and selected is None:
            raise ValueError("--print-output-dir requires --profile")
    except (OSError, ValueError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2
    if args.print_default:
        print(default_profile)
    if args.print_output_dir and selected is not None:
        if not selected.output_path:
            print("[FAIL] profile has no output contract", file=sys.stderr)
            return 2
        print(Path(selected.output_path).parent.as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
