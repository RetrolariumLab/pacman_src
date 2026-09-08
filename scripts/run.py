#!/usr/bin/env python3
"""Stable command dispatcher for repository Python tools."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = PROJECT_ROOT / "config/tooling_layout.json"


def load_commands(registry_path: Path = REGISTRY_PATH) -> dict[str, Path]:
    """Load and validate the public command-to-tool mapping."""
    document = json.loads(registry_path.read_text(encoding="utf-8"))
    rows = document.get("public_commands")
    if not isinstance(rows, list):
        raise ValueError("tooling registry public_commands must be a list")

    scripts_root = (PROJECT_ROOT / "scripts").resolve()
    commands: dict[str, Path] = {}
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("tooling registry contains an invalid public command")
        name = row.get("name")
        relative = row.get("path")
        if not isinstance(name, str) or not name or name in commands:
            raise ValueError(f"invalid or duplicate public command: {name!r}")
        if not isinstance(relative, str):
            raise ValueError(f"public command {name!r} has no tool path")
        target = (PROJECT_ROOT / relative).resolve()
        try:
            target.relative_to(scripts_root)
        except ValueError as error:
            raise ValueError(f"public command escapes scripts root: {name}") from error
        if target.suffix != ".py" or not target.is_file():
            raise ValueError(f"public command target is not a Python file: {relative}")
        commands[name] = target
    return commands


def print_help(commands: dict[str, Path]) -> None:
    print("usage: python scripts/run.py <command> [arguments]")
    print("       python scripts/run.py list")
    print()
    print("Public tool commands:")
    for name in sorted(commands):
        print(f"  {name}")


def main(argv: list[str] | None = None) -> int:
    arguments = list(sys.argv[1:] if argv is None else argv)
    try:
        commands = load_commands()
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"error: cannot load tooling registry: {error}", file=sys.stderr)
        return 2

    if not arguments or arguments[0] in {"-h", "--help", "help"}:
        print_help(commands)
        return 0
    if arguments[0] == "list":
        for name in sorted(commands):
            print(name)
        return 0

    command = arguments.pop(0)
    target = commands.get(command)
    if target is None:
        print(f"error: unknown tool command: {command}", file=sys.stderr)
        print("run 'python scripts/run.py list' to see available commands", file=sys.stderr)
        return 2
    completed = subprocess.run(
        [sys.executable, str(target), *arguments],
        cwd=PROJECT_ROOT,
        check=False,
    )
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
