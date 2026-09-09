# Source Reconstruction 2.2

Source Reconstruction 2.2 is a tag-ready compatible-minor candidate over the
published Source Reconstruction 2.1 tag. It modernizes the repository without
changing the canonical Japan V1.0 image or weakening any accepted 2.1
guarantee.

The published `source-reconstruction-2.1` tag and its manifest remain immutable.
The exact predecessor is commit
`959bee80064aaa692e456cf710b527cc31bfba81`; all 2.2 work occurs after that
commit on a dedicated modernization branch.

## Current status

The release status is `tag-ready`. The project manifest and canonical
source-layout registry are present, every official revision publishes explicit
input/layout/output/capability contracts, and the accepted 2.1 guarantees have
a reusable predecessor gate. Generated results now stay under `build/`, private
editor documents stay under `content/workspace/`, and `make clean` is confined
to the canonical build root. The root Makefile is now the stable interface over
bounded authoring, runtime, and validation fragments. Tool package
paths are now frozen behind a stable dispatcher and an exhaustive responsibility
and test-owner registry; the non-package layout is a checked compatibility
deviation. Real-window interaction smokes now cover all four supported Studios
without modifying private workspace files. The project audit now checks the
complete Git range, exact delta-to-path mappings, non-empty commits, and
English-only public text. Text hygiene is independent of checkout newline
format, and regression coverage rejects a blank terminal line represented with
CRLF as well as LF. Runtime movie hashing and FCEUX playback now use one
canonical CRLF serialization even when the Git blob or checkout uses LF. The
reviewed documentation inventory covers every project document and the
attributed NESdev snapshot boundary, and the sole label-rename registry lives
under reconstruction configuration. The candidate remains untagged and
unpublished pending owner review.

## Accepted baseline

Source 2.2 inherits and must continue to execute all Source 2.1 guarantees:

- byte-identical reconstruction of all seven official profiles;
- direct FCEUX title/runtime smoke coverage for every profile;
- semantic runtime, scoring, and reconstruction-evidence scenarios;
- isolated fixed-layout and NROM-256 authoring variants;
- live debugger-symbol validation;
- canonical symbolic-relocation regression;
- pinned ca65, ld65, FCEUX, artifact, licensing, and provenance contracts.

The release manifest is `config/source_reconstruction_2_2.json`. It is a
self-contained statement of the public project boundary and records only the
delta after Source 2.1.

## Release completion

Release completion has two stateful steps:

1. run `make source-2-2-functional-check` while the manifest remains in
   `development`;
2. record the successful result in substantive candidate metadata and run
   `make source-2-2-check` from a clean build root.

Cross-profile relocation, a sibling engine, and a new platform/container ABI
remain excluded. The existing NROM-256 architecture predates this minor line
and remains isolated by `docs/adr/0001-expanded-nrom256.md`.

## Gate names

The fast contract and reusable complete functional gate are:

```text
make source-2-2-audit
make source-2-2-functional-check
```

The pre-tag and post-tag interfaces are:

```text
make source-2-2-check
make source-2-2-post-tag-audit
```

`source-2-2-check` removes the build root, executes the reusable accepted Source
2.1 baseline first, runs the complete 2.2 delta, removes generated output again,
and finally performs the pre-tag repository audit. A green collection of
narrower tests does not replace that aggregate gate.
