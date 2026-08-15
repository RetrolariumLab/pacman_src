; Pac-Man movement, input, and demo path

; Main Pac-Man movement update (live input or demo script)
; Handles turn buffering, tile legality checks, tunnel wrap, and per-frame stepping.
sub_update_pacman_movement:		; was: sub_D2FB
    LDA ram_flag_demo
    BEQ bra_handle_live_input
    JMP loc_demo_direction_script
; Live gameplay path: read dpad input
bra_handle_live_input:		; was: bra_D302
    LDA ram_btn_total
    AND #con_btns_Dpad
    BEQ bra_fallback_to_current_direction
    LDX #$FF
; Decode first pressed dpad direction into direction index
bra_decode_dpad_direction:		; was: bra_D30A_loop
    INX
    ASL
    BCC bra_decode_dpad_direction
    LDA tbl_dpad_to_direction,X
; Apply requested direction and validate turn legality
loc_apply_requested_direction:		; was: loc_D311
    STA ram_direction_1
    CLC
    ADC #con_direction_reverse_delta
    AND #con_direction_mask
    CMP ram_direction_2
    BNE bra_validate_requested_direction
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_accept_turn_or_reverse
    LDY ram_direction_1
    LDA ram_obj_ppu_tile_direction,Y  ; 022B 022C 022D 022E
    AND #$F0
    BNE bra_validate_requested_direction
; Accept requested direction when legal/aligned
bra_accept_turn_or_reverse:		; was: bra_D32D
    LDA ram_direction_1
    STA ram_direction_2
    JMP loc_select_speed_profile
; Validate requested direction against tile blockers
bra_validate_requested_direction:		; was: bra_D334
    LDX ram_direction_1
    LDA ram_obj_ppu_tile_direction,X  ; 022B 022C 022D 022E
    AND #$F0
    BEQ bra_select_speed_profile_entry
; Fallback to current direction when no valid input
bra_fallback_to_current_direction:		; was: bra_D33D
    LDA ram_direction_2
    STA ram_direction_1
; Branch alias into speed-profile selection entry point
bra_select_speed_profile_entry:		; was: bra_D341
; Select movement speed profile for current tile/state
loc_select_speed_profile:		; was: loc_D341
    LDX #$04
    LDA ram_shared_state_1
    BNE bra_choose_speed_from_tile
    LDX #$0A
; Choose speed class based on current tile type
bra_choose_speed_from_tile:		; was: bra_D349
    LDA ram_obj_ppu_tile_now
    CMP #con_tile + $01
    BEQ bra_load_movement_delta    ; if power pellet (visible)
    CMP #con_tile + $02
    BEQ bra_load_movement_delta    ; if power pellet (not visible)
    DEX
    DEX
    CMP #con_tile + $03
    BEQ bra_load_movement_delta    ; if normal pellet
    CMP #con_tile + $09
    BEQ bra_load_movement_delta    ; if normal pellet (rare)
    DEX
    DEX
; Load per-direction movement delta from runtime table
bra_load_movement_delta:		; was: bra_D360
    LDA ram_level_parameters,X  ; 009F 00A5
    STA ram_pacman_move_fraction
    LDA ram_level_parameters + $01,X  ; 00A0 00A6
    STA ram_pacman_move_pixels
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_pos_lo_update_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_pos_lo_update_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Jump table: update low-byte position component by direction
tbl_pos_lo_update_handlers:		; was: tbl_D379
    .word handler_pos_lo_00_up
    .word handler_pos_lo_01_left
    .word handler_pos_lo_02_down
    .word handler_pos_lo_03_right

handler_pos_lo_00_up:
    LDX #$02    ; obj_pos_Y_lo
    BNE bra_move_negative_axis_lo    ; jmp

handler_pos_lo_01_left:
    LDX #$00    ; obj_pos_X_lo
