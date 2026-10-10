#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath

SCRIPTS_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS_ROOT / "build"))
sys.path.insert(0, str(SCRIPTS_ROOT / "runtime"))

from build_dev import load_toolchain_manifest  # noqa: E402
from documentation_audit import audit_documentation
from make_help import load_help, validate_help
from revision_profiles import Revision, load_manifest  # noqa: E402
from run_revision_smokes import validate_scenarios  # noqa: E402


EXPECTED_RELEASE_LINE = "2.x"
EXPECTED_RELEASE = {"name": "Source Reconstruction 2.2", "version": "2.2"}
EXPECTED_TAG = "source-reconstruction-2.2"
EXPECTED_RELEASE_SUBJECT = "Complete Source Reconstruction 2.2"
CODEX_TRAILER = "Co-Authored-By: Codex <noreply@openai.com>"
PUBLIC_TEXT_SUFFIXES = {
    ".asm", ".cfg", ".inc", ".json", ".lua", ".md", ".mk", ".py", ".txt",
    ".yaml", ".yml",
}
PUBLIC_TEXT_NAMES = {".gitignore", "Makefile"}
NON_ENGLISH_SCRIPT = re.compile(
    r"[\u0370-\u052f\u0590-\u08ff\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]"
)
EXPECTED_PREDECESSOR = {
    "tag": "source-reconstruction-2.1",
    "commit": "959bee80064aaa692e456cf710b527cc31bfba81",
    "manifest": "config/source_reconstruction_2_1.json",
}
EXPECTED_SCOPE = (
    "self_contained_release_metadata",
    "machine_readable_source_layout",
    "machine_readable_profile_contracts",
    "unified_output_layout",
    "responsibility_make_layout",
    "machine_readable_tooling_ownership",
    "romless_scaffold_and_generated_help",
    "workstation_ui_interaction_smokes",
    "canonical_movie_serialization",
    "reviewed_documentation_corpus",
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
    "public_release_metadata",
    "source_layout_ownership",
    "profile_contracts",
    "output_boundaries",
    "make_orchestration_layout",
    "tooling_layout_ownership",
    "public_interface_smoke",
    "workstation_ui_smokes",
    "movie_serialization",
    "documentation_corpus",
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


def validate_history(
    project_root: Path,
    predecessor: object,
    history: object,
    delta: object,
) -> list[str]:
    """Validate the complete substantive Git range and its release-delta map."""
    errors: list[str] = []
    if not isinstance(predecessor, dict):
        return ["release predecessor must be an object"]
    predecessor_commit = predecessor.get("commit")
    predecessor_tag = predecessor.get("tag")
    predecessor_manifest = predecessor.get("manifest")
    if not all(isinstance(value, str) and value for value in (
        predecessor_commit, predecessor_tag, predecessor_manifest,
    )):
        return ["release predecessor identity is incomplete"]
    if not isinstance(history, dict) or set(history) != {
        "range_start", "commit_count", "commits",
    }:
        return ["release history contract has an invalid shape"]
    if history.get("range_start") != predecessor_commit:
        errors.append("release history range does not start at the predecessor commit")
    mappings = history.get("commits")
    count = history.get("commit_count")
    if (
        not isinstance(count, int) or count < 1
        or not isinstance(mappings, list) or len(mappings) != count
    ):
        errors.append("release history count or mappings are invalid")
        return errors
    if not isinstance(delta, list):
        return errors + ["release delta must be a list for history validation"]
    delta_by_id = {
        row.get("id"): row for row in delta
        if isinstance(row, dict) and isinstance(row.get("id"), str)
    }
    expected_subjects: list[str] = []
    mapped_delta_ids: set[str] = set()
    for mapping in mappings:
        if not isinstance(mapping, dict) or set(mapping) != {"subject", "delta_ids", "paths"}:
            errors.append("release history mapping has an invalid shape")
            continue
        subject = mapping.get("subject")
        delta_ids = mapping.get("delta_ids")
        paths = mapping.get("paths")
        if (
            not isinstance(subject, str) or not subject
            or not isinstance(delta_ids, list) or not delta_ids
            or not isinstance(paths, list) or not paths
            or any(not isinstance(path, str) or not path for path in paths)
            or any(
                not isinstance(delta_id, str) or delta_id not in delta_by_id
                for delta_id in delta_ids
            )
        ):
            errors.append("release history mapping references an invalid subject or delta ID")
            continue
        expected_subjects.append(subject)
        mapped_delta_ids.update(delta_ids)
    if len(expected_subjects) != len(mappings):
        return errors
    if mapped_delta_ids != set(delta_by_id):
        errors.append("release history mappings do not cover every delta entry")

    try:
        if git_output(project_root, "cat-file", "-t", predecessor_tag) != "tag":
            errors.append("predecessor tag must remain annotated")
        if git_output(project_root, "rev-list", "-n", "1", predecessor_tag) != predecessor_commit:
            errors.append("predecessor tag no longer resolves to the declared commit")
        hashes_text = git_output(
            project_root, "rev-list", "--reverse", f"{predecessor_commit}..HEAD",
        )
        hashes = hashes_text.splitlines() if hashes_text else []
    except ValueError as error:
        return errors + [str(error)]
    if len(hashes) != count:
        errors.append(
            f"release history contains {len(hashes)} commits after predecessor, expected {count}"
        )
        return errors

    actual_subjects: list[str] = []
    for commit, mapping in zip(hashes, mappings):
        try:
            subject = git_output(project_root, "show", "-s", "--format=%s", commit)
            body = git_output(project_root, "show", "-s", "--format=%b", commit)
            tree = git_output(project_root, "show", "-s", "--format=%T", commit)
            parents = git_output(project_root, "show", "-s", "--format=%P", commit).split()
            parent_trees = [
                git_output(project_root, "show", "-s", "--format=%T", parent)
                for parent in parents
            ]
            changed_text = git_output(
                project_root, "diff-tree", "--no-commit-id", "--name-only", "-r", commit,
            )
        except ValueError as error:
            errors.append(str(error))
            continue
        actual_subjects.append(subject)
        if parent_trees and all(tree == parent_tree for parent_tree in parent_trees):
            errors.append(f"empty commit is forbidden in the release range: {commit}")
        if len(parents) == 1:
            if (
                not subject.isascii() or not body.isascii()
                or subject.endswith(".")
                or subject.casefold() in {"fix", "update", "changes", "wip"}
            ):
                errors.append(f"commit title/body policy failed: {commit}")
            if body.count(CODEX_TRAILER) != 1 or not body.rstrip().endswith(CODEX_TRAILER):
                errors.append(f"commit lacks the exact final Codex trailer: {commit}")
            body_without_trailer = body.rsplit(CODEX_TRAILER, 1)[0].rstrip()
            paragraphs = [
                paragraph for paragraph in re.split(r"\r?\n\s*\r?\n", body_without_trailer)
                if paragraph
            ]
            if len(paragraphs) not in {2, 3}:
                errors.append(f"commit body must contain two or three paragraphs: {commit}")
        changed_paths = set(changed_text.splitlines()) if changed_text else set()
        declared_paths = set(mapping["paths"])
        if changed_paths != declared_paths or len(mapping["paths"]) != len(declared_paths):
            missing = sorted(changed_paths - declared_paths)
            stale = sorted(declared_paths - changed_paths)
            errors.append(
                f"commit {commit} paths differ from its delta mapping"
                f" (missing: {', '.join(missing) or '-'}; stale: {', '.join(stale) or '-'})"
            )
    if actual_subjects != expected_subjects:
        errors.append("release history subjects or order differ from the manifest mapping")
    return errors


def validate_public_text_language(project_root: Path) -> list[str]:
    """Enforce English project text and reject Cyrillic without exceptions."""
    try:
        tracked = git_output(project_root, "ls-files", "-z").split("\0")
    except ValueError as error:
        return [str(error)]
    errors: list[str] = []
    for value in tracked:
        if not value:
            continue
        relative = PurePosixPath(value)
        if relative.name not in PUBLIC_TEXT_NAMES and relative.suffix not in PUBLIC_TEXT_SUFFIXES:
            continue
        path = project_root.joinpath(*relative.parts)
        if not path.is_file():
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except (OSError, UnicodeDecodeError) as error:
            errors.append(f"cannot read tracked public text {value}: {error}")
            continue
        hits = [
            str(index) for index, line in enumerate(lines, 1)
            if NON_ENGLISH_SCRIPT.search(line)
        ]
        if hits:
            errors.append(
                f"tracked public text contains non-English script: {value}"
                f" (lines {', '.join(hits[:8])})"
            )
    return errors


def validate_release_metadata(manifest: dict[str, object]) -> list[str]:
    errors: list[str] = []
    if manifest.get("release_line") != EXPECTED_RELEASE_LINE:
        errors.append("release line differs from Source 2.2")
    if manifest.get("release") != EXPECTED_RELEASE:
        errors.append("release identity differs from Source 2.2")
    if manifest.get("release_kind") != "compatible_minor":
        errors.append("Source 2.2 must declare a compatible_minor release")
    if manifest.get("tag") != EXPECTED_TAG:
        errors.append("release tag differs from Source 2.2")
    if manifest.get("predecessor") != EXPECTED_PREDECESSOR:
        errors.append("predecessor identity differs from Source 2.1")
    if manifest.get("included_scope") != list(EXPECTED_SCOPE):
        errors.append("included scope or order differs from Source 2.2")
    delta = manifest.get("delta")
    if not isinstance(delta, list) or not delta:
        errors.append("release delta must contain evidence-backed entries")
    else:
        delta_ids: list[str] = []
        for row in delta:
            if not isinstance(row, dict) or not all(
                row.get(key) for key in ("id", "kind", "summary", "evidence")
            ):
                errors.append("release delta contains an incomplete entry")
                break
            delta_ids.append(row["id"])
            if row["kind"] not in {"evidence", "source", "tooling", "documentation"}:
                errors.append(f"invalid release delta kind: {row['kind']}")
            if not isinstance(row["evidence"], list) or any(
                not isinstance(value, str) or not value for value in row["evidence"]
            ):
                errors.append(f"invalid release delta evidence: {row['id']}")
        if len(delta_ids) != len(set(delta_ids)):
            errors.append("release delta IDs must be unique")
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


def parse_address(value: object, field: str) -> int:
    if not isinstance(value, str) or not re.fullmatch(r"0x[0-9A-Fa-f]{4}", value):
        raise ValueError(f"invalid {field}: {value!r}")
    return int(value, 16)


def validate_source_layout(project_root: Path, path: Path) -> list[str]:
    try:
        document = read_json(path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"invalid source-layout registry: {error}"]
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        return ["unsupported source-layout registry schema"]
    errors: list[str] = []
    try:
        window = document["cpu_window"]
        if not isinstance(window, dict):
            raise ValueError("cpu_window must be an object")
        cursor = parse_address(window.get("start"), "CPU window start")
        window_end = parse_address(window.get("end"), "CPU window end")
    except (KeyError, ValueError) as error:
        return [str(error)]
    modules = document.get("modules")
    if not isinstance(modules, list) or not modules:
        return ["source-layout registry has no modules"]
    paths: list[str] = []
    for expected_order, row in enumerate(modules, 1):
        if not isinstance(row, dict):
            errors.append(f"source-layout row {expected_order} is not an object")
            continue
        module_path = row.get("path")
        if row.get("order") != expected_order:
            errors.append(f"source-layout order mismatch at row {expected_order}")
        if not isinstance(module_path, str) or not module_path.startswith("src/"):
            errors.append(f"invalid source-layout path at row {expected_order}")
            continue
        paths.append(module_path)
        source_path = project_root / module_path
        if not source_path.is_file():
            errors.append(f"missing source-layout module: {module_path}")
        if not isinstance(row.get("responsibility"), str) or not row["responsibility"]:
            errors.append(f"source-layout module lacks responsibility: {module_path}")
        if row.get("kind") not in {
            "semantic-code", "owned-data", "generated-data-wrapper", "fixed-tail",
        }:
            errors.append(f"invalid source-layout kind: {module_path}")
        try:
            start = parse_address(row.get("start"), f"start for {module_path}")
            end = parse_address(row.get("end"), f"end for {module_path}")
        except ValueError as error:
            errors.append(str(error))
            continue
        if start != cursor:
            errors.append(
                f"source-layout gap or overlap before {module_path}: "
                f"expected 0x{cursor:04X}, got 0x{start:04X}"
            )
        if end < start:
            errors.append(f"source-layout range is reversed: {module_path}")
        cursor = end + 1
        if source_path.is_file():
            line_count = len(source_path.read_text(encoding="utf-8").splitlines())
            exception = row.get("size_exception")
            if (line_count < 25 or line_count > 900) and not isinstance(exception, dict):
                errors.append(
                    f"source-layout size exception is required for {module_path}: "
                    f"{line_count} lines"
                )
            if isinstance(exception, dict) and not all(
                isinstance(exception.get(key), str) and exception[key]
                for key in ("kind", "reason")
            ):
                errors.append(f"invalid source-layout size exception: {module_path}")
    if len(paths) != len(set(paths)):
        errors.append("source-layout module paths are not unique")
    if cursor != window_end + 1:
        errors.append(
            f"source-layout ends at 0x{cursor - 1:04X}, expected 0x{window_end:04X}"
        )
    entrypoint = project_root / str(document.get("canonical_entrypoint", ""))
    if not entrypoint.is_file():
        errors.append("source-layout canonical entrypoint is missing")
        return errors
    includes = re.findall(
        r'^\s*\.include\s+"([^"]+)"',
        entrypoint.read_text(encoding="utf-8"),
        re.MULTILINE,
    )
    relative_modules = [value.removeprefix("src/") for value in paths]
    actual_modules = [value for value in includes if value in set(relative_modules)]
    if actual_modules != relative_modules:
        errors.append("source-layout module order differs from canonical entrypoint")
    non_emitting = document.get("non_emitting_includes")
    if not isinstance(non_emitting, list) or not all(
        isinstance(value, str) and (project_root / value).is_file()
        for value in non_emitting
    ):
        errors.append("source-layout non-emitting include list is invalid")
    else:
        expected_non_emitting = [value.removeprefix("src/") for value in non_emitting]
        actual_non_emitting = [value for value in includes if value not in set(relative_modules)]
        if actual_non_emitting != expected_non_emitting:
            errors.append("non-emitting include order differs from canonical entrypoint")
    variants = document.get("variant_entrypoints")
    if not isinstance(variants, list) or not all(
        isinstance(value, str) and (project_root / value).is_file() for value in variants
    ):
        errors.append("source-layout variant entrypoints are invalid")
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
    for key in (
        "canonical_source", "revision_ids", "source_layout_registry",
        "tooling_layout_registry", "documentation_layout_registry",
        "label_rename_registry", "make_help_manifest", "ui_smoke_manifest",
    ):
        value = contract.get(key)
        if not isinstance(value, str) or not (project_root / value).is_file():
            errors.append(f"missing layout path: {value}")
    registry = contract.get("source_layout_registry")
    if isinstance(registry, str):
        errors.extend(validate_source_layout(project_root, project_root / registry))
    for key in (
        "variant_entrypoints", "linker_configs", "required_test_modules",
        "make_fragments",
    ):
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
    if contract.get("label_rename_registry") != "config/reconstruction/label_renames.json":
        errors.append("label rename registry must use its canonical reconstruction path")
    try:
        rename_registries = git_output(project_root, "ls-files", "*label_renames.json").splitlines()
        if rename_registries != ["config/reconstruction/label_renames.json"]:
            errors.append("tracked label rename registry must be unique and canonical")
    except ValueError as error:
        errors.append(str(error))
    root_makefile = project_root / "Makefile"
    if root_makefile.is_file():
        root_lines = len(root_makefile.read_text(encoding="utf-8").splitlines())
        if root_lines > 300:
            errors.append(f"root Makefile exceeds 300 lines: {root_lines}")
        fragments = contract.get("make_fragments")
        if isinstance(fragments, list):
            root_text = root_makefile.read_text(encoding="utf-8")
            expected_includes = [f"include $(PROJECT_DIR){path}" for path in fragments]
            actual_includes = [
                line for line in root_text.splitlines() if line.startswith("include ")
            ]
            if actual_includes != expected_includes:
                errors.append("Makefile fragment include order differs from layout contract")
            for value in fragments:
                fragment = project_root / value
                if fragment.is_file():
                    line_count = len(fragment.read_text(encoding="utf-8").splitlines())
                    if line_count > 350:
                        errors.append(f"Make fragment exceeds 350 lines: {value}")
    return errors


# Source Reconstruction 3.0 retired the authoring group with the editors.
EXPECTED_TOOL_RESPONSIBILITIES = {
    "build", "launcher", "runtime", "validation", "workflow",
}


def validate_tooling_layout(project_root: Path, path: Path) -> list[str]:
    """Verify complete script ownership and public-command test ownership."""
    try:
        document = read_json(path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"invalid tooling-layout registry: {error}"]
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        return ["unsupported tooling-layout registry schema"]

    errors: list[str] = []
    if document.get("stable_launcher") != "scripts/run.py":
        errors.append("tooling registry must declare scripts/run.py as stable launcher")
    if document.get("scripts_root") != "scripts" or document.get("tests_root") != "tests":
        errors.append("tooling registry roots differ from repository layout")

    responsibilities = document.get("responsibilities")
    if not isinstance(responsibilities, list) or not responsibilities:
        return errors + ["tooling registry has no responsibility groups"]

    owned_paths: list[str] = []
    owners_by_path: dict[str, set[str]] = {}
    responsibility_ids: list[str] = []
    for row in responsibilities:
        if not isinstance(row, dict) or set(row) != {"id", "paths", "test_owners"}:
            errors.append("tooling responsibility has an invalid shape")
            continue
        responsibility = row.get("id")
        paths = row.get("paths")
        test_owners = row.get("test_owners")
        if not isinstance(responsibility, str):
            errors.append("tooling responsibility lacks an ID")
            continue
        responsibility_ids.append(responsibility)
        if not isinstance(paths, list) or not paths or not all(
            isinstance(value, str) and value for value in paths
        ):
            errors.append(f"tooling responsibility {responsibility} has invalid paths")
            continue
        if not isinstance(test_owners, list) or not test_owners or not all(
            isinstance(value, str)
            and value.startswith("tests/")
            and Path(value).name.startswith("test_")
            and value.endswith(".py")
            and (project_root / value).is_file()
            for value in test_owners
        ):
            errors.append(f"tooling responsibility {responsibility} has invalid test owners")
            continue
        owner_set = set(test_owners)
        for value in paths:
            owned_paths.append(value)
            owners_by_path[value] = owner_set
            tool_path = project_root / value
            if not value.startswith("scripts/") or Path(value).suffix not in {".py", ".lua"}:
                errors.append(f"invalid owned tool path: {value}")
            elif not tool_path.is_file():
                errors.append(f"missing owned tool: {value}")

    if set(responsibility_ids) != EXPECTED_TOOL_RESPONSIBILITIES:
        errors.append("tooling responsibility IDs differ from Source 2.2")
    if len(responsibility_ids) != len(set(responsibility_ids)):
        errors.append("tooling responsibility IDs are not unique")
    if len(owned_paths) != len(set(owned_paths)):
        errors.append("tooling paths have multiple responsibility owners")

    scripts_root = project_root / "scripts"
    actual_paths = sorted(
        path.relative_to(project_root).as_posix()
        for path in scripts_root.rglob("*")
        if path.is_file()
        and path.suffix in {".py", ".lua"}
        and "__pycache__" not in path.parts
    )
    if sorted(owned_paths) != actual_paths:
        missing = sorted(set(actual_paths) - set(owned_paths))
        stale = sorted(set(owned_paths) - set(actual_paths))
        if missing:
            errors.append("unowned tooling paths: " + ", ".join(missing))
        if stale:
            errors.append("stale tooling paths: " + ", ".join(stale))

    public_commands = document.get("public_commands")
    if not isinstance(public_commands, list) or not public_commands:
        return errors + ["tooling registry has no public commands"]
    command_names: list[str] = []
    command_paths: list[str] = []
    for row in public_commands:
        if not isinstance(row, dict) or set(row) != {"name", "path", "test_owner"}:
            errors.append("public tooling command has an invalid shape")
            continue
        name = row.get("name")
        tool_path = row.get("path")
        test_owner = row.get("test_owner")
        if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
            errors.append(f"invalid public tooling command name: {name!r}")
            continue
        command_names.append(name)
        if not isinstance(tool_path, str) or tool_path not in owners_by_path:
            errors.append(f"public command {name} refers to an unowned tool")
            continue
        command_paths.append(tool_path)
        if Path(tool_path).suffix != ".py":
            errors.append(f"public command {name} must dispatch to Python")
        if not isinstance(test_owner, str) or test_owner not in owners_by_path[tool_path]:
            errors.append(f"public command {name} lacks its declared test owner")
    if len(command_names) != len(set(command_names)):
        errors.append("public tooling command names are not unique")
    if len(command_paths) != len(set(command_paths)):
        errors.append("public tooling command paths are not unique")

    threshold = document.get("python_review_threshold")
    exceptions = document.get("size_exceptions")
    if threshold != 700 or not isinstance(exceptions, list):
        errors.append("tooling Python size-review contract is invalid")
        return errors
    exception_paths: list[str] = []
    for row in exceptions:
        required = {"path", "threshold", "reason", "cohesion", "split_decision"}
        if not isinstance(row, dict) or set(row) != required:
            errors.append("tooling size exception has an invalid shape")
            continue
        exception_path = row.get("path")
        if not isinstance(exception_path, str):
            errors.append("tooling size exception lacks a path")
            continue
        exception_paths.append(exception_path)
        if row.get("threshold") != threshold or not all(
            isinstance(row.get(key), str) and row[key]
            for key in ("reason", "cohesion", "split_decision")
        ):
            errors.append(f"tooling size exception is incomplete: {exception_path}")
    oversized = {
        value
        for value in actual_paths
        if value.endswith(".py")
        and len((project_root / value).read_text(encoding="utf-8").splitlines()) > threshold
    }
    if set(exception_paths) != oversized or len(exception_paths) != len(set(exception_paths)):
        errors.append("tooling size exceptions differ from Python files above 700 lines")
    oversized_tests = [
        path.relative_to(project_root).as_posix()
        for path in (project_root / "tests").glob("test_*.py")
        if len(path.read_text(encoding="utf-8").splitlines()) > 600
    ]
    if oversized_tests:
        errors.append("test modules exceed the 600-line review threshold: " + ", ".join(oversized_tests))
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
        errors.append("revision manifest format differs from Source 2.2 contract")
    if not isinstance(document, dict) or document.get(
        "profile_contract_version"
    ) != contract.get("profile_contract_version"):
        errors.append("profile contract version differs from Source 2.2 contract")
    if [revision.profile_id for revision in revisions] != contract.get("profile_ids"):
        errors.append("revision profile IDs or order differ from Source 2.2 contract")
    if [revision.ca65_revision for revision in revisions] != contract.get("ca65_revisions"):
        errors.append("ca65 revision IDs or order differ from Source 2.2 contract")
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
            "id": revision.artifact_id,
            "profile": revision.profile_id,
            "build_target": (
                f"make verify-revision REVISION={revision.profile_id}"
            ),
            "size": revision.output_size,
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
            "artifact": revision.artifact_id,
            "identity": revision.identity,
        }
        for revision in revisions
    ]
    return [] if contract == expected else ["accepted profiles differ from revision manifest"]


