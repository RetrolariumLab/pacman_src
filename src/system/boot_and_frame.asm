; Boot, NMI, input, and frame bootstrap

.segment "BANK_FF"
.org $C000

; ---------------------------------------------------------------------------
; BANK_FF subsystem map (quick navigation for reverse-engineering):
; C000..C1F4  Boot/NMI/input/title-frame dispatcher
; C1F5..C989  Title + attract + chase demo pre-game flow
; C98A..D0EE  Gameplay script core + round init + HUD setup
; D0EF..D2FA  Timers/release/fruit/collision runtime
; D2FB..D4C1  Pac-Man movement and direction logic
; D4C2..D8F8  Ghost state machine, targeting, and movement
; D8F9..DEDE  Actor animation, OAM construction, and PPU buffers
; DEDF..E153  Pellets, frightened mode, score, and extra lives
; E154..E654  Tile probes, playfield, and HUD helpers
; E655..EB41  Intermission setup, runtime, and animation scripts
; EB42..EE17  Stage parameters and compressed maze data
; EE18..F0AD  Sound engine and support tables
; F0AE..F427  Generated SFX streams
; F428..FFFF  Unused tail, maze pointer, and vectors
; ---------------------------------------------------------------------------

; !(WHY?) Data preceding reset entry; determine whether it is referenced. See DATA-004.
    .byte "COPY RIGHT 1984 "
.if PACMAN_REVISION = REVISION_USA_NAMCO
    .byte "1993 NAMCO LTD. "
.else
    .byte "1980 NAMCO LTD. "
.endif
    .byte "ALL RIGHTS RESERVED"
; Hardware reset entry: disables IRQ/PPU, clears RAM, validates warm-boot signature
vec_reset_entry:		; was: vec_C033_RESET
.if PACMAN_REVISION = REVISION_USA_NAMCO
    LDX #$00
    STX PPUCTRL
    SEI
    CLD
    DEX
    TXS
    NOP
    NOP
    NOP
    LDX #$02
bra_namco_reset_vblank_pass:
    LDA #PPUMASK_SHOW_LEFT_EDGE
    STA PPUMASK
    LDA PPUSTATUS
bra_wait_namco_reset_vblank:
    LDA PPUSTATUS
    BPL bra_wait_namco_reset_vblank
    LDA #$00
    STA PPUSCROLL
    STA PPUSCROLL
    DEX
    BNE bra_namco_reset_vblank_pass
.else
    SEI
    CLD
    LDA #$00
    STA PPUCTRL
    STA PPUMASK
; Wait for first VBlank after reset before touching PPU state
bra_wait_vblank_ready:		; was: bra_C03D_loop
    LDA PPUSTATUS
    BPL bra_wait_vblank_ready
loc_reset_after_initial_vblank:
    LDX #$FF
    TXS
.endif
; clear 0000-003D
    LDA #$00
    TAY
; Clear boot-critical RAM region (0000-003D)
bra_clear_boot_workspace:		; was: bra_C048_loop
    STA zp_work0,Y
    INY
    CPY #$3E
    BNE bra_clear_boot_workspace
; A = 00
    LDX #$08
    LDY #$87
; Bulk-clear general RAM area (0087-07FF)
bra_clear_runtime_ram:		; was: bra_C054_loop
    STA (zp_work0),Y    ; 0087-07FF
    INY
    BNE bra_clear_runtime_ram
    INC zp_work1
    CPX zp_work1
    BNE bra_clear_runtime_ram
    LDA #PPUMASK_SHOW_LEFT_EDGE
    STA PPUMASK
    LDA #$00
    STA PPUSCROLL
    STA PPUSCROLL
    STA ram_scroll_X
    STA ram_scroll_Y
    STA PPUCTRL
    STA PPUMASK
    TAY
; 0052-0060
; Compare warm-boot signature at 0052-0060
bra_check_warm_boot_signature:		; was: bra_C077_loop
    LDA tbl_warm_boot_signature,Y
    CMP ram_reset_check,Y
    BNE bra_cold_boot_path
    INY
    CPY #$0F
    BNE bra_check_warm_boot_signature
    BEQ bra_boot_finalize_common    ; jmp
; Cold-boot path when signature mismatch detected
bra_cold_boot_path:		; was: bra_C086
; clear 0000-00FF
    LDA #$00
    TAY
; Cold-boot: clear full zero page
bra_clear_zero_page:		; was: bra_C089_loop
    STA zp_work0,Y
    INY
    BNE bra_clear_zero_page
; set 0052-0060
    LDY #$00
; Write warm-boot signature bytes to 0052-0060
bra_write_warm_boot_signature:		; was: bra_C091_loop
    LDA tbl_warm_boot_signature,Y
    STA ram_reset_check,Y
    INY
    CPY #$0F
    BNE bra_write_warm_boot_signature
