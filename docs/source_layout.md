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

## Address-Ordered Modules

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
