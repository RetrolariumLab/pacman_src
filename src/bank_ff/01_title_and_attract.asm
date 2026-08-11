; Title, attract mode, and pre-game demo




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
    LDA $2002
    LDA ram_0000
    STA $2006
    LDA ram_0001
    STA $2006
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
    LDA $2002
    LDA #> $23C8
    STA $2006
    LDA #< $23C8
    STA $2006
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
ofs_000_C458_script04_attract_intro:		; was: ofs_000_C458_04
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_C465_run_attract_substate
    LDA #con_script_02
    STA ram_script
    JMP loc_C168_main_frame_bootstrap
; Execute current attract substate handler
bra_C465_run_attract_substate:		; was: bra_C465
    LDY ram_0087
    LDA tbl_C474_attract_substate_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_C474_attract_substate_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Attract-mode substate handler table
tbl_C474_attract_substate_handlers:		; was: tbl_C474
    .word ofs_001_C48C_attract_substate_init
    .word ofs_001_C4B9_attract_substate_wait_30f
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_04
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_06
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_08
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_0A
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_0C
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_0E
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_10
    .word ofs_001_C4B9_attract_substate_wait_30f_alias_12
    .word ofs_001_C4CF_attract_substate_wait_80f
    .word ofs_001_C6C8_attract_chase_scene



; Attract substate init: setup nametable/palette and seed sequence
ofs_001_C48C_attract_substate_init:		; was: ofs_001_C48C_00
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI completion before attract setup writes
bra_C490_wait_nmi_complete:		; was: bra_C490_infinite_loop
    LDA ram_nmi_wait
    BNE bra_C490_wait_nmi_complete
    LDA #$08
    STA $2000
    STA ram_for_2000
    LDA #$00
    STA $2001
    STA ram_0088
    JSR sub_C51E_draw_attract_playfield_frame
    JSR sub_C54E_setup_attract_palette_and_attrs
    JSR sub_C4EC_build_attract_ppu_packet
    INC ram_0087
    INC ram_0087
    LDA #$88
    STA $2000
    STA ram_for_2000
    JMP loc_C1DE_script_dispatch_loop



; Attract substate wait loop (0x30 frames step)
ofs_001_C4B9_attract_substate_wait_30f:		; was: ofs_001_C4B9_02
; Alias entry for 30-frame attract wait handler (substate 04)
ofs_001_C4B9_attract_substate_wait_30f_alias_04:		; was: ofs_001_C4B9_04
; Alias entry for 30-frame attract wait handler (substate 06)
ofs_001_C4B9_attract_substate_wait_30f_alias_06:		; was: ofs_001_C4B9_06
; Alias entry for 30-frame attract wait handler (substate 08)
ofs_001_C4B9_attract_substate_wait_30f_alias_08:		; was: ofs_001_C4B9_08
; Alias entry for 30-frame attract wait handler (substate 0A)
ofs_001_C4B9_attract_substate_wait_30f_alias_0A:		; was: ofs_001_C4B9_0A
; Alias entry for 30-frame attract wait handler (substate 0C)
ofs_001_C4B9_attract_substate_wait_30f_alias_0C:		; was: ofs_001_C4B9_0C
; Alias entry for 30-frame attract wait handler (substate 0E)
ofs_001_C4B9_attract_substate_wait_30f_alias_0E:		; was: ofs_001_C4B9_0E
; Alias entry for 30-frame attract wait handler (substate 10)
ofs_001_C4B9_attract_substate_wait_30f_alias_10:		; was: ofs_001_C4B9_10
; Alias entry for 30-frame attract wait handler (substate 12)
ofs_001_C4B9_attract_substate_wait_30f_alias_12:		; was: ofs_001_C4B9_12
    INC ram_0088
    LDA ram_0088
    CMP #$30
    BNE bra_C4CC_dispatch_next_frame
    LDA #$00
    STA ram_0088
    JSR sub_C4EC_build_attract_ppu_packet
    INC ram_0087
    INC ram_0087
; Return to script dispatcher after attract wait tick
bra_C4CC_dispatch_next_frame:		; was: bra_C4CC
    JMP loc_C1DE_script_dispatch_loop



; Attract tail wait before handoff
ofs_001_C4CF_attract_substate_wait_80f:		; was: ofs_001_C4CF_14
    INC ram_0088
    LDA ram_0088
    CMP #$80
    BEQ bra_C4DA_advance_substate_after_wait
    JMP loc_C1DE_script_dispatch_loop
