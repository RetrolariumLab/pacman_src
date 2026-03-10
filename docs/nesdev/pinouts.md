# pinouts

# ΜPD7755C/µPD7756C pinout

Source: https://www.nesdev.org/wiki/%CE%9CPD7755C/%C2%B5PD7756C_pinout

NEC µPD7755, µPD7756: 18-pin 0.3" DIP (used with mappers 18, 72, 86, and 92)

```text
         .--V--.
  I4  -> |01 18| <- I3
  I5  -> |02 17| <- I2
  I6  -> |03 16| <- I1
  I7  -> |04 15| <- I0
 Iref -> |05 14| <- /START
SOUND <- |06 13| <- /CS
/BUSY <- |07 12| <- X1
 /RST -> |08 11| -> X2
  Gnd -- |09 10| -- Vdd
         '-----'

```

The amount of current flowing into Iref specifies the amount of current flowing into the SOUND output when the DAC is set to 16 (1/32nd full scale). This is usually configured with an external resistor.

X1 and X2 should be hooked up to a 640kHz ceramic resonator.

# 6578 pinout

Source: https://www.nesdev.org/wiki/6578_pinout

```text
                                        _______
                               IRQ1 -> / 1 100 \ <- /IRQ4
                              IRQ2 -> / 2  _ 99 \ <- IRQ3
                               NC -- / 3  (_) 98 \ -> $4016.1
                         JOY1CLK <- / 4        97 \ -> $4016.0
                        KEY_CLK -> / 5          96 \ <- $4016.1
                       KEY_DAT -> / 6            95 \ -> JOY2CLK
                      PRG A20 <- / 7              94 \ <- $4017.0
                     PRG A19 <- / 8                93 \ <- $4016.0
                    PRG A18 <- / 9                  92 \ -> AEN
                   PRG A17 <- / 10                   91 \ <- /RST
                  PRG A16 <- / 11                     90 \ -- GND
                  /EXRAM <- / 12                       89 \ -> AUDIO
                  I/O 7 <> / 13                         88 \ -> VIDEO
                 I/O 6 <> / 14                           87 \ -- VCC
                  VCC -- / 15                             86 \ <> Crystal 2
             CPU A11 <- / 16                               85 \ <> Crystal 1
                 M2 <- / 17                                 84 \ <> I/O 0
           CPU A10 <- / 18                                   83 \ <> I/O 1
          CPU A12 <- / 19                                     82 \ <> I/O 2
          CPU A9 <- / 20                                       81 \ <> I/O 3
        CPU A13 <- / 21                                        80 / <> PPU D4
        CPU A8 <- / 22                                        79 / <> PPU D3
      CPU A14 <- / 23                                        78 / <> PPU D5
      CPU A7 <- / 24                                        77 / <> PPU D2
     CPU D7 <> / 25                                        76 / <> PPU D6
    CPU A6 <- / 26                                        75 / <> PPU D1
   CPU D6 <> / 27                                        74 / <> PPU D7
  CPU A5 <- / 28                                        73 / <> PPU D0
 CPU D5 <> / 29                                        72 / -> /PTR_ST
CPU A4 <- / 30                                        71 / <- REGION
CPU D4 <> \ 31                                       70 / <- TEST2
 CPU A3 <- \ 32                                     69 / <- TEST 1
  CPU D3 <> \ 33                                   68 / <> I/O 4
   CPU A2 <- \ 34                                 67 / <> I/O 5
    CPU D2 <> \ 35                               66 / -> PPU A14
     CPU A1 <- \ 36                             65 / -> PPU A13
      CPU D1 <> \ 37                           64 / -> PPU A0
       CPU A0 <- \ 38                         63 / -> PPU A12
        CPU D0 <> \ 39                       62 / -> PPU A1
        CPU R/W <- \ 40                     61 / -> PPU A11
         /ROMSEL <- \ 41                   60 / -> PPU A2
               NC -- \ 42                 59 / -> PPU A10
               GND -- \ 43               58 / -> PPU A3
                VCC -- \ 44             57 / -> PPU A9
              /RTCAS <- \ 45           56 / -> PPU A4
                  /PW <- \ 46         55 / -> PPU A8
                   /PR <- \ 47       54 / -> PPU A5
                    GND -- \ 48     53 / -> PPU A7
                 PPU /WR <- \ 49   52 / -> PPU A6
                  PPU /RD <- \ 50 51 / -> /XVRAM
                              -------

```

Legend: Input: -> [6578] <- Output: <- [6578] -> Multidirect: <> [6578] <> Power/Other: -- [6578] -- Unknown: ?? [6578] ??
- NC: No Connection; Leave Floating
- /EXRAM: CS for External RAM ($6000 - $7FFF); Active Low
- /RTCAS: Signal of Address Strobe for RTC
- /PW: Write Signal for peripheral at $4080 - $43xx
- /PR: Read Signal for $4080 - $43xx
- /XVRAM: /CS of External VRAM (PPU $8000 - $FFFF)
- TESTx: Test Pins, Leave Floating
- REGION: 0 = PAL; 1 = NTSC
- /PTR_ST: Signal for Printer to Strobe Data
- AEN: For extending peripheral; like "AEN" signal of ISA bus of PC ($41xx - $43xx)
- IRQx: IRQ Input. Active High, except for /IRQ4, which is active low

Source: http://playpower.pbworks.com/w/file/fetch/58323638/SH6578%208-bit%20Educational%20Computer%20Chipset.pdf

# 8000M pinout

Source: https://www.nesdev.org/wiki/8000M_pinout

8000M or 8000M-1: 28-pin 0.6" PDIP. (Canonically iNES Mapper 227)

```text
                .---\/---.
     PPU /WE -> |1     28| -- VCC
    CPU M2(*)-> |2     27| <- CPU A14
      CPU A7 -> |3     26| <- CPU R/W
      CPU A6 -> |4     25| <- CPU A8
      CPU A5 -> |5     24| <- CPU A9
      CPU A4 -> |6     23| <- PPU A11
      CPU A3 -> |7     22| -> (**)
      CPU A2 -> |8     21| <- PPU A10
      CPU A1 -> |9     20| <- CPU /ROMSEL
      CPU A0 -> |10    19| -> CHR /WE
     PRG A14 <- |11    18| -> CIRAM A10
     PRG A15 <- |12    17| -> PRG A19 (***)
     PRG A16 <- |13    16| -> PRG A18
         GND -- |14    15| -> PRG A17
                `--------'

```

This chip appears either in PDIP or epoxy blob package. Cartridges with blob package have often GG1 markings near the mapper blob.

Notes:
- Pin 2 is in fact positive reset. Cartridges connect CPU M2 signal here via 2.2k resistor. There must be large capacitance inside as probing this pin during cartidge operation shows triangle wave instead of square.
- Pin 17 for cartridges with < 1MB drives 74157 which switches what connects A3..A0 to PRG ROM (CPU A via some fixed solder pad)
- Pin 22 is output that changes its value after some M2 cycles (probably output of restored reset signal, not used in any of analyzed cartridges)

Sources:
- BBS: https://forums.nesdev.org/viewtopic.php?t=24115

# MMC3 pinout

Source: https://www.nesdev.org/wiki/AX5202P_pinout

Nintendo MMC3: 44-pin 0.8mm pitch QFP (Canonically mapper 4)

```text
                              ___
                             /   \
                            /     \
                    n/c -- / 1  44 \ -> CHR A16 (r)
           (r) CHR A10 <- / 2    43 \ -> CHR A11 (r)
          (n) PPU A12 -> / 3   O  42 \ -> PRG RAM /WE (w)
         (n) PPU A11 -> / 4        41 \ -> PRG RAM +CE (w)
        (n) PPU A10 -> / 5          40 \ -- GND
               GND -- / 6            39 \ <- CPU D3 (nrw)         Orientation:
      (r) CHR A13 <- / 7              38 \ <- CPU D2 (nrw)        ------------------
     (r) CHR A14 <- / 8                37 \ <- CPU D4 (nrw)          33        23
    (r) CHR A12 <- / 9                  36 \ <- CPU D1 (nrw)          |        |
 (n) CIRAM A10 <- / 10                   35 \ <- CPU D5 (nrw)        .----------.
  (r) CHR A15 <- / 11                     34 \ <- CPU D0 (nrw)    34-|          |-22
                /        Nintendo MMC3        \                      | Nintendo |
                \        Package QFP-44       /                      | MMC3B    |
  (r) CHR A17 <- \ 12     0.8mm pitch     33 / <- CPU D6 (nrw)    44-|o         |-12
      (n) /IRQ <- \ 13                   32 / <- CPU A0 (nrw)        \----------'
    (n) /ROMSEL -> \ 14                 31 / <- CPU D7 (nrw)          |        |
             GND -- \ 15               30 / -> PRG RAM /CE (w)        1        11
              n/c -- \ 16             29 / <- M2 (n)
           (n) R/W -> \ 17           28 / -- GND          Legend:
        (r) PRG A15 <- \ 18         27 / -- VCC           ------------------------------
         (r) PRG A13 <- \ 19       26 / -> PRG /CE (r)    --[MMC3]-- Power
          (n) CPU A14 -> \ 20     25 / -> PRG A17 (r)     ->[MMC3]<- MMC3 input
           (r) PRG A16 <- \ 21   24 / <- CPU A13 (n)      <-[MMC3]-> MMC3 output
            (r) PRG A14 <- \ 22 23 / -> PRG A18 (r)           n      NES connection
                            \     /                           r      ROM chip connection
                             \   /                            w      RAM chip connection
                              \ /
                               V
01, 16: both officially no connection. sometimes shorted to pin 02, 15 respectively

```
Functional variations

As with several other ASIC mappers, parts of the pinout are often repurposed:

## iNES Mapper 037 and iNES Mapper 047

Mappers 37and 47connect pins 42 and 30 to a 74161
- Pin 30 (was PRG RAM /CE) is now 74'161 CLOCK
- Pin 34 (CPU D0) is additionally 74'161 D0
- In mapper 37, Pins 36, 38 (CPU D1, CPU D2) are additionally 74'161 D1, D2.
- Pin 42 (was PRG RAM /WE) is now 74'161 /LOAD

## TKSROM and TLSROM

iNES Mapper 118connects pin 12 to CIRAM A10, and pin 10 is n/c.
- Pin 10 (was CIRAM A10) is now no-connect
- Pin 12 (was CHR A17) is now CIRAM A10.

## TQROM

iNES Mapper 119connects pin 44 to a 7432and to the CHR RAM's +CE pin.
- Pin 44 (was CHR A16) is now CHR RAM +CE.
- Pin 44 is also ORed with PPU A13 and that goes to CHR ROM -CE

## Acclaim MC-ACC pinout

MC-ACCchip: (40-pin 0.6" DIP)

```text
               .--\/--.
        GND ?? |01  40| -- 5V
(r) PRG A16 <- |02  39| -> PRG A18 (r)
(r) PRG A15 <- |03  38| -> PRG A17 (r)
(n) CPU A14 -> |04  37| -> PRG A14 (r)
(n) CPU A13 -> |05  36| -> PRG A13 (r)
        n/c ?? |06  35| <- CPU R/W (n)
        n/c ?? |07  34| <- /ROMSEL (n)
        n/c ?? |08  33| -> PRG /OE (r)
(nr) CPU A0 -> |09  32| <- CPU D7 (nr)
(nr) CPU D0 -> |10  31| <- CPU D6 (nr)
(nr) CPU D1 -> |11  30| <- CPU D5 (nr)
(nr) CPU D2 -> |12  29| <- CPU D4 (nr)
(r) CHR A16 <- |13  28| <- CPU D3 (nr)
(r) CHR A15 <- |14  27| -> CIRAM A10 (n)
(r) CHR A14 <- |15  26| -> CHR A17 (r)
(r) CHR A13 <- |16  25| -> /IRQ (n)
(r) CHR A12 <- |17  24| <- PPU A12 (n)
(r) CHR A11 <- |18  23| <- PPU A11 (n)
(r) CHR A10 <- |19  22| <- PPU A10 (n)
        GND -- |20  21| <- M2 (n)
               '------'

39: confirmed in [1]
24: on the 55741 PCB, deglitched and shaped as MCACCA12IN = AND(PPUA12,AND(AND(AND(PPUA12)))). Kevtris's notes

```

Source: https://forums.nesdev.org/viewtopic.php?p=16795#p16795Pirate versions (600 mil 40-pin DIP package)

```text
             .--\/--.                              .--\/--.                           .--\/--.
       M2 -> |01  40| -- VCC            /ROMSEL -> |01  40| -> WRAM /CE    CHR A13 <- |01  40| <- PPU A10
 WRAM /CE <- |02  39| -- NC             PRG /CE <- |02  39| -- VCC         CHR A14 <- |02  39| <- PPU A11
   CPU D7 -> |03  38| -> PRG /CE       WRAM /WE <- |03  38| -> WRAM +CE    CHR A12 <- |03  38| <- PPU A12
   CPU A0 -> |04  37| -> PRG A17        CPU A14 -> |04  37| <- CPU R/W   CIRAM A10 <- |04  37| -> CHR A10
   CPU D6 -> |05  36| <- CPU A13        CPU A13 -> |05  36| -> PRG A13     CHR A15 <- |05  36| -> CHR A16
   CPU D0 -> |06  35| -> PRG A18         CPU A0 -> |06  35| -> PRG A14     CHR A17 <- |06  35| -> CHR A11
   CPU D5 -> |07  34| -> PRG A14             M2 -> |07  34| -> PRG A15        /IRQ <- |07  34| -> WRAM /WE
   CPU D1 -> |08  33| -> PRG A16        PPU A12 -> |08  33| -> PRG A16     /ROMSEL -> |08  33| -> WRAM +CE
   CPU D4 -> |09  32| <- CPU A14           /IRQ <- |09  32| -> PRG A17         GND -- |09  32| -- GND
   CPU D2 -> |10  31| -> PRG A13      CIRAM A10 <- |10  31| -> PRG A18     CPU R/W -> |10  31| <- CPU D3
   CPU D3 -> |11  30| -> PRG A15        PPU A10 -> |11  30| -- NC          PRG A15 <- |11  30| <- CPU D2
 WRAM +CE <- |12  29| <- CPU R/W        PPU A11 -> |12  29| -> CHR A17     PRG A13 <- |12  29| <- CPU D4
 WRAM /WE <- |13  28| <- /ROMSEL         CPU D0 -> |13  28| -> CHR A16     CPU A14 -> |13  28| <- CPU D1
  CHR A11 <- |14  27| -> /IRQ            CPU D1 -> |14  27| -> CHR A15     PRG A16 <- |14  27| <- CPU D5
  CHR A16 <- |15  26| -> CHR A17         CPU D2 -> |15  26| -> CHR A14     PRG A14 <- |15  26| <- CPU D0
  CHR A10 <- |16  25| -> CHR A15         CPU D3 -> |16  25| -> CHR A13     PRG A18 <- |16  25| <- CPU D6
  PPU A12 -> |17  24| -> CIRAM A10       CPU D4 -> |17  24| -> CHR A12     CPU A13 -> |17  24| <- CPU A0
  PPU A11 -> |18  23| -> CHR A12         CPU D5 -> |18  23| -> CHR A11     PRG A17 <- |18  23| <- CPU D7
  PPU A10 -> |19  22| -> CHR A14         CPU D6 -> |19  22| -> CHR A10     PRG /CE <- |19  22| -> WRAM /CE
      GND -- |20  21| -> CHR A13            GND -- |20  21| <- CPU D7          VCC -- |20  21| <- M2
             `------'                              `------'                           '------'
            AX5202P #1                      AX5202P #2 / MC-3 (NTDEC's?)                 88

```

```text
             .--\/--.                              .--\/--.                           .--\/--.
  CHR A10 <- |01  40| -- VCC            PPU A10 -> |01  40| -- VCC              M2 -> |01  40| -- VCC
  PPU A12 -> |02  39| -> CHR A16        PPU A11 -> |02  39| -> PRG A18?    CPU R/W -> |02  39| <- PPU A10
  PPU A11 -> |03  38| -> CHR A11        PPU A12 -> |03  38| -> PRG A17?    /ROMSEL -> |03  38| <- PPU A11
  PPU A10 -> |04  37| -> WRAM /WE       CHR A10 <- |04  37| -> PRG A16    WRAM +CE <- |04  37| <- PPU A12
  CHR A13 <- |05  36| -> WRAM +CE       CHR A11 <- |05  36| -> PRG A15    WRAM /CE <- |05  36| <- CPU A0
  CHR A14 <- |06  35| <- CPU D3         CHR A12 <- |06  35| -> PRG A14    WRAM /WE <- |06  35| <- CPU A13
  CHR A12 <- |07  34| <- CPU D2         CHR A13 <- |07  34| -> PRG A13     PRG /CE <- |07  34| <- CPU A14
CIRAM A10 <- |08  33| <- CPU D4         CHR A14 <- |08  33| <- CPU D7       CPU D0 -> |08  33| -> /IRQ
  CHR A15 <- |09  32| <- CPU D1         CHR A15 <- |09  32| <- CPU D6       CPU D1 -> |09  32| -> DELAYED M2
  CHR A17 <- |10  31| <- CPU D5         CHR A16 <- |10  31| <- CPU D5       CPU D2 -> |10  31| -> CIR A10
     /IRQ -> |11  30| <- CPU D0        ?CHR A17 <- |11  30| <- CPU D4       CPU D3 -> |11  30| -> CHR A17
  /ROMSEL -> |12  29| <- CPU D6         /ROMSEL -> |12  29| <- CPU D3       CPU D4 -> |12  29| -> CHR A15
  CPU R/W -> |13  28| <- CPU A0         CPU R/W -> |13  28| <- CPU D2       CPU D5 -> |13  28| -> CHR A14
  PRG A15 <- |14  27| <- CPU D7            /IRQ <- |14  27| <- CPU D1       CPU D6 -> |14  27| -> CHR A13
  PRG A13 <- |15  26| -> WRAM /CE       CIR A10 <- |15  26| <- CPU D0       CPU D7 -> |15  26| -> CHR A12
  CPU A14 -> |16  25| <- M2             CPU A0  -> |16  25| ?? ?           PRG A13 <- |16  25| -> CHR A11
  PRG A16 <- |17  24| -> PRG /CE        CPU A13 -> |17  24| -> PRG /CE     PRG A14 <- |17  24| -> CHR A10
  PRG A14 <- |18  23| ??                CPU A14 -> |18  23| ?? ?           PRG A15 <- |18  23| -> CHR A16
  PRG A18 <- |19  22| -> PRG A17             M2 -> |19  22| ?? ?           PRG A16 <- |19  22| -> PRG A18
      GND -- |20  21| <- CPU A13            GND -- |20  21| ?? ?               GND -- |20  21| -> PRG A17
             '------'                              '------'                           '------'
               9112                                7903 9102                             T1

```

Notes:
- Those chips are fully compatible MMC3 clones that can be found in bootleg games (there might be minor differences like the PPU A12 edge on which the scanline counter is clocked).
- The connections to edge connector for single games are the same in both pirate and original version, although some pirate multicarts use those chips in non-standard way with different connections.
- There are reports that some lots of AX5202P contain a large number of factory seconds with the IRQ not working.
- AX5202P #1 and AX5202P #2 are confirmed to enable WRAM at $6000-$7fff at power up but protect them from writes (during CPU write cycle to $6000-$7fff when WRAM is protected, WRAM !CE and WRAM CE are not asserted). When RAM is disabled, open bus behavior is observed.
- NC seems to be not connected internally in both versions (multimeter diode test does not show any conducting voltage between NC and any other pins)
- AX5202P #1 is the one you can still buy nowadays (it has AX5202P marking).
- AX5202P #2 was found in at least one game - Doki Doki Yuuenchi bootleg (the chip does not have any markings)

## References
- AX5202P #1: BBS
- AX5202P #2: BBS
- 88 BBS
- 9112 BBS
- 7903 9102 BBS
- T1 [2]

# Aladdin deck enhancer pinout

Source: https://www.nesdev.org/wiki/Aladdin_deck_enhancer_pinout

```text
                 Deck | CART | Deck
                       ------
                NC    |01  36| -- +5V
                NC    |02  35| <- $C000.2 OR CPU A14
$C000.3 OR CPU A14 -> |03  34| <- $C000.1 OR CPU A14
                NC    |04  33| <- ROM /OE
                NC    |05  32| <- ROM /CE
            CPU A0 -> |06  31| -> CPU D0
            CPU A1 -> |07  30| -> CPU D1
            CPU A2 -> |08  29| -> CPU D2
            CPU A3 -> |09  28| -> CPU D3
            CPU A4 -> |10  27| -> CPU D4
            CPU A5 -> |11  26| -> CPU D5
            CPU A6 -> |12  25| -> CPU D6
            CPU A7 -> |13  24| -> CPU D7
            CPU A8 -> |14  23| <- $C000.0 OR CPU A14
            CPU A9 -> |15  22| <- CPU A13
           CPU A10 -> |16  21| <- CPU A12
           CPU A11 -> |17  20| <- $8000.4
               GND -- |18  19| <- $8000.3
                       ------
               2x18 pin 0.1" edge connector

```

Notes:
- Pins 01-18 are on the label side (01 = leftmost)
- ROM /OE is logically (not CPU R/W) or CPU /ROMSEL
- ROM /CE is grounded in Aladdin Deck Enhancer 1.1 and driven by PIC16C54 in 2.0
- Single game cartridges wire ROM as: PRG A17 = $C000.3, PRG A16 = $C000.2, PRG A15 = $C000.1, PRG A14 = $C000.0
- Quattro cartridges wire ROM as: PRG A17 = $8000.3, PRG A16 = $8000.4, PRG A15 = $C000.1, PRG A14 = $C000.0
- All Aladdin Deck Enhancer games use vertical mirroring, as there is no mirroring control on this port

Source:
- BBS - Aladdin Deck Enhancer / CCU_v2.00 CF30288 pinouts

# BU3266 / BU3270 pinout

Source: https://www.nesdev.org/wiki/BU3266_/_BU3270_pinout

Custom Nintendo PIO chip found in the New Famicom (HVC-101). This replaces the U3 (139) and the U7/U8 (368).

```text
          .---v---.
INV 3I -> |01   32| -- +5V
INV 3O <- |02   31| -> INV 3B1
    M2 -> |03   30| -> INV 3B2
   A15 -> |04   29| -> /ROMSEL
   A14 -> |05   28| -> PPU /CE
   A13 -> |06   27| -> CPU RAM /CE
 P1 D0 -> |07   26| <- INV 2I
 P0 D0 -> |08   25| -> INV 2O
 P1 D1 -> |09   24| -> CPU D0
 P0 D1 -> |10   23| -> CPU D1
 P1 D2 -> |11   22| <- /INP0 ($4016 /RD)
 P0 D2 -> |12   21| <- /INP1 ($4017 /RD)
 P1 D3 -> |13   20| -> CPU D2
 P1 D4 -> |14   19| -> CPU D3
   GND -- |15   18| -> CPU D4
INV 1I -> |16   17| -> INV 1O
          '-------'

```

Notes:
- INV 1I/O (16-17) = Audio Inverter
- INV 2I/O (25-26) = PA13 Inverter
- INV 3I/O/B1/B1 (01,02,30,31) = unused (intended for CIC clock based on topology) [1]

Sources:
- nes_pio_pinout.txt
- BBS - AV Famicom JIO Chip Replacement Idea

# Bandai Datach pinout

Source: https://www.nesdev.org/wiki/Bandai_Datach_pinout

Bandai Datach: 32-pin 0.1" card edge ( iNES Mapper 157)

```text
  **CHR A13 <- |  1 32 | -- +5V
    PRG A16 <- |  2 31 | -> ??CHR A12??
    PRG A15 <- |  3 30 | -> PRG A17
    CPU A12 <- |  4 29 | -> PRG A14
     CPU A7 <- |  5 28 | -> CPU A13
     CPU A6 <- |  6 27 | -> CPU A8
     CPU A5 <- |  7 26 | -> CPU A9
     CPU A4 <- |  8 25 | -> CPU A11
     CPU A3 <- |  9 24 | -> /ExternalROMRead
     CPU A2 <- | 10 23 | -> CPU A10
     CPU A1 <- | 11 22 | <> I2C SDA
     CPU A0 <- | 12 21 | <> CPU D7
     CPU D0 <> | 13 20 | <> CPU D6
     CPU D1 <> | 14 19 | <> CPU D5
     CPU D2 <> | 15 18 | <> CPU D4
     GND    -- | 16 17 | <> CPU D3

```

Notes:
- Pin 1 is used for the external I²C EEPROM clock.
- Pin 31 is Naruko's educated guess

This is almost the standard JEDEC ROM pin order.

Source: Naruko

# Bandai FCG pinout

Source: https://www.nesdev.org/wiki/Bandai_FCG_pinout

Bandai FCG-1/LZ93D36 and FCG-2: 42-pin shrink PDIP ( iNES Mapper 016)

```text
            .---\/---.
       ? ?? |  1  42 | -- +5V
      M2 -> |  2  41 | ?? ?
 CPU A13 -> |  3  40 | -> PRG A17
 CPU A14 -> |  4  39 | -> PRG A15
  CPU A3 -> |  5  38 | -> PRG A14
  CPU A2 -> |  6  37 | -> PRG A16
  CPU A1 -> |  7  36 | <- CPU D7
  CPU A0 -> |  8  35 | <- CPU D6
 /ROMSEL -> |  9  34 | <- CPU D5
  CPU D0 -> | 10  33 | <- CPU D4
  CPU D1 -> | 11  32 | <- CPU D3
  CPU D2 -> | 12  31 | -> /IRQ
     R/W -> | 13  30 | -> CIRAM A10
 PPU /RD -> | 14  29 | -> CHR A17
 CHR A15 <- | 15  28 | -> CHR A14
 CHR A12 <- | 16  27 | -> CHR A13
 PPU A10 -> | 17  26 | -> CHR A11
 PPU A11 -> | 18  25 | -> CHR A16
 PPU A12 -> | 19  24 | -> CHR A10
 PPU A13 -> | 20  23 | -> CHR /CE
     GND -- | 21  22 | <- ?
            '--------'

```

Pin 22 is grounded on at least one FCG-1 board and floating on at least one FCG-2.

# Bandai Karaoke Studio pinout

Source: https://www.nesdev.org/wiki/Bandai_Karaoke_Studio_pinout

Bandai Karaoke Studio: 30-pin card edge ( iNES Mapper 188)

```text
    Gnd -- | 01  30 | -> CPU A13
CPU A12 <- | 02  29 | -> PRG A14
CPU A11 <- | 03  28 | -> PRG A15
CPU A10 <- | 04  27 | -> PRG A16
 CPU A9 <- | 05  26 | -> PRG A17
 CPU A8 <- | 06  25 | -> /ExternalROMRead
 CPU A7 <- | 07  24 | <> D7
 CPU A6 <- | 08  23 | <> D6
 CPU A5 <- | 09  22 | <> D5
 CPU A4 <- | 10  21 | <> D4
 CPU A3 <- | 11  20 | <> D3
 CPU A2 <- | 12  19 | <> D2
 CPU A1 <- | 13  18 | <> D1
 CPU A0 <- | 14  17 | <> D0
    Vcc -- | 15  16 | -- Gnd

```

Source: Enri(scroll down to "カラオケスタジオの回路図")

# Bandai LZ93D50 pinout

Source: https://www.nesdev.org/wiki/Bandai_LZ93D50_pinout

```text
           .---\/---.
        ?? |  1  52 | -- +5V                                       PPU A10 -> /  1  52 \ -> CHR A12? (=EXT PRG P31)
        ?? |  2  51 | -> PRG RAM /CS                              PPU A11 -> /  2    51 \ -> CHR A15?
PRG /CE <- |  3  50 | ?? ?                               PPU A12? (=GND) -> /  3      50 \ <- PPU /RD? (=GND)
    +5V ?? |  4  49 | ?? +5V                            PPU A13? (=GND) -> /  4        49 \ <- CPU R/W
     M2 -> |  5  48 | ?? ?                                           ? ?? /  5          48 \ <- CPU D2
CPU A13 -> |  6  47 | -> PRG A17                                  GND -- /  6            47 \ <- CPU D1
CPU A14 -> |  7  46 | -> PRG A15                                 SDA ?? /  7              46 \ <- CPU D0
 CPU A3 -> |  8  45 | -> PRG A14                            SCL INT <- /  8                45 \ <- CPU /ROMSEL
 CPU A2 -> |  9  44 | -> PRG A16                          ? (=GND) -> /  9                  44 \ <- CPU A0
 CPU A1 -> | 10  43 | <- CPU D7                          CHR /CE? <- / 10                    43 \ <- CPU A1
 CPU A0 -> | 11  42 | <- CPU D6                         CHR A10? <- / 11                      42 \ <- CPU A2
/ROMSEL -> | 12  41 | <- CPU D5                        CHR A16? <- / 12                        41 \ <- CPU A3
 CPU D0 -> | 13  40 | <> CPU D4            CHR A11? (=6264 P1) <- / 13                          40 \ ?? ?
 CPU D1 -> | 14  39 | <- CPU D3            CHR_A13? (=SCL_EXT) <- \ 14                          39 / <- CPU A14
 CPU D2 -> | 15  38 | -> /IRQ                          CHR A14? <- \ 15                        38 / <- CPU A13
    R/W -> | 16  37 | -> CIRAM A10                      CHR A17? <- \ 16                      37 / <- M2
PPU /RD -> | 17  36 | -> CHR A17                        CIRAM A10 <- \ 17                    36 / ?? ?
CHR A15 <- | 18  35 | -> CHR A14                                 ? ?? \ 18                  35 / -> PRG /CE (=EXT ROM /RD)
CHR A12 <- | 19  34 | -> CHR A13                               /IRQ <- \ 19                34 / ?? ?
PPU A10 -> | 20  33 | -> CHR A11                              CPU D3 -> \ 20              33 / -- GND
PPU A11 -> | 21  32 | -> CHR A16                               CPU D4 -> \ 21            32 / -- VCC
PPU A12 -> | 22  31 | -> CHR A10                                CPU D5 -> \ 22          31 / -> /$6000-$7FFF (=74368's/OE)
PPU A13 -> | 23  30 | -> CHR /CE                                 CPU D6 -> \ 23        30 / ?? ?
    GND -- | 24  29 | <- **                                       CPU D7 -> \ 24      29 / ?? ?
      ? ?? | 25  28 | -> I²C SCL                                  PRG A16 <- \ 25    28 / -> PRG A17
    GND -- | 26  27 | <> I²C SDA                                   PRG A14 <- \ 26  27 / -> PRG A15
           '--------'
Bandai LZ93D50: 52-pin shrink PDIP                                 Bandai LZ93D50P: QFP52 0.65mm pitch
(Canonically iNES Mapper 159)                                   (Canonically iNES Mapper 157)

** Grounded on BA-JUMP2. Floating on other games.         * This chip is used only in Datach Joint System Adapter with
   Seems likely to be an enable for reading I²C from        non-canonical connections (marked as =...)
   $6000-$7fff (internal pullup, normally floating)       * Behaviour of pins ending with "?" is not confirmed, but it
                                                            is suggested by their location identical to PDIP version

```

Bandai's variants of the LZ93D50 are almost as bad as MMC1.

BA-JUMP2: supports PRG RAM instead of I²C, replaces banked CHR-ROM with unbanked CHR-RAM, and increases PRG max to 512KiB:

```text
PPU /RD -> | 17  36 | -> n/c
    n/c <- | 18  35 | -> n/c
    n/c <- | 19  34 | -> n/c
PPU A10 -> | 20  33 | -> n/c
PPU A11 -> | 21  32 | -> n/c
    GND -> | 22  31 | -> PRG A18
    GND -> | 23  30 | -> n/c
    GND -- | 24  29 | <- GND
      ? ?? | 25  28 | -> PRG RAM +CS
    GND -- | 26  27 | <> n/c
           '--------'

```

Datach Joint ROM System: Two separate I²C clocks, replaces banked CHR-ROM with unbanked CHR-RAM, and external barcode reader.

This IC is actually a 52-pin QFP, with a slightly different pin order from the PDIP instantiation. The pertinent changes:
- I²C SCL is only for the internal EEPROM
- CHR A13 is External I²C SCL
- WRAM /CS drives a tristateable buffer that connects barcode data to CPU D3.

See also:
- http://seesaawiki.jp/famicomcartridge/d/Bandai%20Datach
- http://seesaawiki.jp/famicomcartridge/d/Bandai%20LZ93D50%20standard

# Bandai M60001-0115P pinout

Source: https://www.nesdev.org/wiki/Bandai_M60001-0115P_pinout

(Bandai) Mitsubishi M60001-0115P: 28-pin 0.6" PDIP ( iNES Mapper 188)

```text
            .--\/--.
    blue -> |01  28| -- +5V
  yellow -> |02  27| -> internal PRG /CE
  orange -> |03  26| -> external PRG /CE
 PPU A11 -> |04  25| -> VRAM A10
 PPU A10 -> |05  24| -> LatchedD6
 ROM R/W -> |06  23| -> PRG A14
 /ROMSEL -> |07  22| -> PRG A15
 CPU A14 -> |08  21| -> PRG A16
 CPU A13 -> |09  20| -> PRG A17
 CPU A12 -> |10  19| ??
 CPU D0  <> |11  18| <- CPU D6
 CPU D1  <> |12  17| <- CPU D5
 CPU D2  <> |13  16| <- CPU D4
     GND -- |14  15| <- CPU D3
            '------'

```

The color names were silkscreened on the PCB. They are the wires from the microphone.

This mapper has the dubious distinction of failing to prevent bus conflicts but also being too complex to comfortably say "it's just a couple silicon dice in a single package", unlike the Sunsoft-1and -2. The described functionality is equivalent to five 74xx ICs. (74377, ½ 74139, ½ 7420, ½ 74244, 7432)

The M60001 prefix was used by Mitsubishi for custom orders: the M60001-0103P was used in the Joyball for the Famicom: [1]

See also: naruko's writeup

# C5052-13 pinout

Source: https://www.nesdev.org/wiki/C5052-13_pinout

The C5052-13 is a mapper chip with MMC1and MMC3functionality.

```text
            .--\/--.
     +5V -- |01  40| <- CPU A0
    mode -> |02  39| <- CPU A1
 PRG A13 <- |03  38| <- M2
 PRG A14 <- |04  37| <- CPU A12
 PRG A15 <- |05  36| <- CPU A13
 PRG A16 <- |06  35| <- CPU A14
 PRG A17 <- |07  34| <- CPU D4
 PRG A18 <- |08  33| <- CPU D5
 PRG /CE <- |09  32| <- CPU /ROMSEL
WRAM +CE <- |10  31| <- CPU D6
 CHR A10 <- |11  30| <- CPU D7
 CHR A11 <- |12  29| <- CPU D0
 CHR A12 <- |13  28| <- CPU R/!W
 CHR A13 <- |14  27| -> CIRAM A10
 CHR A14 <- |15  26| <- CPU D1
 CHR A15 <- |16  25| <- CPU D2
 CHR A16 <- |17  24| <- CPU D3
 CHR A17 <- |18  23| -> PPU A12
    /IRQ <- |19  22| -> PPU A11
     GND -- |20  21| -> PPU A10
            `------'
            C5052-13

```

## References
- BBS - Interesting mapper: C5052-13 (DIP40)

# CCU v2.00 CF30288 pinout

Source: https://www.nesdev.org/wiki/CCU_v2.00_CF30288_pinout

Camerica CCU: 28-pin 0.4" shrink PDIP marked "CCU_V2.00 CF30288 N X 9240 PHILLIPINES" (Mappers 71and 232)

```text
           .---v---.
 CPU M2 -> |01   28| ??
 CPU D4 -> |02   27| ??
 CPU D3 -> |03   26| ??
 CPU D2 -> |04   25| ??
 CPU D1 -> |05   24| -> ROM /OE
 CPU D0 -> |06   23| ??
    VCC -- |07   22| -- GND
 CPU A0 -> |08   21| -> CIC STUN
CPU A13 -> |09   20| -> $C000.3 OR CPU A14
CPU A14 -> |10   19| -> $8000.3
/ROMSEL -> |11   18| -> $C000.2 OR CPU A14
CPU R/W -> |12   17| -> $8000.4
        ?? |13   16| -> $C000.1 OR CPU A14
        ?? |14   15| -> $C000.0 OR CPU A14
           '-------'
        28-pin 0.4" shrink DIP

```

Notes:
- This chip is used in Aladdin Deck Enhancer 1.1/2.0 and Super Sports Challenge
- CIC STUN pin is used only in Aladdin Deck Enhancer 1.1
- Source: [1]

# CIC lockout chip pinout

Source: https://www.nesdev.org/wiki/CIC_lockout_chip_pinout

## NES CIC lockout chip

```text
                 ----_----
 Data Out 01 <-x|P0.0  Vcc|--- 16 +5V
 Data In  02 x->|P0.1 P2.2|x-x 15 Gnd
 Seed     03 x->|P0.2 P2.1|x-x 14 Gnd
 Lock/Key 04 x->|P0.3 P2.0|x-x 13 Gnd
 N/C      05 x- |Xout P1.3|<-x 12 Gnd/Reset speed B
 Clk in   06  ->|Xin  P1.2|<-x 11 Gnd/Reset speed A
 Reset    07  ->|Rset P1.1|x-> 10 Slave CIC reset
 Gnd      08 ---|Gnd  P1.0|x-> 09 /Host reset
                 ---------

P0.x = I/O port 0
P1.x = I/O port 1
P2.x = I/O port 2
Xin  = Clock Input
Xout = Clock Output
Rset = Reset
Vcc  = Input voltage
Gnd  = Ground
->|  = input
<-|  = output
-x|  = unused as input
x-|  = unused as output
---  = Neither input or output

The CIC is a primitive 4-bit microcontroller. It contains the following registers:

+-+         +-------+  +-------+-------+-------+-------+
|C|         |   A   |  |       |       |       |       |
+-+         +-+-+-+-+  +- - - - - - - - - - - - - - - -+
            |   X   |  |       |       |       |       |
        +---+-+-+-+-+  +- - - - - - - - - - - - - - - -+
        |     P     |  |       |       |       |       |
        | PH|   PL  |  +- - - - - - - - - - - - - - - -+
+-------+-+-+-+-+-+-+  |       |       |       |       |
|         IC        |  +- - - - - - - -R- - - - - - - -+
+-+-+-+-+-+-+-+-+-+-+  |       |       |       |       |
|                   |  +- - - - - - - - - - - - - - - -+
+- - - - - - - - - -+  |       |       |       |       |
|                   |  +- - - - - - - - - - - - - - - -+
+- - - - -S- - - - -+  |       |       |       |       |
|                   |  +- - - - - - - - - - - - - - - -+
+- - - - - - - - - -+  |       |       |       |       |
|                   |  +- - - - - - - - - - - - - - - -+
+-+-+-+-+-+-+-+-+-+-+

A  = 4-bit Accumulator
C  = Carry flag
X  = 4-bit General register
P  = Pointer, used for memory access
PH = Upper 2-bits of P
PL = Lower 4-bits of P, used for I/O
IC = Instruction counter, to save some space; it counts in a polynominal manner instead of linear manner
S  = Stack for the IC register
R  = 32 nibbles of RAM
There are also 512 (768 for the 3195A) bytes of ROM, where the executable code is stored.

```

## Kevtris' CIClone Lockout chip pinout

```text
                          ,---_---.
                 +5V 1 ---|01   08|-- 8 GND
                 CLK 2 x->|02   07|<-x /Force NTSC
 Lockout functioning 3 <-x|03   06|x-> Data Out
             Data In 4 x->|04   05|<-x Reset
                          `-------'

```
Lockout functioning (3) This signal goes high when the lockout chip successfully completes 64 frames. The "lockout functioning" pin is only for debug use. Do not rely on it as some form of cartridge power up reset. Due to toploaders lacking the 4MHz clock, this pin will float or do odd things in those systems. Cutting pin 4 of the lockout chip on a frontloader will cause the pin never to go high. /Force NTSC (7) Pulling this pin low forces the chip into NTSC only (3193 only) mode. The three PAL modes are not usable. Floating (disconnecting) this pin allows the chip to try all 4 regions.

## krikzz's AVR ATtiny13 Lockout chip pinout

```text
                          ATtiny13A
                          ,---_---.
                    nc -x |1     8| --- VCC
          (NES-71) clk x->|2     7| <-x rst (NES-70)
                   led <-x|3     6| <-x din (NES-34)
                   GND ---|4     5| x-> dout(NES-35)
                          `-------'

```

The pin "led" is low when the lockout is functioning normally, high when the chip is trying to change region.

# CPU pinout

Source: https://www.nesdev.org/wiki/CPU_pin_out_and_signal_description

### Pin out

```text
        .--\/--.
 AD1 <- |01  40| -- +5V
 AD2 <- |02  39| -> OUT0
/RST -> |03  38| -> OUT1
 A00 <- |04  37| -> OUT2
 A01 <- |05  36| -> /OE1
 A02 <- |06  35| -> /OE2
 A03 <- |07  34| -> R/W
 A04 <- |08  33| <- /NMI
 A05 <- |09  32| <- /IRQ
 A06 <- |10  31| -> M2
 A07 <- |11  30| <- TST (usually GND)
 A08 <- |12  29| <- CLK
 A09 <- |13  28| <> D0
 A10 <- |14  27| <> D1
 A11 <- |15  26| <> D2
 A12 <- |16  25| <> D3
 A13 <- |17  24| <> D4
 A14 <- |18  23| <> D5
 A15 <- |19  22| <> D6
 GND -- |20  21| <> D7
        `------'

```

### Signal description

Active-Low signals are indicated by a "/". Every cycle is either a read or a write cycle.
- CLK : 21.47727 MHz (NTSC) or 26.6017 MHz (PAL) clock input. Internally, this clock is divided by 12 (NTSC 2A03) or 16 (PAL 2A07) to feed the 6502's clock input φ0, which is in turn inverted to form φ1, which is then inverted to form φ2. φ1 is high during the first phase (half-cycle) of each CPU cycle, while φ2 is high during the second phase.
- AD1 : Audio out pin (both pulse waves).
- AD2 : Audio out pin (triangle, noise, and DPCM).
- Axx and Dx : Address and data bus, respectively. Axx holds the target address during the entire read/write cycle. For reads, the value is read from Dx during φ2. For writes, the value appears on Dx during φ2 (and no sooner).
- OUT0..OUT2 : Output pins used by the controllers ($4016 output latch bits 0-2). These 3 pins are connected to either the NESor Famicom'sexpansion port, and OUT0 is additionally used as the "strobe" signal (OUT) on both controller ports.
- /OE1 and /OE2 : Controller ports (for controller #1 and #2 respectively). Each enable the output of their respective controller, if present.
- R/W : Read/write signal, which is used to indicate operations of the same names. Low is write. R/W stays high/low during the entire read/write cycle.
- /NMI : Non-maskable interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- /IRQ : Interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- M2 : Can be considered as a "signals ready" pin. It is a modified version the 6502's φ2 (which roughly corresponds to the CPU input clock φ0) that allows for slower ROMs. CPU cycles begin at the point where M2 goes low.
  - In the NTSC 2A03E, G, and H, M2 has a duty cycleof 15/24 (5/8), or 350ns/559ns. Equivalently, a CPU read (which happens during the second, high phase of M2 ) takes 1 and 7/8th PPU cycles. The internal φ2 duty cycle is exactly 1/2 (one half).
  - In the PAL 2A07, M2 has a duty cycle of 19/32, or 357ns/601ns, or 1.9 out of 3.2 pixels.
  - In the original NTSC 2A03 (no letter), M2 has a duty cycle of 17/24, or 396ns/559ns, or 2 and 1/8th pixels.
- TST: (tentative name) Pin 30 is special: normally it is grounded in the NES, Famicom, PC10/VS. NES and other Nintendo Arcade Boards (Punch-Out!! and Donkey Kong 3). But if it is pulled high on the RP2A03G, extra diagnostic registers to test the sound hardware are enabled from $4018 through $401A, and the joystick ports $4016 and $4017 become open bus. On the RP2A07 and the RP2A03E [1], pulling pin 30 high instead causes the CPU to stop execution by means of deactivating the embedded 6502's /RDY input.
- /RST : When low, holds CPU in reset state, during which all CPU pins (except pin 2) are in high impedance state. When released, CPU starts executing code (read $FFFC, read $FFFD, ...) after 6 M2 clocks.

## References
- ↑https://forums.nesdev.org/viewtopic.php?p=304145#p304145

# CPU pinout

Source: https://www.nesdev.org/wiki/CPU_pinout

### Pin out

```text
        .--\/--.
 AD1 <- |01  40| -- +5V
 AD2 <- |02  39| -> OUT0
/RST -> |03  38| -> OUT1
 A00 <- |04  37| -> OUT2
 A01 <- |05  36| -> /OE1
 A02 <- |06  35| -> /OE2
 A03 <- |07  34| -> R/W
 A04 <- |08  33| <- /NMI
 A05 <- |09  32| <- /IRQ
 A06 <- |10  31| -> M2
 A07 <- |11  30| <- TST (usually GND)
 A08 <- |12  29| <- CLK
 A09 <- |13  28| <> D0
 A10 <- |14  27| <> D1
 A11 <- |15  26| <> D2
 A12 <- |16  25| <> D3
 A13 <- |17  24| <> D4
 A14 <- |18  23| <> D5
 A15 <- |19  22| <> D6
 GND -- |20  21| <> D7
        `------'

```

### Signal description

Active-Low signals are indicated by a "/". Every cycle is either a read or a write cycle.
- CLK : 21.47727 MHz (NTSC) or 26.6017 MHz (PAL) clock input. Internally, this clock is divided by 12 (NTSC 2A03) or 16 (PAL 2A07) to feed the 6502's clock input φ0, which is in turn inverted to form φ1, which is then inverted to form φ2. φ1 is high during the first phase (half-cycle) of each CPU cycle, while φ2 is high during the second phase.
- AD1 : Audio out pin (both pulse waves).
- AD2 : Audio out pin (triangle, noise, and DPCM).
- Axx and Dx : Address and data bus, respectively. Axx holds the target address during the entire read/write cycle. For reads, the value is read from Dx during φ2. For writes, the value appears on Dx during φ2 (and no sooner).
- OUT0..OUT2 : Output pins used by the controllers ($4016 output latch bits 0-2). These 3 pins are connected to either the NESor Famicom'sexpansion port, and OUT0 is additionally used as the "strobe" signal (OUT) on both controller ports.
- /OE1 and /OE2 : Controller ports (for controller #1 and #2 respectively). Each enable the output of their respective controller, if present.
- R/W : Read/write signal, which is used to indicate operations of the same names. Low is write. R/W stays high/low during the entire read/write cycle.
- /NMI : Non-maskable interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- /IRQ : Interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- M2 : Can be considered as a "signals ready" pin. It is a modified version the 6502's φ2 (which roughly corresponds to the CPU input clock φ0) that allows for slower ROMs. CPU cycles begin at the point where M2 goes low.
  - In the NTSC 2A03E, G, and H, M2 has a duty cycleof 15/24 (5/8), or 350ns/559ns. Equivalently, a CPU read (which happens during the second, high phase of M2 ) takes 1 and 7/8th PPU cycles. The internal φ2 duty cycle is exactly 1/2 (one half).
  - In the PAL 2A07, M2 has a duty cycle of 19/32, or 357ns/601ns, or 1.9 out of 3.2 pixels.
  - In the original NTSC 2A03 (no letter), M2 has a duty cycle of 17/24, or 396ns/559ns, or 2 and 1/8th pixels.
- TST: (tentative name) Pin 30 is special: normally it is grounded in the NES, Famicom, PC10/VS. NES and other Nintendo Arcade Boards (Punch-Out!! and Donkey Kong 3). But if it is pulled high on the RP2A03G, extra diagnostic registers to test the sound hardware are enabled from $4018 through $401A, and the joystick ports $4016 and $4017 become open bus. On the RP2A07 and the RP2A03E [1], pulling pin 30 high instead causes the CPU to stop execution by means of deactivating the embedded 6502's /RDY input.
- /RST : When low, holds CPU in reset state, during which all CPU pins (except pin 2) are in high impedance state. When released, CPU starts executing code (read $FFFC, read $FFFD, ...) after 6 M2 clocks.

## References
- ↑https://forums.nesdev.org/viewtopic.php?p=304145#p304145

# Camerica BF909x pinout

Source: https://www.nesdev.org/wiki/Camerica_BF909x_pinout

```text
                  .--v--.                   |                   .--v--.                   |                   .--v--.
           +5V -- |01 20| <- CPU A14        |            +5V -- |01 20| <- CPU A14        |            +5V -- |01 20| <- CPU A14
       CPU R/W -> |02 19| <- CPU A13        |        CPU R/W -> |02 19| <- CPU A13        |        CPU R/W -> |02 19| <- CPU A13
       PRG /CE <- |03 18| -> $C000.1 OR A14 |        PRG /CE <- |03 18| -> $C000.1 OR A14 |        PRG /CE <- |03 18| -> $C000.1 OR A14
$C000.0 OR A14 <- |04 17| -> $C000.2 OR A14 | $C000.0 OR A14 <- |04 17| -> $8000.4        | $C000.0 OR A14 <- |04 17| -> $8000.4
            M2 -> |05 16| <- ??             |             M2 -> |05 16| <- ??             |             M2 -> |05 16| -> $C000.2 OR A14
        CPU A0 -> |06 15| <- CPU /ROMSEL    |         CPU A0 -> |06 15| <- CPU /ROMSEL    |         CPU A0 -> |06 15| <- ??
        CPU D0 -> |07 14| -> $C000.3 OR A14 |         CPU D0 -> |07 14| -> $8000.3        |         CPU D0 -> |07 14| <- CPU /ROMSEL
        CPU D1 -> |08 13| -> CIC stun       |         CPU D1 -> |08 13| -> CIC stun       |         CPU D1 -> |08 13| -> CIC stun
        CPU D2 -> |09 12| <- CPU D4         |         CPU D2 -> |09 12| <- CPU D4         |         CPU D2 -> |09 12| <- CPU D4
           GND -- |10 11| <- CPU D3         |            GND -- |10 11| <- CPU D3         |            GND -- |10 11| <- CPU D3
                  '-----'                   |                   '-----'                   |                   '-----'
                  BF9093                    |                   BF9096                    |                   BF9097

       $C000.3 OR CPU A14 = PRG A17         |        $8000.3            = PRG A17         |       $8000.4            = CIRAM A10 in Firehawk
       $C000.2 OR CPU A14 = PRG A16         |        $8000.4            = PRG A16         |       $C000.2 OR CPU A14 = PRG A16
       $C000.1 OR CPU A14 = PRG A15         |        $C000.1 OR CPU A14 = PRG A15         |       $C000.1 OR CPU A14 = PRG A15
       $C000.0 OR CPU A14 = PRG A14         |        $C000.0 OR CPU A14 = PRG A14         |       $C000.0 OR CPU A14 = PRG A14

```

Notes:
- All chips are 20-pin 0.3" PDIP
- Register $8000 is at $8000-$BFFF
- Register $C000 is at $C000-$FFFF
- ?? is unknown input, tied to GND in all cartridges
- BF9093 is used in 64 kB / 128 kB / 256 kB NES & 256 kB Famicom singles ( iNES Mapper 071submapper 0)
- BF9096 is used in NES/Famicom Quattro multicarts ( iNES Mapper 232)
- BF9097 is used in Firehawk ( iNES Mapper 071submapper 1) and in 64 kB Famicom singles (pins 17, 16 are not wired here)
- CIC stun latches inverse of CPU A0 when writing at $E000-$FFFF
- Pinout from Kevtrisis not accurate

Source: [1]

# Camerica CME-01 pinout

Source: https://www.nesdev.org/wiki/Camerica_CME-01_pinout

Camerica CME-01: 0.6" 28-pin PDIP ( Mapper 71or Mapper 232depending on PCB)

```text
                                     .---v---.
(R)  $C000.2 OR CPU-A14 (PRG A16) <- |01   28| -- VCC
(R)  $C000.1 OR CPU-A14 (PRG A15) <- |02   27| -> $C000.3 OR CPU-A14 (PRG A17) (R)
                   (R,N)  CPU-A12 -> |03   26| -> $C000.0 OR CPU-A14 (PRG A14) (R)
                     (N)  CPU-A14 -> |04   25| <- CPU A13 (R,N)
                     (N) CPU /RMS -> |05   24| -> PRG /CE (R)
                     (N)  CIC+RST -> |06   23| -> PRG /OE (R)
                     (N)  CPU R/W -> |07   22| <> CPU D7  (R,N)
                   (n/c)  $8000.4 <- |08   21| <> CPU D0  (R,N)
                   (n/c)  $8000.2 <- |09   20| <> CPU D6  (R,N)
                   (n/c)  $8000.3 <- |10   19| <> CPU D1  (R,N)
                           MOSFET <- |11   18| <> CPU D5  (R,N)
                     10MHz CLK IN -> |12   17| <> CPU D2  (R,N)
                    10MHz CLK OUT <- |13   16| <> CPU D4  (R,N)
                              GND -- |14   15| <> CPU D3  (R,N)
                                     '-------'

```

The data bus injects a NOP slide for a fixed amount of time, relying on using the MOSFET connected to the MOSFET output to brown out the NES's power supply and crash the CIC.
- Appears in Cosmic Spacehead [1]and Super Adventure Quests [2]
- Source: Krzysiobal

# Controller port pinout

Source: https://www.nesdev.org/wiki/Controller_port_pinout

## Pinout

```text
                            +----------< $4017.D3
                            | +--------< D0
                            | | +------> OUT0             +------------------ GND
                            | | | +----> CLK              | +--------------<> AUDIO
                            | | | | +--< $4017.D4         | |           +---< D0
        .-                  | | | | |                     | |           |
 GND -- |O\              +-------------+               +-------------------+
 CLK <- |OO\ -- +5V       \ O O O O O /                 \ O O O O O O O O /
 OUT <- |OO| <- D3         \ O O O O /                   \ O O O O O O O /
  D0 -> |OO| <- D4          +-------+                     +-------------+
        '--'                 |   |                         |     |     |
                             |   +------ GND               |     |     +---- +5V
                             +---------- +5V               |     +---------: OUT0
                                                           +---------------> CLK
     NES port           9 pin famiclone port               15 pin famiclone port

 * Directions are relative to the jack on the from of console
 * $4017.D3/$4017.D4 are available only at port 2 in consoles equipped only with 2x9pin ports
 * AUDIO might not always be available

```

The 15-pin connector is a subset of the standard Famicom expansion port.

Official standard controllersusually use a standard coloring for their wires:

| Signal | NES | Famicom player 1 | Famicom player 2 |
| +5V | White | White | Blue |
| OUT | Orange | Orange | Yellow |
| D0 | Red | Yellow | Orange |
| GND | Brown | Brown | Red |
| CLK | Yellow | Red | White |
| D2 | --- | --- | Brown |

## Protection Diodes

Some PAL region systems have a set of diodes on the inside of the controller port which make it incompatible with NTSC controllers. [1]

```text
+5V --|>|-- jack
 D3 --|>|-- jack
 D4 --|>|-- jack
 D0 --|>|-- jack
OUT --|<|-- jack
CLK --|<|-- jack

```

With these diodes, the OUT and CLK lines have to be pulled high by the controller, or else the controller can't receive these signals. See: Standard controller: PAL

These diodes are also present on the ports of the Four Score(NESE-034) accessory for this region.

## Super NES

The FC TwinNES/SNES combo clone uses Super NES controllers, whose pinout is as follows: [2]

```text
 1 [oooo|ooo) 7  1:+5V  2:Clk  3:Out  4:D0  5:D1  6: I/O  7:Gnd

```

An adapter to use Super NES controllers on an NES (or NES controllers on an FC Twin) could be constructed as follows (leaving D3 and D4 unconnected):

```text
        .-
 GND -- |7\
 CLK <- |21\ -- +5V
 OUT <- |3o| -- (D3)
  D0 -> |4o| -- (D4)
        '--'

```
- Buy two controller extension cables, one for NES and one for Super NES, and cut them apart. Strip the cut ends to reveal a small amount of bare wire.
- Using inline splice technique, wrap each wire from one cable with the corresponding wire from the other cable.
- With solder and a soldering iron, glue each wrapped pair together.
- With electrical tape, wrap each joint to insulate it from the other wires.
- Apply heat shrink around the whole assembly.

## Notes
- The signal read by the CPU is logically inverted from the signal input on the D0-4 lines. A low voltage on D0 will be read as a 1 bit from $4016/4017.
- CLK will be low during reads from the CPU, then immediately return to high. This rising edge transition is used to clock the shift register inside the standard controller.
- OUT is a signal latched and held from the last CPU write to $4016:0. For standard controller reads, the program will write a 1 to load the shift register, then return to 0 before reading the results.

## Hardware design
- Famicom and NES controllers use single 40218-step shift register for serial transmission (pressed button is shorted to GND by low-resistance rubber pad; VCC pull-ups are inside 4021)

```text
      +-------
      | -----+
 BTN--+----- +-- GND
      | -----+
      +-------

```
- Cascading input is connected to GND, which results in returning 1 for reads greater than 8 (in contrary to most blob pads, where it returns 0).
- Rare model of non-blob IQ502 famiclone joypad uses UM6582chip which aggregates both serial encoder and square wave generator (for turbo buttons)
- Most famiclone pads use glob chip which integrates both serial encoder and turbo generator
- Pressing TURBOA (or TURBOB) causes short of A (or B) to the square wave generated by chip (or blob).

```text
           TURBO A
            ----
 TURBO >----'  '--+
                  |
            ----  |
   GND -----'  '--+----> !A
             A

```
- Some joypads contains also buttons C and TURBO C (whose acts as pressing buttons A and B together); The SMD contact for that button contains three signals
- SNES joypads contain two 4021 or two WR545 chips chained together

```text
           ,---v---.                 WR545#1  WR545#2
       d0->|01   14|--VCC         d0  B       A
     DOUT<-|02   13|<-d1          d1  Y       X
       d4->|03   12|<-d2          d2  SEL     TL
       d5->|04   11|<-d3          d3  ST      TR
       d6->|05   10|<-DIN         d4  U       -
       d7->|06   09|<-CLOCK       d5  D       -
      GND--|07   08|<-STROBE      d6  L       -
           +-------+              d7  R       -
            WR545

```

## See Also
- Standard controller
- Expansion port

## References
- ↑Forum post: explaining PAL controller diodes and their function.
- ↑superfamicom.org: Schematics, Ports, and Pinouts.

# DIS23C01 pinout

Source: https://www.nesdev.org/wiki/DIS23C01_pinout

DAOU ROM CONTROLLER DIS23C01 Daou 245 (Mapper 156)

```text
                                   _____
                                  /     \                             Orientation:
                     NC (cut) -- / 1  64 \ -- NC (cut)                --------------------
                     GND (*) -- / 2    63 \ <- CPU A1                     51         33
                     CPU A2 -> / 3  (o) 62 \ <- CPU A0                     |         |
                    CPU A3 -> / 4        61 \ ?? always low               .-----------.
                   CPU A4 -> / 5          60 \ ?? always low           52-|o DAOU    o|-32
                 CPU R/W -> / 6            59 \ -- VCC                    |  DIS23C01 |
                    GND -- / 7              58 \ ?? alway high (cut)   64-|o DaOU 245 |-20
               CPU A14 -> / 8                57 \ ?? always high          \-----------'
                  GND -- / 9                  56 \ ?? always high          |         |
             CIR A10 <- / 10                   55 \ ?? always high       01         19
            PRG /CE <- / 11                     54 \ ?? always high
 /IRQ (always low) <- / 12                       53 \ ?? always high
          PRG A14 <- / 13                         52 \ ?? always high
         PRG A15 <- / 14      DAOU DIS23C01       51 / ?? always high
        PRG A16 <- / 15      Package QFP-64      50 / <- CPU D7
       PRG A17 <- / 16        1.00mm pitch      49 / <- CPU D6
      PRG A18 <- / 17         (20mm × 14mm)    48 / <- CPU D5
     PRG A19 <- / 18                          47 / <- CPU D4
    PRG A20 <- / 19                          46 / <- CPU D3
    CHR A10 <- \ 20                         45 / <- CPU D2
         GND -- \ 21                       44 / <- CPU D1
      CHR A11 <- \ 22                     43 / <- CPU D0
       CHR A12 <- \ 23                   42 / -- GND
        CHR A13 <- \ 24                 41 / <- M2
             VCC -- \ 25               40 / <- PPU A12
always high (cut) ?? \ 26             39 / <- PPU A11
           CHR A14 <- \ 27           38 / <- PPU A10
            CHR A15 <- \ 28         37 / -- GND
             CHR A16 <- \ 29       36 / <- CPU /ROMSEL
              CHR A17 <- \ 30     35 / -- GND
               CHR A18 <- \ 31   34 / -- VCC
                CHR A19 <- \ 32 33 / ?? always high
                            \     /
                             \   /
                              \ /
                               V

```

notes:
- pins 1, 64 - no internal connection; externally cut from the package (NC)
- pin 2 - no external con, internally connected to other ground pins
- pins 26, 58 - externally cut
- PRG A pins reflect the bank being set only when M2 is high; when M2 is low, they always go high
- CIRAM A10 is not connected to mapper (premanently wired to GND) on this board (Koko Adventure)
- IRQ pin seems to be non-functional (it is always low)
- This board uses weird pinouts for PRG/CHR eproms (32 holes, pin 2 and 24 both shorted and connected to PRG/CHR A16 respectively), but eproms have pins 24 cut and not soldered to anything (floating)
- A lot of not used pins (but showing signs of internal connection) suggests that this chip maybe some kind of PLD instead of ASIC (just like BF909x from codemasters)

Source: [1]]

# EXP283 pinout

Source: https://www.nesdev.org/wiki/EXP283_pinout

The first release of Based Loadedhas a patcher IC labelled "EXP283" (shrink DIP42) that patches the game to make the NMI handler safely reentrant. Subsequent releases instead have the NMI handler detect reentry and return early.

It appears to do two things:
- Reads from PRG ROM ADDRESS & $7FFF == $0180 replace the byte with $60; this replaces a lda $0573 with lda $6073
- Reads from $6000-$6FFF return MMC1 PRG A15 through A17 on D4-D6.

```text
            NC ?? | 1   42 | -- +5V
            NC ?? | 2   41 | <- MMC1 PRG A17
            NC ?? | 3   40 | <- MMC1 PRG A15
            NC ?? | 4   39 | <- MMC1 PRG A14
            NC ?? | 5   38 | <- CPU A12
            NC ?? | 6   37 | <- CPU A13
            NC ?? | 7   36 | <- CPU A7
            NC ?? | 8   35 | <- CPU A8
            NC ?? | 9   34 | <- CPU A6
PRG RAM +CE IN -> | 10  33 | <- CPU A9
           GND ?? | 11  32 | <- CPU A5
        CPU D7 <> | 12  31 | <- CPU A11
        CPU D6 <> | 13  30 | <- CPU A4
        CPU D5 <> | 14  29 | <- MMC1 PRG A16
        CPU D4 <> | 15  28 | <- CPU A3
        CPU D3 <> | 16  27 | <- CPU A10
        CPU D2 <> | 17  26 | <- CPU A2
        CPU D1 <> | 18  25 | -> PRG ROM /CE OUT
        CPU D0 <> | 19  24 | <- CPU A1
            NC ?? | 20  23 | <- MMC1 PRG /CE IN
           GND -- | 21  22 | <- CPU A0

```

# EXP pins

Source: https://www.nesdev.org/wiki/EXP_pins

The EXP pinsare expansion pins present on the 72-pin NES cartridge connector and which connect to the expansion port on the bottom of the NES-001 console. These pins were not used by any officially released consumer device, but are used by various unlicensed devices and the FamicomBoxhotel console.

## Pin summary

| Device | EXP0 | EXP1 | EXP2 | EXP3 | EXP4 | EXP5 | EXP6 | EXP7 | EXP8 | EXP9 | Type |
| Broke Studio discrete mapper cartridges | ✓ |  |  |  |  | ✓ |  |  |  |  | Cartridge |
| Broke Studio MMC mapper cartridges |  |  |  |  |  | ✓ | ♪ |  |  | ♪ | Cartridge |
| Broke Studio Rainbow mapper cartridges |  |  |  |  |  | ✓ | ♪ |  |  | ♪ | Cartridge |
| CopyNES | ✓ |  |  |  |  |  |  |  |  |  | Console |
| Everdrive N8 |  |  |  |  |  |  | ♪ |  |  |  | Cartridge |
| Everdrive N8 Pro | ~ | ~ | ~ | ~ | ~ | ~ | ♪ | ~ | ~ | ~ | Cartridge |
| Expansion Port Sound Module (EPSM) |  | ✓ | ♪ | ✓ | ✓ |  | ♪ | ✓ | ✓ | ♪ | Expansion |
| ExROM (MMC5) |  |  |  |  |  | ✓ | ♪ |  |  |  | Cartridge |
| Extended NES I/O (ENIO) | ~ | ~ | ~ | ~ | ~ | ✓ | ♪ | ✓ | ✓ | ✓ | Expansion |
| Famicom-to-NES adapter |  |  | ♪* |  |  |  | ♪* |  |  |  | Cartridge |
| FamicomBox | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Console |
| INL cartridges | ✓* | ✓* | ✓* | ✓* | ✓* | ✓* | ♪ |  |  | ♪ | Cartridge |
| INL Expansion Audio Dongle Slim |  |  |  |  |  |  | ♪ |  |  | ~ | Expansion |
| Muramasa NES FDS | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ♪ | ✓ | ✓ | ✓ | Expansion |
| NES Hub | ~ | ~ | ~♪ | ~ | ~ | ~ | ~♪ | ~ | ~ | ~♪ | Expansion |
| NES-21G-CPU-72P | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Cartridge |
| PowerPak | ✓ | ~ | ~ | ~ | ~ | ~ | ♪ | ~ | ~ |  | Cartridge |
| PowerPak Lite | ✓ |  |  |  |  |  |  |  |  |  | Cartridge |
| Simple Famicom Expansion Audio Module (SFEAM) |  |  | ♪* |  |  |  | ♪ |  |  | ♪* | Expansion |
| TinyNES |  |  |  |  |  |  | ♪ |  |  |  | Console |

✓ : This pin is used.
♪ : This pin is used for expansion audio output (cartridge) or input (expansion device or console).
* : This pin is used by some, but not all such devices.
~ : This pin is connected, but lacks a specific function.

## Pin notes

| Pin | Pin exists on: | Notes |
| NES-001 | NES-101 |
| EXP0 | ✓ | ✓ | Some modern cartridges connect EXP0 to ground, likely because of the presence of a ground pin on the Famicom's cartridge connector in the region where the EXP pins are placed on the NES' connector. This provides no benefit because consoles don't put ground there, and it adds risk because a console or expansion port signal could be unexpectedly shorted to ground. For example, inserting such a cartridge into the FamicomBox can short 5V to ground through this pin, causing damage to the cartridge or console. |
| EXP1 | ✓ | ✓ |  |
| EXP2 | ✓ |  | EXP2 is used by some Famicom-to-NES adapters for expansion audio, but no cartridges are known to use it for this purpose. |
| EXP3 | ✓ |  |  |
| EXP4 | ✓ | ✓ |  |
| EXP5 | ✓ |  |  |
| EXP6 | ✓ |  | EXP6 has become the standard console input for expansion audio and is used by flash carts, modern homebrew, and modern Famicom-to-NES adapters. |
| EXP7 | ✓ | ✓ |  |
| EXP8 | ✓ | ✓ |  |
| EXP9 | ✓ | ✓ | Because EXP6 is not present on the NES-101, EXP9 is often used as a secondary audio output so the NES-101 can be modified to use it. |

Note : On the NES-101, the EXP pins that don't exist are not even present on the cartridge slot; that is, there is no metal making contact with those cartridge pins, preventing their use. The other EXP pins connect to the board, but are not routed anywhere, so they are available for console modifications.

## Devices

### Broke Studio discrete mapper cartridges

Broke Studio's NROM, BNROM, and UNROM512 boards use EXP0 and EXP5 for programming and ROM and CIC, respectively.

```text
   Programmer     |      Cart       |     Programmer
                   -----------------
                         ...
                  |20 EXP4
                  |19 EXP3   EXP5 55| <- ATtiny13 AVR reset
                  |18 EXP2   EXP6 54|
                  |17 EXP1   EXP7 53|
   PRG-ROM /WE -> |16 EXP0   EXP8 52|
                             EXP9 51|
                          ...

```

### Broke Studio MMC mapper cartridges

Broke Studio's MMC board uses EXP5 for programming the CIC and outputs expansion audio on both EXP6 and EXP9. These audio outputs are tied together.

```text
 Programmer or                           Programmer or
 Expansion port   |      Cart       |    Expansion Port
                   -----------------
                         ...
                  |20 EXP4
                  |19 EXP3   EXP5 55| <- ATtiny13 AVR reset
                  |18 EXP2   EXP6 54| -> audio
                  |17 EXP1   EXP7 53|
                  |16 EXP0   EXP8 52|
                             EXP9 51| -> audio
                          ...

```

### Broke Studio Rainbow mapper cartridges

Broke Studio's Rainbow mapper board uses EXP5 for programming the CIC and is capable of outputting different expansion audio on each of EXP6 and EXP9. The Rainbow mapper itself produces just one audio stream, which software can choose to output on either or both of these pins. However, the cartridge pins connect to separate FPGA pins, and so another mapper implemented on the same board could output unique audio on each.

```text
 Programmer or                           Programmer or
 Expansion port   |      Cart       |    Expansion Port
                   -----------------
                         ...
                  |20 EXP4
                  |19 EXP3   EXP5 55| <- ATtiny13 AVR reset
                  |18 EXP2   EXP6 54| -> audio 1
                  |17 EXP1   EXP7 53|
                  |16 EXP0   EXP8 52|
                             EXP9 51| -> audio 2
                          ...

```

### CopyNES

The CopyNESallows the 2A03 to control EXP0. It's used to write to RAM carts, such as the PowerPak Lite.

### Expansion Port Sound Module (EPSM)

The EPSMcan be written through either a cart-agnostic universal access mode or a mapper-specific mode, where the cartridge decodes the address and passes chip enable and address bits via EXP pins. It also accepts expansion audio input on EXP2, EXP6, and EXP9, to support as wide a variety of cartridges as possible.

```text
Expansion Port    |      Cart       |    Expansion Port
                   -----------------
                          ...
       EPSM A1 <- |20 EXP4
     EPSM /CE2 <- |19 EXP3   EXP5 55|
         audio <- |18 EXP2   EXP6 54| -> audio
     EPSM /CE1 <- |17 EXP1   EXP7 53| -> EPSM A0
                  |16 EXP0   EXP8 52| -> EPSM CE3
                             EXP9 51| -> audio
                          ...

```

### ExROM (MMC5)

ExROM boards, using MMC5, are configured for expansion audio output on EXP6, though the boards must also have the appropriate resistors and capacitors populated for this to function. EXP5, which is pulled low in the cart, is used as a PRG-RAM read disable.

```text
Expansion Port    |      Cart       |    Expansion Port
                   -----------------
                          ...
                  |20 EXP4
                  |19 EXP3   EXP5 55| <- PRG-RAM /OE
                  |18 EXP2   EXP6 54| -> audio
                  |17 EXP1   EXP7 53|
                  |16 EXP0   EXP8 52|
                             EXP9 51|
                          ...

```

### Extended NES I/O (ENIO)

The ENIOCPU board can be accessed through either a cart-agnostic compatibility mode or a direct addressing mode, where the cartridge decodes the address and passes R/W and /CE to the ENIO via EXP pins. EXP5 and EXP7-9 are passed to the CPU board, handling R/W, /CE, and presumably other currently-undocumented functionality. EXP6 is used as an expansion audio input. EXP0-4 are routed to an unpopulated header for expansion use.

```text
      Expansion Port    |      Cart       |    Expansion Port
                         -----------------
                                ...
ENIO J4 header pin 7 ?? |20 EXP4
ENIO J4 header pin 8 ?? |19 EXP3   EXP5 55| ?? unknown (ENIO CPU board)
ENIO J4 header pin 5 ?? |18 EXP2   EXP6 54| -> audio
ENIO J4 header pin 6 ?? |17 EXP1   EXP7 53| -> ENIO R/W
ENIO J4 header pin 3 ?? |16 EXP0   EXP8 52| -> ENIO /CE
                                   EXP9 51| ?? unknown (ENIO CPU board)
                                ...

```

### Famicom-to-NES adapter

Some Famicom-to-NES adapters connect expansion audio to an EXP pin. If connected, modern adapters typically use EXP6, though EXP2 has been observed due to its proximity to the audio-to-RF pin on the Famicom cartridge connector.

### FamicomBox

The FamicomBoxuses the EXP pins primarily to indicate slot ID to the cartridge's 3198 CIC. 9 of the pins are tied to some combination of ground and 5V, which can cause damage to non-FamicomBox cartridges that use EXP pins. One additional pin provides A15, which is not used by any contemporary game. Unlike the NES-001, the FamicomBox does not route any of these pins to any external port for expansion use.

```text
 FamicomBox    |      Cart       |    FamicomBox
                -----------------
                       ...
    CPU A15 -> |20 EXP4
/SlotIndex3 -> |19 EXP3   EXP5 55| -- GND
/SlotIndex2 -> |18 EXP2   EXP6 54| -- GND
/SlotIndex1 -> |17 EXP1   EXP7 53| -- GND
/SlotIndex0 -> |16 EXP0   EXP8 52| -- +5V
                          EXP9 51| -- +5V
                       ...

```

### INL cartridges

Infinite NES Lives cartridges use EXP pins for various purposes, though not universally across all boards. EXP6 and EXP9 are used to output expansion audio to the console. Newer boards use EXP0 as PRG-ROM /WE for writing the cartridges, with a pullup on the board. Some boards use EXP0-3 (and EXP4 on dual-CPLD boards) for a JTAG interface. When an ATtiny13 is used for the CIC, EXP5 acts as AVR reset. The ATtiny13 is configured for high voltage power supply (HVPS) programming at 12v.

```text
 Programmer or                           Programmer or
 Expansion port   |      Cart       |    Expansion Port
                   -----------------
                          ...
                  |20 EXP4
                  |19 EXP3   EXP5 55|
                  |18 EXP2   EXP6 54| -> audio
                  |17 EXP1   EXP7 53|
   PRG-ROM /WE -> |16 EXP0   EXP8 52|
                             EXP9 51| -> audio
                          ...

```

```text
 Programmer or                           Programmer or
 Expansion port   |      Cart       |    Expansion Port
                   -----------------
                         ...
CPLD2 JTAG TCK -> |20 EXP4
CPLD1 JTAG TCK -> |19 EXP3   EXP5 55| <- ATtiny13 AVR reset
      JTAG TMS -> |18 EXP2   EXP6 54| -> audio
      JTAG TDI -> |17 EXP1   EXP7 53|
      JTAG TDO -> |16 EXP0   EXP8 52|
                             EXP9 51| -> audio
                          ...

```

### INL Expansion Audio Dongle Slim

This expansion port adapter enables expansion audio input on EXP6. While it only has pins on EXP6 and audio mix input by default, pins can be added to it on EXP9 and audio output, though they aren't routed anywhere on the board. Because EXP6 is the default for expansion audio output and the NES-001 is the only console with this expansion port, connecting to EXP9 is unlikely to be useful.

### Muramasa NES FDS

Because the NES-001 doesn't easily allow a cartridge to connect with another device via an external cable, Muramasa's NES FDS connects the RAM adapter cartridge and disk drive via the EXP pins.

```text
            Expansion Port    |      Cart       |    Expansion Port
                               -----------------
                                      ...
                serial out <- |20 EXP4
            (R/W) $4034.W2 <- |19 EXP3   EXP5 55| <- serial in
 (transfer reset) $4035.W1 <- |18 EXP2   EXP6 54| -> audio
(write protected) $4032.R2 -> |17 EXP1   EXP7 53| -> $4025.W0 (motor control)
    (disk /ready) $4032.R1 -> |16 EXP0   EXP8 52| <- $4032.R0 (disk /inserted)
                                         EXP9 51| <- battery
                                      ...

```

### NES Hub

The NES Hubcan be configured with DIP switches to use any combination of EXP2, EXP6, and EXP9 for expansion audio. It also exposes all 10 EXP signals on a mini DisplayPort connector for use by other devices. Note that the pins are different on the source (NES Hub) and destination (EXP addon) side; the pinout below uses source/destination for pins.

```text
                             Expansion Port    |      Cart       |    Expansion Port
                                                -----------------
                                                       ...
                        EXP addon pin 11/15 ?? |20 EXP4
                        EXP addon pin 09/17 ?? |19 EXP3   EXP5 55| ?? EXP addon pin 03/12
EXP addon pin 10/05, and (optionally) audio <? |18 EXP2   EXP6 54| ?> EXP addon pin 01/08, and (optionally) audio
                        EXP addon pin 12/03 ?? |17 EXP1   EXP7 53| ?? EXP addon pin 05/10
                        EXP addon pin 15/11 ?? |16 EXP0   EXP8 52| ?? EXP addon pin 06/06
                                                          EXP9 51| ?> EXP addon pin 04/04, and (optionally) audio
                                                       ...

```

### NES modem

The NES modem is an unreleased official expansion device that would have allowed online access. It is highly likely this device uses the EXP pins, but no specifics are known.

### NES-21G-CPU-72P

The NES-21G-CPU-72Pboard is used in some Nintendo test cartridges and uses the EXP pins to interact with an unknown device. The last value written to $6000 is outputted over 8 EXP pins, with the high bit also signaling whether the M2 and the system clock inputs are not functioning. EXP6 indicates when $6000 is being read, and it is speculated that this would cause the expansion device to drive the latched data onto the CPU data lines. EXP5 is used, but its effect is currently unknown; it may control the PRG-ROM's /OE.

```text
Expansion Port    |      Cart       |    Expansion Port
                   -----------------
                          ...
      $6000.R4 <- |20 EXP4
      $6000.R3 <- |19 EXP3   EXP5 55| <- unknown
      $6000.R2 <- |18 EXP2   EXP6 54| -> $6000 /read
      $6000.R1 <- |17 EXP1   EXP7 53| -> $6000.R7 OR clocks bad
      $6000.R0 <- |16 EXP0   EXP8 52| -> $6000.R6
                             EXP9 51| -> $6000.R5
                          ...

```

### PowerPak

The PowerPakuses EXP0 to allow the CopyNES to program the boot ROM. EXP1-8 are connected to the FPGA and can be used, but only EXP6 has been (for expansion audio output). EXP9 is not connected, and some users have bridged it with EXP6 to enable expansion audio on NES-101 consoles.

```text
  Expansion Port    |      Cart       |    Expansion Port
                     -----------------
                            ...
     FPGA pin 22 ?? |20 EXP4
     FPGA pin 20 ?? |19 EXP3   EXP5 55| ?? FPGA pin 19
     FPGA pin 27 ?? |18 EXP2   EXP6 54| -> audio (FPGA pin 23)
     FPGA pin 12 ?? |17 EXP1   EXP7 53| ?? FPGA pin 94
boot ROM program -> |16 EXP0   EXP8 52| ?? FPGA pin 41
                               EXP9 51|
                            ...

```

### PowerPak Lite

The PowerPak Liteis programmed with settings for the current game by a CopyNES via EXP0.

### Simple Famicom Expansion Audio Module (SFEAM)

This expansion port adapter enables expansion audio input on EXP2, EXP6, or EXP9. It comes with a resistor populated only for EXP6 audio, leaving EXP2 and EXP9 disconnected by default.

# FDS RAM adaptor cable pinout

Source: https://www.nesdev.org/wiki/FDS_RAM_adaptor_cable_pinout

The FDSRAM adapter requires a cable to be connected to the disk drive (physical or emulated) in order to facilitate disk transfers.

## Diagram

Open-end view of the RAM adapter's disk drive connector.

```text
 ████████████████████████████████
 ████████████████████████████████
 ███  1   3   5   7   9   11  ███
 ███                          ███
 ███  2   4   6   8   10  12  ███
 \██████████████████████████████/
  \████████████████████████████/

```

## Pin meanings

| pin # | 2C33 register | *2C33 pin | *RAM pins | I/O | signal description |
| 1 | $4025.2 | 50 | 5 (green) | Output | /write |
| 2 | - | 64 | 12 (cyan) | Output | VCC (+5VDC) |
| 3 | $4025.0 | 48 | 6 (blue) | Output | /scan media |
| 4 | - | 32 | 1 (brown) | Output | VEE (ground) |
| 5 | $4024[1] | 52 | 3 (orange) | Output | write data |
| 6 | $4033.7 | 37 | 11 (pink) | Input | motor on/battery good |
| 7 | $4032.2 | 47 | 8 (grey) | Input | /writable media |
| 8 | - | - | - | Input | motor power† |
| 9 | $4031[1] | 51 | 4 (yellow) | Input | read data |
| 10 | $4032.0 | 45 | 10 (black) | Input | /media set |
| 11 | $4032.1 | 46 | 9 (white) | Input | /ready |
| 12 | $4025.1 | 49 | 7 (violet) | Output | /stop motor |

```text
notes on symbols
----------------
I/O: input/output
/ : Indicates a signal which is active on a low (0) condition.
* :	These are corresponding pinouts for the 2C33 I/O chip, and the other  end
of the RAM adaptor cable, which both are located inside the RAM adaptor.
† :	The RAM adaptor does not use this signal (there is no wire in the cable
to carry the signal). An electronically controlled 5-volt power supply
inside the disk drive unit generates the power that appears here. This power
is also shared with the drive's internal electric motor. Therefore, the
motor only comes on when there is voltage on this pin.

```

## Signal Descriptions

### Pin 1 (Output) /write ($4025.2)

While active, this signal indicates that data appearing on the "write data" signal pin is to be written to the storage media.

### Pin 3 (Output) /scan media ($4025.0)

While inactive, this instructs the storage media pointer to be reset (and stay reset) at the beginning of the media. When active, the media pointer is to be advanced at a constant rate, and data progressively transferred to/from the media (via the media pointer).

### Pin 5 (Output) write data

This is the serial data the RAM adaptor issues to be written to the storage media on the "/write" condition.

### Pin 6 (Input) motor on, battery good ($4033.7)

Applicable mostly to the FDS disk drive unit only, after the RAM adaptor issues a "/scan media" signal, it will check the status of this input to see if the disk drive motor has turned on. If this input is found to be inactive, the RAM adaptor interprets this as the disk drive's batteries having failed. Essentially, this signal's operation is identical to the above mentioned "motor power" signal, except that this is a TTL signal version of it.

### Pin 7 (Input) /writable media ($4032.2)

When active, this signal indicates to the RAM adaptor that the current media is not write protected.

### Pin 9 (Input) read data

When "/scan media" is active, data that is progressively read off the storage media (via the media pointer) is expected to appear here.

### Pin 10 (Input) /media set ($4032.0)

When active, this signal indicates the presence of valid storage media.

### Pin 11 (Input) /ready ($4032.1)

Applicable mostly to the FDS disk drive unit only, the falling edge of this signal would indicate to the RAM adaptor that the disk drive has acknowledged the "/scan media" signal, and the disk drive head is currently at the beginning of the disk (most outer track). While this signal remains active, this indicates that the disk head is advancing across the disk's surface, and appropriate data can be transferred to/from the disk. This signal would then go inactive if the head advances to the end of the disk (most inner track), or the "/scan media" signal goes inactive.

### Pin 12 (Output) /stop motor ($4025.1)

Applicable mostly to the FDS disk drive unit only, the falling edge of this signal would instruct the drive to stop its motor (and therefore end the current scan of the disk).

## Notes
- ↑ 1.01.1Parallel/serial conversion is done via a pair of shift registers inside 2C33

# FDS expansion port pinout

Source: https://www.nesdev.org/wiki/FDS_expansion_port_pinout

The FDShas an expansion port located at the rear of the RAM adapter, covered by a shutter. (Labelled as Expansion Port B on the Twin Famicom) The unreleased Famicom Network Adapterwas designed to use this port.

A few unlicensed devices are also known to use the port:
- ILine-PC ( Iライン-PC ) - to connect the FDS to a PC's printer port.
- Super Copy System: Hacker Pro Digital - for use with disk copier software of the same name.

## Diagram

Open end view of the external connector.

```text
         -------
         |  --  \
  +5V -- | 1||2  | <> EXT6
 EXT5 <> | 3||4  | <> EXT4
 EXT3 <> | 5||6  | <> EXT2
 EXT1 <> | 7||8  | <> EXT0
SOUND <- | 9||10 | -- GND
         |  --  /
         -------

```

## Signal descriptions
- +5V : 5V Power supply from the main voltage regulator.
- GND : 0V Power supply.
- EXT0..6 : Bidirectional - outputs from $4026.D0..D6 and inputs to $4033.D0..D6. (open-collector with 4.7K ohm pull-ups)
  - EXT1..2 are altered when $4025.D5 = 0 but its purpose is unknown.
- SOUND : Analog audio output, after the FDS audiois mixed in.

## References
- https://web.archive.org/web/20140920224500/green.ap.teacup.com/junker/119.html( PDF rehosted on forum)
- Forum thread: I2 ILine-PC

# FPA-PAL-S01 pinout

Source: https://www.nesdev.org/wiki/FPA-PAL-S01_pinout

FPA-PAL-S01 and FPA-92-S01 : 22-pin 0.4" PDIP ( Four Scoreand Famicom Four-Player Adapter)

Present in NES FOUR SCORE, both PAL and NTSC; and in HORI 4 PLAYERS ADAPTOR

```text
           .---v---.
 P2 CLK <- |01   22| -- +5V
 P2 D0  -> |02   21| <- /4P (LOW) or 2P (HIGH)
 P3 CLK <- |03   20| -> P1 CLK
 P3 D0  -> |04   19| <- P1 D0
 P4 CLK <- |05   18| -> P1,P2,P3,P4 STROBE (BUFFERED)
 P4 D0  -> |06   17| <- STROBE
TURBO B -> |07   16| -> $4016 D0
TURBO A -> |08   15| <- $4016 CLK
  XTAL1 -> |09   14| -> $4017 D0
  XTAL2 <- |10   13| <- $4017 CLK
    GND -- |11   12| <- SIGNATURE SELECT (*)
           `-------`

PIN 12 | $4016 reads 16-24  | $4017 reads 16-24
 GND   |       $10          |        $20
 +5V   |       $20          |        $10

```

Source: [1]

# Expansion port

Source: https://www.nesdev.org/wiki/Famicom_expansion_port_pinout

Both the NES and Famicom have expansion ports that allow peripheral devices to be connected to the system.

See also: Input devices

## Famicom

The Famicom has a 15-pin (male) port on the front edge of the console (officially known as the expand connector).

Because its two default controllers were not removable like the NES, peripheral deviceshad to be attached through this expansion port, rather than through a controller portas on the NES.

This was commonly used for third party controllers, usually as a substitute for the built-in controllers, but sometimes also as a 3rd and 4th player.

### Pinout

```text
       (top)    Famicom    (bottom)
               Male DA-15
                 /\
                |   \
joypad 2 /D0 ?? | 08  \
                |   15 | -- +5V
joypad 2 /D1 -> | 07   |
                |   14 | -> /OE for joypad 1 ($4016 read strobe)
joypad 2 /D2 -> | 06   |
                |   13 | <- joypad 1 /D1
joypad 2 /D3 -> | 05   |
                |   12 | -> OUT0 ($4016 write data, bit 0, strobe on pads)
joypad 2 /D4 -> | 04   |
                |   11 | -> OUT1 ($4016 write data, bit 1)
        /IRQ ?? | 03   |
                |   10 | -> OUT2 ($4016 write data, bit 2)
       SOUND <- | 02   |
                |   09 | -> /OE for joypad 2 ($4017 read strobe)
         Gnd -- | 01  /
                |   /
                 \/

```

### Signal descriptions
- Joypad 1 /D1 , Joypad 2 /D0-/D4 : Joypad data lines, which are inverted before reaching the CPU. Joypad 1 /D1 and joypad 2 /D1-/D4 are exclusively inputs, but on the RF Famicom, Twin Famicom, and Famicom Titler, joypad 2 /D0 is supplied by the permanently-connected player 2 controller, making it an output. In contrast, the AV Famicom features user-accessible controller ports and thus detachable controllers, allowing joypad 2 /D0 to potentially be an input. At least one expansion port device, the Multi Adapter AX-1, expects joypad 2 /D0 to be an output.
- Joypad 1 /OE , Joypad 2 /OE : Output enables, asserted when reading from $4016 for joypad 1 and $4017 for joypad 2. Joypads are permitted to send input values at any time and often use /OE just as a clock to advance a shift register. Internally, the console uses /OE to know when to put the joypad input onto the CPU data bus.
- OUT2-0 : Joypad outputs from the CPU matching the values written to $4016 D2-D0. These are updated every APU cycle (every 2 CPU cycles).
- /IRQ : The direction of this signal depends on the cartridge being used. Some cartridges use a push/pull /IRQ driver, which doesn't permit anything else to disagree, preventing input on this pin. Otherwise, it can be used as an input.
- SOUND : Analog audio output. In the RF Famicom, this is before expansion audio is mixed in. In the AV Famicom, it is after. It is possible to use this for audio input, but is inadvisable; there is no single way to mix in audio that is compatible with all consoles and all cartridges, and in most cases, the voltage must be carefully balanced to mix linearly with the signal output by the console's hex inverter.

## NES

The NES has a 48-pin card edge located on the underside of the NES, beneath a plastic tab which must be cut or broken to expose the connector. The connector is exceptionally thick (2.6mm), thicker than standard PCB thicknesses. The port containing the connector is slightly keyed in the front-side corners.

Because the NES had controller portson the front that allowed different devices to be plugged in, the expansion port was a kind of "back up plan" for Nintendo that was never used commercially.

### Pinout

```text
                              (back)       NES       (front)
                                        +-------\
                                 +5V -- |01   48| -- +5V
                                 Gnd -- |02   47| -- Gnd
                     Audio mix input -> |03   46| -- NC
                                /NMI <> |04   45| -> OUT2 ($4016 write data, bit 2)
                                 A15 <- |05   44| -> OUT1 ($4016 write data, bit 1)
                                EXP9 ?? |06   43| -> OUT0 ($4016 write data, bit 0, strobe on sticks)
                                EXP8 ?? |07   42| ?? EXP0
                                EXP7 ?? |08   41| ?? EXP1
                                EXP6 ?? |09   40| ?? EXP2
                                EXP5 ?? |10   39| ?? EXP3
($4017 read strobe) /OE for joypad 2 <- |11   38| ?? EXP4
                        joypad 1 /D1 -> |12   37| -> /OE for joypad 1 ($4016 read strobe)
                        joypad 1 /D3 xx |13   36| xx joypad 1 /D4
                                /IRQ <> |14   35| xx joypad 1 /D0
                        joypad 2 /D2 -> |15   34| -> duplicate of pin 37
                        joypad 2 /D3 xx |16   33| <- joypad 1 /D2
                 duplicate of pin 11 <- |17   32| <> CPU D0
                        joypad 2 /D4 xx |18   31| <> CPU D1
                        joypad 2 /D0 xx |19   30| <> CPU D2
                        joypad 2 /D1 -> |20   29| <> CPU D3
                           Video out <- |21   28| <> CPU D4
                     Amplified audio <- |22   27| <> CPU D5
       unregulated power adapter vdd -- |23   26| <> CPU D6
                     4.00MHz CIC CLK <- |24   25| <> CPU D7
                                        +-------/

```

### Signal notes
- All joypad input lines /D0-/D4 are logically inverted before reaching the CPU. A high signal will be read as a 0 and vice versa.
- xx in above pinout: Joypad 1 and 2 /D0, /D3, and /D4 are available as an input if no peripheral is connected to the corresponding joystick portthat uses those bits:
  - e.g. /D0 is unavailable if a Standard controlleror Four scoreis plugged in, and
  - /D3 and /D4 are unavailable if a Zapper, Arkanoid controller, or Power Padis plugged in.
- /NMI is open-collector.
- /IRQ depends on the cartridge—most ASICs seem to use a push-pull driver instead of relying on the pull-up resistor inside the console.
  - Because of this, a series 1kΩ resistor should be included to safely use the /IRQ signal in the expansion port.
  - This resistor is enough to logically overcome the internal 10kΩ pull-up, and will also limit any ASIC's output-high current to 5mA if your expansion device tries to drive it low at the same time.
- See EXP pinsfor notes about the ten EXP pins.
- See Standard controllerand Controller port pinoutfor more information about controller connections.

# Family Noraebang Karaoke pinout

Source: https://www.nesdev.org/wiki/Family_Noraebang_Karaoke_pinout

Family Noraebang Karaoke: 45 pin card expansion ( iNES 2.0 Mapper 515)

```text
            .------.
 CPU R/W <- |23  01| -- GND
     +5V -- |24  02| -- GND
 CPU A7  <- |25  03| -- GND
 CPU A12 <- |26  04|    NC
 CPU A5  <- |27  05| -- +5V
 CPU A6  <- |28  06| -> PRG A18
 CPU A3  <- |29  07| -- GND
 CPU A4  <- |30  08| -> PRG A17
 CPU A1  <- |31  09| -> PRG A20
 CPU A2  <- |32  10| -> PRG A16
 CPU D0  -> |33  11| -> PRG A19
 CPU A0  <- |34  12| -> PRG A15
 CPU D2  -> |35  13| -- VCC
 CPU D1  -> |36  14| -> CPU A13
    GND  -- |37  15| -> PRG A14
    GND  -- |38  16| -> CPU A9
 CPU D3  -> |39  17| -> CPU A8
    GND  -- |40  18| <- /IRQ
 CPU D5  -> |41  19| -> CPU A10
 CPU D4  -> |42  20| -> PRG A21
 CPU D7  -> |43  21| -> M2
 CPU D6  -> |44  22| -> CPU /ROMSEL
CPU A11  <- |45    |
            '------'
             ^   ^----- bottom side (this row is shifted by half of pin width)
             +--------- label side

```

Source: [1]

# French NES RGB output pinout

Source: https://www.nesdev.org/wiki/French_NES_RGB_output_pinout

Uniquely, the French NES contained a PAL-to-RGB conversion chip in the metal box and no RF nor composite output.

This is the view of the back of the console:

```text
            UP                DOWN
                  +-----\
Composite Sync <- | F  A | -> Mono audio
          Blue <- | G  B | -- Ground
         Green <- | H  C | -- Ground
           Red <- | I  D | -- Ground
SCART "SELECT" <- | J  E | -> SCART "STATUS"
                  +-----/

```

SCART pin 16 "Select" means the video is encoded as RGB. Here it's 5V via a 100Ω resistor.

SCART pin 8 "Status" high requests displaying the video from this connector. Here it's 12V via a half-wave rectifier, 1kΩ resistor, and shunt zener.

# GMNFC 01 pinout

Source: https://www.nesdev.org/wiki/GMNFC_01_pinout

```text
                                                  +-------+
                                          +5V -- / 001 128 \ -- GND
                                          M2 -> / 002   127 \ -- GND
                                    CPU A11 -> / 003     126 \ <- CIR /CS
                                   CPU A12 -> / 004       125 \ <- CIR A10
                                      GND -- / 005         124 \ <- PPU /RD
                           SLAVE CPU A13 <- / 006           123 \ -> SLAVE CIR A10
                                 CPU A9 -> / 007             122 \ <- PPU A13
                         SLAVE CPU A14 <- / 008               121 \ -> SLAVE PPU A13
                               CPU A8 -> / 009                 120 \ NC
                              CPU D7 <> / 010                   119 \ -> EPR /OE
                             CPU A7 -> / 011                     118 \ -> EPR A13
                            CPU D6 <> / 012                       117 \ <- PPU A10
                           CPU A6 -> / 013                         116 \ <- CPU A13
                          CPU D5 <> / 014                           115 \ <- CPU A14
                         CPU A5 -> / 015                             114 \ ??
                        CPU D4 <> / 016                               113 \ -- +5V
                          +5V -- / 017                                 112 \ ??
                     CPU A14 -> / 018                                   111 \ ??
                        GND -- / 019                                     110 \ ??
                    CPU D3 <> / 020                                       109 \ ??
                   CPU A3 -> / 021                                         108 \ <- /RESET
                  CPU D2 <> / 022                                           107 \ <> RAM D7
                        NC / 023                                             106 \ -- +5V
                CPU A2 -> / 024                                               105 \ NC
               CPU D1 <> / 025                                                 104 \ <> RAM D5
              CPU A1 -> / 026                                                   103 \ <> RAM D6
             CPU D0 <> / 027                                                     102 \ <> RAM D4
            CPU A0 -> / 028                                                       101 \ -- XTAL
SLAVE CPU /ROMSEL <- / 029                                                         100 \ -- GND
     CPU /ROMSEL -> / 030                                                           099 \ ??
        CPU R/W -> / 031                                                             098 \ -- GND
           GND -- / 032                           GMNFC 01                            097 \ -- GND
               ?? \ 033                            OKI                                096 / ??
                ?? \ 034                                                             095 / ??
   SLAVE PPU /RD <- \ 035                                                           094 / ??
    SLAVE CIR /CS <- \ 036                                                         093 / -- +5V
                   ?? \ 037                                                       092 / ??
                    ?? \ 038                                                     091 / -- GND
                     ?? \ 039                                                   090 / ??
                      ?? \ 040                                                 089 / ??
                       NC \ 041                                               088 / ??
                        ?? \ 042                                             087 / NC
                         ?? \ 043                                           086 / -- +5V
                          ?? \ 044                                         085 / ??
                           ?? \ 045                                       084 / -- GND
                            ?? \ 046                                     083 / ??
                             ?? \ 047                                   082 / ??
                              ?? \ 048                                 081 / ??
                           +5V -- \ 049                               080 / <> RAM D2
                                ?? \ 050                             079 / ??
                                 ?? \ 051                           078 / <> RAM D3
                                  ?? \ 052                         077 / -- GND
                                   ?? \ 053                       076 / <> RAM D0
                                    ?? \ 054                     075 / <> RAM D1
                                     ?? \ 055                   074 / -> LA04 / LA00
                                      NC \ 056                 073 / -> LA07 / LA12
                                       ?? \ 057               072 / -> LA03 / LA06
                                   ALE1 <- \ 058             071 / -> LA10 / LA08
                                 RAM /WE <- \ 059           070 / -> LA14
                                          ?? \ 060         069 / -> LA16 / LA13
                                      ALE2 <- \ 061       068 / -> LA15 / LA09
                                    RAM /OE <- \ 062     067 / -> LA05 / LA02
                                         GND -- \ 063   066 / -> LA01 / LA11
                                          GND -- \ 064 065 / -- +5V
                                                  +------+/

```

Source: [1]

# HT-2880 pinout

Source: https://www.nesdev.org/wiki/HT-2880_pinout

HT-2880 contains 8 pre-programmed audio samples and was used in Casel Zapper (only KEY1 was utilized, as rifle sound).

```text
          .---v---.
   GND -- |01   18| <> TEST3
   +5V -> |02   17| <> TEST2
 TEST1 <> |03   16| <- LEVEL HOLD
 AUDIO <- |04   15| -- OSC2 --[R=150k]-+
/AUDIO <- |05   14| -- OSC1 -----------+
  KEY8 -> |06   13| <- KEY1
  KEY7 -> |07   12| <- KEY2
  KEY6 -> |08   11| <- KEY3
  KEY5 -> |09   10| <- KEY4
          `-------`
           HT-2880

```

## References
- What's goin on with the Casel Zapper?– forums

# Hardware pinout

Source: https://www.nesdev.org/wiki/Hardware_pinout

This section groups all possible hardware pinoutsinto a single page.

### Accessories
- Nintendo's Famicom Disk System RP2C33chip
- Galoob's Game Genie galoobchip
- Game Action Replay's OKI GMNFC 01chip
- Controller Port
- Infrared Controllers'chips
- Joypad chips: UM6582
- Famicom 3D glasses: SHARP IX0043AE
- Nintendo's Four Score FPA-PAL-S01chip

### Connector
- Cartridge connector for the NES and Famicom
- NES Controller
- NES Expansion Port
- Famicom Expansion Port
- Konami QT adapter pinout
- Codemasters' Aladdin Deck Enhancer
- Bandai Datach
- Bandai Karaoke Studio
- Family Noraebang Karaoke
- Nantettatte!! Baseball
- FDS RAM Adapter
- FDS Expansion Port

### MMC
- Nintendo: MMC1, MMC2, MMC3, MMC4, MMC5, MMC6
- Camerica: BF9093, BF9096, BF9097, CME-01, CCU_v2.00 CF30288
- Irem: G-101, H3001, TAM-S1
- Konami: VRC1, VRC2 and VRC4, VRC3, VRC5, VRC6, VRC7
- Sunsoft: 1, 2, 3, 4, 5 and FME7, 6
- Namco: 108, 109, 118, 119, also Tengen 337001 and MIMIC-1, 129, 163, 175, and 340
- Taito: TC0190, TC0350, TC0690, X1-005, X1-017
- Bandai: FCG-1 and FCG-2, LZ93D50, M60001-0115P
- Sachen: SA8259A, “74LS374N”
- Kaiser: KS-201, KS 202, KS 203, KS 204
- Ntdec: NTDEC TC-112, NTDEC8801
- Yoko: PT8154, PT8159
- Tengen: 337006 / RAMBO-1
- Jaleco: SS 88006
- Huang: 1, 2
- Acclaim: Acclaim MC-ACC
- Hyundai: HY611ALP-10
- NTDEC: TC-112, 8801
- TXC: 05-00002-010
- Other: C5052-13, SPCN 2810, DIS23C01, SMD133 (AA6023), C5052, 8000M

### Micro Processors / Controllers
- 2A03 (NES/Famicom CPU)
- CIC lockout chip

### Audio chips
- HT-2880
- WR550400/WR550402
- UM5100
- M50805
- µPD7755C/µPD7756C
- YM2413
- WR550400/WR550402
- MPD7755C/µPD7756C

### Video Chips
- 2C02 (NES/Famicom PPU)
- UM6558 and UM6559
- NEC MK5060
- Sony V7021

### NES on a Chip
- UM6561
- UM6578
- SP-80
- UM6561A
- VT01
- VT02

### Logic ICs
- 4021latch used in controllers
- 7400 Series(e.g. 7486, 74139, 74161)
- BU2366/BU3270

### Memory
- 6264 SRAM Family, LH2833 custom FDS DRAM
- Mask ROMs, EPROMs, Special-purpose ROMs

### Misc
- KC5373B-010(CIC Stun)
- GMNFC 01

# Irem G-101 pinout

Source: https://www.nesdev.org/wiki/Irem_G-101_pinout

Irem G-101: 52-pin 0.6" high-density PDIP (canonically iNES Mapper 032)

```text
                 .--\/--.
          GND -- | 1  52| -- +5V
       (f) M2 -> | 2  51| -> CIRAM A10 (f)
      (f) R/W -> | 3  50| ??
  (f) /ROMSEL -> | 4  49| -> PRG /CE (r)
  (f) PPU A13 -> | 5  48| ??
  (f) PPU RD# -> | 6  47| ??
  (f) CPU A14 -> | 7  46| ??
  (f) CPU A13 -> | 8  45| -> CHR /OE (r)
 (fr) CPU A12 -> | 9  44| ??
  (fr) CPU A2 -> |10  43| -> (always high)
  (fr) CPU A1 -> |11  42| -> (always high)
  (fr) CPU A0 -> |12  41| -> PRG A17 (r)
  (f) PPU A12 -> |13  40| -> PRG A16 (r)
  (f) PPU A11 -> |14  39| -> PRG A15 (r)
  (f) PPU A10 -> |15  38| -> PRG A14 (r)
  (fr) CPU D7 -> |16  37| -> PRG A13 (r)
  (fr) CPU D6 -> |17  36| ??
  (fr) CPU D5 -> |18  35| -> CHR A17 (f)
  (fr) CPU D4 -> |19  34| -> CHR A16 (f)
  (fr) CPU D3 -> |20  33| -> CHR A15 (f)
  (fr) CPU D2 -> |21  32| -> CHR A14 (f)
  (fr) CPU D1 -> |22  31| -> CHR A13 (f)
  (fr) CPU D0 -> |23  30| -> CHR A12 (f)
            ? ?? |24  29| -> CHR A11 (f)
         mode -> |25  28| -> CHR A10 (f)
          GND -- |26  27| -- +5V
                 '------'

```
- mode tied to +5V: PRG banking mode selectable by software
- mode tied to gnd: PRG banking mode fixed to 8+8+16F (as in Major League )
- For the game Major League , CIRAM A10 is not connected to the G-101, and is instead simply tied to +5V

Reference: http://w.livedoor.jp/famicomcartridge/d/Irem%20G-101

# Irem H3001 pinout

Source: https://www.nesdev.org/wiki/Irem_H3001_pinout

Irem IF-H3001: 48-pin 0.6" DIP (canonically mapper 65)

```text
               .--\/--.
        n/c -- |01  48| -> +5V
        n/c -- |02  47| -> CHR A17
    PRG A18 <- |03  46| -> CHR-A16
    PRG A17 <- |04  45| -> CHR-A15
    PRG-A16 <- |05  44| -> CHR-A14
    PRG-A15 <- |06  43| -> CHR-A13
    PRG-A14 <- |07  42| -> CHR-A12
    PRG-A13 <- |08  41| -> CHR-A11
        GND -- |09  40| -> CHR-A10
         M2 -> |10  39| -- GND
    CPU-A14 -> |11  38| -> PRG RAM /CE
    CPU-A13 -> |12  37| -> /IRQ
    CPU-A12 -> |13  36| -> CIR-A10
    CPU-R/W -> |14  35| -> CHR-/CE
CPU-/ROMSEL -> |15  34| -> PRG-/CE
     CPU-A2 -> |16  33| -> delayed M2
     CPU-A1 -> |17  32| <- PPU-A12
     CPU-A0 -> |18  31| <- PPU-A11
    PPU-A13 -> |19  30| <- PPU-A10
    PPU-/RD -> |20  29| <- CPU-D7
     CPU-D2 -> |21  28| <- CPU-D6
     CPU-D1 -> |22  27| <- CPU-D5
     CPU-D0 -> |23  26| <- CPU-D4
        GND -- |24  25| <- CPU-D3
               '------'

```

References: [1]

# Irem TAM-S1 pinout

Source: https://www.nesdev.org/wiki/Irem_TAM-S1_pinout

Irem TAM-S1: 28-pin 0.3" PDIP (Canonically mapper 97)

```text
                     Irem's TAM-S1 IC
                        .---v---.
             PRG A18 <- |01   28| <- CPU A14 (f)
         (r) PRG A16 <- |02   27| -> PRG A17 (r)
         (r) PRG A15 <- |03   26| -> PRG A14 (r)
        (rf) PPU A10 -> |04   25| -> PRG /A17
        (rf) PPU A11 -> |05   24| -> CIRAM A10 (f)
    (Gnd) prgce mode -> |06   23| <- n/c
                 GND -- |07   22| <- n/c
             xor a14 -> |08   21| -- +5V
             (f) R/W -> |09   20| -> PRG /CE (r)
       (Gnd) data in -> |10   19| <- /ROMSEL (f)
            data out <Z |11   18| <- CPU D7 (rf)
         (rf) CPU D0 -> |12   17| <- CPU Dx  (+5v)
         (rf) CPU D1 -> |13   16| <- CPU D4  (Gnd)
         (rf) CPU D2 -> |14   15| <- CPU D3 (rf)
                        '-------'

```

Pins 6, 8, 22, and 23 all permit configuration of how the mapper works, but are inaccessible by default.

When the value latched by pin 17 is low, pin 11 is a copy of pin 10. When high, pin 11 is high-impedance. Together, these three pins could be modified to either extend PRG support to 1MB, or to allow one kind of 1-screen mirroring.

Tying pin 8 low instead yields the more standard UNROM-like memory layout with the fixed bank at higher addresses.

ROM is enabled during writes to the region where the bankswitching register isn't , much like the self-flashable versions of UNROM 512. The existing game, however, uses mask ROM and so cannot use this functionality.
- Source: Krzysiobal

# Jaleco SS 88006 pinout

Source: https://www.nesdev.org/wiki/Jaleco_SS_88006_pinout

Jaleco SS 88006: 42-pin 0.6" shrink DIP (Canonically mapper 18)

```text
                  SS 88006
                 .---\/---.
       (f) M2 -> |01    42| -- VCC
(frw) CPU A12 -> |02    41| -> PRG RAM +CE (w)
  (f) CPU A13 -> |03    40| -> PRG RAM /CE (w) (Also shorted to RAM /OE)
  (f) CPU A14 -> |04    39| -> PRG RAM /WE (w)
  (r) PRG /CE <- |05    38| -> µPD775x /RESET
  (r) PRG A15 <- |06    37| -> µPD775x /START
  (r) PRG A14 <- |07    36| -> CIRAM A10 (f)
  (r) PRG A13 <- |08    35| <- OR B (PPU /RD)
  (r) PRG A16 <- |09    34| -> CHR A17 (r)
  (r) PRG A17 <- |10    33| -> CHR A10 (r)
  (r) PRG A18 <- |11    32| -> CHR A16 (r)
 (frw) CPU A1 -> |12    31| -> CHR A11 (r)
 (frw) CPU A0 -> |13    30| -> CHR A13 (r)
 (frw) CPU D0 -> |14    29| -> CHR A12 (r)
 (frw) CPU D1 -> |15    28| -> CHR A14 (r)
 (frw) CPU D2 -> |16    27| -> CHR A15 (r)
 (frw) CPU D3 -> |17    26| -> OR Y (unused)
      (f) R/W -> |18    25| <- OR A (PPU A13)
  (f) /ROMSEL -> |19    24| <- PPU A12 (f)
     (f) /IRQ <- |20    23| <- PPU A11 (f)
          GND -- |21    22| <- PPU A10 (f)
                 '--------'

```

The integral OR gate on pin 26, intended for use with a 28-pin 128KiB CHR-ROM, seems to be too slow. [1]To support a 28-pin 128KiB CHR-ROM, some PCBs include an external 7432.

The associated ADPCM IC is wired as:

```text
           µPD7755/6C
                __  __
(I4) PRG D6 -> |01\/18| <- PRG D5 (I3)
(I5) PRG D7 -> |02  17| <- PRG D4 (I2)
   (I6) GND -> |03  16| <- PRG D3 (I1)
   (I7) GND -> |04  15| <- PRG D2 (I0)
(volume) R2 -> |05  14| <- /START
  sound out <- |06  13| <- /CS (Always connected to GND)
     (BUSY) <- |07  12| <- X1
     /RESET -> |08  11| -> X2
        GND -- |09  10| -- VCC
               '------'

```

For games that use the ADPCM IC, it's wired as:

```text
                150                (µPD775X.6)
      +5V------/\/\/------+------- AVO
                          |
From 2A03------/\/\/------+------- To RF
(Cart.45)       330                (Cart.46)

                 1K
      +5V------/\/\/------ REF (µPD775X.7)

```

Most PCBs (JF-24, -25, -29, and -37 without RAM; JF-27 and -40 with RAM and without ADPCM) have jumpers to configure operation:
- 0 ohm through-hole jumpers on the component side:
  - J1 connects CHR ROM /CE = pin 20 of 28 = pin 22 of 32 to PPU A13.
  - J2 connects the same pin to the output of the OR gate.
- Cut-and-solder jumpers on the solder side:
  - J3 connects SS 88006 pin 19 to card edge /ROMSEL
  - J4 connects the same pin to the delayed copy of the same signal generated by the 7432.
  - J5 connects SS 88006 pin 1 to card edge M2
  - J6 connects the same pin to the delayed copy of the same signal generated by the 7432.

JF-23 does not have any jumpers; it is always wired as though J2, J3, and J5 were shorted.

No PCBs have been seen with J4 or J6 enabled, not even on boards that could support it.

Jaleco's 32-pin CHR ROMs are neither a JEDEC-standard pinout, nor the same as Nintendo's proprietary 32-pin CHR ROMs. Like Nintendo, pin 24 remained A16, and pin 2 became PPU /RD. However, on JF-29, JF-37, and JF-40, A17 is instead on pin 30, and other PCBs don't have a trace for A17 at all.

Source: [2]

# KC5373B-010 pinout

Source: https://www.nesdev.org/wiki/KC5373B-010_pinout

```text
              .--v--.
CIC-TO-PAK -> |01 16| (*)
    PPU-A0 -> |02 15| --[C]-> CIC-TO-MB
       VCC -- |03 14| <- \___ one of those pins connects to CIC-CLK
       VCC -- |04 13| <- /
       GND -- |05 12| -- VCC
          +-- |06 11| --+
          +-- |07 10| --+
          +-- |08 09| --+
          |   '-----'   |
          +-------------+--[charge pump] -> CIC-RST

```

```text
*Pin 16 is either tied to pin 15 or left floating, depending on the board

```

This chip was found in many NES NTDEC games and acted like CIC stun [1], [2]

It's exact behviour is unknown, but PPU-A0 is probably a source of high frequency signal, whose current is amplified and available on pins 6-11. Next, going through charge pump, a negative voltage of around -4V is produced which disables NES' internal CIC.

The role of other signals (CIC-TO-PAK, CIC-TO-MB, CIC-CLK) is open question.

# KS-201 pinout

Source: https://www.nesdev.org/wiki/KS-201_pinout

National Semiconductor KS-201: 28-pin DIP (Canonically NES 2.0 Mapper 554)

```text
           .-\_/-.
 CPU M2 -> |01 28| -- +5V
 CPU A1 -> |02 27| -> PRG A13
 CPU A2 -> |03 26| -> PRG A14
 CPU A3 -> |04 25| -> PRG A15
 CPU A4 -> |05 24| -> PRG A16
 CPU A5 -> |06 23| -> CHR A13
 CPU A6 -> |07 22| -> CHR A14
 CPU A7 -> |08 21| -> CHR A15
 CPU A8 -> |09 20| -> CHR A16
 CPU A9 -> |10 19| -> PRG /CE
CPU A10 -> |11 18| <- unknown input (VCC)
CPU A11 -> |12 17| <- CPU /ROMSEL
CPU A12 -> |13 16| <- CPU A14
    GND -- |14 15| <- CPU A13
           '-----'

```

This was also used on NES 2.0 Mapper 312:

```text
           .-\_/-.
 CPU M2 -> |01 28| -- +5V
 CPU A1 -> |02 27| -> PRG /A14
 CPU A2 -> |03 26| -> PRG A15
 CPU A3 -> |04 25| -> PRG A16
 CPU A4 -> |05 24| -> n/c
 CPU A5 -> |06 23| -> n/c
 CPU A6 -> |07 22| -> n/c
 CPU A7 -> |08 21| -> n/c
 CPU A8 -> |09 20| -> n/c
 CPU A9 -> |10 19| -> n/c
CPU A10 -> |11 18| <- unknown input (VCC)
CPU A11 -> |12 17| <- CPU /A14
    n/c -> |13 16| <- CPU /ROMSEL
    GND -- |14 15| <- CPU A13
           '-----'

```

# VRC3 pinout

Source: https://www.nesdev.org/wiki/KS_202_pinout

VRC3: 18-pin PDIP ( mapper 73 )

```text
r: connects to PRG ROM
f: connects to Famicom
w: connects to PRG RAM
                 .-\_/-.
  (r) PRG A16 <- |01 18| -- +5V
  (r) PRG /CE <- |02 17| -> WRAM /CE (w)
  (r) PRG A14 <- |03 16| <- R/W      (wfr)
  (r) PRG A15 <- |04 15| <- CPU D3   (wfr)
  (f)      M2 -> |05 14| <- CPU D0   (wfr)
(wfr) CPU A12 -> |06 13| <- CPU D1   (wfr)
 (rf) CPU A13 -> |07 12| <- CPU D2   (wfr)
  (f) CPU A14 -> |08 11| <- /ROMSEL  (f)
          Gnd -- |09 10| -> /IRQ     (f)
                 '-----'

```

Kaiser seems to have made a subtle upgrade of the VRC3:

National Semiconductor KS202: 20-pin PDIP (canonically iNES Mapper 142)

```text
                 .-\_/-.
(wfr) CPU A12 -> |01 20| -> WRAM /CE (w)
  (f) CPU A13 -> |02 19| <- CPU D3   (wfr)
  (f) CPU A14 -> |03 18| <- R/W      (wfr)
          +5V -- |04 17| <- CPU D0   (wfr)
  (f)      M2 -> |05 16| <- CPU D1   (wfr)
  (r) PRG A14 <- |06 15| <- CPU D2   (wfr)
  (r) PRG A13 <- |07 14| -- GND
  (r) PRG A15 <- |08 13| <- RESET
  (r) PRG A16 <- |09 12| <- /ROMSEL  (f)
  (r) PRG /CE <- |10 11| -> /IRQ     (f)
                 '-----'

```

Source: [1]

# MMC1 pinout

Source: https://www.nesdev.org/wiki/KS_203_pinout

MMC1: 24 pin shrink-DIP (most common mapper 1 ; variants as mappers 105and 155)

Comes in several varieties: 'MMC1', 'MMC1A', and 'MMC1B2'

```text
                .--\/--.
 PRG A14 (r) <- |01  24| -- +5V
 PRG A15 (r) <- |02  23| <- M2 (n)
 PRG A16 (r) <- |03  22| <- CPU A13 (nr)
 PRG A17 (r) <- |04  21| <- CPU A14 (n)
 PRG /CE (r) <- |05  20| <- /ROMSEL (n)
WRAM +CE (w) <- |06  19| <- CPU D7 (nrw)
 CHR A12 (r) <- |07  18| <- CPU D0 (nrw)
 CHR A13 (r) <- |08  17| <- CPU R/W (nw)
 CHR A14 (r) <- |09  16| -> CIRAM A10 (n)
 CHR A15 (r) <- |10  15| <- PPU A12 (nr)
 CHR A16 (r) <- |11  14| <- PPU A11 (nr)
         GND -- |12  13| <- PPU A10 (nr)
                `------'

```

Pinout legend

```text
    -- |  power supply   | --
    <- |     output      | ->
    -> |      input      | <-
    <> |  bidirectional  | <>
    ?? |   unknown use   | ??

n or f - connects to NES or Famicom
 r - connects to ROMs (PRG ROM, CHR ROM, CHR RAM)
 w - connects to WRAM (PRG RAM)
?? - could be an input, no connection, or a supply line

```

## Functional variations

As with several other ASIC mappers, parts of the pinout are often repurposed:

### SEROM, SHROM, SH1ROM

Doesn't support PRG banking

```text
                .--\/--.
         n/c <- |01  24| -- +5V
         n/c <- |02  23| <- M2 (n)
         n/c <- |03  22| <- CPU A13 (nr)
         n/c <- |04  21| <- CPU A14 (n)

       CPU A14 (n) -> PRG A14 (r)

```

### SNROM

Uses CHR A13-A16 as a PRG-RAM disable

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
          n/c <- |10  15| <- PPU A12 (n)
 WRAM /CE (w) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

### SOROM

Uses CHR A13-A16 as PRG-RAM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
 WRAM A13 (w) <- |10  15| <- PPU A12 (n)
          n/c <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SOROM is actually implemented using the WRAMs' /CE inputs and an inverter to select only one RAM at a time.

### SUROM

Uses CHR A13-A16 as PRG-ROM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
          n/c <- |10  15| <- PPU A12 (n)
  PRG A18 (r) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

### SXROM

Uses CHR A13-A16 as PRG-ROM and PRG-RAM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
 WRAM A13 (w) <- |09  16| -> CIRAM A10 (n)
 WRAM A14 (w) <- |10  15| <- PPU A12 (n)
  PRG A18 (r) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SXROM uses an external inverter to convert the MMC1's WRAM +CE to the 62256's -CE input

### EVENT

Uses CHR A13-A16 as more complicated PRG-ROM banking and timer control, also disables CHR RAM banking

```text
         n/c <- |07  18| <- CPU D0 (nrw)
    PRG2 A15 <- |08  17| <- CPU R/W (nw)
    PRG2 A16 <- |09  16| -> CIRAM A10 (n)
     PRG SEL <- |10  15| <- PPU A12 (n)
 TIMER RESET <- |11  14| <- PPU A11 (nr)
         GND -- |12  13| <- PPU A10 (nr)
                `------'

```

Since the PPU A12 input's only purpose is to switch the CHR A12 .. A16 outputs, it's not clear why Nintendo didn't tie the MMC1's PPU A12 input low and connect CHR A12 directly to PPU A12. Doing so would have cost nothing (the ability to swap the two nametables is already granted through PPUCTRL), would have prevented mistakes (unless the same value is in both CHR registers, 4KB mode causes erratic switching of bank during rendering), and would have freed up another bit of control.

### SZROM

Uses CHR A16 as PRG-RAM banking

```text
      CHR A15 <- |10  15| <- PPU A12 (n)
 WRAM A13 (w) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SZROM permits both CHR ROM banking and 16KB of WRAM at the same time. Like SOROM, it's implemented using the WRAMs' /CE inputs and an inverter to select only one RAM at a time.

### 2ME

Uses CIRAM A10 and CHR A12, A13, A16 for EEPROM access and CHR A14, A15, and A16 for PRG-RAM access

```text
            $6000-7FFF +EN (we) <- |06  19| <- Card D7 (nrw)
                  EEPROM DI (e) <- |07  18| <- Card D0 (nrwe)
                 EEPROM CLK (e) <- |08  17| <- Card R/W (nw)
                PRG-RAM A13 (w) <- |09  16| -> EEPROM CS (e)
                PRG-RAM A14 (w) <- |10  15| <- GND (PPU A12)
EEPROM DO +OE, PRG-RAM /CE (we) <- |11  14| <- GND (PPU A11)
                            GND -- |12  13| <- GND (PPU A10)
                                   `------'

```

The data bus here is the Famicom Network System's card data bus, not the CPU data bus. Because the board is not on the PPU bus, the PPU address inputs are grounded, preventing the CHR bank 1 register from being used.

## Pirate clones

There exist pirate clones:
- AX5904 - pinout is same as official MMC1
- KS5361 - pinout unknown [1]
- KS 203- Kaiser clone:

```text
              .--\/--.
   PRG A17 <- |01  24| <- PPU A10
   PRG A16 <- |02  23| <- PPU A11
   PRG A15 <- |03  22| <- PPU A12
   PRG A14 <- |04  21| <- CPU A13
       VCC -- |05  20| <- CPU A14
   PRG /CE <- |06  19| <- /ROMSEL
   CHR A12 <- |07  18| <- RESET
   CHR A13 <- |08  17| -- GND
    CPU D7 -> |09  16| <- M2
    CPU D0 -> |10  15| <- CPU R/W
   CHR A16 <- |11  14| -> CHR A15
   CIR A10 <- |12  13| -> CHR A14
              `------'
               KS 203

```

# Namcot 108 family pinout

Source: https://www.nesdev.org/wiki/KS_204_pinout

Namcot 108, 109, 118, 119: 28-pin shrink PDIP, also Tengen 337001 or MIMIC-1: 28-pin 0.6" PDIP (Canonically mapper 206).

```text
               .--\/--.
(f) CPU A14 -> |01  28| -> PRG A15 (r)
(fr) CPU A0 -> |02  27| -> PRG A14 (r)
(fr) CPU D5 -> |03  26| <- M2 (f)
(fr) CPU D0 -> |04  25| -> PRG A13 (r)
(fr) CPU D4 -> |05  24| <- CPU A13 (f)
(fr) CPU D1 -> |06  23| -> PRG A16 (r)
        Gnd -- |07  22| -> PRG /CE (r)
(fr) CPU D3 -> |08  21| -- +5V
(fr) CPU D2 -> |09  20| -> CHR A13 (r)
(f) /ROMSEL*-> |10  19| -> CHR A11 (r)
    (f) R/W -> |11  18| -> CHR A10 (r)
(r) CHR A15 <- |12  17| <- PPU A10 (f)
(r) CHR A14 <- |13  16| <- PPU A11 (f)
(r) CHR A12 <- |14  15| <- PPU A12 (f)
               `------'

10: on the Vs. System daughterboards, this is instead CPU /A15

```

No behavioral differences are known between the five different part numbers; severalgameswere released on the same board with identical code and different mapper ICs.

## Functional Variations

Many boards (and thus iNES mappers) redefined parts of the pinout for various extensions, mostly to increase the amount of addressable CHR ROM.

#### 3446

Mapper 76: Rewires CHR banking to be able to address more total CHR with coarser CHR banks.

```text
(fr) CPU D2 -> |09  20| -> CHR A14 (r)
(f) /ROMSEL -> |10  19| -> CHR A12 (r)
    (f) R/W -> |11  18| -> CHR A11 (r)
(r) CHR A16 <- |12  17| <- PPU A11 (f)
(r) CHR A15 <- |13  16| <- PPU A12 (f)
(r) CHR A13 <- |14  15| <- +5V
               `------'

      (f) PPU A10 -> CHR A10 (r)

```

#### 3433, 3443, 3453

Mappers 88and 154connect (f) PPU A12 -> CHR A16 (r), skipping the mapper IC altogether.

#### 3425

Mapper 95: Repurposes CHR A15 to control nametable banking

```text
(f) CIRAM A10 <- |12  17| <- PPU A10 (f)
  (r) CHR A14 <- |13  16| <- PPU A11 (f)
  (r) CHR A12 <- |14  15| <- PPU A12 (f)
                 `------'

```

## Pirate clones

AX-24G, NTDEC8701, NCT1024: 28-pin 0.6" PDIP

```text
               .--\/--.                                 .--\/--.
(r) PRG A13 <- |01  28| <- CPU A14 (f)            M2 -> |01  28| -- +5V
(r) PRG A14 <- |02  27| <- CPU A13 (f)           R/W -> |02  27| <- RESET
(r) PRG A16 <- |03  26| <- CPU A0 (fr) MODE/CPU A14* -> |03  26| <- CPU D3*
(r) PRG A15 <- |04  25| -- VCC              CPU A13* -> |04  25| -> CHR A15
(r) CHR A14 <- |05  24| <- /ROMSEL (f)       CPU D1* -> |05  24| -> CHR A14
(r) CHR A11 <- |06  23| -> PRG /OE (r)       CPU D0* -> |06  23| -> CHR A13
(r) CHR A13 <- |07  22| <- M2 (f)            /ROMSEL -> |07  22| -> CHR A12
(r) CHR A12 <- |08  21| <- R/W (f)           CPU D4* -> |08  21| -> CHR A11
(fr) CPU D2 -> |09  20| <- CPU-D0 (fr)        CPU A0 -> |09  20| -> CHR A10
(fr) CPU D3 -> |10  19| <- CPU-D5 (fr)       PRG A16 <- |10  19| <- CPU D5*
(fr) CPU D1 -> |11  18| <- CPU-D4 (fr)       PRG A15 <- |11  18| <- PPU A12
        Gnd -- |12  17| <- PPU-A12 (f)       PRG A14 <- |12  17| <- PPU A11
(r) CHR A15 <- |13  16| <- PPU-A11 (f)       PRG A13 <- |13  16| <- PPU A10
(r) CHR A10 <- |14  15| <- PPU-A10 (f)           GND -- |14  15| <- CPU D2*
               `------'                                 `------'
       AX-24G, NTDEC8701, AX5604P                        KS 204

               .-----v----.
     CPU D2 -> | 01    28 | -- VCC
     CPU D1 -> | 02    27 | <- CPU D3
     CPU D0 -> | 03    26 | <- CPU D4
     CPU M2 -> | 04    25 | <- CPU D5
CPU /ROMSEL -> | 05    24 | <- PPU A11
     CPU A0 -> | 06    23 | <- PPU A12
    CPU R/W -> | 07    22 | <- PPU A10
    CHR A10 <- | 08    21 | -> CHR A13
    CHR A11 <- | 09    20 | -> CHR A14
    CHR A12 <- | 10    19 | -> CHR A15
    CHR A13 <- | 11    18 | <- CPU A14
    PRG A13 <- | 12    17 | -> PRG A17
    PRG A14 <- | 13    16 | -> PRG A16
        GND -- | 14    15 | -> PRG A15
               `----------`
                 NCT1024 [1]

```

KS204:
- MODE: If pin 3 is low on a falling edge of RESET, it operates in N108 mode. If it's high, or before the first falling edge of RESET, it operates in VRC2 mode. [2]
- Pins marked with * change behavior in VRC2 mode

### Functional variations

#### KS7037

Mapper 307(UNIF "KS7037"): repurpose CHR banking for nametable control. Moves second switchable bank.

```text
             .--\/--.
       M2 -> |01  28| -- +5V
      R/W -> |02  27| <- RESET
  CPU A13 -> |03  26| <- CPU D3
  CPU A14 -> |04  25| -> n/c
   CPU D1 -> |05  24| -> n/c
   CPU D0 -> |06  23| -> n/c
  /ROMSEL -> |07  22| -> n/c
   CPU D4 -> |08  21| -> n/c
   CPU A0 -> |09  20| -> CIRAM A10
 PRG A16* <- |10  19| <- CPU D5
  PRG A15 <- |11  18| <- +5V
  PRG A14 <- |12  17| <- PPU A11
  PRG A13 <- |13  16| <- PPU A10
      GND -- |14  15| <- CPU D2
             `------'
              KS 204

```

External hardware further modifies the exact memory map.

#### Sachen 3009

Redundant variation of mapper 133: obfuscatory GNROM-style banking.

```text
               .--\/--.
        n/c <- |01  28| <- CPU A14 (f)
        n/c <- |02  27| <- CPU A13 (f)
        n/c <- |03  26| <- CPU A0 (fr)
        n/c <- |04  25| -- VCC
 feedback#1 <- |05  24| <- /ROMSEL (f)
(r) PRG A15 <- |06  23| -> PRG /OE (r)
(r) CHR A14 <- |07  22| <- M2 (f)
(r) CHR A13 <- |08  21| <- R/W (f)
(fr) CPU D0 -> |09  20| <- CPU D3 (fr)
(fr) CPU D1 -> |10  19| <- CPU D4 (fr)
(fr) CPU D2 -> |11  18| <- CPU D5 (fr)
        Gnd -- |12  17| <- Vcc
 feedback#2 <- |13  16| <- feedback#2
        n/c <- |14  15| <- feedback#1
               `------'
                AX-24G

```

## Sources
- AX-24G or NTDEC8701 [ BBS]
- KS 204 [ BBS]

# Konami QT adapter pinout

Source: https://www.nesdev.org/wiki/Konami_QT_adapter_pinout

```text
                    +-----+
             GND -- |01 21| -- VCC
          CPU A6 -> |02 22| <- CPU A8
         CPU A11 -> |03 23| <- CPU A9
          CPU A4 -> |04 24| <- CPU A5
          CPU A3 -> |05 25| <- CPU A10
          CPU A2 -> |06 26| <> CPU D7
         CPU A12 -> |07 27| <- CPU A7
          CPU D6 <> |08 28| <- CPU R/W
          CPU D5 <> |09 29| <- CPU A1
          CPU D4 <> |10 30| <- CPU A0
             GND -- |11 31| -- GND
          CPU D3 <> |12 32| <> CPU D0
          CPU D2 <> |13 33| <> CPU D1
         PRG A13 -> |14 34| <- PRG A14
         PRG A15 -> |15 35| <- PRG A16
EXT PRG ROM0 /CE -> |16 36| <- PRG A17
EXT PRG ROM1 /CE -> |17 37| <- EXT PRG ROM2 /CE
                  ? |18 38| <- PRG RAM A12
EXT PRG RAM /CE  -- |19 39| ?
             VCC -- |20 40| -- VCC
                    +-----+

```

Notes:
- Pins 1-20 are on label side

Source:
- BBS

# LH2833 pinout

Source: https://www.nesdev.org/wiki/LH2833_pinout

LH2833: custom DRAM chip 28-pin 0.6" DIP

```text
                          .---\/---.
(tied to CPU M2) +CS1? -> | 01  28 | -- +5V
                  /RAS -> | 02  27 | <- +CS2? (tied to CPU A13)
                PRG A0 -> | 03  26 | <- +CS3? (tied to CPU A14)
            PRG A3/A10 -> | 04  25 | <- +CS4? (tied to CPU /ROMSEL)
            PRG A2/A9  -> | 05  24 | <- PRG A4/A11
            PRG A1/A8  -> | 06  23 | <- PRG A5/A12
                CPU A7 -> | 07  22 | <- PRG A6/A13
                /CAS0  -> | 08  21 | <- R/W
                /CAS1  <- | 09  20 | <- /CS? (tied to GND)
                          | 10  19 | <> CPU D4
                CPU D5 <> | 11  18 | <> CPU D3
                CPU D6 <> | 12  17 | <> CPU D2
                CPU D7 <> | 13  16 | <> CPU D1
                   GND -- | 14  15 | <> CPU D0
                          '--------'

Chip is enabled for $6000-$DFFF, so pins 1, 25, 26, 27 must be
internally used as address inputs to chip enable:

CPU M2 | /ROMSEL | A14 | A13 || Enabled?
   1   |    1    |  1  |  1  ||    Y
   x   |    0    |  0  |  0  ||    Y
   x   |    0    |  0  |  1  ||    Y
   x   |    0    |  1  |  0  ||    Y

```

# M50805 pinout

Source: https://www.nesdev.org/wiki/M50805_pinout

Mitsubishi M50805: 22-pin 0.4" PDIP (Used in onemapper 3game)

```text
                 .--\/--.
           NC -- |01  22| -- NC
           NC -- |02  21| -- NC
           NC -- |03  20| -- NC
    DREQ/TEST <- |04  19| <- /D0
  MODE \  MS1 -> |05  18| <- /D1
SELECT /  MS0 -> |06  17| <- /D2,DTIN
         XOUT <- |07  16| -> BUSY
          XIN -> |08  15| <- /SYNC
          /CE -> |09  14| -> DA1 \ DA
       /RESET -> |10  13| -> DA0 / OUTPUT
          +5V -- |11  12| -- GND
                 '------'

```

Sources: [1], [2]

The die shotshows that pins 1-3 and 20-22 are genuinely no connection - there's nothing to be wire bonded to.

# MC-ACC pinout

Source: https://www.nesdev.org/wiki/MC-ACC_pinout

MC-ACCchip: (40-pin 0.6" DIP)

```text
               .--\/--.
        GND ?? |01  40| -- 5V
(r) PRG A16 <- |02  39| -> PRG A18 (r)
(r) PRG A15 <- |03  38| -> PRG A17 (r)
(n) CPU A14 -> |04  37| -> PRG A14 (r)
(n) CPU A13 -> |05  36| -> PRG A13 (r)
        n/c ?? |06  35| <- CPU R/W (n)
        n/c ?? |07  34| <- /ROMSEL (n)
        n/c ?? |08  33| -> PRG /OE (r)
(nr) CPU A0 -> |09  32| <- CPU D7 (nr)
(nr) CPU D0 -> |10  31| <- CPU D6 (nr)
(nr) CPU D1 -> |11  30| <- CPU D5 (nr)
(nr) CPU D2 -> |12  29| <- CPU D4 (nr)
(r) CHR A16 <- |13  28| <- CPU D3 (nr)
(r) CHR A15 <- |14  27| -> CIRAM A10 (n)
(r) CHR A14 <- |15  26| -> CHR A17 (r)
(r) CHR A13 <- |16  25| -> /IRQ (n)
(r) CHR A12 <- |17  24| <- PPU A12 (n)
(r) CHR A11 <- |18  23| <- PPU A11 (n)
(r) CHR A10 <- |19  22| <- PPU A10 (n)
        GND -- |20  21| <- M2 (n)
               '------'

39: confirmed in [1]
24: on the 55741 PCB, deglitched and shaped as MCACCA12IN = AND(PPUA12,AND(AND(AND(PPUA12)))). Kevtris's notes

```

Source: https://forums.nesdev.org/viewtopic.php?p=16795#p16795

# MK5060 pinout

Source: https://www.nesdev.org/wiki/MK5060_pinout

This chip was used at least in Micro Genius IQ-201 (MK5060) [1]and an aftermarket mod board for the PC Engine (NEC MK5060-A) [2]. Its role was to halt the PPU for 3.3 ms at the end of frame (but before the VBLANK). This was achieved by disabling the PPU's primary clock for that time. That way, frame period (NMI frequency) was extended from 16.7 ms (60 Hz) to 20 ms (50 Hz), slowing down the game and audio speed, but keeping PPU/CPU clock ratio and thus saving NTSC compatibility intact.

External components are used to extract from the composite video signal frame and scanline start pulses, which are used to clock the internal counter. At the last render scanline, chip puts PPU into sleep mode, which lasts 3.3ms. MK5060 also watches the PPU/CE line, probably in case if CPU requested to read/write from PPU at the time it is put into sleep, it would be immediately woken up. Additionally, if PPU rendering is disabled during frame, it fools MK5060.

Early Hong Kong Famicoms (HVC-CPU-NPC-18-01) use the MK5060, but later ones (HVC-CPU-NPC-26-01) use a different, Nintendo-branded chip (20-pin N NPC26) that serves a similar purpose.

```text
                                       .--\/--.
high during frame sync & back porch ?? |01  24| -- +5V
                               GND  -- |02  23| ?? wired to pin 1
                                NC  ?? |03  22| -- GND
               colorbust shift 240* <- |04  21| <- saturation input?
               colorbust shift 120* <- |05  20| -- +5V
               colorbust shift 0*   <- |06  19| -> \ 21.x MHZ clock  to PPU
        21.x MHz clock from famicom -> |07  18| -> /
         high during frame sync     <- |08  17| -> 4.43365 MHz clock output
          low during frame sync     <- |09  16| <- 17.7345 MHz clock input
                         PPU /CE    -> |10  15| <- hue input? (?)
                60Hz (H) / 50Hz (L) -> |11  14| <- scanline sync pulse (?)
                                GND -- |12  13| -- +5V
                                       '------'

```

# Mask ROM pinout

Source: https://www.nesdev.org/wiki/Mask_ROM_pinout

## 8kB / 16kB / 32kB / 64kBytes (28pin) ROMs

Nintendo used by default JEDEC standard compatible pinouts for all their mask ROMs of 64 kBytes and below (but some particular boards might be exceptions !). Names [in brackets] applies when the corresponding address pin is unused. On boards where an adress pin is never used (for example, A15 is never used on NROMboards as the ROM can't be greater than 32k), what is in brackets connects to the unused pin.

```text
  27C64/128/256/512 EPROM pinout

              ---_---
 [+5V] A15 - |01   28| - +5V
       A12 - |02   27| - A14 [PGM]
       A7  - |03   26| - A13 [NC]
       A6  - |04   25| - A8
       A5  - |05   24| - A9
       A4  - |06   23| - A11
       A3  - |07   22| - /OE
       A2  - |08   21| - A10
       A1  - |09   20| - /CE
       A0  - |10   19| - D7
       D0  - |11   18| - D6
       D1  - |12   17| - D5
       D2  - |13   16| - D4
       GND - |14   15| - D3
              -------

```

## 128/256/512 KBytes (28/32pin) ROMs

Nintendo used the standard pinout for (extremely rare) prototype boards intended to take a 27C010/020/040 EPROM. But retail Game Paks made by Nintendo have mask ROMs with a different pinout which is not compatible. This pinout, with reshuffled enable lines and higher address lines, allows a 32-pin hole to take a 28-pin 128 KiB PRG ROM in pin 3 to pin 30.

For games using 256 KiB and larger ROMs, other companies producing Famicom or NES boards used either epoxy blobs or standard EPROM pinout. But games with 128 KiB of PRG were more often in a 28-pin package than not.

On Nintendo's boards where PRG A18 is never used, pin 2 is connected with pin 22.

Nintendo's MMC5 boards use the same pinout for both PRG and CHR ROMs, and even 128 KB PRG ROMs are 32-pin so they can have a VCC pin.

```text
        CHR ROM, PRG ROM, and 27C010/020/040/080 EPROM pinouts compared

 MMC5    CHR        PRG      EPROM                   EPROM        PRG   CHR   MMC5
                                         ---_---
 A17    A17 [+5V]  A17      [VPP] A19 - |01   32| - +5V
 A18    /OE        A18 [/CE]      A16 - |02   31| - A18 [PGM]    +5V    /CE2   /CE2
                                  A15 - |03   30| - A17 [NC]     +5V    +5V    A19
                                  A12 - |04   29| - A14
                                  A7  - |05   28| - A13
                                  A6  - |06   27| - A8
                                  A5  - |07   26| - A9
                                  A4  - |08   25| - A11
                                  A3  - |09   24| - /OE          A16    A16    A16
                                  A2  - |10   23| - A10
                                  A1  - |11   22| - /CE          /CE    GND    /CE
                                  A0  - |12   21| - D7
                                  D0  - |13   20| - D6
                                  D1  - |14   19| - D5
                                  D2  - |15   18| - D4
                                  GND - |16   17| - D3
                                         -------

PRG and CHR pins are listed only if they differ from EPROM.

```

## Variants

Here is a list of multiple variants of Nintendo's pinouts above. Only a couple of enable pins typically differs (which are shown in bold).

### Nintendo RROM CHR ROM pinout - 8 KBytes (28pin)

This particular board is functionally identical to NROM but with a strange CHR pinout :

```text
  RROM Non-standard 64-kbit CHR pinout
             ---_---
      A7  - |01   28| - +5V
      A6  - |02   27| - A8
      A5  - |03   26| - A9
      A4  - |04   25| - A12
      A3  - |05   24| - /CE
      +5V - |06   23| - NC
      +5V - |07   22| - /OE
      A2  - |08   21| - A10
      A1  - |09   20| - A11
      A0  - |10   19| - D7
      D0  - |11   18| - D6
      D1  - |12   17| - D5
      D2  - |13   16| - D4
      GND - |14   15| - D3
             -------

```

### Nintendo SROM CHR ROM pinout - 8 KBytes (24pin)

This particular board is functionally identical to NROM but the CHR uses a 24-pin 8KB ROM with pinout very similar to the 27C32:

```text
  SROM  23C62/64 JEDEC-Standard 64-kbit CHR pinout
            ---_---
      A7 - |01   24| - Vcc
      A6 - |02   23| - A8
      A5 - |03   22| - A9
      A4 - |04   21| - A12
      A3 - |05   20| - /OE
      A2 - |06   19| - A10
      A1 - |07   18| - A11
      A0 - |08   17| - D7
      D0 - |09   16| - D6
      D1 - |10   15| - D5
      D2 - |11   14| - D4
     Gnd - |12   13| - D3
            -------

```

With only one output enable, the board synthesizes the signal (/OE = PPU A13 + PPU /RD) using two transistors and a resistor.

### Nintendo STROM

This board uses three 23C62, 8 KBytes, 24 pin MASK ROMs (two as PRG-ROM and one as CHR-ROM) and a few discrete elements for an address decoder [1]

### Nintendo AOROM PRG ROM pinout - 128/256/KBytes (32pin)

Very slight variant of the standard PRG-ROM pinout above, where an additional active high enable line is used to prevent bus conflicts.

```text
              ---_---
       A17 - |01   32| - +5V
       /CE - |02   31| - CE (R/W)
       A15 - |03   30| - +5V
       A12 - |04   29| - A14
       A7  - |05   28| - A13
       A6  - |06   27| - A8
       A5  - |07   26| - A9
       A4  - |08   25| - A11
       A3  - |09   24| - A16
       A2  - |10   23| - A10
       A1  - |11   22| - /CE
       A0  - |12   21| - D7
       D0  - |13   20| - D6
       D1  - |14   19| - D5
       D2  - |15   18| - D4
      GND  - |16   17| - D3
              -------

```

Japanese After Burner connects two such 128 kB mask roms in parallel (pin 2 = PPU /RD, pin 22 = SS4-CHR-/CE, pin31 = SS4-CHR-A17), which implies that one of them needs to have pin 31 active low and the other active high. [2]

## Signal descriptions
A0-A12 address D0-D7 data /CE, /OE The ROM will output data at address A on pins D only if all its CE (chip enable) and OE (output enable) pins are active (CE active high, /CE active low). /CE is sometimes called /CS (chip select). A memory responds faster to /OE than to /CE but draws less current while /CE is not asserted. PGM, VPP Used only during EPROM programing / erasing process.

See Cartridge connectorfor other signals descriptions.

## Converting a donor board

To convert a cartridge board to accept EPROM:
- Compare the pinout of your EPROM to the mask ROM pinout expected by the board.
- Lift any pins whose signals differ.
- Solder short wires to the corresponding holes.
- Solder down the memory or socket with the pins that do not differ.
- Solder each lifted pin to the hole with the same signal.

## See also
- NES EPROM Conversionsby Drk. Instructions on how to modify certain boards to use EPROMs.
- NES ROM pinoutsby Drk. Covers all PRG, CHR, and RAM chips used in NES cartridges.
- EPROM pinoutsby Drk.
- Advanced MMC3 NES Reproduction Tutorialby Callan Brown
- SNROM to SUROMby Ice Man

# NES Game Genie IC pinout

Source: https://www.nesdev.org/wiki/NES_Game_Genie_IC_pinout

See also: Game Genie

```text
                  .---\/---.
    CC PRG /CE <- | 01  48 | <- PPU A13 on NES
 Genie ROM /CE <- | 02  47 | -> CHR A13 on CC
       /ROMSEL -> | 03  46 | <- PPU /RD
       CPU R/W -> | 04  45 | <- PPU  A2
       CPU  A0 -> | 05  44 | <- PPU  A4
       CPU  A1 -> | 06  43 | <- PPU  A5
       CPU  A2 -> | 07  42 | <- PPU  A6
       CPU  A3 -> | 08  41 | <- PPU  A7
       CPU  A4 -> | 09  40 | <> CPU  D0
       CPU  A5 -> | 10  39 | <> CPU  D1
       CPU  A6 -> | 11  38 | <> CPU  D2
           GND -- | 12  37 | <> CPU  D3
       CPU  A7 -> | 13  36 | -- +5V
       CPU  A8 -> | 14  35 | <> CPU  D4
       CPU  A9 -> | 15  34 | <> CPU  D5
       CPU A10 -> | 16  33 | <> CPU  D6
       CPU A11 -> | 17  32 | <> CPU  D7
       CPU A12 -> | 18  31 | -> PPU  D7
       CPU A13 -> | 19  30 | ?? NC
       CPU A14 -> | 20  29 | -> PPU  D6
        /RESET -- | 21  28 | -> PPU  D5
            NC ?? | 22  27 | -> PPU  D4
       PPU  D0 <- | 23  26 | -> PPU  D3
       PPU  D1 <- | 24  25 | -> PPU  D2
                  '--------'

```

Pins 31–35 and 37–40 are connected to the CPU Dx lines via 200-ohm resistors. Their function is to prevent a bus conflict.

CC M2 is pulled low by resistor-diode logic when Genie ROM /CE is low.

/RESET only detects power-on reset, not reset-button reset.

Pin 30 goes to an unpopulated location for a capacitor.

## References
- NESDev Forums – Game Genie tracing/diagramming

# Expansion port

Source: https://www.nesdev.org/wiki/NES_expansion_port_pinout

Both the NES and Famicom have expansion ports that allow peripheral devices to be connected to the system.

See also: Input devices

## Famicom

The Famicom has a 15-pin (male) port on the front edge of the console (officially known as the expand connector).

Because its two default controllers were not removable like the NES, peripheral deviceshad to be attached through this expansion port, rather than through a controller portas on the NES.

This was commonly used for third party controllers, usually as a substitute for the built-in controllers, but sometimes also as a 3rd and 4th player.

### Pinout

```text
       (top)    Famicom    (bottom)
               Male DA-15
                 /\
                |   \
joypad 2 /D0 ?? | 08  \
                |   15 | -- +5V
joypad 2 /D1 -> | 07   |
                |   14 | -> /OE for joypad 1 ($4016 read strobe)
joypad 2 /D2 -> | 06   |
                |   13 | <- joypad 1 /D1
joypad 2 /D3 -> | 05   |
                |   12 | -> OUT0 ($4016 write data, bit 0, strobe on pads)
joypad 2 /D4 -> | 04   |
                |   11 | -> OUT1 ($4016 write data, bit 1)
        /IRQ ?? | 03   |
                |   10 | -> OUT2 ($4016 write data, bit 2)
       SOUND <- | 02   |
                |   09 | -> /OE for joypad 2 ($4017 read strobe)
         Gnd -- | 01  /
                |   /
                 \/

```

### Signal descriptions
- Joypad 1 /D1 , Joypad 2 /D0-/D4 : Joypad data lines, which are inverted before reaching the CPU. Joypad 1 /D1 and joypad 2 /D1-/D4 are exclusively inputs, but on the RF Famicom, Twin Famicom, and Famicom Titler, joypad 2 /D0 is supplied by the permanently-connected player 2 controller, making it an output. In contrast, the AV Famicom features user-accessible controller ports and thus detachable controllers, allowing joypad 2 /D0 to potentially be an input. At least one expansion port device, the Multi Adapter AX-1, expects joypad 2 /D0 to be an output.
- Joypad 1 /OE , Joypad 2 /OE : Output enables, asserted when reading from $4016 for joypad 1 and $4017 for joypad 2. Joypads are permitted to send input values at any time and often use /OE just as a clock to advance a shift register. Internally, the console uses /OE to know when to put the joypad input onto the CPU data bus.
- OUT2-0 : Joypad outputs from the CPU matching the values written to $4016 D2-D0. These are updated every APU cycle (every 2 CPU cycles).
- /IRQ : The direction of this signal depends on the cartridge being used. Some cartridges use a push/pull /IRQ driver, which doesn't permit anything else to disagree, preventing input on this pin. Otherwise, it can be used as an input.
- SOUND : Analog audio output. In the RF Famicom, this is before expansion audio is mixed in. In the AV Famicom, it is after. It is possible to use this for audio input, but is inadvisable; there is no single way to mix in audio that is compatible with all consoles and all cartridges, and in most cases, the voltage must be carefully balanced to mix linearly with the signal output by the console's hex inverter.

## NES

The NES has a 48-pin card edge located on the underside of the NES, beneath a plastic tab which must be cut or broken to expose the connector. The connector is exceptionally thick (2.6mm), thicker than standard PCB thicknesses. The port containing the connector is slightly keyed in the front-side corners.

Because the NES had controller portson the front that allowed different devices to be plugged in, the expansion port was a kind of "back up plan" for Nintendo that was never used commercially.

### Pinout

```text
                              (back)       NES       (front)
                                        +-------\
                                 +5V -- |01   48| -- +5V
                                 Gnd -- |02   47| -- Gnd
                     Audio mix input -> |03   46| -- NC
                                /NMI <> |04   45| -> OUT2 ($4016 write data, bit 2)
                                 A15 <- |05   44| -> OUT1 ($4016 write data, bit 1)
                                EXP9 ?? |06   43| -> OUT0 ($4016 write data, bit 0, strobe on sticks)
                                EXP8 ?? |07   42| ?? EXP0
                                EXP7 ?? |08   41| ?? EXP1
                                EXP6 ?? |09   40| ?? EXP2
                                EXP5 ?? |10   39| ?? EXP3
($4017 read strobe) /OE for joypad 2 <- |11   38| ?? EXP4
                        joypad 1 /D1 -> |12   37| -> /OE for joypad 1 ($4016 read strobe)
                        joypad 1 /D3 xx |13   36| xx joypad 1 /D4
                                /IRQ <> |14   35| xx joypad 1 /D0
                        joypad 2 /D2 -> |15   34| -> duplicate of pin 37
                        joypad 2 /D3 xx |16   33| <- joypad 1 /D2
                 duplicate of pin 11 <- |17   32| <> CPU D0
                        joypad 2 /D4 xx |18   31| <> CPU D1
                        joypad 2 /D0 xx |19   30| <> CPU D2
                        joypad 2 /D1 -> |20   29| <> CPU D3
                           Video out <- |21   28| <> CPU D4
                     Amplified audio <- |22   27| <> CPU D5
       unregulated power adapter vdd -- |23   26| <> CPU D6
                     4.00MHz CIC CLK <- |24   25| <> CPU D7
                                        +-------/

```

### Signal notes
- All joypad input lines /D0-/D4 are logically inverted before reaching the CPU. A high signal will be read as a 0 and vice versa.
- xx in above pinout: Joypad 1 and 2 /D0, /D3, and /D4 are available as an input if no peripheral is connected to the corresponding joystick portthat uses those bits:
  - e.g. /D0 is unavailable if a Standard controlleror Four scoreis plugged in, and
  - /D3 and /D4 are unavailable if a Zapper, Arkanoid controller, or Power Padis plugged in.
- /NMI is open-collector.
- /IRQ depends on the cartridge—most ASICs seem to use a push-pull driver instead of relying on the pull-up resistor inside the console.
  - Because of this, a series 1kΩ resistor should be included to safely use the /IRQ signal in the expansion port.
  - This resistor is enough to logically overcome the internal 10kΩ pull-up, and will also limit any ASIC's output-high current to 5mA if your expansion device tries to drive it low at the same time.
- See EXP pinsfor notes about the ten EXP pins.
- See Standard controllerand Controller port pinoutfor more information about controller connections.

# NTDEC8801 pinout

Source: https://www.nesdev.org/wiki/NTDEC8801_pinout

```text
            .---\/---.
     VCC -- | 01  16 | -- GND
 /WRA000 -> | 02  15 | ?? NC
      NC ?? | 03  14 | ?? NC
  /RESET -> | 04  13 | -> A13
 /WR8000 -> | 05  12 | <- CPU-/ROMSEL
 /WR8000 -> | 06  11 | <- CPU-A13
CNTRESET <- | 07  10 | ?? NC
      NC ?? | 08  09 | -- +5V
            '--------'
             NTDEC8801

```

This chip was used in at least one of SMB2J pirate ports (mapper 40) [1]. There exist exactly the same SMB2J port without this chip but with additional 74's IC [2], so NTDEC8801 is aggregate the function of:
- flip flop with set/reset: CNTRESET <= 0 when /WRA000=0 else '1' when /WR8000=0
- multiplexer with negation: A13 <= CPU-A13 when CPU-!ROMSEL! = 0 else not CPU-A13
- and something more that is not used (not wired)

# NTDEC TC-112 pinout

Source: https://www.nesdev.org/wiki/NTDEC_TC-112_pinout

NTDEC TC-112: 40-pin 0.6" PDIP. (Canonically iNES Mapper 193)

```text
                .---\/---.
 (n)      M2 -> |1     40| -- VCC
 (nr) CPU D7 -> |2     39| -> PRG A16  (r)
 (nr) CPU D6 -> |3     38| -> PRG A15  (r)
 (nr) CPU D5 -> |4     37| -> PRG A14  (r)
 (nr) CPU D4 -> |5     36| -> PRG A13  (r)
 (nr) CPU D3 -> |6     35| -> PRG /CE  (r)
 (nr) CPU D2 -> |7     34| -> CHR A17  (r)
 (nr) CPU D1 -> |8     33| -> CHR A16  (r)
 (nr) CPU A1 -> |9     32| -> CHR A15  (r)
 (nr) CPU A0 -> |10    31| -> CHR A14  (r)
 (n) CPU R/W -> |11    30| -> CHR A13  (r)
 (n) CPU /CE -> |12    29| -> CHR A12  (r)
 (n) CPU A14 -> |13    28| -> CHR A11  (r)
 (n) CPU A13 -> |14    27| -> CHR1 /CE (r) = (PPU /RD) or (PPU A13) or (CHR A17)
 (n) PPU A13 -> |15    26| -> CHR2 /CE (r) = (PPU /RD) or (PPU A13) or (not CHR A17)
 (n) PPU A12 -> |16    25| <- CPU D0  (nr)
 (n) PPU A11 -> |17    24| -> /W6005
 (nr)PPU A10 -> |18    23| -> /W6006
  †  PPU /RD -> |19    22| <- CPU A2  (nr)
         GND -- |20    21| -> CIRAM A10 (n)
                `--------'

```

† On one board, connected to a seemingly-needlessly-complicated 7400circuit. See the thread on the forum.

Sources:
- BootGod: https://forums.nesdev.org/viewtopic.php?p=69275#p69275
- Krzysiobal: https://forums.nesdev.org/viewtopic.php?t=19751

# Namcot 108 family pinout

Source: https://www.nesdev.org/wiki/Namcot_108_family_pinout

Namcot 108, 109, 118, 119: 28-pin shrink PDIP, also Tengen 337001 or MIMIC-1: 28-pin 0.6" PDIP (Canonically mapper 206).

```text
               .--\/--.
(f) CPU A14 -> |01  28| -> PRG A15 (r)
(fr) CPU A0 -> |02  27| -> PRG A14 (r)
(fr) CPU D5 -> |03  26| <- M2 (f)
(fr) CPU D0 -> |04  25| -> PRG A13 (r)
(fr) CPU D4 -> |05  24| <- CPU A13 (f)
(fr) CPU D1 -> |06  23| -> PRG A16 (r)
        Gnd -- |07  22| -> PRG /CE (r)
(fr) CPU D3 -> |08  21| -- +5V
(fr) CPU D2 -> |09  20| -> CHR A13 (r)
(f) /ROMSEL*-> |10  19| -> CHR A11 (r)
    (f) R/W -> |11  18| -> CHR A10 (r)
(r) CHR A15 <- |12  17| <- PPU A10 (f)
(r) CHR A14 <- |13  16| <- PPU A11 (f)
(r) CHR A12 <- |14  15| <- PPU A12 (f)
               `------'

10: on the Vs. System daughterboards, this is instead CPU /A15

```

No behavioral differences are known between the five different part numbers; severalgameswere released on the same board with identical code and different mapper ICs.

## Functional Variations

Many boards (and thus iNES mappers) redefined parts of the pinout for various extensions, mostly to increase the amount of addressable CHR ROM.

#### 3446

Mapper 76: Rewires CHR banking to be able to address more total CHR with coarser CHR banks.

```text
(fr) CPU D2 -> |09  20| -> CHR A14 (r)
(f) /ROMSEL -> |10  19| -> CHR A12 (r)
    (f) R/W -> |11  18| -> CHR A11 (r)
(r) CHR A16 <- |12  17| <- PPU A11 (f)
(r) CHR A15 <- |13  16| <- PPU A12 (f)
(r) CHR A13 <- |14  15| <- +5V
               `------'

      (f) PPU A10 -> CHR A10 (r)

```

#### 3433, 3443, 3453

Mappers 88and 154connect (f) PPU A12 -> CHR A16 (r), skipping the mapper IC altogether.

#### 3425

Mapper 95: Repurposes CHR A15 to control nametable banking

```text
(f) CIRAM A10 <- |12  17| <- PPU A10 (f)
  (r) CHR A14 <- |13  16| <- PPU A11 (f)
  (r) CHR A12 <- |14  15| <- PPU A12 (f)
                 `------'

```

## Pirate clones

AX-24G, NTDEC8701, NCT1024: 28-pin 0.6" PDIP

```text
               .--\/--.                                 .--\/--.
(r) PRG A13 <- |01  28| <- CPU A14 (f)            M2 -> |01  28| -- +5V
(r) PRG A14 <- |02  27| <- CPU A13 (f)           R/W -> |02  27| <- RESET
(r) PRG A16 <- |03  26| <- CPU A0 (fr) MODE/CPU A14* -> |03  26| <- CPU D3*
(r) PRG A15 <- |04  25| -- VCC              CPU A13* -> |04  25| -> CHR A15
(r) CHR A14 <- |05  24| <- /ROMSEL (f)       CPU D1* -> |05  24| -> CHR A14
(r) CHR A11 <- |06  23| -> PRG /OE (r)       CPU D0* -> |06  23| -> CHR A13
(r) CHR A13 <- |07  22| <- M2 (f)            /ROMSEL -> |07  22| -> CHR A12
(r) CHR A12 <- |08  21| <- R/W (f)           CPU D4* -> |08  21| -> CHR A11
(fr) CPU D2 -> |09  20| <- CPU-D0 (fr)        CPU A0 -> |09  20| -> CHR A10
(fr) CPU D3 -> |10  19| <- CPU-D5 (fr)       PRG A16 <- |10  19| <- CPU D5*
(fr) CPU D1 -> |11  18| <- CPU-D4 (fr)       PRG A15 <- |11  18| <- PPU A12
        Gnd -- |12  17| <- PPU-A12 (f)       PRG A14 <- |12  17| <- PPU A11
(r) CHR A15 <- |13  16| <- PPU-A11 (f)       PRG A13 <- |13  16| <- PPU A10
(r) CHR A10 <- |14  15| <- PPU-A10 (f)           GND -- |14  15| <- CPU D2*
               `------'                                 `------'
       AX-24G, NTDEC8701, AX5604P                        KS 204

               .-----v----.
     CPU D2 -> | 01    28 | -- VCC
     CPU D1 -> | 02    27 | <- CPU D3
     CPU D0 -> | 03    26 | <- CPU D4
     CPU M2 -> | 04    25 | <- CPU D5
CPU /ROMSEL -> | 05    24 | <- PPU A11
     CPU A0 -> | 06    23 | <- PPU A12
    CPU R/W -> | 07    22 | <- PPU A10
    CHR A10 <- | 08    21 | -> CHR A13
    CHR A11 <- | 09    20 | -> CHR A14
    CHR A12 <- | 10    19 | -> CHR A15
    CHR A13 <- | 11    18 | <- CPU A14
    PRG A13 <- | 12    17 | -> PRG A17
    PRG A14 <- | 13    16 | -> PRG A16
        GND -- | 14    15 | -> PRG A15
               `----------`
                 NCT1024 [1]

```

KS204:
- MODE: If pin 3 is low on a falling edge of RESET, it operates in N108 mode. If it's high, or before the first falling edge of RESET, it operates in VRC2 mode. [2]
- Pins marked with * change behavior in VRC2 mode

### Functional variations

#### KS7037

Mapper 307(UNIF "KS7037"): repurpose CHR banking for nametable control. Moves second switchable bank.

```text
             .--\/--.
       M2 -> |01  28| -- +5V
      R/W -> |02  27| <- RESET
  CPU A13 -> |03  26| <- CPU D3
  CPU A14 -> |04  25| -> n/c
   CPU D1 -> |05  24| -> n/c
   CPU D0 -> |06  23| -> n/c
  /ROMSEL -> |07  22| -> n/c
   CPU D4 -> |08  21| -> n/c
   CPU A0 -> |09  20| -> CIRAM A10
 PRG A16* <- |10  19| <- CPU D5
  PRG A15 <- |11  18| <- +5V
  PRG A14 <- |12  17| <- PPU A11
  PRG A13 <- |13  16| <- PPU A10
      GND -- |14  15| <- CPU D2
             `------'
              KS 204

```

External hardware further modifies the exact memory map.

#### Sachen 3009

Redundant variation of mapper 133: obfuscatory GNROM-style banking.

```text
               .--\/--.
        n/c <- |01  28| <- CPU A14 (f)
        n/c <- |02  27| <- CPU A13 (f)
        n/c <- |03  26| <- CPU A0 (fr)
        n/c <- |04  25| -- VCC
 feedback#1 <- |05  24| <- /ROMSEL (f)
(r) PRG A15 <- |06  23| -> PRG /OE (r)
(r) CHR A14 <- |07  22| <- M2 (f)
(r) CHR A13 <- |08  21| <- R/W (f)
(fr) CPU D0 -> |09  20| <- CPU D3 (fr)
(fr) CPU D1 -> |10  19| <- CPU D4 (fr)
(fr) CPU D2 -> |11  18| <- CPU D5 (fr)
        Gnd -- |12  17| <- Vcc
 feedback#2 <- |13  16| <- feedback#2
        n/c <- |14  15| <- feedback#1
               `------'
                AX-24G

```

## Sources
- AX-24G or NTDEC8701 [ BBS]
- KS 204 [ BBS]

# Namcot 163 family pinout

Source: https://www.nesdev.org/wiki/Namcot_163_family_pinout

The Namcot 129, 160, and 163 seem to have identical pinning. The Namcot 175 and 340 have minor but vital differences.

Namcot 129, 160, and 163: 48-pin QFP (canonically iNES Mapper 019)

```text
                             _____
                            /     \
           (f) SOUND   <-  / 1  48 \ -> CHR A14 (r)
          (r) CHR A13 <-  / 2    47 \ -> CHR A15 (r)
         (r) CHR A12 <-  / 3   O  46 \ -> CHR A16 (r)
        (r) CHR A11 <-  / 4        45 \ -> CHR A17 (r)
      (fr)*CHR A10 <-  / 5          44 \ -> $F000.6,7
              GND --  / 6            43 \ -- +5Vcc
     (r) PRG A18 <-  / 7              42 \ -> CIRAM /CE (f)
    (r) PRG A17 <-  / 8                41 \ -> CHR ROM /CE (r)
   (r) PRG A16 <-  / 9                  40 \ -> WRAM /CE (w)
  (r) PRG A15 <-  / 10                   39 \ -> /IRQ (f)
 (r) PRG A14 <-  / 11        NAMCO        38 \ <- PPU A10 (f)
(r) PRG A13 <-  / 12    129/163/175/340    37 \ <- PPU A11 (f)
               /                               \
               \        Package QFP-48,        /
(fr)  CPU D7 <> \ 13      0.8mm pitch      36 / <- PPU A12 (f)
 (fr)  CPU D6 <> \ 14                     35 / <- PPU A13 (f)
  (fr)  CPU D5 <> \ 15                   34 / <- 1: apply pin 33 to pin 42 as well
   (fr)  CPU D4 <> \ 16                 33 / <- PPU /RD (f) or GND (see below)
    (fr)  CPU D3 <> \ 17               32 / -- +5Vcc
     (fr)  CPU D2 <> \ 18             31 / -- GND
             +5Vcc -- \ 19           30 / <- M2 (f)
       (fr)  CPU D1 <> \ 20         29 / <- R/W (fw)
        (fr)  CPU D0 <> \ 21       28 / <- /ROMSEL (f)
             /$E000.7 <- \ 22     27 / <- CPU A14 (f)
          (r) PRG /CE  <- \ 23   26 / <- CPU A13 (f)
          (fr) CPU A11  -> \ 24 25 / <- CPU A12 (fr)
                            \     /
                             \   /
                              \ /
                               V

01 Some Namcot 163 games use expansion audio, which uses a common mixing circuit:
           From N163------------------+
           (N163.1)                   |
                        R1            |
           From 2A03---/\/\/---+------+--------To RF
           (Cart.45)           |               (Cart.46)
                              --- C1
                              ---
                               |
                              GND
   R1 appears to be a set of values which may vary in each board (4.7k, 10k, 15k, 22k, 33k).
   C1 may or may not be present in each board. The boards that do have C1 present seem to be a set of values which may vary (1n, 1.6n).
   Note that caps in other games are only noted to be present, with its value not yet measured.

05 also connects to CIRAM A10.
19,32,43 Some boards connect a battery (through a standard diode switch) to this pin to make the waveform memory nonvolatile:
                                            VCC
                                            |E
                           +--330k--------|< PNP
                           |                |C
           GND---3.3VBAT---+--10k---|>|-+   +-- N163 pin 32
                                        |
           VCC----------------------|>|-+--VBB (N163 pins 19 & 43, WRAM pin 28)
   The role of transistor is to cut off the pin 32 from VCC when voltage is below battery level.

22 This pin is a mysterious open-collector output, reflecting the inverse of bit 7 in register $E000.
30 Pull-down resistor present on boards with battery for low-power mode.
33 Ground this pin if CHR's /OE and /CS lines are separate - see pin 41
34 If this pin is high, pin 33 is applied to the CIRAM /CE output also. Unclear when this would be useful; if pin 33 is PPU /RD it would write-protect CIRAM.
41 pin 33 ORed with internal signal
42 pin 33 ANDed with pin 34, then ORed with internal signal
44 PPU A12, A13, and bits 6 and 7 in register $F000 control this pin. Unclear how to use this.

(r) - this pin connects to the ROM chips
(f) - this pin connects to the Famicom connector
(w) - this pin connects to the WRAM

Internal Vcc Connections:
19 ------- 43
32 --|>|-- 19/43 (0.7V diode drop)
Powering only 19/43 does not allow any digital operation.

```

Namcot 175: 48-pin QFP (canonically iNES Mapper 210)

```text
01 sound was removed
05 CIRAM A10 is hardwired to PPU A10 or A11 as appropriate
39 does not provide IRQs
42 does not allow for ROM nametables

```

Namcot 340: 48-pin QFP (also iNES Mapper 210)

```text
 42\ -> ?
  41\ -> ?
   40\ -> CHR /CE (r)
    39\ -> CIRAM A10 (f)
01 sound was also removed.

```

## References
- plgDavid's N163 cartridge details related to audio- a table which lists values of expansion audio circuit components in most N163 games.

# Nantettatte!! Baseball pinout

Source: https://www.nesdev.org/wiki/Nantettatte!!_Baseball_pinout

```text
                        Deck | CART | Deck
                             /------.
                       M2 -> |02  01| -- GND
SS4 PRG /CE | SS4 PRG A17 -> |04  03| <- SS4 WRAM /CE | CPU R/W | $F000.4
                   CPU D3 <> |06  05| <> CPU D2
                   CPU D4 <> |08  07| <> CPU D1
                   CPU D5 <> |10  09| <> CPU D0
                   CPU D6 <> |12  11| <- CPU A0
                   CPU D7 <> |14  13| <- CPU A1
                  CPU A10 -> |16  15| <- CPU A2
              SS4 PRG A16 -> |18  17| <- CPU A3
                  CPU A11 -> |20  19| <- CPU A4
                   CPU A9 -> |22  21| <- CPU A5
                   CPU A8 -> |24  23| <- CPU A6
                  CPU A13 -> |26  25| <- CPU A7
              SS4 PRG A14 -> |28  27| <- CPU A12
                      +5V -- |30  29| <- SS4 PRG A15
                             \------'
                      2x15 pin 0.1" edge connector

```
- Pin numbers correspond to the markings on edge connctor
- Even pins are on the label side of external cartridge (02=leftmost)

Source: [1], [2]

# PPU pinout

Source: https://www.nesdev.org/wiki/PPU_pinout

### Pinout

#### Composite PPU

Composite PPUs (2C02, 2C07) are the standard PPU in consumer consoles.

```text
          .--\/--.
   R/W -> |01  40| -- +5V
CPU D0 <> |02  39| -> ALE
CPU D1 <> |03  38| <> PPU AD0
CPU D2 <> |04  37| <> PPU AD1
CPU D3 <> |05  36| <> PPU AD2
CPU D4 <> |06  35| <> PPU AD3
CPU D5 <> |07  34| <> PPU AD4
CPU D6 <> |08  33| <> PPU AD5
CPU D7 <> |09  32| <> PPU AD6
CPU A2 -> |10  31| <> PPU AD7
CPU A1 -> |11  30| -> PPU A8
CPU A0 -> |12  29| -> PPU A9
   /CS -> |13  28| -> PPU A10
  EXT0 <> |14  27| -> PPU A11
  EXT1 <> |15  26| -> PPU A12
  EXT2 <> |16  25| -> PPU A13
  EXT3 <> |17  24| -> /RD
   CLK -> |18  23| -> /WR
  /INT <+ |19  22| <- /RST
   GND -- |20  21| -> VOUT
          `------'

```

#### RGB PPU

RGB PPUs (2C03, 2C04, 2C05) are used mostly in arcade systems. They have the same pinout as composite except that they replace the EXT3..0 and VOUT signals with signals used for RGB video.

```text
            ...
   /CS -> |13  28| -> PPU A10
     R <- |14  27| -> PPU A11
     G <- |15  26| -> PPU A12
     B <- |16  25| -> PPU A13
   GND -- |17  24| -> /RD
   CLK -> |18  23| -> /WR
  /INT <+ |19  22| <- /RST
   GND -- |20  21| -> CSYNC
          `------'

```

### Signal descriptions
- R/W , CPU D7..0 , and CPU A2..0 , are signals from the CPU. CPU A2..0 are tied to the corresponding CPU address pins and select the PPU register (0-7).
- /CS is generated by the 74139(address decoder) on the mainboard to map the PPU regs in the CPU memory range from $2000 to $3FFF.
  - This signal is sometimes referred to as /DBE.
- EXT3..0 allows the combination of two PPUs - setting the "slave" bit in the PPUCTRL($2000) register causes the PPU to output palette indices to these pins, and clearing said bit causes it to instead read indices from these pins (and use them to select the backdrop color). No official console uses the output mode, so these are normally grounded to set the backdrop to palette entry 0.
  - For RGB PPUs, EXT0..2 are replaced with R , G , and B , respectively. EXT3 is internally and externally tied to ground: perhaps it serves as an analog ground for the video DACs.
- CLK is the 21.47727 MHz (NTSC) or 26.6017 MHz (PAL) clock input. It is doubled for the color generator (and then divided by 12 to get the colorburst frequency) and also divided by 4 (NTSC) or 5 (PAL) for the pixel and memory clocks.
- /INT is an open-drain output, connected to the CPU's /NMI pin as well as a pull-up resistor.
- ALE (Address Latch Enable) goes high at the beginning of a PPU VRAM access and is used to latch the lower 8 bits of the PPU's address bus; see the PPU address bus section of PPU rendering. It stays high for one PPU cycle.
- PPU AD7..0 (Address + Data) is the PPU's data bus, multiplexed with the lower 8 bits of the PPU's address bus.
- PPU A13..8 are the top 6 bits of the PPU's address bus.
- /RD and /WR specify that the PPU is reading from or writing to VRAM. As an exception, writing to the internal palette range (3F00-3FFF) will not assert /WR.
- /RST resets certain parts of the chip to their initial power-on state: the clock divider, video phase generator, scanline/pixel counters, and the even/odd frame toggle. It also keeps several registers zeroed out for a full frame: PPUCTRL, PPUMASK($2001), PPUSCROLL($2005; the VRAM address latch "T", fine X scroll, and the H/V toggle), and the VRAM read buffer. See PPU power up state.
  - This signal is used in the NES to clear the screen when the console is reset either by the button or the CIC.
  - Famicom ties this signal directly to the +5V rail, which is why the screen does not clear as you hold down the reset button.
  - In a dual-PPU system, it can be used to synchronize the "foreground" and "background" PPUs, or it could also be used to genlockmultiple independent PPUs together. In either case, care would need to be taken to ensure that the "even/odd frame" state stays consistent between them.
- VOUT is the shifted analog videooutput.
  - For RGB PPUs, this is instead only CSYNC , the composite sync signal.

### Composite Video Output

The non-RGB PPUs used in home consoles directly output a shifted analog composite video signal from pin 21. Because of this, it is possible to modify models that only have an RF output to add a composite video output. This is the best-known composite video amplifier circuit [1]:

```text
[+5V]---------/\/\/-----+
 |            300Ω      |
 |+                     |       +
--- Tantalum            +---------|(---------/\/\/-------+--------+
--- 4.7-47uF           /     Electrolytic    110Ω        |        |   Pin
 |               (b) |L (e)      220uF                   |        +----O } Composite
 |  [PPU.21]---------| PNP                      Ceramic ---              }   Video
 |                   |\ (c) 2SA937                560pF ---       +----O }
 |                     \    (sub: 2N3906)                |        |  Ring
[PPU.20]----------------+--------------------------------+--------+
[GND]

```

The tantalum capacitor reduces a repeating 4 or 8 pixel wide vertical bar artifact. It is best to specifically use a tantalum centered in the stated range (ex. 10uF), connected directly from PPU pin 20(-) to 22(+) on the Famicom, or from pin 20(-) to 40(+) on the front-loading NES. Since this cap is targeting a specific frequency, bigger is not better for this cap -- centered in the range is better. The existing 2SA937 transistor should be removed to disconnect the RF modulator from the PPU, then reused into this circuit.

On the HVC-CPU(01) through HVC-CPU-08, the NES-CPU-01 through -11, and the NESN-CPU-01, there is no benefit from cutting any of the PPU's pins nor wrapping the PPU in foil.

However, on the HVC-CPU-GPM-01 and -02 boards, isolating pin 21 from its original trace provides a visibly significant improvement.

If your original 2SA937 is damaged or lost, you can substitute a common 2N3906, but note that its pinout is different.

```text
 2SA937        2N3906
                ___
__ ______      /___\
| V     |      |   |
|_______|      |___|
 |  |  |        /|\
 |  |  |       | | |
 E  C  B       E B C

```

### See also
- Wiring diagram of RF Famicom
- Archive of 電子機器(Electronics) Junker's redrawn schematic of the HVC-001(formerly at green.ap.teacup.com/junker/116.html )
- Electronix Corp's redrawn schematic of the NES-001
  - Fixed errata from page 3 of above schematic

## References
- ↑https://forums.nesdev.org/viewtopic.php?f=9&t=18508

# PT8154 pinout

Source: https://www.nesdev.org/wiki/PT8154_pinout

PT8154, used on one version of iNES Mapper 189, 0.6" DIP-28. MMC3 clone without IRQ, PRG RAM, or PRG banking. Pin order matches MMC3.

```text
             .--\/--.
  CHR A10 <- |01  28| -- VCC
  PPU A12 -> |02  27| -> CHR A16
  PPU A11 -> |03  26| -> CHR A11
  PPU A10 -> |04  25| <- CPU D3
  CHR A13 <- |05  24| <- CPU D2
  CHR A14 <- |06  23| <- CPU D4
  CHR A12 <- |07  22| <- CPU D1
CIRAM A10 <- |08  21| <- CPU D5
  CHR A15 <- |09  20| <- CPU D0
  /ROMSEL -> |10  19| <- CPU D6
      R/W -> |11  18| <- CPU A0
  CPU A14 -> |12  17| <- CPU D7
      GND -- |13  16| <- M2
  CPU A13 -> |14  15| -> PRG /CE
             '------'
             PT8154

```

Source: [1]

# PT8159 Pinout

Source: https://www.nesdev.org/wiki/PT8159_Pinout

The PT8159 exists as a Apoxy Blob Present along with the PT8154(which generates IRQs and Mappes CHR ROM) in Street Fighter II by Yoko Soft

```text
           .--\/--.
PRG A16 <- |01    |
PRG A15 <- |02  19| -- VCC
 CPU D4 -> |03  18| <- PPU A13
 CPU D5 -> |04  17| <- PPU /RD
 CPU D0 -> |05  16| -> CHR /CS
 CPU D1 -> |06  15| <- CPU R/W
 CPU D2 -> |07  14| -- GND
 CPU D3 -> |08  13| <- M2
/ROMSEL -> |09  12| -> CPU A8
CPU A14 -> |10  11| <- CPU A13
           `------'

```

See also:
- https://forums.nesdev.org/viewtopic.php?t=20419

# RP2C33 pinout

Source: https://www.nesdev.org/wiki/RP2C33_pinout

Family Computer Disk SystemASIC RP2C33 or RP2C33A: 64-pin shrink DIP (FDS files)

```text
                 .---\/---.
 (Rf) /ROMSEL -> | 01  64 | -- +5V
 (Rf) CPU A14 -> | 02  63 | <- XTAL2
 (Rf) CPU A13 -> | 03  62 | -> XTAL1
  (f) CPU A12 -> | 04  61 | <- /EnableRAS (gnd)
  (f) CPU A11 -> | 05  60 | -> /RAS (r)
  (f) CPU A10 -> | 06  59 | -> /CAS1 (r)
   (f) CPU A9 -> | 07  58 | -> /CAS0 (r)
   (f) CPU A8 -> | 08  57 | <- R/W (rf)
(r) PRG A6/13 <- | 09  56 | <- M2 (Rf)
(r) PRG A5/12 <- | 10  55 | +> /IRQ (f)
(r) PRG A4/11 <- | 11  54 | -> Audio (f)
(r) PRG A3/10 <- | 12  53 | <- +TestMode (gnd)
 (r) PRG A2/9 <- | 13  52 | +> SER OUT
 (r) PRG A1/8 <- | 14  51 | <- SER IN
   (r) PRG A0 <- | 15  50 | +> $4025W.2 (Disk 0=Write, 1=Read)
  (rf) CPU A7 -> | 16  49 | +> $4025W.1 (Motor 0=Start, 1=Stop)
   (f) CPU A6 -> | 17  48 | +> $4025W.0 (1=Reset transfer timing)
   (f) CPU A5 -> | 18  47 | <- $4032R.2 (1=Write protected)
   (f) CPU A4 -> | 19  46 | <- $4032R.1 (1=Disk not ready)
   (f) CPU A3 -> | 20  45 | <- $4032R.0 (1=Disk missing)
   (f) CPU A2 -> | 21  44 | <+> EXT0
   (f) CPU A1 -> | 22  43 | <+> EXT1
   (f) CPU A0 -> | 23  42 | <+> EXT2
      /CE4100 <- | 24  41 | <+> EXT3
  (rf) CPU D0 <> | 25  40 | <+> EXT4
  (rf) CPU D1 <> | 26  39 | <+> EXT5
  (rf) CPU D2 <> | 27  38 | <+> EXT6
  (rf) CPU D3 <> | 28  37 | <+> EXT7/BATT
  (rf) CPU D4 <> | 29  36 | <- PPU A10 (f)
  (rf) CPU D5 <> | 30  35 | <- PPU A11 (f)
  (rf) CPU D6 <> | 31  34 | -> CIRAM A10 (f)
          GND -- | 32  33 | <> CPU D7 (rf)
                 '--------'
R - connects to LH2833 DRAM in later PCB revisions
r - connects to DRAM (all revisions)
f - connects to Famicom
+ - output is open-drain, requires an external pull-up resistor

Expansion audio mixing circuit schematic:
                             1.2M
                         +---/\/---+
                +        |         |       56K
From RP2C33---||---/\/---+---|>o---+---+---/\/---+
(RP2C33.54)   1u    2M                 |         |
                                 0.1u ---        |
                                      ---        |
                                       |         |            100K
                                      GND        |        +---/\/---+
                                                 |     +  |         |
From 2A03----------------------------------/\/---+---||---+---|>o---+---To RF
(Cart.45)                                  56K      1u              (Cart.46)

```

Notes:
- PRG address bus is multiplexed, as is typical for DRAMs.
- EXT port can be written via $4026 and read via $4033

Originally transcribed from https://web.archive.org/web/20140920224500/green.ap.teacup.com/junker/119.html( PDF rehosted on forum)

# SHARP IX0043AE pinout

Source: https://www.nesdev.org/wiki/SHARP_IX0043AE_pinout

SHARP IX0043AE: 16-pin DIP 0.3

```text
         .---v---.
EYE2+ <- |01   16| -- +5V
EYE2- <- |02   15| <- /RESET
         |03   14| -> EYE1-
         |04   13| -> EYE1+
         |05   12|
XTAL1 -- |06   11|
XTAL2 -- |07   10|
  GND -- |08   09| -> V+-GEN
         '-------'

```

Source: krzysiobal on the forums

# SMD133 (AA6023) pinout

Source: https://www.nesdev.org/wiki/SMD133_(AA6023)_pinout

SMD133 (AA6023B): LQFP-48 0.5mm pitch (canonically NES 2.0 Mapper 268submapper 2/3)

```text
                                            ________
                                PPU A11 -> / 1   48 \ <- PPU A12
                               PPU A10 -> / 2     47 \ <- CPU A12
                                  VCC -- / 3       46 \ -> CHR A10
                                 GND -- / 4         45 \ -> CHR A16
                             CPU A1 -> / 5           44 \ -> CHR A11
(PRG A22, may vary) "PX0" $5001.1  <- / 6             43 \ -> $5000.5 (CHR A19 in submappers 2/3, varies in others)
                          CHR A13 <- / 7               42 \ -> $5000.4 (CHR A18, varies)
                         CHR A14 <- / 8                 41 \ <- CPU D3
                        CHR A12 <- / 9     SMD133        40 \ <- CPU D2
             (CIRAM A10?) "HV" <- / 10     (AA6023)       39 \ <- CPU D4
                      CHR A15 <- / 11                      38 \ <- CPU D1
                     CHR A17 <- / 12                        37 \ <- CPU D5
                     PRG A20 <- \ 13                        36 / <- CPU D0
                         /IRQ <- \ 14                      35 / -> $5001.2 "PX1" (PRG A21, may vary)
                   CPU /ROMSEL -> \ 15                    34 / <- CPU D6
                        CPU R/W -> \ 16                  33 / <- CPU A0
                         PRG A15 <- \ 17                32 / <- CPU D7
                          PRG A13 <- \ 18              31 / -> PRG RAM /CE ("EXT CSB")
                           CPU A14 -> \ 19            30 / <- M2 ("CK18")
                       K5K7 or K5K6 -> \ 20          29 / -> VFL
                             PRG A16 <- \ 21        28 / -- VDD
                              PRG A14 <- \ 22      27 / -> PRG A19
                               PRG A18 <- \ 23    26 / -> PRG /CE ("POEB")
                                CPU A13 -> \ 24  25 / -> PRG A17
                                            --------
Legend:
->[SMD]<- Input
<-[SMD]-> Output
--[SMD]-- Power

```

"VFL" is reportedly a diode from VDD, originally intended for powering 3V flash. (Don't do that, it's not a good enough voltage regulator).

Source: [1]

# SP-80 pinout

Source: https://www.nesdev.org/wiki/SP-80_pinout

```text
                                     _____________
                                    /             \
          PPU A0 <-     PPU A13 <- / 79 80   02 01 \ <> PPU D0      -- GND
         PPU A1 <-     PPU A12 <- / 77 78     04 03 \ <> PPU D1      <> PPU D7
        PPU A2 <-     PPU A11 <- / 75 76       06 05 \ <> PPU D2      <> PPU D6
       PPU A3 <-     PPU A10 <- / 73 74         08 07 \ <> PPU D3      <> PPU D5
         GND --      PPU A9 <- / 71 72           10 09 \ <- CLK         <> PPU D4
     PPU A8 <-      PPU A4 <- / 69 70             12 11 \ -> VIDEO       ?? ?
    PPU A7 <-      PPU A5 <- / 67 68               14 13 \ <- /RESET      -- VCC
 PPU /A13 <-      PPU A6 <- / 65 66                 16 15 \ <- $4017 D0    <- $4016 D2
 PPU /WE <-     PPU /RD <- / 63 64                   18 17 \ <- $4016 D0    <- AMP IN
   /IRQ <-          NC -- / 61 62                     20 19 \ -> $4016 CLK   <- $4017 D1
CPU R/W <-    CPU /RMS <- \ 59 60                     22 21 / -> AUDIO OUT   <- $4017 D2
  CPU A0 <-      CPU D0 <> \ 57 58                   24 23 / <- $4017 D3    <- $4016 D1
   CPU A1 <-      CPU D1 <> \ 55 56                 26 25 / <- $4017 D4    -> OUT0
    CPU A2 <-      CPU D2 <> \ 53 54               28 27 / -> OUT2        -> OUT1
     CPU D3 <>         VCC -- \ 51 52             30 29 / -- GND         -> AMP OUT
      CPU D4 <>      CPU A3 <- \ 49 50           32 31 / -- NC          -> $4017 CLK
       CPU D5 <>      CPU A4 <- \ 47 48         34 32 / -> CPU A11     -> CPU /RAM
        CPU D6 <>      CPU A5 <- \ 45 46       36 35 / -> CPU A10     -> CPU M2
         CPU D7 <>      CPU A6 <- \ 43 44     38 37 / -> CPU A9      -> CPU A12
         CPU A14 <-      CPU A7 <- \ 41 42   40 39 / -> CPU A8      -> CPU A13
                                    \_____________/

```

Applies also to TQFP80 version named 1818P [1]

Source: [2]

# SPCN 2810 pinout

Source: https://www.nesdev.org/wiki/SPCN_2810_pinout

```text
SPCN 2810 (from 8752, DIL28-600)
          .---v--.
 !RESET-> |01  28| +5V
CPU A12-> |02  27| <- CPU A14
CPU A7 -> |03  26| <- CPU A13
CPU A6 -> |04  25| <- CPU A8
CPU A5 -> |05  24| <- CPU R/!W
CPU A4 -> |06  23| -> !IRQ
CPU A3 -> |07  22| <- !ROMSEL
CPU A2 -> |08  21| <- MODE
CPU A1 -> |09  20| -> ROM !CE
CPU A0 -> |10  19| <- M2
CPU D0 -> |11  18| -> PRG A16
CPU D1 -> |12  17| -> PRG A15
CPU D2 -> |13  16| -> PRG A14
   GND    |14  15| -> PRG A13
          '------'

Registers:
                                               mask   power-up
$4022 [.... .BBB] - bank select (for mode 0)  $71ff   3 (when 4120.0 = 0) / 1 (when 4120.0 = 1)
$4120 [.... ...S] - bank swapping             $71ff   0
$4122 [.... ...I] - IRQ off/on                $f1ff   0
$8000 [.... .BBB] - bank select (for mode 1)  $8000   0

MODE - sets the chip to two different modes:

WHen MODE = 0:
| $6000 | $8000 | $a000 | $c000 | $e000 |
    $2      $1     $0    {$4022}    $a      (when $4120.0 = 0)
    $0      $0     $0    {$4022}    $8      (when $4120.0 = 1)
Bank at $c000 is switchable and can be changed by writing to $4022
written value                           : 0 1 2 3 4 5 6 7
bank will be switched to when $4120.0=0 : 4 3 5 3 6 3 7 3
bank will be switched to when $4120.0=1 : 1 1 5 1 4 1 5 1

$4122.0: when 0, irqs are disabled (any pending irq is acknowledged), when 1 - irqs are enabled
When IRQs are enabled, after 4096 rising edges of M2, IRQ is triggered
(if it is not acknowledged, after another 4096 rising edges of M2,
it will be automatically acknowledged)

---------------
When MODE = 1

| $6000 |     $8000     |     $c000     |
   OPEN      {$8000}            $7

Value written at $8000 is directly stored in the register (without any scrabling)

```

References: [1]

# Sachen 74LS374N pinout

Source: https://www.nesdev.org/wiki/Sachen_74LS374N_pinout

Sachen fake-marked “74LS374N”: 20-pin 0.3" DIP or epoxy blob on daughterboard.

```text
             .---V---.
     R5.0 <- | 01 20 | -- Vcc
CIRAM A10 <- | 02 19 | <- CPU A8
  PPU A11 -> | 03 18 | <- R/W
     R5.1 <- | 04 17 | <- M2
  CPU A14 -> | 05 16 | <- PPU A10
  CPU  A0 -> | 06 15 | <- /ROMSEL
  CPU  D0 <> | 07 14 | <> CPU  D2
  CPU  D1 <> | 08 13 | -> R6.1
     R2.0 <- | 09 12 | -> R6.0
      GND -- | 10 11 | -> R4.0
             '-------'

```

## Sachen SA-015 PCB (INES Mapper 150)

```text
             .---V---.
  PRG A15 <- | 01 20 | -- Vcc
CIRAM A10 <- | 02 19 | <- CPU A8
  PPU A11 -> | 03 18 | <- R/W
  PRG A16 <- | 04 17 | <- M2
  CPU A14 -> | 05 16 | <- PPU A10
  CPU  A0 -> | 06 15 | <- /ROMSEL
  CPU  D0 <> | 07 14 | <> CPU  D2 or Vcc, depending on solder pad setting
  CPU  D1 <> | 08 13 | -> CHR A14
      N/C <- | 09 12 | -> CHR A13
      GND -- | 10 11 | -> CHR A15
             '-------'

```

## Sachen SA-020A PCB (INES Mapper 243)

```text
             .---V---.
  PRG A15 <- | 01 20 | -- Vcc
CIRAM A10 <- | 02 19 | <- CPU A8
  PPU A11 -> | 03 18 | <- R/W
  PRG A16 <- | 04 17 | <- M2
  CPU A14 -> | 05 16 | <- PPU A10
  CPU  A0 -> | 06 15 | <- /ROMSEL
  CPU  D0 <> | 07 14 | <> CPU  D2
  CPU  D1 <> | 08 13 | -> CHR A16
  CHR A13 <- | 09 12 | -> CHR A15
      GND -- | 10 11 | -> CHR A14
             '-------'

```

# Sachen SA8259A pinout

Source: https://www.nesdev.org/wiki/Sachen_SA8259A_pinout

Sachen SA8259A: 28-pin 0.6" DIP

Most of Sachen's mapper ICs have names that collide with other well-known ICs, presumably as an initial round of indirection to confuse would-be mass copiers. The 8259A is canonically the original IBM PC's Programmable Interrupt Controller.

```text
              .---\/---.
   PRG A15 <- | 01  28 | -- Vcc
 CIRAM A10 <- | 02  27 | -> r42
   PPU A11 -> | 03  26 | <- CPU A8 (+CE)
   PPU A13 -> | 04  25 | -> rX0
   PPU /RD -> | 05  24 | <- R/W
         ? ?? | 06  23 | <- M2
   PRG A16 <- | 07  22 | <- PPU A12
   CPU A14 -> | 08  21 | <- PPU A10
   CPU  A0 -> | 09  20 | <- /ROMSEL
       rX1 <- | 10  19 | -> r41
   CPU  D0 -> | 11  18 | <- CPU D2
   CPU  D1 -> | 12  17 | -> r60
   PRG A17 <- | 13  16 | -> rX2
       GND -- | 14  15 | -> r40
              '--------'

```

The exact connectivity of the pins labelled r?? depends on the corresponding mapper number or name allocated.

| pin \ mapper | 137 | 138 | 139 | 141 |
| rX0 | CHR A10 | CHR A11 | CHR A13 | CHR A12 |
| rX1 | CHR A11 | CHR A12 | CHR A14 | CHR A13 |
| rX2 | CHR A12 | CHR A13 | CHR A15 | CHR A14 |
| r40 | CHR A14¹ | CHR A14 | CHR A16 | CHR A15 |
| r41 | CHR A14¹ | CHR A15 | CHR A17 | CHR A16 |
| r42 | CHR A14¹ | CHR A16 | CHR A18 | CHR A17 |
| r60 | CHR A13¹ | n/c | n/c | n/c |

¹: r40, r41, r42, and r60 go through a 74LS253 dual 4 to 1 multiplexer and a 74LS257 quad 2 to 1 multiplexer to produce 4x1+4F CHR banking

Reference: Cah4e3 ( http://cah4e3.shedevr.org.ru/%5Blst%5D-sachen-mappers.txt)
- Picture of box, cart, and PCB of Super Pang II

# Sunsoft 1 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_1_pinout

Sunsoft-1: 16 pin 0.3" PDIP (canonically mapper 184)

```text
                .---\/---.
 (f) PPU A12 -> |01    16| -- +5V
      (f) M2 -> |02    15| -> CHR A12 (r)
(fr) /ROMSEL -> |03    14| -> CHR A14 (r)
(fr) CPU A13 -> |04    13| -> CHR A13 (r)
(fr) CPU A14 -> |05    12| <- CPU RnW (f)
 (fr) CPU D5 -> |06    11| <- CPU D0 (fr)
 (fr) CPU D4 -> |07    10| <- CPU D1 (fr)
         GND -- |08    09| <- CPU D2 (fr)
                `--------'

```

NOTE: D6 is NOT connected. Games simply always write to the mapper with D6 set. The wiring for Fantasy Zone implies the virtual D6 is treated as though it were connected to +5V always.

Alternative wiring for Fantasy Zone :

```text
                .---\/---.
 (f) CPU A14 -> |01    16| -- +5V
      (f) M2 -> |02    15| -> PRG A14 (r)
(fr) /ROMSEL -> |03    14| -> PRG A16 (r)
(fr) CPU A13 -> |04    13| -> PRG A15 (r)
 (f) CPU A14 -> |05    12| <- CPU RnW (f)
         +5V -> |06    11| <- CPU D0 (fr)
         +5V -> |07    10| <- CPU D1 (fr)
         GND -- |08    09| <- CPU D2 (fr)
                `--------'

```

# Sunsoft 2 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_2_pinout

Sunsoft-2: 24 pin shrink PDIP (mappers 89and 93)

```text
                .---\/---.
 (r) PRG A15 <- | 01  24 | -- +5V
 (r) PRG A14 <- | 02  23 | <- CPU A14 (f)
 (r) PRG A16 <- | 03  22 | -> OR Y (CHR nCS) (r)
 (fr) CPU D7 -> | 04  21 | -> CHR A16 (r)
 (fr) CPU D6 -> | 05  20 | <- OR B (PPU nRD) (f, r?)
 (fr) CPU D5 -> | 06  19 | -> CHR A13 (r)
 (fr) CPU D4 -> | 07  18 | -> CHR A14 (r)
 (fr) CPU D3 -> | 08  17 | -> CHR A15 (r)
 (fr) CPU D2 -> | 09  16 | <- /ROMSEL (fr)
 (fr) CPU D1 -> | 10  15 | <- CPU RnW (f)
 (fr) CPU D0 -> | 11  14 | <- OR A (PPU A13) (f)
         GND -- | 12  13 | -> CIRAM A10 (f)
                `--------'

22 CHR nCS is the logical OR of PPU nRD and PPU A13, allowing them to use a 28-pin 128kB ROM
19 CHR A13 is connected to CHR RAM's positive chip enable, so games that use CHR RAM must write 1 to it

```

The Sunsoft-2 mapper was found on the Sunsoft-3and Sunsoft-3Rboards, which are identical besides the default setting for the 9 configuration jumpers.

The Sunsoft-3R board was by default jumpered for 8kB of CHR RAM; the Sunsoft-3 board for 128kB of CHR ROM.
- J1, J2 - CHR's nWR/A14 input: J1=PPU nWR (support CHR-RAM), J2=SS2 A14 (CHR bank bits are contiguous)
- J3, J4 - SS2's pin 20 input: J3=PPU nRD (support 28 pin 128KiB CHR ROM), J4=ground (support CHR-RAM)
- J5, J6 - CHR's nOE/A16 input: J5=SS2 A16 (support 28 pin 128KiB CHR ROM), J6=PPU nRD (support CHR-RAM)
- J7, J8, J9 - mirroring: J7=horizontal, J8=vertical, J9=mapper-controlled one-screen

This IC could be replaced with a 74377 and a 7432:

```text
                       74-377
                  .------\/------.
  (fr) /ROMSEL -> | /E 01  24 +5 | -- +5V
   (r) CHR A13 <- | Q0 02  23 Q7 | -> CHR A16 (r)
   (fr) CPU D0 -> | D0 03  22 D7 | <- CPU D7 (fr)
   (fr) CPU D1 -> | D1 04  21 D6 | <- CPU D6 (fr)
   (r) CHR A14 <- | Q1 05  20 Q6 | -> Q6
   (r) CHR A15 <- | Q2 06  19 Q5 | -> Q5
   (fr) CPU D2 -> | D2 07  18 D5 | <- CPU D5 (fr)
   (fr) CPU D3 -> | D3 08  17 D4 | <- CPU D4 (fr)
 (f) CIRAM A10 <- | Q3 09  16 Q4 | -> Q4
           GND -- | gn 10  15 CP | <- CPU RnW (f)
                  `--------------'

                       74--32
                  .------\/------.
            Q4 -> | A1 01  24 +5 | -- +5V
   (f) CPU A14 -> | B1 02  23 A4 | <- PPU nRD (f)
   (r) PRG A14 <- | Y1 03  22 B4 | <- PPU A13 (f)
            Q5 -> | A2 04  21 Y4 | -> CHR nCS (r)
   (f) CPU A14 -> | B2 05  20 A3 | <- Q6
   (r) PRG A15 <- | Y2 06  19 B3 | <- CPU A14 (f)
           GND -- | gn 07  18 Y3 | -> PRG A16 (r)
                  `--------------'

```

# Sunsoft 3 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_3_pinout

Sunsoft-3: 42-pin 0.6" shrink DIP (Canonically mapper 67)

```text
                .---\/---.
  delayed M2 -> | 01  42 | -- VCC
(n)       M2 -> | 02  41 | <- EXT /IRQ (n/c)
(nr) CPU A11 -> | 03  40 | <- CPU D7  (nr)
(nr) CPU A12 -> | 04  39 | <- CPU D6  (nr)
(nr) CPU A13 -> | 05  38 | <- CPU D5  (nr)
(n)  CPU A14 -> | 06  37 | <- CPU D4  (nr)
(n)  /ROMSEL -> | 07  36 | <- CPU D3  (nr)
(n)  CPU R/W -> | 08  35 | <- CPU D2  (nr)
(r)  PRG /CE <- | 09  34 | <- CPU D1  (nr)
(n)CIRAM A10 <- | 10  33 | <- CPU D0  (nr)
(r)  CHR /CE <- | 11  32 | -> /RAM-CE (n/c)
(nr) PPU A10 -> | 12  31 | -> RAM+CE  (n/c)
(n)  PPU A11 -> | 13  30 | <- PPU A13 (n)
(n)  PPU A12 -> | 14  29 | <- PPU /RD (n)
(r)  CHR A16 <- | 15  28 | -> /IRQ    (n)
(r)  CHR A15 <- | 16  27 | -> PRG A14 (r)
(r)  CHR A14 <- | 17  26 | -> PRG A15 (r)
(r)  CHR A13 <- | 18  25 | -> PRG A16 (r)
(r)  CHR A12 <- | 19  24 | -> PRG A17 (n/c)
(r)  CHR A11 <- | 20  23 | -> /PRG A17 (n/c)
     GND     -- | 21  22 | -> $f800.4 (n/c)
                '--------'

```

Notes:
- 1 is delayed by roughly 80ns by an external RC
- 1 and 2 must both be high to access registers or drive the RAM enables, and a rising edge of this combined signal clocks the IRQ counter.
- 7 is CPU /A15 in the Vs. System

Source: [ Krzysiobal]

# Sunsoft 4 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_4_pinout

Sunsoft 4: 40-pin 0.6" PDIP

```text
             .---\/---.
       M2 -> | 01  40 | -- +5V
  /ROMSEL -> | 02  39 | <- R/W
  CPU A14 -> | 03  38 | <- CPU D6
  CPU A13 -> | 04  37 | <- CPU D5
  CPU A12 -> | 05  36 | <- CPU D4
 PPU /A13 -> | 06  35 | <- CPU D3
  PPU A12 -> | 07  34 | <- CPU D2
  PPU A11 -> | 08  33 | <- CPU D1
  PPU A10 -> | 09  32 | <- CPU D0
     ?GND -> | 10  31 | <- OR A (PPU /RD)
  PRG /CE <- | 11  30 | <- OR B (SS4 /CHRSEL)
  CHR A17 <- | 12  29 | -> OR Y (CHR /CS)
  CHR A16 <- | 13  28 | -> CIRAM /CS
  CHR A15 <- | 14  27 | -> SS4 /CHRSEL
  CHR A14 <- | 15  26 | -> WRAM /CE
  CHR A13 <- | 16  25 | -> PRG A14
  CHR A12 <- | 17  24 | -> PRG A15
  CHR A11 <- | 18  23 | -> PRG A16
  CHR A10 <- | 19  22 | -> PRG A17
      GND -- | 20  21 | -> WRAM +CE
             `--------'

10 probably actually some control, not a supply pin
19 also connects to CIRAM A10
29,30,31 actually just an OR gate; for use with a 28-pin 128KB CHR-ROM

```

Reference: Naruko's notes

"NEC 65006-389" is legible on the die, indicating that this is a µPD65006 NEC CMOS-4A 1.5µ gate array with 504 pairs of 2P+2N MOSFETs.

Tengen's Sunsoft-4 seems to have a little modified pinout: [1]

```text
.. |
31 | <- OR A (PPU /RD)
30 | <- OR B (PPU A13)
29 | -> (NC?)
28 | -> CIRAM /CS
27 | -> (NC?)
26 | -> goes to NOR gate CHR roms decoder
.. |

```

# Sunsoft 5 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_5_pinout

Sunsoft FME-7(and Sunsoft 5B): 44-pin 0.8mm PQFP

```text
                           / \
                          / O \
         (nrw) CPU D3 -> /01 44\ <- CPU D2 (nrw)
                 varies /02   43\ <- CPU D4 (nrw)
             varies <- /03     42\ <- CPU D1 (nrw)
            (n) M2 -> /04       41\ <- CPU D5 (nrw)
      (n) CPU A13 -> /05         40\ <- CPU D0 (nrw)
             GND -- /06           39\ -- +5V
    (n) CPU A14 -> /07             38\ <- CPU D6 (nrw)
   (n) /ROMSEL -> /08               37\ <- CPU D7 (nrw)
(nrw) CPU R/W -> /09                 36\ -> PRG A13 (r)
    (n) /IRQ <- /10                   35\ -> PRG A16 (r)
(n) PPU /RD -> /11                     34\ -> PRG A14 (r)
(n) PPU A10 -> \12                     33/ -> PRG A15 (r)
 (n) PPU A11 -> \13                   32/ -> PRG A17 (r)
  (n) PPU A12 -> \14                 31/ -> PRG /CE (r)
   (n) PPU A13 -> \15               30/ -> PRG RAM /CE (w)
    (r) CHR /CE <- \16             29/ -> PRG RAM +CE (w)
             +5V -- \17           28/ -- GND
                  ?? \18         27/ varies
(nr) CHR/CIRAM A10 <- \19       26/ -> CHR A17 (r)
        (r) CHR A16 <- \20     25/ -> CHR A15 (r)
         (r) CHR A11 <- \21   24/ -> CHR A14 (r)
          (r) CHR A13 <- \22 23/ -> CHR A12 (r)
                          \   /
                           \ /
pin 2: Amplifier in (5B) or ?PRG A18 out (FME-7)?
pin 3: Amplifier out (5B)
pin 18: Audio /disable (5B) [1] - has internal pullup
pin 27: Audio out (5B) or +5V (FME-7)

n: connects to NES (CPU or PPU)
r: connects to ROM (PRG or CHR)
w: connects to WRAM

Expansion audio mixing circuit:[2]
                                     +                 +
           From S5B----/\/\/---+---||---+---/\/\/---+---||---To RF
           (S5B.27)    1K      |   1u   |   100K    |   1u   (Cart.46)
                               |        |           |
           From 2A03---/\/\/---+        |           |
           (Cart.45)   10K              |           |
                                        |           |
           Amp. In----------------------+           |
           (S5B.2)                                  |
                                                    |
           Amp. Out---------------------------------+
           (S5B.3)

```

On FME-7, the two ground supplies and three +5V supplies are shorted internally. Boards (like GRM-E301) that were used with the 5A or 5B did not connect pin 27 to +5V.

On FME-7, pin 3 has an overvoltage protection diode only; pin 18 has both over- and under- voltage protection diodes. Functionality is still not known.

# Sunsoft 6 pinout

Source: https://www.nesdev.org/wiki/Sunsoft_6_pinout

```text
   .---v---.
?? |01   20| ??
?? |02   19| ??
?? |03   18| ??
?? |04   17| ??
?? |05   16| ??
?? |06   15| ??
?? |07   14| ??
?? |08   13| ??
?? |09   12| ??
?? |10   11| ??
   '-------'
   SUNSOFT-6
Package SOP-20 300 mils, 0.05" pitch

```

Inputs: CPU-M2, CPU R/W, WRAM +CE, WRAM /CE

Outputs: PRG /CE

Source: [1]

# TXC 05-00002-010 pinout

Source: https://www.nesdev.org/wiki/TXC_05-00002-010_pinout

05-00002-010: 24-pin 0.3" DIP. (Mappers 036, 132, and 173)

```text
                .--\/--.
          Q2 <- |01  24| -> Q3
          Q1 <- |02  23| -> Q4
          Q0 <- |03  22| -> o3
          i1 -> |04  21| <- CPU A13 (rn)
          i0 -> |05  20| <- CPU A14 (rn)
         io2 <> |06  19| -- GND
          5V -- |07  18| <- CPU R/W (n)
          D5 <> |08  17| <- /ROMSEL (rn)
          D4 <> |09  16| <- M2 (n)
          D2 <> |10  15| <- CPU A8 (rn)
          D1 <> |11  14| <- CPU A1 (rn)
          D0 <> |12  13| <- CPU A0 (rn)
                '------'

```

There is a lot more functionality here than was used in any of the three mappers that used it.

```text
Mask: $E103
  Write $4103: [.... ...C] - Set/Clear Increment Mode
  Write $4101: [.... ...V] - Set/Clear Invert Mode. Also affects io2 and o3.

                             When clear, io2 relays i0. When set, io2 relays i1.
                             o3 is io2 OR D5 continuously.

                             If something externally overpowers io2, then:
                             When V is clear, o3 is i0 OR D5.
                             When V is set, o3 is io2 OR D5.

  Write $4102: [..RR .PPP] - D[5,4] -> R[5,4]. D[2,1,0] -> P[2,1,0]
                             P3 XOR V -> P3.
  Write $4100: [.... ....] - If Increment Mode is set, R[3,2,1,0] += 1
                             Otherwise, P[3,2,1,0] XOR V -> R[3,2,1,0]
Mask: $E100
  Read $4100:  [..RR .RRR] - R[5,4] XOR V -> D[5,4]. R[2,1,0] -> D[2,1,0]
Mask: $8000
  Write $8000: [.... ....] - R[3,2,1,0] -> Q[3,2,1,0]. R4 XOR V -> Q4.

```

On mapper 36, this ASIC is connected as:

```text
                .--\/--.
          NC <- |01  24| -> NC
 (r) PRG A16 <- |02  23| -> NC
 (r) PRG A15 <- |03  22| -> NC
         GND -> |04  21| <- CPU A13 (rn)
          5V -> |05  20| <- CPU A14 (rn)
          NC <> |06  19| -- GND
          5V -- |07  18| <- CPU R/W (n)
          NC <> |08  17| <- /ROMSEL (rn)
          NC <> |09  16| <- M2 (n)
          NC <> |10  15| <- CPU A8 (rn)
 (rn) CPU D5 <> |11  14| <- CPU A1 (rn)
 (rn) CPU D4 <> |12  13| <- CPU A0 (rn)
                '------'

```

On mapper 132:

```text
                .--\/--.
 (r) PRG A15 <- |01  24| -> NC
 (r) CHR A14 <- |02  23| -> NC
 (r) CHR A13 <- |03  22| -> NC
         GND -> |04  21| <- CPU A13 (fr)
          5V -> |05  20| <- CPU A14 (fr)
          NC <> |06  19| -- GND
          5V -- |07  18| <- CPU R/W (f)
         GND <> |08  17| <- /ROMSEL (fr)
 (fr) CPU D3 <> |09  16| <- M2 (f)
 (fr) CPU D2 <> |10  15| <- CPU A8 (fr)
 (fr) CPU D1 <> |11  14| <- CPU A1 (fr)
 (fr) CPU D0 <> |12  13| <- CPU A0 (fr)
                '------'

```

On mapper 173, labeled "ITC20V8-10LP"

```text
                .--\/--.
          NC <- |01  24| -> NC
*(r) CHR A15 <- |02  23| -> NC
 (r) CHR A13 <- |03  22| -> CHR A14
         GND -> |04  21| <- CPU A13 (fr)
          5V -> |05  20| <- CPU A14 (fr)
          NC <> |06  19| <- GND
          5V -- |07  18| <- CPU R/W (f)
         GND <> |08  17| <- /ROMSEL (fr)
 (fr) CPU D3 <> |09  16| <- M2 (f)
 (fr) CPU D2 <> |10  15| <- CPU A8 (fr)
 (fr) CPU D1 <> |11  14| <- CPU A1 (fr)
 (fr) CPU D0 <> |12  13| <- CPU A0 (fr)
                '------'

```

* TXC pin 2 was routed to CHR ROM pin 1 on a 28-pin package. On a UVEPROM, this is A15. However, no games were ever released using more than 32 KiB of CHR.

# Taito TC0190 pinout

Source: https://www.nesdev.org/wiki/Taito_TC0190_pinout

Taito TC0190: 0.6" 40-pin high-density PDIP (Canonically iNES Mapper 033)

```text
                 .--\/--.
  (fr) CPU D0 -> |01  40| -- Vcc
  (fr) CPU D1 -> |02  39| <- R/W (f)
  (fr) CPU D2 -> |03  38| <- /ROMSEL (f)
  (fr) CPU D3 -> |04  37| <- M2 (f)
  (fr) CPU D4 -> |05  36| -- n/c
  (fr) CPU D5 -> |06  35| -- n/c
  (fr) CPU D6 -> |07  34| <- PPU A10 (f)
  (fr) CPU D7 -> |08  33| <- PPU A11 (f)
  (r) PRG A13 <- |09  32| <- PPU A12 (f)
  (r) PRG A14 <- |10  31| -- GND
  (r) PRG A15 <- |11  30| -> CIRAM A10 (f)
  (r) PRG A16 <- |12  29| -> CHR A10 (r)
  (r) PRG A17 <- |13  28| -> CHR A11 (r)
  (r) PRG A18 <- |14  27| -> CHR A12 (r)
  (fr) CPU A0 -> |15  26| -> CHR A13 (r)
  (fr) CPU A1 -> |16  25| -> CHR A14 (r)
  (f) CPU A13 -> |17  24| -> CHR A15 (r)
  (f) CPU A14 -> |18  23| -> CHR A16 (r)
  (r) PRG /CE <- |19  22| -> CHR A17 (r)
          GND -- |20  21| -> CHR A18 (r)
                 '------'

```

Some boards added a PAL to the TC0190. As far as we can tell, the only purpose of the PAL was to move the mirroring control bit. This becomes a subset of iNES Mapper 048instead:

```text
TC0190 pin 30: (was CIRAM A10) now NC
TC0190 pin 38: (was /ROMSEL) now from PAL pin 12

                 PAL16R4
                  --\/--
  (f) /ROMSEL -> |01  20| -- Vcc
  (f) /ROMSEL -> |02  19| -> CIRAM A10 (f)
  (f)     R/W -> |03  18| ?? NC
  (f) CPU A14 -> |04  17| -> NC (latched value written to D6)
  (f) CPU A13 -> |05  16| -> NC
  (fr) CPU A1 -> |06  15| -> NC
  (fr) CPU A0 -> |07  14| -> NC
  (f) PPU A11 -> |08  13| <- CPU D6 (fr)
  (f) PPU A10 -> |09  12| -> to TC0190 pin 38
          GND -- |10  11| <- GND (PAL /OE signal)
                  ------

```

PALsallow the programming of arbitrary logic functions, but in the PAL16R4, pins 1 and 11 have fixed functionality. This is why /ROMSEL is connected to both pins 1 and pin 2: pin 1 can only be used as a clock input to latch the value of D6, but /ROMSEL is also connected to pin 2 so that the PAL can fail to pass through the write to the TC0190 when the CPU writes to $E000.

# Taito TC0350 pinout

Source: https://www.nesdev.org/wiki/Taito_TC0350_pinout

Taito TC0350: 0.6" 48-pin PDIP (Canonically iNES Mapper 033)

```text
           .--\/--.
    GND -- |01  48| -- VCC
?PRG A18?? |02  47| <- M2
PRG A16 <- |03  46| -> PRG A14
?PRG A17?? |04  45| -> PRG A13
PRG A15 <- |05  44| -> PRG /CE
CPU A13 -> |06  43| <- D7
CPU A14 -> |07  42| <- D6
 CPU A1 -> |08  41| <- D5
 CPU A0 -> |09  40| <- D4
     D0 -> |10  39| <- D3
     D1 -> |11  38| ?> ?CHR A18?
     D2 -> |12  37| -> CHR A17
/ROMSEL -> |13  36| -> CHR A14
CPU R/W -> |14  35| -> CHR A13
   /IRQ <- |15  34| <- PPU A8
PPU /RD -> |16  33| <- PPU A9
CHR A16 <- |17  32| <- PPU A10
CHR A15 <- |18  31| -> CHR A11
CHR A12 <- |19  30| <- PPU A11
 PPU A7 -> |20  29| -> CHR A10/CIRAM A10
 PPU A6 -> |21  28| <- PPU A12
 PPU A5 -> |22  27| -> CHR /OE
 PPU A4 -> |23  26| <- PPU A13
    GND -- |24  25| -- VCC
           .------.

```

# Taito TC0690 pinout

Source: https://www.nesdev.org/wiki/Taito_TC0690_pinout

Taito TC0690: 64-pin 1.0mm pitch QFP (Canonically iNES Mapper 048)

```text
                             _____
                     n/c -- /01 64\ -- n/c
                    n/c -- /02   63\ -- n/c
               CHR A15 <- /03 (o) 62\ -> CHR A16
              PPU /RD -> /04       61\ -> CHR A11
             CHR A18 <- /05         60\ -- n/c
            CHR A10 <- /06           59\ -- GND
          PPU A12* -> /07             58\ <- CPU D3
          PPU A11 -> /08               57\ -- VCC
             VCC -- /09                 56\ <- CPU D2
        PPU A10 -> /10                   55\ <- CPU D4
           GND -- /11                     54\ <- CPU D1
      CHR A13 <- /12                       53\ <- CPU D5
    PPU A13* -> /13    TAITO TC0690FMI      52\ -- n/c
    CHR A14 <- /14                          51/ -- n/c
   CHR A12 <- /15                          50/ -- n/c
CIRAM A10 <- /16                          49/ -- n/c
 CHR A17 <- /17                          48/ <- CPU D0
    n/c -- /18                          47/ <- CPU A1
   n/c -- /19                          46/ <- CPU D6
   n/c -- \20                         45/ <- CPU A0
   /IRQ <- \21                       44/ <- CPU D7
 /ROMSEL -> \22                     43/ -- GND
  PRG /CE <- \23                   42/ -> CHR /CE
   CPU R/W -> \24                 41/ -- VCC
        VCC -- \25               40/ <- M2
     PRG A15 <- \26             39/ -- n/c
          GND -- \27           38/ -> PRG A17
       PRG A13 <- \28         37/ <- CPU A13
        CPU A14 -> \29       36/ -> PRG A18
         PRG A16 <- \30     35/ -> PRG A14
              n/c -- \31   34/ -- n/c
               n/c -- \32 33/ -- n/c
                       \   /
                        \ /

```

Pins marked n/c appear to have no internal connection.

PPU A12 and A13 go through a multiplexer serving as a transparent latch, only permitting changes while PPU /RD is high.

Source: krzysiobal on the forum

# Taito X1-005 pinout

Source: https://www.nesdev.org/wiki/Taito_X1-005_pinout

Taito X1-005: 48-pin 0.6" PDIP (Canonically mapper 80).

```text
                .---\/---.
 (r) PRG A18 <- |01    48| -- VCC
 (f)      M2 -> |02    47| -> PRG A17 (r)
(fr) CPU A12 -> |03    46| -> PRG A15 (r)
 (f) CPU A13 -> |04    45| -> PRG A14 (r)
 (f) CPU A14 -> |05    44| -> PRG A13 (r)
 (fr) CPU A6 -> |06    43| <- CPU A8 (fr)
 (fr) CPU A5 -> |07    42| <- CPU A9 (fr)
 (fr) CPU A4 -> |08    41| <- CPU A11 (fr)
 (fr) CPU A3 -> |09    40| -> PRG A16 (r)
 (fr) CPU A2 -> |10    39| <- CPU A10 (fr)
 (fr) CPU A1 -> |11    38| <- /ROMSEL (fr)
 (fr) CPU A0 -> |12    37| <> PRG D7 (fr)
 (fr) CPU D0 <> |13    36| <> PRG D6 (fr)
 (fr) CPU D1 <> |14    35| <> PRG D5 (fr)
 (fr) CPU D2 <> |15    34| <> PRG D4 (fr)
 (f) CPU R/W -> |16    33| <> PRG D3 (fr)
 (r) CHR A17 <- |17    32| -> /RAMREGION
         GND -- |18    31| -> CIRAM A10 (f)
 (r) CHR A15 <- |19    30| -> CHR A14 (r)
 (r) CHR A12 <- |20    29| -> CHR A13 (r)
 (f) PPU A10 -> |21    28| -> CHR A11 (r)
 (f) PPU A11 -> |22    27| -> CHR A16 (r)
 (f) PPU A12 -> |23    26| -> CHR A10 (r)
        Vbat -- |24    25| -- internal RAM Vcc
                `--------'

```

Games with a battery add a diode from pin 24 to pin 25. It's not clear what pin 24 is for. Games never connect pin 25 straight to 5V.

Variant pinout for mapper 207:

```text
(f) CIRAM A10 <- |17    32| -- NC
          GND -- |18    31| -> NC

```

pin 32 "goes low for the whole duration of read/write cycle when address in 0x6000 .. 0x7FFF", or if the X1-005's internal RAM is enabled, only the region of 0x6000-0x7EFF.

Sources:
- BootGod
- Krzysiobal

# Taito X1-017 pinout

Source: https://www.nesdev.org/wiki/Taito_X1-017_pinout

Taito X1-017: 64-pin 0.6" shrink DIP (Canonically mapper 82)

```text
                   .---\/---.
$7EFA.5 (PRG A) <- |01    64| -- VCC
   (fw) CPU A13 -> |02    63| <- M2 (f)
   (frw) CPU A8 -> |03    62| -> $7EFA.0 (PRG A)
   (frw) CPU A7 -> |04    61| -> $7EFA.2 (PRG A)
   (frw) CPU A9 -> |05    60| -> $7EFA.1 (PRG A)
   (fw) CPU A14 -> |06    59| -> $7EFA.3 (PRG A)
  (frw) CPU A11 -> |07    58| -> $7EFA.4 (PRG A)
   (frw) CPU A6 -> |08    57| <- CPU A12 (frw)
   (frw) CPU A5 -> |09    56| -> delayed M2 by ~80ns, open collector
  (frw) CPU A10 -> |10    55| -> delayed M2 by ~80ns
   (frw) CPU A4 -> |11    54| -> delayed M2 by ~40ns
   (frw) CPU A3 -> |12    53| <- PRG RAM +CE (jumpered to pin 55 by default)
   (frw) CPU D7 <> |13    52| -- VCC
   (frw) CPU A2 -> |14    51| -- GND
   (frw) CPU D6 <> |15    50| -- PAD2 (NC)
   (frw) CPU A1 -> |16    49| -- VBAT (direct connect to positive battery terminal)
   (frw) CPU D5 <> |17    48| -- RAM VCC
   (frw) CPU A0 -> |18    47| -- GND
   (frw) CPU D4 <> |19    46| <- PRG RAM +WE (jumpered to pin 56 with C3+R2)
   (frw) CPU D0 <> |20    45| -> CHR0 /CE (lower 128KB ROM if two 128KB CHR ROMs)
   (frw) CPU D3 <> |21    44| -> CHR1 /CE (upper 128KB ROM if two 128KB CHR ROMs)
   (frw) CPU D1 <> |22    43| -- GND
   (frw) CPU D2 <> |23    42| -> CHR A11 (r)
    (f) CPU R/W -> |24    41| -> CIRAM A10 (f)
   (fr) /ROMSEL -> |25    40| -> CHR A17 (r)
       (f) /IRQ <- |26    39| <- PPU A10 (f)
            GND -- |27    38| -> CHR A16 (r)
 (PPU /RD) OR A -> |28    37| <- PPU A11 (f)
    (r) CHR A15 <- |29    36| -> CHR A10 (r)
    (r) CHR A14 <- |30    35| <- PPU A12 (f)
    (r) CHR A13 <- |31    34| -> OR Y (CHR /CE)
    (r) CHR A12 <- |32    33| <- OR B (PPU A13)
                   '--------'

```

Wiring of PRG address pins:
- OEM PCBs wires: $7EFA.5 as PRG-A13, $7EFA.4 as PRG-A14, $7EFA.3 as PRG-A15, $7EFA.2 as PRG-A16 and skips $7EFA.1 and $7EFA.0. Mapper 552 should be used to descibe it.
- The inaccurate definition of mapper 82 and all ROM dumps that are assigned to it assumes: $7EFA.5 as PRG-A16, $7EFA.4 as PRG-A15, $7EFA.3 as PRG-A14 and $7EFA.2 as PRG-A13 [1]

Sources:
- Ice Man's forum post
- Krzysiobal's forum post

# Tengen RAMBO-1 pinout

Source: https://www.nesdev.org/wiki/Tengen_RAMBO-1_pinout

Tengen 337006 or RAMBO-1: 40-pin 0.6" PDIP (Canonically mapper 64 )

```text
                  .--\/--.
        (n) M2 -> |01  40| -- +5V
   (r) PRG A16 <- |02  39| -> PRG A17 (r)
   (r) PRG A15 <- |03  38| <- CPU A13 (n)
   (r) PRG A13 <- |04  37| -> PRG A14 (r)
   (r) PRG /CE <- |05  36| <- CPU A14 (n)
   (rn) CPU D6 -> |06  35| <- CPU D7 (rn)
   (rn) CPU A0 -> |07  34| <- CPU D5 (rn)
   (rn) CPU D4 -> |08  33| <- CPU D0 (rn)
   (rn) CPU D2 -> |09  32| <- CPU D1 (rn)
       (n) R/W -> |10  31| <- CPU D3 (rn)
   (n) /ROMSEL -> |11  30| -> /IRQ (n)
   (r) CHR A10 <- |12  29| -> CIRAM A10 (n)
   (n) PPU A10 -> |13  28| -> CHR A11 (r)
   (n) PPU A12 -> |14  27| <- PPU A11 (n)
 (n) CIC toPak -> |15  26| -> CHR A13 (r)
  (n) CIC toMB <- |16  25| -> CHR A12 (r)
  (n) CIC +RST -> |17  24| -> CHR A14 (r)
   (n) CIC CLK -> |18  23| -> CHR A15 (r)
           GND ?? |19  22| -> CHR A17 (r)
           GND -- |20  21| -> CHR A16 (r)
                  '------'

```

Variant pinout for iNES Mapper 158:

```text
   (n) /ROMSEL -> |11  30| -> /IRQ (n)
   (r) CHR A10 <- |12  29| -> n/c
   (n) PPU A10 -> |13  28| -> CHR A11 (r)
   (n) PPU A12 -> |14  27| <- PPU A11 (n)
 (n) CIC toPak -> |15  26| -> CHR A13 (r)
  (n) CIC toMB <- |16  25| -> CHR A12 (r)
  (n) CIC +RST -> |17  24| -> CHR A14 (r)
   (n) CIC CLK -> |18  23| -> CHR A15 (r)
           GND ?? |19  22| -> CIRAM A10 (n)
           GND -- |20  21| -> CHR A16 (r)
                  '------'

```

On the PCB 800032, there are seven jumpers:
- R1 connects PRG ROM pin 22(28 pin IC)/24(32 pin IC) to ground, for use with ROMs that follow the standard EPROM pinout.
- R2 connects the same pin to RAMBO-1 PRG A16, for use with 28-pin 128 KiB JEDEC mask ROMs.

Exactly one of R1 and R2 should be populated.
- R3 connects CHR ROM pin 22(28 pin IC)/24(32 pin IC) to PPU /RD, for use with ROMs that follow the standard EPROM pinout.
- R4 connects the same pin to RAMBO-1 CHR A16, for use with 28-pin 128 KiB JEDEC mask ROMs.
- R5 (unlabeled, under the 74'32 socket) connects CHR ROM pin 20(28 pin IC)/22(32 pin IC) to PPU A13, for use with ROMs that follow the standard EPROM pinout.
- Populating the 74'32 in the upper right corner of the board connects CHR ROM pin 20(28 pin IC)/22(32 pin IC) to PPU /RD OR PPU A13 , for use with 28-pin 128 KiB JEDEC mask ROMs.

If R4 is populated, the 74'32 should be populated. Exactly one of R3 and R4 should be populated. Exactly one of R5 and the 74'32 should be populated.
- R6 and R7 tie the RAMBO-1's pins 15 and 17 to ground, respectively.

Additionally, there are two cut & solder jumpers:
- P28 (on the underside of the board) controls whether PRG pin 28(28 pin IC)/30(32 pin IC) is connected to +5V or to RAMBO-1 PRG A17.
- C28 controls whether CHR pin 28(28 pin IC)/30(32 pin IC) is connected to +5V or to RAMBO-1 CHR A17.

Source:
- Kevtris [1][2]
- FrankWDoom's Hard Drivin' reproduction

# UM5100 pinout

Source: https://www.nesdev.org/wiki/UM5100_pinout

UMC UM5100: 40-pin 0.6" PDIP (Used in an unlicensed reproduction of the only mapper 86game)

```text
                .--\/--.
/WRITE PULSE <- |01  40| -- +5V
         A12 <- |02  39| -> A14
          A7 <- |03  38| -> A13
          A6 <- |04  37| -> A8
          A5 <- |05  36| -> A9
          A5 <- |06  35| -> A11
          A3 <- |07  34| <- /RECORD
          A2 <- |08  33| -> A10
          A1 <- |09  32| -> /READ
          A0 <- |10  31| <> D7
          D0 <> |11  30| <> D6
          D1 <> |12  29| <> D5
          D2 <> |13  28| <> D4
          C1 -- |14  27| <> D3
          R1 -- |15  26| -> TD
      +RESET -> |16  25| -> ANG
       /PLAY -> |17  24| -> /TD
    COMPDATA -> |18  23| -> /ANG
CLOCK DRIVER <- |19  22| <- ENVELOPE
         GND -- |20  21| -> FILTER
                '------'

```

Source: BBS

# UM6558 and UM6559 pinout

Source: https://www.nesdev.org/wiki/UM6558_and_UM6559_pinout

UM6558 is PPU with additional 8 pins (CD0..CD7) that are used to output currently rendered pixel color.

```text
            .--\/--.
     R/W -> |01  48| -- +5V
  CPU D0 <> |02  47| -> ALE
  CPU D1 <> |03  46| <> PPU AD0
  CPU D2 <> |04  45| <> PPU AD1
  CPU D3 <> |05  44| <> PPU AD2
  CPU D4 <> |06  43| <> PPU AD3
  CPU D5 <> |07  42| <> PPU AD4
  CPU D6 <> |08  41| <> PPU AD5
  CPU D7 <> |09  40| <> PPU AD6
*    /CS -> |10  39| <> PPU AD7
* CPU A2 -> |11  38| -> PPU A8
* CPU A1 -> |12  37| -> PPU A9
* CPU A0 -> |13  36| -> PPU A10
     GND ?? |14  35| -> PPU A11
     GND ?? |15  34| -> PPU A12
     GND ?? |16  33| -> PPU A13
     GND ?? |17  32| -> /RD
*    VCC ?? |18  31| -> /WR
*    CLK -> |19  30| -> CD0   *
*   /INT <- |20  29| -> CD1   *
*   /RST -> |21  28| -> CD2   *
*    CD7 <- |22  27| -> CD3   *
*    CD6 <- |23  26| -> CD4   *
*    GND -- |24  25| -> CD5   *
            '------'

```
- = difference with respect to the common 40-pin PPU pinout

UM6559 is DAC that is capable of generating RED/GREEN/BLUE/SYNC/CHROMA/LUMA signals from of the CD0..CD7 values

```text
            .--\/--.
     CD4 -> |01  24| <- CD3
     CD5 -> |02  23| <- CD2
     +5V -- |03  22| <- CD1
      A1 -> |04  21| <- CD0
      A2 -> |05  20| -- GND
    LUMA <- |06  19| <- BIAS
   ?? NC -> |07  18| -> BLUE
    SYNC <- |08  17| -> GREEN
     CD6 -> |09  16| -> RED
     CD7 -> |10  15| -- +5V
     CLK -> |11  14| -> CHROMA
     GND -- |12  13| -> NC ??
            '------'

```

Sources:
- Emu-Land forum post with diagram showing difference between UM6558 vs UM6538
- Leaked short datasheet for UM6559
- Krzysiobal's reverse-engineering of UM6559 in isolation

# UM6561 pinout

Source: https://www.nesdev.org/wiki/UM6561_pinout

80-pin QFP

```text
                                    _____
                         PPU D0 <> /01 80\ -> PPU A13
                        PPU D7 <> /02   79\ -> PPU A0
                       PPU D1 <> /03 (o) 78\ -> PPU A12
                      PPU D6 <> /04       77\ -> PPU A1
                     PPU D2 <> /05         76\ -> PPU A11
                    PPU D5 <> /06           75\ -> PPU A2
                   PPU D3 <> /07             74\ -> PPU A10
                  PPU D4 <> /08               73\ -- GND
                  XTAL1 -> /09                 72\ -> PPU A3
                 XTAL2 -> /10                   71\ -> PPU A9
                  +5V -- /11                     70\ -> PPU A4
           VIDEO OUT <- /12                       69\ -> PPU A8
      AUDIO AMP OUT <- /13                         68\ -> PPU A5
      AUDIO AMP IN -> /14                           67\ -> PPU A7
        AUDIO OUT <- /15                             66\ -> PPU A6
             GND -- /16                               65\ -> PPU /A13
         /RESET -> /17                                64/ <- CIRAM A10
            ?? -> /18                                63/ <- CIRAM /CS
     $4016 D2 -> /19         UM6561                 62/ -> PPU /RD
    $4016 D0 -> /20                                61/ -> PPU /WE
   $4017 D0 -> /21                                60/ -- GND
  $4017 D1 -> /22                                59/ <- /IRQ
$4016 CLK <- /23                                58/ -> CPU /ROMSEL
$4017 D2 -> /24                                57/ -> CPU R/W
$4016 D1 -> \25                               56/ <> CPU D0
 $4017 D3 -> \26                             55/ -> CPU A0
      OUT0 <- \27                           54/ <> CPU D1
   $4017 D4 -> \28                         53/ -> CPU A1
        OUT1 <- \29                       52/ <> CPU D2
         OUT2 <- \30                     51/ -> CPU A2
     $4017 CLK -> \31                   50/ <> CPU D3
            +5V -- \32                 49/ -> CPU A3
         CPU A11 <- \33               48/ <> CPU D4
           CPU M2 <- \34             47/ -> CPU A4
           CPU A10 <- \35           46/ <> CPU D5
            CPU A12 <- \36         45/ -> CPU A5
              CPU A9 <- \37       44/ <> CPU D6
              CPU A13 <- \38     43/ -> CPU A6
                CPU A8 <- \39   42/ <> CPU D7
                CPU A14 <- \40 41/ -> CPU A7
                            \   /
                             \ /

```

Notes:
- UM6561AF-2: Dendy (50 Hz)
- UM6561F-1: NTSC [1]
- UM6561F-2: Dendy (50Hz) [2]

# UM6582 pinout

Source: https://www.nesdev.org/wiki/UM6582_pinout

United Microelectronics UM6582: 16-pin 0.3" PDIP (Used in the Stylandia's IQ-502 joypads)

```text
           .---v---.
  TURBO <- |01   16| -> TURBO/2
     /B -> |02   15| -> TURBO/4
 /START -> |03   14| <- /A
/SELECT -> |04   13| -- VCC
  /DOWN -> |05   12| -- GND
 /RIGHT -> |06   11| <- STROBE
    /UP -> |07   10| <- CLK
  /LEFT -> |08   09| -> D0
           '-------'

```

Notes:
- TURBO, TURBO/2, TURBO/4 can be used as turbo input for button A/B (on the tested pad, TURBO was used and other pins were NC),
- They toggle on the every / every second / every fourth rising edge of the (CLK and not STROBE) signal respectively and there is around 82ns delay between the transition
- After 8 edges of CLK signal, D0 goes low (on most pads, it goes high)

Source: [1]

# UNIF to NES 2.0 Mapping

Source: https://www.nesdev.org/wiki/UNIF_to_NES_2.0_Mapping

This page aims to list the NES 2.0equivalent header values of all known UNIFboard names.

Notes:
- Empty cells mean mapper-controlled mirroring and zero amounts of PRG-RAM, respectively. An empty CHR-RAM cell means zero amount of CHR-RAM unless the cart has no CHR-ROM, in which case it has 8K of CHR-RAM.
- Unless mentioned otherwise, PRG-RAM can be battery-backed if an UNIF BATT chunk is present. Boards using both battery-backed and non-backed RAM are denoted using the non-backed amount first, followed by a plus sign and the battery-backed amount.
- Common prefixes such as BMC-, BTL-, HVC-, NES-, UNL are omitted and replaced with *-.
- Compatible boards with the same stem but different prefixes or additional suffixes are not listed separately. For example, *-NROM includes NES-NROM-128-02 as well as IREM-NROM-128 as well.
- Board names are shown capitalized and with leading and trailing space characters removed, even as some UNIF image files do include MAPR chunks with leading or trailing space characters and lowercase letters.
- Because the tables do not list the maximum PRG- and CHR-ROM sizes for each board type for brevity, a reverse lookup of the correct UNIF MAPR for a given NES 2.0 header is not directly possible.
Nintendo-made boards

| UNIF MAPR | Mapper.Submapper | Mirroring | PRG-RAM | CHR-RAM | Notes |
| *-B4 | 4.0 |  |  |  |
| *-AMROM | 7.2 |  |  | 8K |  |
| *-ANROM | 7.1 |  |  | 8K |  |
| *-AN1ROM | 7.1 |  |  | 8K |  |
| *-AOROM | 7.x |  |  | 8K | x=1..2 depending on +CE wiring, or 0 if unknown |
| *-BNROM | 34.2 | H/V |  | 8K |  |
| *-CNROM | 3.2 | H/V |  |  |  |
| *-CNROM+SECURITY | 185.x | H/V |  |  | x=4..7 depending on diode configuration, or 0 if unknown |
| *-CPROM | 13.0 |  |  | 16K |  |
| *-FAMILYBASIC | 0.0 | V | 2K |  |  |
| *-EKROM | 5.0 |  | 8K |  |  |
| *-ELROM | 5.0 |  |  |  |  |
| *-ETROM | 5.0 |  | 8K+8K |  |  |
| *-EWROM | 5.0 |  | 32K |  |  |
| *-FJROM | 10.0 |  | 8K |  |  |
| *-FKROM | 10.0 |  | 8K |  |  |
| *-HROM | 0.0 | V |  |  |  |
| *-HKROM | 4.1 |  | 1K |  |
| *-NROM | 0.0 | H/V |  |  |  |
| *-PEEOROM | 9.0 |  |  |  |  |
| *-PNROM | 9.0 |  |  |  |  |
| *-RROM | 0.0 | H/V |  |  |  |
| *-RTROM | 0.0 | H/V |  |  |
| *-SROM | 0.0 | H/V |  |  |  |
| *-SAROM | 1.0 |  | 8K |  |  |
| *-SBROM | 1.0 |  |  |  |  |
| *-SCROM | 1.0 |  |  |  |  |
| *-SC1ROM | 1.0 |  |  |  |  |
| *-SEROM | 1.5 |  |  |  |  |
| *-SFROM | 1.0 |  |  |  |  |
| *-SF1ROM | 1.0 |  |  |  |  |
| *-SFEXPROM | 1.0 |  |  |  |  |
| *-SGROM | 1.0 |  |  | 8K |  |
| *-SHROM | 1.5 |  |  |  |  |
| *-SH1ROM | 1.5 |  |  |  |  |
| *-SIROM | 1.0 |  | 8K |  |  |
| *-SJROM | 1.0 |  | 8K |  |  |
| *-SKROM | 1.0 |  | 8K |  |  |
| *-SLROM | 1.0 |  |  |  |  |
| *-SL1ROM | 1.0 |  |  |  |  |
| *-SL2ROM | 1.0 |  |  |  |  |
| *-SL3ROM | 1.0 |  |  |  |  |
| *-SLRROM | 1.0 |  |  |  |  |
| *-SMROM | 1.0 |  |  | 8K |  |
| *-SNROM | 1.0 |  | 8K | 8K |  |
| *-SNWEPROM | 1.0 |  | 8K | 8K |  |
| *-SOROM | 1.0 |  | 8K+8K | 8K |  |
| *-SUROM | 1.0 |  | 8K | 8K |  |
| *-SXROM | 1.0 |  | 32K | 8K |  |
| *-TBROM | 4.0 |  |  |  |  |
| *-TEROM | 4.0 |  |  |  | Jumpers CL1/CL2 connected |
| *-TEROM | 4.2 | H/V |  |  | Jumpers CL1/CL2 disconnected |
| *-TFROM | 4.0 |  |  |  | Jumpers CL1/CL2 connected |
| *-TFROM | 4.2 | H/V |  |  | Jumpers CL1/CL2 disconnected |
| *-TGROM | 4.0 |  |  | 8K |  |
| *-TKROM | 4.0 |  | 8K |  |  |
| *-TK1ROM | 4.0 |  | 8K |  |  |
| *-TKEPROM | 4.0 |  | 8K |  |  |
| *-TKSROM | 118.0 |  | 8K |  |  |
| *-TLROM | 4.0 |  |  |  |  |
| *-TL1ROM | 4.0 |  |  |  |  |
| *-TL2ROM | 4.0 |  |  |  |  |
| *-TLSROM | 118.0 |  |  |  |  |
| *-TNROM | 4.0 |  | 8K | 8K |  |
| *-TQROM | 119.0 |  |  | 8K |  |
| *-TR1ROM | 4.0 | 4 |  |  |  |
| *-TSROM | 4.0 |  | 8K |  |  |
| *-TVROM | 4.0 | 4 |  |  |  |
| *-STROM | 0.0 | H/V |  |  |  |
| *-UNROM | 2.2 | H/V |  | 8K |  |
| *-UOROM | 2.2 | H/V |  | 8K |  |
Boards made by third-party licensees

| UNIF MAPR | Mapper.Submapper | Mirroring | PRG-RAM | CHR-RAM | Notes |
| ACCLAIM-MC-ACC | 4.3 |  |  |  |  |
| BANDAI-FCG-1 | 16.4 |  |  |  |  |
| BANDAI-FCG-2 | 16.4 |  |  |  |  |
| BANDAI-LZ93D50 | 16.5 |  |  |  |  |
| BANDAI-LZ93D50+24C01 | 159.0 |  | 128 |  |  |
| BANDAI-LZ93D50+24C02 | 16.5 |  | 256 |  |  |
| BANDAI-PT-554 | 3.2 | H |  |  | 1x Misc. ROM for M50805 |
| IREM-FCG-1 | 16.4 |  |  |  |  |
| JALECO-JF01 | 0.0 | H |  |  |  |
| JALECO-JF02 | 0.0 | H |  |  |  |
| JALECO-JF03 | 0.0 | H |  |  |  |
| JALECO-JF04 | 0.0 | H |  |  |  |
| JALECO-JF15 | 2.2 | V |  | 8K |  |
| JALECO-JF18 | 2.2 | V |  | 8K |  |
| JALECO-JF23 | 18.0 |  |  |  |  |
| JALECO-JF24 | 18.0 |  |  |  |  |
| JALECO-JF25 | 18.0 |  |  |  |  |
| JALECO-JF27 | 18.0 |  | 8K |  |  |
| JALECO-JF29 | 18.0 |  |  |  |  |
| JALECO-JF37 | 18.0 |  |  |  |  |
| JALECO-JF40 | 18.0 |  | 8K |  |  |
| NAMCOT-129 | 19.0 |  |  |  |  |
| NAMCOT-163 | 19.0 |  | 0 or 8K |  |  |
| NAMCOT-3301 | 0.0 | H |  |  |  |
| NAMCOT-3302 | 0.0 | V |  |  |  |
| NAMCOT-3303 | 0.0 | H |  |  |  |
| NAMCOT-3304 | 0.0 | H |  |  |  |
| NAMCOT-3305 | 0.0 | V |  |  |  |
| NAMCOT-3311 | 0.0 | H |  |  |  |
| NAMCOT-3312 | 0.0 | V |  |  |  |
| NAMCOT-CNROM+WRAM | 3.2 | H | 2K |  |  |
| NES-NTBROM | 68.1 |  | 8K |  |  |
| SUNSOFT_UNROM | 93.0 |  |  | 8K |  |
| KONAMI-QTAI | 547.0 |  | 8K+8K | 8K | UNIF uses 256 KiB 2bpp, NES 2.0 uses 128 KiB 1bpp CHR-ROM |
Boards made by unlicensed and bootleg publishers

| UNIF MAPR | Mapper.Submapper | Mirroring | PRG-RAM | CHR-RAM | Notes |
| *-SL1632 | 14.0 |  |  |  |  |
| *-AC-08 | 42.0 |  |  | 8K |  |
| *-LH-09 | 42.0 |  |  |  |  |
| *-SUPERVISION16IN1 | 53.0 |  |  | 8K | Final 8K moved to front |
| *-SUPERHIK8IN1 | 45.0 |  |  |  |  |
| *-STREETFIGTER-GAME4IN1 | 49.? |  |  |  | Sic. $6000 set to $41 rather than $00 on power-up. |
| *-MARIO1-MALEE2 | 42.0 |  | 2K |  |  |
| *-D1038 | 59.0 |  |  |  |  |
| *-T3H53 | 59.0 |  |  |  |  |
| *-SA-016-1M | 79.0 | H/V |  |  |  |
| *-VRC7 | 85.0 |  |  |  |  |
| *-SC-127 | 90.0 |  | 8K |  |  |
| *-BB | 108.0 |  |  |  |  |
| *-SL12 | 108.0 |  |  |  |  |
| *-H2288 | 123.0 |  |  |  |  |
| *-22211 | 132.0 | H/V |  |  |  |
| *-SA-72008 | 133.0 | H/V |  |  |  |
| *-T4A54A | 134.0 |  |  |  |  |
| *-SACHEN-8259D | 137.0 |  |  |  |  |
| *-SACHEN-8259B | 138.0 |  |  |  |  |
| *-SACHEN-8259C | 139.0 |  |  |  |  |
| *-SACHEN-8259A | 141.0 |  |  |  |  |
| *-KS7032 | 142.0 |  |  |  |  |
| *-SA-NROM | 143.0 |  |  |  |  |
| *-SA-72007 | 145.0 |  |  |  |  |
| *-TC-U01-1.5M | 147.0 |  |  |  |  |
| *-SA-0037 | 148.0 |  |  |  |  |
| *-SA-0036 | 149.0 |  |  |  |  |
| *-SACHEN-74LS374N | 150.0 |  |  |  |  |
| *-FS304 | 162.0 |  | 8K | 8K |  |
| *-SUPER24IN1SC03 | 176.0 |  |  | 8K |  |
| *-FK23C | 176.0 |  |  | 256K* | Up to 256K of CHR-RAM in the absence of CHR-ROM |
| *-FK23CA | 176.0 |  |  | 256K* | Up to 256K of CHR-RAM in the absence of CHR-ROM |
| WAIXING-FS005 | 176.0 |  | 32K | 8K |  |
| *-NOVELDIAMOND9999999IN1 | 201.0 |  |  |  |  |
| *-JC-016-2 | 205.0 |  |  |  |  |
| *-8237 | 215.0 |  |  |  |  |
| *-8237A | 215.1 |  |  |  |  |
| *-N625092 | 221.0 |  |  |  |  |
| *-GHOSTBUSTERS63IN1 | 226.0 |  |  |  |  |
| *-42IN1RESETSWITCH | 233.0 |  |  |  |  |
| *-150IN1A | 235.0 |  |  |  |  |
| *-212-HONG-KONG | 235.0 |  |  |  |  |
| *-70IN1 | 236.0 |  |  |  |  |
| *-70IN1B | 236.0 |  |  |  |  |
| *-603-5052 | 238.0 |  |  |  |  |
| WAIXING-FW01 | 227.0 |  | 8K |  |  |
| *-43272 | 227.0 |  | 8K |  |  |
| *-ONEBUS | 256.0 |  | 8K |  |  |
| *-DANCE | 256.0 |  |  |  |  |
| PEC-586 | 257.0 |  | 8K |  |  |
| *-158B | 258.0 |  |  |  |  |
| *-F-15 | 259.0 |  |  |  |  |
| *-HPXX | 260.0 |  | 8K |  |  |
| *-HP2018-A | 260.0 |  | 8K |  |  |
| *-810544-C-A1 | 261.0 |  |  |  |  |
| *-SHERO | 262.0 | 4 |  | 8K |  |
| *-KOF97 | 263.0 |  |  |  |  |
| *-YOKO | 264.0 |  |  |  |  |
| *-T-262 | 265.0 |  |  | 8K |  |
| *-CITYFIGHT | 266.0 |  |  |  |  |
| COOLBOY | 268.0 |  | 8K | 256K |  |
| MINDKIDS | 268.1 |  | 8K | 256K |  |
| *-22026 | 271.0 |  |  |  |  |
| *-80013-B | 274.0 |  |  | 8K |  |
| *-GKCXIN1 | 288.0 |  |  |  |  |
| *-GS-2004 | 283.0 |  |  | 8K |  |
| *-GS-2013 | 283.0 |  |  | 8K |  |
| *-A65AS | 285.0 |  |  | 8K |  |
| *-BS-5 | 286.0 |  |  |  |  |
| *-411120-C | 287.0 |  |  |  |  |
| *-K-3088 | 287.0 |  |  |  |  |
| *-60311C | 289.0 |  |  | 8K |  |
| *-NTD-03 | 290.0 |  |  |  |  |
| *-DRAGONFIGHTER | 292.0 |  |  |  |  |
| *-13IN1JY110 | 295.0 |  |  | 8K |  |
| *-TF1201 | 298.0 |  |  |  |  |
| *-11160 | 299.0 |  |  |  |  |
| *-190in1 | 300.0 |  |  |  |  |
| *-8157 | 301.0 |  |  | 8K |  |
| *-KS7057 | 302.0 |  |  | 8K |  |
| *-KS7017 | 303.0 |  | 8K | 8K |  |
| *-SMB2J | 304.0 |  |  |  |  |
| *-KS7031 | 305.0 |  |  | 8K |  |
| *-KS7016 | 306.0 |  |  | 8K |  |
| *-KS7037 | 307.0 |  | 8K | 8K |  |
| *-TH2131-1 | 308.0 |  |  |  |  |
| *-LH51 | 309.0 |  | 8K | 8K |  |
| *-LH32 | 125.0 |  | 8K | 8K |  |
| *-KS7013B | 312.0 |  |  | 8K |  |
| *-RESET-TXROM | 313.0 |  |  |  |  |
| *-64IN1NOREPEAT | 314.0 |  |  |  |  |
| *-830134C | 315.0 |  |  |  |  |
| *-HP898F | 319.0 |  |  |  |  |
| *-830425C-4391T | 320.0 |  |  | 8K |  |
| *-K-3033 | 322.0 |  |  |  |  |
| *-MALISB | 325.0 |  |  |  |  |
| *-10-24-C-A1 | 327.0 |  | 8K | 8K |  |
| *-RT-01 | 328.0 |  |  |  |  |
| *-EDU2000 | 329.0 |  | 32K | 8K |  |
| *-12-IN-1 | 331.0 |  |  |  |  |
| *-WS | 332.0 |  |  |  |  |
| *-NEWSTAR-GRM070-8IN1 | 333.0 |  |  |  |  |
| *-8-IN-1 | 333.0 |  |  |  |  |
| *-CTC-09 | 335.0 |  |  |  |  |
| *-K-3046 | 336.0 |  |  | 8K |  |
| *-CTC-12IN1 | 337.0 |  |  | 8K |  |
| *-SA005-A | 338.0 |  |  |  |  |
| *-K-3006 | 339.0 |  |  |  |  |
| *-K-3036 | 340.0 |  |  | 8K |  |
| *-TJ-03 | 341.0 |  |  |  |  |
| *-GN-26 | 344.0 |  |  |  |  |
| *-L6IN1 | 345.0 |  |  |  |  |
| *-KS7012" | 346.0 |  | 8K | 8K |  |
| *-KS7030 | 347.0 |  | 8K | 8K |  |
| *-830118C | 348.0 |  |  |  |  |
| *-G-146 | 349.0 |  |  | 8K |  |
| *-891227 | 350.0 |  |  | 8K |  |
| 3D-BLOCK | 355.0 |  |  | 8K | Requires 1x Misc. ROM for microcontroller |
| *-SA-9602B | 513.0 |  |  | 32K |  |
| *-DANCE2000 | 518.0 |  | 8K | 8K |  |
| *-EH8813A | 519.0 |  |  |  |  |
| DREAMTECH01 | 521.0 |  |  | 8K |  |
| *-LH10 | 522.0 |  | 8K | 8K |  |
| *-900218 | 524.0 |  |  |  |  |
| *-KS7021A | 525.0 |  |  |  |  |
| *-BJ-56 | 526.0 |  | 8K |  |  |
| *-AX-40G | 527.0 |  |  |  |  |
| *-831128C | 528.0 |  | 8K |  |  |
| *-T-230 | 529.0 |  |  |  |  |
| *-AX5705 | 530.0 |  |  |  |  |
Homebrew boards

| UNIF MAPR | Mapper.Submapper | Mirroring | PRG-RAM | CHR-RAM | Notes |
| COOLGIRL | 342.0 |  | 32K | 512K |  |
| *-DRIPGAME | 284.0 |  | 8K |  |  |
| FARID_SLROM_8-IN-1 | 323.0 |  |  |  |  |
| FARID_UNROM_8-IN-1 | 324.0 |  |  | 8K |  |
| RET-CUFROM | 29.0 |  |  | 32K |  |
So-far unassigned UNIF board names
- 81-01-31-C
- *-RESETNROM-XIN1
- CHINA_ER_SAN2
- *-GENERIC15IN1
- *-KS106C
- *-SB-2000
- SSS-NROM-256 (Famicom Box)
- *-SV01

# V7021 pinout

Source: https://www.nesdev.org/wiki/V7021_pinout

Sony/ASCII V7021: 28-pin 0.4" PDIP (Used in the French NES)

```text
              .--\/--.
       Gnd -- |01  28| <- Feedback clamp time constant
      Sync <- |02  27| <- Video
     Burst <- |03  26| <> Pedestal clamp time constant
    ACK TC <> |04  25| <> Chroma normalization time constant
    TP adj -> |05  24| <- Chroma
       Vcc -- |06  23| <- Chroma adj
   V phase <- |07  22| -- Vcc
       Vcc -- |08  21| -> Chroma
    APC TC <> |09  20| <- Delay Line Amplifier bias
   Hue Adj -> |10  19| <- Delay Line Amplifier
        X2 -> |11  18| -> Blue
        X1 <- |12  17| -> Green
       Gnd -- |13  16| -> Red
subcarrier <- |14  15| -- Gnd
              '------'

```
- ACK TC: "Auto Color Killer Time Constant"
- V phase: indicates whether PAL colorburst V component is inverted
- APC TC: "Auto Phase Control Time Constant"

See also:
- Reverse-engineered schematic as used in French NES

# VRC1 pinout

Source: https://www.nesdev.org/wiki/VRC1_pinout

There isn't a consistent pinout for the VRC1and its clones; here are two. The pins are mostly in the same order, but power and ground definitely move.

Anything with a ? next to it is uncertain; these pinouts were deduced solely based on images of the PCB.

VRC-1: 28-pin 0.6" DIP (canonically mapper 75 )

Labeled "Konami 8626K7 007422 VRC 075" on PCB labeled "Konami 302114A":

```text
                .--\/--.
 (r) PRG A15 <- |01  28| -- +5V
 (r) PRG A14 <- |02  27| <- CPU A14 (f)
(fr) CPU A12 -> |03  26| <- CPU A13 (f)
 (r) PRG A13 <- |04  25| <- PPU A12 (f)
 (r) PRG A16 <- |05  24| <- PPU A11 (fr)
 (fr) CPU D0 -> |06  23| <- PPU A10 (fr)
 (fr) CPU D1 -> |07  22| -> PRG nSEL (r)
 (fr) CPU D2 -> |08  21| <- CPU R/W (f)
 (fr) CPU D3 -> |09  20| -> CHR nSEL (r)
 (r) CHR A12 <- |10  19| <- PPU A13 (f)
 (r) CHR A14 <- |11  18| <- PPU nRD (f)
 (r) CHR A13 <- |12  17| -> CIRAM A10?
 (r) CHR A15 <- |13  16| <- CPU nROMSEL (f)
         Gnd -- |14  15| -> CHR A16 (r)
                `------'

```

Labeled "VRC 007421 8805 Z04" on PCB labeled "JALECO-20":

```text
               .--\/--.
(r) PRG A15 <- |01  28| <- CPU A14 (f)
   ?PRG A14 <- |02  27| <- CPU A13 (f)
   ?CPU A12 -> |03  26| <- CPU nROMSEL?
   ?PRG A13 <- |04  25| <- PPU A12?
(r) PRG A16 <- |05  24| <- PPU A11?
(fr) CPU D0 -> |06  23| <- CPU RnW (f)
        Gnd -- |07  22| -> PRG nSEL (r)
(fr) CPU D1 -> |08  21| -- +5V
(fr) CPU D2 -> |09  20| -> CHR nSEL?
(fr) CPU D3 -> |10  19| <- PPU A10?
   ?CHR A12 <- |11  18| <- PPU nRD (f)
(r) CHR A14 <- |12  17| -> CIRAM A10 (f)
   ?CHR A13 <- |13  16| <- (CPU nROMSEL OR CPU RnW)?
(r) CHR A15 <- |14  15| -> CHR A16 (r)
               `------'

```

# VRC2 pinout

Source: https://www.nesdev.org/wiki/VRC2_pinout

Konami VRC2 and VRC4: 0.6" 40-pin PDIP (iNES Mappers 21 , 22 , 23 , and 25 )

```text
 r: connects to ROM
 f: connects to Famicom

                     .--\/--.
      (f) CPU A13 -> |01  40| -- +5V
      (f) CPU A14 -> |02  39| -> PRG A17 (r)
      (fr) CPU Ax -> |03  38| -> PRG A15 (r)
      (fr) CPU Ay -> |04  37| <- CPU A12 (f)
      (f) PPU A12 -> |05  36| -> PRG A14 (r)
      (f) PPU A11 -> |06  35| -> PRG A13 (r)
      (f) PPU A10 -> |07  34| -> PRG A16 (r)
      (r) PRG /CE <- |08  33| <- CPU D0 (fr)
      (f) CPU R/W -> |09  32| <- CPU D1 (fr)
   (CHR /CE) OR Y <- |10  31| <- CPU D2 (fr)
   (PPU A13) OR B -> |11  30| <- CPU D4 (fr)
   (PPU /RD) OR A -> |12  29| <- CPU D3 (fr)
    (f) CIRAM A10 <- |13  28| -> CHR A17 (r)
      (f) /ROMSEL -> |14  27| -> CHR A15 (r)
           (f) M2 -> |15  26| -> CHR A12 (r)
 VRC4 (f) CHR A18 <- |16  25| -> CHR A14 (r)
    VRC4 (f) /IRQ <- |17  24| -> CHR A13 (r)
     VRC4 /WR9003 <- |18  23| -> CHR A11 (r)
    VRC4 WRAM /CE <- |19  22| -> CHR A16 (r)
              GND -- |20  21| -> CHR A10 (r)
                     `------'
 3, 4: see below

```

The VRC2's pins 16-19 seem to have been intended for a never-seen-used EEPROM

Konami was greatly fond of making minor variations from one game to the next, presumably to make life harder on pirates.

VRC4a, PCB 352398, mapper 21

```text
   (fr) CPU A2 -> |03  38| -> PRG A15 (r)
   (fr) CPU A1 -> |04  37| <- CPU A12 (f)

```

VRC4b, PCB 351406, mapper 25

```text
   (fr) CPU A0 -> |03  38| -> PRG A15 (r)
   (fr) CPU A1 -> |04  37| <- CPU A12 (f)

```

VRC2c, PCB 351948, mapper 25

```text
   (fr) CPU A0 -> |03  38| -> PRG A15 (r)
   (fr) CPU A1 -> |04  37| <- 74'139 /Y2[1]

```
- The additional logic evaluates (/ROMSEL OR CPUA12), preventing bus conflicts between the Microwire interface and the PRG RAM on the board by making I/O to $6000-$6FFF instead appear to the VRC2 to be happening to $7000-$7FFF

VRC4c, PCB 352889, mapper 21

```text
   (fr) CPU A7 -> |03  38| -> PRG A15 (r)
   (fr) CPU A6 -> |04  37| <- CPU A12 (f)

```

VRC4d, PCB 352400, mapper 25

```text
   (fr) CPU A2 -> |03  38| -> PRG A15 (r)
   (fr) CPU A3 -> |04  37| <- CPU A12 (f)

```

VRC4e, PCB 352396, mapper 23

```text
   (fr) CPU A3 -> |03  38| -> PRG A15 (r)
   (fr) CPU A2 -> |04  37| <- CPU A12 (f)

```

VRC2b, PCBs 350603, 350636, 350926, and 351179, mapper 23

```text
   (fr) CPU A1 -> |03  38| -> PRG A15 (r)
   (fr) CPU A0 -> |04  37| <- CPU A12 (f)

```

VRC2a, PCB 351618, mapper 22 (no submapper necessary)

```text
   (fr) CPU A0 -> |03  38| -> PRG A15 (r)
   (fr) CPU A1 -> |04  37| <- CPU A12 (f)
                  :      :
 (f) CIRAM A10 <- |13  28| -> CHR A16 (r)
   (f) /ROMSEL -> |14  27| -> CHR A14 (r)
        (f) M2 -> |15  26| -> CHR A11 (r)
 VRC2 µWire DO -> |16  25| -> CHR A13 (r)
 VRC2 µWire DI <- |17  24| -> CHR A12 (r)
 VRC2 µWire SK <- |18  23| -> CHR A10 (r)
 VRC2 µWire CS <- |19  22| -> CHR A15 (r)
           GND -- |20  21| -> n/c

```

The VRC2 µWire interface is thought to be nonfunctional.

Sources:
- https://web.archive.org/web/20140920211213/http://nintendoallstars.w.interia.pl/romlab/vrcp.htm
- http://forums.nesdev.org/viewtopic.php?t=8569

## Pirate clones

There exist pirate versionsof both VRC2 and VRC4. The pinout and operation is the same:
- VRC2: 23C3662, AX-40G, 23C269, AX5705, nameless
- VRC4: AX5208P, AX5208C, V4, PT8155

Note:
- PT8155 seems to have CHR-A17 and PRG-A17 (and maybe PRG-A18?) pins either broken, repurposed or not connected at all, because there exists at least one PCB with that chip (P-4073 PP-43KII, game Wai Wai World 2 ) that has additional logic to provide missing CHR-A17 and PRG-A17 lines (see schematic)

# VRC3 pinout

Source: https://www.nesdev.org/wiki/VRC3_pinout

VRC3: 18-pin PDIP ( mapper 73 )

```text
r: connects to PRG ROM
f: connects to Famicom
w: connects to PRG RAM
                 .-\_/-.
  (r) PRG A16 <- |01 18| -- +5V
  (r) PRG /CE <- |02 17| -> WRAM /CE (w)
  (r) PRG A14 <- |03 16| <- R/W      (wfr)
  (r) PRG A15 <- |04 15| <- CPU D3   (wfr)
  (f)      M2 -> |05 14| <- CPU D0   (wfr)
(wfr) CPU A12 -> |06 13| <- CPU D1   (wfr)
 (rf) CPU A13 -> |07 12| <- CPU D2   (wfr)
  (f) CPU A14 -> |08 11| <- /ROMSEL  (f)
          Gnd -- |09 10| -> /IRQ     (f)
                 '-----'

```

Kaiser seems to have made a subtle upgrade of the VRC3:

National Semiconductor KS202: 20-pin PDIP (canonically iNES Mapper 142)

```text
                 .-\_/-.
(wfr) CPU A12 -> |01 20| -> WRAM /CE (w)
  (f) CPU A13 -> |02 19| <- CPU D3   (wfr)
  (f) CPU A14 -> |03 18| <- R/W      (wfr)
          +5V -- |04 17| <- CPU D0   (wfr)
  (f)      M2 -> |05 16| <- CPU D1   (wfr)
  (r) PRG A14 <- |06 15| <- CPU D2   (wfr)
  (r) PRG A13 <- |07 14| -- GND
  (r) PRG A15 <- |08 13| <- RESET
  (r) PRG A16 <- |09 12| <- /ROMSEL  (f)
  (r) PRG /CE <- |10 11| -> /IRQ     (f)
                 '-----'

```

Source: [1]

# VRC5 pinout

Source: https://www.nesdev.org/wiki/VRC5_pinout

Konami VRCV: 80-pin QFP (canonically mapper 547)

```text
                                  _____
                       CPU A8 -> /01 80\ ? (goes to QTA 39, maybe PRG RAM A14?)
                         VCC -- /02   79\ <> CPU D0
                     CPU A9 -> /03 (o) 78\ <> CPU D1
                   CPU A10 -> /04       77\ <> CPU D2
                  CPU A11 -> /05         76\ <> CPU D3
                 CPU A12 -> /06           75\ <> CPU D4
                CPU A13 -> /07             74\ <> CPU D5
               CPU A14 -> /08               73\ -- VCC
              CPU R/W -> /09                 72\ <> CPU D6
           CPU /RMSL -> /10                   71\ <> CPU D7
                 M2 -> /11                     70\ <- PPU /WE
               GND -- /12                       69\ <- PPU /RD
             /IRQ <- /13                         68\ ? (goes to QTA 18, maybe PRG RAM A13?)
         CIR A10 <- /14                           67\ -> PRG RAM A12
    CHR RAM A12 <- /15                             66\ -> EXT PRG ROM0 /CE
        PPU A3 -> /16                               65\ -> EXT PRG ROM1 /CE
       PPU D0 <> /17                                64/ -> EXT PRG ROM2 /CE
      PPU D1 <> /18                                63/ -- GND
     PPU D2 <> /19         VRC 5                  62/ -> INT PRG ROM /CE
    PPU D3 <> /20                                61/ -> PRG A17
   PPU D4 <> /21                                60/ -> PRG A16
  PPU D5 <> /22                                59/ -> PRG A15
    GND -- /23                                58/ -> PRG A14
PPU D6 <> /24                                57/ -> PRG A13
PPU D7 <> \25                               56/ -> QTRAM /WE
 PPU A7 -> \26                             55/ -> INT PRG RAM /CE
  PPU A8 -> \27                           54/ -> EXT PRG RAM /CE
   PPU A9 -> \28                         53/ -> CHR ROM A16
   PPU A10 -> \29                       52/ -- GND
    PPU A11 -> \30                     51/ -> CHR ROM A15
     PPU A12 -> \31                   50/ -> CHR ROM A14
      PPU A13 -> \32                 49/ -> CHR ROM A13
           VCC -- \33               48/ -> CHR ROM A12
      CIRAM /CE <- \34             47/ -> CHR ROM A11
       QTRAM +CE <- \35           46/ <> QTRAM D7
      CHR ROM /CS <- \36         45/ <> QTRAM D6
       CHR RAM /CS <- \37       44/ <> QTRAM D5
           QTRAM D0 <> \38     43/ <> QTRAM D4
            QTRAM D1 <> \39   42/ -- GND
             QTRAM D2 <> \40 41/ <> QTRAM D3
                          \   /
                           \ /

```

Notes:
- CPU R/W (pin 9) and CPU /RMSL (pin 10) might be reversed

Source:
- BBS

# VRC6 pinout

Source: https://www.nesdev.org/wiki/VRC6_pinout

Konami VRC6: 48-pin 0.6" PDIP marked "053328 VRC VI", "053329 VRC VI", or "053330 VRC VI" (iNES Mappers 24and 26)

The Die of "053330" contains the markings "SLA7340 C3T0", a 1.5µ 2-metal-layer CMOS high speed gate array made by S-MOS Systems, a Seiko-Epson affiliate.

```text
                 .---\/---.
          GND -> | 01  48 | -- +5V
       AUD D1 <- | 02  47 | -> AUD D0
       AUD D3 <- | 03  46 | -> AUD D2
       AUD D5 <- | 04  45 | -> AUD D4
 (fr) CPU A12 -> | 05  44 | -> PRG A16 (r)
  (f) CPU A14 -> | 06  43 | <- CPU A13 (f)
       (f) M2 -> | 07  42 | -> PRG A17 (r)
  (r) PRG A14 <- | 08  41 | -> PRG A15 (r)
 (fr) CPU  A1 -> | 09  40 | -> PRG A13 (r)
 (fr) CPU  A0 -> | 10  39 | <- CPU D7 (fr)
 (fr) CPU  D0 -> | 11  38 | <- CPU D6 (fr)
 (fr) CPU  D1 -> | 12  37 | <- CPU D5 (fr)
 (fr) CPU  D2 -> | 13  36 | <- CPU D4 (fr)
  (r) PRG /CE <- | 14  35 | <- CPU D3 (fr)
      (f) R/W -> | 15  34 | <- /ROMSEL (f)
     WRAM /CE <- | 16  33 | -> /IRQ (f)
  (r) CHR /CE <- | 17  32 | -> CIRAM /CE (f)
  (f) PPU /RD -> | 18  31 | <- PPU A10 (f)
  (f) PPU A13 -> | 19  30 | <- PPU A11 (f)
  (r) CHR A16 <- | 20  29 | <- PPU A12 (f)
  (r) CHR A15 <- | 21  28 | -> CHR A17 (r)
  (r) CHR A12 <- | 22  27 | -> CHR A14 (r)
  (r) CHR A11 <- | 23  26 | -> CHR A13 (r)
          GND -- | 24  25 | -> CHR/CIRAM A10 (r)
                 `--------'

 1: On packages 053328 and 053330, ground supply. On 053329, an unknown input
 2-4, 45-47: goes to a 6 bit DAC, and then mixed with system audio
   The DAC is a 6-bit R-2R SIP resistor array with an additional internal 2K resistor in series to the output.[1]
                 3K     3K     3K     3K     3K            2K
       +------+-\/\/-+-\/\/-+-\/\/-+-\/\/-+-\/\/-+------+-\/\/-+
       |      |      |      |      |      |      |      |      |
       \      \      \      \      \      \      \      |      |
       /      /      /      /      /      /      /      |      |
       \ 6K   \ 6K   \ 6K   \ 6K   \ 6K   \ 6K   \ 6K   |      |
       /      /      /      /      /      /      /      |      |
       |      |      |      |      |      |      |      |      |
       O      O      O      O      O      O      O      O      O
      GND     D0     D1     D2     D3     D4     D5   To RF  From 2A03
                                                   (Cart.46) (Cart.45)

 9,10: VRC6a (Mapper 24: Akumajou Densetsu) is shown.  For VRC6b (Mapper 26: Madara, Esper Dream 2), these pins are swapped.
 16: passes through a small pulse-shaping network consisting of a resistor, diode, and capacitor.
 32: The VRC6 supports ROM nametables.

```

# VRC7 pinout

Source: https://www.nesdev.org/wiki/VRC7_pinout

Konami VRC7: 48-pin 0.6" PDIP marked: "VRC VII 053982" (canonically iNES Mapper 085 )

```text
                  .---\/---.
(PPU /RD) OR A -> | 01  48 | -> OR Y (NC)
(PPU A13) OR B -> | 02  47 | <- M2
           GND -- | 03  46 | -> PRG RAM /CE
           R/W -> | 04  45 | <- /ROMSEL
          /IRQ <+ | 05  44 | -> PRG ROM /CE
     CIRAM A10 <- | 06  43 | -> Audio Out
        CPU D0 <> | 07  42 | -- +5V
        CPU D1 <> | 08  41 | -> CHR A17
        CPU D2 <> | 09  40 | -> CHR A16
        CPU D3 <> | 10  39 | -> CHR A15
        CPU D4 <> | 11  38 | -> CHR A14
        CPU D5 <> | 12  37 | -> CHR A13
        CPU D6 <> | 13  36 | -> CHR A12
        CPU D7 <> | 14  35 | -> CHR A11
        /DEBUG -> | 15  34 | -> CHR A10
        CPU A5 -> | 16  33 | <- PPU A12
    Crystal X2 -> | 17  32 | <- PPU A11
    Crystal X1 <- | 18  31 | <- PPU A10
        CPU An -> | 19  30 | -- +5V
       PRG A13 <- | 20  29 | <- CPU A14
       PRG A14 <- | 21  28 | <- CPU A13
       PRG A15 <- | 22  27 | <- CPU A12
       PRG A16 <- | 23  26 | -> PRG A18
           GND -- | 24  25 | -> PRG A17
                  `--------'

 01,02: The OR gate on pins 1, 2, and 48 was intended for a 28-pin
         128KiB CHR ROM, but TTA2 doesn't use it. Perhaps it's too slow?
         This can be considered a general-purpose OR gate when not in debug mode.
 17,18: missing on TTA2, 3.58MHz ceramic resonator on LP
         Note: LP uses a 3-pin resonator, presumably with built-in loading caps.
         An equivalent 2-pin quartz resonator will require loading caps approx. 18pF.
                          _
                        || || 3.579545 MHz
         (VRC7.17) --+--|| ||--+-- (VRC7.18)
                     |  ||_||  |
                    ---       ---
               18pF ---       --- 18pF
                     |         |
                     +----+----+
                          |
                         GND
         (Your resonator's datasheet may make a suggestion for this value.)
 19: A3 on TTA2, A4 on LP

Expansion audio mixing circuit:[1]
   The audio is mixed through a ceramic daughterboard with a 9 pin SIP connector. Pins 4-6 are unconnected,
    since they were primarily used for laser trimming the resistors during production.

           From 2A03---o--+-----------+
           (Cart.45)      |           |
           To RF-------o--|           |
           (Cart.46)      |           |
           GND---------o--|           |
                          |           |
           NC          o--|           |
           (Mix.4)        |           |
           NC          o--|           |
           (Mix.5)        |           |
           NC          o--|           |
           (Mix.6)        |           |
           GND---------o--|           |
                          |           |
           From VRC7---o--|           |
           (VRC7.43)      |           |
           VCC---------o--+-----------+

Equivalent circuit schematic:
   The daughterboard uses a dual op-amp for amplification. Only one amplifier is used.

           From 2A03----------------------------------------------------/\/\/---+
           (Cart.45)                                          _         3.9K    |
                                                             | \                |
           From VRC7---+---/\/\/---+--------+----------------|+  \              |
           (VRC7.43)   /   27K     |        /                |IC.A>-+---/\/\/---+---To RF
                       \          ---       \             +--|-  /  |   2.2K        (Cart.46)
                       / 2.2K     --- 4.7n  / 33K         |  |_/    |
                       |           |        |             |  240K   |
                       +-----------+--------+     NC------+--/\/\/--+
                       |                          (Mix.5) /         |
                       | VCC---+-------+                  \         |
                       |  |  _ |       |                  / 4.3K    |
                       |  | | \|       |          NC------+         +---NC
                       |  +-|+  \     ---         (Mix.6) |         /   (Mix.4)
                       |  | |IC.B>--x --- 0.1u           ---        \
                       |  +-|-  /      |                 --- 0.22u  / 910
                       |    |_/|       |                  |         |
           GND---------+-------+-------+------------------+---------+

```

When the DEBUG pin is tied low, several pins gain function:

```text
                  .---\/---.
(PPU /RD) OR A -> | 01  48 | -> OR Y (NC)
          A(w) -> | 02  47 | <- A(y)
           GND -- | 03  46 | -> WRAM /CS
          A(x) -> | 04  45 | <- /ROMSEL
          /IRQ <+ | 05  44 | -> PRG /CS
                  :        :
       PRG A13 <- | 20  29 | <- CPU A14
       PRG A14 <- | 21  28 | <- A(z)
       PRG A15 <- | 22  27 | <- /IC
       PRG A16 <- | 23  26 | -> PRG A18
           GND -- | 24  25 | -> PRG A17
                  `--------'

```

For more information on debug mode, see VRC7 audio: Debug Mode

See also:
- Decap'ed VRC7: https://siliconpr0n.org/archive/doku.php?id=digshadow:konami:vrc_vii_053982
- Quietust's annotations for the above decap: https://www.qmtpro.com/~nes/chipimages/#vrc7
- More commentary on VRC7 DEBUG mode: https://siliconpr0n.org/archive/doku.php?id=vendor:yamaha:opl2#vrc7_debug_mode

# VT01 Pinout

Source: https://www.nesdev.org/wiki/VT01_Pinout

```text
                                        _____
                                       / 103 \ -> CPU A6
                               GND -- / 1 102 \ <> CPU D7
                                     /     101 \ -> CPU A7
                          CPU D6 <> / 2     100 \ -> CPU A11
                         CPU A5 <- / 3        99 \ -> CPU A8
                        CPU D5 <> / 4          98 \ -> CPU A13
                       CPU A4 <- / 5            97 \ -> CPU A9
                      CPU D4 <> / 6              96 \ -> CPU A12
                     CPU A3 <- / 7                95 \ -> CPU A10
                    CPU D3 <> / 8                  94 \ <- CPU Clock (1.8MHz)
                   CPU A2 <- / 9                    93 \ -> CPU A11
                  CPU D2 <> / 10                     92 \ ?? DIVF
                    GND -- / 11                       91 \ -- VCC
                   VCC -- / 12                         90 \ -> Audio
                  VCC -- / 13                           89 \ <- TFT LCD Select
              CPU A1 <- / 14                             88 \ -> Toggle Enable for LCD source driver
             CPU D1 <> / 15                               87 \ -> LCD Blue
            CPU A0 <- / 16                                 86 \ -> LCD Green
           CPU D0 <> / 17                                   85 \ -> LCD Vertical Start Pulse
         CPU R/W <- / 18                                     84 \ -> LCD /OE
        /ROMSEL <- / 19                                       83 \ -> LCD Red
          /IRQ -> / 20                                         82 \ -> STH
      PPU R/W <- / 21                                           81 \ -> CPH1
                /                                                80 \ -> CPH2
        GND -- / 22                                               79 \ -> CPH3
              /                                                    78 \ -- VCC
 Video /OE -> \ 23                                                  77 \ -- GND
    CPU A15 <- \ 24                                                  76 \ -- GND
    IVAB A10 -> \ 25                                                     \
        Power <- \ 26                                                 75 / <- JOYAM
        PPU A6 <- \ 27                                               74 / ?? CPU47
         PPU A7 <- \ 28                                             73 / <- JOYRTA
          PPU A5 <- \ 29                                           72 / -> IO1
           PPU A8 <- \ 30                                         71 / <- JOYDNA
               GND -- \ 31                                       70 / <- JOYLFA
             PPU A4 <- \ 32                                     69 / <- JOYUPA
              PPU A9 <- \ 33                                   68 / <- $4016.1
               PPU A3 <- \ 34                                 67 / <- JOYST
               PPU A10 <- \ 35                               66 / ?? CUP46
                 PPU A2 <- \ 36                             65 / <- JOYSE
                 PPU A11 <- \ 37                           64 / <- JOYBM
                   PPU A1 <- \ 38                         63 / -> Clock Crystal Output
                   PPU A12 <- \ 39                       62 / <- Clock Crystal Input
                     PPU A0 <- \ 40                     61 / <- /RST
                         VCC -- \ 41                   60 / <- TEST
                    EXROM /CS -> \ 42                 59 / -- VCC
                        PPU D0 <> \ 43               58 / -> Video
                         PPU D7 <> \ 44             57 / <- REG1
                          PPU D1 <> \ 45           56 / <- REG0
                           PPU D6 <> \ 46         55 / <> PPU D4
                            JOYSEL -> \ 47       54 / <> PPU D3
                              LCDGD -> \ 48     53 / <> PPU D5
                                VCOM -> \ 49   52 / <> PPU D2
                                  Q2H -> \ 50 51 / -- GND
                                          -------

```
- IVAB A10: Internal Video Address A10
- Power: Power On signal, default high, low if $2001(D6)=1 or no any pushed for 5 minutes
- LCDGD: Clock input for gate driver of TFT LCD Driver.
- VCOM: Common electrode voltage control of TFT LCD Driver
- Q2H: Video input rotation control of TFT LCD Driver
- REGx: Region Selector. All 0 = NTSC; All 1 = PAL
- CPHx: Sampling and shift clock for source driver of TFT LCD Driver
- STH: Start pulse for source driver of TFT LCD Driver

Based on http://www.vrt.com.tw/old_site/admin/upload/datasheet/VT01%20Data%20Sheet%20RevisionA2_ENG_.pdf

# VT02 / VT03 pinout

Source: https://www.nesdev.org/wiki/VT02_/_VT03_pinout

```text
                             _______
                            /    91 \ -- GND
                   /CS0 <- / 1    90 \ -> CPU A5
                  /CS1 <- / 2      89 \ <> CPU D6
               CPU D5 <> / 3        88 \ -> CPU A6
             CPU A14 <- / 4          87 \ <> CPU D7
             CPU D3 <> / 7            86 \ -> CPU A7
            CPU A2 <- / 8              85 \ -> CPU A14
           CPU D2 <> / 9                84 \ -> CPU A8
          CPU A1 <- / 10                 83 \ -> CPU A13
            GND -- / 11                   82 \ -> CPU A9
        CPU D1 <> / 12                     81 \ -> CPU A12
       CPU A0 <- / 13                       80 \ -> CPU A10
      CPU D0 <> / 14                         79 \ <- CPU CLK (1.8MHz)
        R/W <- / 15                           78 \ -- VCC
   /ROMSEL <- / 16                             77 \ -> CPU A11
     /IRQ -> / 17                               76 \ <- $4016.0
 PPU R/W <- / 18                                 75 \ <> IOCLK1
    VDE <- / 19                                   74 \ <> IO2
    VCC -- \ 20                                    73 \ -> IO1
     ERS <- \ 21                                    72 \ <- $4017.4
CIRAM A10 -> \ 22                                    71 \ -> IO0
    PPU A6 <- \ 23                                    70 \ <- $4017.3
     PPU A7 <- \ 24                                    69 \ <- $4016.1
      PPU A5 <- \ 25                                    68 \ <- $4017.2
       PPU A8 <- \ 26                                    67 \ <> IOCLK0
        PPU A4 <- \ 27                                    66 \ <- $4017.1
         PPU A9 <- \ 28                                    65 \ <- /FH
          PPU A3 <- \ 29                                   64 / -- VCC
          PPU A10 <- \ 30                                 63 / <- /BTS
            PPU A2 <- \ 31                               62 / <- $4017.0
            PPU A11 <- \ 32                             61 / -> Crystal Out
                 VCC -- \ 33                           60 / <- Crystal In
               PPU A1 <- \ 34                         59 / <- /IJSE
               PPU A12 <- \ 35                       58 / <- /16B
                 PPU A0 <- \ 36                     57 / <- OBS
                    /ERS -- \ 37                   56 / -- GND
                   /SFCCS -- \ 38                 55 / -> Audio Out 1
                    PPU D0 <> \ 39               54 / -> Audio Out 0
                     PPU D7 <> \ 40             53 / <- /RST
                      PPU D1 <> \ 41           52 / <- Test Pin
                       PPU D6 <> \ 42         51 / -> VOUT
                        PPU D2 <> \ 43       50 / <- REG0
                         PPU D5 <> \ 44     49 / <- REG1
                          PPU D3 <> \ 45   48 / <- /LCDEN
                           PPU D4 <> \ 46 47 / -- GND
                                      \_____/

```
- /CS0: /CS for $6000 - $7FFF
- /CS1: /CS for $8000 - $FFFF
- VDE: Video Data Output Enable; I/O in OneBus Mode
- ERS: External ROM chip selector / Power on Indicator / I/O in OneBus Mode
- /SFCCS: Swap the function of /CS0 and /CS1 when low
- /LCDEN: Enable LCD Output for Testing
- REGx: Region Selector. All 0 = NTSC, All 1 = PAL
- OBS: OneBus Mode Enable
- /16B: 16 bits data bus selector in OneBus Mode. A0 will decide the low byte or high byte of data on CPU D0-7
- /IJSE: Internal Joystick Enable when XJOYSEL = 0
- /BTS: Bus tristate enable
- /FH: Force /CS0 and /CS1 High
- IOCLKx: Clock of I/O or XCUP47, can be video extention address
- IOx: I/O interface Output pins or Video extention address

### Sources
- VT02 Datasheet: http://www.vrt.com.tw/old_site/admin/upload/datasheet/VT02%20Data%20Sheet%20RevisionA5_ENG__1.pdf
- VT03 Datasheet: http://www.vrt.com.tw/old_site/admin/upload/datasheet/VT03%20Data%20Sheet%20RevisionA6_ENG.pdf

# VT02 / VT03 pinout

Source: https://www.nesdev.org/wiki/VT02_pinout

```text
                             _______
                            /    91 \ -- GND
                   /CS0 <- / 1    90 \ -> CPU A5
                  /CS1 <- / 2      89 \ <> CPU D6
               CPU D5 <> / 3        88 \ -> CPU A6
             CPU A14 <- / 4          87 \ <> CPU D7
             CPU D3 <> / 7            86 \ -> CPU A7
            CPU A2 <- / 8              85 \ -> CPU A14
           CPU D2 <> / 9                84 \ -> CPU A8
          CPU A1 <- / 10                 83 \ -> CPU A13
            GND -- / 11                   82 \ -> CPU A9
        CPU D1 <> / 12                     81 \ -> CPU A12
       CPU A0 <- / 13                       80 \ -> CPU A10
      CPU D0 <> / 14                         79 \ <- CPU CLK (1.8MHz)
        R/W <- / 15                           78 \ -- VCC
   /ROMSEL <- / 16                             77 \ -> CPU A11
     /IRQ -> / 17                               76 \ <- $4016.0
 PPU R/W <- / 18                                 75 \ <> IOCLK1
    VDE <- / 19                                   74 \ <> IO2
    VCC -- \ 20                                    73 \ -> IO1
     ERS <- \ 21                                    72 \ <- $4017.4
CIRAM A10 -> \ 22                                    71 \ -> IO0
    PPU A6 <- \ 23                                    70 \ <- $4017.3
     PPU A7 <- \ 24                                    69 \ <- $4016.1
      PPU A5 <- \ 25                                    68 \ <- $4017.2
       PPU A8 <- \ 26                                    67 \ <> IOCLK0
        PPU A4 <- \ 27                                    66 \ <- $4017.1
         PPU A9 <- \ 28                                    65 \ <- /FH
          PPU A3 <- \ 29                                   64 / -- VCC
          PPU A10 <- \ 30                                 63 / <- /BTS
            PPU A2 <- \ 31                               62 / <- $4017.0
            PPU A11 <- \ 32                             61 / -> Crystal Out
                 VCC -- \ 33                           60 / <- Crystal In
               PPU A1 <- \ 34                         59 / <- /IJSE
               PPU A12 <- \ 35                       58 / <- /16B
                 PPU A0 <- \ 36                     57 / <- OBS
                    /ERS -- \ 37                   56 / -- GND
                   /SFCCS -- \ 38                 55 / -> Audio Out 1
                    PPU D0 <> \ 39               54 / -> Audio Out 0
                     PPU D7 <> \ 40             53 / <- /RST
                      PPU D1 <> \ 41           52 / <- Test Pin
                       PPU D6 <> \ 42         51 / -> VOUT
                        PPU D2 <> \ 43       50 / <- REG0
                         PPU D5 <> \ 44     49 / <- REG1
                          PPU D3 <> \ 45   48 / <- /LCDEN
                           PPU D4 <> \ 46 47 / -- GND
                                      \_____/

```
- /CS0: /CS for $6000 - $7FFF
- /CS1: /CS for $8000 - $FFFF
- VDE: Video Data Output Enable; I/O in OneBus Mode
- ERS: External ROM chip selector / Power on Indicator / I/O in OneBus Mode
- /SFCCS: Swap the function of /CS0 and /CS1 when low
- /LCDEN: Enable LCD Output for Testing
- REGx: Region Selector. All 0 = NTSC, All 1 = PAL
- OBS: OneBus Mode Enable
- /16B: 16 bits data bus selector in OneBus Mode. A0 will decide the low byte or high byte of data on CPU D0-7
- /IJSE: Internal Joystick Enable when XJOYSEL = 0
- /BTS: Bus tristate enable
- /FH: Force /CS0 and /CS1 High
- IOCLKx: Clock of I/O or XCUP47, can be video extention address
- IOx: I/O interface Output pins or Video extention address

### Sources
- VT02 Datasheet: http://www.vrt.com.tw/old_site/admin/upload/datasheet/VT02%20Data%20Sheet%20RevisionA5_ENG__1.pdf
- VT03 Datasheet: http://www.vrt.com.tw/old_site/admin/upload/datasheet/VT03%20Data%20Sheet%20RevisionA6_ENG.pdf

# WR550400/WR550402 pinout

Source: https://www.nesdev.org/wiki/WR550400/WR550402_pinout

```text
         .---v---.
   D7 -> |01   18| <- D0
   D1 -> |02   17| ------------[R=750k]-+
   D6 -> |03   16| -> MAIN CLK----------+
   D2 -> |04   15| -- GND
   D5 -> |05   14| -> SONG3 PLAYED
   D3 -> |06   13| -> SONG3 FINISHED STROBE
   D4 -> |07   12| -> DATA
  +5V -  |08   11| -> CLK1 (for audio data ?)
AUDIO <- |09   10| -> CLK2 (for meta data?)
         `-------`
     WR550400/WR550402

```

Notes:
- Those 2 chips were used in bootleg version of Moe Pro! Saikyou-hen Baseball [1], along with pirate VRC4 chip. Original game used Jaleco SS88006 along with D7756C ADPCM Speech Chip [2]
- Each of those 2 chips contains different set of 8 audio samples, used in game.
- Vendor logo printed on ICs suggest that the manufacturer was Winbond,
- Forcing rising edge on one of its D0..D7 inputs enables playback adequate audio sample
- The output "analog" audio has 32-voltage-levels,
- Along with the analog audio, there is some digital data transmitted on pins 12/11/10
- Pin 14 is high for the whole time when D2 audio sample is played,
- Pin 13 goes high for the last 0.5ms when D2 audio sample is played.

# YM2413 pinout

Source: https://www.nesdev.org/wiki/YM2413_pinout

Yamaha YM2413 or ??? K-663A: 18-pin 0.3" PDIP (used in Mapper 515). Also used as a cheaper and similar-sounding substitute for the VRC7in the TNS-HFX4.

```text
        .--\/--.
 GND -- |01  18| <> D1
  D2 <> |02  17| <> D0
  D3 <> |03  16| -- +5V
  D4 <> |04  15| -> RHYTHM OUT
  D5 <> |05  14| -> MELODY OUT
  D6 <> |06  13| <- /RESET
  D7 <> |07  12| <- /CE
 XIN -> |08  11| <- R/W
XOUT <- |09  10| <- A0
        '------'

```

Sources: [1], [2]

# Cartridge connector

Source: https://www.nesdev.org/wiki/Cartridge_connector

## Pinout of 60-pin Famicom consoles and cartridges

This diagram represents a top-down view looking directly into the connector. Pins 01–30 are on the label side of the cartridge, left to right.

The pitch, or pin spacing, of this connector is 2.5 4 mm. This corresponds to 0.1 inch.

```text
  (front)                 (back)
  Famicom    | Cart  |    Famicom
              -------
      GND -- |01   31| -> CartridgePresent or 5V supply, depending
  CPU A11 -> |02   32| <- M2
  CPU A10 -> |03   33| <- CPU A12
   CPU A9 -> |04   34| <- CPU A13
   CPU A8 -> |05   35| <- CPU A14
   CPU A7 -> |06   36| <> CPU D7
   CPU A6 -> |07   37| <> CPU D6
   CPU A5 -> |08   38| <> CPU D5
   CPU A4 -> |09   39| <> CPU D4
   CPU A3 -> |10   40| <> CPU D3
   CPU A2 -> |11   41| <> CPU D2
   CPU A1 -> |12   42| <> CPU D1
   CPU A0 -> |13   43| <> CPU D0
  CPU R/W -> |14   44| <- /ROMSEL (/A15 + /M2)
     /IRQ <- |15   45| <- Audio from 2A03
      GND -- |16   46| -> Audio to RF
  PPU /RD -> |17   47| <- PPU /WR
CIRAM A10 <- |18   48| -> CIRAM /CE
   PPU A6 -> |19   49| <- PPU /A13
   PPU A5 -> |20   50| <- PPU A7
   PPU A4 -> |21   51| <- PPU A8
   PPU A3 -> |22   52| <- PPU A9
   PPU A2 -> |23   53| <- PPU A10
   PPU A1 -> |24   54| <- PPU A11
   PPU A0 -> |25   55| <- PPU A12
   PPU D0 <> |26   56| <- PPU A13
   PPU D1 <> |27   57| <> PPU D7
   PPU D2 <> |28   58| <> PPU D6
   PPU D3 <> |29   59| <> PPU D5
      +5V -- |30   60| <> PPU D4
              -------

```
- pin 31: On certain revisions of the RF modulator board, pin 31 connects only to the TV/Game switch on the RF modulator board, meaning that the RF modulator is only allowed to send video if a cartridge connects pin 30 to pin 31. On other RF modulator board revisions, pin 31 is connected to the normal 5V supply.

## Pinout of 72-pin NES consoles and cartridges

This diagram represents a top-down view looking directly into the connector. On a front-loader, pins 01–36 are the top side of the connector. Pins 36–01 are on the label side of the cartridge, left to right.

The pitch, or pin spacing, of this connector is 2.5 0 mm. This does NOT correspond to 0.1 inch.

```text
 (front/top)           (back/bottom)
      NES    | Cart  |    NES
              -------
      +5V -- |36   72| -- GND
 CIC toMB <- |35   71| <- CIC CLK
CIC toPak -> |34   70| <- CIC +RST
   PPU D3 <> |33   69| <> PPU D4
   PPU D2 <> |32   68| <> PPU D5
   PPU D1 <> |31   67| <> PPU D6
   PPU D0 <> |30   66| <> PPU D7
   PPU A0 -> |29   65| <- PPU A13
   PPU A1 -> |28   64| <- PPU A12
   PPU A2 -> |27   63| <- PPU A10
   PPU A3 -> |26   62| <- PPU A11
   PPU A4 -> |25   61| <- PPU A9
   PPU A5 -> |24   60| <- PPU A8
   PPU A6 -> |23   59| <- PPU A7
CIRAM A10 <- |22   58| <- PPU /A13
  PPU /RD -> |21   57| -> CIRAM /CE
    EXP 4    |20   56| <- PPU /WR
    EXP 3    |19   55|    EXP 5
    EXP 2    |18   54|    EXP 6
    EXP 1    |17   53|    EXP 7
    EXP 0    |16   52|    EXP 8
     /IRQ <- |15   51|    EXP 9
  CPU R/W -> |14   50| <- /ROMSEL (/A15 + /M2)
   CPU A0 -> |13   49| <> CPU D0
   CPU A1 -> |12   48| <> CPU D1
   CPU A2 -> |11   47| <> CPU D2
   CPU A3 -> |10   46| <> CPU D3
   CPU A4 -> |09   45| <> CPU D4
   CPU A5 -> |08   44| <> CPU D5
   CPU A6 -> |07   43| <> CPU D6
   CPU A7 -> |06   42| <> CPU D7
   CPU A8 -> |05   41| <- CPU A14
   CPU A9 -> |04   40| <- CPU A13
  CPU A10 -> |03   39| <- CPU A12
  CPU A11 -> |02   38| <- M2
      GND -- |01   37| <- SYSTEM CLK
              -------

```

## Additional pinout notes
- For the Famicom: most chips and components appear on the opposite side of the PCB from the label in Famicom cartridges. (Nintendo boards follow this convention, but third party boards vary.)
- For the NES: most chips and components appear on the label side of the PCB in NES cartridges.
- Active-Low signals are indicated by a / (slash) symbol.
- The NES and Famicom connectors have a similar arrangement; the connector on the NES is mostly a mirror image of the Famicom's.
- Most cartridge PCBs made by Nintendo are numbered the same way as indicated in these diagrams.

## Comparison

| Pin(s) | 60-pinFamicom | 72-pinNES |
| +5V, GND | ✓ | ✓ |
| CPU A0-A14, D0-D7, R/W, M2, /ROMSEL, /IRQ |
| PPU A0-A13, D0-D7, /RD, /WR, /A13 |
| CIRAM A10, /CE |
| Audio in/out | ✓ | ✗ |
| CartridgePresent |
| CIC pins | ✗ | ✓ |
| EXP 0-9 |
| SYSTEM CLK |

## Signal descriptions
- +5V : 5V Power supply from the main voltage regulator.
- GND : 0V power supply.
- SYSTEM CLK : Main oscillator frequency output. It is only available on 72-pin connectors, and its speed varies between NTSC (21MHz) and PAL (27MHz) machines.
- M2 : Also called PHI2 (φ2) in official docs (however, see the CPU M2 and CLK descriptionfor additional details). This is the CPU clock output. When this signal is high, this means only that the CPU bus address is in a stable state. For both reads and writes, data is only guaranteed or required to be valid at the falling edge of this signal.
- CPU R/W : The Read/Write signal output from the CPU. This signal is high during CPU reads and low during CPU writes (switches from one mode to another only when M2 is low).
- CPU A0..A14 : Also called just A0..A14 in official docs, or CPU A0..A14 (to not confuse with address outputs of mapperssharing the same number). This is the CPU address bus. It is stable when M2 is high. Note that A15 exists, but is not directly available on the connector.
- CPU D0..D7 : Also called just D0..D7 in official docs, or CPU D0..D7. This is the CPU bidirectional data bus. It goes high impedance on reads, allowing external memory chips to place their data here.
- /ROMSEL : This pin outputs the logical NAND of M2 and CPU A15. It is low when the CPU reads or writes to $8000 – $FFFF and when the address is stable, allowing to enable ROM chips directly. Advanced mappersuse more logic between this pin and the actual PRG /CE (to avoid bus conflicts, for example). Using this signal is the only way to determine the state of A15, so it's needed for any mappers doing any address decoding.
- /IRQ : Interrupt request input. Pull low to trigger an interrupt to the CPU. There is an internal pull-up resistor in the NES/Famicom, so it can be left floating if interrupts aren't used. NES hardware can safely pull the pin high or low, but PlayChoice-10modules must treat it as an open-collector input.
- Audio from 2A03 : Audio output from the 2A03's sound generation hardware, already amplified. Only exists with 60-pins connectors.
- Audio to RF : Usually just tied to the audio from 2A03. This one goes directly to the sound output of the console. This allows cartridges to mix audio with their own audio sources. This is not directly present on 72-pins connectors.
- EXP0..9 : These connect to the expansion porton the bottom of the NES-001 and have no predefined meaning, so they can be used by any cartridge and expansion device pair for whatever purpose. EXP6 has become the standard for expansion audio. See EXP pinsfor detailed pin usage.
- PPU /WR : Also called /WE in official docs. This signal is low when the PPU is writing. On its falling edge, the address and data are stable.
- PPU /RD : Also called /RD in official docs. This signal is low when the PPU is reading. On its falling edge, the address is stable, and the data should be stable until its rising edge.
- PPU A0..A13 : Also called PA0..13 in official docs. This is the PPU's address bus. Most boards tie PA13 directly to the /CE of CHR ROM or CHR RAM to map it into pattern tablespace ( $0000 – $1FFF ) without any extra logic.
- PPU D0..D7 : Also called PD0..7 in official documentation. This is the PPU's bidirectional data bus. Goes high impedance when PPU /RD goes low allowing memory devices to place their data here.
- PPU /A13 : The inverted form of PPU A13. Typically used to map nametablesand attribute tablesto $2000 – $3FFF .
- CIRAM /CE : Also called VRAM /CS. This signal is used as an input to enable the internal 2k of VRAM (used for name table and attribute tables typically, but could be made for another use). This signal is usually directly connected with PPU /A13, but carts using their own RAM for name table and attribute tables will have their own logic implemented.
- CIRAM A10 : Also called VRAM A10. This is the 1k bank selection input for internal VRAM. This is used to control how the name tables are banked; in other words, this selects nametable mirroring. Connect to PPU A10 for vertical mirroring or PPU A11 for horizontal mirroring. Connect it to a software operated latch to allow bank switching of two separate name tables in single-screen mirroring (as in AxROM). Many mappers have software operated mirroring selection: they multiplex PPU A10 and PPU A11 into this pin, selected by a latch.
- CIC +RST and CIC CLK : On the top-loading NES-101, these two are connected to +5V and PPU D4 respectively. The other two CIC pins float.

# CPU ALL

Source: https://www.nesdev.org/wiki/CPU_ALL

CPU

The NES CPU core is based on the 6502 processor and runs at approximately 1.79 MHz (1.66 MHz in a PAL NES). It is made by Ricohand lacks the MOS6502's decimal mode. In the NTSC NES, the RP2A03chip contains the CPU and APU; in the PAL NES, the CPU and APU are contained within the RP2A07chip.

## Sections
- CPU instructions
- CPU addressing modes
- CPU memory map
- CPU power-up state
- CPU registers
- CPU status flag behavior
- CPU interrupts
- Unofficial opcodes
- CPU pin-out and signals, and other hardware pin-outs

## Frequencies

The CPU generates its clock signal by dividing the master clock signal.

| Rate | NTSC NES/Famicom | PAL NES | Dendy |
| Color subcarrier frequency fsc (exact) | 3579545.45 Hz (315/88 MHz) | 4433618.75 Hz | 4433618.75 Hz |
| Color subcarrier frequency fsc (approx.) | 3.579545 MHz | 4.433619 MHz | 4.433619 MHz |
| Master clock frequency 6fsc | 21.477272 MHz | 26.601712 MHz | 26.601712 MHz |
| Clock divisor d | 12 | 16 | 15 |
| CPU clock frequency 6fsc/d | 1.789773 MHz (~559 ns per cycle) | 1.662607 MHz (~601 ns per cycle) | 1.773448 MHz (~564 ns per cycle) |

* The vast majority of PAL famiclones use a chipset or NOAC with this timing. A small number have UMC UA6540+6541, which also uses PAL NES timing. [1]

## Notes
- All illegal 6502 opcodes execute identically on the 2A03/2A07.
- Every cycle on 6502 is either a read or a write cycle.
- A printer friendly version covering all section is available here.
- Emulator authors may wish to emulate the NTSC NES/Famicom CPU at 21441960 Hz ((341×262−0.5)×4×60) to ensure a synchronised/stable 60 frames per second. [2]

## See also
- Cycle reference chart
- 2A03 technical referenceby Brad Taylor. (Pretty old at this point; information on the wiki might be more up-to-date.)

## References
- ↑nesdev forum: Eugene.S provides a list of famiclones
- ↑nesdev forum: Mesen - NES Emulator
Memory map

| Address range | Size | Device |
| $0000–$07FF | $0800 | 2 KB internal RAM |
| $0800–$0FFF | $0800 | Mirrors of $0000–$07FF |
| $1000–$17FF | $0800 |
| $1800–$1FFF | $0800 |
| $2000–$2007 | $0008 | NES PPU registers |
| $2008–$3FFF | $1FF8 | Mirrors of $2000–$2007 (repeats every 8 bytes) |
| $4000–$4017 | $0018 | NES APU and I/O registers |
| $4018–$401F | $0008 | APU and I/O functionality that is normally disabled. See CPU Test Mode. |

| $4020–$FFFF• $6000–$7FFF• $8000–$FFFF | $BFE0$2000$8000 | Unmapped. Available for cartridge use.Usually cartridge RAM, when present.Usually cartridge ROM and mapper registers. |
- Some parts of the 2 KiB of internal RAM at $0000–$07FF have predefined purposes dictated by the 6502 architecture:
  - $0000-$00FF: The zero page, which can be accessed with fewer bytes and cycles than other addresses
  - $0100–$01FF: The page containing the stack, which can be located anywhere here, but typically starts at $01FF and grows downward
Games may divide up the rest however the programmer deems useful. See Sample RAM mapfor an example allocation strategy for this RAM. Most commonly, $0200-$02FF is used for the OAM buffer to be copied to PPU OAM during vblank.
- The unmapped space at $4020-$FFFF can be used by cartridges for any purpose, such as ROM, RAM, and registers. Many common mappers place ROM and save/work RAM in these locations:
  - $6000–$7FFF: Battery-backed save or work RAM (usually referred to as WRAM or PRG-RAM)
  - $8000–$FFFF: ROM and mapper registers (see MMC1and UxROMfor examples)
The cartridge is able to passively observe reads from and writes to any address in the CPU address space, even outside this unmapped space, except for reads from $4015, the only readable register that is internal to the CPU. The cartridge can map writable registers anywhere, but its readable memory can only be placed where it does not interfere with other readable hardware, which would produce a bus conflict. While cartridges can map readable memory at $4000-$4014 and $4018-$401F, a quirk in the 2A03's register decoding can cause DMA to misbehave if the CPU is halted while reading from $4000-$401F, so it is recommended that cartridges only map readable memory from $4020-$FFFF.
- If using DPCM playback, samples are limited to the following practical range:
  - $C000–$FFF1: DPCM sample data
Sample playback wraps around from $FFFF to $8000. The highest sample starting address is $FFC0 and longest sample is $FF1 bytes, so the full DPCM range is $C000-$FFFF and $8000-$8FB0, but making use of the wraparound is challenging because of banking and the presence of the CPU vectors.
- The CPU expects interrupt vectors in a fixed place at the end of the unmapped space:
  - $FFFA–$FFFB: NMI vector, which points at an NMIhandler
  - $FFFC–$FFFD: Reset vector, which points at code to initialize the NES chipset
  - $FFFE–$FFFF: IRQ/BRK vector, which may point at a mapper's interrupthandler (or, less often, a handler for APU interrupts)
These vectors are supplied by the cartridge. Unless a mapper fixes $FFFA–$FFFF to some known bank (normally by fixing an entire bank-sized region at the top of the address space, such as $C000-$FFFF, to a specific bank) or uses some sort of reset detection, the vectors (and a suitable reset code stub) must be present in all banks.
- Reading from memory that is not mapped to anything normally returns open bus. The cartridge hardware may affect open bus behavior across the entire CPU address space, such as by pulling bits high or low.
Pin out and signal description

### Pin out

```text
        .--\/--.
 AD1 <- |01  40| -- +5V
 AD2 <- |02  39| -> OUT0
/RST -> |03  38| -> OUT1
 A00 <- |04  37| -> OUT2
 A01 <- |05  36| -> /OE1
 A02 <- |06  35| -> /OE2
 A03 <- |07  34| -> R/W
 A04 <- |08  33| <- /NMI
 A05 <- |09  32| <- /IRQ
 A06 <- |10  31| -> M2
 A07 <- |11  30| <- TST (usually GND)
 A08 <- |12  29| <- CLK
 A09 <- |13  28| <> D0
 A10 <- |14  27| <> D1
 A11 <- |15  26| <> D2
 A12 <- |16  25| <> D3
 A13 <- |17  24| <> D4
 A14 <- |18  23| <> D5
 A15 <- |19  22| <> D6
 GND -- |20  21| <> D7
        `------'

```

### Signal description

Active-Low signals are indicated by a "/". Every cycle is either a read or a write cycle.
- CLK : 21.47727 MHz (NTSC) or 26.6017 MHz (PAL) clock input. Internally, this clock is divided by 12 (NTSC 2A03) or 16 (PAL 2A07) to feed the 6502's clock input φ0, which is in turn inverted to form φ1, which is then inverted to form φ2. φ1 is high during the first phase (half-cycle) of each CPU cycle, while φ2 is high during the second phase.
- AD1 : Audio out pin (both pulse waves).
- AD2 : Audio out pin (triangle, noise, and DPCM).
- Axx and Dx : Address and data bus, respectively. Axx holds the target address during the entire read/write cycle. For reads, the value is read from Dx during φ2. For writes, the value appears on Dx during φ2 (and no sooner).
- OUT0..OUT2 : Output pins used by the controllers ($4016 output latch bits 0-2). These 3 pins are connected to either the NESor Famicom'sexpansion port, and OUT0 is additionally used as the "strobe" signal (OUT) on both controller ports.
- /OE1 and /OE2 : Controller ports (for controller #1 and #2 respectively). Each enable the output of their respective controller, if present.
- R/W : Read/write signal, which is used to indicate operations of the same names. Low is write. R/W stays high/low during the entire read/write cycle.
- /NMI : Non-maskable interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- /IRQ : Interrupt pin. See the 6502 manual and CPU interruptsfor more details.
- M2 : Can be considered as a "signals ready" pin. It is a modified version the 6502's φ2 (which roughly corresponds to the CPU input clock φ0) that allows for slower ROMs. CPU cycles begin at the point where M2 goes low.
  - In the NTSC 2A03E, G, and H, M2 has a duty cycleof 15/24 (5/8), or 350ns/559ns. Equivalently, a CPU read (which happens during the second, high phase of M2 ) takes 1 and 7/8th PPU cycles. The internal φ2 duty cycle is exactly 1/2 (one half).
  - In the PAL 2A07, M2 has a duty cycle of 19/32, or 357ns/601ns, or 1.9 out of 3.2 pixels.
  - In the original NTSC 2A03 (no letter), M2 has a duty cycle of 17/24, or 396ns/559ns, or 2 and 1/8th pixels.
- TST: (tentative name) Pin 30 is special: normally it is grounded in the NES, Famicom, PC10/VS. NES and other Nintendo Arcade Boards (Punch-Out!! and Donkey Kong 3). But if it is pulled high on the RP2A03G, extra diagnostic registers to test the sound hardware are enabled from $4018 through $401A, and the joystick ports $4016 and $4017 become open bus. On the RP2A07 and the RP2A03E [1], pulling pin 30 high instead causes the CPU to stop execution by means of deactivating the embedded 6502's /RDY input.
- /RST : When low, holds CPU in reset state, during which all CPU pins (except pin 2) are in high impedance state. When released, CPU starts executing code (read $FFFC, read $FFFD, ...) after 6 M2 clocks.

## References
- ↑https://forums.nesdev.org/viewtopic.php?p=304145#p304145
Power up state

Initial tests on the power-up/reset state of the CPU/APU and RAM contents were done using an NTSC front-loading NES from 1988 with a RP2A03G CPU on the NES-CPU-07 board revision.

Countless bugs in commercialand homebrewgames exist because of a reliance on the initial system state. An NES programmer should not rely on the state of CPU/APU registers and RAM contents not guaranteed at power-up/reset.

## CPU

| Register | At Power | After Reset |
| A, X, Y | 0 | unchanged |
| PC | ($FFFC) | ($FFFC) |
| S[1] | $00 - 3 = $FD | S -= 3 |
| C | 0 | unchanged |
| Z | 0 | unchanged |
| I | 1 | 1 |
| D | 0 | unchanged |
| V | 0 | unchanged |
| N | 0 | unchanged |

## APU

| Register | At Power | After Reset |
| Pulses ($4000-$4007) | 0 | unchanged? |
| Triangle ($4008-$400B) | 0 | unchanged? |
| Triangle phase | ? | 0 (output = 15) |
| Noise ($400C-$400F) | 0 | unchanged? |
| Noise 15-bit LFSR | $0000 (all 0s, first clock shifts in a 1)[2] | unchanged? |
| DMC flags and rate ($4010)[3] | 0 | unchanged |
| DMC direct load ($4011)[3] | 0 | [$4011] &= 1 |
| DMC sample address ($4012)[3] | 0 | unchanged |
| DMC sample length ($4013)[3] | 0 | unchanged |
| DMC LFSR | 0? (revision-dependent?) | ? (revision-dependent?) |
| Status ($4015) | 0 (all channels disabled) | 0 (all channels disabled) |
| Frame Counter ($4017) | 0 (frame IRQ enabled) | unchanged |
| Frame Counter LFSR[4] | $7FFF (all 1s) | revision-dependent |

### Revision-dependent Register Values

| Register | At Power | After Reset |
| DMC LFSR | 0? | ? |
| Frame Counter LFSR[4] | $7FFF (all 1s) | unchanged |

| Register | At Power | After Reset |
| DMC LFSR | 0? | ? |
| Frame Counter LFSR[4] | $7FFF (all 1s) | $7FFF (all 1s) |

## RAM contents

Internal RAM ($0000-$07FF) and cartridge RAM (usually $6000–$7FFF, depends on mapper) have an unreliable state on power-up and is unchanged after a reset. Some machines may have consistent RAM contents at power-up, but others may not. Emulators often implement a consistent RAM startup state (e.g. all $00 or $FF, or a particular pattern), and flashcartsmay partially or fully initialize RAM before starting a program.

Battery-backed save RAM and other types of SRAM/NVRAM have an unreliable state on the first power-up and is generally unchanged after subsequent resets and power-ups. However, there is an added chance of data corruption due to loss of power or other external factors (bugs, cheats, etc). Emulators and flashcarts may initialize save files with a consistent state (much like other sections of RAM) and persist this data without corruption after closing or reloading a game.

Because of these factors, an NES programmer must be careful not to blindly trust the initial contents of RAM.

## Best practices
- Configure the emulator so it provides a random system state and random RAM contents on power-up.
  - Mesenprovides a set of such emulation options recommended for developers, along with a debugger setting to break execution on all reads from uninitialized RAM.
- Refer to the init codearticle when setting up the reset handler. The sample implementation is a good point to start from.
  - If you are using an audio driver, make sure to call its initialization routine in the reset handler before playing any sound.
- If some RAM state is intended to persist across resets, ensure that the checks used to do so are robust against random initial RAM contents. (e.g. unique multi-byte signatures, checksum calculations, etc)
- Validate any data read from potentially unreliable sources before using it. For example, the stats of an RPG character could be checked against valid ranges when loading them from a save.

## See also
- PPU power up state

## References
- ↑RESET uses the logic shared with NMI, IRQ, and BRK that would push PC and P. However, like some but not all 6502s, the 2A03 prohibits writes during reset. This testrelies on open bus being precharged by these reads. See 27c3: Reverse Engineering the MOS 6502 CPU (en)from 41:45 onward for details
- ↑Noise channel init log
- ↑ 3.03.13.23.3DMC power-up state manifests as buzzing in Eliminator Boat Duel
- ↑ 4.04.14.22A03letterless is missing transistor to set frame counter LFSR on reset
Status flag behavior

The flags register, also called processor status or just P , is one of the six architectural registers on the 6502 family CPU. It is composed of six one-bit registers. Instructions modify one or more bits and leave others unchanged.

## Flags

Instructions that save or restore the flags map them to bits in the architectural 'P' register as follows:

```text
7  bit  0
---- ----
NV1B DIZC
|||| ||||
|||| |||+- Carry
|||| ||+-- Zero
|||| |+--- Interrupt Disable
|||| +---- Decimal
|||+------ (No CPU effect; see: the B flag)
||+------- (No CPU effect; always pushed as 1)
|+-------- Overflow
+--------- Negative

```
- The PHP (Push Processor Status) and PLP (Pull Processor Status) instructions can be used to retrieve or set this register directly via the stack.
- Interrupts(NMI and IRQ/BRK) implicitly push the status register to the stack.
- Interrupts returning with RTI will implicitly pull the saved status register from the stack.
- The two bits with no CPU effect are ignored when pulling flags from the stack; there are no corresponding registers for them in the CPU.
- When P is displayed as a single 8-bit register by debuggers, there is no convention for what values to use for bits 5 and 4 and their values should not be considered meaningful.

### C: Carry
- After ADC, this is the carry result of the addition.
- After SBC or CMP, both of which do subtraction, this flag will be set if no borrow was the result, or alternatively a "greater than or equal" result.
- After a shift instruction (ASL, LSR, ROL, ROR), this contains the bit that was shifted out.
- Increment and decrement instructions do not affect the carry flag.
- Can be set or cleared directly with SEC or CLC.

### Z: Zero
- After most instructions that have a value result, this flag will either be set or cleared based on whether or not that value is equal to zero.

### I: Interrupt Disable
- When set, IRQ interruptsare inhibited. NMI, BRK, and reset are not affected.
- Can be set or cleared directly with SEI or CLI.
- Automatically set by the CPU after pushing flags to the stack when any interrupt is triggered (NMI, IRQ/BRK, or reset). Restored to its previous state from the stack when leaving an interrupt handler with RTI.
- If an IRQ is pending when this flag is cleared (i.e. the /IRQline is low), an interrupt will be triggered immediately. However, the effect of toggling this flag is delayed 1 instruction when caused by SEI, CLI, or PLP.

### D: Decimal
- On the NES, decimal mode is disabled and so this flag has no effect. However, it still exists and can be observed and modified, as normal.
- On the original 6502, this flag causes some arithmetic instructions to use binary-coded decimalrepresentation to make base 10 calculations easier.
- Can be set or cleared directly with SED or CLD.

### V: Overflow
- ADC and SBC will set this flag if the signed result would be invalid [1], necessary for making signed comparisons [2].
- BIT will load bit 6 of the addressed value directly into the V flag.
- Can be cleared directly with CLV. There is no corresponding set instruction, and the NES CPU does not expose the 6502's Set Overflow (SO) pin.

### N: Negative
- After most instructions that have a value result, this flag will contain bit 7 of that result.
- BIT will load bit 7 of the addressed value directly into the N flag.

### The B flag

While there are only six flags in the processor status register within the CPU, the value pushed to the stack contains additional state in bit 4 called the B flag that can be useful to software. The value of B depends on what caused the flags to be pushed. Note that this flag does not represent a register that can hold a value, but rather a transient signal in the CPU controlling whether it was processing an interrupt when the flags were pushed. B is 0 when pushed by interrupts ( NMIand IRQ) and 1 when pushed by instructions (BRK and PHP).

| Cause | B flag |
| NMI | 0 |
| IRQ | 0 |
| BRK | 1 |
| PHP | 1 |

Because IRQ and BRK use the same IRQ vector, testing the state of the B flag pushed by the interrupt to the stack is the only way for an IRQ handler to distinguish between them. The B flag also allows software to identify whether interrupt hijackinghas occurred, where an NMI overrides the BRK instruction, but the B flag is still set by the BRK. However, testing this bit from the stack is fairly slow, which is one reason why BRK wasn't used as a syscall mechanism. Instead, it was more often used to trigger a patching mechanism that hung off the IRQ vector: a single byte in programmable ROM would be forced to 0, and the IRQ handler would pick something to do instead based on the program counter.

Some debugging tools, such as Visual6502, display the B flag as bit 4 of P as a matter of convenience. The user can see it turn off at the start of an interrupt and back on after the CPU reads the vector.

## External links
- koitsu's explanation

### References
- ↑Article: The Overflow (V) Flag Explained
- ↑Article: Beyond 8-bit Unsigned Comparisons, Signed Comparisons

# Epoxy package mapper pinouts

Source: https://www.nesdev.org/wiki/Epoxy_package_mapper_pinouts

When looking at PCB with unknown epoxy blob mapper, trying to map its pin-out with any existing one can help recognizing the mapper chip.

Notes:
- pins are numbered counter-clockwise (like in ordinary QFP and DIL chips)
- first pin is the one appearing after VCC, so that VCC is last pin (if there are multiple VCCs, the choice is arbitrary)
- pin-outs shown bellow contain the maximum (full) pin-out that was ever observed; if some pins are not used in a particular board (for example: epoxy MMC3 + 128kB PRG + 128kB CHR, no WRAM), there won't be wires coming into the blob (in that example: PRG A17, PRG A18, CHR A17, WRAM +CE, WRAM /CE, WRAM /WE are omitted);
Mapper 090

```text
               /-------\
         M2 -> |  1 56 | -- VCC
    CHR /CE <- |  2 55 | <- CPU A11
CPU /ROMSEL -> |  3 54 | -> PRG A20
    CPU A12 -> |  4 53 | -> PRG A19
    CPU A13 -> |  5 52 | -> PRG A18
    CPU A14 -> |  6 51 | -> PRG A17
     CPU A0 -> |  7 50 | -> PRG A16
     CPU A1 -> |  8 49 | -> PRG A15
     CPU A2 -> |  9 48 | -> PRG A14
    PRG /CE <- | 10 47 | -> PRG A13
   WRAM /CE <- | 11 46 | -> /IRQ
     CPU D0 <> | 12 45 | -> CIRAM A10
     CPU D1 <> | 13 44 | -> CHR A18
     CPU D2 <> | 14 43 | <- CPU R/W
     CPU D3 <> | 15 42 | <- PPU /RD
     CPU D4 <> | 16 41 | -> CHR A17
     CPU D5 <> | 17 40 | -> CHR A16
     CPU D6 <> | 18 39 | -> CHR A15
     CPU D7 <> | 19 38 | -> CHR A14
    PPU A10 -> | 20 37 | -> CHR A13
    PPU A11 -> | 21 36 | -> CHR A12
    PPU A12 -> | 22 35 | -> CHR A11
    PPU A13 -> | 23 34 | -> CHR A10
    CHR A19 <- | 24 33 | -> CIRAM /CE
     PPU A3 -> | 25 32 | <- PPU A9
     PPU A4 -> | 26 31 | <- PPU A8
     PPU A5 -> | 27 30 | <- PPU A7
        GND -- | 28 29 | <- PPU A6
               \-------/

```

Sample games:
- Super Mario World (demo) - does not use CPU A11 [1]
- 45 in 1 [2]
- WarioLand - the only known game using WRAM /CE pin
Mapper 091

```text
           /-------\
     M2 -> |  1    |
 CPU D0 -> |  2 35 | -- VCC
 CPU D1 -> |  3 34 | -> PRG /CE
 CPU D2 -> |  4 33 | -> CHR A18
 CPU D3 -> |  5 32 | -> CHR A17
 CPU D4 -> |  6 31 | -> CHR A16
 CPU D5 -> |  7 30 | -> CHR A15
 CPU D6 -> |  8 29 | -> CHR A14
 CPU D7 -> |  9 28 | -> CHR A13
 CPU A0 -> | 10 27 | -> CHR A12
 CPU A1 -> | 11 26 | -> CHR A11
   /IRQ <- | 12 25 | -> PRG A16
 CPU A2 -> | 13 24 | -> PRG A15
CPU A12 -> | 14 23 | -> PRG A14
CPU A13 -> | 15 22 | -> PRG A13
CPU A14 -> | 16 21 | <- CPU /ROMSEL
PPU A11 <- | 17 20 | <- CPU R/W
PPU A12 <- | 18 19 | -- GND
           \-------/

```

Sample games:
- Dragon Ball Z - Super Butouden 2 [3]
- Super Mario Sonik 2 - CHR A18/A17 are repurposed to select mirroring [4]
- Street Fighter 3 - discrete version [5]

Mapper 221

```text
           /-------\
PRG A19 <- |  1 28 | -- VCC
PRG A18 <- |  2 27 | <- /RESET
PRG A17 <- |  3 26 | <- PPU A10
PRG A16 <- |  4 25 | <- PPU A11
PRG A15 <- |  5 24 | <- PPU /WE
PRG A14 <- |  6 23 | <- CPU A14
CPU A10 -> |  7 22 | <- CPU R/W
 CPU A9 -> |  8 21 | <- CPU /ROMSEL
 CPU A8 -> |  9 20 | -> CIRAM A10
 CPU A7 -> | 10 19 | <- CPU A3
 CPU A6 -> | 11 18 | <- CPU A2
 CPU A5 -> | 12 17 | <- CPU A1
PRG /CE <- | 13 16 | <- CPU A0
    GND -- | 14 15 | -> CHR /WE
           \-------/

```

Sample games:
- 400 in 1 [6]
- 400 in 1 - discrete version [7]

# Expansion port

Source: https://www.nesdev.org/wiki/Expansion_port

Both the NES and Famicom have expansion ports that allow peripheral devices to be connected to the system.

See also: Input devices

## Famicom

The Famicom has a 15-pin (male) port on the front edge of the console (officially known as the expand connector).

Because its two default controllers were not removable like the NES, peripheral deviceshad to be attached through this expansion port, rather than through a controller portas on the NES.

This was commonly used for third party controllers, usually as a substitute for the built-in controllers, but sometimes also as a 3rd and 4th player.

### Pinout

```text
       (top)    Famicom    (bottom)
               Male DA-15
                 /\
                |   \
joypad 2 /D0 ?? | 08  \
                |   15 | -- +5V
joypad 2 /D1 -> | 07   |
                |   14 | -> /OE for joypad 1 ($4016 read strobe)
joypad 2 /D2 -> | 06   |
                |   13 | <- joypad 1 /D1
joypad 2 /D3 -> | 05   |
                |   12 | -> OUT0 ($4016 write data, bit 0, strobe on pads)
joypad 2 /D4 -> | 04   |
                |   11 | -> OUT1 ($4016 write data, bit 1)
        /IRQ ?? | 03   |
                |   10 | -> OUT2 ($4016 write data, bit 2)
       SOUND <- | 02   |
                |   09 | -> /OE for joypad 2 ($4017 read strobe)
         Gnd -- | 01  /
                |   /
                 \/

```

### Signal descriptions
- Joypad 1 /D1 , Joypad 2 /D0-/D4 : Joypad data lines, which are inverted before reaching the CPU. Joypad 1 /D1 and joypad 2 /D1-/D4 are exclusively inputs, but on the RF Famicom, Twin Famicom, and Famicom Titler, joypad 2 /D0 is supplied by the permanently-connected player 2 controller, making it an output. In contrast, the AV Famicom features user-accessible controller ports and thus detachable controllers, allowing joypad 2 /D0 to potentially be an input. At least one expansion port device, the Multi Adapter AX-1, expects joypad 2 /D0 to be an output.
- Joypad 1 /OE , Joypad 2 /OE : Output enables, asserted when reading from $4016 for joypad 1 and $4017 for joypad 2. Joypads are permitted to send input values at any time and often use /OE just as a clock to advance a shift register. Internally, the console uses /OE to know when to put the joypad input onto the CPU data bus.
- OUT2-0 : Joypad outputs from the CPU matching the values written to $4016 D2-D0. These are updated every APU cycle (every 2 CPU cycles).
- /IRQ : The direction of this signal depends on the cartridge being used. Some cartridges use a push/pull /IRQ driver, which doesn't permit anything else to disagree, preventing input on this pin. Otherwise, it can be used as an input.
- SOUND : Analog audio output. In the RF Famicom, this is before expansion audio is mixed in. In the AV Famicom, it is after. It is possible to use this for audio input, but is inadvisable; there is no single way to mix in audio that is compatible with all consoles and all cartridges, and in most cases, the voltage must be carefully balanced to mix linearly with the signal output by the console's hex inverter.

## NES

The NES has a 48-pin card edge located on the underside of the NES, beneath a plastic tab which must be cut or broken to expose the connector. The connector is exceptionally thick (2.6mm), thicker than standard PCB thicknesses. The port containing the connector is slightly keyed in the front-side corners.

Because the NES had controller portson the front that allowed different devices to be plugged in, the expansion port was a kind of "back up plan" for Nintendo that was never used commercially.

### Pinout

```text
                              (back)       NES       (front)
                                        +-------\
                                 +5V -- |01   48| -- +5V
                                 Gnd -- |02   47| -- Gnd
                     Audio mix input -> |03   46| -- NC
                                /NMI <> |04   45| -> OUT2 ($4016 write data, bit 2)
                                 A15 <- |05   44| -> OUT1 ($4016 write data, bit 1)
                                EXP9 ?? |06   43| -> OUT0 ($4016 write data, bit 0, strobe on sticks)
                                EXP8 ?? |07   42| ?? EXP0
                                EXP7 ?? |08   41| ?? EXP1
                                EXP6 ?? |09   40| ?? EXP2
                                EXP5 ?? |10   39| ?? EXP3
($4017 read strobe) /OE for joypad 2 <- |11   38| ?? EXP4
                        joypad 1 /D1 -> |12   37| -> /OE for joypad 1 ($4016 read strobe)
                        joypad 1 /D3 xx |13   36| xx joypad 1 /D4
                                /IRQ <> |14   35| xx joypad 1 /D0
                        joypad 2 /D2 -> |15   34| -> duplicate of pin 37
                        joypad 2 /D3 xx |16   33| <- joypad 1 /D2
                 duplicate of pin 11 <- |17   32| <> CPU D0
                        joypad 2 /D4 xx |18   31| <> CPU D1
                        joypad 2 /D0 xx |19   30| <> CPU D2
                        joypad 2 /D1 -> |20   29| <> CPU D3
                           Video out <- |21   28| <> CPU D4
                     Amplified audio <- |22   27| <> CPU D5
       unregulated power adapter vdd -- |23   26| <> CPU D6
                     4.00MHz CIC CLK <- |24   25| <> CPU D7
                                        +-------/

```

### Signal notes
- All joypad input lines /D0-/D4 are logically inverted before reaching the CPU. A high signal will be read as a 0 and vice versa.
- xx in above pinout: Joypad 1 and 2 /D0, /D3, and /D4 are available as an input if no peripheral is connected to the corresponding joystick portthat uses those bits:
  - e.g. /D0 is unavailable if a Standard controlleror Four scoreis plugged in, and
  - /D3 and /D4 are unavailable if a Zapper, Arkanoid controller, or Power Padis plugged in.
- /NMI is open-collector.
- /IRQ depends on the cartridge—most ASICs seem to use a push-pull driver instead of relying on the pull-up resistor inside the console.
  - Because of this, a series 1kΩ resistor should be included to safely use the /IRQ signal in the expansion port.
  - This resistor is enough to logically overcome the internal 10kΩ pull-up, and will also limit any ASIC's output-high current to 5mA if your expansion device tries to drive it low at the same time.
- See EXP pinsfor notes about the ten EXP pins.
- See Standard controllerand Controller port pinoutfor more information about controller connections.

# Infrared controllers

Source: https://www.nesdev.org/wiki/Infrared_controllers

A few famiclones are equipped with infrared receiver and are paired with additional battery powered wireless joypad(s) with infrared transmitters. Most of them can be configured to work as P1/P2 or even execute special functions (console restart, power down). They use special proprietary chips to handle the communication, whose protocols are not compatible with each other.

## UA6580 + UA6581

```text
          ,---V---.
     VCC--|01   18|->!LED
          |02   17|<-!RIGHT                ,---V---.
          |03   16|<-!LEFT        !RESET?  |01   14|->VCC
 !P1!/P2->|04   15|<-!DOWN         delay?  |02   13|->P2 inactivity pulse?
   XTAL1->|05   14|<-!UP            XTAL1->|03   12|->P1 inactivity pulse?
   XTAL2->|06   13|<-!START         XTAL2->|04   11|->P2_D0
          |07   12|<-!SELECT       P1_CLK->|05   10|<-P2_CLK
      IR<-|08   11|<-!A             P1_D0<-|06   09|<-OUT0
     GND--|09   10|<-!B               GND -|07   08|<-IR
          `-------`                        `-------`
        UA6580 (transmitter)            UA6581 (receiver)

```

They can be found in Bentech Computer Game Machine console and DR Super joypad.
- More info: https://forums.nesdev.org/viewtopic.php?f=9&t=16872

## FLY046 + FLY047

```text
            ,---V---.
       !UP->|01   20|<-!DOWN
    !START->|02   19|<-!LEFt
   !SELECT->|03   18|<-!RIGHT                ,---V---.
        !B->|04   17|<-!2P/1P        P1_CLK->|01   14|
        !A->|05   16|--VCC           P2_CLK->|02   13|<-OUT0
 !TURBO_ON->|06   15|<-!OFF/ON               |03   12|<-IR
     XTAL1->|07   14|--GND                   |04   11|-VCC
     XTAL2->|08   13|--VCC              GND--|05   10|<-XTAL2
   !REDLED<-|09   12|->IR2            P1_D0<-|06   09|<-XTAL1
       GND--|10   11|->IR1            P2_D0  |07   08|
            `-------`                        `-------`
 		FLY046 (transmitter)          FLY047 (receiver)

```

They can be found in Micro Genius IQ1000 console and Micro Genius TIJ-309 joypad.
- More info: https://forums.nesdev.org/viewtopic.php?f=9&t=18984

## FLY-826A + FLY-827A

```text
           ,---v---.
 !REDLED <-|01   20|-- +5V                                   ,---v---.
 !SLOW   ->|02   19|-> !IR                         IRLED   ->|01   18|-> ?
 !LEFT   ->|03   18|-- XTAL2                           ?   --|02   17|-- ?
 !UP     ->|04   17|-- XTAL1 (455 kHZ)   XTAL1 455k (sine) ->|03   16|<- !RESET
 !RIGHT  ->|05   16|<- !SELECT           XTAL2 455k (sq)   <-|04   15|-- ?
 !DOWN   ->|06   15|<- !START                power strobe  <-|05   14|-- +5V
 TURBOB  <-|07   14|<- !A                          P2 D0   <-|06   13|<- P1 CLK
 TURBOA  <-|08   13|<- !B                          P2 CLK  ->|07   12|<- OUT0
 !2P/1P  ->|09   12|-- GND                   reset strobe  <-|08   11|-> P1 D0
 !FUN    ->|10   11|-- ?                               ?   --|09   10|-- GND
           +-------+                                         +-------+
        FLY-826A (transmitter)                             FLY-827A (receiver)

```

They can be found in Micro Genius IQ2000 console and Micro Genius TIJ-325 joypad.
- More info: https://forums.nesdev.org/viewtopic.php?f=9&t=18984

## RTS703 + RTS702 + RTS705

```text
         ,---V---.                        ,---V---.                        ,---V---.
 !P2/P1->|01   16|--VCC            RESET->|01   16|->B             P2_CLK->|01   16|<-P1_CLK
    !UP->|02   15|->LED           ? TEST--|02   15|->A              XTAL1->|02   15|->LED
  !DOWN->|03   14|->IR             XTAL1->|03   14|->SELECT         XTAL2->|03   14|
    GND--|04   13|->TURBO          XTAL2->|04   13|->START                 |04   13|->P2_D0
 !RIGHT->|05   12|<-!B               GND--|05   12|->UP                    |05   12|->P1_D0
  !LEFT->|06   11|<-!A                IR->|06   11|->DOWN                  |06   11|--GND
  XTAL1->|07   10|<-!SELECT          VCC--|07   10|->P1/P2             IR->|07   10|
  XTAL2->|08   09|<-!START          LEFT<-|08   09|->RIGHT          +4.3V->|08   09|<-OUT0
         `-------`                        `-------`                        `-------`
     RTS703 (transmitter)          RTS702 (parallel receiver)        RTS705 (serial receiver)

```

RTS705 - pins: 4,5,6,10,14 has no internal connection inside (multimeter diode test to VCC/GND)
- More info: [1], [2]

## ?? + 74126

Receiver is integrated with Gameinis Ping Pong cartridge and transmitter is believed to be part of a ping pong rocked-shaped joypad.
- More info:
  - https://forums.nesdev.org/viewtopic.php?t=16657
  - http://zc-infinity.blogspot.com/2018/01/knockoff-console-corner-virtual-station.html

## ?? (DIP16) from StarFox famiclone

```text
           ,---V---.
  P2? LED<-|01   16|<-$4017 D0
      GND--|02   15|->P1? LED
           |03   14|<-$4016 D0
    XTAL1->|04   13|
    XTAL2->|05   12|
      VCC--|06   11|<-$4016 clk
       IR->|07   10|<-OUT0
$4017 clk->|08   09|<-OUT0
           `-------`
           (receiver)

```
- More info: https://forums.nesdev.org/viewtopic.php?t=25986

# Mapper 208 pinout

Source: https://www.nesdev.org/wiki/Mapper_208_pinout

iNES Mapper 208

```text
           +---v---+
CPU A14 -> | 1   28| -- VCC
CPU A13 -> | 2   27| <- M2
CPU A12 -> | 3   26| <- CPU /ROMSEL
CPU A11 -> | 4   25| <- CPU R/!W
 CPU A1 -> | 5   24| <- CPU D0
 CPU A0 -> | 6   23| <- CPU D1
PPU A10 -> | 7   22| <- CPU D2
PPU A11 -> | 8   21| -- GND
   OR A -> | 9   20| <- CPU D3
   OR B -> |10   19| <- CPU D4
PRG A16 <- |11   18| <- CPU D5
PRG A15 <- |12   17| <- CPU D6
   OR Y <- |13   16| <- CPU D7
    GND -- |14   15| -> CIR A10
           '-------'
            UNNAMED
        0.6" 40-pin PDIP

```

Source: [ [1]]

# MMC1 pinout

Source: https://www.nesdev.org/wiki/MMC1_pinout

MMC1: 24 pin shrink-DIP (most common mapper 1 ; variants as mappers 105and 155)

Comes in several varieties: 'MMC1', 'MMC1A', and 'MMC1B2'

```text
                .--\/--.
 PRG A14 (r) <- |01  24| -- +5V
 PRG A15 (r) <- |02  23| <- M2 (n)
 PRG A16 (r) <- |03  22| <- CPU A13 (nr)
 PRG A17 (r) <- |04  21| <- CPU A14 (n)
 PRG /CE (r) <- |05  20| <- /ROMSEL (n)
WRAM +CE (w) <- |06  19| <- CPU D7 (nrw)
 CHR A12 (r) <- |07  18| <- CPU D0 (nrw)
 CHR A13 (r) <- |08  17| <- CPU R/W (nw)
 CHR A14 (r) <- |09  16| -> CIRAM A10 (n)
 CHR A15 (r) <- |10  15| <- PPU A12 (nr)
 CHR A16 (r) <- |11  14| <- PPU A11 (nr)
         GND -- |12  13| <- PPU A10 (nr)
                `------'

```

Pinout legend

```text
    -- |  power supply   | --
    <- |     output      | ->
    -> |      input      | <-
    <> |  bidirectional  | <>
    ?? |   unknown use   | ??

n or f - connects to NES or Famicom
 r - connects to ROMs (PRG ROM, CHR ROM, CHR RAM)
 w - connects to WRAM (PRG RAM)
?? - could be an input, no connection, or a supply line

```

## Functional variations

As with several other ASIC mappers, parts of the pinout are often repurposed:

### SEROM, SHROM, SH1ROM

Doesn't support PRG banking

```text
                .--\/--.
         n/c <- |01  24| -- +5V
         n/c <- |02  23| <- M2 (n)
         n/c <- |03  22| <- CPU A13 (nr)
         n/c <- |04  21| <- CPU A14 (n)

       CPU A14 (n) -> PRG A14 (r)

```

### SNROM

Uses CHR A13-A16 as a PRG-RAM disable

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
          n/c <- |10  15| <- PPU A12 (n)
 WRAM /CE (w) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

### SOROM

Uses CHR A13-A16 as PRG-RAM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
 WRAM A13 (w) <- |10  15| <- PPU A12 (n)
          n/c <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SOROM is actually implemented using the WRAMs' /CE inputs and an inverter to select only one RAM at a time.

### SUROM

Uses CHR A13-A16 as PRG-ROM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
          n/c <- |09  16| -> CIRAM A10 (n)
          n/c <- |10  15| <- PPU A12 (n)
  PRG A18 (r) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

### SXROM

Uses CHR A13-A16 as PRG-ROM and PRG-RAM banking

```text
          n/c <- |08  17| <- CPU R/W (nw)
 WRAM A13 (w) <- |09  16| -> CIRAM A10 (n)
 WRAM A14 (w) <- |10  15| <- PPU A12 (n)
  PRG A18 (r) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SXROM uses an external inverter to convert the MMC1's WRAM +CE to the 62256's -CE input

### EVENT

Uses CHR A13-A16 as more complicated PRG-ROM banking and timer control, also disables CHR RAM banking

```text
         n/c <- |07  18| <- CPU D0 (nrw)
    PRG2 A15 <- |08  17| <- CPU R/W (nw)
    PRG2 A16 <- |09  16| -> CIRAM A10 (n)
     PRG SEL <- |10  15| <- PPU A12 (n)
 TIMER RESET <- |11  14| <- PPU A11 (nr)
         GND -- |12  13| <- PPU A10 (nr)
                `------'

```

Since the PPU A12 input's only purpose is to switch the CHR A12 .. A16 outputs, it's not clear why Nintendo didn't tie the MMC1's PPU A12 input low and connect CHR A12 directly to PPU A12. Doing so would have cost nothing (the ability to swap the two nametables is already granted through PPUCTRL), would have prevented mistakes (unless the same value is in both CHR registers, 4KB mode causes erratic switching of bank during rendering), and would have freed up another bit of control.

### SZROM

Uses CHR A16 as PRG-RAM banking

```text
      CHR A15 <- |10  15| <- PPU A12 (n)
 WRAM A13 (w) <- |11  14| <- PPU A11 (nr)
          GND -- |12  13| <- PPU A10 (nr)
                 `------'

```

SZROM permits both CHR ROM banking and 16KB of WRAM at the same time. Like SOROM, it's implemented using the WRAMs' /CE inputs and an inverter to select only one RAM at a time.

### 2ME

Uses CIRAM A10 and CHR A12, A13, A16 for EEPROM access and CHR A14, A15, and A16 for PRG-RAM access

```text
            $6000-7FFF +EN (we) <- |06  19| <- Card D7 (nrw)
                  EEPROM DI (e) <- |07  18| <- Card D0 (nrwe)
                 EEPROM CLK (e) <- |08  17| <- Card R/W (nw)
                PRG-RAM A13 (w) <- |09  16| -> EEPROM CS (e)
                PRG-RAM A14 (w) <- |10  15| <- GND (PPU A12)
EEPROM DO +OE, PRG-RAM /CE (we) <- |11  14| <- GND (PPU A11)
                            GND -- |12  13| <- GND (PPU A10)
                                   `------'

```

The data bus here is the Famicom Network System's card data bus, not the CPU data bus. Because the board is not on the PPU bus, the PPU address inputs are grounded, preventing the CHR bank 1 register from being used.

## Pirate clones

There exist pirate clones:
- AX5904 - pinout is same as official MMC1
- KS5361 - pinout unknown [1]
- KS 203- Kaiser clone:

```text
              .--\/--.
   PRG A17 <- |01  24| <- PPU A10
   PRG A16 <- |02  23| <- PPU A11
   PRG A15 <- |03  22| <- PPU A12
   PRG A14 <- |04  21| <- CPU A13
       VCC -- |05  20| <- CPU A14
   PRG /CE <- |06  19| <- /ROMSEL
   CHR A12 <- |07  18| <- RESET
   CHR A13 <- |08  17| -- GND
    CPU D7 -> |09  16| <- M2
    CPU D0 -> |10  15| <- CPU R/W
   CHR A16 <- |11  14| -> CHR A15
   CIR A10 <- |12  13| -> CHR A14
              `------'
               KS 203

```

# MMC2 pinout

Source: https://www.nesdev.org/wiki/MMC2_pinout

MMC2Chip: (40/42 pin shrink-DIP)

Later revisions of the chip are labelled MMC2-L and are 42 pin instead of 40 pin.

```text
                 .--\/--.
          GND  - |XX  XX| -  +5V
  (n)      M2 -> |01  40| -  +5V
  (n) CPU A14 -> |02  39| -  GND
  (n) CPU A13 -> |03  38| -> CIRAM A10 (n)
  (r) PRG A15 <- |04  37| -> CHR A15 (r)
  (r) PRG A14 <- |05  36| -> CHR A12 (r)
 (rn) CPU A12 -> |06  35| -> CHR A14 (r)
  (r) PRG A13 <- |07  34| <- PPU A12 (n)
  (r) PRG A16 <- |08  33| -> CHR A13 (r)
  (r) PRG /CE <- |09  32| -> CHR A16 (r)
 (rn) CPU  D4 -> |10  31| <- PPU  A8 (rn)
 (rn) CPU  D3 -> |11  30| <- PPU  A5 (rn)
 (rn) CPU  D0 -> |12  29| <- PPU  A9 (rn)
 (rn) CPU  D1 -> |13  28| <- PPU  A4 (rn)
 (rn) CPU  D2 -> |14  27| <- PPU A11 (rn)
  (n) CPU R/W -> |15  26| <- PPU  A3 (rn)
  (n) /ROMSEL -> |16  25| <- PPU  A7 (rn)
 (rn) PPU /RD -> |17  24| <- PPU  A2 (rn)
 (rn) PPU  A0 -> |18  23| <- PPU A10 (rn)
 (rn) PPU  A6 -> |19  22| <- PPU  A1 (rn)
          GND  - |20  21| <- PPU A13 (rn)
                 `------'

(r) - this pin connects to the ROM chips
(n) - this pin connects to the NES connector

```

# MMC3 pinout

Source: https://www.nesdev.org/wiki/MMC3_pinout

Nintendo MMC3: 44-pin 0.8mm pitch QFP (Canonically mapper 4)

```text
                              ___
                             /   \
                            /     \
                    n/c -- / 1  44 \ -> CHR A16 (r)
           (r) CHR A10 <- / 2    43 \ -> CHR A11 (r)
          (n) PPU A12 -> / 3   O  42 \ -> PRG RAM /WE (w)
         (n) PPU A11 -> / 4        41 \ -> PRG RAM +CE (w)
        (n) PPU A10 -> / 5          40 \ -- GND
               GND -- / 6            39 \ <- CPU D3 (nrw)         Orientation:
      (r) CHR A13 <- / 7              38 \ <- CPU D2 (nrw)        ------------------
     (r) CHR A14 <- / 8                37 \ <- CPU D4 (nrw)          33        23
    (r) CHR A12 <- / 9                  36 \ <- CPU D1 (nrw)          |        |
 (n) CIRAM A10 <- / 10                   35 \ <- CPU D5 (nrw)        .----------.
  (r) CHR A15 <- / 11                     34 \ <- CPU D0 (nrw)    34-|          |-22
                /        Nintendo MMC3        \                      | Nintendo |
                \        Package QFP-44       /                      | MMC3B    |
  (r) CHR A17 <- \ 12     0.8mm pitch     33 / <- CPU D6 (nrw)    44-|o         |-12
      (n) /IRQ <- \ 13                   32 / <- CPU A0 (nrw)        \----------'
    (n) /ROMSEL -> \ 14                 31 / <- CPU D7 (nrw)          |        |
             GND -- \ 15               30 / -> PRG RAM /CE (w)        1        11
              n/c -- \ 16             29 / <- M2 (n)
           (n) R/W -> \ 17           28 / -- GND          Legend:
        (r) PRG A15 <- \ 18         27 / -- VCC           ------------------------------
         (r) PRG A13 <- \ 19       26 / -> PRG /CE (r)    --[MMC3]-- Power
          (n) CPU A14 -> \ 20     25 / -> PRG A17 (r)     ->[MMC3]<- MMC3 input
           (r) PRG A16 <- \ 21   24 / <- CPU A13 (n)      <-[MMC3]-> MMC3 output
            (r) PRG A14 <- \ 22 23 / -> PRG A18 (r)           n      NES connection
                            \     /                           r      ROM chip connection
                             \   /                            w      RAM chip connection
                              \ /
                               V
01, 16: both officially no connection. sometimes shorted to pin 02, 15 respectively

```
Functional variations

As with several other ASIC mappers, parts of the pinout are often repurposed:

## iNES Mapper 037 and iNES Mapper 047

Mappers 37and 47connect pins 42 and 30 to a 74161
- Pin 30 (was PRG RAM /CE) is now 74'161 CLOCK
- Pin 34 (CPU D0) is additionally 74'161 D0
- In mapper 37, Pins 36, 38 (CPU D1, CPU D2) are additionally 74'161 D1, D2.
- Pin 42 (was PRG RAM /WE) is now 74'161 /LOAD

## TKSROM and TLSROM

iNES Mapper 118connects pin 12 to CIRAM A10, and pin 10 is n/c.
- Pin 10 (was CIRAM A10) is now no-connect
- Pin 12 (was CHR A17) is now CIRAM A10.

## TQROM

iNES Mapper 119connects pin 44 to a 7432and to the CHR RAM's +CE pin.
- Pin 44 (was CHR A16) is now CHR RAM +CE.
- Pin 44 is also ORed with PPU A13 and that goes to CHR ROM -CE

## Acclaim MC-ACC pinout

MC-ACCchip: (40-pin 0.6" DIP)

```text
               .--\/--.
        GND ?? |01  40| -- 5V
(r) PRG A16 <- |02  39| -> PRG A18 (r)
(r) PRG A15 <- |03  38| -> PRG A17 (r)
(n) CPU A14 -> |04  37| -> PRG A14 (r)
(n) CPU A13 -> |05  36| -> PRG A13 (r)
        n/c ?? |06  35| <- CPU R/W (n)
        n/c ?? |07  34| <- /ROMSEL (n)
        n/c ?? |08  33| -> PRG /OE (r)
(nr) CPU A0 -> |09  32| <- CPU D7 (nr)
(nr) CPU D0 -> |10  31| <- CPU D6 (nr)
(nr) CPU D1 -> |11  30| <- CPU D5 (nr)
(nr) CPU D2 -> |12  29| <- CPU D4 (nr)
(r) CHR A16 <- |13  28| <- CPU D3 (nr)
(r) CHR A15 <- |14  27| -> CIRAM A10 (n)
(r) CHR A14 <- |15  26| -> CHR A17 (r)
(r) CHR A13 <- |16  25| -> /IRQ (n)
(r) CHR A12 <- |17  24| <- PPU A12 (n)
(r) CHR A11 <- |18  23| <- PPU A11 (n)
(r) CHR A10 <- |19  22| <- PPU A10 (n)
        GND -- |20  21| <- M2 (n)
               '------'

39: confirmed in [1]
24: on the 55741 PCB, deglitched and shaped as MCACCA12IN = AND(PPUA12,AND(AND(AND(PPUA12)))). Kevtris's notes

```

Source: https://forums.nesdev.org/viewtopic.php?p=16795#p16795Pirate versions (600 mil 40-pin DIP package)

```text
             .--\/--.                              .--\/--.                           .--\/--.
       M2 -> |01  40| -- VCC            /ROMSEL -> |01  40| -> WRAM /CE    CHR A13 <- |01  40| <- PPU A10
 WRAM /CE <- |02  39| -- NC             PRG /CE <- |02  39| -- VCC         CHR A14 <- |02  39| <- PPU A11
   CPU D7 -> |03  38| -> PRG /CE       WRAM /WE <- |03  38| -> WRAM +CE    CHR A12 <- |03  38| <- PPU A12
   CPU A0 -> |04  37| -> PRG A17        CPU A14 -> |04  37| <- CPU R/W   CIRAM A10 <- |04  37| -> CHR A10
   CPU D6 -> |05  36| <- CPU A13        CPU A13 -> |05  36| -> PRG A13     CHR A15 <- |05  36| -> CHR A16
   CPU D0 -> |06  35| -> PRG A18         CPU A0 -> |06  35| -> PRG A14     CHR A17 <- |06  35| -> CHR A11
   CPU D5 -> |07  34| -> PRG A14             M2 -> |07  34| -> PRG A15        /IRQ <- |07  34| -> WRAM /WE
   CPU D1 -> |08  33| -> PRG A16        PPU A12 -> |08  33| -> PRG A16     /ROMSEL -> |08  33| -> WRAM +CE
   CPU D4 -> |09  32| <- CPU A14           /IRQ <- |09  32| -> PRG A17         GND -- |09  32| -- GND
   CPU D2 -> |10  31| -> PRG A13      CIRAM A10 <- |10  31| -> PRG A18     CPU R/W -> |10  31| <- CPU D3
   CPU D3 -> |11  30| -> PRG A15        PPU A10 -> |11  30| -- NC          PRG A15 <- |11  30| <- CPU D2
 WRAM +CE <- |12  29| <- CPU R/W        PPU A11 -> |12  29| -> CHR A17     PRG A13 <- |12  29| <- CPU D4
 WRAM /WE <- |13  28| <- /ROMSEL         CPU D0 -> |13  28| -> CHR A16     CPU A14 -> |13  28| <- CPU D1
  CHR A11 <- |14  27| -> /IRQ            CPU D1 -> |14  27| -> CHR A15     PRG A16 <- |14  27| <- CPU D5
  CHR A16 <- |15  26| -> CHR A17         CPU D2 -> |15  26| -> CHR A14     PRG A14 <- |15  26| <- CPU D0
  CHR A10 <- |16  25| -> CHR A15         CPU D3 -> |16  25| -> CHR A13     PRG A18 <- |16  25| <- CPU D6
  PPU A12 -> |17  24| -> CIRAM A10       CPU D4 -> |17  24| -> CHR A12     CPU A13 -> |17  24| <- CPU A0
  PPU A11 -> |18  23| -> CHR A12         CPU D5 -> |18  23| -> CHR A11     PRG A17 <- |18  23| <- CPU D7
  PPU A10 -> |19  22| -> CHR A14         CPU D6 -> |19  22| -> CHR A10     PRG /CE <- |19  22| -> WRAM /CE
      GND -- |20  21| -> CHR A13            GND -- |20  21| <- CPU D7          VCC -- |20  21| <- M2
             `------'                              `------'                           '------'
            AX5202P #1                      AX5202P #2 / MC-3 (NTDEC's?)                 88

```

```text
             .--\/--.                              .--\/--.                           .--\/--.
  CHR A10 <- |01  40| -- VCC            PPU A10 -> |01  40| -- VCC              M2 -> |01  40| -- VCC
  PPU A12 -> |02  39| -> CHR A16        PPU A11 -> |02  39| -> PRG A18?    CPU R/W -> |02  39| <- PPU A10
  PPU A11 -> |03  38| -> CHR A11        PPU A12 -> |03  38| -> PRG A17?    /ROMSEL -> |03  38| <- PPU A11
  PPU A10 -> |04  37| -> WRAM /WE       CHR A10 <- |04  37| -> PRG A16    WRAM +CE <- |04  37| <- PPU A12
  CHR A13 <- |05  36| -> WRAM +CE       CHR A11 <- |05  36| -> PRG A15    WRAM /CE <- |05  36| <- CPU A0
  CHR A14 <- |06  35| <- CPU D3         CHR A12 <- |06  35| -> PRG A14    WRAM /WE <- |06  35| <- CPU A13
  CHR A12 <- |07  34| <- CPU D2         CHR A13 <- |07  34| -> PRG A13     PRG /CE <- |07  34| <- CPU A14
CIRAM A10 <- |08  33| <- CPU D4         CHR A14 <- |08  33| <- CPU D7       CPU D0 -> |08  33| -> /IRQ
  CHR A15 <- |09  32| <- CPU D1         CHR A15 <- |09  32| <- CPU D6       CPU D1 -> |09  32| -> DELAYED M2
  CHR A17 <- |10  31| <- CPU D5         CHR A16 <- |10  31| <- CPU D5       CPU D2 -> |10  31| -> CIR A10
     /IRQ -> |11  30| <- CPU D0        ?CHR A17 <- |11  30| <- CPU D4       CPU D3 -> |11  30| -> CHR A17
  /ROMSEL -> |12  29| <- CPU D6         /ROMSEL -> |12  29| <- CPU D3       CPU D4 -> |12  29| -> CHR A15
  CPU R/W -> |13  28| <- CPU A0         CPU R/W -> |13  28| <- CPU D2       CPU D5 -> |13  28| -> CHR A14
  PRG A15 <- |14  27| <- CPU D7            /IRQ <- |14  27| <- CPU D1       CPU D6 -> |14  27| -> CHR A13
  PRG A13 <- |15  26| -> WRAM /CE       CIR A10 <- |15  26| <- CPU D0       CPU D7 -> |15  26| -> CHR A12
  CPU A14 -> |16  25| <- M2             CPU A0  -> |16  25| ?? ?           PRG A13 <- |16  25| -> CHR A11
  PRG A16 <- |17  24| -> PRG /CE        CPU A13 -> |17  24| -> PRG /CE     PRG A14 <- |17  24| -> CHR A10
  PRG A14 <- |18  23| ??                CPU A14 -> |18  23| ?? ?           PRG A15 <- |18  23| -> CHR A16
  PRG A18 <- |19  22| -> PRG A17             M2 -> |19  22| ?? ?           PRG A16 <- |19  22| -> PRG A18
      GND -- |20  21| <- CPU A13            GND -- |20  21| ?? ?               GND -- |20  21| -> PRG A17
             '------'                              '------'                           '------'
               9112                                7903 9102                             T1

```

Notes:
- Those chips are fully compatible MMC3 clones that can be found in bootleg games (there might be minor differences like the PPU A12 edge on which the scanline counter is clocked).
- The connections to edge connector for single games are the same in both pirate and original version, although some pirate multicarts use those chips in non-standard way with different connections.
- There are reports that some lots of AX5202P contain a large number of factory seconds with the IRQ not working.
- AX5202P #1 and AX5202P #2 are confirmed to enable WRAM at $6000-$7fff at power up but protect them from writes (during CPU write cycle to $6000-$7fff when WRAM is protected, WRAM !CE and WRAM CE are not asserted). When RAM is disabled, open bus behavior is observed.
- NC seems to be not connected internally in both versions (multimeter diode test does not show any conducting voltage between NC and any other pins)
- AX5202P #1 is the one you can still buy nowadays (it has AX5202P marking).
- AX5202P #2 was found in at least one game - Doki Doki Yuuenchi bootleg (the chip does not have any markings)

## References
- AX5202P #1: BBS
- AX5202P #2: BBS
- 88 BBS
- 9112 BBS
- 7903 9102 BBS
- T1 [2]

# MMC4 pinout

Source: https://www.nesdev.org/wiki/MMC4_pinout

Nintendo MMC4: 44-pin TQFP

```text
                           ___
                          /   \
                         /     \
                   ? ?? / 1  44 \ <- CPU R/W (n)
        (n) /ROMSEL -> / 2    43 \ <- CPU D0 (nrw)
       (n) PPU /RD -> / 3   O  42 \ <- CPU D1 (nrw)
       (n) PPU A3 -> / 4        41 \ <- CPU D2 (nrw)
               ? ?? / 5          40 \ <- CPU D3 (nrw)         Orientation:
            GND -- / 6            39 \ <- CPU D4 (nrw)        ------------------
    (n) PPU A4 -> / 7              38 \ -> PRG /CE (r)           33        23
   (n) PPU A5 -> / 8                37 \ -> PRG A17 (r)           |        |
  (n) PPU A6 -> / 9                  36 \ -> PRG A16 (r)         .----------.
 (n) PPU A7 -> / 10                   35 \ -> PRG A15 (r)     34-|          |-22
         ? ?? / 11                     34 \ -> PRG A14 (r)       | Nintendo |
             /        Nintendo MMC-4       \                     | MMC-4    |
             \        Package QFP-44       /                  44-|o         |-12
(n) PPU A8 -> \ 12     0.8mm pitch     33 / -- Tied to Pin 32    \----------'
 (n) PPU A9 -> \ 13                   32 / <- CPU A12 (n)         |        |
 (n) PPU A10 -> \ 14                 31 / <- CPU A13 (n)          1        11
  (n) PPU A11 -> \ 15               30 / <- CPU A14 (n)
   (n) PPU A12 -> \ 16             29 / <- M2 (n)             Legend:
    (n) PPU A13 -> \ 17           28 / -- GND                 ------------------------------
             GND -- \ 18         27 / -- VCC                  --[MMC4]-- Power
      (r) CHR A12 <- \ 19       26 / -> VRAM A10 (n)          ->[MMC4]<- MMC4 input
       (r) CHR A13 <- \ 20     25 / -> PRG RAM +CE (w)        <-[MMC4]-> MMC4 Output
        (r) CHR A14 <- \ 21   24 / -> CHR A16 (r)             ??[MMC4]?? Unknown
         (r) CHR A15 <- \ 22 23 / -> PRG RAM /CE (w)              n      NES connection
                         \     /                                  r      ROM chip connection
                          \   /                                   w      RAM chip connection
                           \ /
                            V

```
- Source: INL on the forum

# MMC5 pinout

Source: https://www.nesdev.org/wiki/MMC5_pinout

```text
                                                   _____
                                                  /     \
                        Audio Amplifier Input -> / 1 100 \ -> Audio Amplifier Output
                                   Audio DAC <- / 2    99 \ -- AGnd
                          Audio Pulse Waves <- / 3  (*) 98 \ varies SL3
                                  +5V AVcc -- / 4        97 \ varies CL3
                              (fr) PPU A0 -> / 5          96 \ -> CHR A2 †
                             (fr) PPU A1 -> / 6            95 \ -> CHR A1 †
                            (fr) PPU A2 -> / 7              94 \ -> CHR A0 †
                           (fr) PPU A3 -> / 8                93 \ -> PRG RAM A15 (R)
                          (fr) PPU A4 -> / 9                  92 \ <- +Use Internal Scanline Detection
                         (fr) PPU A5 -> / 10                   91 \ <> PPU D7 (fr)
                        (fr) PPU A6 -> / 11                     90 \ <> PPU D6 (fr)
                       (fr) PPU A7 -> / 12                       89 \ <> PPU D5 (fr)
                      (fr) PPU A8 -> / 13                         88 \ <> PPU D4 (fr)
                     (fr) PPU A9 -> / 14                           87 \ <> PPU D3 (fr)
                    (r) CHR A10 <- / 15                             86 \ <> PPU D2 (fr)
                   (r) CHR A11 <- / 16                               85 \ <> PPU D1 (fr)
                  (r) CHR A12 <- / 17                                 84 \ <> PPU D0 (fr)
                 (r) CHR A13 <- / 18                                   83 \ -> /Internal Reset (PRG RAM +CE) (R)
                (r) CHR A14 <- / 19                                     82 \ <- /External Reset
               (r) CHR A15 <- / 20                                       81 \ <- +Use Internal Reset
              (r) CHR A16 <- / 21                                            \
             (r) CHR A17 <- / 22                                             /
            (r) CHR A18 <- / 23                                          80 / -- DGnd
           (r) CHR A19 <- / 24                                          79 / <- M2 (f)
          (f) PPU A10 -> / 25                                          78 / <- /ROMSEL (f)
         (f) PPU A11 -> / 26              Nintendo MMC5               77 / <- CPU R/W (f)
        (f) PPU A12 -> / 27      Package QFP-100, 0.65mm pitch       76 / -> PRG RAM /WE (R)
      (f) PPU /A13 -> / 28                (20mm × 14mm)             75 / -> PRG RAM /CE (R)
 Unknown Scanline -> / 29                                          74 / -> PRG /CE (r)
V-Split Scanline -> / 30                                          73 / -> PRG RAM A16 (R)
                   /                                             72 / -> PRG RAM 1 /CE (RAM/CE + RAM A15) (R)
                   \                                            71 / -> PRG RAM 0 /CE (RAM/CE + /RAM A15) (R)
   (f) CIRAM /CE <- \ 31                                       70 / -> PRG RAM A14 (R)
    (f) CIRAM A10 <- \ 32                                     69 / -> PRG RAM A13 (R)
       (f) PPU /WR -> \ 33                                   68 / <- CPU A14 (f)        Orientation:
        (f) PPU /RD -> \ 34                                 67 / <- CPU A13 (f)         --------------------
            (f) /IRQ <- \ 35                               66 / -> PRG A19 (r)              80         51
         (frR) CPU D0 <> \ 36                             65 / -> PRG A18 (r)                |         |
          (frR) CPU D1 <> \ 37                           64 / -> PRG A17 (r)                .-----------.
           (frR) CPU D2 <> \ 38                         63 / -> PRG A16 (r)              81-| Nintendo o|-50
            (frR) CPU D3 <> \ 39                       62 / -> PRG A15 (r)                  | MMC5      |
             (frR) CPU D4 <> \ 40                     61 / -> PRG A14 (r)               100-|@          |-31
              (frR) CPU D5 <> \ 41                   60 / -> PRG A13 (r)                    \-----------'
               (frR) CPU D6 <> \ 42                 59 / <- CPU A12 (frR)                    |         |
                (frR) CPU D7 <> \ 43               58 / <- CPU A11 (frR)                   01         30
                     +5V DVcc -- \ 44             57 / -- + Backup battery
                  (frR) CPU A0 -> \ 45           56 / -> PRG RAM Vcc Output   Legend:
                   (frR) CPU A1 -> \ 46         55 / <- CPU A10 (frR)         ------------------------------
                    (frR) CPU A2 -> \ 47       54 / <- CPU A9 (frR)           --[MMC5]-- Power
                     (frR) CPU A3 -> \ 48  O  53 / <- CPU A8 (frR)            ->[MMC5]<- MMC5 input
                      (frR) CPU A4 -> \ 49   52 / <- CPU A7 (frR)             <-[MMC5]-> MMC5 output
                       (frR) CPU A5 -> \ 50 51 / <- CPU A6 (frR)              <>[MMC5]<> Bidirectional
                                        \     /                                   f      Famicom connection
                                         \   /                                    r      ROM chip connection
                                          \ /                                     R      RAM chip connection
                                           V

```

† Default connections ("CL mode"):
- Connect CHR-ROM A0 directly to PPU A0. (CL4)
- Connect CHR-ROM A1 directly to PPU A1. (CL5)
- Connect CHR-ROM A2 directly to PPU A2. (CL6)
- Leave output pins 94, 95 & 96 disconnected on the MMC5.

For smooth vertical scrolling in vertical split mode ("SL mode"):
- Connect CHR-ROM A0 only to pin 94 of the MMC5. (SL4)
- Connect CHR-ROM A1 only to pin 95 of the MMC5. (SL5)
- Connect CHR-ROM A2 only to pin 96 of the MMC5. (SL6)

"CL mode" passes the lowest PPU address bits straight to CHR ROM, while "SL mode" runs them through MMC5. SL mode allows the MMC5 to perform independent, scanline-precise vertical scrolling in vertical split mode on the side specified by register $5200. CL mode does not. All known MMC5 cartridges use CL mode. It is not known why SL mode was not used instead; possibly ROM speed issues.

CL3, SL3:
- In letterless revision:
  - 97 (CL3) is an output, showing the inverse of status bit $5204.0 (read), which comes from a detection circuit that tracks the relation of M2 vs CPU A0.
  - 98 (SL3) is an input, and functionality is unknown. Part of its functionality appears to be enabled when pin 92 is high.
- In "A" revision, 97 and 98 are two GPIO, see MMC5 § CL3/SL3

Audio circuit topology for HVC-ExROM boards:

# MMC6 pinout

Source: https://www.nesdev.org/wiki/MMC6_pinout

```text
                                        ___
                                       /   \
                                      /     \
                      (n) CPU A13 -> / 1  64 \ -> PRG A17 (r)
                              M2 -> / 2    63 \ <- CPU A14 (n)
                 (unknown, GND) -> / 3   O  62 \ -> PRG A18 (r)
                           n/c -- / 4        61 \ -> PRG A14 (r)
                          n/c -- / 5          60 \ -> PRG A15 (r)
                         /M2 <- / 6            59 \ -> PRG A13 (r)
             (unknown, GND) -> / 7              58 \ <- CPU A12 (nr)
             (unknown, 5V) -> / 8                57 \ -- GND
            (unknown, 5V) -> / 9                  56 \ -- VCC/batt
                VCC/batt -- / 10                   55 \ <- CPU A8 (nr)
                    GND -- / 11              ( )    54 \ <- CPU A7 (nr)
         (unknown, 5V) -> / 12                       53 \ <- CPU A9 (nr)
       3.3V Core Bias -- / 13                         52 \ <- CPU A6 (nr)
         (n) PPU A10 -> / 14                           51 \ <- CPU A5 (nr)
        (n) PPU A11 -> / 15                             50 \ -> PRG A16 (r)
PPU /RD || PPU A13 <- / 16                               49 \ <- CPU A4 (nr)    Orientation:
                     /             Nintendo MMC6             \                  --------------------
                     \      Package QFP-64, 0.8mm pitch      /                     48          33
       (r) CHR A10 <- \ 17                               48 / <- CPU A3 (nr)        |          |
        (r) CHR A16 <- \ 18                             47 / -> PRG /CE (r)        .------------.
         (r) CHR A11 <- \ 19                           46 / <- CPU A2 (nr)      49-|            |-32
          (n) PPU A12 -> \ 20                         45 / <> CPU D7 (nr)          |  Nintendo  |
           (r) CHR A13 <- \ 21    ( )                44 / <- CPU A1 (nr)           |O  MMC6B   O|
            (r) CHR A12 <- \ 22                     43 / <> CPU D6 (nr)            |            |
             (r) CHR A14 <- \ 23                   42 / <- CPU A0 (nr)          64-|o           |-17
                      GND -- \ 24                 41 / <> CPU D5 (nr)              \------------'
                  VCC/batt -- \ 25               40 / <> CPU D0 (nr)                |          |
                (r) CHR A15 <- \ 26             39 / <> CPU D4 (nr)                 1          16
               (n) CIRAM A10 <- \ 27           38 / -- VCC/batt
        (nr) CHR /OE, PPU /RD -> \ 28         37 / -- GND             Legend:
         (nr) CHR /CE, PPU A13 -> \ 29       36 / <> CPU D1 (nr)      ------------------------------
                    (r) CHR A17 <- \ 30     35 / <> CPU D3 (nr)       --[MMC6]-- Power
                        (n) /IRQ <- \ 31   34 / <> CPU D2 (nr)        ->[MMC6]<- MMC6 input
                      (n) /ROMSEL -> \ 32 33 / <- CPU R/W (n)         <-[MMC6]-> MMC6 output
                                      \     /                         <>[MMC6]<> Bidirectional
                                       \   /                          ??[MMC6]?? Unknown
                                        \ /                               n      NES connection
                                         V                                r      ROM chip connection

```
- GND pins (11,24,37,57) are internally connected to each other.
- VCC/batt pins (10,25,38,56) are internally connected to each other.
- All pins have internal protection diodes from GND and to VCC/batt except pins 4 and 5.
- Pins 4 and 5 measure infinite resistance to all other pins.
- Unknown input pins (3,7,8,9,12) are labeled per connections on NES-HKROM PCB.

Battery Circuit from NES-HKROM PCB:

```text
   +------|>|----/\/\/------+------|<|-----O  NES 5V
+  |             1 kohm     |
 ----- 3V                   |
  ---  Lithium              +--------------O  MMC6 VCC/Batt
-  |   2032
   |
   +---------------------------------------O  NES GND, MMC6 GND

```

3.3V Core Bias Circuit from NES-HKROM PCB:

```text
           NES 5V  O----/\/\/----+
                       181 ohm   |
                                 |
                                 +-----O  MMC6 3.3V Core Bias
                                 |
                       470 ohm   |
NES GND, MMC6 GND  O----/\/\/----+

```

NES-HKROM (Startropics 1) BOM:

```text
R1  1 kohm
R2  181 ohm
R3  470 ohm
C1  22uF 6.3V Electrolytic
C2  10nF Ceramic
C3  10nF Ceramic
C8  22uF 6.3V Electrolytic
D1  Diode (0.6V Forward)
D2  Diode (0.6V Forward)
U1  PRG-ROM
U2  CHR-ROM
U3  CIC
U4  MMC6
Batt 2032 3V Lithium

```

# X0858CE

Source: https://www.nesdev.org/wiki/X0858CE

The X0858CE is a video transcoder chip used in the Sharp Famicom Titler (AN-510) and Sharp X1 Turbo III systems [1]. It is responsible for taking the 2C05-99 chip's RGB output, and transcoding it into composite and S-Video, with adjustments to saturation using external components, specifically a 0.5 gain on the R-Y and B-Y color difference channels on pin 11 and pin 12 ( `U = U * 0.5; V = V * 0.5 `). This results in a desaturated color outputfor the internal Famicom. The chip is also accompanied by a 3.579545 MHz crystal and supporting components such as a variable capacitor on pins VA, VB and VC (pins 7, 8, and 9 respectively), alongside other components for adjusting other aspects of the video output.

This chip is also responsible for the "superimposing" video feature that the Titler is built for. The YIV and CIV pins (pins 24 and 3 respectively) are inputs for external video, and the YS pin (pin 26) switches between external video and internal video source from the YIC/B-YI/R-YI pins (pins 21, 14, and 13 respectively).

```text
          .--\/--.
   COM <- |01  30| <- CIM
  ACCF -- |02  29| -> VO
   CIV -> |03  28| <- YIM
BIPASS -- |04  27| -> YOM
  /BEP -- |05  26| <- YS
TINT_C -> |06  25| <- YM
    VC ?- |07  24| <- YIV
    VB ?- |08  23| -? /PCP
    VA ?- |09  22| -- VCC
   PDO -- |10  21| <- YIC
  R-YO <- |11  20| -> YOC
  B-YO <- |12  19| <- RI
  R-YI -> |13  18| <- GI
  B-YI -> |14  17| <- BI
   GND -- |15  16| <- COLOR-C
          `------'

```
- ↑Sharp CZ-880 service manual schematic, which uses the same X0858CE transcoder chip
