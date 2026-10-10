# Editing in Retrolarium

Pac-Man's data is edited in Retrolarium Studio, not by tools in this repository.
Open `pacman.rlj` at the repository root in the studio. It asks which revision
to edit, takes that revision's ROM (copied next to `pacman.rlj` and never
committed) and keeps the edits in `hack/<revision>/`. Builds go to
`.retrolarium/`. Neither folder is tracked; delete `hack/<revision>/` to start
over from the original.

## Revisions

| Revision            | ROM                                          | What it is                                        |
| ------------------- | -------------------------------------------- | ------------------------------------------------- |
| `japan-v10`         | `Pac-Man (J) (V1.0) [!].nes`                 | The original NROM-128 layout, fixed capacities.   |
| `japan-v11`         | `Pac-Man (J) (V1.1) [!].nes`                 | The same, for the v1.1 revision.                  |
| `japan-v10-nrom256` | `build/expanded/pacman.nes`, built from v1.0 | The [expanded variant](./expanded_rom_assets.md). |

The expanded revision is not a dump: the studio builds it from the v1.0 ROM with
`scripts/build/build_expanded_base.py` when the image is missing, which needs
the pinned toolchain of `config/toolchain.json`. Its second maze, its sound
streams (8 KiB instead of the original's packed slots) and its relocated tables
are what the expanded layout makes room for.

## What is edited

The kit's Pac-Man profile defines every view; this repository only names the
revisions and the asset split. Each revision offers:

- the maze, on the CHR tiles the game draws it with;
- the round tables: per-round speed, timing, pellet-threshold and release-target
  sets, frightened time and fruit group;
- the 16 sound streams, with a piano roll and preview;
- the CHR graphics, actor frames and every palette;
- the title, attract, HUD, pause and intermission screens, and the game text;
- the attract demo's moves.

## Checking the repository

`make studio-check` runs `rltool studio check pacman.rlj`. In a throwaway copy
of the repository it prepares every revision, decodes and validates each
document and rebuilds each revision with no edits, requiring the original ROM
byte for byte. It needs the revisions' ROMs and the Retrolarium kit (`rltool` on
`PATH`, or `RLTOOL=...`), and never reads or writes `hack/` or `.retrolarium/`.

## Source Reconstruction 3.0

`config/source_reconstruction_3_0.json` is the 3.0 release manifest. It names
the descriptor, the profile and the revisions, the kit and studio versions the
release is checked with, and every removed editor with the view that replaced
it. `make source-3-audit` runs studio-check with `--release`, which also checks
that section against the descriptor and the running kit; `make source-3-check`
runs the Source 2.2 functional gate first. The manifest stays in `development` with the kit unpinned
until Retrolarium publishes its first tags.
