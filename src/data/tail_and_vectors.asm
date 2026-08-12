; Unused bank padding, maze pointer, and hardware vectors.

unused_F428_bank_padding:
    .res $FFF8 - *, $FF

; Pointer to the generated compressed maze stream.
tbl_FFF8_maze_rle_stream_ptr:
    .word tbl_EC78_maze_rle_stream

.out .sprintf("Free bytes in bank FF: 0x%04X [%d]", ($FFFA - *), ($FFFA - *))

.segment "VECTORS"

; NES vector table at fixed tail addresses:
; FFFA: NMI, FFFC: RESET, FFFE: IRQ/BRK.
    .word vec_C0FA_nmi_handler
    .word vec_C033_reset_entry
    .word vec_C167_IRQ
