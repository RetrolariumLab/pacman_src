from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from prepare_expanded_assets import encode_sound_collection  # noqa: E402


def collection(extra_notes: int = 0) -> dict[str, object]:
    streams = []
    for slot in range(16):
        commands = [{"kind": "note", "value": 0x01, "duration": 1}] * (
            extra_notes if slot == 0 else 0
        )
        commands.append({"kind": "control", "opcode": 0xF0})
        streams.append({
            "path": f"audio/slot{slot:02x}_test.bin",
            "stream": {
                "format": "sound_stream",
                "prologue": [1, 2, 3, 4],
                "commands": commands,
                "trailing_bytes": [],
            },
        })
    return {"format": "sound_stream_collection", "streams": streams}


class SoundAuthoringTests(unittest.TestCase):
    def test_variable_length_streams_recalculate_following_pointers(self) -> None:
        pointers, bundle, used = encode_sound_collection(collection(extra_notes=3), 0x9000, 256)
        first = pointers[0] | pointers[1] << 8
        second = pointers[2] | pointers[3] << 8
        self.assertEqual(first, 0x9000)
        self.assertEqual(second, 0x9000 + 4 + 3 * 2 + 1)
        self.assertEqual(len(bundle), 256)
        self.assertEqual(bundle[used:], b"\xFF" * (256 - used))

    def test_sound_budget_overflow_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "exceed 80-byte budget"):
            encode_sound_collection(collection(extra_notes=20), 0x9000, 80)

    def test_slot_order_is_rejected(self) -> None:
        document = collection()
        document["streams"][0]["path"] = "audio/slot01_wrong.bin"
        with self.assertRaisesRegex(ValueError, "order mismatch at slot 00"):
            encode_sound_collection(document)


if __name__ == "__main__":
    unittest.main()
