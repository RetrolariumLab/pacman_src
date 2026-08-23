; Round initialization, runtime parameter loading, HUD, and maze attributes
;
; handler_script00_round_init initializes a fresh stage or rebuilds runtime
; state after death/handoff. Input: restart flag, active player state, and stage.
; Side effects: clears runtime/OAM state, loads stage records, rebuilds maze/HUD
; as needed, and selects con_game_script_round_ready via the gameplay NMI loop.

handler_script00_round_init:		; was: ofs_003_CE35_00
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI before applying round init PPU writes
bra_wait_nmi:		; was: bra_CE39_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi
    LDA #PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    LDA #$00
    STA PPUMASK
    LDX #$00
; Clear runtime RAM block 0087-00EF
bra_clear_runtime_block:		; was: bra_CE4B_loop
; 0087-00EF
    STA ram_shared_state_0,X
    INX
    CPX #$69
    BNE bra_clear_runtime_block
    TAX
; Clear full OAM shadow
bra_clear_oam_all:		; was: bra_CE53_loop
; 0700-07FF
    STA ram_oam,X
    INX
    BNE bra_clear_oam_all
    SetPpuAddress $3F00
    LDY #$00
; Upload gameplay palette
bra_upload_round_palette:		; was: bra_CE68_loop
.ifdef PACMAN_EXPANDED_PALETTES
    LDA tbl_expanded_round_gameplay_palette,Y
.else
    LDA tbl_round_gameplay_palette,Y
.endif
    STA PPUDATA
    INY
    CPY #$20
    BNE bra_upload_round_palette
    LDA #con_game_script_round_ready
    STA ram_script
    LDA ram_round_restart_flag
    BNE bra_common_round_init_tail
    STA ram_fruit_eaten_latch
    LDA #con_tile_power_pellet_visible
    STA ram_power_pellet_tile_p1
    STA ram_power_pellet_tile_p1 + $01
    STA ram_power_pellet_tile_p1 + $02
    STA ram_power_pellet_tile_p1 + $03
    LDA #$C0
    STA ram_pellet_cnt_p1
    LDA ram_stage_p1
    CMP #$16
    BEQ bra_after_stage_increment_check
    INC ram_stage_p1
; Continue round init after stage cap/increment check
bra_after_stage_increment_check:		; was: bra_CE93
    JSR sub_fill_maze_attr_tables
    JSR sub_decompress_and_upload_maze_layout
; Shared round-init tail (runs for fresh round and respawn)
bra_common_round_init_tail:		; was: bra_CE99
    JSR sub_draw_score_hud_live
    JSR sub_fill_center_strip_tiles
    JSR sub_draw_lives_icons
    JSR sub_draw_stage_fruit_history
    JSR sub_upload_hud_text_blocks
    LDX ram_stage_p1
    LDA #$00
    CLC
; Stage-profile stream drives level behavior tables:
; speed/fright timers, dot-release thresholds, and ghost-release targets.
; Compute stage-based offset into level parameter table (step 6)
bra_calc_stage_table_offset:		; was: bra_CEAD_loop
    DEX
    BMI bra_stage_offset_ready
    ADC #con_stage_profile_record_size
    BNE bra_calc_stage_table_offset
; Stage table offset prepared in zp_work0
bra_stage_offset_ready:		; was: bra_CEB4
    STA zp_work0
    TAX
    LDA off_active_stage_profiles,X
    TAX
    LDA #$00
    CLC
; Convert maze/layout index into parameter block offset (step 0x16)
bra_calc_param_block_offset:		; was: bra_CEBE_loop
    DEX
    BMI bra_param_block_base_ready
    ADC #con_level_parameter_block_size
    BNE bra_calc_param_block_offset
; Parameter block base offset ready in Y
bra_param_block_base_ready:		; was: bra_CEC5
    TAY
    LDX #$00
; Copy level parameter block to runtime RAM 009F..00B4
bra_copy_level_param_block:		; was: bra_CEC8_loop
    LDA off_active_level_parameter_blocks,Y
    STA ram_level_parameters,X
    INX
    INY
    CPX #con_level_parameter_block_size
    BNE bra_copy_level_param_block
    LDX zp_work0
    LDA off_active_stage_profiles,X
    ASL
    ASL
    ASL
    TAX
    LDY #$00
    STY ram_scatter_chase_phase
    LDA off_active_speed_timer_blocks,X
    STA ram_scatter_chase_timer
