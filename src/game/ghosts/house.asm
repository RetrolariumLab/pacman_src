; Ghost speed selection, house transitions, and release counters

sub_select_ghost_speed_vector:		; was: sub_D78C
; Speed source registers:
; - ram_ghost0_current_speed_*: slot 0 normal speed
; - ram_ghost_normal_speed_*: slots 1-3 normal speed
; - ram_ghost_frightened_speed_*: frightened speed
; - ram_ghost_tunnel_speed_*: tunnel speed
    LDA ram_ghost_state,X
    CMP #con_ghost_state_returning_eyes
    BEQ bra_apply_eyes_speed
    LDY #$02
    LDA (zp_work2),Y    ; 0020 0024 0028 002C
    CMP #$70
    BNE bra_select_scatter_or_chase_speed
    LDY #$00
    LDA (zp_work2),Y    ; 001E 0022 0026 002A
    CMP #$90
    BCS bra_apply_tunnel_speed
    CMP #$30
    BCS bra_select_scatter_or_chase_speed
; Apply tunnel speed profile
bra_apply_tunnel_speed:		; was: bra_D7A6
    LDA ram_ghost_tunnel_speed_fraction
    STA ram_ghost_move_fraction,X
    LDA ram_ghost_tunnel_speed_pixels
    STA ram_ghost_move_pixels,X
    RTS
; Select scatter/chase speed profile
bra_select_scatter_or_chase_speed:		; was: bra_D7AF
    LDA zp_work4
    AND ram_shared_state_1
    BNE bra_apply_frightened_speed
    TXA
    BNE bra_apply_normal_speed_slots12
    LDA ram_ghost0_current_speed_fraction
    STA ram_ghost_move_fraction
    LDA ram_ghost0_current_speed_pixels
    STA ram_ghost_move_pixels
    RTS
; Apply normal speed profile for slots 1-2
bra_apply_normal_speed_slots12:		; was: bra_D7C1
    LDA ram_ghost_normal_speed_fraction
    STA ram_ghost_move_fraction,X
    LDA ram_ghost_normal_speed_pixels
    STA ram_ghost_move_pixels,X
    RTS
; Apply frightened speed profile
bra_apply_frightened_speed:		; was: bra_D7CA
    LDA ram_ghost_frightened_speed_fraction
    STA ram_ghost_move_fraction,X
    LDA ram_ghost_frightened_speed_pixels
    STA ram_ghost_move_pixels,X
    RTS
; Apply returning-eyes speed profile
bra_apply_eyes_speed:		; was: bra_D7D3
    LDA #$00
    STA ram_ghost_move_fraction,X
    LDA #$02
    STA ram_ghost_move_pixels,X
    RTS

; Ranked direction preference LUT
tbl_ranked_dir_order_lut:		; was: tbl_D7DC
    .byte $03   ; 00
    .byte $02   ; 01
    .byte $02   ; 02
    .byte $03   ; 03
    .byte $03   ; 04
    .byte $00   ; 05
    .byte $00   ; 06
    .byte $03   ; 07
    .byte $01   ; 08
    .byte $02   ; 09
    .byte $02   ; 0A
    .byte $01   ; 0B
    .byte $01   ; 0C
    .byte $00   ; 0D
    .byte $00   ; 0E
    .byte $01   ; 0F

; Forbidden-turn mask pointers by ghost state
tbl_forbidden_turn_mask_by_state:		; was: tbl_D7EC
    .byte $00, $00   ; 04
    .byte $2C, $08   ; 06

; State 02 handler: ghost exiting house
handler_state02_exit_house:		; was: ofs_006_D7F0_02
; Moves ghost from house lane to map entry X=60,Y=58 then arms state04.
    LDA #$00
    TAY
    STA zp_work5
    LDA #$80
    STA zp_work6
    LDA (zp_work2),Y    ; 001E 0022 0026 002A
    CMP #$60
    BEQ bra_transition_to_state04
    BCC bra_choose_exit_left_or_up
    DEC zp_work5
    LDA #con_direction_left
    BNE bra_store_exit_direction    ; jmp
; Choose exit direction variant
bra_choose_exit_left_or_up:		; was: bra_D807
    LDA #con_direction_right
; Store selected exit direction
bra_store_exit_direction:		; was: bra_D809
    STA ram_ghost_direction,X
    LDY #$01
    LDA (zp_work2),Y    ; 0027 002B
    CLC
    ADC zp_work6
    STA (zp_work2),Y    ; 0027 002B
    LDY #$00
    LDA (zp_work2),Y    ; 0026 002A
    ADC zp_work5
    STA (zp_work2),Y    ; 0026 002A
    RTS
; Transition ghost from state 02 to state 04
bra_transition_to_state04:		; was: bra_D81D
    LDA #con_direction_up
    STA ram_ghost_direction,X
    LDY #$03
    LDA (zp_work2),Y    ; 0021 0025 0029 002D
    SEC
    SBC #< $0080
    STA (zp_work2),Y    ; 0021 0025 0029 002D
    LDY #$02
    LDA (zp_work2),Y    ; 0020 0024 0028 002C
    SBC #> $0080
    STA (zp_work2),Y    ; 0020 0024 0028 002C
    CMP #$58
    BEQ bra_finish_exit_house_transition
    RTS
