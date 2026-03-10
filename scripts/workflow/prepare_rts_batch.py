#!/usr/bin/env python3
"""Prepare a top-down RTS-bisection batch from procedure manifest."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


def load_pending(path: Path) -> list[dict[str, str]]:
    with path.open("r", newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    out = [r for r in rows if (r.get("status", "").strip().lower() == "pending")]
    out.sort(key=lambda r: int(r["order"]))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", required=True, type=Path)
    ap.add_argument("--count", type=int, default=32)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()

    pending = load_pending(args.manifest)
    batch = pending[: args.count]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = []
    lines.append("RTS BATCH")
    lines.append("")
    lines.append(
        "For each procedure: patch first opcode at address to RTS ($60), build ROM, run movie, collect mem+screens."
    )
    lines.append("")
    for r in batch:
        lines.append(
            f"{r['order']:>4} | {r['address']} | {r['label']} | status={r.get('status','pending')}"
        )

    args.output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"[OK] Wrote batch of {len(batch)} procedures to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
