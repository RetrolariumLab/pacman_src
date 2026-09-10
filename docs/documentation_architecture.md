# Documentation Architecture and Review

The documentation is organized around reader tasks rather than the order in
which reconstruction work happened. `README.md` gives the legal-input boundary
and shortest verification path, while `docs/index.md` routes readers to release
policy, source architecture, runtime behavior, authoring, and provenance.

## Reader Journeys

- A builder starts with the repository README, then uses `validation.md` and
  the applicable release document for the complete gate.
- A source contributor reads `source_layout.md`, `naming.md`,
  `assembly_style.md`, and the relevant subsystem document before changing ASM.
- An authoring-tool contributor starts with `data_formats.md`, follows the
  format-specific authoring document, and checks `expanded_rom_assets.md`.
- A reviewer follows `licensing.md`, `provenance.md`, `unknowns.md`, and
  the release documents to distinguish imported facts from project claims.

These journeys and the exact Markdown inventory are checked from
`config/documentation_layout.json` so new or orphaned documents cannot bypass
review.

## Corpus Review Decisions

The subsystem documents remain separate because gameplay movement, rendering,
audio, scoring, intermissions, and stage data have distinct code owners and
validation evidence. `bank_ff_map.md` is a compact bank-navigation entry point;
`source_layout.md` owns module sizing and complete address-range ownership, so
their scopes are complementary rather than duplicate.

The authoring documents remain separate by codec and workstation task. Release
documents also remain separate because each is the stable record for a specific
accepted or candidate boundary. Their shared filename prefix is intentional and
is declared as the only project-document prefix exception.

The NROM-256 decision is part of `expanded_rom_assets.md`, alongside the build
layout and verification consequences it governs. Keeping that decision with
the live expanded-ROM workflow prevents a short architectural note from
drifting away from its implementation contract. Imported-label origin and
rename policy remain concise in the top-level `provenance.md`; the JSON registry
under `config/reconstruction/` is the sole machine-readable mapping.

`roadmap.md` is retained as a chronological planning and completed-milestone
ledger. It exceeds the normal document-size recommendation because splitting it
would obscure milestone ordering; current release instructions remain in the
short release and validation documents. The C rewrite postmortem remains a
standalone historical design analysis with a different audience from current
source architecture.

No short, same-prefix project-document clusters require consolidation. Every
current document has a distinct task, subsystem, or release lifecycle, and the
inventory contains no vendored documentation boundary.
