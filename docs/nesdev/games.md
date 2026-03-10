# games

# 1992 Contra 120 in 1

Source: https://www.nesdev.org/wiki/1992_Contra_120_in_1

## Description

The cartridge is a multigames cartridge dated from 1992.

Versions known :
- 1992 Contra Super 120 in 1 : NES version (72-pin)

## Hardware

| NES PCB (Front mirrored picture) | NES PCB (Bottom picture) |
|  |  |

| Datas chips |
| Chips | Description |
| 8M12 - 5003AJ213-PA20C - S22431 - H9208 | Probably 1 MB chip (need confirmation) |
| Hyundai HY6264LP-10 - 9040D | 8K x 8-bit CMOS SRAM, 150ns |
| Usual fonctionnal chips |
| Chips | Description |
| GD74LS161A - 9204 - GoldStar | Binary Counter, LS Series, Synchronous, Positive Edge Triggered, 4-Bit, Up Direction, TTL, PDIP16 |
| GD74LS32 - 9211 - GoldStar | OR Gate, LS Series, 4-Func, 2-Input, TTL, PDIP14 |
| GD74LS157 - 9220 - GoldStar | Multiplexer, LS Series, 4-Func, 2 Line Input, 1 Line Output, True Output, TTL, PDIP16 |
| HD74HC02P - 1K45 | NOR Gate, HC/UH Series, 4-Func, 2-Input, CMOS, PDIP14 |
| GD74LS273 - 9209 - GoldStar | D Flip-Flop, LS Series, 1-Func, Positive Edge Triggered, 8-Bit, True Output, TTL, PDIP20 |
| GD74LS02 - 9215 - GoldStar | NOR Gate, LS Series, 4-Func, 2-Input, TTL, PDIP14 |
| GD74LS153 - 9217 - GoldStar | Multiplexer, LS Series, 2-Func, 4 Line Input, 1 Line Output, True Output, TTL, PDIP16 |

```text
 111111
 5432109876543210
[1.....bPxPPPPpmv]
       | |     |+- 0=16K,1=32K
       | |     +-- 0=V, 1=H
       | +-------- 1=NROM, 0=UNROM
       +---------- UNROM bank

```

The CHR part is a RAM chip, so it doesn't contain any datas to dump.

## Software

The 120 in 1 rom contains 512 KB of PRG and no CHR.

The rom has been dumped and assigned to the submapper 1 of the INES Mapper 227on the 25 march 2023.

It contains 13 different games that can be beginned at different levels.

The rom is fully supported from FCEUX 2.6.6.

## Dumping method

For dumping this cartridge, it's necessary to short-circuit this capacitor (by putting an electric wire between its two pins) :

This short-circuit in place, this script can dump the cartridge with the INLretro-prog dumper (Device firmware version: 2.3.x) :

| dumpN120_72.lua |
| File:DumpN120 72.lua.txt |

```text

```
| -- create the module's table local dumpn120_72 = {} -- import required modules local dict = require "scripts.app.dict" local nes = require "scripts.app.nes" local dump = require "scripts.app.dump" local flash = require "scripts.app.flash" local time = require "scripts.app.time" local files = require "scripts.app.files" local swim = require "scripts.app.swim" local buffers = require "scripts.app.buffers" -- local functions local function create_header( file, prgKB, chrKB ) -- Mapper : 227 ; Mirroring : 0 (Horizontal) nes.write_header( file, prgKB, chrKB, 227, 0) end --dump the PRG ROM local function dump_prgrom( file, rom_size_KB, debug ) --PRG-ROM dump 16KB at a time local KB_per_read = 16 local num_reads = rom_size_KB / KB_per_read local read_count = 0 local addr_base = 0x80 -- $8000 print("CPU dump :") while ( read_count < num_reads ) do if debug then print( "dump PRG part ", read_count, " of ", num_reads) end -- pause of 1 second to take care about the chips local time=os.clock()+1 while time>os.clock() do end dict.nes("NES_CPU_WR", 0x8000 | ((read_count & 0x1f) << 2) | ((read_count << 3) & (1 << 8)) , read_count) dump.dumptofile( file, KB_per_read, addr_base, "NESCPU_PAGE", false ) read_count = read_count + 1 end end --Cart should be in reset state upon calling this function --this function processes all user requests for this specific board/mapper --local function process( test, read, erase, program, verify, dumpfile, flashfile, verifyfile) local function process(process_opts, console_opts) local test = process_opts["test"] local read = process_opts["read"] local erase = process_opts["erase"] local program = process_opts["program"] local verify = process_opts["verify"] local dumpfile = process_opts["dump_filename"] local flashfile = process_opts["flash_filename"] local verifyfile = process_opts["verify_filename"] local rv = nil local file local prg_size = console_opts["prg_rom_size_kb"] local chr_size = console_opts["chr_rom_size_kb"] local wram_size = console_opts["wram_size_kb"] --initialize device i/o for NES dict.io("IO_RESET") dict.io("NES_INIT") print("\nRunning dumpN120_72.lua") --dump the cart to dumpfile if read then print("\nDumping ROM...") file = assert(io.open(dumpfile, "wb")) --create header: pass open & empty file & rom sizes create_header(file, prg_size, chr_size) --TODO find bank table to avoid bus conflicts! --dump cart into file time.start() --dump cart into file dump_prgrom(file, prg_size, false) time.report(prg_size) --close file assert(file:close()) print("DONE Dumping ROM") end dict.io("IO_RESET") end -- functions other modules are able to call dumpn120_72.process = process -- return the module's table return dumpn120_72 |

Under UNIX, the commands to run are :

```text
./inlretro -s scripts/inlretro3.lua -c NES -m dumpn120_72 -x 512 -d 120in1-contra-1992.nes

```

The NES header of the rom is to set to :

```text
4E 45 53 1A 20 00 30 E8 10 00 00 00 00 00 00 00

```

## Games Menu

There are 13 unique games and the same games at different levels :
- 1942
- Arkanoid
- B-Wings
- Battle City
- Bomber Man 1
- Contra
- Dig Dug
- Field Combat
- Galaxian
- Ninja-Kun
- Super Mario Bros 1 (Platforms / 1986)
- Tetris (Tengen)
- TwinBee

| Cartridge Menu |
| N° | Game Name | Original Game Name | Level |
| 001 | CONTRA | Contra | Stage 1 |
| 002 | TETRIS 2 | Tetris (Tengen) |  |
| 003 | SUPER MARIO | Super Mario Bros 1 (Platforms / 1986) | World 1-1 |
| 004 | ARKANOID | Arkanoid | Round 1 |
| 005 | ASUIT CONTRA | Contra | Stage 1 |
| 006 | TANK | Battle City | Stage 1 |
| 007 | GALAXIAN | Galaxian | Flag 1 |
| 008 | FIAME CONTRA | Contra | Stage 1 |
| 009 | DIG DUG | Dig Dug | Round 1 |
| 010 | TWIN BEE | TwinBee |  |
| 011 | SHOTE CONTRA | Contra | Stage 1 |
| 012 | 1942 | 1942 |  |
| 013 | BOMBER MAN | Bomber Man 1 | Stage 1 |
| 014 | CONTRA 30 | Contra | Stage 1 |
| 015 | TANK USA | Battle City | Stage 4 |
| 016 | B-WINGS | B-Wings | Stage 1 |
| 017 | ASUIT CONTRA 30 | Contra | Stage 1 |
| 018 | SPEED MARIO | Super Mario Bros 1 (Platforms / 1986) | World 1-1 |
| 019 | NINJA | Ninja-Kun | Scene 1 |
| 020 | FIAME CONTRA 30 | Contra | Stage 1 |
| 021 | ARKANOID 2 | Arkanoid | Round 4 |
| 022 | DIG DUG 2 | Dig Dug | Round 2 |
| 023 | SHOTE CONTRA 30 | Contra | Stage 1 |
| 024 | TANK CHN | Battle City | Stage 7 |
| 025 | B-WINGS WID | B-Wings | Stage 1 |
| 026 | BASE1 | Contra | Stage 2 – Base 1 |
| 027 | NINJA 2 | Ninja-Kun | Scene 2 |
| 028 | BOMBER MAN OT | Bomber Man 1 | Stage 1 |
| 029 | WATERFALL | Contra | Stage 3 |
| 030 | GALAXIAN 2 | Galaxian | Flag 2 |
| 031 | COMBAT | Field Combat |  |
| 032 | BASE2 | Contra | Stage 4 – Base 2 |
| 033 | SUPER MARIO 2 | Super Mario Bros 1 (Platforms / 1986) | World 2-1 |
| 034 | TANK JPN | Battle City | Stage 10 |
| 035 | SNOW FIELD | Contra | Stage 5 |
| 036 | DIG DUG 3 | Dig Dug | Round 3 |
| 037 | ARKANOID 3 | Arkanoid | Round 7 |
| 038 | ENERGY ZONE | Contra | Stage 6 |
| 039 | NINJA 3 | Ninja-Kun | Scene 3 |
| 040 | B-WINGS MT | B-Wings | Stage 1 |
| 041 | HENGAR | Contra | Stage 7 |
| 042 | TANK IRN | Battle City | Stage 13 |
| 043 | NINJA 4 | Ninja-Kun | Scene 4 |
| 044 | ALIEN LAIR | Contra | Stage 8 |
| 045 | DIG DUG 4 | Dig Dug | Round 4 |
| 046 | GALAXIAN 3 | Galaxian | Flag 3 |
| 047 | BASE1 ASU | Contra | Stage 2 – Base 1 |
| 048 | SUPER MARIO 3 | Super Mario Bros 1 (Platforms / 1986) | World 3-1 |
| 049 | TANK ISR | Battle City | Stage 16 |
| 050 | WATERFALL ASU | Contra | Stage 3 |
| 051 | B-WINGS VAN | B-Wings | Stage 1 |
| 052 | ARKANOID 4 | Arkanoid | Round A |
| 053 | BASE2 ASU | Contra | Stage 4 – Base 2 |
| 054 | COMBAT AX | Field Combat |  |
| 055 | BOMBER MAN NS | Bomber Man 1 | Stage 1 |
| 056 | SNOW FIELD ASU | Contra | Stage 5 |
| 057 | TANK-I | Battle City | Stage 19 |
| 058 | NINJA 5 | Ninja-Kun | Scene 5 |
| 059 | ENERGY ZONE ASU | Contra | Stage 6 |
| 060 | BOMBER MAN RP | Bomber Man 1 | Stage 1 |
| 061 | DIG DUG 5 | Dig Dug | Round 5 |
| 062 | HENGAR ASU | Contra | Stage 7 |
| 063 | SUPER MARIO 4 | Super Mario Bros 1 (Platforms / 1986) | World 4-1 |
| 064 | TANK JOR | Battle City | Stage 22 |
| 065 | ALIEN LAIR ASU | Contra | Stage 8 |
| 066 | B-WINGS SID | B-Wings | Stage 1 |
| 067 | ARKANOID 5 | Arkanoid | Round D |
| 068 | BASE1 FIA | Contra | Stage 2 – Base 1 |
| 069 | NINJA 6 | Ninja-Kun | Scene 6 |
| 070 | COMBAT BX | Field Combat |  |
| 071 | WATERFALL FIA | Contra | Stage 3 |
| 072 | TANK 2C | Battle City | Stage 25 |
| 073 | GALAXIAN 4 | Galaxian | Flag 4 |
| 074 | BASE2 FIA | Contra | Stage 4 – Base 2 |
| 075 | BOMBER MAN TW | Bomber Man 1 | Stage 1 |
| 076 | DIG DUG 6 | Dig Dug | Round 6 |
| 077 | SNOW FIELD FIA | Contra | Stage 5 |
| 078 | SUPER MARIO 5 | Super Mario Bros 1 (Platforms / 1986) | World 5-1 |
| 079 | B-WINGS AT | B-Wings | Stage 1 |
| 080 | ENERGY ZONE FIA | Contra | Stage 6 |
| 081 | TANK LEB | Battle City | Stage 28 |
| 082 | ARKANOID 6 | Arkanoid | Round G |
| 083 | HENGAR FIA | Contra | Stage 7 |
| 084 | B-WINGS HAM | B-Wings | Stage 1 |
| 085 | NINJA 7 | Ninja-Kun | Scene 7 |
| 086 | ALIAN LAIR FIA | Contra | Stage 8 |
| 087 | BOMBER MAN DF | Bomber Man 1 | Stage 1 |
| 088 | DIG DUG 7 | Dig Dug | Round 7 |
| 089 | BASE1 SHO | Contra | Stage 2 – Base 1 |
| 090 | TANK USR | Battle City | Stage 31 |
| 091 | COMBAT CX | Field Combat |  |
| 092 | WATERFALL SHO | Contra | Stage 3 |
| 093 | SUPER MARIO 6 | Super Mario Bros 1 (Platforms / 1986) | World 6-1 |
| 094 | B-WINGS JMP | B-Wings | Stage 1 |
| 095 | BASE2 SHO | Contra | Stage 4 – Base 2 |
| 096 | NINJA 8 | Ninja-Kun | Scene 8 |
| 097 | ARKANOID 7 | Arkanoid | Round J |
| 098 | SNOW FIELD SHO | Contra | Stage 5 |
| 099 | DIG DUG 8 | Dig Dug | Round 8 |
| 100 | GALAXIAN 5 | Galaxian | Flag 5 |
| 101 | COMBAT DX | Field Combat |  |
| 102 | DIG DUG 9 | Dig Dug | Round 9 |
| 103 | TANK IRI | Battle City | Stage 34 |
| 104 | ENERGY ZONE SHO | Contra | Stage 6 |
| 105 | B-WINGS DY | B-Wings | Stage 1 |
| 106 | NINJA 9 | Ninja-Kun | Scene 9 |
| 107 | HENGAR SHO | Contra | Stage 7 |
| 108 | SUPER MARIO 7 | Super Mario Bros 1 (Platforms / 1986) | World 7-1 |
| 109 | SUPER 1942 | 1942 |  |
| 110 | BOMBER MAN AN | Bomber Man 1 | Stage 1 |
| 111 | TANK-II | Battle City | Stage 1 |
| 112 | ARKANOID 8 | Arkanoid | Round L |
| 113 | ALIEN LAIR SHO | Contra | Stage 8 |
| 114 | GALAXIAN 6 | Galaxian | Flag 6 |
| 115 | SUPER TWIN BEE | TwinBee |  |
| 116 | COMBAT EX | Field Combat |  |
| 117 | TANK FRE | Battle City | Stage 18 |
| 118 | B-WINGS FIR | B-Wings | Stage 1 |
| 119 | DIG DUG 10 | Dig Dug | Round 10 |
| 120 | SUPER MARIO 8 | Super Mario Bros 1 (Platforms / 1986) | World 8-1 |

