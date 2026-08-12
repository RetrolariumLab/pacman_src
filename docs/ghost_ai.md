# Ghost AI Notes (`D4C2..D8F8`)

Working notes for the enemy logic in `src/game/ghosts/navigation.asm` and
`src/game/ghosts/house.asm`.

## Core Dispatch
- `sub_update_ghost_slots`: iterates 4 ghost slots (`X += 2`) and dispatches per-state handler.
- `sub_dispatch_ghost_state_handler`: reads `ram_ghost_state,X` and jumps via `tbl_ghost_state_handlers`.

## Ghost States (`ram_ghost_state`)
- `00`: entering/inside house (`handler_state00_enter_house`).
- `02`: exiting house (`handler_state02_exit_house`).
- `04`: active move logic (`handler_state04_move_logic`).
- `06`: eyes-return logic (shares mover at `handler_state06_move_logic` with special target/speed branches).
- `08`: noop/disabled (`handler_ghost_state08_noop`).

## Movement Pipeline (state 04/06)
1. `sub_select_ghost_speed_vector` picks the `ram_ghost_move_fraction,X` and `ram_ghost_move_pixels,X` speed pair.
2. Low-byte step via `tbl_axis_step_lo_handlers`.
3. Carry/borrow is folded into `ram_movement_step_budget`.
4. Hi-byte loop (`loc_step_hi_budget_loop`) via `tbl_axis_step_hi_handlers`.
5. Wrap + tunnel palette bit update around `D59D..D5C7`.
6. At tile-center alignment, target/turn selection path enters `loc_choose_next_direction`.

## Target Selection
- `D617` mode gate:
  - frightened branch -> `bra_pick_turn_from_tile_options` seeded selection from legal exits.
  - scatter/chase branch -> corner targets (`tbl_corner_targets`) or slot-specific formulas (`tbl_target_formula_handlers`).
- Slot formulas:
  - slot0: `handler_target_formula_slot0`.
  - slot1: `handler_target_formula_slot1`.
  - slot2: `handler_target_formula_slot2`.
  - slot3: `handler_target_formula_slot3` with distance gate fallback to slot0-style target.

## Direction Choice
- `loc_choose_next_direction` ranks candidate directions by target deltas.
- Ranking LUT: `tbl_ranked_dir_order_lut`.
- If preferred ranked candidates unavailable, falls back to left/right alternatives.

## House/Release Support
- `sub_update_ghost_house_counters` updates marker flags (`0608..060C`) and pellet-threshold release gating.
- `sub_queue_next_ghost_release` (outside this window but coupled) pushes release slots.

## Invariants to Preserve
1. Keep state IDs numeric and table-driven first.
2. Preserve tile-center checks exactly (`(x|y)&7 == 0`-style points) before allowing turn recompute.
3. Keep speed vectors as fixed-point `(lo,hi)` pair like RAM layout; this avoids desync.
4. Keep tunnel wrap and palette-flag side effect in movement stage, not renderer stage.
