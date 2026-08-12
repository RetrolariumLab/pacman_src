; Tile probes, playfield, HUD, and renderer helpers




; Build current+neighbor tile probe addresses for Pac-Man and all ghosts
sub_E154_build_object_neighbor_ppu_positions:		; was: sub_E154_calculate_ppu_positions
    LDA ram_obj_pos_X_hi
    STA ram_0002
    LDA ram_obj_pos_Y_hi
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDA ram_0003    ; ppu_pos_hi
    STA ram_obj_ppu_pos_hi_now
    LDA ram_0002    ; ppu_pos_lo
    STA ram_obj_ppu_pos_lo_now
    LDX #$00
    LDY #$00
; Build per-object PPU positions for up/left/down/right neighbors
bra_E16D_build_neighbor_ppu_positions:		; was: bra_E16D_loop
    LDA ram_obj_pos_X_hi,X
    STA ram_0002
    LDA ram_obj_pos_Y_hi,X
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDA #< $0020
    STA ram_0014
    LDA #> $0020
    STA ram_0015
    LDA ram_0002    ; ppu_pos_lo
    STA ram_0012    ; ppu_pos_lo_copy
    LDA ram_0003    ; ppu_pos_hi
    STA ram_0013    ; ppu_pos_hi_copy
    JSR sub_E24E_sub_row_stride_0020
    LDA ram_0013
; 0202-0222, interval 08
    STA ram_obj_ppu_pos_hi_up,Y
    LDA ram_0012    ; ppu_pos_lo_copy
    INY
; 0203-0223, interval 08
    STA ram_obj_ppu_pos_lo_up - $01,Y
    LDA ram_0003    ; ppu_pos_hi
    INY
; 0204-0224, interval 08
    STA ram_obj_ppu_pos_hi_left - $02,Y
    LDA ram_0002    ; ppu_pos_lo
    SEC
    SBC #$01
    INY
; 0205-0225, interval 08
    STA ram_obj_ppu_pos_lo_left - $03,Y
    LDA #< $0020
    STA ram_0014
    LDA #> $0020
    STA ram_0015
    LDA ram_0002    ; ppu_pos_lo
    STA ram_0012    ; ppu_pos_lo_copy
    LDA ram_0003    ; ppu_pos_hi
    STA ram_0013    ; ppu_pos_hi_copy
    JSR sub_E240_add_row_stride_0020
    LDA ram_0013
    INY
; 0206-0226, interval 08
    STA ram_obj_ppu_pos_hi_down - $04,Y
    LDA ram_0012    ; ppu_pos_lo_copy
    INY
; 0207-0227, interval 08
    STA ram_obj_ppu_pos_lo_down - $05,Y
    LDA ram_0003    ; ppu_pos_hi
    INY
; 0208-0228, interval 08
    STA ram_obj_ppu_pos_hi_right - $06,Y
    LDA ram_0002    ; ppu_pos_lo
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
    BNE bra_E16D_build_neighbor_ppu_positions
    RTS



; Convert world XY position to nametable PPU address
sub_E1DD_convert_world_pos_to_ppu_addr:		; was: sub_E1DD_convert_position_to_ppu
    LDA #$00
    STA ram_0005
    LDA ram_0003    ; pos_Y_hi
    SEC
    SBC #$04
    AND #$F8
    ASL
    ROL ram_0005
    ASL
    ROL ram_0005
    CLC
    ADC #$40
    STA ram_0004
    LDA #$00
    ADC ram_0005
    STA ram_0005
    LDA ram_0002    ; pos_X_hi
    SEC
    SBC #$04
    LSR
    LSR
    LSR
    CLC
    ADC ram_0004
    STA ram_0002    ; ppu_pos_lo
    LDA ram_0005
    CLC
    ADC #$20
    STA ram_0003    ; ppu_pos_hi
    LDA ram_current_player
    AND ram_game_mode
    BNE bra_E214_apply_player2_nametable_offset
    RTS
; Apply +$0800 nametable offset for player 2
bra_E214_apply_player2_nametable_offset:		; was: bra_E214
; add 0800 to ppu for 2nd player
    LDA ram_0003    ; ppu_pos_hi
    CLC
    ADC #$08
    STA ram_0003    ; ppu_pos_hi
    RTS



; Read tiles from PPU at cached object neighbor positions
sub_E21C_sample_tiles_at_obj_ppu_positions:		; was: sub_E21C_analyze_obj_ppu_pos
    LDX #$00
    LDY #$00
    LDA $2002
; Sample next neighbor tile from PPU
bra_E223_sample_next_obj_neighbor_tile:		; was: bra_E223_loop
    LDA ram_obj_ppu_position,X  ; 0200-0228, even
    STA $2006
    INX
    LDA ram_obj_ppu_position,X  ; 0201-0229, odd
    STA $2006
    LDA $2007
    LDA $2007
    STA ram_obj_ppu_tile,Y  ; 022A-023E
    INX
    INY
    CPX #$2A
    BNE bra_E223_sample_next_obj_neighbor_tile
    RTS



; Add one nametable row stride ($20) to PPU address copy
sub_E240_add_row_stride_0020:		; was: sub_E240_add_0020
; bzk optimize, 0014-0015 is always = $0020
    CLC
    LDA ram_0012
    ADC ram_0014
    STA ram_0012
    LDA ram_0013
    ADC ram_0015
    STA ram_0013
    RTS



; Subtract one nametable row stride ($20) from PPU address copy
sub_E24E_sub_row_stride_0020:		; was: sub_E24E_sbc_0020
; bzk optimize, 0014-0015 is always = $0020
    SEC
    LDA ram_0012
    SBC ram_0014
    STA ram_0012
    LDA ram_0013
    SBC ram_0015
    STA ram_0013
    RTS



; Decompress and upload maze layout data to nametable
