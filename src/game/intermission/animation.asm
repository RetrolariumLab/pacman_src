; Intermission tile-animation dispatch and scene animation states

; Dispatch the animation layer by the same even scene/substate keys as scene logic.
; Inputs: ram_shared_state_0/1, frame/animation phase, and staged actor positions.
; Outputs: current scene's actor sprite-set indices.
; Side effects: may advance ram_pacman_anim_phase; never advances scene substate.
; Clobbers: A, Y and ram_indirect_jmp.
sub_run_intermission_animation_dispatch:		; was: sub_EA20
    LDY ram_shared_state_0
    LDA tbl_intermission_anim_scene_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_intermission_anim_scene_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; Animation scene handler table for intermission script10
tbl_intermission_anim_scene_handlers:		; was: tbl_EA2F
    .word handler_anim_scene00_dispatch ; con_intermission_scene_chase
    .word handler_anim_scene01_dispatch ; con_intermission_scene_ripped_suit
    .word handler_anim_scene02_dispatch ; con_intermission_scene_return

; Animation state machine for intermission scene00
handler_anim_scene00_dispatch:		; was: ofs_016_EA35_00
    LDY ram_shared_state_1
    LDA tbl_anim_scene00_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_anim_scene00_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for animation scene00
tbl_anim_scene00_state_handlers:		; was: tbl_EA44
    .word handler_anim_scene_base_cycle         ; con_intermission_chase_wait_enemy
    .word handler_anim_scene00_head_toggle_alias ; con_intermission_chase_wait_wrap
    .word handler_anim_scene00_tail_toggle      ; con_intermission_chase_wait_midpoint
    .word handler_anim_scene00_banner_cycle     ; con_intermission_chase_wait_pack_wrap

; Shared animation tick: cycle frame index and tile
bra_anim_tick_palette_cycle:		; was: bra_EA4C
; Shared animation tick entry
loc_anim_tick_palette_cycle_entry:		; was: loc_EA4C
; Base tile cycle state
handler_anim_scene_base_cycle:		; was: ofs_017_EA4C_00
; Alternate state reusing base tile cycle
handler_anim_scene_base_cycle_alt:		; was: ofs_017_EA4C_04
    INC ram_pacman_anim_phase
    LDA ram_pacman_anim_phase
    AND #$07
    TAY
    LDA tbl_anim_cycle_tiles,Y
    STA ram_actor_sprite_set + $01
    RTS

; Tile cycle pattern for shared animation tick
tbl_anim_cycle_tiles:		; was: tbl_EA5A
    .byte $04   ; 00
    .byte $04   ; 01
    .byte $04   ; 02
    .byte $05   ; 03
    .byte $05   ; 04
    .byte $04   ; 05
    .byte $01   ; 06
    .byte $01   ; 07

; Scene00 animation: toggle head tile each 8 frames
sub_anim_scene00_toggle_head_tile:		; was: sub_EA62
; Alias entry for scene00 head tile animation routine
handler_anim_scene00_head_toggle_alias:		; was: ofs_017_EA62_02
    LDA ram_frame_cnt
    AND #$07
    BNE bra_anim_tick_palette_cycle
    LDA ram_frame_cnt
    AND #$08
    BNE bra_anim_scene00_select_tile_b
    LDA #$0C
    BNE bra_anim_scene00_store_tile    ; jmp
; Select scene00 alternate tile
bra_anim_scene00_select_tile_b:		; was: bra_EA72
    LDA #$0D
; Store scene00 animated tile
bra_anim_scene00_store_tile:		; was: bra_EA74
    STA ram_actor_sprite_set
    BNE bra_anim_tick_palette_cycle    ; jmp

; Scene00 tail tile toggle state
bra_anim_scene00_tail_tile_toggle:		; was: bra_EA79
; Toggle tail tile in scene00
handler_anim_scene00_tail_toggle:		; was: ofs_017_EA79_04
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_anim_scene00_every8frames
    RTS
; Run scene00 tail toggle every 8 frames
bra_anim_scene00_every8frames:		; was: bra_EA80
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_anim_scene00_select_tail_tile_b
    LDA #$1E
    BNE bra_anim_scene00_store_tail_tile    ; jmp
; Select alternate tail tile
bra_anim_scene00_select_tail_tile_b:		; was: bra_EA8A
    LDA #$1F
; Store scene00 tail tile
bra_anim_scene00_store_tail_tile:		; was: bra_EA8C
    STA ram_actor_sprite_set
    RTS

; Cycle 4-tile banner animation for scene00
handler_anim_scene00_banner_cycle:		; was: ofs_017_EA90_06
    INC ram_pacman_anim_phase
    LDA ram_pacman_anim_phase
    AND #$07
    TAY
    LDA tbl_anim_cycle_to_pattern_index,Y
    TAY
    LDA tbl_anim_banner_tile_quads,Y
    STA ram_actor_sprite_set + $01
    LDA tbl_anim_banner_tile_quads + $01,Y
    STA ram_actor_sprite_set + $02
    LDA tbl_anim_banner_tile_quads + $02,Y
    STA ram_actor_sprite_set + $03
    LDA tbl_anim_banner_tile_quads + $03,Y
    STA ram_actor_sprite_set + $04
    BNE bra_anim_scene00_tail_tile_toggle    ; jmp

