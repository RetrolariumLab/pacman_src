#!/usr/bin/env python3
"""Remove generated build and analysis artifacts from this repository."""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    file_targets: tuple[Path, ...] = ()
    directory_targets = tuple(
        project_root / name
        for name in (
            "build",
            "workflow",
            "reference",
            "diffs",
            "reports",
        )
    )

    removed = 0
    for target in file_targets:
        if target.is_file():
            if not args.dry_run:
                target.unlink()
            action = "WOULD REMOVE" if args.dry_run else "REMOVE"
            print(f"[{action}] {target.relative_to(project_root)}")
            removed += 1
    for target in directory_targets:
        if target.is_dir() or target.is_symlink():
            if not args.dry_run:
                if target.is_symlink():
                    target.unlink()
                else:
                    shutil.rmtree(target)
            action = "WOULD REMOVE" if args.dry_run else "REMOVE"
            print(f"[{action}] {target.relative_to(project_root)}/")
            removed += 1

    verb = "Would remove" if args.dry_run else "Removed"
    print(f"[OK] {verb} {removed} artifact path(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