# 1993 Super 50 in 1 Game

Source: https://www.nesdev.org/wiki/1993_Super_50_in_1_Game

## Description

The cartridge is a multigames cartridge dated from 1993.

Versions known :
- 1993 Super 50 in 1 Game : NES version (72-pin)

## Hardware

| NES PCB (Front mirrored picture) | NES PCB (Bottom picture) |
|  |  |

| Datas chips |
| Chips | Description |
| Blob | PRG-ROM |
| Blob | CHR-ROM |
| Usual fonctionnal chips |
| Chips | Description |
| 74LS161A - 6.70 | BCD Decade counters / 4-bit binary counters |
| GD74LS00 - 9223 - GoldStar | NAND Gate, LS Series, 4-Func, 2-Input, TTL, PDIP14 |

## Software

The 50 in 1 rom contains 64 KB of PRG and 32 KB of CHR.

The rom has been dumped and assigned to the INES Mapper 200.

It contains 4 different games that can be beginned at different levels.

## Dumping method

This script can dump the cartridge with the INLretro-prog dumper (Device firmware version: 2.3.x) :

| dumpMG109.lua |
| File:DumpMG109.lua.txt |

```text

```
| -- create the module's table local dumpmg109 = {} -- import required modules local dict = require "scripts.app.dict" local nes = require "scripts.app.nes" local dump = require "scripts.app.dump" local flash = require "scripts.app.flash" local time = require "scripts.app.time" local files = require "scripts.app.files" local swim = require "scripts.app.swim" local buffers = require "scripts.app.buffers" -- local functions local function create_header( file, prgKB, chrKB ) -- Mapper : 200 ; Mirroring : 0 (Horizontal) nes.write_header( file, prgKB, chrKB, 200, 0) end --dump the PRG ROM local function dump_prgrom( file, rom_size_KB, debug ) --PRG-ROM dump 16KB at a time local KB_per_read = 16 local num_reads = rom_size_KB / KB_per_read local read_count = 0 local addr_base = 0x80 -- $8000 print("CPU dump :") while ( read_count < num_reads ) do if debug then print( "dump PRG part ", read_count, " of ", num_reads) end -- pause of 1 second to take care about the chips local time=os.clock()+1 while time>os.clock() do end local nobusconflicts = dict.nes("NES_CPU_RD", 0x8000 | read_count); dict.nes("NES_CPU_WR", 0x8000 | read_count , nobusconflicts) dump.dumptofile( file, KB_per_read, addr_base, "NESCPU_PAGE", false ) read_count = read_count + 1 end end --dump the CHR ROM local function dump_chrrom( file, rom_size_KB, debug ) local KB_per_read = 8 --dump both PT at once local num_reads = rom_size_KB / KB_per_read local read_count = 0 local addr_base = 0x00 -- $0000 print("PPU dump :") while ( read_count < num_reads ) do if debug then print( "dump CHR part ", read_count, " of ", num_reads) end -- pause of 1 second to take care about the chips local time=os.clock()+1 while time>os.clock() do end local nobusconflicts = dict.nes("NES_CPU_RD", 0x8000 | read_count); dict.nes("NES_CPU_WR", 0x8000 | read_count , nobusconflicts) dump.dumptofile( file, KB_per_read, addr_base, "NESPPU_PAGE", false ) read_count = read_count + 1 end end --Cart should be in reset state upon calling this function --this function processes all user requests for this specific board/mapper --local function process( test, read, erase, program, verify, dumpfile, flashfile, verifyfile) local function process(process_opts, console_opts) local test = process_opts["test"] local read = process_opts["read"] local erase = process_opts["erase"] local program = process_opts["program"] local verify = process_opts["verify"] local dumpfile = process_opts["dump_filename"] local flashfile = process_opts["flash_filename"] local verifyfile = process_opts["verify_filename"] local rv = nil local file local prg_size = console_opts["prg_rom_size_kb"] local chr_size = console_opts["chr_rom_size_kb"] local wram_size = console_opts["wram_size_kb"] --initialize device i/o for NES dict.io("IO_RESET") dict.io("NES_INIT") print("\nRunning dumpMG109.lua") --dump the cart to dumpfile if read then print("\nDumping ROM...") file = assert(io.open(dumpfile, "wb")) --create header: pass open & empty file & rom sizes create_header(file, prg_size, chr_size) --TODO find bank table to avoid bus conflicts! --dump cart into file time.start() --dump cart into file dump_prgrom(file, prg_size, false) dump_chrrom(file, chr_size, false) time.report(prg_size) --close file assert(file:close()) print("DONE Dumping ROM") end dict.io("IO_RESET") end -- functions other modules are able to call dumpmg109.process = process -- return the module's table return dumpmg109 |

Under UNIX, the commands to run are :

```text
./inlretro -s scripts/inlretro3.lua -c NES -m dumpmg109 -x 64 -y 32 -d 50in1-1993.nes

```

The NES header of the rom is to set to

```text

```

## Games Menu

There are 4 unique games and the same games at different levels :
- Duck Hunt
- Wild Gunman
- Battle City
- Mario Bros (Arcade / 1983)

| Cartridge Menu |
| N° | Game Name | Original Game Name | Level |
| 1 | DUCK HUNT | Duck Hunt | Game A : 1 duck |
| 2 | TWO DUCKS HUNT | Duck Hunt | Game B : 2 ducks |
| 3 | CLAY SHOOTING | Duck Hunt | Game C : Clay Shooting |
| 4 | WILD GUNMAN | Wild Gunman | Game A : 1 outlaw |
| 5 | TWO GUNMEN | Wild Gunman | Game B : 2 outlaws |
| 6 | SALOON GUNMEN | Wild Gunman | Game C : Gang |
| 7 | BATTLE CITY 1 | Battle City | Stage 1 |
| 8 | BATTLE CITY 2 | Battle City | Stage 2 |
| 9 | BATTLE CITY 3 | Battle City | Stage 3 |
| 10 | BATTLE CITY 4 | Battle City | Stage 4 |
| 11 | BATTLE CITY 5 | Battle City | Stage 5 |
| 12 | BATTLE CITY 6 | Battle City | Stage 6 |
| 13 | BATTLE CITY 7 | Battle City | Stage 7 |
| 14 | BATTLE CITY 8 | Battle City | Stage 8 |
| 15 | BATTLE CITY 9 | Battle City | Stage 9 |
| 16 | BATTLE CITY 10 | Battle City | Stage 10 |
| 17 | BATTLE CITY 11 | Battle City | Stage 11 |
| 18 | BATTLE CITY 12 | Battle City | Stage 12 |
| 19 | BATTLE CITY 13 | Battle City | Stage 13 |
| 20 | BATTLE CITY 14 | Battle City | Stage 14 |
| 21 | BATTLE CITY 15 | Battle City | Stage 15 |
| 22 | BATTLE CITY 16 | Battle City | Stage 16 |
| 23 | BATTLE CITY 17 | Battle City | Stage 17 |
| 24 | BATTLE CITY 18 | Battle City | Stage 18 |
| 25 | BATTLE CITY 19 | Battle City | Stage 19 |
| 26 | BATTLE CITY 20 | Battle City | Stage 20 |
| 27 | BATTLE CITY 21 | Battle City | Stage 21 |
| 28 | BATTLE CITY 22 | Battle City | Stage 22 |
| 29 | BATTLE CITY 23 | Battle City | Stage 23 |
| 30 | BATTLE CITY 24 | Battle City | Stage 24 |
| 31 | BATTLE CITY 25 | Battle City | Stage 25 |
| 32 | BATTLE CITY 26 | Battle City | Stage 26 |
| 33 | BATTLE CITY 27 | Battle City | Stage 27 |
| 34 | BATTLE CITY 28 | Battle City | Stage 28 |
| 35 | BATTLE CITY 29 | Battle City | Stage 29 |
| 36 | BATTLE CITY 30 | Battle City | Stage 30 |
| 37 | BATTLE CITY 31 | Battle City | Stage 31 |
| 38 | BATTLE CITY 32 | Battle City | Stage 32 |
| 39 | BATTLE CITY 33 | Battle City | Stage 33 |
| 40 | BATTLE CITY 34 | Battle City | Stage 34 |
| 41 | BATTLE CITY 35 | Battle City | Stage 35 |
| 42 | MARIO BROS 1 | Mario Bros (Arcade / 1983) | Phase 1 |
| 43 | MARIO BROS 2 | Mario Bros (Arcade / 1983) | Phase 2 |
| 44 | MARIO BROS 3 | Mario Bros (Arcade / 1983) | Phase 3 |
| 45 | MARIO BROS 4 | Mario Bros (Arcade / 1983) | Phase 4 |
| 46 | MARIO BROS 5 | Mario Bros (Arcade / 1983) | Phase 5 |
| 47 | MARIO BROS 6 | Mario Bros (Arcade / 1983) | Phase 6 |
| 48 | MARIO BROS 7 | Mario Bros (Arcade / 1983) | Phase 7 |
| 49 | MARIO BROS 8 | Mario Bros (Arcade / 1983) | Phase 8 |
| 50 | MARIO BROS 9 | Mario Bros (Arcade / 1983) | Phase 9 |

# Color $0D games

Source: https://www.nesdev.org/wiki/Color_$0D_games

On an NES, the palette color $0D causes the signal to drop below the normal black level. This low voltage signal is sometimes mistaken by televisions for blanking signals, which can cause an unstable picture, or total picture loss on some devices. Other devices seem to process with signal without problem.

## Games

| Game | Notes |

| Contra 100 in 1 | Uses both for background color and one of the sprites' color; to apply a patch, change values at those offsets in ROM from $0D to $0F: $388B, $388F, $3893, $3897, $389B, $389C, $389F, $38A3, $38A7 |

| Contra 168 in 1 | Uses both for background color and one of the sprites' color; to apply a patch, change values at those offsets in ROM from $0D to $0F: $2451, $2455, $2459, $245D, $2461, $2462, 2465, $2469, $246D |
| Bee 52 |  |
| Castelian |  |
| Cybernoid | $0D is used as the background color. |
| The Fantastic Adventures of Dizzy |  |
| FireHawk (USA) | Used in both the background and sprites. The European release (with NTSC video detection) corrects this. |
| Game Genie | The code entry screen uses it for its background. |
| The Immortal | Also uses all three de-emphasis bits to compensate for the the user cranking up the TV set's brightness so that regular black ($xE/$xF) can be used as a first darker shade of gray, and color $1D as an even darker shade of gray, while color $0D is used as a black background color. |
| Indiana Jones and the Last Crusade (Taito) | Used as the background color in the motorcycle level. |
| Indiana Jones and the Last Crusade (Ubisoft) |  |
| Maniac Mansion (USA) |  |
| Micro Machines |  |
| MIG-29 Soviet Fighter |  |
| Quattro Sports |  |
| Quattro Adventures |  |
| Skate or Die 2 | Used as the background color during the introduction cutscene sequence. |
| The Super Shinobi | Unlicensed clone of Shinobi III. |
| Teenage Mutant Ninja Turtles | Uses it for black outlines on sprites, the lack of large areas of this color mitigates the problem. |
| The Three Stooges | Uses $xD colors that are turned to $0D during fades. |

## Effects

Because the signal created by $0D is outside the specifications for the video signal, there is a lot of variation in how display devices handle it. Here are some possible effects that may be seen when using $0D:
- $0D appears the same black as the other black colors (e.g. $0F).
- $0D appears slightly darker than other blacks.
- $0D appears as gray.
- The device renormalizes the range when $0D appears, slightly brightening all other colours while it is onscreen.
- Wobbly or distorted image from loss of horizontal blanking stability (either permanent or periodic)
- Loss of vertical blanking stability.
- Total loss of picture.

These effects are more likely to occur when color $0D is used with the de-emphasis bits enabled, such as in The Immortal , as seen in these examplevideos.

On consoles with an RGB PPU like the Famicom Titler or Sharp C1TV, Color $0D is simply a "normal" black palette entry identical to $0F, so systems with an RGB PPU are immune to causing video output problems.

## Workarounds
- Patch the game code to replace all the $0D writes with $0F. This likely requires changes to many bytes in the ROM, so a Game Genie (limited to 3 changes) would not be sufficient. Instead, updated ROMs or a more capable pass-through patching device would likely be required
- If your TV has digital inputs (for example - HDMI), use RCA to HDMI adapter, whose analog to digital converter might cope better with the out-of-spec video signal
- Modify the console to use a different video output stage that adjusts the voltages so that the TV may accept it, such as by omitting the NPN transistor follower part of the video amplifier. However, the TV may ignore this voltage offset
- Change your TV, console and/or video adapter (if you are using one)

## Tests
- Palette test ROM- Displays NES palette, and can toggle $0D display.
- NESPix- Native graphics editor that allows use of $0D, and can test it in various visual arrangements.
- 240p test suite- TV testing program. Test cards with $0D include PLUGE, SMPTE color bars, Solid color screen, and IRE. PLUGE also includes emphasized $0D.

