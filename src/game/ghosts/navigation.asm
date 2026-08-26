; Ghost movement, targeting, path selection, and direction ranking

; Iterate ghost slots and run per-state movement/update logic
; Core enemy AI dispatcher: state machine, targeting formulas, and speed profiles
; Per ghost slot update pipeline:
; 1) state dispatch (house enter/exit, move logic, noop)
; 2) speed vector select by mode/state
; 3) low-byte move + carry/borrow accumulation
; 4) high-byte move loop, tunnel wrap, palette flag update
; 5) on tile centers choose next direction (targeted or seeded/randomized)
; Inputs: ghost state/direction/position arrays and cached tile probes
; Outputs: updated positions, directions, states, targets, and palette tunnel bits
; Side effects: advances tile/position pointers and a one-bit slot mask internally
; Clobbers: A, X, Y, zp_work0..zp_work14, and ram_indirect_jmp
sub_update_ghost_slots:
    LDX #$00
    LoadPointer zp_work0, (ram_obj_ppu_tile + $05)
    LoadPointer zp_work2, (ram_obj_pos_X_hi + $04)
    LDA #$01
    STA zp_work4
; Loop over 4 ghost slots (X+=2)
bra_update_ghost_slot_loop:
    JSR sub_dispatch_ghost_state_handler
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
    INX  ; con_ghost_slot_stride
    CPX #con_ghost_slot_span
    BNE bra_update_ghost_slot_loop
    RTS
; Dispatch one ghost update handler by even state-table offset
; Inputs: X=interleaved ghost slot offset plus current slot pointers/mask
; Outputs/side effects: state-handler dependent; X is preserved
; Clobbers: A, Y and ram_indirect_jmp
; State and direction are interleaved; release scans start at ghost slot 1
sub_dispatch_ghost_state_handler:
    LDY ram_ghost_state,X
    LDA tbl_ghost_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_ghost_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Ghost state handler jump table
tbl_ghost_state_handlers:
    .word handler_state00_enter_house  ; con_ghost_state_in_house
    .word handler_state02_exit_house  ; con_ghost_state_exiting_house
    .word handler_state04_move_logic  ; con_ghost_state_active
    .word handler_state06_move_logic  ; con_ghost_state_returning_eyes
    .word handler_ghost_state08_noop  ; con_ghost_state_eaten_score

; State 08 handler: no-op
handler_ghost_state08_noop:
    RTS

; State 04 handler: movement/target logic
handler_state04_move_logic:
; State 06 handler: movement/target logic
handler_state06_move_logic:
; Shared mover for normal chase/scatter (04) and eyes-return (06) paths
    JSR sub_select_ghost_speed_vector
    LDA ram_ghost_direction,X
    ASL
    TAY
    LDA tbl_axis_step_lo_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_axis_step_lo_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Low-byte axis step handlers by direction
tbl_axis_step_lo_handlers:
    .word handler_step_lo_neg_axis
    .word handler_step_lo_neg_axis_alt
    .word handler_step_lo_pos_axis
    .word handler_step_lo_pos_axis_alt

; Step positive on low-byte axis
handler_step_lo_pos_axis:
    LDY #$03
    BNE bra_apply_lo_step_add  ; jmp

; Step positive on alternate low-byte axis
handler_step_lo_pos_axis_alt:
    LDY #$01
; Apply low-byte additive step
bra_apply_lo_step_add:
    LDA (zp_work2),Y  ; 001F 0021 0023 0025 0027 0029 002B 002D
    CLC
    ADC ram_ghost_move_fraction,X
    STA (zp_work2),Y  ; 001F 0021 0023 0025 0027 0029 002B 002D
    LDA #$00
    ADC ram_ghost_move_pixels,X
    STA ram_movement_step_budget
    JMP loc_step_hi_budget_loop

; Step negative on low-byte axis
handler_step_lo_neg_axis:
    LDY #$03
    BNE bra_apply_lo_step_sub  ; jmp

; Step negative on alternate low-byte axis
handler_step_lo_neg_axis_alt:
    LDY #$01
; Apply low-byte subtractive step
bra_apply_lo_step_sub:
    LDA (zp_work2),Y  ; 001F 0021 0023 0025 0027 0029 002B 002D
    SEC
    SBC ram_ghost_move_fraction,X
    STA (zp_work2),Y  ; 001F 0021 0023 0025 0027 0029 002B 002D
    LDA #$00
    BCS bra_fold_borrow_into_hi_steps
    LDA #$01
