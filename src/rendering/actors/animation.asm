; Actor animation, OAM construction, and PPU buffers




; Update Pac-Man animation frame from direction/alignment
sub_D8F9_update_pacman_anim_frame:		; was: sub_D8F9
    LDA ram_direction_2
    ASL
    CLC
    ADC #$02
    STA ram_0000
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_D919_advance_anim_phase_counter
    LDY ram_direction_2
    LDA ram_obj_ppu_tile_direction,Y  ; 022B 022C 022D 022E
    AND #$F0
    BEQ bra_D919_advance_anim_phase_counter
    LDA ram_00B7
    AND #$03
    JMP loc_D91D_build_anim_frame_index
; Advance animation phase counter
bra_D919_advance_anim_phase_counter:		; was: bra_D919
    INC ram_00B7
    LDA ram_00B7
; Build final Pac-Man anim frame index
loc_D91D_build_anim_frame_index:		; was: loc_D91D
    AND #$07
    CMP #$06
    BCC bra_D927_use_anim_phase_lut
    LDA #$01
    BNE bra_D92E_store_anim_frame    ; jmp
; Use animation phase LUT
bra_D927_use_anim_phase_lut:		; was: bra_D927
    TAY
    LDA tbl_D931_pacman_anim_phase_lut,Y
    CLC
    ADC ram_0000
; Store computed Pac-Man animation frame
bra_D92E_store_anim_frame:		; was: bra_D92E
    STA ram_animation
    RTS



; Pac-Man animation phase LUT
tbl_D931_pacman_anim_phase_lut:		; was: tbl_D931
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $01   ; 03
    .byte $01   ; 04
    .byte $00   ; 05



; Update ghost animation frames for all slots
sub_D937_update_ghost_anim_frames:		; was: sub_D937
    LDA #$00
    TAX
    STA ram_0000
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_D946_init_anim_phase_offset
    LDA #$01
    STA ram_0000
; Initialize frame-phase offset
bra_D946_init_anim_phase_offset:		; was: bra_D946
    LDA #$01
    STA ram_0001
; Loop over ghost slots for anim update
bra_D94A_update_ghost_anim_slot_loop:		; was: bra_D94A_loop
    JSR sub_D956_dispatch_ghost_anim_handler
    ASL ram_0001
    INX
    INX
    CPX #$08
    BNE bra_D94A_update_ghost_anim_slot_loop
; State07 anim handler: no-op
ofs_011_D955_state07_anim_noop:		; was: ofs_011_D955_07_RTS
    RTS



; Dispatch ghost animation handler by state
sub_D956_dispatch_ghost_anim_handler:		; was: sub_D956
    LDY ram_00B8,X
    LDA tbl_D965_ghost_anim_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_D965_ghost_anim_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Ghost animation handlers by state
tbl_D965_ghost_anim_handlers:		; was: tbl_D965
    .word ofs_011_D98C_state00_anim_default
    .word ofs_011_D98C_state02_anim_default
    .word ofs_011_D98C_state04_anim_default
    .word ofs_011_D998_state06_anim_eyes
    .word ofs_011_D955_state07_anim_noop



; Build base anim frame from direction
bra_D96F_build_anim_frame_from_direction:		; was: bra_D96F
    LDA ram_00B9,X
    STA ram_0003
    LDA #$0A
; Accumulate frame offset by direction
bra_D975_accumulate_anim_frame_offset:		; was: bra_D975_loop
    DEC ram_0003
    BMI bra_D97E_apply_anim_phase_offset
    CLC
    ADC #$02
    BNE bra_D975_accumulate_anim_frame_offset
; Apply global phase offset to frame
bra_D97E_apply_anim_phase_offset:		; was: bra_D97E
    CLC
    ADC ram_0000
    STA ram_0002
; Store ghost anim frame for current slot
bra_D983_store_ghost_anim_frame:		; was: bra_D983
    TXA
    LSR
    TAY
    LDA ram_0002
    STA ram_animation + $01,Y
    RTS



; State00 anim handler
ofs_011_D98C_state00_anim_default:		; was: ofs_011_D98C_00
; State02 anim handler
ofs_011_D98C_state02_anim_default:		; was: ofs_011_D98C_02
; State04 anim handler
ofs_011_D98C_state04_anim_default:		; was: ofs_011_D98C_04
    LDA ram_0001
    AND ram_0088
    BEQ bra_D96F_build_anim_frame_from_direction
    LDA #$1E
    STA ram_0002
    BNE bra_D97E_apply_anim_phase_offset    ; jmp



; State06 anim handler (eyes)
ofs_011_D998_state06_anim_eyes:		; was: ofs_011_D998_06
    LDA ram_00B9,X
    STA ram_0003
    LDA #$20
