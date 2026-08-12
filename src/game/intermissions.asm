; Intermission setup, runtime, and animation scripts




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
    LDA $2002
    LDA #> $3F10
    STA $2006
    LDA #< $3F10
    STA $2006
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
ofs_003_E74B_script10_intermission_runtime:		; was: ofs_003_E74B_10
    JSR sub_E9A5_update_intermission_actor_positions
    JSR sub_EA20_run_intermission_animation_dispatch
    JSR sub_DA5C_build_oam_from_sprite_buffers
    JSR sub_E75A_run_intermission_scene_dispatch
    JMP loc_C9DD_gameplay_mainloop_wait_nmi
; Dispatch selected intermission scene handler by ram_0087 (scene id)
sub_E75A_run_intermission_scene_dispatch:		; was: sub_E75A
    LDY ram_0087
    LDA tbl_E769_intermission_scene_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_E769_intermission_scene_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Intermission scene handler table (scene 0/1/2)
; Scene id mapping:
; 00 -> first chase scene
; 01 -> ripped-suit gag scene
; 02 -> return/chaser finale
tbl_E769_intermission_scene_handlers:		; was: tbl_E769
    .word ofs_012_E76F_scene00_chase_opening
    .word ofs_012_E853_scene01_chase_rip_opening
    .word ofs_012_E8FA_scene02_chase_return_opening



; Intermission scene 00 (first cutscene) state machine
; Uses ram_0088 as substate selector into tbl_E77E_scene00_state_handlers.
ofs_012_E76F_scene00_chase_opening:		; was: ofs_012_E76F_00
    LDY ram_0088
    LDA tbl_E77E_scene00_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_E77E_scene00_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for intermission scene 00
tbl_E77E_scene00_state_handlers:		; was: tbl_E77E
    .word ofs_013_E786_scene00_wait_enemy4_left_entry
    .word ofs_013_E7AF_scene00_wait_pacman_wrap_left
    .word ofs_013_E7DA_scene00_wait_pacman_midpoint
    .word ofs_013_E846_scene00_wait_ghost_pack_wrap



; Wait until enemy 4 reaches trigger X, then initialize chase actor
ofs_013_E786_scene00_wait_enemy4_left_entry:		; was: ofs_013_E786_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$D0
    BCC bra_E78E_scene00_start_chase_actor
    RTS
; Advance to scene00 chase phase and seed actor movement
bra_E78E_scene00_start_chase_actor:		; was: bra_E78E
    INC ram_0088
    INC ram_0088
    LDA #$0C
    STA ram_028C
    LDA #$20
    STA ram_0292
    LDA #$F7
    STA ram_spr_pos_X_hi
    LDA #$7C
    STA ram_spr_pos_Y_hi
    LDA #> $FEE0
    STA ram_obj_pos_X_hi
    LDA #< $FEE0
    STA ram_obj_pos_X_lo
    RTS



; Wait for lead actor to wrap left edge
ofs_013_E7AF_scene00_wait_pacman_wrap_left:		; was: ofs_013_E7AF_02
    LDA ram_spr_pos_X_hi
    BEQ bra_E7B5_scene00_spawn_pacman_runner
    RTS
; Spawn Pac-Man runner and set motion
bra_E7B5_scene00_spawn_pacman_runner:		; was: bra_E7B5
    INC ram_0088
    INC ram_0088
    LDA #$40
    STA ram_004C
    LDA #$1E
    STA ram_028C
    LDA #$22
    STA ram_0292
    LDA #$09
    STA ram_spr_pos_X_hi
    LDA #$7C
    STA ram_spr_pos_Y_hi
    LDA #> $0100
    STA ram_obj_pos_X_hi
    LDA #< $0100
    STA ram_obj_pos_X_lo
    RTS



; Mark actors visible and wait for Pac-Man midpoint trigger
ofs_013_E7DA_scene00_wait_pacman_midpoint:		; was: ofs_013_E7DA_04
    LDA #$01
    STA ram_060D
    STA ram_060E
    LDA ram_spr_pos_X_hi
    CMP #$80
    BCS bra_E7EA_scene00_spawn_ghost_pack
    RTS
