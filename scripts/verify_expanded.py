#!/usr/bin/env python3
"""Verify the NROM-256 layout and its JSON-generated maze asset."""

from __future__ import annotations

import argparse
from pathlib import Path

from build_native import parse_ines


def validate_expanded(original: bytes, candidate: bytes, maze: bytes) -> None:
    original_header, original_prg, original_chr = parse_ines(original)
    header, prg, chr_data = parse_ines(candidate)
    if header[4] != 2 or header[5] != original_header[5]:
        raise ValueError("expanded ROM must declare two PRG banks and preserve CHR size")
    if header[6:] != original_header[6:]:
        raise ValueError("expanded ROM changed mapper, mirroring, or reserved header bytes")
    if len(prg) != 32_768:
        raise ValueError(f"expanded PRG must be 32768 bytes, got {len(prg)}")
    if chr_data != original_chr:
        raise ValueError("expanded ROM CHR differs from the reference")
    fixed = bytearray(prg[16_384:])
    fixed[0x3FF8:0x3FFA] = original_prg[0x3FF8:0x3FFA]
    if bytes(fixed) != original_prg:
        raise ValueError("expanded fixed bank has changes beyond the maze pointer")
    if prg[:len(maze)] != maze:
        raise ValueError("expanded bank does not begin with the encoded maze")
    if any(value != 0xFF for value in prg[len(maze):16_384]):
        raise ValueError("unexpected data after maze in expanded bank")
    if prg[0x7FF8:0x7FFA] != b"\x00\x80":
        raise ValueError("fixed-bank maze pointer does not target $8000")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--maze", required=True, type=Path)
    args = parser.parse_args()
    try:
        validate_expanded(
            args.original.read_bytes(),
            args.candidate.read_bytes(),
            args.maze.read_bytes(),
        )
    except ValueError as error:
        print(f"[ERROR] Expanded ROM validation failed: {error}")
        return 1
    print("[OK] Expanded NROM-256 layout, preserved fixed bank, and $8000 maze pointer.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
