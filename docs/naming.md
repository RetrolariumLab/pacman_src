# Symbol Naming

Symbol names describe program roles, not binary locations. ROM and RAM
addresses belong in linker configuration, constant values, comments, and map
files; they must not be used as identity inside a semantic symbol name.

## Code Symbols

6502 assembly has no `function` keyword. In this project, the control-flow
prefix states how a code label is entered:

| Prefix | Meaning |
|---|---|
| `sub_` | Callable subroutine entered with `JSR` and returned from with `RTS` |
| `handler_` | Entry selected by a jump table or another indirect dispatcher |
| `loc_` | Shared code entry reached with `JMP` |
| `bra_` | Internal branch target within a routine or handler |
| `vec_` | CPU vector entry point |

The source currently enforces this distinction: every `sub_` symbol has a
direct `JSR` caller, and every direct `JSR` target uses the `sub_` prefix.

Every colon label must begin with one of the code or data prefixes documented
on this page and use lowercase snake_case. Empty components, doubled
underscores, leading or trailing underscores, uppercase letters, and unprefixed
legacy names are rejected. This rule applies to labels only; uppercase hardware
and assembly-time constants keep their declared convention. Every colon label
must also be unique across the source tree.

Non-trivial subroutines should have a short contract when the evidence is
known:

```asm
; Update Pac-Man movement for the current frame.
;
; Inputs:
;   ram_btn_1p - current controller state
;
; Outputs:
;   Object position and direction may be updated.
;
; Clobbers:
;   A, X, Y
sub_update_pacman_movement:
```

Do not invent inputs, outputs, or clobbers merely to complete the template.

## Data Symbols

| Prefix | Meaning |
|---|---|
| `tbl_` | Indexed table or lookup data |
| `off_` | Addressable data block referenced through a pointer table |
| `ram_` | Persistent or domain-specific RAM field |
| `con_` | Assembly-time constant |
| `zp_` | Neutral zero-page workspace |
| `unused_` | Code or data proven unreachable for this ROM |

Shared zero-page workspace may use a neutral scratch name until each use has a
proven contextual alias. Unknown persistent state keeps an explicit unknown
marker until runtime evidence supports a semantic name; a plausible guess is
not sufficient.

## Rules

1. Prefer a role such as `sub_update_sound_engine` over a location such as
   `sub_EE5C`.
2. Include subsystem context when a short name would collide, for example
   `bra_return_from_oam_builder`.
3. Keep state numbers and opcode values only when they are part of the decoded
   format, such as `handler_script_0a_game_over`.
4. Preserve original-to-current names in
   `docs/provenance/label_renames.json`, and keep addresses in generated maps
   rather than inline provenance comments.
5. Every rename-only change must pass `make verify`; names must never affect the
   reproduced ROM.

The vocabulary is mandatory for every active colon label. `make lint` rejects
malformed or duplicate labels, lowercase definitions outside this vocabulary,
legacy `ofs_*` definitions, and address-derived identifiers. Uppercase hardware
names remain valid because they follow the conventional register/bit-mask style
in `src/memory/hardware.inc`. Rename a symbol only when control flow, data flow,
encoded structure, or runtime evidence supports the new role, then run both
`make lint` and `make verify`. Every rename must update the existing provenance
entry; every genuinely new label must add one `project_additions` record.
