# Pac-Man (NES, JP) Disassembly

Reverse-engineering and reconstruction of Pac-Man (J) (V1.0) for the NES.

The project is an annotated, native ca65 reconstruction of the game's single
6502 PRG bank, plus tooling that rebuilds the ROM, compares it byte for byte
against the original, and replays a longplay movie in an instrumented FCEUX to
catch behavioural regressions frame by frame.

**Base `bank_FF.asm` reference**: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

**Local docs source**: [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## Status

The label / comment pass covers the major subsystems: boot and frame loop, the
script state machine, Pac-Man movement, ghost AI, scoring, intermissions, and
the sound engine. The source is split into address-ordered subsystem modules
containing real 6502 instructions and ca65 data directives. Ongoing work is
deepening their annotations and replacing generic RAM names.

The gate for every change is `make verify`: rebuild the ROM from
`src/main.asm` and assert byte-identity with the original. Annotation must never
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

`make build` assembles `src/main.asm` and its modules directly with ca65/ld65.
`make verify` performs the same native build and fails unless the result is
byte-identical to the reference ROM.

## Project Structure

```text
pacman_src/
├── bin/                          # ca65 / ld65
├── config/
│   └── tile_ascii_map.txt        # Pac-Man tile mapping for ASCII captures
├── docs/                         # Subsystem notes + local Nesdev Wiki dump
│   ├── nesdev/                   # Dumped NES technical documentation
│   ├── index.md                  # Docs navigation
│   ├── roadmap.md                # Preservation-source milestones and RE rules
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
│   ├── workflow/                 # bank_FF analysis, build, verify, reporting
│   ├── build_native.py           # Build and verify the native ca65 source
│   ├── build_dev.py              # Check tools and clone/build FCEUX
│   ├── clean_artifacts.py        # Remove generated local artifacts
│   ├── flatten_listing.py        # Expand modules for single-file external tools
│   ├── compare_roms.py           # Binary ROM comparison
│   └── split_chr.py              # CHR extractor
├── src/
│   ├── main.asm                  # Native ca65 entrypoint and module index
│   ├── bank_ff/                  # Annotated disassembly modules — source of truth
│   ├── memory/                   # RAM symbols and gameplay constants
│   └── nrom128_prg_only.cfg      # ld65 config: bare 16 KiB PRG, no header/CHR
├── Makefile                      # Automation entrypoint
└── Pac-Man (J) (V1.0) [!].nes    # Original ROM (not distributed)
```

`reference/`, `diffs/`, `reports/` and `workflow/` are generated artifacts and
are not tracked.

## Make Targets

```bash
make                            # Same as `make build`
make build                      # Build the native ca65 ROM
make verify                     # Build and require byte-identity
make split                      # Extract CHR from the original ROM
make build-dev                  # Check tools and clone/build FCEUX if needed
make reference                  # Capture the reference set from the original ROM
make analyze COUNT=32           # Run RTS reverse-engineering analysis
make chunk START=260 LINES=60   # Prepare a rename/analysis chunk
make clean                      # Remove local build and analysis artifacts
make help                       # Show the public targets
```

`make reference` is intentionally explicit because a full reference capture is
expensive. Run it before `make analyze`. `make clean` also removes generated
reference, diff, report, and workflow directories, but never removes the FCEUX
checkout or the original ROM.

## Working Flow

1. Annotate a module under `src/bank_ff/` (or select a logical flattened chunk
   with `make chunk`).
2. Run `make verify` — it must stay byte-identical. Annotation never
   changes assembled bytes, so any diff is a mistake in the edit.
3. Use `make reference` and `make analyze` when runtime evidence is needed.

## Tooling Requirements

- Python 3
- `ca65` / `ld65` (bundled in `bin/`)
- [`fceux_automation`](https://github.com/oranguthang/fceux_automation) — a
  fork of FCEUX with headless capture, reference comparison and state dumping,
  cloned and built by `make build-dev`
- MSBuild / Visual Studio 2022 (to build `fceux_automation` on Windows)

## Known Gaps

- Labels and comments cover all major systems, but many lower-level branches
  and data fields can still be described more precisely.
- Many RAM fields still have address-derived names and need trace-backed
  semantic names.
- Procedure inputs, outputs, clobbers, invariants, and open questions are not
  yet documented consistently; see [`docs/roadmap.md`](docs/roadmap.md).

## Credits

- `bank_FF.asm` base reference: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)
- NES hardware documentation mirrored locally from [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## License

Reverse-engineering / preservation work for educational purposes. No original
ROM data is distributed with this repository. Original game rights belong to
Namco and Nintendo.
