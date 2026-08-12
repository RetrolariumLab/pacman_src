; Sound engine, note periods, and SFX pointer table




; Initialize sound engine pointers, APU channel enables, and frame counter mode
sub_EE18_init_sound_engine:		; was: sub_EE18
    LDA #< ram_sfx
    STA ram_00F0
    LDA #> ram_sfx
    STA ram_00F1
    LDA #< ram_0625
    STA ram_00F2
    LDA #> ram_0620
    STA ram_00F3
    LDA tbl_F08C_sfx_stream_table_ptr
    STA ram_00F4
    LDA tbl_F08C_sfx_stream_table_ptr + $01
    STA ram_00F5
    LDA #$40
    STA ram_00F7
    LDA #$1F
    STA $4015
    LDA #$C0
    STA $4017
; Clear per-channel sound effect state and command slots
sub_EE40_clear_sound_engine_state:		; was: sub_EE40
    LDY #$00
    LDA #$00
; Clear 16-byte SFX request/state area
bra_EE44_loop_clear_sfx_request_slots:		; was: bra_EE44_loop
    STA (ram_00F0),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    INY
    CPY #$10
    BNE bra_EE44_loop_clear_sfx_request_slots
    LDY #$00
    LDX #$10
; Clear one command byte per 8-byte channel struct
bra_EE4F_loop_clear_channel_command_slots:		; was: bra_EE4F_loop
    LDA #$00
    STA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    TYA
    CLC
    ADC #$08
    TAY
    DEX
    BNE bra_EE4F_loop_clear_channel_command_slots
    RTS



; Frame sound tick:
; 1) pre-pass for channel request arbitration
; 2) per-channel stream decode/update
; 3) immediate APU writes for updated channel quads
sub_EE5C_update_sound_engine:
    LDA #$00
    STA ram_00F8
    STA ram_00F9
    STA ram_00FA
    STA ram_00FB
    STA ram_00FD
    STA ram_00FF
    LDA #$F8    ; < ram_00F8
    STA ram_00FE
; Pre-pass over channels to detect command conflicts
bra_EE6E_loop_scan_channel_command_slots:		; was: bra_EE6E_loop
    LDY ram_00FD
    LDA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    BEQ bra_EEAE_advance_channel_prepass
    CMP #$05
    BCC bra_EE83_handle_low_priority_channel_request
    SEC
    SBC #$05
    TAY
    LDA #$01
    STA (ram_00FE),Y    ; 00F8 00F9 00FA
    JMP loc_EEAE_advance_channel_prepass_entry
; Handle 01..04 channel request with deduplication
bra_EE83_handle_low_priority_channel_request:		; was: bra_EE83
    SEC
    SBC #$01
    TAY
    LDA (ram_00FE),Y    ; 00F8 00F9 00FA
    BNE bra_EEAE_advance_channel_prepass
    LDA #$01
    STA (ram_00FE),Y    ; 00F8 00F9 00FA
    TYA
    TAX
    ADC #$04
    LDY ram_00FD
    STA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    TXA
    ASL
    ASL
    STA ram_00F6
    LDX #$00
    LDA #$04
; Write 4-byte APU register quad for selected channel
bra_EEA0_loop_write_apu_register_quad:		; was: bra_EEA0_loop
    PHA
    INY
    LDA (ram_00F2),Y    ; 0621-069C
    STA (ram_00F6,X)    ; 4000 4001 4002 4003 4004 4005 4006 4007 4008 4009 400A 400B
    INC ram_00F6
    PLA
    SEC
    SBC #$01
    BNE bra_EEA0_loop_write_apu_register_quad
; Advance to next channel slot in pre-pass
bra_EEAE_advance_channel_prepass:		; was: bra_EEAE
; Shared entry for channel pre-pass advancement
loc_EEAE_advance_channel_prepass_entry:		; was: loc_EEAE
    LDA ram_00FD
    CLC
    ADC #$08
    STA ram_00FD
    CMP #$80
    BCC bra_EE6E_loop_scan_channel_command_slots
    LDY #$00
    STY ram_00FC
    STY ram_00FD
; Main per-channel sound stream update loop
loc_EEBF_sound_channel_main_loop:		; was: loc_EEBF
    LDY ram_00FC
    LDA (ram_00F0),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    BNE bra_EEC8_channel_has_active_stream
    JMP loc_EF84_advance_to_next_sound_channel_entry
