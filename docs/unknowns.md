# Reverse-Engineering Unknowns

## Purpose

This is the canonical backlog for behavior not yet established for the target
`Pac-Man (J) (V1.0) [!]` ROM. Source comments link here by stable ID. A
plausible interpretation is not enough to rename a symbol or remove an entry.

Statuses are `open`, `testing`, `resolved`, `unused`, and `confirmed bug`.
Confidence describes a hypothesis, not mechanically observed facts. Source
annotations use `!(OBS)`, `!(ASSUME)`, `!(WHY?)`, `!(UNKNOWN)`, `!(BUG?)`, and
`!(UNUSED)`.

## Open Registry

### RAM-001 — `ram_unknown_round_state`

- **Subsystem/address:** round setup; RAM `$00C0`
- **Status/confidence:** open; low
- **Established:** round initialization stores `Y = $04` after normalizing the
  four power-pellet slots. No other active symbolic reference is known.
- **Hypothesis:** state for absent/unreachable code, or a value consumed through
  an array or indirect access.
- **Evidence:** `src/game/round/setup.asm` after
  `bra_normalize_power_pellet_tiles`; `src/memory/ram.inc`.
- **Smallest experiment:** watch reads/writes of `$00C0` through setup, play,
  death, stage clear, and intermission; inspect computed RAM accesses covering it.

### RAM-002 — multiplexed `ram_shared_state_0..3`

- **Subsystem/address:** title, gameplay, and intermissions; RAM `$0087..$008A`
- **Status/confidence:** open; high for known contexts, incomplete overall
- **Established:** ownership changes with `ram_script`. In round runtime, byte 1
  is the frightened-ghost mask and bytes 2/3 its timer. In intermissions, byte
  0 is scene ID, byte 1 substate, and byte 2 a local countdown.
- **Hypothesis:** contextual aliases are appropriate, but no single global
  semantic name is correct.
- **Evidence:** `docs/ram_fields.md`, `docs/intermission_flow.md`,
  `src/game/round/runtime.asm`, and `src/game/intermission/setup.asm`.
- **Smallest experiment:** build a per-script access table and trace the four
  bytes at script transitions; alias only unambiguous lifetimes.

### RAM-003 - release-wave timer semantics

- **Subsystem/address:** ghost-house release; `ram_release_wave_timer`
- **Status/confidence:** open; medium
- **Established:** the field is seeded from stage parameters and participates in
  the round timer/release path, including the direction-reversal trigger around
  `sub_try_reverse_ghost_directions`.
- **Hypothesis:** it is a per-wave release timing value whose exact lifetime and
  relationship to scatter/chase timing remain incompletely separated.
- **Evidence:** `docs/ram_fields.md`, `src/game/round/runtime.asm`, and
  `src/game/scoring.asm`.
- **Experiment:** trace writes/reads with ghost slot, release state, phase, and
  frame across each house exit and the reversal trigger.
### SND-001 — SFX request-slot semantics

- **Subsystem/address:** sound request page; RAM `$0600..$060F`
- **Status/confidence:** open; medium
- **Established:** each byte selects a stream-table entry and is cleared when
  its channel stops. `$0601` and `$0605` are second channels of ready/pellet
  sounds. Names for `$0608..$060E` are provisional and based on callers.
- **Hypothesis:** some slots are multi-channel companions or internal layers,
  not independent effects.
- **Evidence:** `src/memory/ram.inc`, `tbl_sfx_stream_ptr_table`,
  `src/audio/streams.asm`, and `docs/sound_engine.md`.
- **Smallest experiment:** trace every slot write with frame, script, caller PC,
  selected stream, and claimed APU channel.


### DATA-003 - attract sprite strip and `$05F7`

- **Subsystem/status/confidence:** attract rendering; open; low
- **Established:** an optional packet tail copies a selected 16-byte strip; a
  legacy warning mentions an unexplained read involving RAM `$05F7`.
- **Hypothesis:** adjacent-state dependency, overrun, or a stale warning.
- **Evidence:** `src/game/title/attract_intro.asm`.
- **Experiment:** log substate, indexes, destination, and reads near `$05F7`.


### DATA-004 - copyright bytes before reset

- **Subsystem/status/confidence:** boot/data header; open; low
- **Established:** three strings occupy ROM before `vec_reset_entry`.
- **Hypothesis:** referenced display data or an unreferenced identification block.
- **Evidence:** `src/system/boot_and_frame.asm`.
- **Experiment:** inspect pointer-derived reads and use a ROM read breakpoint.

## Resolved Entries

Move entries here only after static analysis, runtime evidence, or a controlled
experiment supports the conclusion. Preserve ID, result, evidence, and the
change that closed it.

### CODE-003 - row-stride operand invariant

