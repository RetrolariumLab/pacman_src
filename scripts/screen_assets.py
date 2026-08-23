#!/usr/bin/env python3
"""Validated screen, text, HUD, and visual intermission assets for M19."""

from __future__ import annotations

import copy
import json
from pathlib import Path

try:
    from build_native import parse_ines
except ModuleNotFoundError:  # Imported as scripts.screen_assets by unit tests.
    from scripts.build_native import parse_ines


FORMAT = "pacman_screen_collection"
PRG_BASE = 0xC000
EXPANDED_BASE = 0xA79E
BUNDLE_SIZE = 0x0412
TITLE_PACKET_CAPACITY = 0x0100
ATTRACT_PACKET_CAPACITY = 0x0200

OFFSETS = {
    "title_logo": 0x0000,
    "title_packets": 0x008A,
    "title_attributes": 0x018A,
    "menu_prompt": 0x01A2,
    "player_count_glyphs": 0x01AA,
    "attract_pointers": 0x01AD,
    "attract_packets": 0x01C1,
    "hud_blocks": 0x03C1,
    "hud_player_packets": 0x03D8,
    "pause_tiles": 0x03EA,
    "intermission_visual": 0x03F6,
}

INTERMISSION_READ_ONLY = (
    ("scene_dispatch", 0xE769, 3, "words"),
    ("scene_0_states", 0xE77E, 4, "words"),
    ("scene_1_states", 0xE862, 3, "words"),
    ("scene_2_states", 0xE909, 4, "words"),
    ("animation_scene_dispatch", 0xEA2F, 3, "words"),
    ("animation_scene_0_states", 0xEA44, 4, "words"),
    ("animation_scene_1_states", 0xEAD8, 3, "words"),
    ("animation_scene_2_states", 0xEB08, 4, "words"),
)

# Pac-Man's text tiles deliberately overlap the ASCII codes for its available
# uppercase font. Lowercase host input is folded onto those uppercase glyphs;
# unsupported punctuation is rejected instead of silently selecting graphics.
GAME_TEXT_TO_TILE = {
    **{chr(value): value for value in range(ord("A"), ord("Z") + 1)},
    **{chr(value): value - 0x20 for value in range(ord("a"), ord("z") + 1)},
    **{chr(value): value for value in range(ord("0"), ord("9") + 1)},
    " ": 0x20, ".": 0x2E, ";": 0x3B,
}
GAME_TILE_TO_TEXT = {value: chr(value) for value in range(ord("A"), ord("Z") + 1)}
GAME_TILE_TO_TEXT.update({value: chr(value) for value in range(ord("0"), ord("9") + 1)})
GAME_TILE_TO_TEXT.update({0x20: " ", 0x2E: ".", 0x3B: ";"})

TEXT_MESSAGES = (
    {"key": "title_one_player", "label": "Title: 1 PLAYER", "group": "title_packets", "index": 1, "start": 2, "width": 8},
    {"key": "title_two_players", "label": "Title: 2 PLAYERS", "group": "title_packets", "index": 2, "start": 0, "width": 9},
    {"key": "title_copyright", "label": "Title: copyright line", "group": "title_packets", "index": 4, "start": 1, "width": 20},
    {"key": "title_rights", "label": "Title: rights line", "group": "title_packets", "index": 5, "start": 0, "width": 19},
    {"key": "attract_header", "label": "Attract: character header", "group": "attract_packets", "index": 0, "start": 0, "width": 21},
    {"key": "attract_oikake", "label": "Attract: OIKAKE", "group": "attract_packets", "index": 1, "start": 0, "width": 11},
    {"key": "attract_akabei", "label": "Attract: AKABEI", "group": "attract_packets", "index": 2, "start": 1, "width": 6},
    {"key": "attract_machibuse", "label": "Attract: MACHIBUSE", "group": "attract_packets", "index": 3, "start": 0, "width": 11},
    {"key": "attract_pinky", "label": "Attract: PINKY", "group": "attract_packets", "index": 4, "start": 1, "width": 5},
    {"key": "attract_otoboke", "label": "Attract: OTOBOKE", "group": "attract_packets", "index": 7, "start": 0, "width": 11},
    {"key": "attract_guzuta", "label": "Attract: GUZUTA", "group": "attract_packets", "index": 8, "start": 1, "width": 6},
    {"key": "points_ten", "label": "Attract: 10 PTS", "group": "attract_packets", "index": 9, "start": 2, "width": 6},
    {"key": "points_fifty", "label": "Attract: 50 PTS", "group": "attract_packets", "index": 9, "start": 13, "width": 6},
    {"key": "pause", "label": "Gameplay: PAUSE", "group": "pause_tiles", "start": 0, "width": 5},
)
TEXT_MESSAGE_BY_KEY = {item["key"]: item for item in TEXT_MESSAGES}


