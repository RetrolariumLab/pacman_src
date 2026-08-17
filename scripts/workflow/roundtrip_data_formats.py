#!/usr/bin/env python3
"""Decode all documented binary formats and prove byte-identical re-encoding."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from data_formats import (
    decode_actors,
    decode_intermission,
    decode_maze,
    decode_ppu,
    decode_sound,
    decode_sound_channel_record,
    decode_stage,
    encode_actors,
    encode_intermission,
    encode_maze,
    encode_ppu,
    encode_sound,
    encode_sound_channel_record,
    encode_stage,
)


def sha1(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def rom_slice(rom: bytes, address: int, size: int, cpu_base: int, header_size: int) -> bytes:
    offset = header_size + address - cpu_base
    data = rom[offset:offset + size]
    if len(data) != size:
        raise ValueError(f"ROM region ${address:04X}..${address + size - 1:04X} is truncated")
    return data


def write_json(path: Path, document: object) -> None:
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")


def prove_roundtrip(
    name: str,
    original: bytes,
    document: dict[str, object],
    encoder,
    output_dir: Path,
) -> None:
    json_path = output_dir / f"{name}.json"
    binary_path = output_dir / f"{name}.roundtrip.bin"
    write_json(json_path, document)
    reloaded = json.loads(json_path.read_text(encoding="utf-8"))
    rebuilt = encoder(reloaded)
    binary_path.write_bytes(rebuilt)
    if rebuilt != original:
        mismatch = next(
            (index for index, pair in enumerate(zip(original, rebuilt)) if pair[0] != pair[1]),
            min(len(original), len(rebuilt)),
        )
        raise ValueError(
            f"{name} round-trip differs at offset {mismatch}: "
            f"original={len(original)} bytes, rebuilt={len(rebuilt)} bytes"
        )
    print(f"[OK] {name}: {len(original)} bytes, SHA1 {sha1(original)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, type=Path)
    parser.add_argument("--asset-dir", required=True, type=Path)
    parser.add_argument("--asset-manifest", required=True, type=Path)
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()

    config = json.loads(args.config.read_text(encoding="utf-8"))
    manifest = json.loads(args.asset_manifest.read_text(encoding="utf-8"))
    rom = args.rom.read_bytes()
    cpu_base = int(config["cpu_base"])
    header_size = int(config["ines_header_size"])
    args.output_dir.mkdir(parents=True, exist_ok=True)

    stage_spec = config["stage_parameters"]
    stage = rom_slice(rom, stage_spec["address"], stage_spec["size"], cpu_base, header_size)
    prove_roundtrip("stage_parameters", stage, decode_stage(stage), encode_stage, args.output_dir)

    maze_spec = config["maze"]
    maze = (args.asset_dir / maze_spec["path"]).read_bytes()
    prove_roundtrip(
        "maze_rle",
        maze,
        decode_maze(maze, maze_spec["rows"], maze_spec["columns"]),
        encode_maze,
        args.output_dir,
    )

    actor_spec = config["actor_sprite_tables"]
    actors = rom_slice(rom, actor_spec["address"], actor_spec["size"], cpu_base, header_size)
    prove_roundtrip("actor_sprite_tables", actors, decode_actors(actors), encode_actors, args.output_dir)

    intermission_regions = config["intermission_tables"]
    intermission = bytearray()
    for region in intermission_regions:
        width = 2 if region["kind"] == "words" else 1
        intermission.extend(
            rom_slice(rom, region["address"], region["count"] * width, cpu_base, header_size)
        )
    prove_roundtrip(
        "intermission_tables",
        bytes(intermission),
        decode_intermission(bytes(intermission), intermission_regions),
        encode_intermission,
        args.output_dir,
    )

    audio_assets = sorted(
        (asset for asset in manifest["assets"] if asset["path"].startswith("audio/")),
        key=lambda asset: asset["path"],
    )
    sound_documents = []
    sound_bundle = bytearray()
    channel_bundle = bytearray()
    for asset in audio_assets:
        path = args.asset_dir / asset["path"]
        data = path.read_bytes()
        if sha1(data) != asset["sha1"]:
            raise ValueError(f"Sound asset checksum mismatch: {path}")
        decoded = decode_sound(data)
        prologue = decoded["prologue"]
        initial_channel = bytes((prologue[0], prologue[1], prologue[2], 0, prologue[3], 0, 0, 0))
        sound_documents.append({
            "path": asset["path"],
            "stream": decoded,
            "initialized_channel_record": decode_sound_channel_record(initial_channel),
        })
        sound_bundle.extend(data)
        channel_bundle.extend(initial_channel)
    sound_json = args.output_dir / "sound_streams.json"
    write_json(sound_json, {"format": "sound_stream_collection", "streams": sound_documents})
    reloaded_sounds = json.loads(sound_json.read_text(encoding="utf-8"))
    rebuilt_bundle = bytearray()
    rebuilt_channels = bytearray()
    for item in reloaded_sounds["streams"]:
        rebuilt_bundle.extend(encode_sound(item["stream"]))
        rebuilt_channels.extend(encode_sound_channel_record(item["initialized_channel_record"]))
    (args.output_dir / "sound_streams.roundtrip.bin").write_bytes(rebuilt_bundle)
    if rebuilt_bundle != sound_bundle:
        raise ValueError("Sound stream collection failed byte-identical round-trip")
    if rebuilt_channels != channel_bundle:
        raise ValueError("Sound channel records failed byte-identical round-trip")
    print(
        f"[OK] sound_streams: {len(audio_assets)} streams, {len(sound_bundle)} bytes; "
        f"{len(channel_bundle) // 8} initialized channel records"
    )

    ppu_documents = []
    ppu_bundle = bytearray()
    for name, hex_data in config["ppu_examples"].items():
        data = bytes.fromhex(hex_data)
        decoded = decode_ppu(data)
        ppu_documents.append({"name": name, "buffer": decoded})
        ppu_bundle.extend(data)
    ppu_json = args.output_dir / "ppu_command_buffers.json"
    write_json(ppu_json, {"format": "ppu_command_buffer_examples", "examples": ppu_documents})
    reloaded_ppu = json.loads(ppu_json.read_text(encoding="utf-8"))
    rebuilt_ppu = b"".join(encode_ppu(item["buffer"]) for item in reloaded_ppu["examples"])
    (args.output_dir / "ppu_command_buffers.roundtrip.bin").write_bytes(rebuilt_ppu)
    if rebuilt_ppu != ppu_bundle:
        raise ValueError("PPU command examples failed byte-identical round-trip")
    print(f"[OK] ppu_command_buffers: {len(ppu_documents)} representative streams")

    print("[OK] All 6 documented binary formats passed decode/encode round-trip.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
