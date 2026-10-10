#!/usr/bin/env python3
"""Build the expanded NROM-256 variant from the v1.0 ROM alone.

Retrolarium runs this to make the expanded revision it edits (the
`[revisions.build]` of pacman.rlj): the data assets come from the ROM as it
is, and the image lands at --output. `make build-expanded` builds the same
image into build/expanded/.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from build_expanded import build  # noqa: E402
from expanded_assets import write_assets  # noqa: E402


ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, type=Path, help="the Pac-Man (J) v1.0 ROM")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    work = ROOT / "build/expanded"
    write_assets(args.rom.resolve(), ROOT / "assets/generated/maze/maze.rle", ROOT / "assets/manifest.json",
                 ROOT / "assets/generated", work / "assets")
    build(ROOT, {
        "source": ROOT / "src/expanded/nrom256.asm",
        "config": ROOT / "config/linker/nrom256_expanded.cfg",
        "original_rom": args.rom.resolve(),
        "chr": ROOT / "assets/generated/chr/pacman.chr",
        "object": work / "pacman.o",
        "prg": work / "pacman.prg",
        "labels": work / "pacman.lbl",
        "map": work / "pacman.map",
        "debug_info": work / "pacman.dbg",
        "output_rom": args.output.resolve(),
        "toolchain_manifest": ROOT / "config/toolchain.json",
    })
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
