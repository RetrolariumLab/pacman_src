; Round initialization, runtime parameter loading, HUD, and maze attributes

ofs_003_CE35_script00_round_init:		; was: ofs_003_CE35_00
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI before applying round init PPU writes
bra_CE39_wait_nmi:		; was: bra_CE39_infinite_loop
    LDA ram_nmi_wait
    BNE bra_CE39_wait_nmi
    LDA #$08
    STA $2000
    STA ram_for_2000
    LDA #$00
    STA $2001
    LDX #$00
; Clear runtime RAM block 0087-00EF
bra_CE4B_clear_runtime_block:		; was: bra_CE4B_loop
; 0087-00EF
    STA ram_0087,X
    INX
    CPX #$69
    BNE bra_CE4B_clear_runtime_block
    TAX
; Clear full OAM shadow
bra_CE53_clear_oam_all:		; was: bra_CE53_loop
; 0700-07FF
    STA ram_oam,X
    INX
    BNE bra_CE53_clear_oam_all
    SetPpuAddress $3F00
    LDY #$00
; Upload gameplay palette
bra_CE68_upload_round_palette:		; was: bra_CE68_loop
    LDA tbl_D060_round_gameplay_palette,Y
    STA $2007
    INY
    CPY #$20
    BNE bra_CE68_upload_round_palette
    LDA #con_script_02
    STA ram_script
    LDA ram_0069
    BNE bra_CE99_common_round_init_tail
    STA ram_008B
    LDA #con_tile + $01
    STA ram_power_pellet_tile_p1
    STA ram_power_pellet_tile_p1 + $01
    STA ram_power_pellet_tile_p1 + $02
    STA ram_power_pellet_tile_p1 + $03
    LDA #$C0
    STA ram_pellet_cnt_p1
    LDA ram_stage_p1
    CMP #$16
    BEQ bra_CE93_after_stage_increment_check
    INC ram_stage_p1
; Continue round init after stage cap/increment check
bra_CE93_after_stage_increment_check:		; was: bra_CE93
    JSR sub_D080_fill_maze_attr_tables
    JSR sub_E25C_decompress_and_upload_maze_layout
; Shared round-init tail (runs for fresh round and respawn)
bra_CE99_common_round_init_tail:		; was: bra_CE99
    JSR sub_E379_draw_score_hud_live
    JSR sub_CFFA_fill_center_strip_tiles
    JSR sub_E4CD_draw_lives_icons
    JSR sub_E53B_draw_stage_fruit_history
    JSR sub_E47C_upload_hud_text_blocks
    LDX ram_stage_p1
    LDA #$00
    CLC
; Stage-profile stream drives level behavior tables:
; speed/fright timers, dot-release thresholds, and ghost-release targets.
; Compute stage-based offset into level parameter table (step 6)
bra_CEAD_calc_stage_table_offset:		; was: bra_CEAD_loop
    DEX
    BMI bra_CEB4_stage_offset_ready
    ADC #$06
    BNE bra_CEAD_calc_stage_table_offset
; Stage table offset prepared in ram_0000
bra_CEB4_stage_offset_ready:		; was: bra_CEB4
    STA ram_0000
    TAX
    LDA tbl_EB42_stage_param_index_stream,X
    TAX
    LDA #$00
    CLC
; Convert maze/layout index into parameter block offset (step 0x16)
bra_CEBE_calc_param_block_offset:		; was: bra_CEBE_loop
    DEX
    BMI bra_CEC5_param_block_base_ready
    ADC #$16
    BNE bra_CEBE_calc_param_block_offset
; Parameter block base offset ready in Y
bra_CEC5_param_block_base_ready:		; was: bra_CEC5
    TAY
    LDX #$00
; Copy level parameter block to runtime RAM 009F..00B4
bra_CEC8_copy_level_param_block:		; was: bra_CEC8_loop
    LDA tbl_EBCC_level_param_blocks_22bytes,Y
    STA ram_009F,X
    INX
    INY
    CPX #$16
    BNE bra_CEC8_copy_level_param_block
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    ASL
    ASL
    TAX
    LDY #$00
    STY ram_00D0
    LDA tbl_EC3A_speed_timer_blocks_8bytes,X
    STA ram_00CF
