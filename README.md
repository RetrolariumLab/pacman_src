# Pac-Man (NES, JP) Reconstruction

Pac-Man (NES, JP) reverse-engineering and reconstruction project.

The project combines:
- a new `cc65`-based C baseline ROM,
- a commented `bank_FF.asm` reference/disassembly workflow,
- automated FCEUX capture and comparison tooling,
- local technical documentation for NES hardware and project-specific notes.

**Base `bank_FF.asm` reference**: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

**Local docs source**: [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## Current Status

What works now:
- title screen,
- main menu,
- attract names screen,
- chase demo partially.

What is still broken:
- chase demo still has sprite bugs,
- some demo sprites disappear, clip, or render in the wrong order,
- gameplay is not yet complete/playable.

In practice, the front-end and demo flow are far enough along to debug visually against the original ROM, but the game is not finished.

## Quick Start

```bash
git clone <repo>
cd pacman_src

# Place original ROM in project root:
#   Pac-Man (J) (V1.0) [!].nes

make build-c0
make test-c0
```

## Project Structure

```text
pacman_src/
├── build_c/                      # Built C ROM output
├── cc65-snapshot-win64/          # Local cc65 toolchain
├── docs/                         # Project notes + local Nesdev Wiki dump
│   ├── nesdev/                   # Dumped NES technical documentation
│   ├── bank_ff_map.md            # bank_FF notes
│   ├── gameplay_feature_map.md   # Gameplay feature mapping
│   ├── ghost_ai.md               # Ghost behavior notes
│   ├── intermission_flow.md      # Intermission/cutscene notes
│   └── ...
├── movies/                       # FM2 movies for automation
├── reference/                    # Reference captures from original ROM
├── reference_projects/           # External projects kept for study
├── reports/                      # Generated reports
├── scripts/                      # Build/repro tooling
│   ├── ghidra/                   # Ghidra export/import/headless helpers
│   ├── workflow/                 # bank_FF analysis and compare helpers
│   ├── build.py                  # Legacy root build
│   ├── build_disasm_repro.py     # Disasm reproduction build
│   ├── build_repro_c_cc65.py     # Ghidra C -> cc65 helper
│   ├── build_repro_c_cc65_rom.py # Ghidra C ROM builder
│   ├── build_repro_layout_rom.py # Repro layout ROM builder
│   ├── compare_roms.py           # Binary ROM comparison
│   ├── generate_repro_disasm.py  # bank_FF -> repro asm generator
│   └── split_chr.py              # CHR extractor
├── src/
│   ├── assets/                   # CHR/assets used by the C build
│   ├── core/                     # Core engine/runtime code
│   ├── game/                     # Game/demo modules
│   ├── include/                  # Headers
│   ├── README.md                 # Source tree notes
│   └── nrom128_horz.cfg          # Current linker config
├── workflow/                     # Generated workflow state and progress data
├── bank_FF.asm                   # Main reference asm file
├── decomp_bank_ff.c              # Auxiliary decompilation reference
├── Makefile                      # Main automation entrypoint
├── Pac-Man (J) (V1.0) [!].nes    # Original ROM
├── README.md
└── tile_ascii_map.txt            # Tile-to-ASCII map for reports
```

### Scripts

| Script | Purpose |
|--------|---------|
| `build.py` | Builds the legacy root-level ROM flow |
| `split_chr.py` | Extracts CHR data from the original ROM |
| `compare_roms.py` | Binary comparison of built ROM vs original |
| `build_disasm_repro.py` | Builds a reproduction ROM from generated disassembly |
| `build_repro_c_cc65.py` | Prepares Ghidra decompilation for `cc65` |
| `build_repro_c_cc65_rom.py` | Builds a ROM from the Ghidra C path |
| `build_repro_layout_rom.py` | Builds a reproduction ROM preserving layout |
| `generate_repro_disasm.py` | Generates a repro asm from `bank_FF.asm` |
| `scripts/workflow/*` | bank_FF manifests, RTS analysis, compare reports, ROM verification |
| `scripts/ghidra/*` | Headless Ghidra export/import and coverage tooling |

## Makefile Workflows

### Core Build Workflow

```bash
make split              # Extract CHR from the original ROM
make build              # Build legacy root-level ROM flow
make clean              # Remove root-level build artifacts

make build-c0           # Build current C baseline ROM
make run-c0             # Run current C baseline ROM
make test-c0            # Run C ROM against reference and generate reports
make clean-c0           # Remove C baseline build output
```

### Emulator / Reference Workflow

```bash
make build-fceux        # Build fceux_automation
make reference          # Generate reference capture set from original ROM
make debug              # Run built ROM against reference capture set
make report             # Generate report from latest debug run
make stop               # Kill running emulator/python processes
```

### `bank_FF.asm` Workflow

```bash
make wf-init                    # Build procedure manifest from bank_FF.asm
make wf-batch COUNT=32          # Prepare RTS analysis batch
make analyze                    # Analyze bank_FF procedures with FCEUX
make verify-bank-ff             # Verify ROM reconstructed from bank_FF.asm
make build-bank-ff-ca65         # Build bank_FF ROM via ca65/ld65
make verify-bank-ff-ca65        # Verify ca65/ld65 build against original
make chunk CHUNK_START=1 CHUNK_LINES=250
                                # Extract rename/analysis chunk from bank_FF.asm
```

### Utility Commands

```bash
make help-workflow      # Print workflow-oriented help
```

## Build System

### C Baseline Build

The current main build target is `make build-c0`.

It uses:
- `cc65-snapshot-win64/bin/cl65`
- `src/nrom128_horz.cfg`
- `src/core/*`
- `src/game/*`
- `src/include/*`

Output:
- `build_c/pacman_c0.nes`

### Reference / Compare Flow

`make test-c0` does this:
1. builds `build_c/pacman_c0.nes`
2. runs it in `fceux_automation`
3. replays `movies/pacman_j_longplay.fm2`
4. saves screenshots, state dumps and ASCII tiles into `workflow/progress`
5. builds a comparison report in `workflow/progress/report`

## Recommended Working Flow

### For C ROM debugging

```bash
make test-c0

# Then inspect:
#   workflow/progress/screens
#   workflow/progress/ascii
#   workflow/progress/report
```

### For `bank_FF.asm` analysis

```bash
make wf-init
make wf-batch COUNT=32
make analyze

# Then inspect:
#   workflow/
#   reports/
#   diffs/
```

## Notes

- The original ROM remains the source of truth.
- `workflow/`, `reports/`, `diffs/`, and parts of `reference/` are generated artifacts.
- The repository currently contains both active code and reverse-engineering infrastructure.
- The `docs/nesdev/` directory is a local dumped copy of [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki).

## Credits

- `bank_FF.asm` base reference came from [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)
- NES hardware documentation is mirrored locally from [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)
- Original game rights belong to Namco/Nintendo

## License

This repository is reverse-engineering / preservation work for educational purposes. Original game rights belong to Namco and Nintendo.
