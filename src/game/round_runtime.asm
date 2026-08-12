; Round timers, release logic, fruit, and collisions




; ---------------------------------------------------------------------------
; LEVEL RUNTIME SYSTEMS
; Timers + release logic + collisions + movement.
; These routines drive enemy behavior, power-up windows, fruit visibility, and scoring.
; ---------------------------------------------------------------------------
; Runtime field legend used heavily below:
; ram_0088: frightened bitmask by ghost slot
; ram_0089/ram_008A: frightened timer hi/lo
; ram_00CF: active scatter/chase timer countdown
; ram_00D0/ram_00D1: phase index + per-second divider
; ram_00D2: per-wave release timer value
; ram_00D3: global dot-release target cursor
; ram_00D4: personal-release stage index
; ram_00D5/ram_00D6: release counters (seconds/subseconds)
; ram_fruit_timer_hi/ram_fruit_timer_lo: fruit visibility timer
; Update frightened timers, ghost release progression, and fruit timer
sub_D0EF_update_round_timers_and_frightened:		; was: sub_D0EF
    LDA ram_0089
    BMI bra_D141_release_and_fruit_tick
    INC ram_008A
    LDA #$3C
    CMP ram_008A
    BNE bra_D117_check_frightened_end_window
    LDA #$00
    STA ram_008A
    DEC ram_0089
    BPL bra_D117_check_frightened_end_window
    STA ram_0088
    LDX #$00
; Apply palette phase bits to ghost sprite attributes
bra_D107_apply_frightened_palette_phase:		; was: bra_D107_loop
    LDA ram_spr_pal + $01,X
    AND #$FC
    STA ram_0000
    TXA
    ORA ram_0000
    STA ram_spr_pal + $01,X
    INX
    CPX #$04
    BNE bra_D107_apply_frightened_palette_phase
; Handle final frightened blinking window
bra_D117_check_frightened_end_window:		; was: bra_D117
    LDA ram_0089
    CMP #$02
    BCS bra_D141_release_and_fruit_tick
    LDX #$00
    LDA ram_008A
    AND #$08
    BNE bra_D127_prepare_ppu_append_index
    LDX #$05
; Prepare insertion point in PPU command buffer
bra_D127_prepare_ppu_append_index:		; was: bra_D127
    LDY #$FF
; Scan PPU command buffer until end token
bra_D129_find_ppu_terminator:		; was: bra_D129_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BNE bra_D129_find_ppu_terminator
    TYA
    BNE bra_D135_append_frightened_cmd_if_empty
    INX
; Adjust source offset when appending frightened palette command
bra_D135_append_frightened_cmd_if_empty:		; was: bra_D135
; Copy frightened palette command sequence into PPU buffer
bra_D135_copy_frightened_palette_cmd:		; was: bra_D135_loop
    LDA tbl_D205_frightened_palette_cmd,X
    STA ram_ppu_buffer_main,Y
    INY
    INX
    CMP #$FF
    BNE bra_D135_copy_frightened_palette_cmd
; Continue with release/fruit timers after frightened handling
bra_D141_release_and_fruit_tick:		; was: bra_D141
    LDA ram_0088
    BNE bra_D174_check_global_release_target
    LDA ram_00CF
    CMP #$FF
    BEQ bra_D174_check_global_release_target
    INC ram_00D1
    LDA ram_00D1
    CMP #$3C
    BNE bra_D174_check_global_release_target
    LDA #$00
    STA ram_00D1
    DEC ram_00CF
    BPL bra_D174_check_global_release_target
    INC ram_00D0
    LDA ram_00D0
    AND #$01
    BEQ bra_D16A_use_personal_release_timer
    JSR sub_E003_try_reverse_ghost_directions
    LDA #$0F
    BNE bra_D16C_store_next_release_timer    ; jmp
; Use per-target release timer value when phase bit is even
bra_D16A_use_personal_release_timer:		; was: bra_D16A
    LDA ram_00D2
; Store selected release timer value into active countdown
bra_D16C_store_next_release_timer:		; was: bra_D16C
    STA ram_0087
    LDX ram_00D0
; 0098-009A
    LDA ram_0097,X
    STA ram_00CF
; Check global dot target for forced ghost release
bra_D174_check_global_release_target:		; was: bra_D174
    LDA ram_00D3
    BEQ bra_D197_release_counter_update_entry
    CLC
    ADC ram_pellet_cnt_p1
    CMP #$C0
    BNE bra_D197_release_counter_update_entry
    JSR sub_D1EB_queue_next_ghost_release
    LDA ram_00D3
    LDX #$00
; Find current release target slot and advance to next
bra_D186_find_matching_release_target:		; was: bra_D186_loop
    CMP ram_008F,X
    BNE bra_D192_next_release_target_candidate
    INX
    LDA ram_008F,X
    STA ram_00D3
    JMP loc_D197_update_release_counters