; Advance attract substate after tail wait expires
bra_C4DA_advance_substate_after_wait:		; was: bra_C4DA
    INC ram_0087
    INC ram_0087
    LDA #$00
    STA ram_0088
    JMP loc_C1DE_script_dispatch_loop


; bzk garbage
    LDA #$01
    STA ram_game_mode
    JMP loc_C98A_enter_gameplay_session



; Build next attract/demo PPU update packet (and optional sprite strip)
sub_C4EC_build_attract_ppu_packet:		; was: sub_C4EC
    LDY ram_0087
    LDA tbl_C5D3_attract_ppu_packet_ptrs,Y
    STA ram_0000
    LDA tbl_C5D3_attract_ppu_packet_ptrs + $01,Y
    STA ram_0001
    LDY #$00
; Copy attract PPU packet bytes into main PPU buffer
bra_C4FA_copy_ppu_packet_to_buffer:		; was: bra_C4FA_loop
    LDA (ram_0000),Y    ; data from 0x0005E3
    STA ram_ppu_buffer_main,Y
    INY
    CMP #$FF
    BNE bra_C4FA_copy_ppu_packet_to_buffer
    LDA (ram_0000),Y    ; data from 0x0005E3 (last byte)
    BEQ bra_C509_copy_optional_sprite_strip
    RTS
; Copy optional sprite strip payload after packet terminator
bra_C509_copy_optional_sprite_strip:		; was: bra_C509
    LDA ram_0087
    SEC
    SBC #$02
    ASL
    ASL
    TAY
    LDX #$10
; Copy 16-byte sprite strip into OAM shadow
bra_C513_copy_attract_sprite_strip:		; was: bra_C513_loop
; potential 0760-079F range, interval 10h
    LDA tbl_C688_attract_sprite_strip_data,Y
    STA ram_oam + $60,Y
    INY
    DEX
    BNE bra_C513_copy_attract_sprite_strip
    RTS



; Draw attract-mode playfield frame tiles
sub_C51E_draw_attract_playfield_frame:		; was: sub_C51E
    LDA #> $20C0
    STA $2006
    LDA #< $20C0
    STA $2006
    LDA #$17
    STA ram_0000
; Draw next row of attract playfield frame
bra_C52C_draw_next_frame_row:		; was: bra_C52C_loop
    LDA #$1C
    STA ram_0001
    LDA #con_tile + $2D
    STA $2007
    STA $2007
    LDA #con_tile + $20
; Fill inner row tiles between frame borders
bra_C53A_fill_frame_inner_row:		; was: bra_C53A_loop
    STA $2007
    DEC ram_0001
    BNE bra_C53A_fill_frame_inner_row
    LDA #con_tile + $2D
    STA $2007
    STA $2007
    DEC ram_0000
    BPL bra_C52C_draw_next_frame_row
    RTS



; Setup attract-mode attributes and palette
sub_C54E_setup_attract_palette_and_attrs:		; was: sub_C54E
    LDA #> $23C0
    STA $2006
    LDA #< $23C0
    STA $2006
    LDY #$20
    LDA #$00
; Clear initial attract attribute block bytes
bra_C55C_clear_attr_block_23C0:		; was: bra_C55C_loop
    STA $2007
    DEY
    BNE bra_C55C_clear_attr_block_23C0
    LDA #> $23D0
    STA $2006
    LDA #< $23D0
    STA $2006
    LDA #$03
    STA ram_0000
    LDA #$55
; Fill attract checker/stripe attribute rows
bra_C572_fill_checker_attr_rows:		; was: bra_C572_loop
    LDY #$08
; Write 8 repeated attribute bytes
bra_C574_write_eight_attr_bytes:		; was: bra_C574_loop
    STA $2007
    DEY
    BNE bra_C574_write_eight_attr_bytes
    CLC
    ADC #$55
    DEC ram_0000
    BNE bra_C572_fill_checker_attr_rows
    LDA #> $3F00
    STA $2006
    LDA #< $3F00
    STA $2006
    LDY #$00
