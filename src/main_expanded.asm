; Optional NROM-256 entrypoint with JSON-generated data in a new PRG bank.

.setcpu "6502"

.segment "HACK_BANK"
.org $8000

tbl_expanded_maze_rle_stream:
    .incbin "assets/generated/maze/maze.rle"

tbl_expanded_stage_parameters:
    .incbin "build/expanded/assets/stage_parameters.bin"

tbl_expanded_stage2_maze_rle_stream:
    .incbin "build/expanded/assets/maze.rle"

; Select the original maze for stage 1 and the editable maze for stage 2+.
; This helper lives entirely in the added bank; the fixed-bank call site keeps
; its original width so no preservation addresses move.
sub_select_expanded_maze:
    LDA a:ram_stage_p1
    CMP #$01
    BCC bra_select_expanded_stage1_maze
    LDA #<tbl_expanded_stage2_maze_rle_stream
    STA z:zp_work0
    LDA #>tbl_expanded_stage2_maze_rle_stream
    STA z:zp_work1
    RTS
bra_select_expanded_stage1_maze:
    LDA #<tbl_expanded_maze_rle_stream
    STA z:zp_work0
    LDA #>tbl_expanded_maze_rle_stream
    STA z:zp_work1
    RTS

tbl_expanded_sfx_stream_ptr_table:
    .incbin "build/expanded/assets/sound_pointers.bin"

tbl_expanded_sfx_streams:
    .incbin "build/expanded/assets/sound_streams.bin"
tbl_expanded_sfx_streams_end:

tbl_expanded_actor_sprite_tiles:
tbl_expanded_actor_data:
    .incbin "build/expanded/assets/actor_sprites.bin"
tbl_expanded_actor_alt_sprite_tiles = tbl_expanded_actor_data + $0100
tbl_expanded_actor_sprite_attrs = tbl_expanded_actor_data + $0134
tbl_expanded_actor_alt_sprite_attrs = tbl_expanded_actor_data + $0234
tbl_expanded_oam_quad_offsets = tbl_expanded_actor_data + $0268
tbl_expanded_actor_data_end:

tbl_expanded_palette_data:
tbl_expanded_title_background_palette:
    .incbin "build/expanded/assets/palettes.bin"
tbl_expanded_attract_bg_spr_palette = tbl_expanded_palette_data + $0010
tbl_expanded_round_gameplay_palette = tbl_expanded_palette_data + $0030
tbl_expanded_intro_sprite_palette = tbl_expanded_palette_data + $0050
tbl_expanded_frightened_palette_cmd = tbl_expanded_palette_data + $0060
tbl_expanded_frightened_palette_cmd_alt = tbl_expanded_palette_data + $006A
tbl_expanded_stage_fruit_palette_color = tbl_expanded_palette_data + $006F
tbl_expanded_palette_data_end:

tbl_expanded_screen_data:
tbl_expanded_title_logo_tiles:
    .incbin "build/expanded/assets/screens.bin"
tbl_expanded_title_logo_text_packets = tbl_expanded_screen_data + $008A
tbl_expanded_title_attribute_bytes = tbl_expanded_screen_data + $018A
tbl_expanded_menu_prompt_tiles = tbl_expanded_screen_data + $01A2
tbl_expanded_player_count_glyph_pair = tbl_expanded_screen_data + $01AA
tbl_expanded_attract_text_ptr_table = tbl_expanded_screen_data + $01AD
tbl_expanded_attract_text_packets = tbl_expanded_screen_data + $01C1
tbl_expanded_hud_blocks = tbl_expanded_screen_data + $03C1
tbl_expanded_hud_player_packets = tbl_expanded_screen_data + $03D8
tbl_expanded_pause_tiles = tbl_expanded_screen_data + $03EA
tbl_expanded_intermission_cycle_tiles = tbl_expanded_screen_data + $03F6
tbl_expanded_intermission_cycle_pattern_indexes = tbl_expanded_screen_data + $03FE
tbl_expanded_intermission_banner_tile_quads = tbl_expanded_screen_data + $0406
tbl_expanded_screen_data_end:

.assert tbl_expanded_maze_rle_stream = $8000, error, "expanded maze must begin at $8000"
.assert tbl_expanded_stage_parameters = $81A0, error, "expanded stage data must begin at $81A0"
.assert tbl_expanded_stage2_maze_rle_stream = $82D6, error, "stage-2 maze must begin at $82D6"
.assert sub_select_expanded_maze = $8476, error, "maze selector must begin at $8476"
.assert tbl_expanded_sfx_stream_ptr_table = $848F, error, "sound pointers must begin at $848F"
.assert tbl_expanded_sfx_streams = $84AF, error, "sound streams must begin at $84AF"
.assert tbl_expanded_sfx_streams_end = $A4AF, error, "sound stream budget must be 8 KiB"
.assert tbl_expanded_actor_data = $A4AF, error, "actor mappings must begin at $A4AF"
.assert tbl_expanded_actor_data_end = $A71F, error, "actor mappings must remain 624 bytes"
.assert tbl_expanded_palette_data = $A71F, error, "palettes must begin at $A71F"
.assert tbl_expanded_palette_data_end = $A79E, error, "palettes must remain 127 bytes"
.assert tbl_expanded_screen_data = $A79E, error, "screens must begin at $A79E"
.assert tbl_expanded_screen_data_end = $ABB0, error, "screens must remain 1042 bytes"

PACMAN_EXPANDED_MAZE = 1
PACMAN_EXPANDED_STAGE = 1
PACMAN_EXPANDED_MULTI_MAZE = 1
PACMAN_EXPANDED_SOUND = 1
PACMAN_EXPANDED_ACTORS = 1
PACMAN_EXPANDED_PALETTES = 1
PACMAN_EXPANDED_SCREENS = 1

.include "main.asm"
