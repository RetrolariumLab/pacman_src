; Editable stage parameters and runtime tuning tables

; Stage-driven index stream selecting parameter groups (step size 6 in round-init)
tbl_stage_param_index_stream:		; was: tbl_EB42
; Read as a 6-byte stage profile:
; [0]=level param block id, [1]=speed/timer block id, [2]=dot-threshold pair id,
; [3]=release target block id, [4]=fruit bonus group id, [5]=fruit color group id.
; 00
    .byte $00   ; 0x000EC7 0x000EE5
    .byte $07   ; 0x000F05
    .byte $00   ; 0x000F0E
    .byte $00   ; 0x000F4A
    .byte $00   ; 0x000F92
    .byte $04   ; 0x000F9B
; 06
    .byte $01
    .byte $06
    .byte $01
    .byte $01
    .byte $01
    .byte $04
; 0C
    .byte $01
    .byte $04
    .byte $02
    .byte $02
    .byte $02
    .byte $03
; 12
    .byte $02
    .byte $03
    .byte $02
    .byte $02
    .byte $02
    .byte $03
; 18
    .byte $02
    .byte $02
    .byte $02
    .byte $02
    .byte $03
    .byte $03
; 1E
    .byte $03
    .byte $05
    .byte $03
    .byte $02
    .byte $03
    .byte $03
; 24
    .byte $03
    .byte $02
    .byte $03
    .byte $02
    .byte $04
    .byte $03
; 2A
    .byte $03
    .byte $02
    .byte $03
    .byte $02
    .byte $04
    .byte $03
; 30
    .byte $03
    .byte $01
    .byte $04
    .byte $02
    .byte $05
    .byte $03
; 36
    .byte $03
    .byte $05
    .byte $04
    .byte $02
    .byte $05
    .byte $03
; 3C
    .byte $03
    .byte $02
    .byte $04
    .byte $02
    .byte $06
    .byte $03
; 42
    .byte $03
    .byte $01
    .byte $05
    .byte $02
    .byte $06
    .byte $03
; 48
    .byte $03
    .byte $01
    .byte $05
    .byte $02
    .byte $07
    .byte $03
; 4E
    .byte $03
    .byte $03
    .byte $05
    .byte $02
    .byte $07
    .byte $03
; 54
    .byte $03
    .byte $01
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 5A
    .byte $03
    .byte $01
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 60
    .byte $03
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 66
    .byte $03
    .byte $01
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 6C
    .byte $03
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 72
    .byte $03
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 78
    .byte $03
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 7E
    .byte $04
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; 84
    .byte $04
    .byte $00
    .byte $06
    .byte $02
    .byte $07
    .byte $03
; Level parameter blocks copied to runtime RAM 009F..00B4 (22 bytes each)
tbl_level_param_blocks_22bytes:		; was: tbl_EBCC
;                                             009F 00A0 00A1 00A2 00A3 00A4 00A5 00A6 00A7 00A8 00A9 00AA 00AB 00AC 00AD 00AE 00AF 00B0 00B1 00B2 00B3 00B4
    .byte $D0, $00, $C0, $00, $A0, $00, $B0, $00, $A0, $00, $80, $00, $A0, $00, $B0, $00, $90, $00, $50, $00, $50, $00   ; 00
    .byte $D0, $00, $C0, $00, $A0, $00, $B0, $00, $A0, $00, $80, $00, $B0, $00, $C0, $00, $A0, $00, $50, $00, $50, $00   ; 01
    .byte $F0, $00, $E0, $00, $C0, $00, $E0, $00, $D0, $00, $B0, $00, $E0, $00, $F0, $00, $D0, $00, $70, $00, $70, $00   ; 02
    .byte $00, $01, $F0, $00, $D0, $00, $00, $01, $F0, $00, $D0, $00, $00, $01, $10, $01, $F0, $00, $80, $00, $80, $00   ; 03
    .byte $00, $01, $F0, $00, $D0, $00, $00, $01, $F0, $00, $D0, $00, $20, $01, $30, $01, $10, $01, $80, $00, $80, $00   ; 04

; Per-level speed/timer control blocks copied to RAM 0097..009E
tbl_speed_timer_blocks_8bytes:		; was: tbl_EC3A
    .byte $07, $14, $07, $14, $05, $14, $05, $FF   ; 00
    .byte $07, $14, $07, $14, $05, $FF, $00, $00   ; 01
    .byte $05, $14, $05, $14, $05, $FF, $00, $00   ; 02
    .byte $05, $14, $05, $14, $05, $FF, $00, $00   ; 03
; Note: stage profile id 04 can also be reached from the 6-byte stage stream above.

; Dot-counter threshold pairs loaded into RAM 008D/008E
tbl_dot_counter_threshold_pairs:		; was: tbl_EC5A
    .byte $14, $0A   ; 00
    .byte $1E, $0F   ; 01
    .byte $28, $14   ; 02
    .byte $32, $19   ; 03
    .byte $3C, $1E   ; 04
    .byte $50, $28   ; 05
    .byte $64, $32   ; 06

; Default ghost release target quads copied to RAM 008F..0092
tbl_ghost_release_target_quads:		; was: tbl_EC68
    .byte $02, $1E, $5A, $00   ; 00
    .byte $03, $32, $00, $00   ; 01
    .byte $04, $00, $00, $00   ; 02

; Special-case release target quad used when partial pellet progress is preserved
tbl_release_target_special_case_quad:		; was: tbl_EC74
; Used by partial-progress path in round init (when pellet count is carried into release logic).
    .byte $01, $07, $11, $20
