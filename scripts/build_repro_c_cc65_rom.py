#!/usr/bin/env python3
from __future__ import annotations

from rom_assets import read_source_text

import argparse
import math
import subprocess
import sys
import tempfile
from pathlib import Path


def fail(msg: str) -> None:
    print(f"[ERROR] {msg}", file=sys.stderr)
    raise SystemExit(1)


def run_cmd(cmd: list[str]) -> None:
    print("[CMD]", " ".join(cmd))
    res = subprocess.run(cmd, check=False)
    if res.returncode != 0:
        fail(f"Command failed with exit code {res.returncode}")


def write_boot_asm(path: Path) -> None:
    path.write_text(
        """.segment "HEADER"
.byte 'N','E','S',$1A
.byte 1
.byte 1
.byte $00
.byte $00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.segment "ZEROPAGE"
.exportzp c_sp, sreg, regsave, regbank, tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
c_sp:    .res 2
sreg:    .res 2
regsave: .res 4
regbank: .res 6
tmp1:    .res 1
tmp2:    .res 1
tmp3:    .res 1
tmp4:    .res 1
ptr1:    .res 2
ptr2:    .res 2
ptr3:    .res 2
ptr4:    .res 2

.segment "STARTUP"
.import _boot_main
reset:
  sei
  cld
  ldx #$ff
  txs
  jsr _boot_main
@loop:
  jmp @loop

nmi:
  rti

irq:
  rti

.segment "VECTORS"
.addr nmi
.addr reset
.addr irq
""",
        encoding="utf-8",
    )


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Build runnable NES from cc65-friendly repro C object and append pacman.chr."
    )
    ap.add_argument("--obj", default="pacman_repro_layout_decomp_cc65_min.o")
    ap.add_argument("--out-rom", default="pacman_repro_layout_decomp_cc65.nes")
    ap.add_argument("--tmp-rom", default="pacman_repro_layout_decomp_cc65_tmp.nes")
    ap.add_argument("--cfg", default="src/nrom128.cfg")
    ap.add_argument("--chr", default="pacman.chr")
    ap.add_argument("--boot-c", default="scripts/cc65_boot_main.c")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    obj = (root / args.obj).resolve()
    out_rom = (root / args.out_rom).resolve()
    tmp_rom = (root / args.tmp_rom).resolve()
    cfg = (root / args.cfg).resolve()
    chr_rom = (root / args.chr).resolve()
    boot_c = (root / args.boot_c).resolve()
    ca65 = (root / "bin" / "ca65.exe").resolve()
    cc65 = (root / "bin" / "cc65.exe").resolve()
    ld65 = (root / "bin" / "ld65.exe").resolve()

    if not obj.is_file():
        fail(f"Object not found: {obj}")
    if not cfg.is_file():
        fail(f"Linker cfg not found: {cfg}")
    if not chr_rom.is_file():
        fail(f"CHR file not found: {chr_rom}")
    if not boot_c.is_file():
        fail(f"Boot C file not found: {boot_c}")
    if not ca65.is_file() or not cc65.is_file() or not ld65.is_file():
        fail("cc65.exe/ca65.exe/ld65.exe not found in bin/")

    fd, boot_name = tempfile.mkstemp(prefix="repro_cc65_boot_", suffix=".s")
    Path(boot_name).unlink(missing_ok=True)
    boot_s = Path(boot_name)
    boot_o = boot_s.with_suffix(".o")
    boot_c_s = boot_s.with_suffix(".c.s")
    boot_c_o = boot_s.with_suffix(".c.o")

    try:
        write_boot_asm(boot_s)
        run_cmd(["wine", str(cc65), "-O", "-t", "nes", str(boot_c), "-o", str(boot_c_s)])
        asm_text = read_source_text(boot_c_s, encoding="utf-8", errors="replace")
        asm_text = asm_text.replace("\t.macpack\tlongbranch\n", "")
        asm_text = asm_text.replace(".macpack\tlongbranch\n", "")
        boot_c_s.write_text(asm_text, encoding="utf-8")
        run_cmd(["wine", str(ca65), str(boot_c_s), "-o", str(boot_c_o)])
        run_cmd(["wine", str(ca65), str(boot_s), "-o", str(boot_o)])
        run_cmd(["wine", str(ld65), "-C", str(cfg), str(boot_o), str(boot_c_o), str(obj), "-o", str(tmp_rom)])

        tmp_bytes = tmp_rom.read_bytes()
        chr_bytes = chr_rom.read_bytes()
        if len(tmp_bytes) < 16:
            fail("Invalid temporary NES ROM.")

        header = bytearray(tmp_bytes[:16])
        prg = tmp_bytes[16:]
        prg_banks = max(1, math.ceil(len(prg) / 16384.0))
        if prg_banks != 1:
            fail(f"PRG size is not NROM-128 (expected 1 bank, got {prg_banks}).")
        header[4] = prg_banks
        header[5] = math.ceil(len(chr_bytes) / 8192.0)
        header[6] = 0
        header[7] = 0

        out_bytes = bytes(header) + prg + chr_bytes
        out_rom.write_bytes(out_bytes)
        print(f"[OK] Built runnable NES: {out_rom}")
    finally:
        boot_s.unlink(missing_ok=True)
        boot_o.unlink(missing_ok=True)
        boot_c_s.unlink(missing_ok=True)
        boot_c_o.unlink(missing_ok=True)
        tmp_rom.unlink(missing_ok=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
