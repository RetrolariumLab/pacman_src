# Ghost State Machine, Targeting, Release, and Speed

The ghost runtime spans `src/game/ghosts/navigation.asm`,
`src/game/ghosts/house.asm`, and the timer/release portion of
`src/game/round/runtime.asm`. It shares the cached tile-probe pipeline described
in `movement_and_collisions.md`.

## Slot Model and State Dispatch

Four ghost slots use even offsets `0, 2, 4, 6` in interleaved state/direction
arrays. The update loop also advances a tile pointer, position pointer, and
one-bit slot mask. Each state value is an even byte offset into a word table:

| State | Meaning | Main update behavior |
| --- | --- | --- |
| `con_ghost_state_in_house` | waiting/bouncing in house | vertical two-phase house motion |
| `con_ghost_state_exiting_house` | queued for release | align to house exit, move up, become active |
| `con_ghost_state_active` | normal/frightened maze actor | speed, fixed-point movement, targeting, turns |
| `con_ghost_state_returning_eyes` | eaten eyes returning | fixed fast speed and house-door target |
| `con_ghost_state_eaten_score` | score-popup freeze | no movement |

The reduced update used during post-eat pause dispatches movement only for
returning eyes; every other state is a no-op. This lets previously eaten eyes
continue home without advancing the ordinary ghosts.

At the observed house entrance `(X=$60,Y=$70)`, returning eyes switch to the
exit-house state, clear their frightened bit, and restore their slot palette.
The exit handler first aligns X to `$60`, moves upward to Y `$58`, then selects
left and changes to active. In-house actors use their direction byte as a local
two-phase selector while bouncing between Y `$69` and `$70`.

## Movement and Tunnel Handling

Active and returning-eye states share fixed-point movement. The chosen
fraction/pixel pair updates the low byte first; carry or borrow becomes the
integer step budget. Each high-byte substep applies tunnel wrap (`$0A` -> `$BF`,
`$C0` -> `$0B`) and updates sprite-palette bit `$20` outside X `$18..$A8`.

Direction selection runs only at eight-pixel alignment. Returning eyes target
the house door. Other active ghosts choose frightened, scatter, or chase logic
from their slot bit in `ram_frightened_ghost_mask` and `ram_shared_state_0`.

## Speed Priority

`sub_select_ghost_speed_vector` chooses exactly one fixed-point pair in this
priority order:

1. returning eyes: literal fraction `0`, pixels `2`;
2. tunnel row Y `$70` with X outside `$30..$8F`: tunnel profile;
3. slot frightened bit set: frightened profile;
4. slot zero: its mutable current-speed profile;
5. slots one through three: shared normal profile.

The slot-zero current-speed pair is initialized from stage parameters and can
advance at personal pellet thresholds. This mutable pair is distinct from the
normal profile used by the other slots.

## Target Modes and Formulas

For an active ghost, mode priority is:

- frightened bit set: choose a legal non-reverse exit using the frame counter
  as a deterministic seed;
- its bit set in `ram_shared_state_0`: use the slot-specific chase formula;
- otherwise: use its fixed corner target.

The chase formulas are expressed in world coordinates:

| Slot | Target formula |
| --- | --- |
| 0 | Pac-Man position |
| 1 | Pac-Man position plus a 24-pixel offset in Pac-Man's direction |
| 2 | `2 * Pac-Man - slot0 ghost position` on both axes |
| 3 | Pac-Man when either axis is at least 32 pixels away; otherwise seeded legal-exit selection |

Slot 3's test is axis-wise, not a radial-distance calculation. Scatter targets
are the four fixed corner coordinates stored in slot order.

## Legal Exits and Direction Ranking

The shared candidate collector scans up/left/down/right tile samples, applies
state-specific accepted tile classes, removes reverse, and compacts valid
directions. With no candidate the fallback is down; with one candidate it is
used directly.

For multiple candidates, `loc_choose_next_direction` computes absolute X and Y
deltas to the target and uses `tbl_ranked_dir_order_lut` to try the two directions
that reduce the dominant/sign-selected axes. If neither ranked direction is
available, it tries relative left then relative right. The LUT and fallback
order are gameplay behavior and must not be replaced by a generic shortest-path
algorithm.

## Scatter/Chase and Reversal

Outside frightened mode, a 60-frame divider decrements the active phase timer.
On expiry the phase index advances, a new duration is loaded, and the mode mask
in `ram_shared_state_0` is selected. One phase parity also calls
`sub_try_reverse_ghost_directions`; that helper reverses eligible active ghosts
using their cached tiles and slot masks.

`ram_personal_release_latch` is cleared at round init and set to one at a
personal pellet threshold. It remains set until the next round setup, supplies
the even-phase mode mask, and gates ordinary phase reversals. Frightened-mode
reversals remain eligible because their full mask takes precedence. The focused
trace establishes this lifetime and both consumers under resolved `RAM-003`.

## House Release Paths

`sub_queue_next_ghost_release` scans house slots one through three and changes
the first in-house state to exiting-house. It is reached by three observed
conditions:

- a global pellet target, compared as target plus current pellet count equals
  `$C0`, then advanced through the target table;
- a seconds/subseconds inactivity-style interval (`$60` ticks per second);
- stage-provided personal pellet thresholds, which also advance slot zero's
  current-speed pair.

`sub_update_ghost_house_counters` separately maintains sound/request-page marker
bytes: returning-eyes presence wins, then frightened presence, otherwise one of
three pellet-count bands. These bytes are coupled to audio-side behavior and
must not be treated as the release-state array itself.

## Preservation Invariants

- Keep even state IDs and even slot offsets aligned with their word tables.
- Preserve the main and reduced dispatchers as distinct update policies.
- Preserve fixed-point carry/borrow and per-pixel tunnel side effects.
- Preserve state/mode/speed priority and slot-zero's separate mutable speed.
- Preserve candidate filtering, reverse exclusion, ranking LUT, and fallback order.
- Keep house coordinates, release scan order, counters, and threshold equality
  comparisons byte-exact.
- Revalidate `RAM-003` with `make trace-evidence` after changing release or
  mode-transition logic.
