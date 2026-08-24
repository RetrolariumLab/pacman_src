# Official ROM Revision Builds

Milestone 21 extends the preservation source to verified official Pac-Man ROM
revisions without weakening the Japan V1.0 reference build. ROM images remain
local inputs and are never distributed by this repository.

Profiles whose CHR differs from the preservation baseline reuse those bytes
directly from the selected local reference ROM during assembly. They do not
copy regional graphics into the repository or its generated asset directory.

## Build Interface

The default `make build` and `make verify` commands always target Japan V1.0.
An official revision is selected explicitly:

```text
make build-revision REVISION=japan_v11
make verify-revision REVISION=japan_v11
make verify-revision REVISION=usa_tengen_unlicensed REVISION_REFERENCE_DIR="path/to/roms/"
make verify-revision REVISION=usa_tengen REVISION_REFERENCE_DIR="path/to/roms/"
make verify-revision REVISION=japan_revb REVISION_REFERENCE_DIR="path/to/roms/"
make verify-revision REVISION=usa_namco REVISION_REFERENCE_DIR="path/to/roms/"
make verify-revision REVISION=europe REVISION_REFERENCE_DIR="path/to/roms/"
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
| `japan_revb` | `Pac-Man (Japan) (En) (Rev B).nes` | `B6214FA9` | `1b66f8ac67c1e72ca4ec97494fb06aaeb05cd68d` | `49ABEEE6` | `8b874a704e37557941179b232bac41644f6d01fc` | byte-identical |
| `europe` | `Pac-Man (E) [!].nes` | `6FA1193B` | `8fef2bdce0c0be2ece67b26587aa22097ba3c9cf` | `19C4AA76` | `feb45bcbcd2326c14280db17330b665ec6adc0cc` | byte-identical |
| `usa_namco` | `Pac-Man (U) (Namco) [!].nes` | `347D7D34` | `aa1bba9a243c70eb4e9928b5efec9d4877579d08` | `ED9E2130` | `e7d818e128593109b5c480497a050facc0744f1b` | byte-identical |
| `usa_tengen` | `Pac-Man (U) (Tengen) [!].nes` | `E35321BC` | `5dd6d83b9827793f1da12923f2212e4d7502cf9a` | `49ABEEE6` | `727176933c25de055e7daa92e8b943f67cae4d9b` | byte-identical |
| `usa_tengen_unlicensed` | `Pac-Man (Unl) (Tengen) [!].nes` | `7154ACB5` | `799b199bdb43fe5f97a37bd37294802515a13dfa` | `49ABEEE6` | `f1d9eb92f931ed925bd6119d00d1023a45da583f` | byte-identical |

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

The reproducible first-pass report is generated without copying a ROM into the
repository:

```text
python scripts/workflow/analyze_revision_alignment.py \
  --reference "path/to/Pac-Man (J) (V1.0) [!].nes" \
  --candidate "path/to/Pac-Man (Unl) (Tengen) [!].nes"
```

Sequence alignment already accounts for 92.5% to 95.8% of each regional PRG.
The licensed and unlicensed Tengen PRGs match in 16,328 of 16,384 aligned
bytes. Their 56 real byte differences are the Nintendo license text, a small
licensed boot stub at `$FF00`, and its reset-vector selection.

The first Tengen structural insertion is 104 bytes immediately after the NMI
handler. It conditionally uploads two 16-byte palettes from RAM at `$0299` and
`$02A9`, then resets their markers. Later common code resumes with a `+107`
address delta before subsequent regional edits change that displacement.