; Fold low-byte borrow into high-byte step budget
bra_fold_borrow_into_hi_steps:
    CLC
    ADC ram_ghost_move_pixels,X
    STA ram_movement_step_budget
; High-byte step budget loop
loc_step_hi_budget_loop:
    DEC ram_movement_step_budget
    BPL bra_dispatch_hi_axis_step
    RTS
; Dispatch high-byte axis step handler
bra_dispatch_hi_axis_step:
    LDA ram_ghost_direction,X
    ASL
    TAY
    LDA tbl_axis_step_hi_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_axis_step_hi_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; High-byte axis step handlers by direction
tbl_axis_step_hi_handlers:
    .word handler_hi_step_neg_y
    .word handler_hi_step_neg_x
    .word handler_hi_step_pos_y
    .word handler_hi_step_pos_x

; High-byte step: negative Y
handler_hi_step_neg_y:
    LDA #$FF
    STA zp_work5
    BNE bra_prepare_y_axis_update  ; jmp

; High-byte step: positive Y
handler_hi_step_pos_y:
    LDA #$01
    STA zp_work5
; Prepare Y-axis high-byte update
bra_prepare_y_axis_update:
    LDY #$02
    BNE bra_apply_hi_axis_delta  ; jmp

; High-byte step: positive X
handler_hi_step_pos_x:
    LDA #$01
    STA zp_work5
    BNE bra_prepare_x_axis_update  ; jmp

; High-byte step: negative X
handler_hi_step_neg_x:
    LDA #$FF
    STA zp_work5
; Prepare X-axis high-byte update
bra_prepare_x_axis_update:
    LDY #$00
; Apply high-byte axis delta
bra_apply_hi_axis_delta:
    LDA (zp_work2),Y  ; 001E 0020 0022 0024 0026 0028 002A 002C
    CLC
    ADC zp_work5
    STA (zp_work2),Y  ; 001E 0020 0022 0024 0026 0028 002A 002C
    LDY #$00
    LDA (zp_work2),Y  ; 001E 0022 0026 002A
    CMP #$0A
    BNE bra_check_right_wrap_candidate
    LDA #$BF
    STA (zp_work2),Y  ; 001E 0022 0026 002A
    BNE bra_set_tunnel_palette_bit  ; jmp
; Check right tunnel wrap candidate
bra_check_right_wrap_candidate:
    CMP #$C0
    BNE bra_check_tunnel_palette_window
    LDA #$0B
    STA (zp_work2),Y  ; 001E 0022 0026 002A
    BNE bra_set_tunnel_palette_bit  ; jmp
; Check tunnel palette range window
bra_check_tunnel_palette_window:
    CMP #$18
    BCC bra_set_tunnel_palette_bit
    CMP #$A9
    BCC bra_clear_tunnel_palette_bit
; Set tunnel palette bit
bra_set_tunnel_palette_bit:
    LDA #$20
    BNE bra_apply_ghost_palette_flag  ; jmp
; Clear tunnel palette bit
bra_clear_tunnel_palette_bit:
    LDA #$00
; Apply tunnel palette flag to ghost sprite attrs
bra_apply_ghost_palette_flag:
    STA zp_work5
    TXA
    LSR
    TAY
    LDA ram_spr_pal + $01,Y
    AND #$DF
    ORA zp_work5
    STA ram_spr_pal + $01,Y
    LDY #$00
    LDA (zp_work2),Y  ; 001E 0022 0026 002A
    LDY #$02
    ORA (zp_work2),Y  ; 0020 0024 0028 002C
    AND #$07
    BEQ bra_check_house_entry_trigger
    JMP loc_step_hi_budget_loop
; Check ghost-house entry trigger point
bra_check_house_entry_trigger:
    LDY #$00
    LDA (zp_work2),Y  ; 001E 0022 0026 002A
    CMP #$60
    BNE bra_handle_state06_targeting
    LDY #$02
    LDA (zp_work2),Y  ; 0020 0024 0028 002C
    CMP #$70
    BNE bra_handle_state06_targeting
    LDA #con_ghost_state_exiting_house
    STA ram_ghost_state,X
    LDA #$00
    CLC
    SBC zp_work4
    AND ram_frightened_ghost_mask
    STA ram_frightened_ghost_mask
    TXA
    LSR
    TAY
    STA zp_work5
    LDA ram_spr_pal + $01,Y
    AND #$FC
    ORA zp_work5
    STA ram_spr_pal + $01,Y
    RTS
