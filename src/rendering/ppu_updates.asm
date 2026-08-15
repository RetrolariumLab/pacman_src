; Power-pellet blinking and buffered PPU update flushing

sub_blink_power_pellet_tiles:		; was: sub_DDC9
    LDA ram_frame_cnt
    AND #$0F
    BEQ bra_process_blink_step
    RTS
; Run blink update every 16 frames
bra_process_blink_step:		; was: bra_DDD0
; each 16 frames
    TAX
; Toggle next power-pellet tile ID
bra_toggle_next_power_pellet_tile:		; was: bra_DDD1_loop
    LDA ram_power_pellet_tile_p1,X
    CMP #con_tile_floor
    BEQ bra_store_power_pellet_tile
    CMP #con_tile_power_pellet_visible
    BNE bra_set_power_pellet_visible
    LDA #con_tile_power_pellet_hidden
    BNE bra_store_power_pellet_tile    ; jmp
; Set power-pellet tile to visible variant
bra_set_power_pellet_visible:		; was: bra_DDDF
    LDA #con_tile_power_pellet_visible
; Store updated power-pellet tile ID
bra_store_power_pellet_tile:		; was: bra_DDE1
    STA ram_power_pellet_tile_p1,X
    INX
    CPX #$04
    BNE bra_toggle_next_power_pellet_tile
    RTS

sub_write_buffer_to_ppu:
    LDA ram_flag_demo
    BEQ bra_flush_score_hud_buffers
    JMP loc_flush_power_pellet_and_main_ppu
; Flush score/hiscore buffers to PPU
bra_flush_score_hud_buffers:		; was: bra_DDF0
; score buffer
    LDA ram_ppu_buffer_score
    CMP #con_ppu_buffer_end
    BEQ bra_update_1up_blink    ; skip if buffer is empty
    SetPpuAddressFrom ram_ppu_buf_score_hi
    LDY #$00
; Write score digits to PPU
bra_write_score_digits:		; was: bra_DE08_loop
    LDA ram_ppu_buffer_score,Y
    STA PPUDATA
    INY
    CPY #con_score_field_size
    BNE bra_write_score_digits
    LDA #con_tile_score_zero
    STA PPUDATA
    LDA #con_ppu_buffer_end
    STA ram_ppu_buffer_score
; hiscore buffer
    LDA ram_ppu_buffer_hiscore
    CMP #con_ppu_buffer_end
    BEQ bra_update_1up_blink    ; skip if buffer is empty
    SetPpuAddressFrom ram_ppu_buf_hiscore_hi
    LDY #$00
; Write hiscore digits to PPU
bra_write_hiscore_digits:		; was: bra_DE35_loop
    LDA ram_ppu_buffer_hiscore,Y
    STA PPUDATA
    INY
    CPY #con_score_field_size
    BNE bra_write_hiscore_digits
    LDA #con_tile_score_zero
    STA PPUDATA
    LDA #con_ppu_buffer_end
    STA ram_ppu_buffer_hiscore
; Update flashing 1UP indicator
bra_update_1up_blink:		; was: bra_DE4A
    LDA ram_frame_cnt
    AND #$07
    BNE bra_flush_power_pellet_and_main_ppu
    SetPpuAddressFrom ram_ppu_buffer_1up
    LDX #$00
    LDA ram_frame_cnt
    AND #$18
    BEQ bra_clear_1up_text
; Write 1UP text tiles
bra_write_1up_text:		; was: bra_DE67_loop
    LDA ram_ppu_buffer_1up + con_ppu_command_address_size,X
    STA PPUDATA
    INX
    CPX #con_1up_field_size
    BNE bra_write_1up_text
    BEQ bra_flush_power_pellet_and_main_ppu    ; jmp
; Clear 1UP text tiles
bra_clear_1up_text:		; was: bra_DE74
    LDA #con_tile_space
; Write clear tiles for 1UP field
bra_write_1up_clear_tiles:		; was: bra_DE76_loop
    STA PPUDATA
    INX
    CPX #con_1up_field_size
    BNE bra_write_1up_clear_tiles
; Flush power-pellet markers and generic PPU command buffer
bra_flush_power_pellet_and_main_ppu:		; was: bra_DE7E
; Flush power-pellet markers and generic PPU command buffer
loc_flush_power_pellet_and_main_ppu:		; was: loc_DE7E
    LDY #$00
    LDX #$00
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_select_player_nametable
    LDY #$08
; Select nametable half based on active player
bra_select_player_nametable:		; was: bra_DE8A
; Write current power-pellet marker tiles
bra_write_power_pellet_markers:		; was: bra_DE8A_loop
    LDA PPUSTATUS
    LDA tbl_power_pellet_ppu_addrs,Y
    STA PPUADDR
    LDA tbl_power_pellet_ppu_addrs + $01,Y
    STA PPUADDR
    LDA ram_power_pellet_tile_p1,X
    STA PPUDATA
    INY
    INY
    INX
    CPX #$04
    BNE bra_write_power_pellet_markers
    LDA PPUSTATUS
    LDY #$FF
; Scan [address hi][address lo][payload...][00] commands until FF.
bra_scan_ppu_command_buffer:		; was: bra_DEAA_loop
    INY
    LDA ram_ppu_buffer_main,Y
    CMP #con_ppu_buffer_end
    BEQ bra_finalize_ppu_command_buffer    ; skip if buffer is empty
    STA PPUADDR
    INY
    LDA ram_ppu_buffer_main,Y
    STA PPUADDR
; Write payload bytes of current PPU command
bra_write_ppu_command_payload:		; was: bra_DEBC_loop
    INY
    LDA ram_ppu_buffer_main,Y
    BEQ bra_scan_ppu_command_buffer ; con_ppu_command_end
    CMP #con_ppu_buffer_end
    BEQ bra_finalize_ppu_command_buffer    ; skip if there isn't anything else in the buffer
    STA PPUDATA
    BNE bra_write_ppu_command_payload   ; jmp
; Mark PPU command buffer as consumed
bra_finalize_ppu_command_buffer:		; was: bra_DECB
    STA ram_ppu_buffer_main
    RTS

; PPU addresses for the four power-pellet marker cells
tbl_power_pellet_ppu_addrs:		; was: tbl_DECF_ppu_addr
    .dbyt $20B4 ; 00
    .dbyt $20A2 ; 02
    .dbyt $22D4 ; 04
    .dbyt $22C2 ; 06
    .dbyt $28B4 ; 08
    .dbyt $28A2 ; 0A
    .dbyt $2AD4 ; 0C
    .dbyt $2AC2 ; 0E
