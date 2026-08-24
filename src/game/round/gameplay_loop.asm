; Gameplay script core and round initialization

; ---------------------------------------------------------------------------
; GAMEPLAY SCRIPT CORE
; This is the main runtime loop used after leaving title/attract.
; Includes round init, pause, ready, collisions, death, stage clear, and game over.
; ---------------------------------------------------------------------------
; Enter gameplay session (demo or real game) and initialize runtime state.
; Inputs: ram_flag_demo and persistent game/high-score state.
; Side effects: resets script/player/pause state, clears display state, and
; enables the NMI-driven gameplay loop. Does not return.
loc_enter_gameplay_session:		; was: loc_C98A
    LDA #PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
; Wait for vblank set before disabling rendering during gameplay init
bra_wait_vblank_set:		; was: bra_C991_infinite_loop
    LDA PPUSTATUS
    BPL bra_wait_vblank_set
    LDA #con_game_script_round_init
    STA PPUMASK
    STA ram_script
    STA ram_current_player
    STA ram_round_restart_flag
    STA ram_flag_pause
    JSR sub_clear_bg_nametables_and_attrs
    JSR sub_upload_hud_text_blocks
    JSR sub_draw_score_hud_live
    LDA ram_flag_demo
    BEQ bra_init_non_demo_player_state
    LDA #$01
    STA ram_lives_p1
    BNE bra_reset_stage_counters    ; jmp
; Initialize player state for non-demo session
bra_init_non_demo_player_state:		; was: bra_C9B6
    LDA #$00
    TAY
; Clear per-player runtime block RAM
bra_clear_player_runtime_block:		; was: bra_C9B9_loop
; 0067-0086
    STA ram_data_p1,Y
    INY
    CPY #$20
    BNE bra_clear_player_runtime_block
    LDA #$03
    STA ram_lives_p1
    STA ram_lives_p2
    STA ram_sfx_plr_ready
    STA ram_sfx_plr_ready + $01
; Reset stage/high-score related counters before loop
bra_reset_stage_counters:		; was: bra_C9CD
.ifdef PACMAN_HACK_START_STAGE
    .assert PACMAN_HACK_START_STAGE >= 1, error, "hack start stage must be at least 1"
    .assert PACMAN_HACK_START_STAGE <= 255, error, "hack start stage must fit one byte"
    LDA #(PACMAN_HACK_START_STAGE - 1)
.else
    LDA #$FF
.endif
    STA ram_stage_p1
    STA ram_stage_p2
    STA ram_ppu_buffer_hiscore
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA ram_ppuctrl_base
    STA PPUCTRL
; Main gameplay loop entry with NMI wait
loc_gameplay_mainloop_wait_nmi:		; was: loc_C9DD
; Gameplay loop per-frame tick
bra_loop_gameplay_tick:		; was: bra_C9DD_loop
    LDA #$01
    STA ram_nmi_wait
; Busy-wait until NMI handler clears flag
bra_wait_nmi_in_gameplay_loop:		; was: bra_C9E1_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi_in_gameplay_loop
    LDA ram_flag_demo
    BEQ bra_handle_script_delay
    LDA ram_btn_1p
    AND #con_btns_SS
    BEQ bra_handle_script_delay
    LDA #con_title_script_menu_idle
    STA ram_script
    JMP loc_main_frame_bootstrap
; Handle script delay countdown before dispatch
bra_handle_script_delay:		; was: bra_C9F6
    LDA ram_script_delay
    BEQ bra_dispatch_current_script
    DEC ram_script_delay
    BNE bra_loop_gameplay_tick
; Dispatch current gameplay script handler.
; Input: ram_script is an even byte offset into tbl_gameplay_script_handlers.
; Clobbers: A, Y, and ram_indirect_jmp. Tail-jumps to the selected handler.
bra_dispatch_current_script:		; was: bra_C9FE
; ram_script stores even-valued state IDs indexing tbl_gameplay_script_handlers
    LDY ram_script
    LDA tbl_gameplay_script_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_gameplay_script_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Main gameplay script handler table
