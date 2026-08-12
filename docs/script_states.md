# Gameplay Script States (`ram_script`)

## Scope
This document tracks the gameplay/intermission script state machine dispatched by:
- `bra_dispatch_current_script`
- `tbl_gameplay_script_handlers`

`ram_script` stores even-valued IDs (`00, 02, 04, ... 10`).

## State Table
| ID | Handler | Meaning |
|---|---|---|
| `00` | `handler_script00_round_init` | Round/session init, table loads, HUD/maze setup. |
| `02` | `handler_script02_round_ready` | READY pre-control countdown and text sprites. |
| `04` | `handler_script04_pause_handler` | Main active gameplay frame loop + pause gate. |
| `06` | `handler_script06_post_eat_pause` | Short freeze after ghost/fruit eat popup event. |
| `08` | `handler_script08_death_sequence` | Death animation and life/handoff logic. |
| `0A` | `handler_script0A_game_over` | GAME OVER flow and timeout. |
| `0C` | `handler_script0C_stage_clear` | Stage-clear flash and intermission gate. |
| `0E` | `handler_script0E_intermission_setup` | Intermission pre-setup. |
| `10` | `handler_script10_intermission_runtime` | Intermission scene runtime. |

## Observed Transitions
| From | To | Trigger / Site |
|---|---|---|
| `00` | `02` | End of round init (`CE73..CE75`: `STA ram_script <- 02`). |
| `02` | `04` | READY SFX complete (`CBCB..CBCD`: `STA ram_script <- 04`). |
| `04` | `06` | Ghost/fruit score freeze (`D29B..D29D`: `STA ram_script <- 06`). |
| `06` | `04` | Freeze timer expires (`CC1B..CC1D`: `STA ram_script <- 04`). |
| `04` | `08` | Dangerous ghost collision (`D2A2..D2A4`: `STA ram_script <- 08`). |
| `08` | `0A` | Death flow reaches no-lives/game-over (`CC8D..CC8F`: `STA ram_script <- 0A`). |
| `08` | `00` | Death flow next-spawn/handoff (`CC94..CC96`: `STA ram_script <- 00`). |
| `04` | `0C` | Pellet clear path (`DF68..DF6A`: `STA ram_script <- 0C`). |
| `0C` | `00` | Stage-clear to next round (`CD4C..CD4E`: `STA ram_script <- 00`). |
| `0C` | `0E` | Stage threshold triggers intermission (`CD45..CD47`: `STA ram_script <- 0E`). |
| `0E` | `10` | Intermission setup complete (`E6B6..E6B8`: `STA ram_script <- 10`). |
| `10` | `00` | Intermission scene finishes (`E9A0..E9A2`: `STA ram_script <- 00`). |
| `*` | `02` | Demo input/title bootstrap path (`C9EF..C9F3`, also title-side bootstrap). |

## Invariants to Preserve
1. Keep script IDs and dispatch table order stable first; refactor enum names only after trace parity.
2. Treat `script 04` as the main frame driver: timers, pellets, pacman move, ghost update, collision, sprite prep.
3. `script 06` is not a full state; it is a timed overlay freeze window before returning to `04`.
4. `script 0E/10` are intermission-only and reuse `ram_shared_state_0..2` differently than gameplay.
