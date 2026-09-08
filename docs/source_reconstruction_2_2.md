# Source Reconstruction 2.2

Source Reconstruction 2.2 is a compatible-minor development line over the
published Source Reconstruction 2.1 tag. It modernizes the repository without
changing the canonical Japan V1.0 image or weakening any accepted 2.1
guarantee.

The published `source-reconstruction-2.1` tag and its manifest remain immutable.
The exact predecessor is commit
`959bee80064aaa692e456cf710b527cc31bfba81`; all 2.2 work occurs after that
commit on the `source-reconstruction-2.2` branch.

## Current status

The release status is `development`. The project manifest and canonical
source-layout registry are present, every official revision publishes explicit
input/layout/output/capability contracts, and the accepted 2.1 guarantees have
a reusable predecessor gate. Generated results now stay under `build/`, private
editor documents stay under `content/workspace/`, and `make clean` is confined
to the canonical build root. The root Makefile is now the stable interface over
bounded authoring, runtime, and validation fragments. Tool paths are now frozen
behind a stable dispatcher and an exhaustive responsibility
and test-owner registry; the non-package layout is a checked compatibility
deviation. Clean release sequencing, UI smoke coverage, and the complete
project release audit are not yet complete. No 2.2 tag should be created
until every planned requirement is satisfied and the full pre-tag gate passes
from a clean build on the supported Windows host.

## Accepted baseline

Source 2.2 inherits and must continue to execute all Source 2.1 guarantees:

- byte-identical reconstruction of all seven official profiles;
- direct FCEUX title/runtime smoke coverage for every profile;
- semantic runtime, scoring, and reconstruction-evidence scenarios;
- isolated fixed-layout and NROM-256 authoring variants;
- live debugger-symbol validation;
- canonical symbolic-relocation regression;
- pinned ca65, ld65, FCEUX, artifact, licensing, and provenance contracts.

The development manifest is `config/source_reconstruction_2_2.json`. It is a
self-contained statement of the public project boundary and records only the
delta after Source 2.1.

## Planned repository delta

The remaining compatible work is organized as vertical, testable slices:

1. separate reusable functional gates from pre-tag and post-tag repository
   state checks, and require a clean build for the release path;
2. add workstation UI interaction smokes for the supported Studios;
3. validate history, delta, paths, profile coverage, artifacts, and tag state in
   the Source 2.2 release audit.

Cross-profile relocation, a sibling engine, and a new platform/container ABI
remain excluded. The existing NROM-256 architecture predates this minor line
and remains isolated by `docs/adr/0001-expanded-nrom256.md`.

## Gate names

During development, the fast contract is:

```text
make source-2-2-audit
```

The final interfaces will be:

```text
make source-2-2-check
make source-2-2-post-tag-audit
```

`source-2-2-check` must first execute the reusable accepted Source 2.1 baseline,
then the complete 2.2 delta, and finally the pre-tag audit. A green collection
of narrower tests does not replace that aggregate gate.
