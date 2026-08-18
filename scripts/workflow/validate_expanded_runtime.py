#!/usr/bin/env python3
"""Validate FCEUX evidence for the expanded maze bank."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--result", required=True, type=Path)
    parser.add_argument("--stage-json", required=True, type=Path)
    parser.add_argument("--sound-json", required=True, type=Path)
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
    stage_document = json.loads(args.stage_json.read_text(encoding="utf-8"))
    expected_duration = int(stage_document["stage_profiles"][1]["frightened_duration"])
    sound_document = json.loads(args.sound_json.read_text(encoding="utf-8"))
    pellet = sound_document["streams"][4]["stream"]
    expected_note = int(pellet["commands"][0]["value"])
    if (
        maze_match is None
        or stage_match is None
        or sound_match is None
        or lines[3:] != ["OK"]
        or int(stage_match.group(1), 16) != expected_duration
        or int(stage_match.group(2), 16) != expected_duration
        or int(sound_match.group(2), 16) <= int(sound_match.group(1), 16)
        or int(sound_match.group(3), 16) != expected_note
    ):
        print(f"[ERROR] Expanded runtime validation failed: {lines}")
        return 1
    print(
        f"[OK] FCEUX selected the stage-2 maze at $82D6 (token ${maze_match.group(1)}) "
        f"and loaded its frightened duration {expected_duration} from $81A0; "
        f"pellet slot 04 decoded JSON note ${expected_note:02X} through $848F."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