; Advance to next release target candidate
bra_D192_next_release_target_candidate:		; was: bra_D192
    INX
    CPX #$04
    BNE bra_D186_find_matching_release_target
; Branch entry into shared release-counter update routine
bra_D197_release_counter_update_entry:		; was: bra_D197
; Update per-frame and per-wave release counters
loc_D197_update_release_counters:		; was: loc_D197
    INC ram_00D6
    LDA #$60
    CMP ram_00D6
    BNE bra_D1B2_check_personal_release_targets
    LDA #$00
    STA ram_00D6
    INC ram_00D5
    LDA ram_00D5
    CMP ram_0096
    BNE bra_D1B2_check_personal_release_targets
    LDA #$00
    STA ram_00D5
    JSR sub_D1EB_queue_next_ghost_release
; Check per-ghost dot counters for personal release
bra_D1B2_check_personal_release_targets:		; was: bra_D1B2
    LDX ram_00D4
    CPX #$02
    BEQ bra_D1CF_update_fruit_visibility_timer
    LDA ram_008D,X
    CMP ram_pellet_cnt_p1
    BNE bra_D1CF_update_fruit_visibility_timer
    INC ram_00D4
    LDA #$01
    STA ram_00D2
    TXA
    ASL
    TAX
    LDA ram_00AB,X
    STA ram_00CA
    LDA ram_00AC,X
    STA ram_00CB
; Tick fruit visibility timer and clear fruit when expired
bra_D1CF_update_fruit_visibility_timer:		; was: bra_D1CF
    ORA ram_fruit_timer_hi
    ORA ram_fruit_timer_lo
    BEQ bra_D1EA_return
    DEC ram_fruit_timer_lo
    BNE bra_D1EA_return
    LDA ram_fruit_timer_hi
    BEQ bra_D1E4_hide_fruit_sprite
    DEC ram_fruit_timer_hi
    LDA #$3C
    STA ram_fruit_timer_lo
    RTS
; Hide fruit sprite and clear fruit active flag
bra_D1E4_hide_fruit_sprite:		; was: bra_D1E4
    STA ram_obj_pos_X_hi + $14
    STA ram_obj_pos_Y_hi + $14
    STA ram_008B
; Return from round timer update
bra_D1EA_return:		; was: bra_D1EA_RTS
    RTS



; Reserve next available ghost release slot
sub_D1EB_queue_next_ghost_release:		; was: sub_D1EB
    LDX #$00
; Scan release slot pairs for an empty entry
bra_D1ED_find_free_release_slot:		; was: bra_D1ED_loop
    LDA ram_00BA,X
    BNE bra_D1F6_advance_release_slot
    LDA #$02
    STA ram_00BA,X
    RTS
; Advance to next release slot pair
bra_D1F6_advance_release_slot:		; was: bra_D1F6
    INX
    INX
    CPX #$06
    BNE bra_D1ED_find_free_release_slot
    RTS


; bzk garbage, same bytes as 0x001FCE
    .byte $24, $25, $26, $27, $28, $29, $2A, $2B
; PPU command fragments for frightened palette writes
tbl_D205_frightened_palette_cmd:		; was: tbl_D205
; 00
    .byte $00
    .dbyt $3F15
    .byte $11
    .byte $FF   ; end token
; 05
    .byte $00
    .dbyt $3F15
    .byte $20
    .byte $FF   ; end token



; Check Pac-Man collisions against ghosts/fruit and dispatch death/eat/score paths
sub_D20F_check_actor_collisions:		; was: sub_D20F
    LDA ram_pellet_cnt_p1
    BNE bra_D214_init_collision_scan
    RTS
; Initialize collision scan pointers and masks
bra_D214_init_collision_scan:		; was: bra_D214
    LDA #< (ram_obj_pos_X_hi + $04)
    STA ram_0000
    LDA #> (ram_obj_pos_X_hi + $04)
    STA ram_0001
    LDA #$01
    STA ram_0002
    LDX #$00
; Iterate ghost/fruit collision candidate slots
bra_D222_scan_collision_candidates:		; was: bra_D222_loop
    LDA ram_00B8,X
    CMP #$04
    BNE bra_D25A_advance_collision_candidate
    LDY #$00
    LDA ram_obj_pos_X_hi
    CMP (ram_0000),Y    ; 001E 0022 0026 002A 002E
    BCS bra_D237_abs_dx_subtract_alt
    LDA (ram_0000),Y    ; 001E 0022 0026 002A 002E
    SEC
    SBC ram_obj_pos_X_hi
    BCS bra_D239_check_dx_window
; Compute alternate X distance branch
bra_D237_abs_dx_subtract_alt:		; was: bra_D237
    SBC (ram_0000),Y    ; 001E 0022 0026 002A 002E
