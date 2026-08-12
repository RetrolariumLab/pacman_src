; Pellets, frightened mode, score, and extra lives




; Pellet/power-pellet detector.
; On hit: updates pellet tile state, queues PPU clear command, updates counters, may spawn fruit,
; then jumps to score accumulator flush at loc_E060_add_points_and_update_score_buffers.
sub_DEDF_check_for_eating_pellets:
    LDX #$00
    LDA ram_obj_ppu_tile_now
    CMP #con_tile + $09
    BEQ bra_DF1E_handle_any_pellet_eaten    ; if normal pellet (rare)
    INX
    INX
    CMP #con_tile + $03
    BEQ bra_DF1E_handle_any_pellet_eaten    ; if normal pellet
    CMP #con_tile + $01
    BEQ bra_DEF7_handle_power_pellet_eaten    ; if power pellet (visible)
    CMP #con_tile + $02
    BEQ bra_DEF7_handle_power_pellet_eaten    ; if power pellet (not visible)
    RTS
; Handle power-pellet eat path
bra_DEF7_handle_power_pellet_eaten:		; was: bra_DEF7
    JSR sub_DFC6_start_frightened_mode
    LDA ram_obj_pos_X_hi
    STA ram_0002
    LDA ram_obj_pos_Y_hi
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDX #$00
    LDA ram_0003
    AND #$07
    BEQ bra_DF0F_select_power_pellet_slot_by_row
    INX
    INX
; Select power-pellet slot by row parity
bra_DF0F_select_power_pellet_slot_by_row:		; was: bra_DF0F
    LDA ram_0002    ; ppu_pos_lo
    AND #$0F
    CMP #$04
    BEQ bra_DF18_mark_power_pellet_slot_eaten
    INX
; Mark matched power-pellet slot as eaten
bra_DF18_mark_power_pellet_slot_eaten:		; was: bra_DF18
    LDA #con_tile + $07
    STA ram_power_pellet_tile_p1,X
    LDX #$04
; Handle common pellet-eaten flow
bra_DF1E_handle_any_pellet_eaten:		; was: bra_DF1E
; Common tail for normal and power pellets:
; - queue one tile clear into ram_ppu_buffer_main
; - write pending score digit delta into 00DC
; - decrement pellet counter and possibly trigger stage-clear script
    LDA #$00
    STA ram_00D5
    STA ram_00D6
    LDA ram_obj_pos_X_hi
    STA ram_0002
    LDA ram_obj_pos_Y_hi
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDY #$FF
; Find end token in PPU command buffer
bra_DF31_find_ppu_buffer_end:		; was: bra_DF31_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BNE bra_DF31_find_ppu_buffer_end
    TYA
    BEQ bra_DF42_append_pellet_clear_ppu_cmd
    LDA #$00
    STA ram_ppu_buffer_main,Y
    INY
; Append pellet-clear PPU command
bra_DF42_append_pellet_clear_ppu_cmd:		; was: bra_DF42
    LDA ram_0003    ; ppu_pos_hi
    STA ram_ppu_buffer_main,Y
    INY
    LDA ram_0002    ; ppu_pos_lo
    STA ram_ppu_buffer_main,Y
    INY
    LDA tbl_DFA6_pellet_clear_tile_and_points,X
    STA ram_ppu_buffer_main,Y
    INY
    LDA #$FF
    STA ram_ppu_buffer_main,Y
    LDA #con_tile + $07
    STA ram_obj_ppu_tile_now
    LDA tbl_DFA6_pellet_clear_tile_and_points_alias + $01,X
    STA ram_00DC
    DEC ram_pellet_cnt_p1
    BNE bra_DF74_check_fruit_spawn_thresholds
    LDA #con_script_stage_clear
    STA ram_script
    LDA #$00
    STA ram_0087
    LDA #$48    ; pause timer
    STA ram_004C
; Check fruit spawn thresholds after pellet eat
bra_DF74_check_fruit_spawn_thresholds:		; was: bra_DF74
    LDA ram_pellet_cnt_p1
    CMP #$37
    BEQ bra_DF7E_spawn_fruit_item
    CMP #$86
    BNE bra_DF99_play_pellet_sfx_and_score
