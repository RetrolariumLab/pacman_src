#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path


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
        description="Build NES ROM from pacman_repro_layout_disasm.asm via wine+ca65/ld65"
    )
    ap.add_argument("--asm", default="pacman_repro_layout_disasm.asm")
    ap.add_argument("--cfg", default="src/nrom128_prg_only.cfg")
    ap.add_argument("--obj", default="pacman_repro_layout.o")
    ap.add_argument("--out-rom", default="pacman_repro_layout.nes")
    ap.add_argument("--original-rom", default="Pac-Man (J) (V1.0) [!].nes")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    asm_path = root / args.asm
    cfg_path = root / args.cfg
    obj_path = root / args.obj
    out_rom = root / args.out_rom
    original_rom = root / args.original_rom

    ca65 = root / "bin" / "ca65.exe"
    ld65 = root / "bin" / "ld65.exe"

    for p in (asm_path, cfg_path, original_rom, ca65, ld65):
        if not p.is_file():
            fail(f"Required file not found: {p}")

    orig = original_rom.read_bytes()
    header, orig_prg, orig_chr = parse_ines(orig)

    fd, tmp_name = tempfile.mkstemp(prefix="pacman_repro_layout_", suffix=".bin")
    os.close(fd)
    prg_path = Path(tmp_name)
    prg_path.unlink(missing_ok=True)

    try:
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

        out = header + prg + orig_chr
        out_rom.write_bytes(out)
        print(f"[OK] Wrote {out_rom}")
        print(f"[INFO] PRG SHA1 orig={sha1_hex(orig_prg)} cand={sha1_hex(prg)}")
        print(f"[INFO] ROM SHA1 orig={sha1_hex(orig)} cand={sha1_hex(out)}")

        if out == orig:
            print("[OK] Byte-identical ROM reproduced.")
            return 0

        off = first_diff(orig, out)
        if off is not None:
            print(f"[DIFF] First ROM diff at 0x{off:04X}")
        if args.strict:
            fail("ROM is not byte-identical")
        print("[WARN] ROM is not byte-identical")
        return 2
    finally:
        prg_path.unlink(missing_ok=True)


if __name__ == "__main__":
    raise SystemExit(main())

