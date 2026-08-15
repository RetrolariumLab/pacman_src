; Sound engine, note periods, and SFX pointer table

; Initialize sound engine pointers, APU channel enables, and frame counter mode
sub_init_sound_engine:		; was: sub_EE18
    LoadPointer ram_sfx_request_ptr, ram_sfx
    LoadPointer ram_sound_channel_ptr, ram_sound_channel_state
    LDA tbl_sfx_stream_table_ptr
    STA ram_sfx_stream_table_ptr
    LDA tbl_sfx_stream_table_ptr + $01
    STA ram_sfx_stream_table_ptr + $01
    LDA #$40
    STA ram_apu_register_ptr + $01
    LDA #APU_STATUS_ENABLE_ALL
    STA APU_STATUS
    LDA #APU_FRAME_COUNTER_IRQ_INHIBIT + APU_FRAME_COUNTER_5_STEP
    STA APU_FRAME_COUNTER
; Clear per-channel sound effect state and command slots
sub_clear_sound_engine_state:		; was: sub_EE40
    LDY #$00
    LDA #$00
; Clear 16-byte SFX request/state area
bra_loop_clear_sfx_request_slots:		; was: bra_EE44_loop
    STA (ram_sfx_request_ptr),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    INY
    CPY #con_sound_channel_count
    BNE bra_loop_clear_sfx_request_slots
    LDY #$00
    LDX #con_sound_channel_count
; Clear one command byte per 8-byte channel struct
bra_loop_clear_channel_command_slots:		; was: bra_EE4F_loop
    LDA #$00
    STA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    TYA
    CLC
    ADC #con_sound_channel_record_size
    TAY
    DEX
    BNE bra_loop_clear_channel_command_slots
    RTS

; Frame sound tick:
; 1) pre-pass for channel request arbitration
; 2) per-channel stream decode/update
; 3) immediate APU writes for updated channel quads
sub_update_sound_engine:
    LDA #$00
    STA ram_sound_channel_claims
    STA ram_sound_channel_claims + $01
    STA ram_sound_channel_claims + $02
    STA ram_sound_channel_claims + $03
    STA ram_sound_channel_offset
    STA ram_sound_work_ptr + $01
    LDA #< ram_sound_channel_claims
    STA ram_sound_work_ptr
; Pre-pass over channels to detect command conflicts
bra_loop_scan_channel_command_slots:		; was: bra_EE6E_loop
    LDY ram_sound_channel_offset
    LDA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    BEQ bra_advance_channel_prepass
    CMP #$05
    BCC bra_handle_low_priority_channel_request
    SEC
    SBC #$05
    TAY
    LDA #$01
    STA (ram_sound_work_ptr),Y    ; 00F8 00F9 00FA
    JMP loc_advance_channel_prepass_entry
; Handle 01..04 channel request with deduplication
bra_handle_low_priority_channel_request:		; was: bra_EE83
    SEC
    SBC #$01
    TAY
    LDA (ram_sound_work_ptr),Y    ; 00F8 00F9 00FA
    BNE bra_advance_channel_prepass
    LDA #$01
    STA (ram_sound_work_ptr),Y    ; 00F8 00F9 00FA
    TYA
    TAX
    ADC #$04
    LDY ram_sound_channel_offset
    STA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    TXA
    ASL
    ASL
    STA ram_apu_register_ptr
    LDX #$00
    LDA #$04
; Write 4-byte APU register quad for selected channel
bra_loop_write_apu_register_quad:		; was: bra_EEA0_loop
    PHA
    INY
    LDA (ram_sound_channel_ptr),Y    ; 0621-069C
    STA (ram_apu_register_ptr,X)    ; 4000 4001 4002 4003 4004 4005 4006 4007 4008 4009 400A 400B
    INC ram_apu_register_ptr
    PLA
    SEC
    SBC #$01
    BNE bra_loop_write_apu_register_quad
; Advance to next channel slot in pre-pass
bra_advance_channel_prepass:		; was: bra_EEAE
; Shared entry for channel pre-pass advancement
loc_advance_channel_prepass_entry:		; was: loc_EEAE
    LDA ram_sound_channel_offset
    CLC
    ADC #con_sound_channel_record_size
    STA ram_sound_channel_offset
    CMP #con_sound_channel_span
    BCC bra_loop_scan_channel_command_slots
    LDY #$00
    STY ram_sound_channel_index
    STY ram_sound_channel_offset
; Main per-channel sound stream update loop
loc_sound_channel_main_loop:		; was: loc_EEBF
    LDY ram_sound_channel_index
    LDA (ram_sfx_request_ptr),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    BNE bra_channel_has_active_stream
    JMP loc_advance_to_next_sound_channel_entry