; Channel has pending stream; update countdown or decode
bra_EEC8_channel_has_active_stream:		; was: bra_EEC8
    LDY ram_00FD
    LDA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    BNE bra_EF1F_decrement_channel_duration
    LDA ram_00FC
    ASL
    TAY
    LDA (ram_00F4),Y    ; low pointers 0x00309E
    PHA
    LDA ram_00FD
    ADC #$05
    TAY
    PLA
    STA (ram_00F2),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    LDA ram_00FC
    ASL
    ADC #$01
    TAY
    LDA (ram_00F4),Y    ; high pointers 0x00309E
    PHA
    LDA ram_00FD
    ADC #$06
    TAY
    PLA
    STA (ram_00F2),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    LDY ram_00FD
    STA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_00FD
    CLC
    ADC #$01
    TAY
    TXA
    STA (ram_00F2),Y    ; 0621 0629 0631 0639 0641 0649 0651 0659 0661 0669 0671 0679 0681 0689 0691 0699
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_00FD
    CLC
    ADC #$02
    TAY
    TXA
    STA (ram_00F2),Y    ; 0622 062A 0632 063A 0642 064A 0652 065A 0662 066A 0672 067A 0682 068A 0692 069A
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    TAX
    LDA ram_00FD
    CLC
    ADC #$04
    TAY
    TXA
    STA (ram_00F2),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    JMP loc_EF2E_decode_sound_stream_byte
; Decrement active channel duration counter
bra_EF1F_decrement_channel_duration:		; was: bra_EF1F
    LDA ram_00FD
    CLC
    ADC #$07
    TAY
    LDA (ram_00F2),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
    SEC
    SBC #$01
    STA (ram_00F2),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
    BNE bra_EF84_advance_to_next_sound_channel
; Decode next sound stream byte for active channel
loc_EF2E_decode_sound_stream_byte:		; was: loc_EF2E
; Stream byte classes:
; 00-BF -> note code (pitch nibble + shift nibble)
; C0-EF -> explicit duration byte follows
; F0-FF -> control opcode via tbl_EFAA_sound_control_opcode_handlers
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    CMP #$F0
    BCS bra_EF99_dispatch_f0_ff_control_opcode
    CMP #$C0
    BCS bra_EF77_C0_EF_fetch_channel_duration_byte_alias
; 00-BF
    PHA
    AND #$F0
    LSR
    LSR
    LSR
    TAX
    LDA tbl_F074_note_period_base_pairs,X
    STA ram_00FE
    LDA tbl_F074_note_period_base_pairs + $01,X
    STA ram_00FF
    PLA
    AND #$0F
    BEQ bra_EF57_00_apply_note_period_to_channel
; 01-0F
    TAX
; Shift note period base by nibble amount
bra_EF50_loop_shift_note_period:		; was: bra_EF50_loop
    LSR ram_00FE
    ROR ram_00FF
    DEX
    BNE bra_EF50_loop_shift_note_period
; Apply computed note period into channel registers
bra_EF57_00_apply_note_period_to_channel:		; was: bra_EF57_00
    LDA ram_00FD
    CLC
    ADC #$04
    TAY
    LDA (ram_00F2),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    AND #$F8
    ORA ram_00FE
    STA (ram_00F2),Y    ; 0624 062C 0634 063C 0644 064C 0654 065C 0664 066C 0674 067C 0684 068C 0694 069C
    LDA ram_00FF
    DEY
    STA (ram_00F2),Y    ; 0623 062B 0633 063B 0643 064B 0653 065B 0663 066B 0673 067B 0683 068B 0693 069B
    LDY ram_00FD
    LDA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    CMP #$05
    BCC bra_EF77_fetch_channel_duration_byte
    SEC
    SBC #$04
    STA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
; Fetch next duration byte after note/control handling
bra_EF77_fetch_channel_duration_byte:		; was: bra_EF77
; Alias entry for C0-EF command path to duration fetch
bra_EF77_C0_EF_fetch_channel_duration_byte_alias:		; was: bra_EF77_C0_EF
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$07
    TAY
    PLA
    STA (ram_00F2),Y    ; 0627 062F 0637 063F 0647 064F 0657 065F 0667 066F 0677 067F 0687 068F 0697 069F
; Advance to next sound channel slot
bra_EF84_advance_to_next_sound_channel:		; was: bra_EF84
; Shared entry to advance to next sound channel
loc_EF84_advance_to_next_sound_channel_entry:		; was: loc_EF84
    LDA ram_00FD
    CLC
    ADC #$08
    STA ram_00FD
    LDA ram_00FC
    ADC #$01
    STA ram_00FC
    CMP #$10
    BCS bra_EF98_sound_update_done
    JMP loc_EEBF_sound_channel_main_loop