def encode_game_text(text: str, width: int) -> list[int]:
    if len(text) > width:
        raise ValueError(f"Game text is {len(text)} characters; this field allows {width}")
    unsupported = sorted({character for character in text if character not in GAME_TEXT_TO_TILE})
    if unsupported:
        rendered = " ".join(repr(character) for character in unsupported)
        raise ValueError(f"Unsupported game-font character(s): {rendered}")
    return [GAME_TEXT_TO_TILE[character] for character in text] + [0x20] * (width - len(text))


def decode_game_text(values: list[int]) -> str:
    try:
        return "".join(GAME_TILE_TO_TEXT[value] for value in values).rstrip()
    except KeyError as error:
        raise ValueError(f"Tile ${error.args[0]:02X} is not an English game-font glyph") from error


def _prg(rom: bytes) -> bytes:
    _header, prg, _chr = parse_ines(rom)
    if len(prg) != 16_384:
        raise ValueError("Screen bootstrap requires the original 16 KiB PRG")
    return prg


def _slice(prg: bytes, address: int, size: int) -> bytes:
    start = address - PRG_BASE
    data = prg[start:start + size]
    if len(data) != size:
        raise ValueError(f"Screen source ${address:04X} is truncated")
    return data


def _packet(prg: bytes, address: int) -> tuple[dict[str, object], int]:
    start = address - PRG_BASE
    cursor = start
    while cursor < len(prg) and prg[cursor] != 0xFF:
        cursor += 1
    if cursor >= len(prg) or cursor - start < 2:
        raise ValueError(f"PPU packet ${address:04X} lacks a valid terminator")
    raw = prg[start:cursor + 1]
    return {
        "address": raw[0] << 8 | raw[1],
        "bytes": list(raw[2:-1]),
    }, prg[cursor + 1] if cursor + 1 < len(prg) else 0xFF


def _encode_packet(packet: dict[str, object]) -> bytes:
    address = int(packet["address"])
    values = packet["bytes"]
    if not 0x2000 <= address <= 0x3FFF:
        raise ValueError(f"Screen packet address ${address:04X} is outside PPU memory")
    if not isinstance(values, list) or any(
            not isinstance(value, int) or not 0 <= value <= 0xFE for value in values):
        raise ValueError("Screen packet bytes must fit in $00..$FE")
    return bytes((address >> 8, address & 0xFF, *values, 0xFF))


def tile_text(values: list[int]) -> str:
    return "".join(chr(value) if 0x20 <= value <= 0x7E else f"<{value:02X}>" for value in values)


def parse_tile_text(text: str) -> list[int]:
    values = []
    cursor = 0
    while cursor < len(text):
        if text[cursor] == "<":
            end = text.find(">", cursor + 1)
            token = text[cursor + 1:end] if end >= 0 else ""
            if end < 0 or len(token) != 2:
                raise ValueError("Raw tiles must use <XX> notation")
            try:
                value = int(token, 16)
            except ValueError as error:
                raise ValueError(f"Invalid raw tile <{token}>") from error
            cursor = end + 1
        else:
            value = ord(text[cursor])
            cursor += 1
        if not 0 <= value <= 0xFE:
            raise ValueError("Text mapping produced a tile outside $00..$FE")
        values.append(value)
    return values


def decode_screen_collection(rom: bytes) -> dict[str, object]:
    prg = _prg(rom)
    title_packets = []
    cursor = 0xC329
    for _ in range(6):
        packet, _post = _packet(prg, cursor)
        title_packets.append(packet)
        cursor += len(_encode_packet(packet))
    if cursor != 0xC395:
        raise ValueError("Title packet block no longer ends at $C395")

    pointers = _slice(prg, 0xC5D3, 20)
    attract_packets = []
    for index in range(0, 20, 2):
        source = pointers[index] | pointers[index + 1] << 8
        packet, post_byte = _packet(prg, source)
        packet["post_byte"] = post_byte
        attract_packets.append(packet)

    read_only = []
    for name, address, count, kind in INTERMISSION_READ_ONLY:
        raw = _slice(prg, address, count * (2 if kind == "words" else 1))
        values = ([raw[index] | raw[index + 1] << 8 for index in range(0, len(raw), 2)]
                  if kind == "words" else list(raw))
        read_only.append({
            "name": name, "address": address, "kind": kind,
            "count": count, "values": values,
        })

    document: dict[str, object] = {
        "format": FORMAT,
        "title_logo": {
            "ppu_address": 0x20E5, "width": 23, "height": 6,
            "tiles": list(_slice(prg, 0xC29F, 138)),
        },
        "title_packets": title_packets,
        "title_attributes": {
            "ppu_address": 0x23C8, "bytes": list(_slice(prg, 0xC3A5, 24)),
        },
        "menu_prompt": list(_slice(prg, 0xC44D, 8)),
        "player_count_glyphs": list(_slice(prg, 0xC455, 3)),
        "attract_packets": attract_packets,
        "hud_blocks": list(_slice(prg, 0xE4B6, 23)),
        "hud_player_packets": list(_slice(prg, 0xD04E, 18)),
        "pause_tiles": list(_slice(prg, 0xCA91, 12)),
        "intermission_visual": {
            "cycle_tiles": list(_slice(prg, 0xEA5A, 8)),
            "cycle_pattern_indexes": list(_slice(prg, 0xEAB5, 8)),
            "banner_tile_quads": list(_slice(prg, 0xEABD, 12)),
        },
        "read_only_code_tables": read_only,
    }
    validate_screen_collection(document)
    return document


