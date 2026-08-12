; HUD text blocks, lives, fruit history, and icon helpers

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
