#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path


def list_frames(folder: Path, ext: str) -> set[str]:
    if not folder.is_dir():
        return set()
    return {p.stem for p in folder.glob(f"*.{ext}") if p.is_file()}


def parse_diff_report(path: Path) -> Counter:
    counts: Counter = Counter()
    if not path.is_file():
        return counts
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("diff report"):
            continue
        if line.startswith("screen_diff"):
            counts["screen_diff"] += 1
        elif line.startswith("memory_diff"):
            counts["memory_diff"] += 1
        else:
            counts["other"] += 1
    return counts


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate summary for FCEUX automation run.")
    ap.add_argument("--run-dir", required=True, help="Capture run directory (diffs/<movie> or reference/<movie>).")
    ap.add_argument("--reference-dir", required=False, default="", help="Reference capture directory.")
    ap.add_argument("--output-dir", required=True, help="Directory for txt/csv reports.")
    ap.add_argument("--movie", required=True, help="Movie label (tas/longplay/menus).")
    args = ap.parse_args()

    run_dir = Path(args.run_dir)
    ref_dir = Path(args.reference_dir) if args.reference_dir else None
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    run_screens = list_frames(run_dir / "screens", "png")
    run_memory = list_frames(run_dir / "memory", "bin")
    ref_screens = list_frames(ref_dir / "screens", "png") if ref_dir else set()
    ref_memory = list_frames(ref_dir / "memory", "bin") if ref_dir else set()

    counters = parse_diff_report(run_dir / "diff_report.txt")

    common_screen = run_screens & ref_screens
    common_memory = run_memory & ref_memory
    missing_screen_in_run = ref_screens - run_screens
    missing_memory_in_run = ref_memory - run_memory
    extra_screen_in_run = run_screens - ref_screens if ref_dir else set()
    extra_memory_in_run = run_memory - ref_memory if ref_dir else set()

    txt_out = out_dir / f"capture_report_{args.movie}.txt"
    csv_out = out_dir / f"capture_report_{args.movie}.csv"

    txt_lines = [
        f"movie={args.movie}",
        f"run_dir={run_dir}",
        f"reference_dir={ref_dir if ref_dir else '(none)'}",
        f"run_screens={len(run_screens)}",
        f"run_memory={len(run_memory)}",
        f"ref_screens={len(ref_screens)}",
        f"ref_memory={len(ref_memory)}",
        f"common_screen_frames={len(common_screen)}",
        f"common_memory_frames={len(common_memory)}",
        f"missing_screen_in_run={len(missing_screen_in_run)}",
        f"missing_memory_in_run={len(missing_memory_in_run)}",
        f"extra_screen_in_run={len(extra_screen_in_run)}",
        f"extra_memory_in_run={len(extra_memory_in_run)}",
        f"screen_diff_lines={counters.get('screen_diff', 0)}",
        f"memory_diff_lines={counters.get('memory_diff', 0)}",
        f"other_diff_lines={counters.get('other', 0)}",
    ]
    txt_out.write_text("\n".join(txt_lines) + "\n", encoding="utf-8")

    with csv_out.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["metric", "value"])
        for line in txt_lines:
            key, val = line.split("=", 1)
            w.writerow([key, val])

    print(f"[OK] Report: {txt_out}")
    print(f"[OK] CSV: {csv_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
