; Gameplay constants used by the Pac-Man (J) V1.0 native source.
; Values verified by the byte-identical ca65 build.
; Base: https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Pac-Man

; Proven background/HUD tile IDs.
con_tile_empty                         = $00
con_tile_power_pellet_visible           = $01
con_tile_power_pellet_hidden            = $02
con_tile_pellet                         = $03
con_tile_floor                          = $07
con_tile_pellet_alt                     = $09
con_tile_space                          = $20
con_tile_maze_blank                     = $2D
con_tile_score_zero                     = $30
; Added with carry set after CMP #$0A, producing tile $41 for digit A.
con_tile_score_hex_adjust               = $36

; OAM composition mode extracted from bits 5-6 of ram_actor_sprite_set.
con_actor_sprite_mode_standard          = $00
con_actor_sprite_mode_alternate         = $01
con_actor_sprite_mode_tile_offsets      = $02
con_actor_sprite_mode_attr_offsets      = $03
con_actor_sprite_mode_index_mask        = $03
; ram_btn_1p
; ram_btn_2p
; ram_btn_total
con_btn_Right                           = $80
con_btn_Left                            = $40
con_btn_Down                            = $20
con_btn_Up                              = $10
con_btn_Start                           = $08
con_btn_Select                          = $04
con_btn_B                               = $02
con_btn_A                               = $01
con_btns_Dpad                           = con_btn_Right + con_btn_Left + con_btn_Down + con_btn_Up  ; F0
con_btns_AB                             = con_btn_A + con_btn_B                                     ; 03
con_btns_SS                             = con_btn_Start + con_btn_Select                            ; 0C

; ram_script while the title-flow dispatcher is active
con_title_script_scroll_in              = $00
con_title_script_menu_idle              = $02
con_title_script_attract_intro          = $04

; ram_script while the gameplay dispatcher is active
; Values are byte offsets into tbl_gameplay_script_handlers.
con_game_script_round_init              = $00
con_game_script_round_ready             = $02
con_game_script_pause                   = $04
con_game_script_post_eat_pause          = $06
con_game_script_death                   = $08
con_game_script_game_over               = $0A
con_game_script_stage_clear             = $0C
con_game_script_intermission_setup      = $0E
con_game_script_intermission_runtime    = $10

; ram_ghost_state; values are byte offsets into tbl_ghost_state_handlers.
con_ghost_state_in_house                = $00
con_ghost_state_exiting_house           = $02
con_ghost_state_active                  = $04
con_ghost_state_returning_eyes          = $06
con_ghost_state_eaten_score             = $08

; Movement direction enum shared by Pac-Man and active ghosts.
con_direction_up                        = $00
con_direction_left                      = $01
con_direction_down                      = $02
con_direction_right                     = $03
con_direction_reverse_delta             = $02
con_direction_mask                      = $03

; ram_shared_state_0 during intermission; byte offsets into scene tables.
con_intermission_scene_chase            = $00
con_intermission_scene_ripped_suit      = $02
con_intermission_scene_return           = $04

; ram_shared_state_1 during intermission; byte offsets into per-scene tables.
con_intermission_chase_wait_enemy       = $00
con_intermission_chase_wait_wrap        = $02
con_intermission_chase_wait_midpoint    = $04
con_intermission_chase_wait_pack_wrap   = $06
con_intermission_rip_wait_enemy         = $00
con_intermission_rip_transform          = $02
con_intermission_rip_blink              = $04
con_intermission_return_wait_enemy      = $00
con_intermission_return_wait_wrap       = $02
con_intermission_return_wait_midpoint   = $04
con_intermission_return_wait_chaser     = $06

; Buffered PPU command stream: [address hi][address lo][payload...][00] ... [FF].
con_ppu_command_end                     = $00
con_ppu_buffer_end                      = $FF
con_ppu_command_address_size            = $02
con_score_field_size                    = $06
con_1up_field_size                      = $03

; Sound stream byte classes and the control opcodes observed in all 16 streams.
con_sound_duration_min                  = $C0
con_sound_control_min                   = $F0
con_sound_control_index_mask            = $0F
con_sound_opcode_stop                   = $F0
con_sound_opcode_set_reg1_mid2          = $F2
con_sound_opcode_set_reg1_low4          = $F3
con_sound_opcode_set_reg4               = $F5
