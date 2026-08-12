; Ghost movement, targeting, path selection, and direction ranking




; Iterate ghost slots and run per-state movement/update logic
; Core enemy AI dispatcher: state machine, targeting formulas, and speed profiles.
; Per ghost slot update pipeline:
; 1) state dispatch (house enter/exit, move logic, noop)
; 2) speed vector select by mode/state
; 3) low-byte move + carry/borrow accumulation
; 4) high-byte move loop, tunnel wrap, palette flag update
; 5) on tile centers choose next direction (targeted or seeded/randomized)
sub_D4C2_update_ghost_slots:		; was: sub_D4C2
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
; Loop over 4 ghost slots (X+=2)
bra_D4D8_update_ghost_slot_loop:		; was: bra_D4D8_loop
    JSR sub_D4F2_dispatch_ghost_state_handler
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
    BNE bra_D4D8_update_ghost_slot_loop
    RTS
; Dispatch ghost update handler by state in ram_00B8
; ram_00B8: ghost state, ram_00B9: ghost direction, ram_00BA/00BB: release queue slots
sub_D4F2_dispatch_ghost_state_handler:		; was: sub_D4F2
    LDY ram_00B8,X
    LDA tbl_D501_ghost_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D501_ghost_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Ghost state handler jump table
tbl_D501_ghost_state_handlers:		; was: tbl_D501
    .word ofs_006_D840_state00_enter_house
    .word ofs_006_D7F0_state02_exit_house
    .word ofs_006_D50C_state04_move_logic
    .word ofs_006_D50C_state06_move_logic
    .word ofs_006_D50B_state08_noop



; State 08 handler: no-op
ofs_006_D50B_state08_noop:		; was: ofs_006_D50B_08_RTS
    RTS



; State 04 handler: movement/target logic
ofs_006_D50C_state04_move_logic:		; was: ofs_006_D50C_04
; State 06 handler: movement/target logic
ofs_006_D50C_state06_move_logic:		; was: ofs_006_D50C_06
; Shared mover for normal chase/scatter (04) and eyes-return (06) paths.
    JSR sub_D78C_select_ghost_speed_vector
    LDA ram_00B9,X
    ASL
    TAY
    LDA tbl_D520_axis_step_lo_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D520_axis_step_lo_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Low-byte axis step handlers by direction
tbl_D520_axis_step_lo_handlers:		; was: tbl_D520
    .word ofs_007_D53E_step_lo_neg_axis
    .word ofs_007_D542_step_lo_neg_axis_alt
    .word ofs_007_D528_step_lo_pos_axis
    .word ofs_007_D52C_step_lo_pos_axis_alt



; Step positive on low-byte axis
ofs_007_D528_step_lo_pos_axis:		; was: ofs_007_D528_02
    LDY #$03
    BNE bra_D52E_apply_lo_step_add    ; jmp



; Step positive on alternate low-byte axis
ofs_007_D52C_step_lo_pos_axis_alt:		; was: ofs_007_D52C_03
    LDY #$01
; Apply low-byte additive step
bra_D52E_apply_lo_step_add:		; was: bra_D52E
    LDA (ram_0002),Y    ; 001F 0021 0023 0025 0027 0029 002B 002D
    CLC
    ADC ram_00C2,X
    STA (ram_0002),Y    ; 001F 0021 0023 0025 0027 0029 002B 002D
    LDA #$00
    ADC ram_00C3,X
    STA ram_00CC
    JMP loc_D556_step_hi_budget_loop



; Step negative on low-byte axis
ofs_007_D53E_step_lo_neg_axis:		; was: ofs_007_D53E_00
    LDY #$03
    BNE bra_D544_apply_lo_step_sub    ; jmp



; Step negative on alternate low-byte axis
ofs_007_D542_step_lo_neg_axis_alt:		; was: ofs_007_D542_01
    LDY #$01
; Apply low-byte subtractive step
bra_D544_apply_lo_step_sub:		; was: bra_D544
    LDA (ram_0002),Y    ; 001F 0021 0023 0025 0027 0029 002B 002D
    SEC
    SBC ram_00C2,X
    STA (ram_0002),Y    ; 001F 0021 0023 0025 0027 0029 002B 002D
    LDA #$00
    BCS bra_D551_fold_borrow_into_hi_steps
    LDA #$01
; Fold low-byte borrow into high-byte step budget
bra_D551_fold_borrow_into_hi_steps:		; was: bra_D551
    CLC
    ADC ram_00C3,X
    STA ram_00CC
; High-byte step budget loop
loc_D556_step_hi_budget_loop:		; was: loc_D556
    DEC ram_00CC
    BPL bra_D55B_dispatch_hi_axis_step
    RTS