## See also
- NTSC video
- PPU palettes
- Colour-emphasis games

# Colour-emphasis games

Source: https://www.nesdev.org/wiki/Colour-emphasis_games

The following is a list of games which make use of PPU register $2001's colour emphasis bits (D7 to D5):

## Commercial
- Bubble Bobble for the Famicom Disk System uses red emphasis to tint the screen throughout the game, which is absent in the cartridge releases.
- Family BASIC allows the user to set PPU emphasis bits through the POKE command. V3 adds the "FILTER" command for this purpose.
- The Fantastic Adventures of Dizzy uses it in the beginning when the scroll is unfurled.
- Final Fantasy and Final Fantasy II rapidly sets and clears all 3 emphasis bits to flash the screen when going into a battle screen, also rotates colors when entering the status screen.
- Super Game's Aladdinuses red emphasis to tint the screen during gameplay, and all 3 emphasis bits to dim when paused. The official version of Aladdin , released only in Europe, also uses the emphasis bits to tint the screen green during gameplay (as the PAL console flips the red and green emphasis bits), but does not dim the screen when paused.

The following games set all 3 emphasis bits at once to dim the screen. Contrary to what some older documentation claims, this is fairly well tolerated by TVs of the era and not cause for a game to fail certification.
- Cliffhanger
- Cybernoid - The Fighting Machine on the top part of the difficulty select and better luck next time screens. Also uses red emphasis when the screen changes in-game.
- Dragon's Lair
- Felix the Cat
- Fun House for fading out
- The Immortal
- Indiana Jones and the Last Crusade (Taito) , story scenes and some action scenes.
- James Bond Jr
- The Jungle Book
- Just Breed , whose box has a notice about incompatibility with the Sharp C-1 TV
- Lagrange Point uses colour emphasis, in some frames combined with grayscale bit to do a very cheap fade-out effect when switching to and from the menu on the playfield, and also when entering into battle
- Legend of Prince Valiant, The (E) uses full emphasis on the title screen, green emphasis for gameplay and red emphasis for status bar
- Lethal Weapon
- The Lion King (E)
- Magician
- Mickey's Adventures in Numberland
- Muppet Adventure: Chaos at the Carnival
- Noah's Ark (E) uses blue emphasis combined with grayscale mode to put part of the level underwater and all 3 emphasis bits in other cases
- Qix
- Rampart uses color emphasis on the player select screen, the options screen and some of the scrolling text. Blue emphasis is used for the score tally bar.
- R.B.I. Baseball 3
- Space Shuttle Project
- Super Spy Hunter , when paused. The Japanese version Battle Formula doesn't do this.
- Xiao Ma Li

## Homebrew
- Wallby Chris Covell uses a blue emphasis to simulate the water flooding the wall.
- Graphics editorby Damian Yerrick allows applying a SCREEN TINT to the picture.
- Munchie Attackby Memblers dims the screen upon Game Over.
- Super Bat Puncher Demodims the screen during pause.
- Battle Kid and Battle Kid 2 dim the screen during pause.
- Waddles the Duckdims the screen when on a warp, and RG-emphasis when in ice-dimension, among others.
- All Hell Unleasedby 8-Bit Slasher dims the screen during pause

### Commercial homebrew
- Full Quietapplies various tints over the course of its day/night cycle.
- Project Bluesets R and G emphasis bits together on the ending screen, to achieve a warmer tan-like tint.

## Multicarts' menus
- 400 in 1sets all 3 bits

## Romhacks
- Rockman 4 Minus Infinity(during Brightman's stage) darkens areas farther away from Mega Man.
- Bisqwit's Castlevania II retranslationuses the de-emphasis bits to highlight a section of a screen when scrolling the list of savegame slots.

## References
- BBS topic
- BBS topic #2

# Color $0D games

Source: https://www.nesdev.org/wiki/Colour_$0D_games

On an NES, the palette color $0D causes the signal to drop below the normal black level. This low voltage signal is sometimes mistaken by televisions for blanking signals, which can cause an unstable picture, or total picture loss on some devices. Other devices seem to process with signal without problem.

## Games

| Game | Notes |

| Contra 100 in 1 | Uses both for background color and one of the sprites' color; to apply a patch, change values at those offsets in ROM from $0D to $0F: $388B, $388F, $3893, $3897, $389B, $389C, $389F, $38A3, $38A7 |

| Contra 168 in 1 | Uses both for background color and one of the sprites' color; to apply a patch, change values at those offsets in ROM from $0D to $0F: $2451, $2455, $2459, $245D, $2461, $2462, 2465, $2469, $246D |
| Bee 52 |  |
| Castelian |  |
| Cybernoid | $0D is used as the background color. |
| The Fantastic Adventures of Dizzy |  |
| FireHawk (USA) | Used in both the background and sprites. The European release (with NTSC video detection) corrects this. |
| Game Genie | The code entry screen uses it for its background. |
| The Immortal | Also uses all three de-emphasis bits to compensate for the the user cranking up the TV set's brightness so that regular black ($xE/$xF) can be used as a first darker shade of gray, and color $1D as an even darker shade of gray, while color $0D is used as a black background color. |
| Indiana Jones and the Last Crusade (Taito) | Used as the background color in the motorcycle level. |
| Indiana Jones and the Last Crusade (Ubisoft) |  |
| Maniac Mansion (USA) |  |
| Micro Machines |  |
| MIG-29 Soviet Fighter |  |
| Quattro Sports |  |
| Quattro Adventures |  |
| Skate or Die 2 | Used as the background color during the introduction cutscene sequence. |
| The Super Shinobi | Unlicensed clone of Shinobi III. |
| Teenage Mutant Ninja Turtles | Uses it for black outlines on sprites, the lack of large areas of this color mitigates the problem. |
| The Three Stooges | Uses $xD colors that are turned to $0D during fades. |

## Effects

Because the signal created by $0D is outside the specifications for the video signal, there is a lot of variation in how display devices handle it. Here are some possible effects that may be seen when using $0D:
- $0D appears the same black as the other black colors (e.g. $0F).
- $0D appears slightly darker than other blacks.
- $0D appears as gray.
- The device renormalizes the range when $0D appears, slightly brightening all other colours while it is onscreen.
- Wobbly or distorted image from loss of horizontal blanking stability (either permanent or periodic)
- Loss of vertical blanking stability.
- Total loss of picture.

These effects are more likely to occur when color $0D is used with the de-emphasis bits enabled, such as in The Immortal , as seen in these examplevideos.

On consoles with an RGB PPU like the Famicom Titler or Sharp C1TV, Color $0D is simply a "normal" black palette entry identical to $0F, so systems with an RGB PPU are immune to causing video output problems.

## Workarounds
- Patch the game code to replace all the $0D writes with $0F. This likely requires changes to many bytes in the ROM, so a Game Genie (limited to 3 changes) would not be sufficient. Instead, updated ROMs or a more capable pass-through patching device would likely be required
- If your TV has digital inputs (for example - HDMI), use RCA to HDMI adapter, whose analog to digital converter might cope better with the out-of-spec video signal
- Modify the console to use a different video output stage that adjusts the voltages so that the TV may accept it, such as by omitting the NPN transistor follower part of the video amplifier. However, the TV may ignore this voltage offset
- Change your TV, console and/or video adapter (if you are using one)

## Tests
- Palette test ROM- Displays NES palette, and can toggle $0D display.
- NESPix- Native graphics editor that allows use of $0D, and can test it in various visual arrangements.
- 240p test suite- TV testing program. Test cards with $0D include PLUGE, SMPTE color bars, Solid color screen, and IRE. PLUGE also includes emphasized $0D.

## See also
- NTSC video
- PPU palettes
- Colour-emphasis games

# Game Doctor/Magic Card FDS Format

Source: https://www.nesdev.org/wiki/Game_Doctor/Magic_Card_FDS_Format

The Front Fareast (Super) Magic Card, Bung (Super) Game Doctor/Game Master and Venus Game Doctor RAM cartridgesload games from the same 2.8" floppy disk media as the Famicom Disk System. The basic header/block structure is identical to the FDS disk format, with the Doctor Header file having a special significance.

## Doctor Header file
- Address: CPU $43FF or $4FFF
- Size: 8 bytes

Game Doctor/Magic Card disks are run by placing the device between the FDS RAM Adapter and the console. By the default, the Game Doctor/Magic Card merely passes through all signals, so that the normal FDS BIOS screen is shown.

The FDS BIOS boots the disk and tries to store the first data byte of the Doctor Header file to $43FF or $4FFF. This operation switches the Game Doctor/Magic Card from Pass-through into Load mode, switching-in its replacement BIOS at $E000-$FFFF. Since the FDS BIOS' instruction that stores bytes read from disk is at offset $E53A, the entry point into the Game Doctor/Magic Card BIOS is offset $E53C.

The Game Doctor BIOS will read and interpret the Doctor Header file and all subsequent blocks as well as prompt for the insertion of additional disks. All blocks must have valid CRC fields, and the gap length between blocks is like on any regular FDS disk.

The Front Fareast Super Magic Card is different in that it displays its own GUI at power-on from which Magic Card disks may be run, but can be set to pass-through mode via a menu choice ("RUN IC CARD" or "RUN NTD 2.8").

### Front Fareast Magic Card 1M/2M/4M disks

```text
Offset Meaning
$0     Flag byte
       1TMM ....
       ||++------ 0: Not a Magic Card 4M game
       ||         1: Magic Card 4M game, 128+256 KiB data
       ||         2: Magic Card 4M game, 256+128 KiB data
       ||         3: Magic Card 4M game, 256+256 KiB data
       |+-------- 1: Trainer present
       |          0: No trainer present
       +--------- 1: Magic Card disk (if offset $7=0 as well)

$1     Mode byte
       This byte is written to register $42FF.

$2-$6  Catalogue number
       Can be in ASCII or FDS BIOS tile numbers.

$7     Must be $00 to indicate Magic Card 1M/2M/4M disk

```
- A Magic Card disk is identified by having byte $0 bit 7 set, and byte $7=00.
- The number of expected disk sides is:
  - If byte $0 bit 4 or 5 is set, 6 sides if one of the two bits is set, or 8 sides if both are set.
  - Otherwise, it is derived from bits 5-7 of byte $1:
    - 0: 2 sides (UNROM)
    - 1-3: 4 sides (UOROM)
    - 4: 3 sides (GNROM)
    - 5-7: 1 side (CNROM/NROM)
- If byte $0 bit 6 is set, following all the files on the first side, there must be a block type $5 containing 512 bytes of trainer data to be loaded to $7000, and an RTS-returning Init routine at $7003 that will be called by BIOS prior to JMPing to the game's Reset handler.
- No data loaded to RAM prior to encountering the Doctor Header file can be assumed to remain present.
- "128+256 KiB data" on Magic Card 4M games means that the first 128 KiB of data are loaded to the beginning of the 512 KiB PRG-RAM, then there is a 128 KiB hole, followed by the remaining 256 KiB of data. The second 256 KiB will contain CHR pattern data that is copied from PRG-RAM to the 32 KiB of CHR-RAM as needed by the Trainer program.

### Front Fareast Super Magic Card disks

```text
Offset Meaning
$0     Flag byte
       1T.. ....
       |+-------- 1: Trainer present
       |          0: No trainer present
       +--------- 1: Super Magic Card disk (if offset $7=$AA as well)

$1     Mode byte
       This byte is written to register $42FF.

$2     Trainer address MSB
$3     Number of 8 KiB PRG banks
$4     Number of 8 KiB CHR banks
$5     8 KiB PRG bank number to be initially mapped to $E000-$FFFF
$6     Number of disk sides minus 1
$7     Must be $AA to indicate Super Magic Card disk

```
- A Super Magic Card disk is identified by having byte $0 bit 7 set, and byte $7=$AA.
- If byte $0 bit 6 is set, a 512-byte trainer must have been loaded to CPU RAM at $0600 prior to encountering the Doctor Header file. BIOS will move it to the address specified at Doctor Header byte $2, and JMP to it instead of JMPing to the game's Reset handler.

### Bung Super Game Doctor disks

```text
Offset Meaning
$0     Flag byte
       1T.. ....
       |+-------- 1: Trainer present
       |          0: No trainer present
       +--------- 1: Super Game Doctor disk (if offset $7 !=0 as well)

$1     Mode byte
       This byte is written to register $42FF.

$2-$6  Catalogue number
       Can be in ASCII or FDS BIOS tile numbers.

$7     Number of disk sides minus 1.

```
- A Super Game Doctor disk is identified by having byte $0 bit 7 set, and byte $7 !=0 (and not $AA).
- If byte $0 bit 6 is set, an RTS-returning Init routine at $7003 that will be called by BIOS prior to JMPing to the game's Reset handler. This trainer data must have been loaded to $7000 as a normal FDS file prior to encountering the Doctor Header file.
- A game disk is furthermore free to load data to any other address between $6000-$7FFF, or even CPU RAM at $0000-$07FF, prior to encountering the Doctor Header file, and JMPing or JSRing to it from the normal game code.
- A special value $FE of byte $0 is used by the Makko Copy Master. In its presence, BIOS keeps the Super Game Doctor in Load mode and just JMPs to $6000 after loading all files from the first disk side.

### Venus Turbo Game Doctor disks

```text
Offset Meaning
$0     Flag byte
       0TL. ....
       ||+------- 1: Special load hooks present
       |+-------- 1: Trainer present
       |          0: No trainer present
       +--------- 0: Turbo Game Doctor disk

$1     Mode byte
       This byte is written to register $42FF.

$2-$6  Catalogue number
       Can be in ASCII or FDS BIOS tile numbers.

$7     Number of disk sides minus 1.

```
- A Turbo Game Doctor disk is identified by having byte $0 bit 7 clear.
- If byte $0 bit 6 is set, an RTS-returning Init routine at $7003 that will be called by BIOS prior to JMPing to the game's Reset handler. This trainer data must have been loaded to $7000 as a normal FDS file prior to encountering the Doctor Header file.
- If byte $0 bit 5 is set, BIOS will JMP to certain RAM addresses during the load process. The code must have been loaded to $0400 as a normal FDS file prior to encountering the Doctor Header file.
  - $0400 ... after reading block type 2 of sides B and later. It must JMP to $E569 to continue with BIOS.
  - $0403 ... after encountering Doctor Header file. It must JMP to $E55F to continue with BIOS.
  - $0406 ... before JMPing to ($FFFC). It must RTS or JMP to ($FFFC) by itself.
- A game disk is furthermore free to load data to any other address between $6000-$7FFF, or even CPU RAM at $0000-$07FF, prior to encountering the Doctor Header file, and JMPing or JSRing to it from the normal game code.
- A special value $FE of byte $0 is used by the Makko Copy Master. In its presence, BIOS keeps the Turbo Game Doctor in Load mode and just JMPs to $6000 after loading all files from the first disk side.

## File Header (block type 3)/File Data (block type 4)

As with normal FDS disks, file data is stored as pairs of File Header (block type 3) and File Data (block type 4) blocks.
- Magic Card and Super Game Doctor disks ignore the address and size fields of the File Header block, only paying attention to bit 0 of the file type (CPU/PPU) byte. CPU files are always assumed to have a size of 32768 bytes, and PPU bytes 8192, 16384 or 32768 bytes depending on byte $1 of the Doctor Header file, each being loaded sequentially into the Magic Card/Game Doctor's own RAM. The target address is then automatically incremented. The File Header block thereby containing potentially incorrect file sizes serves as a simple copy protection method.
- Super Magic Card disks faithfully obey the address and size fields of the File Header block, and use the file ID (offset $1 in block type 3) as PRG A13-A18/CHR A10-A17.
- Turbo Game Doctor disks faithfully obey the address and size fields of the File Header block, and use bits 1-7 of the file type byte as higher target address bits:

```text
 File Header byte $E:
 .PPP P..0
  ||| |  +- Denote CPU address space
  +++-+---- PRG A18..A15

 ...C CC.1
    | || +- Denote PPU address space
    +-++--- CHR A17..A15

```

## Hidden file

The Bung Game Doctor 1M and the Venus Game Converter 1M expect a hidden file, meaning an additional block type 3/block type 4 pair, after the file count denoted in block type 2. Content, size and address do not matter. Later Game Doctors have no such requirement.

## Magic Card Trainer (block type 5)

On Magic Card 1M/2M/4M games only, if the Doctor Header file's byte $0 has bit 6 set, a block type 5 must be follow the file blocks denoted in block type 2. The block type 5 byte is followed directly by 512 bytes of Trainer data to be stored at CPU $7000, followed by a standard CRC word.

This method of storing Trainer data is unique to Magic Card 1M/2M/4M disks; Super and Turbo Game Doctor disks store Trainers as regular FDS files prior to the Doctor Header file.

# Game Genie

Source: https://www.nesdev.org/wiki/Game_Genie

The Game Genie is a enhancement cart for the NES designed by Camericaand distributed by Galooband Camerica. It functions as a pass-thru, with a 72-pin cartridge connectorconnecting it to the NES, and a 72-pin cartridge slot for a game to be inserted into. When plugged in between a game and the NES and turned on, it provides a simple interface to enter up to three cheat codes, which then modify the behavior of the game. First revision were build using ASIC blob chipand 4 kB ROM, the latter one has both chips integrated into single epoxy blob. There even exist a console ( Geniecom Enhance Console video Game ) that has the Game Genie ASIC DIP CHIP ( GENIECOM-V1 BIC ) built it.

The Game Genie is not assigned a mappernumber.

## Technical

The Game Genie works by intercepting CPU reads and replacing the game cart's response with its own response. It can intercept any three addresses in CPU $8000…$FFFF and respond with a single replacement for each. To make the tool more compatible with bank-switching, each of the three codes has an optional compare value which can be used to only replace the byte if the original byte matches the compare, hopefully limiting the cheat to functioning on the desired bank.

When first booted, the Game Genie presents its own 4-KiB PRG ROM(mapped at $c000-$ffff and mirrored 4 times; $8000-$bfff is open bus) and a series of simple gates masquerading as a CHR ROM. The included PRG ROM runs code to show a simple code entry user interface. When the user presses Start, the cheat values are written to memory-mapped registers, and then another register is written which switches the Game Genie into game mode, where the attached game cart's CHR and PRG is passed through, save whatever code replacements were defined. The Game Genie remains in game mode until power-cycled, and will respond to no further writes.

## Software version

The only version known to exists is 1.5A (CRC32 = 1A3A22A1), present both in DIP chip version (with ROM chip marked as GENIE V1.5A ) and single epoxy blob one).

