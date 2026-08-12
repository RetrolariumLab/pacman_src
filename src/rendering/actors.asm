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
    LDA #< (ram_spr_pos_X_hi + $04 + $0C)
    STA ram_0000
    LDA #> (ram_spr_pos_X_hi + $04 + $0C)
    STA ram_0001
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
sub_DA5C_build_oam_from_sprite_buffers:		; was: sub_DA5C
; Build final OAM entries from sprite buffers
loc_DA5C_build_oam_from_sprite_buffers:		; was: loc_DA5C
    LDA #< ram_spr_position
    STA ram_0000
    LDA #> ram_spr_position
    STA ram_0001
    LDA #< ram_oam
    STA ram_0002
    LDA #> ram_oam
    STA ram_0003
    LDA #$00
    STA ram_0004
; Process next sprite group
loc_DA70_next_sprite_group:		; was: loc_DA70
    LDA #$00
    STA ram_0005
    TAX
; Build OAM quad entries for current group
loc_DA75_build_oam_quad_loop:		; was: loc_DA75_loop
    LDY #$02
    LDA (ram_0000),Y    ; 0276 027A 027E 0282 0286 028A
    BNE bra_DA7F_apply_y_offset
    LDA #$FF
    BNE bra_DA83_store_oam_y    ; jmp
; Apply Y offset from sprite offset table
bra_DA7F_apply_y_offset:		; was: bra_DA7F
    CLC
    ADC tbl_DDC1_oam_quad_offsets,X
; Store OAM Y coordinate
bra_DA83_store_oam_y:		; was: bra_DA83
    LDY #$00
    STA (ram_0002),Y    ; 0700-075C (spr_Y)
    LDY ram_0004
    LDA ram_028C,Y
    ASL
    ROL
    ROL
    AND #$03
    BEQ bra_DABC_compose_sprite_set0
    CMP #$02
    BEQ bra_DB02_compose_sprite_set2
    BCC bra_DADF_compose_sprite_set1
; 03
    LDA ram_028C,Y
    ASL
    ASL
    CLC
    ADC ram_0005
    TAY
    STA ram_0006
    LDA tbl_DC8D_actor_sprite_attrs,Y
    LDY #$01
    STA (ram_0002),Y
    LDY ram_0004
    LDA ram_0292,Y
    LDY ram_0006
    ORA tbl_DDC1_oam_quad_offsets,Y
    LDY #$02
    STA (ram_0002),Y
    JMP loc_DB22_write_oam_quad_x_pass
; Compose sprite set 0 tiles/attrs
bra_DABC_compose_sprite_set0:		; was: bra_DABC_00
    LDA ram_028C,Y
    ASL
    ASL
    CLC
    ADC ram_0005
    TAY
    STA ram_0006
    LDA tbl_DB59_actor_sprite_tiles,Y
    LDY #$01
    STA (ram_0002),Y    ; 0701-075D (spr_T)
    LDY ram_0004
    LDA ram_0292,Y
    LDY ram_0006
    ORA tbl_DC8D_actor_sprite_attrs,Y
    LDY #$02
    STA (ram_0002),Y    ; 0702-075E (spr_A)
    JMP loc_DB22_write_oam_quad_x_pass
; Compose sprite set 1 tiles/attrs
bra_DADF_compose_sprite_set1:		; was: bra_DADF_01
    LDA ram_028C,Y
    ASL
    ASL
    CLC
    ADC ram_0005
    TAY
    STA ram_0006
    LDA tbl_DC59_actor_alt_sprite_tiles,Y
    LDY #$01
    STA (ram_0002),Y    ; 0701-072D and 0741-074D (spr_T)
    LDY ram_0004
    LDA ram_0292,Y
    LDY ram_0006
    ORA tbl_DD8D_actor_alt_sprite_attrs,Y
    LDY #$02
    STA (ram_0002),Y    ; 0702-072E and 0742-074E (spr_A)
    JMP loc_DB22_write_oam_quad_x_pass
; Compose sprite set 2 tiles/attrs
bra_DB02_compose_sprite_set2:		; was: bra_DB02_02
    LDA ram_028C,Y
    ASL
    ASL
    CLC
    ADC ram_0005
    TAY
    STA ram_0006
    LDA tbl_DC8D_actor_sprite_attrs,Y
    LDY #$01
    STA (ram_0002),Y
    LDY ram_0004
    LDA ram_0292,Y
    LDY ram_0006
    ORA tbl_DDC1_oam_quad_offsets,Y
    LDY #$02
    STA (ram_0002),Y