def _byte_list(document: dict[str, object], name: str, count: int) -> list[int]:
    values = document.get(name)
    if not isinstance(values, list) or len(values) != count:
        raise ValueError(f"{name} must contain exactly {count} bytes")
    if any(not isinstance(value, int) or not 0 <= value <= 0xFF for value in values):
        raise ValueError(f"{name} contains a value outside $00..$FF")
    return values


def validate_screen_collection(document: dict[str, object]) -> None:
    if document.get("format") != FORMAT:
        raise ValueError("Screen JSON has the wrong format")
    logo = document.get("title_logo")
    if not isinstance(logo, dict) or logo.get("width") != 23 or logo.get("height") != 6:
        raise ValueError("Title logo must retain its 23x6 engine layout")
    _byte_list(logo, "tiles", 138)
    if logo.get("ppu_address") != 0x20E5:
        raise ValueError("Title logo PPU origin must remain $20E5")
    packets = document.get("title_packets")
    if not isinstance(packets, list) or len(packets) != 6:
        raise ValueError("Title screen requires exactly six text packets")
    title_size = sum(len(_encode_packet(packet)) for packet in packets)
    if title_size > TITLE_PACKET_CAPACITY:
        raise ValueError("Title packets exceed their 256-byte expanded budget")
    attrs = document.get("title_attributes")
    if not isinstance(attrs, dict) or attrs.get("ppu_address") != 0x23C8:
        raise ValueError("Title attributes must retain PPU origin $23C8")
    _byte_list(attrs, "bytes", 24)
    for name, count in (("menu_prompt", 8), ("player_count_glyphs", 3),
                        ("hud_blocks", 23), ("hud_player_packets", 18),
                        ("pause_tiles", 12)):
        _byte_list(document, name, count)
    menu = document["menu_prompt"]
    if not 0x2000 <= (menu[0] << 8 | menu[1]) <= 0x3FFF or menu[-1] != 0xFF:
        raise ValueError("Menu prompt must retain a valid PPU address and terminator")
    pause = document["pause_tiles"]
    if pause[5] != 0xFF or pause[11] != 0xFF:
        raise ValueError("Pause visible and blank packets must retain their terminators")
    attract = document.get("attract_packets")
    if not isinstance(attract, list) or len(attract) != 10:
        raise ValueError("Attract screen requires exactly ten pointer-selected packets")
    attract_size = 0
    for packet in attract:
        post = packet.get("post_byte")
        if not isinstance(post, int) or not 0 <= post <= 0xFF:
            raise ValueError("Attract post-byte must fit in one byte")
        attract_size += len(_encode_packet(packet)) + 1
    if attract_size > ATTRACT_PACKET_CAPACITY:
        raise ValueError("Attract packets exceed their 512-byte expanded budget")
    visual = document.get("intermission_visual")
    if not isinstance(visual, dict):
        raise ValueError("Missing intermission visual tables")
    _byte_list(visual, "cycle_tiles", 8)
    indexes = _byte_list(visual, "cycle_pattern_indexes", 8)
    if any(value not in (0, 4, 8) for value in indexes):
        raise ValueError("Intermission cycle indexes must select a four-tile banner frame")
    _byte_list(visual, "banner_tile_quads", 12)
    read_only = document.get("read_only_code_tables")
    if not isinstance(read_only, list) or len(read_only) != len(INTERMISSION_READ_ONLY):
        raise ValueError("Read-only intermission code table catalogue changed")
    for item, spec in zip(read_only, INTERMISSION_READ_ONLY):
        name, address, count, kind = spec
        if (item.get("name"), item.get("address"), item.get("count"), item.get("kind")) != spec:
            raise ValueError(f"Read-only code table metadata changed: {name}")
        if len(item.get("values", [])) != count:
            raise ValueError(f"Read-only code table is truncated: {name}")


