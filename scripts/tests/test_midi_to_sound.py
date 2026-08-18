from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from midi_to_sound import import_commands  # noqa: E402


def midi(track: bytes, division: int = 96) -> bytes:
    header = b"MThd" + (6).to_bytes(4, "big") + b"\x00\x00\x00\x01" + division.to_bytes(2, "big")
    return header + b"MTrk" + len(track).to_bytes(4, "big") + track


class MidiImportTests(unittest.TestCase):
    def test_monophonic_track_imports_notes_and_frames(self) -> None:
        track = bytes((0, 0x90, 45, 100, 96, 0x80, 45, 0, 0, 0x90, 57, 100,
                       96, 0x80, 57, 0, 0, 0xFF, 0x2F, 0))
        commands = import_commands(midi(track), 0, 0)
        self.assertEqual(commands[0], {"kind": "note", "value": 0x00, "duration": 30})
        self.assertEqual(commands[1], {"kind": "note", "value": 0x01, "duration": 30})
        self.assertEqual(commands[-1], {"kind": "control", "opcode": 0xF0})

    def test_polyphony_is_rejected(self) -> None:
        track = bytes((0, 0x90, 45, 100, 0, 0x90, 48, 100, 0, 0xFF, 0x2F, 0))
        with self.assertRaisesRegex(ValueError, "monophonic"):
            import_commands(midi(track), 0, 0)

    def test_rests_are_rejected_explicitly(self) -> None:
        track = bytes((0, 0x90, 45, 100, 48, 0x80, 45, 0, 48, 0x90, 57, 100,
                       48, 0x80, 57, 0, 0, 0xFF, 0x2F, 0))
        with self.assertRaisesRegex(ValueError, "rests are not representable"):
            import_commands(midi(track), 0, 0)


if __name__ == "__main__":
    unittest.main()