; State 06 targeting branch
bra_handle_state06_targeting:
    LDA ram_ghost_state,X
    CMP #con_ghost_state_returning_eyes
    BNE bra_select_target_mode
    LDA #$60
    STA ram_ghost_target_x
    LDA #$6F
    STA ram_ghost_target_y
    JMP loc_choose_next_direction
; Select target mode based on frightened/scatter flags
bra_select_target_mode:
; Priority:
; 1) frightened flag path -> pseudo-random legal turn pick
; 2) scatter/chase gate -> corner target or slot-specific chase formula
    LDA zp_work4
    AND ram_frightened_ghost_mask
    BNE bra_pick_turn_from_tile_options
    LDA zp_work4
    AND ram_shared_state_0
    BNE bra_dispatch_target_formula
    TXA
    TAY
    LDA tbl_corner_targets,Y
    STA ram_ghost_target_x
    LDA tbl_corner_targets + $01,Y
    STA ram_ghost_target_y
    JMP loc_choose_next_direction

; Fixed corner target coordinates
tbl_corner_targets:
    .byte $A8, $08  ; 00
    .byte $18, $08  ; 02
    .byte $A8, $D0  ; 04
    .byte $18, $D0  ; 06

; Dispatch per-ghost target formula
bra_dispatch_target_formula:
    TXA
    TAY
    LDA tbl_target_formula_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_target_formula_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Per-ghost target formula handlers
tbl_target_formula_handlers:
    .word handler_target_formula_slot0
    .word handler_target_formula_slot1
    .word handler_target_formula_slot2
    .word handler_target_formula_slot3

; Target formula for slot 3 ghost
handler_target_formula_slot3:
    LDA ram_obj_pos_X_hi
    SEC
    SBC ram_obj_pos_X_hi + $10
    BCS bra_check_target_dx_window
    STA zp_work5
    LDA #$00
    SEC
    SBC zp_work5
; Check X-distance threshold for slot 3 formula
bra_check_target_dx_window:
    CMP #$20
    BCS bra_use_player_position_target
    LDA ram_obj_pos_Y_hi
    SEC
    SBC ram_obj_pos_Y_hi + $10
    BCS bra_check_target_dy_window
    STA zp_work5
    LDA #$00
    SEC
    SBC zp_work5
; Check Y-distance threshold for slot 3 formula
bra_check_target_dy_window:
    CMP #$20
    BCS bra_use_player_position_target
; Pick turn direction from available tile exits
bra_pick_turn_from_tile_options:
    LDA ram_frame_cnt
    STA zp_work5
    LDA #$05
    STA zp_work6
; Scan candidate exits at current tile
bra_scan_open_exits:
    DEC zp_work6
    BNE bra_try_next_exit_seed
    LDA #con_direction_down
    BNE bra_store_selected_direction  ; jmp
; Try next seeded exit direction
bra_try_next_exit_seed:
    INC zp_work5
    LDA zp_work5
    AND #con_direction_mask
    TAY
    LDA (zp_work0),Y  ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    AND #$F8
    BNE bra_scan_open_exits
    LDA zp_work5
    CLC
    ADC #con_direction_reverse_delta
    AND #con_direction_mask
    CMP ram_ghost_direction,X
    BEQ bra_scan_open_exits
    LDA zp_work5
    AND #con_direction_mask
; Store selected movement direction
bra_store_selected_direction:
    STA ram_ghost_direction,X
    JMP loc_step_hi_budget_loop
; Fallback to direct player-position target
bra_use_player_position_target:
; Target formula for slot 0 ghost
handler_target_formula_slot0:
    LDA ram_obj_pos_X_hi
    STA ram_ghost_target_x
    LDA ram_obj_pos_Y_hi
    STA ram_ghost_target_y
    BNE bra_choose_next_direction
; Target formula for slot 1 ghost
handler_target_formula_slot1:
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_dir_target_offsets,Y
    CLC
    ADC ram_obj_pos_X_hi
    STA ram_ghost_target_x
    LDA tbl_dir_target_offsets + $01,Y
    CLC
    ADC ram_obj_pos_Y_hi
    STA ram_ghost_target_y
    JMP loc_choose_next_direction

