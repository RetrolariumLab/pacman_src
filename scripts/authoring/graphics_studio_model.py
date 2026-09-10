#!/usr/bin/env python3
"""Reversible CHR and actor-metasprite model for the local Graphics Studio."""

from __future__ import annotations

import copy
import json
from pathlib import Path

from data_formats import decode_actors, encode_actors


CHR_SIZE = 8192
TILE_COUNT = 512
TILE_SIZE = 16
NES_PALETTE_SIZE = 64
DEFAULT_SPRITE_PALETTE = (0x0F, 0x29, 0x16, 0x30)


def decode_chr(data: bytes) -> list[list[list[int]]]:
    if len(data) != CHR_SIZE:
        raise ValueError(f"CHR must be exactly {CHR_SIZE} bytes, got {len(data)}")
    tiles = []
    for tile in range(TILE_COUNT):
        offset = tile * TILE_SIZE
        pixels = []
        for row in range(8):
            low, high = data[offset + row], data[offset + 8 + row]
            pixels.append([((low >> (7 - column)) & 1) | (((high >> (7 - column)) & 1) << 1)
                           for column in range(8)])
        tiles.append(pixels)
    return tiles


def encode_chr(tiles: list[list[list[int]]]) -> bytes:
    if len(tiles) != TILE_COUNT:
        raise ValueError(f"CHR requires exactly {TILE_COUNT} tiles")
    output = bytearray()
    for tile_index, tile in enumerate(tiles):
        if len(tile) != 8 or any(len(row) != 8 for row in tile):
            raise ValueError(f"CHR tile {tile_index} must be 8x8 pixels")
        if any(pixel not in range(4) for row in tile for pixel in row):
            raise ValueError(f"CHR tile {tile_index} uses a pixel outside 2bpp range 0..3")
        for plane in (0, 1):
            for row in tile:
                value = 0
                for pixel in row:
                    value = value << 1 | ((pixel >> plane) & 1)
                output.append(value)
    return bytes(output)


def validate_palette(palette: list[int] | tuple[int, ...]) -> None:
    if len(palette) != 4 or any(not 0 <= value < NES_PALETTE_SIZE for value in palette):
        raise ValueError("NES subpalette must contain four values in $00..$3F")


def transform_tile(tile: list[list[int]], attribute: int) -> list[list[int]]:
    if not 0 <= attribute <= 0xFF or attribute & 0x1C:
        raise ValueError(f"Unsupported OAM attribute bits in ${attribute:02X}")
    result = copy.deepcopy(tile)
    if attribute & 0x40:
        result = [list(reversed(row)) for row in result]
    if attribute & 0x80:
        result = list(reversed(result))
    return result


def load_actor_tables(rom: bytes, cpu_address: int = 0xDB59) -> dict[str, object]:
    if rom[:4] != b"NES\x1A":
        raise ValueError("Actor tables require an iNES ROM")
    trainer = 512 if rom[6] & 0x04 else 0
    prg_size = rom[4] * 16384
    prg = rom[16 + trainer:16 + trainer + prg_size]
    offset = cpu_address - (0x10000 - prg_size)
    if not 0 <= offset <= len(prg) - 624:
        raise ValueError("Actor table address is outside the PRG image")
    document = decode_actors(prg[offset:offset + 624])
    if len(encode_actors(document)) != 624:
        raise ValueError("Actor table round-trip changed its fixed size")
    return document


def metasprite_pixels(
    tiles: list[list[list[int]]],
    actors: dict[str, object],
    frame: int,
    alternate: bool = False,
) -> list[list[tuple[int, int]]]:
    tile_key = "alternate_tile_quads" if alternate else "standard_tile_quads"
    attr_key = "alternate_attribute_quads" if alternate else "standard_attribute_quads"
    quads, attrs = actors[tile_key], actors[attr_key]
    if not 0 <= frame < len(quads):
        raise ValueError("Metasprite frame is outside the selected actor table")
    offsets = actors["oam_offsets_yx"]
    signed_offsets = [
        (y if y < 0x80 else y - 0x100, x if x < 0x80 else x - 0x100)
        for y, x in offsets
    ]
    min_y = min(y for y, _ in signed_offsets)
    min_x = min(x for _, x in signed_offsets)
    canvas = [[(0, 0) for _ in range(16)] for _ in range(16)]
    for index, (tile_id, attribute) in enumerate(zip(quads[frame], attrs[frame])):
        if tile_id >= 256:
            raise ValueError("Actor sprite tile index must fit the sprite CHR bank")
        if attribute & 0x1C:
            raise ValueError(f"Actor frame uses unsupported OAM attribute bits ${attribute:02X}")
        raw_y, raw_x = signed_offsets[index]
        y_offset, x_offset = raw_y - min_y, raw_x - min_x
        if y_offset not in (0, 8) or x_offset not in (0, 8):
            raise ValueError("Actor OAM offsets must form a 16x16 four-tile layout")
        pixels = transform_tile(tiles[256 + tile_id], attribute)
        palette = attribute & 0x03
        for y in range(8):
            for x in range(8):
                canvas[y_offset + y][x_offset + x] = (pixels[y][x], palette)
    return canvas


