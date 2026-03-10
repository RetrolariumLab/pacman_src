# BANK_FF Map

## Purpose
Quick navigation map for `bank_FF.asm` with C-port priorities.

## Subsystem Ranges
| Range | Area | Key Entrypoints | C Port Notes |
|---|---|---|---|
| `C033..C1DE` | Boot, NMI, input, frame bootstrap | `vec_C033_reset_entry`, `vec_C0FA_nmi_handler`, `loc_C168_main_frame_bootstrap` | Keep exact frame order (`NMI -> input -> script dispatch`) to avoid desyncs. |
| `C1F5..C98A` | Title, attract, demo pregame | `tbl_C1F5_script_handlers_title_flow`, `sub_C21F_draw_title_logo_and_text`, `loc_C98A_enter_gameplay_session` | Title/attract uses script+substate counters (`ram_0087/0088`); preserve timing ticks. |
| `C98A..D04D` | Gameplay script core and round init | `tbl_CA0D_gameplay_script_handlers`, `ofs_003_CE35_script00_round_init` | This is the gameplay state machine backbone; port scripts as explicit enum states. |
| `D0EF..D2FA` | Timers, frightened, release, fruit, collisions | `sub_D0EF_update_round_timers_and_frightened`, `sub_D1EB_queue_next_ghost_release`, `sub_D20F_check_actor_collisions` | High-risk logic: affects ghost release order, fright windows, scoring. Add golden tests first. |
| `D2FB..D4C1` | Pac-Man movement/input/demo path | `sub_D2FB_update_pacman_movement`, `loc_D311_apply_requested_direction` | Keep tile-grid alignment and tunnel wrap behavior bit-exact. |
| `D4C2..E25B` | Ghost state machine + targeting + motion | `sub_D4C2_update_ghost_slots`, `sub_D4F2_dispatch_ghost_state_handler`, `loc_D6E3_choose_next_direction` | Largest complexity block; split by state (`00/02/04/06/08`) and test per-state traces. |
| `E2FF..E74A` | Playfield/HUD utilities + intermission setup | `sub_E2FF_clear_bg_nametables_and_attrs`, `sub_E379_draw_score_hud_live`, `ofs_003_E655_script0E_intermission_setup` | Mostly PPU writers; isolate as renderer-side helpers in C. |
| `E74B..EB41` | Intermission runtime and animation scripts | `ofs_003_E74B_script10_intermission_runtime`, `sub_E75A_run_intermission_scene_dispatch`, `sub_EA20_run_intermission_animation_dispatch` | Scene/state tables are cleanly data-driven; keep table dispatch structure. |
| `EB42..F3FF` | Stage parameter tables, maze/sound data, audio support | `tbl_EB42_stage_param_index_stream`, `tbl_EBCC_level_param_blocks_22bytes`, `tbl_EFAA_sound_control_opcode_handlers` | Treat as immutable data first; decode into structs only after trace parity. |

## Runtime Fields (Most Critical)
- `ram_script`: gameplay script state (indexes `tbl_CA0D_gameplay_script_handlers`).
- `ram_0087`, `ram_0088`: generic scene/substate counters in title+intermission and some gameplay scripts.
- `ram_0089`, `ram_008A`: frightened timer hi/lo.
- `ram_00B8`, `ram_00B9`: ghost state and direction.
- `ram_00BA`, `ram_00BB`: ghost release queue pairs.
- `ram_00CF`, `ram_00D0`, `ram_00D1`: scatter/chase phase countdown system.
- `ram_00D2`, `ram_00D3`, `ram_00D4`, `ram_00D5`, `ram_00D6`: release target/counter pipeline.
- `ram_fruit_timer_hi`, `ram_fruit_timer_lo`: fruit visibility timer.

## Suggested C Port Order
1. Port `C98A..CA1E` script dispatcher and loop shell.
2. Port `CE35..D04D` round init and data-load pipeline.
3. Port `D2FB..D4C1` Pac-Man movement.
4. Port `D0EF..D2FA` timers/collision/scoring.
5. Port `D4C2..E25B` ghost AI/state machine.
6. Port intermission (`E655..EB41`) last.