; Spawn fruit item and timer
bra_DF7E_spawn_fruit_item:		; was: bra_DF7E_spawn_fruit
    LDA #$0A
    STA ram_fruit_timer_hi
    LDA #$3C
    STA ram_fruit_timer_lo
    LDY ram_0093
    LDA tbl_DFBE_fruit_sprite_tile_by_stage,Y
    STA ram_animation + $05
    LDA #$03
    STA ram_spr_pal + $05
    LDA #$60
    STA ram_obj_pos_X_hi + $14
    LDA #$80
    STA ram_obj_pos_Y_hi + $14
; Play pellet SFX and commit score update
bra_DF99_play_pellet_sfx_and_score:		; was: bra_DF99_skip_fruit_spawn
    LDA ram_pellet_cnt_p1
    AND #$01
    TAY
    LDA #$01
    STA ram_sfx_eat_pellet,Y  ; 0604 0605
    JMP loc_E060_add_points_and_update_score_buffers



; Tile+points pairs for eaten pellet types
tbl_DFA6_pellet_clear_tile_and_points:		; was: tbl_DFA6_tile
; Alias label at same address for pellet tile+points pairs
tbl_DFA6_pellet_clear_tile_and_points_alias:		; was: tbl_DFA6_points
    .byte con_tile + $08, $01   ; 00 normal pellet (rare)
    .byte con_tile + $07, $01   ; 02 normal pellet
    .byte con_tile + $07, $05   ; 04 power pellet


; bzk garbage
    LDX #$00
; Legacy duplicate: find free release slot
bra_DFAE_find_free_release_slot_legacy:		; was: bra_DFAE_loop
    LDA ram_00BA,X
    BNE bra_DFB7_next_release_slot_legacy
    LDA #$02
    STA ram_00BA,X
    RTS
; Legacy duplicate: next release slot
bra_DFB7_next_release_slot_legacy:		; was: bra_DFB7
    INX
    INX
    CPX #$06
    BNE bra_DFAE_find_free_release_slot_legacy
    RTS



; Fruit sprite tile ID by stage
tbl_DFBE_fruit_sprite_tile_by_stage:		; was: tbl_DFBE_fruit_id
; bzk optimize, 24 + Y instead of this table
    .byte $24   ; 00
    .byte $25   ; 01
    .byte $26   ; 02
    .byte $27   ; 03
    .byte $28   ; 04
    .byte $29   ; 05
    .byte $2A   ; 06
    .byte $2B   ; 07



; Enter frightened mode and enqueue palette update
sub_DFC6_start_frightened_mode:		; was: sub_DFC6
    LDA ram_008C
    BNE bra_DFD0_store_frightened_timer
    LDA #$1E
    STA ram_008A
    LDA #$00
; Store frightened timer/state value
bra_DFD0_store_frightened_timer:		; was: bra_DFD0
    STA ram_0089
    LDA #$0F
    STA ram_0088
    LDX #$03
; Set ghost palettes to frightened color set
bra_DFD8_set_ghost_palette_frightened:		; was: bra_DFD8_loop
    LDA ram_spr_pal + $01,X
    AND #$FC
    ORA #$01
    STA ram_spr_pal + $01,X
    DEX
    BPL bra_DFD8_set_ghost_palette_frightened
    LDY #$FF
; Find PPU buffer end for frightened palette command
bra_DFE5_find_ppu_buffer_end_for_palette_cmd:		; was: bra_DFE5_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BNE bra_DFE5_find_ppu_buffer_end_for_palette_cmd
    LDX #$00
    TYA
    BNE bra_DFF3_adjust_palette_cmd_offset
    INX
; Adjust palette command source offset when buffer empty
bra_DFF3_adjust_palette_cmd_offset:		; was: bra_DFF3
; Append frightened palette command bytes
bra_DFF3_append_frightened_palette_cmd:		; was: bra_DFF3_loop
    LDA tbl_E05B_frightened_palette_cmd_alt,X
    STA ram_ppu_buffer_main,Y
    INY
    INX
    CMP #$FF
    BNE bra_DFF3_append_frightened_palette_cmd
    LDA #$00
    STA ram_kill_cnt
