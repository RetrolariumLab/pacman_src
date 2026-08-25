; Load a 16-bit little-endian address into a zero-page pointer

; Expands inline and preserves the original A/flags behavior: A contains the
; source high byte after the macro completes
.macro LoadPointer destination, source
    LDA #< source
    STA destination
    LDA #> source
    STA destination + $01
.endmacro
