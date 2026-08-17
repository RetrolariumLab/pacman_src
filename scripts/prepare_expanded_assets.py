#!/usr/bin/env python3
"""Initialize or encode editable JSON assets for the expanded ROM variant."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from data_formats import decode_maze, encode_maze


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("init", "encode"))
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    if args.operation == "init":
        if args.json.exists():
            print(f"[OK] Editable JSON already exists; left untouched: {args.json}")
            return 0
        document = decode_maze(args.source.read_bytes())
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
        print(f"[OK] Initialized editable maze JSON: {args.json}")
        return 0

    if args.output is None:
        parser.error("encode requires --output")
    document = json.loads(args.json.read_text(encoding="utf-8"))
    encoded = encode_maze(document)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(encoded)
    print(f"[OK] Encoded expanded maze asset: {args.output} ({len(encoded)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
