; Attract-mode chase scene, collisions, slot rotation, and animation

ofs_001_C6C8_attract_chase_scene:		; was: ofs_001_C6C8_16
    LDY ram_0088
    LDA tbl_C6D7_attract_chase_substates,Y
    STA ram_indirect_jmp
    LDA tbl_C6D7_attract_chase_substates + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)



; Substate handlers for chase attract scene
tbl_C6D7_attract_chase_substates:		; was: tbl_C6D7
    .word ofs_002_C6DD_chase_setup_intro_text
    .word ofs_002_C728_chase_run_from_ghosts
    .word ofs_002_C78D_chase_run_toward_ghosts



; Chase substate init: clear score text, seed actor/sprite state
ofs_002_C6DD_chase_setup_intro_text:		; was: ofs_002_C6DD_00
; clear 10 pts 50 pts text
    LDY #$00
; Copy fixed PPU command packet into main buffer
bra_C6DF_copy_ppu_packet:		; was: bra_C6DF_loop
    LDA tbl_C90E_ppu_cmd_clear_points_text,Y
    STA ram_ppu_buffer_main,Y
    INY
    CMP #$FF
    BNE bra_C6DF_copy_ppu_packet
    LDA #< $00FF
    STA ram_obj_pos_X_hi
    LDA #> $00FF
    STA ram_obj_pos_X_lo
    STA ram_0089
    STA ram_008A
    LDA #$F4
    STA ram_spr_pos_X_hi
    LDA #$A8
    STA ram_spr_pos_Y_hi
    LDA #$01
    STA ram_028C
    LDA #$20
    STA ram_0292
    LDA #$00
    TAY
; Clear attract runner object slots
bra_C70D_clear_runner_obj_slots:		; was: bra_C70D_loop
    STA ram_obj_position + $04,Y
    INY
    CPY #$14
    BNE bra_C70D_clear_runner_obj_slots
    TAY
; Clear attract runner sprite slots
bra_C716_clear_runner_sprite_slots:		; was: bra_C716_loop
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$14
    BNE bra_C716_clear_runner_sprite_slots
    JSR sub_DA5C_build_oam_from_sprite_buffers
    INC ram_0088
    INC ram_0088
    JMP loc_C1DE_script_dispatch_loop



; Chase phase A: Pac-Man runs from ghosts
ofs_002_C728_chase_run_from_ghosts:		; was: ofs_002_C728_02
; pacman is running from ghosts
    JSR sub_C812_update_chase_scene_frame
    JSR sub_C8EE_blink_chase_marker
    LDA ram_spr_pos_X_hi
    CMP #$E0
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$D1
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$C2
    BEQ bra_C741_spawn_next_ghost_if_checkpoint
    CMP #$B3
    BNE bra_C744_check_phase_a_finish
; At checkpoint X, spawn next ghost runner
bra_C741_spawn_next_ghost_if_checkpoint:		; was: bra_C741
    JSR sub_C7DE_spawn_ghost_runner
; Wait until lead runner reaches phase-A terminal X
bra_C744_check_phase_a_finish:		; was: bra_C744
    LDA ram_spr_pos_X_hi
    CMP #$40
    BEQ bra_C74E_phase_a_to_b_reset
    JMP loc_C1DE_script_dispatch_loop
; Transition phase A->B: reset slots and marker
bra_C74E_phase_a_to_b_reset:		; was: bra_C74E
    LDY #$00
; Reset chase phase-B object X slots to base
bra_C750_reset_phase_b_obj_slots:		; was: bra_C750_loop
    LDA #> $00C0
    STA ram_obj_pos_X_hi + $04,Y
    LDA #< $00C0
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_C750_reset_phase_b_obj_slots
    LDA #> $0150
    STA ram_obj_pos_X_hi
    LDA #< $0150
    STA ram_obj_pos_X_lo
    LDA #$01
    STA ram_0293
    STA ram_0294
    STA ram_0295
    STA ram_0296
    LDA #$00
    STA ram_0089
    LDA #$22
    STA ram_ppu_buffer_main
    LDA #$20
    STA ram_ppu_buffer_main + $02
    INC ram_0088
    INC ram_0088
    JMP loc_C1DE_script_dispatch_loop