; Write OAM X coordinates for current quad pass
loc_DB22_write_oam_quad_x_pass:		; was: loc_DB22
    LDY #$00
    LDA (ram_0000),Y    ; 0274 0278 027C 0280 0284 0288
    BNE bra_DB2C_apply_x_offset
    LDA #$FF
    BNE bra_DB30_store_oam_x    ; jmp
; Apply X offset from sprite offset table
bra_DB2C_apply_x_offset:		; was: bra_DB2C
    CLC
    ADC tbl_DDC1_oam_quad_offsets + $01,X
; Store OAM X coordinate
bra_DB30_store_oam_x:		; was: bra_DB30
    LDY #$03
    STA (ram_0002),Y    ; 0703-075F (spr_X)
    LDA ram_0002
    CLC
    ADC #$04
    STA ram_0002
    INC ram_0005
    INX
    INX
    CPX #$08
    BEQ bra_DB46_next_sprite_group_or_done
    JMP loc_DA75_build_oam_quad_loop
; Advance to next sprite group or finish
bra_DB46_next_sprite_group_or_done:		; was: bra_DB46
    LDA ram_0000
    CLC
    ADC #$04
    STA ram_0000
    INC ram_0004
    LDA ram_0004
    CMP #$06
    BEQ bra_DB58_return
    JMP loc_DA70_next_sprite_group
; Return from OAM builder
bra_DB58_return:		; was: bra_DB58_RTS
    RTS



; Actor sprite tile patterns
tbl_DB59_actor_sprite_tiles:		; was: tbl_DB59_spr_T
    .byte $4C, $4C, $4C, $4C   ; 00
    .byte $00, $00, $00, $00   ; 01
    .byte $04, $04, $03, $03   ; 02
    .byte $08, $08, $07, $07   ; 03
    .byte $02, $01, $02, $01   ; 04
    .byte $06, $05, $06, $05   ; 05
    .byte $03, $03, $04, $04   ; 06
    .byte $07, $07, $08, $08   ; 07
    .byte $01, $02, $01, $02   ; 08
    .byte $05, $06, $05, $06   ; 09
    .byte $18, $18, $19, $19   ; 0A
    .byte $18, $18, $1A, $1A   ; 0B
    .byte $1B, $1C, $1D, $1F   ; 0C
    .byte $1B, $1C, $1E, $20   ; 0D
    .byte $21, $21, $22, $22   ; 0E
    .byte $21, $21, $23, $23   ; 0F
    .byte $1C, $1B, $1F, $1D   ; 10
    .byte $1C, $1B, $20, $1E   ; 11
    .byte $00, $00, $00, $00   ; 12
    .byte $09, $09, $0A, $0A   ; 13
    .byte $0B, $0B, $0C, $0C   ; 14
    .byte $4C, $4C, $0D, $0D   ; 15
    .byte $4C, $4C, $0E, $0E   ; 16
    .byte $4C, $4C, $0F, $0F   ; 17
    .byte $4C, $4C, $10, $10   ; 18
    .byte $4C, $4C, $11, $11   ; 19
    .byte $4C, $4C, $12, $12   ; 1A
    .byte $4C, $4C, $13, $13   ; 1B
    .byte $14, $15, $16, $17   ; 1C
    .byte $4C, $4C, $4C, $4C   ; 1D
    .byte $24, $24, $25, $25   ; 1E
    .byte $24, $24, $26, $26   ; 1F
    .byte $27, $27, $4C, $4C   ; 20
    .byte $28, $29, $2A, $2B   ; 21
    .byte $2C, $2C, $2D, $2D   ; 22
    .byte $29, $28, $2B, $2A   ; 23
    .byte $90, $91, $92, $93   ; 24
    .byte $94, $95, $96, $97   ; 25
    .byte $98, $99, $9A, $9B   ; 26
    .byte $9C, $9D, $9E, $9F   ; 27
    .byte $A0, $A1, $A2, $A3   ; 28
    .byte $A4, $A5, $A6, $A7   ; 29
    .byte $A8, $A9, $AA, $AB   ; 2A
    .byte $AC, $AD, $AE, $AF   ; 2B
    .byte $2E, $2F, $30, $31   ; 2C
    .byte $32, $2F, $33, $31   ; 2D
    .byte $34, $2F, $35, $31   ; 2E
    .byte $36, $2F, $37, $31   ; 2F
    .byte $38, $2F, $39, $31   ; 30
    .byte $3A, $2F, $3B, $31   ; 31
    .byte $3C, $2F, $3D, $31   ; 32
    .byte $3E, $3F, $40, $41   ; 33
    .byte $42, $3F, $43, $41   ; 34
    .byte $44, $45, $46, $47   ; 35
    .byte $48, $45, $49, $47   ; 36
    .byte $4A, $45, $4B, $47   ; 37
    .byte $4D, $4E, $4F, $50   ; 38
    .byte $4E, $4D, $50, $4F   ; 39
    .byte $4F, $50, $4D, $4E   ; 3A
    .byte $50, $4F, $4E, $4D   ; 3B
    .byte $4D, $4E, $4F, $51   ; 3C
    .byte $4E, $52, $53, $54   ; 3D
    .byte $4F, $51, $4D, $4E   ; 3E
    .byte $53, $54, $4E, $52   ; 3F



