; Build-variant aliases for stage tuning data consumers.

.ifdef PACMAN_EXPANDED_STAGE
    .define off_active_stage_profiles                  tbl_expanded_stage_parameters
    .define off_active_level_parameter_blocks          tbl_expanded_stage_parameters + $008A
    .define off_active_speed_timer_blocks              tbl_expanded_stage_parameters + $00F8
    .define off_active_dot_threshold_pairs             tbl_expanded_stage_parameters + $0118
    .define off_active_ghost_release_targets           tbl_expanded_stage_parameters + $0126
    .define off_active_restart_release_target          tbl_expanded_stage_parameters + $0132
.else
    .define off_active_stage_profiles                  tbl_stage_param_index_stream
    .define off_active_level_parameter_blocks          tbl_level_param_blocks_22bytes
    .define off_active_speed_timer_blocks              tbl_speed_timer_blocks_8bytes
    .define off_active_dot_threshold_pairs             tbl_dot_counter_threshold_pairs
    .define off_active_ghost_release_targets           tbl_ghost_release_target_quads
    .define off_active_restart_release_target          tbl_release_target_special_case_quad
.endif