; Try to reverse ghost directions when frightened starts
sub_E003_try_reverse_ghost_directions:		; was: sub_E003
    LDX #$00
    LoadPointer ram_0000, (ram_obj_ppu_tile + $05)
    LoadPointer ram_0002, (ram_obj_pos_X_hi + $04)
    LDA #$0F
    CMP ram_0088
    BEQ bra_E01F_process_reversal_entry
    LDA ram_00D2
    BNE bra_E046_next_ghost_for_reversal
; Entry label for reversal processing of active ghost slots
bra_E01F_process_reversal_entry:		; was: bra_E01F
; Process direction reversal for active ghost slots
bra_E01F_process_reversal_for_active_ghosts:		; was: bra_E01F_loop
    LDA ram_00B8,X
    CMP #$04
    BNE bra_E046_next_ghost_for_reversal
    LDA ram_00B9,X
    CLC
    ADC #$02
    AND #$03
    STA ram_0004
    LDY #$00
    LDA (ram_0002),Y    ; 001E 0022 0026 002A
    LDY #$02
    ORA (ram_0002),Y    ; 0020 0024 0028 002C
    AND #$07
    BNE bra_E042_store_reversed_direction
    LDY ram_0004
    LDA (ram_0000),Y    ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    AND #$F8
    BNE bra_E046_next_ghost_for_reversal
; Store reversed direction for current ghost
bra_E042_store_reversed_direction:		; was: bra_E042
    LDA ram_0004
    STA ram_00B9,X
; Advance to next ghost in reversal pass
bra_E046_next_ghost_for_reversal:		; was: bra_E046
    LDA ram_0000
    CLC
    ADC #$04
    STA ram_0000
    LDA ram_0002
    CLC
    ADC #$04
    STA ram_0002
    INX
    INX
    CPX #$08
    BNE bra_E01F_process_reversal_for_active_ghosts
    RTS



; Frightened palette command bytes (alternate source)
tbl_E05B_frightened_palette_cmd_alt:		; was: tbl_E05B
    .byte $00
    .dbyt $3F15
    .byte $11
    .byte $FF   ; end token



; Add pending points and rebuild score PPU buffers
loc_E060_add_points_and_update_score_buffers:		; was: loc_E060
; Score pipeline:
; 1) add pending BCD deltas (00DC..00E1) into active score
; 2) rebuild score tile buffer (leading zero suppression)
; 3) apply 1UP threshold once (ram_006B latch) and queue life icon packet
; 4) compare/promote hiscore buffers
    LDA ram_flag_demo
    BEQ bra_E065_score_update_live_only
    RTS
; Skip score update in demo mode
bra_E065_score_update_live_only:		; was: bra_E065
    LDY #$00
    LDA #$06
    STA ram_0000
    CLC
; Add pending BCD score digits
bra_E06C_add_pending_score_digits:		; was: bra_E06C_loop
    LDA ram_score_p1,Y
    ADC ram_00DC,Y
    STA ram_score_p1,Y
    CMP #$0A
    BCC bra_E07F_clear_pending_score_digit
    SBC #$0A
    STA ram_score_p1,Y
    SEC
; Clear pending score digit accumulator
bra_E07F_clear_pending_score_digit:		; was: bra_E07F
    LDA #$00
; 00DC-00E1
    STA ram_00DC,Y
    INY
    DEC ram_0000
    BNE bra_E06C_add_pending_score_digits
    LDX #$00
    DEY
; Skip leading zeroes while formatting score
bra_E08C_skip_leading_zeroes:		; was: bra_E08C_loop
    LDA ram_score_p1,Y
    JSR sub_E148_digit_to_score_tile
    CMP #$30
    BNE bra_E0A5_store_formatted_score_digit
    LDA #$20
    STA ram_ppu_buffer_score,X
    INX
    DEY
    BNE bra_E08C_skip_leading_zeroes
; Write formatted score digits into score PPU buffer
bra_E09F_write_formatted_score_digits:		; was: bra_E09F_loop
    LDA ram_score_p1,Y
    JSR sub_E148_digit_to_score_tile
