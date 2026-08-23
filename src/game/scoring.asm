; Pellets, frightened mode, score, and extra lives

; Check whether Pac-Man's sampled tile is a pellet and consume it.
;
; Inputs:
; - ram_obj_ppu_tile_now: tile sampled at Pac-Man's current position
; - ram_obj_pos_X_hi/ram_obj_pos_Y_hi: world position used to locate the PPU tile
; Outputs:
; - no pellet: returns without changing gameplay state
; - pellet: commits its pending score before returning through
;   loc_add_points_and_update_score_buffers
; Side effects:
; - clears the maze tile through ram_ppu_buffer_main and ram_obj_ppu_tile_now
; - resets the ghost-release inactivity timer and decrements ram_pellet_cnt_p1
; - may start frightened mode, spawn fruit, or select the stage-clear script
; - requests one of the alternating pellet sound effects
; Clobbers: A, X, Y; pellet paths also use zp_work0..zp_work4.
sub_check_for_eating_pellets:
    LDX #$00
    LDA ram_obj_ppu_tile_now
    CMP #con_tile_pellet_alt
    BEQ bra_handle_any_pellet_eaten    ; if normal pellet (rare)
    INX
    INX
    CMP #con_tile_pellet
    BEQ bra_handle_any_pellet_eaten    ; if normal pellet
    CMP #con_tile_power_pellet_visible
    BEQ bra_handle_power_pellet_eaten    ; if power pellet (visible)
    CMP #con_tile_power_pellet_hidden
    BEQ bra_handle_power_pellet_eaten    ; if power pellet (not visible)
    RTS
; Handle power-pellet eat path
bra_handle_power_pellet_eaten:		; was: bra_DEF7
    JSR sub_start_frightened_mode
    LDA ram_obj_pos_X_hi
    STA zp_work2
    LDA ram_obj_pos_Y_hi
    STA zp_work3
    JSR sub_convert_world_pos_to_ppu_addr
    LDX #$00
    LDA zp_work3
    AND #$07
    BEQ bra_select_power_pellet_slot_by_row
    INX
    INX
; Select power-pellet slot by row parity
bra_select_power_pellet_slot_by_row:		; was: bra_DF0F
    LDA zp_work2    ; ppu_pos_lo
    AND #$0F
    CMP #$04
    BEQ bra_mark_power_pellet_slot_eaten
    INX
; Mark matched power-pellet slot as eaten
bra_mark_power_pellet_slot_eaten:		; was: bra_DF18
    LDA #con_tile_floor
    STA ram_power_pellet_tile_p1,X
    LDX #$04
; Handle common pellet-eaten flow
bra_handle_any_pellet_eaten:		; was: bra_DF1E
; Common tail for normal and power pellets:
; - queue one tile clear into ram_ppu_buffer_main
; - write pending score digit delta into 00DC
; - decrement pellet counter and possibly trigger stage-clear script
    LDA #$00
    STA ram_release_timer_seconds
    STA ram_release_timer_ticks
    LDA ram_obj_pos_X_hi
    STA zp_work2
    LDA ram_obj_pos_Y_hi
    STA zp_work3
    JSR sub_convert_world_pos_to_ppu_addr
    LDY #$FF
; Find end token in PPU command buffer
bra_find_ppu_buffer_end:		; was: bra_DF31_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #con_ppu_buffer_end
    BNE bra_find_ppu_buffer_end
    TYA
    BEQ bra_append_pellet_clear_ppu_cmd
    LDA #con_ppu_command_end
    STA ram_ppu_buffer_main,Y
    INY
