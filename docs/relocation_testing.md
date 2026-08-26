# Relocation Testing

The byte-identical build proves the reconstructed source matches the reference,
but it does not prove that symbolic addresses remain correct when the layout
changes. `make test-relocation` builds one deliberately shifted Japan V1.0 ROM
and exercises it in FCEUX.

## Mutation Model

The generated entrypoint contains 29 non-executed `$EA` bytes:

- one immediately after the fixed-bank `.org $C000`, before the unreferenced
  copyright payload;
- one after each active ASM module except `audio/streams.asm`, before the next
  module begins;
- none inside a routine, loop, table, or the fixed tail.

Each inter-module anchor follows either data or an unconditional transfer such
as `RTS`, `RTI`, or `JMP`. The probe bytes therefore change addresses without
adding executed CPU cycles. The first active module moves by one byte, each
following module moves by one additional byte, and `audio/streams.asm` moves by
29 bytes. Existing `$FF` padding absorbs the probes. The pointer at `$FFF8` and
the hardware vectors at `$FFFA..$FFFF` remain fixed and are rebuilt from the
relocated symbols.

The temporary source, manifest, ROM, labels, map, and debug data are written
under `build/relocation/`. No compile-time conditionals or probe bytes enter the
normal source tree or the byte-identical output.

## Validation

The target runs the regular lint and unit-test suites, then compares base and
candidate symbols. It requires every active label to move by the cumulative
offset of its owning module, finds all 29 `$EA` bytes immediately before their
intended modules, verifies that padding shrank by exactly 29 bytes, and checks
the rebuilt maze pointer and three vectors. All runtime scenarios also install
execute hooks at the 29 probe addresses and fail if any supposedly hidden byte
is reached.

The same candidate then passes every emulator workflow applicable to the base
ROM:

1. live FCEUX symbol lookup and an NMI execution breakpoint;
2. all natural and controlled runtime scenarios;
3. a 120,000-frame natural longplay with periodic liveness heartbeats and four
   observed rounds;
4. all six semantic scoring scenarios;
5. both resolved-reconstruction evidence scenarios.

The scoring hooks resolve semantic debugger symbols at runtime. They contain no
fixed ROM addresses, so the same trace script works for the reference and
relocated builds.

## Interpretation

A passing relocation test is strong evidence that code, tables, dispatch
vectors, and cross-module references use assembler symbols rather than hidden
ROM addresses. It is not a cycle-accuracy mutation test. Executed `NOP`
instructions are intentionally excluded because they can consume frame budget
or desynchronize an otherwise valid frame-based movie.

Pac-Man also has no conventional final ending. The longplay proves sustained
play through four rounds and continued semantic activity near its final frame;
it does not exhaust every possible stage, score, or two-player state.