def encode_screen_collection(document: dict[str, object]) -> bytes:
    validate_screen_collection(document)
    output = bytearray(b"\xFF" * BUNDLE_SIZE)

    def place(name: str, payload: bytes, capacity: int | None = None) -> None:
        offset = OFFSETS[name]
        limit = capacity if capacity is not None else len(payload)
        if len(payload) > limit or offset + limit > len(output):
            raise ValueError(f"Expanded screen region overflow: {name}")
        output[offset:offset + len(payload)] = payload

    place("title_logo", bytes(document["title_logo"]["tiles"]))
    title_packets = b"".join(_encode_packet(packet) for packet in document["title_packets"])
    place("title_packets", title_packets, TITLE_PACKET_CAPACITY)
    place("title_attributes", bytes(document["title_attributes"]["bytes"]))
    place("menu_prompt", bytes(document["menu_prompt"]))
    place("player_count_glyphs", bytes(document["player_count_glyphs"]))

    packet_blob = bytearray()
    pointers = bytearray()
    for packet in document["attract_packets"]:
        address = EXPANDED_BASE + OFFSETS["attract_packets"] + len(packet_blob)
        pointers.extend((address & 0xFF, address >> 8))
        packet_blob.extend(_encode_packet(packet))
        packet_blob.append(packet["post_byte"])
    place("attract_pointers", bytes(pointers))
    place("attract_packets", bytes(packet_blob), ATTRACT_PACKET_CAPACITY)
    place("hud_blocks", bytes(document["hud_blocks"]))
    place("hud_player_packets", bytes(document["hud_player_packets"]))
    place("pause_tiles", bytes(document["pause_tiles"]))
    visual = document["intermission_visual"]
    place("intermission_visual", bytes(
        visual["cycle_tiles"] + visual["cycle_pattern_indexes"] + visual["banner_tile_quads"]
    ))
    return bytes(output)


class ScreenDocument:
    def __init__(self, document: dict[str, object], path: Path) -> None:
        validate_screen_collection(document)
        self.document = copy.deepcopy(document)
        self.saved = copy.deepcopy(document)
        self.path = path

    @property
    def dirty(self) -> bool:
        return self.document != self.saved

    def set_tiles(self, section: str, values: list[int]) -> None:
        candidate = copy.deepcopy(self.document)
        if section == "title_logo":
            candidate[section]["tiles"] = list(values)
        elif section == "title_attributes":
            candidate[section]["bytes"] = list(values)
        elif section in ("menu_prompt", "player_count_glyphs", "hud_blocks",
                         "hud_player_packets", "pause_tiles"):
            candidate[section] = list(values)
        else:
            raise ValueError(f"Unsupported editable tile section: {section}")
        validate_screen_collection(candidate)
        self.document = candidate

    def set_packet(self, group: str, index: int, address: int, values: list[int]) -> None:
        if group not in ("title_packets", "attract_packets"):
            raise ValueError("Unknown packet group")
        candidate = copy.deepcopy(self.document)
        candidate[group][index]["address"] = address
        candidate[group][index]["bytes"] = list(values)
        validate_screen_collection(candidate)
        self.document = candidate

    def get_message(self, key: str) -> str:
        spec = TEXT_MESSAGE_BY_KEY.get(key)
        if spec is None:
            raise ValueError("Unknown game-text message")
        source = (self.document[spec["group"]][spec["index"]]["bytes"]
                  if "index" in spec else self.document[spec["group"]])
        start, width = spec["start"], spec["width"]
        return decode_game_text(source[start:start + width])

    def set_message(self, key: str, text: str) -> None:
        spec = TEXT_MESSAGE_BY_KEY.get(key)
        if spec is None:
            raise ValueError("Unknown game-text message")
        candidate = copy.deepcopy(self.document)
        source = (candidate[spec["group"]][spec["index"]]["bytes"]
                  if "index" in spec else candidate[spec["group"]])
        start, width = spec["start"], spec["width"]
        source[start:start + width] = encode_game_text(text, width)
        validate_screen_collection(candidate)
        self.document = candidate

    def save(self) -> Path:
        encode_screen_collection(self.document)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_name(self.path.name + ".tmp")
        temporary.write_text(json.dumps(self.document, indent=2) + "\n", encoding="utf-8")
        temporary.replace(self.path)
        self.saved = copy.deepcopy(self.document)
        return self.path


def load_screen_document(path: Path, fallback: dict[str, object]) -> ScreenDocument:
    document = json.loads(path.read_text(encoding="utf-8")) if path.exists() else fallback
    return ScreenDocument(document, path)
