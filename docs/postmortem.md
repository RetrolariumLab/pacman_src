# Postmortem: rewriting NES Pac-Man in C

This repository used to contain a C reimplementation of Pac-Man (NES, JP)
alongside the `bank_FF.asm` disassembly. The C code has been removed. This
document records why, so the conclusion outlives the code.

Short version: a literal 6502-to-C transfer produces a program that is slower,
larger and less verifiable than the assembly it came from, and it destroys the
one property that made this project checkable in the first place — byte-identity
with the original ROM.

## What was removed

```
decomp_bank_ff.c        3616 lines   Ghidra decompiler output of bank FF
src/**/*.c, *.h         1746 lines   hand-written cc65 baseline ("C0")
scripts/build.py                     legacy cl65 ROM build
scripts/build_repro_c_cc65*.py       Ghidra C -> cc65 build path
scripts/ghidra/*DecompC*, *Coverage* Ghidra C export and coverage tooling
bin/cc65.exe, bin/cl65.exe           C compiler binaries
```

What stays is the actual asset: the native assembly under `src/`, the FCEUX capture
and comparison automation in `scripts/`, the `movies/` input recordings,
`docs/`, and `bin/ca65.exe` + `bin/ld65.exe`.

## How far the C baseline actually got

Working, visually close to the original: title screen, main menu, attract
"character / nickname" screen, part of the chase demo.

Not working: the chase demo had sprite bugs (sprites disappearing, clipping,
wrong draw order), and gameplay was never playable. `game/ghosts.c`,
`game/pellets.c` were empty stubs, and `game/player.c` was a 50-line tile-grid
walker with a `move_cooldown` counter — nothing to do with the original's
sub-pixel movement, turn buffering or speed tables.

So: 1746 lines of C reproduced the front-end of a 9904-line disassembly, and the
front-end is the easy part. Everything expensive — ghost AI, scatter/chase
phases, the release counter pipeline, BCD scoring, intermissions, the sound
engine — was still ahead.

## Why it failed

### 1. No NMI. The whole frame loop was a busy-wait

The original drives everything from the NMI handler (`vec_nmi_handler`):
VBlank fires, the handler pushes the prepared PPU packets and OAM, then game
logic runs during the visible frame.

The C baseline had no interrupt handler at all. `main()` was:

```c
void main(void) {
    game_init();
    while (1) { game_frame(); }
}
```

and `game_frame()` ended with a polling `ppu_wait_vblank()` that spins on
`$2002`. Everything — logic, rendering, input — happened in one linear pass,
with VRAM writes racing the raster instead of being scheduled by it. This is
the root cause of the sprite bugs, not a detail on top of them.

### 2. The VBlank budget, and what happens when you give up on it

VBlank on NTSC NES is ~2273 CPU cycles — roughly 200 bytes of VRAM if you write
them with tight unrolled code. Everything the original does during a frame is
shaped by that number: it prepares small PPU packets during the visible frame
and pushes them in VBlank.

The baseline's gameplay renderer instead did this, **every single frame**:

```c
void render_gameplay_frame(void) {
    ppu_off();
    ppu_wait_vblank();
    render_title_scroll(0);
    upload_palettes();
    ppu_clear_nt(0x2000, 0x20);   /* 960 tiles + 64 attribute bytes */
    ppu_clear_nt(0x2400, 0x20);   /* again, second nametable        */
    maze_draw();
    pellets_draw();
    player_draw();
    ghosts_draw();
    ppu_on_bg();
}
```

Two full nametable wipes plus a maze redraw — on the order of 2000 VRAM writes
per frame, from nested C `for` loops, with rendering forced off for the whole
duration. That is not a frame update, it is a screen rebuild, and it is the
direct cause of the halved frame rate and the freezes on transitions. Same
pattern in `oam_clear()`: 256 bytes pushed through `$2004` in a loop with a
16-bit counter, where the hardware offers `$4014` OAM DMA for exactly this.

There was an attempt to do it properly — `ppu_queue.c` implements a 448-byte
PPU command buffer with `SET_ADDR`/`WRITE`/`FILL`/`WRITE_BLOCK` opcodes. But
`ppu_queue_flush()` was called from the main loop after a polling
`ppu_wait_vblank()`, drained the entire queue unconditionally, and had no notion
of a cycle budget: a full queue is more than twice what VBlank can absorb. So
the buffer discipline existed on paper and was overrun in practice.

The code has a comment admitting where that ended up:

```c
/* Final attract packet: big pellet + 10 PTS, 50 PTS, and NAMCO logo.
   Kept as direct PPU writes because helper-based writes missed vblank. */
```

That is the whole failure in one comment: a helper was replaced by hand-unrolled
register stores because the abstraction cost more cycles than the budget had.
Repeat that for every screen and you have written assembly with C syntax, and
paid the C overhead anyway.

### 3. cc65 codegen against a machine with no registers

The 6502 has A, X, Y and no general-purpose register file. cc65 keeps C locals
and expression temporaries in zero-page pseudo-registers, so ordinary C costs
several times what the equivalent hand-written 6502 costs:

- 16-bit loop counters (`unsigned int i` over 256 iterations) compile to
  two-byte increment-and-compare sequences where the original uses `DEX`/`BNE`;
- pointer selection at runtime — `pad_poll()` picks `&JOYPAD1_REG` or
  `&JOYPAD2_REG` with a ternary, then dereferences it eight times through an
  indirect load, where the original reads the port directly and rolls the result
  into a byte;
