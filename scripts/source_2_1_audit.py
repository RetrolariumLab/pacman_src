#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from build_dev import load_toolchain_manifest
from revision_profiles import Revision, load_manifest
from workflow.run_revision_smokes import validate_scenarios


EXPECTED_RELEASE_LINE = "2.x"
EXPECTED_RELEASE = {"name": "Source Reconstruction 2.1", "version": "2.1"}
EXPECTED_TAG = "source-reconstruction-2.1"
EXPECTED_PREDECESSOR = {
    "tag": "source-reconstruction-2.0",
    "commit": "ae136e1a7246f911e5280e8a7ad869b604bb9189",
    "manifest": None,
    "legacy_without_manifest": True,
}
EXPECTED_SCOPE = (
    "resolved_reconstruction_unknowns",
    "semantic_runtime_evidence",
    "assembly_style_and_label_provenance",
    "canonical_symbolic_relocation",
    "normalized_repository_layout",
    "manifest_driven_revision_builds",
    "pinned_toolchain_and_profile_runtime",
)
EXPECTED_REQUIREMENTS = {
    "canonical_identity",
    "semantic_source_and_provenance",
    "official_revision_profiles",
    "semantic_runtime_evidence",
    "isolated_authoring_and_variants",
    "canonical_relocation",
    "reproducible_toolchain",
    "release_integrity",
}
EXPECTED_LICENSE_CATEGORIES = {
    "project_authored",
    "reconstructed_game_source",
    "bundled_external_tools",
    "imported_materials",
    "private_user_inputs",
    "external_unbundled_tool",
}


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def git_output(project_root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", *arguments], cwd=project_root, capture_output=True, text=True,
        check=False,
    )
    if completed.returncode:
        raise ValueError(f"git {' '.join(arguments)} failed")
    return completed.stdout.strip()


def git_ref_exists(project_root: Path, ref: str) -> bool:
    completed = subprocess.run(
        ["git", "show-ref", "--verify", "--quiet", ref], cwd=project_root,
        check=False,
    )
    if completed.returncode not in {0, 1}:
        raise ValueError(f"git show-ref failed for {ref}")
    return completed.returncode == 0


def remote_tag_exists(project_root: Path, remote: str, tag: str) -> bool:
    completed = subprocess.run(
        [
            "git", "ls-remote", "--tags", remote,
            f"refs/tags/{tag}",
        ],
        cwd=project_root, capture_output=True, text=True, check=False,
    )
    if completed.returncode:
        detail = completed.stderr.strip() or f"exit {completed.returncode}"
        raise ValueError(f"cannot query publish remote {remote}: {detail}")
    return bool(completed.stdout.strip())


def validate_release_metadata(manifest: dict[str, object]) -> list[str]:
    errors: list[str] = []
    if manifest.get("release_line") != EXPECTED_RELEASE_LINE:
        errors.append("release line differs from Source 2.1")
    if manifest.get("release") != EXPECTED_RELEASE:
        errors.append("release identity differs from Source 2.1")
    if manifest.get("release_kind") != "compatible_minor":
        errors.append("Source 2.1 must declare a compatible_minor release")
    if manifest.get("tag") != EXPECTED_TAG:
        errors.append("release tag differs from Source 2.1")
    if manifest.get("predecessor") != EXPECTED_PREDECESSOR:
        errors.append("predecessor identity differs from Source 2.0")
    if manifest.get("included_scope") != list(EXPECTED_SCOPE):
        errors.append("included scope or order differs from Source 2.1")
    delta = manifest.get("delta")
    if not isinstance(delta, list) or not delta:
        errors.append("release delta must contain evidence-backed entries")
    else:
        for row in delta:
            if not isinstance(row, dict) or not all(
                row.get(key) for key in ("id", "kind", "summary", "evidence")
            ):
                errors.append("release delta contains an incomplete entry")
                break
            if row["kind"] not in {"evidence", "source", "tooling", "documentation"}:
                errors.append(f"invalid release delta kind: {row['kind']}")
    excluded = manifest.get("excluded_scope")
    if not isinstance(excluded, list) or not excluded:
        errors.append("excluded scope must be explicit")
    elif any(
        not isinstance(row, dict)
        or not isinstance(row.get("id"), str)
        or row.get("status") not in {"unsupported", "not_applicable", "planned"}
        or not isinstance(row.get("reason"), str)
        or not row["reason"]
        for row in excluded
    ):
        errors.append("excluded scope contains an invalid entry")
    return errors


