#!/usr/bin/env python3
"""Validate the task-oriented documentation corpus."""

from __future__ import annotations

import argparse
import json
import re
from collections import defaultdict
from pathlib import Path, PurePosixPath
from urllib.parse import unquote


LINK_PATTERN = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
def topic_prefix(path: str) -> str:
    """Return a stable prefix used to flag flat filename clusters."""
    parts = PurePosixPath(path).stem.split("_")
    return "_".join(parts[:2]) if len(parts) > 1 else parts[0]


def markdown_inventory(project_root: Path, docs_root: str) -> set[str]:
    root = project_root / docs_root
    return {
        path.relative_to(project_root).as_posix()
        for path in root.rglob("*.md")
        if path.is_file()
    }


def local_link_errors(project_root: Path, paths: set[str]) -> list[str]:
    errors: list[str] = []
    for relative in sorted(paths):
        path = project_root / relative
        text = path.read_text(encoding="utf-8")
        for raw_target in LINK_PATTERN.findall(text):
            target = raw_target.strip().strip("<>").split("#", 1)[0]
            if not target or target.startswith(("http://", "https://", "mailto:")):
                continue
            resolved = (path.parent / unquote(target)).resolve()
            try:
                resolved.relative_to(project_root.resolve())
            except ValueError:
                errors.append(f"documentation link escapes project root: {relative} -> {target}")
                continue
            if not resolved.exists():
                errors.append(f"broken documentation link: {relative} -> {target}")
    return errors


def audit_documentation(project_root: Path, layout: object) -> list[str]:
    if not isinstance(layout, dict) or layout.get("schema_version") != 1:
        return ["unsupported documentation layout schema"]
    errors: list[str] = []
    docs_root = layout.get("docs_root")
    project_documents = layout.get("project_documents")
    if not isinstance(docs_root, str) or not isinstance(project_documents, list):
        return ["documentation layout lacks its root or project inventory"]

    project_set = {item for item in project_documents if isinstance(item, str)}
    if len(project_set) != len(project_documents):
        errors.append("project documentation inventory contains duplicates or invalid paths")
    actual = markdown_inventory(project_root, docs_root)
    if actual != project_set:
        missing = project_set - actual
        unowned = actual - project_set
        if missing:
            errors.append("declared documentation is missing: " + ", ".join(sorted(missing)))
        if unowned:
            errors.append("documentation is not inventoried: " + ", ".join(sorted(unowned)))

    for key in ("index", "review"):
        value = layout.get(key)
        if value not in project_set:
            errors.append(f"documentation {key} is not a project document")
    size_policy = layout.get("size_policy")
    if not isinstance(size_policy, dict):
        errors.append("documentation layout lacks a size policy")
    else:
        maximum = size_policy.get("recommended_max_lines")
        exception_rows = size_policy.get("exceptions")
        if not isinstance(maximum, int) or not isinstance(exception_rows, list):
            errors.append("documentation size policy is invalid")
        else:
            exceptions = {
                row.get("path"): row.get("reason")
                for row in exception_rows if isinstance(row, dict)
            }
            for relative in sorted(project_set):
                path = project_root / relative
                if not path.is_file():
                    continue
                lines = len(path.read_text(encoding="utf-8").splitlines())
                if lines > maximum and not exceptions.get(relative):
                    errors.append(f"oversized project document lacks a review exception: {relative}")
            for relative, reason in exceptions.items():
                if relative not in project_set or not isinstance(reason, str) or not reason:
                    errors.append(f"invalid documentation size exception: {relative}")

    prefix_policy = layout.get("prefix_policy")
    if not isinstance(prefix_policy, dict):
        errors.append("documentation layout lacks a prefix policy")
    else:
        minimum = prefix_policy.get("minimum_cluster_size")
        exception_rows = prefix_policy.get("exceptions")
        if not isinstance(minimum, int) or minimum < 2 or not isinstance(exception_rows, list):
            errors.append("documentation prefix policy is invalid")
        else:
            exceptions = {
                row.get("prefix"): row.get("reason")
                for row in exception_rows if isinstance(row, dict)
            }
            clusters: dict[str, list[str]] = defaultdict(list)
            for relative in project_set:
                if PurePosixPath(relative).parent == PurePosixPath(docs_root):
                    clusters[topic_prefix(relative)].append(relative)
            for prefix, paths in sorted(clusters.items()):
                if len(paths) >= minimum and not exceptions.get(prefix):
                    errors.append(
                        f"documentation prefix cluster lacks a review exception: {prefix} "
                        f"({', '.join(sorted(paths))})"
                    )

    journeys = layout.get("reader_journeys")
    if not isinstance(journeys, list) or not journeys:
        errors.append("documentation layout lacks reader journeys")
    else:
        for journey in journeys:
            if not isinstance(journey, dict) or not isinstance(journey.get("id"), str):
                errors.append("documentation layout contains an invalid reader journey")
                continue
            paths = journey.get("paths")
            if not isinstance(paths, list) or not paths:
                errors.append(f"reader journey has no paths: {journey['id']}")
                continue
            for relative in paths:
                if not isinstance(relative, str) or not (project_root / relative).is_file():
                    errors.append(f"reader journey path is missing: {journey['id']} -> {relative}")

    errors.extend(local_link_errors(project_root, project_set))
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--layout", type=Path, required=True)
    args = parser.parse_args(argv)
    try:
        document = json.loads(args.layout.read_text(encoding="utf-8"))
        errors = audit_documentation(args.project_root.resolve(), document)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors = [str(error)]
    if errors:
        for error in errors:
            print(f"[FAIL] {error}")
        return 1
    print("[OK] Documentation inventory, reader journeys, links, sizes, and filename clusters are consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
