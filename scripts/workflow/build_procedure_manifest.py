#!/usr/bin/env python3
"""Build an ordered procedure manifest from an ld65 VICE label file."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path

VICE_LABEL_RE = re.compile(
    r"^al\s+(?P<address>[0-9A-Fa-f]{6})\s+\.(?P<label>(?:sub|loc)_[A-Za-z0-9_]+)$"
)


def parse_labels(path: Path) -> list[tuple[str, str]]:
    out: list[tuple[int, str]] = []
    for line in path.read_text(encoding="utf-8", errors="strict").splitlines():
        match = VICE_LABEL_RE.match(line.strip())
        if match is None:
            continue
        address = int(match.group("address"), 16)
        if 0xC000 <= address <= 0xFFFF:
            out.append((address, match.group("label")))

    out.sort(key=lambda item: (item[0], item[1]))
    seen: set[str] = set()
    unique: list[tuple[int, str]] = []
    for addr, label in out:
        if label in seen:
            continue
        seen.add(label)
        unique.append((addr, label))
    return [(f"{addr:04X}", label) for addr, label in unique]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--labels", required=True, type=Path)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()

    rows = parse_labels(args.labels)
    if not rows:
        raise SystemExit(f"[ERROR] No subroutine labels found in {args.labels}")
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
