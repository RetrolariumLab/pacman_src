# Licensing and Provenance

This repository documents a reconstruction and preservation workflow. It does
not distribute Pac-Man ROM images. Original ROMs, extracted assets, generated
builds and local hack payloads are ignored inputs or outputs and are not release
artifacts.

The repository does not currently include an open-source license grant for its
project-authored source and tooling. In the absence of such a grant, normal
copyright restrictions apply; publication of the repository alone should not
be read as permission to redistribute or reuse those files. Namco, Nintendo,
Tengen, and other respective owners retain rights in the original game and its
assets.

Each boundary, explicitly:

| Component | Status | Redistribution boundary |
| --- | --- | --- |
| Project-authored tools and documentation | `license_not_granted` | Requires permission until an explicit license is added |
| Reconstructed game source | `license_not_granted` | Requires separate rights review; reconstruction does not grant rights in the original |
| cc65 executables (from Retrolarium Kit) | `external_unbundled` | Not distributed by this repository; the kit pins them |
| Imported disassembly-derived labels and notes | `unknown` | The imported baseline (see the README's credits) requires its own review |
| User-supplied ROMs and extracted inputs | `private_user_supplied` | Never distributed by this repository |

`config/toolchain.json` pins the cc65 versions and binary hashes. Those
technical identities are independent of the licensing classification.

Any future license decision must be explicit in a dedicated license file and
must account separately for project-authored work, third-party tools, imported
documentation, and rights in the original game data.
