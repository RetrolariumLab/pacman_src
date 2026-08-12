; Pac-Man movement, input, and demo path




; Main Pac-Man movement update (live input or demo script)
; Handles turn buffering, tile legality checks, tunnel wrap, and per-frame stepping.
sub_D2FB_update_pacman_movement:		; was: sub_D2FB
    LDA ram_flag_demo
    BEQ bra_D302_handle_live_input
    JMP loc_D471_demo_direction_script
; Live gameplay path: read dpad input
bra_D302_handle_live_input:		; was: bra_D302
    LDA ram_btn_total
    AND #con_btns_Dpad
    BEQ bra_D33D_fallback_to_current_direction
    LDX #$FF
; Decode first pressed dpad direction into direction index
bra_D30A_decode_dpad_direction:		; was: bra_D30A_loop
    INX
    ASL
    BCC bra_D30A_decode_dpad_direction
    LDA tbl_D46D_dpad_to_direction,X
; Apply requested direction and validate turn legality
loc_D311_apply_requested_direction:		; was: loc_D311
    STA ram_direction_1
    CLC
    ADC #$02
    AND #$03
    CMP ram_direction_2
    BNE bra_D334_validate_requested_direction
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_D32D_accept_turn_or_reverse
    LDY ram_direction_1
    LDA ram_obj_ppu_tile_direction,Y  ; 022B 022C 022D 022E
    AND #$F0
    BNE bra_D334_validate_requested_direction
; Accept requested direction when legal/aligned
bra_D32D_accept_turn_or_reverse:		; was: bra_D32D
    LDA ram_direction_1
    STA ram_direction_2
    JMP loc_D341_select_speed_profile
; Validate requested direction against tile blockers
bra_D334_validate_requested_direction:		; was: bra_D334
    LDX ram_direction_1
    LDA ram_obj_ppu_tile_direction,X  ; 022B 022C 022D 022E
    AND #$F0
    BEQ bra_D341_select_speed_profile_entry
; Fallback to current direction when no valid input
bra_D33D_fallback_to_current_direction:		; was: bra_D33D
    LDA ram_direction_2
    STA ram_direction_1
; Branch alias into speed-profile selection entry point
bra_D341_select_speed_profile_entry:		; was: bra_D341
; Select movement speed profile for current tile/state
loc_D341_select_speed_profile:		; was: loc_D341
    LDX #$04
    LDA ram_0088
    BNE bra_D349_choose_speed_from_tile
    LDX #$0A
; Choose speed class based on current tile type
bra_D349_choose_speed_from_tile:		; was: bra_D349
    LDA ram_obj_ppu_tile_now
    CMP #con_tile + $01
    BEQ bra_D360_load_movement_delta    ; if power pellet (visible)
    CMP #con_tile + $02
    BEQ bra_D360_load_movement_delta    ; if power pellet (not visible)
    DEX
    DEX
    CMP #con_tile + $03
    BEQ bra_D360_load_movement_delta    ; if normal pellet
    CMP #con_tile + $09
    BEQ bra_D360_load_movement_delta    ; if normal pellet (rare)
    DEX
    DEX
; Load per-direction movement delta from runtime table
bra_D360_load_movement_delta:		; was: bra_D360
    LDA ram_009F,X  ; 009F 00A5
    STA ram_00B5
    LDA ram_00A0,X  ; 00A0 00A6
    STA ram_00B6
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_D379_pos_lo_update_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D379_pos_lo_update_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Jump table: update low-byte position component by direction
tbl_D379_pos_lo_update_handlers:		; was: tbl_D379
    .word ofs_004_D381_00_up
    .word ofs_004_D385_01_left
    .word ofs_004_D3A0_02_down
    .word ofs_004_D39C_03_right



ofs_004_D381_00_up:
    LDX #$02    ; obj_pos_Y_lo
    BNE bra_D387_move_negative_axis_lo    ; jmp



ofs_004_D385_01_left:
    LDX #$00    ; obj_pos_X_lo
; Move on negative axis using low-byte position
bra_D387_move_negative_axis_lo:		; was: bra_D387
    LDA ram_obj_position + $01,X  ; 001B 001D
    SEC
    SBC ram_00B5
    STA ram_obj_position + $01,X  ; 001B 001D
    LDA #$00
    BCS bra_D394_fold_borrow_into_step_count
    LDA #$01
; Fold borrow/carry into remaining substep counter
bra_D394_fold_borrow_into_step_count:		; was: bra_D394
    CLC
    ADC ram_00B6
    STA ram_00CC
    JMP loc_D3AF_step_remaining_pixels



ofs_004_D39C_03_right:
    LDX #$00    ; obj_pos_X_lo
    BEQ bra_D3A2_move_positive_axis_lo    ; jmp



ofs_004_D3A0_02_down:
    LDX #$02    ; obj_pos_Y_lo
; Shared entry for right/down low-byte movement path
bra_D3A2_move_positive_axis_lo:		; was: bra_D3A2
    LDA ram_obj_position + $01,X  ; 001B 001D
    CLC
    ADC ram_00B5
    STA ram_obj_position + $01,X  ; 001B 001D
    LDA #$00
    ADC ram_00B6
    STA ram_00CC
; Per-pixel stepping loop until movement delta exhausted
loc_D3AF_step_remaining_pixels:		; was: loc_D3AF
    DEC ram_00CC
    BPL bra_D3B4_dispatch_pos_hi_update
    RTS