## Registers

### Master Control ($8000)

```text
7  bit  0
---- ----
.DDD CCCE
 ||| ||||
 ||| |||+- Write 1 to switch into game mode
 ||| +++-- Compare enable for each of the three codes
 +++------ Disable each of the three codes

```

Bit 1 and 4 correspond to the code at $8001…$8004.

Game Genie writes first a value with bit 0 set and then writes 0x00 to this register. Because after the first write, the Game Genie logic switches into game mode, any further writes to range $8000–$ffff will cause the slave cartridge /ROMSEL to become low for that write cycle. As a result, the second write will be seen and interpreted by the hardware inside slave game cartridge. The reason for this write is unknown, maybe it initializes the bank select register for MMC3 games?

### Address High ($8001, $8005, $8009)

```text
7  bit  0
---- ----
.AAA AAAA
 ||| ||||
 +++-++++- Bits 8:14 of address for this cheat (bit 15 fixed to 1)

```

### Address Low ($8002, $8006, $800A)

```text
7  bit  0
---- ----
AAAA AAAA
|||| ||||
++++-++++- Bits 0:7 of address for this cheat

```

### Compare ($8003, $8007, $800B)

```text
7  bit  0
---- ----
CCCC CCCC
|||| ||||
++++-++++- Compare value for this cheat (write 0 if unused?)

```

### Replace ($8004, $8008, $800C)

```text
7  bit  0
---- ----
RRRR RRRR
|||| ||||
++++-++++- Replacement value for this cheat

```

### Unknown ($FFF0, $FFF1)

The Game Genie rom writes 0 to $FFF0, $FFF1, $FFF0 in that sequence.

## Pattern Tables

When game mode is inactive, the Game Genie generates PPU pattern tablesthrough PPU $0000…$1FFF by the following method:
- When PPU A2 = 1:
  - PPU A4 → PPU D4 … D7
  - PPU A5 → PPU D0 … D3
- When PPU A2 = 0:
  - PPU A6 → PPU D4 … D7
  - PPU A7 → PPU D0 … D3

This creates 16 distinct objects that are used to build the menu graphics:

## Bugs

Because of how the hardware is designed, there are some bugs or limitations of this device:
- When a cartridge has something mapped at $4020–$7FFF (WRAM, PRG ROM) and a code for region $C020–$FFFF is added, the Game Genie will hold the slave cartridge's /ROMSEL at 1 when reading from that location. But then, the cartridge logic will see this read cycle as something below $8000, enabling the chip that is mapped here, causing bus conflict at this location and resulting in invalid data being returned to the CPU. [1]Some codes rely on these bus conflicts. For example, in The Legend of Zelda, the code XYYYYL causes the sword beam to leave bait behind, but crashes instead if bus conflicts are not emulated.
- Cartridges that rely only on PPU /A13 when decoding CHR-ROM (like MMC5) will not display the the Game Genie menu properly, as the Game Genie ignores this line, causing bus conflict. [1]
- According to the Game Genie patent, the process of determining if a code with comparison should be enabled is asynchronous. This makes it impossible to apply multiple codes with the same address but different replace/compare values. The Game Genie allows entering such codes, but when it comes to sending them to the ASIC chip, only the first such code will be enabled.

## References
- ↑ 1.01.1Forums: Game Genie - does it work for $e000-$ffff + WRAM?

## External links
- nesgg.txt– NES Game Genie Code Format DOC v0.71 by Benzene of Digital Emutations, 1997-07-10
- Patent US5112051A – Interfacing device for a computer games system
- NES Game Genie ROM disassemblyby Kevin Selwyn ( GitHub page)
- NES Game Genie ROM disassemblyby qalle

# Game bugs

Source: https://www.nesdev.org/wiki/Game_bugs

Listed are games that have been tested on NES or Famicom hardware and verified to look wrong or odd. This can be caused by NES hardware limitations, programming errors, or even intentional effects within the game. Refer to this if you're developing an emulator and find a game that looks wrong, before you look for a problem in your emulator. If you are attempting to give your emulator "bug for bug" compatibility, you'll want to make sure that these glitches (or unusual behaviors) appear the same in your emulator as they do on the NES.

This is an incomplete list that concentrates on commercial games. For an overview of common compatibility problems in homebrew games, see Program Compatibility. Sometimes, a bug slips into a game to make it rely on less-than-intentional features of the hardware; for those, see Tricky-to-emulate games.

## General bugs

| Game | Problem |
| The Addams Family | The in-game status bar occasionally bumps vertically by 1 pixel, caused by non-solid background pixels overlapping the sprite zero that is used for the status bar split. |
| Ai Senshi Nicol | Loading CHR-RAM can fail due to a race condition, causing level graphics to be incorrect. This occurs if an NMI lands between the two PPUADDR writes for the graphics copy, because the NMI handler reads PPUSTATUS, clearing the address write latch. Whether this happens depends on FDS disk access timing, which does not take a well-defined, fixed amount of time. It is not clear if this can happen with real-world timing variance on real hardware, but it is a concern for emulators. |
-
-
| Akumajou Densetsu | When a door is opened/shut when the player goes through them, the screen shakes by one pixel. During Stages 6-4 and 6-5, the game uses horizontal scrolling with vertical arrangement (with one nametable reserved for the rising water) and masks the leftmost column, causing tile/attribute glitches at the left edge and clipping part of the status bar. Castlevania III instead uses a third nametable from the MMC5's ExRAM for the rising water, preventing these issues. |
| Akumajou Special | The game over screen is sometimes glitched when it occurs in bidirectional scroll stages. (Validated in Game Center CX.) |
-
-
-
| Armadillo | The in-game status bar occasionally bumps vertically by 1 pixel. Slowdowns occur frequently. Crashes on Dendy consoles - fix: [1] |
| Asmik-kun Land | Sets the triangle period to $0003 at the end of snare/tom pitch bends, causing high-pitched (but not ultrasonic) beeps in some music tracks. |
| Aspic: Majaou no Noroi | Disk flip detection is unreliable due to a poorly structured loop for $4023 polls.[1] This is especially problematic on emulators (including physical drive emulators) which can swap disk sides instantly. (TODO: Determine real disk drive behaviour) |
| Atari R.B.I. Baseball, The Quest of Ki, Valkyrieの冒険 (all Vs.) | These Vs. Unisystem ports of Namco cartridge games can run on any of the RP2C03 and RP2C04-0001...RP2C04-0004 PPUs by setting the DIP switch appropriately. The look-up table they use for the RP2C04-0001 setting selects the wrong colors for white and light gray however, causing white to be displayed as light gray instead. |
-
| Battletoads | Clinger Winger (Level 11) is impossible with 2 players as player 1 and the Buzzball start moving before player 2 does. Fixed in the Japanese and European versions. |
-
-
| Castlevania | Revision 0 of the US version is prone to crashing when too many sprites are active (for example, when fighting Death), due to the game loading the wrong ROM bank after jumping to the NMI routine. In the US versions, due to DMC DMA controller corruption, holding Up when Simon is hit can occasionally cause the game to pause. Castlevania only uses DPCM for a short grunt sample when Simon is hit, and the US versions do not have any controller re-read code, instead seemingly relying on inputs being ignored while the sample plays; Start is still processed to allow pausing, however, and if DMC DMA causes a controller bit deletion before Start is read, an Up input will be read as Start instead. The Japanese versions (FDS and Famicom) use controller re-read code, so they are exempt from this issue. |
| Castlevania II - Simon's Quest | Sometimes incorrect tiles are shown on the playfield. |
-
-
| Castlevania III - Dracula's Curse | The DMC channel in music sometimes mutes. When pressing the B button at the exact time that Trevor falls off a block, the whip sound plays, but Trevor doesn't attack. |
| Chip 'n Dale Rescue Rangers | As the intro sequence is fading out, the game displays sprites with incorrect tiles in the positions for the player initials and life indicators at the top of the screen. When the screen fades back in, the same positions have the correct graphics. |

-
-
-
| Commando | Graphical issues primarily stemming from slow PPU updates:[2] "Uninitialized" nametable and sprite tiles are frequently visible due to staggered CHR-RAM updates. Vertical scrolling is very jerky due to slow PPU VRAM updates sometimes pushing OAM DMA and PPUSCROLL updates outside of vblank, effectively offsetting the scroll. The screen may briefly display garbage after a player death due to a PPUCTRL write (intended to toggle NMIs) which alters the pattern table mapping and sprite size during rendering. |
| Crystalis | The scanline above the status bar and above text boxes looks wrong. |
| Dizzy The Adventurer | Resets the sound phase every frame, causing a nasty 60Hz buzz. |
| Donald Land | When the player progresses too quickly by boosting off of apples, the background loads fall behind and the scroll seam becomes visible. |
| Donkey Kong | Repeatedly using the top-left ladder in 50m while several barrels are active can cause glitched tiles to appear. This is because on lag frames, the PPUCTRL write to re-enable NMIs can occur while the vblank flag is set, triggering an NMI late into vblank and causing PPU nametable tiles to be written during rendering. The FDS version fixes this by waiting until the vblank flag in PPUSTATUS is clear before toggling NMIs. |
| Door Door | Palette RAM is not initialized correctly if the VBL flag (PPUSTATUS bit 7) is set on power-up/reset due to the PPU's power-up state. |
-
  -
  -
