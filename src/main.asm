; Pac-Man (NES, JP) native ca65 source entrypoint.
; Module order is ROM order and must not change.

.setcpu "6502"

.include "memory/ram.inc"
.include "memory/constants.inc"

.include "system/boot_and_frame.asm"          ; C000-C1F4
.include "game/title_and_attract.asm"         ; C1F5-C989
.include "game/state_machine.asm"             ; C98A-D0EE
.include "game/round_runtime.asm"             ; D0EF-D2FA
.include "game/pacman_movement.asm"           ; D2FB-D4C1
.include "game/ghost_ai.asm"                  ; D4C2-D8F8
.include "rendering/actors.asm"               ; D8F9-DEDE
.include "game/scoring.asm"                   ; DEDF-E153
.include "rendering/playfield_and_hud.asm"    ; E154-E654
.include "game/intermissions.asm"             ; E655-EB41
.include "data/stage_params_and_maze.asm"     ; EB42-EE17
.include "audio/engine.asm"                   ; EE18-F3FF
.include "data/tail_and_vectors.asm"          ; F400-FFFF
