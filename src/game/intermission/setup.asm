; Intermission setup, playfield clearing, and intro palette




; Script 0E: intermission pre-setup (clear playfield, palette, actor seed state)
; Intermission field legend:
; ram_0087: scene index (0..2)
; ram_0088: scene-local substate index
; ram_0089: per-substate countdown in some scenes
; ram_060D/ram_060E: one-shot flags used by intermission setup/runtime
; ram_028D/ram_0293: actor tile/state seeds for initial cutscene composition
ofs_003_E655_script0E_intermission_setup:		; was: ofs_003_E655_0E
    LDA #$08
    STA ram_for_2000
    STA $2000
; Wait for vblank before enabling intro setup flags
bra_E65C_wait_vblank_set_flag:		; was: bra_E65C_infinite_loop
    LDA $2002
    BPL bra_E65C_wait_vblank_set_flag
    LDA #$01
    STA ram_060D
    STA ram_060E
    LDA #$00
    STA $2001
    JSR sub_E6C4_clear_playfield_and_walls
    LDA #$01
    STA ram_028D
    LDA #$01
    STA ram_0293
    LDA #$F7
    STA ram_spr_pos_X_hi + $04
    LDA #$7C
    STA ram_spr_pos_Y_hi + $04
    LDA #< $00FF
    STA ram_obj_pos_X_hi + $04
    LDA #> $00FF
    STA ram_obj_pos_X_lo + $04
    LDA #$00
    STA ram_0088
    SetPpuAddress $3F10
    LDY #$00
; Upload sprite palette for intro/demo setup
bra_E6A0_upload_demo_sprite_palette:		; was: bra_E6A0_loop
    LDA tbl_E73B_intro_sprite_palette,Y
    STA $2007
    INY
    CPY #$10
    BNE bra_E6A0_upload_demo_sprite_palette
    LDA #con_tile + $20
    STA ram_ppu_buffer_1up + $02
    STA ram_ppu_buffer_1up + $03
    STA ram_ppu_buffer_1up + $04
    LDA #con_script_10
    STA ram_script
    LDA #$88
    STA $2000
    STA ram_for_2000
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Clear playfield area and rebuild maze wall fill pattern
sub_E6C4_clear_playfield_and_walls:		; was: sub_E6C4
    LDX #$20    ; 2000
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E6CE_select_playfield_nametable
    LDX #$28    ; 2800
; Select active playfield nametable for current player
bra_E6CE_select_playfield_nametable:		; was: bra_E6CE
    LDA $2002
    STX $2006
    LDA #$00
    STA $2006
    LDA #$1C
    STA ram_0000
; Fill one playfield row pattern block
bra_E6DD_fill_playfield_row_pattern:		; was: bra_E6DD_loop
    LDA #$02
    STA ram_0001
    LDA #$1C
    STA ram_0002
    LDA #$02
    STA ram_0003
    LDA #$2D
; Write pattern byte sequence for playfield row
bra_E6EB_write_playfield_pattern_byte:		; was: bra_E6EB_loop
    STA $2007
    LDX ram_0001
    BEQ bra_E6FA_switch_pattern_phase
    DEC ram_0001
    BNE bra_E6EB_write_playfield_pattern_byte
    LDA #$20
    BNE bra_E6EB_write_playfield_pattern_byte    ; jmp
; Switch between wall/background pattern phases
bra_E6FA_switch_pattern_phase:		; was: bra_E6FA
    LDX ram_0002
    BEQ bra_E706_advance_pattern_repeat_counter
    DEC ram_0002
    BNE bra_E6EB_write_playfield_pattern_byte
    LDA #$2D
    BNE bra_E6EB_write_playfield_pattern_byte    ; jmp
; Advance pattern repeat counter
bra_E706_advance_pattern_repeat_counter:		; was: bra_E706
    DEC ram_0003
    BNE bra_E6EB_write_playfield_pattern_byte
    DEC ram_0000
    BNE bra_E6DD_fill_playfield_row_pattern
    LDA #$00
    TAX
; Clear attribute block bytes
bra_E711_clear_attribute_block:		; was: bra_E711_loop
    STA $2007
    INX
    CPX #$40
    BNE bra_E711_clear_attribute_block
    LDA ram_0087
    CMP #$02
    BEQ bra_E720_draw_center_marker_if_mode2
    RTS
; Draw center marker tile for mode 2
bra_E720_draw_center_marker_if_mode2:		; was: bra_E720
    LDX #$22    ; 2230
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E72A_select_center_marker_nametable
    LDX #$2A    ; 2A30
; Select nametable for center marker
bra_E72A_select_center_marker_nametable:		; was: bra_E72A
    LDA $2002
    STX $2006
    LDA #$30
    STA $2006
    LDA #$5E
    STA $2007
    RTS



; Sprite palette used by intro/demo setup
tbl_E73B_intro_sprite_palette:		; was: tbl_E73B_spr_palette
    .incbin "assets/generated/palettes/intermission-sprites.bin", $0, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/intermission-sprites.bin", $4, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/intermission-sprites.bin", $8, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/intermission-sprites.bin", $C, $4  ; rom-asset .byte
; Gameplay script 10: run active intermission scene state machine
; Script 10: intermission runtime (cutscene actor movement + per-scene animation)
; Per-frame order in script10:
; 1) integrate actor positions/visibility bounds
; 2) mutate animation tiles for current scene/substate
; 3) rebuild OAM from sprite buffers
; 4) run scene/substate logic and transitions