; Spawn ghost pack and initialize formation tiles
bra_E7EA_scene00_spawn_ghost_pack:		; was: bra_E7EA
    INC ram_0088
    INC ram_0088
    LDA #> $01C0
    STA ram_obj_pos_X_hi + $04
    STA ram_obj_pos_X_hi + $08
    STA ram_obj_pos_X_hi + $0C
    STA ram_obj_pos_X_hi + $10
    LDA #< $01C0
    STA ram_obj_pos_X_lo + $04
    STA ram_obj_pos_X_lo + $08
    STA ram_obj_pos_X_lo + $0C
    STA ram_obj_pos_X_lo + $10
    CLC
    LDA #$38
    STA ram_028D
    ADC #$01
    STA ram_028E
    ADC #$01
    STA ram_028F
    ADC #$01
    STA ram_0290
    LDA #$21
    STA ram_0293
    STA ram_0294
    STA ram_0295
    STA ram_0296
    LDA #$09
    STA ram_spr_pos_X_hi + $04
    STA ram_spr_pos_X_hi + $0C
    LDA #$19
    STA ram_spr_pos_X_hi + $08
    STA ram_spr_pos_X_hi + $10
    LDA #$6C
    STA ram_spr_pos_Y_hi + $04
    STA ram_spr_pos_Y_hi + $08
    LDA #$7C
    STA ram_spr_pos_Y_hi + $0C
    STA ram_spr_pos_Y_hi + $10
    RTS



; Wait ghost pack wrap and finish scene
ofs_013_E846_scene00_wait_ghost_pack_wrap:		; was: ofs_013_E846_06
    LDA ram_spr_pos_X_hi + $04
    BEQ bra_E84C_scene00_finish_to_script00
    RTS
; Finish scene00 and return to script00
bra_E84C_scene00_finish_to_script00:		; was: bra_E84C
    LDA #$40
    STA ram_004C
    JMP loc_E9A0_set_script00_return



; Intermission scene 01 (second cutscene) state machine
ofs_012_E853_scene01_chase_rip_opening:		; was: ofs_012_E853_02
    LDY ram_0088
    LDA tbl_E862_scene01_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_E862_scene01_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for intermission scene 01
; 00: wait trigger + spawn lead actor
; 02: transform to ripped-suit phase
; 04: blink ripped tiles then finish
tbl_E862_scene01_state_handlers:		; was: tbl_E862
    .word ofs_014_E868_scene01_wait_enemy4_left_entry
    .word ofs_014_E891_scene01_handle_rip_transform
    .word ofs_014_E8CB_scene01_blink_rip_tiles_then_finish



; Wait enemy 4 position then init chase actor for scene01
ofs_014_E868_scene01_wait_enemy4_left_entry:		; was: ofs_014_E868_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$A0
    BCC bra_E870_scene01_start_chase_actor
    RTS
; Advance scene01 and seed chase actor movement
bra_E870_scene01_start_chase_actor:		; was: bra_E870
    INC ram_0088
    INC ram_0088
    LDA #$0C
    STA ram_028C
    LDA #$20
    STA ram_0292
    LDA #$F7
    STA ram_spr_pos_X_hi
    LDA #$7C
    STA ram_spr_pos_Y_hi
    LDA #> $FF00
    STA ram_obj_pos_X_hi
    LDA #< $FF00
    STA ram_obj_pos_X_lo
    RTS



; Handle midpoint transform to ripped-suit tiles and advance
ofs_014_E891_scene01_handle_rip_transform:		; was: ofs_014_E891_02
    LDA ram_spr_pos_X_hi
    CMP #$80
    BNE bra_E8BB_scene01_check_second_trigger
    LDA #> $FFC0
    STA ram_obj_pos_X_hi
    LDA #< $FFC0
    STA ram_obj_pos_X_lo
    LDA #$42
    STA ram_028E
    LDA #$00
    STA ram_0294
    LDA #$80
    STA ram_spr_pos_X_hi + $08
    LDA #$7C
    STA ram_spr_pos_Y_hi + $08
    LDA #$00
    STA ram_obj_pos_X_hi + $08
    STA ram_obj_pos_X_lo + $08
    RTS
; Check second trigger to hand off into blink phase
bra_E8BB_scene01_check_second_trigger:		; was: bra_E8BB
    CMP #$78
    BEQ bra_E8C0_scene01_advance_to_blink_phase
    RTS
; Advance scene01 to blinking ripped-suit phase
bra_E8C0_scene01_advance_to_blink_phase:		; was: bra_E8C0
    LDA #$00
    STA ram_obj_pos_X_hi
    STA ram_obj_pos_X_lo
    INC ram_0088
    INC ram_0088
    RTS



