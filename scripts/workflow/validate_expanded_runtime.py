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
    args = parser.parse_args()
    if not args.result.is_file():
        print(f"[ERROR] Missing expanded runtime result: {args.result}")
        return 1
    lines = args.result.read_text(encoding="utf-8").splitlines()
    maze_match = re.fullmatch(r"maze,8000,8000,([0-9A-F]{2})", lines[0] if lines else "")
    stage_match = re.fullmatch(
        r"stage,81A0,([0-9A-F]{2}),([0-9A-F]{2})", lines[1] if len(lines) > 1 else ""
    )
    stage_document = json.loads(args.stage_json.read_text(encoding="utf-8"))
    expected_duration = int(stage_document["stage_profiles"][0]["frightened_duration"])
    if (
        maze_match is None
        or stage_match is None
        or lines[2:] != ["OK"]
        or int(stage_match.group(1), 16) != expected_duration
        or int(stage_match.group(2), 16) != expected_duration
    ):
        print(f"[ERROR] Expanded runtime validation failed: {lines}")
        return 1
    print(
        f"[OK] FCEUX read maze at $8000 (token ${maze_match.group(1)}) and "
        f"loaded stage-1 frightened duration {expected_duration} from $81A0."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