; Alternate actor sprite tile patterns
tbl_DC59_actor_alt_sprite_tiles:		; was: tbl_DC59_spr_T
    .byte $55, $4C, $56, $4C   ; 00
    .byte $56, $4C, $55, $4C   ; 01
    .byte $4C, $57, $4C, $58   ; 02
    .byte $4C, $59, $4C, $5A   ; 03
    .byte $4C, $5B, $4C, $5C   ; 04
    .byte $4C, $4C, $4C, $5D   ; 05
    .byte $18, $18, $19, $5E   ; 06
    .byte $60, $61, $19, $5E   ; 07
    .byte $1B, $1C, $1D, $62   ; 08
    .byte $1B, $1C, $1E, $63   ; 09
    .byte $64, $65, $66, $67   ; 0A
    .byte $64, $65, $68, $69   ; 0B
    .byte $6A, $6B, $4C, $4C   ; 0C



; Actor sprite attribute patterns
tbl_DC8D_actor_sprite_attrs:		; was: tbl_DC8D_spr_A
    .byte $00, $00, $00, $00   ; 00
    .byte $00, $40, $80, $C0   ; 01
    .byte $80, $C0, $80, $C0   ; 02
    .byte $80, $C0, $80, $C0   ; 03
    .byte $00, $00, $80, $80   ; 04
    .byte $00, $00, $80, $80   ; 05
    .byte $00, $40, $00, $40   ; 06
    .byte $00, $40, $00, $40   ; 07
    .byte $40, $40, $C0, $C0   ; 08
    .byte $40, $40, $C0, $C0   ; 09
    .byte $00, $40, $00, $40   ; 0A
    .byte $00, $40, $00, $40   ; 0B
    .byte $00, $00, $00, $00   ; 0C
    .byte $00, $00, $00, $00   ; 0D
    .byte $00, $40, $00, $40   ; 0E
    .byte $00, $40, $00, $40   ; 0F
    .byte $40, $40, $40, $40   ; 10
    .byte $40, $40, $40, $40   ; 11
    .byte $00, $40, $80, $C0   ; 12
    .byte $00, $40, $00, $40   ; 13
    .byte $00, $40, $00, $40   ; 14
    .byte $00, $00, $00, $40   ; 15
    .byte $00, $00, $00, $40   ; 16
    .byte $00, $00, $00, $40   ; 17
    .byte $00, $00, $00, $40   ; 18
    .byte $00, $00, $00, $40   ; 19
    .byte $00, $00, $00, $40   ; 1A
    .byte $00, $00, $00, $40   ; 1B
    .byte $00, $00, $00, $00   ; 1C
    .byte $00, $00, $00, $00   ; 1D
    .byte $00, $40, $00, $40   ; 1E
    .byte $00, $40, $00, $40   ; 1F
    .byte $00, $40, $00, $00   ; 20
    .byte $00, $00, $00, $00   ; 21
    .byte $00, $40, $00, $40   ; 22
    .byte $40, $40, $40, $40   ; 23
    .byte $00, $00, $00, $00   ; 24
    .byte $00, $00, $00, $00   ; 25
    .byte $00, $00, $00, $00   ; 26
    .byte $00, $00, $00, $00   ; 27
    .byte $00, $00, $00, $00   ; 28
    .byte $00, $00, $00, $00   ; 29
    .byte $00, $00, $00, $00   ; 2A
    .byte $00, $00, $00, $00   ; 2B
    .byte $00, $00, $00, $00   ; 2C
    .byte $00, $00, $00, $00   ; 2D
    .byte $00, $00, $00, $00   ; 2E
    .byte $00, $00, $00, $00   ; 2F
    .byte $00, $00, $00, $00   ; 30
    .byte $00, $00, $00, $00   ; 31
    .byte $00, $00, $00, $00   ; 32
    .byte $00, $00, $00, $00   ; 33
    .byte $00, $00, $00, $00   ; 34
    .byte $00, $00, $00, $00   ; 35
    .byte $00, $00, $00, $00   ; 36
    .byte $00, $00, $00, $00   ; 37
    .byte $00, $00, $00, $00   ; 38
    .byte $40, $40, $00, $40   ; 39
    .byte $80, $00, $80, $80   ; 3A
    .byte $00, $C0, $C0, $C0   ; 3B
    .byte $00, $00, $00, $00   ; 3C
    .byte $40, $00, $00, $00   ; 3D
    .byte $80, $80, $80, $80   ; 3E
    .byte $80, $80, $C0, $80   ; 3F



