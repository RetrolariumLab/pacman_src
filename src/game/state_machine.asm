; Gameplay script core and round initialization




; ---------------------------------------------------------------------------
; GAMEPLAY SCRIPT CORE
; This is the main runtime loop used after leaving title/attract.
; Includes round init, pause, ready, collisions, death, stage clear, and game over.
; ---------------------------------------------------------------------------
; Enter gameplay session (demo or real game) and init runtime state
loc_C98A_enter_gameplay_session:		; was: loc_C98A
    LDA #$08
    STA $2000
    STA ram_for_2000
; Wait for vblank set before disabling rendering during gameplay init
bra_C991_wait_vblank_set:		; was: bra_C991_infinite_loop
    LDA $2002
    BPL bra_C991_wait_vblank_set
    LDA #$00    ; con_script_00
    STA $2001
    STA ram_script
    STA ram_current_player
    STA ram_0069
    STA ram_flag_pause
    JSR sub_E2FF_clear_bg_nametables_and_attrs
    JSR sub_E47C_upload_hud_text_blocks
    JSR sub_E379_draw_score_hud_live
    LDA ram_flag_demo
    BEQ bra_C9B6_init_non_demo_player_state
    LDA #$01
    STA ram_lives_p1
    BNE bra_C9CD_reset_stage_counters    ; jmp
; Initialize player state for non-demo session
bra_C9B6_init_non_demo_player_state:		; was: bra_C9B6
    LDA #$00
    TAY
; Clear per-player runtime block RAM
bra_C9B9_clear_player_runtime_block:		; was: bra_C9B9_loop
; 0067-0086
    STA ram_data_p1,Y
    INY
    CPY #$20
    BNE bra_C9B9_clear_player_runtime_block
    LDA #$03
    STA ram_lives_p1
    STA ram_lives_p2
    STA ram_sfx_plr_ready
    STA ram_sfx_plr_ready + $01
; Reset stage/high-score related counters before loop
bra_C9CD_reset_stage_counters:		; was: bra_C9CD
    LDA #$FF
    STA ram_stage_p1
    STA ram_stage_p2
    STA ram_ppu_buffer_hiscore
    LDA #$88
    STA ram_for_2000
    STA $2000
; Main gameplay loop entry with NMI wait
loc_C9DD_gameplay_mainloop_wait_nmi:		; was: loc_C9DD
; Gameplay loop per-frame tick
bra_C9DD_loop_gameplay_tick:		; was: bra_C9DD_loop
    LDA #$01
    STA ram_nmi_wait
; Busy-wait until NMI handler clears flag
bra_C9E1_wait_nmi_complete:		; was: bra_C9E1_infinite_loop
    LDA ram_nmi_wait
    BNE bra_C9E1_wait_nmi_complete
    LDA ram_flag_demo
    BEQ bra_C9F6_handle_script_delay
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_C9F6_handle_script_delay
    LDA #con_script_02
    STA ram_script
    JMP loc_C168_main_frame_bootstrap
; Handle script delay countdown before dispatch
bra_C9F6_handle_script_delay:		; was: bra_C9F6
    LDA ram_004C
    BEQ bra_C9FE_dispatch_current_script
    DEC ram_004C
    BNE bra_C9DD_loop_gameplay_tick
; Dispatch current gameplay script handler
bra_C9FE_dispatch_current_script:		; was: bra_C9FE
; ram_script stores even-valued state IDs indexing tbl_CA0D_gameplay_script_handlers
    LDY ram_script
    LDA tbl_CA0D_gameplay_script_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_CA0D_gameplay_script_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Main gameplay script handler table
tbl_CA0D_gameplay_script_handlers:		; was: tbl_CA0D
    .word ofs_003_CE35_script00_round_init
    .word ofs_003_CA9D_script02_round_ready
    .word ofs_003_CA1F_script04_pause_handler
    .word ofs_003_CC0F_script06_post_eat_pause
    .word ofs_003_CC3C_script08_death_sequence
    .word ofs_003_CD61_script0A_game_over
    .word ofs_003_CCE6_script0C_stage_clear
    .word ofs_003_E655_script0E_intermission_setup
    .word ofs_003_E74B_script10_intermission_runtime



