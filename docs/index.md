# Bank FF Docs Index

## Navigation
- [current_state.md](./current_state.md): current project state, active workflow, references and priorities.
- [bank_ff_map.md](./bank_ff_map.md): top-level bank segmentation and porting entry points.
- [ram_fields.md](./ram_fields.md): key RAM fields and migration notes.
- [script_states.md](./script_states.md): gameplay script state machine (`ram_script`).
- [gameplay_feature_map.md](./gameplay_feature_map.md): feature-level map (levels, enemies, bonuses, cutscenes).
- [ghost_ai.md](./ghost_ai.md): ghost update pipeline, states, targeting, movement.
- [score_and_bonus.md](./score_and_bonus.md): pellets/fruit/score/1UP flow.
- [intermission_flow.md](./intermission_flow.md): script0E/script10 and scene/substate transitions.
- [sound_engine.md](./sound_engine.md): audio engine update loop, stream decoder, opcode table.
- [stage_params_and_data_tail.md](./stage_params_and_data_tail.md): stage profile tables, maze RLE, vectors, tail layout.

## Suggested C Port Order
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
`EE18..F3FF` stream decoder and SFX tables.

7. Data tail integration:
`EB42..FFFF` stage profile multiplexer, parameter blocks, maze stream pointer, vectors.

## Verification Rule
After each edit batch:
- run `make verify-bank-ff-ca65`
- require `[OK] Byte-identical to original ROM`

## Current Status
- Bank FF label/comment pass is broadly complete for major systems.
- Next practical step is incremental C-port scaffolding with parity checks per subsystem.
