; Ghost speed selection, house transitions, and release counters

sub_D78C_select_ghost_speed_vector:		; was: sub_D78C
; Speed source registers:
; - 00CA/00CB: slot0 normal speed
; - 00AF/00B0: slots1-3 normal speed
; - 00B1/00B2: frightened speed
; - 00B3/00B4: tunnel speed
    LDA ram_00B8,X
    CMP #$06
    BEQ bra_D7D3_apply_eyes_speed
    LDY #$02
    LDA (ram_0002),Y    ; 0020 0024 0028 002C
    CMP #$70
    BNE bra_D7AF_select_scatter_or_chase_speed
    LDY #$00
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    CMP #$90
    BCS bra_D7A6_apply_tunnel_speed
    CMP #$30
    BCS bra_D7AF_select_scatter_or_chase_speed
; Apply tunnel speed profile
bra_D7A6_apply_tunnel_speed:		; was: bra_D7A6
    LDA ram_00B3
    STA ram_00C2,X
    LDA ram_00B4
    STA ram_00C3,X
    RTS
; Select scatter/chase speed profile
bra_D7AF_select_scatter_or_chase_speed:		; was: bra_D7AF
    LDA ram_0004
    AND ram_0088
    BNE bra_D7CA_apply_frightened_speed
    TXA
    BNE bra_D7C1_apply_normal_speed_slots12
    LDA ram_00CA
    STA ram_00C2
    LDA ram_00CB
    STA ram_00C3
    RTS
; Apply normal speed profile for slots 1-2
bra_D7C1_apply_normal_speed_slots12:		; was: bra_D7C1
    LDA ram_00AF
    STA ram_00C2,X
    LDA ram_00B0
    STA ram_00C3,X
    RTS
; Apply frightened speed profile
bra_D7CA_apply_frightened_speed:		; was: bra_D7CA
    LDA ram_00B1
    STA ram_00C2,X
    LDA ram_00B2
    STA ram_00C3,X
    RTS
; Apply returning-eyes speed profile
bra_D7D3_apply_eyes_speed:		; was: bra_D7D3
    LDA #$00
    STA ram_00C2,X
    LDA #$02
    STA ram_00C3,X
    RTS



; Ranked direction preference LUT
tbl_D7DC_ranked_dir_order_lut:		; was: tbl_D7DC
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
tbl_D7EC_forbidden_turn_mask_by_state:		; was: tbl_D7EC
    .byte $00, $00   ; 04
    .byte $2C, $08   ; 06



; State 02 handler: ghost exiting house
ofs_006_D7F0_state02_exit_house:		; was: ofs_006_D7F0_02
; Moves ghost from house lane to map entry X=60,Y=58 then arms state04.
    LDA #$00
    TAY
    STA ram_0005
    LDA #$80
    STA ram_0006
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    CMP #$60
    BEQ bra_D81D_transition_to_state04
    BCC bra_D807_choose_exit_left_or_up
    DEC ram_0005
    LDA #$01
    BNE bra_D809_store_exit_direction    ; jmp
; Choose exit direction variant
bra_D807_choose_exit_left_or_up:		; was: bra_D807
    LDA #$03
; Store selected exit direction
bra_D809_store_exit_direction:		; was: bra_D809
    STA ram_00B9,X
    LDY #$01
    LDA (ram_0002),Y    ; 0027 002B
    CLC
    ADC ram_0006
    STA (ram_0002),Y    ; 0027 002B
    LDY #$00
    LDA (ram_0002),Y    ; 0026 002A
    ADC ram_0005
    STA (ram_0002),Y    ; 0026 002A
    RTS
; Transition ghost from state 02 to state 04
bra_D81D_transition_to_state04:		; was: bra_D81D
    LDA #$00
    STA ram_00B9,X
    LDY #$03
    LDA (ram_0002),Y    ; 0021 0025 0029 002D
    SEC
    SBC #< $0080
    STA (ram_0002),Y    ; 0021 0025 0029 002D
    LDY #$02
    LDA (ram_0002),Y    ; 0020 0024 0028 002C
    SBC #> $0080
    STA (ram_0002),Y    ; 0020 0024 0028 002C
    CMP #$58
    BEQ bra_D837_finish_exit_house_transition
    RTS
; Finalize exit-house transition
bra_D837_finish_exit_house_transition:		; was: bra_D837
    LDA #$01
    STA ram_00B9,X
    LDA #$04
    STA ram_00B8,X
    RTS



; State 00 handler: ghost entering house
ofs_006_D840_state00_enter_house:		; was: ofs_006_D840_00
; Uses subphase in ram_00B9 to bounce between house Y bounds (69..70).
    LDA #$00
    STA ram_0005
    LDA #$80
    STA ram_0006
    LDY ram_00B9,X
    LDA tbl_D857_house_transition_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D857_house_transition_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Sub-handlers for house transition state
