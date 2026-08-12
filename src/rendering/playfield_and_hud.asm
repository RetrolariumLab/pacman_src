; Tile probes, playfield, HUD, and renderer helpers




; Build current+neighbor tile probe addresses for Pac-Man and all ghosts
sub_E154_build_object_neighbor_ppu_positions:		; was: sub_E154_calculate_ppu_positions
    LDA ram_obj_pos_X_hi
    STA ram_0002
    LDA ram_obj_pos_Y_hi
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDA ram_0003    ; ppu_pos_hi
    STA ram_obj_ppu_pos_hi_now
    LDA ram_0002    ; ppu_pos_lo
    STA ram_obj_ppu_pos_lo_now
    LDX #$00
    LDY #$00
; Build per-object PPU positions for up/left/down/right neighbors
bra_E16D_build_neighbor_ppu_positions:		; was: bra_E16D_loop
    LDA ram_obj_pos_X_hi,X
    STA ram_0002
    LDA ram_obj_pos_Y_hi,X
    STA ram_0003
    JSR sub_E1DD_convert_world_pos_to_ppu_addr
    LDA #< $0020
    STA ram_0014
    LDA #> $0020
    STA ram_0015
    LDA ram_0002    ; ppu_pos_lo
    STA ram_0012    ; ppu_pos_lo_copy
    LDA ram_0003    ; ppu_pos_hi
    STA ram_0013    ; ppu_pos_hi_copy
    JSR sub_E24E_sub_row_stride_0020
    LDA ram_0013
; 0202-0222, interval 08
    STA ram_obj_ppu_pos_hi_up,Y
    LDA ram_0012    ; ppu_pos_lo_copy
    INY
; 0203-0223, interval 08
    STA ram_obj_ppu_pos_lo_up - $01,Y
    LDA ram_0003    ; ppu_pos_hi
    INY
; 0204-0224, interval 08
    STA ram_obj_ppu_pos_hi_left - $02,Y
    LDA ram_0002    ; ppu_pos_lo
    SEC
    SBC #$01
    INY
; 0205-0225, interval 08
    STA ram_obj_ppu_pos_lo_left - $03,Y
    LDA #< $0020
    STA ram_0014
    LDA #> $0020
    STA ram_0015
    LDA ram_0002    ; ppu_pos_lo
    STA ram_0012    ; ppu_pos_lo_copy
    LDA ram_0003    ; ppu_pos_hi
    STA ram_0013    ; ppu_pos_hi_copy
    JSR sub_E240_add_row_stride_0020
    LDA ram_0013
    INY
; 0206-0226, interval 08
    STA ram_obj_ppu_pos_hi_down - $04,Y
    LDA ram_0012    ; ppu_pos_lo_copy
    INY
; 0207-0227, interval 08
    STA ram_obj_ppu_pos_lo_down - $05,Y
    LDA ram_0003    ; ppu_pos_hi
    INY
; 0208-0228, interval 08
    STA ram_obj_ppu_pos_hi_right - $06,Y
    LDA ram_0002    ; ppu_pos_lo
    CLC
    ADC #$01
    INY
; 0209-0229, interval 08
    STA ram_obj_ppu_pos_lo_right - $07,Y
    INX
    INX
    INX
    INX
    INY
    CPY #$28
    BNE bra_E16D_build_neighbor_ppu_positions
    RTS



; Convert world XY position to nametable PPU address
sub_E1DD_convert_world_pos_to_ppu_addr:		; was: sub_E1DD_convert_position_to_ppu
    LDA #$00
    STA ram_0005
    LDA ram_0003    ; pos_Y_hi
    SEC
    SBC #$04
    AND #$F8
    ASL
    ROL ram_0005
    ASL
    ROL ram_0005
    CLC
    ADC #$40
    STA ram_0004
    LDA #$00
    ADC ram_0005
    STA ram_0005
    LDA ram_0002    ; pos_X_hi
    SEC
    SBC #$04
    LSR
    LSR
    LSR
    CLC
    ADC ram_0004
    STA ram_0002    ; ppu_pos_lo
    LDA ram_0005
    CLC
    ADC #$20
    STA ram_0003    ; ppu_pos_hi
    LDA ram_current_player
    AND ram_game_mode
    BNE bra_E214_apply_player2_nametable_offset
    RTS