; All channels processed for this frame
bra_EF98_sound_update_done:		; was: bra_EF98_RTS
    RTS
; Dispatch F0-FF control opcode via handler table
bra_EF99_dispatch_f0_ff_control_opcode:		; was: bra_EF99_F0_FF_control_byte
    AND #$0F
    ASL
    TAX
    LDA tbl_EFAA_sound_control_opcode_handlers,X
    STA ram_00FE
    LDA tbl_EFAA_sound_control_opcode_handlers + $01,X
    STA ram_00FF
    JMP (ram_00FE)



; Handler table for F0-FF sound control opcodes
tbl_EFAA_sound_control_opcode_handlers:		; was: tbl_EFAA
; Several opcode entries are effectively aliases/unused in this title build.
; Active opcodes seen in streams: F0, F2, F3, F5.
    .word ofs_018_EFCA_00_turn_sound_off
    .word ofs_018_EFD7_ctrl01_set_channel_reg1_low6   ; never used
    .word ofs_018_EFEF_ctrl02_set_channel_reg1_mid2
    .word ofs_018_F007_ctrl03_set_channel_reg1_low4
    .word ofs_018_F01F_ctrl04_set_channel_reg2_raw   ; never used
    .word ofs_018_F02F_ctrl05_set_channel_reg4_raw
    .word ofs_018_F03F_ctrl06_set_channel_reg1_raw   ; never used
    .word ofs_018_EFCA_07_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_08_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_09_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0A_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0B_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0C_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0D_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0E_unused_alias_turn_sound_off   ; never used
    .word ofs_018_EFCA_0F_unused_alias_turn_sound_off   ; never used



ofs_018_EFCA_00_turn_sound_off:
; Unused alias of F0 turn-off handler
ofs_018_EFCA_07_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_07
; Unused alias of F0 turn-off handler
ofs_018_EFCA_08_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_08
; Unused alias of F0 turn-off handler
ofs_018_EFCA_09_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_09
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0A_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0A
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0B_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0B
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0C_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0C
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0D_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0D
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0E_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0E
; Unused alias of F0 turn-off handler
ofs_018_EFCA_0F_unused_alias_turn_sound_off:		; was: ofs_018_EFCA_0F
    LDY ram_00FC
    LDA #$00
    STA (ram_00F0),Y    ; 0600 0601 0602 0603 0604 0605 0606 0607 0608 0609 060A 060B 060C 060D 060E 060F
    LDY ram_00FD
    STA (ram_00F2),Y    ; 0620 0628 0630 0638 0640 0648 0650 0658 0660 0668 0670 0678 0680 0688 0690 0698
    JMP loc_EF84_advance_to_next_sound_channel_entry



; Control F1: update channel register byte1 low 6 bits
ofs_018_EFD7_ctrl01_set_channel_reg1_low6:		; was: ofs_018_EFD7_01
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$01
    TAY
    LDA (ram_00F2),Y
    AND #$3F
    STA (ram_00F2),Y
    PLA
    ORA (ram_00F2),Y
    STA (ram_00F2),Y
    JMP loc_EF2E_decode_sound_stream_byte



; Control F2: update channel register byte1 bits 4-5
ofs_018_EFEF_ctrl02_set_channel_reg1_mid2:		; was: ofs_018_EFEF_02
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$01
    TAY
    LDA (ram_00F2),Y    ; 0639
    AND #$CF
    STA (ram_00F2),Y    ; 0639
    PLA
    ORA (ram_00F2),Y    ; 0639
    STA (ram_00F2),Y    ; 0639
    JMP loc_EF2E_decode_sound_stream_byte



; Control F3: update channel register byte1 low nibble
ofs_018_F007_ctrl03_set_channel_reg1_low4:		; was: ofs_018_F007_03
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$01
    TAY
    LDA (ram_00F2),Y    ; 0639
    AND #$F0
    STA (ram_00F2),Y    ; 0639
    PLA
    ORA (ram_00F2),Y    ; 0639
    STA (ram_00F2),Y    ; 0639
    JMP loc_EF2E_decode_sound_stream_byte



; Control F4: write raw value into channel register byte2
ofs_018_F01F_ctrl04_set_channel_reg2_raw:		; was: ofs_018_F01F_04
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$02
    TAY
    PLA
    STA (ram_00F2),Y
    JMP loc_EF2E_decode_sound_stream_byte