; Append pellet-clear PPU command
bra_append_pellet_clear_ppu_cmd:		; was: bra_DF42
    LDA zp_work3    ; ppu_pos_hi
    STA ram_ppu_buffer_main,Y
    INY
    LDA zp_work2    ; ppu_pos_lo
    STA ram_ppu_buffer_main,Y
    INY
    LDA tbl_pellet_clear_tile_and_points,X
    STA ram_ppu_buffer_main,Y
    INY
    LDA #con_ppu_buffer_end
    STA ram_ppu_buffer_main,Y
    LDA #con_tile_floor
    STA ram_obj_ppu_tile_now
    LDA tbl_pellet_clear_tile_and_points_alias + $01,X
    STA ram_pending_score_bcd
    DEC ram_pellet_cnt_p1
    BNE bra_check_fruit_spawn_thresholds
    LDA #con_game_script_stage_clear
    STA ram_script
    LDA #$00
    STA ram_shared_state_0
    LDA #$48    ; pause timer
    STA ram_script_delay
; Check fruit spawn thresholds after pellet eat
bra_check_fruit_spawn_thresholds:		; was: bra_DF74
    LDA ram_pellet_cnt_p1
    CMP #$37
    BEQ bra_spawn_fruit_item
    CMP #$86
    BNE bra_play_pellet_sfx_and_score
; Spawn fruit item and timer
bra_spawn_fruit_item:		; was: bra_DF7E_spawn_fruit
    LDA #$0A
    STA ram_fruit_timer_hi
    LDA #$3C
    STA ram_fruit_timer_lo
    LDY ram_stage_param_index
    LDA tbl_fruit_sprite_tile_by_stage,Y
    STA ram_animation + $05
    LDA #$03
    STA ram_spr_pal + $05
    LDA #$60
    STA ram_obj_pos_X_hi + $14
    LDA #$80
    STA ram_obj_pos_Y_hi + $14
; Play pellet SFX and commit score update
bra_play_pellet_sfx_and_score:		; was: bra_DF99_skip_fruit_spawn
    LDA ram_pellet_cnt_p1
    AND #$01
    TAY
    LDA #$01
    STA ram_sfx_eat_pellet,Y  ; 0604 0605
    JMP loc_add_points_and_update_score_buffers

; Tile+points pairs for eaten pellet types
tbl_pellet_clear_tile_and_points:		; was: tbl_DFA6_tile
; Alias label at same address for pellet tile+points pairs
tbl_pellet_clear_tile_and_points_alias:		; was: tbl_DFA6_points
    .byte $08, $01             ; 00 normal pellet (rare)
    .byte con_tile_floor, $01  ; 02 normal pellet
    .byte con_tile_floor, $05  ; 04 power pellet

; !(UNUSED) No external entry or fall-through reaches this duplicate. See CODE-002.
    LDX #$00
; Legacy duplicate: find free release slot
bra_find_free_release_slot_legacy:		; was: bra_DFAE_loop
    LDA ram_ghost_state + $02,X
    BNE bra_next_release_slot_legacy
    LDA #con_ghost_state_exiting_house
    STA ram_ghost_state + $02,X
    RTS
; Legacy duplicate: next release slot
bra_next_release_slot_legacy:		; was: bra_DFB7
    INX
    INX
    CPX #$06
    BNE bra_find_free_release_slot_legacy
    RTS

; Fruit sprite tile ID by stage
tbl_fruit_sprite_tile_by_stage:		; was: tbl_DFBE_fruit_id
; !(OBS) Values are consecutive, but the preservation source retains the table.
    .byte $24   ; 00
    .byte $25   ; 01
    .byte $26   ; 02
    .byte $27   ; 03
    .byte $28   ; 04
    .byte $29   ; 05
    .byte $2A   ; 06
    .byte $2B   ; 07

; Start frightened mode after a power pellet is consumed.
;
; Inputs:
; - ram_frightened_duration: stage-specific frightened timer value
; - ghost state, direction, position, and sampled neighbor-tile arrays
; - ram_ppu_buffer_main: terminated command stream with space for the palette packet
; Outputs: none.
; Side effects:
; - initializes the frightened timer/mask, resets ram_kill_cnt, and selects the
;   frightened palette for all four ghosts
; - appends tbl_frightened_palette_cmd_alt to ram_ppu_buffer_main
; - falls through to sub_try_reverse_ghost_directions, so eligible active ghosts
;   may reverse before this call returns
; Clobbers: A, X, Y and zp_work0..zp_work4.
sub_start_frightened_mode:		; was: sub_DFC6
    LDA ram_frightened_duration
    BNE bra_store_frightened_timer
    LDA #$1E
    STA ram_shared_state_3
    LDA #$00
