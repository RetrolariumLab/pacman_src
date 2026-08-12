; Compose the tile and attribute bytes for one actor OAM entry.
;
; Inputs:
;   Y - actor slot
;   zp_work2 - destination OAM pointer
;   zp_work5 - quad offset
;
; Clobbers:
;   A, Y, zp_work6
.macro ComposeActorOamEntry tile_table, attribute_table
    LDA ram_actor_sprite_set,Y
    ASL
    ASL
    CLC
    ADC zp_work5
    TAY
    STA zp_work6
    LDA tile_table,Y
    LDY #$01
    STA (zp_work2),Y
    LDY zp_work4
    LDA ram_actor_sprite_attrs,Y
    LDY zp_work6
    ORA attribute_table,Y
    LDY #$02
    STA (zp_work2),Y
.endmacro