; Move on negative axis using low-byte position
bra_move_negative_axis_lo:		; was: bra_D387
    LDA ram_obj_position + $01,X  ; 001B 001D
    SEC
    SBC ram_pacman_move_fraction
    STA ram_obj_position + $01,X  ; 001B 001D
    LDA #$00
    BCS bra_fold_borrow_into_step_count
    LDA #$01
; Fold borrow/carry into remaining substep counter
bra_fold_borrow_into_step_count:		; was: bra_D394
    CLC
    ADC ram_pacman_move_pixels
    STA ram_movement_step_budget
    JMP loc_step_remaining_pixels

handler_pos_lo_03_right:
    LDX #$00    ; obj_pos_X_lo
    BEQ bra_move_positive_axis_lo    ; jmp

handler_pos_lo_02_down:
    LDX #$02    ; obj_pos_Y_lo
; Shared entry for right/down low-byte movement path
bra_move_positive_axis_lo:		; was: bra_D3A2
    LDA ram_obj_position + $01,X  ; 001B 001D
    CLC
    ADC ram_pacman_move_fraction
    STA ram_obj_position + $01,X  ; 001B 001D
    LDA #$00
    ADC ram_pacman_move_pixels
    STA ram_movement_step_budget
; Per-pixel stepping loop until movement delta exhausted
loc_step_remaining_pixels:		; was: loc_D3AF
    DEC ram_movement_step_budget
    BPL bra_dispatch_pos_hi_update
    RTS
; Dispatch high-byte position update by direction
bra_dispatch_pos_hi_update:		; was: bra_D3B4
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_pos_hi_update_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_pos_hi_update_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Jump table: update high-byte position component by direction
tbl_pos_hi_update_handlers:		; was: tbl_D3C5
    .word handler_pos_hi_00_up
    .word handler_pos_hi_01_left
    .word handler_pos_hi_02_down
    .word handler_pos_hi_03_right

handler_pos_hi_03_right:
    LDX #$00    ; obj_pos_X_hi
    STX zp_work0
    LDA #con_direction_right
    STA zp_work1
    BNE bra_move_positive_axis_hi    ; jmp

handler_pos_hi_02_down:
    LDX #$02    ; obj_pos_Y_hi, down
    STX zp_work0
    STX zp_work1
; Move on positive axis (right/down) and align at junctions
bra_move_positive_axis_hi:		; was: bra_D3DD
    LDA ram_obj_position,X  ; 001A 001C
    CLC
    ADC #$01
    STA ram_obj_position,X  ; 001A 001C
    AND #$04
    BNE bra_apply_tunnel_wrap_and_turn
    LDX zp_work1
    LDA ram_obj_ppu_tile_direction,X  ; 022D 022E
    AND #$F0
    BEQ bra_apply_tunnel_wrap_and_turn
    LDX zp_work0
    LDA ram_obj_position,X  ; 001A 001C
    AND #$FC
    STA ram_obj_position,X  ; 001A 001C
    BNE bra_apply_tunnel_wrap_and_turn    ; jmp

handler_pos_hi_01_left:
    LDX #$00    ; obj_pos_X_hi
    STX zp_work0
    LDA #con_direction_left
    STA zp_work1
    BNE bra_move_negative_axis_hi    ; jmp

handler_pos_hi_00_up:
    LDX #$02    ; obj_pos_Y_hi
    STX zp_work0
    LDA #con_direction_up
    STA zp_work1
; Move on negative axis (up/left) and align at junctions
bra_move_negative_axis_hi:		; was: bra_D40D
    LDA ram_obj_position,X  ; 001A 001C
    SEC
    SBC #$01
    STA ram_obj_position,X  ; 001A 001C
    AND #$04
    BEQ bra_apply_tunnel_wrap_and_turn
    LDX zp_work1
    LDA ram_obj_ppu_tile_direction,X  ; 022B 022C
    AND #$F0
    BEQ bra_apply_tunnel_wrap_and_turn
    LDX zp_work0
    LDA ram_obj_position,X  ; 001A 001C
    CLC
    ADC #$04
    AND #$FC
    STA ram_obj_position,X  ; 001A 001C