; Apply +$0800 nametable offset for player 2
bra_E214_apply_player2_nametable_offset:		; was: bra_E214
; add 0800 to ppu for 2nd player
    LDA ram_0003    ; ppu_pos_hi
    CLC
    ADC #$08
    STA ram_0003    ; ppu_pos_hi
    RTS



; Read tiles from PPU at cached object neighbor positions
sub_E21C_sample_tiles_at_obj_ppu_positions:		; was: sub_E21C_analyze_obj_ppu_pos
    LDX #$00
    LDY #$00
    LDA $2002
; Sample next neighbor tile from PPU
bra_E223_sample_next_obj_neighbor_tile:		; was: bra_E223_loop
    LDA ram_obj_ppu_position,X  ; 0200-0228, even
    STA $2006
    INX
    LDA ram_obj_ppu_position,X  ; 0201-0229, odd
    STA $2006
    LDA $2007
    LDA $2007
    STA ram_obj_ppu_tile,Y  ; 022A-023E
    INX
    INY
    CPX #$2A
    BNE bra_E223_sample_next_obj_neighbor_tile
    RTS



; Add one nametable row stride ($20) to PPU address copy
sub_E240_add_row_stride_0020:		; was: sub_E240_add_0020
; bzk optimize, 0014-0015 is always = $0020
    CLC
    LDA ram_0012
    ADC ram_0014
    STA ram_0012
    LDA ram_0013
    ADC ram_0015
    STA ram_0013
    RTS



; Subtract one nametable row stride ($20) from PPU address copy
sub_E24E_sub_row_stride_0020:		; was: sub_E24E_sbc_0020
; bzk optimize, 0014-0015 is always = $0020
    SEC
    LDA ram_0012
    SBC ram_0014
    STA ram_0012
    LDA ram_0013
    SBC ram_0015
    STA ram_0013
    RTS



; Decompress and upload maze layout data to nametable
sub_E25C_decompress_and_upload_maze_layout:		; was: sub_E25C
    LDA #$20    ; 2040
    STA ram_0002
    LDA #$40
    STA ram_0003
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E26E_select_maze_target_nametable
    LDA #$28    ; 2840
    STA ram_0002
; Select base nametable for maze upload by active player
bra_E26E_select_maze_target_nametable:		; was: bra_E26E
    LDA tbl_FFF8_maze_rle_stream_ptr + $01
    STA ram_0001
    LDA tbl_FFF8_maze_rle_stream_ptr
    STA ram_0000
    LDX #$1B
    LDY #$00
; Upload next compressed maze row
bra_E27C_upload_next_maze_row:		; was: bra_E27C_loop
    LDA $2002
    LDA ram_0002
    STA $2006
    LDA ram_0003
    STA $2006
    LDA #$16
    STA ram_0004
; Decode next RLE token from maze stream
bra_E28D_decode_next_maze_rle_token:		; was: bra_E28D_loop
    LDA #$00
    STA ram_0005
    LDA (ram_0000),Y    ; data from 0x002C88
    ASL
    ROL ram_0005
    ASL
    ROL ram_0005
    LDA (ram_0000),Y    ; data from 0x002C88
    AND #$3F
; Write decoded RLE run to PPU
bra_E29D_write_maze_rle_run:		; was: bra_E29D_loop
    STA $2007
    DEC ram_0004
    DEC ram_0005
    BPL bra_E29D_write_maze_rle_run
    INY
    BNE bra_E2AB_continue_maze_row_decode
    INC ram_0001
; Continue decoding current maze row
bra_E2AB_continue_maze_row_decode:		; was: bra_E2AB
    LDA ram_0004
    BNE bra_E28D_decode_next_maze_rle_token
    LDA ram_0003
    CLC
    ADC #< $0020
    STA ram_0003
    LDA ram_0002
    ADC #> $0020
    STA ram_0002
    DEX
    BNE bra_E27C_upload_next_maze_row
    LDY #$02
    LDA #$21    ; 21D6
    STA ram_0000
    LDA #$D6
    STA ram_0001
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E2D3_select_bottom_banner_nametable
    LDA #$29    ; 29D6
    STA ram_0000
