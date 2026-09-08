# Workstation UI Interaction Smoke

`make ui-smoke` is the Windows workstation gate for the four supported Tk
authoring applications. It opens real Sound, Maze, Graphics, and Screen Studio
windows, renders their widget trees, and exercises the release-facing actions
declared in `config/authoring/ui_smokes.json`.

The gate covers:

- open and render for every Studio;
- a valid edit and save through each application's view/controller;
- Sound Studio WAV preview;
- Maze undo/redo and Graphics undo;
- build-button dispatch with the expected Make target and path selectors;
- dirty-close cancellation followed by confirmed close.

Build dispatch is intercepted by the smoke runner after the application has
formed the real command. Full expanded-ROM build and FCEUX behavior are proved
separately by `make validate-expanded`; this test owns the workstation UI
interaction boundary.

The runner reads private inputs but never edits them. Writable JSON/CHR copies,
the WAV preview, and `report.json` are created below `build/ui_smoke/`, so
`make clean` removes the complete result. `make ui-smoke-check` validates the
manifest and entrypoints without opening a display or requiring private inputs;
the ROM-less scaffold gate invokes that contract-only form.

The release gate runs the interaction form on the declared supported Windows
host. A missing display, missing input, failed action, unsafe output path, or
unexpected close is a failure rather than a skip.