; Dispatch high-byte axis step handler
bra_D55B_dispatch_hi_axis_step:		; was: bra_D55B
    LDA ram_00B9,X
    ASL
    TAY
    LDA tbl_D56C_axis_step_hi_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D56C_axis_step_hi_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; High-byte axis step handlers by direction
tbl_D56C_axis_step_hi_handlers:		; was: tbl_D56C
    .word ofs_008_D574_hi_step_neg_y
    .word ofs_008_D588_hi_step_neg_x
    .word ofs_008_D57A_hi_step_pos_y
    .word ofs_008_D582_hi_step_pos_x



; High-byte step: negative Y
ofs_008_D574_hi_step_neg_y:		; was: ofs_008_D574_00
    LDA #$FF
    STA ram_0005
    BNE bra_D57E_prepare_y_axis_update    ; jmp



; High-byte step: positive Y
ofs_008_D57A_hi_step_pos_y:		; was: ofs_008_D57A_02
    LDA #$01
    STA ram_0005
; Prepare Y-axis high-byte update
bra_D57E_prepare_y_axis_update:		; was: bra_D57E
    LDY #$02
    BNE bra_D58E_apply_hi_axis_delta    ; jmp



; High-byte step: positive X
ofs_008_D582_hi_step_pos_x:		; was: ofs_008_D582_03
    LDA #$01
    STA ram_0005
    BNE bra_D58C_prepare_x_axis_update    ; jmp



; High-byte step: negative X
ofs_008_D588_hi_step_neg_x:		; was: ofs_008_D588_01
    LDA #$FF
    STA ram_0005
; Prepare X-axis high-byte update
bra_D58C_prepare_x_axis_update:		; was: bra_D58C
    LDY #$00
; Apply high-byte axis delta
bra_D58E_apply_hi_axis_delta:		; was: bra_D58E
    LDA (ram_0002),Y    ; 001E 0020 0022 0024 0026 0028 002A 002C
    CLC
    ADC ram_0005
    STA (ram_0002),Y    ; 001E 0020 0022 0024 0026 0028 002A 002C
    LDY #$00
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    CMP #$0A
    BNE bra_D5A3_check_right_wrap_candidate
    LDA #$BF
    STA (ram_0002),Y    ; 001E 0022 0026 002A
    BNE bra_D5B5_set_tunnel_palette_bit    ; jmp
; Check right tunnel wrap candidate
bra_D5A3_check_right_wrap_candidate:		; was: bra_D5A3
    CMP #$C0
    BNE bra_D5AD_check_tunnel_palette_window
    LDA #$0B
    STA (ram_0002),Y    ; 001E 0022 0026 002A
    BNE bra_D5B5_set_tunnel_palette_bit    ; jmp
; Check tunnel palette range window
bra_D5AD_check_tunnel_palette_window:		; was: bra_D5AD
    CMP #$18
    BCC bra_D5B5_set_tunnel_palette_bit
    CMP #$A9
    BCC bra_D5B9_clear_tunnel_palette_bit
; Set tunnel palette bit
bra_D5B5_set_tunnel_palette_bit:		; was: bra_D5B5
    LDA #$20
    BNE bra_D5BB_apply_ghost_palette_flag    ; jmp
; Clear tunnel palette bit
bra_D5B9_clear_tunnel_palette_bit:		; was: bra_D5B9
    LDA #$00
; Apply tunnel palette flag to ghost sprite attrs
bra_D5BB_apply_ghost_palette_flag:		; was: bra_D5BB
    STA ram_0005
    TXA
    LSR
    TAY
    LDA ram_spr_pal + $01,Y
    AND #$DF
    ORA ram_0005
    STA ram_spr_pal + $01,Y
    LDY #$00
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    LDY #$02
    ORA (ram_0002),Y    ; 0020 0024 0028 002C
    AND #$07
    BEQ bra_D5D9_check_house_entry_trigger
    JMP loc_D556_step_hi_budget_loop
; Check ghost-house entry trigger point
bra_D5D9_check_house_entry_trigger:		; was: bra_D5D9
    LDY #$00
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    CMP #$60
    BNE bra_D606_handle_state06_targeting
    LDY #$02
    LDA (ram_0002),Y    ; 0020 0024 0028 002C
    CMP #$70
    BNE bra_D606_handle_state06_targeting
    LDA #$02
    STA ram_00B8,X
    LDA #$00
    CLC
    SBC ram_0004
    AND ram_0088
    STA ram_0088
    TXA
    LSR
    TAY
    STA ram_0005
    LDA ram_spr_pal + $01,Y
    AND #$FC
    ORA ram_0005
    STA ram_spr_pal + $01,Y
    RTS
