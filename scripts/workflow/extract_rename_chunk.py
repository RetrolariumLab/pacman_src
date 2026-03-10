#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path

LABEL_RE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*):')
ADDR_RE = re.compile(r'00:([0-9A-Fa-f]{4}):')


def classify_label(label: str) -> str:
    if label.startswith("sub_"):
        return "subroutine"
    if label.startswith("loc_"):
        return "code_label"
    if label.startswith("bra_"):
        return "branch"
    if label.startswith("ofs_"):
        return "offset"
    if label.startswith("tbl_"):
        return "table"
    if label.startswith("vec_"):
        return "vector"
    return "data_or_other"


def find_nearest_addr(lines: list[str], index: int, window: int = 4) -> str:
    end = min(len(lines), index + window + 1)
    for i in range(index, end):
        m = ADDR_RE.search(lines[i])
        if m:
            return m.group(1).upper()
    start = max(0, index - window)
    for i in range(index - 1, start - 1, -1):
        m = ADDR_RE.search(lines[i])
        if m:
            return m.group(1).upper()
    return ""


def main() -> int:
    ap = argparse.ArgumentParser(description="Extract rename candidates from a line chunk of bank_FF.asm.")
    ap.add_argument("--source", required=True)
    ap.add_argument("--start-line", type=int, required=True)
    ap.add_argument("--line-count", type=int, default=250)
    ap.add_argument("--output-csv", required=True)
    ap.add_argument("--output-snippet", required=True)
    ap.add_argument("--append", action="store_true")
    args = ap.parse_args()

    src = Path(args.source)
    if not src.is_file():
        raise SystemExit(f"[ERROR] Missing source file: {src}")
    if args.start_line < 1:
        raise SystemExit("[ERROR] --start-line must be >= 1")
    if args.line_count < 1:
        raise SystemExit("[ERROR] --line-count must be >= 1")

    lines = src.read_text(encoding="utf-8", errors="ignore").splitlines()
    start_idx = args.start_line - 1
    end_idx = min(len(lines), start_idx + args.line_count)
    chunk = lines[start_idx:end_idx]

    out_snippet = Path(args.output_snippet)
    out_snippet.parent.mkdir(parents=True, exist_ok=True)
    snippet_text = "\n".join(chunk) + ("\n" if chunk else "")
    out_snippet.write_text(snippet_text, encoding="utf-8")

    seen: set[str] = set()
    rows: list[dict[str, str]] = []
    for rel_i, line in enumerate(chunk):
        m = LABEL_RE.match(line.strip())
        if not m:
            continue
        label = m.group(1)
        if label in seen:
            continue
        seen.add(label)
        abs_i = start_idx + rel_i
        rows.append(
            {
                "old_name": label,
                "new_name": "",
                "description": "",
                "category": classify_label(label),
                "line": str(abs_i + 1),
                "address": find_nearest_addr(lines, abs_i),
            }
        )

    out_csv = Path(args.output_csv)
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    exists = out_csv.exists()
    mode = "a" if (args.append and exists) else "w"
    with out_csv.open(mode, encoding="utf-8", newline="") as f:
        fieldnames = ["old_name", "new_name", "description", "category", "line", "address"]
        w = csv.DictWriter(f, fieldnames=fieldnames)
        if mode == "w":
            w.writeheader()
        for row in rows:
            w.writerow(row)

    print(f"[OK] Snippet: {out_snippet} ({args.start_line}-{end_idx})")
    print(f"[OK] Labels: {len(rows)} -> {out_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

