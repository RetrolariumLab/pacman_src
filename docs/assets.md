# Generated Binary Assets

The repository keeps code and editable behavior tables as ca65 source. Opaque
original-game assets are not checked in as long `.byte` listings: they are
recreated locally from the reference ROM.

## Policy

Keep data in ASM when its fields are understood and a contributor can edit it
meaningfully. This includes stage profiles, speed/timer blocks, release
thresholds, pointer tables, note periods, and hardware vectors.

Extract data when it is an opaque authored asset without a trustworthy editor
or encoder. The current generated set is:

- the 8 KiB CHR-ROM;
- the 416-byte compressed maze stream at `EC78..EE17`;
- sixteen sound command streams at `F0AE..F427`.

The large unused `FF` bank tail is neither an asset nor a checked-in byte
listing. It is represented by a single ca65 `.res` directive.

## Manifest and Output

[`assets/manifest.json`](../assets/manifest.json) is tracked and records the
required ROM SHA-1 plus every source address, size, and output checksum.
`make split` validates all of those values before writing files under
`assets/generated/`. That directory is ignored by Git but deliberately
preserved by `make clean`, because it may contain local ROM-hack edits.

Generated files are consumed with `.incbin` by `src/data/maze.asm` and
`src/audio/streams.asm`. Labels remain in ASM, so code and pointer tables stay
navigable even though the payloads are local artifacts.

## Build Behavior

Extraction is intentionally explicit and potentially destructive:

```text
make split
```

This replaces local generated assets with the original ROM data. `make build`
and `make verify` only check that every manifest path exists; they never compare
or replace asset contents. If any file is absent, they fail with a message to
run `make split`. This makes it safe to edit extracted data for ROM hacks and
rebuild repeatedly without losing those changes.

If the maze format later receives a tested decoder/encoder and a readable
source representation, replace only `maze.rle` with that generated workflow.
Byte identity remains the acceptance gate.
