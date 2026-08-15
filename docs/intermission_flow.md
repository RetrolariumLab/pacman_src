# Intermission Flow (`E655..EB41`)

## Script States
- `script 0E` (`handler_script0E_intermission_setup`): one-shot setup.
- `script 10` (`handler_script10_intermission_runtime`): per-frame runtime loop.

## Setup (`script 0E`)
- Waits vblank and disables rendering.
- Clears playfield/walls via `sub_clear_playfield_and_walls`.
- Seeds actor tiles/flags (`028D..0296`, `060D/060E`) and initial positions/velocities.
- Uploads intermission sprite palette (`tbl_intro_sprite_palette`).
- Switches to `ram_script = 10`.

## Runtime Frame Pipeline (`script 10`)
Order in `handler_script10_intermission_runtime`:
1. `sub_update_intermission_actor_positions`
2. `sub_run_intermission_animation_dispatch`
3. `sub_build_oam_from_sprite_buffers`
4. `sub_run_intermission_scene_dispatch`

## Scene Dispatch (`ram_shared_state_0`)
- `con_intermission_scene_chase` (`00`): `handler_scene00_chase_opening`
- `con_intermission_scene_ripped_suit` (`02`): `handler_scene01_chase_rip_opening`
- `con_intermission_scene_return` (`04`): `handler_scene02_chase_return_opening`

The scene IDs are byte offsets into word tables, not ordinal `0..2` indexes.
All scenes use `ram_shared_state_1` as an even-valued substate selector. Each
table entry has a scene-specific `con_intermission_*` constant because the same
numeric offset represents different actions in different scenes.

## Scene 00 (First Intermission)
Substates (`tbl_scene00_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: wait wrap, spawn Pac-Man runner.
- `04`: midpoint trigger, spawn ghost pack.
- `06`: wait wrap then finish.

Finish path:
- `bra_scene00_finish_to_script00` -> `loc_set_script00_return`.

## Scene 01 (Ripped-Suit Gag)
Substates (`tbl_scene01_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: transform sequence with position/tile swaps.
- `04`: blink ripped tiles with the `ram_shared_state_2` timer; finish to script00.

Finish path:
- `bra_scene01_toggle_or_finish` -> `loc_set_script00_return`.

## Scene 02 (Return/Finale)
Substates (`tbl_scene02_state_handlers`):
- `00`: wait trigger, spawn chase actor.
- `02`: wait wrap, spawn return runner.
- `04`: midpoint trigger, spawn trailing chaser.
- `06`: wait chaser wrap and finish.

Finish path:
- `bra_scene02_finish_to_script00` -> `loc_set_script00_return`.

## Shared Return
- `loc_set_script00_return`: sets `ram_script = 00` and returns to normal gameplay loop.

## Animation Layer (`EA20..EB41`)
- Scene-aligned animation dispatch table: `tbl_intermission_anim_scene_handlers`.
- Scene animation uses the same `ram_shared_state_1` substate model.
- Scene00: base/head/tail/banner cycle (`EA44` table).
- Scene01: base + rip-tile toggle (`EAD8` table).
- Scene02: base + main/aux tile toggles (`EB08` table).

## RAM Roles in Intermission
- `ram_shared_state_0`: even-valued scene-table offset (`00`, `02`, `04`).
- `ram_shared_state_1`: scene substate (even steps).
- `ram_shared_state_2`: local countdown timer (blink/toggle phases).
- `ram_sfx_intermission_flag_a` / `ram_sfx_intermission_flag_b`: intermission sound-event request slots.

## Invariants to Preserve
1. Keep scene/substate tables data-driven (no flattened if-chains initially).
2. Preserve frame pipeline order from script10; changing order will desync OAM/logic.
3. Keep substate increments by 2, matching table indexing.
4. Reuse shared return helper equivalent to `loc_set_script00_return`.
