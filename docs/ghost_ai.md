# Ghost AI Notes (`D4C2..D8F8`)

Working notes for the enemy logic block in `bank_FF.asm`.

## Core Dispatch
- `sub_D4C2_update_ghost_slots`: iterates 4 ghost slots (`X += 2`) and dispatches per-state handler.
- `sub_D4F2_dispatch_ghost_state_handler`: reads `ram_00B8,X` and jumps via `tbl_D501_ghost_state_handlers`.

## Ghost States (`ram_00B8`)
- `00`: entering/inside house (`ofs_006_D840_state00_enter_house`).
- `02`: exiting house (`ofs_006_D7F0_state02_exit_house`).
- `04`: active move logic (`ofs_006_D50C_state04_move_logic`).
- `06`: eyes-return logic (shares mover at `ofs_006_D50C_state06_move_logic` with special target/speed branches).
- `08`: noop/disabled (`ofs_006_D50B_state08_noop`).

## Movement Pipeline (state 04/06)
1. `sub_D78C_select_ghost_speed_vector` picks `(ram_00C2,X, ram_00C3,X)` speed.
2. Low-byte step via `tbl_D520_axis_step_lo_handlers`.
3. Carry/borrow folded into `ram_00CC` hi-step budget.
4. Hi-byte loop (`loc_D556_step_hi_budget_loop`) via `tbl_D56C_axis_step_hi_handlers`.
5. Wrap + tunnel palette bit update around `D59D..D5C7`.
6. At tile-center alignment, target/turn selection path enters `loc_D6E3_choose_next_direction`.

## Target Selection
- `D617` mode gate:
  - frightened branch -> `bra_D675_pick_turn_from_tile_options` seeded selection from legal exits.
  - scatter/chase branch -> corner targets (`tbl_D632_corner_targets`) or slot-specific formulas (`tbl_D649_target_formula_handlers`).
- Slot formulas:
  - slot0: `ofs_009_D6A6_target_formula_slot0`.
  - slot1: `ofs_009_D6B0_target_formula_slot1`.
  - slot2: `ofs_009_D6CF_target_formula_slot2`.
  - slot3: `ofs_009_D651_target_formula_slot3` with distance gate fallback to slot0-style target.

## Direction Choice
- `loc_D6E3_choose_next_direction` ranks candidate directions by target deltas.
- Ranking LUT: `tbl_D7DC_ranked_dir_order_lut`.
- If preferred ranked candidates unavailable, falls back to left/right alternatives.

## House/Release Support
- `sub_D8C9_update_ghost_house_counters` updates marker flags (`0608..060C`) and pellet-threshold release gating.
- `sub_D1EB_queue_next_ghost_release` (outside this window but coupled) pushes release slots.

## C Port Hints
1. Keep state IDs numeric and table-driven first.
2. Preserve tile-center checks exactly (`(x|y)&7 == 0`-style points) before allowing turn recompute.
3. Keep speed vectors as fixed-point `(lo,hi)` pair like RAM layout; this avoids desync.
4. Keep tunnel wrap and palette-flag side effect in movement stage, not renderer stage.
