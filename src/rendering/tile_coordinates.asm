; Tile probes, playfield, HUD, and renderer helpers

; Build current+neighbor tile probe addresses for Pac-Man and all ghosts
sub_build_object_neighbor_ppu_positions:		; was: sub_E154_calculate_ppu_positions
    LDA ram_obj_pos_X_hi
    STA zp_work2
    LDA ram_obj_pos_Y_hi
    STA zp_work3
    JSR sub_convert_world_pos_to_ppu_addr
    LDA zp_work3    ; ppu_pos_hi
    STA ram_obj_ppu_pos_hi_now
    LDA zp_work2    ; ppu_pos_lo
    STA ram_obj_ppu_pos_lo_now
    LDX #$00
    LDY #$00
; Build per-object PPU positions for up/left/down/right neighbors
bra_build_neighbor_ppu_positions:		; was: bra_E16D_loop
    LDA ram_obj_pos_X_hi,X
    STA zp_work2
    LDA ram_obj_pos_Y_hi,X
    STA zp_work3
    JSR sub_convert_world_pos_to_ppu_addr
    LDA #< $0020
    STA ram_ppu_row_delta_lo
    LDA #> $0020
    STA ram_ppu_row_delta_hi
    LDA zp_work2    ; ppu_pos_lo
    STA ram_ppu_work_addr_lo
    LDA zp_work3    ; ppu_pos_hi
    STA ram_ppu_work_addr_hi
    JSR sub_subtract_nametable_row_stride
    LDA ram_ppu_work_addr_hi
; 0202-0222, interval 08
    STA ram_obj_ppu_pos_hi_up,Y
    LDA ram_ppu_work_addr_lo
    INY
; 0203-0223, interval 08
    STA ram_obj_ppu_pos_lo_up - $01,Y
    LDA zp_work3    ; ppu_pos_hi
    INY
; 0204-0224, interval 08
    STA ram_obj_ppu_pos_hi_left - $02,Y
    LDA zp_work2    ; ppu_pos_lo
    SEC
    SBC #$01
    INY
; 0205-0225, interval 08
    STA ram_obj_ppu_pos_lo_left - $03,Y
    LDA #< $0020
    STA ram_ppu_row_delta_lo
    LDA #> $0020
    STA ram_ppu_row_delta_hi
    LDA zp_work2    ; ppu_pos_lo
    STA ram_ppu_work_addr_lo
    LDA zp_work3    ; ppu_pos_hi
    STA ram_ppu_work_addr_hi
    JSR sub_add_nametable_row_stride
    LDA ram_ppu_work_addr_hi
    INY
; 0206-0226, interval 08
    STA ram_obj_ppu_pos_hi_down - $04,Y
    LDA ram_ppu_work_addr_lo
    INY
; 0207-0227, interval 08
    STA ram_obj_ppu_pos_lo_down - $05,Y
    LDA zp_work3    ; ppu_pos_hi
    INY
; 0208-0228, interval 08
    STA ram_obj_ppu_pos_hi_right - $06,Y
    LDA zp_work2    ; ppu_pos_lo
    CLC
    ADC #$01
    INY
; 0209-0229, interval 08
    STA ram_obj_ppu_pos_lo_right - $07,Y
    INX
    INX
    INX
    INX
    INY
    CPY #$28
    BNE bra_build_neighbor_ppu_positions
    RTS

; Convert world XY position to nametable PPU address
sub_convert_world_pos_to_ppu_addr:		; was: sub_E1DD_convert_position_to_ppu
    LDA #$00
    STA zp_work5
    LDA zp_work3    ; pos_Y_hi
    SEC
    SBC #$04
    AND #$F8
    ASL
    ROL zp_work5
    ASL
    ROL zp_work5
    CLC
    ADC #$40
    STA zp_work4
    LDA #$00
    ADC zp_work5
    STA zp_work5
    LDA zp_work2    ; pos_X_hi
    SEC
    SBC #$04
    LSR
    LSR
    LSR
    CLC
    ADC zp_work4
    STA zp_work2    ; ppu_pos_lo
    LDA zp_work5
    CLC
    ADC #$20
    STA zp_work3    ; ppu_pos_hi
    LDA ram_current_player
    AND ram_game_mode
    BNE bra_apply_player2_nametable_offset
    RTS
; Apply +$0800 nametable offset for player 2
bra_apply_player2_nametable_offset:		; was: bra_E214
; add 0800 to ppu for 2nd player
    LDA zp_work3    ; ppu_pos_hi
    CLC
    ADC #$08
    STA zp_work3    ; ppu_pos_hi
    RTS

; Read tiles from PPU at cached object neighbor positions
sub_sample_tiles_at_obj_ppu_positions:		; was: sub_E21C_analyze_obj_ppu_pos
    LDX #$00
    LDY #$00
    LDA PPUSTATUS
; Sample next neighbor tile from PPU
bra_sample_next_obj_neighbor_tile:		; was: bra_E223_loop
    LDA ram_obj_ppu_position,X  ; 0200-0228, even
    STA PPUADDR
    INX
    LDA ram_obj_ppu_position,X  ; 0201-0229, odd
    STA PPUADDR
    LDA PPUDATA
    LDA PPUDATA
    STA ram_obj_ppu_tile,Y  ; 022A-023E
    INX
    INY
    CPX #$2A
    BNE bra_sample_next_obj_neighbor_tile
    RTS

; Add one nametable row stride ($20) to PPU address copy
sub_add_nametable_row_stride:		; was: sub_E240_add_0020
; !(OBS) All callers set row delta to $0020. See resolved CODE-003.
    CLC
    LDA ram_ppu_work_addr_lo
    ADC ram_ppu_row_delta_lo
    STA ram_ppu_work_addr_lo
    LDA ram_ppu_work_addr_hi
    ADC ram_ppu_row_delta_hi
    STA ram_ppu_work_addr_hi
    RTS

; Subtract one nametable row stride ($20) from PPU address copy
sub_subtract_nametable_row_stride:		; was: sub_E24E_sbc_0020
; !(OBS) All callers set row delta to $0020. See resolved CODE-003.
    SEC
    LDA ram_ppu_work_addr_lo
    SBC ram_ppu_row_delta_lo
    STA ram_ppu_work_addr_lo
    LDA ram_ppu_work_addr_hi
    SBC ram_ppu_row_delta_hi
    STA ram_ppu_work_addr_hi
    RTS

; Decompress and upload maze layout data to nametable
