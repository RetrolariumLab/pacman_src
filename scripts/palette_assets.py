#!/usr/bin/env python3
"""Validated editable palette collection for the expanded ROM."""

from __future__ import annotations

import copy
import json
from pathlib import Path

from build_native import parse_ines


FORMAT = "pacman_palette_collection"
PRG_BASE = 0xC000
PALETTE_TABLES = {
    "title_background": (0xC395, 16),
    "attract_bg_spr": (0xC5B3, 32),
    "round_gameplay": (0xD060, 32),
    "intermission_sprites": (0xE73B, 16),
    "fruit_by_stage": (0xE645, 16),
}
FRIGHTENED_COMMAND_ADDRESS = 0xD205
FRIGHTENED_ALT_ADDRESS = 0xE05B
ENCODED_SIZE = 127


def _validate_colors(values: object, count: int, name: str) -> list[int]:
    if not isinstance(values, list) or len(values) != count:
        raise ValueError(f"{name} must contain exactly {count} NES color indexes")
    if any(not isinstance(value, int) or not 0 <= value <= 0x3F for value in values):
        raise ValueError(f"{name} uses a color outside $00..$3F")
    return values


def validate_palette_collection(document: dict[str, object]) -> None:
    if document.get("format") != FORMAT:
        raise ValueError("Palette JSON has the wrong format")
    for name, (_address, count) in PALETTE_TABLES.items():
        _validate_colors(document.get(name), count, name)
    for name in ("attract_bg_spr", "round_gameplay"):
        values = document[name]
        if any(values[index] != values[index + 16] for index in (0, 4, 8, 12)):
            raise ValueError(f"{name} must preserve NES sprite universal-color mirrors")
    frightened = document.get("frightened")
    if not isinstance(frightened, dict):
        raise ValueError("frightened palette entry must be an object")
    for name in ("active", "normal"):
        value = frightened.get(name)
        if not isinstance(value, int) or not 0 <= value <= 0x3F:
            raise ValueError(f"frightened.{name} must be in $00..$3F")


def decode_palette_collection(rom: bytes) -> dict[str, object]:
    _header, prg, _chr = parse_ines(rom)
    if len(prg) != 16_384:
        raise ValueError("Palette bootstrap requires the original 16 KiB PRG")
    document: dict[str, object] = {"format": FORMAT}
    for name, (address, count) in PALETTE_TABLES.items():
        offset = address - PRG_BASE
        document[name] = list(prg[offset:offset + count])
    command = prg[FRIGHTENED_COMMAND_ADDRESS - PRG_BASE:FRIGHTENED_COMMAND_ADDRESS - PRG_BASE + 10]
    alternate = prg[FRIGHTENED_ALT_ADDRESS - PRG_BASE:FRIGHTENED_ALT_ADDRESS - PRG_BASE + 5]
    if command[:3] != b"\x00\x3F\x15" or command[4:8] != b"\xFF\x00\x3F\x15" or command[9] != 0xFF:
        raise ValueError("Original frightened palette command layout is unexpected")
    if alternate != command[:5]:
        raise ValueError("Alternate frightened command differs from its primary copy")
    document["frightened"] = {"active": command[3], "normal": command[8]}
    validate_palette_collection(document)
    return document


def encode_palette_collection(document: dict[str, object]) -> bytes:
    validate_palette_collection(document)
    frightened = document["frightened"]
    command_active = bytes((0x00, 0x3F, 0x15, frightened["active"], 0xFF))
    command_normal = bytes((0x00, 0x3F, 0x15, frightened["normal"], 0xFF))
    payload = bytearray()
    for name in ("title_background", "attract_bg_spr", "round_gameplay", "intermission_sprites"):
        payload.extend(document[name])
    payload.extend(command_active)
    payload.extend(command_normal)
    payload.extend(command_active)
    payload.extend(document["fruit_by_stage"])
    if len(payload) != ENCODED_SIZE:
        raise ValueError(f"Encoded palette collection must be {ENCODED_SIZE} bytes")
    return bytes(payload)


class PaletteDocument:
    def __init__(self, document: dict[str, object], path: Path) -> None:
        validate_palette_collection(document)
        self.document = copy.deepcopy(document)
        self.saved = copy.deepcopy(document)
        self.path = path

    @property
    def dirty(self) -> bool:
        return self.document != self.saved

    def set_color(self, section: str, index: int, value: int) -> None:
        if section not in PALETTE_TABLES:
            raise ValueError(f"Unknown palette section: {section}")
        if not 0 <= index < PALETTE_TABLES[section][1] or not 0 <= value <= 0x3F:
            raise ValueError("Palette edit is outside its NES range")
        self.document[section][index] = value
        if section in ("attract_bg_spr", "round_gameplay") and index % 4 == 0:
            mirror = index + 16 if index < 16 else index - 16
            self.document[section][mirror] = value

    def set_frightened(self, state: str, value: int) -> None:
        if state not in ("active", "normal") or not 0 <= value <= 0x3F:
            raise ValueError("Frightened palette edit is outside its NES range")
        self.document["frightened"][state] = value

    def save(self) -> Path:
        encode_palette_collection(self.document)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_name(self.path.name + ".tmp")
        temporary.write_text(json.dumps(self.document, indent=2) + "\n", encoding="utf-8")
        temporary.replace(self.path)
        self.saved = copy.deepcopy(self.document)
        return self.path


def load_palette_document(path: Path, fallback: dict[str, object]) -> PaletteDocument:
    document = json.loads(path.read_text(encoding="utf-8")) if path.exists() else fallback
    return PaletteDocument(document, path)
