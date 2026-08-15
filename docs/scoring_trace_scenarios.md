# Scoring Trace Scenarios

The scoring trace records semantic execution hooks and a compact RAM snapshot;
it does not store full emulator dumps. Scenario definitions and their required
event order live in `scenarios/scoring_trace.json`.

## Workflow

```text
make trace-scoring
make validate-scoring-trace
```

The first command builds the byte-identical ROM, plays the repository longplay
in the instrumented FCEUX build, and writes `tmp/scoring_trace.csv`. The second
checks the event sequence and its semantic RAM invariants. Both the trace and
any patched save states remain local artifacts under the ignored `tmp/`
directory.

Before capture, the workflow verifies that both Lua runtime DLLs exist beside
FCEUX and that every hard-coded execution hook still matches its symbol in the
fresh linker label file. It removes an old CSV before launch and fails after
emulation if a new non-empty trace was not produced.

Each CSV row contains the frame, event name, pending/current/high-score BCD
digits, lives, extra-life latch, pellet count, frightened mask, and ghost-chain
count. Hooks are attached to preserved CPU addresses for:

- power-pellet and common pellet handling;
- confirmed actor collisions and frightened-ghost awards;
- fruit awards;
- the shared score commit.

Frame sampling additionally records changes to score, high score, lives, and
the extra-life latch.

The repository longplay was exercised through 120,000 frames with this workflow.
All six scenarios in `scenarios/scoring_trace.json` passed value-aware checks in
the unpatched byte-identical build. These include exact pending BCD awards,
ghost-chain indices, fruit stage mapping, the extra-life latch/lives transition,
and equality after high-score promotion. The generated CSV remains a local
artifact; rerunning the two commands above reproduces the evidence check.

## Evidence rules

Natural longplay observations are preservation-build evidence. A rare scenario
may instead start from a controlled save-state or RAM patch, but the trace must
then be accompanied by a note containing:

- base ROM SHA-1;
- movie/save-state identity and starting frame;
- every patched address with old and new values;
- why the state cannot reasonably be reached in the current movie;
- which observations depend on the patch.

A patched result can confirm control flow from the patched state. It must not be
reported as evidence that ordinary play naturally produced that state.

## Scenarios

### Normal pellet

Observe `pellet -> score_commit -> score_changed`. The commit snapshot should
contain pending digit 0 equal to 1, corresponding to 10 displayed points.

### Power pellet

Observe `power_pellet -> pellet -> score_commit -> score_changed`. The common
pellet entry should see pending digit 0 equal to 5, and the frightened mask
should be initialized before the score transaction completes.

### Four-ghost chain

Observe four `ghost_award -> score_commit` pairs without another power-pellet
reset. `kill_count` advances from 0 through 4 and the pending awards represent
200, 400, 800, and 1600 points.

### Fruit award

Observe `actor_collision -> fruit_award -> score_commit -> score_changed`.
The pending indexes 1 and 2 identify the stage-indexed award documented in
`docs/score_and_bonus.md`.

### Extra life threshold

Observe `score_commit -> score_changed -> extra_life_awarded` while crossing
10,000 points. The lives value increments and
the extra-life latch changes from zero to one exactly once.

### High-score promotion

Observe `score_commit -> score_changed -> hiscore_changed`. The high-score BCD
snapshot must match the promoted player score after the frame completes.