; Direction-based target offsets
tbl_dir_target_offsets:
    .byte $00, $E8  ; 00
    .byte $E8, $00  ; 01
    .byte $00, $18  ; 02
    .byte $18, $00  ; 03

; Target formula for slot 2 ghost
handler_target_formula_slot2:
    LDA ram_obj_pos_X_hi
    SEC
    SBC ram_obj_pos_X_hi + $04
    CLC
    ADC ram_obj_pos_X_hi
    STA ram_ghost_target_x
    LDA ram_obj_pos_Y_hi
    SEC
    SBC ram_obj_pos_Y_hi + $04
    CLC
    ADC ram_obj_pos_Y_hi
    STA ram_ghost_target_y
; Choose a non-reverse direction from cached legal exits and the current target
; Inputs: X=ghost slot, zp_work0=neighbor tiles, zp_work2=position,
; ram_ghost_target_x/y=current target
; Output: ram_ghost_direction,X; X is preserved
; Clobbers: A, Y and zp_work5..zp_work14
bra_choose_next_direction:
; Choose next movement direction via path candidates
loc_choose_next_direction:
    LDA ram_ghost_state,X
    SEC
    SBC #con_ghost_state_active
    TAY
    LDA tbl_forbidden_turn_mask_by_state,Y
    STA zp_work9
    LDA tbl_forbidden_turn_mask_by_state + $01,Y
    STA zp_work10
    JSR sub_collect_valid_turn_candidates
    LDA zp_work11
    CMP #$FF
    BNE bra_check_candidate_b
    LDA #con_direction_down
    BNE bra_commit_direction_choice  ; jmp
; Check second direction candidate validity
bra_check_candidate_b:
    LDA zp_work12
    CMP #$FF
    BNE bra_rank_direction_candidates
    LDA zp_work11
; Commit chosen direction
bra_commit_direction_choice:
    STA ram_ghost_direction,X
    RTS
; Rank candidate directions by target distance
bra_rank_direction_candidates:
    LDY #$00
    STY zp_work5
    LDA ram_ghost_target_x
    SEC
    SBC (zp_work2),Y  ; 001E 0022 0026 002A
    BCS bra_store_abs_dx
    STA zp_work8
    LDA #$00
    SEC
    SBC zp_work8
    INC zp_work5
    INC zp_work5
    INC zp_work5
    INC zp_work5
; Store absolute X distance to target
bra_store_abs_dx:
    STA zp_work6
    LDA ram_ghost_target_y
    LDY #$02
    SEC
    SBC (zp_work2),Y  ; 0020 0024 0028 002C
    BCS bra_store_abs_dy
    STA zp_work8
    LDA #$00
    SEC
    SBC zp_work8
    INC zp_work5
    INC zp_work5
; Store absolute Y distance to target
bra_store_abs_dy:
    STA zp_work7
    LDA zp_work6
    CMP zp_work7
    BCS bra_prepare_candidate_pair_scan
    INC zp_work5
; Prepare candidate-pair scan
bra_prepare_candidate_pair_scan:
    LDA zp_work5
    ASL
    STA zp_work5
    LDA #$02
    STA zp_work6
; Try ranked direction candidates
bra_try_ranked_direction:
    LDY zp_work5
    LDA tbl_ranked_dir_order_lut,Y
    LDY #$00
; Match ranked candidate against valid exits
bra_match_candidate_against_valid:
    CMP zp_work11,Y
    BEQ bra_commit_direction_choice
    INY
    CPY #$04
    BNE bra_match_candidate_against_valid
    INC zp_work5
    DEC zp_work6
    BNE bra_try_ranked_direction
    LDA ram_ghost_direction,X
    SEC
    SBC #$01
    AND #con_direction_mask
    LDY #$00
; Try alternate direction (left turn)
bra_try_turn_left_alt:
    CMP zp_work11,Y
    BEQ bra_commit_direction_choice
    INY
    CPY #$04
    BNE bra_try_turn_left_alt
    LDA ram_ghost_direction,X
    CLC
    ADC #$01
    AND #con_direction_mask
    LDY #$00
; Try alternate direction (right turn)
bra_try_turn_right_alt:
    CMP zp_work11,Y
    BEQ bra_commit_direction_choice
    INY
    CPY #$04
    BNE bra_try_turn_right_alt
    RTS

; Select ghost speed vector based on mode/state
