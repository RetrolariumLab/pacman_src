; Sound engine and SFX streams




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
; SFX stream data #02
; SFX stream for slot 02 (extra life event)
off_F0AE_sfx_slot02_extra_life:		; was: _off001_F0AE_02
    .incbin "assets/generated/audio/slot02_extra_life.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot02_extra_life.bin", $13, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #06
; SFX stream for slot 06 (fruit event)
; Fast arpeggio-like pickup with short fixed durations.
off_F0C3_sfx_slot06_fruit:		; was: _off001_F0C3_06
    .incbin "assets/generated/audio/slot06_fruit.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot06_fruit.bin", $29, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0A
; SFX stream for slot 0A (ghost release counter high band)
off_F0EE_sfx_slot0A_release_counter_hi:		; was: _off001_F0EE_0A
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin", $29, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0B
; SFX stream for slot 0B (ghost release counter mid band)
off_F119_sfx_slot0B_release_counter_mid:		; was: _off001_F119_0B
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin", $21, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0C
; SFX stream for slot 0C (ghost release counter low band)
off_F13C_sfx_slot0C_release_counter_lo:		; was: _off001_F13C_0C
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin", $1D, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #09
; SFX stream for slot 09 (ghost-house release marker)
off_F15B_sfx_slot09_ghost_house_release_marker:		; was: _off001_F15B_09
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin", $13, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #07
; SFX stream for slot 07 (eat ghost)
off_F170_sfx_slot07_eat_ghost:		; was: _off001_F170_07
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1B, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot07_eat_ghost.bin", $21, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0D
; SFX stream for slot 0D (intermission flag A)
; Long scripted melody phrase used during intermission flow.
off_F193_sfx_slot0D_intermission_flag_a:		; was: _off001_F193_0D
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $29, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $2F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $30, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $31, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $32, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $33, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $34, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $35, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $36, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $37, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $38, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $39, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $3F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $40, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $41, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $42, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $43, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $44, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $45, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $46, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $47, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $48, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $49, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $4F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $50, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $51, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $52, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $53, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $54, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $55, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $56, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $57, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $58, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $59, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $5F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $60, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $61, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $62, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $63, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $64, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $65, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $66, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $67, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $68, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $69, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $6F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $70, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin", $71, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0E
; SFX stream for slot 0E (intermission flag B)
; Companion intermission phrase built mostly from C0-duration commands.
off_F206_sfx_slot0E_intermission_flag_b:		; was: _off001_F206_0E
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $29, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $2F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $30, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $31, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $32, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $33, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $34, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $35, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $36, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $37, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $38, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $39, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $3F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $40, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $41, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $42, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $43, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $44, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $45, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $46, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $47, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $48, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $49, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $4F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $50, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $51, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $52, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $53, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $54, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $55, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $56, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $57, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $58, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $59, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $5F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $60, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $61, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $62, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $63, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $64, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $65, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $66, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $67, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $68, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $69, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $6F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $70, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $71, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $72, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $73, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $74, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $75, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $76, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $77, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $78, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $79, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $7F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $80, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $81, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $82, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $83, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $84, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $85, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $86, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $87, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $88, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $89, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $8F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $90, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $91, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $92, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $93, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $94, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $95, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $96, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $97, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $98, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $99, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $9F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $A0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin", $A1, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #08
; SFX stream for slot 08 (ghost-house state marker)
off_F2A9_sfx_slot08_ghost_house_state6_marker:		; was: _off001_F2A9_08
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin", $1D, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #03
; SFX stream for slot 03 (player death)
; Descending multi-step death motif with long tail.
off_F2C8_sfx_slot03_death:		; was: _off001_F2C8_03
    .incbin "assets/generated/audio/slot03_death.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $29, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $2F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $30, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $31, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $32, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $33, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $34, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $35, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $36, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $37, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $38, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $39, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $3F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $40, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $41, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $42, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $43, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $44, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $45, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $46, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $47, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $48, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $49, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $4F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $50, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $51, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $52, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $53, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $54, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $55, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $56, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $57, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $58, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $59, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $5F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $60, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $61, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $62, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $63, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $64, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $65, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f2_set_reg1_mid2
    .incbin "assets/generated/audio/slot03_death.bin", $67, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f3_set_reg1_low4
    .incbin "assets/generated/audio/slot03_death.bin", $69, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot03_death.bin", $6B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $6C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $6D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $6E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $6F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $70, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $71, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $72, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $73, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $74, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $75, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $76, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $77, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $78, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $79, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $7F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $80, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $81, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $82, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $83, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $84, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $85, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $86, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $87, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $88, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $89, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $8A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $8B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $8C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot03_death.bin", $8D, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #00
; SFX stream for slot 00 (player ready channel A)
; "Ready" jingle lead voice.
off_F357_sfx_slot00_player_ready_chA:		; was: _off001_F357_00
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $29, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $2F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $30, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $31, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $32, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $33, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $34, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $35, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $36, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $37, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $38, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $39, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $3F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $40, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $41, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $42, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $43, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $44, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $45, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $46, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin", $47, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #01
; SFX stream for slot 01 (player ready channel B)
; "Ready" jingle companion voice.
off_F3A0_sfx_slot01_player_ready_chB:		; was: _off001_F3A0_01
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $10, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $12, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $13, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $14, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $15, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $16, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $17, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $18, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $19, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $1F, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $20, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $21, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $22, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $23, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $24, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $25, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $26, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $27, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $28, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin", $29, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #04
; SFX stream for slot 04 (pellet tick even)
; Short pellet click variant A (alternates with slot05).
off_F3CB_sfx_slot04_pellet_even:		; was: _off001_F3CB_04
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $B, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $C, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $D, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot04_pellet_even.bin", $F, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #05
; SFX stream for slot 05 (pellet tick odd)
; Short pellet click variant B (alternates with slot04).
off_F3DC_sfx_slot05_pellet_odd:		; was: _off001_F3DC_05
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $B, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot05_pellet_odd.bin", $F, $1  ; rom-asset .byte
    .byte con_sfx_off
; SFX stream data #0F
; SFX stream for slot 0F (pause toggle)
; Pause chirp sequence with repeated F5 register updates.
off_F3ED_sfx_slot0F_pause_toggle:		; was: _off001_F3ED_0F
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $0, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $1, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $2, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $3, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $4, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $5, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $6, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $7, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $8, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $9, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $A, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $B, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $D, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $E, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $F, $1  ; rom-asset .byte
    .byte con_sfx_ctrl_f5_set_reg4_raw
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $11, $1  ; rom-asset .byte
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin", $12, $1  ; rom-asset .byte
