# Pac-Man (NES, JP) Disassembly

Reverse-engineering and reconstruction of Pac-Man (J) (V1.0) for the NES.

The project is an annotated, native ca65 reconstruction of the game's single
6502 PRG bank, plus tooling that rebuilds the ROM, compares it byte for byte
against the original, and replays a longplay movie in an instrumented FCEUX to
catch behavioural regressions frame by frame.

**Base `bank_FF.asm` reference**: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

**Local docs source**: [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## Status

Preservation Source 1.0 is release-candidate complete. The annotated source
covers every major subsystem, unresolved interpretations remain explicit in the
unknowns registry, and the complete validation matrix is available through
`make preservation-audit`. See
[`docs/preservation_source_1_0.md`](docs/preservation_source_1_0.md) for the
release contract and evidence summary.

The source is split into address-ordered subsystem modules containing real 6502
instructions and ca65 data directives. Further reverse engineering can deepen
provisional annotations without weakening the preservation target.

Modules are divided at natural procedure and data boundaries and remain below
600 lines. [`docs/source_layout.md`](docs/source_layout.md) is the detailed
address-to-file map.

Repeated domain operations use a small set of byte-preserving ca65 macros under
`src/macros/`; the project deliberately avoids hiding ordinary 6502 instructions
behind generic syntax aliases. See [`docs/macros.md`](docs/macros.md).

Symbols are named by program role rather than ROM address. The `sub_`,
`handler_`, `loc_`, and `bra_` prefixes distinguish callable subroutines from
dispatch handlers and internal control flow; see [`docs/naming.md`](docs/naming.md).

`make symbols` generates native ld65 source mappings for Mesen, FCEUX ROM/RAM
labels, breakpoint groups, and a standard watch list. See
[`docs/debugger_workflow.md`](docs/debugger_workflow.md).

Focused natural and controlled FCEUX traces cover scoring, lifecycle, ghost
release/mode changes, all intermissions, pause, player handoff, and sound byte
classes. See [`docs/runtime_trace_scenarios.md`](docs/runtime_trace_scenarios.md).

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

make split
make build
```

A successful run reports `[OK] Byte-identical ROM reproduced.`

Run `make split` once to validate the reference ROM and extract the ignored CHR,
maze, and audio assets described by `assets/manifest.json`. This command is
explicit because it overwrites those local asset files with the original data.

`make build` assembles `src/main.asm` and its modules directly with ca65/ld65.
It only checks that all required assets exist and never extracts or overwrites
them, so locally edited assets can be used for ROM hacks.
`make verify` performs the same native build and fails unless the result is
byte-identical to the reference ROM.

## Project Structure

```text
pacman_src/
|-- assets/
|   |-- manifest.json              # Tracked extraction ranges and checksums
|   `-- generated/                # Ignored CHR, maze, and audio payloads
|-- bin/                           # ca65 / ld65
|-- build/                         # Generated ROM and linker artifacts
|-- config/                        # Emulator/reference configuration
|-- docs/                          # Architecture and RE notes
|-- movies/                        # FM2 inputs for automated capture
|-- scripts/
|   |-- workflow/                  # Analysis and reporting tools
|   |-- build_native.py            # Native build and byte verification
|   |-- build_dev.py               # FCEUX bootstrap
|   |-- clean_artifacts.py         # Generated-artifact cleanup
|   `-- split_assets.py           # Validated ROM asset extractor
|-- src/
|   |-- main.asm                   # Address-ordered ca65 entrypoint
|   |-- system/
|   |-- game/
|   |-- rendering/
|   |-- audio/
|   |-- data/
|   `-- memory/
|-- Makefile
`-- Pac-Man (J) (V1.0) [!].nes   # Original ROM (not distributed)
```

`assets/generated/`, `build/`, `reference/`, `diffs/`, `reports/` and
`workflow/` are generated artifacts and are not tracked. See
[`docs/assets.md`](docs/assets.md) for the source-versus-asset policy.

## Make Targets

```bash
make                            # Same as `make build`
make build                      # Build the native ca65 ROM
make verify                     # Build and require byte-identity
make build-hack                 # Build the isolated default ROM-hack variant
make verify-hack                # Require only its documented byte difference
make validate-hack              # Prove its stage-5 behavior in FCEUX
make run-hack                   # Build and run the default hack
make init-expanded-assets       # Initialize editable maze/stage JSON once
make build-expanded             # Build the JSON-backed NROM-256 variant
make verify-expanded            # Verify assets, layout, and fixed-bank operands
make validate-expanded          # Prove expanded maze/stage access in FCEUX
make run-expanded               # Build and run the NROM-256 variant
make symbols                    # Generate Mesen/FCEUX debugger artifacts
make test-debug-symbols         # Test symbol parsing and conversion
make validate-symbols           # Prove live symbol lookup and named breakpoint
make lint                       # Check source, naming, docs, and Python syntax
make test                       # Run all focused Python workflow tests
make roundtrip-formats          # Decode/encode six binary format families
make preservation-audit         # Run the complete Preservation Source 1.0 gate
make trace-runtime              # Capture and validate focused gameplay traces
make validate-runtime-traces    # Revalidate existing gameplay traces
make run                        # Build and run the ROM in FCEUX
make split                      # Extract CHR, maze, and audio from the original ROM
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

1. Annotate a subsystem module under `src/` (or select a logical flattened
   chunk with `make chunk`).
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

- Some neutral RAM and branch names remain where evidence does not yet justify
  a more specific interpretation. They are intentionally retained and tracked
  in [`docs/unknowns.md`](docs/unknowns.md), rather than guessed for the 1.0
  release.
- Optional behavior-changing ROM variants must not replace the default
  byte-identical preservation build. The isolated workflow is documented in
  [`docs/rom_hack_variants.md`](docs/rom_hack_variants.md).

## Credits

- `bank_FF.asm` base reference: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)
- NES hardware documentation mirrored locally from [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## License

Reverse-engineering / preservation work for educational purposes. No original
ROM data is distributed with this repository. Original game rights belong to
Namco and Nintendo.