; Script 04: pause input gate + PAUSE text packet
ofs_003_CA1F_script04_pause_handler:		; was: ofs_003_CA1F_04
    LDA ram_060F
    BEQ bra_CA27_check_start_edge
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Check Start button edge for pause toggle
bra_CA27_check_start_edge:		; was: bra_CA27
    LDA ram_btn_1p
    AND #con_btn_Start
    CMP ram_0049
    BEQ bra_CA67_run_frame_when_no_new_start
    STA ram_0049
    LDA ram_0049
    BEQ bra_CA67_run_frame_when_no_new_start
    INC ram_flag_pause
    LDX #$22    ; 2237
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_CA41_store_pause_ppu_addr
    LDX #$2A    ; 2A37
; Store selected nametable address for PAUSE text packet
bra_CA41_store_pause_ppu_addr:		; was: bra_CA41
    STX ram_ppu_buffer_main
    LDA #$37
    STA ram_ppu_buffer_main + $01
    LDX #$06
    LDY #$00
    LDA ram_flag_pause
    AND #$01
    BEQ bra_CA58_select_pause_text_variant
    LDX #$00
    STA ram_060F
; Select PAUSE text or blanks based on pause state
bra_CA58_select_pause_text_variant:		; was: bra_CA58
; Copy pause/on-off tile sequence into PPU packet
bra_CA58_copy_pause_tiles:		; was: bra_CA58_loop
    LDA tbl_CA91_pause_text_tiles,X
    STA ram_ppu_buffer_main + $02,Y
    INX
    INY
    CPY #$06
    BNE bra_CA58_copy_pause_tiles
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; No new Start edge path for normal frame processing
bra_CA67_run_frame_when_no_new_start:		; was: bra_CA67
    LDA ram_flag_pause
    AND #$01
    BEQ bra_CA70_run_unpaused_gameplay_step
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Run gameplay update chain when not paused
bra_CA70_run_unpaused_gameplay_step:		; was: bra_CA70
    JSR sub_D0EF_update_round_timers_and_frightened
    JSR sub_DEDF_check_for_eating_pellets
    JSR sub_D2FB_update_pacman_movement
    JSR sub_D8F9_update_pacman_anim_frame
    JSR sub_D4C2_update_ghost_slots
    JSR sub_D937_update_ghost_anim_frames
    JSR sub_D8C9_update_ghost_house_counters
    JSR sub_DDC9_blink_power_pellet_tiles
    JSR sub_D20F_check_actor_collisions
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Tile sequences for PAUSE on/off text
tbl_CA91_pause_text_tiles:		; was: tbl_CA91
    .byte $50, $41, $55, $53, $45, $FF   ; 00
    .byte $2D, $2D, $2D, $2D, $2D, $FF   ; 06



; Script 02: READY countdown + pre-control HUD/sprite setup
ofs_003_CA9D_script02_round_ready:		; was: ofs_003_CA9D_02
    LDA ram_0087
    BEQ bra_CAA4_build_ready_sprites
    JMP loc_CB1A_round_ready_tick
; Enter READY sprite composition routine
bra_CAA4_build_ready_sprites:		; was: bra_CAA4
    LDA #< (ram_oam + $60)
    STA ram_0000
    LDA #> (ram_oam + $60)
    STA ram_0001
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
ofs_003_CC0F_script06_post_eat_pause:		; was: ofs_003_CC0F_06
    INC ram_00DA
    LDA #$28
    CMP ram_00DA
    BNE bra_CC2D_run_post_eat_updates
    LDA #$02
    STA ram_00DA
    LDA #con_script_04
    STA ram_script
    LDA #$08
    LDX #$FE
; Find ghost slot matching post-eat state marker
bra_CC23_find_matching_ghost_state_slot:		; was: bra_CC23_loop
    INX
    INX
    CMP ram_00B8,X
    BNE bra_CC23_find_matching_ghost_state_slot
    LDA #$06
    STA ram_00B8,X
; Continue post-eat freeze updates
bra_CC2D_run_post_eat_updates:		; was: bra_CC2D
    JSR sub_DDC9_blink_power_pellet_tiles
    JSR sub_D87F_update_ghost_slots_state06_only
    JSR sub_D937_update_ghost_anim_frames
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Script 08: Pac-Man death sequence + life decrement / handoff logic
ofs_003_CC3C_script08_death_sequence:		; was: ofs_003_CC3C_08
    LDA ram_0087
    BNE bra_CC63_run_death_anim_phase
    DEC ram_00DB
    BNE bra_CC57_run_pre_death_frame_updates
    INC ram_0087
    LDA #$0A
    STA ram_00DB
    STA ram_sfx_death
    LDA #$00
    TAX
; Clear actor slots at death-sequence start
bra_CC50_clear_actor_slots_for_death:		; was: bra_CC50_loop
    STA ram_obj_position + $04,X
    INX
    CPX #$14
    BNE bra_CC50_clear_actor_slots_for_death
