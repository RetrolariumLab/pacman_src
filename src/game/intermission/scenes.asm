; Intermission scene dispatch and the three chase sequences

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
