#!/usr/bin/env python3
"""Run ROM-less repository checks in a disposable tracked-file checkout."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SYNTHETIC_TESTS = (
    "tests.test_build_dev",
    "tests.test_clean_artifacts",
    "tests.test_data_formats",
    "tests.test_lint_source",
    "tests.test_make_help",
    "tests.test_scaffold_check",
    "tests.test_source_2_2_audit",
    "tests.test_tooling_layout",
    "tests.test_ui_smoke",
)


def repository_files(project_root: Path) -> list[Path]:
    completed = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=project_root,
        capture_output=True,
        check=False,
    )
    if completed.returncode:
        detail = completed.stderr.decode(errors="replace").strip()
        raise ValueError(f"cannot enumerate repository scaffold: {detail}")
    paths: list[Path] = []
    for raw in completed.stdout.split(b"\0"):
        if not raw:
            continue
        value = raw.decode("utf-8")
        pure = PurePosixPath(value)
        if pure.is_absolute() or ".." in pure.parts:
            raise ValueError(f"unsafe repository path: {value}")
        paths.append(Path(*pure.parts))
    return sorted(paths, key=lambda path: path.as_posix())


def copy_scaffold(project_root: Path, destination: Path, paths: list[Path]) -> None:
    for relative in paths:
        source = project_root / relative
        if not source.is_file():
            raise ValueError(f"repository entry is not a file: {relative.as_posix()}")
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def run(command: list[str], cwd: Path) -> None:
    print("[RUN] " + " ".join(command), flush=True)
    completed = subprocess.run(command, cwd=cwd, check=False)
    if completed.returncode:
        raise ValueError(
            f"scaffold command exited with {completed.returncode}: {' '.join(command)}"
        )


def validate_no_private_inputs(root: Path) -> None:
    forbidden = [
        path.relative_to(root).as_posix()
        for pattern in ("*.nes", "*.fds")
        for path in root.rglob(pattern)
    ]
    for relative in ("assets/generated", "content/workspace", "build"):
        if (root / relative).exists():
            forbidden.append(relative)
    if forbidden:
        raise ValueError("disposable scaffold contains private/generated inputs: " + ", ".join(forbidden))


def check_scaffold(project_root: Path, python: str, make: str) -> None:
    paths = repository_files(project_root)
    with tempfile.TemporaryDirectory(prefix="pacman-scaffold-") as directory:
        root = Path(directory) / "repository"
        root.mkdir()
        copy_scaffold(project_root, root, paths)
        validate_no_private_inputs(root)
        run(["git", "init", "-q"], root)
        run(["git", "-c", "core.autocrlf=false", "add", "-A"], root)
        run([make, "help-check"], root)
        run([make, "tool-list"], root)
        run([make, "ui-smoke-check"], root)
        run([python, "-m", "unittest", *SYNTHETIC_TESTS, "-v"], root)
        run([make, "source-2-2-audit"], root)
    print(f"[OK] ROM-less scaffold passed {len(SYNTHETIC_TESTS)} synthetic test modules and public Make smokes.")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=PROJECT_ROOT)
    parser.add_argument("--python", default=sys.executable)
    parser.add_argument("--make", default="make")
    args = parser.parse_args(argv)
    try:
        check_scaffold(args.project_root.resolve(), args.python, args.make)
    except (OSError, ValueError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