; Death sequence pre-animation update frame
bra_CC57_run_pre_death_frame_updates:		; was: bra_CC57
    JSR sub_DDC9_blink_power_pellet_tiles
    JSR sub_D937_update_ghost_anim_frames
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Death sequence phase with animation stepping
bra_CC63_run_death_anim_phase:		; was: bra_CC63
    DEC ram_00DB
    BPL bra_CC76_wait_next_death_anim_step
    LDA #$0A
    STA ram_00DB
    LDA ram_animation
    CLC
    ADC #$01
    STA ram_animation
    CMP #$1E
    BEQ bra_CC7F_finish_death_anim_phase
; Wait until next death animation step timer
bra_CC76_wait_next_death_anim_step:		; was: bra_CC76
    JSR sub_DDC9_blink_power_pellet_tiles
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Handle transition when death animation reaches terminal frame
bra_CC7F_finish_death_anim_phase:		; was: bra_CC7F
    LDA ram_flag_demo
    BNE bra_CCBF_bootstrap_title_after_game_over
    DEC ram_lives_p1
    BNE bra_CC94_prepare_next_spawn_alias
    LDA #$00
    STA ram_0087
    STA ram_0069
    LDA #con_script_0A
    STA ram_script
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Branch alias into next-spawn preparation block
bra_CC94_prepare_next_spawn_alias:		; was: bra_CC94
; Prepare next spawn/player handoff after death
loc_CC94_prepare_next_spawn:		; was: loc_CC94
    LDA #con_script_00
    STA ram_script
    LDA #$01
    STA ram_0069
    LDA ram_game_mode
    BEQ bra_CCA4_check_p1_lives_after_death
    LDA ram_lives_p2
    BNE bra_CCCA_swap_state_and_switch_player
; Check P1 lives after handling P2/coop branch
bra_CCA4_check_p1_lives_after_death:		; was: bra_CCA4
    LDA ram_lives_p1
    BNE bra_CCE3_return_gameplay_dispatch
    STA ram_0069
    LDA ram_current_player
    BEQ bra_CCBF_bootstrap_title_after_game_over
; Swap P1/P2 16-byte runtime blocks via ram_0000 temp
    LDX #$0F
; Swap P1/P2 state blocks before reset path
bra_CCB0_swap_player_state_blocks_first_path:		; was: bra_CCB0_loop
    LDA ram_data_p1,X
    STA ram_0000
    LDA ram_data_p2,X
    STA ram_data_p1,X
    LDA ram_0000
    STA ram_data_p2,X
    DEX
    BPL bra_CCB0_swap_player_state_blocks_first_path
; Bootstrap after game-over/no-lives path
bra_CCBF_bootstrap_title_after_game_over:		; was: bra_CCBF
    LDA #$00
    STA ram_current_player
    LDA #con_script_00
    STA ram_script
    JMP loc_C168_main_frame_bootstrap
; Swap player state and switch active player for next spawn
bra_CCCA_swap_state_and_switch_player:		; was: bra_CCCA
; Duplicate swap logic for alternate handoff path (same as block at 00:CCAE)
    LDX #$0F
; Swap P1/P2 state blocks before player handoff
bra_CCCC_swap_player_state_blocks_second_path:		; was: bra_CCCC_loop
    LDA ram_data_p1,X
    STA ram_0000
    LDA ram_data_p2,X
    STA ram_data_p1,X
    LDA ram_0000
    STA ram_data_p2,X
    DEX
    BPL bra_CCCC_swap_player_state_blocks_second_path
    INC ram_current_player
    LDA ram_current_player
    AND #$01
    STA ram_current_player
; Return to gameplay dispatcher from death handler
bra_CCE3_return_gameplay_dispatch:		; was: bra_CCE3
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Script 0C: stage clear flash + gate into intermission script when needed
ofs_003_CCE6_script0C_stage_clear:		; was: ofs_003_CCE6_0C
    LDA ram_0087
    BNE bra_CCFB_stage_clear_flash_tick
    LDX #$00
; Clear actor slots at stage-clear script start
bra_CCEC_clear_actor_slots:		; was: bra_CCEC_loop
    STA ram_obj_position + $04,X
    INX
    CPX #$14
    BNE bra_CCEC_clear_actor_slots
    INC ram_0087
    LDA #$01
    STA ram_animation
    BNE bra_CD50_stage_clear_tail_entry    ; jmp