; Control F5: write raw value into channel register byte4
ofs_018_F02F_ctrl05_set_channel_reg4_raw:		; was: ofs_018_F02F_05
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$04
    TAY
    PLA
    STA (ram_00F2),Y    ; 063C 0644 064C 065C 069C
    JMP loc_EF2E_decode_sound_stream_byte



; Control F6: write raw value into channel register byte1
ofs_018_F03F_ctrl06_set_channel_reg1_raw:		; was: ofs_018_F03F_06
    JSR sub_F04F_fetch_stream_byte_and_advance_ptr
    PHA
    LDA ram_00FD
    CLC
    ADC #$01
    TAY
    PLA
    STA (ram_00F2),Y
    JMP loc_EF2E_decode_sound_stream_byte



; Read next byte from channel stream pointer and advance stream pointer
sub_F04F_fetch_stream_byte_and_advance_ptr:		; was: sub_F04F_get_sound_data_and_increase_pointer
    LDA ram_00FD
    CLC
    ADC #$05
    TAY
    LDA (ram_00F2),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    STA ram_00FE
    INY
    LDA (ram_00F2),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    STA ram_00FF
; bzk optimize, read (ram_00FE,X) at the end instead of PHA + PLA
    LDX #$00
    LDA (ram_00FE,X)    ; data from 0x00309E
    PHA
    LDA ram_00FE
    DEY
    CLC
    ADC #< $0001
    STA (ram_00F2),Y    ; 0625 062D 0635 063D 0645 064D 0655 065D 0665 066D 0675 067D 0685 068D 0695 069D
    LDA ram_00FF
    ADC #> $0001
    INY
    STA (ram_00F2),Y    ; 0626 062E 0636 063E 0646 064E 0656 065E 0666 066E 0676 067E 0686 068E 0696 069E
    PLA
    RTS



; Base 11-bit timer period pairs indexed by note high nibble
tbl_F074_note_period_base_pairs:		; was: tbl_F074
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
tbl_F08C_sfx_stream_table_ptr:		; was: tbl_F08C
    .word tbl_F08E_sfx_stream_ptr_table



; SFX stream pointer table (16 entries)
tbl_F08E_sfx_stream_ptr_table:		; was: tbl_F08E
; bytes from data chunks are read via 0x003070
; Slot semantics are mapped from writers into ram_sfx slots 0600..060F.
; Entries 08..0E remain provisional until fully validated by trace/audio capture.
    .word off_F357_sfx_slot00_player_ready_chA
    .word off_F3A0_sfx_slot01_player_ready_chB
    .word off_F0AE_sfx_slot02_extra_life
    .word off_F2C8_sfx_slot03_death
    .word off_F3CB_sfx_slot04_pellet_even
    .word off_F3DC_sfx_slot05_pellet_odd
    .word off_F0C3_sfx_slot06_fruit
    .word off_F170_sfx_slot07_eat_ghost
    .word off_F2A9_sfx_slot08_ghost_house_state6_marker
    .word off_F15B_sfx_slot09_ghost_house_release_marker
    .word off_F0EE_sfx_slot0A_release_counter_hi
    .word off_F119_sfx_slot0B_release_counter_mid
    .word off_F13C_sfx_slot0C_release_counter_lo
    .word off_F193_sfx_slot0D_intermission_flag_a
    .word off_F206_sfx_slot0E_intermission_flag_b
    .word off_F3ED_sfx_slot0F_pause_toggle



; F0-FF control opcode constants (decoded by loc_EF2E -> tbl_EFAA_sound_control_opcode_handlers)
con_sfx_off                             = $F0 ; control opcode F0: turn sound off
con_sfx_ctrl_f2_set_reg1_mid2          = $F2 ; control opcode F2 -> handler ctrl02
con_sfx_ctrl_f3_set_reg1_low4          = $F3 ; control opcode F3 -> handler ctrl03
con_sfx_ctrl_f5_set_reg4_raw           = $F5 ; control opcode F5 -> handler ctrl05


; Stream byte classes used by decoder at loc_EF2E:
; 00-BF = note/period nibble + duration byte follows
; C0-EF = duration-only update byte follows
; F0-FF = control opcode dispatched via tbl_EFAA_sound_control_opcode_handlers
; Per-stream prologue layout consumed at stream start (see EECE..EF1A):
; byte0 -> channel state byte at offset +0
; byte1 -> channel register/control byte at offset +1
; byte2 -> channel register/control byte at offset +2
; byte3 -> channel register/control byte at offset +4
