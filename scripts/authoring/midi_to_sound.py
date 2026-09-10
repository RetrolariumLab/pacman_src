#!/usr/bin/env python3
"""Import a monophonic Standard MIDI track into one Pac-Man sound slot."""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path

from sound_authoring import NTSC_FRAME_RATE, midi_to_sound_byte


@dataclass(frozen=True)
class MidiNote:
    note: int
    start_tick: int
    end_tick: int


def read_varlen(data: bytes, cursor: int) -> tuple[int, int]:
    value = 0
    for _ in range(4):
        if cursor >= len(data):
            raise ValueError("Truncated MIDI variable-length value")
        byte = data[cursor]
        cursor += 1
        value = value << 7 | byte & 0x7F
        if byte < 0x80:
            return value, cursor
    raise ValueError("MIDI variable-length value exceeds four bytes")


def parse_track(data: bytes, channel: int) -> tuple[list[MidiNote], list[tuple[int, int]]]:
    cursor = 0
    tick = 0
    running_status: int | None = None
    active: dict[int, int] = {}
    notes: list[MidiNote] = []
    tempos: list[tuple[int, int]] = []
    while cursor < len(data):
        delta, cursor = read_varlen(data, cursor)
        tick += delta
        if cursor >= len(data):
            raise ValueError("Truncated MIDI event")
        status = data[cursor]
        if status < 0x80:
            if running_status is None:
                raise ValueError("MIDI running status has no previous channel event")
            status = running_status
        else:
            cursor += 1
            if status < 0xF0:
                running_status = status
        if status == 0xFF:
            if cursor >= len(data):
                raise ValueError("Truncated MIDI meta event")
            kind = data[cursor]
            cursor += 1
            length, cursor = read_varlen(data, cursor)
            payload = data[cursor:cursor + length]
            if len(payload) != length:
                raise ValueError("Truncated MIDI meta payload")
            cursor += length
            if kind == 0x51 and length == 3:
                tempos.append((tick, int.from_bytes(payload, "big")))
            if kind == 0x2F:
                break
            continue
        if status in (0xF0, 0xF7):
            length, cursor = read_varlen(data, cursor)
            cursor += length
            continue
        event = status & 0xF0
        event_channel = status & 0x0F
        length = 1 if event in (0xC0, 0xD0) else 2
        payload = data[cursor:cursor + length]
        if len(payload) != length:
            raise ValueError("Truncated MIDI channel event")
        cursor += length
        if event_channel != channel or event not in (0x80, 0x90):
            continue
        note = payload[0]
        is_on = event == 0x90 and payload[1] != 0
        if is_on:
            if active:
                raise ValueError("MIDI import requires a monophonic track")
            active[note] = tick
        elif note in active:
            notes.append(MidiNote(note, active.pop(note), tick))
    if active:
        raise ValueError("MIDI note remains active at end of track")
    return notes, tempos


def parse_midi(data: bytes, track_index: int, channel: int) -> tuple[int, list[MidiNote], list[tuple[int, int]]]:
    if data[:4] != b"MThd" or len(data) < 14:
        raise ValueError("Not a Standard MIDI file")
    header_size = int.from_bytes(data[4:8], "big")
    if header_size < 6:
        raise ValueError("Invalid MIDI header length")
    track_count = int.from_bytes(data[10:12], "big")
    division = int.from_bytes(data[12:14], "big")
    if division & 0x8000:
        raise ValueError("SMPTE MIDI timing is not supported")
    if not 0 <= track_index < track_count:
        raise ValueError("MIDI track index is out of range")
    cursor = 8 + header_size
    selected = None
    all_tempos: list[tuple[int, int]] = []
    for index in range(track_count):
        if data[cursor:cursor + 4] != b"MTrk":
            raise ValueError("Missing MIDI track chunk")
        length = int.from_bytes(data[cursor + 4:cursor + 8], "big")
        payload = data[cursor + 8:cursor + 8 + length]
        if len(payload) != length:
            raise ValueError("Truncated MIDI track")
        notes, tempos = parse_track(payload, channel)
        all_tempos.extend(tempos)
        if index == track_index:
            selected = notes
        cursor += 8 + length
    return division, selected or [], sorted(all_tempos)


def tick_seconds(tick: int, division: int, tempos: list[tuple[int, int]]) -> float:
    elapsed = 0.0
    previous_tick = 0
    tempo = 500_000
    for change_tick, new_tempo in tempos:
        if change_tick >= tick:
            break
        elapsed += (change_tick - previous_tick) * tempo / (division * 1_000_000)
        previous_tick = change_tick
        tempo = new_tempo
    return elapsed + (tick - previous_tick) * tempo / (division * 1_000_000)


def import_commands(data: bytes, track: int, channel: int) -> list[dict[str, int | str]]:
    division, notes, tempos = parse_midi(data, track, channel)
    if not notes:
        raise ValueError("Selected MIDI track contains no notes")
    commands: list[dict[str, int | str]] = []
    previous_end = notes[0].start_tick
    for note in notes:
        if note.start_tick != previous_end:
            raise ValueError("MIDI rests are not representable by the current sound engine")
        frames = max(1, round(
            (tick_seconds(note.end_tick, division, tempos)
             - tick_seconds(note.start_tick, division, tempos)) * NTSC_FRAME_RATE
        ))
        value = midi_to_sound_byte(note.note)
        while frames:
            duration = min(frames, 255)
            commands.append({"kind": "note", "value": value, "duration": duration})
            frames -= duration
        previous_end = note.end_tick
    commands.append({"kind": "control", "opcode": 0xF0})
    return commands


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--midi", required=True, type=Path)
    parser.add_argument("--sound-json", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--slot", required=True, type=lambda value: int(value, 0))
    parser.add_argument("--track", type=int, default=0)
    parser.add_argument("--channel", type=int, default=0)
    args = parser.parse_args()
    if not 0 <= args.slot < 16 or not 0 <= args.channel < 16:
        parser.error("slot and channel must be in 0..15")
    document = json.loads(args.sound_json.read_text(encoding="utf-8"))
    stream = document["streams"][args.slot]["stream"]
    stream["commands"] = import_commands(args.midi.read_bytes(), args.track, args.channel)
    stream["trailing_bytes"] = []
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    print(f"[OK] Imported MIDI track {args.track} into sound slot {args.slot:02X}: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
