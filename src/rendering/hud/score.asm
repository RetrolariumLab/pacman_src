; Score and high-score HUD rendering

sub_E379_draw_score_hud_live:		; was: sub_E379
    PrepareScoreHud $20B6, $80
    LDX #$00
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E3A5_select_score_addr_triplet
    LDA #> $28B6
    STA ram_score_hud_ppu_addr_hi
    BNE bra_E3A5_select_score_addr_triplet    ; jmp



; Draw score/hiscore HUD rows for dual-player/title layout
sub_E393_draw_score_hud_dual:		; was: sub_E393
    PrepareScoreHud $2083, $09
    LDA #$01
    STA ram_game_mode
    LDX #$0C
; Select score-address triplet based on mode/player
bra_E3A5_select_score_addr_triplet:		; was: bra_E3A5
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E3B0_init_hud_row_counter
    TXA
    CLC
    ADC #$06
    TAX
; Initialize HUD row draw counter
bra_E3B0_init_hud_row_counter:		; was: bra_E3B0
    LDA #$03
    STA ram_score_hud_row_count
; Draw next HUD row packet
bra_E3B4_draw_next_hud_row:		; was: bra_E3B4_loop
    SetPpuAddressFrom ram_score_hud_ppu_addr_hi
    LDA tbl_E419_score_source_triplets,X
    STA ram_score_hud_value_ptr
    LDA tbl_E419_score_source_triplets + $01,X
    STA ram_score_hud_value_ptr + $01
    JSR sub_E3EE_write_6digit_score_to_ppu
    INX
    INX
    LDA ram_score_hud_ppu_addr_lo
    CLC
    ADC ram_score_hud_row_stride
    STA ram_score_hud_ppu_addr_lo
    LDA #$00
    ADC ram_score_hud_ppu_addr_hi
    STA ram_score_hud_ppu_addr_hi
    DEC ram_score_hud_row_count
    LDA ram_score_hud_row_count
    CMP #$01
    BNE bra_E3E9_continue_hud_row_loop
    LDA ram_game_mode
    BEQ bra_E3ED_return
; Continue HUD row loop unless done
bra_E3E9_continue_hud_row_loop:		; was: bra_E3E9
    LDA ram_score_hud_row_count
    BNE bra_E3B4_draw_next_hud_row
; Return from HUD row draw routine
bra_E3ED_return:		; was: bra_E3ED_RTS
    RTS



; Write one 6-digit score value to PPU with leading-space suppression
sub_E3EE_write_6digit_score_to_ppu:		; was: sub_E3EE
    LDY #$05
; Skip leading zeros while writing score digits
bra_E3F0_skip_leading_zeros_in_score:		; was: bra_E3F0_loop
    LDA (ram_score_hud_value_ptr),Y    ; 0064 0065 0066 0071 0072 0073 0074 0075 0081 0082 0083 0084 0085
    AND #$0F
    BNE bra_E402_emit_score_digit_tile
    LDA #con_tile + $20
    STA $2007
    DEY
    BNE bra_E3F0_skip_leading_zeros_in_score
    BEQ bra_E40B_write_last_digit_and_suffix    ; jmp
; Write remaining score digits
bra_E400_write_remaining_score_digits:		; was: bra_E400_loop
    LDA (ram_score_hud_value_ptr),Y    ; 0062 0063 0064 0071 0072 0073 0081 0082
; Emit one score digit tile
bra_E402_emit_score_digit_tile:		; was: bra_E402
    JSR sub_E148_digit_to_score_tile
    STA $2007
    DEY
    BNE bra_E400_write_remaining_score_digits
; Write least-significant digit and trailing zero tile
bra_E40B_write_last_digit_and_suffix:		; was: bra_E40B
; Y = 00
    LDA (ram_score_hud_value_ptr),Y    ; 0061 0070 0080
    JSR sub_E148_digit_to_score_tile
    STA $2007
    LDA #con_tile + $30
    STA $2007
    RTS



; Source RAM triplets (hiscore/p1/p2 order) for HUD draw
tbl_E419_score_source_triplets:		; was: tbl_E419_score_addr
; 00
    .word ram_score_hi
    .word ram_score_p1
    .word ram_score_p2
; 06
    .word ram_score_hi
    .word ram_score_p2
    .word ram_score_p1
; 0C
    .word ram_score_p1
    .word ram_score_hi
    .word ram_score_p2



; Collect valid turn candidates from tile neighborhood