def validate_layout(project_root: Path, contract: object) -> list[str]:
    if not isinstance(contract, dict):
        return ["layout contract must be an object"]
    errors: list[str] = []
    expected_root = contract.get("src_root_asm")
    actual_root = sorted(path.name for path in (project_root / "src").glob("*.asm"))
    if actual_root != expected_root:
        errors.append(f"src root ASM files are {actual_root}, expected {expected_root}")
    if list((project_root / "src").glob("*.cfg")):
        errors.append("linker configs must not remain in src root")
    for key in ("canonical_source", "revision_ids"):
        value = contract.get(key)
        if not isinstance(value, str) or not (project_root / value).is_file():
            errors.append(f"missing layout path: {value}")
    for key in ("variant_entrypoints", "linker_configs", "required_test_modules"):
        values = contract.get(key)
        if not isinstance(values, list) or not values or not all(
            isinstance(value, str) for value in values
        ):
            errors.append(f"layout field {key} must be a non-empty path list")
            continue
        for value in values:
            if not (project_root / value).is_file():
                errors.append(f"missing layout path: {value}")
    tests_root = project_root / str(contract.get("tests_root", ""))
    if not tests_root.is_dir():
        errors.append("invalid tests root contract")
    if any((project_root / "scripts" / "tests").glob("test_*.py")):
        errors.append("legacy scripts/tests directory still exists")
    return errors


def validate_revision_contract(
    project_root: Path, contract: object,
) -> tuple[list[str], list[Revision]]:
    if not isinstance(contract, dict):
        return ["revision contract must be an object"], []
    errors: list[str] = []
    manifest_path = project_root / str(contract.get("manifest", ""))
    try:
        document = read_json(manifest_path)
        _, revisions = load_manifest(manifest_path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"invalid revision manifest: {error}"], []
    if not isinstance(document, dict) or document.get("format") != contract.get("schema_format"):
        errors.append("revision manifest format differs from Source 2.1 contract")
    if [revision.profile_id for revision in revisions] != contract.get("profile_ids"):
        errors.append("revision profile IDs or order differ from Source 2.1 contract")
    if [revision.ca65_revision for revision in revisions] != contract.get("ca65_revisions"):
        errors.append("ca65 revision IDs or order differ from Source 2.1 contract")
    return errors, revisions


def validate_runtime_contract(
    project_root: Path, contract: object, manifest_path: object,
    revisions: list[Revision],
) -> list[str]:
    if not isinstance(contract, list):
        return ["runtime coverage contract must be a list"]
    errors: list[str] = []
    profile_ids = [revision.profile_id for revision in revisions]
    coverage_ids = [
        row.get("profile_id") for row in contract if isinstance(row, dict)
    ]
    if len(coverage_ids) != len(contract) or coverage_ids != profile_ids:
        errors.append("runtime coverage profile IDs or order differ from revisions")
    if any(
        row.get("mode") != "direct"
        or not isinstance(row.get("scenarios"), list)
        or "title_menu_boot" not in row["scenarios"]
        for row in contract if isinstance(row, dict)
    ):
        errors.append("runtime coverage must directly include every revision profile")
    canonical = next(
        (row for row in contract if isinstance(row, dict) and row.get("profile_id") == "japan_v10"),
        None,
    )
    if canonical is None or not {
        "runtime_trace_suite", "scoring_transactions", "reconstruction_evidence",
    }.issubset(set(canonical.get("scenarios", []))):
        errors.append("canonical profile lacks the deep runtime scenario set")
    try:
        document = read_json(project_root / str(manifest_path or ""))
        if not isinstance(document, dict) or document.get("format") != 1:
            raise ValueError("unsupported smoke scenario manifest")
        rows = document.get("profiles")
        validate_scenarios(
            rows, {revision.profile_id: revision for revision in revisions}, True,
        )
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors.append(f"invalid runtime smoke manifest: {error}")
        return errors
    return errors


