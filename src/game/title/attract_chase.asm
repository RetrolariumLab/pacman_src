; Attract-mode chase scene, collisions, slot rotation, and animation

handler_attract_chase_scene:  ; was: ofs_001_C6C8_16
    LDY ram_shared_state_1
    LDA tbl_attract_chase_substates,Y
    STA ram_indirect_jmp
    LDA tbl_attract_chase_substates + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Substate handlers for chase attract scene
tbl_attract_chase_substates:  ; was: tbl_C6D7
    .word handler_chase_setup_intro_text
    .word handler_chase_run_from_ghosts
    .word handler_chase_run_toward_ghosts

; Chase substate init: clear score text, seed actor/sprite state
handler_chase_setup_intro_text:  ; was: ofs_002_C6DD_00
; clear 10 pts 50 pts text
    LDY #$00
; Copy fixed PPU command packet into main buffer
bra_copy_ppu_packet:  ; was: bra_C6DF_loop
    LDA tbl_ppu_cmd_clear_points_text,Y
    STA ram_ppu_buffer_main,Y
    INY
    CMP #con_ppu_buffer_end
    BNE bra_copy_ppu_packet
    LDA #< $00FF
    STA ram_obj_pos_X_hi
    LDA #> $00FF
    STA ram_obj_pos_X_lo
    STA ram_shared_state_2
    STA ram_shared_state_3
    LDA #$F4
    STA ram_spr_pos_X_hi
    LDA #$A8
    STA ram_spr_pos_Y_hi
    LDA #$01
    STA ram_actor_sprite_set
    LDA #$20
    STA ram_actor_sprite_attrs
    LDA #$00
    TAY
; Clear attract runner object slots
bra_clear_runner_obj_slots:  ; was: bra_C70D_loop
    STA ram_obj_position + $04,Y
    INY
    CPY #$14
    BNE bra_clear_runner_obj_slots
    TAY
; Clear attract runner sprite slots
bra_clear_runner_sprite_slots:  ; was: bra_C716_loop
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$14
    BNE bra_clear_runner_sprite_slots
    JSR sub_build_oam_from_sprite_buffers
    INC ram_shared_state_1
    INC ram_shared_state_1
    JMP loc_script_dispatch_loop

; Chase phase A: Pac-Man runs from ghosts
handler_chase_run_from_ghosts:  ; was: ofs_002_C728_02
; pacman is running from ghosts
    JSR sub_update_chase_scene_frame
    JSR sub_blink_chase_marker
    LDA ram_spr_pos_X_hi
    CMP #$E0
    BEQ bra_spawn_next_ghost_if_checkpoint
    CMP #$D1
    BEQ bra_spawn_next_ghost_if_checkpoint
    CMP #$C2
    BEQ bra_spawn_next_ghost_if_checkpoint
    CMP #$B3
    BNE bra_check_phase_a_finish
; At checkpoint X, spawn next ghost runner
bra_spawn_next_ghost_if_checkpoint:  ; was: bra_C741
    JSR sub_spawn_ghost_runner
; Wait until lead runner reaches phase-A terminal X
bra_check_phase_a_finish:  ; was: bra_C744
    LDA ram_spr_pos_X_hi
    CMP #$40
    BEQ bra_phase_a_to_b_reset
    JMP loc_script_dispatch_loop
; Transition phase A->B: reset slots and marker
bra_phase_a_to_b_reset:  ; was: bra_C74E
    LDY #$00
; Reset chase phase-B object X slots to base
bra_reset_phase_b_obj_slots:  ; was: bra_C750_loop
    LDA #> $00C0
    STA ram_obj_pos_X_hi + $04,Y
    LDA #< $00C0
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_reset_phase_b_obj_slots
    LDA #> $0150
    STA ram_obj_pos_X_hi
    LDA #< $0150
    STA ram_obj_pos_X_lo
    LDA #$01
    STA ram_actor_sprite_attrs + $01
    STA ram_actor_sprite_attrs + $02
    STA ram_actor_sprite_attrs + $03
    STA ram_actor_sprite_attrs + $04
    LDA #$00
    STA ram_shared_state_2
    LDA #$22
    STA ram_ppu_buffer_main
    LDA #$20
    STA ram_ppu_buffer_main + $02
    INC ram_shared_state_1
    INC ram_shared_state_1
    JMP loc_script_dispatch_loop

