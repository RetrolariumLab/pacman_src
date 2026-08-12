; Original SFX and music command streams.
;
; These opaque sequencer assets are generated from the reference ROM by
; `make split`. Labels remain in source so the editable pointer table in
; engine.asm can refer to individual streams.

off_F0AE_sfx_slot02_extra_life:
    .incbin "assets/generated/audio/slot02_extra_life.bin"

off_F0C3_sfx_slot06_fruit:
    .incbin "assets/generated/audio/slot06_fruit.bin"

off_F0EE_sfx_slot0A_release_counter_hi:
    .incbin "assets/generated/audio/slot0a_release_counter_hi.bin"

off_F119_sfx_slot0B_release_counter_mid:
    .incbin "assets/generated/audio/slot0b_release_counter_mid.bin"

off_F13C_sfx_slot0C_release_counter_lo:
    .incbin "assets/generated/audio/slot0c_release_counter_lo.bin"

off_F15B_sfx_slot09_ghost_house_release_marker:
    .incbin "assets/generated/audio/slot09_ghost_house_release_marker.bin"

off_F170_sfx_slot07_eat_ghost:
    .incbin "assets/generated/audio/slot07_eat_ghost.bin"

off_F193_sfx_slot0D_intermission_flag_a:
    .incbin "assets/generated/audio/slot0d_intermission_flag_a.bin"

off_F206_sfx_slot0E_intermission_flag_b:
    .incbin "assets/generated/audio/slot0e_intermission_flag_b.bin"

off_F2A9_sfx_slot08_ghost_house_state6_marker:
    .incbin "assets/generated/audio/slot08_ghost_house_state6_marker.bin"

off_F2C8_sfx_slot03_death:
    .incbin "assets/generated/audio/slot03_death.bin"

off_F357_sfx_slot00_player_ready_chA:
    .incbin "assets/generated/audio/slot00_player_ready_channel_a.bin"

off_F3A0_sfx_slot01_player_ready_chB:
    .incbin "assets/generated/audio/slot01_player_ready_channel_b.bin"

off_F3CB_sfx_slot04_pellet_even:
    .incbin "assets/generated/audio/slot04_pellet_even.bin"

off_F3DC_sfx_slot05_pellet_odd:
    .incbin "assets/generated/audio/slot05_pellet_odd.bin"

off_F3ED_sfx_slot0F_pause_toggle:
    .incbin "assets/generated/audio/slot0f_pause_toggle.bin"