- **Subsystem/status:** tile coordinates; resolved
- **Result:** both row-stride helpers always receive `$0020`. Each helper has
  exactly one direct caller; immediately before each call, the caller writes
  `$20` and `$00` to `ram_ppu_row_delta_lo/hi`. No other symbolic writes to
  the pair exist in the source tree.
- **Evidence:** static whole-tree reference search and
  `src/rendering/tile_coordinates.asm`.
- **Resolution:** retain the original RAM-based operations for byte identity;
  source annotations now record the invariant as `!(OBS)`.

### CODE-004 - sound fetch stack round trip

- **Subsystem/status:** sound engine; resolved
- **Result:** the `PHA`/`PLA` round trip is functionally redundant. The routine
  increments the pointer stored in channel state but leaves
  `ram_sound_work_ptr` pointing at the fetched byte. Moving
  `LDA (ram_sound_work_ptr,X)` after the pointer stores would return the same
  byte with the same final A, X, Y, N, and Z state.
- **Evidence:** instruction-level analysis of
  `sub_fetch_stream_byte_and_advance_ptr` in `src/audio/engine.asm`.
- **Resolution:** retain the original sequence because changing its cycles,
  addresses, and bytes is outside the preservation target.
### SND-002 - inactive sound control opcodes

- **Subsystem/status:** sound decoder; resolved
- **Result:** grammar-aware decoding of all 16 extracted streams reaches their
  terminators using only `F0`, `F2`, `F3`, and `F5` as control opcodes.
  Counts are `F0=16`, `F2=1`, `F3=1`, and `F5=10`. No `F1`, `F4`,
  `F6`, or `F7..FF` byte occurs in opcode position.
- **Evidence:** all assets under `assets/generated/audio`, decoded using the
  four-byte prologue and operand rules implemented by
  `loc_decode_sound_stream_byte`.
- **Resolution:** retain dormant handlers as part of the original engine. The
  final two `$FF` bytes in slot 0F occur after `F0` and are tracked as
  DATA-005 rather than interpreted as opcodes.
### CODE-002 - duplicate ghost-release routine in scoring

- **Subsystem/status:** scoring/ghost house; unused
- **Result:** the duplicate routine at `$DFAC..$DFBD` is statically unreachable.
  Neither possible entry address (`$DFAC` initialization or `$DFAE` loop)
  occurs as a 16-bit value elsewhere in the PRG; the only branch to `$DFAE`
  is the routine's own loop. The preceding executable path jumps away before
  the pellet table, so there is no fall-through.
- **Evidence:** whole-PRG pointer/relative-target scan and local control flow in
  `src/game/scoring.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the original bytes.
### DATA-001 - repeated fruit-tile sequence

- **Subsystem/status:** round runtime data; unused
- **Result:** the eight bytes at `$D1FD..$D204` are statically unreachable as
  data. No address within the range occurs as a 16-bit value elsewhere in the
  PRG. The preceding release routine ends in `RTS`; the following referenced
  object begins at `tbl_frightened_palette_cmd = $D205`.
- **Evidence:** whole-PRG pointer scan, linker labels, and local control flow in
  `src/game/round/runtime.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the duplicate bytes.
### CODE-001 - attract gameplay-bootstrap block

- **Subsystem/status:** attract intro; unused
- **Result:** the instruction block at `$C4E5..$C4EB` is statically
  unreachable. No address in the block occurs as a 16-bit pointer or relative
  branch target. The preceding path ends with `JMP loc_script_dispatch_loop`;
  the next reachable object is `sub_build_attract_ppu_packet = $C4EC`.
- **Evidence:** whole-PRG pointer/branch scan, linker labels, and local control
  flow in `src/game/title/attract_intro.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the original bytes.

### DATA-002 - bytes after life-icon PPU packets

- **Subsystem/status:** scoring data; unused
- **Result:** the four `$4A` bytes at `$E144..$E147` are statically
  unreachable. No address in the range occurs as a pointer or branch target.
  The preceding high-score copy ends in `RTS`; the following callable routine
  begins at `sub_digit_to_score_tile = $E148`.
- **Evidence:** whole-PRG pointer/branch scan, linker labels, and local control
  flow in `src/game/scoring.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the bytes.

### DATA-005 - bytes after the pause-toggle stream terminator

- **Subsystem/status:** audio/data tail; unused
- **Result:** `$F426..$F427` are not decoded as part of slot 0F. Its only
  pointer enters at `$F3ED`, and the stream stops at `$F425 = F0`. Neither
  trailing address occurs as another pointer or branch target; padding begins
  at `$F428`.
- **Evidence:** grammar-aware stream decode, whole-PRG pointer/branch scan, and
  linker boundaries.
- **Resolution:** classify the two `$FF` bytes as unused tail padding retained
  inside the extracted asset.