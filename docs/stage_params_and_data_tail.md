# Stage Parameters, Maze Stream, Padding, and Vectors

This subsystem covers the data-driven round-init profile at `$EB42..$EC77`, the
generated maze stream, and the fixed bank tail through the NES vectors.

## Six-Byte Stage Profile

Round init multiplies the zero-based stage index by six and uses that byte
offset in `tbl_stage_param_index_stream`. There are 23 records. The actual
consumer mapping is:

| Field | Use |
| --- | --- |
| `0` | shared profile ID: selects both a 22-byte level block and an 8-byte timing window |
| `1` | frightened duration copied directly to `ram_frightened_duration` |
| `2` | two-byte personal pellet-threshold pair ID |
| `3` | four-byte ghost-release target set ID |
| `4` | fruit/bonus stage group saved in `ram_stage_param_index` |
| `5` | release interval in seconds copied to `ram_release_interval_seconds` |

Older descriptions that called fields 1 and 5 speed-block and fruit-color IDs
are contradicted by the round-init reads. Field 0 is deliberately reused for
two differently sized tables.

## Runtime Table Copies

The field-0 ID is multiplied by 22 and copies a complete level block to
`ram_level_parameters` (`$009F..$00B4`): eleven little-endian speeds, the low
byte in 1/256 pixel and the high byte in whole pixels per frame.

| Offset | RAM name | Speed |
| --- | --- | --- |
| `+$00` | `ram_pacman_frightened_floor_speed` | Pac-Man on a floor tile while ghosts are frightened |
| `+$02` | `ram_pacman_frightened_pellet_speed` | Pac-Man on a pellet tile while ghosts are frightened |
| `+$04` | `ram_pacman_frightened_power_speed` | Pac-Man on a power-pellet tile while ghosts are frightened |
| `+$06` | `ram_pacman_floor_speed` | Pac-Man on a floor tile otherwise, and at round start |
| `+$08` | `ram_pacman_pellet_speed` | Pac-Man on a pellet tile otherwise |
| `+$0A` | `ram_pacman_power_pellet_speed` | Pac-Man on a power-pellet tile otherwise |
| `+$0C` | `ram_ghost0_normal_speed_*` | ghost 0 after its first personal dot threshold |
| `+$0E` | `ram_ghost0_second_speed_*` | ghost 0 after its second threshold |
| `+$10` | `ram_ghost_normal_speed_*` | the other ghosts, and ghost 0 until its first threshold |
| `+$12` | `ram_ghost_frightened_speed_*` | a frightened ghost |
| `+$14` | `ram_ghost_tunnel_speed_*` | a ghost in the side tunnels |

`loc_select_speed_profile` picks Pac-Man's speed;
`sub_select_ghost_speed_vector` and the release checks in
`game/round/runtime.asm` pick the ghosts'. The European release scales all
five blocks for 50 Hz.

The same field-0 ID is multiplied by eight and copies an eight-byte window to
`ram_scatter_chase_durations` (`$0097..$009E`), with its first byte also seeding
the active timer. IDs 0 through 3 address the four explicit rows in
`tbl_speed_timer_blocks_8bytes`. ID 4, used by the last two stage records,
starts at the immediately adjacent `tbl_dot_counter_threshold_pairs`; its
eight-byte window is therefore the first four threshold pairs. The absence of
padding between these tables is gameplay-significant.

Field 2 selects one threshold pair for `ram_personal_release_thresholds`.
Field 3 normally selects one release-target quad. On round restart, the special
quad is used instead and its later three values are adjusted by `$C0` minus the
carried pellet count. The resulting first target determines how many house
slots initially enter exiting-house state; the second becomes the global target.

## Maze RLE Format and Upload

`tbl_maze_rle_stream` comes from v1.0 (`make split`) and every revision
includes it (at `$EC78` in v1.0). Each token is:

```text
bits 7..6: run length minus one (0..3 means 1..4 tiles)
bits 5..0: tile ID
```

`sub_decompress_and_upload_maze_layout` decodes exactly 27 rows of 22 tiles,
starting at PPU `$2040` for player one or `$2840` for player two. Row addresses
advance by `$20`. A run must not cross a row end: a row ends only when its tile
count reaches exactly zero, so a crossing run writes on past it. The stream cursor is a pointer plus Y index; when Y wraps, the
pointer high byte increments.

After the maze, the routine writes three eight-tile bottom-banner rows from a
small fill table at `$21D6` or `$29D6`. It writes directly to PPU and therefore
requires rendering/vblank ownership from its caller.

The maze remains a generated asset (Retrolarium edits it). Its pointer is
stored separately at the bank tail, not adjacent to the stream.

## Padding and Fixed Tail

In v1.0 the sound assets end at `$F427`, and `unused_bank_padding` emits `$FF`
from there through `$FFF7`. The expression `.res $FFF8 - *, $FF` makes any
growth in earlier modules reduce this padding while preserving the next fixed
address. The revisions differ at the tail:

| Revisions | Tail |
| --- | --- |
| v1.0, v1.1, Rev B, unlicensed Tengen | `$FF` up to `$FFF8`, where `tbl_maze_rle_stream_ptr` points to the maze |
| licensed Tengen | the same, but a reset trampoline at `$FF00` (`vec_tengen_licensed_reset_entry`, two extra vblank waits), and the reset vector points to it |
| Namco's USA, European | the maze pointer at `$FFF6` (`tbl_namco_maze_rle_stream_ptr`); the word at `$FFF8` holds `vec_nmi_handler` |

The separate `VECTORS` segment then occupies `$FFFA..$FFFF`:

| Address | Vector |
| --- | --- |
| `$FFFA` | `vec_nmi_handler` |
| `$FFFC` | `vec_reset_entry` (licensed Tengen: `vec_tengen_licensed_reset_entry`) |
| `$FFFE` | `vec_irq_handler` |

The linker configuration fixes `BANK_FF` to `$C000..$FFF9` and `VECTORS` to the
last six bytes. Overflow fails linking rather than silently shifting vectors.

## Preservation Invariants

- Preserve six-byte record order and field-0 reuse by both table consumers.
- Preserve adjacency of the timing blocks and dot-threshold pairs; profile ID 4
  intentionally reads across the semantic table boundary.
- Keep 22/8/2/4-byte multipliers and copy sizes exact.
- Preserve restart adjustment arithmetic and release-queue initialization order.
- Keep maze tokens limited to 1..4 repeats of a six-bit tile, with 27x22 output.
- Keep the maze asset manifest-verified and referenced by the tail pointer
  (`$FFF8`, or `$FFF6` in the late Namco releases).
- Preserve the `$FF` fill and all three fixed vectors.