; Apply tunnel palette/wrap logic and commit queued turns
bra_apply_tunnel_wrap_and_turn:		; was: bra_D42C
    LDA ram_obj_pos_X_hi
    CMP #$18
    BCC bra_set_tunnel_palette
; 18-FF
    CMP #$A9
    BCS bra_set_tunnel_palette    ; if A9-FF
; 18-A8
    LDA ram_spr_pal
    AND #$DF
    BCC bra_store_pacman_palette    ; jmp
; Set tunnel palette bit outside center corridor
bra_set_tunnel_palette:		; was: bra_D43C
; 00-17 and A9-FF
    LDA #$20
    ORA ram_spr_pal
; Store updated Pac-Man sprite palette
bra_store_pacman_palette:		; was: bra_D440
    STA ram_spr_pal
    LDA ram_obj_pos_X_hi
    CMP #$0B
    BCS bra_check_right_wrap
    LDA #$BF
    STA ram_obj_pos_X_hi
    BNE bra_try_apply_queued_turn    ; jmp
; Check right-edge wrap condition
bra_check_right_wrap:		; was: bra_D44E
    CMP #$C0
    BCC bra_try_apply_queued_turn
    LDA #$0B
    STA ram_obj_pos_X_hi
; Apply queued requested turn at tile alignment
bra_try_apply_queued_turn:		; was: bra_D456
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_continue_step_loop
    LDA ram_direction_1
    CMP ram_direction_2
    BEQ bra_continue_step_loop
    STA ram_direction_2
    INC ram_movement_step_budget
    INC ram_movement_step_budget
; Continue movement step loop
bra_continue_step_loop:		; was: bra_D46A
    JMP loc_step_remaining_pixels

; Map dpad bit order to direction enum
tbl_dpad_to_direction:		; was: tbl_D46D_direction
    .byte con_direction_right
    .byte con_direction_left
    .byte con_direction_down
    .byte con_direction_up

; Demo/autoplay direction sequencer
loc_demo_direction_script:		; was: loc_D471
    LDY ram_demo_direction_index
    DEC ram_demo_direction_timer
    BNE bra_apply_demo_direction
    INC ram_demo_direction_index
    INC ram_demo_direction_index
    LDY ram_demo_direction_index
    LDA tbl_demo_direction_timing_pairs,Y
    STA ram_demo_direction_timer
; Apply current demo direction and branch into movement core
bra_apply_demo_direction:		; was: bra_D482
    LDA tbl_demo_direction_timing_pairs + $01,Y
    AND #$03
    JMP loc_apply_requested_direction

; Demo script pairs: frame duration + direction
tbl_demo_direction_timing_pairs:		; was: tbl_D48A
; Byte pairs: [duration, direction], consumed by loc_demo_direction_script
    .byte $00, $01   ; 00
    .byte $D0, $00   ; 01
    .byte $28, $01   ; 02
    .byte $28, $02   ; 03
    .byte $90, $03   ; 04
    .byte $38, $00   ; 05
    .byte $20, $03   ; 06
    .byte $18, $01   ; 07
    .byte $60, $02   ; 08
    .byte $30, $01   ; 09
    .byte $10, $02   ; 0A
    .byte $48, $01   ; 0B
    .byte $18, $02   ; 0C
    .byte $40, $01   ; 0D
    .byte $20, $02   ; 0E
    .byte $18, $00   ; 0F
    .byte $20, $03   ; 10
    .byte $40, $02   ; 11
    .byte $38, $01   ; 12
    .byte $18, $02   ; 13
    .byte $E0, $03   ; 14
    .byte $30, $00   ; 15
    .byte $28, $01   ; 16
    .byte $28, $02   ; 17
    .byte $20, $02   ; 18
    .byte $80, $03   ; 19
    .byte $40, $00   ; 1A
    .byte $40, $01   ; 1B
