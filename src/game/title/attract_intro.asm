; Attract-mode introduction, text packets, palettes, and setup

handler_script04_attract_intro:		; was: ofs_000_C458_04
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_run_attract_substate
    LDA #con_title_script_menu_idle
    STA ram_script
    JMP loc_main_frame_bootstrap
; Execute current attract substate handler
bra_run_attract_substate:		; was: bra_C465
    LDY ram_shared_state_0
    LDA tbl_attract_substate_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_attract_substate_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Attract-mode substate handler table
tbl_attract_substate_handlers:		; was: tbl_C474
    .word handler_attract_substate_init
    .word handler_attract_substate_wait_30f
    .word handler_attract_substate_wait_30f_alias_04
    .word handler_attract_substate_wait_30f_alias_06
    .word handler_attract_substate_wait_30f_alias_08
    .word handler_attract_substate_wait_30f_alias_0A
    .word handler_attract_substate_wait_30f_alias_0C
    .word handler_attract_substate_wait_30f_alias_0E
    .word handler_attract_substate_wait_30f_alias_10
    .word handler_attract_substate_wait_30f_alias_12
    .word handler_attract_substate_wait_80f
    .word handler_attract_chase_scene

; Attract substate init: setup nametable/palette and seed sequence
handler_attract_substate_init:		; was: ofs_001_C48C_00
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI completion before attract setup writes
bra_wait_nmi_before_attract_setup:		; was: bra_C490_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi_before_attract_setup
    LDA #PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    LDA #$00
    STA PPUMASK
    STA ram_shared_state_1
    JSR sub_draw_attract_playfield_frame
    JSR sub_setup_attract_palette_and_attrs
    JSR sub_build_attract_ppu_packet
    INC ram_shared_state_0
    INC ram_shared_state_0
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    JMP loc_script_dispatch_loop

; Attract substate wait loop (0x30 frames step)
handler_attract_substate_wait_30f:		; was: ofs_001_C4B9_02
; Alias entry for 30-frame attract wait handler (substate 04)
handler_attract_substate_wait_30f_alias_04:		; was: ofs_001_C4B9_04
; Alias entry for 30-frame attract wait handler (substate 06)
handler_attract_substate_wait_30f_alias_06:		; was: ofs_001_C4B9_06
; Alias entry for 30-frame attract wait handler (substate 08)
handler_attract_substate_wait_30f_alias_08:		; was: ofs_001_C4B9_08
; Alias entry for 30-frame attract wait handler (substate 0A)
handler_attract_substate_wait_30f_alias_0A:		; was: ofs_001_C4B9_0A
; Alias entry for 30-frame attract wait handler (substate 0C)
handler_attract_substate_wait_30f_alias_0C:		; was: ofs_001_C4B9_0C
; Alias entry for 30-frame attract wait handler (substate 0E)
handler_attract_substate_wait_30f_alias_0E:		; was: ofs_001_C4B9_0E
; Alias entry for 30-frame attract wait handler (substate 10)
handler_attract_substate_wait_30f_alias_10:		; was: ofs_001_C4B9_10
; Alias entry for 30-frame attract wait handler (substate 12)
handler_attract_substate_wait_30f_alias_12:		; was: ofs_001_C4B9_12
    INC ram_shared_state_1
    LDA ram_shared_state_1
    CMP #$30
    BNE bra_dispatch_next_attract_frame
    LDA #$00
    STA ram_shared_state_1
    JSR sub_build_attract_ppu_packet
    INC ram_shared_state_0
    INC ram_shared_state_0
; Return to script dispatcher after attract wait tick
bra_dispatch_next_attract_frame:		; was: bra_C4CC
    JMP loc_script_dispatch_loop

; Attract tail wait before handoff
handler_attract_substate_wait_80f:		; was: ofs_001_C4CF_14
    INC ram_shared_state_1
    LDA ram_shared_state_1
    CMP #$80
    BEQ bra_advance_substate_after_wait
    JMP loc_script_dispatch_loop
; Advance attract substate after tail wait expires
bra_advance_substate_after_wait:		; was: bra_C4DA
    INC ram_shared_state_0
    INC ram_shared_state_0
    LDA #$00
    STA ram_shared_state_1
    JMP loc_script_dispatch_loop