; State 06 targeting branch
bra_D606_handle_state06_targeting:		; was: bra_D606
    LDA ram_00B8,X
    CMP #$06
    BNE bra_D617_select_target_mode
    LDA #$60
    STA ram_00CD
    LDA #$6F
    STA ram_00CE
    JMP loc_D6E3_choose_next_direction
; Select target mode based on frightened/scatter flags
bra_D617_select_target_mode:		; was: bra_D617
; Priority:
; 1) frightened flag path -> pseudo-random legal turn pick
; 2) scatter/chase gate -> corner target or slot-specific chase formula
    LDA ram_0004
    AND ram_0088
    BNE bra_D675_pick_turn_from_tile_options
    LDA ram_0004
    AND ram_0087
    BNE bra_D63A_dispatch_target_formula
    TXA
    TAY
    LDA tbl_D632_corner_targets,Y
    STA ram_00CD
    LDA tbl_D632_corner_targets + $01,Y
    STA ram_00CE
    JMP loc_D6E3_choose_next_direction



; Fixed corner target coordinates
tbl_D632_corner_targets:		; was: tbl_D632
    .byte $A8, $08   ; 00
    .byte $18, $08   ; 02
    .byte $A8, $D0   ; 04
    .byte $18, $D0   ; 06



; Dispatch per-ghost target formula
bra_D63A_dispatch_target_formula:		; was: bra_D63A
    TXA
    TAY
    LDA tbl_D649_target_formula_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D649_target_formula_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Per-ghost target formula handlers
tbl_D649_target_formula_handlers:		; was: tbl_D649
    .word ofs_009_D6A6_target_formula_slot0
    .word ofs_009_D6B0_target_formula_slot1
    .word ofs_009_D6CF_target_formula_slot2
    .word ofs_009_D651_target_formula_slot3



; Target formula for slot 3 ghost
ofs_009_D651_target_formula_slot3:		; was: ofs_009_D651_06
    LDA ram_obj_pos_X_hi
    SEC
    SBC ram_obj_pos_X_hi + $10
    BCS bra_D65F_check_target_dx_window
    STA ram_0005
    LDA #$00
    SEC
    SBC ram_0005
; Check X-distance threshold for slot 3 formula
bra_D65F_check_target_dx_window:		; was: bra_D65F
    CMP #$20
    BCS bra_D6A6_use_player_position_target
    LDA ram_obj_pos_Y_hi
    SEC
    SBC ram_obj_pos_Y_hi + $10
    BCS bra_D671_check_target_dy_window
    STA ram_0005
    LDA #$00
    SEC
    SBC ram_0005
; Check Y-distance threshold for slot 3 formula
bra_D671_check_target_dy_window:		; was: bra_D671
    CMP #$20
    BCS bra_D6A6_use_player_position_target
; Pick turn direction from available tile exits
bra_D675_pick_turn_from_tile_options:		; was: bra_D675
    LDA ram_frame_cnt
    STA ram_0005
    LDA #$05
    STA ram_0006
; Scan candidate exits at current tile
bra_D67D_scan_open_exits:		; was: bra_D67D_loop
    DEC ram_0006
    BNE bra_D685_try_next_exit_seed
    LDA #$02
    BNE bra_D6A1_store_selected_direction    ; jmp
; Try next seeded exit direction
bra_D685_try_next_exit_seed:		; was: bra_D685
    INC ram_0005
    LDA ram_0005
    AND #$03
    TAY
    LDA (ram_0000),Y    ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    AND #$F8
    BNE bra_D67D_scan_open_exits
    LDA ram_0005
    CLC
    ADC #$02
    AND #$03
    CMP ram_00B9,X
    BEQ bra_D67D_scan_open_exits
    LDA ram_0005
    AND #$03
; Store selected movement direction
bra_D6A1_store_selected_direction:		; was: bra_D6A1
    STA ram_00B9,X
    JMP loc_D556_step_hi_budget_loop
; Fallback to direct player-position target
bra_D6A6_use_player_position_target:		; was: bra_D6A6
; Target formula for slot 0 ghost
ofs_009_D6A6_target_formula_slot0:		; was: ofs_009_D6A6_00
    LDA ram_obj_pos_X_hi
    STA ram_00CD
    LDA ram_obj_pos_Y_hi
    STA ram_00CE
    BNE bra_D6E3_choose_next_direction
; Target formula for slot 1 ghost
ofs_009_D6B0_target_formula_slot1:		; was: ofs_009_D6B0_02
    LDA ram_direction_2
    ASL
    TAY
    LDA tbl_D6C7_dir_target_offsets,Y
    CLC
    ADC ram_obj_pos_X_hi
    STA ram_00CD
    LDA tbl_D6C7_dir_target_offsets + $01,Y
    CLC
    ADC ram_obj_pos_Y_hi
    STA ram_00CE
    JMP loc_D6E3_choose_next_direction



