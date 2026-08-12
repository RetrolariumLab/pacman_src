; Actor animation, OAM construction, and PPU buffers

; Update Pac-Man animation frame from direction/alignment
sub_update_pacman_anim_frame:		; was: sub_D8F9
    LDA ram_direction_2
    ASL
    CLC
    ADC #$02
    STA zp_work0
    LDA ram_obj_pos_X_hi
    ORA ram_obj_pos_Y_hi
    AND #$07
    BNE bra_advance_anim_phase_counter
    LDY ram_direction_2
    LDA ram_obj_ppu_tile_direction,Y  ; 022B 022C 022D 022E
    AND #$F0
    BEQ bra_advance_anim_phase_counter
    LDA ram_pacman_anim_phase
    AND #$03
    JMP loc_build_anim_frame_index
; Advance animation phase counter
bra_advance_anim_phase_counter:		; was: bra_D919
    INC ram_pacman_anim_phase
    LDA ram_pacman_anim_phase
; Build final Pac-Man anim frame index
loc_build_anim_frame_index:		; was: loc_D91D
    AND #$07
    CMP #$06
    BCC bra_use_anim_phase_lut
    LDA #$01
    BNE bra_store_anim_frame    ; jmp
; Use animation phase LUT
bra_use_anim_phase_lut:		; was: bra_D927
    TAY
    LDA tbl_pacman_anim_phase_lut,Y
    CLC
    ADC zp_work0
; Store computed Pac-Man animation frame
bra_store_anim_frame:		; was: bra_D92E
    STA ram_animation
    RTS

; Pac-Man animation phase LUT
tbl_pacman_anim_phase_lut:		; was: tbl_D931
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $01   ; 03
    .byte $01   ; 04
    .byte $00   ; 05

; Update ghost animation frames for all slots
sub_update_ghost_anim_frames:		; was: sub_D937
    LDA #$00
    TAX
    STA zp_work0
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_init_anim_phase_offset
    LDA #$01
    STA zp_work0
; Initialize frame-phase offset
bra_init_anim_phase_offset:		; was: bra_D946
    LDA #$01
    STA zp_work1
; Loop over ghost slots for anim update
bra_update_ghost_anim_slot_loop:		; was: bra_D94A_loop
    JSR sub_dispatch_ghost_anim_handler
    ASL zp_work1
    INX
    INX
    CPX #$08
    BNE bra_update_ghost_anim_slot_loop
; State07 anim handler: no-op
handler_state07_anim_noop:		; was: ofs_011_D955_07_RTS
    RTS

; Dispatch ghost animation handler by state
sub_dispatch_ghost_anim_handler:		; was: sub_D956
    LDY ram_ghost_state,X
    LDA tbl_ghost_anim_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_ghost_anim_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Ghost animation handlers by state
tbl_ghost_anim_handlers:		; was: tbl_D965
    .word handler_state00_anim_default
    .word handler_state02_anim_default
    .word handler_state04_anim_default
    .word handler_state06_anim_eyes
    .word handler_state07_anim_noop

; Build base anim frame from direction
bra_build_anim_frame_from_direction:		; was: bra_D96F
    LDA ram_ghost_direction,X
    STA zp_work3
    LDA #$0A
; Accumulate frame offset by direction
bra_accumulate_anim_frame_offset:		; was: bra_D975_loop
    DEC zp_work3
    BMI bra_apply_anim_phase_offset
    CLC
    ADC #$02
    BNE bra_accumulate_anim_frame_offset
; Apply global phase offset to frame
bra_apply_anim_phase_offset:		; was: bra_D97E
    CLC
    ADC zp_work0
    STA zp_work2
; Store ghost anim frame for current slot
bra_store_ghost_anim_frame:		; was: bra_D983
    TXA
    LSR
    TAY
    LDA zp_work2
    STA ram_animation + $01,Y
    RTS

; State00 anim handler
handler_state00_anim_default:		; was: ofs_011_D98C_00
; State02 anim handler
handler_state02_anim_default:		; was: ofs_011_D98C_02
; State04 anim handler
handler_state04_anim_default:		; was: ofs_011_D98C_04
    LDA zp_work1
    AND ram_shared_state_1
    BEQ bra_build_anim_frame_from_direction
    LDA #$1E
    STA zp_work2
    BNE bra_apply_anim_phase_offset    ; jmp

; State06 anim handler (eyes)
handler_state06_anim_eyes:		; was: ofs_011_D998_06
    LDA ram_ghost_direction,X
    STA zp_work3
    LDA #$20
