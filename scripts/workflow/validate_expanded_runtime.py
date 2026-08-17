#!/usr/bin/env python3
"""Validate FCEUX evidence for the expanded maze bank."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--result", required=True, type=Path)
    args = parser.parse_args()
    if not args.result.is_file():
        print(f"[ERROR] Missing expanded runtime result: {args.result}")
        return 1
    lines = args.result.read_text(encoding="utf-8").splitlines()
    match = re.fullmatch(r"maze,8000,8000,([0-9A-F]{2})", lines[0] if lines else "")
    if match is None or lines[1:] != ["OK"]:
        print(f"[ERROR] Expanded runtime validation failed: {lines}")
        return 1
    print(f"[OK] FCEUX read expanded maze at $8000 (first token ${match.group(1)}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