; Chase phase B: Pac-Man turns and chases ghosts
handler_chase_run_toward_ghosts:  ; was: ofs_002_C78D_04
; pacman is running at ghosts
    LDA ram_shared_state_3
    BEQ bra_update_phase_b_scene
    JSR sub_rotate_runner_slots
    DEC ram_shared_state_3
    BEQ bra_resolve_eaten_ghost
    JMP loc_script_dispatch_loop
; Resolve one eaten ghost slot and score marker update
bra_resolve_eaten_ghost:  ; was: bra_C79B
    LDY #$00
; Scan eaten-marker slots for active entry
bra_find_active_eaten_marker_slot:  ; was: bra_C79D_loop
    LDA ram_actor_sprite_set + $01,Y
    AND #$E0
    BNE bra_clear_eaten_slot_state
    INY
    BNE bra_find_active_eaten_marker_slot  ; Y steps 0,4,8,0C so branch always until slot found
; Clear resolved eaten marker and slot state
bra_clear_eaten_slot_state:  ; was: bra_C7A7
    LDA #$00
    STA ram_actor_sprite_set + $01,Y
    LDA #$00
    STA ram_actor_sprite_attrs + $01,Y
    TYA
    ASL
    ASL
    TAY
    LDA #$00
    STA ram_spr_pos_X_hi + $04,Y
    STA ram_spr_pos_Y_hi + $04,Y
    STA ram_obj_pos_X_hi + $04,Y
    STA ram_obj_pos_X_lo + $04,Y
    LDA #$A8
    STA ram_spr_pos_Y_hi
    LDA ram_shared_state_2
    CMP #$04
    BEQ bra_enter_gameplay_after_chase
    JMP loc_script_dispatch_loop
; Exit attract chase and jump into gameplay init
bra_enter_gameplay_after_chase:  ; was: bra_C7D1
    LDA #$01
    STA ram_game_mode
    JMP loc_enter_gameplay_session
; Phase B path when no eat event is active
bra_update_phase_b_scene:  ; was: bra_C7D8
    JSR sub_update_chase_scene_frame
    JMP loc_script_dispatch_loop

; Spawn one ghost runner entity in attract chase
sub_spawn_ghost_runner:  ; was: sub_C7DE
    LDY #$00
    STY zp_work0
; Find first free runner slot for ghost spawn
bra_find_free_runner_slot:  ; was: bra_C7E2_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_init_spawned_runner_slot
    INC zp_work0
    INY
    INY
    INY
    INY
    BNE bra_find_free_runner_slot
; Initialize spawned ghost runner slot values
bra_init_spawned_runner_slot:  ; was: bra_C7EF
    LDA #$F4
    STA ram_spr_pos_X_hi + $04,Y
    LDA #$A8
    STA ram_spr_pos_Y_hi + $04,Y
    LDA #< $00FF
    STA ram_obj_pos_X_hi + $04,Y
    LDA #> $00FF
    STA ram_obj_pos_X_lo + $04,Y
    LDY zp_work0
    LDA ram_shared_state_2
    STA ram_actor_sprite_attrs + $01,Y
    LDA #$0C
    STA ram_actor_sprite_set + $01,Y
    INC ram_shared_state_2
    RTS

; Per-frame chase scene update: movement, anim, collision, OAM
sub_update_chase_scene_frame:  ; was: sub_C812
    JSR sub_update_intermission_actor_positions
    JSR sub_rotate_runner_slots
    JSR sub_update_chase_anim_tiles
    JSR sub_handle_chase_contact
    JMP loc_build_oam_from_sprite_buffers

