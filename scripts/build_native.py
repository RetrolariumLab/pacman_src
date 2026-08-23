#!/usr/bin/env python3
"""Build the native modular ca65 source and optionally verify the ROM."""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path

from debug_symbols import normalize_dbg_for_ines


PRG_SIZE = 16_384


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def resolve_tool(name: str, project_root: Path) -> Path:
    bundled = project_root / "bin" / f"{name}.exe"
    if bundled.is_file():
        return bundled
    found = shutil.which(name)
    if found:
        return Path(found)
    fail(f"{name} not found (expected in bin/ or PATH)")
    raise AssertionError


def run_tool(tool: Path, arguments: list[str], cwd: Path) -> None:
    command = [str(tool), *arguments]
    if os.name != "nt" and tool.suffix.lower() == ".exe":
        if not shutil.which("wine"):
            fail(f"wine not found in PATH (needed to run {tool.name})")
        command.insert(0, "wine")
    print("[RUN]", " ".join(command))
    result = subprocess.run(command, cwd=str(cwd), check=False)
    if result.returncode != 0:
        fail(f"Command failed with exit code {result.returncode}")


def assemble_prg(
    project_root: Path,
    source: Path,
    config: Path,
    object_path: Path,
    prg_path: Path,
    labels_path: Path,
    map_path: Path,
    debug_path: Path,
    output_rom_path: Path,
    expected_prg_size: int = PRG_SIZE,
    defines: list[str] | None = None,
) -> bytes:
    object_path.parent.mkdir(parents=True, exist_ok=True)
    prg_path.parent.mkdir(parents=True, exist_ok=True)
    labels_path.parent.mkdir(parents=True, exist_ok=True)
    map_path.parent.mkdir(parents=True, exist_ok=True)
    debug_path.parent.mkdir(parents=True, exist_ok=True)
    raw_debug_path = debug_path.with_name(f"{debug_path.stem}.ld65.dbg")
    ca65 = resolve_tool("ca65", project_root)
    ld65 = resolve_tool("ld65", project_root)
    ca65_arguments = [str(source), "-g"]
    for define in defines or []:
        ca65_arguments.extend(["-D", define])
    ca65_arguments.extend(
        [
            "-I",
            str(source.parent),
            "-I",
            str(project_root),
            "-o",
            str(object_path),
        ]
    )
    run_tool(ca65, ca65_arguments, project_root)
    run_tool(
        ld65,
        [
            "-C",
            str(config),
            str(object_path),
            "-o",
            str(prg_path),
            "-Ln",
            str(labels_path),
            "--mapfile",
            str(map_path),
            "-vm",
            "--dbgfile",
            str(raw_debug_path),
        ],
        project_root,
    )
    normalize_dbg_for_ines(
        raw_debug_path,
        debug_path,
        prg_path,
        output_rom_path,
    )
    raw_debug_path.unlink()
    prg = prg_path.read_bytes()
    if len(prg) != expected_prg_size:
        fail(f"Linked PRG must be {expected_prg_size} bytes, got {len(prg)}")
    return prg


def parse_ines(data: bytes) -> tuple[bytes, bytes, bytes]:
    if len(data) < 16 or data[:4] != b"NES\x1a":
        fail("Reference ROM is not valid iNES")
    trainer_size = 512 if data[6] & 0x04 else 0
    prg_size = data[4] * PRG_SIZE
    chr_size = data[5] * 8_192
    prg_offset = 16 + trainer_size
    return (
        data[:16],
        data[prg_offset : prg_offset + prg_size],
        data[prg_offset + prg_size : prg_offset + prg_size + chr_size],
    )


def first_diff(left: bytes, right: bytes) -> int | None:
    for index, (a, b) in enumerate(zip(left, right)):
        if a != b:
            return index
    return min(len(left), len(right)) if len(left) != len(right) else None


def sha1(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def rooted(project_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else project_root / path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default="src/main.asm")
    parser.add_argument("--config", default="src/nrom128_prg_only.cfg")
    parser.add_argument("--original-rom", default="Pac-Man (J) (V1.0) [!].nes")
    parser.add_argument("--chr", default="assets/generated/chr/pacman.chr")
    parser.add_argument("--object", default="build/pacman.o")
    parser.add_argument("--prg", default="build/pacman.prg")
    parser.add_argument("--labels", default="build/pacman.lbl")
    parser.add_argument("--map", default="build/pacman.map")
    parser.add_argument("--debug-info", default="build/pacman.dbg")
    parser.add_argument("--output-rom", default="build/pacman.nes")
    parser.add_argument(
        "--define",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Pass a compile-time symbol to ca65; may be repeated",
    )
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    source = rooted(project_root, args.source)
    config = rooted(project_root, args.config)
    original_rom = rooted(project_root, args.original_rom)
    chr_path = rooted(project_root, args.chr)
    object_path = rooted(project_root, args.object)
    prg_path = rooted(project_root, args.prg)
    labels_path = rooted(project_root, args.labels)
    map_path = rooted(project_root, args.map)
    debug_path = rooted(project_root, args.debug_info)
    output_rom = rooted(project_root, args.output_rom)
    for path in (source, config, original_rom, chr_path):
        if not path.is_file():
            fail(f"Required file not found: {path}")

    reference = original_rom.read_bytes()
    header, original_prg, original_chr = parse_ines(reference)
    chr_data = chr_path.read_bytes()
    if len(chr_data) != len(original_chr):
        fail(
            f"Generated CHR must be {len(original_chr)} bytes, "
            f"got {len(chr_data)}"
        )
    prg = assemble_prg(
        project_root,
        source,
        config,
        object_path,
        prg_path,
        labels_path,
        map_path,
        debug_path,
        output_rom,
        defines=args.define,
    )
    candidate = header + prg + chr_data
    output_rom.parent.mkdir(parents=True, exist_ok=True)
    output_rom.write_bytes(candidate)

    print(f"[OK] Built native ROM: {output_rom}")
    print(f"[INFO] PRG SHA1 orig={sha1(original_prg)} cand={sha1(prg)}")
    print(f"[INFO] ROM SHA1 orig={sha1(reference)} cand={sha1(candidate)}")
    if candidate == reference:
        print("[OK] Byte-identical ROM reproduced from native ca65 source.")
        return 0

    difference = first_diff(candidate, reference)
    if difference is not None:
        level = "FAIL" if args.verify else "WARN"
        print(f"[{level}] First ROM difference at file offset 0x{difference:06X}")
    if args.verify:
        return 1
    print("[WARN] ROM differs from the reference; verification was not requested.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
