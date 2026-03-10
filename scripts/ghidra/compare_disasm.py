#!/usr/bin/env python3
from __future__ import annotations

from rom_assets import read_source_text

import argparse
import re
from dataclasses import dataclass
from pathlib import Path

MNEM_RE = r"[A-Za-z]{3}"

BANK_PREFIX_RE = re.compile(r"00:([0-9A-Fa-f]{4}):\s*(.*)$")
BANK_TAIL_RE = re.compile(
    rf"^([0-9A-Fa-f]{{2}}(?:\s+[0-9A-Fa-f]{{2}})*)\s{{2,}}({MNEM_RE})\b"
)
GHIDRA_RE = re.compile(
    rf"^([0-9A-Fa-f]{{4}}):\s*([0-9A-Fa-f]{{2}}(?:\s+[0-9A-Fa-f]{{2}})*)\s+({MNEM_RE})\b"
)

LABEL_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(?:;.*)?$")
BYTES_AND_ASM_RE = re.compile(r"^([0-9A-Fa-f]{2}(?:\s+[0-9A-Fa-f]{2})*)\s{2,}(.*)$")


@dataclass(frozen=True)
class Instr:
    addr: str
    bytes_hex: str
    mnemonic: str
    src_line_no: int

    @property
    def key(self) -> str:
        return f"{self.addr}: {self.bytes_hex} {self.mnemonic}"


def _collapse_spaces(s: str) -> str:
    return re.sub(r"\s+", " ", s.strip())


def _strip_comment(s: str) -> str:
    if ";" in s:
        return s.split(";", 1)[0].rstrip()
    return s.rstrip()


def _parse_bank_instr(path: Path) -> list[Instr]:
    out: list[Instr] = []
    for i, raw in enumerate(read_source_text(path, encoding="utf-8").splitlines(), start=1):
        line = _strip_comment(raw)
        if not line.strip():
            continue

        pm = BANK_PREFIX_RE.search(line)
        if not pm:
            continue

        addr = pm.group(1).lower()
        tail = pm.group(2)
        tm = BANK_TAIL_RE.match(tail)
        if not tm:
            continue

        bytes_hex = _collapse_spaces(tm.group(1)).upper()
        mnemonic = tm.group(2).upper()
        out.append(Instr(addr, bytes_hex, mnemonic, i))
    return out


def _parse_ghidra_instr(path: Path) -> list[Instr]:
    out: list[Instr] = []
    for i, raw in enumerate(read_source_text(path, encoding="utf-8").splitlines(), start=1):
        line = _strip_comment(raw)
        if not line.strip():
            continue

        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*:\s*$", line):
            continue

        m = GHIDRA_RE.search(_collapse_spaces(line))
        if not m:
            continue

        addr = m.group(1).lower()
        bytes_hex = _collapse_spaces(m.group(2)).upper()
        mnemonic = m.group(3).upper()
        out.append(Instr(addr, bytes_hex, mnemonic, i))
    return out


def _to_addr_map(instrs: list[Instr]) -> dict[str, Instr]:
    out: dict[str, Instr] = {}
    for ins in instrs:
        if ins.addr not in out:
            out[ins.addr] = ins
    return out


def _parse_labels(path: Path) -> set[str]:
    labels: set[str] = set()
    for raw in read_source_text(path, encoding="utf-8").splitlines():
        m = LABEL_RE.match(raw.strip())
        if not m:
            continue
        name = m.group(1)
        if re.fullmatch(r"[0-9A-Fa-f]{4}", name):
            continue
        labels.add(name)
    return labels


