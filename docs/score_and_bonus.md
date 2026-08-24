# Score, Pellets, Fruit, and Extra Lives

The scoring path spans three source modules:

- `src/game/scoring.asm` consumes pellets, starts frightened mode, commits score
  transactions, awards the extra life, and promotes the high score;
- `src/game/round/runtime.asm` produces ghost- and fruit-collision awards;
- `src/rendering/ppu_updates.asm` flushes the prepared HUD and command buffers to
  the PPU during the rendering update.

## Score representation

`ram_score_p1` and `ram_score_hi` each contain six unpacked BCD digits in
least-significant-first order. Index 0 is the tens digit; the displayed units
digit is always a separate zero tile. For example, an internal delta of
`00 02 00 00 00 00` displays as 200 points.

`ram_pending_score_bcd` has the same six-byte layout. Event producers write a
delta there and tail-jump to `loc_add_points_and_update_score_buffers`. The
commit loop propagates decimal carry from index 0 through index 5, clears each
pending byte as it consumes it, and rebuilds the formatted score buffer.

```text
pellet / ghost / fruit event
            |
            v
 ram_pending_score_bcd
            |
            v
 loc_add_points_and_update_score_buffers
      |            |             |
      v            v             v
 ram_score_p1   extra-life    high-score
      |          side effect    promotion
      v
 ram_ppu_buffer_score
      |
      v
 sub_write_buffer_to_ppu -> PPUDATA
```

The commit entry returns immediately in demo mode. In that path it does not
consume or clear the pending digits.

## Pellet transaction

`sub_check_for_eating_pellets` runs once in the unpaused gameplay update after
tile sampling and before Pac-Man movement. It recognizes four tile variants:

| Sampled tile | Meaning | Pending internal delta | Displayed points |
| --- | --- | ---: | ---: |
| `con_tile + $09` | alternate normal pellet | 1 at index 0 | 10 |
| `con_tile + $03` | normal pellet | 1 at index 0 | 10 |
| `con_tile + $01` | visible power pellet | 5 at index 0 | 50 |
| `con_tile + $02` | hidden blink-phase power pellet | 5 at index 0 | 50 |

A non-pellet returns without changing gameplay state. A pellet performs the
following transaction:

1. Reset the ghost-release inactivity timer.
2. Convert Pac-Man's world position to a nametable address.
3. Append a one-tile clear command to `ram_ppu_buffer_main`.
4. Replace `ram_obj_ppu_tile_now` with the floor tile.
5. Copy the table-selected award to `ram_pending_score_bcd`.
6. Decrement `ram_pellet_cnt_p1` and select stage clear when it reaches zero.
7. Spawn fruit when the remaining count is `$86` or `$37`.
8. Alternate the two pellet SFX requests by remaining-count parity.
9. Tail-jump to the common score commit.

Power pellets first call `sub_start_frightened_mode`. Their world position is
also mapped to one of the four `ram_power_pellet_tile_p1` marker slots and that
slot is replaced with the floor tile.

## Frightened-mode side transaction

`sub_start_frightened_mode` initializes the stage-specific frightened timer and
four-ghost frightened mask, changes the ghost palette selectors, appends the
frightened palette packet to `ram_ppu_buffer_main`, and resets `ram_kill_cnt`.
It then falls through into `sub_try_reverse_ghost_directions` rather than
returning directly.

The reversal pass considers the four ghost slots. Only active state-`$04`
ghosts whose current movement/tile state permits reversal receive the opposite
direction. The same reversal routine is also called by the scatter/chase phase
transition path in `src/game/round/runtime.asm`.

## Ghost capture chain

Collision handling requires the colliding ghost's bit in
`ram_frightened_ghost_mask`; otherwise the collision starts Pac-Man's death sequence.
For an edible ghost, `ram_kill_cnt` indexes parallel popup and score tables:

| Capture index | Pending digits at indexes 2:1 | Displayed points |
| ---: | --- | ---: |
| 0 | `00:02` | 200 |
| 1 | `00:04` | 400 |
| 2 | `00:08` | 800 |
| 3 | `01:06` | 1600 |

The handler selects the popup tile, increments `ram_kill_cnt`, changes the
ghost to state `$08`, requests the ghost-eaten SFX, selects the freeze script,
and tail-jumps to the score commit. The next power pellet resets the chain.

## Fruit lifecycle and award

Fruit is spawned when the pellet count becomes `$86` or `$37`. Spawn setup
loads the `0A:3C` visibility timer, chooses the stage-dependent sprite tile,
and places the fruit at world position `$60,$80`.

The round runtime decrements the timer and hides the fruit when it expires.
While `ram_fruit_eaten_latch` is clear, collision handling replaces the fruit
with its score popup, sets the latch, starts the popup timer, requests the fruit
SFX, and writes the stage-indexed award:

| Stage parameter index | Displayed points |
| ---: | ---: |
| 0 | 100 |
| 1 | 300 |
| 2 | 500 |
| 3 | 700 |
| 4 | 1000 |
| 5 | 2000 |
| 6 | 3000 |
| 7 | 5000 |

The collision path then tail-jumps to the same score commit used by pellets and
ghost captures.

## Formatting and deferred PPU writes

After BCD addition, the commit walks score digits from index 5 down to index 0.
Leading zeroes become space tiles; remaining digits pass through
`sub_digit_to_score_tile`. The resulting six tiles are stored in
`ram_ppu_buffer_score`.

This does not write the PPU immediately. `sub_write_buffer_to_ppu` later writes
the six prepared tiles and a final zero tile through `PPUDATA`, then restores
the score buffer's empty marker. Pellet clears, frightened palettes, and
extra-life icons use the separate terminated `ram_ppu_buffer_main` command
stream and are flushed by the same rendering update.

## One-time extra life

After formatting, the commit checks `ram_extra_life_awarded`. If the latch is
clear and score digit index 3 has reached 1, the game:

1. sets the latch;
2. requests the extra-life SFX;
3. increments `ram_lives_p1`;
4. appends the appropriate two-row life-icon packet for the active player.

Because index 3 is the ten-thousands digit and the displayed units digit is
implicit, this is the 10,000-point threshold. The latch makes the award a
one-time side effect.

## High-score promotion

The commit compares `ram_score_hi` with `ram_score_p1` from index 5 down to
index 0. Equality continues at the next lower digit. A lower high-score digit
promotes the player score; a higher one returns immediately.

Promotion copies both representations:

- six formatted tiles from `ram_ppu_buffer_score` to
  `ram_ppu_buffer_hiscore`;
- six unpacked BCD digits from `ram_score_p1` to `ram_score_hi`.

Keeping both copies synchronized lets the deferred PPU updater redraw the high
score without recomputing its formatting.

## Invariants

- Event producers write pending digits and enter the single common commit path.
- Decimal carry runs from index 0 toward index 5; integer conversion would alter
  the preserved representation and control flow.
- The visible units digit is not stored in score RAM.
- Score and high-score PPU buffers are staging data, not immediate PPU writes.
- The extra-life award is guarded by a persistent latch.
- Frightened ghost-chain state resets when a power pellet starts frightened mode.
