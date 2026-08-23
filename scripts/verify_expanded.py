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
    expected_chr: bytes | None = None,
) -> None:
    original_header, original_prg, original_chr = parse_ines(original)
    header, prg, chr_data = parse_ines(candidate)
    if header[4] != 2 or header[5] != original_header[5]:
        raise ValueError("expanded ROM must declare two PRG banks and preserve CHR size")
    if header[6:] != original_header[6:]:
        raise ValueError("expanded ROM changed mapper, mirroring, or reserved header bytes")
    if len(prg) != 32_768:
        raise ValueError(f"expanded PRG must be 32768 bytes, got {len(prg)}")
    expected_chr = original_chr if expected_chr is None else expected_chr
    if len(expected_chr) != len(original_chr):
        raise ValueError("expected CHR must preserve the reference 8 KiB size")
    if chr_data != expected_chr:
        raise ValueError("expanded ROM CHR differs from the declared CHR input")

    bank_spec = layout["extra_bank"]
    bank_address = int(bank_spec["address"])
    bank_size = int(bank_spec["size"])
    fill = int(bank_spec["fill"])
    if bank_address != 0x8000 or bank_size != 16_384:
        raise ValueError("expanded layout must describe the mapper-0 $8000 bank")
    regions: list[tuple[int, str, bytes]] = []
    for spec in layout["assets"]:
        name = str(spec["name"])
        address = int(spec["address"])
        size = int(spec["size"])
        data = assets.get(name)
        if data is None:
            raise ValueError(f"missing expanded asset: {name}")
        if len(data) != size:
            raise ValueError(f"expanded asset size mismatch for {name}: {len(data)} != {size}")
        regions.append((address, name, data))
    for spec in layout.get("inline_regions", []):
        name = str(spec["name"])
        address = int(spec["address"])
        data = bytes(spec["bytes"])
        regions.append((address, name, data))

    cursor = 0
    for address, name, data in sorted(regions):
        if address != bank_address + cursor:
            raise ValueError(f"expanded region is not contiguous: {name}")
        if prg[cursor:cursor + len(data)] != data:
            raise ValueError(f"expanded region mismatch for {name}")
        cursor += len(data)
    if any(value != fill for value in prg[cursor:bank_size]):
        raise ValueError("unexpected data after declared assets in expanded bank")

    expected_changes = sorted(
        layout["fixed_bank_changes"] + layout.get("screen_fixed_bank_changes", []),
        key=lambda item: int(item["address"]),
    )
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
    parser.add_argument("--sound-pointers", required=True, type=Path)
    parser.add_argument("--sound-streams", required=True, type=Path)
    parser.add_argument("--actors", required=True, type=Path)
    parser.add_argument("--palettes", required=True, type=Path)
    parser.add_argument("--screens", required=True, type=Path)
    parser.add_argument("--expected-chr", type=Path)
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
                "sound_pointer_table": args.sound_pointers.read_bytes(),
                "sound_streams": args.sound_streams.read_bytes(),
                "actor_mappings": args.actors.read_bytes(),
                "palettes": args.palettes.read_bytes(),
                "screens": args.screens.read_bytes(),
            },
            json.loads(args.layout.read_text(encoding="utf-8")),
            args.expected_chr.read_bytes() if args.expected_chr else None,
        )
    except (KeyError, TypeError, ValueError) as error:
        print(f"[ERROR] Expanded ROM validation failed: {error}")
        return 1
    print("[OK] Expanded layout, all JSON assets, and exact fixed-bank change manifest.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