; Upload 32-byte attract palette block
bra_C58D_upload_attract_palette32:		; was: bra_C58D_loop
    LDA tbl_C5B3_attract_bg_spr_palette,Y
    STA $2007
    INY
    CPY #$20
    BNE bra_C58D_upload_attract_palette32
    LDA #> $23E8
    STA $2006
    LDA #< $23E8
    STA $2006
    LDA #$AA
    STA $2007
    STA $2007
    STA $2007
    LDA #$22
    STA $2007
    RTS



; Attract scene BG+SPR palette block (32 bytes)
tbl_C5B3_attract_bg_spr_palette:		; was: tbl_C5B3_palette
; bg
    .incbin "assets/generated/palettes/attract-namco.bin", $0, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $4, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $8, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $C, $4  ; rom-asset .byte
; spr
    .incbin "assets/generated/palettes/attract-namco.bin", $10, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $14, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $18, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/attract-namco.bin", $1C, $4  ; rom-asset .byte
; Pointer table to attract text/packet scripts by substate
tbl_C5D3_attract_ppu_packet_ptrs:		; was: tbl_C5D3
    .word off_C5E7_attract_text_header_character_nickname
    .word off_C5FF_attract_text_alias_oikake
    .word off_C60E_attract_text_name_akabei
    .word off_C619_attract_text_alias_machibuse
    .word off_C628_attract_text_name_pinky
    .word off_C632_attract_text_alias_tiles_0A
    .word off_C641_attract_text_name_tiles_0C
    .word off_C64C_attract_text_alias_otoboke
    .word off_C65B_attract_text_name_guzuta
    .word off_C666_attract_text_points_table



; bzk careful here if you move this data
; code always reads next byte after FF via 0x000514
; and checks if it is 00 or not
; recommended to place additional FF or 01 or whatever byte after each chunk of data
; so it will be pairs of FF + 00 and FF + FF
; currently only FF + 00 pairs exist
; Attract packet: header CHARACTER/NICKNAME
off_C5E7_attract_text_header_character_nickname:		; was: _off000_C5E7_00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $20E6
    .byte                               $43, $48, $52, $41, $43, $54, $45, $52, $20, $20
    .byte $3B, $20, $20, $4E, $49, $43, $4B, $4E, $41, $4D, $45
    .byte $FF   ; end token



; Attract packet: alias text OIKAKE...
off_C5FF_attract_text_alias_oikake:		; was: _off000_C5FF_02
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2148
    .byte                                         $4F, $49, $4B, $41, $4B, $45, $2E, $2E
    .byte $2E, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition



; Attract packet: name AKABEI
off_C60E_attract_text_name_akabei:		; was: _off000_C60E_04
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2153
    .byte $5F, $41, $4B, $41, $42, $45, $49, $5F
    .byte $FF   ; end token



; Attract packet: alias text MACHIBUSE..
off_C619_attract_text_alias_machibuse:		; was: _off000_C619_06
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $21A8
    .byte $4D, $41, $43, $48, $49, $42, $55, $53
    .byte $45, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition



; Attract packet: name PINKY
off_C628_attract_text_name_pinky:		; was: _off000_C628_08
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $21B3
    .byte                $5F, $50, $49, $4E, $4B, $59, $5F
    .byte $FF   ; end token



; Attract packet: alias text tile sequence (set 0A)
off_C632_attract_text_alias_tiles_0A:		; was: _off000_C632_0A
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2208
    .byte                                         $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7
    .byte $03, $03, $03
    .byte $FF   ; end token
    .byte $00   ; condition



; Attract packet: name tile sequence (set 0C)
off_C641_attract_text_name_tiles_0C:		; was: _off000_C641_0C
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2213
    .byte                $C8, $C3, $C9, $CA, $C5, $C0, $C7, $C8
    .byte $FF   ; end token



; Attract packet: alias text OTOBOKE...
off_C64C_attract_text_alias_otoboke:		; was: _off000_C64C_0E
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2268
    .byte                                         $4F, $54, $4F, $42, $4F, $4B, $45, $2E
    .byte $2E, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition



; Attract packet: name GUZUTA
off_C65B_attract_text_name_guzuta:		; was: _off000_C65B_10
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2273
    .byte                $5F, $47, $55, $5A, $55, $54, $41, $5F
    .byte $FF   ; end token



