; Maze decompression, nametable upload, and background clearing

sub_decompress_and_upload_maze_layout:		; was: sub_E25C
    LDA #$20    ; 2040
    STA zp_work2
    LDA #$40
    STA zp_work3
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_select_maze_target_nametable
    LDA #$28    ; 2840
    STA zp_work2
; Select base nametable for maze upload by active player
bra_select_maze_target_nametable:		; was: bra_E26E
    LDA tbl_maze_rle_stream_ptr + $01
    STA zp_work1
    LDA tbl_maze_rle_stream_ptr
    STA zp_work0
    LDX #$1B
    LDY #$00
; Upload next compressed maze row
bra_upload_next_maze_row:		; was: bra_E27C_loop
    SetPpuAddressFrom zp_work2
    LDA #$16
    STA zp_work4
; Decode next RLE token from maze stream
bra_decode_next_maze_rle_token:		; was: bra_E28D_loop
    LDA #$00
    STA zp_work5
    LDA (zp_work0),Y    ; data from 0x002C88
    ASL
    ROL zp_work5
    ASL
    ROL zp_work5
    LDA (zp_work0),Y    ; data from 0x002C88
    AND #$3F
; Write decoded RLE run to PPU
bra_write_maze_rle_run:		; was: bra_E29D_loop
    STA PPUDATA
    DEC zp_work4
    DEC zp_work5
    BPL bra_write_maze_rle_run
    INY
    BNE bra_continue_maze_row_decode
    INC zp_work1
; Continue decoding current maze row
bra_continue_maze_row_decode:		; was: bra_E2AB
    LDA zp_work4
    BNE bra_decode_next_maze_rle_token
    LDA zp_work3
    CLC
    ADC #< $0020
    STA zp_work3
    LDA zp_work2
    ADC #> $0020
    STA zp_work2
    DEX
    BNE bra_upload_next_maze_row
    LDY #$02
    LDA #$21    ; 21D6
    STA zp_work0
    LDA #$D6
    STA zp_work1
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_select_bottom_banner_nametable
    LDA #$29    ; 29D6
    STA zp_work0
; Select bottom banner nametable by active player
bra_select_bottom_banner_nametable:		; was: bra_E2D3
; Fill bottom banner rows with pattern tiles
bra_fill_bottom_banner_rows:		; was: bra_E2D3_loop
    LDX #$07
    SetPpuAddressFrom zp_work0
    LDA tbl_bottom_banner_fill_tiles,Y
; Write one bottom banner row
bra_write_bottom_banner_row:		; was: bra_E2E5_loop
    STA PPUDATA
    DEX
    BPL bra_write_bottom_banner_row
    LDA zp_work1
    CLC
    ADC #< $0020
    STA zp_work1
    LDA #> $0020
    ADC zp_work0
    STA zp_work0
    DEY
    BPL bra_fill_bottom_banner_rows
    RTS

; Fill tiles used for bottom banner rows
tbl_bottom_banner_fill_tiles:		; was: tbl_E2FC
; fill ppu with this byte
    .byte con_tile + $2D   ; 00
    .byte con_tile + $04   ; 01
    .byte con_tile + $2D   ; 02

; Clear both nametables and attribute blocks with blank tile
sub_clear_bg_nametables_and_attrs:		; was: sub_E2FF
    SetPpuAddress $2000
    LDA #$01
    STA zp_work2
; One nametable tile-fill pass in clear routine
loc_clear_nametable_fill_pass:		; was: loc_E310
    LDA #$01
    STA zp_work3
    LDA #$03
    STA zp_work0
    LDA #$C0
    STA zp_work1
    LDA #con_tile + $2D
bra_fill_nametable_tiles:
    STA PPUDATA
    DEC zp_work1
    BNE bra_fill_nametable_tiles
    DEC zp_work0
    BPL bra_fill_nametable_tiles
    DEC zp_work3
    BNE bra_select_next_nametable_phase
    LDA #$40
    STA zp_work1
    LDA #$00
    BEQ bra_fill_nametable_tiles    ; jmp
; Select next nametable/phase in clear routine
bra_select_next_nametable_phase:		; was: bra_E335
    DEC zp_work2
    BNE bra_clear_attribute_blocks_phase
    SetPpuAddress $2800
    JMP loc_clear_nametable_fill_pass
; Clear attribute blocks after nametable fill
bra_clear_attribute_blocks_phase:		; was: bra_E349
    LDA #$01
    STA zp_work0
    SetPpuAddress $23C0
bra_clear_attribute_tables:
    LDA #$00
    TAY
bra_clear_attribute_table_bytes:
    STA PPUDATA
    INY
    CPY #$20
    BNE bra_clear_attribute_table_bytes
    DEC zp_work0
    BNE bra_select_second_attr_block
    RTS
; Switch to second attribute block during clear
bra_select_second_attr_block:		; was: bra_E36A
    SetPpuAddress $2BC0
    BNE bra_clear_attribute_tables   ; jmp

; Draw score/hiscore HUD rows for live gameplay layout
