#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
from pathlib import Path

from revision_profiles import Revision, select_revision


def file_sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_reference_layout(path: Path, revision: Revision) -> None:
    layout = revision.layout
    if layout is None:
        return
    data = path.read_bytes()
    expected_size = layout.header_size + layout.prg_size + layout.chr_size
    if len(data) != expected_size:
        raise ValueError(
            f"reference size {len(data)}, expected {expected_size} for "
            f"{revision.layout_contract}"
        )
    header = data[:layout.header_size]
    if layout.container != "ines-1.0" or header[:4] != b"NES\x1a":
        raise ValueError("reference does not match the iNES 1.0 container contract")
    if header[4] * 16384 != layout.prg_size or header[5] * 8192 != layout.chr_size:
        raise ValueError("reference PRG/CHR sizes differ from the profile layout")
    mapper = (header[6] >> 4) | (header[7] & 0xF0)
    if mapper != layout.mapper:
        raise ValueError(f"reference mapper {mapper}, expected {layout.mapper}")
    mirroring = "vertical" if header[6] & 0x01 else "horizontal"
    if mirroring != layout.mirroring:
        raise ValueError(
            f"reference mirroring {mirroring}, expected {layout.mirroring}"
        )
    if header[6] & 0x04:
        raise ValueError("trainer is not permitted by the profile layout")
    if layout.cpu_start != 0xC000 or not layout.prg_mirrored:
        raise ValueError("unsupported NROM-128 CPU mapping in profile layout")
    if layout.ppu_start != 0x0000:
        raise ValueError("unsupported CHR PPU mapping in profile layout")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build one official Pac-Man revision from the revision manifest."
    )
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--profile", required=True)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--project-dir", type=Path, required=True)
    parser.add_argument("--toolchain-manifest", type=Path)
    parser.add_argument("--source", type=Path)
    parser.add_argument("--config", type=Path)
    parser.add_argument("--generated-chr", type=Path)
    parser.add_argument("--build-dir", type=Path)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    try:
        revision = select_revision(args.manifest, args.profile)
        reference_rom = args.reference_dir / revision.rom
        if not reference_rom.is_file():
            raise ValueError(f"missing reference ROM: {reference_rom}")
        actual_sha1 = file_sha1(reference_rom)
        if actual_sha1 != revision.sha1:
            raise ValueError(
                f"reference SHA1 {actual_sha1}, expected {revision.sha1}"
            )
        actual_sha256 = file_sha256(reference_rom)
        if actual_sha256 != revision.sha256:
            raise ValueError(
                f"reference SHA256 {actual_sha256}, expected {revision.sha256}"
            )
        validate_reference_layout(reference_rom, revision)
        contract_paths = {
            "source": revision.source_entrypoint,
            "config": revision.linker_config,
            "generated_chr": revision.generated_chr,
        }
        resolved_paths: dict[str, Path] = {}
        for field, contract_path in contract_paths.items():
            override = getattr(args, field)
            if contract_path:
                expected = args.project_dir / contract_path
                if override is not None and override.resolve() != expected.resolve():
                    raise ValueError(
                        f"--{field.replace('_', '-')} differs from profile contract: "
                        f"{override} != {expected}"
                    )
                resolved_paths[field] = expected
            elif override is not None:
                resolved_paths[field] = override
            else:
                raise ValueError(f"profile lacks required {field} input")
        if revision.output_path:
            expected_build_dir = (args.project_dir / revision.output_path).parent
            if (
                args.build_dir is not None
                and args.build_dir.resolve() != expected_build_dir.resolve()
            ):
                raise ValueError(
                    f"--build-dir differs from profile contract: "
                    f"{args.build_dir} != {expected_build_dir}"
                )
            build_dir = expected_build_dir
        elif args.build_dir is not None:
            build_dir = args.build_dir
        else:
            raise ValueError("profile lacks required output path")
    except (OSError, ValueError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    command = [
        sys.executable,
        str(args.project_dir / "scripts" / "build_native.py"),
        "--source", str(resolved_paths["source"]),
        "--define", f"PACMAN_REVISION={revision.ca65_revision}",
        "--config", str(resolved_paths["config"]),
        "--original-rom", str(reference_rom),
        "--object", str(build_dir / "pacman.o"),
        "--prg", str(build_dir / "pacman.prg"),
        "--labels", str(build_dir / "pacman.lbl"),
        "--map", str(build_dir / "pacman.map"),
        "--debug-info", str(build_dir / "pacman.dbg"),
        "--output-rom", str(build_dir / "pacman.nes"),
        "--toolchain-manifest", str(
            args.toolchain_manifest
            or args.project_dir / "config" / "toolchain.json"
        ),
    ]
    if revision.chr_source == "reference":
        command.append("--chr-from-reference")
    else:
        command.extend(("--chr", str(resolved_paths["generated_chr"])))
    if args.verify:
        command.append("--verify")
    return subprocess.run(command, cwd=args.project_dir, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
