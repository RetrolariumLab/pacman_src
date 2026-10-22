; Pac-Man (NES) source, assembled through a revision's entry file,
; src/revisions/<id>.asm; module order is ROM order

.setcpu "6502"

.ifndef PACMAN_REVISION
    .error "assemble a revision's entry file, src/revisions/<id>.asm"
.endif

.include "revisions/derived_flags.inc"

.segment "HEADER"

    .byte "NES", $1A  ; iNES magic
    .byte $01  ; one 16 KiB PRG-ROM bank
    .byte $01  ; one 8 KiB CHR-ROM bank
    .byte $00  ; mapper 0, horizontal mirroring
    .byte $00  ; upper mapper bits
    .byte $00, $00, $00, $00, $00, $00, $00, $00

.include "memory/ram.inc"
.include "memory/hardware.inc"
.include "memory/constants.inc"
.include "macros/memory.inc"
.include "macros/ppu.inc"
.include "macros/hud.inc"
.include "macros/actors.inc"

.include "system/boot_and_frame.asm"
.include "game/title/screen.asm"
.include "game/title/attract_intro.asm"
.include "game/title/attract_chase.asm"
.include "game/round/gameplay_loop.asm"
.include "game/round/ready.asm"
.include "game/round/transitions.asm"
.include "game/round/setup.asm"
.include "game/round/runtime.asm"
.include "game/pacman_movement.asm"
.include "game/ghosts/navigation.asm"
.include "game/ghosts/house.asm"
.include "rendering/actors/animation.asm"
.include "rendering/actors/oam.asm"
.include "rendering/ppu_updates.asm"
.include "game/scoring.asm"
.include "rendering/tile_coordinates.asm"
.include "rendering/maze_rendering.asm"
.include "rendering/hud/score.asm"
.include "game/turn_candidates.asm"
.include "rendering/hud/status.asm"
.include "game/intermission/setup.asm"
.include "game/intermission/scenes.asm"
.include "game/intermission/actors.asm"
.include "game/intermission/animation.asm"
.include "data/stage_parameters.asm"
.include "data/maze.asm"
.include "audio/engine.asm"
.include "audio/streams.asm"
.include "data/tail_and_vectors.asm"

; The CHR, cut from the ROMs (make split): Namco's USA and the European
; release have their own, the other revisions share v1.0's
.segment "CHR"
.if PACMAN_REVISION = REVISION_USA_NAMCO
    .incbin "assets/generated/chr/usa-namco.chr"
.elseif PACMAN_REVISION = REVISION_EUROPE
    .incbin "assets/generated/chr/europe.chr"
.else
    .incbin "assets/generated/chr/pacman.chr"
.endif