def validate_artifacts(contract: object, revisions: list[Revision]) -> list[str]:
    if not isinstance(contract, list):
        return ["artifacts must be a list"]
    expected = [
        {
            "id": f"pacman_{revision.profile_id}",
            "profile": revision.profile_id,
            "build_target": (
                f"make verify-revision REVISION={revision.profile_id}"
            ),
            "size": 24592,
            "sha1": revision.sha1,
            "sha256": revision.sha256,
        }
        for revision in revisions
    ]
    return [] if contract == expected else ["artifact identities differ from revision manifest"]


def validate_profiles(contract: object, revisions: list[Revision]) -> list[str]:
    if not isinstance(contract, list):
        return ["profiles must be a list"]
    expected = [
        {
            "id": revision.profile_id,
            "status": "supported",
            "artifact": f"pacman_{revision.profile_id}",
            "identity": "byte-identical",
        }
        for revision in revisions
    ]
    return [] if contract == expected else ["accepted profiles differ from revision manifest"]


def make_targets(makefile: str) -> set[str]:
    return set(re.findall(r"^([A-Za-z0-9][A-Za-z0-9_.-]*):", makefile, re.MULTILINE))


def repository_make_targets(project_root: Path) -> set[str]:
    paths = [project_root / "Makefile", *sorted((project_root / "mk").glob("*.mk"))]
    targets: set[str] = set()
    for path in paths:
        targets.update(make_targets(path.read_text(encoding="utf-8")))
    return targets


def validate_paths(project_root: Path, values: object, field: str) -> list[str]:
    if not isinstance(values, list) or not values:
        return [f"{field} must be a non-empty list"]
    return [
        f"missing required file: {value}"
        for value in values
        if not isinstance(value, str) or not (project_root / value).is_file()
    ]


def validate_delta_evidence(project_root: Path, delta: object) -> list[str]:
    if not isinstance(delta, list):
        return ["release delta must be a list"]
    errors: list[str] = []
    for row in delta:
        if not isinstance(row, dict):
            continue
        evidence = row.get("evidence")
        if not isinstance(evidence, list) or not evidence:
            continue
        for value in evidence:
            if not isinstance(value, str) or not (project_root / value).exists():
                errors.append(f"missing release-delta evidence: {value}")
    return errors


def validate_requirements(
    project_root: Path, contract: object, targets: set[str], artifact_ids: set[str],
) -> list[str]:
    if not isinstance(contract, dict) or set(contract) != EXPECTED_REQUIREMENTS:
        return ["requirement IDs differ from the Source 2.1 contract"]
    errors: list[str] = []
    for requirement_id, requirement in contract.items():
        if not isinstance(requirement, dict) or requirement.get("status") != "satisfied":
            errors.append(f"requirement is not satisfied: {requirement_id}")
            continue
        evidence = requirement.get("evidence")
        if not isinstance(evidence, dict):
            errors.append(f"requirement lacks evidence: {requirement_id}")
            continue
        keys = {"targets", "files", "scenarios", "artifacts"}
        if set(evidence) != keys or any(
            not isinstance(evidence[key], list)
            or not all(isinstance(value, str) and value for value in evidence[key])
            for key in keys
        ):
            errors.append(f"requirement evidence has an invalid shape: {requirement_id}")
            continue
        if not any(evidence.values()):
            errors.append(f"requirement has no concrete evidence: {requirement_id}")
        missing_targets = [value for value in evidence["targets"] if value not in targets]
        if missing_targets:
            errors.append(
                f"requirement {requirement_id} names missing targets: "
                + ", ".join(missing_targets)
            )
        for value in evidence["files"]:
            if not (project_root / value).exists():
                errors.append(f"requirement {requirement_id} names missing file: {value}")
        missing_artifacts = [
            value for value in evidence["artifacts"] if value not in artifact_ids
        ]
        if missing_artifacts:
            errors.append(
                f"requirement {requirement_id} names missing artifacts: "
                + ", ".join(missing_artifacts)
            )
    return errors


def validate_layout_deviations(contract: object) -> list[str]:
    if not isinstance(contract, list):
        return ["layout_deviations must be a list"]
    required = {"rule_id", "actual_path", "reason", "equivalent_control"}
    if any(
        not isinstance(row, dict)
        or set(row) != required
        or not all(isinstance(row[key], str) and row[key] for key in required)
        for row in contract
    ):
        return ["layout_deviations contains an incomplete deviation"]
    return []