; Copy 8-byte timer/speed block to runtime RAM 0097..009E
bra_CEE5_copy_timer_block:		; was: bra_CEE5_loop
    LDA tbl_EC3A_speed_timer_blocks_8bytes,X
    STA ram_0097,Y
    INX
    INY
    CPY #$08
    BNE bra_CEE5_copy_timer_block
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_008C
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    TAX
    LDA tbl_EC5A_dot_counter_threshold_pairs,X
    STA ram_008D
    INX
    LDA tbl_EC5A_dot_counter_threshold_pairs,X
    STA ram_008E
    INC ram_0000
    LDA ram_0069
    BEQ bra_CF38_load_release_targets_from_table
    LDX #$0C
    LDY #$00
    LDA tbl_EC74_release_target_special_case_quad - $0C,X
    STA ram_008F,Y
    INY
    INX
    LDA #$C0
    SEC
    SBC ram_pellet_cnt_p1
    STA ram_0001
; Adjust release target counters based on pellets already eaten
bra_CF27_adjust_release_targets_by_pellets:		; was: bra_CF27_loop
    LDA ram_0001
    CLC
    ADC tbl_EC74_release_target_special_case_quad - $0C,X
    STA ram_008F,Y
    INY
    INX
    CPY #$04
    BNE bra_CF27_adjust_release_targets_by_pellets
    BEQ bra_CF4E_init_ghost_release_state    ; jmp
; Load default release target counters from table
bra_CF38_load_release_targets_from_table:		; was: bra_CF38
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    ASL
    ASL
    TAX
    LDY #$00
; Copy 4-byte release target set to RAM 008F..0092
bra_CF42_copy_release_target_quad:		; was: bra_CF42_loop
    LDA tbl_EC68_ghost_release_target_quads,X
    STA ram_008F,Y
    INX
    INY
    CPY #$04
    BNE bra_CF42_copy_release_target_quad
; Initialize ghost release scheduler state
bra_CF4E_init_ghost_release_state:		; was: bra_CF4E
    LDA #$04
    STA ram_00B8
    LDA #$01
    STA ram_00B9
    LDA ram_008F
    STA ram_0001
    LDX #$00
; Fill active portion of release queue/state pairs
bra_CF5C_fill_release_queue_active:		; was: bra_CF5C_loop
    DEC ram_0001
    BEQ bra_CF6C_release_queue_tail_start
    LDA #$02
    STA ram_00BA,X
    LDA #$00
    STA ram_00BB,X
    INX
    INX
    BNE bra_CF5C_fill_release_queue_active
; Switch to clearing remaining release queue entries
bra_CF6C_release_queue_tail_start:		; was: bra_CF6C
    LDA #$00
; Clear remaining release queue/state pairs
bra_CF6E_clear_release_queue_tail:		; was: bra_CF6E_loop
    CPX #$06
    BEQ bra_CF7A_finalize_round_runtime
    STA ram_00BA,X
    STA ram_00BB,X
    INX
    INX
    BNE bra_CF6E_clear_release_queue_tail
; Finalize runtime fields after table copies
bra_CF7A_finalize_round_runtime:		; was: bra_CF7A
    LDA ram_0090
    STA ram_00D3
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_0093
    INC ram_0000
    LDX ram_0000
    LDA tbl_EB42_stage_param_index_stream,X
    STA ram_0096
    LDA ram_009F + $06
    STA ram_00B5
    LDA ram_009F + $07
    STA ram_00B6
    LDA ram_00AF
    STA ram_00C2 + $02
    STA ram_00C2 + $04
    STA ram_00C2 + $06
    STA ram_00CA
    LDA ram_00B0
    STA ram_00C3 + $02
    STA ram_00C3 + $04
    STA ram_00C3 + $06
    STA ram_00CB
    LDA #$01
    STA ram_direction_1
    STA ram_direction_2
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_CFBE_select_hud_packet
    LDY #$09
; Select HUD packet variant based on active player side
bra_CFBE_select_hud_packet:		; was: bra_CFBE
; Copy HUD PPU packet into RAM buffer
bra_CFBE_copy_hud_ppu_packet:		; was: bra_CFBE_loop
    LDA tbl_D04E_hud_ppu_packets_by_player,Y
    STA ram_ppu_buffer_hud,X
    INY
    INX
    CPX #$09
    BNE bra_CFBE_copy_hud_ppu_packet
    LDY #$00
