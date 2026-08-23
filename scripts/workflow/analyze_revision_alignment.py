#!/usr/bin/env python3
"""Align two NROM Pac-Man PRGs without assuming equal code addresses."""

from __future__ import annotations

import argparse
import collections
import difflib
from pathlib import Path


PRG_BASE = 0xC000
PRG_SIZE = 16_384


def read_prg(path: Path) -> bytes:
    data = path.read_bytes()
    if len(data) < 16 or data[:4] != b"NES\x1a":
        raise ValueError(f"not an iNES ROM: {path}")
    trainer_size = 512 if data[6] & 0x04 else 0
    prg_size = data[4] * 16_384
    start = 16 + trainer_size
    prg = data[start : start + prg_size]
    if len(prg) != PRG_SIZE:
        raise ValueError(f"expected one 16 KiB PRG bank, got {len(prg)} bytes")
    return prg


def address(offset: int) -> str:
    return f"${PRG_BASE + offset:04X}"


def analyze(reference: bytes, candidate: bytes, min_block: int) -> tuple[list, list]:
    matcher = difflib.SequenceMatcher(None, reference, candidate, autojunk=False)
    blocks = [block for block in matcher.get_matching_blocks() if block.size >= min_block]
    changes = [opcode for opcode in matcher.get_opcodes() if opcode[0] != "equal"]
    return blocks, changes


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--min-block", type=int, default=8)
    parser.add_argument("--limit", type=int, default=40)
    args = parser.parse_args()

    if args.min_block < 1:
        parser.error("--min-block must be positive")
    if args.limit < 1:
        parser.error("--limit must be positive")

    try:
        reference = read_prg(args.reference)
        candidate = read_prg(args.candidate)
    except (OSError, ValueError) as error:
        parser.error(str(error))

    blocks, changes = analyze(reference, candidate, args.min_block)
    covered = sum(block.size for block in blocks)
    deltas: collections.Counter[int] = collections.Counter()
    for block in blocks:
        deltas[block.b - block.a] += block.size

    print(
        f"[OK] {covered}/{PRG_SIZE} bytes ({covered / PRG_SIZE:.1%}) "
        f"aligned in {len(blocks)} blocks of at least {args.min_block} bytes."
    )
    print(f"[INFO] {len(changes)} non-equal alignment operations.")
    print("\nDominant address deltas:")
    for delta, size in deltas.most_common(args.limit):
        print(f"  {delta:+6} bytes  {size:5} matched bytes")

    print("\nLargest aligned blocks:")
    largest = sorted(blocks, key=lambda block: block.size, reverse=True)
    for block in largest[: args.limit]:
        print(
            f"  {address(block.a)} -> {address(block.b)}  "
            f"delta={block.b - block.a:+5}  size={block.size:4}"
        )

    print("\nStructural edits of at least four bytes:")
    shown = 0
    for tag, ref_start, ref_end, cand_start, cand_end in changes:
        ref_size = ref_end - ref_start
        cand_size = cand_end - cand_start
        if max(ref_size, cand_size) < 4:
            continue
        print(
            f"  {tag:7} ref={address(ref_start)}+{ref_size:<4} "
            f"candidate={address(cand_start)}+{cand_size:<4} "
            f"delta-after={cand_end - ref_end:+5}"
        )
        shown += 1
        if shown == args.limit:
            break
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
