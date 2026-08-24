# BANK_FF Map

## Purpose
Quick navigation map for the modules included by `src/main.asm`.

## Subsystem Ranges
| Range | Area | Key Entrypoints | Notes |
|---|---|---|---|
| `C000..C1F4` | Boot, NMI, input, frame bootstrap | `vec_reset_entry`, `vec_nmi_handler`, `loc_main_frame_bootstrap` | Keep exact frame order (`NMI -> input -> script dispatch`) to avoid desyncs. |
| `C1F5..C989` | Title, attract, demo pregame | `tbl_script_handlers_title_flow`, `sub_draw_title_logo_and_text` | Title/attract uses the shared state slots as script/substate counters; preserve timing ticks. |
| `C98A..D0EE` | Gameplay script core and round init | `loc_enter_gameplay_session`, `tbl_gameplay_script_handlers`, `handler_script00_round_init` | Keep handlers explicit and make every script transition visible. |
| `D0EF..D2FA` | Timers, frightened, release, fruit, collisions | `sub_update_round_timers_and_frightened`, `sub_queue_next_ghost_release`, `sub_check_actor_collisions` | High-risk logic: affects ghost release order, fright windows, and scoring; validate with focused runtime traces. |
| `D2FB..D4C1` | Pac-Man movement/input/demo path | `sub_update_pacman_movement`, `loc_apply_requested_direction` | Keep tile-grid alignment and tunnel wrap behavior bit-exact. |
| `D4C2..D8F8` | Ghost state machine + targeting + motion | `sub_update_ghost_slots`, `sub_dispatch_ghost_state_handler`, `loc_choose_next_direction` | Largest complexity block; annotate by state (`00/02/04/06/08`) and validate per-state traces. |
| `D8F9..DEDE` | Actor animation, OAM, buffered PPU writes | `sub_update_pacman_anim_frame`, `sub_build_oam_from_sprite_buffers`, `sub_write_buffer_to_ppu` | Preserve actor ordering, overlap handling, and NMI-side write order. |
| `DEDF..E153` | Pellets, frightened mode, score, 1UP | `sub_check_for_eating_pellets`, `loc_add_points_and_update_score_buffers` | Score and frightened-mode side effects share this path; document them as one transaction. |
| `E154..E654` | Tile probes, playfield, and HUD | `sub_build_object_neighbor_ppu_positions`, `sub_clear_bg_nametables_and_attrs`, `sub_draw_score_hud_live` | Mostly PPU and coordinate helpers; keep address conversion and buffering assumptions visible. |
| `E655..EB41` | Intermission setup, runtime, animation | `handler_script0E_intermission_setup`, `sub_run_intermission_scene_dispatch`, `sub_run_intermission_animation_dispatch` | Scene/state tables are cleanly data-driven; keep table dispatch structure. |
| `EB42..EC77` | Editable stage parameters | `tbl_stage_param_index_stream`, `tbl_level_param_blocks_22bytes` | Understood tuning tables remain readable ca65 source. |
| `EC78..EE17` | Generated compressed maze | `tbl_maze_rle_stream` | Extracted by `make split`; keep address, size, and checksum stable. |
| `EE18..F0AD` | Sound engine and support tables | `sub_init_sound_engine`, `sub_update_sound_engine`, `tbl_sound_control_opcode_handlers` | Decoder control flow and channel arbitration are timing-sensitive. |
| `F0AE..F427` | Generated SFX streams | `off_sfx_slot02_extra_life`, `off_sfx_slot0F_pause_toggle` | Labels and pointer table stay in ASM; payloads are extracted locally. |
| `F428..FFFF` | Unused tail, maze pointer, vectors | `tbl_maze_rle_stream_ptr`, `vec_nmi_handler` | Preserve filler size/value and fixed vector placement. |

## Runtime Fields (Most Critical)
- `ram_script`: gameplay script state (indexes `tbl_gameplay_script_handlers`).
- `ram_shared_state_0`, `ram_shared_state_1`: scene/substate counters in title and intermission, reused by gameplay.
- `ram_shared_state_2`, `ram_shared_state_3`: frightened timer pair, reused as local cutscene timers.
- `ram_ghost_state`, `ram_ghost_direction`: interleaved ghost state/direction pairs.
- `ram_scatter_chase_timer`, `ram_scatter_chase_phase`, `ram_scatter_chase_second_divider`: scatter/chase countdown system.
- `ram_personal_release_latch`, `ram_global_release_target`, `ram_personal_release_stage`, `ram_release_timer_seconds`, `ram_release_timer_ticks`: release target/counter pipeline.
- `ram_fruit_timer_hi`, `ram_fruit_timer_lo`: fruit visibility timer.
