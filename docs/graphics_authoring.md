# Graphics Studio

Run the local editor from the repository root:

```text
make graphics-studio
```

The editor loads the extracted 8 KiB CHR-ROM and saves changes to
`hacks/local/pacman.chr`. That destination is ignored by Git. If it already
exists, the editor resumes it; deleting it returns the next session to the
original extracted graphics.

The left pane exposes both 256-tile pattern tables. Background tiles are
`$000..$0FF`; sprite tiles are `$100..$1FF`. Select a tile, choose one of its
four 2bpp pixel values, and paint in the center pane. The NES color picker only
changes the editor preview: CHR stores pixel values, not palette colors.

The actor editor starts from the PRG table at `$DB59`. It previews all 64
standard and 13 alternate four-tile frames and reports each sprite's tile,
palette, horizontal/vertical flip flags, priority bit, and signed OAM offset.
For each quadrant, tile ID, palette selector, priority, and flip flags are
editable and saved atomically to `hacks/local/actor_sprites.json`. The expanded
asset pipeline validates and packs that document into the original fixed
624-byte layout at `$A4AF`. The fixed-bank OAM builder reads the expanded copy
through a reviewed operand manifest. Shared OAM offsets remain read-only because
the engine assumes their 16x16 arrangement.

`Build expanded ROM` saves the CHR atomically and runs `make verify-expanded`
with that exact file declared as `GENERATED_CHR`, plus the actor JSON. Verification requires an
8 KiB CHR image, the exact declared CHR payload in the built ROM, and the normal
expanded-layout, actor payload, and fixed-bank invariants. `Run in FCEUX` performs that check
before launching the emulator.

The preservation build remains independent:

```text
make verify
```

It always uses `assets/generated/chr/pacman.chr` and must continue reproducing
the original ROM byte for byte.