-
| Double Dragon | "Garbage sprites" (sprite 0 (for sprite-0 hit) and sprite 1) can be seen in the lower right of the game screen. Sprite 0 consists of tile $FF (a black tile with 2x2 non-background pixels (i.e. a tile with a 2x2 "dot" in it, visually similar to ▣ or ⚀)), and the priority bit set. Sprite 1 consists of tile $FE (a tile consisting entirely of a single non-transparent colour, often palette entry $0F but varies per stage). The screen will sometimes shake vertically on heavy sprite usage. |
| Double Dragon II | The status bar may suddenly change colors: sometimes when scrolling vertically it shows incorrectly for a couple of frames. |
| Double Dragon III | Same status bar issue as Double Dragon II. |
| DuckTales | The scroll split between the status bar and playfield is placed in the middle of the status bar's bottom-most scanline, causing it to jitter when scrolling horizontally. Additionally, the game uses different sprites for the status bar and playfield that are swapped mid-frame via a PPUCTRL write, and hides the status bar's sprites whenever the player's metasprite overlaps it, further complicating sprite 0 hit behavior and causing the bottom-most scanline to scroll across the entire screen instead. |
| Duck Maze | The original 60-pin release for famiclones relies on decimal mode working as it does in a 6502. Without decimal mode, score counting works wrong, and the game may never finish counting down at the end of a level. (Fixed for HES's 72-pin rerelease.) |
-
| Eliminator Boat Duel | Audible buzzing due to the DMC channel being enabled in its power-on state every frame.[3] |
| Exed Exes | When pausing, the immediate next note of the music will play after the pause jingle completes. |
-
-
| F-1 Race | The game displays garbled graphics and/or freezes if the Start button is held during power-up/reset. Will not boot on NES-001 (frontloader) due to its PPU warm-up loop being too short. |
| F-15 City War | The last boss is glitched when playing through the game from start to finish in its original INES Mapper 173 and AVE "1.x" version. It is not glitched when jumping to the last boss through cheating in those versions, and never glitched in the later AVE "1.1" and Gluk Video versions. |
| Ghostbusters (J) | Loads the ending text from the wrong CHR bank, causing it to display a blank screen that eventually scrolls "りり" (hiragana "riri") on the screen. |
-
-
| Ghosts 'n Goblins | Relies on the VBL flag (PPUSTATUS bit 7) being clear to wait before enabling NMIs during the reset handler. If it is set, the write to PPUCTRL occurs too early and the game fails to boot. Garbage sprites sometimes appear on-screen due to incomplete display lists being uploaded to OAM. (see Strider) |
| Gimmick! | The game's controller polling routine relies on extra DMC DMA controller corruption only present on select hardware revisions (original RF, Twin, and Titler Famicoms) to detect if a controller read was corrupted. On NES consoles and the New/AV Famicom, DMC DMA glitches are not as pronounced, causing the routine to accept a corrupted read. This results in occasional spurious inputs such as pausing when holding up, or turning/inching rightwards while idle. The PAL 2A07 CPU does not have this conflict, so the glitch is avoided entirely in the European release. |
-
-
| Hebereke | The triangle channel in the title screen music is silent, except after exiting from the password screen. The HUD disappears when the player overlaps its vertical position, due to both using the same CHR ROM sprite bank that is swapped mid-frame. |
| Hottarman no Chitei Tanken | If gameplay slows down due to excessive on-screen objects, scrolling may glitch and display garbage values. |
| The Immortal | Uses color $0D (blacker than black) as black and color $0E (normal black) as a darker gray than color $2D while setting all three deemphasis bits, causing picture instability on many television sets and TV capture cards. (see Color $0D games for more) |
| Ironsword: Wizards and Warriors II | Noise channel doesn't work properly, sometimes plays longer notes and sometimes mutes. |
-
-
-
| Kirby's Adventure | When Kirby copies a new ability, the status bar icon may flicker or display incorrect attributes. (?) Slowdowns occur frequently. Jump and attack inputs are sometimes ignored. |
| The Legend of Zelda | Vertical scrolling between screens is very messy, jumping by 3-4 scanlines because of an incorrect fine y from the $2006 writes, two reads from $2007, and imprecise timing on these accesses that can cause a $2007 read's y increment to be lost.[4] Vertical scrolling while DPCM is playing can cause the vertical scroll to momentarily jump due to conflicts between 2nd $2006 writes and automatic fine y increments. See PPU scrolling for details on how these registers interact with scrolling. |
| Linus Spacehead's Cosmic Crusade | The music lacks noise channel instruments due to a sound driver bug. |
| The Lord of King | Will not boot on NES-001 (frontloader) due to an inadequate wait before enabling NMIs. Fixed in Astyanax. |
| Magic John | Same as The Lord of King. Fixed in Totally Rad. |
-
-
| Mega Man | When pausing and unpausing the game with the Select button, the high bits of the triangle channel's period are not rewritten until Mega Man's teleporting animation finishes, causing distorted, high-pitched noise due to them being left at 0 until then. If Fire Man is defeated and the stage clear orb is obtained while his ground flame remains active, it will incorrectly use tiles loaded for the stage clear text before being deleted, due to them occupying the same space in CHR RAM. |
-
-
| Mega Man 3 | The first scanline of the weapon menu and the scanline above Shadow Man in the stage select screen are glitched due to improperly timed scroll splits. In revision 0 of the PAL version, when the Wily Machine is fought, the floor heavily jitters up and down across the screen. This is because two MMC3 scanline counter IRQs are used for the Machine and the floor, but after the first IRQ, the new reload value (116) is written to $C000 without a write to $C001, which can sometimes happen at the same time the counter is clocked from 0 by PPU A12, overwriting it with the old reload value (58) and causing the split to happen much earlier. This was fixed in later revisions by changing the timing of the $C000 write. |
| Mega Man 5 | In Gyro Man's stage, inside the two elevators, the floor moves up by a few pixels when the elevator goes up, and move back down when the screen is fast-scrolled. |
| Metroid | The ending song of the Japanese version is supposed to use volume envelopes, yet the in-game playback plays without them. The reason is that the memory location that holds the value that will be written to $4080 on the next start of a note is re-used for some other purpose (routine at PC $6779 in revision 3). |
| Micro Machines | Graphical problems on PPU revisions prior to 2C02G due to OAMDATA unreadability. Resetting on Famicom and NES-101 (toploader) doesn't always work because the game fails to clear PPUCTRL and PPUMASK on reset. |
| Mitsume ga Tooru | Garbage data is visible in the upper side of the status bar by when shaken by an earthquake, due to the status bar and playfield both sharing the nametables. |
| Monopoly | Holding any direction on the Control Pad while landing on a property owned by another player when you don't have enough cash will skip paying the rent. |
| Neunzehn - 19 | Disk flip detection is sluggish due to the game waiting ~512ms between $4023 reads. This is especially problematic on emulators (including physical drive emulators) which can swap disk sides instantly. |
| Othello | The FDS DV 2 and Famicom versions can crash and show garbled graphics[5] during CPU matches, due to a stack overflow caused by nested subroutine calls in the CPU player logic. Seemingly fixed in FDS DV 3,5(?), leaked Rev 1 FC, and NES versions. |
| Othello (Famiclone) | The original 60-pin release for Famiclones relies on decimal mode working as it does in a 6502. Without decimal mode, spots are counted wrong. (Fixed for HES's 72-pin rerelease.) |
| Panic Restaurant | The in-game status bar is bumped up by 1 pixel. |
| Rad Racer | Steer to the far left, and a background scanline will be seen on the road. |
| Rambo | One scanline is occasionally glitched, for the same reason as in Super Mario Bros.[6] |
| Rampart (Jaleco) | During build phase, the drums (on the noise channel) drop out fairly early. |
| Romancia | PRG1 version has a slightly shaky status bar due to a very imprecise wait-for-sprite-0-hit loop. PRG0 version is fine. |
| Snow Bros. | When you clear the stage and rise to the next floor, incorrect CHR bank switching results in glitches in the new floor's graphics. |
| Solar Jetman (NTSC version) | Some songs use the sweep registers heavily, which are not restored after a sound effect plays that uses the sweep registers as well. The PAL version seems to have corrected this error. |
-
-
| StarTropics | The music data for two songs were not set up correctly.[7] The island map music (NSF track 1) has a problem with the second pulse channel: it is intermittently silent or playing the wrong notes after the first minute or two, because the music data was not made to fit/repeat properly. The music for one of the ending cutscenes has a silent triangle channel except for a single glitched note due to an error in the music data. |
| Strider | The NMI handler pushes an incomplete display list to OAM during lag frames, leading to visible garbage sprites.[8] |
| Super Cars | The top of the screen flickers on PPU revisions prior to 2C02G due to OAMDATA unreadability. |
-
-
- ``
| Super Mario Bros. | The status bar shakes horizontally on heavy sprite usage and the music slows down. This can be seen especially in worlds 6-4, 7-4 and 8-4, where the large number of hammer objects created by Bowser's code causes the processing time to overshoot a frame. NMIs are disabled on entry to the NMI code and only reenabled when the CPU is "idle", thus when the overshoot occurs, the CPU "misses" a frame, causing general slowdown and status bar shakiness. At various parts of 1-2, in certain CPU/PPU alignments, a single scanline gets glitched. This is caused by writing to PPUCTRL to reenable NMI at the exact end of the previous scanline, causing the PPU to begin that scanline from the first nametable instead of the second.[9] When hitting a ? block while maintaining a run at top speed, after the bounce animation finishes, the block disappears for up to two frames before settling in the background. (Updating the nametable at the scroll seam has priority.) |
-
-
-
-
| Super Mario Bros. 3 | The first scanline after a scroll split is glitched. This shows up as garbage above the left side of the status bar and as incorrectly scrolled lines in the "spade" (not N-spade) bonus game. Note blocks containing items become squarer for a second while the item is popping out. (This is an artifact of the sprite priority exploit that it uses.) If a Hammer Bros. battle ends precisely when a note is starting, the note will freeze on an incorrect duty cycle. Big fat attribute glitch on the right side of most levels, because this game uses horizontal scrolling with vertical arrangement. Discussed heavily.[10] |
-
-
| Teenage Mutant Ninja Turtles | Sprite overflow (due to large numbers of enemies) causes the status bar to flicker. Uses Y scroll values greater than 239, causing the PPU to read the attribute table as nametable data before looping back to the same nametable instead of rolling to the next nametable down. |
| Tetris (Bullet-Proof Software) | Sets APU Triangle period to longest value instead of actually muting it. |
| Tetris 2 + Bombliss | The 2-player mode will become softlocked (requiring a reset) if the second player presses the start button to pause the game, as the game does not properly account for the start/select buttons being present on the second controller in this scenario. This is possible if expansion port controllers are connected, or if the game is being played on the NES or the New/AV Famicom. |
| Titanic Mystery: Ao no Senritsu | Same disk flip/swap detection problems as Aspic: Majaou no Noroi. |
| Topple Zip | On PPU revisions 2C02G and onwards, garbage sprites may be visible at the start of a level after power-on/reset. This is because the game accidentally reads from a mirror of OAMDATA during rendering to fetch an index to a sprite object pointer in this scenario, seemingly relying on PPU open bus from unreadable OAMDATA. If OAMDATA is readable instead, then further fetches for the sprite object use more PPU register mirror reads during rendering, resulting in the creation of garbage sprites.[11] |

| Zelda II: The Adventure of Link | Reads from PPUDATA during the title screen twice, moving the background upward by 2 scanlines after the split point. |
| Zombie Nation | Same as Tetris (Bullet-Proof Software), above |

## Reliance on power-on mapper state

| Game | Problem |
| Bad News Baseball and Gekitou Stadium!! | The intro sequence is started 1 frame before the MMC1 CHR bank registers are initialised. Depending on the initial CHR bank values, the sprite 0 hit detection can fail and cause the sequence to hang (with the music still playing). |

| Digital Devil Story: Megami Tensei II | When powered-on with uninitialized SRAM, a "DDS II" logo is flashed from left to right before proceeding with the normal introduction. The logo's background looks garbled because the game has not fully initialized the CHR bank select registers at that point. |
| Mega Man 5 | Neglects to disable MMC3 IRQs on reset and executes a CLI instruction before the game has fully initialized, causing the game to not boot if an IRQ was pending at that point. |
| Popils (Prototype) | Interrupt vectors including reset rely on the MMC3 PRG banking mode at power-on. (expects $8000.D6 = 0, second-last PRG bank mapped to $C000) It also neglects to initialize the nametable arrangement and PRG-RAM protection state. TODO: Is this expecting MIMIC-1 with PRG-RAM instead? |
| Populous (Prototype) | Neglects to initialise the MMC1 control and CHR bank 0 registers. CHR-RAM contents will be filled with incorrect data at power-on if CHR bank mode = 1 (switch two separate 4 KB banks) and CHR bank 0 = 0. |

## Reliance on RAM values

Several games erroneously rely on RAM areas being pre-populated with certain values at power-on, despite RAM contents not being in a consistent state on power-on. Other games rely on similar values, but in PRG-RAM (WRAM), or CHR-RAM.

Note that using power-on RAM content as a seed for random number generation (such as in Final Fantasy) is not a game bug, even if it makes speedruns harder to verify on console.

| Game | Problem |
| Cheetahmen II | Suspected that certain RAM values may affect being able to reach the final two levels of the game (levels 5 and 6).[12] |
| Chinese Kungfu: 少林武者 | The game will not display the first self-running demo correctly if $0707 contains the value $FF at startup. Values $00-$09 will cause one of nine self-running demo sequences to play first, while values above that will cause the game to always begin with the first demo sequence. For the Western localization (Challenge of the Dragon, not to be confused with the Color Dreams game of the same name), the developers seemed to have noticed this problem and went out of their way to initialize this memory location with $00. |
| Cybernoid | On the title screen, the default selection for the difficulty level changes based on the contents of RAM at power on. Also, the music may not start when starting a game (depending on uninitialized RAM values).[13] |
| Dancing Blocks (Sachen) | Game will not boot when addresses $EC and $ED are both set to $FF.[14] |
| Erika to Satoru no Yume Bouken | Plays uninitialized sound RAM as a waveform on the title screen, resulting in a buzzy tone on some power-ons[15]. |
| F-1 Race (Beta Version only) | Title screen will be skipped if $6B and $70 contain non-zero values.[16] Game blindly reads and uses values from $51, $55, $70, $A4, and $0200-02FF (via sprite DMA).[17] |
| Famicom Jump II: 最強の7人 | If save RAM is initialized to all 00s, the game will freeze at the very first power-on with a black screen. It will work normally after a soft reset as well as subsequent power-ons. |
| Gun.Smoke (FDS version only) | The music player's RAM is not cleared before starting the title screen song, resulting in a garbage first noise channel note, with random properties, if that RAM is not zero. |
| Huang Di | Uses uninitialized RAM at $0100 to determine if Cheat Mode is enabled or not. When it's zero, cheat mode is enabled, allowing infinite jumps in midair. |
| Huge Insect | Artifacts show up on the screen when nametable RAM is initialized with random values (the game only appears to initialize one of the 2 nametables). |
| Keroppi to Keroriinu no Splash Bomb! | Can crash during the final boss if any of $0680-$069F contain any value between $30-$33. This is because the game's playfield data begins 2 rows down from the top of the screen, so when checking for playfield collision, the position of the falling fire is adjusted by $20 and underflows at the top of the screen, using uninitialized RAM after the playfield for these non-existent rows. If the value indicates the fire can land there, the game uses an invalid jump table index and crashes. |
| Layla | The music player's RAM is not cleared before starting the title screen song, resulting in a flubbed first note, sometimes with a frequency sweep, depending on power-on RAM content. |
| Minna no Taabou no Nakayoshi Daisakusen | Requires that address $11 be initialized to a value other than $00, otherwise the game will not start.[18] A PRG1 version corrects the issue. |
| Silva Saga | When save RAM is initialized with all 0s, the game incorrectly creates 3 blank saved games which do not work properly.[19] |
| Super Mario Bros. | Blindly reads and uses variables used for the continue feature's starting world number (accessed by pressing A+Start on the title screen) and the hard mode/second quest toggle on warm starts. A cartridge swap involving Tennis is often used to access "glitch worlds" beyond world 8 as a result of this.[20] |
| Super Mario Bros. (bootleg versions) | Relies on portions of RAM containing $00, otherwise player starts at world 0-1.[21] |
| Terminator 2: Judgment Day | The copyright screen is skipped if RAM is filled with $00 (more generally, if a high score table checksum happens to be valid).[22] |
| Ultima: Exodus | Relies on PRG-RAM contents before they're initialised; a fresh/new game may see artifacts such as shaking/wobbly text during the initial text intro screens, corruption of text intro screen fonts, and possibly audio anomalies.[23] |

## "Impossible" controller input

Many games behave oddly when button combinations that would be impossible (or at least very hard) to input on a standard controllerare pressed. This comprises pressing left+right and up+down simultaneously. Such impossible controller input should probably be prevented by default in an emulator, but they can be optionally allowed for experimental purposes.

Alternatively, controller reading routinesin most games combine inputs from both the standard ports and the Famicom's expansion port(even in international versions) to support replacement controllers, so it is possible to press one direction in a standard controller and simultaneously the opposing direction in the replacement controller to achieve the same effect.

| Game | Problem |
| Bad Street Brawler | A Power Glove Gaming Series game which maps a unique attack to left+right. It instantly kills one enemy per stage. |
| Battletoads | Pressing up+down in the vertical tunnel level kills the player instantly. Additionally, pressing left+right causes the player to walk up/back even when in pure 2D stages, which can result in certain areas becoming impossible to complete. |
| Mega Man 1 and 2 | By pressing up+down at the top of a ladder, one may enter the "climbing ladder" state briefly above the top of the ladder. This allows "zipping" through walls. |
| Panic Restaurant | Pressing up while crouching (by pressing down, thus pressing up+down simultaneously) the player character's sprite uses garbage data including the damage sprite. This does not occur if up is pressed before down; the player chef merely stands still. |
| Predator | Pressing left+right+A/B in normal levels, or up+down+A/B in the level number screen before 'big mode' levels, activates a level skip. |
| Spy vs. Spy | The character turns into an airplane and other garbage sprites when pressing left+right or up+down. |
| Star Soldier | Cheat code button combinations include left+right and left+right+up+down inputs, which rely on the fact that both controller inputs are ORed bitwise when polling.[24] |
| Super Mario Bros. 2 | Ladders can be climbed very fast by pressing up+down. |
| Teenage Mutant Ninja Turtles | If you press the attack button while you jump while pressing up+down, the player character uses a garbage sprite, and attacks will use unusual (i.e. garbage data) hitboxes. |
| Teenage Mutant Ninja Turtles II: The Arcade Game | When you jump with a left or right move while pressing up+down, the player character will move in unusual directions and speeds, possibly screen-wrapping. |
| Tetris (Nintendo) | Holding left+down+right will cause the current and next piece sprites to flicker, slowing the game down in the process. |
| Tiny Toon Adventures | The player can gain unusual speed when pressing left+right. |
| Zelda II: The Adventure of Link | Link can gain tremendous speed when pressing left+right. |

## Overscan ugliness

Some games display junk tiles in the overscanarea, which is usually not seen (or is at least partially obstructed) on real TV sets. Examples include the NTSC versions of Metal Gear (e.g. in the jungle area when gameplay starts) and Solstice (on the title screen).
- Metal Gear
- Solstice – The Quest for the Staff of Demnos

## References
- ↑https://forums.nesdev.org/viewtopic.php?t=16923
- ↑"The Jumpy Scrolling and Graphical Glitches of NES Commando - Behind the Code" by Displaced Gamers(30 minutes)
- ↑Eliminator Boat Duel
- ↑Zelda Screen Transitions are Undefined Behaviour: A deep dive into Zelda scrolling that is largely good until the "Scroll Down to Scroll Up" section, which has significant factual errors.
- ↑"オセロ LEVEL３がバグる ファミコン" ("Othello level 3 CPU bugged on Famicom") by Hiroshi Tsuchiya(Japanese, 8 minutes)
- ↑http://forums.nesdev.org/viewtopic.php?p=154894#p154894
- ↑"Fixing StarTropics" by Brad Smith(5 minutes)
- ↑"The Garbage Sprites in Strider (NES) - Behind the Code" by Displaced Gamers(15 minutes)
- ↑https://forums.nesdev.org/viewtopic.php?p=112424#p112424
- ↑http://forums.nesdev.org/viewtopic.php?f=10&t=7844
- ↑Topple Zip accidentally relies on unreadable OAMDATA
- ↑http://forums.nesdev.org/viewtopic.php?p=178154#p178154
- ↑http://tasvideos.org/forum/viewtopic.php?p=463659&sid=7cfe55942ee3420275d8f16b2a59770a#463659
- ↑http://tasvideos.org/forum/viewtopic.php?p=463659&sid=7cfe55942ee3420275d8f16b2a59770a#463659
- ↑N163 Sound RAM Initialisation Behaviour
- ↑http://forums.nesdev.org/viewtopic.php?p=178168#p178168
- ↑http://forums.nesdev.org/viewtopic.php?p=178015#p178015
- ↑http://forums.nesdev.org/viewtopic.php?p=185663#p185663
- ↑https://forums.nesdev.org/viewtopic.php?f=11&t=11045
- ↑"Access Glitch Worlds in Super Mario Bros. via NES Tennis" by Retro Game Mechanics Explained(13 minutes)
- ↑http://forums.nesdev.org/viewtopic.php?p=178163#p178163
- ↑http://forums.nesdev.org/viewtopic.php?p=180752#p180752
- ↑http://forums.nesdev.org/viewtopic.php?p=185163#p185163
- ↑Star Soldier cheat codes(Japanese)

# List of games by mirroring technique

Source: https://www.nesdev.org/wiki/List_of_games_by_mirroring_technique

This article categorizes games by their rendering and scrollingmethods, and how that relates to mirroring.

| Scrolling Type | Mirroring – With Status Bar | Mirroring – With Status Bar and Parallax Scrolling Effect | Mirroring – With Parallax Scrolling Effect | Mirroring – Without Status Bar and Parallax Scrolling Effect | Games example | Comment |
| 1-screen fixed Only | Any | Vertical, Horizontal2 | Vertical, Horizontal2 | Any | Donkey Kong |  |
| Horizontal Only | Vertical | Vertical, Horizontal2 | Vertical, Horizontal2 | Vertical | Castlevania, Cheetahmen II, Gimmick!, Gradius, Super Mario Bros. |  |

| Vertical Only | Vertical, Horizontal, Single Screen, 3-screen V/H3 | Vertical, Horizontal2, Single Screen2, 3-screen V/D3 | Horizontal2, Vertical1, Diagonal, 3-screen V/D3, 4-screen4 | Horizontal | Gun.Smoke, Ice Climber, Recca | Horizontal mirroring with a status bar works best with as status bar will have to change address when scrolling vertically. If you are using a parallax scrolling effect on the entire screen with a status bar, such as the Recca, it is best to use a Single Screen, Horizontal, or the Vertical mirroring with a scanline counter IRQ. |

| Horizontal Only, field limited horizontally | Vertical | Vertical | Vertical | Vertical | Bomberman, Lode Runner | No data has to be loaded at all when scrolling horizontally, but the area is limited to two screens. This screen type, some of parallax scrolling effect does not work. |
| Vertical Only, field limited vertically | Horizontal | Horizontal | Horizontal | Horizontal | Ninja Kun, Wrecking Crew | No data has to be loaded at all when scrolling vertically, but the area is limited to two screens (less the status bar if present). |

| Horizontal/Vertical aligned screens | Vertical, Horizontal2, Diagonal, 3-screen V/D3, 4-screen4 | Vertical, Horizontal2, Single Screen2, 3-screen V/D3, 4-screen4 | Vertical, Horizontal2, Diagonal, 3-screen V/D3, 4-screen4 | Alternate H/V, L-shaped, Diagonal, 3-screen D3, 4-screen4 | Air Fortress, Duck Tales, Jackie Chan, Mega Man series, Metroid, TMNT | For use if scrolling direction changes only on a screen-based pattern, as in Metroid and Mega Man 3, 4, 5, 6. Horizontal mirroring with a status bar works best with as status bar will have to change address when scrolling vertically (Also work as Diagonal mirroring) or playfield will have to be written twice to memory. (Panic Restaurant, TMNT) If you are using a parallax scrolling effect on the entire screen with a status bar, such as the Recca, it is best to use a Single Screen, Horizontal, or the Vertical mirroring with a scanline counter IRQ. |
| 1-screen switching by the Horizontal/Vertical | Alternate H/V, Vertical, Diagonal | Alternate H/V, Vertical, Diagonal | Alternate H/V, Diagonal | Alternate H/V, Diagonal | Guardian Legend, Hydlide 3, Legend of Zelda | Depending on the direction of the pattern to scroll in a single screen, it is the best choice for switching the mirroring by the mapper. |

| Horizontal/Vertical/Bidirectional aligned screens | Vertical <-> Single Screen2, Horizontal2, Vertical, 4-screen4 | Vertical <-> Single Screen2, Single Screen2, Horizontal2, Vertical, 4-screen4 | Vertical1, Horizontal2, Diagonal, 4-screen4 | Vertical1, Horizontal2, Diagonal, 4-screen4 | Akumajou Special, Rockman 4 Minus Infinity, TMNT II/III | Horizontal or 4-screen mirroring with a status bar works best with as status bar will have to change address when scrolling vertically or playfield will have to be written twice to memory. (TMNT III: The Manhattan Project) Vertical mirroring Only with a status bar works best with a scanline counter IRQ. (TMNT II: The Arcade Game) If you are using a parallax scrolling effect on the entire screen with a status bar, such as the Recca, it is best to use a Single Screen, Horizontal, or the Vertical mirroring with a scanline counter IRQ. |
| Bidirectional, field limited vertically | Horizontal2 | Horizontal2 | Horizontal2 | Horizontal2 | Super Mario Bros. 3, Tiny Toon Adventures | No data has to be loaded at all when scrolling vertically, but the area is limited to two screens (less the status bar if present). |

| Bidirectional, field limited horizontally | Vertical | Vertical | Vertical1 | Vertical1 | Fire Emblem | No data has to be loaded at all when scrolling horizontally, but the area is limited to two screens. Vertical mirroring with a status bar works best with a scanline counter IRQ. This screen type, some of parallax scrolling effect does not work. |
| Bidirectional, field limited 4-screen | 4-screen4 | 4-screen4 | 4-screen4 | 4-screen4 | Gauntlet | No data has to be loaded at all when scrolling 4-screen, but the area is limited to four screens (less the status bar if present). |
-
-

| Free bidirectional | Single Screen2, Horizontal2, Vertical, 4-screen4 | Single Screen2, Horizontal2, Vertical, 4-screen4 | Vertical1, Horizontal2, Diagonal, 4-screen4 | Vertical1, Horizontal2, Diagonal, 4-screen4 | Battletoads, Castlevania II, Hebereke, Kirby's Adventure, countless RPG games | If using horizontal or 4-screen mirroring with a status bar there are 2 possibilities: The status bar will have to change address when scrolling vertically (Conquest of Crystal Palace, Double Dragon series, Gradius II) The playfield will have to be written twice to memory (Incredible Crash Dummmies, Kirby's Adventure, Little Nemo: The Dream Master), which only works if the status's bar size remains constant. Vertical mirroring with a status bar works best with a scanline counter IRQ. (Jungle Book, Mickey's Safari in Letterland) |
| Depth screen | Vertical, Horizontal, 4-screen4 | Vertical, Horizontal, 4-screen4 | Vertical, Horizontal, 4-screen4 | Vertical, Horizontal, 4-screen4 | After Burner, F-1 Race, Mach Rider, Rad Racer | Bidirectional Pseudo 3D depth perspective works best with a CHR bank switching ROM nametables. (After Burner) |
- 1 : Vertical glitches on PAL screens and on NTSC that doesn't overscan.
- 2 : Horizontal glitches will be unavoidable when scrolling (see above).
- 3 : 3-screen mirroring, you can use only specific mapper of MMC5.
- 4 : 4-screen mirroring, and can be used only when you added an additional RAM to the cartridge board.