; Select bottom banner nametable by active player
bra_E2D3_select_bottom_banner_nametable:		; was: bra_E2D3
; Fill bottom banner rows with pattern tiles
bra_E2D3_fill_bottom_banner_rows:		; was: bra_E2D3_loop
    LDX #$07
    LDA $2002
    LDA ram_0000
    STA $2006
    LDA ram_0001
    STA $2006
    LDA tbl_E2FC_bottom_banner_fill_tiles,Y
; Write one bottom banner row
bra_E2E5_write_bottom_banner_row:		; was: bra_E2E5_loop
    STA $2007
    DEX
    BPL bra_E2E5_write_bottom_banner_row
    LDA ram_0001
    CLC
    ADC #< $0020
    STA ram_0001
    LDA #> $0020
    ADC ram_0000
    STA ram_0000
    DEY
    BPL bra_E2D3_fill_bottom_banner_rows
    RTS



; Fill tiles used for bottom banner rows
tbl_E2FC_bottom_banner_fill_tiles:		; was: tbl_E2FC
; fill ppu with this byte
    .byte con_tile + $2D   ; 00
    .byte con_tile + $04   ; 01
    .byte con_tile + $2D   ; 02



; Clear both nametables and attribute blocks with blank tile
sub_E2FF_clear_bg_nametables_and_attrs:		; was: sub_E2FF
    LDA $2002
    LDA #> $2000
    STA $2006
    LDA #< $2000
    STA $2006
    LDA #$01
    STA ram_0002
; One nametable tile-fill pass in clear routine
loc_E310_clear_nametable_fill_pass:		; was: loc_E310
    LDA #$01
    STA ram_0003
    LDA #$03
    STA ram_0000
    LDA #$C0
    STA ram_0001
    LDA #con_tile + $2D
bra_E31E_loop:
    STA $2007
    DEC ram_0001
    BNE bra_E31E_loop
    DEC ram_0000
    BPL bra_E31E_loop
    DEC ram_0003
    BNE bra_E335_select_next_nametable_phase
    LDA #$40
    STA ram_0001
    LDA #$00
    BEQ bra_E31E_loop    ; jmp
; Select next nametable/phase in clear routine
bra_E335_select_next_nametable_phase:		; was: bra_E335
    DEC ram_0002
    BNE bra_E349_clear_attribute_blocks_phase
    LDA $2002
    LDA #> $2800
    STA $2006
    LDA #< $2800
    STA $2006
    JMP loc_E310_clear_nametable_fill_pass
; Clear attribute blocks after nametable fill
bra_E349_clear_attribute_blocks_phase:		; was: bra_E349
    LDA #$01
    STA ram_0000
    LDA $2002
    LDA #> $23C0
    STA $2006
    LDA #< $23C0
    STA $2006
bra_E35A_loop:
    LDA #$00
    TAY
bra_E35D_loop:
    STA $2007
    INY
    CPY #$20
    BNE bra_E35D_loop
    DEC ram_0000
    BNE bra_E36A_select_second_attr_block
    RTS
; Switch to second attribute block during clear
bra_E36A_select_second_attr_block:		; was: bra_E36A
    LDA $2002
    LDA #> $2BC0
    STA $2006
    LDA #< $2BC0
    STA $2006
    BNE bra_E35A_loop   ; jmp



; Draw score/hiscore HUD rows for live gameplay layout
sub_E379_draw_score_hud_live:		; was: sub_E379
    LDA #$20
    STA ram_0000
    LDA #$B6
    STA ram_0001
    LDA #$80
    STA ram_0004
    LDX #$00
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E3A5_select_score_addr_triplet
    LDA #$28
    STA ram_0000
    BNE bra_E3A5_select_score_addr_triplet    ; jmp



