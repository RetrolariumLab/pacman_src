# Optional ROM-Hack Variants

Optional variants are isolated from the default byte-identical build. The
default `make build` continues to assemble `src/main.asm`; `make verify` must
remain byte-identical to the reference ROM. A hack is selected only through the
explicit `src/main_hack.asm` entrypoint and writes all artifacts below
`build/hack/`.

## Default demonstration variant

The first variant starts a new game on stage 5. `src/main_hack.asm` defines
`PACMAN_HACK_START_STAGE = 5`; the guarded source operand stores stage 4 before
the original round-init increment. This changes no code size or addresses.

```text
make build-hack
make verify-hack
make validate-hack
make run-hack
```

`make verify-hack` compares the complete candidate ROM against the original and
accepts exactly the byte declared in `config/hack_variants.json`: PRG offset
`$09CE` changes from `$FF` to `$04`. Any additional PRG, CHR, or header change
fails. `make validate-hack` also replays the standard movie in FCEUX and proves
through semantic symbols that the first round enters stage 5.

`HACK_CHR` may point at an explicitly edited 8 KiB CHR file for exploratory
builds. Such a custom build is intentionally outside the default manifest and
will fail `make verify-hack` until its changes receive a separate reviewed
variant declaration.

## Adding variants safely

1. Keep preservation defaults outside every conditional block.
2. Select modifications only from an explicit hack entrypoint or feature flag.
3. Write outputs below a variant-specific build directory.
4. Declare and review every expected byte difference.
5. Run `make verify` as well as the variant-specific checks.
6. Add runtime evidence when a byte-level assertion does not prove behavior.

The original 16 KiB PRG has no free space. Same-size operand/table replacements
fit the current layout. Larger changes use the separately documented NROM-256
workflow in `docs/expanded_rom_assets.md`; that layout remains optional and
never becomes the default or weakens `make verify`.
