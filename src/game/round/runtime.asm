; Round timers, release logic, fruit, and collisions

; ---------------------------------------------------------------------------
; LEVEL RUNTIME SYSTEMS
; Timers + release logic + collisions + movement
; These routines drive enemy behavior, power-up windows, fruit visibility, and scoring
; ---------------------------------------------------------------------------
; Runtime field legend used heavily below:
; ram_frightened_ghost_mask: frightened bitmask by ghost slot
; ram_frightened_seconds/ram_frightened_frame_counter: frightened countdown
; ram_scatter_chase_timer: active scatter/chase timer countdown
; ram_scatter_chase_phase/ram_scatter_chase_second_divider: phase index + per-second divider
; ram_personal_release_latch: persistent post-threshold phase/reversal gate
; ram_global_release_target: global dot-release target cursor
; ram_personal_release_stage: personal-release stage index
; ram_release_timer_seconds/ram_release_timer_ticks: release counters (seconds/subseconds)
; ram_fruit_timer_hi/ram_fruit_timer_lo: fruit visibility timer
; Advance the per-frame frightened, release, scatter/chase, and fruit timers

; Inputs: current round timer/state fields and terminated ram_ppu_buffer_main
; Outputs: none
; Side effects:
; - advances frightened state and queues palette blink/end packets
; - advances scatter/chase and ghost-release state, possibly reversing ghosts
; - decrements the fruit/popup timer and removes its sprite when it expires
; Clobbers: A, X, Y and zp_work0..zp_work4
sub_update_round_timers_and_frightened:  ; was: sub_D0EF
    LDA ram_frightened_seconds
    BMI bra_release_and_fruit_tick
    INC ram_frightened_frame_counter
    LDA #$3C
    CMP ram_frightened_frame_counter
    BNE bra_check_frightened_end_window
    LDA #$00
    STA ram_frightened_frame_counter
    DEC ram_frightened_seconds
    BPL bra_check_frightened_end_window
    STA ram_frightened_ghost_mask
    LDX #$00
; Apply palette phase bits to ghost sprite attributes
bra_apply_frightened_palette_phase:  ; was: bra_D107_loop
    LDA ram_spr_pal + $01,X
    AND #$FC
    STA zp_work0
    TXA
    ORA zp_work0
    STA ram_spr_pal + $01,X
    INX
    CPX #$04
    BNE bra_apply_frightened_palette_phase
; Handle final frightened blinking window
bra_check_frightened_end_window:  ; was: bra_D117
    LDA ram_frightened_seconds
    CMP #$02
    BCS bra_release_and_fruit_tick
.ifdef PACMAN_REVISION_RAM_PALETTES
    LDX #$11
    LDA ram_frightened_frame_counter
    AND #$08
    BNE bra_apply_tengen_frightened_palette
    LDX #$20
bra_apply_tengen_frightened_palette:
    STX ram_sprite_palette_update + $05
    LDA #$0F
    STA ram_sprite_palette_update
.else
    LDX #$00
    LDA ram_frightened_frame_counter
    AND #$08
    BNE bra_prepare_ppu_append_index
    LDX #$05
; Prepare insertion point in PPU command buffer
bra_prepare_ppu_append_index:  ; was: bra_D127
    LDY #$FF
; Scan PPU command buffer until end token
bra_find_ppu_terminator:  ; was: bra_D129_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #con_ppu_buffer_end
    BNE bra_find_ppu_terminator
    TYA
    BNE bra_append_frightened_cmd_if_empty
    INX
; Adjust source offset when appending frightened palette command
bra_append_frightened_cmd_if_empty:  ; was: bra_D135
; Copy frightened palette command sequence into PPU buffer
bra_copy_frightened_palette_cmd:  ; was: bra_D135_loop
    .ifdef PACMAN_EXPANDED_PALETTES
        LDA tbl_expanded_frightened_palette_cmd,X
    .else
        LDA tbl_frightened_palette_cmd,X
    .endif
    STA ram_ppu_buffer_main,Y
    INY
    INX
    CMP #con_ppu_buffer_end
    BNE bra_copy_frightened_palette_cmd
