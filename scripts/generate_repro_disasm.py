#!/usr/bin/env python3
from __future__ import annotations

from rom_assets import read_source_text

import argparse
import re
from collections import defaultdict
from pathlib import Path

LINE_RE = re.compile(r"0x([0-9A-Fa-f]{6})\s+00:([0-9A-Fa-f]{4}):\s+(.+)$")
BYTES_AND_ASM_RE = re.compile(r"^([0-9A-Fa-f]{2}(?: [0-9A-Fa-f]{2})*)\s{2,}(.*)$")
LABEL_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(?:;.*)?$")


def split_comment(s: str) -> str:
    if ";" in s:
        return s.split(";", 1)[0].rstrip()
    return s.rstrip()


def split_csv_keeping_quotes(s: str) -> list[str]:
    out: list[str] = []
    buf: list[str] = []
    in_quote = False
    for ch in s:
        if ch == '"':
            in_quote = not in_quote
            buf.append(ch)
        elif ch == "," and not in_quote:
            tok = "".join(buf).strip()
            if tok:
                out.append(tok)
            buf = []
        else:
            buf.append(ch)
    tok = "".join(buf).strip()
    if tok:
        out.append(tok)
    return out


def parse_byte_args(expr: str) -> bytes:
    expr = split_comment(expr).strip()
    if not expr:
        return b""

    vals: list[int] = []
    tokens = split_csv_keeping_quotes(expr)
    for tok in tokens:
        t = tok.strip()
        if not t:
            continue
        if t.startswith('"') and t.endswith('"') and len(t) >= 2:
            vals.extend(ord(c) & 0xFF for c in t[1:-1])
            continue
        if t.startswith("$"):
            vals.append(int(t[1:], 16) & 0xFF)
            continue
        if t.startswith("%"):
            vals.append(int(t[1:], 2) & 0xFF)
            continue
        if t.lower().startswith("0x"):
            vals.append(int(t[2:], 16) & 0xFF)
            continue
        if t.isdigit():
            vals.append(int(t, 10) & 0xFF)
            continue
        m = re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*\$([0-9A-Fa-f]+)$", t)
        if m:
            vals.append(int(m.group(1), 16) & 0xFF)
            continue
        m = re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*([0-9]+)$", t)
        if m:
            vals.append(int(m.group(1), 10) & 0xFF)
            continue
        raise ValueError(f"Unsupported .byte token: {t!r}")
    return bytes(vals)


def parse_line_data(asm: str, shown_bytes: list[int]) -> bytes:
    # For byte-identical reconstruction we always trust the byte column
    # in the listing. The textual asm field can be stylistic/inconsistent.
    _ = asm
    return bytes(shown_bytes)