; Accumulate eyes animation offset
bra_D99E_accumulate_eyes_anim_offset:		; was: bra_D99E_loop
    DEC ram_0003
    BMI bra_D9A7_store_eyes_anim_offset
    CLC
    ADC #$01
    BNE bra_D99E_accumulate_eyes_anim_offset    ; jmp
; Store eyes animation offset
bra_D9A7_store_eyes_anim_offset:		; was: bra_D9A7
    STA ram_0002
    BMI bra_D983_store_ghost_anim_frame    ; jmp



; Prepare sprite positions and resolve overlap ordering
sub_D9AB_prepare_sprite_positions:		; was: sub_D9AB
    LDX #$23
; Copy object positions to sprite position buffer
bra_D9AD_copy_obj_to_sprite_pos:		; was: bra_D9AD_loop
    LDA ram_obj_position,X
    STA ram_spr_position,X
    DEX
    BPL bra_D9AD_copy_obj_to_sprite_pos
    LoadPointer ram_0000, (ram_spr_pos_X_hi + $04 + $0C)
    LDA #$08
    STA ram_0003
    LDA #$03
    STA ram_0002
; Resolve sprite overlap ordering loop
loc_D9C5_overlap_resolution_loop:		; was: loc_D9C5_loop
    LDA ram_0003
    AND ram_0088
    BNE bra_DA46_next_overlap_candidate
    LDY #$00
    LDA ram_spr_pos_X_hi
    CMP (ram_0000),Y    ; 0278 027C 0280 0284
    BCS bra_D9DC_abs_dx_alt
    LDA (ram_0000),Y    ; 0278 027C 0280 0284
    SEC
    SBC ram_spr_pos_X_hi
    BCS bra_D9DE_check_overlap_dx
; Alternate absolute X difference branch
bra_D9DC_abs_dx_alt:		; was: bra_D9DC
    SBC (ram_0000),Y    ; 0278 027C 0280 0284
; Check overlap X threshold
bra_D9DE_check_overlap_dx:		; was: bra_D9DE
    CMP #$19
    BCS bra_DA46_next_overlap_candidate
    STA ram_0004
    LDY #$02
    LDA ram_spr_pos_Y_hi
    CMP (ram_0000),Y    ; 027A 027E 0282 0286
    BCS bra_D9F5_abs_dy_alt
    LDA (ram_0000),Y    ; 027A 027E 0282 0286
    SEC
    SBC ram_spr_pos_Y_hi
    BCS bra_D9F7_check_overlap_dy
; Alternate absolute Y difference branch
bra_D9F5_abs_dy_alt:		; was: bra_D9F5
    SBC (ram_0000),Y    ; 027A 027E 0282 0286
; Check overlap Y threshold
bra_D9F7_check_overlap_dy:		; was: bra_D9F7
    CMP #$19
    BCS bra_DA46_next_overlap_candidate
    ADC ram_0004
    CMP #$10
    BCS bra_DA46_next_overlap_candidate
    LDA ram_spr_pos_X_hi
    STA ram_0003
    LDA ram_spr_pos_Y_hi
    STA ram_0004
    LDA ram_028C
    STA ram_0005
    LDA ram_0292
    STA ram_0006
    LDY #$00
    LDA (ram_0000),Y    ; 0278 027C 0280 0284
    STA ram_spr_pos_X_hi
    LDA ram_0003
    STA (ram_0000),Y    ; 0278 027C 0280 0284
    LDY #$02
    LDA (ram_0000),Y    ; 027A 027E 0282 0286
    STA ram_spr_pos_Y_hi
    LDA ram_0004
    STA (ram_0000),Y    ; 027A 027E 0282 0286
    LDX ram_0002
    LDA ram_028D,X
    STA ram_028C
    LDA ram_0005
    STA ram_028D,X
    LDA ram_0293,X
    STA ram_0292
    LDA ram_0006
    STA ram_0293,X
    JMP loc_DA56_finalize_positions
; Advance to next overlap candidate
bra_DA46_next_overlap_candidate:		; was: bra_DA46
    LDA ram_0000
    SEC
    SBC #$04
    STA ram_0000
    LSR ram_0003
    DEC ram_0002
    BMI bra_DA56_finalize_positions
    JMP loc_D9C5_overlap_resolution_loop
; Finalize positions and continue to OAM compose
bra_DA56_finalize_positions:		; was: bra_DA56
; Finalize positions and continue to OAM compose
loc_DA56_finalize_positions:		; was: loc_DA56
    JSR sub_E154_build_object_neighbor_ppu_positions
    JMP loc_DA5C_build_oam_from_sprite_buffers



; Build final OAM entries from sprite buffers
