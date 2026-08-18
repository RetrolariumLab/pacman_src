from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sound_authoring import (  # noqa: E402
    beats_to_frames,
    frames_to_beats,
    midi_note_name,
    midi_to_sound_byte,
    note_name_to_midi,
    sound_byte_to_midi,
)


class SoundMusicModelTests(unittest.TestCase):
    def test_known_game_notes_have_stable_names(self) -> None:
        self.assertEqual(midi_note_name(sound_byte_to_midi(0x00)), "A2")
        self.assertEqual(midi_note_name(sound_byte_to_midi(0x01)), "A3")
        self.assertEqual(midi_note_name(sound_byte_to_midi(0xB1)), "G#4")

    def test_note_names_and_sound_bytes_roundtrip(self) -> None:
        for name in ("A2", "C3", "F#4", "G#6"):
            midi = note_name_to_midi(name)
            self.assertEqual(sound_byte_to_midi(midi_to_sound_byte(midi)), midi)
        self.assertEqual(note_name_to_midi("Bb3"), note_name_to_midi("A#3"))

    def test_frame_and_beat_conversion_roundtrip(self) -> None:
        frames = beats_to_frames(1.0, 120.0)
        self.assertEqual(frames, 30)
        self.assertAlmostEqual(frames_to_beats(frames, 120.0), 1.0, places=2)

    def test_out_of_range_notes_are_rejected(self) -> None:
        with self.assertRaises(ValueError):
            midi_to_sound_byte(44)
        with self.assertRaises(ValueError):
            sound_byte_to_midi(0xC0)


if __name__ == "__main__":
    unittest.main()
