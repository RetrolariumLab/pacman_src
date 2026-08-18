# Sound Authoring Core

Milestone 15 provides command-line authoring primitives beneath the planned
local Sound Studio. It does not change the preservation build or pretend that
the original sequencer is general MIDI.

Milestone 16 adds the dependency-free local GUI over those primitives. Initialize
the ignored editable assets once, then launch it with:

```text
make init-expanded-assets
make sound-studio
```

The studio provides a 16-slot browser, scrollable piano roll, exact command
inspector, note insertion/editing/removal, comparison against the original
extracted streams, per-slot restore, WAV playback, guarded MIDI import, atomic
JSON save, and explicit expanded-ROM build and FCEUX launch buttons. It uses
Python's bundled Tkinter and adds no package dependency.

The editable JSON remains the source of truth. The GUI never saves, builds, or
launches implicitly. Closing with unsaved changes prompts before discarding;
building is refused until edits are saved. `Save As` supports experiments without
overwriting `hacks/local/sound_streams.json`.

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

The GUI uses the same importer and presents the limitation before replacing a
slot: the format is monophonic and contiguous, and MIDI velocity, instruments,
polyphony, and rests cannot be preserved. Unsupported input remains an error.

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

On Windows, the Sound Studio plays this WAV asynchronously through the standard
system API. On other platforms it still writes the preview file but does not
claim to provide a bundled audio player.
