#!/usr/bin/env python3
"""Check that locally editable generated assets exist without changing them."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path, PurePosixPath


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def asset_path(root: Path, relative: str) -> Path:
    posix = PurePosixPath(relative)
    if posix.is_absolute() or not posix.parts or ".." in posix.parts:
        fail(f"unsafe asset path in manifest: {relative!r}")
    destination = root.joinpath(*posix.parts)
    try:
        destination.resolve().relative_to(root.resolve())
    except ValueError:
        fail(f"asset path escapes asset directory: {relative!r}")
    return destination


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, help="asset range manifest")
    parser.add_argument("--asset-dir", required=True, help="local asset root")
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    asset_dir = Path(args.asset_dir)
    if not manifest_path.is_file():
        fail(f"manifest not found: {manifest_path}")
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read manifest: {exc}")
    if manifest.get("schema_version") != 1:
        fail("unsupported asset manifest schema")

    assets = manifest.get("assets")
    if not isinstance(assets, list) or not assets:
        fail("manifest has no assets")

    missing: list[str] = []
    for entry in assets:
        if not isinstance(entry, dict) or not isinstance(entry.get("path"), str):
            fail("asset entries must contain a string path")
        relative = entry["path"]
        if not asset_path(asset_dir, relative).is_file():
            missing.append(relative)

    if missing:
        print("[ERROR] Required local assets are missing:", file=sys.stderr)
        for relative in missing:
            print(f"  - {relative}", file=sys.stderr)
        print(
            "[ERROR] Run `make split` explicitly to extract the original assets.",
            file=sys.stderr,
        )
        print(
            "[ERROR] Build targets never extract or overwrite local asset edits.",
            file=sys.stderr,
        )
        return 1

    print(f"[OK] Found {len(assets)} local asset files (contents left untouched).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