.endif
; Continue with release/fruit timers after frightened handling
bra_release_and_fruit_tick:  ; was: bra_D141
    LDA ram_frightened_ghost_mask
    BNE bra_check_global_release_target
    LDA ram_scatter_chase_timer
    CMP #$FF
    BEQ bra_check_global_release_target
    INC ram_scatter_chase_second_divider
    LDA ram_scatter_chase_second_divider
    CMP #$3C
    BNE bra_check_global_release_target
    LDA #$00
    STA ram_scatter_chase_second_divider
    DEC ram_scatter_chase_timer
    BPL bra_check_global_release_target
    INC ram_scatter_chase_phase
    LDA ram_scatter_chase_phase
    AND #$01
    BEQ bra_use_personal_release_latch
    JSR sub_try_reverse_ghost_directions
    LDA #$0F
    BNE bra_store_next_mode_mask  ; jmp
; Use the persistent post-threshold mode mask when the phase bit is even
bra_use_personal_release_latch:  ; was: bra_D16A
    LDA ram_personal_release_latch
; Store the selected chase/scatter mask, then load the phase countdown
bra_store_next_mode_mask:  ; was: bra_D16C
    STA ram_shared_state_0
    LDX ram_scatter_chase_phase
; 0098-009A
    LDA ram_scatter_chase_durations,X
    STA ram_scatter_chase_timer
; Check global dot target for forced ghost release
bra_check_global_release_target:  ; was: bra_D174
    LDA ram_global_release_target
    BEQ bra_release_counter_update_entry
    CLC
    ADC ram_pellet_cnt_p1
    CMP #$C0
    BNE bra_release_counter_update_entry
    JSR sub_queue_next_ghost_release
    LDA ram_global_release_target
    LDX #$00
; Find current release target slot and advance to next
bra_find_matching_release_target:  ; was: bra_D186_loop
    CMP ram_ghost_release_targets,X
    BNE bra_next_release_target_candidate
    INX
    LDA ram_ghost_release_targets,X
    STA ram_global_release_target
    JMP loc_update_release_counters
; Advance to next release target candidate
bra_next_release_target_candidate:  ; was: bra_D192
    INX
    CPX #$04
    BNE bra_find_matching_release_target
; Branch entry into shared release-counter update routine
bra_release_counter_update_entry:  ; was: bra_D197
; Update per-frame and per-wave release counters
loc_update_release_counters:  ; was: loc_D197
    INC ram_release_timer_ticks
    LDA #$60
    CMP ram_release_timer_ticks
    BNE bra_check_personal_release_targets
    LDA #$00
    STA ram_release_timer_ticks
    INC ram_release_timer_seconds
    LDA ram_release_timer_seconds
    CMP ram_release_interval_seconds
    BNE bra_check_personal_release_targets
    LDA #$00
    STA ram_release_timer_seconds
    JSR sub_queue_next_ghost_release
; Check per-ghost dot counters for personal release
bra_check_personal_release_targets:  ; was: bra_D1B2
    LDX ram_personal_release_stage
    CPX #$02
    BEQ bra_update_fruit_visibility_timer
    LDA ram_personal_release_thresholds,X
    CMP ram_pellet_cnt_p1
    BNE bra_update_fruit_visibility_timer
    INC ram_personal_release_stage
    LDA #$01
    STA ram_personal_release_latch
    TXA
    ASL
    TAX
    LDA ram_ghost0_normal_speed_fraction,X
    STA ram_ghost0_current_speed_fraction
    LDA ram_ghost0_normal_speed_pixels,X
    STA ram_ghost0_current_speed_pixels
; Tick fruit visibility timer and clear fruit when expired
bra_update_fruit_visibility_timer:  ; was: bra_D1CF
    ORA ram_fruit_timer_hi
    ORA ram_fruit_timer_lo
    BEQ bra_return_from_round_timer_update
    DEC ram_fruit_timer_lo
    BNE bra_return_from_round_timer_update
    LDA ram_fruit_timer_hi
    BEQ bra_hide_fruit_sprite
    DEC ram_fruit_timer_hi
    LDA #$3C
    STA ram_fruit_timer_lo
    RTS
; Hide the fruit/popup sprite and clear the eaten latch
bra_hide_fruit_sprite:  ; was: bra_D1E4
    STA ram_obj_pos_X_hi + $14
    STA ram_obj_pos_Y_hi + $14
    STA ram_fruit_eaten_latch
; Return from round timer update
bra_return_from_round_timer_update:  ; was: bra_D1EA_RTS
    RTS

