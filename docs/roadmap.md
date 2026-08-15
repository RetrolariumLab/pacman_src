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
- Semantic symbols no longer encode ROM or RAM addresses. Control-flow prefixes
  distinguish direct subroutines, dispatched handlers, shared jump entries, and
  internal branch targets as documented in `docs/naming.md`.
- `src/memory/ram.inc` and `src/memory/constants.inc` provide the symbols needed
  by the native source. Proven fields use semantic names; deliberately neutral
  scratch, shared-state, and unknown names remain where meaning is unproven.
- Small domain-level ca65 macros describe repeated pointer, PPU, HUD, and OAM
  operations without changing instruction order or runtime behavior.
- The build emits linker labels so analysis tools can retain exact addresses
  without putting addresses back into source identifiers.
- Assembly whitespace is normalized: blocks use at most one blank separator and
  tracked text files end with exactly one newline.
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
experiment supports it. Record reusable open questions in the canonical `docs/unknowns.md` registry.

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
- Preserve the original byte order, fixed vectors, and full PRG layout.
- Convert listing metadata into native ca65 instructions and data directives.
- Make build, verification, asset extraction, and analysis paths include-aware.
- Require byte identity from the default preservation build.
- Keep every native source module below 600 lines without relocating ROM code.

### 1. Source Naming and Mechanical Cleanup — Complete

- Replace ROM-address-derived code and data identifiers with semantic names.
- Use `sub_` only for direct `JSR` targets, `handler_` for dispatched entries,
  `loc_` for shared `JMP` entries, and `bra_` for internal branch targets.
- Replace proven RAM addresses with semantic fields or array bases.
- Use neutral `zp_work*`, `ram_shared_state_*`, and `ram_unknown_*` names where
  a single global interpretation is not yet supported by evidence.
- Keep runtime addresses in linker-generated label files rather than encoding
  them into source identifiers.
- Collapse repeated blank lines and require exactly one final newline in every
  tracked text file.

The naming rules are documented in `docs/naming.md`. Future renames must retain
the same evidence standard and pass `make verify`.

### 2. Unknowns Registry and Evidence Cleanup — Complete

Create `docs/unknowns.md` as the canonical reverse-engineering backlog. Each
entry should contain:

- a stable identifier;
- the subsystem and current semantic symbol;
- the ROM address from linker labels when relevant;
- what is mechanically established;
- the current hypothesis, if any;
- confidence and evidence references;
- the smallest controlled experiment that could resolve it;
- status: open, testing, resolved, unused, or confirmed bug.

Initial candidates include:

- `ram_unknown_round_state`;
- context-specific meanings of `ram_shared_state_0..3`;
- provisional sound request slots and stream opcodes;
- legacy `bzk garbage`, `bzk optimize`, and `bzk warning` annotations;
- duplicated or apparently unreachable code near scoring and release logic;
- table formats whose mechanics are known but whose field meanings are not.

Normalize source annotations to `!(OBS)`, `!(ASSUME)`, `!(WHY?)`,
`!(UNKNOWN)`, `!(BUG?)`, and `!(UNUSED)`. Replace a hypothesis with a factual
name only after static analysis, trace evidence, or a controlled patch proves
it.

Exit criteria:

- every material unresolved question is searchable in one registry;
- legacy uncertainty comments use the evidence tags;
- resolved entries link to the source or documentation change that closed them.

### 3. Fully Document the Scoring System — Complete

Use `src/game/scoring.asm` as the first end-to-end documentation standard.
Document every substantial `sub_` routine and important dispatched entry with
verified purpose, inputs, outputs, clobbers, side effects, and invariants.

Trace the complete transaction chains for:

1. ordinary pellet consumption;
2. power-pellet consumption and frightened-mode activation;
3. successive ghost captures and the 200/400/800/1600 chain;
4. fruit spawn, collision, score popup, and timeout;
5. BCD score accumulation and PPU buffer formatting;
6. one-time extra-life threshold handling;
7. high-score comparison and promotion.

The module should explain which work is immediate and which work is queued for
the NMI/PPU update path. Uncertain contracts must remain partial or explicitly
tagged rather than being completed speculatively.

Deliverables:

- procedure headers in `src/game/scoring.asm`;
- an updated `docs/score_and_bonus.md` architecture narrative;
- contextual RAM aliases where ownership is proven;
- targeted runtime traces for the important score events;
- open questions recorded in `docs/unknowns.md`;
- a byte-identical `make verify` result.

Once complete, this module becomes the style template for every later
subsystem pass.

Completed with procedure contracts in `src/game/scoring.asm` and
`src/game/round/runtime.asm`, the architecture narrative in
`docs/score_and_bonus.md`, and reproducible Lua-backed scenarios documented in
`docs/scoring_trace_scenarios.md`. The repository longplay observes all six
defined score-event sequences in the byte-identical preservation build.

### 4. Hardware Registers, Flags, and Constants — Complete

`src/memory/hardware.inc` now names the CPU-visible registers used directly by
the source. Raw register operands have been replaced while VRAM addresses such
as nametable `$2000` remain numeric. The initial proven PPU, APU, and controller
bit masks are also defined there.

