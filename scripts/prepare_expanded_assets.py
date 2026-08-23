#!/usr/bin/env python3
"""Initialize or encode editable JSON assets for the expanded ROM variant."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_native import parse_ines
from data_formats import (
    decode_actors,
    decode_maze,
    decode_sound,
    decode_stage,
    encode_actors,
    encode_maze,
    encode_sound,
    encode_stage,
)
from palette_assets import decode_palette_collection, encode_palette_collection


STAGE_CPU_ADDRESS = 0xEB42
STAGE_SIZE = 310
ACTOR_CPU_ADDRESS = 0xDB59
ACTOR_SIZE = 624
PRG_CPU_BASE = 0xC000
SOUND_POINTER_TABLE_ADDRESS = 0x848F
SOUND_STREAMS_ADDRESS = SOUND_POINTER_TABLE_ADDRESS + 32
SOUND_STREAMS_CAPACITY = 8192


def write_once(path: Path, document: dict[str, object], description: str) -> None:
    if path.exists():
        print(f"[OK] Editable {description} JSON already exists; left untouched: {path}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    print(f"[OK] Initialized editable {description} JSON: {path}")


def encode_sound_collection(
    document: dict[str, object],
    base_address: int = SOUND_STREAMS_ADDRESS,
    capacity: int = SOUND_STREAMS_CAPACITY,
) -> tuple[bytes, bytes, int]:
    if document.get("format") != "sound_stream_collection":
        raise ValueError("Expanded sound JSON has the wrong format")
    streams = document["streams"]
    if len(streams) != 16:
        raise ValueError("Expanded sound collection must contain 16 streams")
    bundle = bytearray()
    pointers = bytearray()
    for slot, item in enumerate(streams):
        prefix = f"audio/slot{slot:02x}_"
        if not item["path"].startswith(prefix):
            raise ValueError(f"Expanded sound stream order mismatch at slot {slot:02X}")
        encoded = encode_sound(item["stream"])
        address = base_address + len(bundle)
        if address + len(encoded) > base_address + capacity:
            raise ValueError(
                f"Expanded sound streams exceed {capacity}-byte budget at slot {slot:02X}"
            )
        pointers.extend((address & 0xFF, address >> 8))
        bundle.extend(encoded)
    used = len(bundle)
    bundle.extend(b"\xFF" * (capacity - used))
    return bytes(pointers), bytes(bundle), used


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
    parser.add_argument("--actor-json", required=True, type=Path)
    parser.add_argument("--actor-output", type=Path)
    parser.add_argument("--palette-json", required=True, type=Path)
    parser.add_argument("--palette-output", type=Path)
    parser.add_argument("--demo-frightened-duration", type=int, default=14)
    args = parser.parse_args()

    if args.operation == "init":
        write_once(args.maze_json, decode_maze(args.maze_source.read_bytes()), "maze")
        _, prg, _ = parse_ines(args.original_rom.read_bytes())
        offset = STAGE_CPU_ADDRESS - PRG_CPU_BASE
        stage = decode_stage(prg[offset:offset + STAGE_SIZE])
        stage["stage_profiles"][0]["frightened_duration"] = args.demo_frightened_duration
        write_once(args.stage_json, stage, "stage parameter")
        actor_offset = ACTOR_CPU_ADDRESS - PRG_CPU_BASE
        actors = decode_actors(prg[actor_offset:actor_offset + ACTOR_SIZE])
        write_once(args.actor_json, actors, "actor mapping")
        palettes = decode_palette_collection(args.original_rom.read_bytes())
        write_once(args.palette_json, palettes, "palette")
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
            or args.sound_pointers_output is None or args.actor_output is None
            or args.palette_output is None):
        parser.error("encode requires all binary output paths")
    maze = encode_maze(json.loads(args.maze_json.read_text(encoding="utf-8")))
    stage = encode_stage(json.loads(args.stage_json.read_text(encoding="utf-8")))
    sound_document = json.loads(args.sound_json.read_text(encoding="utf-8"))
    actors = encode_actors(json.loads(args.actor_json.read_text(encoding="utf-8")))
    palettes = encode_palette_collection(json.loads(args.palette_json.read_text(encoding="utf-8")))
    pointers, sound_bundle, sound_used = encode_sound_collection(sound_document)
    args.maze_output.parent.mkdir(parents=True, exist_ok=True)
    args.stage_output.parent.mkdir(parents=True, exist_ok=True)
    args.maze_output.write_bytes(maze)
    args.stage_output.write_bytes(stage)
    args.sound_output.parent.mkdir(parents=True, exist_ok=True)
    args.sound_output.write_bytes(sound_bundle)
    args.sound_pointers_output.write_bytes(pointers)
    args.actor_output.parent.mkdir(parents=True, exist_ok=True)
    args.actor_output.write_bytes(actors)
    args.palette_output.parent.mkdir(parents=True, exist_ok=True)
    args.palette_output.write_bytes(palettes)
    print(f"[OK] Encoded expanded maze asset: {args.maze_output} ({len(maze)} bytes)")
    print(f"[OK] Encoded expanded stage asset: {args.stage_output} ({len(stage)} bytes)")
    print(
        f"[OK] Encoded expanded sound assets: 16 streams, {sound_used}/"
        f"{SOUND_STREAMS_CAPACITY} bytes used"
    )
    print(f"[OK] Encoded expanded actor mappings: {len(actors)} bytes")
    print(f"[OK] Encoded expanded palettes: {len(palettes)} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