; Reject candidate when X distance is too large
bra_D239_check_dx_window:		; was: bra_D239
    CMP #$0A
    BCS bra_D25A_advance_collision_candidate
    STA ram_0003
    LDY #$02
    LDA ram_obj_pos_Y_hi
    CMP (ram_0000),Y    ; 0020 0024 0028 002C 0030
    BCS bra_D24E_abs_dy_subtract_alt
    LDA (ram_0000),Y    ; 0020 0024 0028 002C 0030
    SEC
    SBC ram_obj_pos_Y_hi
    BCS bra_D250_check_dy_window
; Compute alternate Y distance branch
bra_D24E_abs_dy_subtract_alt:		; was: bra_D24E
    SBC (ram_0000),Y    ; 0020 0024 0028 002C 0030
; Reject candidate when Y distance is too large
bra_D250_check_dy_window:		; was: bra_D250
    CMP #$0A
    BCS bra_D25A_advance_collision_candidate
    ADC ram_0003
    CMP #$05
    BCC bra_D26A_dispatch_collision_type
; Advance to next collision candidate
bra_D25A_advance_collision_candidate:		; was: bra_D25A
    INX
    INX
    LDA ram_0000
    CLC
    ADC #$04
    STA ram_0000
    ASL ram_0002
    CPX #$0A
    BNE bra_D222_scan_collision_candidates
    RTS
; Dispatch ghost-eat, player-death, or fruit-eat paths
bra_D26A_dispatch_collision_type:		; was: bra_D26A
    CPX #$08
    BEQ bra_D2B3_handle_fruit_collision
    LDA ram_0002
    AND ram_0088
    BEQ bra_D2A2_trigger_player_death
    TXA
    LSR
    STA ram_0003
    LDY ram_kill_cnt
    LDA tbl_D2D7_ghost_score_popup_tiles,Y
    LDY ram_0003
    STA ram_animation + $01,Y
    LDA #$00
    STA ram_animation
    LDY ram_kill_cnt
    LDA tbl_D2E7_ghost_score_popup_lo,Y
    STA ram_00DD
    LDA tbl_D2E3_ghost_score_popup_hi,Y
    STA ram_00DE
    INC ram_kill_cnt
    LDA #$08
    STA ram_00B8,X
    STA ram_sfx_eat_ghost
    LDA #con_script_freeze
    STA ram_script
    JMP loc_E060_add_points_and_update_score_buffers
; Collision with dangerous ghost: enter death script
bra_D2A2_trigger_player_death:		; was: bra_D2A2
    LDA #con_script_08
    STA ram_script
    LDA #$12
    STA ram_animation
    LDA #$80
    STA ram_00DB
    LDA #$00
    STA ram_0087
    RTS
; Fruit candidate reached: check spawn state
bra_D2B3_handle_fruit_collision:		; was: bra_D2B3
    LDA ram_008B
    BEQ bra_D2B8_spawn_fruit_and_score
    RTS
; Spawn fruit score popup and start fruit timer
bra_D2B8_spawn_fruit_and_score:		; was: bra_D2B8
    STA ram_fruit_timer_hi
    LDA #$80
    STA ram_fruit_timer_lo
    STA ram_008B
    STA ram_sfx_eat_fruit
    LDY ram_0093
    LDA tbl_D2EB_fruit_score_hi,Y
    STA ram_00DD
    LDA tbl_D2F3_fruit_score_lo,Y
    STA ram_00DE
    LDA tbl_D2DB_fruit_score_popup_tiles,Y
    STA ram_animation + $05
    JMP loc_E060_add_points_and_update_score_buffers



; Tile IDs for ghost-eaten score popups
tbl_D2D7_ghost_score_popup_tiles:		; was: tbl_D2D7
    .byte $2D   ; 00
    .byte $2F   ; 01
    .byte $32   ; 02
    .byte $34   ; 03



; Tile IDs for fruit score popups by stage
tbl_D2DB_fruit_score_popup_tiles:		; was: tbl_D2DB
    .byte $2C   ; 00
    .byte $2E   ; 01
    .byte $30   ; 02
    .byte $31   ; 03
    .byte $33   ; 04
    .byte $35   ; 05
    .byte $36   ; 06
    .byte $37   ; 07



; High-byte score values for ghost-eat chain
tbl_D2E3_ghost_score_popup_hi:		; was: tbl_D2E3
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $01   ; 03



; Low-byte score values for ghost-eat chain
tbl_D2E7_ghost_score_popup_lo:		; was: tbl_D2E7
    .byte $02   ; 00
    .byte $04   ; 01
    .byte $08   ; 02
    .byte $06   ; 03



; High-byte fruit score values by stage
tbl_D2EB_fruit_score_hi:		; was: tbl_D2EB
    .byte $01   ; 00
    .byte $03   ; 01
    .byte $05   ; 02
    .byte $07   ; 03
    .byte $00   ; 04
    .byte $00   ; 05
    .byte $00   ; 06
    .byte $00   ; 07



; Low-byte fruit score values by stage
tbl_D2F3_fruit_score_lo:		; was: tbl_D2F3
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $00   ; 03
    .byte $01   ; 04
    .byte $02   ; 05
    .byte $03   ; 06
    .byte $05   ; 07
