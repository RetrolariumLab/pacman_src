# Source Provenance

The canonical [`label_renames.json`](../config/reconstruction/label_renames.json)
registry maps every active colon label in the imported `bank_FF.asm` baseline to
its current semantic name and module. The source baseline is pinned to commit
`95cff8bc55bd1c6cbf4570091e40a12a1474222e` so its identity does not depend on
the mutable upstream branch.

Only labels active when `bank_FF.asm` entered this repository are source names.
Earlier `was:` comments and project-internal intermediate names are excluded.
The registry records current labels without a source label as
`project_additions`, including their introducing commit and reason.

Current paths are navigation hints, not stable identities. Tests require each
mapped target and project addition to exist exactly once across active ASM and
INC modules without relying on source line numbers.
