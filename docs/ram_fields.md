# RAM Fields (BANK_FF)

## Purpose
Working glossary for the most important RAM fields used by `src/main.asm`.

## Fields
| Field | Hypothesized Meaning | Key Usage Sites | Confidence | Notes |
|---|---|---|---|---|
| `ram_script` | Current title-flow or gameplay script state | `bra_dispatch_current_script`, `tbl_gameplay_script_handlers` | High | Semantic `con_title_script_*` and `con_game_script_*` constants reflect the active dispatcher. |
| `ram_flag_demo` | Demo/autoplay mode flag | `loc_enter_gameplay_session`, `sub_update_pacman_movement` | High | Gates input path and some script transitions. |
| `ram_flag_pause` | Pause toggle state | `handler_script04_pause_handler` | High | Also drives PAUSE text packet variant. |
| `ram_stage_p1` / `ram_stage_p2` | Current stage counters per player | `handler_script00_round_init`, stage-clear/game-over flows | High | Used as table index drivers for level params. |
| `ram_lives_p1` / `ram_lives_p2` | Lives counters | ready/death/game-over scripts (`CA9D..CDFF`) | High | Preserve exact decrement/handoff timing. |
| `ram_pellet_cnt_p1` | Remaining pellets (or inverse counter basis) | `D0EF..D2FA`, pellet and release logic | High | Affects release targets and fruit checks. |
| `ram_kill_cnt` | Ghost-eat chain index (200/400/800/1600) | `sub_check_actor_collisions` | High | Reset behavior must match frightened flow. |
| `ram_shared_state_0` | Generic script-local timer, phase, or mode mask | title and gameplay scripts | High | Intermission code uses `ram_intermission_scene`; see resolved RAM-002. |
| `ram_shared_state_1` | Generic substate storage | title/attract and other script-local handlers | High | Gameplay and intermission code use contextual aliases. |
| `ram_shared_state_2` / `ram_shared_state_3` | Generic timer storage | title/attract and other script-local handlers | High | Ownership changes only at documented script boundaries. |
| `ram_frightened_ghost_mask` | Ghost-slot frightened bitmask | round runtime, movement, collisions, animation | High | Contextual alias of `$0088`. |
| `ram_frightened_seconds` / `ram_frightened_frame_counter` | Frightened countdown | round runtime and scoring | High | Contextual aliases of `$0089/$008A`. |
| `ram_intermission_scene` / `ram_intermission_substate` / `ram_intermission_countdown` | Scene dispatcher state | intermission setup, scenes, animation | High | Contextual aliases of `$0087..$0089`. |
| `ram_ghost_state` | Ghost state array with a two-byte stride | `sub_dispatch_ghost_state_handler`, `tbl_ghost_state_handlers` | High | Core ghost FSM selector, represented by `con_ghost_state_*`. Release routines scan slots 1..3 at `ram_ghost_state + $02,X`. |
| `ram_ghost_direction` | Ghost direction array interleaved with state | ghost movement/targeting (`D50C..D83F`) | High | Uses the shared `con_direction_*` encoding: up, left, down, right (`0..3`). |
| `ram_scatter_chase_timer` | Active scatter/chase countdown | `sub_update_round_timers_and_frightened` | High | Decremented via the second divider. |
| `ram_scatter_chase_phase` / `ram_scatter_chase_second_divider` | Scatter/chase phase index and second divider | `D14B..D172` | High | Drives phase transitions and optional direction reversals. |
| `ram_personal_release_latch` | Persistent post-threshold mode/reversal gate | `D16A`, `D1C2`, `E01B` | High | Cleared at setup and set at personal thresholds; see resolved RAM-003. |
| `ram_global_release_target` | Global dot-release target cursor | `D174..D18F`, initialized in `CF7A` | Medium | Advanced through the release target table. |
| `ram_personal_release_stage` | Personal release stage index | `D1B2..D1C2` | Medium | Selects personal dot thresholds. |
| `ram_release_timer_seconds` / `ram_release_timer_ticks` | Global release timer | `loc_update_release_counters` | High | Periodic trigger path for house release. |
| `ram_fruit_timer_hi` / `ram_fruit_timer_lo` | Fruit visibility timer | `bra_update_fruit_visibility_timer`, `bra_spawn_fruit_and_score` | High | Timer expiry hides fruit actor and clears active flag. |
| `ram_sfx_intermission_flag_a` / `ram_sfx_intermission_flag_b` | Intermission sound-event request slots | `handler_script0E_intermission_setup`, scene02 midpoint | High | Slots 0D/0E in the sound request table. |

## Evidence Notes
- See resolved RAM-002 in `docs/unknowns.md` for traced ownership of the
  multiplexed `ram_shared_state_*` bytes.
- See resolved RAM-003 for the `ram_personal_release_latch` lifetime and its
  phase-selection and reversal consumers.