; Channel has pending stream; update countdown or decode
bra_channel_has_active_stream:		; was: bra_EEC8
    LDY ram_sound_channel_offset
    LDA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    BNE bra_decrement_channel_duration
    LDA ram_sound_channel_index
    ASL
    TAY
    LDA (ram_sfx_stream_table_ptr),Y    ; low pointers 0x00309E
    PHA
    LDA ram_sound_channel_offset
    ADC #$05
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    LDA ram_sound_channel_index
    ASL
    ADC #$01
    TAY
    LDA (ram_sfx_stream_table_ptr),Y    ; high pointers 0x00309E
    PHA
    LDA ram_sound_channel_offset
    ADC #$06
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    JSR sub_fetch_stream_byte_and_advance_ptr
    LDY ram_sound_channel_offset
    STA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    JSR sub_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_sound_channel_offset
    CLC
    ADC #$01
    TAY
    TXA
    STA (ram_sound_channel_ptr),Y    ; 0621 0629 0631 0639 0641 0649 0651 0659 0661 0669 0671 0679 0681 0689 0691 0699
    JSR sub_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_sound_channel_offset
    CLC
    ADC #$02
    TAY
    TXA
    STA (ram_sound_channel_ptr),Y    ; 0622 062A 0632 063A 0642 064A 0652 065A 0662 066A 0672 067A 0682 068A 0692 069A
    JSR sub_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_sound_channel_offset
    CLC
    ADC #$04
    TAY
    TXA
    STA (ram_sound_channel_ptr),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    JMP loc_decode_sound_stream_byte
; Decrement active channel duration counter
bra_decrement_channel_duration:		; was: bra_EF1F
    LDA ram_sound_channel_offset
    CLC
    ADC #$07
    TAY
    LDA (ram_sound_channel_ptr),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
    SEC
    SBC #$01
    STA (ram_sound_channel_ptr),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
    BNE bra_advance_to_next_sound_channel
; Decode next sound stream byte for active channel
loc_decode_sound_stream_byte:		; was: loc_EF2E
; Stream byte classes:
; 00-BF -> note code (pitch nibble + shift nibble)
; C0-EF -> explicit duration byte follows
; F0-FF -> control opcode via tbl_sound_control_opcode_handlers
    JSR sub_fetch_stream_byte_and_advance_ptr
    CMP #con_sound_control_min
    BCS bra_dispatch_f0_ff_control_opcode
    CMP #con_sound_duration_min
    BCS bra_C0_EF_fetch_channel_duration_byte_alias
; 00-BF
    PHA
    AND #$F0
    LSR
    LSR
    LSR
    TAX
    LDA tbl_note_period_base_pairs,X
    STA ram_sound_work_ptr
    LDA tbl_note_period_base_pairs + $01,X
    STA ram_sound_work_ptr + $01
    PLA
    AND #con_sound_control_index_mask
    BEQ bra_00_apply_note_period_to_channel
; 01-0F
    TAX
; Shift note period base by nibble amount
bra_loop_shift_note_period:		; was: bra_EF50_loop
    LSR ram_sound_work_ptr
    ROR ram_sound_work_ptr + $01
    DEX
    BNE bra_loop_shift_note_period
; Apply computed note period into channel registers
bra_00_apply_note_period_to_channel:		; was: bra_EF57_00
    LDA ram_sound_channel_offset
    CLC
    ADC #$04
    TAY
    LDA (ram_sound_channel_ptr),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    AND #$F8
    ORA ram_sound_work_ptr
    STA (ram_sound_channel_ptr),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    LDA ram_sound_work_ptr + $01
    DEY
    STA (ram_sound_channel_ptr),Y    ; 0623 062B 0633 063B 0643 064B 0653 065B 0663 066B 0673 067B 0683 068B 0693 069B
    LDY ram_sound_channel_offset
    LDA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    CMP #$05
    BCC bra_fetch_channel_duration_byte
    SEC
    SBC #$04
    STA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
; Fetch next duration byte after note/control handling
bra_fetch_channel_duration_byte:		; was: bra_EF77
; Alias entry for C0-EF command path to duration fetch
bra_C0_EF_fetch_channel_duration_byte_alias:		; was: bra_EF77_C0_EF
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$07
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
; Advance to next sound channel slot
bra_advance_to_next_sound_channel:		; was: bra_EF84
; Shared entry to advance to next sound channel
loc_advance_to_next_sound_channel_entry:		; was: loc_EF84
    LDA ram_sound_channel_offset
    CLC
    ADC #con_sound_channel_record_size
    STA ram_sound_channel_offset
    LDA ram_sound_channel_index
    ADC #$01
    STA ram_sound_channel_index
    CMP #$10
    BCS bra_sound_update_done
    JMP loc_sound_channel_main_loop
