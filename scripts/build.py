#!/usr/bin/env python3
from __future__ import annotations

import math
import subprocess
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> int:
    project_dir = Path(__file__).resolve().parent.parent
    cc65_bin = project_dir / "bin"
    cl65 = cc65_bin / "cl65.exe"
    src_dir = project_dir / "src"
    tmp_rom = project_dir / "pacman_c_tmp.nes"
    out_rom = project_dir / "pacman_c.nes"
    chr_rom = project_dir / "pacman.chr"
    cfg = src_dir / "nrom128.cfg"

    if not cl65.is_file():
        fail(f"cl65.exe not found: {cl65}")
    if not cfg.is_file():
        fail(f"Linker cfg not found: {cfg}")
    if not chr_rom.is_file():
        fail(f"CHR ROM not found: {chr_rom}")

    print("[INFO] Building PRG with local cc65 toolchain...")
    cmd = [
        str(cl65),
        f"-I{src_dir}",
        "-t",
        "nes",
        "-C",
        str(cfg),
        str(src_dir / "main.c"),
        str(src_dir / "globals.c"),
        str(src_dir / "neslib.c"),
        "-o",
        str(tmp_rom),
    ]
    result = subprocess.run(cmd, check=False)
    if result.returncode != 0:
        fail("Build failed.")

    print(r"[INFO] Injecting CHR bank from pacman.chr...")
    tmp_bytes = tmp_rom.read_bytes()
    chr_bytes = chr_rom.read_bytes()

    if len(tmp_bytes) < 16:
        fail("Invalid temporary NES ROM.")

    prg = tmp_bytes[16:]
    if not prg:
        fail("Invalid PRG payload size.")

    header = bytearray(tmp_bytes[:16])
    header[4] = 1
    header[5] = math.ceil(len(chr_bytes) / 8192.0)
    header[6] = 0
    header[7] = 0

    out_bytes = bytes(header) + prg + chr_bytes
    out_rom.write_bytes(out_bytes)

    if tmp_rom.exists():
        tmp_rom.unlink()

    print(f"[OK] Build completed: {out_rom}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
