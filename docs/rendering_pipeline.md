# Actor Animation, OAM, and Buffered PPU Updates

The gameplay renderer is a producer/consumer pipeline. Mainline code selects
animation frames, copies logical positions into a sprite staging area, builds
shadow OAM, and appends PPU commands. NMI transfers shadow OAM and consumes the
PPU buffers during vblank.

## Per-Frame Order

On an unpaused gameplay frame, movement precedes animation. After collision
handling, `sub_prepare_sprite_positions` copies object records to sprite staging,
may reorder an overlapping ghost ahead of Pac-Man, rebuilds tile-probe
addresses, and tail-jumps to OAM composition. At the next NMI:

1. the previously built shadow OAM page is transferred by OAM DMA;
2. score, 1UP, power-pellet, and generic PPU buffers are flushed;
3. cached tile addresses are sampled;
4. scroll and PPUCTRL are restored;
5. controller input is latched.

This ordering means shadow OAM and PPU command RAM are ownership boundaries
between mainline and NMI code.

## Actor Animation Selection

Pac-Man's base frame is derived from direction. Its phase normally advances
each update; when centered against a blocked forward tile, only the low two
phase bits are reused, preserving the stopped-mouth behavior. A six-entry phase
LUT and two terminal closed-mouth phases produce the final frame index.

Ghost animation uses bit 3 of the global frame counter as a two-frame phase.
Each slot is dispatched by ghost state:

- in-house, exiting, and active use direction-based body frames;
- a frightened slot uses the frightened base plus the global phase;
- returning eyes use one frame per direction;
- eaten-score state leaves the existing frame untouched.

## Sprite Staging and Overlap Ordering

Thirty-six bytes of object positions are copied to `ram_spr_position`. The
routine then scans selected non-frightened ghost staging records against
Pac-Man. Candidates pass X/Y windows below 25 pixels and a preserved narrow
combined-distance gate. On the first accepted overlap, position, sprite-set,
and attribute records are swapped so OAM ordering changes together. As in the
gameplay collision check, the original carry behavior is part of the gate and
must not be replaced by a generic distance helper without trace evidence.

## OAM Composition

Six actor groups are emitted as four 8x8 sprites each. Each OAM entry has
Y/tile/attribute/X fields; a zero staged coordinate hides that axis at `$FF`.
The shared quad offsets place tiles at `(Y+3 or Y+11, X-12 or X-4)`.

The high mode bits of `ram_actor_sprite_set` choose among four table pairings:
standard tiles/attributes, alternate tiles/attributes, tile offsets, or
attribute offsets. `ComposeActorOamEntry` combines the selected frame with a
quad index and merges per-actor attribute bits. These modes are data-layout
contracts, not interchangeable visual styles.

## PPU Buffer Formats

`sub_write_buffer_to_ppu` runs in NMI. Outside demo mode it first consumes the
fixed-width score and high-score buffers, marking each first byte `$FF` after
use, and updates the blinking 1UP field every eight frames. Demo mode skips
those HUD paths.

Power-pellet marker tiles are always written to four fixed addresses selected
for the active player's nametable. The generic main buffer then contains zero
or more commands:

```text
[PPU address high][PPU address low][payload bytes...][$00] ... [$FF]
```

`$00` ends one command and `$FF` ends the entire stream. Once consumed, `$FF`
is stored at the first byte. Payload therefore cannot represent tile `$00` in
this format. Producers that append commands must preserve an existing final
`$FF` and enough room for the new command.

## Preservation Invariants

- Keep movement -> animation -> collision -> staging/OAM order unchanged.
- Keep mainline/NMI ownership and the one-frame shadow-buffer boundary explicit.
- Preserve overlap scan order and arithmetic carry behavior.
- Emit six groups of four OAM entries with the existing offset and mode tables.
- Preserve demo-mode HUD suppression and player-two nametable selection.
- Never place `$00` in a generic PPU-command payload; retain `$00` command and
  `$FF` stream terminators.
- Restore scroll and PPUCTRL after NMI PPU reads/writes.
