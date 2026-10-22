# Sound Engine, Stream Commands, and Channel Arbitration

The sound engine lives in `src/audio/engine.asm`; the 16 original byte streams
are checksum-managed generated assets included by `src/audio/streams.asm`.
`sub_update_sound_engine` runs from NMI when demo mode does not suppress audio.

## Initialization and Ownership

`sub_init_sound_engine` installs pointers to the request page, channel records,
and stream-pointer table, enables all APU channels, selects five-step frame
counter mode with IRQ inhibited, then falls through to clearing state.
`sub_clear_sound_engine_state` zeros all 16 request bytes and only byte zero of
each channel record.

The request page at `$0600..$060F` has one byte per stream-table slot. Writers
set a nonzero byte to request/keep that stream active; the F0 stop command
clears both the request byte and its channel state. Some slots are companion
layers, not necessarily independent audible effects. Slots `$0608..$060E` are
internal house, release-counter, and intermission markers.

## Channel Record Layout

There are 16 eight-byte records beginning at `ram_sound_channel_state`: `$0625`
in v1.0 and `$0620` in every other revision (`src/memory/ram.inc`). The 128
bytes end at `$06A4` in v1.0 and `$069F` elsewhere:

| Offset  | Role                        |
| ------- | --------------------------- |
| `+0`    | arbitration/channel state   |
| `+1`    | APU register byte 0         |
| `+2`    | APU register byte 1         |
| `+3`    | computed timer low          |
| `+4`    | APU timer-high/control byte |
| `+5,+6` | little-endian stream cursor |
| `+7`    | remaining duration          |

A stream begins with a four-byte prologue, read when its request first turns the
record on: the channel state (`$01-$04` claims the first pulse, the second
pulse, the triangle or the noise register quad), then the values for `+1`, `+2`
and `+4`. Pitch decoding supplies `+3` and the low timer bits in `+4`.

## Frame Update and Arbitration

The update has two passes. The pre-pass clears four physical-channel claim
bytes, then scans logical records in slot order. State zero is inactive. States
at least five mark the corresponding physical-channel claim. States one through
four are admitted only if that claim is still free; an admitted state is
promoted into the five-through-eight range and its four register bytes are
immediately copied to the corresponding APU register quad. A duplicate low state
is skipped.

This scan order and promotion arithmetic implement arbitration. They must not be
described as generic mixing or reordered by apparent sound importance: the
stream state byte and earlier logical slot determine the observed winner.

The main pass then walks the same 16 logical slots. A zero request skips the
slot. When channel state is zero, the slot's stream pointer is installed and a
four-byte prologue is read. Otherwise its duration decrements; reaching zero
continues directly into byte decoding. Only the pre-pass writes APU quads.

## Stream Grammar

After the four-byte prologue, the cursor consumes these byte classes:

| Range      | Meaning                                                                                                    |
| ---------- | ---------------------------------------------------------------------------------------------------------- |
| `$00..$BF` | note: high nibble selects one of 12 base periods; low nibble right-shifts it, then a duration byte follows |
| `$C0..$EF` | duration-only command marker; the next byte becomes duration                                               |
| `$F0..$FF` | control opcode indexed through a 16-entry word table                                                       |

For note commands, the 11-bit period is split across record bytes `+3/+4` while
preserving the upper five bits of `+4`. Channel states at least five are reduced
by four after a note before the next duration is loaded, feeding the next
frame's arbitration cycle.

## Control Opcodes

All control handlers either stop the stream or consume one operand and continue
decoding in the same frame:

| Opcode   | Effect                                                                                      |
| -------- | ------------------------------------------------------------------------------------------- |
| `F0`     | clear request and channel state, advance to next logical slot                               |
| `F1 vv`  | record `+1` = (`+1` AND `$3F`) OR `vv`: bits 6-7, the pulse duty, when `vv` uses only those |
| `F2 vv`  | record `+1` = (`+1` AND `$CF`) OR `vv`: bits 4-5                                            |
| `F3 vv`  | record `+1` = (`+1` AND `$F0`) OR `vv`: the low nibble, the volume                          |
| `F4`     | replace record `+2`                                                                         |
| `F5`     | replace record `+4`                                                                         |
| `F6`     | replace record `+1`                                                                         |
| `F7..FF` | aliases of stop                                                                             |

Static decoding of every generated stream observes only F0, F2, F3, and F5; the
remaining handlers are retained dormant behavior, as recorded by resolved
`SND-002`. The fetch helper's redundant PHA/PLA is similarly retained and
tracked by resolved `CODE-004`.

## Stream Assets and Slot Table

`tbl_sfx_stream_ptr_table` maps request slots 00 through 0F to generated assets.
Confirmed callers cover READY's two layers, extra life, death, alternating
pellet slots, fruit, eaten ghost, and pause. The house/release/intermission
names are caller-based labels whose same-index stream activation is confirmed by
resolved entry `SND-001`.

The binary streams are regenerated by `make split` and verified through the
asset manifest. Editing the pointer table or decoder remains source work.

## Preservation Invariants

- Keep 16 request slots and 16 channel records at stride eight.
- Address the channel records through `ram_sound_channel_state`; its address
  differs between revisions.
- Preserve pre-pass scan order, claim mapping, carry-dependent promotion, and
  immediate four-register writes.
- Preserve stream prologue and byte-class grammar exactly.
- Keep opcode table entries and dormant handlers until stronger evidence permits
  removal.
- Run `make test-full` after changing request arbitration.
- Keep generated streams manifest-verified and the rebuilt ROM byte-identical.