; Draw score/hiscore HUD rows for dual-player/title layout
sub_E393_draw_score_hud_dual:		; was: sub_E393
    LDA #$20
    STA ram_0000
    LDA #$83
    STA ram_0001
    LDA #$09
    STA ram_0004
    LDA #$01
    STA ram_game_mode
    LDX #$0C
; Select score-address triplet based on mode/player
bra_E3A5_select_score_addr_triplet:		; was: bra_E3A5
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E3B0_init_hud_row_counter
    TXA
    CLC
    ADC #$06
    TAX
; Initialize HUD row draw counter
bra_E3B0_init_hud_row_counter:		; was: bra_E3B0
    LDA #$03
    STA ram_0005
; Draw next HUD row packet
bra_E3B4_draw_next_hud_row:		; was: bra_E3B4_loop
    LDA $2002
    LDA ram_0000
    STA $2006
    LDA ram_0001
    STA $2006
    LDA tbl_E419_score_source_triplets,X
    STA ram_0002
    LDA tbl_E419_score_source_triplets + $01,X
    STA ram_0003
    JSR sub_E3EE_write_6digit_score_to_ppu
    INX
    INX
    LDA ram_0001
    CLC
    ADC ram_0004
    STA ram_0001
    LDA #$00
    ADC ram_0000
    STA ram_0000
    DEC ram_0005
    LDA ram_0005
    CMP #$01
    BNE bra_E3E9_continue_hud_row_loop
    LDA ram_game_mode
    BEQ bra_E3ED_return
; Continue HUD row loop unless done
bra_E3E9_continue_hud_row_loop:		; was: bra_E3E9
    LDA ram_0005
    BNE bra_E3B4_draw_next_hud_row
; Return from HUD row draw routine
bra_E3ED_return:		; was: bra_E3ED_RTS
    RTS



; Write one 6-digit score value to PPU with leading-space suppression
sub_E3EE_write_6digit_score_to_ppu:		; was: sub_E3EE
    LDY #$05
; Skip leading zeros while writing score digits
bra_E3F0_skip_leading_zeros_in_score:		; was: bra_E3F0_loop
    LDA (ram_0002),Y    ; 0064 0065 0066 0071 0072 0073 0074 0075 0081 0082 0083 0084 0085
    AND #$0F
    BNE bra_E402_emit_score_digit_tile
    LDA #con_tile + $20
    STA $2007
    DEY
    BNE bra_E3F0_skip_leading_zeros_in_score
    BEQ bra_E40B_write_last_digit_and_suffix    ; jmp
; Write remaining score digits
bra_E400_write_remaining_score_digits:		; was: bra_E400_loop
    LDA (ram_0002),Y    ; 0062 0063 0064 0071 0072 0073 0081 0082
; Emit one score digit tile
bra_E402_emit_score_digit_tile:		; was: bra_E402
    JSR sub_E148_digit_to_score_tile
    STA $2007
    DEY
    BNE bra_E400_write_remaining_score_digits
; Write least-significant digit and trailing zero tile
bra_E40B_write_last_digit_and_suffix:		; was: bra_E40B
; Y = 00
    LDA (ram_0002),Y    ; 0061 0070 0080
    JSR sub_E148_digit_to_score_tile
    STA $2007
    LDA #con_tile + $30
    STA $2007
    RTS



; Source RAM triplets (hiscore/p1/p2 order) for HUD draw
tbl_E419_score_source_triplets:		; was: tbl_E419_score_addr
; 00
    .word ram_score_hi
    .word ram_score_p1
    .word ram_score_p2
; 06
    .word ram_score_hi
    .word ram_score_p2
    .word ram_score_p1
; 0C
    .word ram_score_p1
    .word ram_score_hi
    .word ram_score_p2



; Collect valid turn candidates from tile neighborhood
sub_E42B_collect_valid_turn_candidates:		; was: sub_E42B
    LDY #$FF
    STY ram_000C
    STY ram_000D
    STY ram_000E
    STY ram_000F
    INY ; 00
; Scan neighbor tiles for passable candidates
bra_E436_scan_neighbor_tiles:		; was: bra_E436_loop
    LDA (ram_0000),Y    ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    CMP ram_000A
    BEQ bra_E444_store_candidate_direction
    AND #$F8
    BEQ bra_E444_store_candidate_direction
    CMP ram_000B
    BNE bra_E448_next_neighbor_tile