; Stage-clear periodic flash tick path
bra_CCFB_stage_clear_flash_tick:		; was: bra_CCFB
    LDA ram_frame_cnt
    AND #$07
    BNE bra_CD50_stage_clear_tail_entry
    LDX #$00
    LDA ram_0087
    AND #$01
    BNE bra_CD0B_flash_packet_copy_entry
    LDX #$04
; Entry before copying flash PPU packet
bra_CD0B_flash_packet_copy_entry:		; was: bra_CD0B
    LDY #$03
; Copy 4-byte flash command packet into PPU buffer reversed index
bra_CD0D_copy_flash_packet_reversed:		; was: bra_CD0D_loop
    LDA tbl_CD59_stage_clear_flash_cmd,X
    STA ram_ppu_buffer_main,Y
    INX
    DEY
    BPL bra_CD0D_copy_flash_packet_reversed
    INC ram_0087
    LDA #$10
    CMP ram_0087
    BNE bra_CD50_stage_clear_tail_entry
    LDA #$00
    STA ram_obj_pos_X_hi
    STA ram_obj_pos_Y_hi
    STA ram_0087
    LDA ram_stage_p1
    CMP #$01
    BEQ bra_CD45_start_intermission_script
    INC ram_0087
    INC ram_0087
    CMP #$04
    BEQ bra_CD45_start_intermission_script
    INC ram_0087
    INC ram_0087
    CMP #$08
    BEQ bra_CD45_start_intermission_script
    CMP #$0C
    BEQ bra_CD45_start_intermission_script
    CMP #$10
    BNE bra_CD4C_start_next_round_script
; Switch to intermission script when stage threshold reached
bra_CD45_start_intermission_script:		; was: bra_CD45
    LDA #con_script_0E
    STA ram_script
    JMP loc_CD50_stage_clear_tail
; Switch to normal round-init script when no intermission
bra_CD4C_start_next_round_script:		; was: bra_CD4C
    LDA #con_script_00
    STA ram_script
; Direct branch into shared stage-clear tail
bra_CD50_stage_clear_tail_entry:		; was: bra_CD50
; Shared tail for stage-clear flow
loc_CD50_stage_clear_tail:		; was: loc_CD50
    JSR sub_DDC9_blink_power_pellet_tiles
    JSR sub_D9AB_prepare_sprite_positions
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; PPU commands for stage-clear flash effect
tbl_CD59_stage_clear_flash_cmd:		; was: tbl_CD59
    .byte $FF, $11, $05, $3F   ; 00
    .byte $FF, $20, $05, $3F   ; 04



; Script 0A: GAME OVER text flow + timeout to restart/bootstrap
ofs_003_CD61_script0A_game_over:		; was: ofs_003_CD61_0A
    LDA ram_0087
    BEQ bra_CD68_build_game_over_sprites
    JMP loc_CDEC_game_over_tick
; Build GAME OVER sprite text when entering script
bra_CD68_build_game_over_sprites:		; was: bra_CD68
    LDY #$00
    LDA #$FF
; Clear OAM head area before drawing GAME OVER
bra_CD6C_clear_oam_head:		; was: bra_CD6C_loop
; 0700-075F
    STA ram_oam,Y
    INY
    CPY #$60
    BNE bra_CD6C_clear_oam_head
    LDA #< (ram_oam + $60)
    STA ram_0000
    LDA #> (ram_oam + $60)
    STA ram_0001
    LDA #$03
    STA ram_0004
    LDY #$00
    STY ram_0005
    STY ram_0006
    STY ram_0007
; Build next GAME OVER sprite group
bra_CD88_build_next_game_over_group:		; was: bra_CD88_loop
    LDX ram_0006
    LDA tbl_CE29_game_over_sprite_positions,X
    STA ram_0002    ; spr_X
    LDA tbl_CE29_game_over_sprite_positions + $01,X
    STA ram_0003    ; spr_Y
    LDX ram_0007
    LDA tbl_CE31_game_over_group_sizes,X
    STA ram_0008    ; spr counter
