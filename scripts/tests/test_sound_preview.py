from __future__ import annotations

import sys
import tempfile
import unittest
import wave
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from render_sound_preview import note_frequency, render_stream, write_wav  # noqa: E402


class SoundPreviewTests(unittest.TestCase):
    def test_note_frequency_doubles_for_one_octave_shift(self) -> None:
        self.assertAlmostEqual(note_frequency(0x01), note_frequency(0x00) * 2, delta=0.3)

    def test_preview_duration_matches_frame_grid(self) -> None:
        stream = {
            "prologue": [1, 0x9F, 0x7F, 0x28],
            "commands": [
                {"kind": "note", "value": 0x01, "duration": 2},
                {"kind": "control", "opcode": 0xF0},
            ],
        }
        pcm = render_stream(stream, 6000)
        self.assertEqual(len(pcm), round(2 * 6000 / 60.0988) * 2)

    def test_wav_writer_emits_mono_pcm(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "preview.wav"
            write_wav(path, b"\x00\x00" * 10, 8000)
            with wave.open(str(path), "rb") as source:
                self.assertEqual(source.getnchannels(), 1)
                self.assertEqual(source.getsampwidth(), 2)
                self.assertEqual(source.getframerate(), 8000)
                self.assertEqual(source.getnframes(), 10)


if __name__ == "__main__":
    unittest.main()
