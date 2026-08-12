; Post-eat pause, death, stage-clear, and game-over scripts

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
    LoadPointer ram_0000, (ram_oam + $60)
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