; Emit one GAME OVER sprite group into OAM
bra_CD9B_emit_game_over_group_sprites:		; was: bra_CD9B_loop
    LDA ram_0003    ; spr_Y
    STA (ram_0000),Y    ; 0760-07A0 (spr_Y)
    LDX ram_0005
    LDA tbl_CE01_game_over_sprite_tiles,X
    INY
    STA (ram_0000),Y    ; 0761-07A1 (spr_T)
    LDA tbl_CE15_game_over_sprite_attrs,X
    INY
    STA (ram_0000),Y    ; 0762-07A2 (spr_A)
    LDA ram_0002    ; spr_X
    INY
    STA (ram_0000),Y    ; 0763-07A3 (spr_X)
    LDA ram_0002    ; spr_X
    CLC
    ADC #$08
    STA ram_0002    ; spr_X
    INY
    INC ram_0005
    DEC ram_0008    ; spr counter
    BNE bra_CD9B_emit_game_over_group_sprites
    INC ram_0006
    INC ram_0006
    INC ram_0007
    LDA ram_game_mode
    BEQ bra_CDD4_advance_game_over_group_counter
    LDA ram_lives_p2
    BNE bra_CDD4_advance_game_over_group_counter
    LDA ram_0004
    CMP #$02
    BEQ bra_CDEC_game_over_tick_entry
; Advance GAME OVER group counter
bra_CDD4_advance_game_over_group_counter:		; was: bra_CDD4
    DEC ram_0004
    BEQ bra_CDDC_check_two_player_game_over_layout
    BPL bra_CD88_build_next_game_over_group
    BMI bra_CDEC_game_over_tick_entry    ; jmp
; Adjust GAME OVER layout for two-player context
bra_CDDC_check_two_player_game_over_layout:		; was: bra_CDDC
    LDA ram_game_mode
    BEQ bra_CDEC_game_over_tick_entry
    LDA ram_current_player
    BEQ bra_CD88_build_next_game_over_group
    INC ram_0005
    INC ram_0005
    INC ram_0005
    BNE bra_CD88_build_next_game_over_group   ; jmp
; Entry alias for game-over timer tick routine
bra_CDEC_game_over_tick_entry:		; was: bra_CDEC
; Game-over timer tick and exit
loc_CDEC_game_over_tick:		; was: loc_CDEC
    INC ram_0087
    BNE bra_CDFE_return_gameplay_dispatch
    LDA #$00
    TAY
; Clear OAM tail before respawn/title bootstrap
bra_CDF3_clear_oam_tail:		; was: bra_CDF3_loop
; 0760-07FF
    STA ram_oam + $60,Y
    INY
    CPY #$A0
    BNE bra_CDF3_clear_oam_tail
    JMP loc_CC94_prepare_next_spawn
; Return to gameplay dispatcher during game-over timeout
bra_CDFE_return_gameplay_dispatch:		; was: bra_CDFE
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Sprite tiles for GAME OVER text
tbl_CE01_game_over_sprite_tiles:		; was: tbl_CE01_spr_T
    .byte $BC   ; 00
    .byte $B2   ; 01
    .byte $BD   ; 02
    .byte $B4   ; 03
    .byte $B6   ; 04
    .byte $BE   ; 05
    .byte $B4   ; 06
    .byte $B5   ; 07
    .byte $B0   ; 08
    .byte $B1   ; 09
    .byte $B2   ; 0A
    .byte $B3   ; 0B
    .byte $B4   ; 0C
    .byte $B5   ; 0D
    .byte $B6   ; 0E
    .byte $B7   ; 0F
    .byte $B4   ; 10
    .byte $B8   ; 11
    .byte $B9   ; 12
    .byte $B6   ; 13



; Sprite attributes for GAME OVER text
tbl_CE15_game_over_sprite_attrs:		; was: tbl_CE15_spr_A
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $00   ; 03
    .byte $00   ; 04
    .byte $00   ; 05
    .byte $00   ; 06
    .byte $00   ; 07
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
    .byte $02   ; 12
    .byte $02   ; 13



; Base positions for GAME OVER sprite groups
tbl_CE29_game_over_sprite_positions:		; was: tbl_CE29_spr_pos
; X, Y
    .byte $38, $88   ; 00
    .byte $60, $88   ; 02
    .byte $44, $60   ; 04
    .byte $50, $70   ; 06



; Sprite group sizes for GAME OVER text builder
tbl_CE31_game_over_group_sizes:		; was: tbl_CE31_spr_counter
    .byte $04   ; 00
    .byte $04   ; 01
    .byte $06   ; 02
    .byte $03   ; 03



; Script 00: round initialization
; Loads level parameter blocks (speed/release/fright settings), resets runtime state,
; uploads palette/maze/HUD, and prepares first READY script.
ofs_003_CE35_script00_round_init:		; was: ofs_003_CE35_00
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI before applying round init PPU writes
bra_CE39_wait_nmi:		; was: bra_CE39_infinite_loop
    LDA ram_nmi_wait
    BNE bra_CE39_wait_nmi
    LDA #$08
    STA $2000
    STA ram_for_2000
    LDA #$00
    STA $2001
    LDX #$00
