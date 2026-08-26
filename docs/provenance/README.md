# Source Provenance

`label_renames.json` maps every active colon label in the imported
`bank_FF.asm` directly to its current semantic name and module. The source side
is pinned to repository commit `95cff8bc55bd1c6cbf4570091e40a12a1474222e`,
which preserves the imported file independently of the mutable upstream branch.

Only labels that were active when `bank_FF.asm` entered this repository are
treated as source names. Any `was:` comments already present in that file belong
to its earlier external history and are intentionally excluded.

Project-internal intermediate names are also omitted. The separate
`project_additions` collection records current labels that had no active source
label, together with the commit that introduced each one and a short reason.

Current file paths are navigation hints rather than stable identities. Tests
require every mapped target and project addition to exist exactly once across
all active ASM and INC modules, without relying on fragile source line numbers.
