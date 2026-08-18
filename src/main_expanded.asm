; Optional NROM-256 entrypoint with JSON-generated data in a new PRG bank.

.setcpu "6502"

.segment "HACK_BANK"
.org $8000

tbl_expanded_maze_rle_stream:
    .incbin "assets/generated/maze/maze.rle"

tbl_expanded_stage_parameters:
    .incbin "build/expanded/assets/stage_parameters.bin"

tbl_expanded_stage2_maze_rle_stream:
    .incbin "build/expanded/assets/maze.rle"

; Select the original maze for stage 1 and the editable maze for stage 2+.
; This helper lives entirely in the added bank; the fixed-bank call site keeps
; its original width so no preservation addresses move.
sub_select_expanded_maze:
    LDA a:ram_stage_p1
    CMP #$01
    BCC bra_select_expanded_stage1_maze
    LDA #<tbl_expanded_stage2_maze_rle_stream
    STA z:zp_work0
    LDA #>tbl_expanded_stage2_maze_rle_stream
    STA z:zp_work1
    RTS
bra_select_expanded_stage1_maze:
    LDA #<tbl_expanded_maze_rle_stream
    STA z:zp_work0
    LDA #>tbl_expanded_maze_rle_stream
    STA z:zp_work1
    RTS

.assert tbl_expanded_maze_rle_stream = $8000, error, "expanded maze must begin at $8000"
.assert tbl_expanded_stage_parameters = $81A0, error, "expanded stage data must begin at $81A0"
.assert tbl_expanded_stage2_maze_rle_stream = $82D6, error, "stage-2 maze must begin at $82D6"
.assert sub_select_expanded_maze = $8476, error, "maze selector must begin at $8476"

PACMAN_EXPANDED_MAZE = 1
PACMAN_EXPANDED_STAGE = 1
PACMAN_EXPANDED_MULTI_MAZE = 1

.include "main.asm"
