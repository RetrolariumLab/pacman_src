#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


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


def main() -> int:
    ap = argparse.ArgumentParser(description="Build candidate ROM from bank_FF.asm and compare with original ROM.")
    ap.add_argument("--listing", required=True)
    ap.add_argument("--original-rom", required=True)
    ap.add_argument("--output-rom", required=True)
    args = ap.parse_args()

    root = Path(__file__).resolve().parents[2]
    ghidra_dir = root / "scripts" / "ghidra"

    import sys
    sys.path.insert(0, str(ghidra_dir))
    from build_bank_ff_bin import parse_listing  # type: ignore

    listing = Path(args.listing)
    original_rom = Path(args.original_rom)
    output_rom = Path(args.output_rom)
    if not listing.is_file():
        raise SystemExit(f"[ERROR] Missing listing: {listing}")
    if not original_rom.is_file():
        raise SystemExit(f"[ERROR] Missing ROM: {original_rom}")

    header, original_prg, chr_blob = parse_ines(original_rom)
    bank = parse_listing(listing)
    if len(bank) != 16_384:
        raise SystemExit(f"[ERROR] bank_FF PRG size must be 16384, got {len(bank)}")

    # NROM-128 game: entire PRG is one 16KB bank mirrored by mapper.
    candidate = header + bank + chr_blob
    output_rom.parent.mkdir(parents=True, exist_ok=True)
    output_rom.write_bytes(candidate)

    original = original_rom.read_bytes()
    if candidate == original:
        print(f"[OK] Byte-identical ROM: {output_rom}")
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


if __name__ == "__main__":
    raise SystemExit(main())
