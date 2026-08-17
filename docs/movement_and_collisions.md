# Movement, Tile Probes, and Collisions

This document describes the shared coordinate and tile-probe pipeline used by
Pac-Man and the ghosts, then follows Pac-Man input through movement and actor
collision handling. The relevant source is split across:

- `src/game/pacman_movement.asm`: input, queued turns, speed selection, stepping,
  tunnel palette, and horizontal wrap;
- `src/rendering/tile_coordinates.asm`: world-to-PPU conversion and tile sampling;
- `src/game/turn_candidates.asm`: legal ghost-turn candidate collection;
- `src/game/round/runtime.asm`: Pac-Man/ghost/fruit collision outcomes;
- `src/game/round/gameplay_loop.asm`: per-frame ordering.

## Coordinates and Directions

Each actor position is a four-byte record: X high/fraction followed by Y
high/fraction. The high bytes are world pixel coordinates. Movement updates the
fractional byte first and folds its carry or borrow into an integer-pixel step
budget. The four direction values are shared by movement and tile probes:

| Value | Direction | Neighbor sample |
| --- | --- | --- |
| `0` | up | current row minus one nametable row |
| `1` | left | current tile minus one column |
| `2` | down | current row plus one nametable row |
| `3` | right | current tile plus one column |

Adding two modulo four gives the reverse direction. `ram_direction_1` is the
requested or queued Pac-Man direction; `ram_direction_2` is the direction
currently being moved.

## Frame Boundary and Tile-Probe Pipeline

During sprite preparation, `sub_build_object_neighbor_ppu_positions` converts
Pac-Man and all four ghost positions to PPU addresses and caches the current,
up, left, down, and right probes. The conversion rounds `(coordinate - 4)` to
an eight-pixel tile grid. Player two receives the observed `$0800` nametable
offset.

The following NMI calls `sub_sample_tiles_at_obj_ppu_positions`. It performs the
required PPUDATA dummy read, then stores 21 tile values: Pac-Man's current tile
and four directional neighbors for each of the five actors. Gameplay on the
next unpaused frame consumes that cached snapshot. Thus movement and ghost AI
do not synchronously read the PPU and must preserve this build -> NMI sample ->
gameplay consume ordering.

The row helpers operate on a copied PPU address. Every observed caller supplies
the fixed nametable row stride `$0020`; this is the evidence that resolved
`CODE-003` in the unknowns registry.

## Pac-Man Input and Queued Turns

Live input masks the joypad to the D-pad and maps the first set input bit to the
shared direction encoding. With no D-pad input, the current direction becomes
the request. Demo mode obtains `[duration, direction]` pairs from its table and
enters the same request-validation path, so autoplay does not bypass movement
legality or stepping.

An opposite-direction request can reverse immediately between tile centers.
Other requests are checked against the cached neighbor tile and normally remain
queued until `(X | Y) & 7 == 0`. A directional tile is considered open by this
path when its high nibble is zero. On committing a queued turn, the routine adds
two integer substeps to the remaining budget; this is original timing behavior,
not a general acceleration rule.

## Speed and Per-Pixel Stepping

The speed-profile offset depends on the shared frightened state and Pac-Man's
cached current tile. Separate parameter pairs cover floor, normal pellet, and
power-pellet movement. Each pair contains a fractional delta and an integer
pixel count.

The fractional component is added for right/down and subtracted for left/up.
Carry or borrow is combined with the integer count, and the resulting budget is
consumed one high-byte pixel at a time. At grid boundaries, the directional
neighbor sample can stop and snap the active axis to a four-pixel boundary.
Every substep also reaches tunnel handling and the queued-turn check.

## Tunnel Behavior

Tunnel behavior is based on Pac-Man's X high byte:

- X below `$18` or at least `$A9` sets sprite-palette bit `$20`;
- X in `$18..$A8` clears that bit;
- X below `$0B` wraps to `$BF`;
- X at least `$C0` wraps to `$0B`.

These palette and wrap thresholds are independent: the broader palette region
starts before the actual wrap boundary.

## Ghost Turn Candidates

`sub_collect_valid_turn_candidates` scans the four cached directional samples
through a caller-supplied pointer. It accepts the two caller-supplied special
tile classes or tiles whose upper five bits are clear, removes the direction
opposite the ghost's current heading, and compacts the remaining direction
indices to the front of `zp_work11..zp_work14`. Unused entries are `$FF`.
Target selection can therefore consume a dense candidate list without treating
reverse as an ordinary junction choice.

## Actor Collision Pipeline

After Pac-Man and ghost updates, the gameplay loop checks four ghost position
records followed by the fruit record. The scan is skipped when the current
player's pellet count is zero. Each eligible slot must pass separate X and Y
windows below ten pixels and then the preserved narrow combined-distance gate.
The arithmetic deliberately retains the original carry behavior; it should not
be rewritten as a generic rectangle or Manhattan-distance helper without a
trace proving equivalence.

A confirmed overlap has three outcomes:

| Candidate | Condition | Outcome |
| --- | --- | --- |
| ghost | its bit is absent from the frightened mask | select death script and initialize death animation |
| ghost | its bit is present in the frightened mask | select the chained BCD award and popup, mark the ghost eaten, request SFX, select post-eat pause, then commit score |
| fruit | availability/popup latch is clear | latch the fruit popup, select the stage award and tile, request SFX, then commit score |

Fruit scoring does not select the post-eat pause script. Ghost awards advance
`ram_kill_cnt`, which indexes the 200/400/800/1600 chain documented in
`score_and_bonus.md`.

## Preservation Invariants

- Keep the direction encoding and reverse-by-two relationship unchanged.
- Keep cached probe order current/up/left/down/right and the eight-byte
  per-object address stride unchanged.
- Preserve the asynchronous build -> NMI sample -> gameplay consume pipeline.
- Do not replace high-bit tile-class tests with semantic guesses lacking trace
  evidence.
- Preserve fractional carry/borrow, turn-budget adjustment, snap points, and
  tunnel thresholds exactly.
- Preserve collision scan order, carry behavior, state filtering, and tail jumps
  into the score transaction.
