#!/usr/bin/env python3
"""Require a ROM-hack candidate to contain only its declared byte changes."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_native import parse_ines


def observed_differences(original: bytes, candidate: bytes) -> list[tuple[int, int, int]]:
    if len(original) != len(candidate):
        raise ValueError(
            f"ROM sizes differ: original={len(original)}, candidate={len(candidate)}"
        )
    return [
        (offset, left, right)
        for offset, (left, right) in enumerate(zip(original, candidate))
        if left != right
    ]


def expected_rom_differences(
    original: bytes,
    candidate: bytes,
    entries: list[dict[str, object]],
) -> list[tuple[int, int, int]]:
    original_header, original_prg, original_chr = parse_ines(original)
    candidate_header, candidate_prg, candidate_chr = parse_ines(candidate)
    if original_header != candidate_header:
        raise ValueError("variant manifest cannot authorize iNES header changes")
    regions = {
        "prg": (len(original_header), original_prg, candidate_prg),
        "chr": (len(original_header) + len(original_prg), original_chr, candidate_chr),
    }
    expected: list[tuple[int, int, int]] = []
    seen: set[int] = set()
    for entry in entries:
        region_name = str(entry["region"])
        if region_name not in regions:
            raise ValueError(f"unsupported difference region: {region_name}")
        base, original_region, candidate_region = regions[region_name]
        offset = int(entry["offset"])
        if not 0 <= offset < len(original_region):
            raise ValueError(f"{region_name} offset out of range: {offset}")
        rom_offset = base + offset
        if rom_offset in seen:
            raise ValueError(f"duplicate expected ROM offset: 0x{rom_offset:X}")
        seen.add(rom_offset)
        original_value = int(entry["original"])
        variant_value = int(entry["variant"])
        if original_region[offset] != original_value:
            raise ValueError(
                f"manifest original mismatch at {region_name}+0x{offset:X}: "
                f"expected 0x{original_value:02X}, got 0x{original_region[offset]:02X}"
            )
        if candidate_region[offset] != variant_value:
            raise ValueError(
                f"variant mismatch at {region_name}+0x{offset:X}: "
                f"expected 0x{variant_value:02X}, got 0x{candidate_region[offset]:02X}"
            )
        expected.append((rom_offset, original_value, variant_value))
    return sorted(expected)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original", required=True)
    parser.add_argument("--candidate", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--variant", required=True)
    args = parser.parse_args()

    original = Path(args.original).read_bytes()
    candidate = Path(args.candidate).read_bytes()
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    try:
        variant = manifest["variants"][args.variant]
        expected = expected_rom_differences(
            original, candidate, variant["expected_differences"]
        )
        observed = observed_differences(original, candidate)
    except (KeyError, TypeError, ValueError) as error:
        print(f"[ERROR] Invalid hack variant or ROM: {error}")
        return 1
    if observed != expected:
        print(f"[ERROR] Hack diff mismatch: expected {expected}, observed {observed}")
        return 1
    print(
        f"[OK] Hack variant '{args.variant}': {len(observed)} documented ROM byte "
        "difference(s)."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