def validate_toolchain(project_root: Path, contract: object) -> list[str]:
    if not isinstance(contract, dict):
        return ["toolchain contract must be an object"]
    try:
        manifest_path = project_root / str(contract.get("manifest", ""))
        components = load_toolchain_manifest(manifest_path)
        document = read_json(manifest_path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"invalid toolchain manifest: {error}"]
    expected_components = [
        {
            "id": "assembler",
            "version": components["ca65"]["version"],
            "source": components["ca65"]["source"],
            "source_commit": components["ca65"]["source_commit"],
            "binary_sha256": components["ca65"]["binary_sha256"],
            "provenance": components["ca65"]["provenance"],
            "verification": "make build-dev",
        },
        {
            "id": "linker",
            "version": components["ld65"]["version"],
            "source": components["ld65"]["source"],
            "source_commit": components["ld65"]["source_commit"],
            "binary_sha256": components["ld65"]["binary_sha256"],
            "provenance": components["ld65"]["provenance"],
            "verification": "make build-dev",
        },
        {
            "id": "emulator",
            "version": f"source commit {components['fceux_automation']['source_commit']}",
            "source": components["fceux_automation"]["source"],
            "source_commit": components["fceux_automation"]["source_commit"],
            "binary_sha256": components["fceux_automation"]["binary_sha256"],
            "provenance": "source-built",
            "verification": "make build-dev",
        },
    ]
    hosts = document.get("hosts") if isinstance(document, dict) else None
    expected_hosts = [
        {
            "os": host["os"],
            "architecture": host["architecture"],
            "shell": host["shell"],
            "language_versions": {"python": host["python_tested"]},
            "supported_status": "supported",
        }
        for host in hosts or []
    ]
    errors: list[str] = []
    if contract.get("components") != expected_components:
        errors.append("release toolchain components differ from the toolchain manifest")
    if contract.get("hosts") != expected_hosts:
        errors.append("release host support differs from the toolchain manifest")
    return errors


def validate_licensing_and_provenance(
    project_root: Path, licensing: object, provenance: object,
) -> list[str]:
    errors: list[str] = []
    if not isinstance(licensing, list) or {
        row.get("category") for row in licensing if isinstance(row, dict)
    } != EXPECTED_LICENSE_CATEGORIES:
        errors.append("licensing categories differ from the release contract")
    elif any(
        not isinstance(row, dict) or not all(
            isinstance(row.get(key), str) and row[key]
            for key in (
                "component", "category", "origin", "license_id_or_status",
                "redistribution", "notes",
            )
        )
        for row in licensing
    ):
        errors.append("licensing contains an incomplete component")
    if not isinstance(provenance, dict) or provenance.get("private_inputs_tracked") is not False:
        errors.append("provenance must declare that private inputs are not tracked")
    else:
        errors.extend(validate_paths(
            project_root, provenance.get("references"), "provenance references",
        ))
    try:
        tracked_private = git_output(project_root, "ls-files", "*.nes", "*.fds")
        if tracked_private:
            errors.append("private ROM or disk images are tracked")
    except ValueError as error:
        errors.append(str(error))
    return errors


def validate_repository_state(
    project_root: Path, verify_tag: bool, publish_remote: object,
) -> list[str]:
    errors: list[str] = []
    try:
        if git_output(project_root, "status", "--porcelain", "--untracked-files=all"):
            errors.append("tag-ready audit requires a clean worktree")
        subject = git_output(project_root, "show", "-s", "--format=%s", "HEAD")
        body = git_output(project_root, "show", "-s", "--format=%b", "HEAD")
        if subject != "Complete Source Reconstruction 2.1":
            errors.append("release commit title differs from the contract")
        paragraphs = [
            paragraph for paragraph in re.split(r"\r?\n\s*\r?\n", body)
            if paragraph and not paragraph.startswith("Co-Authored-By:")
        ]
        if len(paragraphs) not in {2, 3}:
            errors.append("release commit body must contain two or three paragraphs")
        if "Co-Authored-By: Codex <noreply@openai.com>" not in body:
            errors.append("release commit lacks the required Codex attribution")
        if not all(term in body for term in ("source-2-1-check", "excluded", "manifest")):
            errors.append("release commit body lacks delta, gate, or scope evidence")
        if verify_tag:
            if git_output(project_root, "cat-file", "-t", EXPECTED_TAG) != "tag":
                errors.append("Source 2.1 tag must be annotated")
            tag_commit = git_output(project_root, "rev-list", "-n", "1", EXPECTED_TAG)
            head = git_output(project_root, "rev-parse", "HEAD")
            if tag_commit != head:
                errors.append("Source 2.1 tag does not resolve to HEAD")
        else:
            if git_ref_exists(project_root, f"refs/tags/{EXPECTED_TAG}"):
                errors.append("future Source 2.1 tag already exists locally")
            if not isinstance(publish_remote, str) or not publish_remote:
                errors.append("release manifest lacks a publish remote")
            elif remote_tag_exists(project_root, publish_remote, EXPECTED_TAG):
                errors.append("future Source 2.1 tag already exists on publish remote")
    except ValueError as error:
        errors.append(str(error))
    return errors


