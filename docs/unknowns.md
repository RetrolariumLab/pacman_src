# Reverse-Engineering Unknowns

## Purpose

This is the permanent evidence record for resolved reconstruction questions
and the canonical backlog for any future uncertainty in the target
`Pac-Man (J) (V1.0) [!]` ROM. Source comments link here by stable ID. A
plausible interpretation is not enough to rename a symbol or resolve an entry.

Statuses are `open`, `testing`, `resolved`, `unused`, and `confirmed bug`.
Confidence describes a hypothesis, not mechanically observed facts. Source
annotations use `!(OBS)`, `!(ASSUME)`, `!(WHY?)`, `!(UNKNOWN)`, `!(BUG?)`, and
`!(UNUSED)`.

## Open Registry

No entries remain open after the focused milestone-23 static and runtime audit.
New uncertainty must receive a stable ID and a bounded experiment before it is
added here.

Reproduce the evidence with:

```text
make trace-evidence
make validate-evidence
```

The first command rebuilds the byte-identical ROM, captures a complete natural
longplay and a controlled pause probe in FCEUX, and invokes the validator. The
second command revalidates the ignored CSV files without starting the emulator.
Both paths require manifest-matched scenario identities, exact frame bounds,
declared patch addresses, and the complete pause/slot-0F/resume sequence.

## Resolved Entries

Move entries here only after static analysis, runtime evidence, or a controlled
experiment supports the conclusion. Preserve ID, result, evidence, and the
change that closed it.

### RAM-001 — fruit collision-state array member

- **Subsystem/status:** actor collisions; resolved
- **Result:** `$00C0` is the fifth element reached by the interleaved actor-state
  scan `ram_ghost_state + X` with `X = 0,2,4,6,8`. The final index represents
  the fruit candidate, so round setup stores active state `$04` there.
- **Evidence:** the 120000-frame reconstruction evidence trace observes the write at `$CFEC`
  with `Y = 04` and the indexed read at `$D224` with `X = 08`.
- **Resolution:** rename the field to `ram_fruit_collision_state`.

### RAM-002 — multiplexed shared-state ownership

- **Subsystem/status:** script-local RAM; resolved
- **Result:** `$0087..$008A` deliberately change ownership with `ram_script`.
  Gameplay uses a frightened mask and seconds/frame countdown; intermissions
  use scene, substate, and countdown aliases. Title, READY, death, stage-clear,
  game-over, and attract handlers retain their documented local ownership.
- **Evidence:** PC/script-aware read/write capture covers scripts `$00`, `$02`,
  `$04`, `$06`, `$08`, `$0A`, `$0C`, `$0E`, and `$10`; static owners are listed
  in `docs/script_states.md` and `docs/intermission_flow.md`.
- **Resolution:** retain neutral storage names and add contextual aliases for
  the unambiguous gameplay and intermission lifetimes.

### RAM-003 — personal-release phase latch

- **Subsystem/status:** ghost release and mode transitions; resolved
- **Result:** `ram_personal_release_latch` is cleared by round setup, set to one
  when either personal pellet threshold is reached, and remains set until the
  next setup. Even scatter/chase phases copy it into the ghost targeting mask;
  ordinary reversal passes skip active ghosts while it is set. Frightened-mode
  reversals remain eligible because the full frightened mask takes precedence.
- **Evidence:** the trace observes `$D1C4` writes of one, `$D16C` reads of both
  zero and one at phase boundaries, and reversal entries under both latch states.
- **Resolution:** replace the incorrect timer name with
  `ram_personal_release_latch` and document both consumers.

### SND-001 — SFX request-slot semantics

- **Subsystem/status:** sound request page; resolved
- **Result:** each byte `$0600..$060F` activates the same-index entry in the
  16-stream pointer table. Values are stream-specific channel-state requests,
  not uniform booleans; paired ready/pellet slots and internal house/release/
  intermission markers are therefore correctly represented as separate slots.
- **Evidence:** natural longplay plus controlled pause/resume activates all 16
  slot indexes at `bra_channel_has_active_stream`, including slot `$0F`.
- **Resolution:** retain the caller- and role-based names in `src/memory/ram.inc`
  and the matching stream labels in `src/audio/streams.asm`.

### DATA-003 — attract packet file offset and sprite strips

- **Subsystem/status:** attract rendering; resolved
- **Result:** legacy `$05F7` is an iNES file offset, not RAM. Removing the
  16-byte header maps it to CPU `$C5E7`, the first attract packet referenced by
  `tbl_attract_ppu_packet_ptrs`. A zero byte after selected packet terminators
  intentionally requests one of four 16-byte OAM strips.