The evidence-backed magic-number and state/data-format pass is complete for the
verified concepts listed below. Standard register symbols include:

```asm
PPUCTRL       = $2000
PPUMASK       = $2001
PPUSTATUS     = $2002
OAMDMA        = $4014
APU_STATUS    = $4015
JOYPAD1       = $4016
JOYPAD2       = $4017
```

Named bit masks are limited to clear uses such as NMI enable, rendering enable,
controller buttons, and APU channel enables. Exact immediate values and
instruction encodings remain preserved.

Named constants now cover:

- gameplay script states;
- ghost states;
- movement directions;
- intermission scene and substate IDs;
- sound stream control opcodes;
- tile IDs and actor sprite modes;
- PPU command-buffer terminators and field sizes;
- state-table strides and record sizes.

Keep numbers that are inherently data, timing values, table indexes, or still
unexplained. A named constant should communicate a verified concept, not merely
move a hexadecimal literal elsewhere.

Suggested layout:

```text
src/memory/
  hardware.inc
  ram.inc
  constants.inc
```

### 5. Systematic Subsystem Documentation

After the scoring reference module is complete, apply the same standard in this
order:

1. gameplay script dispatcher and state transitions;
2. movement, tile probes, tunnel wrapping, and collision rules;
3. ghost state machine, targeting formulas, release logic, and speed profiles;
4. actor animation, OAM construction, and buffered PPU updates;
5. intermission state machines and animation tables;
6. sound engine, stream commands, and channel arbitration;
7. stage parameters, maze compression, padding, and vectors.

Each pass should produce both local procedure contracts and a subsystem-level
document. Update diagrams only when they make multi-stage control flow, state
transitions, or a binary layout materially easier to understand.

Do not split files further merely to reduce line count. The current modules are
already small enough; new boundaries should reflect ownership or a decoded data
format rather than an arbitrary size target.

### 6. Debugger Symbols and Source-Level Navigation

The build already emits ld65 labels with addresses separated from semantic
source names. Extend this into a first-class debugging workflow:

- emit ca65/ld65 debug information and a stable map artifact;
- convert symbols into a format accepted by Mesen or another modern NES
  debugger;
- map runtime addresses back to semantic labels and source files;
- document how to load symbols and source mappings;
- provide useful breakpoint groups for scripts, scoring, ghost decisions, PPU
  writes, and sound commands;
- define a standard watch list for important RAM fields.

Completion means a contributor can open the rebuilt ROM in the debugger, stop
on a named routine, inspect meaningful RAM fields, and return to the matching
source without manually translating an address.

### 7. Focused Runtime Trace Scenarios

The longplay comparison remains the broad regression test. Add short,
deterministic scenarios for semantic investigation:

- consume one ordinary pellet;
- consume a power pellet and observe frightened-mode start/end;
- capture one through four ghosts in one frightened window;
- spawn, collect, and time out a fruit;
- die, respawn, and switch players;
- release each ghost from the house;
- cross scatter/chase boundaries and direction reversals;
- execute every intermission;
- pause and resume gameplay;
- decode representative sound streams and control opcodes.

Each scenario should record only the relevant fields per frame into a compact
CSV or structured trace. Store the scenario definition and expected semantic
events in the repository; keep large captures and emulator dumps ignored.

Use controlled patches when needed to force a rare state, but record the exact
patch and never confuse a patched ROM result with evidence from the preservation
build.

### 8. Automated Source and Documentation Checks — In Progress

The initial `make lint` target now checks text whitespace and final newlines,
evidence tags and registry IDs, legacy uncertainty annotations, raw hardware
operands, address-derived symbols, direct `JSR`/`sub_` consistency, and the ASM
module size budget. Remaining checks below can be added as their rules become
precise enough to avoid false positives.

It should eventually verify:

- no ROM or RAM addresses are embedded in active symbol names;
- every direct `JSR` target uses `sub_` and every `sub_` has a direct caller;
- no legacy `ofs_*` definitions remain;
- symbol prefixes follow `docs/naming.md`;
- no repeated blank-line runs or trailing whitespace exist;
- every tracked text file ends with exactly one newline;
- source modules remain within the agreed size budget;
- documentation references resolve to existing symbols where practical;
- evidence tags use the approved vocabulary;
- Python workflow scripts parse and pass focused unit tests.

Keep `make lint` fast. `make verify` remains the authoritative binary gate, and
emulator scenarios remain a separate, slower layer.

Recommended validation layers:

```text
make lint       # source and documentation invariants
make verify     # byte-identical ROM
make analyze    # expensive behavioral comparison when relevant
```

### 9. Decode and Document Binary Data Formats

Write a specification and a small decoder/dumper for each format as it becomes
understood:

- stage parameter records and profile selection;
- maze RLE commands and nametable reconstruction;
- sound stream notes, durations, control opcodes, and channel records;
- buffered PPU command packets;
- actor sprite-set and OAM composition tables;
- intermission scene and animation tables.