; Clear runtime RAM block 0087-00EF
bra_CE4B_clear_runtime_block:		; was: bra_CE4B_loop
; 0087-00EF
    STA ram_0087,X
    INX
    CPX #$69
    BNE bra_CE4B_clear_runtime_block
    TAX
; Clear full OAM shadow
bra_CE53_clear_oam_all:		; was: bra_CE53_loop
; 0700-07FF
    STA ram_oam,X
    INX
    BNE bra_CE53_clear_oam_all
    LDA $2002
    LDA #> $3F00
    STA $2006
    LDA #< $3F00
    STA $2006
    LDY #$00
; Upload gameplay palette
bra_CE68_upload_round_palette:		; was: bra_CE68_loop
    LDA tbl_D060_round_gameplay_palette,Y
    STA $2007
    INY
    CPY #$20
    BNE bra_CE68_upload_round_palette
    LDA #con_script_02
    STA ram_script
    LDA ram_0069
    BNE bra_CE99_common_round_init_tail
    STA ram_008B
    LDA #con_tile + $01
    STA ram_power_pellet_tile_p1
    STA ram_power_pellet_tile_p1 + $01
    STA ram_power_pellet_tile_p1 + $02
    STA ram_power_pellet_tile_p1 + $03
    LDA #$C0
    STA ram_pellet_cnt_p1
    LDA ram_stage_p1
    CMP #$16
    BEQ bra_CE93_after_stage_increment_check
    INC ram_stage_p1
; Continue round init after stage cap/increment check
bra_CE93_after_stage_increment_check:		; was: bra_CE93
    JSR sub_D080_fill_maze_attr_tables
    JSR sub_E25C_decompress_and_upload_maze_layout
; Shared round-init tail (runs for fresh round and respawn)
bra_CE99_common_round_init_tail:		; was: bra_CE99
    JSR sub_E379_draw_score_hud_live
    JSR sub_CFFA_fill_center_strip_tiles
    JSR sub_E4CD_draw_lives_icons
    JSR sub_E53B_draw_stage_fruit_history
    JSR sub_E47C_upload_hud_text_blocks
    LDX ram_stage_p1
    LDA #$00
    CLC
; Stage-profile stream drives level behavior tables:
; speed/fright timers, dot-release thresholds, and ghost-release targets.
; Compute stage-based offset into level parameter table (step 6)
bra_CEAD_calc_stage_table_offset:		; was: bra_CEAD_loop
    DEX
    BMI bra_CEB4_stage_offset_ready
    ADC #$06
    BNE bra_CEAD_calc_stage_table_offset
; Stage table offset prepared in ram_0000
bra_CEB4_stage_offset_ready:		; was: bra_CEB4
    STA ram_0000
    TAX
    LDA tbl_EB42_stage_param_index_stream,X
    TAX
    LDA #$00
    CLC
; Convert maze/layout index into parameter block offset (step 0x16)
bra_CEBE_calc_param_block_offset:		; was: bra_CEBE_loop
    DEX
    BMI bra_CEC5_param_block_base_ready
    ADC #$16
    BNE bra_CEBE_calc_param_block_offset
; Parameter block base offset ready in Y
bra_CEC5_param_block_base_ready:		; was: bra_CEC5
    TAY
    LDX #$00
; Copy level parameter block to runtime RAM 009F..00B4
bra_CEC8_copy_level_param_block:		; was: bra_CEC8_loop
    LDA tbl_EBCC_level_param_blocks_22bytes,Y
    STA ram_009F,X
    INX
    INY
    CPX #$16
    BNE bra_CEC8_copy_level_param_block
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    ASL
    ASL
    TAX
    LDY #$00
    STY ram_00D0
    LDA tbl_EC3A_speed_timer_blocks_8bytes,X
    STA ram_00CF
; Copy 8-byte timer/speed block to runtime RAM 0097..009E
bra_CEE5_copy_timer_block:		; was: bra_CEE5_loop
    LDA tbl_EC3A_speed_timer_blocks_8bytes,X
    STA ram_0097,Y
    INX
    INY
    CPY #$08
    BNE bra_CEE5_copy_timer_block
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_008C
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    TAX
    LDA tbl_EC5A_dot_counter_threshold_pairs,X
    STA ram_008D
    INX
    LDA tbl_EC5A_dot_counter_threshold_pairs,X
    STA ram_008E
    INC ram_0000
    LDA ram_0069
    BEQ bra_CF38_load_release_targets_from_table
    LDX #$0C
    LDY #$00
    LDA tbl_EC74_release_target_special_case_quad - $0C,X
    STA ram_008F,Y
    INY
    INX
    LDA #$C0
    SEC
    SBC ram_pellet_cnt_p1
    STA ram_0001