; Map cycle step to banner pattern index
tbl_anim_cycle_to_pattern_index:		; was: tbl_EAB5_index
    .byte $00   ; 00
    .byte $00   ; 01
    .byte $00   ; 02
    .byte $04   ; 03
    .byte $04   ; 04
    .byte $00   ; 05
    .byte $08   ; 06
    .byte $08   ; 07

; Banner tile quads for scene00 animation
tbl_anim_banner_tile_quads:		; was: tbl_EABD
; 00
    .byte $3C
    .byte $3D
    .byte $3E
    .byte $3F
; 04
    .byte $3C
    .byte $40
    .byte $3E
    .byte $41
; 08
    .byte $38
    .byte $39
    .byte $3A
    .byte $3B
; Animation state machine for intermission scene01
handler_anim_scene01_dispatch:		; was: ofs_016_EAC9_02
    LDY ram_shared_state_1
    LDA tbl_anim_scene01_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_anim_scene01_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for animation scene01
; 00: base cycle, 02: ripped-tile toggle, 04: base cycle alt
tbl_anim_scene01_state_handlers:		; was: tbl_EAD8
    .word handler_anim_scene_base_cycle        ; con_intermission_rip_wait_enemy
    .word handler_anim_scene01_rip_tile_toggle ; con_intermission_rip_transform
    .word handler_anim_scene_base_cycle_alt    ; con_intermission_rip_blink

; Scene01 animation: toggle ripped-suit center tile by position
handler_anim_scene01_rip_tile_toggle:		; was: ofs_017_EADE_02
    JSR sub_anim_scene00_toggle_head_tile
    LDA ram_spr_pos_X_hi
    CMP #$7D
    BNE bra_anim_scene01_check_second_tile_trigger
    LDA #$43
    STA ram_actor_sprite_set + $02
    RTS
; Check second X trigger for ripped tile
bra_anim_scene01_check_second_tile_trigger:		; was: bra_EAEE
    CMP #$7B
    BEQ bra_anim_scene01_store_second_rip_tile
    RTS
; Store second ripped-suit tile
bra_anim_scene01_store_second_rip_tile:		; was: bra_EAF3
    LDA #$44
    STA ram_actor_sprite_set + $02
    RTS

; Animation state machine for intermission scene02
handler_anim_scene02_dispatch:		; was: ofs_016_EAF9_04
    LDY ram_shared_state_1
    LDA tbl_anim_scene02_state_handlers,Y
    STA ram_indirect_jmp
    LDA tbl_anim_scene02_state_handlers + $01,Y
    STA ram_indirect_jmp + $01
    JMP (ram_indirect_jmp)

; State handlers for animation scene02
; 00: base cycle, 02: main-tile toggle, 04/06: aux-tile toggles
tbl_anim_scene02_state_handlers:		; was: tbl_EB08
    .word handler_anim_scene_base_cycle            ; con_intermission_return_wait_enemy
    .word handler_anim_scene02_toggle_main_tile     ; con_intermission_return_wait_wrap
    .word handler_anim_scene02_toggle_aux_tile      ; con_intermission_return_wait_midpoint
    .word handler_anim_scene02_toggle_aux_tile_alt  ; con_intermission_return_wait_chaser

; Scene02 animation: toggle main actor tile every 8 frames
handler_anim_scene02_toggle_main_tile:		; was: ofs_017_EB10_02
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_anim_scene02_every8frames
    JMP loc_anim_tick_palette_cycle_entry
; Run scene02 main tile toggle every 8 frames
bra_anim_scene02_every8frames:		; was: bra_EB19
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_anim_scene02_select_main_tile_b
    LDA #$48
    BNE bra_anim_scene02_store_main_tile    ; jmp
; Select alternate main tile
bra_anim_scene02_select_main_tile_b:		; was: bra_EB23
    LDA #$49
; Store scene02 main tile
bra_anim_scene02_store_main_tile:		; was: bra_EB25
    STA ram_actor_sprite_set
    JMP loc_anim_tick_palette_cycle_entry

; Scene02 animation: toggle auxiliary tile every 8 frames
handler_anim_scene02_toggle_aux_tile:		; was: ofs_017_EB2B_04
; Alt state sharing auxiliary tile toggle
handler_anim_scene02_toggle_aux_tile_alt:		; was: ofs_017_EB2B_06
    LDA ram_frame_cnt
    AND #$07
    BEQ bra_anim_scene02_aux_every8frames
    RTS
; Run scene02 auxiliary tile toggle every 8 frames
bra_anim_scene02_aux_every8frames:		; was: bra_EB32
; each 8 frames
    LDA ram_frame_cnt
    AND #$08
    BNE bra_anim_scene02_select_aux_tile_b
    LDA #$4A
    BNE bra_anim_scene02_store_aux_tile    ; jmp
; Select alternate auxiliary tile
bra_anim_scene02_select_aux_tile_b:		; was: bra_EB3C
    LDA #$4B
; Store scene02 auxiliary tile
bra_anim_scene02_store_aux_tile:		; was: bra_EB3E
    STA ram_actor_sprite_set
    RTS
