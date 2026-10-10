#!/usr/bin/env python3
"""Run a published release's own audit in a checkout of its tag.

A release manifest describes the tree it was tagged with. Once the repository
moves on (Source Reconstruction 3.0 retired the editors the 2.2 manifest
audits), the audit runs where that tree still is: a disposable clone of this
repository, with its tags, checked out at the release tag. The command is the
tag's own script; `{root}` in it names the clone.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]


def run_at_tag(project_root: Path, tag: str, command: list[str]) -> int:
    if not command:
        raise ValueError("no audit command given")
    with tempfile.TemporaryDirectory(prefix="tag-audit-") as directory:
        clone = Path(directory) / "repository"
        for step in (["git", "clone", "--quiet", "--no-hardlinks", str(project_root), str(clone)],
                     ["git", "-C", str(clone), "checkout", "--quiet", "--detach", f"refs/tags/{tag}"]):
            completed = subprocess.run(step, capture_output=True, text=True, check=False)
            if completed.returncode:
                raise ValueError(f"cannot check out {tag}: {completed.stderr.strip()}")
        arguments = [part.replace("{root}", str(clone)) for part in command]
        print(f"[RUN] at {tag}: " + " ".join(command), flush=True)
        return subprocess.run([sys.executable, str(clone / arguments[0]), *arguments[1:]],
                              cwd=clone, check=False).returncode


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", required=True)
    parser.add_argument("command", nargs=argparse.REMAINDER,
                        help="after --: the tag's script, relative to the root, and its arguments")
    args = parser.parse_args(argv)
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    try:
        return run_at_tag(PROJECT_ROOT, args.tag, command)
    except ValueError as error:
        print(f"[FAIL] {error}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