# List of games with significant regional differences

Source: https://www.nesdev.org/wiki/List_of_games_with_significant_regional_differences

This list attempts to document regional changes that are significant.

## FDS

Several games that were originally released for the FDSwould later get released on cartridge for the NES outside of Japan. The 3-D Battles of World Runner The FDS version features enhanced FDS audio. Blades of Steel The FDS version is significantly cut down compared to the NES version. Bubble Bobble The NES version replaces the save file menu with a password menu. The FDS version features a red tint on the graphics while the NES version does not. Double Dribble The NES version includes additional graphics and music not included in the FDS version. The FDS version features enhanced FDS audio. Castlevania The NES version removes the save file menu. Castlevania II: Simon's Quest The NES version replaces the save file menu with a password menu. The FDS version features enhanced FDS audio. Ice Climber The FDS version is based on the Vs. Systemversion. Jackal The NES version features expanded content and features compared to the FDS version. The Legend of Zelda The FDS version features enhanced FDS audio. Metroid The NES version replaces the save file menu with a password menu. The FDS version features enhanced FDS audio. Super Mario Bros. 2 Originally released for the FDS as Yume Koujou: Doki Doki Panic . The NES version removes the save file menu. Mystery Quest The NES version is significantly cut down compared to the FDS version. Wrecking Crew The FDS version allows saving and loading custom level data without the need for the Family BASIC Data Recorder. Zelda II: The Adventure of Link Several graphical and gameplay differences between the FDS and NES versions. The FDS version features enhanced FDS audio.