; Alternate actor sprite attributes
tbl_DD8D_actor_alt_sprite_attrs:		; was: tbl_DD8D_spr_A
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $00   ; 03
    .byte $80   ; 04
    .byte $00   ; 05
    .byte $80   ; 06
    .byte $00   ; 07
    .byte $00   ; 08
    .byte $00   ; 09
    .byte $00   ; 0A
    .byte $00   ; 0B
    .byte $00   ; 0C
    .byte $00   ; 0D
    .byte $00   ; 0E
    .byte $00   ; 0F
    .byte $00   ; 10
    .byte $00   ; 11
    .byte $00   ; 12
    .byte $00   ; 13
    .byte $00   ; 14
    .byte $00   ; 15
    .byte $00   ; 16
    .byte $00   ; 17
    .byte $00   ; 18
    .byte $40   ; 19
    .byte $00   ; 1A
    .byte $00   ; 1B
    .byte $00   ; 1C
    .byte $00   ; 1D
    .byte $00   ; 1E
    .byte $00   ; 1F
    .byte $00   ; 20
    .byte $00   ; 21
    .byte $00   ; 22
    .byte $00   ; 23
    .byte $00   ; 24
    .byte $00   ; 25
    .byte $00   ; 26
    .byte $00   ; 27
    .byte $00   ; 28
    .byte $00   ; 29
    .byte $00   ; 2A
    .byte $00   ; 2B
    .byte $00   ; 2C
    .byte $00   ; 2D
    .byte $00   ; 2E
    .byte $00   ; 2F
    .byte $00   ; 30
    .byte $00   ; 31
    .byte $00   ; 32
    .byte $00   ; 33



; Per-quad OAM XY offsets
tbl_DDC1_oam_quad_offsets:		; was: tbl_DDC1_spr_pos
; Y, X
    .byte $03, $F4   ; 00
    .byte $03, $FC   ; 02
    .byte $0B, $F4   ; 04
    .byte $0B, $FC   ; 06



; Toggle power-pellet tile IDs on a 16-frame cadence
sub_DDC9_blink_power_pellet_tiles:		; was: sub_DDC9
    LDA ram_frame_cnt
    AND #$0F
    BEQ bra_DDD0_process_blink_step
    RTS
; Run blink update every 16 frames
bra_DDD0_process_blink_step:		; was: bra_DDD0
; each 16 frames
    TAX
; Toggle next power-pellet tile ID
bra_DDD1_toggle_next_power_pellet_tile:		; was: bra_DDD1_loop
    LDA ram_power_pellet_tile_p1,X
    CMP #con_tile + $07
    BEQ bra_DDE1_store_power_pellet_tile
    CMP #con_tile + $01
    BNE bra_DDDF_set_power_pellet_visible
    LDA #con_tile + $02
    BNE bra_DDE1_store_power_pellet_tile    ; jmp
; Set power-pellet tile to visible variant
bra_DDDF_set_power_pellet_visible:		; was: bra_DDDF
    LDA #con_tile + $01
; Store updated power-pellet tile ID
bra_DDE1_store_power_pellet_tile:		; was: bra_DDE1
    STA ram_power_pellet_tile_p1,X
    INX
    CPX #$04
    BNE bra_DDD1_toggle_next_power_pellet_tile
    RTS



sub_DDE9_write_buffer_to_ppu:
    LDA ram_flag_demo
    BEQ bra_DDF0_flush_score_hud_buffers
    JMP loc_DE7E_flush_power_pellet_and_main_ppu
; Flush score/hiscore buffers to PPU
bra_DDF0_flush_score_hud_buffers:		; was: bra_DDF0
; score buffer
    LDA ram_ppu_buffer_score
    CMP #$FF
    BEQ bra_DE4A_update_1up_blink    ; skip if buffer is empty
    LDA $2002
    LDA ram_ppu_buf_score_hi
    STA $2006
    LDA ram_ppu_buf_score_lo
    STA $2006
    LDY #$00
