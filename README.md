# Pac-Man NES Source Reconstruction

The 6502 source of the Famicom Pac-Man, rebuilt from the cartridge as readable
ca65 modules: seven official revisions assemble from one shared source, each
byte for byte identical to its ROM, with Japan v1.0 as the default.

**Base `bank_FF.asm` reference**:
[cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

## Status

Source Reconstruction 3.1. The annotated source covers every subsystem and no
registered unknown is open ([`docs/unknowns.md`](docs/unknowns.md)). Editing
happens in Retrolarium Studio: open `pacman.rlj` to edit the maze, round tables,
sound, graphics, palettes, screens, text and the attract demo of v1.0 or v1.1
([`docs/retrolarium.md`](docs/retrolarium.md)). Expanded ROMs and hacks return
with extended editing in Retrolarium in a later release; 3.0 had an expanded
NROM-256 variant and a stage-5 hack.

3.1 keeps only what builds and checks the source. The earlier releases' audits,
runtime traces, analysis tools and the FCEUX tooling remain in the history (tags
`source-reconstruction-1.0` to `3.0`).

## Quick start

You need Python 3, GNU Make and Retrolarium Kit (`rltool` on `PATH`, or
`RLTOOL=...`); the kit supplies the pinned ca65 and ld65 of
`config/toolchain.json`. Copy your `Pac-Man (J) (V1.0) [!].nes` into the
repository root, then:

```bash
make split     # cut the header, CHR, maze and audio out of the ROMs (once)
make verify    # build and compare byte for byte
```

`make split` (`rltool assets split`, Retrolarium Kit) writes the ignored assets
under `assets/generated/` from every ROM that is here; `assets/manifest.json`
names the ROMs and the assets. It overwrites them, so run it again only to
start over. `make build` uses whatever assets are there, edited or not;
`make verify` fails unless the ROM is identical to the original.

## Targets

```bash
make build / verify                       # the v1.0 ROM
make build-revision REVISION=europe       # one official revision (assets/manifest.json)
make verify-revision REVISION=europe      #   and byte for byte
make verify-revisions                     # every revision whose ROM is here
make build-relocated                      # every module moved by a few bytes
make studio-check                         # open and rebuild every pacman.rlj revision
make test                                 # the quick suite
make test-full                            # the full suite, with MAME
make golden                               # the longplay's reference values
make lint / format                        # the house style (Retrolarium Kit)
make hooks                                # the Git hooks
make clean                                # remove build/
```

## Tests

`make test` (about half a minute) runs the unit tests of the build scripts,
verifies every build byte for byte against the ROMs that are present (the seven
revisions), builds the relocated variant and runs the studio check.

`make test-full` (about four minutes) adds the longplay
`movies/pacman_j_longplay.fm2`, played in MAME on the relocated build, where
every module sits a few bytes away from its original address. At its checkpoints the game's state (mode, lives, round,
extra-life flag, score) must equal what the original ROM gives, as recorded in
`movies/pacman_j_longplay.check.json`. Name MAME with `MAME=<path>` or
`RETROLARIUM_MAME`.

Record the reference values with `make golden` after changing the movie or the
cells it checks. Movies are recorded in FCEUX (`.fm2`); Retrolarium Kit plays
them in MAME frame for frame (`rltool movie`).

## Layout

```text
src/            ca65 source: main.asm, the modules, macros, revisions,
config/         revisions, linker layout, toolchain, lint, the Retrolarium
                profile and names
assets/         manifest.json (the generated assets are ignored)
scripts/build/  build, split, variants, relocation and verification scripts
tests/build/    their unit tests
movies/         the longplay and its check
docs/           how the game works and how the source is written
pacman.rlj      the Retrolarium project
```

`build/`, `assets/generated/`, the ROMs, and Retrolarium's `hack/` and
`.retrolarium/` are ignored.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Credits

- `bank_FF.asm` base reference:
  [cyneprepou4uk/NES-Games-Disassembly - Pac-Man](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man)

## Trademarks

This is an unofficial reconstruction, made for study and preservation. The game,
its title and its characters are trademarks of their owners, who have not made,
licensed or endorsed this project. It contains no part of the game: you need
your own copy of Pac-Man to build anything.

## License

No original ROM data is distributed with this repository. The repository does
not currently grant an open-source license for project-authored files; see
[`docs/licensing.md`](docs/licensing.md). Original game rights remain with their
respective owners.
