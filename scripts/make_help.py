#!/usr/bin/env python3
"""Render and validate the machine-readable public Make interface."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = PROJECT_ROOT / "config/make_help.json"


def makefile_paths(project_root: Path) -> list[Path]:
    return [project_root / "Makefile", *sorted((project_root / "mk").glob("*.mk"))]


def defined_targets(project_root: Path) -> set[str]:
    targets: set[str] = set()
    for path in makefile_paths(project_root):
        text = path.read_text(encoding="utf-8")
        targets.update(re.findall(r"^([A-Za-z0-9][A-Za-z0-9_.-]*):", text, re.MULTILINE))
    return targets


def phony_targets(project_root: Path) -> set[str]:
    text = (project_root / "Makefile").read_text(encoding="utf-8")
    values: set[str] = set()
    for declaration in re.findall(r"^\.PHONY:\s*(.+)$", text, re.MULTILINE):
        values.update(declaration.split())
    return values


def load_help(path: Path) -> dict[str, object]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        raise ValueError("unsupported Make help manifest schema")
    return document


def validate_help(project_root: Path, document: dict[str, object]) -> list[str]:
    errors: list[str] = []
    categories = document.get("categories")
    hidden = document.get("hidden_targets")
    if not isinstance(categories, list) or not categories:
        return ["Make help manifest has no categories"]
    if not isinstance(hidden, list) or not all(
        isinstance(value, str) and value for value in hidden
    ):
        return ["Make help hidden_targets must be a string list"]

    category_ids: list[str] = []
    public_targets: list[str] = []
    for category in categories:
        if not isinstance(category, dict) or set(category) != {"id", "title", "commands"}:
            errors.append("Make help category has an invalid shape")
            continue
        category_id = category.get("id")
        title = category.get("title")
        commands = category.get("commands")
        if not isinstance(category_id, str) or not category_id:
            errors.append("Make help category lacks an ID")
            continue
        category_ids.append(category_id)
        if not isinstance(title, str) or not title:
            errors.append(f"Make help category {category_id} lacks a title")
        if not isinstance(commands, list) or not commands:
            errors.append(f"Make help category {category_id} has no commands")
            continue
        for command in commands:
            if not isinstance(command, dict) or set(command) != {"target", "usage", "summary"}:
                errors.append(f"Make help category {category_id} has an invalid command")
                continue
            target = command.get("target")
            if not isinstance(target, str) or not target:
                errors.append(f"Make help category {category_id} has an invalid target")
                continue
            public_targets.append(target)
            if not all(
                isinstance(command.get(key), str) and command[key]
                for key in ("usage", "summary")
            ):
                errors.append(f"Make help target {target} lacks usage or summary")

    if len(category_ids) != len(set(category_ids)):
        errors.append("Make help category IDs are not unique")
    if len(public_targets) != len(set(public_targets)):
        errors.append("Make help public targets are not unique")
    if len(hidden) != len(set(hidden)):
        errors.append("Make help hidden targets are not unique")
    if set(public_targets) & set(hidden):
        errors.append("Make help targets cannot be both public and hidden")

    declared = phony_targets(project_root)
    documented = set(public_targets) | set(hidden)
    if declared != documented:
        missing = sorted(declared - documented)
        stale = sorted(documented - declared)
        if missing:
            errors.append("undocumented public Make targets: " + ", ".join(missing))
        if stale:
            errors.append("stale Make help targets: " + ", ".join(stale))
    undefined = sorted(set(public_targets) - defined_targets(project_root))
    if undefined:
        errors.append("Make help refers to undefined targets: " + ", ".join(undefined))
    return errors


def render_help(document: dict[str, object]) -> str:
    categories = document["categories"]
    width = max(
        len(command["usage"])
        for category in categories
        for command in category["commands"]
    )
    lines = [str(document.get("title", "Project targets:"))]
    for category in categories:
        lines.extend(("", f"{category['title']}:"))
        for command in category["commands"]:
            lines.append(f"  make {command['usage']:<{width}}  {command['summary']}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=PROJECT_ROOT)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    try:
        document = load_help(args.manifest)
        errors = validate_help(args.project_root.resolve(), document)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors = [str(error)]
        document = {}
    if errors:
        for error in errors:
            print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    if args.check:
        count = sum(len(category["commands"]) for category in document["categories"])
        print(f"[OK] Make help covers {count} public targets.")
    else:
        print(render_help(document))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
