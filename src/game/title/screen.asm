; Title screen drawing, menu input, and player-count selection

; Jump table for title-flow scripts 00/02/04
tbl_script_handlers_title_flow:
    .word handler_script00_title_scroll_in
    .word handler_script02_title_menu_idle
    .word handler_script04_attract_intro
.if PACMAN_REVISION = REVISION_USA_NAMCO
    .word handler_script06_namco_title_delay

; Script 06: hold the completed Namco title before enabling menu input
handler_script06_namco_title_delay:
    DEC ram_namco_title_delay
    BNE loc_script_dispatch_loop
    LDA #con_title_script_menu_idle
    STA ram_script
    JMP loc_script_dispatch_loop
.endif

; Script 00: title scroll-in and transition to menu script
handler_script00_title_scroll_in:
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_continue_title_scroll
.if PACMAN_REVISION = REVISION_USA_NAMCO
    LDA #con_title_script_namco_delay
    STA ram_script
    LDA #$5A
    STA ram_namco_title_delay
.else
    LDA #con_title_script_menu_idle
    STA ram_script
.endif
    JMP loc_main_frame_bootstrap
; Advance title scroll until target Y reached
bra_continue_title_scroll:
    INC ram_scroll_Y
    LDA #$F0
    CMP ram_scroll_Y
    BNE bra_dispatch_next_title_frame
    LDA #$00
    STA ram_scroll_Y
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA ram_ppuctrl_base
.if PACMAN_REVISION = REVISION_USA_NAMCO
    LDA #con_title_script_namco_delay
    STA ram_script
    LDA #$5A
    STA ram_namco_title_delay
.else
    LDA #con_title_script_menu_idle
    STA ram_script
.endif
; Return to script dispatcher on next frame
bra_dispatch_next_title_frame:
    JMP loc_script_dispatch_loop

; Draw title logo bitmap rows and text packets
sub_draw_title_logo_and_text:
    LDA #> $20E5
    STA zp_work0
    LDA #< $20E5
    STA zp_work1
    LDA #$06  ; counter
    STA zp_work2
    LDY #$00
; Iterate over title logo rows
bra_draw_next_logo_row:
    SetPpuAddressFrom zp_work0
    LDA #$17
    STA zp_work3
; Stream one title logo row tile sequence
bra_stream_logo_row_tiles:
    LDA tbl_title_logo_tiles,Y
    STA PPUDATA
    INY
    DEC zp_work3
    BNE bra_stream_logo_row_tiles
    LDA zp_work1
    CLC
    ADC #< $0020
    STA zp_work1
    LDA #> $0020
    ADC zp_work0
    STA zp_work0
    DEC zp_work2
    BNE bra_draw_next_logo_row
; draw text
.if PACMAN_REVISION = REVISION_EUROPE
    LDA #$07  ; counter
.elseif .defined(PACMAN_REVISION_TENGEN) .or PACMAN_REVISION = REVISION_USA_NAMCO
    LDA #$09  ; counter
.else
    LDA #$06  ; counter
.endif
    STA zp_work0
    LDY #$00
; Draw next title text packet header+payload
bra_draw_next_logo_text_packet:
    LDA PPUSTATUS
    LDA tbl_title_logo_text_packets,Y
    STA PPUADDR
    INY
    LDA tbl_title_logo_text_packets,Y
    STA PPUADDR
    INY
; Stream text payload bytes until FF terminator
bra_stream_logo_text_until_ff:
    LDA tbl_title_logo_text_packets,Y
    CMP #con_ppu_buffer_end
    BEQ bra_advance_to_next_logo_text_packet
    STA PPUDATA
    INY
    BNE bra_stream_logo_text_until_ff
; Advance to next title text packet
bra_advance_to_next_logo_text_packet:
    INY
    DEC zp_work0
    BNE bra_draw_next_logo_text_packet
    RTS

; Upload title-screen attribute bytes
sub_upload_title_attribute_table:
    SetPpuAddress $23C8
    LDY #$00
; Upload next title attribute byte
bra_upload_next_attribute_byte:
    LDA tbl_title_attribute_bytes,Y
    STA PPUDATA
    INY
.ifdef PACMAN_REVISION_TENGEN
    CPY #$28
.else
    CPY #$18
.endif
    BNE bra_upload_next_attribute_byte
    RTS

; Tile data for title logo bitmap (6 rows)
tbl_title_logo_tiles:
    .incbin "assets/generated/title/logo-tiles.bin"
