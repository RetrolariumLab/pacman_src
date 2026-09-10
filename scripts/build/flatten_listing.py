#!/usr/bin/env python3
"""Expand a modular Bank FF listing into one file for external tools."""

from __future__ import annotations

import argparse
from pathlib import Path

from listing_source import read_listing_text


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("listing", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(read_listing_text(args.listing), encoding="utf-8")
    print(f"[OK] Flattened listing: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
