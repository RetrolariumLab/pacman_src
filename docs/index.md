# Documentation Index

## Releases and Project Policy

- [source_reconstruction_1_0.md](./source_reconstruction_1_0.md): preservation contract, evidence matrix, and tag procedure.
- [source_reconstruction_2_0.md](./source_reconstruction_2_0.md): authoring and official-revision release scope.
- [source_reconstruction_2_1.md](./source_reconstruction_2_1.md): compatible delta and aggregate acceptance gates.
- [source_reconstruction_2_2.md](./source_reconstruction_2_2.md): compatible-minor project contract and modernization boundary.
- [roadmap.md](./roadmap.md): project direction, evidence rules, and completion criteria.
- [validation.md](./validation.md): lint, unit, identity, debugger, runtime, and release layers.
- [licensing.md](./licensing.md): distribution boundary, license status, and third-party provenance.
- [CONTRIBUTING.md](../CONTRIBUTING.md): local inputs, change workflow, commit rules, and required gates.
- [postmortem.md](./postmortem.md): why the C reimplementation was removed and what replaced it.

## Source Architecture and Evidence

- [source_layout.md](./source_layout.md): address-ordered module map and file-sizing rules.
- [bank_ff_map.md](./bank_ff_map.md): top-level bank segmentation and annotation entry points.
- [ram_fields.md](./ram_fields.md): key RAM fields and runtime roles.
- [macros.md](./macros.md): allowed ca65 abstractions and byte-identity rules.
- [naming.md](./naming.md): semantic symbol names and control-flow prefixes.
- [assembly_style.md](./assembly_style.md): mechanically enforced ca65 layout, case, labels, and comments.
- [tooling_layout.md](./tooling_layout.md): stable dispatcher, responsibility ownership, test owners, and recorded layout deviations.
- [provenance/README.md](./provenance/README.md): imported-label provenance policy and complete rename map.
- [unknowns.md](./unknowns.md): resolved research record and canonical home for future findings.
- [relocation_testing.md](./relocation_testing.md): progressively shifted ROM and semantic FCEUX proof.

## Runtime and Game Subsystems

- [debugger_workflow.md](./debugger_workflow.md): symbols, source navigation, breakpoints, and RAM watches.
- [runtime_trace_scenarios.md](./runtime_trace_scenarios.md): natural and controlled gameplay evidence.
- [scoring_trace_scenarios.md](./scoring_trace_scenarios.md): scoring-event capture and semantic validation.
- [script_states.md](./script_states.md): gameplay script state machine (`ram_script`).
- [movement_and_collisions.md](./movement_and_collisions.md): input, tile probes, stepping, wrap, and collisions.
- [rendering_pipeline.md](./rendering_pipeline.md): animation, OAM composition, and NMI PPU buffers.
- [gameplay_feature_map.md](./gameplay_feature_map.md): levels, enemies, bonuses, and cutscenes.
- [ghost_ai.md](./ghost_ai.md): ghost states, targeting, movement, and update pipeline.
- [score_and_bonus.md](./score_and_bonus.md): pellets, fruit, score, and extra-life flow.
- [intermission_flow.md](./intermission_flow.md): intermission scripts and scene transitions.
- [sound_engine.md](./sound_engine.md): audio update loop, stream decoder, and opcodes.
- [stage_params_and_data_tail.md](./stage_params_and_data_tail.md): stage tables, maze RLE, vectors, and tail layout.

## Profiles, Variants, and Authoring

- [multi_revision_builds.md](./multi_revision_builds.md): seven official profiles and shared-source workflow.
- [goodnes_variant_notes.md](./goodnes_variant_notes.md): classification of overdumps, hacks, and derivatives.
- [rom_hack_variants.md](./rom_hack_variants.md): isolated optional builds and declared differences.
- [expanded_rom_assets.md](./expanded_rom_assets.md): NROM-256 editable-asset pipeline.
- [adr/0001-expanded-nrom256.md](./adr/0001-expanded-nrom256.md): rationale and isolation boundary for expansion.
- [data_formats.md](./data_formats.md): six decoded formats and exact round trips.
- [assets.md](./assets.md): policy and reproducible extraction of opaque assets.
- [sound_authoring.md](./sound_authoring.md): variable-length streams, MIDI import, and WAV preview.
- [maze_authoring.md](./maze_authoring.md): CHR-backed editing, RLE export, and runtime guards.
- [graphics_authoring.md](./graphics_authoring.md): reversible CHR and actor-mapping editing.
- [screen_authoring.md](./screen_authoring.md): title, text, HUD, and intermission editing.

## Verification Rule
After each edit batch:
- run `make verify`
- require `[OK] Byte-identical ROM reproduced from native ca65 source.`

## Project Snapshot
- Source Reconstruction 2.1 is the current release contract; its annotated tag
  is verified separately by the post-tag audit.
- One shared source tree reproduces seven verified official ROM profiles.
- `make source-2-1-check` is the strict pre-tag release gate for the reference
  build, all official revisions, runtime evidence, relocation, and authoring
  pipelines; `make source-2-1-post-tag-audit` verifies the resulting tag.
- Sound, maze, graphics, and screen editors are available as local Python tools;
  their JSON assets feed the isolated expanded NROM-256 build.
- The milestone-23 audit resolved every registered unknown; the registry retains
  their evidence histories and accepts future findings. A unified Qt editor is
  retained as a low-priority packaging improvement, not a release blocker.