; PPU command packets for title logo text
tbl_title_logo_text_packets:
.if PACMAN_REVISION = REVISION_EUROPE
    .dbyt $2065
    .byte $B0, $B3, $B2, $20, $20, $20, $20, $B4, $B5, $B6, $B7
    .byte $B8, $B9, $BA, $BB, $20, $20, $20, $B1, $B3, $B2, $FF
    .dbyt $220A
    .byte $5C, $2D, $31, $20, $50, $4C, $41, $59, $45, $52, $FF
    .dbyt $224C
    .byte $32, $20, $50, $4C, $41, $59, $45, $52, $53, $FF
    .dbyt $2323
    .byte $54, $4D, $20, $CC, $20, $5D, $20, $31, $39, $38, $30
    .byte $20, $31, $39, $39, $33, $20, $4E, $41, $4D, $43, $4F
    .byte $20, $4C, $54, $44, $5B, $FF
    .dbyt $2366
    .byte $4C, $49, $43, $45, $4E, $53, $45, $44, $20, $54, $4F
    .byte $20, $4E, $49, $4E, $54, $45, $4E, $44, $4F, $FF
    .dbyt $22AC
    .byte $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $FF
    .dbyt $20FC
    .byte $0E, $0F, $FF
.elseif PACMAN_REVISION = REVISION_USA_NAMCO
    .dbyt $2065
    .byte $B0, $B3, $B2, $20, $20, $20, $20, $B4, $B5, $B6, $B7
    .byte $B8, $B9, $BA, $BB, $20, $20, $20, $B1, $B3, $B2, $FF
    .dbyt $220C
    .byte $31, $20, $50, $4C, $41, $59, $45, $52, $FF
    .dbyt $224C
    .byte $32, $20, $50, $4C, $41, $59, $45, $52, $53, $FF
    .dbyt $22E3
    .byte $54, $4D, $20, $CC, $20, $5D, $20, $31, $39, $38, $30
    .byte $20, $31, $39, $39, $33, $20, $4E, $41, $4D, $43, $4F
    .byte $20, $4C, $54, $44, $5B, $FF
    .dbyt $2327
    .byte $4E, $41, $4D, $43, $4F, $20, $48, $4F, $4D, $45, $54
    .byte $45, $4B, $CD, $49, $4E, $43, $5B, $FF
    .dbyt $2366
    .byte $4C, $49, $43, $45, $4E, $53, $45, $44, $20, $42, $59
    .byte $20, $4E, $49, $4E, $54, $45, $4E, $44, $4F, $FF
    .dbyt $2293
    .byte $CE, $CF, $FF
    .dbyt $22AC
    .byte $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $FF
    .dbyt $20FC
    .byte $0E, $0F, $FF
.elseif .defined(PACMAN_REVISION_TENGEN)
    .dbyt $2065
    .byte $B0, $B3, $B2, $20, $20, $20, $20, $B4, $B5, $B6, $B7
    .byte $B8, $B9, $BA, $BB, $20, $20, $20, $B1, $B3, $B2, $FF
    .dbyt $220A
    .byte $5C, $20, $31, $20, $50, $4C, $41, $59, $45, $52, $FF
    .dbyt $224C
    .byte $32, $20, $50, $4C, $41, $59, $45, $52, $53, $FF
    .dbyt $22A2
    .byte $54, $4D, $20, $41, $4E, $44, $20, $5D, $20
    .byte $31, $39, $38, $30, $20, $31, $39, $38, $34, $20
    .byte $4E, $41, $4D, $43, $4F, $20, $4C, $54, $44, $5B, $FF
    .dbyt $22ED
    .byte $54, $45, $4E, $47, $45, $4E, $FF
    .dbyt $2326
    .if PACMAN_REVISION = REVISION_USA_TENGEN_LICENSED
        .byte $4C, $49, $43, $45, $4E, $53, $45, $44, $20, $42
        .byte $59, $20, $4E, $49, $4E, $54, $45, $4E, $44, $4F, $FF
    .else
        .byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
        .byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $FF
    .endif
    .dbyt $2369
    .if PACMAN_REVISION = REVISION_USA_TENGEN_LICENSED
        .byte $4F, $46, $20, $41, $4D, $45, $52, $49
        .byte $43, $41, $20, $49, $4E, $43, $5B, $FF
    .else
        .byte $20, $20, $20, $20, $20, $20, $20, $20
        .byte $20, $20, $20, $20, $20, $20, $20, $FF
    .endif
    .dbyt $22C2
    .byte $20, $FF
    .dbyt $22D4
    .byte $20, $FF
.else
; 00
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2065
    .byte $B0, $B3, $B2, $20, $20, $20, $20, $B4, $B5, $B6, $B7
    .byte $B8, $B9, $BA, $BB, $20, $20, $20, $B1, $B3, $B2
    .byte $FF  ; end token
; 01
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $220A
    .byte $5C, $2D, $31, $20, $50, $4C
    .byte $41, $59, $45, $52
    .byte $FF  ; end token
