; Prepare the scratch state shared by the score HUD entry points.
.macro PrepareScoreHud ppu_address, row_stride
    LDA #> ppu_address
    STA ram_score_hud_ppu_addr_hi
    LDA #< ppu_address
    STA ram_score_hud_ppu_addr_lo
    LDA #row_stride
    STA ram_score_hud_row_stride
.endmacro
