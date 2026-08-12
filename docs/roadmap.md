# Roadmap

## Project Goal

Turn the existing reassemblable Pac-Man listing into a readable, documented,
native 6502/ca65 source tree that explains the game as an engineered system.
The result should preserve the original ROM exactly while making control flow,
state, data formats, hardware interaction, and unresolved questions explicit.

This is not a new C reimplementation. The original 6502 program, its data
layout, and its timing behavior remain the source of truth.

## Reference ROM

The project targets the local `Pac-Man (J) (V1.0) [!].nes` image:

- Full-ROM CRC32: `B509243F`
- Full-ROM SHA-1: `adb4d7d7d28c89ca177aad231e0fdad992c0fbfb`
- PRG CRC32: `BB1B591B`
- PRG SHA-1: `20f0fc7664983b5d4f166866302f1ad20efb727d`

Other revisions, including V1.1 disassemblies, may be useful references but
must not be merged by address or name alone. Every imported fact must be
checked against this ROM's bytes and behavior.

## Current Baseline

- `src/main.asm` is the address-ordered module index.
- Semantic subsystem directories under `src/` contain address-ordered ROM
  modules.
- Large subsystem listings are divided at procedural boundaries; every native
  source module is currently below 600 lines. See `docs/source_layout.md`.
- Major systems have an initial label and comment pass.
- The default build and compatibility verification targets reproduce the
  reference ROM byte for byte from the same native source.
- FCEUX capture tooling can compare frames and memory against a reference run.
- The subsystem modules contain native 6502 instructions and ca65 data
  directives; disassembler address and machine-code columns have been removed.
- `src/memory/ram.inc` and `src/memory/constants.inc` provide the symbols needed
  by the native source. Generic RAM names remain where semantics are unproven.
- Opaque CHR, maze, and audio payloads are reproducibly extracted from the
  validated reference ROM according to `assets/manifest.json`; editable tables
  and all asset labels remain in source.

## Reverse-Engineering Evidence Rules

Comments must distinguish established behavior from inference. Use these tags
consistently in source and documentation:

- `!(OBS)` — directly observed in code, memory traces, or emulator behavior.
- `!(ASSUME)` — a working interpretation supported by evidence but not proven.
- `!(WHY?)` — behavior is understood mechanically, but its purpose is unclear.
- `!(UNKNOWN)` — the field, branch, value, or format is not yet understood.
- `!(BUG?)` — suspected original-game bug; requires evidence before promotion
  to a definite bug annotation.
- `!(UNUSED)` — code or data confirmed unreachable or unused for this ROM.

Do not silently turn an assumption into a factual name or comment. Promote a
tagged hypothesis only after static analysis, trace evidence, or a controlled
experiment supports it. Record reusable open questions in `docs/unknowns.md`
once that file is introduced.

Comments should explain intent, invariants, state transitions, data formats,
and hardware consequences. They should not merely translate an instruction
into English.

## Procedure Documentation Standard

Substantial procedures should converge on this form:

```asm
; -----------------------------------------------------------------------------
; CheckForEatingPellets
;
; Checks the maze tile under Pac-Man and applies pellet-consumption side effects.
;
; Inputs:
;   ram_obj_ppu_tile_now - tile currently occupied by Pac-Man
;
; Outputs:
;   Pellet state, score request, sound request, and fruit progression may change.
;
; Clobbers:
;   A, X, Y
;
; Invariants:
;   PPU updates are queued; this routine does not write the nametable directly.
;
; RE:
;   !(UNKNOWN) Explain any remaining unresolved state or branch here.
; -----------------------------------------------------------------------------
```

Only document inputs, outputs, and clobbers that have been verified. Omit or
tag uncertain claims instead of filling the template speculatively.

## Milestones

### 0. Reproducible Modular Baseline — Complete

- Split the monolithic listing into address-ordered subsystem modules.
- Preserve the original byte order and fixed vectors.
- Make build, verification, and analysis paths include-aware.
- Require byte identity from every supported build path.

### 1. Commenting Standard and Unknowns Registry

- Adopt the evidence tags defined above.
- Add `docs/unknowns.md` with address, subsystem, evidence, and next experiment
  for every material unresolved question.
