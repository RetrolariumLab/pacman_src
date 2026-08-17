# Gameplay Script States (`ram_script`)

## Scope

This document tracks the gameplay/intermission script state machine dispatched by:

- `bra_dispatch_current_script`
- `tbl_gameplay_script_handlers`

`ram_script` stores even-valued byte offsets into a table of 16-bit handler
addresses. Title flow reuses some numeric values but has a separate dispatcher
and separate `con_title_script_*` constants.

## State Table
| Constant | Handler | Meaning |
|---|---|---|
| `con_game_script_round_init` (`00`) | `handler_script00_round_init` | Round/session init, table loads, HUD/maze setup. |
| `con_game_script_round_ready` (`02`) | `handler_script02_round_ready` | READY pre-control countdown and text sprites. |
| `con_game_script_pause` (`04`) | `handler_script04_pause_handler` | Main active gameplay frame loop and pause gate. |
| `con_game_script_post_eat_pause` (`06`) | `handler_script06_post_eat_pause` | Short freeze after an eaten-ghost score popup. |
| `con_game_script_death` (`08`) | `handler_script08_death_sequence` | Death animation and life/player handoff. |
| `con_game_script_game_over` (`0A`) | `handler_script0A_game_over` | GAME OVER composition, timeout, and exit. |
| `con_game_script_stage_clear` (`0C`) | `handler_script0C_stage_clear` | Stage-clear flash and intermission gate. |
| `con_game_script_intermission_setup` (`0E`) | `handler_script0E_intermission_setup` | One-shot intermission setup. |
| `con_game_script_intermission_runtime` (`10`) | `handler_script10_intermission_runtime` | Per-frame intermission scene runtime. |

## Observed Transitions
| From | To | Trigger |
|---|---|---|
| `round_init` | `round_ready` | Round initialization selects READY before completing its setup tail. |
| `round_ready` | `pause` | Both READY sound channels have stopped. |
| `pause` | `post_eat_pause` | A frightened ghost is captured and its score popup is prepared. |
| `post_eat_pause` | `pause` | The popup timer expires and the captured ghost becomes returning eyes. |
| `pause` | `death` | Collision with a non-frightened active ghost. |
| `death` | `game_over` | The active player has no remaining lives. |
| `death` | `round_init` | Respawn or player handoff requires round reinitialization. |
| `pause` | `stage_clear` | Pellet consumption reduces the remaining count to zero. |
| `stage_clear` | `round_init` | The cleared stage does not trigger an intermission. |
| `stage_clear` | `intermission_setup` | A configured stage threshold selects an intermission. |
| `intermission_setup` | `intermission_runtime` | Palette, playfield, and actor setup completes. |
| `intermission_runtime` | `round_init` | The selected scene reaches its shared return path. |
| gameplay demo | title `menu_idle` | Start or Select exits demo playback through `loc_main_frame_bootstrap`; this changes dispatcher context. |

## Dispatcher Contract

- `loc_gameplay_mainloop_wait_nmi` requests one NMI and waits for the handler to
  clear `ram_nmi_wait` before script work begins.
- `ram_script_delay` suppresses dispatch while nonzero. Its final decrement to
  zero still returns to the NMI wait, so the handler runs on the next frame.
- Dispatch reads a 16-bit address at `tbl_gameplay_script_handlers + ram_script`
  and tail-jumps through `ram_indirect_jmp`.
- Every handler returns to the NMI wait, transfers to the bootstrap when
  changing dispatcher context, or tail-jumps into another documented path.

## Shared State Ownership

| Script context | Shared fields |
|---|---|
| `round_ready` | `ram_shared_state_0` is the READY timer. |
| `pause` | `ram_shared_state_1` is the frightened-ghost mask; bytes 2/3 are its timer. |
| `death` | `ram_shared_state_0` selects pre-animation versus animation phase. |
| `game_over` | `ram_shared_state_0` is the wrapping timeout counter. |
| `stage_clear` | `ram_shared_state_0` drives initialization and flash phases, then temporarily selects the intermission scene. |
| intermission scripts | Bytes 0/1/2 are scene ID, scene-local substate, and local timer; see `intermission_flow.md`. |

## Invariants to Preserve
1. Keep script values as even byte offsets and preserve dispatch table order.
2. Treat `con_game_script_pause` as the main frame driver: timers, pellets,
   Pac-Man movement, ghost updates, collision, and sprite preparation execute in
   that order when not paused.
3. `con_game_script_post_eat_pause` is a restricted update window: only pellet
   blink, returning-eyes movement, ghost animation, and sprite preparation run.
4. Do not interpret title constants through the gameplay table even when their
   numeric values match.
5. Interpret `ram_shared_state_*` only under the currently active script owner.
