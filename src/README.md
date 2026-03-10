# C0 Baseline (NROM-128)

This is the new clean C baseline for Pac-Man port work.

## Fixed Baseline
- Mapper: 0 (NROM)
- PRG: 16 KiB (`NES_PRG_BANKS = 1`)
- CHR: 8 KiB CHR ROM (`src/assets/pacman.chr` extracted from original ROM)
- Mirroring: horizontal (`NES_MIRRORING = 0`)
- Toolchain: `cc65/ca65/ld65` via `cl65`
- Runtime helpers: local minimal `neslib`-style API in `src/core/neslib.c`

## Build
- `make build-c0`
- `make run-c0`
- `make clean-c0`

## Current Vertical Slice
- `core/title.c`: title slide + player select
- `core/render.c`: PPU/title/gameplay rendering helpers
- `core/ppu_queue.c`: queued VRAM command helper for safe staged updates
- `core/game.c`: top-level state machine
- `game/demo.c`: attract mode (ghost names + scripted demo playback)
- `game/maze.c`: maze collision + drawing
- `game/player.c`: player movement
- `game/ghosts.c`, `game/pellets.c`: gameplay stubs for incremental porting

## Reference Sources
Used as implementation references while porting logic:
- `reference_projects/*`
- `src_old/*`
- `bank_FF.asm` (primary logic source)
- `decomp_bank_ff.c` (secondary reference)

## Next Step
- Move from full-screen redraw to vblank queue updates (ppu command buffer discipline), then add pellets and score path.