def _parse_table_bytes_bank(path: Path) -> dict[str, bytes]:
    def split_csv_keeping_quotes(s: str) -> list[str]:
        out: list[str] = []
        buf: list[str] = []
        in_quote = False
        for ch in s:
            if ch == '\"':
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

    def parse_num_token(tok: str) -> int | None:
        t = tok.strip()
        if not t:
            return None
        if t.startswith("$"):
            try:
                return int(t[1:], 16)
            except ValueError:
                return None
        if t.startswith("%"):
            try:
                return int(t[1:], 2)
            except ValueError:
                return None
        if t.lower().startswith("0x"):
            try:
                return int(t[2:], 16)
            except ValueError:
                return None
        if re.fullmatch(r"[0-9]+", t):
            try:
                return int(t, 10)
            except ValueError:
                return None
        return None

    def parse_byte_args(expr: str, shown: list[int]) -> bytes:
        expr = _strip_comment(expr).strip()
        if not expr:
            return bytes(shown)

        vals: list[int] = []
        tokens = split_csv_keeping_quotes(expr)
        for tok in tokens:
            t = tok.strip()
            if not t:
                continue
            if t.startswith('\"') and t.endswith('\"') and len(t) >= 2:
                vals.extend(ord(c) & 0xFF for c in t[1:-1])
                continue
            if t.startswith("$"):
                vals.append(int(t[1:], 16) & 0xFF)
                continue
            if t.startswith("%"):
                vals.append(int(t[1:], 2) & 0xFF)
                continue
            if t.isdigit():
                vals.append(int(t) & 0xFF)
                continue
            if t.lower().startswith("0x"):
                vals.append(int(t[2:], 16) & 0xFF)
                continue
            m = re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*\$([0-9A-Fa-f]+)$", t)
            if m:
                vals.append(int(m.group(1), 16) & 0xFF)
                continue
            m = re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*\+\s*([0-9]+)$", t)
            if m:
                vals.append(int(m.group(1), 10) & 0xFF)
                continue
            # Symbol-only constants are already resolved in listing's byte column.
            if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", t):
                if len(tokens) == 1:
                    return bytes(shown)
            return bytes(shown)
        return bytes(vals)

    def parse_word_like_args(expr: str, shown: list[int], little_endian: bool) -> bytes:
        expr = _strip_comment(expr).strip()
        if not expr:
            return bytes(shown)

        vals: list[int] = []
        tokens = split_csv_keeping_quotes(expr)
        for tok in tokens:
            n = parse_num_token(tok)
            if n is None:
                return bytes(shown)
            lo = n & 0xFF
            hi = (n >> 8) & 0xFF
            if little_endian:
                vals.extend((lo, hi))
            else:
                vals.extend((hi, lo))
        return bytes(vals)

    tables: dict[str, bytearray] = {}
    current: str | None = None

    for raw in read_source_text(path, encoding="utf-8").splitlines():
        lm = LABEL_RE.match(raw.strip())
        if lm:
            lbl = lm.group(1)
            current = lbl if lbl.startswith("tbl_") else None
            if current is not None and current not in tables:
                tables[current] = bytearray()
            continue

        if current is None:
            continue

        line = _strip_comment(raw)
        pm = BANK_PREFIX_RE.search(line)
        if not pm:
            continue
        tail = pm.group(2)
        bm = BYTES_AND_ASM_RE.match(tail)
        if not bm:
            continue
        shown = [int(x, 16) for x in bm.group(1).split()]
        asm = bm.group(2).strip()
        data = b""
        if asm.startswith(".byte"):
            expr = asm[len(".byte") :].strip()
            data = parse_byte_args(expr, shown)
        elif asm.startswith(".word"):
            expr = asm[len(".word") :].strip()
            data = parse_word_like_args(expr, shown, little_endian=True)
        elif asm.startswith(".dbyt"):
            expr = asm[len(".dbyt") :].strip()
            data = parse_word_like_args(expr, shown, little_endian=False)
        else:
            continue
        tables[current].extend(data)

    return {k: bytes(v) for k, v in tables.items()}


