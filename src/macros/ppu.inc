; Reset the PPU address latch and select a fixed VRAM address.
.macro SetPpuAddress address
    LDA $2002
    LDA #> address
    STA $2006
    LDA #< address
    STA $2006
.endmacro

; Reset the PPU address latch and select a VRAM address stored high-byte first
; in two consecutive RAM bytes.
.macro SetPpuAddressFrom source
    LDA $2002
    LDA source
    STA $2006
    LDA source + $01
    STA $2006
.endmacro
