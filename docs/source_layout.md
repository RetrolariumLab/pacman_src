# Source Module Layout

`src/main.asm` is the canonical module index. Its includes follow CPU address
order exactly; moving an include changes the ROM layout and must fail
`make verify`.

## Sizing Rule

- Prefer one coherent responsibility per file.
- Aim for roughly 200–500 lines when a natural boundary exists.
- Treat 700 lines as a soft upper limit rather than splitting a procedure or
  separating a small table from the code that owns it.
- Very small modules are acceptable for isolated formats, generated assets,
  vectors, or short helpers that do not belong to adjacent subsystems.

The current largest native source module is below 600 lines.

## Japan V1.0 Address Map

The ranges below describe the canonical Japan V1.0 profile. Other official
profiles preserve the same semantic module order but can place boundaries at
different CPU addresses, so ranges are intentionally not duplicated in
`src/main.asm`.

| Range | Module | Responsibility |
|---|---|---|
| `C000..C1F4` | `system/boot_and_frame.asm` | Reset, NMI, input, frame bootstrap |
| `C1F5..C457` | `game/title/screen.asm` | Title drawing and menu input |
| `C458..C6C7` | `game/title/attract_intro.asm` | Attract introduction and text packets |
| `C6C8..C989` | `game/title/attract_chase.asm` | Attract chase simulation and animation |
| `C98A..CA9C` | `game/round/gameplay_loop.asm` | Session loop, script dispatch, pause |
| `CA9D..CC0E` | `game/round/ready.asm` | READY sequence and player handoff |
| `CC0F..CE34` | `game/round/transitions.asm` | Death, stage clear, game over |
| `CE35..D0EE` | `game/round/setup.asm` | Round initialization and table loading |
| `D0EF..D2FA` | `game/round/runtime.asm` | Timers, releases, fruit, collisions |
| `D2FB..D4C1` | `game/pacman_movement.asm` | Pac-Man input and movement |
| `D4C2..D78B` | `game/ghosts/navigation.asm` | Ghost movement, targeting, path choice |
| `D78C..D8F8` | `game/ghosts/house.asm` | Speed profiles, house and release logic |
| `D8F9..DA5B` | `rendering/actors/animation.asm` | Actor animation and positions |
| `DA5C..DDC8` | `rendering/actors/oam.asm` | OAM construction and sprite tables |
| `DDC9..DEDE` | `rendering/ppu_updates.asm` | Buffered PPU writes and pellet blinking |
| `DEDF..E153` | `game/scoring.asm` | Pellets, fruit, score, extra life |
| `E154..E25B` | `rendering/tile_coordinates.asm` | Tile probes and coordinate conversion |
| `E25C..E378` | `rendering/maze_rendering.asm` | Maze upload and nametable clearing |
| `E379..E42A` | `rendering/hud/score.asm` | Score and high-score display |
| `E42B..E47B` | `game/turn_candidates.asm` | Valid movement-direction collection |
| `E47C..E654` | `rendering/hud/status.asm` | Text, lives, fruit history, icons |
| `E655..E74A` | `game/intermission/setup.asm` | Intermission playfield setup |
| `E74B..E9A4` | `game/intermission/scenes.asm` | Three intermission scene scripts |
| `E9A5..EA1F` | `game/intermission/actors.asm` | Actor movement and visibility |
| `EA20..EB41` | `game/intermission/animation.asm` | Intermission tile animations |
| `EB42..EC77` | `data/stage_parameters.asm` | Editable stage tuning tables |
| `EC78..EE17` | `data/maze.asm` | Generated compressed maze asset |
| `EE18..F0AD` | `audio/engine.asm` | Decoder and audio support tables |
| `F0AE..F427` | `audio/streams.asm` | Generated audio streams |
| `F428..FFFF` | `data/tail_and_vectors.asm` | Padding, maze pointer, vectors |

These are source-organization boundaries, not linker segments or movable ROM
sections. Cross-file branches and labels intentionally remain global within the
single ca65 translation unit.

Reusable inline operations live under `src/macros/` and emit bytes at their
call sites; they do not own ROM ranges. See [macros.md](./macros.md).

Shared address and constant definitions live under `src/memory/`, while
revision selection lives under `src/revisions/`:

- `profile_ids.inc` names the seven revisions and `derived_flags.inc` derives
  the feature flags (see Revisions below);
- `hardware.inc` names CPU-visible NES registers and proven register bit masks;
- `ram.inc` maps runtime RAM fields;
- `constants.inc` defines verified gameplay and data-format constants.

These includes emit no bytes and are loaded by `src/main.asm` before macros and
address-ordered ROM modules.

## Revisions

Each revision has an entry file, `src/revisions/<id>.asm`, that sets
`PACMAN_REVISION` to one of the ids of `profile_ids.inc` and includes
`src/main.asm`; `main.asm` refuses to assemble on its own.
`derived_flags.inc` derives the `PACMAN_REVISION_TENGEN`,
`PACMAN_REVISION_RAM_PALETTES` and `PACMAN_REVISION_LATE_NAMCO` flags from it.
`main.asm` writes the iNES header and includes the revision's CHR, so ld65
links the whole image (`config/linker/nrom128.cfg`).

## Where to start

| Area | Entry points |
|---|---|
| Boot, NMI, input | `vec_reset_entry`, `vec_nmi_handler`, `loc_main_frame_bootstrap` |
| Title, attract, demo | `tbl_script_handlers_title_flow`, `sub_draw_title_logo_and_text` |
| Gameplay scripts | `loc_enter_gameplay_session`, `tbl_gameplay_script_handlers`, `handler_script00_round_init` |
| Timers, release, fruit, collisions | `sub_update_round_timers_and_frightened`, `sub_queue_next_ghost_release`, `sub_check_actor_collisions` |
| Pac-Man movement | `sub_update_pacman_movement`, `loc_apply_requested_direction` |
| Ghosts | `sub_update_ghost_slots`, `sub_dispatch_ghost_state_handler`, `loc_choose_next_direction` |
| Animation, OAM, PPU buffer | `sub_update_pacman_anim_frame`, `sub_build_oam_from_sprite_buffers`, `sub_write_buffer_to_ppu` |
| Pellets, score, 1UP | `sub_check_for_eating_pellets`, `loc_add_points_and_update_score_buffers` |
| Tiles, playfield, HUD | `sub_build_object_neighbor_ppu_positions`, `sub_clear_bg_nametables_and_attrs`, `sub_draw_score_hud_live` |
| Intermissions | `handler_script_0e_intermission_setup`, `sub_run_intermission_scene_dispatch`, `sub_run_intermission_animation_dispatch` |
| Sound | `sub_init_sound_engine`, `sub_update_sound_engine`, `tbl_sound_control_opcode_handlers` |

The RAM fields these share are in [ram_fields.md](./ram_fields.md).