; Accumulate eyes animation offset
bra_accumulate_eyes_anim_offset:		; was: bra_D99E_loop
    DEC zp_work3
    BMI bra_store_eyes_anim_offset
    CLC
    ADC #$01
    BNE bra_accumulate_eyes_anim_offset    ; jmp
; Store eyes animation offset
bra_store_eyes_anim_offset:		; was: bra_D9A7
    STA zp_work2
    BMI bra_store_ghost_anim_frame    ; jmp

; Prepare sprite positions and resolve overlap ordering
sub_prepare_sprite_positions:		; was: sub_D9AB
    LDX #$23
; Copy object positions to sprite position buffer
bra_copy_obj_to_sprite_pos:		; was: bra_D9AD_loop
    LDA ram_obj_position,X
    STA ram_spr_position,X
    DEX
    BPL bra_copy_obj_to_sprite_pos
    LoadPointer zp_work0, (ram_spr_pos_X_hi + $04 + $0C)
    LDA #$08
    STA zp_work3
    LDA #$03
    STA zp_work2
; Resolve sprite overlap ordering loop
loc_overlap_resolution_loop:		; was: loc_D9C5_loop
    LDA zp_work3
    AND ram_shared_state_1
    BNE bra_next_overlap_candidate
    LDY #$00
    LDA ram_spr_pos_X_hi
    CMP (zp_work0),Y    ; 0278 027C 0280 0284
    BCS bra_abs_dx_alt
    LDA (zp_work0),Y    ; 0278 027C 0280 0284
    SEC
    SBC ram_spr_pos_X_hi
    BCS bra_check_overlap_dx
; Alternate absolute X difference branch
bra_abs_dx_alt:		; was: bra_D9DC
    SBC (zp_work0),Y    ; 0278 027C 0280 0284
; Check overlap X threshold
bra_check_overlap_dx:		; was: bra_D9DE
    CMP #$19
    BCS bra_next_overlap_candidate
    STA zp_work4
    LDY #$02
    LDA ram_spr_pos_Y_hi
    CMP (zp_work0),Y    ; 027A 027E 0282 0286
    BCS bra_abs_dy_alt
    LDA (zp_work0),Y    ; 027A 027E 0282 0286
    SEC
    SBC ram_spr_pos_Y_hi
    BCS bra_check_overlap_dy
; Alternate absolute Y difference branch
bra_abs_dy_alt:		; was: bra_D9F5
    SBC (zp_work0),Y    ; 027A 027E 0282 0286
; Check overlap Y threshold
bra_check_overlap_dy:		; was: bra_D9F7
    CMP #$19
    BCS bra_next_overlap_candidate
    ADC zp_work4
    CMP #$10
    BCS bra_next_overlap_candidate
    LDA ram_spr_pos_X_hi
    STA zp_work3
    LDA ram_spr_pos_Y_hi
    STA zp_work4
    LDA ram_actor_sprite_set
    STA zp_work5
    LDA ram_actor_sprite_attrs
    STA zp_work6
    LDY #$00
    LDA (zp_work0),Y    ; 0278 027C 0280 0284
    STA ram_spr_pos_X_hi
    LDA zp_work3
    STA (zp_work0),Y    ; 0278 027C 0280 0284
    LDY #$02
    LDA (zp_work0),Y    ; 027A 027E 0282 0286
    STA ram_spr_pos_Y_hi
    LDA zp_work4
    STA (zp_work0),Y    ; 027A 027E 0282 0286
    LDX zp_work2
    LDA ram_actor_sprite_set + $01,X
    STA ram_actor_sprite_set
    LDA zp_work5
    STA ram_actor_sprite_set + $01,X
    LDA ram_actor_sprite_attrs + $01,X
    STA ram_actor_sprite_attrs
    LDA zp_work6
    STA ram_actor_sprite_attrs + $01,X
    JMP loc_finalize_positions
; Advance to next overlap candidate
bra_next_overlap_candidate:		; was: bra_DA46
    LDA zp_work0
    SEC
    SBC #$04
    STA zp_work0
    LSR zp_work3
    DEC zp_work2
    BMI bra_finalize_positions
    JMP loc_overlap_resolution_loop
; Finalize positions and continue to OAM compose
bra_finalize_positions:		; was: bra_DA56
; Finalize positions and continue to OAM compose
loc_finalize_positions:		; was: loc_DA56
    JSR sub_build_object_neighbor_ppu_positions
    JMP loc_build_oam_from_sprite_buffers

; Build final OAM entries from sprite buffers