; Chase phase B: Pac-Man turns and chases ghosts
ofs_002_C78D_chase_run_toward_ghosts:		; was: ofs_002_C78D_04
; pacman is running at ghosts
    LDA ram_008A
    BEQ bra_C7D8_update_phase_b_scene
    JSR sub_C864_rotate_runner_slots
    DEC ram_008A
    BEQ bra_C79B_resolve_eaten_ghost
    JMP loc_C1DE_script_dispatch_loop
; Resolve one eaten ghost slot and score marker update
bra_C79B_resolve_eaten_ghost:		; was: bra_C79B
    LDY #$00
; Scan eaten-marker slots for active entry
bra_C79D_find_active_eaten_marker_slot:		; was: bra_C79D_loop
    LDA ram_028D,Y
    AND #$E0
    BNE bra_C7A7_clear_eaten_slot_state
    INY
    BNE bra_C79D_find_active_eaten_marker_slot    ; Y steps 0,4,8,0C so branch always until slot found
; Clear resolved eaten marker and slot state
bra_C7A7_clear_eaten_slot_state:		; was: bra_C7A7
    LDA #$00
    STA ram_028D,Y
    LDA #$00
    STA ram_0293,Y
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
    LDA ram_0089
    CMP #$04
    BEQ bra_C7D1_enter_gameplay_after_chase
    JMP loc_C1DE_script_dispatch_loop
; Exit attract chase and jump into gameplay init
bra_C7D1_enter_gameplay_after_chase:		; was: bra_C7D1
    LDA #$01
    STA ram_game_mode
    JMP loc_C98A_enter_gameplay_session
; Phase B path when no eat event is active
bra_C7D8_update_phase_b_scene:		; was: bra_C7D8
    JSR sub_C812_update_chase_scene_frame
    JMP loc_C1DE_script_dispatch_loop



; Spawn one ghost runner entity in attract chase
sub_C7DE_spawn_ghost_runner:		; was: sub_C7DE
    LDY #$00
    STY ram_0000
; Find first free runner slot for ghost spawn
bra_C7E2_find_free_runner_slot:		; was: bra_C7E2_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_C7EF_init_spawned_runner_slot
    INC ram_0000
    INY
    INY
    INY
    INY
    BNE bra_C7E2_find_free_runner_slot
; Initialize spawned ghost runner slot values
bra_C7EF_init_spawned_runner_slot:		; was: bra_C7EF
    LDA #$F4
    STA ram_spr_pos_X_hi + $04,Y
    LDA #$A8
    STA ram_spr_pos_Y_hi + $04,Y
    LDA #< $00FF
    STA ram_obj_pos_X_hi + $04,Y
    LDA #> $00FF
    STA ram_obj_pos_X_lo + $04,Y
    LDY ram_0000
    LDA ram_0089
    STA ram_0293,Y
    LDA #$0C
    STA ram_028D,Y
    INC ram_0089
    RTS



; Per-frame chase scene update: movement, anim, collision, OAM
sub_C812_update_chase_scene_frame:		; was: sub_C812
    JSR sub_E9A5_update_intermission_actor_positions
    JSR sub_C864_rotate_runner_slots
    JSR sub_C930_update_chase_anim_tiles
    JSR sub_C821_handle_chase_contact
    JMP loc_DA5C_build_oam_from_sprite_buffers



; Detect Pac-Man contact with runner and trigger eat event
sub_C821_handle_chase_contact:		; was: sub_C821
    LDA ram_obj_pos_X_hi
    BPL bra_C826_scan_runners_for_contact
    RTS
; Begin collision scan between Pac-Man and runners
bra_C826_scan_runners_for_contact:		; was: bra_C826
    LDA ram_spr_pos_X_hi
    CLC
    ADC #$08
    STA ram_0000
    LDY #$00
    STY ram_0001