; Store one formatted score digit
bra_E0A5_store_formatted_score_digit:		; was: bra_E0A5
    STA ram_ppu_buffer_score,X
    INX
    DEY
    BPL bra_E09F_write_formatted_score_digits
    LDA ram_006B
    BNE bra_E110_compare_score_with_hiscore
    LDA #$01
    CMP ram_score_p1 + $03
    BNE bra_E110_compare_score_with_hiscore
    LDA #$01
    STA ram_006B
    STA ram_0602
    INC ram_lives_p1
    LDA ram_lives_p1
    SEC
    SBC #$02
    ASL
    STA ram_0000
    LDY #$FF
; Find end of PPU command buffer before appending extra-life icon update
bra_E0C9_find_ppu_buffer_end_for_life_icon:		; was: bra_E0C9_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BNE bra_E0C9_find_ppu_buffer_end_for_life_icon
    TYA
    BEQ bra_E0DA_select_life_icon_nametable
    LDA #$00
    STA ram_ppu_buffer_main,Y
    INY
; Select life-icon nametable segment for active player
bra_E0DA_select_life_icon_nametable:		; was: bra_E0DA
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_E0E2_init_life_icon_packet_copy
    LDA #$08
; Initialize life-icon packet copy pointers
bra_E0E2_init_life_icon_packet_copy:		; was: bra_E0E2
    STA ram_0001
    LDX #$00
; Copy life icon packet into main PPU command buffer
bra_E0E6_copy_life_icon_packet:		; was: bra_E0E6_loop
    LDA tbl_E13A_life_icon_ppu_packets,X
    CLC
    ADC ram_0001
    STA ram_ppu_buffer_main,Y
    INY
    INX
    LDA tbl_E13A_life_icon_ppu_packets,X
    CLC
    ADC ram_0000
    STA ram_ppu_buffer_main,Y
    LDA #$03
    STA ram_0002
; Copy one life-icon payload chunk
bra_E0FE_copy_life_icon_payload:		; was: bra_E0FE_loop
    INY
    INX
    LDA tbl_E13A_life_icon_ppu_packets,X
    STA ram_ppu_buffer_main,Y
    DEC ram_0002
    BNE bra_E0FE_copy_life_icon_payload
    INY
    INX
    CPX #$0A
    BNE bra_E0E6_copy_life_icon_packet
; Compare current score with hiscore
bra_E110_compare_score_with_hiscore:		; was: bra_E110
; BCD digit-wise compare from highest index down.
    LDY #$05
; Digit-wise compare loop for hiscore update
bra_E112_hiscore_compare_loop:		; was: bra_E112_loop
    LDA ram_score_hi,Y
    CMP ram_score_p1,Y
    BEQ bra_E11D_continue_hiscore_compare
    BCC bra_E121_promote_score_to_hiscore
    RTS
; Continue hiscore compare with next digit
bra_E11D_continue_hiscore_compare:		; was: bra_E11D
    DEY
    BPL bra_E112_hiscore_compare_loop
    RTS
; Promote score buffer and score RAM to hiscore
bra_E121_promote_score_to_hiscore:		; was: bra_E121
    LDX #$00
; Copy score PPU buffer into hiscore PPU buffer
bra_E123_copy_score_buf_to_hiscore_buf:		; was: bra_E123_loop
    LDA ram_ppu_buffer_score,X
    STA ram_ppu_buffer_hiscore,X
    INX
    CPX #$06
    BNE bra_E123_copy_score_buf_to_hiscore_buf
    LDX #$00
; Copy score digits into hiscore RAM
bra_E130_copy_score_ram_to_hiscore_ram:		; was: bra_E130_loop
    LDA ram_score_p1,X
    STA ram_score_hi,X
    INX
    CPX #$06
    BNE bra_E130_copy_score_ram_to_hiscore_ram
    RTS



; PPU packet template for extra-life icon updates
tbl_E13A_life_icon_ppu_packets:		; was: tbl_E13A
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2317
    .byte                                    $3C, $3D, $00
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2337
    .byte                                    $3E, $3F, $FF
; bzk garbage
    .byte $4A, $4A, $4A, $4A
; Convert BCD nibble to score tile code
sub_E148_digit_to_score_tile:		; was: sub_E148
    AND #$0F
    CMP #$0A
    BCS bra_E151_convert_hex_digit_tile
    ADC #con_tile + $30
    RTS
; Convert hex digit 0xA-0xF to tile code
bra_E151_convert_hex_digit_tile:		; was: bra_E151
    ADC #con_tile + $36
    RTS
