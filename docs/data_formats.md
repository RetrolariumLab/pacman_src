# Binary Data Format Round-Trips

Milestone 9 provides one JSON decoder/encoder implementation for six binary
format families. The preservation ROM and extracted assets remain the source of
truth; generated JSON is an editable inspection format, not an implicit build
input.

```text
make roundtrip-formats
```

The target first requires `make verify`, decodes each format into
`tmp/data_formats/*.json`, reloads that JSON, encodes it, and compares every
byte with the original region. All output stays ignored. Neither `make build`
nor `make verify` reads generated JSON or overwrites extracted assets.

For individual binary files, `scripts/data_formats.py` exposes explicit
`decode` and `encode` operations:

```text
python scripts/data_formats.py decode maze --input maze.rle --output maze.json
python scripts/data_formats.py encode maze --input maze.json --output maze.rle
```

The supported names are `stage`, `maze`, `sound`, `ppu`, `actors`, and
`intermission`. Intermission decode additionally needs
`--config config/data_formats.json` because its tables are non-contiguous in
the ROM; its input is the table bundle emitted by the round-trip workflow.

## Stage parameters

The `$EB42..$EC77` region is decoded into:

- 23 six-byte stage profiles with named fields;
- five 22-byte level parameter blocks;
- four eight-byte scatter/chase timing rows;
- seven two-byte pellet-threshold pairs;
- three four-byte ghost-release target sets;
- the special four-byte restart target set.

The encoder enforces every count and record width. It deliberately preserves
the adjacency between timing rows and threshold pairs because profile ID 4
reads an eight-byte window across that semantic boundary.

## Maze RLE

Each byte records a one-to-four tile run in bits 7–6 and a six-bit tile ID.
JSON contains both the original token boundaries and the expanded 27 by 22
tile rows. Encoding uses the tokens so different-but-equivalent RLE packings do
not silently change ROM bytes, and rejects disagreement between the tokens and
expanded rows.

## Sound streams

Every stream contains a four-byte prologue followed by note, duration, and
control records:

- `$00..$BF`: note byte plus duration;
- `$C0..$EF`: duration marker plus duration;
- `$F0` and `$F7..$FF`: stop;
- `$F1..$F6`: control opcode plus operand.

All 16 manifest-managed streams are decoded. Bytes after the first stop remain
in `trailing_bytes`; this preserves the two bytes after the pause-toggle `$F0`
and makes the `DATA-005` evidence visible rather than discarding it.

The same sound artifact also shows a named eight-byte initialized channel record
for every stream: arbitration state, two APU bytes, computed timer low,
timer-high/control, little-endian cursor, and remaining duration. The record
codec enforces the fixed stride used by the 16 runtime channel slots.

## Buffered PPU commands

The generic buffer grammar is represented as address/payload records:

```text
[address high][address low][payload...][$00] ... [$FF]
```

The encoder rejects addresses outside `$0000..$3FFF` and payload bytes `$00`
or `$FF`, which are reserved terminators. It preserves whether a packet used
the usual `$00` command terminator or the consumer's supported direct `$FF`
final terminator. Three representative empty, single, and multi-command streams
exercise the format round-trip; static producer fragments remain in ca65 source
because they are not complete runtime buffers.

## Actor sprite/OAM tables

The contiguous `$DB59..$DDC8` region becomes standard and alternate tile quads,
standard and alternate attribute quads, and four Y/X offset pairs. Counts are
fixed at 64/13/64/13 frame records plus four offsets, matching the four mode
paths used by `sub_build_oam_from_sprite_buffers`.

## Intermission tables

The workflow gathers eleven non-contiguous tables declared in
`config/data_formats.json`: scene dispatch/state pointers, animation
dispatch/state pointers, cycle tiles, pattern indexes, and banner tile quads.
Word tables are decoded as little-endian 16-bit handler addresses; byte tables
remain ordered values. The encoder rebuilds the same logical bundle and checks
all 84 source bytes.

## Editing policy

Generated JSON can be copied elsewhere and edited for investigation, then
encoded explicitly. Promoting an edited representation into preservation
source requires a separate reviewed source change and `make verify`. The
round-trip target itself is read-only with respect to ROM source and extracted
assets.
