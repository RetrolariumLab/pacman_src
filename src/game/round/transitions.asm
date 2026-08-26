; Post-eat pause, death, stage-clear, and game-over scripts

; Advance the eaten-ghost popup freeze
; Input: one ghost remains in con_ghost_state_eaten_score
; Side effects: returns that ghost as con_ghost_state_returning_eyes when the
; timer expires; otherwise runs only the restricted freeze-frame update set
handler_script06_post_eat_pause:
    INC ram_post_eat_pause_timer
    LDA #$28
    CMP ram_post_eat_pause_timer
    BNE bra_run_post_eat_updates
    LDA #$02
    STA ram_post_eat_pause_timer
    LDA #con_game_script_pause
    STA ram_script
    LDA #con_ghost_state_eaten_score
    LDX #$FE
; Find ghost slot matching post-eat state marker
bra_find_matching_ghost_state_slot:
    INX
    INX
    CMP ram_ghost_state,X
    BNE bra_find_matching_ghost_state_slot
    LDA #con_ghost_state_returning_eyes
    STA ram_ghost_state,X
; Continue post-eat freeze updates
bra_run_post_eat_updates:
    JSR sub_blink_power_pellet_tiles
    JSR sub_update_ghost_slots_state06_only
    JSR sub_update_ghost_anim_frames
    JSR sub_prepare_sprite_positions
    JMP loc_gameplay_mainloop_wait_nmi

; Script 08: Pac-Man death sequence + life decrement / handoff logic
; Advances death animation, decrements lives, and selects respawn, player
; handoff, game over, or title bootstrap. ram_shared_state_0 owns the phase
; Returns through the gameplay NMI loop unless control transfers to bootstrap
handler_script08_death_sequence:
    LDA ram_shared_state_0
    BNE bra_run_death_anim_phase
    DEC ram_death_anim_timer
    BNE bra_run_pre_death_frame_updates
    INC ram_shared_state_0
    LDA #$0A
    STA ram_death_anim_timer
    STA ram_sfx_death
    LDA #$00
    TAX
; Clear actor slots at death-sequence start
bra_clear_actor_slots_for_death:
    STA ram_obj_position + $04,X
    INX
    CPX #$14
    BNE bra_clear_actor_slots_for_death
; Death sequence pre-animation update frame
bra_run_pre_death_frame_updates:
    JSR sub_blink_power_pellet_tiles
    JSR sub_update_ghost_anim_frames
    JSR sub_prepare_sprite_positions
    JMP loc_gameplay_mainloop_wait_nmi
; Death sequence phase with animation stepping
bra_run_death_anim_phase:
    DEC ram_death_anim_timer
    BPL bra_wait_next_death_anim_step
    LDA #$0A
    STA ram_death_anim_timer
    LDA ram_animation
    CLC
    ADC #$01
    STA ram_animation
    CMP #$1E
    BEQ bra_finish_death_anim_phase
; Wait until next death animation step timer
bra_wait_next_death_anim_step:
    JSR sub_blink_power_pellet_tiles
    JSR sub_prepare_sprite_positions
    JMP loc_gameplay_mainloop_wait_nmi
; Handle transition when death animation reaches terminal frame
bra_finish_death_anim_phase:
    LDA ram_flag_demo
    BNE bra_bootstrap_title_after_game_over
    DEC ram_lives_p1
    BNE bra_prepare_next_spawn_alias
    LDA #$00
    STA ram_shared_state_0
    STA ram_round_restart_flag
    LDA #con_game_script_game_over
    STA ram_script
    JMP loc_gameplay_mainloop_wait_nmi
; Branch alias into next-spawn preparation block
bra_prepare_next_spawn_alias:
; Prepare next spawn/player handoff after death
loc_prepare_next_spawn:
    LDA #con_game_script_round_init
    STA ram_script
    LDA #$01
    STA ram_round_restart_flag
    LDA ram_game_mode
    BEQ bra_check_p1_lives_after_death
    LDA ram_lives_p2
    BNE bra_swap_state_and_switch_player
; Check P1 lives after handling P2/coop branch
bra_check_p1_lives_after_death:
    LDA ram_lives_p1
    BNE bra_return_from_death_handler
    STA ram_round_restart_flag
    LDA ram_current_player
    BEQ bra_bootstrap_title_after_game_over
; Swap P1/P2 16-byte runtime blocks via zp_work0 temp
    LDX #$0F
; Swap P1/P2 state blocks before reset path
bra_swap_player_state_blocks_first_path:
    LDA ram_data_p1,X
    STA zp_work0
    LDA ram_data_p2,X
    STA ram_data_p1,X
    LDA zp_work0
    STA ram_data_p2,X
    DEX
    BPL bra_swap_player_state_blocks_first_path
; Bootstrap after game-over/no-lives path
bra_bootstrap_title_after_game_over:
    LDA #$00
    STA ram_current_player
    LDA #con_game_script_round_init
    STA ram_script
    JMP loc_main_frame_bootstrap