; Attract packet: points table entries
off_C666_attract_text_points_table:		; was: _off000_C666_12
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AD
    .byte                                                                  $03, $20, $31
    .byte $30, $20, $50, $54, $53, $00, $22, $ED, $01, $20, $35, $30, $20, $50, $54, $53
    .byte $00, $23, $4C, $23, $24, $25, $26, $27, $28, $29, $2A, $2B
    .byte $FF   ; end token
; bzk warning, read 0x0005F7



; Sprite strip data used by optional attract packet payload
tbl_C688_attract_sprite_strip_data:		; was: tbl_C688_spr_data
; reading 4 lines bytes each time, start line depends on 0x000519
    .byte $48, $1C, $40, $26   ; 02
    .byte $48, $1B, $40, $2E   ; 03
    .byte $50, $1F, $40, $26   ; 04
    .byte $50, $1D, $40, $2E   ; 05
    .byte $60, $1C, $41, $26   ; 06
    .byte $60, $1B, $41, $2E   ; 07
    .byte $68, $1F, $41, $26   ; 08
    .byte $68, $1D, $41, $2E   ; 09
    .byte $78, $1C, $42, $26   ; 0A
    .byte $78, $1B, $42, $2E   ; 0B
    .byte $80, $1F, $42, $26   ; 0C
    .byte $80, $1D, $42, $2E   ; 0D
    .byte $90, $1C, $43, $26   ; 0E
    .byte $90, $1B, $43, $2E
    .byte $98, $1F, $43, $26
    .byte $98, $1D, $43, $2E
; Attract scene: chase sequence state machine (ghost intro -> run -> reversal)
ofs_001_C6C8_attract_chase_scene:		; was: ofs_001_C6C8_16
    LDY ram_0088
    LDA tbl_C6D7_attract_chase_substates,Y
    STA ram_indirect_jmp
    LDA tbl_C6D7_attract_chase_substates + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Substate handlers for chase attract scene
tbl_C6D7_attract_chase_substates:		; was: tbl_C6D7
    .word ofs_002_C6DD_chase_setup_intro_text
    .word ofs_002_C728_chase_run_from_ghosts
    .word ofs_002_C78D_chase_run_toward_ghosts



; Chase substate init: clear score text, seed actor/sprite state
ofs_002_C6DD_chase_setup_intro_text:		; was: ofs_002_C6DD_00
; clear 10 pts 50 pts text
    LDY #$00
; Copy fixed PPU command packet into main buffer
bra_C6DF_copy_ppu_packet:		; was: bra_C6DF_loop
    LDA tbl_C90E_ppu_cmd_clear_points_text,Y
    STA ram_ppu_buffer_main,Y
    INY
    CMP #$FF
    BNE bra_C6DF_copy_ppu_packet
    LDA #< $00FF
    STA ram_obj_pos_X_hi
    LDA #> $00FF
    STA ram_obj_pos_X_lo
    STA ram_0089
    STA ram_008A
    LDA #$F4
    STA ram_spr_pos_X_hi
    LDA #$A8
    STA ram_spr_pos_Y_hi
    LDA #$01
    STA ram_028C
    LDA #$20
    STA ram_0292
    LDA #$00
    TAY
; Clear attract runner object slots
bra_C70D_clear_runner_obj_slots:		; was: bra_C70D_loop
    STA ram_obj_position + $04,Y
    INY
    CPY #$14
    BNE bra_C70D_clear_runner_obj_slots
    TAY
; Clear attract runner sprite slots
bra_C716_clear_runner_sprite_slots:		; was: bra_C716_loop
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$14
    BNE bra_C716_clear_runner_sprite_slots
    JSR sub_DA5C_build_oam_from_sprite_buffers
    INC ram_0088
    INC ram_0088
    JMP loc_C1DE_script_dispatch_loop



; Chase phase A: Pac-Man runs from ghosts
ofs_002_C728_chase_run_from_ghosts:		; was: ofs_002_C728_02
; pacman is running from ghosts
    JSR sub_C812_update_chase_scene_frame
    JSR sub_C8EE_blink_chase_marker
    LDA ram_spr_pos_X_hi
    CMP #$E0
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$D1
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$C2
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$B3
    BNE bra_C744_check_phase_a_finish
; At checkpoint X, spawn next ghost runner
bra_C741_spawn_next_ghost_if_checkpoint:		; was: bra_C741
    JSR sub_C7DE_spawn_ghost_runner
