# Expanded NROM-256 ROM

The expanded variant is an optional NROM-256 build with 32 KiB of PRG. It does
not replace the default byte-identical build or the fixed-size demonstration
hack.

```text
$8000..$819F  original stage-1 maze RLE
$81A0..$82D5  relocated stage parameters
$82D6..$8475  stage-2-and-later maze RLE
$8476..$848E  stage-aware maze selector
$848F..$84AE  generated 16-entry sound pointer table
$84AF..$A4AE  8 KiB variable-length sound region
$A4AF..$A71E  actor tile/attribute mappings and OAM offsets
$A71F..$A79D  title/gameplay/dynamic palette collection
$A79E..$ABAF  title/text/HUD/intermission visual collection
$ABB0..$BFFF  $FF free space for future assets
$C000..$FFF7  original fixed PRG bank
$CEB8..$CF8D  reviewed stage-table operand bytes target $81A0..$82D2
$E26E..$E277  fixed-width call to the expanded maze selector
$FFF8..$FFF9  maze pointer changed from $EC78 to $8000
$FFFA..$FFFF  original NMI, RESET, and IRQ vectors
```

The iNES header changes its PRG count from one 16 KiB bank to two. Mapper 0,
mirroring, CHR, code addresses, and vectors remain unchanged. The original maze
bytes remain in the fixed bank for layout stability. The expanded variant
duplicates them at `$8000` for stage 1 and selects the editable maze at `$82D6`
from stage 2 onward.

This is the `japan-v10-nrom256` revision of `pacman.rlj`: Retrolarium Studio
builds it from the v1.0 ROM and edits it like a dump, with the room the added
bank makes (a second maze, 8 KiB of sound). See [retrolarium.md](./retrolarium.md).

## Architecture decision

The preservation entrypoint fills the original NROM-128 PRG and must remain
byte-identical. A second maze, longer sound, and relocated stage, graphics,
palette, and screen data need additional capacity, so the project isolates them in the separate
`src/expanded/nrom256.asm` entrypoint and
`config/linker/nrom256_expanded.cfg` layout. The relocated data lives in the added PRG bank; the fixed bank continues to use shared game source and a
manifest-reviewed operand allowlist. Output, symbols, verification, and FCEUX
runtime evidence remain separate from the default build.

Post-link patching was rejected because it would hide executable changes from
source and symbols. Enlarging the preservation build would break its container
identity, while opaque editable payloads would prevent reviewable codecs,
capacity checks, and round trips. The chosen boundary preserves the canonical
ROM and makes the expanded variant explicit. It does not imply expanded layouts
or profile-aware authoring for other official profiles.

## Building

```text
make build-expanded
make verify-expanded
make validate-expanded
make run-expanded
```

`make expanded-assets` (run by the build) writes the data, as the v1.0 ROM
holds it, into `build/expanded/assets/`: the original maze for stage 2 and
later, the stage parameters, the 16 sound streams with their pointer table,
the actor mappings, the palettes, and the screens. The build links the original
maze at `$8000`, stage parameters at `$81A0`, the second maze at `$82D6`, the
sound pointer table and streams at `$848F`, actor mappings at `$A4AF`,
palettes at `$A71F`, and screen assets at `$A79E`. All other artifacts remain
below `build/expanded/`. `scripts/build/build_expanded_base.py` makes the same
image from a given v1.0 ROM; it is the build Retrolarium runs, and the kit
pins the image's SHA-256.

`make verify-expanded` requires:

- a mapper-0 iNES image with two PRG banks and the exact declared 8 KiB CHR;
- both maze copies, stage parameters, selector, sound pointers, streams, actor
  mappings, the 127-byte palette collection, and the 1042-byte screen bundle
  at contiguous manifest-declared addresses;
- only `$FF` free space after the final declared asset;
- an exact manifest of 30 stage-table operand bytes, ten fixed-width selector
  call-site bytes, twenty actor-table operand bytes, fourteen palette-table
  operand bytes, two active-sound-table bytes,
  forty-four screen-table operand bytes, and two maze-pointer bytes
  changed in the fixed bank, with every other byte preserved.

`make validate-expanded` additionally loads expanded-ROM symbols in FCEUX,
builds a probe image in `build/expanded-probe/` whose round 2 frightened time
is 14 (it is 6) and whose first pellet note is `$B1`, so the run can tell the
relocated data from the original. It uses a controlled stage-index patch to
enter stage 2, proves that the live decompressor pointer selects `$82D6`, and
requires the second profile's frightened duration to match both expanded data
and runtime RAM. It then requests pellet slot 04 and proves its runtime cursor
and probed note originate from the expanded sound table at `$848F`. Finally, it
compares all 32 bytes of live FCEUX PPU palette RAM with the relocated gameplay
palette and the documented stage-fruit override at `$3F1D`. It also observes the first title-logo tile from `$A79E`
at live PPU `$20E5`.

## Extending the layout

More data can move into the free space after the screens. Each moved table
needs a linker symbol, bounds validation, a runtime consumer, and a resource
override for the `japan-v10-nrom256` revision in the kit's Pac-Man profile, so
Retrolarium finds it there. Keep generated binary and ROM output ignored.
