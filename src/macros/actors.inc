; Compose the tile and attribute bytes for one actor OAM entry.
;
; Inputs:
;   Y - actor slot
;   ram_0002 - destination OAM pointer
;   ram_0005 - quad offset
;
; Clobbers:
;   A, Y, ram_0006
.macro ComposeActorOamEntry tile_table, attribute_table
    LDA ram_028C,Y
    ASL
    ASL
    CLC
    ADC ram_0005
    TAY
    STA ram_0006
    LDA tile_table,Y
    LDY #$01
    STA (ram_0002),Y
    LDY ram_0004
    LDA ram_0292,Y
    LDY ram_0006
    ORA attribute_table,Y
    LDY #$02
    STA (ram_0002),Y
.endmacro
