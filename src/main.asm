; Pac-Man (NES, JP) native ca65 source entrypoint.
; Module order is ROM order and must not change.

.setcpu "6502"

.include "memory/ram.inc"
.include "memory/hardware.inc"
.include "memory/constants.inc"
.include "macros/memory.inc"
.include "macros/ppu.inc"
.include "macros/hud.inc"
.include "macros/actors.inc"

.include "system/boot_and_frame.asm"          ; C000-C1F4
.include "game/title/screen.asm"                ; C1F5-C457
.include "game/title/attract_intro.asm"         ; C458-C6C7
.include "game/title/attract_chase.asm"         ; C6C8-C989
.include "game/round/gameplay_loop.asm"         ; C98A-CA9C
.include "game/round/ready.asm"                 ; CA9D-CC0E
.include "game/round/transitions.asm"           ; CC0F-CE34
.include "game/round/setup.asm"                 ; CE35-D0EE
.include "game/round/runtime.asm"               ; D0EF-D2FA
.include "game/pacman_movement.asm"           ; D2FB-D4C1
.include "game/ghosts/navigation.asm"           ; D4C2-D78B
.include "game/ghosts/house.asm"                ; D78C-D8F8
.include "rendering/actors/animation.asm"       ; D8F9-DA5B
.include "rendering/actors/oam.asm"             ; DA5C-DDC8
.include "rendering/ppu_updates.asm"           ; DDC9-DEDE
.include "game/scoring.asm"                   ; DEDF-E153
.include "rendering/tile_coordinates.asm"      ; E154-E25B
.include "rendering/maze_rendering.asm"        ; E25C-E378
.include "rendering/hud/score.asm"              ; E379-E42A
.include "game/turn_candidates.asm"            ; E42B-E47B
.include "rendering/hud/status.asm"             ; E47C-E654
.include "game/intermission/setup.asm"          ; E655-E74A
.include "game/intermission/scenes.asm"         ; E74B-E9A4
.include "game/intermission/actors.asm"         ; E9A5-EA1F
.include "game/intermission/animation.asm"      ; EA20-EB41
.include "data/stage_parameters.asm"          ; EB42-EC77
.include "data/maze.asm"                      ; EC78-EE17
.include "audio/engine.asm"                   ; EE18-F0AD
.include "audio/streams.asm"                  ; F0AE-F427
.include "data/tail_and_vectors.asm"          ; F428-FFFF
