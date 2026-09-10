# Licensing and Provenance

This repository documents a reconstruction and preservation workflow. It does
not distribute Pac-Man ROM images. Original ROMs, extracted
assets, generated builds, emulator traces, and local hack payloads are ignored
inputs or outputs and are not release artifacts.

The repository does not currently include an open-source license grant for its
project-authored source and tooling. In the absence of such a grant, normal
copyright restrictions apply; publication of the repository alone should not
be read as permission to redistribute or reuse those files. Namco, Nintendo,
Tengen, and other respective owners retain rights in the original game and its
assets.

The release manifest classifies each boundary explicitly:

| Component | Status | Redistribution boundary |
| --- | --- | --- |
| Project-authored tools and documentation | `license_not_granted` | Requires permission until an explicit license is added |
| Reconstructed game source | `license_not_granted` | Requires separate rights review; reconstruction does not grant rights in the original |
| Bundled cc65 executables | `unknown` in this project contract | Upstream provenance is pinned, but redistribution requires an upstream-license review |
| Imported disassembly-derived labels and notes | `unknown` | The imported baseline requires its own review; origin is recorded in `docs/provenance.md` |
| User-supplied ROMs and extracted inputs | `private_user_supplied` | Never distributed by this repository |
| External `fceux_automation` checkout | `external_unbundled` | Not distributed by this repository |

`config/toolchain.json` pins the cc65 and FCEUX versions, source commits, and
binary hashes. Those technical identities are independent of the licensing
classification. `config/source_reconstruction_2_1.json` is the machine-readable
owner of the component categories above and declares that private inputs are
not tracked.

Any future license decision must be explicit in a dedicated license file and
must account separately for project-authored work, third-party tools, imported
documentation, and rights in the original game data.
