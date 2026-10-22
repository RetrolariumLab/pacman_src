# Official ROM Revision Builds

The shared source builds all seven official Pac-Man revisions, each byte for
byte. ROM images remain local inputs and are never distributed by this
repository; `assets/manifest.json` names each by file, size and SHA-1 (its
image id is the revision's name).

All revisions share one iNES header, which the source writes. `make split`
cuts three CHRs (v1.0's, which five revisions share, Namco's USA one and the
European one) and v1.0's maze and sound streams, which every revision takes.
So every build needs the v1.0 ROM, plus the revision's own ROM for Namco's USA
and the European release.

## Build Interface

`make build` and `make verify` take `REVISION=<id>` (v1.0 unless given) and
build `src/revisions/<id>.asm`, which sets `PACMAN_REVISION` and includes
`src/main.asm`; `make verify-revisions` verifies every revision whose ROM is
here. Revision differences must be represented as semantic source
alternatives: text, constants, RAM layout, code, tables, or vectors. Raw
binary patches are not accepted.

`src/revisions/profile_ids.inc` names the revisions, and
`src/revisions/derived_flags.inc` derives the broader Tengen, RAM-palette, and
late-Namco feature flags used by shared conditional source.

| Revision | ROM | CHR |
| --- | --- | --- |
| `japan-v10` | `Pac-Man (J) (V1.0) [!].nes` | v1.0 |
| `japan-v11` | `Pac-Man (J) (V1.1) [!].nes` | v1.0 |
| `japan-revb` | `Pac-Man (Japan) (En) (Rev B).nes` | v1.0 |
| `usa-tengen-unlicensed` | `Pac-Man (Unl) (Tengen) [!].nes` | v1.0 |
| `usa-tengen` | `Pac-Man (U) (Tengen) [!].nes` | v1.0 |
| `usa-namco` | `Pac-Man (U) (Namco) [!].nes` | its own |
| `europe` | `Pac-Man (E) [!].nes` | its own |

## Revision Family Tree

This tree describes relationships proven by aligned code, shared data layouts,
and the byte-identical source alternatives. It is a structural family tree, not
a claim about Namco's unreleased source-control history.

```text
Shared original game core
|
+-- Early Japanese line
|   `-- Japan V1.0 (preservation baseline)
|       `-- Japan V1.1 / Rev A
|           corrected CHARACTER text + relocated sound-channel RAM
|
`-- Later regional architecture
    RAM-backed palette queues + relocated regional code/data
    |
    +-- Japan Rev B
    |   Japanese presentation on the later rendering architecture
    |
    +-- Tengen branch
    |   +-- USA Tengen, unlicensed
    |   `-- USA Tengen, Nintendo-licensed
    |       unlicensed program + license text + reset trampoline/vector
    |
    `-- Namco 1993 branch
        +-- USA Namco
        |   extended title delay + USA reset sequence
        `-- Europe PAL
            compact title flow + 50 Hz movement profiles + PAL OAM hiding
```

The arrows and nesting are intentionally conservative. Japan V1.1 is a direct
eight-byte refinement of V1.0, and licensed Tengen is a small, clearly bounded
variant of the unlicensed Tengen program. Rev B, Tengen, and the 1993 Namco
releases share later architecture, but are shown as sibling branches where the
binary evidence does not establish a unique chronological parent. USA Namco
and Europe are likewise sibling regional variants of their shared 1993 branch.

## Proven Japan V1.1 Differences

Japan V1.1 changes eight PRG bytes in two semantic locations:

- seven bytes correct `CHRACTER` to `CHARACTER` in the attract header while
  preserving the packet length;
- one operand byte moves `ram_sound_channel_state` from `$0625` to `$0620`.

Both alternatives live in shared source and are selected by
`PACMAN_REVISION`. There is no post-link patching.

Japan Rev B belongs to the later regional code family rather than being a
small continuation of Japan V1.1. It shares the RAM-backed palette queues and
related rendering paths with Tengen, while retaining the Japanese title and
attract text, controller mask, and maze blank tile. Its attract attribute
table and corrected `CHARACTER` heading are selected independently.

The USA Namco release is another member of the later regional family. It adds
Namco's 1993 title sequence and localized ghost names, uses a dedicated title
delay state, and places the active maze-data pointer at `$FFF6` while retaining
a legacy vector word at `$FFF8`. Its regional CHR is read from the selected
local reference ROM; both the reconstructed PRG and complete ROM are verified
byte for byte.

The European release shares the 1993 Namco copyright, localized attract text,
RAM-backed palette queues, and regional CHR, but not the longer USA title delay
or reset sequence. Its PAL-specific paths initialize hidden shadow-OAM entries
to `$EF` during boot, title, READY, round setup, and normal gameplay. Five
movement profiles are scaled for the 50 Hz frame rate. These differences remain
semantic source alternatives, and the complete European ROM is byte-identical.

## Structural Comparison

A raw same-offset diff is not a useful measure for the regional releases: a
small insertion changes later operands, pointers and branch targets even when
the logic is unchanged. Aligned, 92.5% to 95.8% of each regional PRG matches
v1.0.
The licensed and unlicensed Tengen PRGs match in 16,328 of 16,384 aligned
bytes. Their 56 real byte differences are the Nintendo license text, a small
licensed boot stub at `$FF00`, and its reset-vector selection.

The first Tengen structural insertion is 104 bytes immediately after the NMI
handler. It conditionally uploads two 16-byte palettes from RAM at `$0299` and
`$02A9`, then resets their markers. Later common code resumes with a `+107`
address delta before subsequent regional edits change that displacement.
