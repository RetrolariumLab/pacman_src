# Intermission Flow (`E655..EB41`)

## Script States
- `script 0E` (`ofs_003_E655_script0E_intermission_setup`): one-shot setup.
- `script 10` (`ofs_003_E74B_script10_intermission_runtime`): per-frame runtime loop.

## Setup (`script 0E`)
- Waits vblank and disables rendering.
- Clears playfield/walls via `sub_E6C4_clear_playfield_and_walls`.
- Seeds actor tiles/flags (`028D..0296`, `060D/060E`) and initial positions/velocities.
- Uploads intermission sprite palette (`tbl_E73B_intro_sprite_palette`).
- Switches to `ram_script = 10`.

## Runtime Frame Pipeline (`script 10`)
Order in `ofs_003_E74B_script10_intermission_runtime`:
1. `sub_E9A5_update_intermission_actor_positions`
2. `sub_EA20_run_intermission_animation_dispatch`
3. `sub_DA5C_build_oam_from_sprite_buffers`
4. `sub_E75A_run_intermission_scene_dispatch`

## Scene Dispatch (`ram_0087`)
- `00`: `ofs_012_E76F_scene00_chase_opening`
- `01`: `ofs_012_E853_scene01_chase_rip_opening`
- `02`: `ofs_012_E8FA_scene02_chase_return_opening`

All scenes use `ram_0088` as even-valued substate selector.

## Scene 00 (First Intermission)
Substates (`tbl_E77E_scene00_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: wait wrap, spawn Pac-Man runner.
- `04`: midpoint trigger, spawn ghost pack.
- `06`: wait wrap then finish.

Finish path:
- `bra_E84C_scene00_finish_to_script00` -> `loc_E9A0_set_script00_return`.

## Scene 01 (Ripped-Suit Gag)
Substates (`tbl_E862_scene01_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: transform sequence with position/tile swaps.
- `04`: blink ripped tiles with `ram_0089` timer; finish to script00.

Finish path:
- `bra_E8E6_scene01_toggle_or_finish` -> `loc_E9A0_set_script00_return`.

## Scene 02 (Return/Finale)
Substates (`tbl_E909_scene02_state_handlers`):
- `00`: wait trigger, spawn chase actor.
- `02`: wait wrap, spawn return runner.
- `04`: midpoint trigger, spawn trailing chaser.
- `06`: wait chaser wrap and finish.

Finish path:
- `bra_E99C_scene02_finish_to_script00` -> `loc_E9A0_set_script00_return`.

## Shared Return
- `loc_E9A0_set_script00_return`: sets `ram_script = 00` and returns to normal gameplay loop.

## Animation Layer (`EA20..EB41`)
- Scene-aligned animation dispatch table: `tbl_EA2F_intermission_anim_scene_handlers`.
- Scene animation uses same `ram_0088` substate model.
- Scene00: base/head/tail/banner cycle (`EA44` table).
- Scene01: base + rip-tile toggle (`EAD8` table).
- Scene02: base + main/aux tile toggles (`EB08` table).

## RAM Roles in Intermission
- `ram_0087`: scene index (0..2).
- `ram_0088`: scene substate (even steps).
- `ram_0089`: local countdown timer (blink/toggle phases).
- `ram_060D/ram_060E`: actor visibility/one-shot control flags.

## C Port Notes
1. Keep scene/substate tables data-driven (no flattened if-chains initially).
2. Preserve frame pipeline order from script10; changing order will desync OAM/logic.
3. Keep substate increments by 2, matching table indexing.
4. Reuse shared return helper equivalent to `loc_E9A0_set_script00_return`.