; All channels processed for this frame
bra_sound_update_done:		; was: bra_EF98_RTS
    RTS
; Dispatch F0-FF control opcode via handler table
bra_dispatch_f0_ff_control_opcode:		; was: bra_EF99_F0_FF_control_byte
    AND #$0F
    ASL
    TAX
    LDA tbl_sound_control_opcode_handlers,X
    STA ram_sound_work_ptr
    LDA tbl_sound_control_opcode_handlers + $01,X
    STA ram_sound_work_ptr + $01
    JMP (ram_sound_work_ptr)

; Handler table for F0-FF sound control opcodes
tbl_sound_control_opcode_handlers:		; was: tbl_EFAA
; !(OBS) Only F0, F2, F3, and F5 occur as opcodes in all 16 decoded streams. See resolved SND-002.
; F1, F4, and F6 handlers are dormant; F7-FF alias the F0 handler.
    .word handler_00_turn_sound_off              ; con_sound_opcode_stop
    .word handler_ctrl01_set_channel_reg1_low6   ; never used
    .word handler_ctrl02_set_channel_reg1_mid2   ; con_sound_opcode_set_reg1_mid2
    .word handler_ctrl03_set_channel_reg1_low4   ; con_sound_opcode_set_reg1_low4
    .word handler_ctrl04_set_channel_reg2_raw   ; never used
    .word handler_ctrl05_set_channel_reg4_raw    ; con_sound_opcode_set_reg4
    .word handler_ctrl06_set_channel_reg1_raw   ; never used
    .word handler_07_unused_alias_turn_sound_off   ; never used
    .word handler_08_unused_alias_turn_sound_off   ; never used
    .word handler_09_unused_alias_turn_sound_off   ; never used
    .word handler_0A_unused_alias_turn_sound_off   ; never used
    .word handler_0B_unused_alias_turn_sound_off   ; never used
    .word handler_0C_unused_alias_turn_sound_off   ; never used
    .word handler_0D_unused_alias_turn_sound_off   ; never used
    .word handler_0E_unused_alias_turn_sound_off   ; never used
    .word handler_0F_unused_alias_turn_sound_off   ; never used

handler_00_turn_sound_off:
; Unused alias of F0 turn-off handler
handler_07_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_07
; Unused alias of F0 turn-off handler
handler_08_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_08
; Unused alias of F0 turn-off handler
handler_09_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_09
; Unused alias of F0 turn-off handler
handler_0A_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0A
; Unused alias of F0 turn-off handler
handler_0B_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0B
; Unused alias of F0 turn-off handler
handler_0C_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0C
; Unused alias of F0 turn-off handler
handler_0D_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0D
; Unused alias of F0 turn-off handler
handler_0E_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0E
; Unused alias of F0 turn-off handler
handler_0F_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0F
    LDY ram_sound_channel_index
    LDA #$00
    STA (ram_sfx_request_ptr),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    LDY ram_sound_channel_offset
    STA (ram_sound_channel_ptr),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    JMP loc_advance_to_next_sound_channel_entry

; Control F1: update channel register byte1 low 6 bits
handler_ctrl01_set_channel_reg1_low6:		; was: ofs_018_EFD7_01
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$01
    TAY
    LDA (ram_sound_channel_ptr),Y
    AND #$3F
    STA (ram_sound_channel_ptr),Y
    PLA
    ORA (ram_sound_channel_ptr),Y
    STA (ram_sound_channel_ptr),Y
    JMP loc_decode_sound_stream_byte

; Control F2: update channel register byte1 bits 4-5
handler_ctrl02_set_channel_reg1_mid2:		; was: ofs_018_EFEF_02
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$01
    TAY
    LDA (ram_sound_channel_ptr),Y    ; 0639
    AND #$CF
    STA (ram_sound_channel_ptr),Y    ; 0639
    PLA
    ORA (ram_sound_channel_ptr),Y    ; 0639
    STA (ram_sound_channel_ptr),Y    ; 0639
    JMP loc_decode_sound_stream_byte

; Control F3: update channel register byte1 low nibble
handler_ctrl03_set_channel_reg1_low4:		; was: ofs_018_F007_03
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$01
    TAY
    LDA (ram_sound_channel_ptr),Y    ; 0639
    AND #$F0
    STA (ram_sound_channel_ptr),Y    ; 0639
    PLA
    ORA (ram_sound_channel_ptr),Y    ; 0639
    STA (ram_sound_channel_ptr),Y    ; 0639
    JMP loc_decode_sound_stream_byte

