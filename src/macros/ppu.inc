; Reset the PPU address latch and select a fixed VRAM address.
.macro SetPpuAddress address
    LDA PPUSTATUS
    LDA #> address
    STA PPUADDR
    LDA #< address
    STA PPUADDR
.endmacro

; Reset the PPU address latch and select a VRAM address stored high-byte first
; in two consecutive RAM bytes.
.macro SetPpuAddressFrom source
    LDA PPUSTATUS
    LDA source
    STA PPUADDR
    LDA source + $01
    STA PPUADDR
.endmacro