; Detect Pac-Man contact with runner and trigger eat event
sub_handle_chase_contact:  ; was: sub_C821
    LDA ram_obj_pos_X_hi
    BPL bra_scan_runners_for_contact
    RTS
; Begin collision scan between Pac-Man and runners
bra_scan_runners_for_contact:  ; was: bra_C826
    LDA ram_spr_pos_X_hi
    CLC
    ADC #$08
    STA zp_work0
    LDY #$00
    STY zp_work1
; Scan runner X positions against Pac-Man threshold
bra_find_first_runner_ahead_of_pacman:  ; was: bra_C832_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_advance_runner_scan
    CMP zp_work0
    BCC bra_mark_runner_eaten
; Advance to next runner slot during contact scan
bra_advance_runner_scan:  ; was: bra_C83B
    INC zp_work1
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_find_first_runner_ahead_of_pacman
    RTS
; Mark contacted runner as eaten and trigger score popup
bra_mark_runner_eaten:  ; was: bra_C846
    LDY ram_shared_state_2
    INC ram_shared_state_2
    LDA #$40
    STA ram_shared_state_3
    LDA tbl_ghost_score_tiles,Y
    LDY zp_work1
    STA ram_actor_sprite_set + $01,Y
    LDA #$00
    STA ram_actor_sprite_attrs + $01,Y
    LDA #$00
    STA ram_actor_sprite_set
    STA ram_spr_pos_Y_hi
    RTS

; Rotate runner object/sprite/state arrays
sub_rotate_runner_slots:  ; was: sub_C864
    LDA ram_obj_pos_X_hi + $04
    STA zp_work0
    LDA ram_obj_pos_X_lo + $04
    STA zp_work1
    LDY #$00
; Rotate object position ring buffer left by one slot
bra_rotate_object_positions_left:  ; was: bra_C86E_loop
    LDA ram_obj_pos_X_hi + $08,Y
    STA ram_obj_pos_X_hi + $04,Y
    LDA ram_obj_pos_X_lo + $08,Y
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$0C
    BNE bra_rotate_object_positions_left
    LDA zp_work0
    STA ram_obj_pos_X_hi + $10
    LDA zp_work1
    STA ram_obj_pos_X_lo + $10
    LDA ram_spr_pos_X_hi + $04
    STA zp_work0
    LDA ram_spr_pos_X_lo + $04
    STA zp_work1
    LDA ram_spr_pos_Y_hi + $04
    STA zp_work2
    LDA ram_spr_pos_Y_lo + $04
    STA zp_work3
    LDY #$00
; Rotate sprite position bytes left by one slot
bra_rotate_sprite_bytes_left:  ; was: bra_C8A0_loop
    LDA ram_spr_pos_X_hi + $08,Y
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$0C
    BNE bra_rotate_sprite_bytes_left
    LDA zp_work0
    STA ram_spr_pos_X_hi + $10
    LDA zp_work1
    STA ram_spr_pos_X_lo + $10
    LDA zp_work2
    STA ram_spr_pos_Y_hi + $10
    LDA zp_work3
    STA ram_spr_pos_Y_lo + $10
    LDA ram_actor_sprite_set + $01
    STA zp_work0
    LDY #$00
; Rotate runner tile IDs left by one slot
bra_rotate_runner_tile_ids_left:  ; was: bra_C8C6_loop
    LDA ram_actor_sprite_set + $02,Y
    STA ram_actor_sprite_set + $01,Y
    INY
    CPY #$03
    BNE bra_rotate_runner_tile_ids_left
    LDA zp_work0
    STA ram_actor_sprite_set + $04
    LDA ram_actor_sprite_attrs + $01
    STA zp_work0
    LDY #$00
; Rotate runner palette/flags left by one slot
bra_rotate_runner_palette_flags_left:  ; was: bra_C8DD_loop
    LDA ram_actor_sprite_attrs + $02,Y
    STA ram_actor_sprite_attrs + $01,Y
    INY
    CPY #$03
    BNE bra_rotate_runner_palette_flags_left
    LDA zp_work0
    STA ram_actor_sprite_attrs + $04
    RTS

