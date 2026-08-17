#!/usr/bin/env python3
"""Validate the compact runtime result emitted by the default hack."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--result", required=True)
    parser.add_argument("--expected-stage", required=True, type=int)
    args = parser.parse_args()

    path = Path(args.result)
    if not path.is_file():
        print(f"[ERROR] Missing hack runtime result: {path}")
        return 1
    lines = path.read_text(encoding="utf-8").splitlines()
    expected = [f"stage,{args.expected_stage}", "OK"]
    if lines != expected:
        print(f"[ERROR] Hack runtime validation failed: {lines}")
        return 1
    print(f"[OK] Default hack entered gameplay on stage {args.expected_stage}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
