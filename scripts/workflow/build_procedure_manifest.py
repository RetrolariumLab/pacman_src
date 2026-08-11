#!/usr/bin/env python3
"""Build an ordered procedure manifest from the modular assembly source."""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from listing_source import read_listing_lines  # noqa: E402


LABEL_RE = re.compile(
    r"^(sub_[A-Za-z0-9_]+|loc_[A-Za-z0-9_]+):\s*(?:;.*)?$"
)
LABEL_ADDR_RE = re.compile(r"^(?:sub|loc)_([C-F][0-9A-F]{3})(?:_|$)")


def parse_listing(path: Path) -> list[tuple[str, str]]:
    lines = read_listing_lines(path)
    out: list[tuple[str, str]] = []

    for line in lines:
        match = LABEL_RE.match(line.strip())
        if match is None:
            continue
        label = match.group(1)
        address = LABEL_ADDR_RE.match(label)
        if address is not None:
            out.append((address.group(1), label))

    # Keep first occurrence only (listing may contain alias labels).
    seen: set[str] = set()
    unique: list[tuple[str, str]] = []
    for addr, label in out:
        if label in seen:
            continue
        seen.add(label)
        unique.append((addr, label))
    return unique


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--listing", required=True, type=Path)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()

    rows = parse_listing(args.listing)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["order", "address", "label", "status", "notes"])
        for idx, (addr, label) in enumerate(rows, start=1):
            w.writerow([idx, addr, label, "pending", ""])

    print(f"[OK] Wrote {len(rows)} procedures to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