- **Evidence:** the pointer at CPU `$C5D3` is `$C5E7`; runtime capture observes
  strip selections `$02`, `$06`, `$0A`, and `$0E` entering the `$C688` table.
- **Resolution:** replace the misleading warning with the file-offset mapping.

### DATA-004 — unreferenced ROM copyright notice

- **Subsystem/status:** boot metadata; resolved
- **Result:** `$C000..$C032` is a 51-byte ASCII copyright/rights notice. The
  reset vector enters at `$C033`, immediately after it; on-screen copyright
  text comes from separate PPU packet data.
- **Evidence:** exact ROM bytes, reset vector `$C033`, revision-specific notice
  alternatives, and the absence of a symbolic consumer in the shared source.
- **Resolution:** label the block `tbl_rom_copyright_notice` and retain it as
  unreferenced identification metadata required for byte identity.

### CODE-003 — row-stride operand invariant

- **Subsystem/status:** tile coordinates; resolved
- **Result:** both row-stride helpers always receive `$0020`. Each helper has
  exactly one direct caller; immediately before each call, the caller writes
  `$20` and `$00` to `ram_ppu_row_delta_lo/hi`. No other symbolic writes to
  the pair exist in the source tree.
- **Evidence:** static whole-tree reference search and
  `src/rendering/tile_coordinates.asm`.
- **Resolution:** retain the original RAM-based operations for byte identity;
  source annotations now record the invariant as `!(OBS)`.

### CODE-004 — sound fetch stack round trip

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
### SND-002 — inactive sound control opcodes

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
### CODE-002 — duplicate ghost-release routine in scoring

- **Subsystem/status:** scoring/ghost house; unused
- **Result:** the duplicate routine at `$DFAC..$DFBD` is statically unreachable.
  Neither possible entry address (`$DFAC` initialization or `$DFAE` loop)
  occurs as a 16-bit value elsewhere in the PRG; the only branch to `$DFAE`
  is the routine's own loop. The preceding executable path jumps away before
  the pellet table, so there is no fall-through.
- **Evidence:** whole-PRG pointer/relative-target scan and local control flow in
  `src/game/scoring.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the original bytes.
### DATA-001 — repeated fruit-tile sequence

- **Subsystem/status:** round runtime data; unused
- **Result:** the eight bytes at `$D1FD..$D204` are statically unreachable as
  data. No address within the range occurs as a 16-bit value elsewhere in the
  PRG. The preceding release routine ends in `RTS`; the following referenced
  object begins at `tbl_frightened_palette_cmd = $D205`.
- **Evidence:** whole-PRG pointer scan, linker labels, and local control flow in
  `src/game/round/runtime.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the duplicate bytes.
### CODE-001 — attract gameplay-bootstrap block

- **Subsystem/status:** attract intro; unused
- **Result:** the instruction block at `$C4E5..$C4EB` is statically
  unreachable. No address in the block occurs as a 16-bit pointer or relative
  branch target. The preceding path ends with `JMP loc_script_dispatch_loop`;
  the next reachable object is `sub_build_attract_ppu_packet = $C4EC`.
- **Evidence:** whole-PRG pointer/branch scan, linker labels, and local control
  flow in `src/game/title/attract_intro.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the original bytes.

### DATA-002 — bytes after life-icon PPU packets

- **Subsystem/status:** scoring data; unused
- **Result:** the four `$4A` bytes at `$E144..$E147` are statically
  unreachable. No address in the range occurs as a pointer or branch target.
  The preceding high-score copy ends in `RTS`; the following callable routine
  begins at `sub_digit_to_score_tile = $E148`.
- **Evidence:** whole-PRG pointer/branch scan, linker labels, and local control
  flow in `src/game/scoring.asm`.
- **Resolution:** annotate as `!(UNUSED)`; retain the bytes.

### DATA-005 — bytes after the pause-toggle stream terminator

- **Subsystem/status:** audio/data tail; unused
- **Result:** `$F426..$F427` are not decoded as part of slot 0F. Its only
  pointer enters at `$F3ED`, and the stream stops at `$F425 = F0`. Neither
  trailing address occurs as another pointer or branch target; padding begins
  at `$F428`.
- **Evidence:** grammar-aware stream decode, whole-PRG pointer/branch scan, and
  linker boundaries.
- **Resolution:** classify the two `$FF` bytes as unused tail padding retained
  inside the extracted asset.
