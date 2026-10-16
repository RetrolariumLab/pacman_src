#!/usr/bin/env python3
"""Build the native modular ca65 source into a ROM: the header and CHR come
from the split assets (rltool assets split); rltool assets verify compares
the result with the original."""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import re
import subprocess
import sys
from pathlib import Path

from toolchain import load_toolchain_manifest, tool_path, verify_bundled_tool

RECORD_FIELD_RE = re.compile(r'(?:^|,)([a-z]+)=("(?:[^"]|"")*"|[^,]*)')


def parse_record(line: str) -> tuple[str, dict[str, str]]:
    """One record of an ld65 debug file: its kind and its fields."""
    kind, separator, payload = line.partition("\t")
    if not separator:
        return kind, {}
    fields: dict[str, str] = {}
    for match in RECORD_FIELD_RE.finditer(payload.rstrip("\n")):
        value = match.group(2)
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1].replace('""', '"')
        fields[match.group(1)] = value
    return kind, fields


def normalize_dbg_for_ines(raw_path: Path, output_path: Path, linked_prg_path: Path,
                           output_rom_path: Path, header_size: int = 16) -> None:
    """Retarget ld65 segment file offsets from a bare PRG to its iNES image,
    for debuggers that load the .dbg next to the ROM."""
    linked_names = {str(linked_prg_path), linked_prg_path.as_posix()}
    rewritten: list[str] = []
    segment_count = 0
    for line in raw_path.read_text(encoding="utf-8").splitlines(keepends=True):
        kind, fields = parse_record(line)
        if kind == "seg" and fields.get("oname") in linked_names:
            if "ooffs" not in fields:
                raise ValueError("ld65 segment record is missing ooffs")
            line = (line.replace(f'oname="{fields["oname"]}"', f'oname="{output_rom_path}"')
                    .replace(f'ooffs={fields["ooffs"]}', f'ooffs={int(fields["ooffs"], 0) + header_size}'))
            segment_count += 1
        rewritten.append(line)
    if segment_count == 0:
        raise ValueError(f"No output segments for {linked_prg_path} in {raw_path}")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("".join(rewritten), encoding="utf-8", newline="\n")


PRG_SIZE = 16_384


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def load_verified_build_tools(
    project_root: Path, manifest_path: Path,
) -> tuple[Path, Path]:
    try:
        components = load_toolchain_manifest(manifest_path)
        tools: list[Path] = []
        for component_id in ("ca65", "ld65"):
            component = components[component_id]
            if component.get("provenance") != "retrolarium-kit":
                raise ValueError(
                    f"{component_id} must use the assembler Retrolarium Kit ships"
                )
            verify_bundled_tool(project_root, component_id, component)
            tools.append(tool_path(project_root, component_id, component))
    except (OSError, ValueError) as error:
        fail(str(error))
    return tools[0], tools[1]


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
    include_dirs: list[Path] | None = None,
    toolchain_manifest: Path | None = None,
) -> bytes:
    ca65, ld65 = load_verified_build_tools(
        project_root,
        toolchain_manifest or project_root / "config" / "toolchain.json",
    )
    object_path.parent.mkdir(parents=True, exist_ok=True)
    prg_path.parent.mkdir(parents=True, exist_ok=True)
    labels_path.parent.mkdir(parents=True, exist_ok=True)
    map_path.parent.mkdir(parents=True, exist_ok=True)
    debug_path.parent.mkdir(parents=True, exist_ok=True)
    raw_debug_path = debug_path.with_name(f"{debug_path.stem}.ld65.dbg")
    ca65_arguments = [str(source), "-g"]
    for define in defines or []:
        ca65_arguments.extend(["-D", define])
    search_paths = [source.parent, *(include_dirs or []), project_root]
    for search_path in dict.fromkeys(path.resolve() for path in search_paths):
        ca65_arguments.extend(["-I", str(search_path)])
    ca65_arguments.extend(["-o", str(object_path)])
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


def rooted(project_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else project_root / path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("--source", default="src/main.asm")
    parser.add_argument("--config", default="config/linker/nrom128_prg_only.cfg")
    parser.add_argument("--header", default="assets/generated/header/pacman.hdr")
    parser.add_argument("--chr", default="assets/generated/chr/pacman.chr")
    parser.add_argument("--object", default="build/pacman.o")
    parser.add_argument("--prg", default="build/pacman.prg")
    parser.add_argument("--labels", default="build/pacman.lbl")
    parser.add_argument("--map", default="build/pacman.map")
    parser.add_argument("--debug-info", default="build/pacman.dbg")
    parser.add_argument("--output-rom", default="build/pacman.nes")
    parser.add_argument(
        "--toolchain-manifest", default="config/toolchain.json",
        help="Pinned build-tool paths, versions, and SHA-256 identities",
    )
    parser.add_argument(
        "--define",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Pass a compile-time symbol to ca65; may be repeated",
    )
    parser.add_argument(
        "--include-dir",
        action="append",
        default=[],
        help="Add a ca65 include directory; may be repeated",
    )
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[2]
    source = rooted(project_root, args.source)
    config = rooted(project_root, args.config)
    header_path = rooted(project_root, args.header)
    chr_path = rooted(project_root, args.chr)
    output_rom = rooted(project_root, args.output_rom)
    for path in (source, config, header_path, chr_path):
        if not path.is_file():
            fail(f"Required file not found: {path}" + (" (run make split)" if "generated" in path.parts else ""))

    header = header_path.read_bytes()
    chr_data = chr_path.read_bytes()
    if len(header) != 16 or header[:4] != b"NES\x1a":
        fail(f"{header_path} is not an iNES header")
    if len(chr_data) != header[5] * 8_192:
        fail(f"{chr_path} must be {header[5] * 8_192} bytes, got {len(chr_data)}")
    prg = assemble_prg(
        project_root,
        source,
        config,
        rooted(project_root, args.object),
        rooted(project_root, args.prg),
        rooted(project_root, args.labels),
        rooted(project_root, args.map),
        rooted(project_root, args.debug_info),
        output_rom,
        expected_prg_size=header[4] * PRG_SIZE,
        defines=args.define,
        include_dirs=[rooted(project_root, value) for value in args.include_dir],
        toolchain_manifest=rooted(project_root, args.toolchain_manifest),
    )
    output_rom.parent.mkdir(parents=True, exist_ok=True)
    output_rom.write_bytes(header + prg + chr_data)
    print(f"[OK] Built {output_rom} (SHA-1 {hashlib.sha1(header + prg + chr_data).hexdigest()})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
