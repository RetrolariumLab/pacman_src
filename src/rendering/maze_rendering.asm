; Maze decompression, nametable upload, and background clearing

sub_E25C_decompress_and_upload_maze_layout:		; was: sub_E25C
    LDA #$20    ; 2040
    STA ram_0002
    LDA #$40
    STA ram_0003
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E26E_select_maze_target_nametable
    LDA #$28    ; 2840
    STA ram_0002
; Select base nametable for maze upload by active player
bra_E26E_select_maze_target_nametable:		; was: bra_E26E
    LDA tbl_FFF8_maze_rle_stream_ptr + $01
    STA ram_0001
    LDA tbl_FFF8_maze_rle_stream_ptr
    STA ram_0000
    LDX #$1B
    LDY #$00
; Upload next compressed maze row
bra_E27C_upload_next_maze_row:		; was: bra_E27C_loop
    SetPpuAddressFrom ram_0002
    LDA #$16
    STA ram_0004
; Decode next RLE token from maze stream
bra_E28D_decode_next_maze_rle_token:		; was: bra_E28D_loop
    LDA #$00
    STA ram_0005
    LDA (ram_0000),Y    ; data from 0x002C88
    ASL
    ROL ram_0005
    ASL
    ROL ram_0005
    LDA (ram_0000),Y    ; data from 0x002C88
    AND #$3F
; Write decoded RLE run to PPU
bra_E29D_write_maze_rle_run:		; was: bra_E29D_loop
    STA $2007
    DEC ram_0004
    DEC ram_0005
    BPL bra_E29D_write_maze_rle_run
    INY
    BNE bra_E2AB_continue_maze_row_decode
    INC ram_0001
; Continue decoding current maze row
bra_E2AB_continue_maze_row_decode:		; was: bra_E2AB
    LDA ram_0004
    BNE bra_E28D_decode_next_maze_rle_token
    LDA ram_0003
    CLC
    ADC #< $0020
    STA ram_0003
    LDA ram_0002
    ADC #> $0020
    STA ram_0002
    DEX
    BNE bra_E27C_upload_next_maze_row
    LDY #$02
    LDA #$21    ; 21D6
    STA ram_0000
    LDA #$D6
    STA ram_0001
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E2D3_select_bottom_banner_nametable
    LDA #$29    ; 29D6
    STA ram_0000
; Select bottom banner nametable by active player
bra_E2D3_select_bottom_banner_nametable:		; was: bra_E2D3
; Fill bottom banner rows with pattern tiles
bra_E2D3_fill_bottom_banner_rows:		; was: bra_E2D3_loop
    LDX #$07
    SetPpuAddressFrom ram_0000
    LDA tbl_E2FC_bottom_banner_fill_tiles,Y
; Write one bottom banner row
bra_E2E5_write_bottom_banner_row:		; was: bra_E2E5_loop
    STA $2007
    DEX
    BPL bra_E2E5_write_bottom_banner_row
    LDA ram_0001
    CLC
    ADC #< $0020
    STA ram_0001
    LDA #> $0020
    ADC ram_0000
    STA ram_0000
    DEY
    BPL bra_E2D3_fill_bottom_banner_rows
    RTS



; Fill tiles used for bottom banner rows
tbl_E2FC_bottom_banner_fill_tiles:		; was: tbl_E2FC
; fill ppu with this byte
    .byte con_tile + $2D   ; 00
    .byte con_tile + $04   ; 01
    .byte con_tile + $2D   ; 02



; Clear both nametables and attribute blocks with blank tile
sub_E2FF_clear_bg_nametables_and_attrs:		; was: sub_E2FF
    SetPpuAddress $2000
    LDA #$01
    STA ram_0002
; One nametable tile-fill pass in clear routine
loc_E310_clear_nametable_fill_pass:		; was: loc_E310
    LDA #$01
    STA ram_0003
    LDA #$03
    STA ram_0000
    LDA #$C0
    STA ram_0001
    LDA #con_tile + $2D
bra_E31E_loop:
    STA $2007
    DEC ram_0001
    BNE bra_E31E_loop
    DEC ram_0000
    BPL bra_E31E_loop
    DEC ram_0003
    BNE bra_E335_select_next_nametable_phase
    LDA #$40
    STA ram_0001
    LDA #$00
    BEQ bra_E31E_loop    ; jmp
; Select next nametable/phase in clear routine
bra_E335_select_next_nametable_phase:		; was: bra_E335
    DEC ram_0002
    BNE bra_E349_clear_attribute_blocks_phase
    SetPpuAddress $2800
    JMP loc_E310_clear_nametable_fill_pass
; Clear attribute blocks after nametable fill
bra_E349_clear_attribute_blocks_phase:		; was: bra_E349
    LDA #$01
    STA ram_0000
    SetPpuAddress $23C0
bra_E35A_loop:
    LDA #$00
    TAY
bra_E35D_loop:
    STA $2007
    INY
    CPY #$20
    BNE bra_E35D_loop
    DEC ram_0000
    BNE bra_E36A_select_second_attr_block
    RTS
; Switch to second attribute block during clear
bra_E36A_select_second_attr_block:		; was: bra_E36A
    SetPpuAddress $2BC0
    BNE bra_E35A_loop   ; jmp



; Draw score/hiscore HUD rows for live gameplay layout
