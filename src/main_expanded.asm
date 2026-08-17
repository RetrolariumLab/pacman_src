; Optional NROM-256 entrypoint with JSON-generated data in a new PRG bank.

.setcpu "6502"

.segment "HACK_BANK"
.org $8000

tbl_expanded_maze_rle_stream:
    .incbin "build/expanded/assets/maze.rle"

PACMAN_EXPANDED_MAZE = 1

.include "main.asm"
