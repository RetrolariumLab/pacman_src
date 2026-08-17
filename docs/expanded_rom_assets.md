# Expanded ROM and JSON Assets

The expanded variant is an optional NROM-256 build with 32 KiB of PRG. It does
not replace Preservation Source 1.0 or the fixed-size demonstration hack.

```text
$8000..$BFFF  HACK_BANK: generated assets followed by $FF free space
$C000..$FFF7  original fixed PRG bank
$FFF8..$FFF9  maze pointer changed from $EC78 to $8000
$FFFA..$FFFF  original NMI, RESET, and IRQ vectors
```

The iNES header changes its PRG count from one 16 KiB bank to two. Mapper 0,
mirroring, CHR, code addresses, and vectors remain unchanged. The original maze
bytes remain in the fixed bank for layout stability but are no longer selected
by the expanded variant.

## Editable asset workflow

Initialize the ignored local JSON exactly once:

```text
make init-expanded-assets
```

This decodes `assets/generated/maze/maze.rle` into
`hacks/local/maze.json`. If the JSON already exists, the command leaves it
untouched. This protects local edits from an accidental bootstrap rerun.

Then build or validate the variant:

```text
make build-expanded
make verify-expanded
make validate-expanded
make run-expanded
```

Every build explicitly encodes the JSON through the documented maze codec into
`build/expanded/assets/maze.rle`, links it at `$8000`, and writes all other
artifacts below `build/expanded/`. Missing or structurally invalid JSON fails
the build instead of falling back to the extracted binary.

`make verify-expanded` requires:

- a mapper-0 iNES image with two PRG banks and the original CHR;
- the generated maze at the beginning of the new bank;
- only `$FF` free space after that asset;
- the original `$C000..$FFFF` bank except for the two-byte maze pointer;
- a little-endian `$8000` pointer at CPU address `$FFF8`.

`make validate-expanded` additionally loads expanded-ROM symbols in FCEUX,
replays the standard movie to the first round, and proves that the runtime
pointer and linked asset symbol both resolve to `$8000`.

## Extending the pipeline

Additional JSON codecs can allocate data after the maze in `HACK_BANK`. Each
asset needs a deterministic encoder, a linker symbol, bounds validation, and a
runtime consumer before it is considered connected. Keep generated binary and
ROM output ignored; only schemas, tooling, and documentation belong in Git.
