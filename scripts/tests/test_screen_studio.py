import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

from screen_assets import (  # noqa: E402
    BUNDLE_SIZE,
    EXPANDED_BASE,
    OFFSETS,
    ScreenDocument,
    decode_screen_collection,
    encode_screen_collection,
    parse_tile_text,
    encode_game_text,
    tile_text,
    validate_screen_collection,
)


class ScreenStudioTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rom = (ROOT / "Pac-Man (J) (V1.0) [!].nes").read_bytes()
        cls.document = decode_screen_collection(cls.rom)

    def test_original_screens_encode_into_fixed_bundle(self):
        encoded = encode_screen_collection(self.document)
        self.assertEqual(len(encoded), BUNDLE_SIZE)
        self.assertEqual(encoded[:138], bytes(self.document["title_logo"]["tiles"]))

    def test_attract_pointers_follow_variable_packets(self):
        document = copy.deepcopy(self.document)
        document["attract_packets"][0]["bytes"].append(0x41)
        encoded = encode_screen_collection(document)
        pointer = encoded[OFFSETS["attract_pointers"]] | encoded[OFFSETS["attract_pointers"] + 1] << 8
        second = encoded[OFFSETS["attract_pointers"] + 2] | encoded[OFFSETS["attract_pointers"] + 3] << 8
        self.assertEqual(pointer, EXPANDED_BASE + OFFSETS["attract_packets"])
        self.assertGreater(second, pointer)

    def test_tile_text_notation_roundtrips(self):
        values = [0x41, 0x00, 0xC0, 0x7E]
        self.assertEqual(parse_tile_text(tile_text(values)), values)

    def test_engine_layout_and_code_catalogue_are_guarded(self):
        document = copy.deepcopy(self.document)
        document["title_logo"]["width"] = 24
        with self.assertRaisesRegex(ValueError, "23x6"):
            validate_screen_collection(document)
        document = copy.deepcopy(self.document)
        document["read_only_code_tables"][0]["address"] += 1
        with self.assertRaisesRegex(ValueError, "Read-only"):
            validate_screen_collection(document)

    def test_invalid_packet_and_oversized_region_are_rejected(self):
        document = copy.deepcopy(self.document)
        document["title_packets"][0]["address"] = 0x1000
        with self.assertRaisesRegex(ValueError, "outside PPU"):
            encode_screen_collection(document)
        document = copy.deepcopy(self.document)
        document["title_packets"][0]["bytes"] = [0x20] * 300
        with self.assertRaisesRegex(ValueError, "256-byte"):
            encode_screen_collection(document)

    def test_document_save_is_valid_json_and_clears_dirty_state(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "screens.json"
            model = ScreenDocument(self.document, path)
            tiles = list(model.document["title_logo"]["tiles"])
            tiles[0] ^= 1
            model.set_tiles("title_logo", tiles)
            self.assertTrue(model.dirty)
            model.save()
            self.assertFalse(model.dirty)
            self.assertEqual(json.loads(path.read_text(encoding="utf-8"))["format"],
                             "pacman_screen_collection")

    def test_title_palette_attributes_are_editable(self):
        with tempfile.TemporaryDirectory() as directory:
            model = ScreenDocument(self.document, Path(directory) / "screens.json")
            attributes = list(model.document["title_attributes"]["bytes"])
            attributes[0] ^= 0x40
            model.set_tiles("title_attributes", attributes)
            self.assertEqual(model.document["title_attributes"]["bytes"], attributes)

    def test_english_messages_map_lowercase_to_game_font(self):
        with tempfile.TemporaryDirectory() as directory:
            model = ScreenDocument(self.document, Path(directory) / "screens.json")
            model.set_message("pause", "hello")
            self.assertEqual(model.document["pause_tiles"][:5], list(b"HELLO"))
            self.assertEqual(model.get_message("pause"), "HELLO")

    def test_every_catalogued_original_message_decodes(self):
        with tempfile.TemporaryDirectory() as directory:
            model = ScreenDocument(self.document, Path(directory) / "screens.json")
            from screen_assets import TEXT_MESSAGES
            self.assertTrue(all(model.get_message(item["key"]) for item in TEXT_MESSAGES))

    def test_english_messages_reject_unavailable_characters_and_overflow(self):
        with self.assertRaisesRegex(ValueError, "Unsupported"):
            encode_game_text("PAC@MAN", 8)
        with self.assertRaisesRegex(ValueError, "allows 5"):
            encode_game_text("TOO LONG", 5)


if __name__ == "__main__":
    unittest.main()