def _parse_ghidra_byte_tokens(expr: str) -> list[int]:
    out: list[int] = []
    for tok in expr.split(","):
        t = tok.strip()
        if not t:
            continue
        if t.startswith("$"):
            out.append(int(t[1:], 16) & 0xFF)
        elif t.lower().startswith("0x"):
            out.append(int(t[2:], 16) & 0xFF)
        elif t.isdigit():
            out.append(int(t) & 0xFF)
    return out


def _parse_ghidra_word_tokens(expr: str, little_endian: bool) -> list[int]:
    out: list[int] = []
    for tok in expr.split(","):
        t = tok.strip()
        if not t:
            continue
        n: int | None = None
        if t.startswith("$"):
            n = int(t[1:], 16)
        elif t.lower().startswith("0x"):
            n = int(t[2:], 16)
        elif t.isdigit():
            n = int(t)
        if n is None:
            continue
        lo = n & 0xFF
        hi = (n >> 8) & 0xFF
        if little_endian:
            out.extend((lo, hi))
        else:
            out.extend((hi, lo))
    return out


def _parse_table_bytes_ghidra(path: Path) -> dict[str, bytes]:
    tables: dict[str, bytearray] = {}
    current: str | None = None

    for raw in read_source_text(path, encoding="utf-8").splitlines():
        line = raw.strip()
        lm = LABEL_RE.match(line)
        if lm:
            lbl = lm.group(1)
            current = lbl if lbl.startswith("tbl_") else None
            if current is not None and current not in tables:
                tables[current] = bytearray()
            continue

        if current is None:
            continue

        stripped = _strip_comment(line)
        if not stripped:
            continue

        vals: list[int] = []
        if ".byte" in stripped:
            _, rhs = stripped.split(".byte", 1)
            vals = _parse_ghidra_byte_tokens(rhs)
        elif ".word" in stripped:
            _, rhs = stripped.split(".word", 1)
            vals = _parse_ghidra_word_tokens(rhs, little_endian=True)
        elif ".dbyt" in stripped:
            _, rhs = stripped.split(".dbyt", 1)
            vals = _parse_ghidra_word_tokens(rhs, little_endian=False)
        else:
            continue
        tables[current].extend(vals)

    return {k: bytes(v) for k, v in tables.items()}


def _first_byte_diff(a: bytes, b: bytes) -> int | None:
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            return i
    if len(a) != len(b):
        return n
    return None


