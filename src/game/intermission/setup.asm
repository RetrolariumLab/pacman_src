; Intermission setup, playfield clearing, and intro palette

; Script 0E: intermission pre-setup (clear playfield, palette, actor seed state)
; Intermission field legend:
; ram_intermission_scene: even-valued scene-table offset (00/02/04)
; ram_intermission_substate: scene-local substate index
; ram_intermission_countdown: per-substate countdown in some scenes
; ram_sfx_intermission_flag_a/ram_sfx_intermission_flag_b: one-shot flags used by intermission setup/runtime
; Actor sprite-set and attribute arrays seed the initial cutscene composition
; Inputs: selected intermission scene, current player/game mode, PPU in gameplay state
; Outputs: cleared playfield, seeded actors/palette, substate 00, script 10 selected
; Side effects: waits for vblank, temporarily disables rendering, writes PPU directly
; Clobbers: A, X, Y and zp_work0..zp_work3
handler_script0E_intermission_setup:  ; was: ofs_003_E655_0E
    LDA #PPUCTRL_SPRITE_PATTERN_HIGH
    STA ram_ppuctrl_base
    STA PPUCTRL
; Wait for vblank before enabling intro setup flags
bra_wait_vblank_set_flag:  ; was: bra_E65C_infinite_loop
    LDA PPUSTATUS
    BPL bra_wait_vblank_set_flag
    LDA #$01
    STA ram_sfx_intermission_flag_a
    STA ram_sfx_intermission_flag_b
    LDA #$00
    STA PPUMASK
    JSR sub_clear_playfield_and_walls
    LDA #$01
    STA ram_actor_sprite_set + $01
    LDA #$01
    STA ram_actor_sprite_attrs + $01
    LDA #$F7
    STA ram_spr_pos_X_hi + $04
    LDA #$7C
    STA ram_spr_pos_Y_hi + $04
    LDA #< $00FF
    STA ram_obj_pos_X_hi + $04
    LDA #> $00FF
    STA ram_obj_pos_X_lo + $04
    LDA #$00  ; every intermission scene begins at its first substate
    STA ram_intermission_substate
.ifndef PACMAN_REVISION_RAM_PALETTES
    SetPpuAddress $3F10
.endif
    LDY #$00
; Upload sprite palette for intro/demo setup
bra_upload_demo_sprite_palette:  ; was: bra_E6A0_loop
.ifdef PACMAN_EXPANDED_PALETTES
    LDA tbl_expanded_intro_sprite_palette,Y
.else
    LDA tbl_intro_sprite_palette,Y
.endif
.ifdef PACMAN_REVISION_RAM_PALETTES
    STA ram_sprite_palette_update,Y
.else
    STA PPUDATA
.endif
    INY
    CPY #$10
    BNE bra_upload_demo_sprite_palette
    LDA #con_tile_space
    STA ram_ppu_buffer_1up + $02
    STA ram_ppu_buffer_1up + $03
    STA ram_ppu_buffer_1up + $04
    LDA #con_game_script_intermission_runtime
    STA ram_script
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    JMP loc_gameplay_mainloop_wait_nmi

; Clear the active playfield and attributes, with scene01's optional center marker
; Inputs: current player/game mode and intermission scene ID
; Outputs: selected nametable playfield/attribute region rewritten
; Side effects: direct PPU writes; caller must own rendering/vblank timing
; Clobbers: A, X and zp_work0..zp_work3; Y is preserved
sub_clear_playfield_and_walls:  ; was: sub_E6C4
    LDX #$20  ; 2000
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_select_playfield_nametable
    LDX #$28  ; 2800
; Select active playfield nametable for current player
bra_select_playfield_nametable:  ; was: bra_E6CE
    LDA PPUSTATUS
    STX PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$1C
    STA zp_work0
; Fill one playfield row pattern block
bra_fill_playfield_row_pattern:  ; was: bra_E6DD_loop
    LDA #$02
    STA zp_work1
    LDA #$1C
    STA zp_work2
    LDA #$02
    STA zp_work3
    LDA #$2D
; Write pattern byte sequence for playfield row
bra_write_playfield_pattern_byte:  ; was: bra_E6EB_loop
    STA PPUDATA
    LDX zp_work1
    BEQ bra_switch_pattern_phase
    DEC zp_work1
    BNE bra_write_playfield_pattern_byte
    LDA #$20
    BNE bra_write_playfield_pattern_byte  ; jmp
; Switch between wall/background pattern phases
bra_switch_pattern_phase:  ; was: bra_E6FA
    LDX zp_work2
    BEQ bra_advance_pattern_repeat_counter
    DEC zp_work2
    BNE bra_write_playfield_pattern_byte
    LDA #$2D
    BNE bra_write_playfield_pattern_byte  ; jmp
; Advance pattern repeat counter
bra_advance_pattern_repeat_counter:  ; was: bra_E706
    DEC zp_work3
    BNE bra_write_playfield_pattern_byte
    DEC zp_work0
    BNE bra_fill_playfield_row_pattern
    LDA #$00
    TAX
; Clear attribute block bytes
bra_clear_attribute_block:  ; was: bra_E711_loop
    STA PPUDATA
    INX
    CPX #$40
    BNE bra_clear_attribute_block
    LDA ram_intermission_scene
    CMP #con_intermission_scene_ripped_suit
    BEQ bra_draw_center_marker_if_mode2
    RTS
; Draw center marker tile for mode 2
bra_draw_center_marker_if_mode2:  ; was: bra_E720
    LDX #$22  ; 2230
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_select_center_marker_nametable
    LDX #$2A  ; 2A30
; Select nametable for center marker
bra_select_center_marker_nametable:  ; was: bra_E72A
    LDA PPUSTATUS
    STX PPUADDR
    LDA #$30
    STA PPUADDR
    LDA #$5E
    STA PPUDATA
    RTS

; Sprite palette used by intro/demo setup
tbl_intro_sprite_palette:  ; was: tbl_E73B_spr_palette
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