; Reserve the next available house ghost for release
; Inputs: interleaved ghost state array for slots one through three
; Outputs: first in-house slot becomes con_ghost_state_exiting_house, if any
; Clobbers: A, X
sub_queue_next_ghost_release:  ; was: sub_D1EB
    LDX #$00
; Scan release slot pairs for an empty entry
bra_find_free_release_slot:  ; was: bra_D1ED_loop
    LDA ram_ghost_state + $02,X
    BNE bra_advance_release_slot
    LDA #con_ghost_state_exiting_house
    STA ram_ghost_state + $02,X
    RTS
; Advance to next release slot pair
bra_advance_release_slot:  ; was: bra_D1F6
    INX
    INX
    CPX #$06
    BNE bra_find_free_release_slot
    RTS

; !(UNUSED) No pointer or fall-through reaches this duplicate table. See DATA-001
    .byte $24, $25, $26, $27, $28, $29, $2A, $2B
; PPU command fragments for frightened palette writes
.ifndef PACMAN_REVISION_RAM_PALETTES
tbl_frightened_palette_cmd:  ; was: tbl_D205
; 00
    .byte $00
    .dbyt $3F15
    .byte $11
    .byte $FF  ; end token
; 05
    .byte $00
    .dbyt $3F15
    .byte $20
    .byte $FF  ; end token
.endif

; Check Pac-Man against the four ghost slots and the fruit slot

; Inputs:
; - Pac-Man and candidate world positions
; - ghost states and ram_frightened_ghost_mask
; - fruit availability state and ram_stage_param_index
; Outputs: none
; Side effects:
; - dangerous ghost: selects the death script and initializes death animation
; - frightened ghost: prepares the indexed 200/400/800/1600 transaction, popup,
; ghost state, SFX, and freeze script, then tail-jumps to the score commit
; - available fruit: prepares its stage-indexed transaction, popup timer, and SFX,
; then tail-jumps to the score commit
; Clobbers: A, X, Y and zp_work0..zp_work3
sub_check_actor_collisions:  ; was: sub_D20F
    LDA ram_pellet_cnt_p1
    BNE bra_init_collision_scan
    RTS
; Initialize collision scan pointers and masks
bra_init_collision_scan:  ; was: bra_D214
    LoadPointer zp_work0, (ram_obj_pos_X_hi + $04)
    LDA #$01
    STA zp_work2
    LDX #$00
; Iterate ghost/fruit collision candidate slots
bra_scan_collision_candidates:  ; was: bra_D222_loop
    LDA ram_ghost_state,X
    CMP #con_ghost_state_active
    BNE bra_advance_collision_candidate
    LDY #$00
    LDA ram_obj_pos_X_hi
    CMP (zp_work0),Y  ; 001E 0022 0026 002A 002E
    BCS bra_abs_dx_subtract_alt
    LDA (zp_work0),Y  ; 001E 0022 0026 002A 002E
    SEC
    SBC ram_obj_pos_X_hi
    BCS bra_check_dx_window
; Compute alternate X distance branch
bra_abs_dx_subtract_alt:  ; was: bra_D237
    SBC (zp_work0),Y  ; 001E 0022 0026 002A 002E
; Reject candidate when X distance is too large
bra_check_dx_window:  ; was: bra_D239
    CMP #$0A
    BCS bra_advance_collision_candidate
    STA zp_work3
    LDY #$02
    LDA ram_obj_pos_Y_hi
    CMP (zp_work0),Y  ; 0020 0024 0028 002C 0030
    BCS bra_abs_dy_subtract_alt
    LDA (zp_work0),Y  ; 0020 0024 0028 002C 0030
    SEC
    SBC ram_obj_pos_Y_hi
    BCS bra_check_dy_window
; Compute alternate Y distance branch
bra_abs_dy_subtract_alt:  ; was: bra_D24E
    SBC (zp_work0),Y  ; 0020 0024 0028 002C 0030
; Reject candidate when Y distance is too large
bra_check_dy_window:  ; was: bra_D250
    CMP #$0A
    BCS bra_advance_collision_candidate
    ADC zp_work3
    CMP #$05
    BCC bra_dispatch_collision_type
; Advance to next collision candidate
bra_advance_collision_candidate:  ; was: bra_D25A
    INX
    INX
    LDA zp_work0
    CLC
    ADC #con_actor_position_record_size
    STA zp_work0
    ASL zp_work2
    CPX #$0A
    BNE bra_scan_collision_candidates
    RTS
