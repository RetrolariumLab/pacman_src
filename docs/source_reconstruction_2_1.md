# Source Reconstruction 2.1

Source Reconstruction 2.1 closes the evidence work performed after 2.0 and
normalizes the repository interface without changing the reconstructed game.
It retains every preservation, authoring, revision, and runtime guarantee from
2.0, and adds the symbolic-relocation guarantee established during this release.

This is a backward-compatible refinement of the 2.0 contract, not a new
reconstruction generation. Historical 1.0 and 2.0 tags remain unchanged.

## Release Scope

| Capability | Contract |
| --- | --- |
| One canonical root entrypoint | `src/main.asm` is the only ASM file directly under `src/` |
| Variants are visibly isolated | Expanded and stage-5 entrypoints live under `src/expanded/` and `src/variants/` |
| Tool configuration is separate from source | ld65 layouts live under `config/linker/` |
| Tests are a first-class project interface | All unit and contract tests live under top-level `tests/` |
| Revision metadata has one owner | `config/revisions.json` selects ROM, hash, ca65 ID, and CHR source through `scripts/build_revision.py` |
| Every official profile has direct runtime evidence | `make smoke-revisions` builds and boots all seven revisions in FCEUX |
| Release tools are pinned | `config/toolchain.json` owns the versions, commits, and SHA-256 identities used by `make build-dev` |
| Multi-revision source is not mislabeled | `src/main.asm` contains semantic module order but no Japan-only address ranges |
| The release boundary is machine-readable | `config/source_reconstruction_2_1.json` and `make source-2-1-audit` |

Exact Japan V1.0 ranges remain available in `docs/source_layout.md`. They are
not duplicated next to shared include statements because other official
profiles can move the same semantic module boundaries.

## Delta Since Source Reconstruction 2.0

The complete history after predecessor commit
`ae136e1a7246f911e5280e8a7ad869b604bb9189` is represented by these reviewable
steps:

1. `Clarify current project boundaries`, `Refresh the project documentation`,
   and `Correct documentation review findings` aligned the public contract with
   the already accepted 2.0 capabilities.
2. `Resolve the remaining reconstruction unknowns` and `Harden reconstruction
   evidence validation` closed the registry and bound runtime results to exact
   scenarios, frames, and declared control patches.
3. `Enforce canonical assembly source style` and `Standardize contribution and
   label conventions` added safe formatting, naming policy, and complete label
   provenance without changing emitted bytes.
4. `Prove symbolic ROM relocation in FCEUX` added the canonical internal
   relocation regression proof; it does not claim cross-profile relocation.
5. The Source 2.1 release commit normalizes paths, makes revision builds
   manifest-driven, pins the toolchain, expands direct smoke coverage to all
   seven profiles, and adds the contract-revision-3 release audit.

The exact included and excluded capability IDs, evidence files, accepted
profiles, artifact hashes, and requirement statuses are owned by
`config/source_reconstruction_2_1.json`.

## Acceptance Gates

The fast structural contract is:

```text
make source-2-1-audit
```

The tag-ready aggregate is:

```text
make source-2-1-check
```

It retains the complete Source Reconstruction 2.0 gate, verifies and executes
the isolated hack and expanded layouts in FCEUX, runs symbolic relocation, then
validates the Source 2.1 manifest in tag-ready mode. ROMs and extracted assets
remain ignored local inputs.

The release manifest records the exact predecessor, included and excluded
scope, evidence-backed delta, artifact identities, direct per-profile runtime
coverage, toolchain manifest, licensing document, and pre/post-tag gates. The
auditor checks those semantics rather than treating a file-count threshold as
evidence of completeness.

The flat `scripts/` directory is a documented layout deviation. Exact paths are
still controlled by Make targets, Python syntax lint, import tests, and the
release audit. Moving them into packages would touch stable public workflows
without strengthening 2.1 evidence, so the coordinated migration is deferred.

## Tag Procedure

Run `make source-2-1-check` on the exact clean release commit while the future
tag is absent locally and on the publish remote. Create the annotated
`source-reconstruction-2.1` tag on that commit, then run
`make source-2-1-post-tag-audit`. The post-tag audit proves that the tag is an
annotated object and resolves to the tested `HEAD`.
