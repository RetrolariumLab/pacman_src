# Documentation Index

## Navigation
- [roadmap.md](./roadmap.md): project direction, evidence rules, milestones, and completion criteria.
- [source_reconstruction_2_0.md](./source_reconstruction_2_0.md): release scope and strict audit for authoring plus official revisions.
- [multi_revision_builds.md](./multi_revision_builds.md): verified official ROM profiles and the shared-source revision workflow.
- [goodnes_variant_notes.md](./goodnes_variant_notes.md): reproducible classification of overdumps, hacks, and structural derivative evidence.
- [unknowns.md](./unknowns.md): resolved reverse-engineering record and canonical home for future findings.
- [source_layout.md](./source_layout.md): address-ordered module map and file-sizing rules.
- [macros.md](./macros.md): allowed ca65 abstractions and byte-identity rules.
- [naming.md](./naming.md): semantic symbol names and control-flow prefixes.
- [debugger_workflow.md](./debugger_workflow.md): Mesen/FCEUX symbols, source navigation, breakpoints, and RAM watches.
- [runtime_trace_scenarios.md](./runtime_trace_scenarios.md): natural and controlled gameplay trace evidence.
- [scoring_trace_scenarios.md](./scoring_trace_scenarios.md): scoring-event capture and semantic validation.
- [validation.md](./validation.md): fast lint, unit, binary, debugger, and emulator validation layers.
- [data_formats.md](./data_formats.md): six decoded binary formats and byte-identical round-trip workflow.
- [source_reconstruction_1_0.md](./source_reconstruction_1_0.md): stable release contract, evidence matrix, and tagging procedure.
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
- [sound_authoring.md](./sound_authoring.md): variable-length streams, musical notes, MIDI import, and WAV preview.
- [maze_authoring.md](./maze_authoring.md): CHR-backed maze editing, fixed RLE export, and runtime landmark guards.
- [graphics_authoring.md](./graphics_authoring.md): reversible CHR pixel editing and actor metasprite inspection.
- [screen_authoring.md](./screen_authoring.md): title, text packet, HUD, and intermission visual editing.
- [stage_params_and_data_tail.md](./stage_params_and_data_tail.md): stage profile tables, maze RLE, vectors, tail layout.
- [assets.md](./assets.md): policy and reproducible extraction of opaque ROM assets.

## Verification Rule
After each edit batch:
- run `make verify`
- require `[OK] Byte-identical ROM reproduced from native ca65 source.`

## Project Snapshot
- `source-reconstruction-2.0` is the current tagged release.
- One shared source tree reproduces seven verified official ROM profiles.
- `make reconstruction-audit-2` is the strict release gate for the reference
  build, official revisions, runtime evidence, and authoring pipelines.
- Sound, maze, graphics, and screen editors are available as local Python tools;
  their JSON assets feed the isolated expanded NROM-256 build.
- The milestone-23 audit resolved every registered unknown; the registry retains
  their evidence histories and accepts future findings. A unified Qt editor is
  retained as a low-priority packaging improvement, not a release blocker.