def make_targets(makefile: str) -> set[str]:
    return set(re.findall(r"^([A-Za-z0-9][A-Za-z0-9_.-]*):", makefile, re.MULTILINE))


def makefile_paths(project_root: Path) -> list[Path]:
    return [
        project_root / "Makefile",
        *sorted((project_root / "mk").glob("*.mk")),
    ]


def repository_make_targets(project_root: Path) -> set[str]:
    targets: set[str] = set()
    for path in makefile_paths(project_root):
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
    require_ready: bool,
) -> list[str]:
    if not isinstance(contract, dict) or set(contract) != EXPECTED_REQUIREMENTS:
        return ["requirement IDs differ from the Source 2.2 contract"]
    errors: list[str] = []
    for requirement_id, requirement in contract.items():
        if not isinstance(requirement, dict):
            errors.append(f"requirement is invalid: {requirement_id}")
            continue
        status = requirement.get("status")
        allowed = {"satisfied"} if require_ready else {
            "satisfied", "partial", "unsupported", "planned",
        }
        if status not in allowed:
            errors.append(f"requirement has invalid status: {requirement_id}")
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


EXPECTED_OUTPUT_LAYOUT = {
    "build_root": "build",
    "authoring_workspace": "content/workspace",
    "generated_assets": "assets/generated",
    "clean_target": "clean",
    "clean_script": "scripts/build/clean_artifacts.py",
    "legacy_local_paths_preserved": [
        "tmp", "workflow", "reference", "diffs", "reports", "hacks/local",
    ],
}


