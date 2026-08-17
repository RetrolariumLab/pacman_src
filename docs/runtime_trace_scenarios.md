# Focused Runtime Trace Scenarios

Roadmap milestone 7 adds compact semantic traces for gameplay transactions that
are not specific to scoring. The trace captures state transitions and selected
execution hooks rather than screenshots or full memory dumps.

## Workflow

```text
make trace-runtime
make validate-runtime-traces
```

`make trace-runtime` rebuilds the byte-identical ROM, exports fresh debugger
symbols, and runs the scenarios declared in `scenarios/runtime_trace.json`.
Each scenario writes an ignored CSV under `tmp/runtime_traces/`; the target then
validates semantic invariants automatically. The second command revalidates
existing local traces without starting the emulator.

The CSV stores frame, event, compact detail, gameplay script, active player,
lives, stage, intermission scene/substate, four ghost states, scatter/chase
phase, and pause counter. Sound decode events store only the first occurrence
of each channel/byte pair.

## Natural-play evidence

`natural-longplay` replays `movies/pacman_j_longplay.fm2` without patches and
checks:

- death script to round initialization and READY respawn;
- each of the three initially housed ghosts transitioning `00 -> 02 -> 04`
  (in house, exiting, active);
- scatter/chase phase boundaries `00 -> 01 -> 02 -> 03` and execution of the
  shared ghost reversal routine;
- scene 0 intermission substates and return to round initialization;
- representative note (`00-BF`), duration (`C0-EF`), and control (`F0-FF`)
  sound bytes, including stop `$F0` and loop/restart `$F5`.

The existing scoring workflow remains authoritative for pellet, power-pellet,
four-ghost award, fruit, extra-life, and high-score transactions.

## Controlled scenarios

The repository movie does not naturally pause, switch players after a death,
or reach the second and third intermission scenes. Four separate runs cover
those paths without modifying the ROM:

- `pause-resume` injects two Start edges at the script04 input gate;
- `death-player-switch` enters the terminal death-animation step from stable
  live play and enables the documented two-player handoff path;
- `intermission-scene-1` changes the stage index at the first natural
  stage-clear entry to select scene 1;
- `intermission-scene-2` does the same for scene 2.

Every allowed address, semantic symbol, and reason is declared in the scenario
JSON. Each actual write is recorded as a `controlled_patch` event containing
address, old value, new value, and reason. Validation fails if the observed set
of patched addresses differs from the declaration, if a trace did not finish,
or if the expected state-machine path is absent.

These runs prove control flow from the explicitly patched state. They are not
evidence that ordinary play produced that state. All scenarios use the
preservation ROM and exact FM2 SHA-1 values recorded in the configuration; the
runner rejects either input if its digest differs. Generated traces stay ignored
because they are reproducible evidence artifacts rather than source.