tbl_D857_house_transition_handlers:		; was: tbl_D857
    .word ofs_010_D85B_house_move_up_phase
    .word ofs_010_D85D_house_move_down_phase



; House transition phase: move up
ofs_010_D85B_house_move_up_phase:		; was: ofs_010_D85B_00
    DEC ram_0005
; House transition phase: move down
ofs_010_D85D_house_move_down_phase:		; was: ofs_010_D85D_02
    LDY #$03
    LDA (ram_0002),Y    ; 0025 0029 002D
    CLC
    ADC ram_0006
    STA (ram_0002),Y    ; 0025 0029 002D
    LDY #$02
    LDA (ram_0002),Y    ; 0024 0028 002C
    ADC ram_0005
    STA (ram_0002),Y    ; 0024 0028 002C
    CMP #$69
    BCS bra_D876_check_house_transition_bounds
    LDA #$02
    BNE bra_D87C_store_house_transition_phase    ; jmp
; Check house transition bounds
bra_D876_check_house_transition_bounds:		; was: bra_D876
    CMP #$70
    BCC bra_D87E_return
    LDA #$00
; Store next house transition phase
bra_D87C_store_house_transition_phase:		; was: bra_D87C
    STA ram_00B9,X
; Return from house transition handler
bra_D87E_return:		; was: bra_D87E_RTS
    RTS



; Update ghost slots with state06-only dispatch
sub_D87F_update_ghost_slots_state06_only:		; was: sub_D87F
    LDX #$00
    LDA #< (ram_obj_ppu_tile + $05)
    STA ram_0000
    LDA #> (ram_obj_ppu_tile + $05)
    STA ram_0001
    LDA #< (ram_obj_pos_X_hi + $04)
    STA ram_0002
    LDA #> (ram_obj_pos_X_hi + $04)
    STA ram_0003
    LDA #$01
    STA ram_0004
; Loop over ghost slots for state06-only update
bra_D895_update_state06_slot_loop:		; was: bra_D895_loop
    JSR sub_D8AF_dispatch_state06_only_handler
    LDA ram_0000
    CLC
    ADC #$04
    STA ram_0000
    LDA ram_0002
    CLC
    ADC #$04
    STA ram_0002
    ASL ram_0004
    INX
    INX
    CPX #$08
    BNE bra_D895_update_state06_slot_loop
    RTS



; Dispatch reduced handler set for state06 pass
sub_D8AF_dispatch_state06_only_handler:		; was: sub_D8AF
    LDY ram_00B8,X
    LDA tbl_D8BE_state06_only_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D8BE_state06_only_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Reduced handler table for state06 pass
tbl_D8BE_state06_only_handlers:		; was: tbl_D8BE
    .word ofs_006_D8C8_state00_noop
    .word ofs_006_D8C8_state02_noop
    .word ofs_006_D8C8_state04_noop
    .word ofs_006_D50C_state06_move_logic
    .word ofs_006_D8C8_state08_noop



; State00 in reduced pass: no-op
ofs_006_D8C8_state00_noop:		; was: ofs_006_D8C8_00_RTS
; State02 in reduced pass: no-op
ofs_006_D8C8_state02_noop:		; was: ofs_006_D8C8_02_RTS
; State04 in reduced pass: no-op
ofs_006_D8C8_state04_noop:		; was: ofs_006_D8C8_04_RTS
; State08 in reduced pass: no-op
ofs_006_D8C8_state08_noop:		; was: ofs_006_D8C8_08_RTS
    RTS



; Update ghost-house counters and release markers
sub_D8C9_update_ghost_house_counters:		; was: sub_D8C9
; Maintains state06 marker and pellet-threshold release flags in 0608..060C.
    LDX #$00
    STX ram_0000
; Scan ghost slots for state06 presence
bra_D8CD_scan_state06_presence:		; was: bra_D8CD_loop
    LDA ram_00B8,X
    CMP #$06
    BNE bra_D8D7_next_slot_for_state06_scan
    STA ram_0608
    RTS
; Advance to next slot in state06 scan
bra_D8D7_next_slot_for_state06_scan:		; was: bra_D8D7
    INX
    INX
    CPX #$08
    BNE bra_D8CD_scan_state06_presence
    LDA ram_0088
    BEQ bra_D8E5_set_release_marker_by_pellets
    STA ram_0609
    RTS
; Set ghost release marker based on pellet thresholds
bra_D8E5_set_release_marker_by_pellets:		; was: bra_D8E5
    LDY #$00
    LDA ram_pellet_cnt_p1
    CMP #$88
    BCS bra_D8F3_commit_release_marker
    INY
    CMP #$42
    BCS bra_D8F3_commit_release_marker
    INY
; Commit selected release marker flag
bra_D8F3_commit_release_marker:		; was: bra_D8F3
    LDA #$01
    STA ram_060A,Y  ; 060A 060B 060C
    RTS
