from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from data_formats import decode_maze, encode_maze
from maze_studio_model import MazeDocument, document_from_grid, inspect_grid, pack_grid


ASSET = Path(__file__).resolve().parents[2] / "assets/generated/maze/maze.rle"


class MazeStudioTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.original = decode_maze(ASSET.read_bytes())

    def test_original_grid_exports_to_fixed_layout_size(self) -> None:
        document = document_from_grid(self.original["decoded_rows"])
        encoded = encode_maze(document)
        self.assertEqual(len(encoded), 416)
        self.assertEqual(decode_maze(encoded)["decoded_rows"], self.original["decoded_rows"])

    def test_runs_never_cross_row_boundaries(self) -> None:
        tokens = pack_grid([[7] * 22 for _ in range(27)])
        cursor = 0
        for token in tokens:
            self.assertLessEqual((cursor % 22) + token["length"], 22)
            cursor += token["length"]
        self.assertEqual(cursor, 27 * 22)

    def test_paint_undo_redo_and_original_comparison(self) -> None:
        model = MazeDocument(self.original, Path("maze.json"), self.original)
        old = model.grid[0][0]
        self.assertTrue(model.paint(0, 0, old ^ 1))
        self.assertTrue(model.changed(0, 0))
        self.assertTrue(model.undo())
        self.assertFalse(model.changed(0, 0))
        self.assertTrue(model.redo())
        self.assertTrue(model.changed(0, 0))

    def test_runtime_sensitive_pellet_counts_are_enforced(self) -> None:
        grid = copy.deepcopy(self.original["decoded_rows"])
        pellet = next((r, c) for r, row in enumerate(grid) for c, tile in enumerate(row) if tile == 3)
        grid[pellet[0]][pellet[1]] = 7
        report = inspect_grid(grid)
        self.assertTrue(any("expects 192" in error for error in report["errors"]))

    def test_door_spawn_and_tunnel_assumptions_are_enforced(self) -> None:
        cases = (((11, 11), 7, "door"), ((20, 11), 0x10, "Pac-Man spawn"),
                 ((13, 0), 0x10, "tunnel endpoint"))
        for (row, column), tile, message in cases:
            with self.subTest(message=message):
                grid = copy.deepcopy(self.original["decoded_rows"])
                grid[row][column] = tile
                self.assertTrue(any(message in error for error in inspect_grid(grid)["errors"]))

    def test_save_is_atomic_and_round_trips(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "maze.json"
            model = MazeDocument(self.original, path, self.original)
            model.save()
            saved = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(saved["decoded_rows"], self.original["decoded_rows"])
            self.assertFalse(model.dirty)
            self.assertFalse(path.with_name(path.name + ".tmp").exists())


if __name__ == "__main__":
    unittest.main()
