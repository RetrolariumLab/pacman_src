; Fixed bank tail: $FF padding through $FFF7, maze pointer, and hardware vectors.

unused_bank_padding:
.if PACMAN_REVISION = REVISION_USA_TENGEN_LICENSED
    .res $FF00 - *, $FF

; Licensed Tengen cartridge reset trampoline. Its extra two-vblank gate hands
; control back to the shared reset routine after that routine's initial wait.
vec_tengen_licensed_reset_entry:
    SEI
    CLD
    LDA #$00
    STA PPUCTRL
    STA PPUMASK
bra_wait_tengen_licensed_first_vblank:
    LDA PPUSTATUS
    BPL bra_wait_tengen_licensed_first_vblank
bra_wait_tengen_licensed_second_vblank:
    LDA PPUSTATUS
    BPL bra_wait_tengen_licensed_second_vblank
    JMP loc_reset_after_initial_vblank
.endif
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
.if PACMAN_REVISION = REVISION_USA_TENGEN_LICENSED
    .word vec_tengen_licensed_reset_entry
.else
    .word vec_reset_entry
.endif
    .word vec_irq_handler
