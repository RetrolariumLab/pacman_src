# Official ROM Revision Builds

Milestone 21 extends the preservation source to verified official Pac-Man ROM
revisions without weakening the Japan V1.0 reference build. ROM images remain
local inputs and are never distributed by this repository.

## Build Interface

The default `make build` and `make verify` commands always target Japan V1.0.
An official revision is selected explicitly:

```text
make build-revision REVISION=japan_v11
make verify-revision REVISION=japan_v11
```

Every revision assembles the single `src/main.asm` entrypoint. The build passes
the selected `PACMAN_REVISION` profile to ca65 as a compile-time definition.
Revision differences must be represented as semantic source alternatives:
text, constants, RAM layout, code, tables, or vectors. Raw binary patches are
not accepted.

## Verified Local Reference Matrix

These hashes were calculated from clean GoodNES `[!]` images. Full-ROM hashes
include the 16-byte iNES header.

| Profile | GoodNES filename | PRG CRC32 | PRG SHA-1 | CHR CRC32 | Full ROM SHA-1 | Build status |
| --- | --- | --- | --- | --- | --- | --- |
| `japan_v10` | `Pac-Man (J) (V1.0) [!].nes` | `BB1B591B` | `20f0fc7664983b5d4f166866302f1ad20efb727d` | `49ABEEE6` | `adb4d7d7d28c89ca177aad231e0fdad992c0fbfb` | byte-identical |
| `japan_v11` | `Pac-Man (J) (V1.1) [!].nes` | `2BF9D836` | `160920895ec9ff4ed832cd16c9b2be5352feebae` | `49ABEEE6` | `b8be2bffb4592873cc211becb529bf64071c7f90` | byte-identical |
| `europe` | `Pac-Man (E) [!].nes` | `6FA1193B` | `8fef2bdce0c0be2ece67b26587aa22097ba3c9cf` | `19C4AA76` | `feb45bcbcd2326c14280db17330b665ec6adc0cc` | structural analysis |
| `usa_namco` | `Pac-Man (U) (Namco) [!].nes` | `347D7D34` | `aa1bba9a243c70eb4e9928b5efec9d4877579d08` | `ED9E2130` | `e7d818e128593109b5c480497a050facc0744f1b` | structural analysis |
| `usa_tengen` | `Pac-Man (U) (Tengen) [!].nes` | `E35321BC` | `5dd6d83b9827793f1da12923f2212e4d7502cf9a` | `49ABEEE6` | `727176933c25de055e7daa92e8b943f67cae4d9b` | structural analysis |
| `usa_tengen_unlicensed` | `Pac-Man (Unl) (Tengen) [!].nes` | `7154ACB5` | `799b199bdb43fe5f97a37bd37294802515a13dfa` | `49ABEEE6` | `f1d9eb92f931ed925bd6119d00d1023a45da583f` | structural analysis |

The known Japan Rev B PRG (`B6214FA9`) is not present in the current local ROM
set and therefore cannot become a verified build target yet.

## Proven Japan V1.1 Differences

Japan V1.1 changes eight PRG bytes in two semantic locations:

- seven bytes correct `CHRACTER` to `CHARACTER` in the attract header while
  preserving the packet length;
- one operand byte moves `ram_sound_channel_state` from `$0625` to `$0620`.

Both alternatives live in shared source and are selected by
`PACMAN_REVISION`. There is no post-link patching.

## Structural Comparison Method

A raw same-offset diff is not a useful measure for the regional releases. A
small insertion or reordered table changes later instruction operands,
pointers, and branch destinations even when gameplay logic is unchanged.

Analysis proceeds in this order:

1. align identical PRG byte blocks independently of their original offsets;
2. transfer known V1.0 code/data boundaries and semantic symbols;
3. normalize control-flow operands and compare instruction sequences;
4. separate relocated code from changed text, graphics, timing, and logic;
5. use runtime code/data coverage and an interactive disassembler only for
   ambiguous regions;
6. express proven differences in shared ca65 source and require a byte-exact
   build against the matching local ROM.

Sequence alignment already accounts for 92.5% to 95.8% of each regional PRG.
The licensed and unlicensed Tengen PRGs match in 16,328 of 16,384 aligned
bytes. Their 56 real byte differences are the Nintendo license text, a small
licensed boot stub at `$FF00`, and its reset-vector selection.