; Adjust release target counters based on pellets already eaten
bra_CF27_adjust_release_targets_by_pellets:		; was: bra_CF27_loop
    LDA ram_0001
    CLC
    ADC tbl_EC74_release_target_special_case_quad - $0C,X
    STA ram_008F,Y
    INY
    INX
    CPY #$04
    BNE bra_CF27_adjust_release_targets_by_pellets
    BEQ bra_CF4E_init_ghost_release_state    ; jmp
; Load default release target counters from table
bra_CF38_load_release_targets_from_table:		; was: bra_CF38
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    ASL
    TAX
    LDY #$00
; Copy 4-byte release target set to RAM 008F..0092
bra_CF42_copy_release_target_quad:		; was: bra_CF42_loop
    LDA tbl_EC68_ghost_release_target_quads,X
    STA ram_008F,Y
    INX
    INY
    CPY #$04
    BNE bra_CF42_copy_release_target_quad
; Initialize ghost release scheduler state
bra_CF4E_init_ghost_release_state:		; was: bra_CF4E
    LDA #$04
    STA ram_00B8
    LDA #$01
    STA ram_00B9
    LDA ram_008F
    STA ram_0001
    LDX #$00
; Fill active portion of release queue/state pairs
bra_CF5C_fill_release_queue_active:		; was: bra_CF5C_loop
    DEC ram_0001
    BEQ bra_CF6C_release_queue_tail_start
    LDA #$02
    STA ram_00BA,X
    LDA #$00
    STA ram_00BB,X
    INX
    INX
    BNE bra_CF5C_fill_release_queue_active
; Switch to clearing remaining release queue entries
bra_CF6C_release_queue_tail_start:		; was: bra_CF6C
    LDA #$00
; Clear remaining release queue/state pairs
bra_CF6E_clear_release_queue_tail:		; was: bra_CF6E_loop
    CPX #$06
    BEQ bra_CF7A_finalize_round_runtime
    STA ram_00BA,X
    STA ram_00BB,X
    INX
    INX
    BNE bra_CF6E_clear_release_queue_tail
; Finalize runtime fields after table copies
bra_CF7A_finalize_round_runtime:		; was: bra_CF7A
    LDA ram_0090
    STA ram_00D3
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_0093
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_0096
    LDA ram_009F + $06
    STA ram_00B5
    LDA ram_009F + $07
    STA ram_00B6
    LDA ram_00AF
    STA ram_00C2 + $02
    STA ram_00C2 + $04
    STA ram_00C2 + $06
    STA ram_00CA
    LDA ram_00B0
    STA ram_00C3 + $02
    STA ram_00C3 + $04
    STA ram_00C3 + $06
    STA ram_00CB
    LDA #$01
    STA ram_direction_1
    STA ram_direction_2
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_CFBE_select_hud_packet
    LDY #$09
; Select HUD packet variant based on active player side
bra_CFBE_select_hud_packet:		; was: bra_CFBE
; Copy HUD PPU packet into RAM buffer
bra_CFBE_copy_hud_ppu_packet:		; was: bra_CFBE_loop
    LDA tbl_D04E_hud_ppu_packets_by_player,Y
    STA ram_ppu_buffer_hud,X
    INY
    INX
    CPX #$09
    BNE bra_CFBE_copy_hud_ppu_packet
    LDY #$00
; Copy default animation/sprite palette bytes
bra_CFCC_copy_anim_palette_defaults:		; was: bra_CFCC_loop
    LDA tbl_D042_round_init_anim_and_sprite_attr_defaults,Y
    STA ram_animation,Y     ; also ram_spr_pal
    INY
    CPY #$0C
    BNE bra_CFCC_copy_anim_palette_defaults
    LDY #$00
; Normalize blinking power pellet tile IDs for gameplay
bra_CFD9_normalize_power_pellet_tiles:		; was: bra_CFD9_loop
    LDA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
    CMP #con_tile + $02
    BNE bra_CFE5_next_power_pellet_slot
    LDA #con_tile + $01
    STA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
; Advance to next power-pellet tile slot
bra_CFE5_next_power_pellet_slot:		; was: bra_CFE5
    INY
    CPY #$04
    BNE bra_CFD9_normalize_power_pellet_tiles
    STY ram_00C0
    LDA #$FF
    STA ram_0089
    LDA #$88
    STA $2000
    STA ram_for_2000
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Fill a center nametable strip (spaces + separator tiles) used during round setup
sub_CFFA_fill_center_strip_tiles:		; was: sub_CFFA
    LDY #$22    ; 2256
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_D004_center_strip_addr_ready
    LDY #$2A    ; 2A56