class GraphicsDocument:
    def __init__(self, chr_data: bytes, path: Path) -> None:
        self.tiles = decode_chr(chr_data)
        self.original = copy.deepcopy(self.tiles)
        self.saved = copy.deepcopy(self.tiles)
        self.path = path
        self.undo_stack: list[tuple[int, list[list[int]]]] = []
        self.stroke_tile: int | None = None

    @property
    def dirty(self) -> bool:
        return self.tiles != self.saved

    def changed(self, tile: int) -> bool:
        return self.tiles[tile] != self.original[tile]

    def begin_stroke(self, tile: int) -> None:
        if not 0 <= tile < TILE_COUNT:
            raise ValueError("CHR stroke tile is outside the tile bank")
        self.stroke_tile = tile
        self.undo_stack.append((tile, copy.deepcopy(self.tiles[tile])))

    def end_stroke(self) -> None:
        if self.stroke_tile is not None and self.undo_stack[-1][1] == self.tiles[self.stroke_tile]:
            self.undo_stack.pop()
        self.stroke_tile = None

    def paint(self, tile: int, row: int, column: int, color: int) -> bool:
        if not 0 <= tile < TILE_COUNT or not 0 <= row < 8 or not 0 <= column < 8:
            raise ValueError("CHR paint coordinate is outside the tile bank")
        if color not in range(4):
            raise ValueError("CHR pixel color must be in 0..3")
        if self.tiles[tile][row][column] == color:
            return False
        if self.stroke_tile != tile:
            self.undo_stack.append((tile, copy.deepcopy(self.tiles[tile])))
        self.tiles[tile][row][column] = color
        return True

    def undo(self) -> bool:
        if not self.undo_stack:
            return False
        tile, pixels = self.undo_stack.pop()
        self.tiles[tile] = pixels
        return True

    def restore_tile(self, tile: int) -> None:
        if self.changed(tile):
            self.undo_stack.append((tile, copy.deepcopy(self.tiles[tile])))
            self.tiles[tile] = copy.deepcopy(self.original[tile])

    def save(self, path: Path | None = None) -> Path:
        destination = path or self.path
        payload = encode_chr(self.tiles)
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(destination.name + ".tmp")
        temporary.write_bytes(payload)
        temporary.replace(destination)
        self.path = destination
        self.saved = copy.deepcopy(self.tiles)
        return destination


class ActorDocument:
    def __init__(self, actors: dict[str, object], path: Path) -> None:
        encode_actors(actors)
        self.actors = copy.deepcopy(actors)
        self.original = copy.deepcopy(actors)
        self.saved = copy.deepcopy(actors)
        self.path = path

    @property
    def dirty(self) -> bool:
        return self.actors != self.saved

    def set_quad(
        self,
        alternate: bool,
        frame: int,
        quad: int,
        tile: int,
        attribute: int,
    ) -> None:
        if not 0 <= frame < (13 if alternate else 64) or not 0 <= quad < 4:
            raise ValueError("Actor frame coordinate is outside its table")
        tile_key = "alternate_tile_quads" if alternate else "standard_tile_quads"
        attr_key = "alternate_attribute_quads" if alternate else "standard_attribute_quads"
        tiles = list(self.actors[tile_key][frame])
        attributes = list(self.actors[attr_key][frame])
        tiles[quad] = tile
        attributes[quad] = attribute
        self.set_frame(alternate, frame, tiles, attributes)

    def set_frame(
        self,
        alternate: bool,
        frame: int,
        tiles: list[int],
        attributes: list[int],
    ) -> None:
        tile_key = "alternate_tile_quads" if alternate else "standard_tile_quads"
        attr_key = "alternate_attribute_quads" if alternate else "standard_attribute_quads"
        count = 13 if alternate else 64
        if not 0 <= frame < count or len(tiles) != 4 or len(attributes) != 4:
            raise ValueError("Actor frame coordinate is outside its table")
        if any(not 0 <= tile <= 0xFF for tile in tiles):
            raise ValueError("Actor tile ID must be in $00..$FF")
        if any(not 0 <= attribute <= 0xFF or attribute & 0x1C for attribute in attributes):
            raise ValueError("Actor attribute may use only palette, priority, H-flip, and V-flip bits")
        self.actors[tile_key][frame] = list(tiles)
        self.actors[attr_key][frame] = list(attributes)
        encode_actors(self.actors)

    def save(self) -> Path:
        payload = encode_actors(self.actors)
        if len(payload) != 624:
            raise ValueError("Actor mapping must encode to exactly 624 bytes")
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_name(self.path.name + ".tmp")
        temporary.write_text(json.dumps(self.actors, indent=2) + "\n", encoding="utf-8")
        temporary.replace(self.path)
        self.saved = copy.deepcopy(self.actors)
        return self.path


def load_actor_document(path: Path, fallback: dict[str, object]) -> ActorDocument:
    actors = json.loads(path.read_text(encoding="utf-8")) if path.exists() else fallback
    return ActorDocument(actors, path)
