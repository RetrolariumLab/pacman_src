#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import re
import shutil
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path


def parse_ines(path: Path) -> tuple[bytes, bytes]:
    data = path.read_bytes()
    if len(data) < 16 or data[:4] != b"NES\x1A":
        raise ValueError(f"Not a valid iNES ROM: {path}")
    prg_banks = data[4]
    chr_banks = data[5]
    trainer = 512 if (data[6] & 0x04) else 0
    off = 16 + trainer
    prg_size = prg_banks * 16_384
    chr_size = chr_banks * 8_192
    header = data[:16]
    chr_blob = data[off + prg_size : off + prg_size + chr_size]
    return header, chr_blob


def load_batch_labels(path: Path) -> list[str]:
    labels: list[str] = []
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # Formats supported:
        # 1) "sub_C21F"
        # 2) "3 | C21F | sub_C21F_draw_logo_screen | status=pending"
        if "|" in line:
            parts = [p.strip() for p in line.split("|")]
            if len(parts) >= 3 and parts[2]:
                labels.append(parts[2])
            continue
        if line.lower().startswith("rts batch") or line.lower().startswith("for each procedure"):
            continue
        labels.append(line)
    return labels


def load_manifest(path: Path) -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    with path.open("r", encoding="utf-8", newline="") as f:
        rd = csv.DictReader(f)
        for row in rd:
            label = (row.get("label") or "").strip()
            if label:
                out[label] = row
    return out


