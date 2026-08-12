#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from listing_source import read_listing_lines  # noqa: E402

LABEL_RE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*):')
VICE_LABEL_RE = re.compile(
    r"^al\s+(?P<address>[0-9A-Fa-f]{6})\s+\.(?P<label>[A-Za-z_][A-Za-z0-9_]*)$"
)


def classify_label(label: str) -> str:
    if label.startswith("sub_"):
        return "subroutine"
    if label.startswith("loc_"):
        return "code_label"
    if label.startswith("bra_"):
        return "branch"
    if label.startswith("ofs_"):
        return "offset"
    if label.startswith("handler_"):
        return "handler"
    if label.startswith("tbl_"):
        return "table"
    if label.startswith("off_"):
        return "addressable_data"
    if label.startswith("vec_"):
        return "vector"
    return "data_or_other"


def load_label_addresses(path: Path) -> dict[str, str]:
    addresses: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8", errors="strict").splitlines():
        match = VICE_LABEL_RE.match(line.strip())
        if match is None:
            continue
        address = int(match.group("address"), 16)
        if 0xC000 <= address <= 0xFFFF:
            addresses[match.group("label")] = f"{address:04X}"
    return addresses


def main() -> int:
    ap = argparse.ArgumentParser(description="Extract rename candidates from a modular assembly chunk.")
    ap.add_argument("--source", required=True)
    ap.add_argument("--labels", required=True)
    ap.add_argument("--start-line", type=int, required=True)
    ap.add_argument("--line-count", type=int, default=250)
    ap.add_argument("--output-csv", required=True)
    ap.add_argument("--output-snippet", required=True)
    ap.add_argument("--append", action="store_true")
    args = ap.parse_args()

    src = Path(args.source)
    labels_path = Path(args.labels)
    if not src.is_file():
        raise SystemExit(f"[ERROR] Missing source file: {src}")
    if not labels_path.is_file():
        raise SystemExit(f"[ERROR] Missing linker labels: {labels_path}")
    if args.start_line < 1:
        raise SystemExit("[ERROR] --start-line must be >= 1")
    if args.line_count < 1:
        raise SystemExit("[ERROR] --line-count must be >= 1")

    lines = read_listing_lines(src)
    label_addresses = load_label_addresses(labels_path)
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
                "address": label_addresses.get(label, ""),
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