def parse_listing(
    path: Path, prg_blob: bytes | None = None
) -> tuple[list[tuple[int, bytes, str]], dict[int, list[str]]]:
    rows: list[tuple[int, int, list[int], str]] = []
    labels_by_addr: dict[int, list[str]] = defaultdict(list)
    pending_labels: list[str] = []

    for raw in read_source_text(path, encoding="utf-8").splitlines():
        lm = LABEL_RE.match(raw.strip())
        if lm:
            pending_labels.append(lm.group(1))
            continue

        m = LINE_RE.search(raw)
        if not m:
            continue

        addr = int(m.group(2), 16)
        tail = m.group(3)
        bm = BYTES_AND_ASM_RE.match(tail)
        if not bm:
            continue
        shown = [int(x, 16) for x in bm.group(1).split()]
        asm = bm.group(2)
        if pending_labels:
            for lbl in pending_labels:
                if lbl not in labels_by_addr[addr]:
                    labels_by_addr[addr].append(lbl)
            pending_labels = []

        rows.append((int(m.group(1), 16), addr, shown, split_comment(asm).strip()))

    if not rows:
        raise ValueError("No listing rows were parsed")

    rows.sort(key=lambda x: x[0])
    base_off = rows[0][0]
    rows = [(off - base_off, addr, shown, asm) for off, addr, shown, asm in rows]
    prev_off = -1
    for off, _, _, _ in rows:
        if off <= prev_off:
            raise ValueError(
                f"File offset order error at 0x{off + base_off:06X} after 0x{prev_off + base_off:06X}"
            )
        prev_off = off

    records: list[tuple[int, bytes, str]] = []
    expected_addr = rows[0][1]
    for i, (off, addr, shown, asm) in enumerate(rows):
        next_off = rows[i + 1][0] if i + 1 < len(rows) else 0x4000
        if next_off <= off:
            raise ValueError(f"Invalid offsets around 0x{off:06X}")
        size = next_off - off

        if prg_blob is not None:
            data = prg_blob[off : off + size]
            if len(data) != size:
                raise ValueError(
                    f"PRG blob too small for range off=0x{off:04X} size=0x{size:X}"
                )
        else:
            parsed = parse_line_data(asm, shown)
            if len(parsed) != size:
                raise ValueError(
                    f"Cannot infer exact bytes at ${addr:04X}: parsed {len(parsed)} vs expected {size}. "
                    "Provide --rom to source exact PRG bytes."
                )
            data = parsed

        if addr != expected_addr:
            raise ValueError(
                f"Address gap/overlap at ${addr:04X}, expected ${expected_addr:04X}"
            )
        expected_addr += len(data)
        records.append((addr, data, asm))

    if records[0][0] != 0xC000 or expected_addr != 0x10000:
        raise ValueError(
            f"Expected full bank address range C000-FFFF, got ${records[0][0]:04X}-${expected_addr - 1:04X}"
        )

    return records, labels_by_addr


def fmt_bytes(data: bytes) -> str:
    return ", ".join(f"${b:02X}" for b in data)


def write_ca65_disasm(out_path: Path, records: list[tuple[int, bytes, str]], labels_by_addr: dict[int, list[str]]) -> None:
    with out_path.open("w", encoding="utf-8") as f:
        f.write("; Auto-generated reproducible PRG disassembly for ca65\n")
        f.write("; Source: bank_FF.asm\n")
        f.write('; Goal: byte-identical PRG for Pac-Man (J) (V1.0) [!]\n\n')
        f.write('.setcpu "6502"\n\n')
        f.write('.segment "BANK_FF"\n\n')

        in_vectors = False
        for addr, data, asm in records:
            if not in_vectors and addr >= 0xFFFA:
                f.write('\n.segment "VECTORS"\n\n')
                in_vectors = True

            for lbl in labels_by_addr.get(addr, []):
                f.write(f"{lbl}:\n")

            comment = f"; ${addr:04X}"
            if asm:
                comment += f"  {asm}"
            f.write(f"    .byte {fmt_bytes(data)}  {comment}\n")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Generate ca65-assemblable disassembly from bank_FF.asm"
    )
    ap.add_argument("--listing", default="bank_FF.asm")
    ap.add_argument(
        "--rom",
        default=None,
        help="Optional iNES ROM to source exact PRG bytes from (recommended).",
    )
    ap.add_argument("--output", default="src/pacman_disasm_repro.asm")
    args = ap.parse_args()

    prg_blob = None
    if args.rom is not None:
        rom = Path(args.rom).read_bytes()
        if len(rom) < 16 or rom[:4] != b"NES\x1a":
            raise ValueError("Not a valid iNES ROM")
        prg_size = rom[4] * 16_384
        trainer = 512 if (rom[6] & 0x04) else 0
        prg_off = 16 + trainer
        prg_blob = rom[prg_off : prg_off + prg_size]
        if len(prg_blob) < 0x4000:
            raise ValueError("ROM PRG is smaller than 16KB")
        prg_blob = prg_blob[:0x4000]

    records, labels = parse_listing(Path(args.listing), prg_blob=prg_blob)
    out_path = Path(args.output)
    write_ca65_disasm(out_path, records, labels)
    print(f"Wrote {out_path} ({len(records)} lines)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