; set hi-score to 10.000
    LDA #$01
    STA ram_score_hi + $03
; Common boot finalization shared by cold/warm paths
bra_boot_finalize_common:		; was: bra_C0A0
    LDY #con_title_script_scroll_in
    STY ram_script
    LDA #> ram_oam
    STA ram_oam_dma_page
    LDA #$01
    CMP ram_game_mode
    BNE bra_init_apu_and_continue
    CMP ram_current_player
    BNE bra_init_apu_and_continue
; When resuming P2, swap P1/P2 persistent state blocks
bra_swap_player_state_blocks:		; was: bra_C0B2_loop
    LDA ram_data_p2,Y
    STA zp_work0
    LDA ram_data_p1,Y
    STA ram_data_p2,Y
    LDA zp_work0
    STA ram_data_p1,Y
    INY
    CPY #$10
    BNE bra_swap_player_state_blocks
; Initialize APU + jump into main frame bootstrap
bra_init_apu_and_continue:		; was: bra_C0C7
    LDA #APU_STATUS_ENABLE_ALL
    STA APU_STATUS
    LDA #APU_FRAME_COUNTER_IRQ_INHIBIT + APU_FRAME_COUNTER_5_STEP
    STA APU_FRAME_COUNTER
    JSR sub_init_sound_engine
    JSR sub_clear_sound_engine_state
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH
    STA ram_ppuctrl_base
    STA PPUCTRL
    LDA #con_ppu_buffer_end
    STA ram_flag_demo
    STA ram_ppu_buffer_score
    STA ram_ppu_buffer_main
    JMP loc_main_frame_bootstrap

; Warm-boot signature literal (contains author string + AA55)
tbl_warm_boot_signature:		; was: tbl_C0EB_reset_hash
; developers often use bytes 55 and AA for reset checks
    .byte "HIROKI AOYAGI"
    .byte $AA, $55
; NMI handler: OAM DMA, buffered PPU writes, input latch/read
vec_nmi_handler:		; was: vec_C0FA_NMI
    PHA
    TXA
    PHA
    TYA
    PHA
    LDA #PPUMASK_SHOW_LEFT_EDGE + PPUMASK_RENDERING_ENABLE
    STA PPUMASK
    LDA #$00    ; < ram_oam
    STA OAMADDR
    STA ram_nmi_wait
    LDA ram_oam_dma_page
    STA OAMDMA
    JSR sub_write_buffer_to_ppu
    JSR sub_sample_tiles_at_obj_ppu_positions
.ifdef PACMAN_REVISION_RAM_PALETTES
    JSR sub_upload_regional_palette_updates
.endif
    LDA ram_scroll_X
    STA PPUSCROLL
    LDA ram_scroll_Y
    STA PPUSCROLL
    LDA ram_game_mode
    AND ram_current_player
    AND #$01
    ASL
    ORA ram_ppuctrl_base
    STA PPUCTRL
; read input
    LDA #JOYPAD_STROBE
    STA JOYPAD1
    LDA #$00
    STA JOYPAD1
    LDX #$08
; Shift in 8 controller bits for both gamepads
bra_shift_in_controller_bits:		; was: bra_C138_loop
    LDA JOYPAD1
.ifdef PACMAN_REVISION_TENGEN
    AND #JOYPAD_SERIAL_BIT
.else
    AND #JOYPAD_READ_MASK
.endif
    CMP #JOYPAD_SERIAL_BIT
    ROR ram_btn_1p
    LDA JOYPAD2
.ifdef PACMAN_REVISION_TENGEN
    AND #JOYPAD_SERIAL_BIT
.else
    AND #JOYPAD_READ_MASK
.endif
    CMP #JOYPAD_SERIAL_BIT
    ROR ram_btn_2p
    DEX
    BNE bra_shift_in_controller_bits
; give control to a specific player
    LDX ram_btn_1p
    LDA ram_current_player
    AND ram_game_mode
    BEQ bra_store_active_player_input
    LDX ram_btn_2p
; Store selected active-player input into shared button byte
bra_store_active_player_input:		; was: bra_C157
    STX ram_btn_total
    INC ram_frame_cnt
    LDA ram_flag_demo
    BNE bra_pop_regs_and_rti
    JSR sub_update_sound_engine
; Shared NMI exit tail that restores regs and returns
bra_pop_regs_and_rti:		; was: bra_C162
    PLA
    TAY
    PLA
    TAX
    PLA
vec_irq_handler:
    RTI

.ifdef PACMAN_REVISION_RAM_PALETTES
; Later regional revisions can queue complete background and sprite palettes in RAM.
; A universal-color marker of $0F makes the corresponding 16-byte half live.
sub_upload_regional_palette_updates:
    LDA ram_bg_palette_update
    CMP #$0F
    BNE bra_check_regional_sprite_palette
    SetPpuAddress $3F00
    LDY #$00