tbl_gameplay_script_handlers:		; was: tbl_CA0D
    .word handler_script00_round_init        ; con_game_script_round_init
    .word handler_script02_round_ready       ; con_game_script_round_ready
    .word handler_script04_pause_handler     ; con_game_script_pause
    .word handler_script06_post_eat_pause    ; con_game_script_post_eat_pause
    .word handler_script08_death_sequence    ; con_game_script_death
    .word handler_script0A_game_over         ; con_game_script_game_over
    .word handler_script0C_stage_clear       ; con_game_script_stage_clear
    .word handler_script0E_intermission_setup ; con_game_script_intermission_setup
    .word handler_script10_intermission_runtime ; con_game_script_intermission_runtime

; Script 04: pause input gate and normal gameplay frame driver.
; Input: controller edge state, pause state, and live round state.
; Side effects: may toggle pause/SFX/PPU text; when unpaused, runs the ordered
; gameplay update chain. Returns only through the NMI wait loop.
handler_script04_pause_handler:		; was: ofs_003_CA1F_04
    LDA ram_sfx_pause_toggle
    BEQ bra_check_pause_start_edge
    JMP loc_gameplay_mainloop_wait_nmi
; Check Start button edge for pause toggle
bra_check_pause_start_edge:		; was: bra_CA27
    LDA ram_btn_1p
    AND #con_btn_Start
    CMP ram_pause_start_latch
    BEQ bra_run_frame_when_no_new_start
    STA ram_pause_start_latch
    LDA ram_pause_start_latch
    BEQ bra_run_frame_when_no_new_start
    INC ram_flag_pause
    LDX #$22    ; 2237
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_store_pause_ppu_addr
    LDX #$2A    ; 2A37
; Store selected nametable address for PAUSE text packet
bra_store_pause_ppu_addr:		; was: bra_CA41
    STX ram_ppu_buffer_main
    LDA #$37
    STA ram_ppu_buffer_main + $01
    LDX #con_score_field_size
    LDY #$00
    LDA ram_flag_pause
    AND #$01
    BEQ bra_select_pause_text_variant
    LDX #$00
    STA ram_sfx_pause_toggle
; Select PAUSE text or blanks based on pause state
bra_select_pause_text_variant:		; was: bra_CA58
; Copy pause/on-off tile sequence into PPU packet
bra_copy_pause_tiles:		; was: bra_CA58_loop
.ifdef PACMAN_EXPANDED_SCREENS
    LDA tbl_expanded_pause_tiles,X
.else
    LDA tbl_pause_text_tiles,X
.endif
    STA ram_ppu_buffer_main + con_ppu_command_address_size,Y
    INX
    INY
    CPY #con_score_field_size
    BNE bra_copy_pause_tiles
    JMP loc_gameplay_mainloop_wait_nmi
; No new Start edge path for normal frame processing
bra_run_frame_when_no_new_start:		; was: bra_CA67
    LDA ram_flag_pause
    AND #$01
    BEQ bra_run_unpaused_gameplay_step
    JMP loc_gameplay_mainloop_wait_nmi
; Run gameplay update chain when not paused
bra_run_unpaused_gameplay_step:		; was: bra_CA70
.if PACMAN_REVISION = REVISION_EUROPE
; PAL Namco hides every shadow-OAM entry before rebuilding active sprites.
    LDA #> ram_oam
    STA zp_work1
    LDA #< ram_oam
    STA zp_work0
    TAY
    LDA #$EF
bra_hide_europe_oam_before_gameplay:
    STA (zp_work0),Y
    INY
    BNE bra_hide_europe_oam_before_gameplay
.endif
    JSR sub_update_round_timers_and_frightened
    JSR sub_check_for_eating_pellets
    JSR sub_update_pacman_movement
    JSR sub_update_pacman_anim_frame
    JSR sub_update_ghost_slots
    JSR sub_update_ghost_anim_frames
    JSR sub_update_ghost_house_counters
    JSR sub_blink_power_pellet_tiles
    JSR sub_check_actor_collisions
    JSR sub_prepare_sprite_positions
    JMP loc_gameplay_mainloop_wait_nmi

; Tile sequences for PAUSE on/off text
tbl_pause_text_tiles:		; was: tbl_CA91
    .byte $50, $41, $55, $53, $45, $FF   ; 00
    .byte $2D, $2D, $2D, $2D, $2D, $FF   ; 06

; Script 02: READY countdown + pre-control HUD/sprite setup
