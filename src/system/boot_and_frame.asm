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
    .byte "1980 NAMCO LTD. "
    .byte "ALL RIGHTS RESERVED"
; Hardware reset entry: disables IRQ/PPU, clears RAM, validates warm-boot signature
vec_reset_entry:		; was: vec_C033_RESET
    SEI
    CLD
    LDA #$00
    STA $2000
    STA $2001
; Wait for first VBlank after reset before touching PPU state
bra_wait_vblank_ready:		; was: bra_C03D_loop
    LDA $2002
    BPL bra_wait_vblank_ready
    LDX #$FF
    TXS
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
    LDA #$06
    STA $2001
    LDA #$00
    STA $2005
    STA $2005
    STA ram_scroll_X
    STA ram_scroll_Y
    STA $2000
    STA $2001
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
    LDY #con_script_00
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
    LDA #$1F
    STA $4015
    LDA #$C0
    STA $4017
    JSR sub_init_sound_engine
    JSR sub_clear_sound_engine_state
    LDA #$88
    STA ram_ppuctrl_base
    STA $2000
    LDA #$FF
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
    LDA #$1E
    STA $2001
    LDA #$00    ; < ram_oam
    STA $2003
    STA ram_nmi_wait
    LDA ram_oam_dma_page
    STA $4014
    JSR sub_write_buffer_to_ppu
    JSR sub_sample_tiles_at_obj_ppu_positions
    LDA ram_scroll_X
    STA $2005
    LDA ram_scroll_Y
    STA $2005
    LDA ram_game_mode
    AND ram_current_player
    AND #$01
    ASL
    ORA ram_ppuctrl_base
    STA $2000
; read input
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016
    LDX #$08
; Shift in 8 controller bits for both gamepads
bra_shift_in_controller_bits:		; was: bra_C138_loop
    LDA $4016
    AND #$03
    CMP #$01
    ROR ram_btn_1p
    LDA $4017
    AND #$03
    CMP #$01
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

; Main frame bootstrap: waits NMI, reinitializes title/game script context
loc_main_frame_bootstrap:		; was: loc_C168
    LDA #$01
    STA ram_nmi_wait
; Wait until NMI clears wait flag
bra_wait_nmi_before_main_bootstrap:		; was: bra_C16C_infinite_loop
    LDA ram_nmi_wait
    BNE bra_wait_nmi_before_main_bootstrap
    LDA #$08
    STA $2000
    STA ram_ppuctrl_base
    LDA $2002
    LDA #$00
    STA $2001
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
    SetPpuAddress $3F00
    LDY #$00
; Upload 16-byte title background palette
bra_upload_background_palette:		; was: bra_C1A3_loop
    LDA tbl_title_background_palette,Y
    STA $2007
    INY
    CPY #$10
    BNE bra_upload_background_palette
    LDA #con_tile + $2D
    STA ram_power_pellet_tile_p1
    STA ram_power_pellet_tile_p1 + $01
    STA ram_power_pellet_tile_p1 + $02
    STA ram_power_pellet_tile_p1 + $03
    LDA #$FF
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
; if con_script_00
    LDA #$8A    ; nmt 2800
    BNE bra_commit_ppuctrl_base    ; jmp
; Select nametable 2000 path when script != 00
bra_select_primary_nametable:		; was: bra_C1D7
    LDA #$88    ; nmt 2000
; Commit selected PPUCTRL base and mirror
bra_commit_ppuctrl_base:		; was: bra_C1D9
    STA $2000
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