def audit(
    project_root: Path, manifest: object, require_ready: bool, verify_tag: bool = False,
) -> list[str]:
    if not isinstance(manifest, dict) or manifest.get("schema_version") != 2:
        return ["unsupported Source 2.1 manifest schema"]
    errors = validate_release_metadata(manifest)
    if require_ready and manifest.get("status") != "tag-ready":
        errors.append("Source 2.1 manifest is not tag-ready")
    elif manifest.get("status") not in {"development", "tag-ready"}:
        errors.append("unsupported Source 2.1 release status")
    errors.extend(validate_delta_evidence(project_root, manifest.get("delta")))
    errors.extend(validate_paths(project_root, manifest.get("required_files"), "required_files"))
    try:
        targets = repository_make_targets(project_root)
    except OSError as exc:
        errors.append(f"cannot read Makefile: {exc}")
        targets = set()
    required_targets = manifest.get("required_make_targets")
    if not isinstance(required_targets, list) or not required_targets:
        errors.append("required_make_targets must be a non-empty list")
    else:
        missing = [target for target in required_targets if target not in targets]
        if missing:
            errors.append(f"missing Make targets: {', '.join(missing)}")
    errors.extend(validate_layout(project_root, manifest.get("layout")))
    revision_errors, revisions = validate_revision_contract(
        project_root, manifest.get("revision_contract"),
    )
    errors.extend(revision_errors)
    if revisions:
        errors.extend(validate_profiles(manifest.get("profiles"), revisions))
        errors.extend(validate_runtime_contract(
            project_root, manifest.get("runtime_coverage"),
            manifest.get("runtime_coverage_manifest"), revisions,
        ))
        errors.extend(validate_artifacts(manifest.get("artifacts"), revisions))
    artifacts = manifest.get("artifacts")
    artifact_ids = {
        row.get("id") for row in artifacts or [] if isinstance(row, dict)
    } if isinstance(artifacts, list) else set()
    errors.extend(validate_requirements(
        project_root, manifest.get("requirements"), targets, artifact_ids,
    ))
    errors.extend(validate_layout_deviations(manifest.get("layout_deviations")))
    errors.extend(validate_toolchain(project_root, manifest.get("toolchain")))
    errors.extend(validate_licensing_and_provenance(
        project_root, manifest.get("licensing"), manifest.get("provenance"),
    ))
    if manifest.get("aggregate_gates") != {
        "pre_tag": ["make source-2-1-check"],
        "post_tag": ["make source-2-1-post-tag-audit"],
    }:
        errors.append("aggregate pre-tag or post-tag gate differs from Source 2.1")
    if require_ready:
        errors.extend(validate_repository_state(
            project_root, verify_tag, manifest.get("publish_remote"),
        ))
    elif verify_tag:
        errors.append("--verify-tag requires --require-ready")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit the Pac-Man Source 2.1 contract.")
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--require-ready", action="store_true")
    parser.add_argument("--verify-tag", action="store_true")
    args = parser.parse_args()
    try:
        document = read_json(args.manifest)
        errors = audit(args.project_root, document, args.require_ready, args.verify_tag)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors = [str(error)]
        document = {}
    if errors:
        for error in errors:
            print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    release = document["release"]
    print(f"[OK] {release['name']} manifest and repository contract are consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
