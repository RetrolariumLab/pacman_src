#!/usr/bin/env python3
"""Decode and encode documented Pac-Man binary data formats as JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Callable


STAGE_FIELDS = (
    "profile_id",
    "frightened_duration",
    "dot_threshold_pair_id",
    "release_target_set_id",
    "fruit_stage_group",
    "release_interval_seconds",
)


def chunks(data: bytes, size: int) -> list[list[int]]:
    if len(data) % size:
        raise ValueError(f"Data size {len(data)} is not divisible by record size {size}")
    return [list(data[index:index + size]) for index in range(0, len(data), size)]


def flatten(records: list[list[int]]) -> bytes:
    values = [value for record in records for value in record]
    if any(not isinstance(value, int) or not 0 <= value <= 0xFF for value in values):
        raise ValueError("Encoded byte values must be integers in range 0..255")
    return bytes(values)


def decode_stage(data: bytes) -> dict[str, object]:
    if len(data) != 310:
        raise ValueError(f"Stage parameter block must be 310 bytes, got {len(data)}")
    offset = 0
    profiles = []
    for raw in chunks(data[offset:offset + 138], 6):
        profiles.append(dict(zip(STAGE_FIELDS, raw, strict=True)))
    offset += 138
    level_blocks = chunks(data[offset:offset + 110], 22)
    offset += 110
    timing_blocks = chunks(data[offset:offset + 32], 8)
    offset += 32
    thresholds = chunks(data[offset:offset + 14], 2)
    offset += 14
    release_targets = chunks(data[offset:offset + 12], 4)
    offset += 12
    special = list(data[offset:offset + 4])
    return {
        "format": "stage_parameters",
        "stage_profiles": profiles,
        "level_parameter_blocks": level_blocks,
        "scatter_chase_timing_blocks": timing_blocks,
        "dot_threshold_pairs": thresholds,
        "ghost_release_target_sets": release_targets,
        "restart_release_target_set": special,
    }


def encode_stage(document: dict[str, object]) -> bytes:
    profiles = document["stage_profiles"]
    if not isinstance(profiles, list) or len(profiles) != 23:
        raise ValueError("Stage data requires exactly 23 six-byte profiles")
    profile_records = [[profile[field] for field in STAGE_FIELDS] for profile in profiles]
    sections = (
        (profile_records, 6, 23, "stage profiles"),
        (document["level_parameter_blocks"], 22, 5, "level parameter blocks"),
        (document["scatter_chase_timing_blocks"], 8, 4, "timing blocks"),
        (document["dot_threshold_pairs"], 2, 7, "dot threshold pairs"),
        (document["ghost_release_target_sets"], 4, 3, "release target sets"),
        ([document["restart_release_target_set"]], 4, 1, "restart release target"),
    )
    output = bytearray()
    for records, width, count, name in sections:
        if not isinstance(records, list) or len(records) != count:
            raise ValueError(f"Expected {count} {name}")
        if any(not isinstance(record, list) or len(record) != width for record in records):
            raise ValueError(f"Every {name} record must contain {width} bytes")
        output.extend(flatten(records))
    return bytes(output)


def decode_maze(data: bytes, rows: int = 27, columns: int = 22) -> dict[str, object]:
    tokens = []
    tiles: list[int] = []
    for value in data:
        run_length = (value >> 6) + 1
        tile = value & 0x3F
        tokens.append({"length": run_length, "tile": tile})
        tiles.extend([tile] * run_length)
    expected = rows * columns
    if len(tiles) != expected:
        raise ValueError(f"Maze expands to {len(tiles)} tiles; expected {rows}x{columns}={expected}")
    return {
        "format": "maze_rle",
        "rows": rows,
        "columns": columns,
        "tokens": tokens,
        "decoded_rows": [tiles[index:index + columns] for index in range(0, expected, columns)],
    }


def encode_maze(document: dict[str, object]) -> bytes:
    rows = int(document["rows"])
    columns = int(document["columns"])
    tokens = document["tokens"]
    if not isinstance(tokens, list):
        raise ValueError("Maze tokens must be a list")
    output = bytearray()
    expanded: list[int] = []
    for token in tokens:
        length = int(token["length"])
        tile = int(token["tile"])
        if not 1 <= length <= 4 or not 0 <= tile <= 0x3F:
            raise ValueError(f"Invalid maze token: {token}")
        output.append(((length - 1) << 6) | tile)
        expanded.extend([tile] * length)
    if len(expanded) != rows * columns:
        raise ValueError("Maze tokens do not fill the declared dimensions")
    decoded_rows = document.get("decoded_rows")
    if decoded_rows is not None and flatten(decoded_rows) != bytes(expanded):
        raise ValueError("Maze decoded_rows disagree with token expansion")
    return bytes(output)


def decode_sound(data: bytes) -> dict[str, object]:
    if len(data) < 5:
        raise ValueError("Sound stream is shorter than its four-byte prologue and stop")
    cursor = 4
    commands: list[dict[str, int | str]] = []
    stopped = False
    while cursor < len(data):
        value = data[cursor]
        cursor += 1
        if value < 0xC0:
            if cursor >= len(data):
                raise ValueError("Note command lacks duration byte")
            commands.append({"kind": "note", "value": value, "duration": data[cursor]})
            cursor += 1
        elif value < 0xF0:
            if cursor >= len(data):
                raise ValueError("Duration marker lacks duration byte")
            commands.append({"kind": "duration", "marker": value, "duration": data[cursor]})
            cursor += 1
        elif value == 0xF0 or value >= 0xF7:
            commands.append({"kind": "control", "opcode": value})
            stopped = True
            break
        else:
            if cursor >= len(data):
                raise ValueError("Sound control opcode lacks operand")
            commands.append({"kind": "control", "opcode": value, "operand": data[cursor]})
            cursor += 1
    if not stopped:
        raise ValueError("Sound stream has no stop opcode")
    return {
        "format": "sound_stream",
        "prologue": list(data[:4]),
        "commands": commands,
        "trailing_bytes": list(data[cursor:]),
    }


def encode_sound(document: dict[str, object]) -> bytes:
    output = bytearray(document["prologue"])
    if len(output) != 4:
        raise ValueError("Sound prologue must contain four bytes")
    stopped = False
    commands = document["commands"]
    for index, command in enumerate(commands):
        kind = command["kind"]
        if kind == "note":
            output.extend((command["value"], command["duration"]))
        elif kind == "duration":
            output.extend((command["marker"], command["duration"]))
        elif kind == "control":
            opcode = command["opcode"]
            output.append(opcode)
            if 0xF1 <= opcode <= 0xF6:
                output.append(command["operand"])
            else:
                stopped = True
                if index != len(commands) - 1:
                    raise ValueError("Sound commands cannot follow a stop opcode")
                break
        else:
            raise ValueError(f"Unknown sound command kind: {kind}")
    if not stopped:
        raise ValueError("Encoded sound stream must end with a stop opcode")
    output.extend(document.get("trailing_bytes", []))
    return bytes(output)


def decode_sound_channel_record(data: bytes) -> dict[str, int | str]:
    if len(data) != 8:
        raise ValueError("Sound channel record must contain exactly eight bytes")
    return {
        "format": "sound_channel_record",
        "arbitration_state": data[0],
        "apu_register_0": data[1],
        "apu_register_1": data[2],
        "timer_low": data[3],
        "timer_high_control": data[4],
        "stream_cursor": data[5] | data[6] << 8,
        "remaining_duration": data[7],
    }


def encode_sound_channel_record(document: dict[str, object]) -> bytes:
    cursor = int(document["stream_cursor"])
    if not 0 <= cursor <= 0xFFFF:
        raise ValueError("Sound stream cursor must fit in 16 bits")
    values = (
        document["arbitration_state"],
        document["apu_register_0"],
        document["apu_register_1"],
        document["timer_low"],
        document["timer_high_control"],
        cursor & 0xFF,
        cursor >> 8,
        document["remaining_duration"],
    )
    if any(not isinstance(value, int) or not 0 <= value <= 0xFF for value in values):
        raise ValueError("Sound channel record fields must fit in bytes")
    return bytes(values)


def decode_ppu(data: bytes) -> dict[str, object]:
    cursor = 0
    commands = []
    while cursor < len(data) and data[cursor] != 0xFF:
        if cursor + 2 > len(data):
            raise ValueError("Truncated PPU command address")
        address = data[cursor] << 8 | data[cursor + 1]
        cursor += 2
        payload = []
        while cursor < len(data) and data[cursor] not in (0x00, 0xFF):
            payload.append(data[cursor])
            cursor += 1
        if cursor >= len(data):
            raise ValueError("PPU command stream lacks terminator")
        terminator = data[cursor]
        commands.append({"address": address, "payload": payload, "terminator": terminator})
        if terminator == 0xFF:
            break
        cursor += 1
    if cursor >= len(data) or data[cursor] != 0xFF:
        raise ValueError("PPU command stream lacks final $FF")
    if cursor != len(data) - 1:
        raise ValueError("PPU command stream has trailing bytes after $FF")
    return {"format": "ppu_command_buffer", "commands": commands}


def encode_ppu(document: dict[str, object]) -> bytes:
    output = bytearray()
    commands = document["commands"]
    ended = False
    for index, command in enumerate(commands):
        address = int(command["address"])
        payload = command["payload"]
        if not 0 <= address <= 0x3FFF:
            raise ValueError(f"Invalid PPU address: {address}")
        if any(value in (0x00, 0xFF) for value in payload):
            raise ValueError("PPU payload cannot contain $00 or $FF")
        output.extend((address >> 8, address & 0xFF))
        output.extend(payload)
        terminator = int(command.get("terminator", 0x00))
        if terminator not in (0x00, 0xFF):
            raise ValueError("PPU command terminator must be $00 or $FF")
        output.append(terminator)
        if terminator == 0xFF:
            if index != len(commands) - 1:
                raise ValueError("PPU commands cannot follow a final $FF")
            ended = True
    if not ended:
        output.append(0xFF)
    return bytes(output)


def decode_actors(data: bytes) -> dict[str, object]:
    if len(data) != 624:
        raise ValueError(f"Actor table block must be 624 bytes, got {len(data)}")
    return {
        "format": "actor_sprite_tables",
        "standard_tile_quads": chunks(data[0:256], 4),
        "alternate_tile_quads": chunks(data[256:308], 4),
        "standard_attribute_quads": chunks(data[308:564], 4),
        "alternate_attribute_quads": chunks(data[564:616], 4),
        "oam_offsets_yx": chunks(data[616:624], 2),
    }


def encode_actors(document: dict[str, object]) -> bytes:
    sections = (
        ("standard_tile_quads", 64),
        ("alternate_tile_quads", 13),
        ("standard_attribute_quads", 64),
        ("alternate_attribute_quads", 13),
        ("oam_offsets_yx", 4),
    )
    output = bytearray()
    for name, count in sections:
        records = document[name]
        width = 2 if name == "oam_offsets_yx" else 4
        if not isinstance(records, list) or len(records) != count:
            raise ValueError(f"Expected {count} records in {name}")
        if any(len(record) != width for record in records):
            raise ValueError(f"Invalid record width in {name}")
        output.extend(flatten(records))
    return bytes(output)


def decode_intermission(data: bytes, regions: list[dict[str, object]]) -> dict[str, object]:
    cursor = 0
    tables = []
    for region in regions:
        count = int(region["count"])
        width = 2 if region["kind"] == "words" else 1
        size = count * width
        raw = data[cursor:cursor + size]
        if len(raw) != size:
            raise ValueError(f"Intermission bundle is truncated at {region['name']}")
        values = [raw[index] | raw[index + 1] << 8 for index in range(0, size, 2)] if width == 2 else list(raw)
        tables.append({
            "name": region["name"],
            "kind": region["kind"],
            "count": count,
            "values": values,
        })
        cursor += size
    if cursor != len(data):
        raise ValueError("Intermission bundle has trailing bytes")
    return {"format": "intermission_tables", "tables": tables}


def encode_intermission(document: dict[str, object]) -> bytes:
    output = bytearray()
    for table in document["tables"]:
        if len(table["values"]) != int(table["count"]):
            raise ValueError(f"Intermission table count mismatch: {table['name']}")
        if table["kind"] == "words":
            for value in table["values"]:
                if not 0 <= value <= 0xFFFF:
                    raise ValueError("Intermission pointer is outside 16-bit range")
                output.extend((value & 0xFF, value >> 8))
        elif table["kind"] == "bytes":
            output.extend(table["values"])
        else:
            raise ValueError(f"Unknown intermission table kind: {table['kind']}")
    return bytes(output)


CODECS: dict[str, tuple[Callable[..., dict[str, object]], Callable[[dict[str, object]], bytes]]] = {
    "stage": (decode_stage, encode_stage),
    "maze": (decode_maze, encode_maze),
    "sound": (decode_sound, encode_sound),
    "ppu": (decode_ppu, encode_ppu),
    "actors": (decode_actors, encode_actors),
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("decode", "encode"))
    parser.add_argument("format", choices=sorted((*CODECS, "intermission")))
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--config", type=Path)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.format == "intermission":
        encoder = encode_intermission
        if args.operation == "decode":
            if args.config is None:
                parser.error("intermission decode requires --config")
            config = json.loads(args.config.read_text(encoding="utf-8"))
            document = decode_intermission(args.input.read_bytes(), config["intermission_tables"])
            args.output.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
            return 0
    else:
        decoder, encoder = CODECS[args.format]
    if args.operation == "decode":
        document = decoder(args.input.read_bytes())
        args.output.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    else:
        document = json.loads(args.input.read_text(encoding="utf-8"))
        args.output.write_bytes(encoder(document))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