bra_upload_regional_bg_palette:
    LDA ram_bg_palette_update,Y
    STA PPUDATA
    INY
    CPY #$10
    BNE bra_upload_regional_bg_palette
bra_check_regional_sprite_palette:
    LDA ram_sprite_palette_update
    CMP #$0F
    BNE bra_finish_regional_palette_updates
    SetPpuAddress $3F10
    LDY #$00
bra_upload_regional_sprite_palette:
    LDA ram_sprite_palette_update,Y
    STA PPUDATA
    INY
    CPY #$10
    BNE bra_upload_regional_sprite_palette
bra_finish_regional_palette_updates:
    LDA ram_bg_palette_update
    CMP #$0F
    BEQ bra_reset_regional_palette_updates
    LDA ram_sprite_palette_update
    CMP #$0F
    BEQ bra_reset_regional_palette_updates
    RTS
bra_reset_regional_palette_updates:
    LDA #$30
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    STA PPUADDR
    STA PPUADDR
    STA ram_bg_palette_update
    STA ram_sprite_palette_update
    RTS
.endif

; Main frame bootstrap: waits NMI, reinitializes title/game script context
loc_main_frame_bootstrap:		; was: loc_C168
    LDA #$01
    STA ram_nmi_wait
; Wait until NMI clears wait flag
bra_wait_nmi_before_main_bootstrap:		; was: bra_C16C_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi_before_main_bootstrap
    LDA #PPUCTRL_SPRITE_PATTERN_HIGH
    STA PPUCTRL
    STA ram_ppuctrl_base
    LDA PPUSTATUS
    LDA #$00
    STA PPUMASK
    TAX
; Clear OAM shadow RAM
bra_clear_oam_buffer:		; was: bra_C180_loop
    STA ram_oam,X   ; 0700-07FF
    INX
    BNE bra_clear_oam_buffer
    STA ram_current_player
    JSR sub_clear_bg_nametables_and_attrs
    JSR sub_upload_title_attribute_table
    JSR sub_draw_title_logo_and_text
    JSR sub_draw_score_hud_dual
.ifdef PACMAN_REVISION_RAM_PALETTES
    LDY #$00
bra_copy_tengen_initial_palettes:
    LDA tbl_title_background_palette,Y
    STA ram_bg_palette_update,Y
    INY
    CPY #$20
    BNE bra_copy_tengen_initial_palettes
.else
    SetPpuAddress $3F00
    LDY #$00
; Upload 16-byte title background palette
bra_upload_background_palette:		; was: bra_C1A3_loop
.ifdef PACMAN_EXPANDED_PALETTES
    LDA tbl_expanded_title_background_palette,Y
.else
    LDA tbl_title_background_palette,Y
.endif
    STA PPUDATA
    INY
    CPY #$10
    BNE bra_upload_background_palette
.endif
.ifdef PACMAN_REVISION_TENGEN
    LDA #$20
.else
    LDA #con_tile_maze_blank
.endif
    STA ram_power_pellet_tile_p1
    STA ram_power_pellet_tile_p1 + $01
    STA ram_power_pellet_tile_p1 + $02
    STA ram_power_pellet_tile_p1 + $03
    LDA #con_ppu_buffer_end
    STA ram_ppu_buffer_score
    STA ram_flag_demo
    LDA #$00
    STA ram_game_mode
    STA ram_current_player
    STA ram_scroll_Y
    STA ram_scroll_X
    STA ram_script_delay
    STA ram_shared_state_0
    STA ram_shared_state_1
    LDA ram_script
    BNE bra_select_primary_nametable
; if con_title_script_scroll_in
    LDA #$8A    ; nmt 2800
    BNE bra_commit_ppuctrl_base    ; jmp
; Select nametable 2000 path when script != 00
bra_select_primary_nametable:		; was: bra_C1D7
    LDA #PPUCTRL_NMI_ENABLE + PPUCTRL_SPRITE_PATTERN_HIGH    ; nmt 2000
; Commit selected PPUCTRL base and mirror
bra_commit_ppuctrl_base:		; was: bra_C1D9
    STA PPUCTRL
    STA ram_ppuctrl_base
; Per-frame script dispatcher keyed by ram_script
loc_script_dispatch_loop:		; was: loc_C1DE
    LDA #$01
    STA ram_nmi_wait
; Wait for NMI flag clear in main script dispatcher loop
bra_wait_nmi_in_script_dispatch:		; was: bra_C1E2_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi_in_script_dispatch
    LDY ram_script
    LDA tbl_script_handlers_title_flow,Y
    STA ram_indirect_jmp
    LDA tbl_script_handlers_title_flow + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)