; Store frightened timer/state value
bra_store_frightened_timer:		; was: bra_DFD0
    STA ram_shared_state_2
    LDA #$0F
    STA ram_shared_state_1
    LDX #$03
; Set ghost palettes to frightened color set
bra_set_ghost_palette_frightened:		; was: bra_DFD8_loop
    LDA ram_spr_pal + $01,X
    AND #$FC
    ORA #$01
    STA ram_spr_pal + $01,X
    DEX
    BPL bra_set_ghost_palette_frightened
.ifdef PACMAN_REVISION_TENGEN
    LDA #$11
    STA ram_tengen_sprite_palette_update + $05
    LDA #$0F
    STA ram_tengen_sprite_palette_update
.else
    LDY #$FF
; Find PPU buffer end for frightened palette command
bra_find_ppu_buffer_end_for_palette_cmd:		; was: bra_DFE5_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #con_ppu_buffer_end
    BNE bra_find_ppu_buffer_end_for_palette_cmd
    LDX #$00
    TYA
    BNE bra_adjust_palette_cmd_offset
    INX
; Adjust palette command source offset when buffer empty
bra_adjust_palette_cmd_offset:		; was: bra_DFF3
; Append frightened palette command bytes
bra_append_frightened_palette_cmd:		; was: bra_DFF3_loop
.ifdef PACMAN_EXPANDED_PALETTES
    LDA tbl_expanded_frightened_palette_cmd_alt,X
.else
    LDA tbl_frightened_palette_cmd_alt,X
.endif
    STA ram_ppu_buffer_main,Y
    INY
    INX
    CMP #con_ppu_buffer_end
    BNE bra_append_frightened_palette_cmd
.endif
    LDA #$00
    STA ram_kill_cnt
; Reverse eligible active ghosts for a frightened/scatter-chase transition.
;
; Inputs:
; - ram_shared_state_1 and the RAM-003 post-threshold gate select reversal eligibility
; - ghost state/direction, position fractions, and sampled neighbor tiles
; Outputs: none.
; Side effects: writes ram_ghost_direction for state-$04 ghosts whose movement
; state permits an immediate reversal; all other slots are left unchanged.
; Clobbers: A, X, Y and zp_work0..zp_work4.
sub_try_reverse_ghost_directions:		; was: sub_E003
    LDX #$00
    LoadPointer zp_work0, (ram_obj_ppu_tile + $05)
    LoadPointer zp_work2, (ram_obj_pos_X_hi + $04)
    LDA #$0F
    CMP ram_shared_state_1
    BEQ bra_process_reversal_entry
    LDA ram_release_wave_timer
    BNE bra_next_ghost_for_reversal
; Entry label for reversal processing of active ghost slots
bra_process_reversal_entry:		; was: bra_E01F
; Process direction reversal for active ghost slots
bra_process_reversal_for_active_ghosts:		; was: bra_E01F_loop
    LDA ram_ghost_state,X
    CMP #con_ghost_state_active
    BNE bra_next_ghost_for_reversal
    LDA ram_ghost_direction,X
    CLC
    ADC #con_direction_reverse_delta
    AND #con_direction_mask
    STA zp_work4
    LDY #$00
    LDA (zp_work2),Y    ; 001E 0022 0026 002A
    LDY #$02
    ORA (zp_work2),Y    ; 0020 0024 0028 002C
    AND #$07
    BNE bra_store_reversed_direction
    LDY zp_work4
    LDA (zp_work0),Y    ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    AND #$F8
    BNE bra_next_ghost_for_reversal
; Store reversed direction for current ghost
bra_store_reversed_direction:		; was: bra_E042
    LDA zp_work4
    STA ram_ghost_direction,X