; Direction-based target offsets
tbl_D6C7_dir_target_offsets:		; was: tbl_D6C7
    .byte $00, $E8   ; 00
    .byte $E8, $00   ; 01
    .byte $00, $18   ; 02
    .byte $18, $00   ; 03



; Target formula for slot 2 ghost
ofs_009_D6CF_target_formula_slot2:		; was: ofs_009_D6CF_04
    LDA ram_obj_pos_X_hi
    SEC
    SBC ram_obj_pos_X_hi + $04
    CLC
    ADC ram_obj_pos_X_hi
    STA ram_00CD
    LDA ram_obj_pos_Y_hi
    SEC
    SBC ram_obj_pos_Y_hi + $04
    CLC
    ADC ram_obj_pos_Y_hi
    STA ram_00CE
; Choose next movement direction via path candidates
bra_D6E3_choose_next_direction:		; was: bra_D6E3
; Choose next movement direction via path candidates
loc_D6E3_choose_next_direction:		; was: loc_D6E3
    LDA ram_00B8,X
    SEC
    SBC #$04
    TAY
    LDA tbl_D7EC_forbidden_turn_mask_by_state,Y
    STA ram_000A
    LDA tbl_D7EC_forbidden_turn_mask_by_state + $01,Y
    STA ram_000B
    JSR sub_E42B_collect_valid_turn_candidates
    LDA ram_000C
    CMP #$FF
    BNE bra_D700_check_candidate_b
    LDA #$02
    BNE bra_D708_commit_direction_choice    ; jmp
; Check second direction candidate validity
bra_D700_check_candidate_b:		; was: bra_D700
    LDA ram_000D
    CMP #$FF
    BNE bra_D70B_rank_direction_candidates
    LDA ram_000C
; Commit chosen direction
bra_D708_commit_direction_choice:		; was: bra_D708
    STA ram_00B9,X
    RTS
; Rank candidate directions by target distance
bra_D70B_rank_direction_candidates:		; was: bra_D70B
    LDY #$00
    STY ram_0005
    LDA ram_00CD
    SEC
    SBC (ram_0002),Y    ; 001E 0022 0026 002A
    BCS bra_D725_store_abs_dx
    STA ram_0008
    LDA #$00
    SEC
    SBC ram_0008
    INC ram_0005
    INC ram_0005
    INC ram_0005
    INC ram_0005
; Store absolute X distance to target
bra_D725_store_abs_dx:		; was: bra_D725
    STA ram_0006
    LDA ram_00CE
    LDY #$02
    SEC
    SBC (ram_0002),Y    ; 0020 0024 0028 002C
    BCS bra_D73B_store_abs_dy
    STA ram_0008
    LDA #$00
    SEC
    SBC ram_0008
    INC ram_0005
    INC ram_0005
; Store absolute Y distance to target
bra_D73B_store_abs_dy:		; was: bra_D73B
    STA ram_0007
    LDA ram_0006
    CMP ram_0007
    BCS bra_D745_prepare_candidate_pair_scan
    INC ram_0005
; Prepare candidate-pair scan
bra_D745_prepare_candidate_pair_scan:		; was: bra_D745
    LDA ram_0005
    ASL
    STA ram_0005
    LDA #$02
    STA ram_0006
; Try ranked direction candidates
bra_D74E_try_ranked_direction:		; was: bra_D74E
    LDY ram_0005
    LDA tbl_D7DC_ranked_dir_order_lut,Y
    LDY #$00
; Match ranked candidate against valid exits
bra_D755_match_candidate_against_valid:		; was: bra_D755_loop
    CMP ram_000C,Y
    BEQ bra_D708_commit_direction_choice
    INY
    CPY #$04
    BNE bra_D755_match_candidate_against_valid
    INC ram_0005
    DEC ram_0006
    BNE bra_D74E_try_ranked_direction
    LDA ram_00B9,X
    SEC
    SBC #$01
    AND #$03
    LDY #$00
; Try alternate direction (left turn)
bra_D76E_try_turn_left_alt:		; was: bra_D76E_loop
    CMP ram_000C,Y
    BEQ bra_D708_commit_direction_choice
    INY
    CPY #$04
    BNE bra_D76E_try_turn_left_alt
    LDA ram_00B9,X
    CLC
    ADC #$01
    AND #$03
    LDY #$00
; Try alternate direction (right turn)
bra_D781_try_turn_right_alt:		; was: bra_D781_loop
    CMP ram_000C,Y
    BEQ bra_D708_commit_direction_choice
    INY
    CPY #$04
    BNE bra_D781_try_turn_right_alt
    RTS



; Select ghost speed vector based on mode/state
