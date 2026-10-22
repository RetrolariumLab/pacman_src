; Editable stage parameters and runtime tuning tables

; Stage-driven index stream selecting parameter groups (step size 6 in round-init)
tbl_stage_param_index_stream:
; One 6-byte record per round; the stage counter stops at $16, so round 23 also
; serves every later round:
; level block and timing window id, frightened duration, dot-threshold pair
; id, release-target quad id, fruit/bonus group, release interval in seconds
    .byte $00, $07, $00, $00, $00, $04  ; round 1
    .byte $01, $06, $01, $01, $01, $04  ; round 2
    .byte $01, $04, $02, $02, $02, $03  ; round 3
    .byte $02, $03, $02, $02, $02, $03  ; round 4
    .byte $02, $02, $02, $02, $03, $03  ; round 5
    .byte $03, $05, $03, $02, $03, $03  ; round 6
    .byte $03, $02, $03, $02, $04, $03  ; round 7
    .byte $03, $02, $03, $02, $04, $03  ; round 8
    .byte $03, $01, $04, $02, $05, $03  ; round 9
    .byte $03, $05, $04, $02, $05, $03  ; round 10
    .byte $03, $02, $04, $02, $06, $03  ; round 11
    .byte $03, $01, $05, $02, $06, $03  ; round 12
    .byte $03, $01, $05, $02, $07, $03  ; round 13
    .byte $03, $03, $05, $02, $07, $03  ; round 14
    .byte $03, $01, $06, $02, $07, $03  ; round 15
    .byte $03, $01, $06, $02, $07, $03  ; round 16
    .byte $03, $00, $06, $02, $07, $03  ; round 17
    .byte $03, $01, $06, $02, $07, $03  ; round 18
    .byte $03, $00, $06, $02, $07, $03  ; round 19
    .byte $03, $00, $06, $02, $07, $03  ; round 20
    .byte $03, $00, $06, $02, $07, $03  ; round 21
    .byte $04, $00, $06, $02, $07, $03  ; round 22
    .byte $04, $00, $06, $02, $07, $03  ; round 23

; Level parameter blocks copied to ram_level_parameters, eleven speeds each
; (low byte 1/256 pixel, high byte whole pixels, per frame): Pac-Man while
; ghosts are frightened on floor, pellet and power-pellet tiles; the same
; three otherwise; ghost 0 after its first and second dot threshold; ghosts'
; normal, frightened and tunnel speeds
tbl_level_param_blocks_22bytes:
.if PACMAN_REVISION = REVISION_EUROPE
; PAL timing equivalents of the five NTSC movement profiles below
    .word $00FA, $00E6, $00C0, $00D3, $00C0, $009A, $00C0, $00D3, $00AD, $0060, $0060  ; 00
    .word $00FA, $00E6, $00C0, $00D3, $00C0, $009A, $00D3, $00E6, $00C0, $0060, $0060  ; 01
    .word $0120, $010D, $00E6, $010D, $00FA, $00D3, $010D, $0120, $00FA, $0086, $0086  ; 02
    .word $0133, $0120, $00FA, $0133, $0120, $00FA, $0133, $0146, $0120, $009A, $009A  ; 03
    .word $0133, $0120, $00FA, $0133, $0120, $00FA, $015A, $016D, $0146, $009A, $009A  ; 04
.else
    .word $00D0, $00C0, $00A0, $00B0, $00A0, $0080, $00A0, $00B0, $0090, $0050, $0050  ; 00
    .word $00D0, $00C0, $00A0, $00B0, $00A0, $0080, $00B0, $00C0, $00A0, $0050, $0050  ; 01
    .word $00F0, $00E0, $00C0, $00E0, $00D0, $00B0, $00E0, $00F0, $00D0, $0070, $0070  ; 02
    .word $0100, $00F0, $00D0, $0100, $00F0, $00D0, $0100, $0110, $00F0, $0080, $0080  ; 03
    .word $0100, $00F0, $00D0, $0100, $00F0, $00D0, $0120, $0130, $0110, $0080, $0080  ; 04
.endif

; Per-level speed/timer control windows copied to RAM 0097..009E
; Profile id 4 reads the eight bytes immediately following these four rows,
; so adjacency with tbl_dot_counter_threshold_pairs is a runtime contract
tbl_speed_timer_blocks_8bytes:
    .byte $07, $14, $07, $14, $05, $14, $05, $FF  ; 00
    .byte $07, $14, $07, $14, $05, $FF, $00, $00  ; 01
    .byte $05, $14, $05, $14, $05, $FF, $00, $00  ; 02
    .byte $05, $14, $05, $14, $05, $FF, $00, $00  ; 03

; Dot-counter threshold pairs loaded into RAM 008D/008E
tbl_dot_counter_threshold_pairs:
    .byte $14, $0A  ; 00
    .byte $1E, $0F  ; 01
    .byte $28, $14  ; 02
    .byte $32, $19  ; 03
    .byte $3C, $1E  ; 04
    .byte $50, $28  ; 05
    .byte $64, $32  ; 06

; Default ghost release target quads copied to RAM 008F..0092
tbl_ghost_release_target_quads:
    .byte $02, $1E, $5A, $00  ; 00
    .byte $03, $32, $00, $00  ; 01
    .byte $04, $00, $00, $00  ; 02

; Special-case release target quad used when partial pellet progress is preserved
tbl_release_target_special_case_quad:
; Used by partial-progress path in round init (when pellet count is carried into release logic)
    .byte $01, $07, $11, $20
