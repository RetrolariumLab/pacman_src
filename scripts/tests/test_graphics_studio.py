from __future__ import annotations

import copy
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from graphics_studio_model import (
    ActorDocument, GraphicsDocument, decode_chr, encode_chr, load_actor_document, load_actor_tables,
    metasprite_pixels, transform_tile, validate_palette,
)
from build_expanded import validate_chr_input
from palette_assets import (
    ENCODED_SIZE, PaletteDocument, decode_palette_collection, encode_palette_collection,
    load_palette_document,
)


ROOT = Path(__file__).resolve().parents[2]
CHR = ROOT / "assets/generated/chr/pacman.chr"
ROM = ROOT / "Pac-Man (J) (V1.0) [!].nes"


class GraphicsStudioTests(unittest.TestCase):
    def test_chr_round_trip_is_byte_identical(self) -> None:
        source = CHR.read_bytes()
        self.assertEqual(encode_chr(decode_chr(source)), source)

    def test_pixel_edit_undo_and_atomic_save(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "edited.chr"
            model = GraphicsDocument(CHR.read_bytes(), path)
            old = model.tiles[256][0][0]
            model.paint(256, 0, 0, old ^ 1)
            self.assertTrue(model.changed(256))
            self.assertTrue(model.undo())
            self.assertFalse(model.changed(256))
            model.save()
            self.assertEqual(path.stat().st_size, 8192)

    def test_complete_brush_stroke_uses_one_undo_entry(self) -> None:
        model = GraphicsDocument(CHR.read_bytes(), Path("ignored.chr"))
        before = copy.deepcopy(model.tiles[0])
        model.begin_stroke(0)
        model.paint(0, 0, 0, model.tiles[0][0][0] ^ 1)
        model.paint(0, 0, 1, model.tiles[0][0][1] ^ 1)
        model.end_stroke()
        self.assertEqual(len(model.undo_stack), 1)
        self.assertTrue(model.undo())
        self.assertEqual(model.tiles[0], before)

    def test_oam_flip_bits_transform_pixels(self) -> None:
        tile = [[(row * 8 + column) % 4 for column in range(8)] for row in range(8)]
        self.assertEqual(transform_tile(tile, 0x40)[0], list(reversed(tile[0])))
        self.assertEqual(transform_tile(tile, 0x80)[0], tile[-1])
        with self.assertRaisesRegex(ValueError, "Unsupported"):
            transform_tile(tile, 0x04)

    def test_original_actor_tables_render_all_frames(self) -> None:
        tiles = decode_chr(CHR.read_bytes())
        actors = load_actor_tables(ROM.read_bytes())
        for alternate, count in ((False, 64), (True, 13)):
            for frame in range(count):
                image = metasprite_pixels(tiles, actors, frame, alternate)
                self.assertEqual((len(image), len(image[0])), (16, 16))

    def test_actor_mapping_edit_saves_fixed_round_trip_json(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "actors.json"
            model = ActorDocument(load_actor_tables(ROM.read_bytes()), path)
            model.set_quad(False, 0, 0, 0x7F, 0xE3)
            self.assertTrue(model.dirty)
            model.save()
            self.assertFalse(model.dirty)
            reloaded = load_actor_document(path, load_actor_tables(ROM.read_bytes()))
            self.assertEqual(reloaded.actors["standard_tile_quads"][0][0], 0x7F)
            self.assertEqual(reloaded.actors["standard_attribute_quads"][0][0], 0xE3)

    def test_actor_mapping_rejects_reserved_oam_bits(self) -> None:
        model = ActorDocument(load_actor_tables(ROM.read_bytes()), Path("ignored.json"))
        with self.assertRaisesRegex(ValueError, "only palette"):
            model.set_quad(False, 0, 0, 0, 0x04)

    def test_palette_rejects_non_nes_values(self) -> None:
        validate_palette([0x0F, 0x16, 0x29, 0x30])
        with self.assertRaisesRegex(ValueError, "four values"):
            validate_palette([0, 1, 2, 0x40])

    def test_palette_collection_round_trips_all_runtime_sections(self) -> None:
        document = decode_palette_collection(ROM.read_bytes())
        payload = encode_palette_collection(document)
        self.assertEqual(len(payload), ENCODED_SIZE)
        self.assertEqual(payload[:16], bytes(document["title_background"]))
        self.assertEqual(payload[16:48], bytes(document["attract_bg_spr"]))
        self.assertEqual(payload[48:80], bytes(document["round_gameplay"]))

    def test_palette_document_persists_nes_color_edits(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "palettes.json"
            model = PaletteDocument(decode_palette_collection(ROM.read_bytes()), path)
            model.set_color("round_gameplay", 17, 0x2A)
            model.set_color("round_gameplay", 16, 0x0C)
            model.set_frightened("active", 0x12)
            model.save()
            reloaded = load_palette_document(path, {})
            self.assertEqual(reloaded.document["round_gameplay"][17], 0x2A)
            self.assertEqual(reloaded.document["round_gameplay"][0], 0x0C)
            self.assertEqual(reloaded.document["frightened"]["active"], 0x12)
            with self.assertRaisesRegex(ValueError, "NES range"):
                reloaded.set_color("round_gameplay", 0, 0x40)

    def test_expanded_build_accepts_custom_fixed_size_chr(self) -> None:
        validate_chr_input(b"\x33" * 8192, CHR.read_bytes())
        with self.assertRaises(SystemExit):
            validate_chr_input(b"\x33" * 8191, CHR.read_bytes())


if __name__ == "__main__":
    unittest.main()
