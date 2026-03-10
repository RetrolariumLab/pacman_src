# Gameplay Feature Map (Bank FF)

High-level map for the systems we care about before C porting.
Addresses are from `bank_FF.asm`.

## Level Flow
- `C98A..CA1E`: gameplay loop shell + script dispatch (`ram_script`).
- `CE35..CFFA`: round init (`script 00`), maze/HUD setup, READY stage.
- `CA9D..CC0E`: READY phase (`script 02`) and handoff to active gameplay.
- `CA1F..CC0E`: active frame driver (`script 04`) including pause gate.
- `CCE6..CD60`: stage clear (`script 0C`) with next-stage/intermission branch.

## Enemies (Ghost AI)
- `D4C2..D87E`: main ghost slot update, state dispatch, movement and turn choice.
- `D87F..D8C8`: state06-only ghost pass.
- `D6E3..D78B`: turn decision and target direction selection.
- `D78C..D87E`: per-state speed profile/vector setup.
- `D8C9..D937`: house counters + anim frame selection.

## Power Pellets / Frightened Mode
- `D0EF..D196`: round timers and frightened counters maintenance.
- `DFC6..E05A`: enter frightened mode, palette command append, optional ghost reversal.
- `E05B..E05F`: frightened palette command bytes.

## Bonuses / Fruits / Score
- `DEDF..DF68`: pellet consumption detection and clear progression.
- `DFBE..DFC5`: fruit sprite tile by stage.
- `E060..E147`: pending score apply, 1UP threshold, hiscore compare/promote.
- `E13A..E143`: life icon PPU packet templates.
- `E53B..E654`: stage fruit-history HUD drawing.

## Player / Movement / Collisions
- `D2FB..D4C1`: Pac-Man movement and demo input script path.
- `D20F..D2FA`: actor collision checks and state transitions (`script 06/08`).
- `E154..E21B`: object tile-probe address generation for movement/collision logic.
- `E1DD..E21B`: world XY to nametable address conversion helpers.

## Intermissions (Cutscenes)
- `E655..E74A`: intermission setup (`script 0E`).
- `E74B..E9A4`: intermission runtime (`script 10`) scene dispatch and completion.
- `EA20..EB41`: intermission animation dispatch tables.

## Sound
- `EE18..F04E`: sound engine init/clear/update + stream decode.
- `F357..F3FE`: SFX data blocks used by gameplay events.

## Porting Priority
1. Keep `script 00/02/04/06/08/0C` cycle stable before touching intermissions.
2. Port pellet/frightened path (`DEDF..E05A`) as a single unit to preserve timers.
3. Port ghost movement (`D4C2..D87E`) only after neighbor-tile probes (`E154..E21B`) are parity-checked.
4. Port intermission scripts last; they are isolated from normal round progression.