; Wait until lead runner reaches phase-A terminal X
bra_C744_check_phase_a_finish:		; was: bra_C744
    LDA ram_spr_pos_X_hi
    CMP #$40
    BEQ bra_C74E_phase_a_to_b_reset
    JMP loc_C1DE_script_dispatch_loop
; Transition phase A->B: reset slots and marker
bra_C74E_phase_a_to_b_reset:		; was: bra_C74E
    LDY #$00
; Reset chase phase-B object X slots to base
bra_C750_reset_phase_b_obj_slots:		; was: bra_C750_loop
    LDA #> $00C0
    STA ram_obj_pos_X_hi + $04,Y
    LDA #< $00C0
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_C750_reset_phase_b_obj_slots
    LDA #> $0150
    STA ram_obj_pos_X_hi
    LDA #< $0150
    STA ram_obj_pos_X_lo
    LDA #$01
    STA ram_0293
    STA ram_0294
    STA ram_0295
    STA ram_0296
    LDA #$00
    STA ram_0089
    LDA #$22
    STA ram_ppu_buffer_main
    LDA #$20
    STA ram_ppu_buffer_main + $02
    INC ram_0088
    INC ram_0088
    JMP loc_C1DE_script_dispatch_loop



; Chase phase B: Pac-Man turns and chases ghosts
ofs_002_C78D_chase_run_toward_ghosts:		; was: ofs_002_C78D_04
; pacman is running at ghosts
    LDA ram_008A
    BEQ bra_C7D8_update_phase_b_scene
    JSR sub_C864_rotate_runner_slots
    DEC ram_008A
    BEQ bra_C79B_resolve_eaten_ghost
    JMP loc_C1DE_script_dispatch_loop
; Resolve one eaten ghost slot and score marker update
bra_C79B_resolve_eaten_ghost:		; was: bra_C79B
    LDY #$00
; Scan eaten-marker slots for active entry
bra_C79D_find_active_eaten_marker_slot:		; was: bra_C79D_loop
    LDA ram_028D,Y
    AND #$E0
    BNE bra_C7A7_clear_eaten_slot_state
    INY
    BNE bra_C79D_find_active_eaten_marker_slot    ; Y steps 0,4,8,0C so branch always until slot found
; Clear resolved eaten marker and slot state
bra_C7A7_clear_eaten_slot_state:		; was: bra_C7A7
    LDA #$00
    STA ram_028D,Y
    LDA #$00
    STA ram_0293,Y
    TYA
    ASL
    ASL
    TAY
    LDA #$00
    STA ram_spr_pos_X_hi + $04,Y
    STA ram_spr_pos_Y_hi + $04,Y
    STA ram_obj_pos_X_hi + $04,Y
    STA ram_obj_pos_X_lo + $04,Y
    LDA #$A8
    STA ram_spr_pos_Y_hi
    LDA ram_0089
    CMP #$04
    BEQ bra_C7D1_enter_gameplay_after_chase
    JMP loc_C1DE_script_dispatch_loop
; Exit attract chase and jump into gameplay init
bra_C7D1_enter_gameplay_after_chase:		; was: bra_C7D1
    LDA #$01
    STA ram_game_mode
    JMP loc_C98A_enter_gameplay_session
; Phase B path when no eat event is active
bra_C7D8_update_phase_b_scene:		; was: bra_C7D8
    JSR sub_C812_update_chase_scene_frame
    JMP loc_C1DE_script_dispatch_loop



; Spawn one ghost runner entity in attract chase
sub_C7DE_spawn_ghost_runner:		; was: sub_C7DE
    LDY #$00
    STY ram_0000
; Find first free runner slot for ghost spawn
bra_C7E2_find_free_runner_slot:		; was: bra_C7E2_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_C7EF_init_spawned_runner_slot
    INC ram_0000
    INY
    INY
    INY
    INY
    BNE bra_C7E2_find_free_runner_slot
; Initialize spawned ghost runner slot values
bra_C7EF_init_spawned_runner_slot:		; was: bra_C7EF
    LDA #$F4
    STA ram_spr_pos_X_hi + $04,Y
    LDA #$A8
    STA ram_spr_pos_Y_hi + $04,Y
    LDA #< $00FF
    STA ram_obj_pos_X_hi + $04,Y
    LDA #> $00FF
    STA ram_obj_pos_X_lo + $04,Y
    LDY ram_0000
    LDA ram_0089
    STA ram_0293,Y
    LDA #$0C
    STA ram_028D,Y
    INC ram_0089
    RTS