; Store candidate direction index
bra_E444_store_candidate_direction:		; was: bra_E444
    TYA
    STA ram_000C,Y
; Advance to next neighbor tile
bra_E448_next_neighbor_tile:		; was: bra_E448
    INY
    CPY #$04
    BNE bra_E436_scan_neighbor_tiles
    LDA ram_00B9,X
    CLC
    ADC #$02
    AND #$03
    TAY
    LDA #$FF
    STA ram_000C,Y
    LDA #$03
    STA ram_000B
; Compact candidate list removing blocked/reverse entries
bra_E45E_compact_candidate_list:		; was: bra_E45E_loop
    LDY #$00
; Shift candidate entries left during compaction
bra_E460_shift_candidate_entry:		; was: bra_E460_loop
    LDA ram_000C,Y
    CMP #$FF
    BNE bra_E472_next_compaction_index
    LDA ram_000D,Y
    STA ram_000C,Y
    LDA #$FF
    STA ram_000D,Y
; Advance compaction index
bra_E472_next_compaction_index:		; was: bra_E472
    INY
    CPY #$03
    BNE bra_E460_shift_candidate_entry
    DEC ram_000B
    BNE bra_E45E_compact_candidate_list
    RTS



; Upload fixed HUD text blocks (READY/1UP/2UP labels etc.)
sub_E47C_upload_hud_text_blocks:		; was: sub_E47C
    LDX #$01
; Process next HUD block page
bra_E47E_next_hud_block_page:		; was: bra_E47E_loop
    LDY #$00
; Stream one HUD block packet to PPU
bra_E480_stream_hud_block_packet:		; was: bra_E480_loop
    LDA tbl_E4B6_hud_block_packets,Y
    CPX #$00
    BNE bra_E489_write_hud_block_addr_hi
    ADC #$07
; Write HUD block PPU high address
bra_E489_write_hud_block_addr_hi:		; was: bra_E489
    STA $2006
    INY
    LDA tbl_E4B6_hud_block_packets,Y
    STA $2006
    INY
    LDA tbl_E4B6_hud_block_packets,Y
    STA ram_0000
; Write HUD block payload bytes
bra_E499_write_hud_block_payload:		; was: bra_E499_loop
    INY
    LDA tbl_E4B6_hud_block_packets,Y
    STA $2007
    DEC ram_0000
    BNE bra_E499_write_hud_block_payload
    INY
    CPY #$11
    BNE bra_E4AE_continue_hud_block_stream
    LDA ram_game_mode
    BNE bra_E4AE_continue_hud_block_stream
    RTS
; Continue HUD block stream
bra_E4AE_continue_hud_block_stream:		; was: bra_E4AE
    CPY #$17
    BNE bra_E480_stream_hud_block_packet
    DEX
    BEQ bra_E47E_next_hud_block_page
    RTS



; Packed HUD block packets for PPU upload
tbl_E4B6_hud_block_packets:		; was: tbl_E4B6
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2076
    .byte $08   ; counter
    .byte                               $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $20F7
    .byte $03   ; counter
    .byte                                    $B0, $B3, $B2
;                                              00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
    .dbyt $2177
    .byte $03   ; counter
    .byte                                    $B1, $B3, $B2
; Draw remaining lives icons in maze HUD
sub_E4CD_draw_lives_icons:		; was: sub_E4CD
    LDA ram_lives_p1
    BNE bra_E4D2_prepare_lives_draw
    RTS
; Prepare clamped lives count for icon draw
bra_E4D2_prepare_lives_draw:		; was: bra_E4D2
    CLC
    ADC #$01
    CMP #$07
    BCC bra_E4DB_init_life_icon_write_state
    LDA #$07
; Initialize life-icon write state
bra_E4DB_init_life_icon_write_state:		; was: bra_E4DB
    STA ram_0002
    LDA #$04
    STA ram_0003
    LDA #$23
    STA ram_0000
    LDA #$17
    STA ram_0001
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_E4F6_next_life_icon_slot
    LDA ram_0000
    CLC
    ADC #$08
    STA ram_0000