; Control F4: write raw value into channel register byte2
handler_ctrl04_set_channel_reg2_raw:		; was: ofs_018_F01F_04
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$02
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y
    JMP loc_decode_sound_stream_byte

; Control F5: write raw value into channel register byte4
handler_ctrl05_set_channel_reg4_raw:		; was: ofs_018_F02F_05
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$04
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y    ; 063C 0644 064C 065C 069C
    JMP loc_decode_sound_stream_byte

; Control F6: write raw value into channel register byte1
handler_ctrl06_set_channel_reg1_raw:		; was: ofs_018_F03F_06
    JSR sub_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_sound_channel_offset
    CLC
    ADC #$01
    TAY
    PLA
    STA (ram_sound_channel_ptr),Y
    JMP loc_decode_sound_stream_byte

; Read next byte from channel stream pointer and advance stream pointer
sub_fetch_stream_byte_and_advance_ptr:		; was: sub_F04F_get_sound_data_and_increase_pointer
    LDA ram_sound_channel_offset
    CLC
    ADC #$05
    TAY
    LDA (ram_sound_channel_ptr),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    STA ram_sound_work_ptr
    INY
    LDA (ram_sound_channel_ptr),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    STA ram_sound_work_ptr + $01
; !(OBS) PHA/PLA is functionally redundant but retained for timing/layout. See resolved CODE-004.
    LDX #$00
    LDA (ram_sound_work_ptr,X)    ; data from 0x00309E
    PHA
    LDA ram_sound_work_ptr
    DEY
    CLC
    ADC #< $0001
    STA (ram_sound_channel_ptr),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    LDA ram_sound_work_ptr + $01
    ADC #> $0001
    INY
    STA (ram_sound_channel_ptr),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    PLA
    RTS

; Base 11-bit timer period pairs indexed by note high nibble
tbl_note_period_base_pairs:		; was: tbl_F074
    .byte $03, $F9   ; 00
    .byte $03, $C0   ; 10
    .byte $03, $8A   ; 20
    .byte $03, $57   ; 30
    .byte $03, $27   ; 40
    .byte $02, $FA   ; 50
    .byte $02, $CF   ; 60
    .byte $02, $A7   ; 70
    .byte $02, $81   ; 80
    .byte $02, $5D   ; 90
    .byte $02, $3B   ; A0
    .byte $02, $1B   ; B0

; Pointer to active SFX stream pointer table
tbl_sfx_stream_table_ptr:		; was: tbl_F08C
    .word tbl_sfx_stream_ptr_table

; SFX stream pointer table (16 entries)
tbl_sfx_stream_ptr_table:		; was: tbl_F08E
; bytes from data chunks are read via 0x003070
; Slot semantics are mapped from writers into ram_sfx slots 0600..060F.
; Entries 08..0E remain provisional until fully validated by trace/audio capture.
    .word off_sfx_slot00_player_ready_chA
    .word off_sfx_slot01_player_ready_chB
    .word off_sfx_slot02_extra_life
    .word off_sfx_slot03_death
    .word off_sfx_slot04_pellet_even
    .word off_sfx_slot05_pellet_odd
    .word off_sfx_slot06_fruit
    .word off_sfx_slot07_eat_ghost
    .word off_sfx_slot08_ghost_house_state6_marker
    .word off_sfx_slot09_ghost_house_release_marker
    .word off_sfx_slot0A_release_counter_hi
    .word off_sfx_slot0B_release_counter_mid
    .word off_sfx_slot0C_release_counter_lo
    .word off_sfx_slot0D_intermission_flag_a
    .word off_sfx_slot0E_intermission_flag_b
    .word off_sfx_slot0F_pause_toggle

; F0-FF control opcode constants (decoded by loc_decode_sound_stream_byte)
con_sfx_off                             = $F0 ; control opcode F0: turn sound off
con_sfx_ctrl_f2_set_reg1_mid2          = $F2 ; control opcode F2 -> handler ctrl02
con_sfx_ctrl_f3_set_reg1_low4          = $F3 ; control opcode F3 -> handler ctrl03
con_sfx_ctrl_f5_set_reg4_raw           = $F5 ; control opcode F5 -> handler ctrl05

; Stream byte classes used by loc_decode_sound_stream_byte:
; 00-BF = note/period nibble + duration byte follows
; C0-EF = duration-only update byte follows
; F0-FF = control opcode dispatched via tbl_sound_control_opcode_handlers
; Per-stream prologue layout consumed at stream start (see EECE..EF1A):
; byte0 -> channel state byte at offset +0
; byte1 -> channel register/control byte at offset +1
; byte2 -> channel register/control byte at offset +2
; byte3 -> channel register/control byte at offset +4