; Finalize exit-house transition
bra_finish_exit_house_transition:		; was: bra_D837
    LDA #con_direction_left
    STA ram_ghost_direction,X
    LDA #con_ghost_state_active
    STA ram_ghost_state,X
    RTS

; State 00 handler: ghost entering house
handler_state00_enter_house:		; was: ofs_006_D840_00
; Uses subphase in ram_ghost_direction to bounce between house Y bounds (69..70).
    LDA #$00
    STA zp_work5
    LDA #$80
    STA zp_work6
    LDY ram_ghost_direction,X
    LDA tbl_house_transition_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_house_transition_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Sub-handlers for house transition state
tbl_house_transition_handlers:		; was: tbl_D857
    .word handler_house_move_up_phase
    .word handler_house_move_down_phase

; House transition phase: move up
handler_house_move_up_phase:		; was: ofs_010_D85B_00
    DEC zp_work5
; House transition phase: move down
handler_house_move_down_phase:		; was: ofs_010_D85D_02
    LDY #$03
    LDA (zp_work2),Y    ; 0025 0029 002D
    CLC
    ADC zp_work6
    STA (zp_work2),Y    ; 0025 0029 002D
    LDY #$02
    LDA (zp_work2),Y    ; 0024 0028 002C
    ADC zp_work5
    STA (zp_work2),Y    ; 0024 0028 002C
    CMP #$69
    BCS bra_check_house_transition_bounds
    LDA #$02
    BNE bra_store_house_transition_phase    ; jmp
; Check house transition bounds
bra_check_house_transition_bounds:		; was: bra_D876
    CMP #$70
    BCC bra_return_from_house_transition
    LDA #$00
; Store next house transition phase
bra_store_house_transition_phase:		; was: bra_D87C
    STA ram_ghost_direction,X
; Return from house transition handler
bra_return_from_house_transition:		; was: bra_D87E_RTS
    RTS

; Update ghost slots with state06-only dispatch
sub_update_ghost_slots_state06_only:		; was: sub_D87F
    LDX #$00
    LoadPointer zp_work0, (ram_obj_ppu_tile + $05)
    LoadPointer zp_work2, (ram_obj_pos_X_hi + $04)
    LDA #$01
    STA zp_work4
; Loop over ghost slots for state06-only update
bra_update_state06_slot_loop:		; was: bra_D895_loop
    JSR sub_dispatch_state06_only_handler
    LDA zp_work0
    CLC
    ADC #con_actor_position_record_size
    STA zp_work0
    LDA zp_work2
    CLC
    ADC #con_actor_position_record_size
    STA zp_work2
    ASL zp_work4
    INX
    INX ; con_ghost_slot_stride
    CPX #con_ghost_slot_span
    BNE bra_update_state06_slot_loop
    RTS

; Dispatch reduced handler set for state06 pass
sub_dispatch_state06_only_handler:		; was: sub_D8AF
    LDY ram_ghost_state,X
    LDA tbl_state06_only_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_state06_only_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Reduced handler table for state06 pass
tbl_state06_only_handlers:		; was: tbl_D8BE
    .word handler_state00_noop           ; con_ghost_state_in_house
    .word handler_state02_noop           ; con_ghost_state_exiting_house
    .word handler_state04_noop           ; con_ghost_state_active
    .word handler_state06_move_logic     ; con_ghost_state_returning_eyes
    .word handler_reduced_ghost_state08_noop ; con_ghost_state_eaten_score

; State00 in reduced pass: no-op
handler_state00_noop:		; was: ofs_006_D8C8_00_RTS
; State02 in reduced pass: no-op
handler_state02_noop:		; was: ofs_006_D8C8_02_RTS
; State04 in reduced pass: no-op
handler_state04_noop:		; was: ofs_006_D8C8_04_RTS
; State08 in reduced pass: no-op
handler_reduced_ghost_state08_noop:		; was: ofs_006_D8C8_08_RTS
    RTS

; Update ghost-house counters and release markers
sub_update_ghost_house_counters:		; was: sub_D8C9
; Maintains state06 marker and pellet-threshold release flags in 0608..060C.
    LDX #$00
    STX zp_work0
; Scan ghost slots for state06 presence
bra_scan_state06_presence:		; was: bra_D8CD_loop
    LDA ram_ghost_state,X
    CMP #con_ghost_state_returning_eyes
    BNE bra_next_slot_for_state06_scan
    STA ram_sfx_ghost_house_state6_marker
    RTS
; Advance to next slot in state06 scan
bra_next_slot_for_state06_scan:		; was: bra_D8D7
    INX
    INX ; con_ghost_slot_stride
    CPX #con_ghost_slot_span
    BNE bra_scan_state06_presence
    LDA ram_shared_state_1
    BEQ bra_set_release_marker_by_pellets
    STA ram_sfx_ghost_house_release_marker
    RTS
; Set ghost release marker based on pellet thresholds
bra_set_release_marker_by_pellets:		; was: bra_D8E5
    LDY #$00
    LDA ram_pellet_cnt_p1
    CMP #$88
    BCS bra_commit_release_marker
    INY
    CMP #$42
    BCS bra_commit_release_marker
    INY
; Commit selected release marker flag
bra_commit_release_marker:		; was: bra_D8F3
    LDA #$01
    STA ram_sfx_release_counter_hi,Y  ; 060A 060B 060C
    RTS
