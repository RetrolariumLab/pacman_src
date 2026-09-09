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
- A reviewer follows `licensing.md`, `provenance/README.md`, `unknowns.md`, and
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

`roadmap.md` is retained as a chronological planning and completed-milestone
ledger. It exceeds the normal document-size recommendation because splitting it
would obscure milestone ordering; current release instructions remain in the
short release and validation documents. The C rewrite postmortem remains a
standalone historical design analysis with a different audience from current
source architecture.

## Vendored Reference Boundary

`nesdev/` is reviewed as one attributed reference boundary. Its large topic
snapshots preserve primary-source context and are excluded from project-authored
size and filename-cluster rules. They do not define project behavior or release
status. `nesdev/README.md` records the attribution, refresh, licensing, and
ownership policy, while each content file retains its source URL.

The review found one misleading filename: the FDS format snapshot was stored as
`nesdev/docs.md`. It is now `nesdev/fds.md`, matching its actual subject. No
short, same-prefix project-document clusters required consolidation; all other
project documents have a distinct task, subsystem, or release lifecycle.
