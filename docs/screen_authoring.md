# Screen, Text, and Intermission Authoring

Screen Studio is the local Tkinter editor for screen-oriented data that does
not belong in the maze or CHR editors:

```text
make init-expanded-assets
make screen-studio
```

The ignored `hacks/local/screens.json` document contains the 23 by 6 title
logo tilemap, six title PPU packets, title attributes, menu and player-count
glyphs, ten pointer-selected attract packets, HUD and pause blocks, and the
visual tile tables used by intermissions. The intermission handler tables are
catalogued read-only because their words are executable code pointers, not
screen content.

The Title Screen tab composes a 32 by 30 nametable from the original CHR and
the active palette JSON. Its logo rectangle can be painted from the background
tile bank. The remaining tabs edit addressed text packets, fixed-size HUD data,
and bounded intermission tile tables. Printable tile IDs may be entered as
characters; arbitrary values use `<XX>` notation. Saving is atomic and rejects
changed engine dimensions, invalid PPU addresses, missing terminators, invalid
tile values, pointer-table edits, and data that exceeds its reserved budget.

Every actual Latin-font message also appears as a separately named English text
field. Host lowercase letters map to the game's uppercase `$41..$5A` glyphs;
digits, spaces, periods, and semicolons use their confirmed game tiles. Fields
retain their original widths and pad shorter text with spaces. Unsupported
characters and overlong strings are rejected rather than being converted into
unrelated logo or sprite tiles that share the surrounding numeric range.

## Expanded-bank allocation

The encoder always emits a 1042-byte bundle at `$A79E..$ABAF`. Variable-length
title and attract packets live in fixed 256-byte and 512-byte regions;
attract-mode pointers are recalculated on every build. Fixed-size consumers
read named subregions in the added bank. The normal `make verify` path does not
define `PACMAN_EXPANDED_SCREENS`, so it continues to assemble the original
tables and reproduce the reference ROM byte for byte.

`Build expanded ROM` runs `make verify-expanded`. `Run in FCEUX` verifies first
and then launches the ROM. The fixed-bank verifier permits only the reviewed
operand changes in `screen_fixed_bank_changes`. `make validate-expanded`
additionally observes the first JSON title tile being copied from `$A79E` to
PPU `$20E5`, alongside the existing maze, tuning, sound, and palette evidence.