; Blink ripped-suit tiles, then end scene01
ofs_014_E8CB_scene01_blink_rip_tiles_then_finish:		; was: ofs_014_E8CB_04
    LDA ram_028C
    AND #$40
    BNE bra_E8E1_scene01_wait_blink_timer
    LDA #$46
    STA ram_028C
    LDA #$45
    STA ram_028E
    LDA #$40
    STA ram_0089
    RTS
; Wait blink timer before toggling tile
bra_E8E1_scene01_wait_blink_timer:		; was: bra_E8E1
    DEC ram_0089
    BEQ bra_E8E6_scene01_toggle_or_finish
    RTS
; Toggle ripped-suit tile state or finish scene
bra_E8E6_scene01_toggle_or_finish:		; was: bra_E8E6
    LDA ram_028C
    CMP #$47
    BNE bra_E8F0_scene01_set_blink_tile_alt
    JMP loc_E9A0_set_script00_return
; Set alternate ripped-suit tile
bra_E8F0_scene01_set_blink_tile_alt:		; was: bra_E8F0
    LDA #$47
    STA ram_028C
    LDA #$40
    STA ram_0089
    RTS



; Intermission scene 02 (third cutscene) state machine
ofs_012_E8FA_scene02_chase_return_opening:		; was: ofs_012_E8FA_04
    LDY ram_0088
    LDA tbl_E909_scene02_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_E909_scene02_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for intermission scene 02
; 00: wait trigger + spawn lead actor
; 02: wait wrap + spawn return runner
; 04: wait midpoint + spawn chaser
; 06: wait chaser wrap then finish
tbl_E909_scene02_state_handlers:		; was: tbl_E909
    .word ofs_015_E911_scene02_wait_enemy4_left_entry
    .word ofs_015_E93A_scene02_wait_pacman_wrap_left
    .word ofs_015_E965_scene02_wait_return_midpoint
    .word ofs_015_E996_scene02_wait_chaser_wrap



; Wait enemy 4 trigger and init chase actor for scene02
ofs_015_E911_scene02_wait_enemy4_left_entry:		; was: ofs_015_E911_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$D8
    BCC bra_E919_scene02_start_chase_actor
    RTS
; Advance scene02 and seed chase actor movement
bra_E919_scene02_start_chase_actor:		; was: bra_E919
    INC ram_0088
    INC ram_0088
    LDA #$4C
    STA ram_028C
    LDA #$20
    STA ram_0292
    LDA #$F7
    STA ram_spr_pos_X_hi
    LDA #$7C
    STA ram_spr_pos_Y_hi
    LDA #> $FF00
    STA ram_obj_pos_X_hi
    LDA #< $FF00
    STA ram_obj_pos_X_lo
    RTS



; Wait lead actor wrap and spawn return runner
ofs_015_E93A_scene02_wait_pacman_wrap_left:		; was: ofs_015_E93A_02
    LDA ram_spr_pos_X_hi
    BEQ bra_E940_scene02_spawn_pacman_return_runner
    RTS
; Spawn Pac-Man return runner and set motion
bra_E940_scene02_spawn_pacman_return_runner:		; was: bra_E940
    INC ram_0088
    INC ram_0088
    LDA #$28
    STA ram_004C
    LDA #$4A
    STA ram_028C
    LDA #$23
    STA ram_0292
    LDA #$09
    STA ram_spr_pos_X_hi
    LDA #$7C
    STA ram_spr_pos_Y_hi
    LDA #> $0100
    STA ram_obj_pos_X_hi
    LDA #< $0100
    STA ram_obj_pos_X_lo
    RTS



; Mark actors visible and wait midpoint before spawn
ofs_015_E965_scene02_wait_return_midpoint:		; was: ofs_015_E965_04
    LDA #$01
    STA ram_060D
    STA ram_060E
    LDA ram_spr_pos_X_hi
    CMP #$19
    BCS bra_E975_scene02_spawn_chaser_actor
    RTS
; Spawn trailing chaser actor for scene02
bra_E975_scene02_spawn_chaser_actor:		; was: bra_E975
    INC ram_0088
    INC ram_0088
    LDA #$4C
    STA ram_028D
    LDA #$21
    STA ram_0293
    LDA #$11
    STA ram_spr_pos_X_hi + $04
    LDA #$84
    STA ram_spr_pos_Y_hi + $04
    LDA #> $0100
    STA ram_obj_pos_X_hi + $04
    LDA #< $0100
    STA ram_obj_pos_X_lo + $04
    RTS



; Wait chaser wrap and finish scene02
ofs_015_E996_scene02_wait_chaser_wrap:		; was: ofs_015_E996_06
    LDA ram_spr_pos_X_hi + $04
    BEQ bra_E99C_scene02_finish_to_script00
    RTS
