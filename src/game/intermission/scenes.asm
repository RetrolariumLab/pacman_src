; Intermission scene dispatch and the three chase sequences

; Script10 per-frame cutscene coordinator.
; Inputs: selected scene/substate plus cutscene actor state.
; Outputs: integrated actors, animation/OAM, and scene-transition effects.
; Side effects: scene completion may select script00 after OAM is built.
; Clobbers: A, X, Y, shared work bytes, and ram_indirect_jmp.
handler_script10_intermission_runtime:		; was: ofs_003_E74B_10
    JSR sub_update_intermission_actor_positions
    JSR sub_run_intermission_animation_dispatch
    JSR sub_build_oam_from_sprite_buffers
    JSR sub_run_intermission_scene_dispatch
    JMP loc_gameplay_mainloop_wait_nmi
; Dispatch selected intermission scene handler by even scene-table offset.
; Inputs: ram_shared_state_0 and scene-local actor/substate data.
; Outputs/side effects: handler-dependent; scene handlers alone advance substates.
; Clobbers: A, Y and ram_indirect_jmp.
sub_run_intermission_scene_dispatch:		; was: sub_E75A
    LDY ram_shared_state_0
    LDA tbl_intermission_scene_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_intermission_scene_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Intermission scene handler table (byte offsets 00/02/04)
; Scene id mapping:
; 00 -> first chase scene
; 02 -> ripped-suit gag scene
; 04 -> return/chaser finale
tbl_intermission_scene_handlers:		; was: tbl_E769
    .word handler_scene00_chase_opening        ; con_intermission_scene_chase
    .word handler_scene01_chase_rip_opening    ; con_intermission_scene_ripped_suit
    .word handler_scene02_chase_return_opening ; con_intermission_scene_return

; Intermission scene 00 (first cutscene) state machine
; Uses ram_shared_state_1 as substate selector into tbl_scene00_state_handlers.
handler_scene00_chase_opening:		; was: ofs_012_E76F_00
    LDY ram_shared_state_1
    LDA tbl_scene00_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_scene00_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for intermission scene 00
tbl_scene00_state_handlers:		; was: tbl_E77E
    .word handler_scene00_wait_enemy4_left_entry ; con_intermission_chase_wait_enemy
    .word handler_scene00_wait_pacman_wrap_left  ; con_intermission_chase_wait_wrap
    .word handler_scene00_wait_pacman_midpoint   ; con_intermission_chase_wait_midpoint
    .word handler_scene00_wait_ghost_pack_wrap   ; con_intermission_chase_wait_pack_wrap

; Wait until enemy 4 reaches trigger X, then initialize chase actor
handler_scene00_wait_enemy4_left_entry:		; was: ofs_013_E786_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$D0
    BCC bra_scene00_start_chase_actor
    RTS
; Advance to scene00 chase phase and seed actor movement
bra_scene00_start_chase_actor:		; was: bra_E78E
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$0C
    STA ram_actor_sprite_set
    LDA #$20
    STA ram_actor_sprite_attrs
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
handler_scene00_wait_pacman_wrap_left:		; was: ofs_013_E7AF_02
    LDA ram_spr_pos_X_hi
    BEQ bra_scene00_spawn_pacman_runner
    RTS
; Spawn Pac-Man runner and set motion
bra_scene00_spawn_pacman_runner:		; was: bra_E7B5
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$40
    STA ram_script_delay
    LDA #$1E
    STA ram_actor_sprite_set
    LDA #$22
    STA ram_actor_sprite_attrs
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
handler_scene00_wait_pacman_midpoint:		; was: ofs_013_E7DA_04
    LDA #$01
    STA ram_sfx_intermission_flag_a
    STA ram_sfx_intermission_flag_b
    LDA ram_spr_pos_X_hi
    CMP #$80
    BCS bra_scene00_spawn_ghost_pack
    RTS
; Spawn ghost pack and initialize formation tiles
bra_scene00_spawn_ghost_pack:		; was: bra_E7EA
    INC ram_shared_state_1
    INC ram_shared_state_1
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
    STA ram_actor_sprite_set + $01
    ADC #$01
    STA ram_actor_sprite_set + $02
    ADC #$01
    STA ram_actor_sprite_set + $03
    ADC #$01
    STA ram_actor_sprite_set + $04
    LDA #$21
    STA ram_actor_sprite_attrs + $01
    STA ram_actor_sprite_attrs + $02
    STA ram_actor_sprite_attrs + $03
    STA ram_actor_sprite_attrs + $04
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
handler_scene00_wait_ghost_pack_wrap:		; was: ofs_013_E846_06
    LDA ram_spr_pos_X_hi + $04
    BEQ bra_scene00_finish_to_script00
    RTS
; Finish scene00 and return to script00
bra_scene00_finish_to_script00:		; was: bra_E84C
    LDA #$40
    STA ram_script_delay
    JMP loc_set_script00_return

; Intermission scene 01 (second cutscene) state machine
handler_scene01_chase_rip_opening:		; was: ofs_012_E853_02
    LDY ram_shared_state_1
    LDA tbl_scene01_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_scene01_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for intermission scene 01
; 00: wait trigger + spawn lead actor
; 02: transform to ripped-suit phase
; 04: blink ripped tiles then finish
tbl_scene01_state_handlers:		; was: tbl_E862
    .word handler_scene01_wait_enemy4_left_entry      ; con_intermission_rip_wait_enemy
    .word handler_scene01_handle_rip_transform        ; con_intermission_rip_transform
    .word handler_scene01_blink_rip_tiles_then_finish ; con_intermission_rip_blink

; Wait enemy 4 position then init chase actor for scene01
handler_scene01_wait_enemy4_left_entry:		; was: ofs_014_E868_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$A0
    BCC bra_scene01_start_chase_actor
    RTS
