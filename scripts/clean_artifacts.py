#!/usr/bin/env python3
"""Remove only the canonical generated build tree from this repository."""

from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path


def clean_build_root(project_root: Path, build_root: Path, dry_run: bool) -> int:
    project_root = project_root.resolve()
    build_root = Path(os.path.abspath(build_root))
    canonical = project_root / "build"
    if build_root != canonical:
        raise ValueError(f"cleanup target must be the canonical build root: {canonical}")
    if build_root == project_root:
        raise ValueError("cleanup target must be a child of the project root")

    if build_root.is_symlink():
        if not dry_run:
            build_root.unlink()
        action = "WOULD REMOVE" if dry_run else "REMOVE"
        print(f"[{action}] {build_root.relative_to(project_root)}/")
        verb = "Would remove" if dry_run else "Removed"
        print(f"[OK] {verb} 1 artifact path(s).")
        return 0
    resolved_build_root = build_root.resolve()
    if project_root not in resolved_build_root.parents:
        raise ValueError("cleanup target must resolve inside the project root")

    if not build_root.exists() and not build_root.is_symlink():
        print("[OK] Removed 0 artifact path(s).")
        return 0
    if not dry_run:
        if build_root.is_symlink():
            build_root.unlink()
        else:
            shutil.rmtree(build_root)
    action = "WOULD REMOVE" if dry_run else "REMOVE"
    print(f"[{action}] {build_root.relative_to(project_root)}/")
    verb = "Would remove" if dry_run else "Removed"
    print(f"[OK] {verb} 1 artifact path(s).")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    try:
        return clean_build_root(project_root, project_root / "build", args.dry_run)
    except ValueError as error:
        print(f"[FAIL] {error}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
