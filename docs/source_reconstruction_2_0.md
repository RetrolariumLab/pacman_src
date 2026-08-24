# Source Reconstruction 2.0

Source Reconstruction 2.0 extends the stable Japan V1.0 reconstruction without
changing its default preservation contract. The original profile remains a
byte-identical native ca65 build; the release adds reversible content-authoring
tools, an isolated expanded-ROM format, seven official byte-identical revision
profiles, and regional runtime gates.

ROM images and extracted proprietary assets remain ignored local inputs.

## Release Scope

| Capability | Evidence |
| --- | --- |
| Source Reconstruction 1.0 remains intact | `make reconstruction-audit`; `make verify` still selects Japan V1.0 |
| Content editing is reversible and isolated | Sound, maze, graphics, and screen studios; validated JSON codecs; `src/main_expanded.asm` |
| Expanded assets do not contaminate the original | NROM-256 build/verification/runtime targets and fixed-bank guards |
| Official revisions share one semantic source | Seven profiles in `config/revisions.json` and `docs/multi_revision_builds.md` |
| Every official profile is byte-identical | strict `make verify-revisions` layer in `make reconstruction-audit-2` |
| Late regional behavior boots correctly | USA Namco and Europe FCEUX title/NMI/OAM smoke checks |
| Derivatives are separated from official lineage | reproducible GoodNES survey in `docs/goodnes_variant_notes.md` |

The optional unified Qt Content Studio remains planned at low priority. The
four existing Python applications and their JSON formats are complete and
supported; Qt packaging is not a 2.0 release requirement.

## Reproducing the Release Audit

Place all seven exact local reference ROMs in one directory (the repository
root by default), prepare the ignored assets and FCEUX checkout, then run:

```text
make reconstruction-audit-2
```

This first runs the complete Source Reconstruction 1.0 audit, then requires all
seven official ROMs to pass full-file SHA-1 and byte-identical reconstruction,
and finally boots USA Namco and Europe in FCEUX. Both regional profiles must
reach the title menu with NMI active and retain the expected full shadow-OAM
fill at that boundary.

## Stable Tag Procedure

The reviewed release commit is fast-forwarded into `main`. Run
`make reconstruction-audit-2` on that exact clean commit and create the annotated
`source-reconstruction-2.0` tag. The tag must point directly at the audited main
commit, never an intermediate branch.