; Scan runner X positions against Pac-Man threshold
bra_C832_find_first_runner_ahead_of_pacman:		; was: bra_C832_loop
    LDA ram_spr_pos_X_hi + $04,Y
    BEQ bra_C83B_advance_runner_scan
    CMP ram_0000
    BCC bra_C846_mark_runner_eaten
; Advance to next runner slot during contact scan
bra_C83B_advance_runner_scan:		; was: bra_C83B
    INC ram_0001
    INY
    INY
    INY
    INY
    CPY #$10
    BNE bra_C832_find_first_runner_ahead_of_pacman
    RTS
; Mark contacted runner as eaten and trigger score popup
bra_C846_mark_runner_eaten:		; was: bra_C846
    LDY ram_0089
    INC ram_0089
    LDA #$40
    STA ram_008A
    LDA tbl_C924_ghost_score_tiles,Y
    LDY ram_0001
    STA ram_028D,Y
    LDA #$00
    STA ram_0293,Y
    LDA #$00
    STA ram_028C
    STA ram_spr_pos_Y_hi
    RTS



; Rotate runner object/sprite/state arrays
sub_C864_rotate_runner_slots:		; was: sub_C864
    LDA ram_obj_pos_X_hi + $04
    STA ram_0000
    LDA ram_obj_pos_X_lo + $04
    STA ram_0001
    LDY #$00
; Rotate object position ring buffer left by one slot
bra_C86E_rotate_object_positions_left:		; was: bra_C86E_loop
    LDA ram_obj_pos_X_hi + $08,Y
    STA ram_obj_pos_X_hi + $04,Y
    LDA ram_obj_pos_X_lo + $08,Y
    STA ram_obj_pos_X_lo + $04,Y
    INY
    INY
    INY
    INY
    CPY #$0C
    BNE bra_C86E_rotate_object_positions_left
    LDA ram_0000
    STA ram_obj_pos_X_hi + $10
    LDA ram_0001
    STA ram_obj_pos_X_lo + $10
    LDA ram_spr_pos_X_hi + $04
    STA ram_0000
    LDA ram_spr_pos_X_lo + $04
    STA ram_0001
    LDA ram_spr_pos_Y_hi + $04
    STA ram_0002
    LDA ram_spr_pos_Y_lo + $04
    STA ram_0003
    LDY #$00
; Rotate sprite position bytes left by one slot
bra_C8A0_rotate_sprite_bytes_left:		; was: bra_C8A0_loop
    LDA ram_spr_pos_X_hi + $08,Y
    STA ram_spr_pos_X_hi + $04,Y
    INY
    CPY #$0C
    BNE bra_C8A0_rotate_sprite_bytes_left
    LDA ram_0000
    STA ram_spr_pos_X_hi + $10
    LDA ram_0001
    STA ram_spr_pos_X_lo + $10
    LDA ram_0002
    STA ram_spr_pos_Y_hi + $10
    LDA ram_0003
    STA ram_spr_pos_Y_lo + $10
    LDA ram_028D
    STA ram_0000
    LDY #$00
; Rotate runner tile IDs left by one slot
bra_C8C6_rotate_runner_tile_ids_left:		; was: bra_C8C6_loop
    LDA ram_028E,Y
    STA ram_028D,Y
    INY
    CPY #$03
    BNE bra_C8C6_rotate_runner_tile_ids_left
    LDA ram_0000
    STA ram_0290
    LDA ram_0293
    STA ram_0000
    LDY #$00
; Rotate runner palette/flags left by one slot
bra_C8DD_rotate_runner_palette_flags_left:		; was: bra_C8DD_loop
    LDA ram_0294,Y
    STA ram_0293,Y
    INY
    CPY #$03
    BNE bra_C8DD_rotate_runner_palette_flags_left
    LDA ram_0000
    STA ram_0296
    RTS



; Blink chase marker text/tile packet every 8 frames
sub_C8EE_blink_chase_marker:		; was: sub_C8EE
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_C8F5_blink_tick
    RTS