def main() -> int:
    ap = argparse.ArgumentParser(
        description=(
            "Compare bank_FF.asm vs pacman_original_disasm.asm with normalization. "
            "Reports label differences, tbl_* byte differences, and instruction differences."
        )
    )
    ap.add_argument("--bank", default="bank_FF.asm")
    ap.add_argument("--ghidra", default="pacman_original_disasm.asm")
    ap.add_argument("--max-labels", type=int, default=50)
    ap.add_argument("--max-tables", type=int, default=50)
    ap.add_argument("--max-instr-diffs", type=int, default=50)
    args = ap.parse_args()

    bank_path = Path(args.bank)
    ghidra_path = Path(args.ghidra)

    bank_labels = _parse_labels(bank_path)
    ghidra_labels = _parse_labels(ghidra_path)

    missing_in_ghidra = sorted(bank_labels - ghidra_labels)
    extra_in_ghidra = sorted(ghidra_labels - bank_labels)

    bank_tables = _parse_table_bytes_bank(bank_path)
    ghidra_tables = _parse_table_bytes_ghidra(ghidra_path)

    bank_tbl_names = set(bank_tables.keys())
    ghidra_tbl_names = set(ghidra_tables.keys())
    common_tbl_names = sorted(bank_tbl_names & ghidra_tbl_names)

    missing_tbl_in_ghidra = sorted(bank_tbl_names - ghidra_tbl_names)
    extra_tbl_in_ghidra = sorted(ghidra_tbl_names - bank_tbl_names)

    table_diffs: list[str] = []
    table_diff_count = 0
    for name in common_tbl_names:
        b = bank_tables[name]
        g = ghidra_tables[name]
        d = _first_byte_diff(b, g)
        if d is not None:
            table_diff_count += 1
            if len(table_diffs) < args.max_tables:
                bv = b[d] if d < len(b) else None
                gv = g[d] if d < len(g) else None
                bvs = f"0x{bv:02X}" if bv is not None else "<eof>"
                gvs = f"0x{gv:02X}" if gv is not None else "<eof>"
                table_diffs.append(
                    f"{name}: first diff at byte {d} (bank={bvs}, ghidra={gvs}), "
                    f"sizes: bank={len(b)}, ghidra={len(g)}"
                )

    bank_instr = _parse_bank_instr(bank_path)
    ghidra_instr = _parse_ghidra_instr(ghidra_path)
    bank_map = _to_addr_map(bank_instr)
    ghidra_map = _to_addr_map(ghidra_instr)

    bank_addrs = set(bank_map.keys())
    ghidra_addrs = set(ghidra_map.keys())
    common_addrs = sorted(bank_addrs & ghidra_addrs)

    instr_mismatch = 0
    instr_mismatch_lines: list[str] = []
    for addr in common_addrs:
        b = bank_map[addr]
        g = ghidra_map[addr]
        if b.key != g.key:
            instr_mismatch += 1
            if len(instr_mismatch_lines) < args.max_instr_diffs:
                instr_mismatch_lines.append(
                    f"addr {addr}: bank[{b.src_line_no}] {b.key} != ghidra[{g.src_line_no}] {g.key}"
                )

    only_bank_instr = sorted(bank_addrs - ghidra_addrs)
    only_ghidra_instr = sorted(ghidra_addrs - bank_addrs)

    print("=== LABELS ===")
    print(f"bank labels   : {len(bank_labels)}")
    print(f"ghidra labels : {len(ghidra_labels)}")
    print(f"missing in ghidra: {len(missing_in_ghidra)}")
    for x in missing_in_ghidra[: args.max_labels]:
        print(f"  - {x}")
    print(f"extra in ghidra: {len(extra_in_ghidra)}")
    for x in extra_in_ghidra[: args.max_labels]:
        print(f"  + {x}")

    print("\n=== TABLES (tbl_*) ===")
    print(f"bank tables   : {len(bank_tbl_names)}")
    print(f"ghidra tables : {len(ghidra_tbl_names)}")
    print(f"missing tbl_* in ghidra: {len(missing_tbl_in_ghidra)}")
    for x in missing_tbl_in_ghidra[: args.max_tables]:
        print(f"  - {x}")
    print(f"extra tbl_* in ghidra: {len(extra_tbl_in_ghidra)}")
    for x in extra_tbl_in_ghidra[: args.max_tables]:
        print(f"  + {x}")
    print(f"tbl_* byte mismatches: {table_diff_count}")
    for x in table_diffs:
        print(f"  * {x}")

    print("\n=== INSTRUCTIONS ===")
    print(f"bank instructions unique addresses  : {len(bank_addrs)}")
    print(f"ghidra instructions unique addresses: {len(ghidra_addrs)}")
    print(f"same-address opcode/mnemonic mismatches: {instr_mismatch}")
    for x in instr_mismatch_lines:
        print(f"  * {x}")
    print(f"only in bank addresses  : {len(only_bank_instr)}")
    print(f"only in ghidra addresses: {len(only_ghidra_instr)}")

    total_diff_score = (
        len(missing_in_ghidra)
        + len(extra_in_ghidra)
        + len(missing_tbl_in_ghidra)
        + len(extra_tbl_in_ghidra)
        + table_diff_count
        + instr_mismatch
        + len(only_bank_instr)
        + len(only_ghidra_instr)
    )

    print("\n=== SUMMARY ===")
    if total_diff_score == 0:
        print("MATCH: no differences found")
        return 0

    print("DIFFERENCES FOUND")
    print(f"aggregate difference score: {total_diff_score}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
