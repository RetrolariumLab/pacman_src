# Sound Engine Notes (`EE18..F3FF`)

## Entry Points
- `sub_EE18_init_sound_engine`: initializes pointers, enables APU channels (`$4015`), frame counter (`$4017`).
- `sub_EE40_clear_sound_engine_state`: clears SFX request slots and channel command/state bytes.
- `sub_EE5C_update_sound_engine`: per-frame mixer/decoder update (called from NMI path when not in demo).

## RAM Layout (high-level)
- `0600..060F`: SFX request slots (`ram_sfx_*`), one per logical sound event id.
- `0620..069F`: 16 channel structs, stride 8 bytes.
  - byte `+0`: channel state/request id
  - bytes `+1..+4`: register/control bytes used for APU writes
  - bytes `+5,+6`: stream pointer lo/hi
  - byte `+7`: duration counter

## Per-frame Update (`sub_EE5C_update_sound_engine`)
1. Clears temporary dedup flags (`00F8..00FF`).
2. Pre-pass over 16 channel structs (`EE6E..EEB7`):
   - resolves command conflicts and low-priority dedup.
   - may write immediate 4-byte APU quads to `4000..400B`.
3. Main per-channel loop (`loc_EEBF_sound_channel_main_loop`):
   - if duration active -> decrement counter.
   - if expired/new -> load stream header and decode stream bytes.
4. Advances to next channel until all are processed.

## Stream Decoder (`loc_EF2E_decode_sound_stream_byte`)
Byte classes:
- `00..BF`: note encoding.
  - upper nibble selects base period pair (`tbl_F074_note_period_base_pairs`)
  - lower nibble applies shift to period.
  - writes resulting period into channel register bytes.
- `C0..EF`: duration-like command path; fetches next duration byte.
- `F0..FF`: control opcode dispatch via `tbl_EFAA_sound_control_opcode_handlers`.

## Control Opcodes
- `F0`: turn sound off (`ofs_018_EFCA_00_turn_sound_off`).
- `F2`: set reg1 middle bits (`ofs_018_EFEF_ctrl02_set_channel_reg1_mid2`).
- `F3`: set reg1 low nibble (`ofs_018_F007_ctrl03_set_channel_reg1_low4`).
- `F5`: set reg4 raw (`ofs_018_F02F_ctrl05_set_channel_reg4_raw`).

Other handler table entries exist but appear mostly alias/unused in this ROM build.

## Stream Source Table
- Root pointer: `tbl_F08C_sfx_stream_table_ptr` -> `tbl_F08E_sfx_stream_ptr_table`.
- Slots map request ids `00..0F` to concrete streams, e.g.:
  - `00/01`: READY jingle A/B
  - `02`: extra life
  - `03`: death
  - `04/05`: pellet alternation
  - `06`: fruit
  - `07`: eat ghost
  - `0D/0E`: intermission phrases
  - `0F`: pause toggle

## C Port Notes
1. Keep the 8-byte channel struct and decode order intact first.
2. Preserve opcode semantics as byte-accurate handlers (no early abstraction).
3. Preserve pre-pass arbitration before decode; it affects overlap/priority behavior.
4. Keep stream data raw and table-driven; don’t rewrite SFX data format initially.
