#!/usr/bin/env python3
"""Write a relocated copy of the source: one $EA byte at the bank origin and
one more after every module, so each module moves one byte further than the
one before, while the fixed tail and vectors stay put. The bytes are never
executed; a build that still plays the movies shows that nothing depends on
the original addresses."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

INCLUDE_RE = re.compile(r'^(?P<indent>\s*)\.include "(?P<path>[^"]+)"(?P<tail>.*)$')
ORIGIN_RE = re.compile(r"^\.org \$C000$")
EA_DIRECTIVE = "    .byte $EA"
TAIL_MODULE = "data/tail_and_vectors.asm"


def parse_modules(main_source: Path) -> list[str]:
    modules = [match.group("path") for line in main_source.read_text(encoding="utf-8").splitlines()
               if (match := INCLUDE_RE.fullmatch(line)) and match.group("path").endswith(".asm")]
    if len(modules) < 2 or modules[-1] != TAIL_MODULE:
        raise ValueError(f"the main source must end with {TAIL_MODULE}")
    return modules


def insert_origin_ea(source: str) -> str:
    output: list[str] = []
    inserted = 0
    for line in source.splitlines():
        output.append(line)
        if ORIGIN_RE.fullmatch(line):
            output.append(EA_DIRECTIVE)
            inserted += 1
    if inserted != 1:
        raise ValueError(f"expected one .org $C000 directive, found {inserted}")
    return "\n".join(output) + "\n"


def relocate(main_source: Path, output: Path) -> list[tuple[str, int]]:
    """Write the relocated main source (and its first module) to output's
    folder; return each moved module with its shift in bytes."""
    source_root = main_source.resolve().parent
    modules = parse_modules(main_source)
    first = output.parent / Path(modules[0]).name
    first.parent.mkdir(parents=True, exist_ok=True)
    first.write_text(insert_origin_ea((source_root / modules[0]).read_text(encoding="utf-8")),
                     encoding="utf-8", newline="\n")
    lines: list[str] = []
    index = 0
    for line in main_source.read_text(encoding="utf-8").splitlines():
        match = INCLUDE_RE.fullmatch(line)
        if match is None:
            lines.append(line)
            continue
        path = first.name if match.group("path") == modules[0] else match.group("path")
        lines.append(f'{match.group("indent")}.include "{path}"{match.group("tail")}')
        if match.group("path").endswith(".asm"):
            if index < len(modules) - 2:
                lines.append(EA_DIRECTIVE)
            index += 1
    output.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    return [(f"src/{module}", shift) for shift, module in enumerate(modules[:-1], 1)]


def relocate_entry(entry: Path, output_dir: Path) -> list[tuple[str, int]]:
    """Relocate the main source a revision's entry file includes, and write
    the entry file beside it, including the relocated copy."""
    main_source = entry.resolve().parent.parent / "main.asm"
    shifts = relocate(main_source, output_dir / "main.asm")
    text = entry.read_text(encoding="utf-8")
    if text.count('.include "../main.asm"') != 1:
        raise ValueError(f"{entry} must include ../main.asm once")
    text = text.replace('.include "../main.asm"', '.include "main.asm"')
    text = text.replace('.include "profile_ids.inc"', '.include "revisions/profile_ids.inc"')
    (output_dir / entry.name).write_text(text, encoding="utf-8", newline="\n")
    return shifts


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("--entry", type=Path, required=True, help="src/revisions/<id>.asm")
    parser.add_argument("--output-dir", type=Path, required=True, help="the folder of the relocated source")
    args = parser.parse_args()
    shifts = relocate_entry(args.entry, args.output_dir)
    print(f"[OK] Relocated source: {len(shifts)} modules moved by 1 to {shifts[-1][1]} bytes.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