; Dispatch a confirmed overlap to ghost-eat, player-death, or fruit-eat handling
bra_dispatch_collision_type:  ; was: bra_D26A
    CPX #$08
    BEQ bra_handle_fruit_collision
    LDA zp_work2
    AND ram_frightened_ghost_mask
    BEQ bra_trigger_player_death
; Prepare the frightened-ghost award selected by ram_kill_cnt
bra_award_frightened_ghost:
    TXA
    LSR
    STA zp_work3
    LDY ram_kill_cnt
    LDA tbl_ghost_score_popup_tiles,Y
    LDY zp_work3
    STA ram_animation + $01,Y
    LDA #$00
    STA ram_animation
    LDY ram_kill_cnt
    LDA tbl_ghost_score_popup_lo,Y
    STA ram_pending_score_bcd + $01
    LDA tbl_ghost_score_popup_hi,Y
    STA ram_pending_score_bcd + $02
    INC ram_kill_cnt
    LDA #con_ghost_state_eaten_score
    STA ram_ghost_state,X
    STA ram_sfx_eat_ghost
    LDA #con_game_script_post_eat_pause
    STA ram_script
    JMP loc_add_points_and_update_score_buffers
; Collision with dangerous ghost: enter death script
bra_trigger_player_death:  ; was: bra_D2A2
    LDA #con_game_script_death
    STA ram_script
    LDA #$12
    STA ram_animation
    LDA #$80
    STA ram_death_anim_timer
    LDA #$00
    STA ram_shared_state_0
    RTS
; Accept a fruit collision only while the availability/popup latch is clear
bra_handle_fruit_collision:  ; was: bra_D2B3
    LDA ram_fruit_eaten_latch
    BEQ bra_spawn_fruit_and_score
    RTS
; Replace the fruit with its score popup and prepare the stage-indexed award
bra_spawn_fruit_and_score:  ; was: bra_D2B8
    STA ram_fruit_timer_hi
    LDA #$80
    STA ram_fruit_timer_lo
    STA ram_fruit_eaten_latch
    STA ram_sfx_eat_fruit
    LDY ram_stage_param_index
    LDA tbl_fruit_score_hi,Y
    STA ram_pending_score_bcd + $01
    LDA tbl_fruit_score_lo,Y
    STA ram_pending_score_bcd + $02
    LDA tbl_fruit_score_popup_tiles,Y
    STA ram_animation + $05
    JMP loc_add_points_and_update_score_buffers

; Tile IDs for ghost-eaten score popups
tbl_ghost_score_popup_tiles:  ; was: tbl_D2D7
    .byte $2D  ; 00
    .byte $2F  ; 01
    .byte $32  ; 02
    .byte $34  ; 03

; Tile IDs for fruit score popups by stage
tbl_fruit_score_popup_tiles:  ; was: tbl_D2DB
    .byte $2C  ; 00
    .byte $2E  ; 01
    .byte $30  ; 02
    .byte $31  ; 03
    .byte $33  ; 04
    .byte $35  ; 05
    .byte $36  ; 06
    .byte $37  ; 07

; High-byte score values for ghost-eat chain
tbl_ghost_score_popup_hi:  ; was: tbl_D2E3
    .byte $00  ; 00
    .byte $00  ; 01
    .byte $00  ; 02
    .byte $01  ; 03

; Low-byte score values for ghost-eat chain
tbl_ghost_score_popup_lo:  ; was: tbl_D2E7
    .byte $02  ; 00
    .byte $04  ; 01
    .byte $08  ; 02
    .byte $06  ; 03

; High-byte fruit score values by stage
tbl_fruit_score_hi:  ; was: tbl_D2EB
    .byte $01  ; 00
    .byte $03  ; 01
    .byte $05  ; 02
    .byte $07  ; 03
    .byte $00  ; 04
    .byte $00  ; 05
    .byte $00  ; 06
    .byte $00  ; 07

; Low-byte fruit score values by stage
tbl_fruit_score_lo:  ; was: tbl_D2F3
    .byte $00  ; 00
    .byte $00  ; 01
    .byte $00  ; 02
    .byte $00  ; 03
    .byte $01  ; 04
    .byte $02  ; 05
    .byte $03  ; 06
    .byte $05  ; 07
