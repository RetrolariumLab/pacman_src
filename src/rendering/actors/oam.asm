; OAM construction and actor sprite tile/attribute tables

sub_build_oam_from_sprite_buffers:		; was: sub_DA5C
; Build final OAM entries from sprite buffers
loc_build_oam_from_sprite_buffers:		; was: loc_DA5C
    LoadPointer zp_work0, ram_spr_position
    LoadPointer zp_work2, ram_oam
    LDA #$00
    STA zp_work4
; Process next sprite group
loc_next_sprite_group:		; was: loc_DA70
    LDA #$00
    STA zp_work5
    TAX
; Build OAM quad entries for current group
loc_build_oam_quad_loop:		; was: loc_DA75_loop
    LDY #$02
    LDA (zp_work0),Y    ; 0276 027A 027E 0282 0286 028A
    BNE bra_apply_y_offset
    LDA #$FF
    BNE bra_store_oam_y    ; jmp
; Apply Y offset from sprite offset table
bra_apply_y_offset:		; was: bra_DA7F
    CLC
    ADC tbl_oam_quad_offsets,X
; Store OAM Y coordinate
bra_store_oam_y:		; was: bra_DA83
    LDY #$00
    STA (zp_work2),Y    ; 0700-075C (spr_Y)
    LDY zp_work4
    LDA ram_actor_sprite_set,Y
    ASL
    ROL
    ROL
    AND #$03
    BEQ bra_compose_sprite_set0
    CMP #$02
    BEQ bra_compose_sprite_set2
    BCC bra_compose_sprite_set1
; 03
    ComposeActorOamEntry tbl_actor_sprite_attrs, tbl_oam_quad_offsets
    JMP loc_write_oam_quad_x_pass
; Compose sprite set 0 tiles/attrs
bra_compose_sprite_set0:		; was: bra_DABC_00
    ComposeActorOamEntry tbl_actor_sprite_tiles, tbl_actor_sprite_attrs
    JMP loc_write_oam_quad_x_pass
; Compose sprite set 1 tiles/attrs
bra_compose_sprite_set1:		; was: bra_DADF_01
    ComposeActorOamEntry tbl_actor_alt_sprite_tiles, tbl_actor_alt_sprite_attrs
    JMP loc_write_oam_quad_x_pass
; Compose sprite set 2 tiles/attrs
bra_compose_sprite_set2:		; was: bra_DB02_02
    ComposeActorOamEntry tbl_actor_sprite_attrs, tbl_oam_quad_offsets
; Write OAM X coordinates for current quad pass
loc_write_oam_quad_x_pass:		; was: loc_DB22
    LDY #$00
    LDA (zp_work0),Y    ; 0274 0278 027C 0280 0284 0288
    BNE bra_apply_x_offset
    LDA #$FF
    BNE bra_store_oam_x    ; jmp
; Apply X offset from sprite offset table
bra_apply_x_offset:		; was: bra_DB2C
    CLC
    ADC tbl_oam_quad_offsets + $01,X
; Store OAM X coordinate
bra_store_oam_x:		; was: bra_DB30
    LDY #$03
    STA (zp_work2),Y    ; 0703-075F (spr_X)
    LDA zp_work2
    CLC
    ADC #$04
    STA zp_work2
    INC zp_work5
    INX
    INX
    CPX #$08
    BEQ bra_next_sprite_group_or_done
    JMP loc_build_oam_quad_loop
; Advance to next sprite group or finish
bra_next_sprite_group_or_done:		; was: bra_DB46
    LDA zp_work0
    CLC
    ADC #$04
    STA zp_work0
    INC zp_work4
    LDA zp_work4
    CMP #$06
    BEQ bra_return_from_oam_builder
    JMP loc_next_sprite_group
; Return from OAM builder
bra_return_from_oam_builder:		; was: bra_DB58_RTS
    RTS

; Actor sprite tile patterns
tbl_actor_sprite_tiles:		; was: tbl_DB59_spr_T
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
tbl_actor_alt_sprite_tiles:		; was: tbl_DC59_spr_T
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
tbl_actor_sprite_attrs:		; was: tbl_DC8D_spr_A
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
tbl_actor_alt_sprite_attrs:		; was: tbl_DD8D_spr_A
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
tbl_oam_quad_offsets:		; was: tbl_DDC1_spr_pos
; Y, X
    .byte $03, $F4   ; 00
    .byte $03, $FC   ; 02
    .byte $0B, $F4   ; 04
    .byte $0B, $FC   ; 06

; Toggle power-pellet tile IDs on a 16-frame cadence