; Blink chase marker text/tile packet every 8 frames
sub_blink_chase_marker:  ; was: sub_C8EE
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_blink_tick
    RTS
; Every-8-frame blink update entry
bra_blink_tick:  ; was: bra_C8F5
; each 8 frames
    LDX #$00
    LDY #$00
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_select_marker_variant
    LDY #$04
; Select visible/hidden marker packet variant
bra_select_marker_variant:  ; was: bra_C901
; Copy marker packet bytes into PPU buffer
bra_copy_marker_packet:  ; was: bra_C901_loop
    LDA tbl_ppu_cmd_chase_marker,Y
    STA ram_ppu_buffer_main,X
    INX
    INY
    CPX #$04
    BNE bra_copy_marker_packet
    RTS

; PPU packet to clear 10/50/200/400 points text area
tbl_ppu_cmd_clear_points_text:  ; was: tbl_C90E
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AD
    .byte $2D, $2D, $2D
    .byte $2D, $2D, $2D, $2D, $2D, $00, $22, $ED, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D
    .byte $FF  ; end token

; Tile IDs for ghost-eaten score popups
tbl_ghost_score_tiles:  ; was: tbl_C924
    .byte $2D  ; 00
    .byte $2F  ; 01
    .byte $32  ; 02
    .byte $34  ; 03

; PPU packets for chase marker blink states
tbl_ppu_cmd_chase_marker:  ; was: tbl_C928
; 00
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte $20
    .byte $FF
; 04
; 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte $01
    .byte $FF
; Update chase scene animation tiles for Pac-Man/ghosts
sub_update_chase_anim_tiles:  ; was: sub_C930
    LDX #$00
    LDA ram_obj_pos_X_hi
    BMI bra_store_anim_bank_offset
    LDX #$0A
; Store selected animation bank offset
bra_store_anim_bank_offset:  ; was: bra_C938
    STX zp_work0
    INC ram_pacman_anim_phase
    LDA ram_pacman_anim_phase
    AND #$07
    CLC
    ADC zp_work0
    TAY
    LDA tbl_chase_anim_lut,Y
    STA ram_actor_sprite_set
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_update_ghost_tiles_every_8f
    RTS
; Update ghost tiles every 8 frames only
bra_update_ghost_tiles_every_8f:  ; was: bra_C951
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_select_chomp_toggle
    LDA #$01
; Select alternate tile on 8-frame toggle bit
bra_select_chomp_toggle:  ; was: bra_C959
    CLC
    ADC zp_work0
    ADC #$08
    TAY
    LDA tbl_chase_anim_lut,Y
    STA zp_work0
    LDY #$00
; Apply current ghost tile to active runner slots
bra_apply_ghost_tile_to_active_slots:  ; was: bra_C966_loop
    LDA ram_actor_sprite_set + $01,Y
    BEQ bra_next_runner_tile_slot
    LDA zp_work0
    STA ram_actor_sprite_set + $01,Y
; Advance to next chase runner tile slot in update loop
bra_next_runner_tile_slot:  ; was: bra_C970
    INY
    CPY #$04
    BNE bra_apply_ghost_tile_to_active_slots
    RTS

; Animation LUT used by chase scene update
tbl_chase_anim_lut:  ; was: tbl_C976
; indexes 08, 09, 12 and 13 are read via 0x00096F
; other indexes are read via 0x000954
    .byte $04  ; 00
    .byte $04  ; 01
    .byte $04  ; 02
    .byte $05  ; 03
    .byte $05  ; 04
    .byte $04  ; 05
    .byte $01  ; 06
    .byte $01  ; 07
    .byte $0C  ; 08
    .byte $0D  ; 09
    .byte $08  ; 0A
    .byte $08  ; 0B
    .byte $08  ; 0C
    .byte $09  ; 0D
    .byte $09  ; 0E
    .byte $08  ; 0F
    .byte $01  ; 10
    .byte $01  ; 11
    .byte $1E  ; 12
    .byte $1F  ; 13