; Advance to next ghost in reversal pass
bra_next_ghost_for_reversal:		; was: bra_E046
    LDA zp_work0
    CLC
    ADC #con_actor_position_record_size
    STA zp_work0
    LDA zp_work2
    CLC
    ADC #con_actor_position_record_size
    STA zp_work2
    INX
    INX
    CPX #con_ghost_slot_span
    BNE bra_process_reversal_for_active_ghosts
    RTS

; Frightened palette command bytes (alternate source)
.ifndef PACMAN_REVISION_TENGEN
tbl_frightened_palette_cmd_alt:		; was: tbl_E05B
    .byte $00
    .dbyt $3F15
    .byte $11
    .byte $FF   ; end token
.endif

; Commit the pending BCD score transaction and refresh derived HUD state.
;
; Entry contract: producers fill ram_pending_score_bcd and tail-jump here. In
; demo mode the entry returns immediately and leaves the pending digits intact.
; Outputs: none.
; Side effects in live play:
; - adds and clears all six pending BCD digits, then rebuilds ram_ppu_buffer_score
; - awards the one-time extra life, requests its SFX, and appends its icon packet
;   when the threshold digit first reaches one
; - promotes the score RAM and formatted buffer when the score exceeds the hiscore
; Clobbers: A, X, Y and zp_work0..zp_work2.
loc_add_points_and_update_score_buffers:		; was: loc_E060
; Score pipeline:
; 1) add pending BCD deltas from ram_pending_score_bcd into active score
; 2) rebuild score tile buffer (leading zero suppression)
; 3) apply 1UP threshold once (ram_extra_life_awarded latch) and queue life icon packet
; 4) compare/promote hiscore buffers
    LDA ram_flag_demo
    BEQ bra_score_update_live_only
    RTS
; Skip score update in demo mode
bra_score_update_live_only:		; was: bra_E065
    LDY #$00
    LDA #$06
    STA zp_work0
    CLC
; Add pending BCD score digits
bra_add_pending_score_digits:		; was: bra_E06C_loop
    LDA ram_score_p1,Y
    ADC ram_pending_score_bcd,Y
    STA ram_score_p1,Y
    CMP #$0A
    BCC bra_clear_pending_score_digit
    SBC #$0A
    STA ram_score_p1,Y
    SEC
; Clear pending score digit accumulator
bra_clear_pending_score_digit:		; was: bra_E07F
    LDA #$00
; Six-byte pending BCD accumulator
    STA ram_pending_score_bcd,Y
    INY
    DEC zp_work0
    BNE bra_add_pending_score_digits
    LDX #$00
    DEY
; Skip leading zeroes while formatting score
bra_skip_leading_zeroes:		; was: bra_E08C_loop
    LDA ram_score_p1,Y
    JSR sub_digit_to_score_tile
    CMP #$30
    BNE bra_store_formatted_score_digit
    LDA #$20
    STA ram_ppu_buffer_score,X
    INX
    DEY
    BNE bra_skip_leading_zeroes
; Write formatted score digits into score PPU buffer
bra_write_formatted_score_digits:		; was: bra_E09F_loop
    LDA ram_score_p1,Y
    JSR sub_digit_to_score_tile
; Store one formatted score digit
bra_store_formatted_score_digit:		; was: bra_E0A5
    STA ram_ppu_buffer_score,X
    INX
    DEY
    BPL bra_write_formatted_score_digits
    LDA ram_extra_life_awarded
    BNE bra_compare_score_with_hiscore
    LDA #$01
    CMP ram_score_p1 + $03
    BNE bra_compare_score_with_hiscore
    LDA #$01
    STA ram_extra_life_awarded
    STA ram_sfx_extra_life
    INC ram_lives_p1
    LDA ram_lives_p1
    SEC
    SBC #$02
    ASL
    STA zp_work0
    LDY #$FF
