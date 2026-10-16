# Contributing to the Pac-Man NES Source Reconstruction

The original game's code, layout, data and timing are the baseline: the default
build must stay byte for byte identical to the Japan v1.0 ROM.

## Local inputs

Use a legally obtained Japan v1.0 ROM (SHA-1
`adb4d7d7d28c89ca177aad231e0fdad992c0fbfb`) and run `make split` once. Never add
ROM images, extracted assets, object files or anything under `assets/generated/`
or `build/` to Git. The tracked `.fm2` movie holds controller input, not game
data. The other official revisions' ROMs are optional; their names are in
`config/revisions.json` and `docs/multi_revision_builds.md`.

## Source changes

Start with `docs/source_layout.md` to find the module and `docs/index.md` for
the subsystem notes. Keep `src/main.asm` in address order and procedures with
the small tables they own. Use the names of `docs/naming.md` and the layout of
`docs/assembly_style.md`; comments and documentation are in English. Record an
uncertain reading in `docs/unknowns.md` rather than presenting a guess as fact.

For each change:

```bash
make format
make test
```

Run `make test-full` (MAME) after changing control flow, state machines or
anything timing-sensitive. Behaviour-changing work must not weaken the default
build. Data is
edited in Retrolarium Studio (`docs/retrolarium.md`).

`make hooks` installs Git hooks that check commits and pushes for words that
must not be published and run `make lint` before each commit.
