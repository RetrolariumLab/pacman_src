# Pac-Man NES Source Reconstruction

Reverse-engineering and byte-identical reconstruction of seven official NES
Pac-Man revisions from one shared ca65 source, with Japan V1.0 retained as the
default preservation baseline.

The project is an annotated, native ca65 reconstruction of the game's single
6502 PRG bank, plus tooling that rebuilds the ROM, compares it byte for byte
against the original, and replays a longplay movie in an instrumented FCEUX to
catch behavioural regressions frame by frame.

**Base `bank_FF.asm` reference**: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

**Local docs source**: [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## Status

Source Reconstruction 2.0 is the current tagged release. It retains the 1.0
preservation contract and adds the completed content-authoring pipeline, seven
byte-identical official revision profiles, and strict regional runtime gates. See
[`docs/source_reconstruction_2_0.md`](docs/source_reconstruction_2_0.md) for the
release contract. The release tags are `source-reconstruction-1.0` and
`source-reconstruction-2.0`.

The annotated source covers every major subsystem, milestone 23 has resolved
every registered unknown, and the complete validation matrix is available
through `make reconstruction-audit-2`. Future uncertainty remains governed by
the evidence rules in the unknowns registry. See
[`docs/source_reconstruction_1_0.md`](docs/source_reconstruction_1_0.md) for the
original preservation contract and evidence summary.

The optional NROM-256 content-authoring workflow is complete. Four focused
local applications edit sound and music, the maze, CHR and actor mappings,
palettes, screens, English game text, HUD data, and intermission visuals. They
share validated ignored-local assets and one deterministic expanded-ROM build
pipeline. A future unified Qt application is tracked as a low-priority
convenience milestone; it is not required to use or maintain the current tools.

Seven official cartridge profiles rebuild byte-identically from the shared
source. `make verify-revisions` checks every locally available reference, while
`make smoke-regional-revisions` boots the USA Namco and European profiles in
FCEUX and validates their regional title/OAM behavior. ROM images remain local
and ignored.

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
The complete import-to-current label history is maintained separately in
[`docs/provenance/label_renames.json`](docs/provenance/label_renames.json).

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

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for local-input policy, assembly naming
and formatting rules, evidence expectations, and the validation gates required
for source, data, or revision changes.

## Quick Start

```bash
git clone <repo>
cd pacman_src

# Place the original ROM in the project root:
#   Pac-Man (J) (V1.0) [!].nes

make split
make verify
```

A successful verification reports
`[OK] Byte-identical ROM reproduced from native ca65 source.`

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
|-- .editorconfig                  # Cross-editor text and ASM indentation rules
|-- CONTRIBUTING.md                # Change policy and validation workflow
|-- assets/
|   |-- manifest.json              # Tracked extraction ranges and checksums
|   `-- generated/                 # Ignored CHR, maze, and audio payloads
|-- bin/                           # ca65 / ld65
|-- build/                         # Generated ROM and linker artifacts
|-- config/                        # Emulator/reference configuration
|-- docs/                          # Architecture and RE notes
|-- movies/                        # FM2 inputs for automated capture
|-- scenarios/                     # Runtime, scoring, and revision smoke cases
|-- scripts/
|   |-- workflow/                  # Analysis and reporting tools
|   |-- build_native.py            # Native build and byte verification
|   |-- build_dev.py               # FCEUX bootstrap
|   |-- sound_studio.py            # Music and sound editor
|   |-- maze_studio.py             # Maze editor
|   |-- graphics_studio.py         # CHR, actor, and palette editor
|   |-- screen_studio.py           # Screen, text, HUD, and intermission editor
|   |-- clean_artifacts.py         # Generated-artifact cleanup
|   `-- split_assets.py            # Validated ROM asset extractor
|-- src/
|   |-- main.asm                   # Address-ordered ca65 entrypoint
|   |-- main_hack.asm              # Isolated behavior-changing entrypoint
|   |-- main_expanded.asm          # JSON-backed NROM-256 entrypoint
|   |-- nrom128_prg_only.cfg       # Reference linker layout
|   |-- nrom256_expanded.cfg       # Expanded linker layout
|   |-- macros/                    # Byte-preserving ca65 abstractions
|   |-- system/
|   |-- game/
|   |-- rendering/
|   |-- audio/
|   |-- data/
|   `-- memory/
|-- Makefile
`-- Pac-Man (J) (V1.0) [!].nes     # Original ROM (not distributed)
```

`assets/generated/`, `build/`, `reference/`, `diffs/`, `reports/`, and the
root-level `workflow/` analysis output are generated artifacts and are not
tracked. The source tools under `scripts/workflow/` are tracked. See
[`docs/assets.md`](docs/assets.md) for the source-versus-asset policy.

## Make Targets

```bash
make                                    # Same as `make build`
make build                              # Build the native ca65 ROM
make verify                             # Build and require byte-identity
make build-revision REVISION=europe     # Build one official revision
make verify-revision REVISION=europe    # Verify one official revision
make verify-revisions                   # Verify every available official revision
make smoke-regional-revisions           # Boot USA Namco and Europe in FCEUX
make build-hack                         # Build the isolated default ROM-hack variant
make verify-hack                        # Require only its documented byte difference
make validate-hack                      # Prove its stage-5 behavior in FCEUX
make run-hack                           # Build and run the default hack
make init-expanded-assets               # Initialize all editable local JSON once
make build-expanded                     # Build the JSON-backed NROM-256 variant
make verify-expanded                    # Verify assets, layout, and fixed-bank operands
make validate-expanded                  # Prove expanded assets are consumed in FCEUX
make run-expanded                       # Build and run the NROM-256 variant
make sound-studio                       # Open the local slot editor and piano roll
make maze-studio                        # Open the local 27x22 CHR-backed maze editor
make graphics-studio                    # Open the local CHR and metasprite editor
make screen-studio                      # Open the title, text, HUD, and intermission editor
make describe-sound SOUND_SLOT=4        # Inspect decoded musical notes
make preview-sound SOUND_SLOT=4         # Render an ignored WAV preview
make import-midi MIDI_FILE=x.mid        # Import monophonic MIDI to ignored JSON
make symbols                            # Generate Mesen/FCEUX debugger artifacts
make test-debug-symbols                 # Test symbol parsing and conversion
make validate-symbols                   # Prove live symbol lookup and named breakpoint
make format                             # Normalize ca65 assembly source style
make lint                               # Check assembly, naming, docs, and Python syntax
make test                               # Run all focused Python workflow tests
make roundtrip-formats                  # Decode/encode six binary format families
make reconstruction-audit               # Run the complete Source Reconstruction 1.0 gate
make reconstruction-audit-2             # Run the strict Source Reconstruction 2.0 gate
make trace-scoring                      # Capture semantic scoring events
make validate-scoring-trace             # Revalidate an existing scoring trace
make trace-runtime                      # Capture and validate focused gameplay traces
make validate-runtime-traces            # Revalidate existing gameplay traces
make trace-evidence                     # Recapture resolved research evidence
make validate-evidence                  # Revalidate existing evidence
make run                                # Build and run the ROM in FCEUX
make split                              # Extract CHR, maze, and audio from the original ROM
make build-dev                          # Check tools and clone/build FCEUX if needed
make reference                          # Capture the reference set from the original ROM
make analyze COUNT=32                   # Run RTS reverse-engineering analysis
make chunk START=260 LINES=60           # Prepare a rename/analysis chunk
make clean                              # Remove local build and analysis artifacts
make help                               # Show the public targets
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

## Project Boundaries

- The unknowns registry preserves resolved research evidence and remains the
  canonical place for any future open findings. Neutral names are required
  whenever evidence is incomplete instead of guessing a semantic role.
- `make verify` permanently represents the byte-identical Japan V1.0 baseline.
  Behavior-changing work is already supported through the isolated fixed-size
  workflow in [`docs/rom_hack_variants.md`](docs/rom_hack_variants.md) and the
  NROM-256 JSON asset pipeline in
  [`docs/expanded_rom_assets.md`](docs/expanded_rom_assets.md).

## Credits

- `bank_FF.asm` base reference: [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)
- NES hardware documentation mirrored locally from [Nesdev Wiki](https://www.nesdev.org/wiki/Nesdev_Wiki)

## License

Reverse-engineering / preservation work for educational purposes. No original
ROM data is distributed with this repository. Original game rights belong to
Namco and Nintendo.