def validate_output_layout(project_root: Path, contract: object) -> list[str]:
    if contract != EXPECTED_OUTPUT_LAYOUT:
        return ["output layout differs from the Source 2.2 contract"]
    errors: list[str] = []
    ignore = (project_root / ".gitignore").read_text(encoding="utf-8").splitlines()
    for ignored in ("/build/", "/assets/generated/", "/content/workspace/"):
        if ignored not in ignore:
            errors.append(f"generated/private path is not ignored: {ignored}")
    makefile = "\n".join(
        path.read_text(encoding="utf-8") for path in makefile_paths(project_root)
    )
    forbidden_make_paths = (
        "$(PROJECT_DIR)tmp", "?= reference", "?= diffs", "?= workflow",
        "$(PROJECT_DIR)hacks/local",
    )
    for value in forbidden_make_paths:
        if value in makefile:
            errors.append(
                f"Makefile still emits outside the build/workspace roots: {value}"
            )
    try:
        tracked = git_output(
            project_root, "ls-files", "--", "tmp", "workflow", "reference",
            "diffs", "reports", "content/workspace", "assets/generated",
        )
        if tracked:
            errors.append("generated or private output paths contain tracked files")
    except ValueError as error:
        errors.append(str(error))
    clean_script = project_root / EXPECTED_OUTPUT_LAYOUT["clean_script"]
    if not clean_script.is_file():
        errors.append("canonical clean script is missing")
    return errors


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
            "verification": "make verify",
        },
        {
            "id": "linker",
            "version": components["ld65"]["version"],
            "source": components["ld65"]["source"],
            "source_commit": components["ld65"]["source_commit"],
            "binary_sha256": components["ld65"]["binary_sha256"],
            "provenance": components["ld65"]["provenance"],
            "verification": "make verify",
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
        if subject != EXPECTED_RELEASE_SUBJECT:
            errors.append("release commit title differs from the contract")
        paragraphs = [
            paragraph for paragraph in re.split(r"\r?\n\s*\r?\n", body)
            if paragraph and not paragraph.startswith("Co-Authored-By:")
        ]
        if len(paragraphs) not in {2, 3}:
            errors.append("release commit body must contain two or three paragraphs")
        if body.count(CODEX_TRAILER) != 1 or not body.rstrip().endswith(CODEX_TRAILER):
            errors.append("release commit lacks the required Codex attribution")
        if not all(term in body for term in ("source-2-2-check", "excluded", "manifest")):
            errors.append("release commit body lacks delta, gate, or scope evidence")
        if verify_tag:
            if git_output(project_root, "cat-file", "-t", EXPECTED_TAG) != "tag":
                errors.append("Source 2.2 tag must be annotated")
            tag_commit = git_output(project_root, "rev-list", "-n", "1", EXPECTED_TAG)
            head = git_output(project_root, "rev-parse", "HEAD")
            if tag_commit != head:
                errors.append("Source 2.2 tag does not resolve to HEAD")
        else:
            if git_ref_exists(project_root, f"refs/tags/{EXPECTED_TAG}"):
                errors.append("future Source 2.2 tag already exists locally")
            if not isinstance(publish_remote, str) or not publish_remote:
                errors.append("release manifest lacks a publish remote")
            elif remote_tag_exists(project_root, publish_remote, EXPECTED_TAG):
                errors.append("future Source 2.2 tag already exists on publish remote")
    except ValueError as error:
        errors.append(str(error))
    return errors


def audit(
    project_root: Path, manifest: object, require_ready: bool, verify_tag: bool = False,
) -> list[str]:
    if not isinstance(manifest, dict) or manifest.get("schema_version") != 2:
        return ["unsupported Source 2.2 manifest schema"]
    errors = validate_release_metadata(manifest)
    errors.extend(validate_public_text_language(project_root))
    if require_ready and manifest.get("status") != "tag-ready":
        errors.append("Source 2.2 manifest is not tag-ready")
    elif manifest.get("status") not in {"development", "tag-ready"}:
        errors.append("unsupported Source 2.2 release status")
    errors.extend(validate_delta_evidence(project_root, manifest.get("delta")))
    errors.extend(validate_history(
        project_root, manifest.get("predecessor"), manifest.get("history"),
        manifest.get("delta"),
    ))
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
    layout = manifest.get("layout")
    tooling_registry = layout.get("tooling_layout_registry") if isinstance(layout, dict) else None
    if isinstance(tooling_registry, str):
        errors.extend(validate_tooling_layout(project_root, project_root / tooling_registry))
    documentation_registry = (
        layout.get("documentation_layout_registry") if isinstance(layout, dict) else None
    )
    if isinstance(documentation_registry, str):
        try:
            errors.extend(audit_documentation(
                project_root, read_json(project_root / documentation_registry),
            ))
        except (OSError, ValueError, json.JSONDecodeError) as error:
            errors.append(f"invalid documentation layout manifest: {error}")
    help_manifest = layout.get("make_help_manifest") if isinstance(layout, dict) else None
    if isinstance(help_manifest, str):
        try:
            errors.extend(validate_help(project_root, load_help(project_root / help_manifest)))
        except (OSError, ValueError, json.JSONDecodeError) as error:
            errors.append(f"invalid Make help manifest: {error}")
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
        require_ready,
    ))
    errors.extend(validate_layout_deviations(manifest.get("layout_deviations")))
    errors.extend(validate_output_layout(project_root, manifest.get("output_layout")))
    errors.extend(validate_toolchain(project_root, manifest.get("toolchain")))
    errors.extend(validate_licensing_and_provenance(
        project_root, manifest.get("licensing"), manifest.get("provenance"),
    ))
    if manifest.get("aggregate_gates") != {
        "pre_tag": ["make source-2-2-check"],
        "post_tag": ["make source-2-2-post-tag-audit"],
    }:
        errors.append("aggregate pre-tag or post-tag gate differs from Source 2.2")
    if require_ready:
        errors.extend(validate_repository_state(
            project_root, verify_tag, manifest.get("publish_remote"),
        ))
    elif verify_tag:
        errors.append("--verify-tag requires --require-ready")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit the Pac-Man Source 2.2 contract.")
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
