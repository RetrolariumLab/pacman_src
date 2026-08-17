from __future__ import annotations

import copy
import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from data_formats import (  # noqa: E402
    decode_actors,
    decode_intermission,
    decode_maze,
    decode_ppu,
    decode_sound,
    decode_sound_channel_record,
    decode_stage,
    encode_actors,
    encode_intermission,
    encode_maze,
    encode_ppu,
    encode_sound,
    encode_sound_channel_record,
    encode_stage,
)


class DataFormatTests(unittest.TestCase):
    def test_stage_roundtrip_and_record_count_validation(self) -> None:
        data = bytes(index & 0xFF for index in range(310))
        document = decode_stage(data)
        self.assertEqual(encode_stage(document), data)
        broken = copy.deepcopy(document)
        broken["stage_profiles"].pop()
        with self.assertRaisesRegex(ValueError, "23"):
            encode_stage(broken)

    def test_maze_preserves_token_boundaries(self) -> None:
        data = bytes((0x41, 0x01))
        document = decode_maze(data, rows=1, columns=3)
        self.assertEqual(document["decoded_rows"], [[1, 1, 1]])
        self.assertEqual(encode_maze(document), data)

    def test_sound_preserves_commands_and_trailing_bytes(self) -> None:
        data = bytes((1, 2, 3, 4, 0x31, 6, 0xC0, 9, 0xF5, 0x18, 0xF0, 0xAA, 0xBB))
        document = decode_sound(data)
        self.assertEqual(document["trailing_bytes"], [0xAA, 0xBB])
        self.assertEqual(encode_sound(document), data)

    def test_sound_channel_record_has_named_eight_byte_layout(self) -> None:
        data = bytes.fromhex("0530408A0378F00C")
        document = decode_sound_channel_record(data)
        self.assertEqual(document["stream_cursor"], 0xF078)
        self.assertEqual(encode_sound_channel_record(document), data)

    def test_ppu_roundtrip_and_reserved_payload_bytes(self) -> None:
        data = bytes.fromhex("3F1511002241504155534500FF")
        document = decode_ppu(data)
        self.assertEqual(encode_ppu(document), data)
        document["commands"][0]["payload"] = [0]
        with self.assertRaisesRegex(ValueError, "cannot contain"):
            encode_ppu(document)
        compact = bytes.fromhex("3F1511FF")
        self.assertEqual(encode_ppu(decode_ppu(compact)), compact)

    def test_actor_tables_preserve_all_modes(self) -> None:
        data = bytes(index & 0xFF for index in range(624))
        self.assertEqual(encode_actors(decode_actors(data)), data)

    def test_intermission_word_and_byte_tables_roundtrip(self) -> None:
        regions = [
            {"name": "handlers", "kind": "words", "count": 2},
            {"name": "tiles", "kind": "bytes", "count": 3},
        ]
        data = bytes.fromhex("69E76FE7040506")
        self.assertEqual(encode_intermission(decode_intermission(data, regions)), data)


if __name__ == "__main__":
    unittest.main()
