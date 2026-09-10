#!/usr/bin/env python3
"""Validate the compact runtime result produced by validate_debug_symbols.lua."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--result", required=True, type=Path)
    args = parser.parse_args()

    if not args.result.is_file():
        raise SystemExit(f"[ERROR] Debug runtime result not found: {args.result}")
    lines = args.result.read_text(encoding="utf-8").splitlines()
    failures = [line for line in lines if line.startswith("FAIL,")]
    symbols = [line for line in lines if line.startswith("symbol,")]
    breaks = [line for line in lines if line.startswith("break,")]
    if failures:
        raise SystemExit(f"[ERROR] Runtime debugger validation failed: {failures[0]}")
    if lines[-1:] != ["OK"] or len(symbols) != 8 or len(breaks) != 1:
        raise SystemExit("[ERROR] Incomplete runtime debugger validation result")
    print(f"[OK] Runtime debugger validation: {len(symbols)} symbol lookups and semantic NMI break.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
