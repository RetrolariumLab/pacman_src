# Pac-Man (NES, JP) Disassembly

Reverse-engineering and reconstruction of Pac-Man (J) (V1.0) for the NES.

The project is an annotated 6502 disassembly of the game's single PRG bank,
plus the tooling used to prove the disassembly is correct: rebuild the ROM from
`bank_FF.asm`, compare it byte for byte against the original, and replay a
longplay movie in an instrumented FCEUX to catch behavioural regressions frame
by frame.

**Base `bank_FF.asm` reference**: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

**Local docs source**: [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## Status

The label / comment pass covers the major subsystems: boot and frame loop, the
script state machine, Pac-Man movement, ghost AI, scoring, intermissions, and
the sound engine. Ongoing work is deepening those annotations and splitting the
single listing into per-subsystem modules.

The gate for every change is `make verify-bank-ff`: rebuild the ROM from
`bank_FF.asm` and assert byte-identity with the original. Annotation must never
alter the assembled bytes, so any diff means the edit was wrong.

The repository previously also contained a C reimplementation. It was removed —
see [`docs/postmortem.md`](docs/postmortem.md) for what was tried and why it did
not work.

## Quick Start

```bash
git clone <repo>
cd pacman_src

# Place the original ROM in the project root:
#   Pac-Man (J) (V1.0) [!].nes

make build
```

A successful run reports `[OK] Byte-identical ROM reproduced.`

Three independent paths rebuild the ROM and all three assert byte-identity:
`make build` (generated ca65 disassembly), `make verify-bank-ff` (pure Python
assembler) and `make verify-bank-ff-ca65` (ca65/ld65 straight from
`bank_FF.asm`).

## Project Structure

```text
pacman_src/
├── bank_FF.asm                   # The disassembly — source of truth
├── bin/                          # ca65 / ld65
├── docs/                         # Subsystem notes + local Nesdev Wiki dump
│   ├── nesdev/                   # Dumped NES technical documentation
│   ├── index.md                  # Docs navigation
│   ├── postmortem.md             # Why the C rewrite was abandoned
│   ├── bank_ff_map.md            # Bank segmentation and annotation priorities
│   ├── ram_fields.md             # RAM field glossary
│   ├── script_states.md          # Gameplay script state machine
│   ├── ghost_ai.md               # Ghost behaviour
│   ├── score_and_bonus.md        # Pellets / fruit / score / 1UP
│   ├── intermission_flow.md      # Intermission scenes
│   ├── sound_engine.md           # Audio engine and stream decoder
│   └── stage_params_and_data_tail.md
├── movies/                       # FM2 movies driving the automated capture
├── scripts/
│   ├── ghidra/                   # Headless Ghidra disasm export / import
│   ├── workflow/                 # bank_FF analysis, build, verify, reporting
│   ├── build_disasm_repro.py     # Build a ROM from generated disassembly
│   ├── build_repro_layout_rom.py # Layout-preserving repro ROM builder
│   ├── compare_roms.py           # Binary ROM comparison
│   ├── generate_repro_disasm.py  # bank_FF -> repro asm generator
│   └── split_chr.py              # CHR extractor
├── src/
│   └── nrom128_prg_only.cfg      # ld65 config: bare 16 KiB PRG, no header/CHR
├── Makefile                      # Automation entrypoint
├── Pac-Man (J) (V1.0) [!].nes    # Original ROM (not distributed)
└── tile_ascii_map.txt            # Tile-to-ASCII map for capture reports
```

`reference/`, `diffs/`, `reports/` and `workflow/` are generated artifacts and
are not tracked.

## Makefile Workflows

### Build and verification

```bash
make                            # Same as `make build`
make build                      # Build ROM from generated ca65 disassembly, assert byte-identity
make verify-bank-ff             # Rebuild ROM from bank_FF.asm, compare with original
make build-bank-ff-ca65         # Build the bank_FF ROM via ca65/ld65
make verify-bank-ff-ca65        # Build via ca65/ld65 and compare with original
```

### Annotation

```bash
make wf-init                    # Build the procedure manifest from bank_FF.asm
make wf-batch COUNT=32          # Prepare an RTS analysis batch
make analyze                    # Analyze bank_FF procedures with FCEUX
make chunk CHUNK_START=1 CHUNK_LINES=250
                                # Extract a rename/analysis chunk from bank_FF.asm
```

### Emulator / regression capture

```bash
make build-fceux                # Build fceux_automation
make reference                  # Capture the reference set from the original ROM
make debug                      # Replay the longplay on the rebuilt ROM vs reference
make report                     # Generate a report from the latest debug run
make progress-report RUN_DIR=…  # Compare an existing capture dir against reference
make stop                       # Kill running emulator/python processes
```

### Utility

```bash
make split                      # Extract CHR from the original ROM
make clean                      # Remove build artifacts
make help-workflow              # Print workflow-oriented help
```

## Working Flow

1. Annotate a chunk of `bank_FF.asm` (`make chunk`).
2. Run `make verify-bank-ff` — it must stay byte-identical. Annotation never
   changes assembled bytes, so any diff is a mistake in the edit.
3. For changes that do alter behaviour, run `make debug` and inspect the frame
   diffs in `diffs/` and the report in `reports/`.

## Tooling Requirements

- Python 3
- `ca65` / `ld65` (bundled in `bin/`)
- [`fceux_automation`](https://github.com/oranguthang/fceux_automation) — a
  fork of FCEUX with headless capture, reference comparison and state dumping,
  cloned and built by `make build-fceux`
- MSBuild / Visual Studio 2022 (to build `fceux_automation` on Windows)
- Ghidra, only for the optional `scripts/ghidra/` export paths

## Known Gaps

- `bank_FF.asm` is still a single listing; the intended target shape is a split
  into per-subsystem modules, matching `smb1_src`.
- The generated `src/pacman_disasm_repro.asm` is a flat `.byte` stream with the
  original mnemonics kept as trailing comments. It reproduces the ROM exactly
  but is not the readable artifact — `bank_FF.asm` is.

## Credits

- `bank_FF.asm` base reference: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)
- NES hardware documentation mirrored locally from [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## License

Reverse-engineering / preservation work for educational purposes. No original
ROM data is distributed with this repository. Original game rights belong to
Namco and Nintendo.
