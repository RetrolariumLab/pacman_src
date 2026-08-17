# Bank FF Docs Index

## Navigation
- [roadmap.md](./roadmap.md): project direction, evidence rules, milestones, and completion criteria.
- [unknowns.md](./unknowns.md): canonical reverse-engineering backlog and evidence experiments.
- [source_layout.md](./source_layout.md): address-ordered module map and file-sizing rules.
- [macros.md](./macros.md): allowed ca65 abstractions and byte-identity rules.
- [naming.md](./naming.md): semantic symbol names and control-flow prefixes.
- [debugger_workflow.md](./debugger_workflow.md): Mesen/FCEUX symbols, source navigation, breakpoints, and RAM watches.
- [runtime_trace_scenarios.md](./runtime_trace_scenarios.md): natural and controlled gameplay trace evidence.
- [validation.md](./validation.md): fast lint, unit, binary, debugger, and emulator validation layers.
- [data_formats.md](./data_formats.md): six decoded binary formats and byte-identical round-trip workflow.
- [preservation_source_1_0.md](./preservation_source_1_0.md): stable release contract, evidence matrix, and tagging procedure.
- [rom_hack_variants.md](./rom_hack_variants.md): isolated optional builds, declared ROM differences, and runtime validation.
- [expanded_rom_assets.md](./expanded_rom_assets.md): NROM-256 layout and editable JSON-to-ROM asset pipeline.
- [postmortem.md](./postmortem.md): why the C reimplementation was removed and what replaced it.
- [bank_ff_map.md](./bank_ff_map.md): top-level bank segmentation and annotation entry points.
- [ram_fields.md](./ram_fields.md): key RAM fields and runtime roles.
- [script_states.md](./script_states.md): gameplay script state machine (`ram_script`).
- [movement_and_collisions.md](./movement_and_collisions.md): input buffering, tile probes, stepping, tunnel wrap, and actor collisions.
- [rendering_pipeline.md](./rendering_pipeline.md): actor animation, overlap ordering, OAM composition, and NMI PPU buffers.
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
- Systematic subsystem documentation (roadmap milestone 5) is complete across
  all seven planned subsystem passes.
- Native ca65 source is split into semantic subsystem directories under `src/`,
  with `src/main.asm` retaining the modules' address order.
- Debugger symbols and source-level navigation (roadmap milestone 6) are
  available through `make symbols` and validated at runtime with
  `make validate-symbols`.
- Focused runtime traces (roadmap milestone 7) cover lifecycle, ghost releases,
  mode changes, intermissions, pause/player handoff, and sound byte classes via
  `make trace-runtime`.
- Automated source and documentation checks (roadmap milestone 8) are available
  through the fast `make lint` and aggregate `make test` gates.
- Six binary format families (roadmap milestone 9) have documented JSON codecs
  and byte-identical verification through `make roundtrip-formats`.
- Preservation Source 1.0 (roadmap milestone 10) is release-candidate complete;
  `make preservation-audit` reproduces its full validation matrix.
- Optional ROM-hack variants (roadmap milestone 11) use separate entrypoints,
  outputs, byte-diff manifests, and FCEUX behavior checks.
- The expanded NROM-256 variant (roadmap milestone 12) adds a free 16 KiB bank
  and consumes an explicitly initialized editable maze JSON asset.