def sanitize(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", name)


def count_diffs(diff_report: Path) -> tuple[int, int]:
    screen = 0
    memory = 0
    if not diff_report.is_file():
        return screen, memory
    for raw in diff_report.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if line.startswith("screen_diff"):
            screen += 1
        elif line.startswith("memory_diff"):
            memory += 1
    return screen, memory


def patch_listing_rts(path: Path, addr_hex: str) -> bool:
    target = addr_hex.upper()
    rows = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    out: list[str] = []
    patched = False
    for line in rows:
        if not patched and f"00:{target}:" in line:
            m = re.match(r"^(.*00:[0-9A-Fa-f]{4}:\s+)([0-9A-Fa-f]{2})(.*)$", line)
            if m:
                line = f"{m.group(1)}60{m.group(3)}"
                patched = True
        out.append(line)
    if patched:
        path.write_text("\n".join(out) + "\n", encoding="utf-8")
    return patched


def analyze_one(task: dict) -> dict:
    import sys

    ghidra_dir = Path(task["ghidra_dir"])
    sys.path.insert(0, str(ghidra_dir))
    from build_bank_ff_bin import parse_listing  # type: ignore

    label = task["label"]
    addr_s = task["address"]
    order = task["order"]
    safe_label = sanitize(label)

    work_dir = Path(task["work_root"]) / safe_label
    run_dir = Path(task["diff_root"]) / safe_label

    if work_dir.exists():
        shutil.rmtree(work_dir)
    if run_dir.exists():
        shutil.rmtree(run_dir)
    work_dir.mkdir(parents=True, exist_ok=True)
    run_dir.mkdir(parents=True, exist_ok=True)

    listing_copy = work_dir / "bank_FF.asm"
    shutil.copy2(Path(task["listing"]), listing_copy)
    if not patch_listing_rts(listing_copy, addr_s):
        return {
            "order": order,
            "label": label,
            "address": addr_s,
            "status": "patch_failed",
            "screen_diff": 0,
            "memory_diff": 0,
            "exit_code": -1,
            "run_dir": str(run_dir),
            "work_dir": str(work_dir),
        }

    patched_prg = bytearray(parse_listing(listing_copy))
    if len(patched_prg) != 16_384:
        return {
            "order": order,
            "label": label,
            "address": addr_s,
            "status": "build_failed",
            "screen_diff": 0,
            "memory_diff": 0,
            "exit_code": -1,
            "run_dir": str(run_dir),
            "work_dir": str(work_dir),
        }

    rom_path = work_dir / "candidate_rts.nes"
    rom_path.write_bytes(bytes.fromhex(task["header_hex"]) + bytes(patched_prg) + bytes.fromhex(task["chr_hex"]))

    col = task["worker_index"] % int(task["grid_cols"])
    row = task["worker_index"] // int(task["grid_cols"])
    window_x = col * int(task["window_w"])
    window_y = row * int(task["window_h"])

    cmd = [
        task["fceux"],
        "-playmovie",
        task["movie"],
        "-screenshot-interval",
        str(task["interval"]),
        "-screenshot-dir",
        str(run_dir),
        "-reference-dir",
        task["reference_dir"],
        "-save-state-dumps",
        "-max-diffs",
        str(task["max_diffs"]),
        "-max-frames",
        str(task["max_frames"]),
        "-window-x",
        str(window_x),
        "-window-y",
        str(window_y),
    ]
    if task["pixel_perfect"]:
        cmd.append("-pixel-perfect-window")
    if task["turbo"]:
        cmd.extend(["-turbo", "1"])
    if task["nothrottle"]:
        cmd.extend(["-nothrottle", "1"])
    cmd.append(str(rom_path))

    rc = subprocess.run(cmd, check=False).returncode
    screen_diff, memory_diff = count_diffs(run_dir / "diff_report.txt")
    return {
        "order": order,
        "label": label,
        "address": addr_s,
        "status": "ok" if rc == 0 else "run_failed",
        "screen_diff": screen_diff,
        "memory_diff": memory_diff,
        "exit_code": rc,
        "run_dir": str(run_dir),
        "work_dir": str(work_dir),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="RTS analysis runner for bank_FF procedures.")
    ap.add_argument("--listing", required=True)
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--batch", required=True)
    ap.add_argument("--original-rom", required=True)
    ap.add_argument("--movie", required=True)
    ap.add_argument("--fceux", required=True)
    ap.add_argument("--reference-dir", required=True)
    ap.add_argument("--diff-root", required=True)
    ap.add_argument("--output-report", required=True)
    ap.add_argument("--interval", type=int, default=20)
    ap.add_argument("--max-frames", type=int, default=0)
    ap.add_argument("--max-diffs", type=int, default=1)
    ap.add_argument("--workers", type=int, default=24)
    ap.add_argument("--grid-cols", type=int, default=6)
    ap.add_argument("--window-width", type=int, default=320)
    ap.add_argument("--window-height", type=int, default=260)
    ap.add_argument("--pixel-perfect", action="store_true")
    ap.add_argument("--turbo", action="store_true")
    ap.add_argument("--nothrottle", action="store_true")
    args = ap.parse_args()

    script_dir = Path(__file__).resolve().parent
    ghidra_dir = script_dir.parent / "ghidra"

    listing = Path(args.listing)
    manifest = Path(args.manifest)
    batch = Path(args.batch)
    original_rom = Path(args.original_rom)
    movie = Path(args.movie)
    fceux = Path(args.fceux)
    reference_dir = Path(args.reference_dir)
    diff_root = Path(args.diff_root)
    report = Path(args.output_report)

    for p in [listing, manifest, batch, original_rom, movie, fceux]:
        if not p.is_file():
            raise SystemExit(f"[ERROR] Missing file: {p}")
    if not reference_dir.is_dir():
        raise SystemExit(f"[ERROR] Missing reference dir: {reference_dir}")

    diff_root.mkdir(parents=True, exist_ok=True)
    report.parent.mkdir(parents=True, exist_ok=True)
    work_root = report.parent / "rts_work"
    work_root.mkdir(parents=True, exist_ok=True)

    header, chr_blob = parse_ines(original_rom)
    manifest_rows = load_manifest(manifest)
    labels = load_batch_labels(batch)
    if not labels:
        raise SystemExit("[ERROR] Empty RTS batch.")

    tasks: list[dict] = []
    worker_index = 0
    for idx, label in enumerate(labels, start=1):
        row = manifest_rows.get(label)
        if not row:
            continue
        addr_s = (row.get("address") or "").strip()
        try:
            int(addr_s, 16)
        except ValueError:
            continue
        tasks.append(
            {
                "order": row.get("order", idx),
                "label": label,
                "address": addr_s,
                "worker_index": worker_index,
                "listing": str(listing),
                "work_root": str(work_root),
                "diff_root": str(diff_root),
                "fceux": str(fceux),
                "movie": str(movie),
                "reference_dir": str(reference_dir),
                "interval": args.interval,
                "max_frames": args.max_frames,
                "max_diffs": args.max_diffs,
                "grid_cols": args.grid_cols,
                "window_w": args.window_width,
                "window_h": args.window_height,
                "pixel_perfect": args.pixel_perfect,
                "turbo": args.turbo,
                "nothrottle": args.nothrottle,
                "header_hex": header.hex(),
                "chr_hex": chr_blob.hex(),
                "ghidra_dir": str(ghidra_dir),
            }
        )
        worker_index += 1

    if not tasks:
        raise SystemExit("[ERROR] No valid procedures found in batch.")

    print(f"[INFO] Starting {len(tasks)} tasks with {args.workers} workers...")
    rows: list[dict] = []
    with ProcessPoolExecutor(max_workers=args.workers) as ex:
        fut_map = {ex.submit(analyze_one, t): t for t in tasks}
        for i, fut in enumerate(as_completed(fut_map), start=1):
            t = fut_map[fut]
            try:
                row = fut.result()
            except Exception as exc:
                row = {
                    "order": t["order"],
                    "label": t["label"],
                    "address": t["address"],
                    "status": f"worker_error:{exc}",
                    "screen_diff": 0,
                    "memory_diff": 0,
                    "exit_code": -1,
                    "run_dir": "",
                    "work_dir": "",
                }
            rows.append(row)
            print(f"[{i}/{len(tasks)}] {row['label']} status={row['status']} screen={row['screen_diff']}")

    rows.sort(key=lambda r: int(r.get("order", 0)))
    with report.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "order",
                "label",
                "address",
                "status",
                "screen_diff",
                "memory_diff",
                "exit_code",
                "run_dir",
                "work_dir",
            ],
        )
        w.writeheader()
        for r in rows:
            w.writerow(r)

    print(f"[OK] Analysis report: {report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
