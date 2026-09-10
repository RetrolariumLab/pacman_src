#!/usr/bin/env python3
"""Document model shared by the local Pac-Man Sound Studio and its tests."""

from __future__ import annotations

import copy
import json
from pathlib import Path

from data_formats import decode_sound, encode_sound
from midi_to_sound import import_commands
from sound_authoring import midi_note_name, midi_to_sound_byte, note_name_to_midi, sound_byte_to_midi


SLOT_COUNT = 16


def load_collection(path: Path) -> dict[str, object]:
    document = json.loads(path.read_text(encoding="utf-8"))
    validate_collection(document)
    return document


def load_original_collection(manifest_path: Path, asset_dir: Path) -> dict[str, object]:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = sorted(
        (item for item in manifest["assets"] if item["path"].startswith("audio/")),
        key=lambda item: item["path"],
    )
    document = {
        "format": "sound_stream_collection",
        "streams": [
            {
                "path": item["path"],
                "stream": decode_sound((asset_dir / item["path"]).read_bytes()),
            }
            for item in assets
        ],
    }
    validate_collection(document)
    return document


def validate_collection(document: dict[str, object]) -> None:
    if document.get("format") != "sound_stream_collection":
        raise ValueError("Sound Studio requires a sound_stream_collection document")
    streams = document.get("streams")
    if not isinstance(streams, list) or len(streams) != SLOT_COUNT:
        raise ValueError("Sound Studio requires exactly 16 ordered sound slots")
    for slot, item in enumerate(streams):
        prefix = f"audio/slot{slot:02x}_"
        if not isinstance(item, dict) or not str(item.get("path", "")).startswith(prefix):
            raise ValueError(f"Sound slot order mismatch at slot {slot:02X}")
        encode_sound(item["stream"])


def command_description(command: dict[str, object]) -> str:
    kind = command["kind"]
    if kind == "note":
        midi = sound_byte_to_midi(int(command["value"]))
        return f"{midi_note_name(midi)} (${int(command['value']):02X})"
    if kind == "duration":
        return f"duration marker ${int(command['marker']):02X}"
    operand = command.get("operand")
    suffix = "" if operand is None else f" ${int(operand):02X}"
    return f"control ${int(command['opcode']):02X}{suffix}"


class StudioDocument:
    def __init__(
        self,
        document: dict[str, object],
        path: Path,
        original: dict[str, object] | None = None,
    ) -> None:
        validate_collection(document)
        if original is not None:
            validate_collection(original)
        self.document = copy.deepcopy(document)
        self.path = path
        self.saved = copy.deepcopy(document)
        self.original = copy.deepcopy(original if original is not None else document)

    def item(self, slot: int) -> dict[str, object]:
        if not 0 <= slot < SLOT_COUNT:
            raise ValueError("Sound slot must be in 0..15")
        return self.document["streams"][slot]

    def commands(self, slot: int) -> list[dict[str, object]]:
        return self.item(slot)["stream"]["commands"]

    def slot_label(self, slot: int) -> str:
        return f"{slot:02X}  {Path(self.item(slot)['path']).stem}"

    def slot_changed(self, slot: int) -> bool:
        return self.item(slot)["stream"] != self.original["streams"][slot]["stream"]

    def original_command_description(self, slot: int, index: int) -> str:
        commands = self.original["streams"][slot]["stream"]["commands"]
        if not 0 <= index < len(commands):
            return "(not present)"
        return command_description(commands[index])

    @property
    def dirty(self) -> bool:
        return self.document != self.saved

    def summary(self, slot: int) -> dict[str, int | bool]:
        commands = self.commands(slot)
        return {
            "commands": len(commands),
            "notes": sum(command["kind"] == "note" for command in commands),
            "frames": sum(
                int(command.get("duration", 0))
                for command in commands
                if command["kind"] in ("note", "duration")
            ),
            "bytes": len(encode_sound(self.item(slot)["stream"])),
            "changed_from_original": self.slot_changed(slot),
        }

    def update_note(self, slot: int, index: int, name: str, duration: int) -> None:
        commands = self.commands(slot)
        if not 0 <= index < len(commands) or commands[index]["kind"] != "note":
            raise ValueError("Select a note command before editing it")
        if not 1 <= duration <= 255:
            raise ValueError("Note duration must be in 1..255 NTSC frames")
        value = midi_to_sound_byte(note_name_to_midi(name))
        replacement = {"kind": "note", "value": value, "duration": duration}
        old = commands[index]
        commands[index] = replacement
        try:
            encode_sound(self.item(slot)["stream"])
        except Exception:
            commands[index] = old
            raise

    def insert_note(self, slot: int, index: int, name: str, duration: int) -> None:
        if not 1 <= duration <= 255:
            raise ValueError("Note duration must be in 1..255 NTSC frames")
        commands = self.commands(slot)
        index = min(max(index, 0), len(commands))
        command = {
            "kind": "note",
            "value": midi_to_sound_byte(note_name_to_midi(name)),
            "duration": duration,
        }
        commands.insert(index, command)
        try:
            encode_sound(self.item(slot)["stream"])
        except Exception:
            commands.pop(index)
            raise

    def delete_note(self, slot: int, index: int) -> None:
        commands = self.commands(slot)
        if not 0 <= index < len(commands) or commands[index]["kind"] != "note":
            raise ValueError("Only note commands can be deleted in the piano-roll editor")
        removed = commands.pop(index)
        try:
            encode_sound(self.item(slot)["stream"])
        except Exception:
            commands.insert(index, removed)
            raise

    def replace_from_midi(self, slot: int, data: bytes, track: int, channel: int) -> None:
        commands = import_commands(data, track, channel)
        stream = self.item(slot)["stream"]
        previous_commands = stream["commands"]
        previous_trailing = stream["trailing_bytes"]
        stream["commands"] = commands
        stream["trailing_bytes"] = []
        try:
            encode_sound(stream)
        except Exception:
            stream["commands"] = previous_commands
            stream["trailing_bytes"] = previous_trailing
            raise

    def reset_slot_to_original(self, slot: int) -> None:
        self.item(slot)["stream"] = copy.deepcopy(self.original["streams"][slot]["stream"])

    def save(self, path: Path | None = None) -> Path:
        destination = path if path is not None else self.path
        validate_collection(self.document)
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(destination.name + ".tmp")
        temporary.write_text(json.dumps(self.document, indent=2) + "\n", encoding="utf-8")
        temporary.replace(destination)
        self.path = destination
        self.saved = copy.deepcopy(self.document)
        return destination