; Dispatch high-byte position update by direction
bra_D3B4_dispatch_pos_hi_update:		; was: bra_D3B4
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_D3C5_pos_hi_update_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D3C5_pos_hi_update_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Jump table: update high-byte position component by direction
tbl_D3C5_pos_hi_update_handlers:		; was: tbl_D3C5
    .word ofs_005_D405_00_up
    .word ofs_005_D3FB_01_left
    .word ofs_005_D3D7_02_down
    .word ofs_005_D3CD_03_right



ofs_005_D3CD_03_right:
    LDX #$00    ; obj_pos_X_hi
    STX ram_0000
    LDA #$03    ; right
    STA ram_0001
    BNE bra_D3DD_move_positive_axis_hi    ; jmp



ofs_005_D3D7_02_down:
    LDX #$02    ; obj_pos_Y_hi, down
    STX ram_0000
    STX ram_0001
; Move on positive axis (right/down) and align at junctions
bra_D3DD_move_positive_axis_hi:		; was: bra_D3DD
    LDA ram_obj_position,X  ; 001A 001C
    CLC
    ADC #$01
    STA ram_obj_position,X  ; 001A 001C
    AND #$04
    BNE bra_D42C_apply_tunnel_wrap_and_turn
    LDX ram_0001
    LDA ram_obj_ppu_tile_direction,X  ; 022D 022E
    AND #$F0
    BEQ bra_D42C_apply_tunnel_wrap_and_turn
    LDX ram_0000
    LDA ram_obj_position,X  ; 001A 001C
    AND #$FC
    STA ram_obj_position,X  ; 001A 001C
    BNE bra_D42C_apply_tunnel_wrap_and_turn    ; jmp



ofs_005_D3FB_01_left:
    LDX #$00    ; obj_pos_X_hi
    STX ram_0000
    LDA #$01    ; left
    STA ram_0001
    BNE bra_D40D_move_negative_axis_hi    ; jmp



ofs_005_D405_00_up:
    LDX #$02    ; obj_pos_Y_hi
    STX ram_0000
    LDA #$00    ; up
    STA ram_0001
; Move on negative axis (up/left) and align at junctions
bra_D40D_move_negative_axis_hi:		; was: bra_D40D
    LDA ram_obj_position,X  ; 001A 001C
    SEC
    SBC #$01
    STA ram_obj_position,X  ; 001A 001C
    AND #$04
    BEQ bra_D42C_apply_tunnel_wrap_and_turn
    LDX ram_0001
    LDA ram_obj_ppu_tile_direction,X  ; 022B 022C
    AND #$F0
    BEQ bra_D42C_apply_tunnel_wrap_and_turn
    LDX ram_0000
    LDA ram_obj_position,X  ; 001A 001C
    CLC
    ADC #$04
    AND #$FC
    STA ram_obj_position,X  ; 001A 001C
; Apply tunnel palette/wrap logic and commit queued turns
bra_D42C_apply_tunnel_wrap_and_turn:		; was: bra_D42C
    LDA ram_obj_pos_X_hi
    CMP #$18
    BCC bra_D43C_set_tunnel_palette
; 18-FF
    CMP #$A9
    BCS bra_D43C_set_tunnel_palette    ; if A9-FF
; 18-A8
    LDA ram_spr_pal
    AND #$DF
    BCC bra_D440_store_pacman_palette    ; jmp
; Set tunnel palette bit outside center corridor
bra_D43C_set_tunnel_palette:		; was: bra_D43C
; 00-17 and A9-FF
    LDA #$20
    ORA ram_spr_pal
; Store updated Pac-Man sprite palette
bra_D440_store_pacman_palette:		; was: bra_D440
    STA ram_spr_pal
    LDA ram_obj_pos_X_hi
    CMP #$0B
    BCS bra_D44E_check_right_wrap
    LDA #$BF
    STA ram_obj_pos_X_hi
    BNE bra_D456_try_apply_queued_turn    ; jmp
; Check right-edge wrap condition
bra_D44E_check_right_wrap:		; was: bra_D44E
    CMP #$C0
    BCC bra_D456_try_apply_queued_turn
    LDA #$0B
    STA ram_obj_pos_X_hi
; Apply queued requested turn at tile alignment
bra_D456_try_apply_queued_turn:		; was: bra_D456
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_D46A_continue_step_loop
    LDA ram_direction_1
    CMP ram_direction_2
    BEQ bra_D46A_continue_step_loop
    STA ram_direction_2
    INC ram_00CC
    INC ram_00CC
; Continue movement step loop
bra_D46A_continue_step_loop:		; was: bra_D46A
    JMP loc_D3AF_step_remaining_pixels



; Map dpad bit order to direction enum
tbl_D46D_dpad_to_direction:		; was: tbl_D46D_direction
    .byte $03   ; 00 right
    .byte $01   ; 01 left
    .byte $02   ; 02 down
    .byte $00   ; 03 up



; Demo/autoplay direction sequencer
loc_D471_demo_direction_script:		; was: loc_D471
    LDY ram_00E4
    DEC ram_00E3
    BNE bra_D482_apply_demo_direction
    INC ram_00E4
    INC ram_00E4
    LDY ram_00E4
    LDA tbl_D48A_demo_direction_timing_pairs,Y
    STA ram_00E3
; Apply current demo direction and branch into movement core
bra_D482_apply_demo_direction:		; was: bra_D482
    LDA tbl_D48A_demo_direction_timing_pairs + $01,Y
    AND #$03
    JMP loc_D311_apply_requested_direction



; Demo script pairs: frame duration + direction
tbl_D48A_demo_direction_timing_pairs:		; was: tbl_D48A
; Byte pairs: [duration, direction], consumed by loc_D471_demo_direction_script
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
