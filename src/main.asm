; Pac-Man (NES, JP) native ca65 source entrypoint.
; Module order is ROM order and must not change.

.setcpu "6502"

.include "memory/ram.inc"
.include "memory/constants.inc"

.include "bank_ff/00_boot_and_frame.asm"
.include "bank_ff/01_title_and_attract.asm"
.include "bank_ff/02_gameplay_core.asm"
.include "bank_ff/03_timers_collisions.asm"
.include "bank_ff/04_pacman_movement.asm"
.include "bank_ff/05_ghost_ai.asm"
.include "bank_ff/06_actor_rendering.asm"
.include "bank_ff/07_score_and_bonus.asm"
.include "bank_ff/08_playfield_hud.asm"
.include "bank_ff/09_intermissions.asm"
.include "bank_ff/10_stage_data.asm"
.include "bank_ff/11_sound_engine.asm"
.include "bank_ff/12_padding_and_vectors.asm"
