# Validation Workflow

The source reconstruction uses separate validation layers so fast structural
checks do not silently grow into emulator runs.

```text
make lint                 # tracked text, source, naming, docs, Python syntax
make test                 # all focused Python workflow unit tests
make verify               # authoritative byte-identical ROM gate
make roundtrip-formats    # six binary format decode/encode checks
make validate-symbols     # live debugger-symbol lookup and execution hook
make trace-runtime        # slower focused emulator evidence
make trace-scoring        # slower scoring-event capture
make reconstruction-audit # complete release-candidate gate, including captures
make verify-hack          # exact manifest-declared default variant difference
make validate-hack        # default variant behavior in live FCEUX
make verify-expanded      # NROM-256 layout, fixed-bank boundary, JSON maze
make validate-expanded    # expanded-bank access in live FCEUX
```

## Fast lint

`make lint` checks every tracked or unignored source file and reports all
violations in one run. It enforces:

- UTF-8 text, no trailing whitespace, and exactly one final newline;
- no repeated blank-line runs in assembly source;
- the ASM module size budget;
- approved evidence tags and valid unknown-registry references;
- no legacy `bzk` or `ofs_*` definitions;
- no address-derived active symbol names;
- lowercase symbol prefixes from `docs/naming.md`;
- direct `JSR`/`sub_` consistency and unique callable labels;
- symbolic NES hardware operands;
- backticked semantic symbols and relative links in project-authored docs;
- syntax parsing of every tracked Python file.

The imported `docs/nesdev/` reference snapshot is checked as UTF-8 text but is
excluded from project documentation reference checks because it retains source
wiki syntax and external link conventions. README and all other `docs/*.md`
files remain in scope.

## Unit tests

`make test` discovers every `scripts/tests/test_*.py` module. Narrow targets
such as `make test-debug-symbols` and `make test-runtime-traces` remain useful
during development, but the aggregate target is the pre-commit gate. Tests use
small synthetic inputs and do not start FCEUX.

## Binary and runtime gates

`make verify` remains authoritative for preservation: it must reproduce the
reference PRG and ROM hashes exactly. Debugger and trace targets are separate
because they build or start external tooling and take longer. A green lint or
unit-test run never substitutes for byte identity or behavioral evidence.

## Preservation release gate

`make reconstruction-audit` runs lint, all focused unit tests, byte identity and
format round-trips, live debugger validation, then fresh runtime and scoring
captures with their semantic validators. It intentionally regenerates ignored
evidence under `tmp/`; a stale local trace therefore cannot make the release
gate pass. Run it on the exact commit intended for the stable tag.

## Optional variant gates

Variant validation is additive: it never replaces `make verify` or
`make reconstruction-audit`. `make verify-hack` requires the complete ROM diff to
match `config/hack_variants.json`; `make validate-hack` then loads symbols for
that candidate and proves its intended stage-5 start in FCEUX. See
`docs/rom_hack_variants.md` for the isolation and review policy.

The expanded variant adds two more layers. `make verify-expanded` requires a
two-bank mapper-0 header, unchanged CHR, contiguous manifest-declared JSON
assets, `$FF` free space, and the exact reviewed set of fixed-bank operand
changes. Then `make validate-expanded` uses generated symbols and FCEUX to
prove stage 2 selects its maze at `$82D6`, loads second-level stage tuning from
`$81A0`, and advances pellet slot 04 through the JSON-generated sound table at
`$848F`.
