from __future__ import annotations

import copy
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from sound_studio_model import StudioDocument, validate_collection


def collection() -> dict[str, object]:
    streams = []
    for slot in range(16):
        streams.append({
            "path": f"audio/slot{slot:02x}_test.bin",
            "stream": {
                "format": "sound_stream",
                "prologue": [1, 0x9F, 0x7F, 0x28],
                "commands": [
                    {"kind": "note", "value": 0x01, "duration": 8},
                    {"kind": "control", "opcode": 0xF0},
                ],
                "trailing_bytes": [],
            },
        })
    return {"format": "sound_stream_collection", "streams": streams}


class SoundStudioModelTests(unittest.TestCase):
    def test_note_edit_is_reversible_against_original(self) -> None:
        source = collection()
        model = StudioDocument(source, Path("sounds.json"), copy.deepcopy(source))
        model.update_note(4, 0, "C4", 12)
        self.assertTrue(model.slot_changed(4))
        self.assertTrue(model.dirty)
        self.assertEqual(model.summary(4)["frames"], 12)
        self.assertEqual(model.original_command_description(4, 0), "A3 ($01)")
        model.reset_slot_to_original(4)
        self.assertFalse(model.slot_changed(4))

    def test_insert_and_delete_only_touch_selected_slot(self) -> None:
        model = StudioDocument(collection(), Path("sounds.json"))
        original_slot = copy.deepcopy(model.item(3))
        model.insert_note(2, 1, "G#4", 5)
        self.assertEqual(len(model.commands(2)), 3)
        model.delete_note(2, 1)
        self.assertEqual(model.item(3), original_slot)

    def test_save_round_trips_and_clears_dirty_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sound_streams.json"
            model = StudioDocument(collection(), path)
            model.update_note(0, 0, "A3", 9)
            model.save()
            self.assertFalse(model.dirty)
            reloaded = StudioDocument(__import__("json").loads(path.read_text()), path)
            self.assertEqual(reloaded.commands(0)[0]["duration"], 9)

    def test_validation_rejects_reordered_slots(self) -> None:
        document = collection()
        document["streams"][0], document["streams"][1] = document["streams"][1], document["streams"][0]
        with self.assertRaisesRegex(ValueError, "order mismatch"):
            validate_collection(document)

    def test_invalid_edit_does_not_mutate_document(self) -> None:
        model = StudioDocument(collection(), Path("sounds.json"))
        before = copy.deepcopy(model.document)
        with self.assertRaisesRegex(ValueError, "1..255"):
            model.update_note(0, 0, "C4", 0)
        self.assertEqual(model.document, before)


if __name__ == "__main__":
    unittest.main()
