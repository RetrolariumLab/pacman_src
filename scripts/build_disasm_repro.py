#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path

from generate_repro_disasm import parse_listing, write_ca65_disasm


def fail(msg: str) -> None:
    print(f"[ERROR] {msg}", file=sys.stderr)
    raise SystemExit(1)


def sha1_hex(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def parse_ines(data: bytes) -> tuple[bytes, bytes, bytes]:
    if len(data) < 16 or data[:4] != b"NES\x1a":
        fail("Original ROM is not valid iNES")
    prg_banks = data[4]
    chr_banks = data[5]
    trainer = 512 if (data[6] & 0x04) else 0
    off = 16 + trainer
    prg_size = prg_banks * 16_384
    chr_size = chr_banks * 8_192
    prg = data[off : off + prg_size]
    chr_ = data[off + prg_size : off + prg_size + chr_size]
    return data[:16], prg, chr_


def run_cmd(cmd: list[str]) -> None:
    print("[RUN]", " ".join(cmd))
    r = subprocess.run(cmd, check=False)
    if r.returncode != 0:
        fail(f"Command failed ({r.returncode}): {' '.join(cmd)}")


def first_diff(a: bytes, b: bytes) -> int | None:
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            return i
    if len(a) != len(b):
        return n
    return None


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Build byte-identical Pac-Man ROM from generated ca65 disassembly"
    )
    ap.add_argument("--listing", default="bank_FF.asm")
    ap.add_argument("--original-rom", default="Pac-Man (J) (V1.0) [!].nes")
    ap.add_argument("--asm", default="src/pacman_disasm_repro.asm")
    ap.add_argument("--cfg", default="src/nrom128_prg_only.cfg")
    ap.add_argument("--obj", default="pacman_disasm_repro.o")
    ap.add_argument(
        "--prg-temp",
        default=None,
        help="Optional temporary PRG path. If omitted, uses auto temp file and removes it.",
    )
    ap.add_argument("--out-rom", default="pacman_disasm_repro.nes")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    listing = root / args.listing
    original_rom = root / args.original_rom
    asm_path = root / args.asm
    cfg_path = root / args.cfg
    obj_path = root / args.obj
    out_rom = root / args.out_rom

    ca65 = root / "bin" / "ca65.exe"
    ld65 = root / "bin" / "ld65.exe"
    if not ca65.is_file() or not ld65.is_file():
        fail("ca65.exe/ld65.exe not found in bin/")
    if not listing.is_file():
        fail(f"Listing not found: {listing}")
    if not original_rom.is_file():
        fail(f"Original ROM not found: {original_rom}")
    if not cfg_path.is_file():
        fail(f"Linker cfg not found: {cfg_path}")

    orig = original_rom.read_bytes()
    header, orig_prg, orig_chr = parse_ines(orig)

    print("[INFO] Generating ca65 disassembly...")
    records, labels = parse_listing(listing, prg_blob=orig_prg[:0x4000])
    write_ca65_disasm(asm_path, records, labels)
    print(f"[OK] Wrote {asm_path}")

    if args.prg_temp:
        prg_path = root / args.prg_temp
        cleanup_prg = False
    else:
        fd, tmp_name = tempfile.mkstemp(prefix="pacman_disasm_repro_", suffix=".bin")
        os.close(fd)
        Path(tmp_name).unlink(missing_ok=True)
        prg_path = Path(tmp_name)
        cleanup_prg = True

    print("[INFO] Assembling PRG with wine + ca65/ld65...")
    run_cmd(["wine", str(ca65), str(asm_path), "-o", str(obj_path)])
    run_cmd(
        [
            "wine",
            str(ld65),
            "-C",
            str(cfg_path),
            str(obj_path),
            "-o",
            str(prg_path),
        ]
    )

    prg = prg_path.read_bytes()
    if len(prg) != 16_384:
        fail(f"Linked PRG size must be 16384 bytes, got {len(prg)}")

    out_rom.write_bytes(header + prg + orig_chr)
    print(f"[OK] Wrote {out_rom}")

    prg_same = prg == orig_prg
    rom_same = out_rom.read_bytes() == orig
    print(f"[INFO] PRG SHA1 orig={sha1_hex(orig_prg)} cand={sha1_hex(prg)}")
    print(f"[INFO] ROM SHA1 orig={sha1_hex(orig)} cand={sha1_hex(out_rom.read_bytes())}")

    if not prg_same:
        off = first_diff(orig_prg, prg)
        if off is not None:
            print(f"[DIFF] First PRG diff at 0x{off:04X}")
    if not rom_same:
        off = first_diff(orig, out_rom.read_bytes())
        if off is not None:
            print(f"[DIFF] First ROM diff at 0x{off:04X}")

    if prg_same and rom_same:
        print("[OK] Byte-identical ROM reproduced.")
        if cleanup_prg:
            prg_path.unlink(missing_ok=True)
        return 0

    if args.strict:
        if cleanup_prg:
            prg_path.unlink(missing_ok=True)
        fail("ROM is not byte-identical")
    print("[WARN] ROM is not byte-identical")
    if cleanup_prg:
        prg_path.unlink(missing_ok=True)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