; Copy 8-byte timer/speed block to runtime RAM 0097..009E
bra_copy_timer_block:		; was: bra_CEE5_loop
    LDA off_active_speed_timer_blocks,X
    STA ram_scatter_chase_durations,Y
    INX
    INY
    CPY #con_speed_timer_block_size
    BNE bra_copy_timer_block
    INC zp_work0
    LDX zp_work0
    LDA off_active_stage_profiles,X
    STA ram_frightened_duration
    INC zp_work0
    LDX zp_work0
    LDA off_active_stage_profiles,X
    ASL ; multiply index by con_dot_threshold_pair_size
    TAX
    LDA off_active_dot_threshold_pairs,X
    STA ram_personal_release_thresholds
    INX
    LDA off_active_dot_threshold_pairs,X
    STA ram_personal_release_thresholds + $01
    INC zp_work0
    LDA ram_round_restart_flag
    BEQ bra_load_release_targets_from_table
    LDX #$0C
    LDY #$00
    LDA off_active_restart_release_target - $0C,X
    STA ram_ghost_release_targets,Y
    INY
    INX
    LDA #$C0
    SEC
    SBC ram_pellet_cnt_p1
    STA zp_work1
; Adjust release target counters based on pellets already eaten
bra_adjust_release_targets_by_pellets:		; was: bra_CF27_loop
    LDA zp_work1
    CLC
    ADC off_active_restart_release_target - $0C,X
    STA ram_ghost_release_targets,Y
    INY
    INX
    CPY #con_release_target_record_size
    BNE bra_adjust_release_targets_by_pellets
    BEQ bra_init_ghost_release_state    ; jmp
; Load default release target counters from table
bra_load_release_targets_from_table:		; was: bra_CF38
    LDX zp_work0
    LDA off_active_stage_profiles,X
    ASL
    ASL ; multiply index by con_release_target_record_size
    TAX
    LDY #$00
; Copy 4-byte release target set to RAM 008F..0092
bra_copy_release_target_quad:		; was: bra_CF42_loop
    LDA off_active_ghost_release_targets,X
    STA ram_ghost_release_targets,Y
    INX
    INY
    CPY #con_release_target_record_size
    BNE bra_copy_release_target_quad
; Initialize ghost release scheduler state
bra_init_ghost_release_state:		; was: bra_CF4E
    LDA #con_ghost_state_active
    STA ram_ghost_state
    LDA #con_direction_left
    STA ram_ghost_direction
    LDA ram_ghost_release_targets
    STA zp_work1
    LDX #$00
; Fill active portion of release queue/state pairs
bra_fill_release_queue_active:		; was: bra_CF5C_loop
    DEC zp_work1
    BEQ bra_release_queue_tail_start
    LDA #con_ghost_state_exiting_house
    STA ram_ghost_state + $02,X
    LDA #$00
    STA ram_ghost_direction + $02,X
    INX
    INX
    BNE bra_fill_release_queue_active
; Switch to clearing remaining release queue entries
bra_release_queue_tail_start:		; was: bra_CF6C
    LDA #$00
; Clear remaining release queue/state pairs
bra_clear_release_queue_tail:		; was: bra_CF6E_loop
    CPX #$06
    BEQ bra_finalize_round_runtime
    STA ram_ghost_state + $02,X
    STA ram_ghost_direction + $02,X
    INX
    INX
    BNE bra_clear_release_queue_tail
; Finalize runtime fields after table copies
bra_finalize_round_runtime:		; was: bra_CF7A
    LDA ram_ghost_release_targets + $01
    STA ram_global_release_target
    INC zp_work0
    LDX zp_work0
    LDA off_active_stage_profiles,X
    STA ram_stage_param_index
    INC zp_work0
    LDX zp_work0
    LDA off_active_stage_profiles,X
    STA ram_release_interval_seconds
    LDA ram_level_parameters + $06
    STA ram_pacman_move_fraction
    LDA ram_level_parameters + $07
    STA ram_pacman_move_pixels
    LDA ram_ghost_normal_speed_fraction
    STA ram_ghost_move_fraction + $02
    STA ram_ghost_move_fraction + $04
    STA ram_ghost_move_fraction + $06
    STA ram_ghost0_current_speed_fraction
    LDA ram_ghost_normal_speed_pixels
    STA ram_ghost_move_pixels + $02
    STA ram_ghost_move_pixels + $04
    STA ram_ghost_move_pixels + $06
    STA ram_ghost0_current_speed_pixels
    LDA #con_direction_left
    STA ram_direction_1
    STA ram_direction_2
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_select_hud_packet
    LDY #$09
; Select HUD packet variant based on active player side
bra_select_hud_packet:		; was: bra_CFBE
; Copy HUD PPU packet into RAM buffer
bra_copy_hud_ppu_packet:		; was: bra_CFBE_loop
    LDA tbl_hud_ppu_packets_by_player,Y
    STA ram_ppu_buffer_hud,X
    INY
    INX
    CPX #$09
    BNE bra_copy_hud_ppu_packet
    LDY #$00
; Copy default animation/sprite palette bytes
bra_copy_anim_palette_defaults:		; was: bra_CFCC_loop
    LDA tbl_round_init_anim_and_sprite_attr_defaults,Y
    STA ram_animation,Y     ; also ram_spr_pal
    INY
    CPY #$0C
    BNE bra_copy_anim_palette_defaults
    LDY #$00
