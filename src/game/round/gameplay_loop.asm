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