; Finish scene02 and return to script00
bra_E99C_scene02_finish_to_script00:		; was: bra_E99C
    LDA #$40
    STA ram_004C
; Common return: set script00 and exit
loc_E9A0_set_script00_return:		; was: loc_E9A0
    LDA #con_script_00
    STA ram_script
    RTS



; Update intermission actor positions, wrap flags, and hide offscreen actors
sub_E9A5_update_intermission_actor_positions:		; was: sub_E9A5
    LDA #< ram_obj_position
    STA ram_0000
    LDA #> ram_obj_position
    STA ram_0001
    LDA #< ram_spr_position
    STA ram_0002
    LDA #> ram_spr_position
    STA ram_0003
    LDX #$00
; Iterate to next actor slot
bra_E9B7_loop_update_next_actor:		; was: bra_E9B7_loop
    LDY #$00
    LDA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    BEQ bra_EA00_advance_actor_pointer
    INY
    LDA (ram_0000),Y    ; 001B 001F 0023 0027 002B
    CLC
    ADC (ram_0002),Y    ; 0275 0279 027D 0281 0285
    STA (ram_0002),Y    ; 0275 0279 027D 0281 0285
    DEY
    LDA (ram_0000),Y    ; 001A 001E 0022 0026 002A
    ADC (ram_0002),Y    ; 0274 0278 027C 0280 0284
    STA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    CMP #$C0
    BCC bra_E9DA_actor_in_visible_range
; Mark actor attribute when crossing horizontal boundary
bra_E9D0_loop_mark_actor_horizontal_wrap:		; was: bra_E9D0_loop
    LDA #$20
    ORA ram_0292,X
    STA ram_0292,X
    BNE bra_E9E6_continue_actor_bounds_check    ; jmp
; Actor within visible horizontal range
bra_E9DA_actor_in_visible_range:		; was: bra_E9DA
    CMP #$40
    BCC bra_E9D0_loop_mark_actor_horizontal_wrap
    LDA #$DF
    AND ram_0292,X
    STA ram_0292,X
; Continue with vertical/offscreen bounds checks
bra_E9E6_continue_actor_bounds_check:		; was: bra_E9E6
    LDY #$00
    LDA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    CMP #$FC
    BCC bra_E9FC_actor_not_outside_vertical_bounds
; Reset offscreen actor position and velocity
bra_E9EE_loop_reset_offscreen_actor:		; was: bra_E9EE_loop
    LDA #$00
    STA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    STA (ram_0000),Y    ; 001A 001E 0022 0026 002A
    INY
    STA (ram_0000),Y    ; 001B 001F 0023 0027 002B
    INY
    STA (ram_0002),Y    ; 0276 027A 027E 0282 0286
    BNE bra_EA00_advance_actor_pointer
; Actor remains within vertical bounds
bra_E9FC_actor_not_outside_vertical_bounds:		; was: bra_E9FC
    CMP #$04
    BCC bra_E9EE_loop_reset_offscreen_actor
; Advance object/sprite pointers to next actor
bra_EA00_advance_actor_pointer:		; was: bra_EA00
    LDA ram_0000
    CLC
    ADC #< $0004
    STA ram_0000
    LDA ram_0001
    ADC #> $0004
    STA ram_0001
    LDA ram_0002
    CLC
    ADC #< $0004
    STA ram_0002
    LDA ram_0003
    ADC #> $0004
    STA ram_0003
    INX
    CPX #$05
    BNE bra_E9B7_loop_update_next_actor
    RTS



; Dispatch intermission tile animation script by scene id
; Animation dispatch is scene-aligned with tbl_E769_intermission_scene_handlers
; and usually keyed by the same ram_0088 substate.
sub_EA20_run_intermission_animation_dispatch:		; was: sub_EA20
    LDY ram_0087
    LDA tbl_EA2F_intermission_anim_scene_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_EA2F_intermission_anim_scene_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Animation scene handler table for intermission script10
tbl_EA2F_intermission_anim_scene_handlers:		; was: tbl_EA2F
    .word ofs_016_EA35_anim_scene00_dispatch
    .word ofs_016_EAC9_anim_scene01_dispatch
    .word ofs_016_EAF9_anim_scene02_dispatch



; Animation state machine for intermission scene00
ofs_016_EA35_anim_scene00_dispatch:		; was: ofs_016_EA35_00
    LDY ram_0088
    LDA tbl_EA44_anim_scene00_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_EA44_anim_scene00_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for animation scene00