; Per-frame chase scene update: movement, anim, collision, OAM
sub_C812_update_chase_scene_frame:		; was: sub_C812
    JSR sub_E9A5_update_intermission_actor_positions
    JSR sub_C864_rotate_runner_slots
    JSR sub_C930_update_chase_anim_tiles
    JSR sub_C821_handle_chase_contact
    JMP loc_DA5C_build_oam_from_sprite_buffers



; Detect Pac-Man contact with runner and trigger eat event
sub_C821_handle_chase_contact:		; was: sub_C821
    LDA ram_obj_pos_X_hi
    BPL bra_C826_scan_runners_for_contact
    RTS
; Begin collision scan between Pac-Man and runners
bra_C826_scan_runners_for_contact:		; was: bra_C826
    LDA ram_spr_pos_X_hi
    CLC
    ADC #$08
    STA ram_0000
    LDY #$00
    STY ram_0001
; Scan runner X positions against Pac-Man threshold
bra_C832_find_first_runner_ahead_of_pacman:		; was: bra_C832_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_C83B_advance_runner_scan
    CMP ram_0000
    BCC bra_C846_mark_runner_eaten
; Advance to next runner slot during contact scan
bra_C83B_advance_runner_scan:		; was: bra_C83B
    INC ram_0001
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_C832_find_first_runner_ahead_of_pacman
    RTS
; Mark contacted runner as eaten and trigger score popup
bra_C846_mark_runner_eaten:		; was: bra_C846
    LDY ram_0089
    INC ram_0089
    LDA #$40
    STA ram_008A
    LDA tbl_C924_ghost_score_tiles,Y
    LDY ram_0001
    STA ram_028D,Y
    LDA #$00
    STA ram_0293,Y
    LDA #$00
    STA ram_028C
    STA ram_spr_pos_Y_hi
    RTS



; Rotate runner object/sprite/state arrays
sub_C864_rotate_runner_slots:		; was: sub_C864
    LDA ram_obj_pos_X_hi + $04
    STA ram_0000
    LDA ram_obj_pos_X_lo + $04
    STA ram_0001
    LDY #$00
; Rotate object position ring buffer left by one slot
bra_C86E_rotate_object_positions_left:		; was: bra_C86E_loop
    LDA ram_obj_pos_X_hi + $08,Y
    STA ram_obj_pos_X_hi + $04,Y
    LDA ram_obj_pos_X_lo + $08,Y
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$0C
    BNE bra_C86E_rotate_object_positions_left
    LDA ram_0000
    STA ram_obj_pos_X_hi + $10
    LDA ram_0001
    STA ram_obj_pos_X_lo + $10
    LDA ram_spr_pos_X_hi + $04
    STA ram_0000
    LDA ram_spr_pos_X_lo + $04
    STA ram_0001
    LDA ram_spr_pos_Y_hi + $04
    STA ram_0002
    LDA ram_spr_pos_Y_lo + $04
    STA ram_0003
    LDY #$00
; Rotate sprite position bytes left by one slot
bra_C8A0_rotate_sprite_bytes_left:		; was: bra_C8A0_loop
    LDA ram_spr_pos_X_hi + $08,Y
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$0C
    BNE bra_C8A0_rotate_sprite_bytes_left
    LDA ram_0000
    STA ram_spr_pos_X_hi + $10
    LDA ram_0001
    STA ram_spr_pos_X_lo + $10
    LDA ram_0002
    STA ram_spr_pos_Y_hi + $10
    LDA ram_0003
    STA ram_spr_pos_Y_lo + $10
    LDA ram_028D
    STA ram_0000
    LDY #$00
; Rotate runner tile IDs left by one slot
bra_C8C6_rotate_runner_tile_ids_left:		; was: bra_C8C6_loop
    LDA ram_028E,Y
    STA ram_028D,Y
    INY
    CPY #$03
    BNE bra_C8C6_rotate_runner_tile_ids_left
    LDA ram_0000
    STA ram_0290
    LDA ram_0293
    STA ram_0000
    LDY #$00
