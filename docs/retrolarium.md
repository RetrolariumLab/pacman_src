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

## The game's names and tables

Retrolarium keeps nothing taken from the game; this repository gives it what it
needs. `config/names.json` holds the game's own names (the ghosts and fruits) in
English. The studio and the kit read it when a project opens and show the names
as they are, untranslated; without it they show numbers instead. Its `guard`
list names what Retrolarium's own repositories must never contain.

`config/game_profile.json` is the game's Retrolarium profile: its revisions with
their hashes and, for each resource, where it lies in each revision's image and
which codec reads it. The kit reads it when it opens `pacman.rlj` or a project
made from it; Retrolarium keeps no copy.

`config/profile_tables.json` names, by label, the tables the kit reads from the
image built from this source. `rltool profile tables` prints their offsets in
each revision's build, the values of `config/game_profile.json`; `make
profile-check` (part of `make test`) compares the two, so a source change that
moves such a table fails until the profile is updated. The profile's other
offsets are not derived from labels yet.

## Studio and source

The studio builds a revision from its original ROM and the documents in
`hack/<revision>/`; it does not assemble `src/`. `make build` assembles `src/`
and never reads `hack/`. So an edit to the source shows in `make build` and
`make play`, not in the studio, and a studio edit stays in the studio's
documents until someone writes it into the source by hand. Use the studio for
content (maze, rounds, sound, graphics, text) and the source for code.

## Checking the repository

`make studio-check` runs `rltool studio check pacman.rlj --present`. In a
throwaway copy of the repository it prepares every revision whose ROM is here, decodes and validates each
document and rebuilds each revision with no edits, requiring the original ROM
byte for byte. It needs the revisions' ROMs and the Retrolarium kit (`rltool` on
`PATH`, or `RLTOOL=...`), and never reads or writes `hack/` or `.retrolarium/`.