; Write score digits to PPU
bra_DE08_write_score_digits:		; was: bra_DE08_loop
    LDA ram_ppu_buffer_score,Y
    STA $2007
    INY
    CPY #$06
    BNE bra_DE08_write_score_digits
    LDA #con_tile + $30
    STA $2007
    LDA #$FF
    STA ram_ppu_buffer_score
; hiscore buffer
    LDA ram_ppu_buffer_hiscore
    CMP #$FF
    BEQ bra_DE4A_update_1up_blink    ; skip if buffer is empty
    LDA $2002
    LDA ram_ppu_buf_hiscore_hi
    STA $2006
    LDA ram_ppu_buf_hiscore_lo
    STA $2006
    LDY #$00
; Write hiscore digits to PPU
bra_DE35_write_hiscore_digits:		; was: bra_DE35_loop
    LDA ram_ppu_buffer_hiscore,Y
    STA $2007
    INY
    CPY #$06
    BNE bra_DE35_write_hiscore_digits
    LDA #con_tile + $30
    STA $2007
    LDA #$FF
    STA ram_ppu_buffer_hiscore
; Update flashing 1UP indicator
bra_DE4A_update_1up_blink:		; was: bra_DE4A
    LDA ram_frame_cnt
    AND #$07
    BNE bra_DE7E_flush_power_pellet_and_main_ppu
    LDA $2002
    LDA ram_ppu_buffer_1up
    STA $2006
    LDA ram_ppu_buffer_1up + $01
    STA $2006
    LDX #$00
    LDA ram_frame_cnt
    AND #$18
    BEQ bra_DE74_clear_1up_text
; Write 1UP text tiles
bra_DE67_write_1up_text:		; was: bra_DE67_loop
    LDA ram_ppu_buffer_1up + $02,X
    STA $2007
    INX
    CPX #$03
    BNE bra_DE67_write_1up_text
    BEQ bra_DE7E_flush_power_pellet_and_main_ppu    ; jmp
; Clear 1UP text tiles
bra_DE74_clear_1up_text:		; was: bra_DE74
    LDA #con_tile + $20
; Write clear tiles for 1UP field
bra_DE76_write_1up_clear_tiles:		; was: bra_DE76_loop
    STA $2007
    INX
    CPX #$03
    BNE bra_DE76_write_1up_clear_tiles
; Flush power-pellet markers and generic PPU command buffer
bra_DE7E_flush_power_pellet_and_main_ppu:		; was: bra_DE7E
; Flush power-pellet markers and generic PPU command buffer
loc_DE7E_flush_power_pellet_and_main_ppu:		; was: loc_DE7E
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_DE8A_select_player_nametable
    LDY #$08
; Select nametable half based on active player
bra_DE8A_select_player_nametable:		; was: bra_DE8A
; Write current power-pellet marker tiles
bra_DE8A_write_power_pellet_markers:		; was: bra_DE8A_loop
    LDA $2002
    LDA tbl_DECF_power_pellet_ppu_addrs,Y
    STA $2006
    LDA tbl_DECF_power_pellet_ppu_addrs + $01,Y
    STA $2006
    LDA ram_power_pellet_tile_p1,X
    STA $2007
    INY
    INY
    INX
    CPX #$04
    BNE bra_DE8A_write_power_pellet_markers
    LDA $2002
    LDY #$FF
; Scan packed PPU command buffer entries
bra_DEAA_scan_ppu_command_buffer:		; was: bra_DEAA_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BEQ bra_DECB_finalize_ppu_command_buffer    ; skip if buffer is empty
    STA $2006
    INY
    LDA ram_ppu_buffer_main,Y
    STA $2006
; Write payload bytes of current PPU command
bra_DEBC_write_ppu_command_payload:		; was: bra_DEBC_loop
    INY
    LDA ram_ppu_buffer_main,Y
    BEQ bra_DEAA_scan_ppu_command_buffer
    CMP #$FF
    BEQ bra_DECB_finalize_ppu_command_buffer    ; skip if there isn't anything else in the buffer
    STA $2007
    BNE bra_DEBC_write_ppu_command_payload   ; jmp
; Mark PPU command buffer as consumed
bra_DECB_finalize_ppu_command_buffer:		; was: bra_DECB
    STA ram_ppu_buffer_main
    RTS



; PPU addresses for the four power-pellet marker cells
tbl_DECF_power_pellet_ppu_addrs:		; was: tbl_DECF_ppu_addr
    .dbyt $20B4 ; 00
    .dbyt $20A2 ; 02
    .dbyt $22D4 ; 04
    .dbyt $22C2 ; 06
    .dbyt $28B4 ; 08
    .dbyt $28A2 ; 0A
    .dbyt $2AD4 ; 0C
    .dbyt $2AC2 ; 0E
