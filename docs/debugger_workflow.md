# Debugger Symbols and Source Navigation

The native build produces debugger artifacts from the same ca65 source that
reproduces the reference ROM. Generate the complete set with:

```bash
make symbols
```

The generated files under `build/` are local artifacts and are not committed:

- `pacman.nes` — byte-identical preservation ROM;
- `pacman.dbg` — ld65 symbols, source files, source lines, and spans for Mesen;
- `pacman.map` — verbose and stable linker map;
- `pacman.lbl` — VICE-format linker labels;
- `pacman.nes.0.nl` and `pacman.nes.ram.nl` — FCEUX ROM and RAM labels;
- `debug_symbols.json` — resolved breakpoint groups and RAM watch addresses.

## Mesen

Keep `pacman.dbg` next to `pacman.nes` with the same basename and open the ROM
in Mesen. In the debugger, named routines are available in the symbol list and
Source View maps instructions back to the corresponding files under `src/`.
The `.dbg` file contains the source paths recorded by ca65, so regenerate it
after moving the checkout or changing source line positions.

The linker first produces a bare 16 KiB PRG, while the debugger opens the final
iNES file. `scripts/debug_symbols.py` therefore retargets segment output names
to `pacman.nes` and adds the 16-byte iNES header to ld65 file offsets. Without
this normalization, source spans would point 16 bytes before the instructions
in the ROM file.

## FCEUX Automation Fork

`make symbols` puts `.nl` files beside the rebuilt ROM, which the project FCEUX
fork loads automatically. Open its debugger to use semantic ROM labels and add
RAM symbols from the generated RAM label file to watches.

The repository provides a repeatable runtime proof:

```bash
make validate-symbols
```

This builds the development emulator if necessary, checks eight representative
ROM/RAM symbol lookups through its Lua debugger API, and installs an execution
hook on `vec_nmi_handler`. Success means the emulator reached that named entry
within 120 frames. The artifact validator separately follows each key symbol's
ld65 definition record back to the exact source file and label line.

## Breakpoints and Watches

[`config/debugger_breakpoints.json`](../config/debugger_breakpoints.json)
defines named breakpoint groups for scripts, scoring, ghost decisions, PPU
work, and sound decoding. [`config/debugger_watches.json`](../config/debugger_watches.json)
defines the standard RAM watch groups for frame/script state, actors, scoring,
ghosts, PPU/OAM, and sound. Entries use semantic symbols rather than fixed
addresses.

Run `make symbols`, then read `build/debug_symbols.json` for the addresses
resolved against the current build. This keeps debugger setup reviewable while
avoiding hand-translated addresses that become stale after source changes.

## Validation Layers

```bash
make test-debug-symbols  # parser, iNES normalization, aliases, config errors
make symbols             # artifact and source-mapping validation
make validate-symbols    # live FCEUX lookup and named execution hook
make verify              # authoritative byte-identity gate
```

Mesen is the preferred interactive source-level debugger. The automated FCEUX
check is the reproducible runtime gate and does not replace a contributor's
normal interactive inspection session.
