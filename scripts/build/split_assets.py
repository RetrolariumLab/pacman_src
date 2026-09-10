#!/usr/bin/env python3
"""Extract uneditable binary assets from the original Pac-Man ROM."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path, PurePosixPath
from typing import Any


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def parse_number(value: Any, field: str) -> int:
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value, 0)
        except ValueError:
            pass
    fail(f"invalid integer for {field}: {value!r}")
    raise AssertionError


def parse_ines(data: bytes) -> tuple[bytes, bytes]:
    if len(data) < 16 or data[:4] != b"NES\x1a":
        fail("reference ROM is not a valid iNES file")
    trainer_size = 512 if data[6] & 0x04 else 0
    prg_size = data[4] * 16_384
    chr_size = data[5] * 8_192
    prg_start = 16 + trainer_size
    chr_start = prg_start + prg_size
    end = chr_start + chr_size
    if end > len(data):
        fail("reference ROM is truncated")
    return data[prg_start:chr_start], data[chr_start:end]


def safe_output_path(root: Path, relative: str) -> Path:
    posix = PurePosixPath(relative)
    if posix.is_absolute() or not posix.parts or ".." in posix.parts:
        fail(f"unsafe asset path in manifest: {relative!r}")
    destination = root.joinpath(*posix.parts)
    resolved_root = root.resolve()
    try:
        destination.resolve().relative_to(resolved_root)
    except ValueError:
        fail(f"asset path escapes output directory: {relative!r}")
    return destination


def write_if_changed(path: Path, payload: bytes) -> str:
    if path.is_file() and path.read_bytes() == payload:
        return "OK"
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_bytes(payload)
    os.replace(temporary, path)
    return "WRITE"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, help="original iNES ROM")
    parser.add_argument("--manifest", required=True, help="asset range manifest")
    parser.add_argument("--output-dir", required=True, help="generated asset root")
    args = parser.parse_args()

    rom_path = Path(args.rom)
    manifest_path = Path(args.manifest)
    output_dir = Path(args.output_dir)
    if not rom_path.is_file():
        fail(f"ROM not found: {rom_path}")
    if not manifest_path.is_file():
        fail(f"manifest not found: {manifest_path}")

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read manifest: {exc}")
    if manifest.get("schema_version") != 1:
        fail("unsupported asset manifest schema")

    reference = manifest.get("reference_rom", {})
    rom = rom_path.read_bytes()
    actual_sha1 = hashlib.sha1(rom).hexdigest()
    expected_sha1 = str(reference.get("sha1", "")).lower()
    if actual_sha1 != expected_sha1:
        fail(f"wrong reference ROM: SHA1 {actual_sha1}, expected {expected_sha1}")

    prg, chr_data = parse_ines(rom)
    expected_prg_size = parse_number(reference.get("prg_size"), "prg_size")
    expected_chr_size = parse_number(reference.get("chr_size"), "chr_size")
    if len(prg) != expected_prg_size or len(chr_data) != expected_chr_size:
        fail(
            "reference ROM layout does not match manifest: "
            f"PRG={len(prg)}, CHR={len(chr_data)}"
        )
    prg_cpu_base = parse_number(reference.get("prg_cpu_base"), "prg_cpu_base")

    assets = manifest.get("assets")
    if not isinstance(assets, list) or not assets:
        fail("manifest has no assets")

    seen_paths: set[str] = set()
    written = 0
    for entry in assets:
        if not isinstance(entry, dict):
            fail("asset entries must be objects")
        relative = str(entry.get("path", ""))
        if relative in seen_paths:
            fail(f"duplicate asset path: {relative}")
        seen_paths.add(relative)
        size = parse_number(entry.get("size"), f"{relative}.size")
        if size <= 0:
            fail(f"asset size must be positive: {relative}")

        region = entry.get("region")
        if region == "prg":
            address = parse_number(entry.get("address"), f"{relative}.address")
            offset = address - prg_cpu_base
            source = prg
            source_name = f"PRG ${address:04X}"
        elif region == "chr":
            offset = parse_number(entry.get("offset", 0), f"{relative}.offset")
            source = chr_data
            source_name = f"CHR +0x{offset:X}"
        else:
            fail(f"unknown region for {relative}: {region!r}")

        end = offset + size
        if offset < 0 or end > len(source):
            fail(f"asset range is outside {region.upper()}: {relative}")
        payload = source[offset:end]
        if len(payload) != size:
            fail(f"extracted size mismatch for {relative}")

        digest = hashlib.sha1(payload).hexdigest()
        expected_digest = str(entry.get("sha1", "")).lower()
        if digest != expected_digest:
            fail(
                f"asset checksum mismatch for {relative}: "
                f"{digest}, expected {expected_digest}"
            )

        destination = safe_output_path(output_dir, relative)
        action = write_if_changed(destination, payload)
        written += action == "WRITE"
        print(
            f"[{action}] {relative} "
            f"({size} bytes, {source_name}, sha1={digest[:12]})"
        )

    print(f"[OK] Validated {len(assets)} generated assets; wrote {written} file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
