# Source Reconstruction 1.0

Source Reconstruction 1.0 is the stable, behavior-preserving reconstruction of
`Pac-Man (J) (V1.0) [!]`. Its default build is native ca65 source and must
remain byte-identical to the reference ROM. The release does not claim that
every original implementation detail is known; it claims that uncertainty is
explicit and that the documented source can be inspected, rebuilt, debugged,
and changed safely.

## Release criteria and evidence

| Criterion | Evidence |
| --- | --- |
| Major routines have purpose and calling contracts | Address-ordered modules under `src/`; naming and documentation checks in `make lint` |
| RAM, constants, state machines, and tables are documented | `docs/ram_fields.md`, subsystem documents, `src/memory/`, and `docs/data_formats.md` |
| Unresolved behavior is explicit | Stable IDs, evidence, hypotheses, and experiments in `docs/unknowns.md`; registry references enforced by lint |
| Source-level debugger navigation works | ld65/FCEUX artifacts from `make symbols`; live lookup and semantic NMI break from `make validate-symbols` |
| Main gameplay transactions have focused evidence | Five runtime trace configurations cover nine semantic checks documented in `docs/runtime_trace_scenarios.md`; six scoring scenarios are documented in `docs/scoring_trace_scenarios.md` |
| A subsystem can be changed in isolation | `docs/source_layout.md`, subsystem index in `docs/index.md`, bounded semantic modules, and format-specific JSON codecs |
| The default build remains preservation-safe | `make verify` checks reference PRG and ROM SHA-1 values; generated JSON and trace artifacts remain ignored |

At the 1.0 milestone, open entries in `docs/unknowns.md` were not release
blockers: neutral names and bounded hypotheses were preferable to unsupported
certainty. Milestone 23 subsequently resolved that backlog while preserving
each entry's evidence history.

## Reproducing the release audit

Prerequisites are the original ROM, extracted local assets, Python, the bundled
ca65/ld65 tools, and a usable `fceux_automation` checkout. Then run:

```text
make reconstruction-audit
```

The command performs, in order:

1. source, naming, documentation, link, and Python lint;
2. all focused workflow unit tests;
3. byte-identical native ROM build and six format round-trips;
4. live FCEUX symbol lookup and named NMI breakpoint validation;
5. fresh capture from five runtime trace configurations and validation of nine
   focused semantic checks;
6. fresh scoring capture and semantic validation of six scoring scenarios.

Passing only an individual layer is insufficient for a stable release. Runtime
captures are regenerated into ignored `tmp/` output by the aggregate target so
previous local evidence cannot mask a regression.

## Stable tag procedure

The milestone commit is first reviewed and merged into `main`. Run the complete
audit on that exact merge result, verify the worktree is clean, and then create
the annotated `source-reconstruction-1.0` tag. The tag must identify the reviewed
`main` commit; it must not point at an intermediate milestone branch.

Behavior-changing work begins only after that tag and uses an explicit build
variant. The default `make build` and `make verify` targets continue to represent
the preserved original ROM.