; Advance to next life icon slot
bra_E4F6_next_life_icon_slot:		; was: bra_E4F6
    DEC ram_0002
    BNE bra_E4FB_next_life_icon_row
    RTS
; Advance to next life icon row
bra_E4FB_next_life_icon_row:		; was: bra_E4FB
    DEC ram_0003
    BNE bra_E506_write_life_icon_quad
    LDA ram_0001
    CLC
    ADC #$3A
    STA ram_0001
; Write one life icon quad to PPU
bra_E506_write_life_icon_quad:		; was: bra_E506
    LDY #$3C
    JSR sub_E514_write_icon_quad_to_ppu
    LDA ram_0001
    CLC
    ADC #$02
    STA ram_0001
    BNE bra_E4F6_next_life_icon_slot    ; jmp



; Write 2x2 icon quad at current PPU position
sub_E514_write_icon_quad_to_ppu:		; was: sub_E514
    LDA ram_0000
    STA $2006
    LDA ram_0001
    STA $2006
    STY $2007
    INY
    STY $2007
    LDA ram_0000
    STA $2006
    LDA ram_0001
    CLC
    ADC #$20
    STA $2006
    INY
    STY $2007
    INY
    STY $2007
    RTS



; Draw stage fruit history icons and related mask data
sub_E53B_draw_stage_fruit_history:		; was: sub_E53B
    LDA #$00
    STA ram_0003
    STA ram_000E
    STA ram_000F
    LDA #$15
    STA ram_000A
    LDA #$11
    STA ram_000D
    LDA #$05
    STA ram_000B
    STA ram_000C
    LDA ram_stage_p1
    STA ram_0002
    SEC
    SBC #$07
    BCC bra_E567_stage_history_base_index_zero
    CMP #$0C
    BCC bra_E560_clamp_stage_history_index
    LDA #$0C
; Clamp stage history index to table range
bra_E560_clamp_stage_history_index:		; was: bra_E560
    TAX
    LDA #$07
    STA ram_0002
    BNE bra_E569_init_fruit_history_ppu_base    ; jmp
; Use base index for early stages
bra_E567_stage_history_base_index_zero:		; was: bra_E567
    LDX #$00
; Initialize fruit history PPU base address
bra_E569_init_fruit_history_ppu_base:		; was: bra_E569
    LDA #$22
    STA ram_0000
    LDA #$56
    STA ram_0001
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_E57E_apply_player2_fruit_history_offset
    LDA ram_0000
    CLC
    ADC #$08
    STA ram_0000
; Apply nametable offset for player 2 fruit history
bra_E57E_apply_player2_fruit_history_offset:		; was: bra_E57E
    LDA #$05
    STA ram_0004
; Loop over fruit history icon slots
bra_E582_draw_next_fruit_history_icon:		; was: bra_E582_loop
    DEC ram_0004
    BNE bra_E58D_select_fruit_icon_tile
    LDA ram_0001
    CLC
    ADC #$38
    STA ram_0001
; Select fruit icon tile ID from stage LUT
bra_E58D_select_fruit_icon_tile:		; was: bra_E58D
    LDA tbl_E619_stage_to_fruit_icon_index,X
    STA ram_0005
    ASL
    ASL
    ADC #$60
    TAY
    JSR sub_E514_write_icon_quad_to_ppu
    LDY ram_0003
    LDA tbl_E62D_history_mask_offsets,Y
    STA ram_0006
    LDA tbl_E62D_history_mask_offsets + $01,Y
    STA ram_0007
    LDY ram_0005
    LDA tbl_E63D_history_mask_seed_bits,Y
; Build bitmask for fruit history rows
bra_E5AB_build_history_mask_bits:		; was: bra_E5AB_loop
    DEC ram_0007
    BMI bra_E5B3_accumulate_history_mask
    ASL
    ASL
    BCC bra_E5AB_build_history_mask_bits
