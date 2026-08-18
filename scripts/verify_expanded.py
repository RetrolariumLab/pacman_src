#!/usr/bin/env python3
"""Verify the NROM-256 layout and its JSON-generated assets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_native import parse_ines


def fixed_differences(original: bytes, candidate: bytes) -> list[dict[str, int]]:
    return [
        {"address": 0xC000 + offset, "original": left, "variant": right}
        for offset, (left, right) in enumerate(zip(original, candidate))
        if left != right
    ]


def validate_expanded(
    original: bytes,
    candidate: bytes,
    assets: dict[str, bytes],
    layout: dict[str, object],
) -> None:
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

    bank_spec = layout["extra_bank"]
    bank_address = int(bank_spec["address"])
    bank_size = int(bank_spec["size"])
    fill = int(bank_spec["fill"])
    if bank_address != 0x8000 or bank_size != 16_384:
        raise ValueError("expanded layout must describe the mapper-0 $8000 bank")
    cursor = 0
    for spec in layout["assets"]:
        name = str(spec["name"])
        address = int(spec["address"])
        size = int(spec["size"])
        data = assets.get(name)
        if data is None:
            raise ValueError(f"missing expanded asset: {name}")
        if address != bank_address + cursor:
            raise ValueError(f"expanded asset is not contiguous: {name}")
        if len(data) != size:
            raise ValueError(f"expanded asset size mismatch for {name}: {len(data)} != {size}")
        if prg[cursor:cursor + size] != data:
            raise ValueError(f"expanded bank data mismatch for {name}")
        cursor += size
    for spec in layout.get("inline_regions", []):
        name = str(spec["name"])
        address = int(spec["address"])
        data = bytes(spec["bytes"])
        if address != bank_address + cursor:
            raise ValueError(f"expanded inline region is not contiguous: {name}")
        if prg[cursor:cursor + len(data)] != data:
            raise ValueError(f"expanded inline region mismatch for {name}")
        cursor += len(data)
    if any(value != fill for value in prg[cursor:bank_size]):
        raise ValueError("unexpected data after declared assets in expanded bank")

    expected_changes = layout["fixed_bank_changes"]
    observed_changes = fixed_differences(original_prg, prg[16_384:])
    if observed_changes != expected_changes:
        raise ValueError(
            f"fixed-bank change manifest mismatch: expected {expected_changes}, "
            f"observed {observed_changes}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--maze-original", required=True, type=Path)
    parser.add_argument("--maze-stage2", required=True, type=Path)
    parser.add_argument("--stage", required=True, type=Path)
    parser.add_argument("--layout", required=True, type=Path)
    args = parser.parse_args()
    try:
        validate_expanded(
            args.original.read_bytes(),
            args.candidate.read_bytes(),
            {
                "maze_original": args.maze_original.read_bytes(),
                "stage_parameters": args.stage.read_bytes(),
                "maze_stage2": args.maze_stage2.read_bytes(),
            },
            json.loads(args.layout.read_text(encoding="utf-8")),
        )
    except (KeyError, TypeError, ValueError) as error:
        print(f"[ERROR] Expanded ROM validation failed: {error}")
        return 1
    print("[OK] Expanded layout, stage-specific mazes, and exact fixed-bank change manifest.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
