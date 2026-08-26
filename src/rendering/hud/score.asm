; Score and high-score HUD rendering

sub_draw_score_hud_live:
    PrepareScoreHud $20B6, $80
    LDX #$00
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_select_score_addr_triplet
    LDA #> $28B6
    STA ram_score_hud_ppu_addr_hi
    BNE bra_select_score_addr_triplet  ; jmp

; Draw score/hiscore HUD rows for dual-player/title layout
sub_draw_score_hud_dual:
    PrepareScoreHud $2083, $09
    LDA #$01
    STA ram_game_mode
    LDX #$0C
; Select score-address triplet based on mode/player
bra_select_score_addr_triplet:
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_init_hud_row_counter
    TXA
    CLC
    ADC #$06
    TAX
; Initialize HUD row draw counter
bra_init_hud_row_counter:
    LDA #$03
    STA ram_score_hud_row_count
; Draw next HUD row packet
bra_draw_next_hud_row:
    SetPpuAddressFrom ram_score_hud_ppu_addr_hi
    LDA tbl_score_source_triplets,X
    STA ram_score_hud_value_ptr
    LDA tbl_score_source_triplets + $01,X
    STA ram_score_hud_value_ptr + $01
    JSR sub_write_6digit_score_to_ppu
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
    BNE bra_continue_hud_row_loop
    LDA ram_game_mode
    BEQ bra_return_from_score_hud_draw
; Continue HUD row loop unless done
bra_continue_hud_row_loop:
    LDA ram_score_hud_row_count
    BNE bra_draw_next_hud_row
; Return from HUD row draw routine
bra_return_from_score_hud_draw:
    RTS

; Write one 6-digit score value to PPU with leading-space suppression
sub_write_6digit_score_to_ppu:
    LDY #$05
; Skip leading zeros while writing score digits
bra_skip_leading_zeros_in_score:
    LDA (ram_score_hud_value_ptr),Y  ; 0064 0065 0066 0071 0072 0073 0074 0075 0081 0082 0083 0084 0085
    AND #$0F
    BNE bra_emit_score_digit_tile
    LDA #con_tile_space
    STA PPUDATA
    DEY
    BNE bra_skip_leading_zeros_in_score
    BEQ bra_write_last_digit_and_suffix  ; jmp
; Write remaining score digits
bra_write_remaining_score_digits:
    LDA (ram_score_hud_value_ptr),Y  ; 0062 0063 0064 0071 0072 0073 0081 0082
; Emit one score digit tile
bra_emit_score_digit_tile:
    JSR sub_digit_to_score_tile
    STA PPUDATA
    DEY
    BNE bra_write_remaining_score_digits
; Write least-significant digit and trailing zero tile
bra_write_last_digit_and_suffix:
; Y = 00
    LDA (ram_score_hud_value_ptr),Y  ; 0061 0070 0080
    JSR sub_digit_to_score_tile
    STA PPUDATA
    LDA #con_tile_score_zero
    STA PPUDATA
    RTS

; Source RAM triplets (hiscore/p1/p2 order) for HUD draw
tbl_score_source_triplets:
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
