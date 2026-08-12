# ca65 Macro Policy

Macros in this project describe recurring 6502 operations with a stable,
domain-level meaning. They expand inline: they do not add calls, change timing,
or create a second runtime implementation.

Every macro refactor must still pass `make verify` and reproduce the reference
ROM byte for byte.

## Current Macros

| Macro | Purpose | Current uses |
|---|---|---:|
| `LoadPointer destination, source` | Load a little-endian 16-bit address into a zero-page pointer | 15 |
| `SetPpuAddress address` | Reset the PPU latch and select a fixed VRAM address | 10 |
| `SetPpuAddressFrom source` | Select a VRAM address stored high-byte first in two RAM bytes | 8 |
| `PrepareScoreHud address, stride` | Initialize the score-HUD destination and row step | 2 |
| `ComposeActorOamEntry tiles, attrs` | Emit the shared OAM tile/attribute composition block | 4 |

The indexed power-pellet PPU-address write remains explicit because its two
table operands do not match the consecutive-RAM form.

## What Should Not Become a Macro

- a generic replacement for every `LDA`/`STA` pair;
- one-off instruction sequences;
- code that is only textually similar but has different state or flag
  invariants;
- branches, timing-sensitive loops, or hardware accesses whose mechanics are
  clearer when visible;
- unresolved code whose apparent abstraction is still a hypothesis.

In particular, zeroing several unrelated fields remains ordinary 6502 code.
The sound control handlers also remain explicit for now: their common setup is
small, while their masks and destination fields have different semantics.

## Review Checklist

1. The macro name must explain an operation, not merely abbreviate syntax.
2. Inputs, outputs, clobbers, and important final flags must be documented.
3. Expansion must preserve instruction order and addressing modes exactly.
4. Labels and branch targets must remain outside opaque macro internals unless
   local labels are essential and documented.
5. `make verify`, `make chunk`, and the procedure manifest must continue to
   work after adoption.