; Advance scene01 and seed chase actor movement
bra_scene01_start_chase_actor:		; was: bra_E870
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$0C
    STA ram_actor_sprite_set
    LDA #$20
    STA ram_actor_sprite_attrs
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
handler_scene01_handle_rip_transform:		; was: ofs_014_E891_02
    LDA ram_spr_pos_X_hi
    CMP #$80
    BNE bra_scene01_check_second_trigger
    LDA #> $FFC0
    STA ram_obj_pos_X_hi
    LDA #< $FFC0
    STA ram_obj_pos_X_lo
    LDA #$42
    STA ram_actor_sprite_set + $02
    LDA #$00
    STA ram_actor_sprite_attrs + $02
    LDA #$80
    STA ram_spr_pos_X_hi + $08
    LDA #$7C
    STA ram_spr_pos_Y_hi + $08
    LDA #$00
    STA ram_obj_pos_X_hi + $08
    STA ram_obj_pos_X_lo + $08
    RTS
; Check second trigger to hand off into blink phase
bra_scene01_check_second_trigger:		; was: bra_E8BB
    CMP #$78
    BEQ bra_scene01_advance_to_blink_phase
    RTS
; Advance scene01 to blinking ripped-suit phase
bra_scene01_advance_to_blink_phase:		; was: bra_E8C0
    LDA #$00
    STA ram_obj_pos_X_hi
    STA ram_obj_pos_X_lo
    INC ram_shared_state_1
    INC ram_shared_state_1
    RTS

; Blink ripped-suit tiles, then end scene01
handler_scene01_blink_rip_tiles_then_finish:		; was: ofs_014_E8CB_04
    LDA ram_actor_sprite_set
    AND #$40
    BNE bra_scene01_wait_blink_timer
    LDA #$46
    STA ram_actor_sprite_set
    LDA #$45
    STA ram_actor_sprite_set + $02
    LDA #$40
    STA ram_shared_state_2
    RTS
; Wait blink timer before toggling tile
bra_scene01_wait_blink_timer:		; was: bra_E8E1
    DEC ram_shared_state_2
    BEQ bra_scene01_toggle_or_finish
    RTS
; Toggle ripped-suit tile state or finish scene
bra_scene01_toggle_or_finish:		; was: bra_E8E6
    LDA ram_actor_sprite_set
    CMP #$47
    BNE bra_scene01_set_blink_tile_alt
    JMP loc_set_script00_return
; Set alternate ripped-suit tile
bra_scene01_set_blink_tile_alt:		; was: bra_E8F0
    LDA #$47
    STA ram_actor_sprite_set
    LDA #$40
    STA ram_shared_state_2
    RTS

; Intermission scene 02 (third cutscene) state machine
handler_scene02_chase_return_opening:		; was: ofs_012_E8FA_04
    LDY ram_shared_state_1
    LDA tbl_scene02_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_scene02_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for intermission scene 02
; 00: wait trigger + spawn lead actor
; 02: wait wrap + spawn return runner
; 04: wait midpoint + spawn chaser
; 06: wait chaser wrap then finish
tbl_scene02_state_handlers:		; was: tbl_E909
    .word handler_scene02_wait_enemy4_left_entry ; con_intermission_return_wait_enemy
    .word handler_scene02_wait_pacman_wrap_left  ; con_intermission_return_wait_wrap
    .word handler_scene02_wait_return_midpoint   ; con_intermission_return_wait_midpoint
    .word handler_scene02_wait_chaser_wrap       ; con_intermission_return_wait_chaser

; Wait enemy 4 trigger and init chase actor for scene02
handler_scene02_wait_enemy4_left_entry:		; was: ofs_015_E911_00
    LDA ram_spr_pos_X_hi + $04
    CMP #$D8
    BCC bra_scene02_start_chase_actor
    RTS
; Advance scene02 and seed chase actor movement
bra_scene02_start_chase_actor:		; was: bra_E919
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$4C
    STA ram_actor_sprite_set
    LDA #$20
    STA ram_actor_sprite_attrs
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
handler_scene02_wait_pacman_wrap_left:		; was: ofs_015_E93A_02
    LDA ram_spr_pos_X_hi
    BEQ bra_scene02_spawn_pacman_return_runner
    RTS
; Spawn Pac-Man return runner and set motion
bra_scene02_spawn_pacman_return_runner:		; was: bra_E940
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$28
    STA ram_script_delay
    LDA #$4A
    STA ram_actor_sprite_set
    LDA #$23
    STA ram_actor_sprite_attrs
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
handler_scene02_wait_return_midpoint:		; was: ofs_015_E965_04
    LDA #$01
    STA ram_sfx_intermission_flag_a
    STA ram_sfx_intermission_flag_b
    LDA ram_spr_pos_X_hi
    CMP #$19
    BCS bra_scene02_spawn_chaser_actor
    RTS
; Spawn trailing chaser actor for scene02
bra_scene02_spawn_chaser_actor:		; was: bra_E975
    INC ram_shared_state_1
    INC ram_shared_state_1
    LDA #$4C
    STA ram_actor_sprite_set + $01
    LDA #$21
    STA ram_actor_sprite_attrs + $01
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
handler_scene02_wait_chaser_wrap:		; was: ofs_015_E996_06
    LDA ram_spr_pos_X_hi + $04
    BEQ bra_scene02_finish_to_script00
    RTS
; Finish scene02 and return to script00
bra_scene02_finish_to_script00:		; was: bra_E99C
    LDA #$40
    STA ram_script_delay
; Common return: set script00 and exit
loc_set_script00_return:		; was: loc_E9A0
    LDA #con_game_script_round_init
    STA ram_script
    RTS

; Update intermission actor positions, wrap flags, and hide offscreen actors