## NTSC and PAL

Many games that were released in both NTSC and PAL regions are only trivially different, with the primary difference being slower action in the PAL version. Air Fortress PAL optimisation Batman music speed (not pitch) Battletoads the two-player bug with the Clinger Winger level is fixed in the PAL version Battletoads & Double Dragon gameplay speed Blaster Master there are more bugs in the PAL version California Games music differs at title screen Castlevania II: Simon's Quest music speed and pitch Castlevania III: Dracula's Curse music speed and pitch Dr. Mario full PAL optimisation Dragon's Lair gameplay speed DuckTales gameplay speed The Guardian Legend gameplay speed Kirby's Adventure speed adjustment The Legend of Zelda intro scrolling speed Little Samson gameplay speed Mario & Yoshi (PAL) / Yoshi (NA) full PAL optimisation Mega Man music speed and pitch Mega Man 2 music speed and pitch Mega Man 3 music speed and pitch Mega Man 4 music speed and pitch Mega Man 5 music speed and pitch Rainbow Islands: Bubble Bobble 2 (PAL) / Rainbow Islands (NA) completely different ports Rygar gameplay speed Solomon's Key 2 (PAL) / Fire 'n Ice (NA) gameplay speed StarTropics gameplay speed Super Mario Bros. gameplay speed, music speed and pitch Tetris full PAL optimisation Tetris 2 full PAL optimisation Wario's Woods full PAL optimisation Yoshi's Cookie full PAL optimisation Zelda II: The Adventure of Link vertical movement speed

## References
- Official games with PAL-adjusted code(forum thread)

## External links
- Category:Games_with_regional_differenceson The Cutting Room Floor

# PEGASUS 5 IN 1

Source: https://www.nesdev.org/wiki/PEGASUS_5_IN_1

PEGASUS 5 IN 1 (known in Poland as Złota Piątka - Golden Five) is an unlicenced Famiclone cartridge (sold in box with manual), which consists of the following 5 Codemasters' games (each of them was also separately available as licensed game):
- Big Nose Freaks Out,
- Micro Machines,
- Fantastic Adventures of Dizzy (blue version),
- Ultimate Stuntman,
- Big Nose The Caveman.

Cartridge menu was encoded into Dizzy and Ultimate Stuntman was slightly modified (Codemaster's title screen was cut off and game was adapted to be playable on Dendy's clones, as the original ROM hangs due to bug in video system detection routine). Other games are the same like licensed version.

The cartridge PCB was available in two versions:
- 4xROM (3x 2 Mbit mask ROM + 4 Mbit mask KROM with additional 74138 decoder)
- 2xROM (2 Mbit mask ROM + 8 Mbit mask ROM)

First version is probably older due to earlier datamarks on chips. PAL chip is slightly different in both versions, although the ROM's content (after combining) and mapper description is the same Registers

OUTER & INNER registers are cleared on startup but not software reset

```text
$8000-$bfff: OUTER REGISTER
[.... wPPP]
      ||||
      |+++- select 256KB outer PRG bank (one out of 5 games: 0=Dizzy, 1=BNFO, 2=US, 3=BNTC, 4=MM)
      +---- 1: protect OUTER register from further writes

```

```text
$c000-$ffff: INNER REGISTER
[.... pppp]
      ||||
      ++++- select 16KB inner PRG bank

```
Memory map
- $8000-$bfff - switchable 16 kB PRG-ROM bank
- $c000-$ffff - fixed 16 kB PRG-ROM bank

```text
$8000-$bfff | $c000-$ffff
------------+------------
PPPpppp     |  PPP1111

```

Trivia
- PAL's marking on every PCB was removed to make rev-en harder,
- The reset R-C circuit (which clears both registers at startup but does not affect them after console reset) is problematic, causing the cartridge to not start properly on every power-up or make this is a side-effect of the copy-protection descibed bellow,
- This multicart uses something whis acts like copy protection:
  - When game is power up, all regs are cleared by R-C circuit, so the menu routine from Dizzy's ROM is started,
  - At some moment game check for magic value in RAM if it was run one time or not. At this time it was not but it marks that the first time hast just occured.
  - At CPU cycle 101077 (0.06sec after powerup) game writes $0C (0b1100) to $8927, which would normally result in switching to Micro Machines bank and protect outer register from further writes. However, 100n capacitor in RC circuit is charged by very high 39k resistance and at this time it hasn't charged yet so the register is still hold in reset and ignores writes. Then game compares $0C with $08 and because comparison fails, it jumps to reset ($FFFC).
  - Now checking for first run fails so the game jumps to display menu routine.

# Tricky-to-emulate games

Source: https://www.nesdev.org/wiki/Tricky-to-emulate_games