When a format is fully understood and useful to edit by hand, represent it with
named ca65 constants or domain macros while preserving identical bytes. Keep
opaque proprietary payloads under the explicit `make split` workflow until a
round-trip source representation is justified.

Round-trip tools should support:

```text
binary asset -> decoded human-readable form -> encoded binary asset
```

The encoded result must match the original asset before the format is declared
stable. Editors and encoders must never run implicitly during `make build` in a
way that overwrites local modifications.

### 10. Preservation Source 1.0

Declare a preservation milestone when:

- all major routines have verified purpose and calling-contract comments;
- important RAM fields, constants, state machines, and table formats are
  documented;
- unresolved behavior is explicit in `docs/unknowns.md`;
- source-level debugger navigation works;
- the focused scenario suite covers the main gameplay transactions;
- a new contributor can modify one subsystem without reconstructing the whole
  PRG bank mentally;
- the reference build remains byte-identical and is still the default.

Tag this state as a stable preservation release before beginning substantial
behavior changes.

### 11. Optional ROM-Hack and Bug-Fix Variants

Only after the preservation source is mature should behavior changes become a
normal project activity. Keep them behind explicit build variants:

```text
make build          # preservation build
make verify         # must match the original ROM
make build-hack     # modified behavior/assets are allowed
make run-hack
```

Potential experiments include confirmed original-game bug fixes, alternate
speed profiles, selectable starting stages, new mazes, changed ghost behavior,
and edited graphics or sound.

The current PRG bank has no free bytes, so non-trivial hacks require an explicit
strategy: reclaim verified unused space, optimize with measured equivalence, or
introduce a documented expanded-ROM layout. Never let the modified layout
replace or weaken the preservation target.

## Recommended Next Work Package

Create a branch such as `document-scoring-system` and complete this sequence:

1. review `docs/unknowns.md` and link scoring-related findings by stable ID;
2. use `src/memory/hardware.inc` symbols when documenting hardware effects;
3. document `src/game/scoring.asm` procedure by procedure;
4. add focused traces for pellet, frightened, ghost-score, fruit, 1UP, and
   high-score events;
5. promote only proven RAM fields and constants;
6. run `make lint` once available and always run `make verify`;
7. update `docs/score_and_bonus.md` and close or refine registry entries.

Avoid another broad mechanical rewrite during this phase. Small evidence-backed
commits will make regressions and mistaken interpretations easier to isolate.

## Resuming Work on Another Computer

The repository intentionally does not distribute the original ROM or extracted
proprietary assets. To recreate the local environment:

1. Clone the repository and enter its directory.
2. Check out the intended branch and confirm that the working tree is clean.
3. Place the exact reference ROM in the repository root as:
   `Pac-Man (J) (V1.0) [!].nes`.
4. Run `make split` once to validate the ROM and extract ignored local assets.
5. Run `make verify` and require the expected PRG and ROM SHA-1 values.
6. Run `make build-dev` only if the instrumented FCEUX checkout is needed.
7. Run `make reference` only when a new longplay reference capture is actually
   required; it is intentionally expensive and never implicit.

Minimal bootstrap:

```bash
git clone <repo>
cd pacman_src

# Copy the exact reference ROM into this directory first.
make split
make verify

# Optional emulator and behavioral-analysis setup.
make build-dev
```

Before starting new reverse engineering:

```bash
git status
git log --oneline -10
make verify
```

Then read, in order:

1. `docs/roadmap.md`;
2. `docs/unknowns.md`;
3. `docs/naming.md`;
4. `docs/macros.md`;
5. the subsystem document related to the intended change;
6. the matching files under `src/`.

Do not commit the reference ROM, `assets/generated/`, `build/`, `workflow/`,
`reference/`, `diffs/`, or emulator binaries. `make split` is explicit because
it overwrites extracted assets; `make build` and `make verify` never do.

## Verification Gates

Every source edit batch must pass:

```text
make verify
```

This assembles the native source and must reproduce the reference ROM exactly.
Annotation-only commits must never change ROM bytes. Changes affecting analysis
tooling should also run the relevant chunk, manifest, trace, or emulator smoke
test.

Expected preservation hashes:

```text
PRG SHA-1: 20f0fc7664983b5d4f166866302f1ad20efb727d
ROM SHA-1: adb4d7d7d28c89ca177aad231e0fdad992c0fbfb
```

Use the narrowest relevant checks during development, but run `make verify`
before every preservation-source commit.

## Definition of Done

The preservation source is complete when:

- the native ca65 modules build the reference ROM byte for byte;
- major procedures have verified purpose and calling-contract comments;
- RAM fields, constants, tables, and state machines are documented;
- assumptions and unknowns are explicit and searchable;
- debugger symbols map runtime addresses back to readable source;
- focused traces explain the main state transitions and gameplay transactions;
- decoded binary formats have tested round-trip tools where appropriate;
- automated checks protect naming, formatting, and documentation invariants;
- a contributor can navigate and modify one subsystem without reconstructing
  the entire bank mentally;
- the original byte-identical build remains the default and permanent gate.
