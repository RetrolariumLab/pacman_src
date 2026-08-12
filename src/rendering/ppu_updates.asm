; Power-pellet blinking and buffered PPU update flushing

sub_DDC9_blink_power_pellet_tiles:		; was: sub_DDC9
    LDA ram_frame_cnt
    AND #$0F
    BEQ bra_DDD0_process_blink_step
    RTS
; Run blink update every 16 frames
bra_DDD0_process_blink_step:		; was: bra_DDD0
; each 16 frames
    TAX
; Toggle next power-pellet tile ID
bra_DDD1_toggle_next_power_pellet_tile:		; was: bra_DDD1_loop
    LDA ram_power_pellet_tile_p1,X
    CMP #con_tile + $07
    BEQ bra_DDE1_store_power_pellet_tile
    CMP #con_tile + $01
    BNE bra_DDDF_set_power_pellet_visible
    LDA #con_tile + $02
    BNE bra_DDE1_store_power_pellet_tile    ; jmp
; Set power-pellet tile to visible variant
bra_DDDF_set_power_pellet_visible:		; was: bra_DDDF
    LDA #con_tile + $01
; Store updated power-pellet tile ID
bra_DDE1_store_power_pellet_tile:		; was: bra_DDE1
    STA ram_power_pellet_tile_p1,X
    INX
    CPX #$04
    BNE bra_DDD1_toggle_next_power_pellet_tile
    RTS



sub_DDE9_write_buffer_to_ppu:
    LDA ram_flag_demo
    BEQ bra_DDF0_flush_score_hud_buffers
    JMP loc_DE7E_flush_power_pellet_and_main_ppu
; Flush score/hiscore buffers to PPU
bra_DDF0_flush_score_hud_buffers:		; was: bra_DDF0
; score buffer
    LDA ram_ppu_buffer_score
    CMP #$FF
    BEQ bra_DE4A_update_1up_blink    ; skip if buffer is empty
    SetPpuAddressFrom ram_ppu_buf_score_hi
    LDY #$00
; Write score digits to PPU
bra_DE08_write_score_digits:		; was: bra_DE08_loop
    LDA ram_ppu_buffer_score,Y
    STA $2007
    INY
    CPY #$06
    BNE bra_DE08_write_score_digits
    LDA #con_tile + $30
    STA $2007
    LDA #$FF
    STA ram_ppu_buffer_score
; hiscore buffer
    LDA ram_ppu_buffer_hiscore
    CMP #$FF
    BEQ bra_DE4A_update_1up_blink    ; skip if buffer is empty
    SetPpuAddressFrom ram_ppu_buf_hiscore_hi
    LDY #$00
; Write hiscore digits to PPU
bra_DE35_write_hiscore_digits:		; was: bra_DE35_loop
    LDA ram_ppu_buffer_hiscore,Y
    STA $2007
    INY
    CPY #$06
    BNE bra_DE35_write_hiscore_digits
    LDA #con_tile + $30
    STA $2007
    LDA #$FF
    STA ram_ppu_buffer_hiscore
; Update flashing 1UP indicator
bra_DE4A_update_1up_blink:		; was: bra_DE4A
    LDA ram_frame_cnt
    AND #$07
    BNE bra_DE7E_flush_power_pellet_and_main_ppu
    SetPpuAddressFrom ram_ppu_buffer_1up
    LDX #$00
    LDA ram_frame_cnt
    AND #$18
    BEQ bra_DE74_clear_1up_text
; Write 1UP text tiles
bra_DE67_write_1up_text:		; was: bra_DE67_loop
    LDA ram_ppu_buffer_1up + $02,X
    STA $2007
    INX
    CPX #$03
    BNE bra_DE67_write_1up_text
    BEQ bra_DE7E_flush_power_pellet_and_main_ppu    ; jmp
; Clear 1UP text tiles
bra_DE74_clear_1up_text:		; was: bra_DE74
    LDA #con_tile + $20
; Write clear tiles for 1UP field
bra_DE76_write_1up_clear_tiles:		; was: bra_DE76_loop
    STA $2007
    INX
    CPX #$03
    BNE bra_DE76_write_1up_clear_tiles
; Flush power-pellet markers and generic PPU command buffer
bra_DE7E_flush_power_pellet_and_main_ppu:		; was: bra_DE7E
; Flush power-pellet markers and generic PPU command buffer
loc_DE7E_flush_power_pellet_and_main_ppu:		; was: loc_DE7E
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_DE8A_select_player_nametable
    LDY #$08
; Select nametable half based on active player
bra_DE8A_select_player_nametable:		; was: bra_DE8A
; Write current power-pellet marker tiles
bra_DE8A_write_power_pellet_markers:		; was: bra_DE8A_loop
    LDA $2002
    LDA tbl_DECF_power_pellet_ppu_addrs,Y
    STA $2006
    LDA tbl_DECF_power_pellet_ppu_addrs + $01,Y
    STA $2006
    LDA ram_power_pellet_tile_p1,X
    STA $2007
    INY
    INY
    INX
    CPX #$04
    BNE bra_DE8A_write_power_pellet_markers
    LDA $2002
    LDY #$FF
; Scan packed PPU command buffer entries
bra_DEAA_scan_ppu_command_buffer:		; was: bra_DEAA_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #$FF
    BEQ bra_DECB_finalize_ppu_command_buffer    ; skip if buffer is empty
    STA $2006
    INY
    LDA ram_ppu_buffer_main,Y
    STA $2006
; Write payload bytes of current PPU command
bra_DEBC_write_ppu_command_payload:		; was: bra_DEBC_loop
    INY
    LDA ram_ppu_buffer_main,Y
    BEQ bra_DEAA_scan_ppu_command_buffer
    CMP #$FF
    BEQ bra_DECB_finalize_ppu_command_buffer    ; skip if there isn't anything else in the buffer
    STA $2007
    BNE bra_DEBC_write_ppu_command_payload   ; jmp
; Mark PPU command buffer as consumed
bra_DECB_finalize_ppu_command_buffer:		; was: bra_DECB
    STA ram_ppu_buffer_main
    RTS



; PPU addresses for the four power-pellet marker cells
tbl_DECF_power_pellet_ppu_addrs:		; was: tbl_DECF_ppu_addr
    .dbyt $20B4 ; 00
    .dbyt $20A2 ; 02
    .dbyt $22D4 ; 04
    .dbyt $22C2 ; 06
    .dbyt $28B4 ; 08
    .dbyt $28A2 ; 0A
    .dbyt $2AD4 ; 0C
    .dbyt $2AC2 ; 0E