; Find end of PPU command buffer before appending extra-life icon update
bra_find_ppu_buffer_end_for_life_icon:		; was: bra_E0C9_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #con_ppu_buffer_end
    BNE bra_find_ppu_buffer_end_for_life_icon
    TYA
    BEQ bra_select_life_icon_nametable
    LDA #con_ppu_command_end
    STA ram_ppu_buffer_main,Y
    INY
; Select life-icon nametable segment for active player
bra_select_life_icon_nametable:		; was: bra_E0DA
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_init_life_icon_packet_copy
    LDA #$08
; Initialize life-icon packet copy pointers
bra_init_life_icon_packet_copy:		; was: bra_E0E2
    STA zp_work1
    LDX #$00
; Copy life icon packet into main PPU command buffer
bra_copy_life_icon_packet:		; was: bra_E0E6_loop
    LDA tbl_life_icon_ppu_packets,X
    CLC
    ADC zp_work1
    STA ram_ppu_buffer_main,Y
    INY
    INX
    LDA tbl_life_icon_ppu_packets,X
    CLC
    ADC zp_work0
    STA ram_ppu_buffer_main,Y
    LDA #$03
    STA zp_work2
; Copy one life-icon payload chunk
bra_copy_life_icon_payload:		; was: bra_E0FE_loop
    INY
    INX
    LDA tbl_life_icon_ppu_packets,X
    STA ram_ppu_buffer_main,Y
    DEC zp_work2
    BNE bra_copy_life_icon_payload
    INY
    INX
    CPX #$0A
    BNE bra_copy_life_icon_packet
; Compare current score with hiscore
bra_compare_score_with_hiscore:		; was: bra_E110
; BCD digit-wise compare from highest index down.
    LDY #$05
; Digit-wise compare loop for hiscore update
bra_hiscore_compare_loop:		; was: bra_E112_loop
    LDA ram_score_hi,Y
    CMP ram_score_p1,Y
    BEQ bra_continue_hiscore_compare
    BCC bra_promote_score_to_hiscore
    RTS
; Continue hiscore compare with next digit
bra_continue_hiscore_compare:		; was: bra_E11D
    DEY
    BPL bra_hiscore_compare_loop
    RTS
; Promote score buffer and score RAM to hiscore
bra_promote_score_to_hiscore:		; was: bra_E121
    LDX #$00
; Copy score PPU buffer into hiscore PPU buffer
bra_copy_score_buf_to_hiscore_buf:		; was: bra_E123_loop
    LDA ram_ppu_buffer_score,X
    STA ram_ppu_buffer_hiscore,X
    INX
    CPX #con_score_field_size
    BNE bra_copy_score_buf_to_hiscore_buf
    LDX #$00
; Copy score digits into hiscore RAM
bra_copy_score_ram_to_hiscore_ram:		; was: bra_E130_loop
    LDA ram_score_p1,X
    STA ram_score_hi,X
    INX
    CPX #con_score_field_size
    BNE bra_copy_score_ram_to_hiscore_ram
    RTS

; PPU packet template for extra-life icon updates
tbl_life_icon_ppu_packets:		; was: tbl_E13A
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2317
    .byte                                    $3C, $3D, $00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2337
    .byte                                    $3E, $3F, $FF
; !(UNUSED) No pointer, branch, or fall-through reaches these bytes. See DATA-002.
    .byte $4A, $4A, $4A, $4A
; Convert the low nibble in A to the corresponding score-font tile.
;
; Input: A (only bits 0..3 are significant).
; Output: A = score digit tiles $30..$39 for 0..9, or $41..$46 for A..F.
; Preserves: X, Y. Clobbers: processor flags.
sub_digit_to_score_tile:		; was: sub_E148
    AND #$0F
    CMP #$0A
    BCS bra_convert_hex_digit_tile
    ADC #con_tile_score_zero
    RTS
; Convert hex digit 0xA-0xF to tile code
bra_convert_hex_digit_tile:		; was: bra_E151
    ADC #con_tile_score_hex_adjust
    RTS
