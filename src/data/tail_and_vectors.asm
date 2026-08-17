; Fixed bank tail: $FF padding through $FFF7, maze pointer, and hardware vectors.

unused_bank_padding:
    .res $FFF8 - *, $FF

; Pointer to the generated compressed maze stream.
; Fixed at $FFF8; the VECTORS segment starts at $FFFA.
tbl_maze_rle_stream_ptr:
.ifdef PACMAN_EXPANDED_MAZE
    .word tbl_expanded_maze_rle_stream
.else
    .word tbl_maze_rle_stream
.endif

.out .sprintf("Free bytes in bank FF: 0x%04X [%d]", ($FFFA - *), ($FFFA - *))

.segment "VECTORS"

; NES vector table at fixed tail addresses:
; FFFA: NMI, FFFC: RESET, FFFE: IRQ/BRK.
    .word vec_nmi_handler
    .word vec_reset_entry
    .word vec_irq_handler