; !(UNUSED) No pointer, branch, or fall-through reaches this block. See CODE-001.
    LDA #$01
    STA ram_game_mode
    JMP loc_enter_gameplay_session

; Build next attract/demo PPU update packet (and optional sprite strip)
sub_build_attract_ppu_packet:		; was: sub_C4EC
    LDY ram_shared_state_0
    LDA tbl_attract_ppu_packet_ptrs,Y
    STA zp_work0
    LDA tbl_attract_ppu_packet_ptrs + $01,Y
    STA zp_work1
    LDY #$00
; Copy attract PPU packet bytes into main PPU buffer
bra_copy_ppu_packet_to_buffer:		; was: bra_C4FA_loop
    LDA (zp_work0),Y    ; data from 0x0005E3
    STA ram_ppu_buffer_main,Y
    INY
    CMP #con_ppu_buffer_end
    BNE bra_copy_ppu_packet_to_buffer
    LDA (zp_work0),Y    ; data from 0x0005E3 (last byte)
    BEQ bra_copy_optional_sprite_strip
    RTS
; Copy optional sprite strip payload after packet terminator
bra_copy_optional_sprite_strip:		; was: bra_C509
    LDA ram_shared_state_0
    SEC
    SBC #$02
    ASL
    ASL
    TAY
    LDX #$10
; Copy 16-byte sprite strip into OAM shadow
bra_copy_attract_sprite_strip:		; was: bra_C513_loop
; potential 0760-079F range, interval 10h
    LDA tbl_attract_sprite_strip_data,Y
    STA ram_oam + $60,Y
    INY
    DEX
    BNE bra_copy_attract_sprite_strip
    RTS

; Draw attract-mode playfield frame tiles
sub_draw_attract_playfield_frame:		; was: sub_C51E
    LDA #> $20C0
    STA PPUADDR
    LDA #< $20C0
    STA PPUADDR
    LDA #$17
    STA zp_work0
; Draw next row of attract playfield frame
bra_draw_next_frame_row:		; was: bra_C52C_loop
    LDA #$1C
    STA zp_work1
    LDA #con_tile_maze_blank
    STA PPUDATA
    STA PPUDATA
    LDA #con_tile_space
; Fill inner row tiles between frame borders
bra_fill_frame_inner_row:		; was: bra_C53A_loop
    STA PPUDATA
    DEC zp_work1
    BNE bra_fill_frame_inner_row
    LDA #con_tile_maze_blank
    STA PPUDATA
    STA PPUDATA
    DEC zp_work0
    BPL bra_draw_next_frame_row
    RTS

; Setup attract-mode attributes and palette
sub_setup_attract_palette_and_attrs:		; was: sub_C54E
    LDA #> $23C0
    STA PPUADDR
    LDA #< $23C0
    STA PPUADDR
    LDY #$20
    LDA #$00
; Clear initial attract attribute block bytes
bra_clear_primary_attribute_table:		; was: bra_C55C_loop
    STA PPUDATA
    DEY
    BNE bra_clear_primary_attribute_table
    LDA #> $23D0
    STA PPUADDR
    LDA #< $23D0
    STA PPUADDR
    LDA #$03
    STA zp_work0
    LDA #$55
; Fill attract checker/stripe attribute rows
bra_fill_checker_attr_rows:		; was: bra_C572_loop
    LDY #$08
; Write 8 repeated attribute bytes
bra_write_eight_attr_bytes:		; was: bra_C574_loop
    STA PPUDATA
    DEY
    BNE bra_write_eight_attr_bytes
    CLC
    ADC #$55
    DEC zp_work0
    BNE bra_fill_checker_attr_rows
    LDA #> $3F00
    STA PPUADDR
    LDA #< $3F00
    STA PPUADDR
    LDY #$00
; Upload 32-byte attract palette block
bra_upload_attract_palette32:		; was: bra_C58D_loop
    LDA tbl_attract_bg_spr_palette,Y
    STA PPUDATA
    INY
    CPY #$20
    BNE bra_upload_attract_palette32
    LDA #> $23E8
    STA PPUADDR
    LDA #< $23E8
    STA PPUADDR
    LDA #$AA
    STA PPUDATA
    STA PPUDATA
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    RTS

