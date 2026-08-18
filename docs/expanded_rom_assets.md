# Expanded ROM and JSON Assets

The expanded variant is an optional NROM-256 build with 32 KiB of PRG. It does
not replace Preservation Source 1.0 or the fixed-size demonstration hack.

```text
$8000..$819F  original stage-1 maze RLE
$81A0..$82D5  JSON-generated stage parameters
$82D6..$8475  JSON-generated stage-2-and-later maze RLE
$8476..$848E  stage-aware maze selector
$848F..$84AE  generated 16-entry sound pointer table
$84AF..$A4AE  8 KiB variable-length JSON sound region
$A4AF..$BFFF  $FF free space for future assets
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

## Editable asset workflow

Initialize the ignored local JSON files exactly once:

```text
make init-expanded-assets
```

This decodes `assets/generated/maze/maze.rle` into `hacks/local/maze.json` for
the stage-2-and-later layout and the reference `$EB42..$EC77` region into
`hacks/local/stage_parameters.json`. It also decodes all 16 manifest-managed
streams into `hacks/local/sound_streams.json`. The demonstrations change
first-level frightened duration from 7 to 14 and the first slot-04 pellet note
from `$01` to `$B1`. Existing JSON files are left untouched, protecting local
edits from an accidental bootstrap rerun.

Then build or validate the variant:

```text
make build-expanded
make verify-expanded
make validate-expanded
make run-expanded
```

Every build explicitly encodes all three JSON files through the documented codecs
into `build/expanded/assets/`, links the original maze at `$8000`, stage
parameters at `$81A0`, the editable maze at `$82D6`, and the sound pointer table
and streams at `$848F`. All other artifacts remain below `build/expanded/`. Missing or
structurally invalid JSON fails the build instead of falling back to extracted
binary data.

`make verify-expanded` requires:

- a mapper-0 iNES image with two PRG banks and the original CHR;
- both maze copies, stage parameters, selector, sound pointers, and streams at contiguous
  manifest-declared addresses;
- only `$FF` free space after the final declared asset;
- an exact manifest of 30 stage-table operand bytes, ten fixed-width selector
  call-site bytes, two active-sound-table bytes, and two maze-pointer bytes
  changed in the fixed bank, with every other byte preserved.

`make validate-expanded` additionally loads expanded-ROM symbols in FCEUX,
uses a controlled stage-index patch to enter stage 2, proves that the live
decompressor pointer selects `$82D6`, and requires the second profile's JSON
frightened duration to match both expanded data and runtime RAM. It then
requests pellet slot 04 and proves its runtime cursor and edited note originate
from the expanded sound table at `$848F`.

## Extending the pipeline

Additional JSON codecs can allocate data after the maze in `HACK_BANK`. Each
asset needs a deterministic encoder, a linker symbol, bounds validation, and a
runtime consumer before it is considered connected. Keep generated binary and
ROM output ignored; only schemas, tooling, and documentation belong in Git.
