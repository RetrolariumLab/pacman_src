; Title screen drawing, menu input, and player-count selection




; Jump table for title-flow scripts 00/02/04
tbl_C1F5_script_handlers_title_flow:		; was: tbl_C1F5
    .word ofs_000_C1FB_script00_title_scroll_in
    .word ofs_000_C3BD_script02_title_menu_idle
    .word ofs_000_C458_script04_attract_intro



; Script 00: title scroll-in and transition to menu script
ofs_000_C1FB_script00_title_scroll_in:		; was: ofs_000_C1FB_00
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_C208_continue_title_scroll
    LDA #con_script_02
    STA ram_script
    JMP loc_C168_main_frame_bootstrap
; Advance title scroll until target Y reached
bra_C208_continue_title_scroll:		; was: bra_C208
    INC ram_scroll_Y
    LDA #$F0
    CMP ram_scroll_Y
    BNE bra_C21C_dispatch_next_frame
    LDA #$00
    STA ram_scroll_Y
    LDA #$88
    STA ram_for_2000
    LDA #con_script_02
    STA ram_script
; Return to script dispatcher on next frame
bra_C21C_dispatch_next_frame:		; was: bra_C21C
    JMP loc_C1DE_script_dispatch_loop



; Draw title logo bitmap rows and text packets
sub_C21F_draw_title_logo_and_text:		; was: sub_C21F_draw_logo_screen
    LDA #> $20E5
    STA ram_0000
    LDA #< $20E5
    STA ram_0001
    LDA #$06    ; counter
    STA ram_0002
    LDY #$00
; Iterate over title logo rows
bra_C22D_draw_next_logo_row:		; was: bra_C22D_loop
    SetPpuAddressFrom ram_0000
    LDA #$17
    STA ram_0003
; Stream one title logo row tile sequence
bra_C23E_stream_logo_row_tiles:		; was: bra_C23E_loop
    LDA tbl_C29F_title_logo_tiles,Y
    STA $2007
    INY
    DEC ram_0003
    BNE bra_C23E_stream_logo_row_tiles
    LDA ram_0001
    CLC
    ADC #< $0020
    STA ram_0001
    LDA #> $0020
    ADC ram_0000
    STA ram_0000
    DEC ram_0002
    BNE bra_C22D_draw_next_logo_row
; draw text
    LDA #$06    ; counter
    STA ram_0000
    LDY #$00
; Draw next title text packet header+payload
bra_C260_draw_next_logo_text_packet:		; was: bra_C260_loop
    LDA $2002
    LDA tbl_C329_title_logo_text_packets,Y
    STA $2006
    INY
    LDA tbl_C329_title_logo_text_packets,Y
    STA $2006
    INY
; Stream text payload bytes until FF terminator
bra_C271_stream_logo_text_until_ff:		; was: bra_C271_loop
    LDA tbl_C329_title_logo_text_packets,Y
    CMP #$FF
    BEQ bra_C27E_advance_to_next_logo_text_packet
    STA $2007
    INY
    BNE bra_C271_stream_logo_text_until_ff
; Advance to next title text packet
bra_C27E_advance_to_next_logo_text_packet:		; was: bra_C27E
    INY
    DEC ram_0000
    BNE bra_C260_draw_next_logo_text_packet
    RTS



; Upload title-screen attribute bytes
sub_C284_upload_title_attribute_table:		; was: sub_C284_set_bg_attr
    SetPpuAddress $23C8
    LDY #$00
; Upload next title attribute byte
bra_C293_upload_next_attribute_byte:		; was: bra_C293_loop
    LDA tbl_C3A5_title_attribute_bytes,Y
    STA $2007
    INY
    CPY #$18
    BNE bra_C293_upload_next_attribute_byte
    RTS



; Tile data for title logo bitmap (6 rows)
tbl_C29F_title_logo_tiles:		; was: tbl_C29F_pacman_logo
    .incbin "assets/generated/title/logo-tiles.bin", $0, $17  ; rom-asset .byte
    .incbin "assets/generated/title/logo-tiles.bin", $17, $17  ; rom-asset .byte
    .incbin "assets/generated/title/logo-tiles.bin", $2E, $17  ; rom-asset .byte
    .incbin "assets/generated/title/logo-tiles.bin", $45, $17  ; rom-asset .byte
    .incbin "assets/generated/title/logo-tiles.bin", $5C, $17  ; rom-asset .byte
    .incbin "assets/generated/title/logo-tiles.bin", $73, $17  ; rom-asset .byte
; PPU command packets for title logo text
tbl_C329_title_logo_text_packets:		; was: tbl_C329_logo_text
; 00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2065
    .byte                          $B0, $B3, $B2, $20, $20, $20, $20, $B4, $B5, $B6, $B7
    .byte $B8, $B9, $BA, $BB, $20, $20, $20, $B1, $B3, $B2
    .byte $FF   ; end token
; 01
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $220A
    .byte                                                   $5C, $2D, $31, $20, $50, $4C
    .byte $41, $59, $45, $52
    .byte $FF   ; end token
; 02
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $224C
    .byte                                                             $32, $20, $50, $4C
    .byte $41, $59, $45, $52, $53
    .byte $FF   ; end token
