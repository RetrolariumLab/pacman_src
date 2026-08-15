; READY sequence, player handoff, and associated sprite tables

handler_script02_round_ready:		; was: ofs_003_CA9D_02
    LDA ram_shared_state_0
    BEQ bra_build_ready_sprites
    JMP loc_round_ready_tick
; Enter READY sprite composition routine
bra_build_ready_sprites:		; was: bra_CAA4
    LoadPointer zp_work0, (ram_oam + $60)
    LDA ram_flag_demo
    BNE bra_round_ready_tick_entry
    LDA #$02
    STA zp_work4
    LDY #$00
    STY zp_work5
    STY zp_work6
    STY zp_work7
; Build next READY sprite group
bra_build_next_ready_group:		; was: bra_CABC_loop
    LDX zp_work6
    LDA tbl_ready_text_sprite_positions,X
    STA zp_work2    ; spr_X
    LDA tbl_ready_text_sprite_positions + $01,X
    STA zp_work3    ; spr_Y
    LDX zp_work7
    LDA tbl_ready_text_group_sizes,X
    STA zp_work8    ; spr counter
; Emit one READY sprite group into OAM
bra_emit_ready_group_sprites:		; was: bra_CACF_loop
    LDA zp_work3    ; spr_Y
    STA (zp_work0),Y    ; 0760-0798 (spr_Y)
    LDX zp_work5
    LDA tbl_ready_text_sprite_tiles,X
    INY
    STA (zp_work0),Y    ; 0761-0799 (spr_T)
    LDA tbl_ready_text_sprite_attrs,X
    INY
    STA (zp_work0),Y    ; 0762-079A (spr_A)
    LDA zp_work2    ; spr_X
    INY
    STA (zp_work0),Y    ; 0763-079B (spr_X)
    LDA zp_work2    ; spr_X
    CLC
    ADC #$08
    STA zp_work2    ; spr_X
    INY
    INC zp_work5
    DEC zp_work8    ; spr counter
    BNE bra_emit_ready_group_sprites
    INC zp_work6
    INC zp_work6
    INC zp_work7
    LDA ram_round_restart_flag
    BNE bra_advance_ready_group_counter
    LDA ram_stage_p1
    BNE bra_round_ready_tick_entry
; Advance READY group repetition counter
bra_advance_ready_group_counter:		; was: bra_CB02
    DEC zp_work4
    BEQ bra_check_two_player_ready_layout
    BPL bra_build_next_ready_group
    BMI bra_round_ready_tick_entry    ; jmp
; Adjust READY layout for two-player/current-player mode
bra_check_two_player_ready_layout:		; was: bra_CB0A
    LDA ram_game_mode
    BEQ bra_round_ready_tick_entry
    LDA ram_current_player
    BEQ bra_build_next_ready_group
    INC zp_work5
    INC zp_work5
    INC zp_work5
    BNE bra_build_next_ready_group   ; jmp
; Jump target entering ready-phase timer tick
bra_round_ready_tick_entry:		; was: bra_CB1A
; Round-ready timer tick and thresholds
loc_round_ready_tick:		; was: loc_CB1A
    LDA ram_shared_state_0
    CMP #$C0
    BNE bra_inc_ready_timer
; C0
    JMP loc_wait_ready_sfx_done
; Increment READY timer and check thresholds
bra_inc_ready_timer:		; was: bra_CB23
    INC ram_shared_state_0
    LDA ram_shared_state_0
    CMP #$78
    BEQ bra_ready_timer_reached_78
    JMP loc_return_gameplay_dispatch
; At READY timer $78: pre-position actor sprites before handoff
bra_ready_timer_reached_78:		; was: bra_CB2E_78
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
bra_clear_ready_oam_window:		; was: bra_CB4F_loop
; 0778-079B
    STA ram_oam + $78,Y
    INY
    CPY #$24
    BNE bra_clear_ready_oam_window
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_store_life_icon_offset
    LDA #$08
; Store base offset for life icon placement
bra_store_life_icon_offset:		; was: bra_CB5F
    STA zp_work0
    LDA ram_lives_p1
    SEC
    SBC #$01
    ASL
    TAY
    LDA tbl_life_icons_ppu_addresses,Y
    CLC
    ADC zp_work0
    STA zp_work0
    LDA tbl_life_icons_ppu_addresses + $01,Y
    STA zp_work1
    LDA zp_work0    ; ppu hi
    STA ram_ppu_buffer_main
    LDA zp_work1    ; ppu lo
    STA ram_ppu_buffer_main + $01
    LDA #con_tile + $2D
    STA ram_ppu_buffer_main + $02
    STA ram_ppu_buffer_main + $03
    LDA #con_tile + $00
    STA ram_ppu_buffer_main + $04
    LDA zp_work0
    STA ram_ppu_buffer_main + $05
    LDA zp_work1
    CLC
    ADC #con_tile + $20
    STA ram_ppu_buffer_main + $06
    LDA #con_tile + $2D
    STA ram_ppu_buffer_main + $07
    STA ram_ppu_buffer_main + $08
    LDA #$FF    ; close buffer
    STA ram_ppu_buffer_main + $09
    JSR sub_update_pacman_anim_frame
    JSR sub_update_ghost_anim_frames
    JSR sub_prepare_sprite_positions
    JMP loc_return_gameplay_dispatch

; Wait until READY SFX complete before leaving ready phase
loc_wait_ready_sfx_done:		; was: loc_CBB2
    LDA ram_sfx_plr_ready
    ORA ram_sfx_plr_ready + $01
    BNE bra_return_dispatch
    LDA ram_flag_demo
    BNE bra_switch_to_pause_script
    LDA #$00
    STA ram_round_restart_flag
    TAY
; Clear READY text OAM tail before script switch
bra_clear_ready_oam_tail:		; was: bra_CBC3_loop
; 0760-07FF
    STA ram_oam + $60,Y
    INY
    CPY #$A0
    BNE bra_clear_ready_oam_tail
; Switch script to active gameplay/pause handler
bra_switch_to_pause_script:		; was: bra_CBCB
    LDA #con_game_script_pause
    STA ram_script
; Return to gameplay dispatcher
bra_return_dispatch:		; was: bra_CBCF
; Return to gameplay dispatcher loop
loc_return_gameplay_dispatch:		; was: loc_CBCF
    JMP loc_gameplay_mainloop_wait_nmi

; Sprite tile sequence used in READY/game-over text builder
tbl_ready_text_sprite_tiles:		; was: tbl_CBD2_spr_T
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
tbl_ready_text_sprite_attrs:		; was: tbl_CBE4_spr_A
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
tbl_ready_text_sprite_positions:		; was: tbl_CBF6_spr_pos
; X, Y
    .byte $44, $88   ; 00
    .byte $44, $60   ; 02
    .byte $50, $70   ; 04

; Sprite group sizes for READY phase text composition
tbl_ready_text_group_sizes:		; was: tbl_CBFC_spr_counter
    .byte $06   ; 00
    .byte $06   ; 02
    .byte $03   ; 04

; Unused padding bytes (not referenced by code/data pointers)
    .byte $C0, $C1, $C2, $C3, $C4, $C5, $C3, $C6
; PPU addresses for life icons placement
tbl_life_icons_ppu_addresses:		; was: tbl_CC07
; Row addresses used to erase/redraw life icons near HUD
    .dbyt $2317 ; 01
    .dbyt $2319 ; 02
    .dbyt $231B ; 03
    .dbyt $2357 ; 04

; Script 06: short freeze after ghost/fruit eat events (score popup window)
