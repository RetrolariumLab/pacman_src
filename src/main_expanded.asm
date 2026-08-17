; Optional NROM-256 entrypoint with JSON-generated data in a new PRG bank.

.setcpu "6502"

.segment "HACK_BANK"
.org $8000

tbl_expanded_maze_rle_stream:
    .incbin "build/expanded/assets/maze.rle"

tbl_expanded_stage_parameters:
    .incbin "build/expanded/assets/stage_parameters.bin"

.assert tbl_expanded_maze_rle_stream = $8000, error, "expanded maze must begin at $8000"
.assert tbl_expanded_stage_parameters = $81A0, error, "expanded stage data must begin at $81A0"

PACMAN_EXPANDED_MAZE = 1
PACMAN_EXPANDED_STAGE = 1

.include "main.asm"