tbl_EA44_anim_scene00_state_handlers:		; was: tbl_EA44
    .word ofs_017_EA4C_anim_scene_base_cycle
    .word ofs_017_EA62_anim_scene00_head_toggle_alias
    .word ofs_017_EA79_anim_scene00_tail_toggle
    .word ofs_017_EA90_anim_scene00_banner_cycle



; Shared animation tick: cycle frame index and tile
bra_EA4C_anim_tick_palette_cycle:		; was: bra_EA4C
; Shared animation tick entry
loc_EA4C_anim_tick_palette_cycle_entry:		; was: loc_EA4C
; Base tile cycle state
ofs_017_EA4C_anim_scene_base_cycle:		; was: ofs_017_EA4C_00
; Alternate state reusing base tile cycle
ofs_017_EA4C_anim_scene_base_cycle_alt:		; was: ofs_017_EA4C_04
    INC ram_00B7
    LDA ram_00B7
    AND #$07
    TAY
    LDA tbl_EA5A_anim_cycle_tiles,Y
    STA ram_028D
    RTS



; Tile cycle pattern for shared animation tick
tbl_EA5A_anim_cycle_tiles:		; was: tbl_EA5A
    .byte $04   ; 00
    .byte $04   ; 01
    .byte $04   ; 02
    .byte $05   ; 03
    .byte $05   ; 04
    .byte $04   ; 05
    .byte $01   ; 06
    .byte $01   ; 07



; Scene00 animation: toggle head tile each 8 frames
sub_EA62_anim_scene00_toggle_head_tile:		; was: sub_EA62
; Alias entry for scene00 head tile animation routine
ofs_017_EA62_anim_scene00_head_toggle_alias:		; was: ofs_017_EA62_02
    LDA ram_frame_cnt
    AND #$07
    BNE bra_EA4C_anim_tick_palette_cycle
    LDA ram_frame_cnt
    AND #$08
    BNE bra_EA72_anim_scene00_select_tile_b
    LDA #$0C
    BNE bra_EA74_anim_scene00_store_tile    ; jmp
; Select scene00 alternate tile
bra_EA72_anim_scene00_select_tile_b:		; was: bra_EA72
    LDA #$0D
; Store scene00 animated tile
bra_EA74_anim_scene00_store_tile:		; was: bra_EA74
    STA ram_028C
    BNE bra_EA4C_anim_tick_palette_cycle    ; jmp



; Scene00 tail tile toggle state
bra_EA79_anim_scene00_tail_tile_toggle:		; was: bra_EA79
; Toggle tail tile in scene00
ofs_017_EA79_anim_scene00_tail_toggle:		; was: ofs_017_EA79_04
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_EA80_anim_scene00_every8frames
    RTS
; Run scene00 tail toggle every 8 frames
bra_EA80_anim_scene00_every8frames:		; was: bra_EA80
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_EA8A_anim_scene00_select_tail_tile_b
    LDA #$1E
    BNE bra_EA8C_anim_scene00_store_tail_tile    ; jmp
; Select alternate tail tile
bra_EA8A_anim_scene00_select_tail_tile_b:		; was: bra_EA8A
    LDA #$1F
; Store scene00 tail tile
bra_EA8C_anim_scene00_store_tail_tile:		; was: bra_EA8C
    STA ram_028C
    RTS



; Cycle 4-tile banner animation for scene00
ofs_017_EA90_anim_scene00_banner_cycle:		; was: ofs_017_EA90_06
    INC ram_00B7
    LDA ram_00B7
    AND #$07
    TAY
    LDA tbl_EAB5_anim_cycle_to_pattern_index,Y
    TAY
    LDA tbl_EABD_anim_banner_tile_quads,Y
    STA ram_028D
    LDA tbl_EABD_anim_banner_tile_quads + $01,Y
    STA ram_028E
    LDA tbl_EABD_anim_banner_tile_quads + $02,Y
    STA ram_028F
    LDA tbl_EABD_anim_banner_tile_quads + $03,Y
    STA ram_0290
    BNE bra_EA79_anim_scene00_tail_tile_toggle    ; jmp



; Map cycle step to banner pattern index
tbl_EAB5_anim_cycle_to_pattern_index:		; was: tbl_EAB5_index
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $04   ; 03
    .byte $04   ; 04
    .byte $00   ; 05
    .byte $08   ; 06
    .byte $08   ; 07



