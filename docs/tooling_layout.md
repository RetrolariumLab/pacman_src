# Tooling Layout and Ownership

The stable project interface is the root `Makefile`. For direct Python use,
`scripts/run.py` is the stable dispatcher: `python scripts/run.py list` prints
the supported command names and `python scripts/run.py <command> [arguments]`
forwards arguments from the project root.

`make help` is rendered from `config/make_help.json`. `make help-check` proves
that every `.PHONY` target is either documented once or explicitly hidden as an
internal/compatibility target. `make scaffold-check` copies only tracked and
non-ignored files into a disposable Git checkout, proves that no ROM, extracted
asset, workspace, or build output crossed that boundary, and runs synthetic
tests plus real `help-check`, `tool-list`, and `source-2-2-audit` Make commands.
The separate `make ui-smoke` workstation gate exercises actual Studio windows;
its contract-only `make ui-smoke-check` form is safe inside the ROM-less gate.

`config/tooling_layout.json` is the machine-readable ownership contract. Every
tracked Python or Lua file below `scripts/` belongs to exactly one of these
responsibilities:

- `build` assembles, compares, splits, and describes cartridge artifacts;
- `authoring` owns codecs, headless editor models, and workstation Studios;
- `validation` owns lint, identity checks, symbols, and release audits;
- `runtime` owns emulator capture and behavioral validation;
- `workflow` owns reverse-engineering analysis and reporting;
- `launcher` owns the stable direct-tool dispatcher.

Each responsibility names its test owners. Every command exposed by the stable
dispatcher additionally names one specific test owner. The Source 2.2 audit
compares the registry with the complete `.py`/`.lua` inventory and rejects
missing, stale, multiply owned, or untested public entries.

The registry also enforces the guide's 700-line Python review threshold and the
600-line test-module threshold. The two current oversized workflow/contract
tools carry explicit cohesion and split decisions; a new oversized tool cannot
appear without an equally reviewable exception.

## Physical layout

Tool files live under `scripts/authoring/`, `scripts/build/`,
`scripts/runtime/`, `scripts/validation/`, and `scripts/workflow/`. Tests mirror
those responsibilities below `tests/`. Only the stable `scripts/run.py`
dispatcher remains at the scripts root. Make targets and documentation use the
category paths directly, while the dispatcher provides stable command names.

## Adding or changing a tool

1. Assign every new Python or Lua file to one responsibility in
   `config/tooling_layout.json`.
2. Add or update a test owner. If the tool is a stable direct command, add one
   `public_commands` entry and a focused launcher/test-owner check.
3. Prefer project-root defaults derived from `__file__`, validate inputs before
   subprocess execution, and keep generated output under `build/`.
4. Run `make tool-list`, `make test`, `make lint`, and
   `make source-2-2-audit`.
