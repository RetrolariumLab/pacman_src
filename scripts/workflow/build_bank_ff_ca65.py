#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def fail(msg: str) -> None:
    print(f"[ERROR] {msg}")
    raise SystemExit(1)


def parse_ines(path: Path) -> tuple[bytes, bytes, bytes]:
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
    prg = data[off : off + prg_size]
    chr_blob = data[off + prg_size : off + prg_size + chr_size]
    return header, prg, chr_blob


def first_diff(a: bytes, b: bytes) -> int | None:
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            return i
    if len(a) != len(b):
        return n
    return None


def resolve_tool(tool_name: str, project_root: Path) -> Path:
    candidates = [
        project_root / "cc65-snapshot-win64" / "bin" / f"{tool_name}.exe",
        project_root / "bin" / f"{tool_name}.exe",
    ]
    for p in candidates:
        if p.is_file():
            return p
    found = shutil.which(tool_name)
    if found:
        return Path(found)
    fail(f"{tool_name} not found (expected in cc65-snapshot-win64/bin or PATH)")
    raise AssertionError


def run(cmd: list[str], cwd: Path) -> None:
    print("[RUN]", " ".join(cmd))
    rc = subprocess.run(cmd, cwd=str(cwd), check=False).returncode
    if rc != 0:
        fail(f"Command failed with exit code {rc}")


def main() -> int:
    ap = argparse.ArgumentParser(description="Build bank_FF ROM via ca65/ld65 and optionally verify against original ROM.")
    ap.add_argument("--listing", required=True)
    ap.add_argument("--original-rom", required=True)
    ap.add_argument("--cfg", default="src/nrom128_prg_only.cfg")
    ap.add_argument("--generated-asm", default="workflow/bank_ff_ca65_generated.asm")
    ap.add_argument("--obj", default="workflow/bank_ff_ca65_generated.o")
    ap.add_argument("--prg", default="workflow/bank_ff_ca65_generated.bin")
    ap.add_argument("--output-rom", default="workflow/bank_ff_ca65.nes")
    ap.add_argument("--verify", action="store_true")
    args = ap.parse_args()

    project_root = Path(__file__).resolve().parents[2]
    listing = Path(args.listing)
    original_rom = Path(args.original_rom)
    cfg = Path(args.cfg)
    generated_asm = Path(args.generated_asm)
    obj = Path(args.obj)
    prg = Path(args.prg)
    output_rom = Path(args.output_rom)

    for p in (listing, original_rom, cfg):
        if not p.is_file():
            fail(f"Missing file: {p}")

    generated_asm.parent.mkdir(parents=True, exist_ok=True)
    obj.parent.mkdir(parents=True, exist_ok=True)
    prg.parent.mkdir(parents=True, exist_ok=True)
    output_rom.parent.mkdir(parents=True, exist_ok=True)

    sys.path.insert(0, str(project_root / "scripts"))
    sys.path.insert(0, str(project_root / "scripts" / "ghidra"))
    from generate_repro_disasm import parse_listing, write_ca65_disasm  # type: ignore
    from build_bank_ff_bin import parse_listing as parse_bank_bytes  # type: ignore

    prg_from_listing = parse_bank_bytes(listing)
    records, labels = parse_listing(listing, prg_blob=prg_from_listing)
    write_ca65_disasm(generated_asm, records, labels)
    print(f"[OK] Generated {generated_asm}")

    ca65 = resolve_tool("ca65", project_root)
    ld65 = resolve_tool("ld65", project_root)
    run([str(ca65), str(generated_asm), "-o", str(obj)], cwd=project_root)
    run([str(ld65), "-C", str(cfg), str(obj), "-o", str(prg)], cwd=project_root)

    prg_blob = prg.read_bytes()
    if len(prg_blob) != 16_384:
        fail(f"Linked PRG size must be 16384 bytes, got {len(prg_blob)}")

    header, _, chr_blob = parse_ines(original_rom)
    candidate = header + prg_blob + chr_blob
    output_rom.write_bytes(candidate)
    print(f"[OK] Built ROM via ca65: {output_rom}")

    if args.verify:
        original = original_rom.read_bytes()
        if candidate == original:
            print("[OK] Byte-identical to original ROM")
            return 0
        off = first_diff(candidate, original)
        if off is None:
            off = 0
        cb = candidate[off] if off < len(candidate) else None
        ob = original[off] if off < len(original) else None
        cb_s = "EOF" if cb is None else f"0x{cb:02X}"
        ob_s = "EOF" if ob is None else f"0x{ob:02X}"
        print(f"[FAIL] ROM mismatch at 0x{off:06X}: candidate={cb_s} original={ob_s}")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
