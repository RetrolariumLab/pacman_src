# Documentation Index

## Project

- [licensing.md](./licensing.md): distribution boundary and license status.
- [CONTRIBUTING.md](../CONTRIBUTING.md): local inputs and the change workflow.
- [retrolarium.md](./retrolarium.md): editing in Retrolarium Studio, its three
  revisions and `make studio-check`.
- [postmortem.md](./postmortem.md): why the earlier C reimplementation was
  removed.

## Source

- [source_layout.md](./source_layout.md): address-ordered module map and
  file-sizing rules.
- [bank_ff_map.md](./bank_ff_map.md): top-level bank segmentation.
- [ram_fields.md](./ram_fields.md): key RAM fields and their roles.
- [macros.md](./macros.md): allowed ca65 abstractions.
- [naming.md](./naming.md): symbol names and control-flow prefixes.
- [assembly_style.md](./assembly_style.md): ca65 layout, case, labels and
  comments.
- [unknowns.md](./unknowns.md): resolved research record and home for future
  findings.

## How the game works

- [script_states.md](./script_states.md): gameplay script state machine
  (`ram_script`).
- [movement_and_collisions.md](./movement_and_collisions.md): input, tile
  probes, stepping, wrap and collisions.
- [rendering_pipeline.md](./rendering_pipeline.md): animation, OAM composition
  and NMI PPU buffers.
- [gameplay_feature_map.md](./gameplay_feature_map.md): levels, enemies,
  bonuses and cutscenes.
- [ghost_ai.md](./ghost_ai.md): ghost states, targeting, movement and update
  pipeline.
- [score_and_bonus.md](./score_and_bonus.md): pellets, fruit, score and
  extra-life flow.
- [intermission_flow.md](./intermission_flow.md): intermission scripts and scene
  transitions.
- [sound_engine.md](./sound_engine.md): audio update loop, stream decoder and
  opcodes.
- [stage_params_and_data_tail.md](./stage_params_and_data_tail.md): stage
  tables, maze RLE, vectors and tail layout.

## Revisions and variants

- [multi_revision_builds.md](./multi_revision_builds.md): the seven official
  revisions from one source.
- [assets.md](./assets.md): the generated assets and how they are extracted.

## Checks

`make test` must pass after every change: among other things it rebuilds the
v1.0 ROM and requires it byte for byte. `make test-full` also plays the longplay
in MAME on a moved build (see the README).