- Remove comments that merely restate 6502 instructions.
- Keep factual comments, observations, and hypotheses visibly distinct.

### 2. Fully Document One Reference Module

Use `src/game/scoring.asm` as the first end-to-end example:

- document each substantial procedure's purpose and calling contract;
- trace pellet, power-pellet, frightened-mode, score, 1UP, and high-score side
  effects as one connected transaction;
- identify RAM fields and constants that can be renamed with confidence;
- record remaining uncertainty with evidence tags;
- keep the ROM byte-identical after every small edit batch.

The finished module becomes the style reference for the rest of the project.

### 3. Restore Memory and Constant Definitions — In Progress

- Maintained RAM and constant include files have been reconstructed.
- Hardware registers still need a dedicated include file.
- Generic address-derived RAM names must be replaced only when their semantics
  are supported by code usage and runtime traces.
- Enumerations, bit flags, and table-format constants should be separated as
  their roles become established.
- Preserve address-oriented aliases where a field has more than one contextual
  role.
- Cross-check names against code usage and runtime traces before replacing
  numeric or generic identifiers.

Suggested target layout:

```text
src/
  memory/
    hardware.inc  # planned
    ram.inc
    constants.inc
```

### 4. Convert the Listing to Native ca65 Source — Complete

- Replaced listing metadata and byte columns with real ca65 instructions and
  data directives across all Bank FF modules.
- Preserved instruction selection, addressing modes, branch distances, data
  order, padding, and vector placement.
- Verified the complete native source byte for byte against the reference ROM.

Do not perform semantic cleanup, code relocation, or optimization during this
phase. Readability changes must not alter the executable layout.

### 4.5. Separate Editable Data from Opaque Assets — Complete

- Keep understood gameplay, rendering, stage, audio-support, and pointer tables
  as editable ca65 source.
- Extract CHR, compressed maze bytes, and sound streams from the exact reference
  ROM into the ignored `assets/generated/` directory.
- Track extraction ranges, sizes, and checksums in `assets/manifest.json`.
- Make asset extraction an explicit operation; normal build and verification
  targets only require the files and never overwrite local modifications.
- Represent deterministic unused padding with ca65 directives instead of
  thousands of repeated byte literals.

### 5. Systematic Subsystem Documentation

Apply the reference-module standard in this order:

1. gameplay script dispatcher and state transitions;
2. score, pellets, frightened mode, and bonuses;
3. movement, tile probes, and collision rules;
4. ghost state machine, targeting, release logic, and speed profiles;
5. actor animation, OAM construction, and buffered PPU updates;
6. intermission state machines;
7. sound engine, stream commands, and channel arbitration;
8. stage parameters, maze compression, padding, and vectors.

Update the corresponding subsystem document whenever a source annotation
establishes a reusable architectural fact.

### 6. Debugger and Contributor Experience

- Generate labels and source mappings usable by Mesen or another modern NES
  debugger.
- Add focused emulator scripts for state transitions, ghost decisions, score
  events, PPU queues, and sound commands.
- Add diagrams only where they clarify multi-stage control flow or data layout.
- Make verification commands and expected hashes obvious to new contributors.

### 7. Optional Behavior Changes

Only after the preservation source is complete should modified gameplay or bug
fixes be considered. Such work must live behind explicit build variants and
must never replace the byte-identical reference build.

## Verification Gates

Every source edit batch must pass:

```text
make verify
```

This assembles the native source and must reproduce the reference ROM exactly.
Annotation-only commits must never change ROM bytes. Changes affecting analysis
tooling should also run the relevant chunk or emulator smoke test.

## Definition of Done

The preservation source is complete when:

- the native ca65 modules build the reference ROM byte for byte;
- major procedures have verified purpose and calling-contract comments;
- RAM fields, constants, tables, and state machines are documented;
- assumptions and unknowns are explicit and searchable;
- debugger symbols map runtime addresses back to readable source;
- a contributor can navigate and modify one subsystem without reconstructing
  the entire bank mentally;
- the original byte-identical build remains the default and permanent gate.