; Accumulate built mask into history buffer
bra_E5B3_accumulate_history_mask:		; was: bra_E5B3
    LDY ram_0006
    ORA ram_buffer_000A,Y
    STA ram_buffer_000A,Y
    LDA ram_0001
    CLC
    ADC #$02
    STA ram_0001
    INC ram_0003
    INC ram_0003
    INX
    DEC ram_0002
    BPL bra_E582_draw_next_fruit_history_icon
    LDX #$23    ; 23E5
    LDA ram_game_mode
    AND ram_current_player
    BEQ bra_E5D5_init_history_mask_upload
    LDX #$2B    ; 2BE5
; Initialize PPU upload for fruit history mask
bra_E5D5_init_history_mask_upload:		; was: bra_E5D5
    STX $2006
    STX ram_0000
    LDA #$E5
    STA $2006
    LDX #$00
; Process next history mask row
bra_E5E1_next_history_mask_row:		; was: bra_E5E1_loop
    LDA #$03
    STA ram_0001
; Upload history mask bytes to PPU
bra_E5E5_upload_history_mask_bytes:		; was: bra_E5E5_loop
    LDA ram_buffer_000A,X
    STA $2007
    INX
    DEC ram_0001
    BNE bra_E5E5_upload_history_mask_bytes
    INC ram_0002
    BNE bra_E5FF_upload_fruit_palette_color
; 23ED or 2BED
    LDA ram_0000
    STA $2006
    LDA #$ED
    STA $2006
    BNE bra_E5E1_next_history_mask_row   ; jmp
; Upload stage fruit color into palette slot
bra_E5FF_upload_fruit_palette_color:		; was: bra_E5FF
    LDA #> $3F1D
    STA $2006
    LDA #< $3F1D
    STA $2006
    LDA ram_stage_p1
    CMP #$10
    BCC bra_E611_clamp_fruit_color_index
    LDA #$0F
; Clamp fruit color index by stage
bra_E611_clamp_fruit_color_index:		; was: bra_E611
    TAY
    LDA tbl_E645_stage_fruit_palette_color,Y
    STA $2007
    RTS



; Map stage to fruit icon index
tbl_E619_stage_to_fruit_icon_index:		; was: tbl_E619
    .byte $00   ; 00
    .byte $01   ; 01
    .byte $02   ; 02
    .byte $02   ; 03
    .byte $03   ; 04
    .byte $03   ; 05
    .byte $04   ; 06
    .byte $04   ; 07
    .byte $05   ; 08
    .byte $05   ; 09
    .byte $06   ; 0A
    .byte $06   ; 0B
    .byte $07   ; 0C
    .byte $07   ; 0D
    .byte $07   ; 0E
    .byte $07   ; 0F
    .byte $07   ; 10
    .byte $07   ; 11
    .byte $07   ; 12
    .byte $07   ; 13



; Offsets and counts for fruit history mask composition
tbl_E62D_history_mask_offsets:		; was: tbl_E62D
    .byte $00, $03   ; 00
    .byte $01, $02   ; 02
    .byte $01, $03   ; 04
    .byte $02, $02   ; 06
    .byte $03, $01   ; 08
    .byte $04, $00   ; 0A
    .byte $04, $01   ; 0C
    .byte $05, $00   ; 0E



; Seed bits for fruit history mask builder
tbl_E63D_history_mask_seed_bits:		; was: tbl_E63D
    .byte $02   ; 00
    .byte $02   ; 01
    .byte $02   ; 02
    .byte $02   ; 03
    .byte $03   ; 04
    .byte $03   ; 05
    .byte $03   ; 06
    .byte $03   ; 07



; Fruit palette color by stage
tbl_E645_stage_fruit_palette_color:		; was: tbl_E645_fruit_color
    .byte $16   ; 00
    .byte $16   ; 01
    .byte $26   ; 02
    .byte $26   ; 03
    .byte $06   ; 04
    .byte $06   ; 05
    .byte $19   ; 06
    .byte $19   ; 07
    .byte $17   ; 08
    .byte $17   ; 09
    .byte $17   ; 0A
    .byte $17   ; 0B
    .byte $12   ; 0C
    .byte $12   ; 0D
    .byte $12   ; 0E
    .byte $12   ; 0F