; Normalize blinking power pellet tile IDs for gameplay
bra_normalize_power_pellet_tiles:		; was: bra_CFD9_loop
    LDA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
    CMP #con_tile_power_pellet_hidden
    BNE bra_next_power_pellet_slot
    LDA #con_tile_power_pellet_visible
    STA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
; Advance to next power-pellet tile slot
bra_next_power_pellet_slot:		; was: bra_CFE5
    INY
    CPY #$04
    BNE bra_normalize_power_pellet_tiles
    STY ram_unknown_round_state
    LDA #$FF
    STA ram_shared_state_2
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    JMP loc_gameplay_mainloop_wait_nmi

; Fill a center nametable strip (spaces + separator tiles) used during round setup
sub_fill_center_strip_tiles:		; was: sub_CFFA
    LDY #$22    ; 2256
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_center_strip_addr_ready
    LDY #$2A    ; 2A56
; Center-strip base nametable address selected
bra_center_strip_addr_ready:		; was: bra_D004
    STY zp_work0
    LDA #$56
    STA zp_work1
    LDA #$0A    ; counter
    STA zp_work2
; Iterate rows while filling center strip tiles
bra_fill_center_strip_rows:		; was: bra_D00E_loop
    SetPpuAddressFrom zp_work0
    LDA #$06    ; counter
    STA zp_work3
    LDA #con_tile_space
; Write one row segment of center-strip tiles
bra_fill_center_strip_row_tiles:		; was: bra_D021_loop
    STA PPUDATA
    DEC zp_work3
    BNE bra_fill_center_strip_row_tiles
    LDA #con_tile_maze_blank
    STA PPUDATA
    STA PPUDATA
    LDA zp_work1
    CLC
    ADC #< $0020
    STA zp_work1
    LDA zp_work0
    ADC #> $0020
    STA zp_work0
    DEC zp_work2
    BNE bra_fill_center_strip_rows
    RTS

; Default animation and sprite-attr bytes loaded at round start
; Default animation IDs + sprite attribute bytes copied to RAM 0032..003D
tbl_round_init_anim_and_sprite_attr_defaults:		; was: tbl_D042_spr_data
; animation
    .byte $04   ; 00
    .byte $0C   ; 01
    .byte $0A   ; 02
    .byte $0A   ; 03
    .byte $0A   ; 04
    .byte $00   ; 05
; spr_A
    .byte $00   ; 06
    .byte $00   ; 07
    .byte $01   ; 08
    .byte $02   ; 09
    .byte $03   ; 0A
    .byte $00   ; 0B

; HUD PPU packet templates for left/right player sides
; HUD PPU packet templates for left-side (P1) and right-side (P2) layouts
tbl_hud_ppu_packets_by_player:		; was: tbl_D04E_ppu
; 00
    .dbyt $2136 ; ram_ppu_buf_score

    .dbyt $20F7 ; ram_ppu_buffer_1up
    .byte $B0, $B3, $B2   ; 1UP

    .dbyt $20B6 ; ram_ppu_buf_hiscore

; 09
    .dbyt $29B6 ; ram_ppu_buf_score

    .dbyt $2977 ; ram_ppu_buffer_1up
    .byte $B1, $B3, $B2   ; 2UP

    .dbyt $28B6 ; ram_ppu_buf_hiscore

; 32-byte gameplay palette uploaded during round init
; 32-byte gameplay palette (BG + SPR) uploaded at round initialization
tbl_round_gameplay_palette:		; was: tbl_D060_palette
; background
    .incbin "assets/generated/palettes/round.bin", $0, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $4, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $8, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $C, $4  ; rom-asset .byte
; sprites
    .incbin "assets/generated/palettes/round.bin", $10, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $14, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $18, $4  ; rom-asset .byte
    .incbin "assets/generated/palettes/round.bin", $1C, $4  ; rom-asset .byte
; Write maze attribute bytes into both gameplay nametables
sub_fill_maze_attr_tables:		; was: sub_D080
    SetPpuAddress $23C0
    LDX #$01
; Run two passes: first nametable $23C0, then $2BC0
bra_attr_table_pass_loop:		; was: bra_D08F
    LDY #$00
; Copy 0x40 attribute bytes to current nametable
bra_copy_attr_block_loop:		; was: bra_D091_loop
    LDA tbl_maze_attribute_bytes,Y
    STA PPUDATA
    INY
    CPY #$40
    BNE bra_copy_attr_block_loop
    DEX
    BEQ bra_select_second_attr_table
    RTS
; Switch PPU address to second nametable attribute block
bra_select_second_attr_table:		; was: bra_D0A0
    SetPpuAddress $2BC0
    BNE bra_attr_table_pass_loop    ; jmp

; Maze attribute byte pattern for gameplay background
tbl_maze_attribute_bytes:		; was: tbl_D0AF_bg_attr
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $51, $50, $50
    .byte $55, $55, $55, $55, $55, $11, $05, $05, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