; 02
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $224C
    .byte $32, $20, $50, $4C
    .byte $41, $59, $45, $52, $53
    .byte $FF  ; end token
; 03
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AC
    .byte $23, $24, $25, $26
    .byte $27, $28, $29, $2A, $2B
    .byte $FF  ; end token
; 04
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2305
    .byte $5D, $20, $31, $39, $38, $30, $20, $31, $39, $38, $34
    .byte $20, $4E, $41, $4D, $43, $4F, $20, $4C, $54, $44, $5B
    .byte $FF  ; end token
; 05
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2347
    .byte $41, $4C, $4C, $20, $52, $49, $47, $48, $54
    .byte $53, $20, $52, $45, $53, $45, $52, $56, $45, $44
    .byte $FF  ; end token
.endif

; Background palette for title screen
tbl_title_background_palette:
    .incbin "assets/generated/palettes/title-background.bin"
.ifdef PACMAN_REVISION_RAM_PALETTES
    .incbin "assets/generated/palettes/title-extra.bin"
.endif
; Attribute bytes for title layout
tbl_title_attribute_bytes:
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .byte $80, $A0, $A0, $A0, $A0, $A0, $A0, $00
    .byte $00, $66, $55, $55, $55, $55, $DD, $00, $08, $0A, $0A, $0A, $0A, $0A, $0A, $00
.ifdef PACMAN_REVISION_TENGEN
tbl_tengen_title_transition_steps:
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
.endif
; Script 02: title menu idle (1P/2P select, start, demo timeout)
handler_script02_title_menu_idle:
    LDA ram_shared_state_0
    ORA ram_shared_state_1
    BNE bra_title_idle_tick
    LDY #$00
; Copy title menu prompt packet into main PPU buffer
bra_copy_menu_prompt_to_ppu_buffer:
    LDA tbl_ppu_cmd_player_count_prompt,Y
    STA ram_ppu_buffer_main,Y
    INY
    CMP #$FF
    BNE bra_copy_menu_prompt_to_ppu_buffer
    LDA ram_btn_1p
    AND #con_btn_Select
    STA ram_direction_1
    LDA ram_btn_1p
    AND #con_btn_Start
    STA ram_direction_2
; Title idle tick: timer and input edge handling
bra_title_idle_tick:
    CLC
    LDA #< $0001
    ADC ram_shared_state_0
    STA ram_shared_state_0
    LDA ram_shared_state_1
    ADC #> $0001
    STA ram_shared_state_1
    CMP #$02
    BNE bra_handle_select_toggle
; start demo mode when timer is 200h
    LDA #$00
    STA ram_shared_state_0
    LDA #con_title_script_attract_intro
    STA ram_script
    JMP loc_script_dispatch_loop
; Handle Select edge: toggle 1P/2P and refresh text
bra_handle_select_toggle:
    LDA ram_btn_1p
    AND #con_btn_Select
    CMP ram_direction_1
    BEQ bra_check_title_start_edge
    STA ram_direction_1
; reset timer
    LDA #> $0001
    STA ram_shared_state_1
    LDA #< $0001
    STA ram_shared_state_0
    LDA ram_direction_1
    BEQ bra_check_title_start_edge
    LDX #$00
    INC ram_game_mode
    LDA ram_game_mode
    AND #$01
    STA ram_game_mode
    BEQ bra_select_player_glyph_index
    INX
; Select glyph pair index for 1P/2P prompt
bra_select_player_glyph_index:
    LDA tbl_player_count_glyph_pair,X
    STA ram_ppu_buffer_main + $02
    LDA tbl_player_count_glyph_pair + $01,X
    STA ram_ppu_buffer_main + $06
    LDA #$22
    STA ram_ppu_buffer_main
    JMP loc_script_dispatch_loop
; Handle Start edge detection
bra_check_title_start_edge:
    LDA ram_btn_1p
    AND #con_btn_Start
    CMP ram_direction_2
    BNE bra_latch_start_state
    JMP loc_script_dispatch_loop
; Latch Start button state
bra_latch_start_state:
    STA ram_direction_2
    LDA ram_direction_2
    BNE bra_start_game_from_title
    JMP loc_script_dispatch_loop
; Start pressed: leave demo flag, init audio, jump into game init
bra_start_game_from_title:
    LDA #$00
    STA ram_flag_demo
    JSR sub_clear_sound_engine_state
    JMP loc_enter_gameplay_session

; PPU command packet to draw player count prompt
tbl_ppu_cmd_player_count_prompt:
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $220A
    .byte $5C, $00, $22, $4A, $20
    .byte $FF  ; end token

; Glyph pairs for 1P/2P indicator update
tbl_player_count_glyph_pair:
; either 5C 20 or 20 5C pair is read
    .byte $5C
    .byte $20
    .byte $5C
; Script 04: attract/demo pre-roll state machine
