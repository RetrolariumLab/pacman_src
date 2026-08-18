#!/usr/bin/env python3
"""Musical authoring primitives for Pac-Man sound bytecode."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


NTSC_FRAME_RATE = 60.0988
BASE_MIDI_NOTE = 45  # A2, matching period $03F9 in the game's note table.
NOTE_NAMES = ("A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#")
NAME_TO_PITCH_CLASS = {
    "C": 0, "C#": 1, "DB": 1, "D": 2, "D#": 3, "EB": 3,
    "E": 4, "F": 5, "F#": 6, "GB": 6, "G": 7, "G#": 8,
    "AB": 8, "A": 9, "A#": 10, "BB": 10, "B": 11,
}


def sound_byte_to_midi(value: int) -> int:
    if not 0 <= value < 0xC0:
        raise ValueError("Sound note byte must be in $00..$BF")
    return BASE_MIDI_NOTE + (value >> 4) + 12 * (value & 0x0F)


def midi_to_sound_byte(note: int) -> int:
    delta = note - BASE_MIDI_NOTE
    if not 0 <= delta <= 11 + 12 * 15:
        raise ValueError("MIDI note is outside the Pac-Man sequencer range")
    octave_shift, semitone = divmod(delta, 12)
    return semitone << 4 | octave_shift


def midi_note_name(note: int) -> str:
    names = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")
    return f"{names[note % 12]}{note // 12 - 1}"


def note_name_to_midi(name: str) -> int:
    match = re.fullmatch(r"\s*([A-Ga-g])([#bB]?)(-?\d+)\s*", name)
    if match is None:
        raise ValueError(f"Invalid musical note name: {name}")
    pitch = NAME_TO_PITCH_CLASS[match.group(1).upper() + match.group(2).upper()]
    return (int(match.group(3)) + 1) * 12 + pitch


def frames_to_beats(frames: int, tempo_bpm: float, frame_rate: float = NTSC_FRAME_RATE) -> float:
    if frames < 0 or tempo_bpm <= 0 or frame_rate <= 0:
        raise ValueError("Frames must be nonnegative and rates must be positive")
    return frames * tempo_bpm / (60.0 * frame_rate)


def beats_to_frames(beats: float, tempo_bpm: float, frame_rate: float = NTSC_FRAME_RATE) -> int:
    if beats < 0 or tempo_bpm <= 0 or frame_rate <= 0:
        raise ValueError("Beats must be nonnegative and rates must be positive")
    return round(beats * 60.0 * frame_rate / tempo_bpm)


def describe_slot(document: dict[str, object], slot: int) -> dict[str, object]:
    item = document["streams"][slot]
    commands = []
    for command in item["stream"]["commands"]:
        described = dict(command)
        if command["kind"] == "note":
            midi = sound_byte_to_midi(int(command["value"]))
            described.update({"midi_note": midi, "note": midi_note_name(midi)})
        commands.append(described)
    return {"slot": slot, "path": item["path"], "commands": commands}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--slot", required=True, type=lambda value: int(value, 0))
    args = parser.parse_args()
    if not 0 <= args.slot < 16:
        parser.error("--slot must be in 0..15")
    document = json.loads(args.input.read_text(encoding="utf-8"))
    print(json.dumps(describe_slot(document, args.slot), indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
