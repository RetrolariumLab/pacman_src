# GoodNES Variant Survey

This survey treats the local GoodNES collection as research evidence, not as
additional preservation targets. The ROM images remain ignored and are not
distributed. Re-run the inventory against any local collection with:

```text
python scripts/workflow/analyze_rom_collection.py \
  --collection "path/to/Pac-Man ROMs" \
  --manifest config/revisions.json \
  --reference-dir "path/to/official references" \
  --details
```

The tool parses the iNES container, separates PRG, CHR, and trailing bytes,
collapses mirrored 16 KiB overdumps, compares the vector-bearing high bank of
non-mirrored 32 KiB images, and selects the nearest verified official profile.
Counts are raw byte differences; aligned disassembly is still required before
interpreting a large relocated block as new logic.

## Survey Result

The inspected directory contained 41 images. It did not reveal another clean
official revision beyond the Milestone 21 matrix. It did expose several useful
classes of derivative:

- clean official images and container-only duplicates;
- CHR-only character/theme replacements;
- translations and title/attract text edits;
- tiny gameplay cheats;
- hacks combining presentation edits with small table/code changes;
- two unusual uses of normally unused or duplicated PRG space.

GoodNES `[o1]` is not evidence of another program revision here. The Japan V1.0
overdump is the same 16 KiB PRG mirrored to 32 KiB. USA Namco, licensed Tengen,
and unlicensed Tengen overdumps have an identical declared payload followed by
128 extra bytes. Several hack overdumps similarly add 127/128 bytes or mirror
the PRG without changing the effective game.

## Content-Only Hacks

Acid Hackman, Clyde's Revenge, Oct Man, Pak-azz, and Warman retain a byte-identical
PRG from their nearest official parent and change only CHR. Their changed CHR
counts range from 489 to 1,093 bytes. These images confirm that many theme hacks
need no engine change at all: the existing CHR/graphics pipeline is the correct
abstraction for them.

The Tengen `[b1]` image differs from the clean licensed release by only two CHR
bytes. It is a bad dump or damaged graphic, not a source revision. Japan `[p2]`
changes 34 title/copyright PRG bytes and 144 CHR bytes; it is a presentation
patch, not a distinct gameplay lineage.

## Small Program Edits

Japan V1.0 `[t1]` changes one PRG byte at CPU `$D2A4`: opcode `$85` becomes
`$A5`. In the preserved source this is the `STA ram_script` immediately after
`bra_trigger_player_death`. Replacing the store prevents the collision path
from selecting the death script, a compact invincibility cheat. This is a good
example of why a one-byte patch should be interpreted through semantic source,
not merely catalogued by checksum.

The French, Chinese, and Brazilian translations concentrate most PRG edits in
title/attract text packets and corresponding CHR glyphs. Sexual Pac-Man changes
55 PRG bytes in copyright/title/attract regions and no CHR. Remix, Transformers,
and Unicron also touch small scattered runtime/table locations, so they are
presentation hacks with limited program customization rather than evidence for
an unknown official branch.

## Structural Oddities

The image labelled Japan V1.0 `[p1]` is not a normal small pirate patch. Sequence
alignment preserves about 87% of the 16 KiB PRG but finds a 1,996-byte insertion
at `$F430`, inside the original game's unused tail. Its reset vector changes
from `$C033` to `$F600`, and the inserted bytes contain an `8 IN 1` selection
menu and multiple game names. This is multicart/bootstrap code grafted into free
space while the main Pac-Man body remains mostly in place. It demonstrates a
historical use for the same tail region that the source reconstruction deliberately
keeps visible, but it should not become an official revision profile.

Rush declares a 32 KiB NROM PRG. Its vector-bearing `$C000` bank remains close
to Japan V1.0 (192 changed PRG bytes), while the `$8000` and `$C000` banks differ
by only 89 bytes and both contain near-complete Pac-Man bodies. This looks like
two closely related program variants placed in one NROM-256 image, not the
clean free-bank asset architecture used by this project's expanded build. It
is useful comparative evidence that mapper 0 can expose a second 16 KiB bank,
but copying its duplicated-code layout would be a regression for authoring.

## Consequences for This Project

No surveyed hack should be added to the official revision tree. The useful
lessons are architectural:

1. keep container normalization separate from program lineage;
2. compare CHR independently so graphics-only hacks are immediately visible;
3. resolve tiny patches through symbols and source semantics;
4. retain the unused-tail map because historical derivatives placed bootstrap
   code there;
5. keep the expanded NROM-256 pipeline asset-oriented instead of duplicating
   the complete program bank;
6. use aligned comparison before judging any derivative with large raw diffs.

The local collection is therefore a reference corpus for future format and
hack research, not a backlog of revisions that must be reconstructed.
