# RAM Fields (BANK_FF)

## Purpose
Working glossary for the most important RAM fields used in `bank_FF.asm`.

## Fields
| Field | Hypothesized Meaning | Key Usage Sites | Confidence | Notes for C Port |
|---|---|---|---|---|
| `ram_script` | Current gameplay script state | `bra_C9FE_dispatch_current_script`, `tbl_CA0D_gameplay_script_handlers` | High | Model as enum (`SCRIPT_00`, `SCRIPT_02`, ...). |
| `ram_flag_demo` | Demo/autoplay mode flag | `loc_C98A_enter_gameplay_session`, `sub_D2FB_update_pacman_movement` | High | Gates input path and some script transitions. |
| `ram_flag_pause` | Pause toggle state | `ofs_003_CA1F_script04_pause_handler` | High | Also drives PAUSE text packet variant. |
| `ram_stage_p1` / `ram_stage_p2` | Current stage counters per player | `ofs_003_CE35_script00_round_init`, stage-clear/game-over flows | High | Used as table index drivers for level params. |
| `ram_lives_p1` / `ram_lives_p2` | Lives counters | ready/death/game-over scripts (`CA9D..CDFF`) | High | Preserve exact decrement/handoff timing. |
| `ram_pellet_cnt_p1` | Remaining pellets (or inverse counter basis) | `D0EF..D2FA`, pellet and release logic | High | Affects release targets and fruit checks. |
| `ram_kill_cnt` | Ghost-eat chain index (200/400/800/1600) | `sub_D20F_check_actor_collisions` | High | Reset behavior must match frightened flow. |
| `ram_0087` | Generic script/scene local timer or scene id | title/intermission/gameplay scripts | Medium | Semantics vary by context; keep per-script ownership clear. |
| `ram_0088` | Generic substate counter or frightened mask | attract/intermission substates; runtime frightened mask | Medium | In runtime (`D0EF+`) acts as frightened bitmask by ghost slot. |
| `ram_0089` / `ram_008A` | Frightened timer hi/lo (and scene countdown in intermission) | `sub_D0EF_update_round_timers_and_frightened`, scene blink waits | Medium | Shared reuse; document per-script interpretation. |
| `ram_00B8` | Ghost state per slot | `sub_D4F2_dispatch_ghost_state_handler`, `tbl_D501_ghost_state_handlers` | High | Core ghost FSM selector. |
| `ram_00B9` | Ghost direction per slot | ghost movement/targeting (`D50C..D83F`) | High | Keep direction encoding stable (0..3). |
| `ram_00BA` / `ram_00BB` | Ghost release queue slot pairs | `sub_D1EB_queue_next_ghost_release`, round init setup | Medium | Queue mechanics critical for house release parity. |
| `ram_00CF` | Active scatter/chase countdown | `sub_D0EF_update_round_timers_and_frightened` | High | Decremented via second-divider logic. |
| `ram_00D0` / `ram_00D1` | Scatter/chase phase index and second divider | `D14B..D172` | High | Drives phase transitions and optional direction reversals. |
| `ram_00D2` | Per-wave release timer seed/current | `D16A`, `D1C2`, `E01B` | Medium | Used when phase timer source switches. |
| `ram_00D3` | Global dot-release target cursor | `D174..D18F`, initialized in `CF7A` | Medium | Advanced through release target table. |
| `ram_00D4` | Personal release stage index | `D1B2..D1C2` | Medium | Selects personal dot thresholds. |
| `ram_00D5` / `ram_00D6` | Release counters (seconds/subseconds) | `loc_D197_update_release_counters` | High | Global periodic release trigger path. |
| `ram_fruit_timer_hi` / `ram_fruit_timer_lo` | Fruit visibility timer | `bra_D1CF_update_fruit_visibility_timer`, `bra_D2B8_spawn_fruit_and_score` | High | Timer expiry hides fruit actor and clears active flag. |
| `ram_060D` / `ram_060E` | Intermission actor visibility/setup flags | `ofs_003_E655_script0E_intermission_setup`, scene02 midpoint | Medium | Appears as cutscene-only control flags. |

## Open Questions
- `ram_0087/ram_0088/ram_0089` are multiplexed across multiple subsystems; exact canonical names should likely be context-specific in C.
- `ram_00D2` naming may improve after deeper trace capture around `E003` reverse-direction trigger path.