; Banner tile quads for scene00 animation
tbl_EABD_anim_banner_tile_quads:		; was: tbl_EABD
; 00
    .byte $3C
    .byte $3D
    .byte $3E
    .byte $3F
; 04
    .byte $3C
    .byte $40
    .byte $3E
    .byte $41
; 08
    .byte $38
    .byte $39
    .byte $3A
    .byte $3B
; Animation state machine for intermission scene01
ofs_016_EAC9_anim_scene01_dispatch:		; was: ofs_016_EAC9_02
    LDY ram_0088
    LDA tbl_EAD8_anim_scene01_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_EAD8_anim_scene01_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for animation scene01
; 00: base cycle, 02: ripped-tile toggle, 04: base cycle alt
tbl_EAD8_anim_scene01_state_handlers:		; was: tbl_EAD8
    .word ofs_017_EA4C_anim_scene_base_cycle
    .word ofs_017_EADE_anim_scene01_rip_tile_toggle
    .word ofs_017_EA4C_anim_scene_base_cycle_alt



; Scene01 animation: toggle ripped-suit center tile by position
ofs_017_EADE_anim_scene01_rip_tile_toggle:		; was: ofs_017_EADE_02
    JSR sub_EA62_anim_scene00_toggle_head_tile
    LDA ram_spr_pos_X_hi
    CMP #$7D
    BNE bra_EAEE_anim_scene01_check_second_tile_trigger
    LDA #$43
    STA ram_028E
    RTS
; Check second X trigger for ripped tile
bra_EAEE_anim_scene01_check_second_tile_trigger:		; was: bra_EAEE
    CMP #$7B
    BEQ bra_EAF3_anim_scene01_store_second_rip_tile
    RTS
; Store second ripped-suit tile
bra_EAF3_anim_scene01_store_second_rip_tile:		; was: bra_EAF3
    LDA #$44
    STA ram_028E
    RTS



; Animation state machine for intermission scene02
ofs_016_EAF9_anim_scene02_dispatch:		; was: ofs_016_EAF9_04
    LDY ram_0088
    LDA tbl_EB08_anim_scene02_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_EB08_anim_scene02_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; State handlers for animation scene02
; 00: base cycle, 02: main-tile toggle, 04/06: aux-tile toggles
tbl_EB08_anim_scene02_state_handlers:		; was: tbl_EB08
    .word ofs_017_EA4C_anim_scene_base_cycle
    .word ofs_017_EB10_anim_scene02_toggle_main_tile
    .word ofs_017_EB2B_anim_scene02_toggle_aux_tile
    .word ofs_017_EB2B_anim_scene02_toggle_aux_tile_alt



; Scene02 animation: toggle main actor tile every 8 frames
ofs_017_EB10_anim_scene02_toggle_main_tile:		; was: ofs_017_EB10_02
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_EB19_anim_scene02_every8frames
    JMP loc_EA4C_anim_tick_palette_cycle_entry
; Run scene02 main tile toggle every 8 frames
bra_EB19_anim_scene02_every8frames:		; was: bra_EB19
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_EB23_anim_scene02_select_main_tile_b
    LDA #$48
    BNE bra_EB25_anim_scene02_store_main_tile    ; jmp
; Select alternate main tile
bra_EB23_anim_scene02_select_main_tile_b:		; was: bra_EB23
    LDA #$49
; Store scene02 main tile
bra_EB25_anim_scene02_store_main_tile:		; was: bra_EB25
    STA ram_028C
    JMP loc_EA4C_anim_tick_palette_cycle_entry



; Scene02 animation: toggle auxiliary tile every 8 frames
ofs_017_EB2B_anim_scene02_toggle_aux_tile:		; was: ofs_017_EB2B_04
; Alt state sharing auxiliary tile toggle
ofs_017_EB2B_anim_scene02_toggle_aux_tile_alt:		; was: ofs_017_EB2B_06
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_EB32_anim_scene02_aux_every8frames
    RTS
; Run scene02 auxiliary tile toggle every 8 frames
bra_EB32_anim_scene02_aux_every8frames:		; was: bra_EB32
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_EB3C_anim_scene02_select_aux_tile_b
    LDA #$4A
    BNE bra_EB3E_anim_scene02_store_aux_tile    ; jmp
; Select alternate auxiliary tile
bra_EB3C_anim_scene02_select_aux_tile_b:		; was: bra_EB3C
    LDA #$4B
; Store scene02 auxiliary tile
bra_EB3E_anim_scene02_store_aux_tile:		; was: bra_EB3E
    STA ram_028C
    RTS
