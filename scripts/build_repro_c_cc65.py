#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path


FUNC_SIG_RE = re.compile(
    r"^\s*([A-Za-z_][A-Za-z0-9_\s\*]*?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^;{}]*)\)\s*$"
)


def fail(msg: str) -> None:
    print(f"[ERROR] {msg}", file=sys.stderr)
    raise SystemExit(1)


def find_next_nonempty(lines: list[str], start: int) -> int:
    i = start
    while i < len(lines) and not lines[i].strip():
        i += 1
    return i


def detect_functions(lines: list[str]) -> tuple[int, list[tuple[str, str, str]]]:
    funcs: list[tuple[str, str, str]] = []
    first_func_idx = len(lines)
    i = 0
    while i < len(lines):
        m = FUNC_SIG_RE.match(lines[i])
        if not m:
            i += 1
            continue

        j = find_next_nonempty(lines, i + 1)
        if j >= len(lines) or lines[j].strip() != "{":
            i += 1
            continue

        if first_func_idx == len(lines):
            first_func_idx = i

        ret_t = " ".join(m.group(1).split())
        name = m.group(2)
        args = " ".join(m.group(3).split())
        funcs.append((ret_t, name, args))

        depth = 0
        k = j
        while k < len(lines):
            depth += lines[k].count("{")
            depth -= lines[k].count("}")
            k += 1
            if depth <= 0:
                break
        i = k
    return first_func_idx, funcs


def default_return_stmt(ret_t: str) -> str:
    t = ret_t.strip()
    if t == "void":
        return ""
    if "*" in t:
        return "    return 0;\n"
    return "    return 0;\n"


def generate_stub_source(input_c: Path, output_c: Path, keep_data: bool) -> tuple[int, int]:
    text = input_c.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    first_func_idx, funcs = detect_functions(lines)
    data_prefix = lines[:first_func_idx]
    # Fix one malformed banner comment emitted by exporter ("*/" inside comment text).
    data_prefix = [
        ln.replace("tbl_*/off_*/ofs_*/_off*", "tbl/off/ofs/_off")
        for ln in data_prefix
    ]

    data_symbols: set[str] = set()
    normalized_prefix: list[str] = []
    for ln in data_prefix:
        m = re.match(r"^(\s*)unsigned\s+char\s+([A-Za-z_][A-Za-z0-9_]*)\s*\[\]\s*=", ln)
        if m:
            data_symbols.add(m.group(2))
            ln = re.sub(r"^(\s*)unsigned\s+char\s+", r"\1const unsigned char ", ln)
        normalized_prefix.append(ln)
    data_prefix = normalized_prefix

    seen: set[str] = set()
    uniq_funcs: list[tuple[str, str, str]] = []
    for ret_t, name, args in funcs:
        if name in seen:
            continue
        if name in data_symbols:
            continue
        seen.add(name)
        uniq_funcs.append((ret_t, name, args))

    out: list[str] = []
    out.append("/* Auto-generated cc65-friendly stub translation from Ghidra decomp */")
    out.append("/* Data blocks are preserved; function bodies are reduced to stubs. */")
    out.append("")
    out.append("typedef unsigned char byte;")
    out.append("typedef unsigned char undefined1;")
    out.append("typedef unsigned int undefined2;")
    out.append("typedef unsigned long undefined4;")
    out.append("typedef unsigned int ushort;")
    out.append("#ifndef true")
    out.append("#define true 1")
    out.append("#endif")
    out.append("#ifndef false")
    out.append("#define false 0")
    out.append("#endif")
    out.append("")
    if keep_data:
        out.extend(data_prefix)
    if out and out[-1].strip():
        out.append("")
    out.append("/* cc65 stubs for decompiled functions */")
    out.append("")

    for ret_t, name, args in uniq_funcs:
        # Minimal ROM mode: emit flat no-arg stubs to avoid cc65 runtime helper deps.
        if not keep_data:
            sig = f"void {name}(void)"
        else:
            sig = f"{ret_t} {name}({args})".strip()
        out.append(sig)
        out.append("{")
        ret_stmt = default_return_stmt(ret_t)
        if keep_data and ret_stmt:
            out.append(ret_stmt.rstrip("\n"))
        out.append("}")
        out.append("")

    output_c.write_text("\n".join(out) + "\n", encoding="utf-8")
    return len(uniq_funcs), len(data_prefix)


def run_cmd(cmd: list[str]) -> None:
    print("[CMD]", " ".join(cmd))
    res = subprocess.run(cmd, check=False)
    if res.returncode != 0:
        fail(f"Command failed with exit code {res.returncode}")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Generate cc65-compilable stub C from Ghidra decomp and compile it."
    )
    ap.add_argument("--input", default="pacman_repro_layout_decomp.c")
    ap.add_argument("--output", default="pacman_repro_layout_decomp_cc65.c")
    ap.add_argument("--obj", default="pacman_repro_layout_decomp_cc65.o")
    ap.add_argument("--drop-data", action="store_true")
    ap.add_argument("--no-compile", action="store_true")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    input_c = (root / args.input).resolve()
    output_c = (root / args.output).resolve()
    out_obj = (root / args.obj).resolve()
    cc65 = (root / "bin" / "cc65.exe").resolve()
    ca65 = (root / "bin" / "ca65.exe").resolve()

    if not input_c.is_file():
        fail(f"Input C not found: {input_c}")
    if not cc65.is_file():
        fail(f"cc65.exe not found: {cc65}")
    if not ca65.is_file():
        fail(f"ca65.exe not found: {ca65}")

    fn_count, data_lines = generate_stub_source(input_c, output_c, keep_data=(not args.drop_data))
    print(f"[OK] Wrote cc65-friendly C: {output_c}")
    print(f"[INFO] data prefix lines kept: {data_lines if not args.drop_data else 0}")
    print(f"[INFO] function stubs emitted: {fn_count}")

    if not args.no_compile:
        fd, tmp_name = tempfile.mkstemp(prefix="pacman_repro_cc65_", suffix=".s")
        Path(tmp_name).unlink(missing_ok=True)
        tmp_s = Path(tmp_name)

        run_cmd(
            [
                "wine",
                str(cc65),
                "-O",
                "-t",
                "nes",
                str(output_c),
                "-o",
                str(tmp_s),
            ]
        )

        asm_text = tmp_s.read_text(encoding="utf-8", errors="replace")
        asm_text = asm_text.replace("\t.macpack\tlongbranch\n", "")
        asm_text = asm_text.replace(".macpack\tlongbranch\n", "")
        tmp_s.write_text(asm_text, encoding="utf-8")

        run_cmd(
            [
                "wine",
                str(ca65),
                str(tmp_s),
                "-o",
                str(out_obj),
            ]
        )
        tmp_s.unlink(missing_ok=True)
        print(f"[OK] cc65 object built: {out_obj}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
