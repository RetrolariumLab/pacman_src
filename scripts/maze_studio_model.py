#!/usr/bin/env python3
"""Editable 27x22 maze model with fixed-size Pac-Man RLE output."""

from __future__ import annotations

import copy
import json
from collections import Counter, deque
from pathlib import Path

from data_formats import encode_maze


ROWS = 27
COLUMNS = 22
RLE_SIZE = 416
PELLET_TILES = frozenset((0x01, 0x03, 0x09))
POWER_PELLET_TILE = 0x01


def validate_grid(grid: list[list[int]]) -> None:
    if len(grid) != ROWS or any(len(row) != COLUMNS for row in grid):
        raise ValueError(f"Maze must be exactly {ROWS}x{COLUMNS} tiles")
    if any(not isinstance(tile, int) or not 0 <= tile <= 0x3F for row in grid for tile in row):
        raise ValueError("Maze tile IDs must be integers in $00..$3F")


def pack_grid(grid: list[list[int]], token_count: int = RLE_SIZE) -> list[dict[str, int]]:
    """Encode row-bounded runs and split them deterministically to a fixed size."""
    validate_grid(grid)
    tokens: list[dict[str, int]] = []
    for row in grid:
        cursor = 0
        while cursor < COLUMNS:
            tile = row[cursor]
            length = 1
            while cursor + length < COLUMNS and length < 4 and row[cursor + length] == tile:
                length += 1
            tokens.append({"length": length, "tile": tile})
            cursor += length
    if len(tokens) > token_count:
        raise ValueError(
            f"Maze needs {len(tokens)} RLE bytes; expanded layout allows {token_count}. "
            "Use longer same-tile runs."
        )
    cursor = 0
    while len(tokens) < token_count:
        while cursor < len(tokens) and tokens[cursor]["length"] == 1:
            cursor += 1
        if cursor == len(tokens):
            raise ValueError(f"Cannot expand maze encoding to exactly {token_count} bytes")
        token = tokens[cursor]
        token["length"] -= 1
        tokens.insert(cursor, {"length": 1, "tile": token["tile"]})
        cursor += 1
    return tokens


def document_from_grid(grid: list[list[int]]) -> dict[str, object]:
    tokens = pack_grid(grid)
    document = {
        "format": "maze_rle",
        "rows": ROWS,
        "columns": COLUMNS,
        "tokens": tokens,
        "decoded_rows": copy.deepcopy(grid),
    }
    encoded = encode_maze(document)
    if len(encoded) != RLE_SIZE:
        raise ValueError(f"Maze encoding must remain {RLE_SIZE} bytes")
    return document


def passable_components(grid: list[list[int]]) -> list[int]:
    remaining = {(row, column) for row in range(ROWS) for column in range(COLUMNS) if grid[row][column] < 0x10}
    sizes = []
    while remaining:
        start = remaining.pop()
        queue = deque((start,))
        size = 1
        while queue:
            row, column = queue.popleft()
            neighbors = ((row - 1, column), (row + 1, column),
                         (row, (column - 1) % COLUMNS), (row, (column + 1) % COLUMNS))
            for neighbor in neighbors:
                if neighbor in remaining:
                    remaining.remove(neighbor)
                    queue.append(neighbor)
                    size += 1
        sizes.append(size)
    return sorted(sizes, reverse=True)


def inspect_grid(grid: list[list[int]]) -> dict[str, object]:
    validate_grid(grid)
    counts = Counter(tile for row in grid for tile in row)
    errors = []
    warnings = []
    pellet_count = sum(counts[tile] for tile in PELLET_TILES)
    if pellet_count != 192:
        errors.append(f"maze has {pellet_count} collectible pellets; runtime round counter expects 192")
    if counts[POWER_PELLET_TILE] != 4:
        errors.append(f"maze has {counts[POWER_PELLET_TILE]} visible power pellets; runtime marker table expects 4")
    components = passable_components(grid)
    if len(components) > 2 or (len(components) == 2 and components[1] > 6):
        errors.append(f"passable maze is unexpectedly disconnected: component sizes {components}")
    elif len(components) == 2:
        warnings.append("six-tile ghost-house interior is intentionally separate from the main path")
    minimum = 0
    for row in grid:
        cursor = 0
        while cursor < COLUMNS:
            length = 1
            while cursor + length < COLUMNS and length < 4 and row[cursor + length] == row[cursor]:
                length += 1
            minimum += 1
            cursor += length
    if minimum > RLE_SIZE:
        errors.append(f"maze needs {minimum} RLE bytes; expanded layout allows {RLE_SIZE}")
    return {
        "errors": errors,
        "warnings": warnings,
        "pellets": pellet_count,
        "power_pellets": counts[POWER_PELLET_TILE],
        "components": components,
        "minimum_rle_bytes": minimum,
        "export_rle_bytes": RLE_SIZE,
    }


class MazeDocument:
    def __init__(self, document: dict[str, object], path: Path, original: dict[str, object] | None = None) -> None:
        self.grid = copy.deepcopy(document["decoded_rows"])
        validate_grid(self.grid)
        self.original = copy.deepcopy((original or document)["decoded_rows"])
        validate_grid(self.original)
        self.path = path
        self.saved = copy.deepcopy(self.grid)
        self.undo_stack: list[list[list[int]]] = []
        self.redo_stack: list[list[list[int]]] = []

    @property
    def dirty(self) -> bool:
        return self.grid != self.saved

    def changed(self, row: int, column: int) -> bool:
        return self.grid[row][column] != self.original[row][column]

    def paint(self, row: int, column: int, tile: int) -> bool:
        if not 0 <= row < ROWS or not 0 <= column < COLUMNS or not 0 <= tile <= 0x3F:
            raise ValueError("Paint location or tile is outside the maze format")
        if self.grid[row][column] == tile:
            return False
        self.undo_stack.append(copy.deepcopy(self.grid))
        self.redo_stack.clear()
        self.grid[row][column] = tile
        return True

    def undo(self) -> bool:
        if not self.undo_stack:
            return False
        self.redo_stack.append(copy.deepcopy(self.grid))
        self.grid = self.undo_stack.pop()
        return True

    def redo(self) -> bool:
        if not self.redo_stack:
            return False
        self.undo_stack.append(copy.deepcopy(self.grid))
        self.grid = self.redo_stack.pop()
        return True

    def restore_original(self) -> None:
        if self.grid != self.original:
            self.undo_stack.append(copy.deepcopy(self.grid))
            self.redo_stack.clear()
            self.grid = copy.deepcopy(self.original)

    def save(self, path: Path | None = None) -> Path:
        report = inspect_grid(self.grid)
        if report["errors"]:
            raise ValueError("Cannot export maze:\n" + "\n".join(report["errors"]))
        destination = path or self.path
        temporary = destination.with_name(destination.name + ".tmp")
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary.write_text(json.dumps(document_from_grid(self.grid), indent=2) + "\n", encoding="utf-8")
        temporary.replace(destination)
        self.path = destination
        self.saved = copy.deepcopy(self.grid)
        return destination


def load_document(path: Path) -> dict[str, object]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("format") != "maze_rle":
        raise ValueError("Maze Studio requires a maze_rle document")
    validate_grid(document["decoded_rows"])
    return document