; Swap player state and switch active player for next spawn
bra_swap_state_and_switch_player:
; Duplicate swap logic for alternate handoff path (same as block at 00:CCAE)
    LDX #$0F
; Swap P1/P2 state blocks before player handoff
bra_swap_player_state_blocks_second_path:
    LDA ram_data_p1,X
    STA zp_work0
    LDA ram_data_p2,X
    STA ram_data_p1,X
    LDA zp_work0
    STA ram_data_p2,X
    DEX
    BPL bra_swap_player_state_blocks_second_path
    INC ram_current_player
    LDA ram_current_player
    AND #$01
    STA ram_current_player
; Return to gameplay dispatcher from death handler
bra_return_from_death_handler:
    JMP loc_gameplay_mainloop_wait_nmi

; Script 0C: stage clear flash + gate into intermission script when needed
; ram_shared_state_0 owns the flash phase and then the intermission scene ID
; Side effects: queues palette packets and selects round init or intermission
handler_script_0c_stage_clear:
    LDA ram_shared_state_0
    BNE bra_stage_clear_flash_tick
    LDX #$00
; Clear actor slots at stage-clear script start
bra_clear_actor_slots:
    STA ram_obj_position + $04,X
    INX
    CPX #$14
    BNE bra_clear_actor_slots
    INC ram_shared_state_0
    LDA #$01
    STA ram_animation
    BNE bra_stage_clear_tail_entry  ; jmp
; Stage-clear periodic flash tick path
bra_stage_clear_flash_tick:
    LDA ram_frame_cnt
    AND #$07
    BNE bra_stage_clear_tail_entry
.ifdef PACMAN_REVISION_RAM_PALETTES
    LDX #$11
    LDA ram_shared_state_0
    AND #$01
    BNE bra_apply_tengen_stage_flash
    LDX #$20
bra_apply_tengen_stage_flash:
    STX ram_bg_palette_update + $05
    LDA #$0F
    STA ram_bg_palette_update
.else
    LDX #$00
    LDA ram_shared_state_0
    AND #$01
    BNE bra_flash_packet_copy_entry
    LDX #$04
; Entry before copying flash PPU packet
bra_flash_packet_copy_entry:
    LDY #$03
; Copy 4-byte flash command packet into PPU buffer reversed index
bra_copy_flash_packet_reversed:
    LDA tbl_stage_clear_flash_cmd,X
    STA ram_ppu_buffer_main,Y
    INX
    DEY
    BPL bra_copy_flash_packet_reversed
.endif
    INC ram_shared_state_0
    LDA #$10
    CMP ram_shared_state_0
    BNE bra_stage_clear_tail_entry
    LDA #$00
    STA ram_obj_pos_X_hi
    STA ram_obj_pos_Y_hi
    STA ram_shared_state_0
    LDA ram_stage_p1
    CMP #$01
    BEQ bra_start_intermission_script
    INC ram_shared_state_0
    INC ram_shared_state_0
    CMP #$04
    BEQ bra_start_intermission_script
    INC ram_shared_state_0
    INC ram_shared_state_0
    CMP #$08
    BEQ bra_start_intermission_script
    CMP #$0C
    BEQ bra_start_intermission_script
    CMP #$10
    BNE bra_start_next_round_script
; Switch to intermission script when stage threshold reached
bra_start_intermission_script:
    LDA #con_game_script_intermission_setup
    STA ram_script
    JMP loc_stage_clear_tail
; Switch to normal round-init script when no intermission
bra_start_next_round_script:
    LDA #con_game_script_round_init
    STA ram_script
; Direct branch into shared stage-clear tail
bra_stage_clear_tail_entry:
; Shared tail for stage-clear flow
loc_stage_clear_tail:
    JSR sub_blink_power_pellet_tiles
    JSR sub_prepare_sprite_positions
    JMP loc_gameplay_mainloop_wait_nmi

; PPU commands for stage-clear flash effect
.ifndef PACMAN_REVISION_RAM_PALETTES
tbl_stage_clear_flash_cmd:
    .byte $FF, $11, $05, $3F  ; 00
    .byte $FF, $20, $05, $3F  ; 04
.endif

; Script 0A: GAME OVER text flow + timeout to restart/bootstrap
; Composes GAME OVER sprites on entry, then advances the wrapping timeout in
; ram_shared_state_0. On expiry, tail-jumps into the shared exit decision path
handler_script_0a_game_over:
    LDA ram_shared_state_0
    BEQ bra_build_game_over_sprites
    JMP loc_game_over_tick
; Build GAME OVER sprite text when entering script
bra_build_game_over_sprites:
    LDY #$00
    LDA #$FF
; Clear OAM head area before drawing GAME OVER
bra_clear_oam_head:
; 0700-075F
    STA ram_oam,Y
    INY
    CPY #$60
    BNE bra_clear_oam_head
    LoadPointer zp_work0, (ram_oam + $60)
    LDA #$03
    STA zp_work4
    LDY #$00
    STY zp_work5
    STY zp_work6
    STY zp_work7
