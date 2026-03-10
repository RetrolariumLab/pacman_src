# Score, Pellets, Fruit, 1UP (`DEDF..E148`)

## Entry Points
- `sub_DEDF_check_for_eating_pellets`: pellet/power-pellet detection at Pac-Man tile.
- `loc_E060_add_points_and_update_score_buffers`: central score commit/format/hiscore path.

## Pellet Detection and Clear
- Tile checks in `DEDF..DEF6` classify:
  - normal pellet variants (`+09`, `+03`)
  - power pellet variants (`+01`, `+02`)
- Power-pellet branch `DEF7`:
  - enters frightened mode (`sub_DFC6_start_frightened_mode`)
  - maps world pos to pellet marker slot and marks it eaten in `ram_power_pellet_tile_p1`.

## Common Pellet Tail (`DF1E..DFA3`)
- Queues one PPU write command into `ram_ppu_buffer_main` to clear consumed tile.
- Sets `ram_obj_ppu_tile_now = con_tile + $07` (floor tile).
- Loads pending score delta from `tbl_DFA6_pellet_clear_tile_and_points` into `ram_00DC`.
- Decrements `ram_pellet_cnt_p1`:
  - if reaches `0` -> switches to stage-clear script (`ram_script = 0C`).
  - else checks fruit thresholds.

## Fruit Spawn / Visibility
- Spawn thresholds in remaining pellet count:
  - `0x86` and `0x37` -> `bra_DF7E_spawn_fruit_item`.
- Spawn writes:
  - timer (`ram_fruit_timer_hi/lo = 0A:3C`)
  - sprite tile by stage via `tbl_DFBE_fruit_sprite_tile_by_stage`
  - fruit sprite position (`X=60`, `Y=80`) and palette.
- Fruit timer decrement/hide is maintained in earlier runtime block `D1CF..D1E4`.

## Score Commit (`E060..E139`)
1. Skip in demo mode.
2. Add pending BCD digits (`00DC..00E1`) into active score (`70..75`) with carry.
3. Clear pending digits.
4. Rebuild score tile buffer (`ram_ppu_buffer_score`) with leading-zero spaces.
5. 1UP check (`ram_006B` latch) and life increment + life-icon packet append.
6. Compare score vs hiscore digit-by-digit and promote both PPU+RAM buffers if exceeded.

## Related Tables
- `tbl_DFA6_pellet_clear_tile_and_points`: pellet clear tile + point deltas.
- `tbl_DFBE_fruit_sprite_tile_by_stage`: fruit sprite tile per stage group.
- `tbl_E13A_life_icon_ppu_packets`: packet template for life icon update.

## RAM Contracts (for C port)
- `ram_00DC..00E1`: pending BCD score deltas (event producers write here).
- `ram_score_p1` / `ram_score_hi`: canonical score/hiscore digits.
- `ram_ppu_buffer_score` / `ram_ppu_buffer_hiscore`: display buffers.
- `ram_006B`: one-time 1UP awarded latch.
- `ram_pellet_cnt_p1`: remaining pellets in round.
- `ram_fruit_timer_hi/lo`: fruit visibility lifetime.

## Porting Notes
1. Keep BCD digit math exact; avoid int conversion shortcuts initially.
2. Keep event producers writing only pending deltas; centralize commit in `E060` equivalent.
3. Preserve exact threshold values (`0x86`, `0x37`, `0x00`) and ordering.
4. Keep 1UP as a latched side effect in score commit stage.
