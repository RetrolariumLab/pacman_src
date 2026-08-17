# Expanded ROM and JSON Assets

The expanded variant is an optional NROM-256 build with 32 KiB of PRG. It does
not replace Preservation Source 1.0 or the fixed-size demonstration hack.

```text
$8000..$819F  JSON-generated maze RLE
$81A0..$82D5  JSON-generated stage parameters
$82D6..$BFFF  $FF free space for future assets
$C000..$FFF7  original fixed PRG bank
$CEB8..$CF8D  reviewed stage-table operand bytes target $81A0..$82D2
$FFF8..$FFF9  maze pointer changed from $EC78 to $8000
$FFFA..$FFFF  original NMI, RESET, and IRQ vectors
```

The iNES header changes its PRG count from one 16 KiB bank to two. Mapper 0,
mirroring, CHR, code addresses, and vectors remain unchanged. The original maze
bytes remain in the fixed bank for layout stability but are no longer selected
by the expanded variant.

## Editable asset workflow

Initialize the ignored local JSON files exactly once:

```text
make init-expanded-assets
```

This decodes `assets/generated/maze/maze.rle` into `hacks/local/maze.json` and
the reference `$EB42..$EC77` region into
`hacks/local/stage_parameters.json`. The demonstration stage profile changes
first-level frightened duration from 7 to 14. If either JSON already exists,
the command leaves that file untouched, protecting local edits from an
accidental bootstrap rerun.

Then build or validate the variant:

```text
make build-expanded
make verify-expanded
make validate-expanded
make run-expanded
```

Every build explicitly encodes both JSON files through the documented codecs
into `build/expanded/assets/`, links maze at `$8000` and stage parameters at
`$81A0`, and writes all other artifacts below `build/expanded/`. Missing or
structurally invalid JSON fails the build instead of falling back to extracted
binary data.

`make verify-expanded` requires:

- a mapper-0 iNES image with two PRG banks and the original CHR;
- maze and stage assets at their contiguous manifest-declared addresses;
- only `$FF` free space after the final declared asset;
- an exact manifest of 30 stage-table operand bytes and two maze-pointer bytes
  changed in the fixed bank, with every other byte preserved.

`make validate-expanded` additionally loads expanded-ROM symbols in FCEUX,
replays the standard movie to the first round, proves maze access through
`$8000`, and requires the first profile's JSON frightened duration to match
both the byte at `$81A1` and the value loaded into `ram_frightened_duration`.

## Extending the pipeline

Additional JSON codecs can allocate data after the maze in `HACK_BANK`. Each
asset needs a deterministic encoder, a linker symbol, bounds validation, and a
runtime consumer before it is considered connected. Keep generated binary and
ROM output ignored; only schemas, tooling, and documentation belong in Git.
