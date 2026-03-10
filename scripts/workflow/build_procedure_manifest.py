#!/usr/bin/env python3
"""Build ordered procedure manifest from bank_FF.asm."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


LABEL_RE = re.compile(r"^(sub_[A-Za-z0-9_]+|loc_[A-Za-z0-9_]+):\s*$")
ADDR_RE = re.compile(r"00:([0-9A-F]{4}):")


def parse_listing(path: Path) -> list[tuple[str, str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    out: list[tuple[str, str]] = []

    i = 0
    while i < len(lines):
        m = LABEL_RE.match(lines[i].strip())
        if not m:
            i += 1
            continue

        label = m.group(1)
        addr = ""
        j = i + 1
        while j < len(lines):
            s = lines[j]
            if LABEL_RE.match(s.strip()):
                break
            ma = ADDR_RE.search(s)
            if ma:
                addr = ma.group(1)
                break
            j += 1

        if addr:
            out.append((addr, label))
        i = j

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

