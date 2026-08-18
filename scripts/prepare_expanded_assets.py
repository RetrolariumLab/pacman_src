#!/usr/bin/env python3
"""Initialize or encode editable JSON assets for the expanded ROM variant."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_native import parse_ines
from data_formats import (
    decode_maze,
    decode_sound,
    decode_stage,
    encode_maze,
    encode_sound,
    encode_stage,
)


STAGE_CPU_ADDRESS = 0xEB42
STAGE_SIZE = 310
PRG_CPU_BASE = 0xC000
SOUND_POINTER_TABLE_ADDRESS = 0x848F
SOUND_STREAMS_ADDRESS = SOUND_POINTER_TABLE_ADDRESS + 32


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
    parser.add_argument("--asset-manifest", required=True, type=Path)
    parser.add_argument("--asset-dir", required=True, type=Path)
    parser.add_argument("--sound-json", required=True, type=Path)
    parser.add_argument("--sound-output", type=Path)
    parser.add_argument("--sound-pointers-output", type=Path)
    parser.add_argument("--demo-frightened-duration", type=int, default=14)
    args = parser.parse_args()

    if args.operation == "init":
        write_once(args.maze_json, decode_maze(args.maze_source.read_bytes()), "maze")
        _, prg, _ = parse_ines(args.original_rom.read_bytes())
        offset = STAGE_CPU_ADDRESS - PRG_CPU_BASE
        stage = decode_stage(prg[offset:offset + STAGE_SIZE])
        stage["stage_profiles"][0]["frightened_duration"] = args.demo_frightened_duration
        write_once(args.stage_json, stage, "stage parameter")
        manifest = json.loads(args.asset_manifest.read_text(encoding="utf-8"))
        audio_assets = sorted(
            (asset for asset in manifest["assets"] if asset["path"].startswith("audio/")),
            key=lambda asset: asset["path"],
        )
        sounds = {
            "format": "sound_stream_collection",
            "streams": [
                {
                    "path": asset["path"],
                    "stream": decode_sound((args.asset_dir / asset["path"]).read_bytes()),
                }
                for asset in audio_assets
            ],
        }
        pellet = next(item for item in sounds["streams"] if item["path"].startswith("audio/slot04_"))
        pellet["stream"]["commands"][0]["value"] = 0xB1
        write_once(args.sound_json, sounds, "sound stream")
        return 0

    if (args.maze_output is None or args.stage_output is None or args.sound_output is None
            or args.sound_pointers_output is None):
        parser.error("encode requires all binary output paths")
    maze = encode_maze(json.loads(args.maze_json.read_text(encoding="utf-8")))
    stage = encode_stage(json.loads(args.stage_json.read_text(encoding="utf-8")))
    sound_document = json.loads(args.sound_json.read_text(encoding="utf-8"))
    expected_paths = [f"audio/slot{slot:02x}_" for slot in range(16)]
    streams = sound_document["streams"]
    if len(streams) != 16:
        raise ValueError("Expanded sound collection must contain 16 streams")
    sound_bundle = bytearray()
    pointers = bytearray()
    for slot, item in enumerate(streams):
        if not item["path"].startswith(expected_paths[slot]):
            raise ValueError(f"Expanded sound stream order mismatch at slot {slot:02X}")
        encoded = encode_sound(item["stream"])
        original_size = (args.asset_dir / item["path"]).stat().st_size
        if len(encoded) != original_size:
            raise ValueError(f"Expanded sound stream size changed: {item['path']}")
        address = SOUND_STREAMS_ADDRESS + len(sound_bundle)
        pointers.extend((address & 0xFF, address >> 8))
        sound_bundle.extend(encoded)
    args.maze_output.parent.mkdir(parents=True, exist_ok=True)
    args.stage_output.parent.mkdir(parents=True, exist_ok=True)
    args.maze_output.write_bytes(maze)
    args.stage_output.write_bytes(stage)
    args.sound_output.parent.mkdir(parents=True, exist_ok=True)
    args.sound_output.write_bytes(sound_bundle)
    args.sound_pointers_output.write_bytes(pointers)
    print(f"[OK] Encoded expanded maze asset: {args.maze_output} ({len(maze)} bytes)")
    print(f"[OK] Encoded expanded stage asset: {args.stage_output} ({len(stage)} bytes)")
    print(f"[OK] Encoded expanded sound assets: 16 streams, {len(sound_bundle)} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
