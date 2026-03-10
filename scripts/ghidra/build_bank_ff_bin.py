#!/usr/bin/env python3
from __future__ import annotations

from rom_assets import read_source_text

import argparse
import re
from pathlib import Path

LINE_RE = re.compile(r'0x([0-9A-Fa-f]{6})\s+00:([0-9A-Fa-f]{4}):\s+(.+)$')
BYTES_AND_ASM_RE = re.compile(r'^([0-9A-Fa-f]{2}(?: [0-9A-Fa-f]{2})*)\s{2,}(.*)$')


def split_comment(s: str) -> str:
    if ';' in s:
        return s.split(';', 1)[0].rstrip()
    return s.rstrip()


def split_csv_keeping_quotes(s: str) -> list[str]:
    out: list[str] = []
    buf: list[str] = []
    in_quote = False
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == '"':
            in_quote = not in_quote
            buf.append(ch)
        elif ch == ',' and not in_quote:
            token = ''.join(buf).strip()
            if token:
                out.append(token)
            buf = []
        else:
            buf.append(ch)
        i += 1

    token = ''.join(buf).strip()
    if token:
        out.append(token)
    return out


def parse_byte_args(expr: str) -> bytes:
    expr = split_comment(expr).strip()
    if not expr:
        return b''

    tokens = split_csv_keeping_quotes(expr)
    values: list[int] = []
    for tok in tokens:
        tok = tok.strip()
        if not tok:
            continue

        if tok.startswith('"') and tok.endswith('"') and len(tok) >= 2:
            text = tok[1:-1]
            values.extend(ord(c) & 0xFF for c in text)
            continue

        if tok.startswith('$'):
            values.append(int(tok[1:], 16) & 0xFF)
            continue

        if tok.startswith('%'):
            values.append(int(tok[1:], 2) & 0xFF)
            continue

        if tok.isdigit():
            values.append(int(tok, 10) & 0xFF)
            continue

        # Handles forms like: con_tile + $08
        m = re.match(r'^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*\$([0-9A-Fa-f]+)$', tok)
        if m:
            values.append(int(m.group(1), 16) & 0xFF)
            continue

        # Handles forms like: con_tile + 8
        m = re.match(r'^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*([0-9]+)$', tok)
        if m:
            values.append(int(m.group(1), 10) & 0xFF)
            continue

        # Standalone symbolic constants are resolved by the listing byte column.
        if re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', tok):
            if len(tokens) == 1:
                raise ValueError('SYMBOL_ONLY')
            raise ValueError('Unsupported multi-token symbol in .byte: %r' % tok)

        raise ValueError('Unsupported .byte token: %r' % tok)

    return bytes(values)


def parse_line_data(asm: str, shown_bytes: list[int]) -> bytes:
    asm_nc = split_comment(asm).strip()
    if asm_nc.startswith('.byte'):
        expr = asm_nc[len('.byte') :].strip()
        try:
            return parse_byte_args(expr)
        except ValueError as exc:
            if str(exc) == 'SYMBOL_ONLY':
                return bytes(shown_bytes)
            raise
    return bytes(shown_bytes)


def parse_listing(path: Path) -> bytes:
    chunks: list[tuple[int, bytes, str]] = []

    for idx, raw in enumerate(read_source_text(path, encoding='utf-8').splitlines(), start=1):
        m = LINE_RE.search(raw)
        if not m:
            continue

        file_off = int(m.group(1), 16)
        tail = m.group(3)
        bm = BYTES_AND_ASM_RE.match(tail)
        if not bm:
            continue

        shown = [int(x, 16) for x in bm.group(1).split()]
        asm = bm.group(2)

        data = parse_line_data(asm, shown)
        if not data:
            raise ValueError('No bytes parsed at line %d: %s' % (idx, raw))
        chunks.append((file_off, data, raw))

    if not chunks:
        raise ValueError('No listing rows were parsed')

    chunks.sort(key=lambda x: x[0])
    expected = chunks[0][0]
    out = bytearray()

    for off, data, raw in chunks:
        if off != expected:
            raise ValueError(
                'Gap/overlap at file offset 0x%06X (expected 0x%06X)\n%s'
                % (off, expected, raw)
            )
        out.extend(data)
        expected += len(data)

    return bytes(out)


def main() -> int:
    p = argparse.ArgumentParser(description='Build raw bank_FF.bin from bank_FF.asm listing.')
    p.add_argument('listing', nargs='?', default='bank_FF.asm')
    p.add_argument('-o', '--output', default='bank_FF.bin')
    args = p.parse_args()

    listing = Path(args.listing)
    output = Path(args.output)

    blob = parse_listing(listing)
    output.write_bytes(blob)

    print('Wrote %s (%d bytes)' % (output, len(blob)))
    if len(blob) != 0x4000:
        print('WARNING: expected 0x4000 bytes for NROM-128 PRG bank, got 0x%X' % len(blob))

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