; 03
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AC
    .byte                                                             $23, $24, $25, $26
    .byte $27, $28, $29, $2A, $2B
    .byte $FF   ; end token
; 04
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2305
    .byte                          $5D, $20, $31, $39, $38, $30, $20, $31, $39, $38, $34
    .byte $20, $4E, $41, $4D, $43, $4F, $20, $4C, $54, $44, $5B
    .byte $FF   ; end token
; 05
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2347
    .byte                                    $41, $4C, $4C, $20, $52, $49, $47, $48, $54
    .byte $53, $20, $52, $45, $53, $45, $52, $56, $45, $44
    .byte $FF   ; end token



; Background palette for title screen
tbl_C395_title_background_palette:		; was: tbl_C395_background_palette
    .incbin "assets/generated/palettes/title-background.bin", $0, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/title-background.bin", $4, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/title-background.bin", $8, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/title-background.bin", $C, $4  ; rom-asset .byte
; Attribute bytes for title layout
tbl_C3A5_title_attribute_bytes:		; was: tbl_C3A5_background_attributes
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .byte                                         $80, $A0, $A0, $A0, $A0, $A0, $A0, $00
    .byte $00, $66, $55, $55, $55, $55, $DD, $00, $08, $0A, $0A, $0A, $0A, $0A, $0A, $00
; Script 02: title menu idle (1P/2P select, start, demo timeout)
ofs_000_C3BD_script02_title_menu_idle:		; was: ofs_000_C3BD_02
    LDA ram_0087
    ORA ram_0088
    BNE bra_C3DC_title_idle_tick
    LDY #$00
; Copy title menu prompt packet into main PPU buffer
bra_C3C5_copy_menu_prompt_to_ppu_buffer:		; was: bra_C3C5_loop
    LDA tbl_C44D_ppu_cmd_player_count_prompt,Y
    STA ram_ppu_buffer_main,Y
    INY
    CMP #$FF
    BNE bra_C3C5_copy_menu_prompt_to_ppu_buffer
    LDA ram_btn_1p
    AND #con_btn_Select
    STA ram_direction_1
    LDA ram_btn_1p
    AND #con_btn_Start
    STA ram_direction_2
; Title idle tick: timer and input edge handling
bra_C3DC_title_idle_tick:		; was: bra_C3DC
    CLC
    LDA #< $0001
    ADC ram_0087
    STA ram_0087
    LDA ram_0088
    ADC #> $0001
    STA ram_0088
    CMP #$02
    BNE bra_C3F8_handle_select_toggle
; start demo mode when timer is 200h
    LDA #$00
    STA ram_0087
    LDA #con_script_04
    STA ram_script
    JMP loc_C1DE_script_dispatch_loop
; Handle Select edge: toggle 1P/2P and refresh text
bra_C3F8_handle_select_toggle:		; was: bra_C3F8
    LDA ram_btn_1p
    AND #con_btn_Select
    CMP ram_direction_1
    BEQ bra_C42F_check_start_edge
    STA ram_direction_1
; reset timer
    LDA #> $0001
    STA ram_0088
    LDA #< $0001
    STA ram_0087
    LDA ram_direction_1
    BEQ bra_C42F_check_start_edge
    LDX #$00
    INC ram_game_mode
    LDA ram_game_mode
    AND #$01
    STA ram_game_mode
    BEQ bra_C41B_select_player_glyph_index
    INX
; Select glyph pair index for 1P/2P prompt
bra_C41B_select_player_glyph_index:		; was: bra_C41B
    LDA tbl_C455_player_count_glyph_pair,X
    STA ram_ppu_buffer_main + $02
    LDA tbl_C455_player_count_glyph_pair + $01,X
    STA ram_ppu_buffer_main + $06
    LDA #$22
    STA ram_ppu_buffer_main
    JMP loc_C1DE_script_dispatch_loop
; Handle Start edge detection
bra_C42F_check_start_edge:		; was: bra_C42F
    LDA ram_btn_1p
    AND #con_btn_Start
    CMP ram_direction_2
    BNE bra_C43A_latch_start_state
    JMP loc_C1DE_script_dispatch_loop
; Latch Start button state
bra_C43A_latch_start_state:		; was: bra_C43A
    STA ram_direction_2
    LDA ram_direction_2
    BNE bra_C443_start_game_from_title
    JMP loc_C1DE_script_dispatch_loop
; Start pressed: leave demo flag, init audio, jump into game init
bra_C443_start_game_from_title:		; was: bra_C443
    LDA #$00
    STA ram_flag_demo
    JSR sub_EE40_clear_sound_engine_state
    JMP loc_C98A_enter_gameplay_session



; PPU command packet to draw player count prompt
tbl_C44D_ppu_cmd_player_count_prompt:		; was: tbl_C44D
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $220A
    .byte                                                   $5C, $00, $22, $4A, $20
    .byte $FF   ; end token



; Glyph pairs for 1P/2P indicator update
tbl_C455_player_count_glyph_pair:		; was: tbl_C455
; either 5C 20 or 20 5C pair is read
    .byte $5C
    .byte $20
    .byte $5C
; Script 04: attract/demo pre-roll state machine
