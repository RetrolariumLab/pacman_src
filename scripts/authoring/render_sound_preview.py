#!/usr/bin/env python3
"""Render a deterministic pulse-wave WAV preview of one Pac-Man sound slot."""

from __future__ import annotations

import argparse
import json
import math
import struct
import wave
from pathlib import Path

from sound_authoring import NTSC_FRAME_RATE


CPU_FREQUENCY = 1_789_773.0
BASE_PERIODS = (0x3F9, 0x3C0, 0x38A, 0x357, 0x327, 0x2FA,
                0x2CF, 0x2A7, 0x281, 0x25D, 0x23B, 0x21B)
DUTY_CYCLES = (0.125, 0.25, 0.5, 0.75)


def note_frequency(value: int) -> float:
    if not 0 <= value < 0xC0:
        raise ValueError("Preview note byte must be in $00..$BF")
    period = BASE_PERIODS[value >> 4] >> (value & 0x0F)
    return CPU_FREQUENCY / (16.0 * (period + 1))


def render_stream(stream: dict[str, object], sample_rate: int = 44_100) -> bytes:
    if sample_rate <= 0:
        raise ValueError("Sample rate must be positive")
    register0 = int(stream["prologue"][1])
    duty = DUTY_CYCLES[(register0 >> 6) & 3]
    volume = (register0 & 0x0F) / 15.0
    current_frequency = 0.0
    phase = 0.0
    samples = bytearray()
    for command in stream["commands"]:
        kind = command["kind"]
        if kind == "control":
            opcode = int(command["opcode"])
            if opcode == 0xF6:
                register0 = int(command["operand"])
                duty = DUTY_CYCLES[(register0 >> 6) & 3]
                volume = (register0 & 0x0F) / 15.0
            if opcode == 0xF0 or opcode >= 0xF7:
                break
            continue
        if kind == "note":
            current_frequency = note_frequency(int(command["value"]))
        duration = int(command["duration"])
        count = round(duration * sample_rate / NTSC_FRAME_RATE)
        for _ in range(count):
            amplitude = volume if phase < duty else -volume
            samples.extend(struct.pack("<h", round(amplitude * 12_000)))
            if current_frequency:
                phase = math.fmod(phase + current_frequency / sample_rate, 1.0)
    return bytes(samples)


def write_wav(path: Path, pcm: bytes, sample_rate: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(sample_rate)
        output.writeframes(pcm)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sound-json", required=True, type=Path)
    parser.add_argument("--slot", required=True, type=lambda value: int(value, 0))
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--sample-rate", type=int, default=44_100)
    args = parser.parse_args()
    if not 0 <= args.slot < 16:
        parser.error("--slot must be in 0..15")
    document = json.loads(args.sound_json.read_text(encoding="utf-8"))
    pcm = render_stream(document["streams"][args.slot]["stream"], args.sample_rate)
    write_wav(args.output, pcm, args.sample_rate)
    print(f"[OK] Rendered slot {args.slot:02X} preview: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