; Center-strip base nametable address selected
bra_D004_center_strip_addr_ready:		; was: bra_D004
    STY ram_0000
    LDA #$56
    STA ram_0001
    LDA #$0A    ; counter
    STA ram_0002
; Iterate rows while filling center strip tiles
bra_D00E_fill_center_strip_rows:		; was: bra_D00E_loop
    LDA $2002
    LDA ram_0000
    STA $2006
    LDA ram_0001
    STA $2006
    LDA #$06    ; counter
    STA ram_0003
    LDA #con_tile + $20
; Write one row segment of center-strip tiles
bra_D021_fill_center_strip_row_tiles:		; was: bra_D021_loop
    STA $2007
    DEC ram_0003
    BNE bra_D021_fill_center_strip_row_tiles
    LDA #con_tile + $2D
    STA $2007
    STA $2007
    LDA ram_0001
    CLC
    ADC #< $0020
    STA ram_0001
    LDA ram_0000
    ADC #> $0020
    STA ram_0000
    DEC ram_0002
    BNE bra_D00E_fill_center_strip_rows
    RTS



; Default animation and sprite-attr bytes loaded at round start
; Default animation IDs + sprite attribute bytes copied to RAM 0032..003D
tbl_D042_round_init_anim_and_sprite_attr_defaults:		; was: tbl_D042_spr_data
; animation
    .byte $04   ; 00
    .byte $0C   ; 01
    .byte $0A   ; 02
    .byte $0A   ; 03
    .byte $0A   ; 04
    .byte $00   ; 05
; spr_A
    .byte $00   ; 06
    .byte $00   ; 07
    .byte $01   ; 08
    .byte $02   ; 09
    .byte $03   ; 0A
    .byte $00   ; 0B



; HUD PPU packet templates for left/right player sides
; HUD PPU packet templates for left-side (P1) and right-side (P2) layouts
tbl_D04E_hud_ppu_packets_by_player:		; was: tbl_D04E_ppu
; 00
    .dbyt $2136 ; ram_ppu_buf_score

    .dbyt $20F7 ; ram_ppu_buffer_1up
    .byte $B0, $B3, $B2   ; 1UP

    .dbyt $20B6 ; ram_ppu_buf_hiscore


; 09
    .dbyt $29B6 ; ram_ppu_buf_score

    .dbyt $2977 ; ram_ppu_buffer_1up
    .byte $B1, $B3, $B2   ; 2UP

    .dbyt $28B6 ; ram_ppu_buf_hiscore



; 32-byte gameplay palette uploaded during round init
; 32-byte gameplay palette (BG + SPR) uploaded at round initialization
tbl_D060_round_gameplay_palette:		; was: tbl_D060_palette
; background
    .incbin "assets/generated/palettes/round.bin", $0, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $4, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $8, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $C, $4  ; rom-asset .byte
; sprites
    .incbin "assets/generated/palettes/round.bin", $10, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $14, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $18, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $1C, $4  ; rom-asset .byte
; Write maze attribute bytes into both gameplay nametables
sub_D080_fill_maze_attr_tables:		; was: sub_D080
    LDA $2002
    LDA #> $23C0
    STA $2006
    LDA #< $23C0
    STA $2006
    LDX #$01
; Run two passes: first nametable $23C0, then $2BC0
bra_D08F_attr_table_pass_loop:		; was: bra_D08F
    LDY #$00
; Copy 0x40 attribute bytes to current nametable
bra_D091_copy_attr_block_loop:		; was: bra_D091_loop
    LDA tbl_D0AF_maze_attribute_bytes,Y
    STA $2007
    INY
    CPY #$40
    BNE bra_D091_copy_attr_block_loop
    DEX
    BEQ bra_D0A0_select_second_attr_table
    RTS
; Switch PPU address to second nametable attribute block
bra_D0A0_select_second_attr_table:		; was: bra_D0A0
    LDA $2002
    LDA #> $2BC0
    STA $2006
    LDA #< $2BC0
    STA $2006
    BNE bra_D08F_attr_table_pass_loop    ; jmp



; Maze attribute byte pattern for gameplay background
tbl_D0AF_maze_attribute_bytes:		; was: tbl_D0AF_bg_attr
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $51, $50, $50
    .byte $55, $55, $55, $55, $55, $11, $05, $05, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55