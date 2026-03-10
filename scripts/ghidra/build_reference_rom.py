#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from build_bank_ff_bin import parse_listing

INES_HEADER_SIZE = 16
PRG_BANK_SIZE = 16_384
CHR_BANK_SIZE = 8_192


def make_ines_header(prg_banks: int, chr_banks: int, mapper: int = 0, mirroring_vertical: bool = False) -> bytes:
    flag6 = ((mapper & 0x0F) << 4) | (0x01 if mirroring_vertical else 0x00)
    flag7 = mapper & 0xF0
    return bytes([
        0x4E,
        0x45,
        0x53,
        0x1A,
        prg_banks & 0xFF,
        chr_banks & 0xFF,
        flag6 & 0xFF,
        flag7 & 0xFF,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    ])


def load_chr(chr_path: str | None) -> tuple[bytes, int]:
    if chr_path is None:
        return b"\x00" * CHR_BANK_SIZE, 1

    data = Path(chr_path).read_bytes()
    if len(data) == 0:
        return b"", 0

    if len(data) % CHR_BANK_SIZE != 0:
        raise ValueError(
            f"CHR size must be multiple of {CHR_BANK_SIZE} bytes, got {len(data)}"
        )

    banks = len(data) // CHR_BANK_SIZE
    return data, banks


def main() -> int:
    p = argparse.ArgumentParser(
        description='Build iNES reference ROM from bank_FF.asm listing.'
    )
    p.add_argument('listing', nargs='?', default='bank_FF.asm')
    p.add_argument('-o', '--output', default='pacman_bank_ff_ref.nes')
    p.add_argument(
        '--chr',
        dest='chr_path',
        default=None,
        help='Optional CHR data file. If omitted, writes 8KB zero CHR bank.',
    )
    p.add_argument(
        '--vertical-mirroring',
        action='store_true',
        help='Set iNES mirroring bit to vertical (default: horizontal).',
    )
    args = p.parse_args()

    prg = parse_listing(Path(args.listing))
    if len(prg) != PRG_BANK_SIZE:
        raise ValueError(
            f"PRG size from listing must be {PRG_BANK_SIZE} bytes, got {len(prg)}"
        )

    chr_data, chr_banks = load_chr(args.chr_path)
    header = make_ines_header(
        prg_banks=1,
        chr_banks=chr_banks,
        mapper=0,
        mirroring_vertical=args.vertical_mirroring,
    )

    out = header + prg + chr_data
    out_path = Path(args.output)
    out_path.write_bytes(out)

    print(f"Wrote {out_path} ({len(out)} bytes)")
    print(f"iNES: PRG=1 bank ({PRG_BANK_SIZE} bytes), CHR={chr_banks} bank(s), mapper=0")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