At the very least the following games depend on hard-to-emulate or just obscure behavior. (If you're looking for a good first game for your new emulator, try anything made in 1984 or earlier, such as Donkey Kong .) Abarenbou Tengu (J), Captain Tsubasa 2 (J), Noah's Ark (E), Rampart (U), Zombie Nation (U) These refer to CHR ROM banks outside their size. A CHR ROM of the correct size will wrap the addresses correctly by discarding the most significant bits, as do most emulators. But if you are developing a flash-cart that just pre-programs its flash/SRAM memory with the CHR ROM data without address wrapping, graphical bugs will happen. If you want to simulate that behaviour in emulator, increase CHR-ROM banks number in iNES header twice and paste zeros in the the CHR area. Adventures of Lolo 2 , Ms. Pac-Man (Tengen), and Spelunker These games rely on proper timing for when the CPU polls for interrupts. When NMI becomes enabled while the vblank flag is already set, the resulting NMI occurs late enough in the instruction that another instruction is able to execute before the NMI is serviced. Air Fortress (J) Expects RAM to be enabled at power-up, as it clears WRAM before enabling it ($E000 D4). If MMC1 powers up with RAM disabled, the values written in the init routine go nowhere. If RAM is not enabled is used and the RAM's power-up value is anything but $00, unwanted color emphasis gets applied until the reset button is pressed. (The North American version enables WRAM first.) Arkista's Ring Crashes after completing the first loop if a read from PPU open bus returns 1 on bit 6, which is 0 unless using a mod such as NESRGB or Hi-Def NES that uses EXT output. Balloon Fight and Mario Bros. These games read the PPU nametablesthrough PPUDATA($2007). Balloon Fight uses it to determine the current tile of each star in the background when twinkling them. (The code is at $D603.) Mario Bros. uses it for background collision detection. The scroll split in the "Balloon Trip" mode of Balloon Fight also depends to an extent on the correct number of CPU cycles from the start of NMI to the start of display, but it's not particularly picky. Bandit Kings of Ancient China , Gemfire , L'Empereur , Nobunaga's Ambition II , Romance of the Three Kingdoms II , and Uncharted Waters Koei's MMC5 RPGs and strategy games use 8×8-pixel attributes and large work RAM. Bases Loaded II The screen glitches after a pitch is thrown ( screenshot) if writing $00 then $80 to PPUCTRLduring vertical blank does not cause an additional NMI. Batman: Return of the Joker , Dragon Quest , and Milon's Secret Castle These read level data and control logic from CHR ROM. The $2007 read must take into account not only the 1-byte delay (see entry for Super Mario Bros. ) but also CHR bank switching. Batman: RotJ also executes code from PRG RAM. Battletoads Infamous among emulator developers for requiring fairly precise CPU and PPU timing (including the cycle penalty for crossing pages) and a fairly robust sprite 0 implementation. Because it continuously streams animation frames into CHR RAM, it leaves rendering disabled for a number of scanlines into the visible frame to gain extra VRAM upload time and then enables it. If the timing is off so that the background image appears too high or too low at this point, a sprite zero hit will fail to trigger, hanging the game. This usually occurs immediately upon entering the first stage if the timing is off by enough, and might cause random hangs at other points otherwise. Battletoads & Double Dragon and Low G Man They read from WRAM at $6000–$7FFF despite there being none on the cartridge, relying on the values produced by open bus behavior. [1]Additionally, LGM disables WRAM through $A001, which some emulators disregard in order to kludge MMC6games into working. If WRAM is present and enabled, some pre-loaded values will cause BT&DD to crash at the end of stage 1 when Abobo makes his first appearance and LGM to crash when playing boss music. [2]Bee 52 This needs accurate DMC timing and relies on PPUSTATUSbit 5 (sprite overflow) as well. Bill & Ted's Excellent Adventure and some other MMC1games These depend on the mapper ignoring successive writes; see iNES Mapper 001(the talk page for that page might be informative too). Bill & Ted also turns off and re-enables rendering midframe to switch CHR banks (such as in the black border above dialog boxes). Burai Fighter (U) It accesses PPUDATAduring rendering to draw the scorebar. Incorrect emulation clips the scorebar to half size. See the notes on accessing PPUDATAduring rendering on the PPU scrollingpage. B-Wings , Fantasy Zone II , Demon Sword / Fudō Myōō Den , Fushigi no Umi no Nadia , Krusty's Fun House , Trolls in Crazyland , Over Horizon , Super Xevious: GAMP no Nazo , and Zippy Race They write to CHR ROM and expect the writes to have no effect. [3][4]Captain Planet , Dirty Harry , Infiltrator , Mad Max , Paperboy , The Last Starfighter Mindscape games which rely on the open busbehavior of controller reads and expects them to return exactly 0x40 or 0x41; see Standard controller. Cobra Triangle and Ironsword: Wizards and Warriors II They rely on the dummy read for the `sta $4000,X `instruction to acknowledge pending APU IRQs. Crystalis Uses MMC3 scanline for a moving vertical split to wrap the playfield while accommodating the status bar. Incorrect MMC3 timing will create a moving seam as you wander up and down the map. Crystalis , Fantastic Adventures of Dizzy , Fire Hawk , Indiana Jones and the Last Crusade , StarTropics , and Super Off Road These do mid-frame palette changes. Daydreamin' Davey Changes the background palette color mid-frame; also does an OAM DMA for its sprite-only status bar below the split. (See also: Stunt Kids.) Door Door Writes to the PRG-ROM area frequently through a pointer explicitly set to $8080. Harmless on NROM. Additionally, the game polls controller input multiple times per frame in some instances (such as the Title screen or when pausing) due to the code causing the CPU to spinwait on reading the controller input. Final Fantasy , River City Ransom , Apple Town Story [5], Impossible Mission II [6]amongst others Use the semi-random contents of RAM on powerup to seed their RNGs. Emulators often provide fully deterministic emulated powerup state, and these games will seem to be deterministic when they weren't intended to be. Fire Hawk , Mig 29 Soviet Fighter , and Time Lord These need accurate DMC timing because they abuse APU DMC IRQto split the screen. Galaxian Requires proper handling of bit 4 of the P registerfor /IRQ. G.I. Joe and Mickey in Letterland These turn sprite displayoff and leave the background on. Correct timing of MMC3 IRQs requires that the sprite fetches still clock the scanline counter when either is enabled. [1]Graphic Editor Hokusai , Jingorou , Kosodate Gokko , and Quick Hunter These are unlicensed FDSdisk utilities/copiers which operate on arbitrary disks. They also require correct parsing of non-standard disk imagesand accurate handling of low-level disk drive accesses to avoid triggering copy protection measures. [7]This is particularly problematic when using the popular FDS file format, which omits gaps and CRCs. Huge Insect Depends on obscure OAMADDR($2003) behavior in the OAM DRAM controller; see PPU registers. Ishin no Arashi Plays sound effects through MMC5 pulse channelsand times them using $5015 reads. Jurassic Park The wobbling OCEAN logo on the title screen is very sensitive to slight delay in the MMC3IRQ and could have incorrectly scrolled lines if mistimed. Kira Kira Star Night DX Entering the code to access the debug screen gives the CPU slightly less than a single frame to load the entire menu tilemap. If the timing is significantly off, the menu will appear glitched. Additionally, the main gameplay backgrounds rely on correct MMC3 timing, or else the parallax effects appear glitched. The Legend of Zelda Writes to PPUADDRmidframe to set the coarse Y scrollfor vertical scrolling between screens. See the Game bugspage for buggy behavior arising from its implementation. The Magic of Scheherazade It maps two non-contiguous PRG ROM pages next to each other, then executes code across the page boundary. Emulators which use pointers to fetch sequential instruction bytes from ROM will fail when taking damage in the RPG-style battles. (Use password `5W `to test this easily.) Marble Madness , Mother (J), and Pirates These switch CHR banks mid-scanline to draw text boxes (such as at the beginning of each MM level). Getting these to render correctly requires fairly precise timing. Micro Machines Requires correct values when reading OAMDATA($2004) during rendering, and also relies on proper background color selection when rendering is disabled and the VRAM address points to the palette (see the "background palette hack" on PPU palettes). Punch-Out!! MMC2 snoops PPU fetches. If the PPU does not fetch the 34th tile, the ring will be glitched. Puzznic and Reflect World (FDS) These use unofficialopcode $89, which is a two-byte NOP on 6502 and BIT #imm on 65C02. ( Puzznic tasvideos discussion) The instruction in Puzznic is $89 $00; emulating $89 as a single-byte NOP will trigger a BRK that causes the screen to shake. Rollerblade Racer Has an unusual status bar using only sprites with the background disabled. (See also: Daydreamin' Davey .) Shinsenden Depends on the MMC1 reset bit (bit 7) not being ignored on successive writes, unlike the data bit (bit 0). Selecting the 4th option of the command menu ("みる", "look") accidentally triggers illegal instruction $7F, an RMW instruction which in this case first writes with bit 7 clear and then bit 7 set. The second write triggers a mapper reset that prevents the game from crashing. Slalom Does a JSR while the stack pointer is 0, so that half of the return address ends up at $0100 and the other half at $01FF. Also executes code from RAM. Solar Jetman Enables the decimal bit through manipulation of a flag bytepushed to the stack and expects addition to continue to operate in binary. Spot and Quattro Sports These poll input multiple times per frame, and may not respond to emulated input that can only change at one specific time during the frame [8][9]. Emulators generally don't have the option to poll the controller many times per frame in real-time, so the solutions used may need to compromise (e.g. game-specific solution, user option to decide when during the frame input changes, non-deterministic input change time). Tepples created a test ROM to explore this behaviour: Telling LYs?Star Trek – 25th Anniversary Forces MMC3 to fire IRQ at scanline 0 which on some MMC3 versions or flashcarts causes glitching during split-screen scenes. StarTropics Disables rendering at the top of the status bar to change palettes, but also re-enables sprites when rendering comes back on. For hardware mapper emulation, the specific timing is critical. If the MMC3 IRQ timing is delayed by a cycle or two, this will begin to cause all sprites to flicker erratically. Even with a correctly timed hardware implementation, there are still some subtle corruption interactions to do with turning rendering off, then re-enabling sprites mid-framewhich might not be possible to emulate correctly with current knowledge [10]. Stunt Kids Mid-frame OAM DMA for split-screen gameplay. Sunsoft Tile Editor (Kakeru-kun) , Sunsoft Map Editor (Chizuko-san) Relies on graphics that are already loaded from the BIOS boot sequence (such as the menu font), and relies on loading and saving of arbitrary disk images, which may not be properly formatted, contain a "KYODAKU-" boot file, or are completely blank. Additionally, it assumes it can fully or partially wipe, format, and rewrite the entire disk contents, and not just single files. Super Mario Bros. This is probably the hardest game to emulateamong the most popular NROMgames, which are generally the first targets against which an emulator author tests their work. It relies on JMP indirect, correct palette mirroring (otherwise the sky will be black; see PPU palettes), sprite 0 detection (otherwise the game will freeze on the title screen), the 1-byte delay when reading from CHR ROM through PPUDATA(see The PPUDATA read buffer), proper behavior of the nametable selection bits of PPUSTATUSand PPUADDR, and correct handling of multiple controllers (otherwise the game will refuse to progress past the title screen [11]). In addition, there are several bad dumps floating around, some of which were ripped from pirate multicarts whose cheat menus leave several key parameters in RAM. Super Mario Bros. 3 , Mystery World Dizzy , Double Action 53 , and Haunted: Halloween '86: The Curse of Possum Hollow This relies on an interaction between the sprite prioritybit and the OAM index to put sprites behind the background. SMB3 uses it for powerups sprouting from blocks. Mystery World Dizzy puts Dizzy behind a blue pillar ( screenshot). RHDE: Furniture Fight in DA53 uses it for characters behind furniture. HH86 uses it when Donny or Tami passes behind a telephone pole or steps into polluted water. Teenage Mutant Ninja Turtles Uses Y scroll values greater than 239, causing the PPU to read the attribute table as nametable data before looping back to the same nametable instead of rolling to the next nametable down. Time Lord This is sensitive to the power-on state of the NES. The Vblank flag in PPUSTATUS must be set for the first time within 240 scanlines, otherwise there will be a frame IRQ which is never acknowledged, which will mess up the DMC IRQs used elsewhere and cause the game to crash. Tonkachi Editor This is an unlicensed hex editor which can view and edit files on arbitrary disks (known for bundling the earliest Super Mario Bros. hack commonly referred to as "Tonkachi Mario"). It manually polls the byte transfer flag from $4030.D7 for disk accesses instead of using BIOS routines or IRQs. Ultimate Stuntman , Skate or Die 2 Ultimate Stuntman plays PCM drum samples on the DMC channel during idle portions of the frame. Skate or Die 2 does it on the title screen. (See also: Battletoads introduction.) Wario's Woods Uses MMC3IRQ with unusual configuration of BG using CHR page $1000 and sprites using CHR page $0000. On some CPU-PPU alignments(assigned randomly at reset), the IRQ receives an extra clock on every second frame, causing the last 48 pixels of the green ground to flicker, but not on all resets [12]. Wizards and Warriors 3 It writes new tile graphics for the sprites at the screen split after the sprites have been drawn, but before the frame has ended. Emulators which draw the sprites all at once using graphics data from the end of the frame will have glitches in the main character's sprite. The Young Indiana Jones Chronicles and Zelda II: The Adventure of Link These access PPUDATAduring rendering to perform a glitchy y scroll. Young Indy uses it to make the screen shake when cannonballs hit the ground, and Zelda II uses it to skip scanlines on the title screen. See the notes on accessing PPUDATAduring rendering on PPU scrollingpage.

## Troubleshooting games

If a scroll split doesn't work, and a garbage sprite shows up around the intended split point, then the game is probably trying to use a sprite 0 hit, but either the wrong tile data is loaded or the background is scrolled to a position that doesn't overlap correctly. This could be a problem with nametable mirroring, with CHR bankswitching in mappersthat support it, or with the CPU and PPU timing of whatever happened above the split. Battletoads , for one, uses 1-screen mirroring and requires exact timing to get the background scroll position dead-on.

## See also
- Game bugs: These games have glitches on NES hardware, so don't go "fixing" them while breaking your emulator.
- Sprite overflow games
- Unofficial opcode games
- List of games that run code from outside of PRG-ROM

## References
- ↑thread: Battletoads Double Dragon Powerpak Freeze
- ↑thread: Battletoads Double Dragon Powerpak Freeze - pre-loading $FF reliably crashes BT&DD , $00 reliably does not.
- ↑thread: KrzysioCart - Home made cartridge that support>80% NES games
- ↑thread: Hong Kong 212 PCB,128+1024?
- ↑http://forums.nesdev.org/viewtopic.php?p=183064#p183064
- ↑http://forums.nesdev.org/viewtopic.php?f=3&t=18111
- ↑thread: Copy protection methods on FDS disks
- ↑forum thread: Spot bug in Mesen and Nintaco
- ↑forum thread: Quattro Sports BMX Simulator uses extra controller?
- ↑forum thread: OAM corruption in StarTropics
- ↑forum thread:Diagnosing controller signals with Super Mario Bros.
- ↑forum post:discussion of Wario's Woods behaviour on real hardware

## External links
- Software Indexon SMS Power
- Tricky-to-emulate gameson GbdevWiki
- ACCURACY.mdfrom NanoBoyAdvance docs

# Action 53

Source: https://www.nesdev.org/wiki/Action_53

Action 53 is a series of homebrew multicart releases, using a mapper designed by Damian Yerrick for this purpose.

For the multicart mapper, see: Action 53 mapper
- STREEMERZ: Action 53 Function 16 Volume One ( discussion| download)
- Double Action 53: Volume 2 ( discussion| download)
- Action 53 Vol. 3: Revenge of the Twins ( discussion| download)
- Action 53 Vol. 4: Actually 54 ( download)
- NESDev '19 Compo Cart ( download)

This multi-discrete mapper(iNES #28) can simulate the behavior of popular discrete boards. In the first volume, the menu and all games except STREEMERZ run in this mapper's BNROMcompatibility mode. The second and third volumes still use BNROM mode for the menu and most games but uses UNROMmode for several games and NROM-128 mode for 16K games so that both games in a bank can have their own NMI vectors. The third volume uses CNROMmode (which requires 32K RAM) for one game ( Sinking Feeling )

## Contents

### Action 53 Function 16 Volume ONE
- Streemerz
- Forehead Block Guy
- LAN Master
- Lawn Mower
- Slappin'
- Thwaite
- Concentration Room
- Driar
- I Wanna Flip the Sky
- MineShaft
- Munchie Attack
- NES15
- NES Virus Cleaner
- Pogo Cats
- ZapPing
- Zooming Secretary
- Music Toy: Axe
- Russian Roulette
- TapeDump
- Zapper Calibration

### Double Action 53 Volume 2
- Double Action Blaster Guys
- RHDE: Furniture Fight
- robotfindskitten
- Sliding Blaster
- Solar Wars
- Super PakPak
- 1007 Bolts
- 2048
- Auge
- Chase
- Function
- Love Story
- MilioNESy
- PCB Artist
- Sir Ababol
- Sgt. Helmet - Training Day
- Conway's Life
- Sound Effect Editor
- Theremin

### Action 53 Vol. 3: Revenge of the Twins
- Twin Dragons (Demo)
- Nebs 'n Debs
- Filthy Kitchen
- Lala the Magical
- Cheril the Goddess
- Wo xiang niào niào
- Sinking Feeling
- Brick Breaker
- Flappy Jack
- Jupiter Scope 2: Operation Europa
- Karate Kick
- The Paths of Bridewell
- Rock Paper Scissors +
- Spacey McRacey
- Super Tilt Bro.
- Waddles the Duck
- Haunted: Halloween '85(Demo)
- Lunar Limit
- Ralph 4
- Zombie Calavera (Prologue)
- 240p Test Suite
- Button Logger
- Musical Controller

## Contributors

In order of menu appearance, through volume 3:
- Mr Podunkian@SuperFunDungeonRun: design of STREEMERZ
- thefox@Faux Game Co.: port of STREEMERZ
- NovaSquirrel: FHBG, DABG, Sliding Blaster, some RHDE graphics, Conway's Life
- Shiru: LAN Master, Lawn Mower, program of Zooming Secretary, Chase
- PinWizz: graphics of Zooming Secretary
- Michael Swanson: Slappin'
- Damian Yerrick: menu, Thwaite, Concentration Room, Zap Ruder, Russian Roulette, RHDE, port of robotfindskitten, Sound Effect Editor, Haunted: Halloween '85 (Demo), 240p Test Suite
- David Eriksson: Driar
- Stefan Adolfsson: Driar
- Tom Livak: I Wanna Flip the Sky, Love Story, Threremin
- Nioreh: MineShaft
- Memblers (Joe Parsell): Munchie Attack
- Mathew Brenaman: NES15
- Roth@Sly Dog: NES Virus Cleaner
- Yggi: Pogo Cats
- Chris Covell: TapeDump, Solar Wars
- Leonard Richardson: design of robotfindskitten
- artoh: Super PakPak
- user: 1007 Bolts
- Gabriele Cirulli: design of 2048
- tsone: port of 2048
- Krill: Auge
- Denine: Function, MilioNESy
- Paul Molloy@Infinite NES Lives: PCB Artist, cart manufacturing
- Mojon Twins: Sir Ababol, Sgt. Helmet - Training Day, Lala the Magical, Cheril the Goddess, Wo xiang niào niào, Zombie Calavera (Prologue)
- Glutock: Twin Dragons
- Chris Cacciatore: Nebs 'n Debs
- Dustmop: Filthy Kitchen
- Calima: Sinking Feeling
- Punch: Brick Breaker
- Dougeff (Doug Fraker): Flappy Jack, Rock Paper Scissors +
- Nin-kuuku: Jupiter Scope 2
- Michael Moffitt: Karate Kick
- Zkip: The Paths of Bridewell
- Nathan Tolbert: Spacey McRacey
- Sylvain Gadrat: Super Tilt Bro.
- cppchriscpp: Waddles the Duck
- Retrotainment Games: Haunted: Halloween '85 (Demo)
- Pubby: Lunar Limit, Ralph 4
- Johnathan Roatch: Button Logger, Musical Controller

## See also
- Action 53 manual

## External links
- Action 53 on author's wiki
- Action 53 multicart engineon NESdev BBS
- Action 53 menu source codeon GitHub