; Build next GAME OVER sprite group
bra_build_next_game_over_group:
    LDX zp_work6
    LDA tbl_game_over_sprite_positions,X
    STA zp_work2  ; spr_X
    LDA tbl_game_over_sprite_positions + $01,X
    STA zp_work3  ; spr_Y
    LDX zp_work7
    LDA tbl_game_over_group_sizes,X
    STA zp_work8  ; spr counter
; Emit one GAME OVER sprite group into OAM
bra_emit_game_over_group_sprites:
    LDA zp_work3  ; spr_Y
    STA (zp_work0),Y  ; 0760-07A0 (spr_Y)
    LDX zp_work5
    LDA tbl_game_over_sprite_tiles,X
    INY
    STA (zp_work0),Y  ; 0761-07A1 (spr_T)
    LDA tbl_game_over_sprite_attrs,X
    INY
    STA (zp_work0),Y  ; 0762-07A2 (spr_A)
    LDA zp_work2  ; spr_X
    INY
    STA (zp_work0),Y  ; 0763-07A3 (spr_X)
    LDA zp_work2  ; spr_X
    CLC
    ADC #$08
    STA zp_work2  ; spr_X
    INY
    INC zp_work5
    DEC zp_work8  ; spr counter
    BNE bra_emit_game_over_group_sprites
    INC zp_work6
    INC zp_work6
    INC zp_work7
    LDA ram_game_mode
    BEQ bra_advance_game_over_group_counter
    LDA ram_lives_p2
    BNE bra_advance_game_over_group_counter
    LDA zp_work4
    CMP #$02
    BEQ bra_game_over_tick_entry
; Advance GAME OVER group counter
bra_advance_game_over_group_counter:
    DEC zp_work4
    BEQ bra_check_two_player_game_over_layout
    BPL bra_build_next_game_over_group
    BMI bra_game_over_tick_entry  ; jmp
; Adjust GAME OVER layout for two-player context
bra_check_two_player_game_over_layout:
    LDA ram_game_mode
    BEQ bra_game_over_tick_entry
    LDA ram_current_player
    BEQ bra_build_next_game_over_group
    INC zp_work5
    INC zp_work5
    INC zp_work5
    BNE bra_build_next_game_over_group  ; jmp
; Entry alias for game-over timer tick routine
bra_game_over_tick_entry:
; Game-over timer tick and exit
loc_game_over_tick:
    INC ram_shared_state_0
    BNE bra_return_from_game_over_timer
    LDA #$00
    TAY
; Clear OAM tail before respawn/title bootstrap
bra_clear_oam_tail:
; 0760-07FF
    STA ram_oam + $60,Y
    INY
    CPY #$A0
    BNE bra_clear_oam_tail
    JMP loc_prepare_next_spawn
; Return to gameplay dispatcher during game-over timeout
bra_return_from_game_over_timer:
    JMP loc_gameplay_mainloop_wait_nmi

; Sprite tiles for GAME OVER text
tbl_game_over_sprite_tiles:
    .byte $BC  ; 00
    .byte $B2  ; 01
    .byte $BD  ; 02
    .byte $B4  ; 03
    .byte $B6  ; 04
    .byte $BE  ; 05
    .byte $B4  ; 06
    .byte $B5  ; 07
    .byte $B0  ; 08
    .byte $B1  ; 09
    .byte $B2  ; 0A
    .byte $B3  ; 0B
    .byte $B4  ; 0C
    .byte $B5  ; 0D
    .byte $B6  ; 0E
    .byte $B7  ; 0F
    .byte $B4  ; 10
    .byte $B8  ; 11
    .byte $B9  ; 12
    .byte $B6  ; 13

; Sprite attributes for GAME OVER text
tbl_game_over_sprite_attrs:
    .byte $00  ; 00
    .byte $00  ; 01
    .byte $00  ; 02
    .byte $00  ; 03
    .byte $00  ; 04
    .byte $00  ; 05
    .byte $00  ; 06
    .byte $00  ; 07
    .byte $02  ; 08
    .byte $02  ; 09
    .byte $02  ; 0A
    .byte $02  ; 0B
    .byte $02  ; 0C
    .byte $02  ; 0D
    .byte $02  ; 0E
    .byte $02  ; 0F
    .byte $02  ; 10
    .byte $02  ; 11
    .byte $02  ; 12
    .byte $02  ; 13

; Base positions for GAME OVER sprite groups
tbl_game_over_sprite_positions:
; X, Y
    .byte $38, $88  ; 00
    .byte $60, $88  ; 02
    .byte $44, $60  ; 04
    .byte $50, $70  ; 06

; Sprite group sizes for GAME OVER text builder
tbl_game_over_group_sizes:
    .byte $04  ; 00
    .byte $04  ; 01
    .byte $06  ; 02
    .byte $03  ; 03

; Script 00: round initialization
; Loads level parameter blocks (speed/release/fright settings), resets runtime state,
; uploads palette/maze/HUD, and prepares first READY script