; Every-8-frame blink update entry
bra_C8F5_blink_tick:		; was: bra_C8F5
; each 8 frames
    LDX #$00
    LDY #$00
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_C901_select_marker_variant
    LDY #$04
; Select visible/hidden marker packet variant
bra_C901_select_marker_variant:		; was: bra_C901
; Copy marker packet bytes into PPU buffer
bra_C901_copy_marker_packet:		; was: bra_C901_loop
    LDA tbl_C928_ppu_cmd_chase_marker,Y
    STA ram_ppu_buffer_main,X
    INX
    INY
    CPX #$04
    BNE bra_C901_copy_marker_packet
    RTS



; PPU packet to clear 10/50/200/400 points text area
tbl_C90E_ppu_cmd_clear_points_text:		; was: tbl_C90E
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22AD
    .byte                                                                  $2D, $2D, $2D
    .byte $2D, $2D, $2D, $2D, $2D, $00, $22, $ED, $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D
    .byte $FF   ; end token



; Tile IDs for ghost-eaten score popups
tbl_C924_ghost_score_tiles:		; was: tbl_C924
    .byte $2D   ; 00
    .byte $2F   ; 01
    .byte $32   ; 02
    .byte $34   ; 03



; PPU packets for chase marker blink states
tbl_C928_ppu_cmd_chase_marker:		; was: tbl_C928
; 00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte                                    $20
    .byte $FF
; 04
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $22C7
    .byte                                    $01
    .byte $FF
; Update chase scene animation tiles for Pac-Man/ghosts
sub_C930_update_chase_anim_tiles:		; was: sub_C930
    LDX #$00
    LDA ram_obj_pos_X_hi
    BMI bra_C938_store_anim_bank_offset
    LDX #$0A
; Store selected animation bank offset
bra_C938_store_anim_bank_offset:		; was: bra_C938
    STX ram_0000
    INC ram_00B7
    LDA ram_00B7
    AND #$07
    CLC
    ADC ram_0000
    TAY
    LDA tbl_C976_chase_anim_lut,Y
    STA ram_028C
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_C951_update_ghost_tiles_every_8f
    RTS
; Update ghost tiles every 8 frames only
bra_C951_update_ghost_tiles_every_8f:		; was: bra_C951
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BEQ bra_C959_select_chomp_toggle
    LDA #$01
; Select alternate tile on 8-frame toggle bit
bra_C959_select_chomp_toggle:		; was: bra_C959
    CLC
    ADC ram_0000
    ADC #$08
    TAY
    LDA tbl_C976_chase_anim_lut,Y
    STA ram_0000
    LDY #$00
; Apply current ghost tile to active runner slots
bra_C966_apply_ghost_tile_to_active_slots:		; was: bra_C966_loop
    LDA ram_028D,Y
    BEQ bra_C970_next_runner_tile_slot
    LDA ram_0000
    STA ram_028D,Y
; Advance to next chase runner tile slot in update loop
bra_C970_next_runner_tile_slot:		; was: bra_C970
    INY
    CPY #$04
    BNE bra_C966_apply_ghost_tile_to_active_slots
    RTS



; Animation LUT used by chase scene update
tbl_C976_chase_anim_lut:		; was: tbl_C976
; indexes 08, 09, 12 and 13 are read via 0x00096F
; other indexes are read via 0x000954
    .byte $04   ; 00
    .byte $04   ; 01
    .byte $04   ; 02
    .byte $05   ; 03
    .byte $05   ; 04
    .byte $04   ; 05
    .byte $01   ; 06
    .byte $01   ; 07
    .byte $0C   ; 08
    .byte $0D   ; 09
    .byte $08   ; 0A
    .byte $08   ; 0B
    .byte $08   ; 0C
    .byte $09   ; 0D
    .byte $09   ; 0E
    .byte $08   ; 0F
    .byte $01   ; 10
    .byte $01   ; 11
    .byte $1E   ; 12
    .byte $1F   ; 13
