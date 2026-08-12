# Bank FF Docs Index

## Navigation
- [roadmap.md](./roadmap.md): project direction, evidence rules, milestones, and completion criteria.
- [source_layout.md](./source_layout.md): address-ordered module map and file-sizing rules.
- [postmortem.md](./postmortem.md): why the C reimplementation was removed and what replaced it.
- [bank_ff_map.md](./bank_ff_map.md): top-level bank segmentation and annotation entry points.
- [ram_fields.md](./ram_fields.md): key RAM fields and runtime roles.
- [script_states.md](./script_states.md): gameplay script state machine (`ram_script`).
- [gameplay_feature_map.md](./gameplay_feature_map.md): feature-level map (levels, enemies, bonuses, cutscenes).
- [ghost_ai.md](./ghost_ai.md): ghost update pipeline, states, targeting, movement.
- [score_and_bonus.md](./score_and_bonus.md): pellets/fruit/score/1UP flow.
- [intermission_flow.md](./intermission_flow.md): script0E/script10 and scene/substate transitions.
- [sound_engine.md](./sound_engine.md): audio engine update loop, stream decoder, opcode table.
- [stage_params_and_data_tail.md](./stage_params_and_data_tail.md): stage profile tables, maze RLE, vectors, tail layout.
- [assets.md](./assets.md): policy and reproducible extraction of opaque ROM assets.

## Suggested Annotation Order
1. Core loop shell:
`C98A..CA1E` + `script 00/02/04/06/08/0C` dispatcher and transitions.

2. Rendering-safe gameplay data path:
`DEDF..E148` (pellet/fruit/score/1UP), then HUD writers needed by it.

3. Movement/collision foundation:
`E154..E24E` tile probes/conversion + `D2FB..D4C1` Pac-Man movement.

4. Enemy logic:
`D4C2..D8F8` ghost states, targeting and speed tables.

5. Intermissions:
`E655..EB41` scene runtime + animation dispatch.

6. Audio engine:
`EE18..F0AD` decoder/tables and `F0AE..F427` generated SFX streams.

7. Data tail integration:
`EB42..FFFF` stage profile multiplexer, parameter blocks, maze stream pointer, vectors.

## Verification Rule
After each edit batch:
- run `make verify`
- require `[OK] Byte-identical ROM reproduced from native ca65 source.`

## Current Status
- Bank FF label/comment pass is broadly complete for major systems.
- Native ca65 source is split into semantic subsystem directories under `src/`,
  with `src/main.asm` retaining the modules' address order.
- Next practical step is deepening lower-level branch and data annotations,
  keeping byte-identity after every edit batch.
