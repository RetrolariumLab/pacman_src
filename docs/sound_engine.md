# Sound Engine Notes (`EE18..F427`)

## Entry Points
- `sub_init_sound_engine`: initializes pointers, enables APU channels (`$4015`), frame counter (`$4017`).
- `sub_clear_sound_engine_state`: clears SFX request slots and channel command/state bytes.
- `sub_update_sound_engine`: per-frame mixer/decoder update (called from NMI path when not in demo).

## RAM Layout (high-level)
- `0600..060F`: SFX request slots (`ram_sfx_*`), one per logical sound event id.
- `0620..069F`: 16 channel structs, stride 8 bytes.
  - byte `+0`: channel state/request id
  - bytes `+1..+4`: register/control bytes used for APU writes
  - bytes `+5,+6`: stream pointer lo/hi
  - byte `+7`: duration counter

## Per-frame Update (`sub_update_sound_engine`)
1. Clears temporary dedup flags (`00F8..00FF`).
2. Pre-pass over 16 channel structs (`EE6E..EEB7`):
   - resolves command conflicts and low-priority dedup.
   - may write immediate 4-byte APU quads to `4000..400B`.
3. Main per-channel loop (`loc_sound_channel_main_loop`):
   - if duration active -> decrement counter.
   - if expired/new -> load stream header and decode stream bytes.
4. Advances to next channel until all are processed.

## Stream Decoder (`loc_decode_sound_stream_byte`)
Byte classes:
- `00..BF`: note encoding.
  - upper nibble selects base period pair (`tbl_note_period_base_pairs`)
  - lower nibble applies shift to period.
  - writes resulting period into channel register bytes.
- `C0..EF`: duration-like command path; fetches next duration byte.
- `F0..FF`: control opcode dispatch via `tbl_sound_control_opcode_handlers`.

## Control Opcodes
- `F0`: turn sound off (`handler_00_turn_sound_off`).
- `F2`: set reg1 middle bits (`handler_ctrl02_set_channel_reg1_mid2`).
- `F3`: set reg1 low nibble (`handler_ctrl03_set_channel_reg1_low4`).
- `F5`: set reg4 raw (`handler_ctrl05_set_channel_reg4_raw`).

Other handler table entries are dormant in all decoded streams; see resolved SND-002 in `docs/unknowns.md`.

## Stream Source Table
- Root pointer: `tbl_sfx_stream_table_ptr` -> `tbl_sfx_stream_ptr_table`.
- Slots map request ids `00..0F` to concrete streams, e.g.:
  - `00/01`: READY jingle A/B
  - `02`: extra life
  - `03`: death
  - `04/05`: pellet alternation
  - `06`: fruit
  - `07`: eat ghost
  - `0D/0E`: intermission phrases
  - `0F`: pause toggle

Slot semantics that still require runtime correlation are tracked as SND-001 in docs/unknowns.md.

The decoder, note-period table, and pointer table remain editable in
`src/audio/engine.asm` (`EE18..F0AD`). The stream payloads (`F0AE..F427`) are
generated from the reference ROM into `assets/generated/audio/` and included by
`src/audio/streams.asm`. See [assets.md](./assets.md).

## Invariants to Preserve
1. Keep the 8-byte channel struct and decode order intact first.
2. Preserve opcode semantics as byte-accurate handlers (no early abstraction).
3. Preserve pre-pass arbitration before decode; it affects overlap/priority behavior.
4. Keep stream data table-driven and checksum-verified; do not rewrite its
   format without a tested encoder.
