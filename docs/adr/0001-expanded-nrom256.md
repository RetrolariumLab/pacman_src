# ADR 0001: Isolate the Expanded NROM-256 Build

Status: accepted

## Context

The preservation entrypoint fills the original NROM-128 PRG and must remain
byte-identical. Editable mazes, stage data, sound, graphics, palettes, and
screens need additional capacity, but changing the default mapper layout would
weaken the preservation contract.

## Decision

The expanded build uses the separate `src/expanded/nrom256.asm` entrypoint and
`config/linker/nrom256_expanded.cfg` layout. Generated JSON-derived assets live
in the added PRG bank; the fixed bank continues to use shared game source and a
manifest-reviewed operand allowlist. Its output, verification, symbols, and
FCEUX runtime gate remain separate from the default build.

## Alternatives

Post-link patching was rejected because it would hide executable changes from
source and symbols. Enlarging the preservation build was rejected because it
would change its container identity. Keeping editable payloads in opaque binary
blobs was rejected because the authoring formats and capacities must remain
reviewable and round-trippable.

## Consequences

The canonical ROM remains unchanged, while the expanded variant has an explicit
architecture and validation boundary. Expanded layouts for other official
profiles are not implied; profile-aware authoring remains excluded from the 2.1
scope until each profile receives its own capacity and runtime contract.
