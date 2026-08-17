#!/usr/bin/env python3
"""Initialize or encode editable JSON assets for the expanded ROM variant."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_native import parse_ines
from data_formats import decode_maze, decode_stage, encode_maze, encode_stage


STAGE_CPU_ADDRESS = 0xEB42
STAGE_SIZE = 310
PRG_CPU_BASE = 0xC000


def write_once(path: Path, document: dict[str, object], description: str) -> None:
    if path.exists():
        print(f"[OK] Editable {description} JSON already exists; left untouched: {path}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    print(f"[OK] Initialized editable {description} JSON: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("init", "encode"))
    parser.add_argument("--maze-source", required=True, type=Path)
    parser.add_argument("--maze-json", required=True, type=Path)
    parser.add_argument("--maze-output", type=Path)
    parser.add_argument("--original-rom", required=True, type=Path)
    parser.add_argument("--stage-json", required=True, type=Path)
    parser.add_argument("--stage-output", type=Path)
    parser.add_argument("--demo-frightened-duration", type=int, default=14)
    args = parser.parse_args()

    if args.operation == "init":
        write_once(args.maze_json, decode_maze(args.maze_source.read_bytes()), "maze")
        _, prg, _ = parse_ines(args.original_rom.read_bytes())
        offset = STAGE_CPU_ADDRESS - PRG_CPU_BASE
        stage = decode_stage(prg[offset:offset + STAGE_SIZE])
        stage["stage_profiles"][0]["frightened_duration"] = args.demo_frightened_duration
        write_once(args.stage_json, stage, "stage parameter")
        return 0

    if args.maze_output is None or args.stage_output is None:
        parser.error("encode requires --maze-output and --stage-output")
    maze = encode_maze(json.loads(args.maze_json.read_text(encoding="utf-8")))
    stage = encode_stage(json.loads(args.stage_json.read_text(encoding="utf-8")))
    args.maze_output.parent.mkdir(parents=True, exist_ok=True)
    args.stage_output.parent.mkdir(parents=True, exist_ok=True)
    args.maze_output.write_bytes(maze)
    args.stage_output.write_bytes(stage)
    print(f"[OK] Encoded expanded maze asset: {args.maze_output} ({len(maze)} bytes)")
    print(f"[OK] Encoded expanded stage asset: {args.stage_output} ({len(stage)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
