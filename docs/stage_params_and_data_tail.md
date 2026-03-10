# Stage Params and Data Tail (`EB42..FFFF`)

This covers the remaining data-heavy tail of bank FF after gameplay/intermission logic.

## Stage Profile Multiplexer (`EB42`)
- `tbl_EB42_stage_param_index_stream` is a 6-byte profile stream per stage bucket.
- In round init (`CEAD..CF8B`), stage index is converted into this stream offset.
- Profile fields:
  - `[0]` level param block id (`tbl_EBCC`)
  - `[1]` speed/timer block id (`tbl_EC3A`)
  - `[2]` dot-threshold pair id (`tbl_EC5A`)
  - `[3]` release target block id (`tbl_EC68`)
  - `[4]` fruit bonus group id
  - `[5]` fruit color group id

## Runtime Parameter Tables
- `tbl_EBCC_level_param_blocks_22bytes`:
  - copied to RAM `009F..00B4` (per-stage ghost/chase/fright/speed related constants).
- `tbl_EC3A_speed_timer_blocks_8bytes`:
  - copied to `0097..009E`.
- `tbl_EC5A_dot_counter_threshold_pairs`:
  - loaded into `008D/008E`.
- `tbl_EC68_ghost_release_target_quads`:
  - default release target set copied to `008F..0092`.
- `tbl_EC74_release_target_special_case_quad`:
  - used when round init adjusts release targets from carried pellet progress.

## Maze Data
- `tbl_EC78_maze_rle_stream`:
  - compressed maze stream decoded by `sub_E25C_decompress_and_upload_maze_layout`.
- `tbl_FFF8_maze_rle_stream_ptr`:
  - fixed pointer to the maze stream used by uploader init.

## Audio Support Tables in Tail
- `tbl_F074_note_period_base_pairs`: note base periods for decoder (`EF2E`).
- `tbl_F08C_sfx_stream_table_ptr` -> `tbl_F08E_sfx_stream_ptr_table`:
  - maps SFX request slots `00..0F` to stream definitions.

## Padding / Unused Tail
- Large `FF`-filled region appears in high tail (`F4xx..FFF7`).
- Keep untouched during refactors; this is stable ROM layout padding.

## Vectors (`FFFA..FFFF`)
- `FFFA`: `vec_C0FA_nmi_handler`
- `FFFC`: `vec_C033_reset_entry`
- `FFFE`: `vec_C167_IRQ`

## C Port Notes
1. Preserve stage profile decoding order from round init exactly.
2. Keep all parameter tables byte-identical and table-driven at first.
3. Keep maze stream raw and referenced through pointer table as in ROM.
4. Preserve fixed vectors and tail alignment in any bank recreation flow.
