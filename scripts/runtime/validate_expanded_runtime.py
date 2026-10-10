#!/usr/bin/env python3
"""Validate FCEUX evidence for the expanded maze bank."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


ROUND_PROFILE = 6
STAGE2_PROFILE = 1
SOUND_BASE = 0x84AF
PELLET_SLOT = 4


def expected_values(assets: Path) -> tuple[int, int, bytes, int]:
    """What the run must observe, from the binaries the variant includes."""
    stage = (assets / "stage_parameters.bin").read_bytes()
    duration = stage[STAGE2_PROFILE * ROUND_PROFILE + 1]
    pointers = (assets / "sound_pointers.bin").read_bytes()
    pellet = int.from_bytes(pointers[PELLET_SLOT * 2:PELLET_SLOT * 2 + 2], "little") - SOUND_BASE
    # A stream opens with a four-byte prologue; its first note follows.
    note = (assets / "sound_streams.bin").read_bytes()[pellet + 4]
    palettes = (assets / "palettes.bin").read_bytes()
    palette = bytearray(palettes[0x30:0x50])
    palette[0x1D] = palettes[0x6F + 1]      # the round's fruit colour
    title_tile = (assets / "screens.bin").read_bytes()[0]
    return duration, note, bytes(palette), title_tile


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--result", required=True, type=Path)
    parser.add_argument("--assets", required=True, type=Path)
    args = parser.parse_args()
    if not args.result.is_file():
        print(f"[ERROR] Missing expanded runtime result: {args.result}")
        return 1
    lines = args.result.read_text(encoding="utf-8").splitlines()
    maze_match = re.fullmatch(r"maze,82D6,82D6,([0-9A-F]{2})", lines[0] if lines else "")
    stage_match = re.fullmatch(
        r"stage,81A0,([0-9A-F]{2}),([0-9A-F]{2})", lines[1] if len(lines) > 1 else ""
    )
    sound_match = re.fullmatch(
        r"sound,848F,([0-9A-F]{4}),([0-9A-F]{4}),([0-9A-F]{2})",
        lines[2] if len(lines) > 2 else "",
    )
    palette_match = re.fullmatch(
        r"palette,([0-9A-F]{64})", lines[3] if len(lines) > 3 else ""
    )
    screen_match = re.fullmatch(
        r"screen,A79E,([0-9A-F]{2}),1", lines[4] if len(lines) > 4 else ""
    )
    expected_duration, expected_note, expected_palette, expected_title_tile = expected_values(args.assets)
    if (
        maze_match is None
        or stage_match is None
        or sound_match is None
        or palette_match is None
        or screen_match is None
        or lines[5:] != ["OK"]
        or int(stage_match.group(1), 16) != expected_duration
        or int(stage_match.group(2), 16) != expected_duration
        or int(sound_match.group(2), 16) <= int(sound_match.group(1), 16)
        or int(sound_match.group(3), 16) != expected_note
        or bytes.fromhex(palette_match.group(1)) != expected_palette
        or int(screen_match.group(1), 16) != expected_title_tile
    ):
        print(f"[ERROR] Expanded runtime validation failed: {lines}")
        return 1
    print(
        f"[OK] FCEUX selected the stage-2 maze at $82D6 (token ${maze_match.group(1)}) "
        f"and loaded its frightened duration {expected_duration} from $81A0; "
        f"pellet slot 04 decoded note ${expected_note:02X} through $848F; "
        "PPU palette RAM matches the relocated gameplay palette plus its stage-1 fruit override; "
        f"title tile ${expected_title_tile:02X} from $A79E was observed at PPU $20E5."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
