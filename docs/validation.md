# Validation Workflow

The source reconstruction uses separate validation layers so fast structural
checks do not silently grow into emulator runs.

```text
make format               # normalize ca65 assembly source style, then lint
make lint                 # assembly style, tracked text, naming, docs, Python syntax
make docs-audit           # documentation inventory, links, sizes, and reader journeys
make test                 # all focused Python workflow unit tests
make verify               # authoritative byte-identical ROM gate
make roundtrip-formats    # six binary format decode/encode checks
make validate-symbols     # live debugger-symbol lookup and execution hook
make trace-runtime        # slower focused emulator evidence
make trace-scoring        # slower scoring-event capture
make trace-evidence       # focused evidence for resolved registry entries
make test-relocation      # progressively shifted ROM and emulator gates
make reconstruction-audit # complete Source Reconstruction 1.0 release gate
make reconstruction-audit-2 # strict seven-revision and regional runtime gate
make source-2-1-audit     # fast repository-layout and release-manifest contract
make source-2-1-check     # complete tag-ready Source Reconstruction 2.1 gate
make source-2-1-post-tag-audit # verify annotated tag identity against HEAD
make verify-hack          # exact manifest-declared default variant difference
make validate-hack        # default variant behavior in live FCEUX
make verify-expanded      # all NROM-256 assets and fixed-bank operands
make validate-expanded    # expanded-asset consumption in live FCEUX
```

## Fast lint

`make format` normalizes every `.asm` and `.inc` file under `src/`, then runs
the complete fast lint. The formatter standardizes indentation, mnemonic and
directive case, comment spacing, blank lines, and LF endings; it does not edit
operands, symbols, or non-assembly files.

`make lint` first checks that assembly source already has the canonical style,
then checks every tracked or unignored source file and reports all violations
in one run. Together these layers enforce:

- UTF-8 text, no trailing whitespace, and exactly one final newline;
- no repeated blank-line runs in assembly source;
- the ASM module size budget;
- approved evidence tags and valid unknown-registry references;
- no legacy `bzk` or `ofs_*` definitions;
- no address-derived active symbol names;
- role-prefixed lowercase snake_case and globally unique colon labels;
- complete machine-readable provenance for every active colon label;
- direct `JSR`/`sub_` consistency;
- symbolic NES hardware operands;
- backticked semantic symbols and relative links in project-authored docs;
- complete documentation inventory, reader journeys, size exceptions, and filename clusters;
- syntax parsing of every tracked Python file.

Every `docs/*.md` file belongs to the reviewed project corpus described by
`documentation_architecture.md` and `config/documentation_layout.json`.

## Unit tests

`make test` discovers every `tests/test_*.py` module. Narrow targets
such as `make test-debug-symbols` and `make test-runtime-traces` remain useful
during development, but the aggregate target is the pre-commit gate. Tests use
small synthetic inputs and do not start FCEUX.

## Binary and runtime gates

`make verify` remains authoritative for preservation: it must reproduce the
reference PRG and ROM hashes exactly. Debugger and trace targets are separate
because they build or start external tooling and take longer. A green lint or
unit-test run never substitutes for byte identity or behavioral evidence.

`make test-relocation` complements byte identity with a deliberately mutated
layout. It inserts 29 non-executed `$EA` bytes between address-ordered modules,
checks every resulting symbol offset and fixed-tail pointer, then runs debugger,
runtime, scoring, and reconstruction-evidence workflows against the same ROM.
See `relocation_testing.md` for the anchor policy and limitations.

## Reconstruction release gates

`make reconstruction-audit` runs lint, all focused unit tests, byte identity and
format round-trips, live debugger validation, then fresh runtime and scoring
captures with their semantic validators. It intentionally regenerates ignored
evidence under `build/runtime/`; a stale local trace therefore cannot make the release
gate pass. Run it on the exact commit intended for the stable tag.

`make reconstruction-audit-2` adds strict verification and a direct FCEUX
title/OAM smoke for every official revision profile. Unlike the convenient
standalone matrix commands, the release gate treats every missing reference ROM
as a failure. `make build-dev` first verifies the pinned ca65, ld65, FCEUX source
commit, and FCEUX binary identities from `config/toolchain.json`.
Every native build entrypoint also authenticates the manifest-selected ca65 and
ld65 binaries by SHA-256 and exact version before assembly begins. The builders
do not fall back to unverified executables from `PATH`.
The revision Lua hook records raw menu/NMI/OAM facts, while the Python runner
owns the manifest comparison and PASS/FAIL decision.

`make source-2-1-check` adds both isolated variant runtimes, symbolic relocation,
and the clean-worktree release contract. After creating the annotated tag on
that exact commit, `make source-2-1-post-tag-audit` confirms its object type and
that it resolves to `HEAD`.

## Reconstruction evidence

`make trace-evidence` runs the full natural longplay plus a controlled pause
probe and then validates the results against static ROM facts. The gate covers
the actor-state array member at `$00C0`, shared-state ownership by script,
personal-release latch consumers, all 16 sound request slots, attract sprite
strip selection, and the pre-reset copyright block. It also binds each CSV to
its declared scenario and exact frame range, rejects undeclared memory patches,
and requires sound slot 0F to activate between the controlled pause and resume.
Traces remain ignored under `build/runtime/reconstruction_evidence/`;
`make validate-evidence` rechecks an existing set.

## Optional variant gates

Variant validation is additive: it never replaces `make verify` or
`make reconstruction-audit`. `make verify-hack` requires the complete ROM diff to
match `config/hack_variants.json`; `make validate-hack` then loads symbols for
that candidate and proves its intended stage-5 start in FCEUX. See
`docs/rom_hack_variants.md` for the isolation and review policy.

The expanded variant adds two more layers. `make verify-expanded` requires a
two-bank mapper-0 header, the declared CHR, contiguous manifest-declared maze,
stage, sound, actor, palette, and screen assets, `$FF` free space, and the exact
reviewed set of fixed-bank operand changes. Then `make validate-expanded` uses
generated symbols and FCEUX to prove stage 2 selects its maze at `$82D6`, loads
second-level stage tuning from `$81A0`, advances pellet slot 04 through the
JSON-generated sound table at `$848F`, applies the live 32-byte palette, and
renders the JSON title-logo tile.