; Rotate runner palette/flags left by one slot
bra_C8DD_rotate_runner_palette_flags_left:		; was: bra_C8DD_loop
    LDA ram_0294,Y
    STA ram_0293,Y
    INY
    CPY #$03
    BNE bra_C8DD_rotate_runner_palette_flags_left
    LDA ram_0000
    STA ram_0296
    RTS



; Blink chase marker text/tile packet every 8 frames
sub_C8EE_blink_chase_marker:		; was: sub_C8EE
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_C8F5_blink_tick
    RTS
; Every-8-frame blink update entry
bra_C8F5_blink_tick:		; was: bra_C8F5
; each 8 frames
    LDX #$00
    LDY #$00
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_C901_select_marker_variant
    LDY #$04
; Select visible/hidden marker packet variant
bra_C901_select_marker_variant:		; was: bra_C901
; Copy marker packet bytes into PPU buffer
bra_C901_copy_marker_packet:		; was: bra_C901_loop
    LDA tbl_C928_ppu_cmd_chase_marker,Y
    STA ram_ppu_buffer_main,X
    INX
    INY
    CPX #$04
    BNE bra_C901_copy_marker_packet
    RTS



; PPU packet to clear 10/50/200/400 points text area
tbl_C90E_ppu_cmd_clear_points_text:		; was: tbl_C90E
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AD
    .byte                                                                  $2D, $2D, $2D
    .byte $2D, $2D, $2D, $2D, $2D, $00, $22, $ED, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D
    .byte $FF   ; end token



; Tile IDs for ghost-eaten score popups
tbl_C924_ghost_score_tiles:		; was: tbl_C924
    .byte $2D   ; 00
    .byte $2F   ; 01
    .byte $32   ; 02
    .byte $34   ; 03



; PPU packets for chase marker blink states
tbl_C928_ppu_cmd_chase_marker:		; was: tbl_C928
; 00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte                                    $20
    .byte $FF
; 04
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte                                    $01
    .byte $FF
; Update chase scene animation tiles for Pac-Man/ghosts
sub_C930_update_chase_anim_tiles:		; was: sub_C930
    LDX #$00
    LDA ram_obj_pos_X_hi
    BMI bra_C938_store_anim_bank_offset
    LDX #$0A
; Store selected animation bank offset
bra_C938_store_anim_bank_offset:		; was: bra_C938
    STX ram_0000
    INC ram_00B7
    LDA ram_00B7
    AND #$07
    CLC
    ADC ram_0000
    TAY
    LDA tbl_C976_chase_anim_lut,Y
    STA ram_028C
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_C951_update_ghost_tiles_every_8f
    RTS
; Update ghost tiles every 8 frames only
bra_C951_update_ghost_tiles_every_8f:		; was: bra_C951
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_C959_select_chomp_toggle
    LDA #$01
; Select alternate tile on 8-frame toggle bit
bra_C959_select_chomp_toggle:		; was: bra_C959
    CLC
    ADC ram_0000
    ADC #$08
    TAY
    LDA tbl_C976_chase_anim_lut,Y
    STA ram_0000
    LDY #$00
; Apply current ghost tile to active runner slots
bra_C966_apply_ghost_tile_to_active_slots:		; was: bra_C966_loop
    LDA ram_028D,Y
    BEQ bra_C970_next_runner_tile_slot
    LDA ram_0000
    STA ram_028D,Y
; Advance to next chase runner tile slot in update loop
bra_C970_next_runner_tile_slot:		; was: bra_C970
    INY
    CPY #$04
    BNE bra_C966_apply_ghost_tile_to_active_slots
    RTS



; Animation LUT used by chase scene update
tbl_C976_chase_anim_lut:		; was: tbl_C976
; indexes 08, 09, 12 and 13 are read via 0x00096F
; other indexes are read via 0x000954
    .byte $04   ; 00
    .byte $04   ; 01
    .byte $04   ; 02
    .byte $05   ; 03
    .byte $05   ; 04
    .byte $04   ; 05
    .byte $01   ; 06
    .byte $01   ; 07
    .byte $0C   ; 08
    .byte $0D   ; 09
    .byte $08   ; 0A
    .byte $08   ; 0B
    .byte $08   ; 0C
    .byte $09   ; 0D
    .byte $09   ; 0E
    .byte $08   ; 0F
    .byte $01   ; 10
    .byte $01   ; 11
    .byte $1E   ; 12
    .byte $1F   ; 13
