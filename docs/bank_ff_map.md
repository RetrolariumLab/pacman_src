# BANK_FF Map

## Purpose
Quick navigation map for the modules included by `src/main.asm`, with annotation
priorities.

## Subsystem Ranges
| Range | Area | Key Entrypoints | Notes |
|---|---|---|---|
| `C000..C1F4` | Boot, NMI, input, frame bootstrap | `vec_C033_reset_entry`, `vec_C0FA_nmi_handler`, `loc_C168_main_frame_bootstrap` | Keep exact frame order (`NMI -> input -> script dispatch`) to avoid desyncs. |
| `C1F5..C989` | Title, attract, demo pregame | `tbl_C1F5_script_handlers_title_flow`, `sub_C21F_draw_title_logo_and_text` | Title/attract uses script+substate counters (`ram_0087/0088`); preserve timing ticks. |
| `C98A..D0EE` | Gameplay script core and round init | `loc_C98A_enter_gameplay_session`, `tbl_CA0D_gameplay_script_handlers`, `ofs_003_CE35_script00_round_init` | Keep handlers explicit and make every script transition visible. |
| `D0EF..D2FA` | Timers, frightened, release, fruit, collisions | `sub_D0EF_update_round_timers_and_frightened`, `sub_D1EB_queue_next_ghost_release`, `sub_D20F_check_actor_collisions` | High-risk logic: affects ghost release order, fright windows, scoring. Add golden tests first. |
| `D2FB..D4C1` | Pac-Man movement/input/demo path | `sub_D2FB_update_pacman_movement`, `loc_D311_apply_requested_direction` | Keep tile-grid alignment and tunnel wrap behavior bit-exact. |
| `D4C2..D8F8` | Ghost state machine + targeting + motion | `sub_D4C2_update_ghost_slots`, `sub_D4F2_dispatch_ghost_state_handler`, `loc_D6E3_choose_next_direction` | Largest complexity block; annotate by state (`00/02/04/06/08`) and validate per-state traces. |
| `D8F9..DEDE` | Actor animation, OAM, buffered PPU writes | `sub_D8F9_update_pacman_anim_frame`, `sub_DA5C_build_oam_from_sprite_buffers`, `sub_DDE9_write_buffer_to_ppu` | Preserve actor ordering, overlap handling, and NMI-side write order. |
| `DEDF..E153` | Pellets, frightened mode, score, 1UP | `sub_DEDF_check_for_eating_pellets`, `loc_E060_add_points_and_update_score_buffers` | Score and frightened-mode side effects share this path; document them as one transaction. |
| `E154..E654` | Tile probes, playfield, and HUD | `sub_E154_build_object_neighbor_ppu_positions`, `sub_E2FF_clear_bg_nametables_and_attrs`, `sub_E379_draw_score_hud_live` | Mostly PPU and coordinate helpers; keep address conversion and buffering assumptions visible. |
| `E655..EB41` | Intermission setup, runtime, animation | `ofs_003_E655_script0E_intermission_setup`, `sub_E75A_run_intermission_scene_dispatch`, `sub_EA20_run_intermission_animation_dispatch` | Scene/state tables are cleanly data-driven; keep table dispatch structure. |
| `EB42..EC77` | Editable stage parameters | `tbl_EB42_stage_param_index_stream`, `tbl_EBCC_level_param_blocks_22bytes` | Understood tuning tables remain readable ca65 source. |
| `EC78..EE17` | Generated compressed maze | `tbl_EC78_maze_rle_stream` | Extracted by `make split`; keep address, size, and checksum stable. |
| `EE18..F0AD` | Sound engine and support tables | `sub_EE18_init_sound_engine`, `sub_EE5C_update_sound_engine`, `tbl_EFAA_sound_control_opcode_handlers` | Decoder control flow and channel arbitration are timing-sensitive. |
| `F0AE..F427` | Generated SFX streams | `off_F0AE_sfx_slot02_extra_life`, `off_F3ED_sfx_slot0F_pause_toggle` | Labels and pointer table stay in ASM; payloads are extracted locally. |
| `F428..FFFF` | Unused tail, maze pointer, vectors | `tbl_FFF8_maze_rle_stream_ptr`, `vec_C0FA_nmi_handler` | Preserve filler size/value and fixed vector placement. |

## Runtime Fields (Most Critical)
- `ram_script`: gameplay script state (indexes `tbl_CA0D_gameplay_script_handlers`).
- `ram_0087`, `ram_0088`: generic scene/substate counters in title+intermission and some gameplay scripts.
- `ram_0089`, `ram_008A`: frightened timer hi/lo.
- `ram_00B8`, `ram_00B9`: ghost state and direction.
- `ram_00BA`, `ram_00BB`: ghost release queue pairs.
- `ram_00CF`, `ram_00D0`, `ram_00D1`: scatter/chase phase countdown system.
- `ram_00D2`, `ram_00D3`, `ram_00D4`, `ram_00D5`, `ram_00D6`: release target/counter pipeline.
- `ram_fruit_timer_hi`, `ram_fruit_timer_lo`: fruit visibility timer.

## Suggested Annotation Order
1. `C98A..CA1E` script dispatcher and loop shell.
2. `CE35..D04D` round init and data-load pipeline.
3. `D2FB..D4C1` Pac-Man movement.
4. `D0EF..D2FA` timers/collision/scoring.
5. `D4C2..E25B` ghost AI/state machine.
6. Intermission (`E655..EB41`) last.
