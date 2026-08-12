; READY sequence, player handoff, and associated sprite tables

ofs_003_CA9D_script02_round_ready:		; was: ofs_003_CA9D_02
    LDA ram_0087
    BEQ bra_CAA4_build_ready_sprites
    JMP loc_CB1A_round_ready_tick
; Enter READY sprite composition routine
bra_CAA4_build_ready_sprites:		; was: bra_CAA4
    LoadPointer ram_0000, (ram_oam + $60)
    LDA ram_flag_demo
    BNE bra_CB1A_round_ready_tick_entry
    LDA #$02
    STA ram_0004
    LDY #$00
    STY ram_0005
    STY ram_0006
    STY ram_0007
; Build next READY sprite group
bra_CABC_build_next_ready_group:		; was: bra_CABC_loop
    LDX ram_0006
    LDA tbl_CBF6_ready_text_sprite_positions,X
    STA ram_0002    ; spr_X
    LDA tbl_CBF6_ready_text_sprite_positions + $01,X
    STA ram_0003    ; spr_Y
    LDX ram_0007
    LDA tbl_CBFC_ready_text_group_sizes,X
    STA ram_0008    ; spr counter
; Emit one READY sprite group into OAM
bra_CACF_emit_ready_group_sprites:		; was: bra_CACF_loop
    LDA ram_0003    ; spr_Y
    STA (ram_0000),Y    ; 0760-0798 (spr_Y)
    LDX ram_0005
    LDA tbl_CBD2_ready_text_sprite_tiles,X
    INY
    STA (ram_0000),Y    ; 0761-0799 (spr_T)
    LDA tbl_CBE4_ready_text_sprite_attrs,X
    INY
    STA (ram_0000),Y    ; 0762-079A (spr_A)
    LDA ram_0002    ; spr_X
    INY
    STA (ram_0000),Y    ; 0763-079B (spr_X)
    LDA ram_0002    ; spr_X
    CLC
    ADC #$08
    STA ram_0002    ; spr_X
    INY
    INC ram_0005
    DEC ram_0008    ; spr counter
    BNE bra_CACF_emit_ready_group_sprites
    INC ram_0006
    INC ram_0006
    INC ram_0007
    LDA ram_0069
    BNE bra_CB02_advance_ready_group_counter
    LDA ram_stage_p1
    BNE bra_CB1A_round_ready_tick_entry
; Advance READY group repetition counter
bra_CB02_advance_ready_group_counter:		; was: bra_CB02
    DEC ram_0004
    BEQ bra_CB0A_check_two_player_ready_layout
    BPL bra_CABC_build_next_ready_group
    BMI bra_CB1A_round_ready_tick_entry    ; jmp
; Adjust READY layout for two-player/current-player mode
bra_CB0A_check_two_player_ready_layout:		; was: bra_CB0A
    LDA ram_game_mode
    BEQ bra_CB1A_round_ready_tick_entry
    LDA ram_current_player
    BEQ bra_CABC_build_next_ready_group
    INC ram_0005
    INC ram_0005
    INC ram_0005
    BNE bra_CABC_build_next_ready_group   ; jmp
; Jump target entering ready-phase timer tick
bra_CB1A_round_ready_tick_entry:		; was: bra_CB1A
; Round-ready timer tick and thresholds
loc_CB1A_round_ready_tick:		; was: loc_CB1A
    LDA ram_0087
    CMP #$C0
    BNE bra_CB23_inc_ready_timer
; C0
    JMP loc_CBB2_wait_ready_sfx_done
; Increment READY timer and check thresholds
bra_CB23_inc_ready_timer:		; was: bra_CB23
    INC ram_0087
    LDA ram_0087
    CMP #$78
    BEQ bra_CB2E_ready_timer_reached_78
    JMP loc_CBCF_return_gameplay_dispatch
; At READY timer $78: pre-position actor sprites before handoff
bra_CB2E_ready_timer_reached_78:		; was: bra_CB2E_78
    LDA #$A8
    STA ram_obj_pos_Y_hi
    LDA #$60
    STA ram_obj_pos_X_hi
    STA ram_obj_pos_X_hi + $04
    STA ram_obj_pos_X_hi + $08
    LDA #$58
    STA ram_obj_pos_X_hi + $0C
    STA ram_obj_pos_Y_hi + $04
    LDA #$68
    STA ram_obj_pos_X_hi + $10
    LDA #$70
    STA ram_obj_pos_Y_hi + $08
    STA ram_obj_pos_Y_hi + $0C
    STA ram_obj_pos_Y_hi + $10
    LDA #$00
    TAY
; Clear OAM window used by READY text
bra_CB4F_clear_ready_oam_window:		; was: bra_CB4F_loop
; 0778-079B
    STA ram_oam + $78,Y
    INY
    CPY #$24
    BNE bra_CB4F_clear_ready_oam_window
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_CB5F_store_life_icon_offset
    LDA #$08