- struct-of-actors access becomes indexed pointer arithmetic through zero page,
  where the original uses parallel byte arrays with `LDA table,X`.

Measured result: roughly half the original's frame rate, with visible stalls and
freezes on screen transitions.

### 4. Decompiler output is not source code

`decomp_bank_ff.c` was Ghidra's decompilation of bank FF. It does not compile to
anything meaningful, and it is not readable either. The reset vector begins:

```c
void vec_RESET(void)
{
  do { } while (-1 < DAT_2002);
  sVar3 = CONCAT11((char)((ushort)&stack0x0000 >> 8),0xff);
  ...
  } while (cVar1 != '\b');
```

Three specific problems, all structural rather than cosmetic:

- **Hardware registers become opaque globals.** `$2002` is `DAT_2002`, an
  ordinary variable. The fact that reading it has the side effect of clearing
  the VBlank flag — which is the entire reason that loop exists — is gone.
- **Zero-page pointer pairs become `CONCAT11` noise.** The 6502 idiom of a
  16-bit pointer built from two zero-page bytes decompiles into synthetic
  concatenation intrinsics that no C compiler has.
- **Overlapping symbols.** Ghidra itself warns at the top of the file: *"Globals
  starting with '_' overlap smaller symbols at the same address."* Zero-page
  reuse — reading the same bytes as a byte pair here and a pointer there — has
  no C type that expresses it.

And data comes out as executable statements. Loading a binary asset — a maze
stream, a palette, a PPU packet — decompiles into several hundred lines of
sequential assignments. That is most of what those 3616 lines are.

### 5. It killed the verification story

The value of this repository is `make verify`: rebuild the ROM from
`src/main.asm` and assert **byte-identical to the original**. That is a real,
binary, unarguable pass/fail. Every annotation added to the disassembly is
checked by it.

A C build cannot have that property. cc65 chooses its own layout, so the output
is a different ROM by construction, and the only available check is fuzzy —
compare screenshots frame by frame and eyeball the diffs. The project traded a
provable invariant for a subjective one, and then spent its time debugging the
comparison harness instead of the game.

### 6. The original is timing-dependent by design

Where an NES game does something interesting, it usually does it by knowing
exactly how many cycles it has. Raster-timed writes, packet updates ordered to
fit the VBlank window, the frame pipeline order that the intermission code
depends on (see `docs/intermission_flow.md`: *"preserve frame pipeline order
from script10; changing order will desync OAM/logic"*). None of that survives a
translation into a language whose entire premise is that you do not control the
generated instruction sequence.

## The second attempt: `pacman_reimplementation`

Before this conclusion was reached, the same goal was attempted from the
opposite direction, in a separate repository: not a transfer of the
disassembly, but a **from-scratch reimplementation in C on top of
[`nes-starter-kit`](https://github.com/cppchriscpp/nes-starter-kit)** — neslib,
`create-nes-game` toolchain, famitracker audio, MMC1, the whole framework.

It went further on gameplay than the in-repo baseline did: title screen, the
original maze tile stream with correct palettes and attributes, real Pac-Man
sprites and animation, four-direction grid movement with wall collision and
buffered turns, pellets as level state with targeted VRAM clears. It still had
no ghosts, no scoring, no lives, no round flow, no frightened mode, no HUD — and
it did not reliably build.

The useful part is that both attempts failed the same way, from different
starting points. Starting from a framework does not help, because the framework
solves the generic problems (a build, a VBlank update queue, a sprite system)
while every remaining problem is Pac-Man-specific and lives in the exact timing
and layout of the original. You end up reimplementing the original's behaviour
by reading the disassembly anyway — at which point the disassembly is the thing
you actually have, and the C is a lossy copy of it that you cannot verify.

`pacman_reimplementation` is kept as a private reference next to this
repository rather than deleted; the two are a matched pair.

## The counter-evidence from the same author

Across the same set of projects, the split is clean:

| Approach | Projects | Result |
|---|---|---|
| Annotated disassembly, stays in asm | `alien_soldier_src`, `flicky_src`, `smb1_src`, `s1/s2/sk_improvements`, `sf1/sf2_fast_exp` | all work |
| Rewritten in C | `pacman_src` (C baseline), `pacman_reimplementation` | neither works |

Eight for eight against zero for two. The conclusion is not a feeling about
Pac-Man specifically.

## What this is *not* an argument for

It is not "C is unusable on the NES". New NES homebrew written in C with neslib,
designed around cc65's cost model from the start, ships and works. The claim is
narrower and stronger:

**Reproducing an existing, shipped, cycle-tuned assembly game by rewriting it in
C is the wrong move.** The original's correctness lives in its instruction
sequence and memory layout. C deliberately abstracts away both. So every detail
that matters has to be reintroduced by hand, in a language that fights you,
while giving up the byte-identity check that would have told you whether you got
it right.

If the goal is to *understand* the game: annotate the disassembly. If the goal
is to *modify* it: patch the disassembly and rebuild, verifying against the
original. If the goal is to write a Pac-Man-like game in C: write one, and stop
pretending it is a reproduction.

## What the project does now

- `src/main.asm` and its subsystem modules under `src/` are the source of truth.
- `make verify` must report byte-identity after every batch of edits.
- `scripts/` + `movies/` + `fceux_automation` provide frame-level regression
  capture against the original ROM.
- Target shape is `smb1_src`: disassembly, linker config, `ca65`/`ld65`,
  Makefile, docs. Nothing else.