; Copy default animation/sprite palette bytes
bra_CFCC_copy_anim_palette_defaults:		; was: bra_CFCC_loop
    LDA tbl_D042_round_init_anim_and_sprite_attr_defaults,Y
    STA ram_animation,Y     ; also ram_spr_pal
    INY
    CPY #$0C
    BNE bra_CFCC_copy_anim_palette_defaults
    LDY #$00
; Normalize blinking power pellet tile IDs for gameplay
bra_CFD9_normalize_power_pellet_tiles:		; was: bra_CFD9_loop
    LDA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
    CMP #con_tile + $02
    BNE bra_CFE5_next_power_pellet_slot
    LDA #con_tile + $01
    STA ram_power_pellet_tile_p1,Y  ; 006C 006D 006E 006F
; Advance to next power-pellet tile slot
bra_CFE5_next_power_pellet_slot:		; was: bra_CFE5
    INY
    CPY #$04
    BNE bra_CFD9_normalize_power_pellet_tiles
    STY ram_00C0
    LDA #$FF
    STA ram_0089
    LDA #$88
    STA $2000
    STA ram_for_2000
    JMP loc_C9DD_gameplay_mainloop_wait_nmi



; Fill a center nametable strip (spaces + separator tiles) used during round setup
sub_CFFA_fill_center_strip_tiles:		; was: sub_CFFA
    LDY #$22    ; 2256
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_D004_center_strip_addr_ready
    LDY #$2A    ; 2A56
; Center-strip base nametable address selected
bra_D004_center_strip_addr_ready:		; was: bra_D004
    STY ram_0000
    LDA #$56
    STA ram_0001
    LDA #$0A    ; counter
    STA ram_0002
; Iterate rows while filling center strip tiles
bra_D00E_fill_center_strip_rows:		; was: bra_D00E_loop
    SetPpuAddressFrom ram_0000
    LDA #$06    ; counter
    STA ram_0003
    LDA #con_tile + $20
; Write one row segment of center-strip tiles
bra_D021_fill_center_strip_row_tiles:		; was: bra_D021_loop
    STA $2007
    DEC ram_0003
    BNE bra_D021_fill_center_strip_row_tiles
    LDA #con_tile + $2D
    STA $2007
    STA $2007
    LDA ram_0001
    CLC
    ADC #< $0020
    STA ram_0001
    LDA ram_0000
    ADC #> $0020
    STA ram_0000
    DEC ram_0002
    BNE bra_D00E_fill_center_strip_rows
    RTS



; Default animation and sprite-attr bytes loaded at round start
; Default animation IDs + sprite attribute bytes copied to RAM 0032..003D
tbl_D042_round_init_anim_and_sprite_attr_defaults:		; was: tbl_D042_spr_data
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
tbl_D04E_hud_ppu_packets_by_player:		; was: tbl_D04E_ppu
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
tbl_D060_round_gameplay_palette:		; was: tbl_D060_palette
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
sub_D080_fill_maze_attr_tables:		; was: sub_D080
    SetPpuAddress $23C0
    LDX #$01
; Run two passes: first nametable $23C0, then $2BC0
bra_D08F_attr_table_pass_loop:		; was: bra_D08F
    LDY #$00
; Copy 0x40 attribute bytes to current nametable
bra_D091_copy_attr_block_loop:		; was: bra_D091_loop
    LDA tbl_D0AF_maze_attribute_bytes,Y
    STA $2007
    INY
    CPY #$40
    BNE bra_D091_copy_attr_block_loop
    DEX
    BEQ bra_D0A0_select_second_attr_table
    RTS
; Switch PPU address to second nametable attribute block
bra_D0A0_select_second_attr_table:		; was: bra_D0A0
    SetPpuAddress $2BC0
    BNE bra_D08F_attr_table_pass_loop    ; jmp



; Maze attribute byte pattern for gameplay background
tbl_D0AF_maze_attribute_bytes:		; was: tbl_D0AF_bg_attr
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $11, $00, $00, $55, $55, $55, $55, $55, $51, $50, $50
    .byte $55, $55, $55, $55, $55, $11, $05, $05, $55, $55, $55, $55, $55, $11, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