; Store base offset for life icon placement
bra_CB5F_store_life_icon_offset:		; was: bra_CB5F
    STA ram_0000
    LDA ram_lives_p1
    SEC
    SBC #$01
    ASL
    TAY
    LDA tbl_CC07_life_icons_ppu_addresses,Y
    CLC
    ADC ram_0000
    STA ram_0000
    LDA tbl_CC07_life_icons_ppu_addresses + $01,Y
    STA ram_0001
    LDA ram_0000    ; ppu hi
    STA ram_ppu_buffer_main
    LDA ram_0001    ; ppu lo
    STA ram_ppu_buffer_main + $01
    LDA #con_tile + $2D
    STA ram_ppu_buffer_main + $02
    STA ram_ppu_buffer_main + $03
    LDA #con_tile + $00
    STA ram_ppu_buffer_main + $04
    LDA ram_0000
    STA ram_ppu_buffer_main + $05
    LDA ram_0001
    CLC
    ADC #con_tile + $20
    STA ram_ppu_buffer_main + $06
    LDA #con_tile + $2D
    STA ram_ppu_buffer_main + $07
    STA ram_ppu_buffer_main + $08
    LDA #$FF    ; close buffer
    STA ram_ppu_buffer_main + $09
    JSR sub_D8F9_update_pacman_anim_frame
    JSR sub_D937_update_ghost_anim_frames
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_CBCF_return_gameplay_dispatch



; Wait until READY SFX complete before leaving ready phase
loc_CBB2_wait_ready_sfx_done:		; was: loc_CBB2
    LDA ram_sfx_plr_ready
    ORA ram_sfx_plr_ready + $01
    BNE bra_CBCF_return_dispatch
    LDA ram_flag_demo
    BNE bra_CBCB_switch_to_pause_script
    LDA #$00
    STA ram_0069
    TAY
; Clear READY text OAM tail before script switch
bra_CBC3_clear_ready_oam_tail:		; was: bra_CBC3_loop
; 0760-07FF
    STA ram_oam + $60,Y
    INY
    CPY #$A0
    BNE bra_CBC3_clear_ready_oam_tail
; Switch script to active gameplay/pause handler
bra_CBCB_switch_to_pause_script:		; was: bra_CBCB
    LDA #con_script_04
    STA ram_script
; Return to gameplay dispatcher
bra_CBCF_return_dispatch:		; was: bra_CBCF
; Return to gameplay dispatcher loop
loc_CBCF_return_gameplay_dispatch:		; was: loc_CBCF
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Sprite tile sequence used in READY/game-over text builder
tbl_CBD2_ready_text_sprite_tiles:		; was: tbl_CBD2_spr_T
    .byte $C6   ; 00
    .byte $C3   ; 01
    .byte $C1   ; 02
    .byte $BA   ; 03
    .byte $C7   ; 04
    .byte $BB   ; 05
    .byte $B0   ; 06
    .byte $B1   ; 07
    .byte $B2   ; 08
    .byte $B3   ; 09
    .byte $B4   ; 0A
    .byte $B5   ; 0B
    .byte $B6   ; 0C
    .byte $B7   ; 0D
    .byte $B4   ; 0E
    .byte $B8   ; 0F
    .byte $B9   ; 10
    .byte $B6   ; 11



; Sprite attributes for READY/game-over text sprites
tbl_CBE4_ready_text_sprite_attrs:		; was: tbl_CBE4_spr_A
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $00   ; 03
    .byte $00   ; 04
    .byte $00   ; 05
    .byte $02   ; 06
    .byte $02   ; 07
    .byte $02   ; 08
    .byte $02   ; 09
    .byte $02   ; 0A
    .byte $02   ; 0B
    .byte $02   ; 0C
    .byte $02   ; 0D
    .byte $02   ; 0E
    .byte $02   ; 0F
    .byte $02   ; 10
    .byte $02   ; 11



; Base sprite positions for READY phase text
tbl_CBF6_ready_text_sprite_positions:		; was: tbl_CBF6_spr_pos
; X, Y
    .byte $44, $88   ; 00
    .byte $44, $60   ; 02
    .byte $50, $70   ; 04



; Sprite group sizes for READY phase text composition
tbl_CBFC_ready_text_group_sizes:		; was: tbl_CBFC_spr_counter
    .byte $06   ; 00
    .byte $06   ; 02
    .byte $03   ; 04


; Unused padding bytes (not referenced by code/data pointers)
    .byte $C0, $C1, $C2, $C3, $C4, $C5, $C3, $C6
; PPU addresses for life icons placement
tbl_CC07_life_icons_ppu_addresses:		; was: tbl_CC07
; Row addresses used to erase/redraw life icons near HUD
    .dbyt $2317 ; 01
    .dbyt $2319 ; 02
    .dbyt $231B ; 03
    .dbyt $2357 ; 04



; Script 06: short freeze after ghost/fruit eat events (score popup window)
