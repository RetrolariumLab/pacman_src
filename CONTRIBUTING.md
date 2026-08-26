# Contributing to the Pac-Man NES Source Reconstruction

This repository treats the original game code, layout, data, and timing as a
source-reconstruction baseline. Read `docs/source_reconstruction_2_0.md` before
changing emitted bytes.

## Local Inputs

Use a legally obtained Japan V1.0 ROM matching SHA-1
`adb4d7d7d28c89ca177aad231e0fdad992c0fbfb`. Run `make split` once to create
the ignored CHR, maze, and audio files. Never add ROM images, extracted assets,
object files, PRG output, or files under `assets/generated/` to Git. The tracked
FM2 file contains controller input rather than game payload.

Additional official revision ROMs are optional local inputs unless a change
touches revision-specific source or the strict 2.0 release gate. Their exact
profiles and filenames are documented in `docs/multi_revision_builds.md`.

## Source Changes

Start with `docs/source_layout.md` to find the owning module and `docs/index.md`
to find the relevant subsystem notes. Preserve address order in `src/main.asm`.
Keep procedures and their owned small tables together; do not split files merely
to reduce line counts.

Use the vocabulary in `docs/naming.md` and the mechanically checked formatting
in `docs/assembly_style.md`. Source comments and project-authored documentation
are English. Put uncertain interpretations in `docs/unknowns.md` with an
evidence tag; do not turn a plausible guess into an unqualified fact.

For each coherent source change:

```bash
make format
make test
make verify
```

`make format` performs deterministic mechanical normalization and then runs
lint. Review semantic names, comments, contracts, and data changes manually.
If shared revision code changes, also run `make verify-revisions` with all seven
local reference ROMs available.

Every active colon label is covered by
`docs/provenance/label_renames.json`. Update its existing current target when
renaming a label. Add a `project_additions` record only when the new label has no
active counterpart in the imported `bank_FF.asm`; do not add inline `was:`
comments to the assembly source.

## Data Changes

Before editing a packed format, read `docs/data_formats.md`. Add or extend one
decoder/encoder and its focused tests when a format is not yet represented.
Run `make roundtrip-formats`; generated output under `build/` and `tmp/` must not
become a second source of truth.

Behavior-changing assets and code belong to the isolated hack or expanded-ROM
entrypoints described in `docs/rom_hack_variants.md` and
`docs/expanded_rom_assets.md`. They must not weaken the byte-identical default
build.

## Runtime Evidence

Use `make symbols` for debugger navigation. Recapture the relevant evidence with
`make trace-runtime`, `make trace-scoring`, or `make trace-evidence` after
changing control flow, state machines, timing-sensitive logic, debugger symbols,
or scenario-owned RAM.

Natural input evidence and controlled patches are not interchangeable. Every
controlled RAM mutation belongs in its scenario manifest and must appear in the
captured trace with its old value, new value, and reason.

## Reconstruction Gates

Before proposing a change to the default reconstruction, run:

```bash
make reconstruction-audit
```

Before a release or a change affecting official revision profiles, run the
strict gate with all seven exact local ROMs available:

```bash
make reconstruction-audit-2
```

These gates combine lint, unit tests, byte identity, data round trips, debugger
checks, and runtime evidence. Optional ROM hacks must retain separate entrypoints
and outputs; silently changing the default profile is not an acceptable shortcut.
