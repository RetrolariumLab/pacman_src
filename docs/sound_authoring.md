# Sound Authoring Core

Milestone 15 provides command-line authoring primitives beneath the planned
local Sound Studio. It does not change the preservation build or pretend that
the original sequencer is general MIDI.

## Expanded-bank allocation

The expanded variant reserves `$84AF..$A4AE` as an 8 KiB sound region. All 16
streams are encoded at their actual lengths, their little-endian pointers are
rebuilt at `$848F`, and unused capacity is filled with `$FF`. The build rejects
a missing/reordered slot, malformed bytecode, an address overflow, or a total
larger than 8192 bytes.

This replaces milestone 14's same-size-per-stream restriction while retaining
a stable outer ROM layout for review. `make verify-expanded` checks the complete
padded region, not merely its used prefix.

## Musical model

The game's note byte uses its high nibble for one of twelve base periods and
its low nibble for an octave right shift. The authoring model exposes reversible
MIDI numbers and names such as `A3` and `G#4`; durations remain integer NTSC
frames. Inspect a slot with:

```text
make describe-sound SOUND_SLOT=4
```

## MIDI import

The dependency-free importer accepts Standard MIDI files with PPQ timing,
tempo changes, and one selected channel. The source must be monophonic and
contiguous: polyphony, SMPTE timing, out-of-range pitches, and rests are
reported as errors because the current Pac-Man stream model cannot represent
them faithfully.

```text
make import-midi MIDI_FILE=melody.mid SOUND_SLOT=4 MIDI_TRACK=0 MIDI_CHANNEL=0
```

The default output is the ignored `hacks/local/sound_streams.midi.json`; the
working `hacks/local/sound_streams.json` is never overwritten implicitly.
Review or rename the imported file before using it as the expanded build input.

## WAV preview

```text
make preview-sound SOUND_SLOT=4
```

This writes ignored `tmp/sound_preview.wav`. The renderer uses the NTSC 2A03
CPU frequency, the game's twelve base timer periods, frame durations, and the
pulse duty/volume encoded in the stream prologue. It is deterministic and
useful for note editing, but is not a cycle-accurate APU emulator: arbitration,
envelopes, sweeps, triangle/noise behavior, and frame-counter timing still
require FCEUX validation.
