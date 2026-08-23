#!/usr/bin/env python3
"""Build an isolated 32 KiB NROM-256 variant around the preserved fixed bank."""

from __future__ import annotations

import argparse
from pathlib import Path

from build_native import assemble_prg, fail, parse_ines, rooted, sha1


EXPANDED_PRG_SIZE = 32_768


def validate_chr_input(chr_data: bytes, reference_chr: bytes) -> None:
    if len(chr_data) != len(reference_chr) or len(chr_data) != 8192:
        fail(f"Expanded build requires exactly 8192 CHR bytes, got {len(chr_data)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True)
    parser.add_argument("--config", required=True)
    parser.add_argument("--original-rom", required=True)
    parser.add_argument("--chr", required=True)
    parser.add_argument("--object", required=True)
    parser.add_argument("--prg", required=True)
    parser.add_argument("--labels", required=True)
    parser.add_argument("--map", required=True)
    parser.add_argument("--debug-info", required=True)
    parser.add_argument("--output-rom", required=True)
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    paths = {name: rooted(project_root, value) for name, value in vars(args).items()}
    for name in ("source", "config", "original_rom", "chr"):
        if not paths[name].is_file():
            fail(f"Required file not found: {paths[name]}")

    reference = paths["original_rom"].read_bytes()
    header, original_prg, original_chr = parse_ines(reference)
    chr_data = paths["chr"].read_bytes()
    validate_chr_input(chr_data, original_chr)
    prg = assemble_prg(
        project_root,
        paths["source"],
        paths["config"],
        paths["object"],
        paths["prg"],
        paths["labels"],
        paths["map"],
        paths["debug_info"],
        paths["output_rom"],
        expected_prg_size=EXPANDED_PRG_SIZE,
    )
    expanded_header = bytearray(header)
    expanded_header[4] = 2
    candidate = bytes(expanded_header) + prg + chr_data
    paths["output_rom"].parent.mkdir(parents=True, exist_ok=True)
    paths["output_rom"].write_bytes(candidate)

    print(f"[OK] Built expanded ROM: {paths['output_rom']}")
    print(f"[INFO] Expanded PRG SHA1={sha1(prg)} ROM SHA1={sha1(candidate)}")
    print("[INFO] Run verify-expanded to enforce the reviewed fixed-bank changes.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