; Attract scene BG+SPR palette block (32 bytes)
tbl_attract_bg_spr_palette:		; was: tbl_C5B3_palette
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
tbl_attract_ppu_packet_ptrs:		; was: tbl_C5D3
    .word off_attract_text_header_character_nickname
    .word off_attract_text_alias_oikake
    .word off_attract_text_name_akabei
    .word off_attract_text_alias_machibuse
    .word off_attract_text_name_pinky
    .word off_attract_text_alias_tiles_0A
    .word off_attract_text_name_tiles_0C
    .word off_attract_text_alias_otoboke
    .word off_attract_text_name_guzuta
    .word off_attract_text_points_table

; Keep this data adjacent to the indexed lookup above if the block is moved.
; code always reads next byte after FF via 0x000514
; and checks if it is 00 or not
; recommended to place additional FF or 01 or whatever byte after each chunk of data
; so it will be pairs of FF + 00 and FF + FF
; currently only FF + 00 pairs exist
; Attract packet: header CHARACTER/NICKNAME
off_attract_text_header_character_nickname:		; was: _off000_C5E7_00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $20E6
    .byte                               $43, $48, $52, $41, $43, $54, $45, $52, $20, $20
    .byte $3B, $20, $20, $4E, $49, $43, $4B, $4E, $41, $4D, $45
    .byte $FF   ; end token

; Attract packet: alias text OIKAKE...
off_attract_text_alias_oikake:		; was: _off000_C5FF_02
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2148
    .byte                                         $4F, $49, $4B, $41, $4B, $45, $2E, $2E
    .byte $2E, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition

; Attract packet: name AKABEI
off_attract_text_name_akabei:		; was: _off000_C60E_04
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2153
    .byte $5F, $41, $4B, $41, $42, $45, $49, $5F
    .byte $FF   ; end token

; Attract packet: alias text MACHIBUSE..
off_attract_text_alias_machibuse:		; was: _off000_C619_06
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $21A8
    .byte $4D, $41, $43, $48, $49, $42, $55, $53
    .byte $45, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition

; Attract packet: name PINKY
off_attract_text_name_pinky:		; was: _off000_C628_08
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $21B3
    .byte                $5F, $50, $49, $4E, $4B, $59, $5F
    .byte $FF   ; end token

; Attract packet: alias text tile sequence (set 0A)
off_attract_text_alias_tiles_0A:		; was: _off000_C632_0A
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2208
    .byte                                         $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7
    .byte $03, $03, $03
    .byte $FF   ; end token
    .byte $00   ; condition

; Attract packet: name tile sequence (set 0C)
off_attract_text_name_tiles_0C:		; was: _off000_C641_0C
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2213
    .byte                $C8, $C3, $C9, $CA, $C5, $C0, $C7, $C8
    .byte $FF   ; end token

; Attract packet: alias text OTOBOKE...
off_attract_text_alias_otoboke:		; was: _off000_C64C_0E
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2268
    .byte                                         $4F, $54, $4F, $42, $4F, $4B, $45, $2E
    .byte $2E, $2E, $2E
    .byte $FF   ; end token
    .byte $00   ; condition

; Attract packet: name GUZUTA
off_attract_text_name_guzuta:		; was: _off000_C65B_10
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2273
    .byte                $5F, $47, $55, $5A, $55, $54, $41, $5F
    .byte $FF   ; end token

; Attract packet: points table entries
off_attract_text_points_table:		; was: _off000_C666_12
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AD
    .byte                                                                  $03, $20, $31
    .byte $30, $20, $50, $54, $53, $00, $22, $ED, $01, $20, $35, $30, $20, $50, $54, $53
    .byte $00, $23, $4C, $23, $24, $25, $26, $27, $28, $29, $2A, $2B
    .byte $FF   ; end token
; !(UNKNOWN) Explain the legacy $05F7 read warning. See DATA-003.

; Sprite strip data used by optional attract packet payload
tbl_attract_sprite_strip_data:		; was: tbl_C688_spr_data
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
