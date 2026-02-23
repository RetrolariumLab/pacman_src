#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def parse_ines(data: bytes) -> dict[str, int]:
    if len(data) < 16 or data[:4] != b"NES\x1a":
        raise ValueError("Not a valid iNES ROM")
    prg_banks = data[4]
    chr_banks = data[5]
    mapper = (data[6] >> 4) | (data[7] & 0xF0)
    has_trainer = 1 if (data[6] & 0x04) else 0
    return {
        "prg_banks": prg_banks,
        "chr_banks": chr_banks,
        "mapper": mapper,
        "has_trainer": has_trainer,
        "prg_size": prg_banks * 16_384,
        "chr_size": chr_banks * 8_192,
    }


def sha1_hex(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def byte_diff_count(a: bytes, b: bytes) -> int:
    n = min(len(a), len(b))
    diff = sum(1 for i in range(n) if a[i] != b[i])
    diff += abs(len(a) - len(b))
    return diff


def first_diffs(a: bytes, b: bytes, limit: int = 16) -> list[int]:
    n = min(len(a), len(b))
    out: list[int] = []
    for i in range(n):
        if a[i] != b[i]:
            out.append(i)
            if len(out) >= limit:
                return out
    if len(a) != len(b):
        out.append(n)
    return out


def split_ines(data: bytes) -> tuple[bytes, bytes, bytes]:
    info = parse_ines(data)
    offset = 16 + (512 if info["has_trainer"] else 0)
    prg = data[offset : offset + info["prg_size"]]
    chr_ = data[
        offset + info["prg_size"] : offset + info["prg_size"] + info["chr_size"]
    ]
    return data[:16], prg, chr_


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare two NES ROM files (iNES).")
    parser.add_argument(
        "--original",
        default="Pac-Man (J) (V1.0) [!].nes",
        help="Path to original ROM",
    )
    parser.add_argument(
        "--candidate",
        default="pacman_c.nes",
        help="Path to built ROM",
    )
    args = parser.parse_args()

    orig_path = Path(args.original)
    cand_path = Path(args.candidate)

    orig = orig_path.read_bytes()
    cand = cand_path.read_bytes()

    orig_info = parse_ines(orig)
    cand_info = parse_ines(cand)

    oh, op, oc = split_ines(orig)
    ch, cp, cc = split_ines(cand)

    print(f"Original : {orig_path.name} ({len(orig)} bytes)")
    print(f"Candidate: {cand_path.name} ({len(cand)} bytes)")
    print()
    print(
        "Header  : "
        f"orig(PRG={orig_info['prg_banks']}, CHR={orig_info['chr_banks']}, mapper={orig_info['mapper']}) "
        f"cand(PRG={cand_info['prg_banks']}, CHR={cand_info['chr_banks']}, mapper={cand_info['mapper']})"
    )
    print(f"SHA1    : orig={sha1_hex(orig)} cand={sha1_hex(cand)}")
    print()

    print(f"Diff(header) : {byte_diff_count(oh, ch)} bytes")
    print(f"Diff(PRG)    : {byte_diff_count(op, cp)} bytes")
    print(f"Diff(CHR)    : {byte_diff_count(oc, cc)} bytes")
    print(f"Diff(total)  : {byte_diff_count(orig, cand)} bytes")

    offs = first_diffs(orig, cand, limit=16)
    if offs:
        pretty = ", ".join(f"0x{x:04X}" for x in offs)
        print(f"First diffs  : {pretty}")
    else:
        print("First diffs  : none (identical)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
