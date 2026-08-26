# Intermission State Machines and Animation

The intermission subsystem owns gameplay scripts `0E` and `10`. It reuses the
normal actor sprite/OAM tables, but treats the object-position X pair as a
fixed-point horizontal velocity for five staged cutscene actors.

## Script States
- `script 0E` (`handler_script_0e_intermission_setup`): one-shot setup.
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

This order is observable behavior: movement and animation affect the OAM built
for the current frame, while scene transitions seed actors after that build and
therefore become visible on the following frame.

## Actor Integrator

`sub_update_intermission_actor_positions` walks five four-byte records. A zero
staged X high byte disables the slot. For an enabled slot it adds the object's
X low/high pair to the staged X low/high pair. The sprite-attribute tunnel bit
is set outside X `$40..$BF` and cleared inside that interval.

When staged X leaves the sentinel bounds `$04..$FB`, the routine clears staged
X/Y and the X velocity pair, disabling the actor. Despite the historic branch
naming, this bound is tested against staged X; retain the actual data flow
rather than inferring a Y-coordinate check.

## Scene Dispatch (`ram_intermission_scene`)
- `con_intermission_scene_chase` (`00`): `handler_scene00_chase_opening`
- `con_intermission_scene_ripped_suit` (`02`): `handler_scene01_chase_rip_opening`
- `con_intermission_scene_return` (`04`): `handler_scene02_chase_return_opening`

The scene IDs are byte offsets into word tables, not ordinal `0..2` indexes.
All scenes use `ram_intermission_substate` as an even-valued substate selector. Each
table entry has a scene-specific `con_intermission_*` constant because the same
numeric offset represents different actions in different scenes.

## Scene 00 (First Intermission)
Substates (`tbl_scene00_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: wait wrap, spawn Pac-Man runner.
- `04`: midpoint trigger, spawn ghost pack.
- `06`: wait wrap then finish.

The sequence is threshold-driven: enemy slot X below `$D0`, lead actor wrap to
zero, Pac-Man X at least `$80`, then ghost-pack X wrap to zero. Actor seeds and
the `$40` script delay are part of the transition actions.

Finish path:
- `bra_scene00_finish_to_script00` -> `loc_set_script00_return`.

## Scene 01 (Ripped-Suit Gag)
Substates (`tbl_scene01_state_handlers`):
- `00`: wait trigger, spawn lead actor.
- `02`: transform sequence with position/tile swaps.
- `04`: blink ripped tiles with `ram_intermission_countdown`; finish to script00.

The transform is keyed by exact lead-actor X values `$80`, `$78`, then animation
tile events at `$7D` and `$7B`. The final state uses `$40`-tick waits to select
tiles `$46` then `$47`; seeing `$47` at expiry ends the scene.

Finish path:
- `bra_scene01_toggle_or_finish` -> `loc_set_script00_return`.

## Scene 02 (Return/Finale)
Substates (`tbl_scene02_state_handlers`):
- `00`: wait trigger, spawn chase actor.
- `02`: wait wrap, spawn return runner.
- `04`: midpoint trigger, spawn trailing chaser.
- `06`: wait chaser wrap and finish.

Its triggers are enemy X below `$D8`, lead wrap to zero, return runner X at
least `$19`, and trailing chaser wrap to zero. The return runner also seeds the
observed `$28` script delay.

Finish path:
- `bra_scene02_finish_to_script00` -> `loc_set_script00_return`.

## Shared Return
- `loc_set_script00_return`: sets `ram_script = 00` and returns to normal gameplay loop.

## Animation Layer (`EA20..EB41`)
- Scene-aligned animation dispatch table: `tbl_intermission_anim_scene_handlers`.
- Scene animation uses the same `ram_intermission_substate` model.
- Scene00: base/head/tail/banner cycle (`EA44` table).
- Scene01: base + rip-tile toggle (`EAD8` table).
- Scene02: base + main/aux tile toggles (`EB08` table).

Scene and animation dispatch use parallel word tables indexed by the same even
scene/substate values. The common animation cycle advances
`ram_pacman_anim_phase`, maps its low three bits through an eight-entry LUT, and
writes sprite-set indices. Other handlers toggle on the global frame counter's
8-frame phase or at exact actor X thresholds. Animation does not advance the
scene substate; only scene handlers do.

## RAM Roles in Intermission
- `ram_intermission_scene`: even-valued scene-table offset (`00`, `02`, `04`).
- `ram_intermission_substate`: scene substate (even steps).
- `ram_intermission_countdown`: local countdown timer (blink/toggle phases).
- `ram_sfx_intermission_flag_a` / `ram_sfx_intermission_flag_b`: intermission sound-event request slots.

## Invariants to Preserve
1. Keep scene/substate tables data-driven (no flattened if-chains initially).
2. Preserve frame pipeline order from script10; changing order will desync OAM/logic.
3. Keep substate increments by 2, matching table indexing.
4. Reuse shared return helper equivalent to `loc_set_script00_return`.
5. Preserve five-slot fixed-point integration, X-bound clearing, and palette-bit
   thresholds exactly.
6. Keep scene and animation tables parallel and indexed by even byte offsets.
7. Preserve exact threshold comparisons and the one-frame visibility delay of
   actors seeded by the final scene-dispatch step.
