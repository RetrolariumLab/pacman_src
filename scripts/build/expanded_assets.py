#!/usr/bin/env python3
"""Write the expanded NROM-256 variant's data assets from the original ROM.

The variant moves the stage parameters, a second maze, the sound streams,
the actor mappings, the palettes and the screens into its added PRG bank.
This writes each of them, as the original v1.0 ROM holds it, into the
binary the variant's entrypoint includes. Retrolarium edits the built
variant like any other revision, so the repository keeps no editable
copies of this data.

--probe marks two values so the runtime check can see the relocated data
being read: round 2's frightened time becomes 14 (it is 6) and the pellet sound's
first note $B1. Only `make validate-expanded` builds with it.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from build_native import parse_ines  # noqa: E402
from data_formats import (  # noqa: E402
    decode_actors,
    decode_maze,
    decode_sound,
    decode_stage,
    encode_actors,
    encode_maze,
    encode_sound,
    encode_stage,
)
from palette_assets import decode_palette_collection, encode_palette_collection  # noqa: E402
from screen_assets import decode_screen_collection, encode_screen_collection  # noqa: E402


STAGE_CPU_ADDRESS = 0xEB42
STAGE_SIZE = 310
ACTOR_CPU_ADDRESS = 0xDB59
ACTOR_SIZE = 624
PRG_CPU_BASE = 0xC000
SOUND_POINTER_TABLE_ADDRESS = 0x848F
SOUND_STREAMS_ADDRESS = SOUND_POINTER_TABLE_ADDRESS + 32
SOUND_STREAMS_CAPACITY = 8192
PROBE_FRIGHTENED_TIME = 14
PROBE_PELLET_NOTE = 0xB1


def encode_sound_collection(
    streams: list[dict[str, object]],
    base_address: int = SOUND_STREAMS_ADDRESS,
    capacity: int = SOUND_STREAMS_CAPACITY,
) -> tuple[bytes, bytes, int]:
    """The 16-entry pointer table and the stream region, streams in slot order."""
    if len(streams) != 16:
        raise ValueError("Expanded sound collection must contain 16 streams")
    bundle = bytearray()
    pointers = bytearray()
    for slot, stream in enumerate(streams):
        encoded = encode_sound(stream)
        address = base_address + len(bundle)
        if address + len(encoded) > base_address + capacity:
            raise ValueError(f"Expanded sound streams exceed {capacity}-byte budget at slot {slot:02X}")
        pointers.extend((address & 0xFF, address >> 8))
        bundle.extend(encoded)
    used = len(bundle)
    bundle.extend(b"\xFF" * (capacity - used))
    return bytes(pointers), bytes(bundle), used


def write_assets(rom_path: Path, maze_rle: Path, asset_manifest: Path, asset_dir: Path, output_dir: Path,
                 *, probe: bool = False) -> dict[str, int]:
    rom = rom_path.read_bytes()
    _header, prg, _chr = parse_ines(rom)
    stage = decode_stage(prg[STAGE_CPU_ADDRESS - PRG_CPU_BASE:][:STAGE_SIZE])
    manifest = json.loads(asset_manifest.read_text(encoding="utf-8"))
    audio = sorted((asset for asset in manifest["assets"] if asset["path"].startswith("audio/")),
                   key=lambda asset: asset["path"])
    streams = [decode_sound((asset_dir / asset["path"]).read_bytes()) for asset in audio]
    if probe:
        stage["stage_profiles"][1]["frightened_duration"] = PROBE_FRIGHTENED_TIME
        pellet = next(index for index, asset in enumerate(audio) if asset["path"].startswith("audio/slot04_"))
        streams[pellet]["commands"][0]["value"] = PROBE_PELLET_NOTE
    pointers, sound, used = encode_sound_collection(streams)
    outputs = {
        "maze.rle": encode_maze(decode_maze(maze_rle.read_bytes())),
        "stage_parameters.bin": encode_stage(stage),
        "sound_pointers.bin": pointers,
        "sound_streams.bin": sound,
        "actor_sprites.bin": encode_actors(decode_actors(prg[ACTOR_CPU_ADDRESS - PRG_CPU_BASE:][:ACTOR_SIZE])),
        "palettes.bin": encode_palette_collection(decode_palette_collection(rom)),
        "screens.bin": encode_screen_collection(decode_screen_collection(rom)),
    }
    output_dir.mkdir(parents=True, exist_ok=True)
    for name, data in outputs.items():
        (output_dir / name).write_bytes(data)
    return {"sound_bytes": used, **{name: len(data) for name, data in outputs.items()}}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original-rom", required=True, type=Path)
    parser.add_argument("--maze-source", required=True, type=Path)
    parser.add_argument("--asset-manifest", required=True, type=Path)
    parser.add_argument("--asset-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--probe", action="store_true")
    args = parser.parse_args()
    sizes = write_assets(args.original_rom, args.maze_source, args.asset_manifest, args.asset_dir,
                         args.output_dir, probe=args.probe)
    mode = " with the runtime probes" if args.probe else ""
    print(f"[OK] Expanded assets written to {args.output_dir}{mode}: "
          f"{sizes['sound_bytes']}/{SOUND_STREAMS_CAPACITY} sound bytes used")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
