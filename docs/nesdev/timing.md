# timing

# Cycle reference chart

Source: https://www.nesdev.org/wiki/Clock_rate

## Clock rates

The clock rate of various components in the NES differs between consoles in the USA and Europe due to the different television standards used (NTSC M vs. PAL B). The color encoding method used by the NES (see NTSC video) requires that the master clock frequency be six times that of the color subcarrier, but this frequency is about 24% higher on PAL than on NTSC. In addition, PAL has more scanlines per field and fewer fields per second than NTSC. Furthermore, the PAL CPU's master clock could have been divided by 15 to preserve the ratio between CPU and PPU speeds, but Nintendo chose to keep the Johnson counterstructure, which always has an even period, and divide by 16 instead.

So the main differences between the NTSC and PAL PPUs are depicted in the following table:

| Property | NTSC (2C02) | PAL (2C07) | "Dendy" PAL Famiclone | RGB (2C03/4/5) | Brazil Famiclone | Argentina Famiclone |

| Master clock speed | 21.477272 MHz ± 40 Hz236.25 MHz ÷ 11 by definition | 26.601712 MHz ± 50 Hz26.6017125 MHz by definition | Like PAL | Like NTSC | 21.453671 MHz3.067875 GHz ÷ 143 by definition | 21.492338 MHz42.984675 MHz ÷ 2 by definition |
| CPU | Ricoh 2A03 | Ricoh 2A07 | UMC UA6527P | Ricoh 2A03 | UMC UA6527 |
| CPU clock speed | 21.47~ MHz ÷ 12 = 1.789773 MHz | 26.60~ MHz ÷ 16 = 1.662607 MHz | 26.60~ MHz ÷ 15 = 1.773448 MHz | Like NTSC | 21.45~ MHz ÷ 12 = 1.787806 MHz | 21.49~ MHz ÷ 12 = 1.791028 MHz |
| APU Frame Counter rate | 60 Hz | 50 Hz[1] | 59 Hz[2] | Like NTSC | Like NTSC |
| PPU | Ricoh 2C02 | Ricoh 2C07 | UMC UA6538 | Ricoh 2C03, 2C04, 2C05 | UMC UA6548 | UMC UA6528P |
| Master clocks per PPU dot | 4 | 5 | 5 | 4 | 4 |
| PPU dots per CPU cycle | 3 | 3.2 | Like NTSC |
| CPU cycles per scanline | 341 × 4÷12 = 1132⁄3 | 341 × 5÷16 = 1069⁄16 | 341 × 5÷15 = 1132⁄3 | Like NTSC |
| Height of picture | 240 scanlines | 239 scanlines | Like PAL | Like NTSC | thought to be like NTSC | thought to be like PAL |
| Nominal visible picture height (see Overscan) | 224 scanlines | 268 scanlines | Like PAL | Like NTSC | Like NTSC | Like PAL |
| "Post-render" blanking lines between end of picture and NMI | 1 scanline | 1 scanline | 51 scanlines | 1 scanline | 1 scanline | 51 scanlines |
| Length of vertical blanking after NMI | 20 scanlines (≈ 2273 CPU cycles) | 70 scanlines (≈ 7459 CPU cycles) | Like NTSC |
| Time during which OAM can be written | Vertical or forced blanking | Only during first 24 scanlines after NMI (≈2557 CPU cycles) | Like NTSC | Like NTSC |
| "Pre-render" lines between vertical blanking and next picture | 1 scanline |

| Total number of dots per frame | 341 × 261 + 340.5 = 89341.5(pre-render line is one dot shorter in every odd frame) | 341 × 312 = 106392 | Like PAL | 341 × 262 = 89342 | unknowneither like NTSC or RGB | Like PAL |

| Total number of CPU cycles per frame | 89341.5 ÷ 3 = 29780.5 | 106392 ÷ 3.2 = 33247.5 | 106392 ÷ 3 = 35464 | 89342 ÷ 3 = 297802⁄3 | unknowneither like NTSC or RGB | Like PAL famiclone |
| Frame rate (vertical scan rate) | 60.0988 Hz | 50.0070 Hz | Like PAL | 60.0985 Hz | 60.03 Hz | 50.5027 Hz |
| Color of top border | Always black ($0E) |
| Side and bottom borders | Palette entry at $3F00 | Always black ($0E), intruding on left and right 2 pixels and top 1 pixel of picture | Like PAL[3] | Like NTSC[4] | Unknown | Unknown, probably like PAL |

| Color emphasis(with correlating bit in PPUMASK) | Blue (D7), green (D6), red (D5) | Blue (D7), red (D6), green (D5) | Like PAL | Blue, green, red (full scale) | Unknown |
| Other quirks | Early revisions cannot read back sprite or palette memory |  |  | Many | poorly-researched |

Some frequencies in the above table are rounded.

The 2C03, 2C04, and 2C05 PPUs were all found in Nintendo's Vs. Systemand PlayChoice-10(a.k.a. PC10 or PC-10) arcade systems. Famicom Titler, Famicom TVs, and RGB-modded NES consoles would use either the 2C03 or a 2C05 with glue logic to unswap $2000 and $2001. (Later RGB mods used a 2C02 in output mode and faked out all palette logic.)

The color emphasis bits on the PAL NES have their red and green bits in PPUMASKswapped

The authentic NES sold in Brazil is an NTSC NES with an adapter board to turn the NTSC video into PAL-M video, a variant of PAL using NTSC frequencies but PAL's color modulation.

Micro Genius is a clone of the Famicom, manufactured by TXC Corporation of Taiwan and sold under various brand names in the 50 Hz market. [5]Among the best known brands is Dendy, distributed in Russia by Steepler, and the attention given by Russian reverse engineers to this clone has led to "Dendy" becoming a common name for all PAL Micro Genius-type famiclones. Its chipset (UA6527P+UA6538) is designed for compatibility with Famicom games, including games with CPU cycle counting mappers (e.g. VRC4) and games that use a cycle-timed NMI handler (e.g. Balloon Fight ). This explains the faster CPU divider and longer post-render period vs. the authentic PAL NES.

To compensate for these differences, you can detect the TV systemat power-on.

## CPU cycle counts

To make things easier for those programming on the NES, the below chart provides the number of CPU cycles that a particular PPU-oriented trait takes.

| Property | NTSC | PAL | Dendy |
| Scanline (341 pixels) | 1132⁄3 | 1069⁄16 | 1132⁄3 |
| HBlank (85 pixels) | 281⁄3 | 269⁄16 | 281⁄3 |
| NMI to start of rendering | 22731⁄3 | 74593⁄8 | 22731⁄3 |
| Frame | 29780.5* | 33247.5 | 35464 |
| PPU dots ÷ CPU cycles | 3 | 3.2 | 3 |
| OAM DMA | 513 (+1 if starting on CPU get cycles) |

* NTSC frame timing is 29780.5 cycles if rendering is enabled during the 20th scanline; 29780 2 ⁄ 3 otherwise.

## See also
- PPU frame timing
- PPU rendering
- Cycle counting

## References
- ↑nesdev forum post by thefox: http://forums.nesdev.org/viewtopic.php?p=160349#p160349
- ↑nesdev forum post by Eugene.S: http://forums.nesdev.org/viewtopic.php?p=174970#p174970
- ↑nesdev forum post by Eugene.S: https://forums.nesdev.org/viewtopic.php?p=173764#p173764
- ↑nesdev forum post by lidnariq: https://forums.nesdev.org/viewtopic.php?p=179705#p179705
- ↑Post by feos at TASVideosand NESdev

# Cycle counting

Source: https://www.nesdev.org/wiki/Clockslide

It is often useful to delay a specific number of CPU cycles. Timing raster effects or generating PCM audio are some examples that might utilize this. This article outlines a few relevant techniques.

## Instruction timings

You can use an instruction reference[1]for instruction timings, but there are some rules-of-thumb [2]that can help remember most of them:
- There is a minimum of 2 cycles per instruction.
- Each byte of memory read or written adds 1 more cycle to the instruction. This includes fetching the instruction, and each byte of its operand, then any memory it references.
- Indexed instructions which cross a page take 1 extra cycle to adjust the high byte of the effective address first.
- Read-modify-write instructions perform a dummy write during the "modify" stage and thus take 1 extra cycle.
- Instructions that push data onto the stack take 1 extra cycle.
- Instructions that pop data from the stack take 2 extra cycles, since they also need to pre-increment the stack pointer.
- "Extra" cycles often include an extra read or write that usually does not affect the outcome.

Examples:

| Instructions | Cycles | Bytes | Details |
``| SEC | 2 | 1 | opcode, but has to wait for the 2-cycle minimum. |
``| AND #imm | 2 | 2 | opcode + operand. Only affects registers. |
``| LDA zp | 3 | 2 | opcode + operand + byte fetched from zp. |
``| STA abs | 4 | 3 | opcode + 2 byte operand + byte written to abs. |
``| LDA abs,X | 4 or 5 | 3 | opcode + 2 byte operand + read from abs, but it delays 1 extra cycle if the addition of the X index causes a page crossing. |
``| STA abs,X | 5 | 3 | Like LDA abs,X, but assumes the worst case of page crossing and always spends 1 extra read cycle. |
``| ASL zp | 5 | 2 | opcode + operand + read from zp + write to zp, but it takes 1 extra cycle to modify the value. |
``| LDA (indirect),Y | 5 or 6 | 2 | opcode + operand + two reads from zp + read from indirect address. 1 extra cycle if a page is crossed. |
``| STA (indirect),Y | 6 | 2 | Like LDA (indirect),Y, but assumes the worst case of page crossing and always spends 1 extra read cycle. |
``| PHA | 3 | 1 | opcode + stack write, but requires 1 extra cycle to perform the stack operation. |
``| RTS | 6 | 1 | opcode + two stack reads, but requires 2 extra cycles to perform the stack operations, plus 1 cycle to post-increment the program counter (to compensate for the off-by-1 address pushed by JSR). |

## Short delays

Here are few ways to create short delays without side effects. As the shortest instruction time is 2 cycles, it is not possible to delay 1 cycle on its own. NOP is essential for 2 cycle delays. 3 cycle delays always take 2 bytes, but usually have some compromise. More options become available as delays become longer.

| Instructions | Cycles | Bytes | Side effects and notes |
``| NOP | 2 | 1 |  |
``| JMP *+3 | 3 | 3 |  |
``| Bxx *+2 | 3 | 2 | None, but requires a known flag state (e.g. BCC if carry is known to be clear). |
``| BIT zp | 3 | 2 | Clobbers NVZ flags. Reads zp. |
``| IGN zp | 3 | 2 | Reads zp. (Unofficial instruction.) |
``| NOP, NOP | 4 | 2 |
``| NOP, ... | 5 | 3 | (... = 3 cycle delay of choice) |
``| CLV, BVC *+2 | 5 | 3 | Clears V flag. (Can instead use C flag with CLC, BCC or SEC, BCS.) |
``| NOP, NOP, NOP | 6 | 3 |
``| PHP, PLP | 7 | 2 | Modifies 1 byte of stack. |
``| NOP, NOP, NOP, NOP | 8 | 4 |
``| PHP, PLP, NOP | 9 | 3 | Modifies 1 byte of stack. |
``| PHP, CMP zp, PLP | 10 | 4 | Modifies 1 byte of stack. Reads zp. |
``| PHP, PLP, NOP, NOP | 11 | 4 | Modifies 1 byte of stack. |
``| JSR, RTS | 12 | 3 | Modifies 2 bytes of stack. (Takes 3 bytes only if reusing an existing RTS; otherwise 4.) |

## Clockslide

A clockslide [3]is a sequence of instructions that wastes a small constant amount of cycles plus one cycle per executed byte, no matter whether it's entered on an odd or even address. With official instructions, one can construct a clockslide from CMP instructions: `... C9 C9 C9 C9 C5 EA `Disassemble from the start and you get `CMP #$C9 CMP #$C9 CMP $EA `(6 bytes, 7 cycles). Disassemble one byte in and you get `CMP #$C9 CMP #$C5 NOP `(5 bytes, 6 cycles). The entry point can be controlled with an indirect jump or the RTS Trickto precisely control raster effect or sample playback timing.

CMP has a side effect of destroying most of the flags, but you can substitute other instructions with the same size and timing that preserve whichever flags/registers you need at the end of the slide. There are unofficial instructionsthat can avoid altering any state: replace $C9 (CMP) with $89 or $80, which ignores an immediate operand, and replace $C5 with $04, $44, or $64, which ignore a read from the zero page.

## Resources
- Delay code- various variable-cycle delays
- Fixed cycle delay- shortest fixed-cycle delays
- Fixed-cycle delay code vending machine- code for generating shortest-possible delay routines at compile-time.
- 6502 vdelay- code for delaying a variable number of cycles at run-time.

## References
- ↑6502_cpu.txt: cycle-by-cycle instruction behaviour
- ↑Forum: Is there a logic to instruction timings?
- ↑Clockslide: How to waste an exact number of clock cycles on the 6502

# Cycle counting

Source: https://www.nesdev.org/wiki/Cycle_counting

It is often useful to delay a specific number of CPU cycles. Timing raster effects or generating PCM audio are some examples that might utilize this. This article outlines a few relevant techniques.

## Instruction timings

You can use an instruction reference[1]for instruction timings, but there are some rules-of-thumb [2]that can help remember most of them:
- There is a minimum of 2 cycles per instruction.
- Each byte of memory read or written adds 1 more cycle to the instruction. This includes fetching the instruction, and each byte of its operand, then any memory it references.
- Indexed instructions which cross a page take 1 extra cycle to adjust the high byte of the effective address first.
- Read-modify-write instructions perform a dummy write during the "modify" stage and thus take 1 extra cycle.
- Instructions that push data onto the stack take 1 extra cycle.
- Instructions that pop data from the stack take 2 extra cycles, since they also need to pre-increment the stack pointer.
- "Extra" cycles often include an extra read or write that usually does not affect the outcome.

Examples:

| Instructions | Cycles | Bytes | Details |
``| SEC | 2 | 1 | opcode, but has to wait for the 2-cycle minimum. |
``| AND #imm | 2 | 2 | opcode + operand. Only affects registers. |
``| LDA zp | 3 | 2 | opcode + operand + byte fetched from zp. |
``| STA abs | 4 | 3 | opcode + 2 byte operand + byte written to abs. |
``| LDA abs,X | 4 or 5 | 3 | opcode + 2 byte operand + read from abs, but it delays 1 extra cycle if the addition of the X index causes a page crossing. |
``| STA abs,X | 5 | 3 | Like LDA abs,X, but assumes the worst case of page crossing and always spends 1 extra read cycle. |
``| ASL zp | 5 | 2 | opcode + operand + read from zp + write to zp, but it takes 1 extra cycle to modify the value. |
``| LDA (indirect),Y | 5 or 6 | 2 | opcode + operand + two reads from zp + read from indirect address. 1 extra cycle if a page is crossed. |
``| STA (indirect),Y | 6 | 2 | Like LDA (indirect),Y, but assumes the worst case of page crossing and always spends 1 extra read cycle. |
``| PHA | 3 | 1 | opcode + stack write, but requires 1 extra cycle to perform the stack operation. |
``| RTS | 6 | 1 | opcode + two stack reads, but requires 2 extra cycles to perform the stack operations, plus 1 cycle to post-increment the program counter (to compensate for the off-by-1 address pushed by JSR). |

## Short delays

Here are few ways to create short delays without side effects. As the shortest instruction time is 2 cycles, it is not possible to delay 1 cycle on its own. NOP is essential for 2 cycle delays. 3 cycle delays always take 2 bytes, but usually have some compromise. More options become available as delays become longer.

| Instructions | Cycles | Bytes | Side effects and notes |
``| NOP | 2 | 1 |  |
``| JMP *+3 | 3 | 3 |  |
``| Bxx *+2 | 3 | 2 | None, but requires a known flag state (e.g. BCC if carry is known to be clear). |
``| BIT zp | 3 | 2 | Clobbers NVZ flags. Reads zp. |
``| IGN zp | 3 | 2 | Reads zp. (Unofficial instruction.) |
``| NOP, NOP | 4 | 2 |
``| NOP, ... | 5 | 3 | (... = 3 cycle delay of choice) |
``| CLV, BVC *+2 | 5 | 3 | Clears V flag. (Can instead use C flag with CLC, BCC or SEC, BCS.) |
``| NOP, NOP, NOP | 6 | 3 |
``| PHP, PLP | 7 | 2 | Modifies 1 byte of stack. |
``| NOP, NOP, NOP, NOP | 8 | 4 |
``| PHP, PLP, NOP | 9 | 3 | Modifies 1 byte of stack. |
``| PHP, CMP zp, PLP | 10 | 4 | Modifies 1 byte of stack. Reads zp. |
``| PHP, PLP, NOP, NOP | 11 | 4 | Modifies 1 byte of stack. |
``| JSR, RTS | 12 | 3 | Modifies 2 bytes of stack. (Takes 3 bytes only if reusing an existing RTS; otherwise 4.) |

## Clockslide

A clockslide [3]is a sequence of instructions that wastes a small constant amount of cycles plus one cycle per executed byte, no matter whether it's entered on an odd or even address. With official instructions, one can construct a clockslide from CMP instructions: `... C9 C9 C9 C9 C5 EA `Disassemble from the start and you get `CMP #$C9 CMP #$C9 CMP $EA `(6 bytes, 7 cycles). Disassemble one byte in and you get `CMP #$C9 CMP #$C5 NOP `(5 bytes, 6 cycles). The entry point can be controlled with an indirect jump or the RTS Trickto precisely control raster effect or sample playback timing.

CMP has a side effect of destroying most of the flags, but you can substitute other instructions with the same size and timing that preserve whichever flags/registers you need at the end of the slide. There are unofficial instructionsthat can avoid altering any state: replace $C9 (CMP) with $89 or $80, which ignores an immediate operand, and replace $C5 with $04, $44, or $64, which ignore a read from the zero page.

## Resources
- Delay code- various variable-cycle delays
- Fixed cycle delay- shortest fixed-cycle delays
- Fixed-cycle delay code vending machine- code for generating shortest-possible delay routines at compile-time.
- 6502 vdelay- code for delaying a variable number of cycles at run-time.

## References
- ↑6502_cpu.txt: cycle-by-cycle instruction behaviour
- ↑Forum: Is there a logic to instruction timings?
- ↑Clockslide: How to waste an exact number of clock cycles on the 6502

# Cycle reference chart

Source: https://www.nesdev.org/wiki/Cycle_reference_chart

## Clock rates

The clock rate of various components in the NES differs between consoles in the USA and Europe due to the different television standards used (NTSC M vs. PAL B). The color encoding method used by the NES (see NTSC video) requires that the master clock frequency be six times that of the color subcarrier, but this frequency is about 24% higher on PAL than on NTSC. In addition, PAL has more scanlines per field and fewer fields per second than NTSC. Furthermore, the PAL CPU's master clock could have been divided by 15 to preserve the ratio between CPU and PPU speeds, but Nintendo chose to keep the Johnson counterstructure, which always has an even period, and divide by 16 instead.

So the main differences between the NTSC and PAL PPUs are depicted in the following table:

| Property | NTSC (2C02) | PAL (2C07) | "Dendy" PAL Famiclone | RGB (2C03/4/5) | Brazil Famiclone | Argentina Famiclone |

| Master clock speed | 21.477272 MHz ± 40 Hz236.25 MHz ÷ 11 by definition | 26.601712 MHz ± 50 Hz26.6017125 MHz by definition | Like PAL | Like NTSC | 21.453671 MHz3.067875 GHz ÷ 143 by definition | 21.492338 MHz42.984675 MHz ÷ 2 by definition |
| CPU | Ricoh 2A03 | Ricoh 2A07 | UMC UA6527P | Ricoh 2A03 | UMC UA6527 |
| CPU clock speed | 21.47~ MHz ÷ 12 = 1.789773 MHz | 26.60~ MHz ÷ 16 = 1.662607 MHz | 26.60~ MHz ÷ 15 = 1.773448 MHz | Like NTSC | 21.45~ MHz ÷ 12 = 1.787806 MHz | 21.49~ MHz ÷ 12 = 1.791028 MHz |
| APU Frame Counter rate | 60 Hz | 50 Hz[1] | 59 Hz[2] | Like NTSC | Like NTSC |
| PPU | Ricoh 2C02 | Ricoh 2C07 | UMC UA6538 | Ricoh 2C03, 2C04, 2C05 | UMC UA6548 | UMC UA6528P |
| Master clocks per PPU dot | 4 | 5 | 5 | 4 | 4 |
| PPU dots per CPU cycle | 3 | 3.2 | Like NTSC |
| CPU cycles per scanline | 341 × 4÷12 = 1132⁄3 | 341 × 5÷16 = 1069⁄16 | 341 × 5÷15 = 1132⁄3 | Like NTSC |
| Height of picture | 240 scanlines | 239 scanlines | Like PAL | Like NTSC | thought to be like NTSC | thought to be like PAL |
| Nominal visible picture height (see Overscan) | 224 scanlines | 268 scanlines | Like PAL | Like NTSC | Like NTSC | Like PAL |
| "Post-render" blanking lines between end of picture and NMI | 1 scanline | 1 scanline | 51 scanlines | 1 scanline | 1 scanline | 51 scanlines |
| Length of vertical blanking after NMI | 20 scanlines (≈ 2273 CPU cycles) | 70 scanlines (≈ 7459 CPU cycles) | Like NTSC |
| Time during which OAM can be written | Vertical or forced blanking | Only during first 24 scanlines after NMI (≈2557 CPU cycles) | Like NTSC | Like NTSC |
| "Pre-render" lines between vertical blanking and next picture | 1 scanline |

| Total number of dots per frame | 341 × 261 + 340.5 = 89341.5(pre-render line is one dot shorter in every odd frame) | 341 × 312 = 106392 | Like PAL | 341 × 262 = 89342 | unknowneither like NTSC or RGB | Like PAL |

| Total number of CPU cycles per frame | 89341.5 ÷ 3 = 29780.5 | 106392 ÷ 3.2 = 33247.5 | 106392 ÷ 3 = 35464 | 89342 ÷ 3 = 297802⁄3 | unknowneither like NTSC or RGB | Like PAL famiclone |
| Frame rate (vertical scan rate) | 60.0988 Hz | 50.0070 Hz | Like PAL | 60.0985 Hz | 60.03 Hz | 50.5027 Hz |
| Color of top border | Always black ($0E) |
| Side and bottom borders | Palette entry at $3F00 | Always black ($0E), intruding on left and right 2 pixels and top 1 pixel of picture | Like PAL[3] | Like NTSC[4] | Unknown | Unknown, probably like PAL |

| Color emphasis(with correlating bit in PPUMASK) | Blue (D7), green (D6), red (D5) | Blue (D7), red (D6), green (D5) | Like PAL | Blue, green, red (full scale) | Unknown |
| Other quirks | Early revisions cannot read back sprite or palette memory |  |  | Many | poorly-researched |

Some frequencies in the above table are rounded.

The 2C03, 2C04, and 2C05 PPUs were all found in Nintendo's Vs. Systemand PlayChoice-10(a.k.a. PC10 or PC-10) arcade systems. Famicom Titler, Famicom TVs, and RGB-modded NES consoles would use either the 2C03 or a 2C05 with glue logic to unswap $2000 and $2001. (Later RGB mods used a 2C02 in output mode and faked out all palette logic.)

The color emphasis bits on the PAL NES have their red and green bits in PPUMASKswapped

The authentic NES sold in Brazil is an NTSC NES with an adapter board to turn the NTSC video into PAL-M video, a variant of PAL using NTSC frequencies but PAL's color modulation.

Micro Genius is a clone of the Famicom, manufactured by TXC Corporation of Taiwan and sold under various brand names in the 50 Hz market. [5]Among the best known brands is Dendy, distributed in Russia by Steepler, and the attention given by Russian reverse engineers to this clone has led to "Dendy" becoming a common name for all PAL Micro Genius-type famiclones. Its chipset (UA6527P+UA6538) is designed for compatibility with Famicom games, including games with CPU cycle counting mappers (e.g. VRC4) and games that use a cycle-timed NMI handler (e.g. Balloon Fight ). This explains the faster CPU divider and longer post-render period vs. the authentic PAL NES.

To compensate for these differences, you can detect the TV systemat power-on.

## CPU cycle counts

To make things easier for those programming on the NES, the below chart provides the number of CPU cycles that a particular PPU-oriented trait takes.

| Property | NTSC | PAL | Dendy |
| Scanline (341 pixels) | 1132⁄3 | 1069⁄16 | 1132⁄3 |
| HBlank (85 pixels) | 281⁄3 | 269⁄16 | 281⁄3 |
| NMI to start of rendering | 22731⁄3 | 74593⁄8 | 22731⁄3 |
| Frame | 29780.5* | 33247.5 | 35464 |
| PPU dots ÷ CPU cycles | 3 | 3.2 | 3 |
| OAM DMA | 513 (+1 if starting on CPU get cycles) |

* NTSC frame timing is 29780.5 cycles if rendering is enabled during the 20th scanline; 29780 2 ⁄ 3 otherwise.

## See also
- PPU frame timing
- PPU rendering
- Cycle counting

## References
- ↑nesdev forum post by thefox: http://forums.nesdev.org/viewtopic.php?p=160349#p160349
- ↑nesdev forum post by Eugene.S: http://forums.nesdev.org/viewtopic.php?p=174970#p174970
- ↑nesdev forum post by Eugene.S: https://forums.nesdev.org/viewtopic.php?p=173764#p173764
- ↑nesdev forum post by lidnariq: https://forums.nesdev.org/viewtopic.php?p=179705#p179705
- ↑Post by feos at TASVideosand NESdev

# Fixed cycle delay

Source: https://www.nesdev.org/wiki/Fixed_cycle_delay

Shortest possible CPU code that creates N cycles of delay, depending on constraints.

## Code

All code samples are written for CA65.

Assumptions:
- No page wrap occurs during any branch instruction. If a page wrap occurs, it adds +1 cycle for each loop, completely thwarting the accurate delay.
- No interrupt / NMI occurs during the delay code.

It is permissible for DMA to steal cycles during the loops. If you are expecting that to happen, you have to manually adjust the delay cycle count (and it is in fact possible to do so) in order to get the correct delay.

### Explanations on the requirements
- @rts12 means you know a memory address that contains byte $60 ( `RTS `).

cycle instruction that fits your constraints (such as `LDA $00 `), followed by `RTS `.

### Instructions, addressing modes, byte counts, cycle counts and notes

| Addressing mode | Instruction type | Bytes | Cycle count | Example instruction | Notes |
``````````| Implied | Inter-register | 1 | 2 | TAX | NOP has no side effects. Flag-manipulations like CLC, and SECCLV are used when their effects are desired. |
``````| Implied | Stack push | 1 | 3 | PHA | PHP is only paired with PLP. |
``| Implied | Stack pop | 1 | 4 | PLA |  |
``````| Implied | Return | 1 | 6 | RTS | Used indirectly when paired with JSR. Similarly for RTI. |
````````| Immediate |  | 2 | 2 | CMP #$C5 | Includes instructions like LDA, LDX and LDY. Other ALU instructions are used in more complex situations. |
``| Relative | Branch | 2 | 2—4 | BCC *+2 | Branch takes 3 cycles when taken, 2 otherwise. A page crossing adds +1 cycle when branch is taken, but because of difficulties setting that up, we don't use it. |
``| Zeropage | Read, write | 2 | 3 | LDA $A5 |
``| Zeropage | RMW | 2 | 5 | INC @zptemp | Writing to zeropage is only permitted when @zptemp is available. Technically we could save @zptemp into register and restore at end, but it is bytewise inferior to other techniques. |
````| Zeropage indexed | Read, write | 2 | 4 | LDA $EA,X | Inferior to 2 × NOP, but useful for hiding additional code to be executed in a loop. |
``| Zeropage indexed | RMW | 2 | 6 | INC @zptemp,X | Only doable when X is known to be 0, or when entire zeropage can be clobbered. |
``| Indexed indirect | Read, write | 2 | 6 | STA (@ptrtemp,X) | Only doable when X is known to be 0. |
``| Indexed indirect | RMW | 2 | 8 | SLO (@ptrtemp,X) | The most cost-effective instruction. Only doable when X is known to be 0, lest we write to a random address. All instructions in this category are unofficial. |
``| Indirect indexed | Read | 2 | 5—6 | LDA (@ptrtemp),Y | Never used by this code. |
``| Indirect indexed | Write | 2 | 6 | STA (@ptrtemp),Y | Only doable when Y is known to be 0. |
``| Indirect indexed | RMW | 2 | 8 | SLO (@ptrtemp),Y | All instructions in this category are unofficial. |
``| Absolute | Jump | 3 | 3 | JMP *+3 |  |
````| Absolute | Read, write | 3 | 4 | LDA $2808 | Inferior to 2 × NOP, but can be used carefully to hide additional code to be executed in a loop. |
````| Absolute | RMW | 3 | 6 | INC $4018 | Inferior to 3 × NOP. |
``| Absolute indexed | Read | 3 | 4—5 | LDA $0200,X | Inferior to shorter alternatives. |
``| Absolute indexed | Write | 3 | 5 | STA $0200,X | Inferior to shorter alternatives. |
``| Absolute indexed | RMW | 3 | 7 | INC $4018,X | Only doable when writing into the given address is harmless considering the possible values of X. |
``| Absolute indirect | Jump | 3 | 5 | JMP (@ptrtemp) | Inferior to shorter alternatives. |

{{#css:

```text
 .testtable td{padding:2px} .testtable td pre{padding:2px;margin:2px}

```

}}

### 2 cycles

| 1 bytes |

```text

```
| EA NOP | No requirements |
- All instructions cost at least 2 cycles. There is no way to do 1 cycle of delay (though −1 cycles may sometimes appear in branch cost calculations).

### 3 cycles

| 2 bytes |

```text

```
| C5 C5 CMP $C5 | Clobbers Z&N, and C |

```text

```
| 24 24 BIT $24 | Clobbers Z&N, and V |

```text

```
| A5 A5 LDA $A5 | Clobbers A, and Z&N |

```text

```
| A6 A6 LDX $A6 | Clobbers X, and Z&N |

```text

```
| A4 A4 LDY $A4 | Clobbers Y, and Z&N |
| 3 bytes |

```text

```
| 4C xx xx JMP *+3 | No requirements |
- Not relocatable means that the target address is hardcoded into the code. In ROM hacking, it sometimes makes sense to move code blobs around, and a hardcoded address makes it difficult to relocate the code. This restriction does not apply to branches, which use relative addressing. It is also assumed to not apply to `JSR `instructions, as chances are the JSR target is outside the code being relocated.

### 4 cycles

| 2 bytes |

```text

```
| EA ... NOP × 2 | No requirements |
- zp-indexed modes such as `LDA $00,X `also do 4 cycles, but having side effects, these two-byte instructions are inferior to a simple 2 × `NOP `.
- There is also an unofficial opcode `NOP $00,X `(34 00), but there is no reason to use this instruction when the official equivalent has the same performance.

### 5 cycles

| 3 bytes |

```text

```
| 18 CLC 90 00 BCC *+2 | Clobbers C |

```text

```
| B8 CLV 50 00 BVC *+2 | Clobbers V |

```text

```
| EA NOP A5 A5 LDA $A5 | Clobbers A, and Z&N |

```text

```
| EA NOP A6 A6 LDX $A6 | Clobbers X, and Z&N |

```text

```
| EA NOP A4 A4 LDY $A4 | Clobbers Y, and Z&N |
| 4 bytes |

```text

```
| EA NOP 4C xx xx JMP *+3 | No requirements |
- abs-indexed modes such as `LDA $1234,X `cause 4 or 5 cycles of delay, depending whether a page wrap occurred. Because you need extra setup code to make sure that a wrap does occur, you do not see this mode in these samples, outside situations where circumstances permit.

### 6 cycles

| 3 bytes |

```text

```
| EA ... NOP × 3 | No requirements |
- zp-indexed RMW instructions such as `INC @zptemp,X `do 6 cycles. Unless we know the value of X, it might write into any address between $00-$FF. This option is only useful if the entire range of $00-$FF is free for clobbering with random data, or if X has a known value.
- ix instructions like `LDA ($00,X) `do 6 cycles, but the value of X decides where a pointer is read from, and said pointer can point anywhere. We only do that when the value of X is known.
- iy instructions like `LDA ($00),Y `also do 5-6 cycles, but in addition to the note above, we cannot predict whether a wrap occurs or not. So we don't use this mode.
- Absolute RMW instructions like `INC $4018 `do 6 cycles, but weighing 3 bytes with side-effects it would be inferior to 3 × `NOP `.

### 7 cycles

| 2 bytes |

```text

```
| 08 PHP 28 PLP | No requirements |
- `PHP-PLP `is very efficient for 7 cycles of delay, but it does modify stack contents. S register remains unchanged though.
- `PLA-PHA `does not overwrite any bytes in stack. It just writes back the same byte. But it does clobber A and Z+N. It is not interrupt-unsafe either: If an interrupt happens, the stack byte does get temporarily clobbered, but the value is still in A when the interrupt exits, and gets written back in stack.
- abs-indexed RMW instructions such as `INC abs,X `do 7 cycles. We only do this when either we know the value of X (for instance, `INC $4018,X `is safe when X is 0—7, or when the entire 256-byte page can be safely overwritten with random data.

### 8 cycles

| 4 bytes |

```text

```
| EA ... NOP × 4 | No requirements |
- Unofficial ix and iy RMW instructions such as `SLO ($00,X) `or `SLO ($00),Y `would do 8 cycles for 2 bytes of code. We only do that if we know X or Y to be zero, and we have a known pointer to safely rewritable data.

### 9 cycles

| 3 bytes |

```text

```
| EA NOP 08 PHP 28 PLP | No requirements |
- Jumping into the middle of another instruction and thereby reusing code is a very efficient way of reducing code size. Note that all code samples using branches on this page require that no page wrap occurs.

### 10 cycles

| 4 bytes |

```text

```
| 08 PHP C5 C5 CMP $C5 28 PLP | No requirements |
- The `ROL-ROR `sequence preserves the original value of the memory address. Carry is also preserved.

### 11 cycles

| 4 bytes |

```text

```
| EA ... NOP × 2 08 PHP 28 PLP | No requirements |

### 12 cycles

| 3 bytes |

```text

```
| 20 xx xx JSR @rts12 | Requires @rts12 |
| 4 bytes |

```text

```
| 36 36 ROL $36,X 76 36 ROR $36,X | Clobbers Z&N |
| 5 bytes |

```text

```
| 08 PHP 18 CLC 90 00 BCC *+2 28 PLP | No requirements |
- `JSR-RTS `causes 12 cycles of delay. But it does write a function return address in the stack, which may be unwanted in some applications. S is not modified.
- Again, `ROL-ROR `does not have side effects (as long as an interrupt does not happen in the middle), except for Z+N.

### 13 cycles

| 5 bytes |

```text

```
| EA ... NOP × 3 08 PHP 28 PLP | No requirements |

### 14 cycles

| 4 bytes |

```text

```
| 08 PHP \ × 2 28 PLP / | No requirements |

### 15 cycles

| 5 bytes |

```text

```
| 08 PHP BA TSX 28 PLP 9A TXS 28 PLP | Clobbers X |

```text

```
| C5 C5 CMP $C5 20 xx xx JSR @rts12 | Clobbers Z&N, and C; and requires @rts12 |

```text

```
| 24 24 BIT $24 20 xx xx JSR @rts12 | Clobbers Z&N, and V; and requires @rts12 |

```text

```
| A5 A5 LDA $A5 20 xx xx JSR @rts12 | Clobbers A, and Z&N; and requires @rts12 |

```text

```
| A4 A4 LDY $A4 20 xx xx JSR @rts12 | Clobbers Y, and Z&N; and requires @rts12 |
| 6 bytes |

```text

```
| 08 PHP 28 PLP EA ... NOP × 4 | No requirements |

### 16 cycles

| 5 bytes |

```text

```
| EA NOP 08 PHP \ × 2 28 PLP / | No requirements |

### 17 cycles

| 6 bytes |

```text

```
| 08 PHP 48 PHA A5 A5 LDA $A5 68 PLA 28 PLP | No requirements |

### 18 cycles

| 6 bytes |

```text

```
| EA ... NOP × 2 08 PHP \ × 2 28 PLP / | No requirements |

### 19 cycles

| 5 bytes |

```text

```
| 08 PHP 28 PLP 20 xx xx JSR @rts12 | Requires @rts12 |
| 6 bytes |

```text

```
| 08 PHP 36 36 ROL $36,X 76 36 ROR $36,X 28 PLP | No requirements |

### 20 cycles

| 5 bytes |

```text

```
| A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 | Clobbers A, Z&N, and C |
| 7 bytes |

```text

```
| EA ... NOP × 3 08 PHP \ × 2 28 PLP / | No requirements |

### 21 cycles

| 5 bytes |

```text

```
| 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 | Clobbers A, Z&N, and C |

```text

```
| A2 04 LDX #4 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| A0 04 LDY #4 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 6 bytes |

```text

```
| 08 PHP \ × 3 28 PLP / | No requirements |

### 22 cycles

| 6 bytes |

```text

```
| 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 | Clobbers A, Z&N, and C |

```text

```
| A2 02 LDX #2 EA NOP CA DEX 10 FC BPL *-2 | Clobbers X, and Z&N |

```text

```
| A0 03 LDY #3 EA NOP 88 DEY D0 FC BNE *-2 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 08 PHP BA TSX 08 PHP 28 ... PLP × 2 9A TXS 28 PLP | Clobbers X |

```text

```
| 08 PHP C5 C5 CMP $C5 28 PLP 20 xx xx JSR @rts12 | Requires @rts12 |
| 8 bytes |

```text

```
| 08 PHP \ × 2 28 PLP / EA ... NOP × 4 | No requirements |

### 23 cycles

| 6 bytes |

```text

```
| 18 ... CLC × 2 A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 | Clobbers A, Z&N, and C |

```text

```
| EA NOP A2 04 LDX #4 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA NOP A0 04 LDY #4 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| EA NOP 08 PHP \ × 3 28 PLP / | No requirements |

### 24 cycles

| 4 bytes |

```text

```
| A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 | Clobbers A, Z&N, and C |
| 6 bytes |

```text

```
| 20 xx xx JSR @rts12× 2 | Requires @rts12 |
| 7 bytes |

```text

```
| A6 A6 LDX $A6 A2 04 LDX #4 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| A4 A4 LDY $A4 A0 04 LDY #4 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 08 PHP C5 C5 CMP $C5 28 PLP \ × 2 08 PHP / 28 PLP | No requirements |

### 25 cycles

| 7 bytes |

```text

```
| 98 TYA A0 04 LDY #4 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 2 A2 04 LDX #4 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA ... NOP × 2 A0 04 LDY #4 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| EA ... NOP × 2 08 PHP \ × 3 28 PLP / | No requirements |

### 26 cycles

| 5 bytes |

```text

```
| 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 | Clobbers A, Z&N, and C |

```text

```
| A2 04 LDX #4 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| A0 05 LDY #5 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| EA NOP 20 xx xx JSR @rts12× 2 | Requires @rts12 |
| 8 bytes |

```text

```
| 08 PHP 48 PHA 36 36 ROL $36,X 76 36 ROR $36,X 68 PLA 28 PLP | No requirements |

### 27 cycles

| 6 bytes |

```text

```
| A5 A5 LDA $A5 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 | Clobbers A, Z&N, and C |
| 7 bytes |

```text

```
| 48 PHA A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 28 PLP | Clobbers A |

```text

```
| 24 2C BIT <$2C ;hides 'BIT $FDA2' A2 FD LDX #253 E8 INX D0 FA BNE *-4 | Clobbers X, Z&N, and V |

```text

```
| 24 2C BIT <$2C ;hides 'BIT $FDA0' A0 FD LDY #253 C8 INY D0 FA BNE *-4 | Clobbers Y, Z&N, and V |

```text

```
| A4 AC LDY <$AC ;hides 'LDY $82A2' A2 82 LDX #130 CA DEX 30 FA BMI *-4 | Clobbers X, Y, and Z&N |
| 8 bytes |

```text

```
| EA ... NOP × 3 A2 04 LDX #4 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA ... NOP × 3 A0 04 LDY #4 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |

```text

```
| 24 24 BIT $24 20 xx xx JSR @rts12× 2 | Clobbers Z&N, and V; and requires @rts12 |

```text

```
| 20 xx xx JSR @rts12 08 PHP BA TSX 28 PLP 9A TXS 28 PLP | Clobbers X; and requires @rts12 |
| 9 bytes |

```text

```
| EA ... NOP × 3 08 PHP \ × 3 28 PLP / | No requirements |

### 28 cycles

| 6 bytes |

```text

```
| 38 ... SEC × 2 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 | Clobbers A, Z&N, and C |

```text

```
| EA NOP A2 04 LDX #4 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| EA NOP A0 05 LDY #5 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 04 LDX #4 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 04 LDY #4 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 8 bytes |

```text

```
| 08 PHP \ × 4 28 PLP / | No requirements |

### 29 cycles

| 6 bytes |

```text

```
| 18 CLC A9 2A LDA #$2A ;hides 'ROL A' EA NOP 90 FC BCC *-2 | Clobbers A, Z&N, and C |

```text

```
| A2 04 LDX #4 EA NOP CA DEX D0 FC BNE *-2 | Clobbers X, and Z&N |

```text

```
| A0 04 LDY #4 EA NOP 88 DEY D0 FC BNE *-2 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 02 LDX #2 EA NOP CA DEX 10 FC BPL *-2 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 03 LDY #3 EA NOP 88 DEY D0 FC BNE *-2 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 28 PLP 08 PHP C5 C5 CMP $C5 28 PLP 20 xx xx JSR @rts12 | Requires @rts12 |
| 10 bytes |

```text

```
| 08 PHP C5 C5 CMP $C5 28 PLP 08 PHP 36 36 ROL $36,X 76 36 ROR $36,X 28 PLP | No requirements |

### 30 cycles

| 7 bytes |

```text

```
| 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 2 A2 04 LDX #4 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| EA ... NOP × 2 A0 05 LDY #5 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 18 ... CLC × 2 A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 ... CLC × 2 A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 28 PLP | Clobbers A |

```text

```
| EA NOP 08 PHP A2 04 LDX #4 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| EA NOP 08 PHP A0 04 LDY #4 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 6A LDA #$6A ;hides 'ROR A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 31 cycles

| 5 bytes |

```text

```
| 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 | Clobbers A, Z&N, and C |

```text

```
| A2 05 LDX #5 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| A0 06 LDY #6 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 6 bytes |

```text

```
| 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 28 PLP | Clobbers A |
| 8 bytes |

```text

```
| 08 PHP 28 PLP 20 xx xx JSR @rts12× 2 | Requires @rts12 |
| 9 bytes |

```text

```
| 08 PHP A6 A6 LDX $A6 A2 04 LDX #4 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A4 A4 LDY $A4 A0 04 LDY #4 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| 08 PHP 36 36 ROL $36,X \ × 2 76 36 ROR $36,X / 28 PLP | No requirements |

### 32 cycles

| 6 bytes |

```text

```
| A2 05 LDX #5 ;hides 'ORA zp' CA DEX ;first loop only CA DEX D0 FB BNE *-3 | Clobbers A, X, and Z&N |

```text

```
| A0 05 LDY #5 ;hides 'ORA zp' 88 DEY ;first loop only 88 DEY D0 FB BNE *-3 | Clobbers A, Y, and Z&N |
| 7 bytes |

```text

```
| A9 2A LDA #$2A ;hides 'ROL A' EA ... NOP × 3 10 FA BPL *-4 | Clobbers A, Z&N, and C |
| 8 bytes |

```text

```
| EA NOP 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| A6 A6 LDX $A6 A2 04 LDX #4 EA NOP CA DEX D0 FC BNE *-2 | Clobbers X, and Z&N |

```text

```
| A4 A4 LDY $A4 A0 04 LDY #4 EA NOP 88 DEY D0 FC BNE *-2 | Clobbers Y, and Z&N |
| 9 bytes |

```text

```
| 48 PHA 98 TYA A0 04 LDY #4 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA | Clobbers Z&N |

```text

```
| 08 PHP 98 TYA A0 04 LDY #4 88 DEY D0 FD BNE *-1 A8 TAY 28 PLP | Clobbers A |

```text

```
| EA ... NOP × 2 08 PHP A2 04 LDX #4 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| EA ... NOP × 2 08 PHP A0 04 LDY #4 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 18 ... CLC × 2 A9 6A LDA #$6A ;hides 'ROR A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 33 cycles

| 6 bytes |

```text

```
| 18 ... CLC × 2 A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 | Clobbers A, Z&N, and C |

```text

```
| EA NOP A2 05 LDX #5 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| EA NOP A0 06 LDY #6 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 04 LDX #4 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 05 LDY #5 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| EA NOP 08 PHP 28 PLP 20 xx xx JSR @rts12× 2 | Requires @rts12 |
| 10 bytes |

```text

```
| 08 PHP \ × 2 28 PLP / 08 PHP 36 36 ROL $36,X 76 36 ROR $36,X 28 PLP | No requirements |

### 34 cycles

| 5 bytes |

```text

```
| A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 | Clobbers A, Z&N, and C |

```text

```
| A0 88 LDY #136 ;hides 'DEY' 88 DEY 30 FC BMI *-2 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| A6 A6 LDX $A6 A2 05 LDX #5 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |
| 8 bytes |

```text

```
| C5 C5 CMP $C5 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A5 A5 LDA $A5 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 28 PLP | Clobbers A |
| 9 bytes |

```text

```
| 08 PHP 48 PHA A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 68 PLA 28 PLP | No requirements |

### 35 cycles

| 6 bytes |

```text

```
| A9 2A LDA #$2A ;hides 'ROL A' 08 PHP 28 PLP 10 FB BPL *-3 | Clobbers A, Z&N, and C |

```text

```
| A2 F8 LDX #248 ;hides 'SED' E8 ... INX × 2 D0 FB BNE *-3 | Clobbers X, Z&N, and D |

```text

```
| A0 88 LDY #136 ;hides 'DEY' 88 ... DEY × 2 30 FB BMI *-3 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 98 TYA A0 06 LDY #6 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 2 A2 05 LDX #5 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 38 ... SEC × 2 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 38 ... SEC × 2 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 28 PLP | Clobbers A |

```text

```
| EA NOP 08 PHP A2 04 LDX #4 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |

```text

```
| EA NOP 08 PHP A0 05 LDY #5 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 36 cycles

| 5 bytes |

```text

```
| A9 E9 LDA #$E9 ;hides 'SBC #$2A' 2A ROL A ;first loop only B0 FC BCS *-2 | Clobbers A, Z&N, C, and V |

```text

```
| A2 07 LDX #7 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| A0 06 LDY #6 88 DEY 10 FD BPL *-1 | Clobbers Y, and Z&N |
| 6 bytes |

```text

```
| 38 SEC A9 0A LDA #$0A ;hides 'ASL A' 38 SEC 10 FC BPL *-2 | Clobbers A, Z&N, and C |
| 8 bytes |

```text

```
| 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' EA NOP 90 FC BCC *-2 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 CLC A9 2A LDA #$2A ;hides 'ROL A' EA NOP 90 FC BCC *-2 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 04 LDX #4 EA NOP CA DEX D0 FC BNE *-2 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 04 LDY #4 EA NOP 88 DEY D0 FC BNE *-2 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 20 xx xx JSR @rts12× 3 | Requires @rts12 |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 38 SEC 10 FC BPL *-2 68 PLA 28 PLP | No requirements |

### 37 cycles

| 7 bytes |

```text

```
| A5 A5 LDA $A5 A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 | Clobbers A, Z&N, and C |

```text

```
| A2 04 LDX #4 EA ... NOP × 2 CA DEX D0 FB BNE *-3 | Clobbers X, and Z&N |

```text

```
| A0 04 LDY #4 EA ... NOP × 2 88 DEY D0 FB BNE *-3 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| EA NOP 98 TYA A0 06 LDY #6 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |
| 9 bytes |

```text

```
| 48 PHA 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA | Clobbers Z&N |

```text

```
| 08 PHP 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY 28 PLP | Clobbers A |

```text

```
| EA ... NOP × 2 08 PHP A2 04 LDX #4 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |

```text

```
| EA ... NOP × 2 08 PHP A0 05 LDY #5 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 18 ... CLC × 2 A9 2A LDA #$2A ;hides 'ROL A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 38 cycles

| 6 bytes |

```text

```
| 38 SEC A9 69 LDA #$69 ;hides 'ADC #$EA' EA NOP ;first loop only B0 FC BCS *-2 | Clobbers A, Z&N, C, and V |

```text

```
| EA NOP A2 07 LDX #7 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA NOP A0 06 LDY #6 88 DEY 10 FD BPL *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 05 LDX #5 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 06 LDY #6 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 8 bytes |

```text

```
| 08 PHP 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA 28 PLP | No requirements |

### 39 cycles

| 4 bytes |

```text

```
| A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 | Clobbers A, Z&N, and C |
| 7 bytes |

```text

```
| A6 A6 LDX $A6 A2 07 LDX #7 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| A4 A4 LDY $A4 A0 06 LDY #6 88 DEY 10 FD BPL *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 98 TYA A0 88 LDY #136 ;hides 'DEY' 88 ... DEY × 2 30 FB BMI *-3 A8 TAY | Clobbers A, and Z&N |

```text

```
| 08 PHP A2 05 LDX #5 ;hides 'ORA zp' CA DEX ;first loop only CA DEX D0 FB BNE *-3 28 PLP | Clobbers A, and X |

```text

```
| 08 PHP A0 05 LDY #5 ;hides 'ORA zp' 88 DEY ;first loop only 88 DEY D0 FB BNE *-3 28 PLP | Clobbers A, and Y |
| 9 bytes |

```text

```
| 48 PHA A9 2A LDA #$2A ;hides 'ROL A' EA ... NOP × 3 10 FA BPL *-4 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 2A LDA #$2A ;hides 'ROL A' EA ... NOP × 3 10 FA BPL *-4 28 PLP | Clobbers A |
| 10 bytes |

```text

```
| EA NOP 48 PHA 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA | Clobbers Z&N |

```text

```
| 08 PHP A6 A6 LDX $A6 A2 04 LDX #4 EA NOP CA DEX D0 FC BNE *-2 28 PLP | Clobbers X |

```text

```
| 08 PHP A4 A4 LDY $A4 A0 04 LDY #4 EA NOP 88 DEY D0 FC BNE *-2 28 PLP | Clobbers Y |
| 11 bytes |

```text

```
| 08 PHP 48 PHA 98 TYA A0 04 LDY #4 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA 28 PLP | No requirements |

### 40 cycles

| 6 bytes |

```text

```
| A2 05 LDX #5 ;hides 'ORA zp' EA NOP CA DEX D0 FB BNE *-3 | Clobbers A, X, and Z&N |

```text

```
| A0 05 LDY #5 ;hides 'ORA zp' EA NOP 88 DEY D0 FB BNE *-3 | Clobbers A, Y, and Z&N |
| 7 bytes |

```text

```
| 98 TYA A0 06 LDY #6 88 DEY 10 FD BPL *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 2 A2 07 LDX #7 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA ... NOP × 2 A0 06 LDY #6 88 DEY 10 FD BPL *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 18 ... CLC × 2 A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 18 ... CLC × 2 A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 28 PLP | Clobbers A |

```text

```
| EA NOP 08 PHP A2 05 LDX #5 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |

```text

```
| EA NOP 08 PHP A0 06 LDY #6 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA 28 PLP | No requirements |

### 41 cycles

| 5 bytes |

```text

```
| 38 SEC A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 | Clobbers A, Z&N, and C |

```text

```
| A2 08 LDX #8 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| A0 08 LDY #8 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 28 PLP | Clobbers A |

```text

```
| 08 PHP A0 88 LDY #136 ;hides 'DEY' 88 DEY 30 FC BMI *-2 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP A6 A6 LDX $A6 A2 05 LDX #5 CA DEX 10 FD BPL *-1 28 PLP | Clobbers X |
| 10 bytes |

```text

```
| 08 PHP 48 PHA A5 A5 LDA $A5 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA 28 PLP | No requirements |

### 42 cycles

| 6 bytes |

```text

```
| A5 A5 LDA $A5 A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 | Clobbers A, Z&N, and C |
| 7 bytes |

```text

```
| EA NOP A2 05 LDX #5 ;hides 'ORA zp' EA NOP CA DEX D0 FB BNE *-3 | Clobbers A, X, and Z&N |

```text

```
| EA NOP A0 05 LDY #5 ;hides 'ORA zp' EA NOP 88 DEY D0 FB BNE *-3 | Clobbers A, Y, and Z&N |
| 8 bytes |

```text

```
| 48 PHA A9 2A LDA #$2A ;hides 'ROL A' 08 PHP 28 PLP 10 FB BPL *-3 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 2A LDA #$2A ;hides 'ROL A' 08 PHP 28 PLP 10 FB BPL *-3 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 F8 LDX #248 ;hides 'SED' E8 ... INX × 2 D0 FB BNE *-3 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 88 LDY #136 ;hides 'DEY' 88 ... DEY × 2 30 FB BMI *-3 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 48 PHA 98 TYA A0 06 LDY #6 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA | Clobbers Z&N |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 38 ... SEC × 2 A9 0A LDA #$0A ;hides 'ASL A' 10 FD BPL *-1 68 PLA 28 PLP | No requirements |

### 43 cycles

| 6 bytes |

```text

```
| 38 ... SEC × 2 A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 | Clobbers A, Z&N, and C |

```text

```
| A2 05 LDX #5 EA NOP CA DEX 10 FC BPL *-2 | Clobbers X, and Z&N |

```text

```
| A0 06 LDY #6 EA NOP 88 DEY D0 FC BNE *-2 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA A9 E9 LDA #$E9 ;hides 'SBC #$2A' 2A ROL A ;first loop only B0 FC BCS *-2 68 PLA | Clobbers Z&N, C, and V |

```text

```
| 08 PHP A9 E9 LDA #$E9 ;hides 'SBC #$2A' 2A ROL A ;first loop only B0 FC BCS *-2 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 07 LDX #7 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 06 LDY #6 88 DEY 10 FD BPL *-1 28 PLP | Clobbers Y |
| 8 bytes |

```text

```
| 48 PHA 38 SEC A9 0A LDA #$0A ;hides 'ASL A' 38 SEC 10 FC BPL *-2 68 PLA | Clobbers Z&N, and C |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 2A LDA #$2A ;hides 'ROL A' EA NOP 90 FC BCC *-2 68 PLA 28 PLP | No requirements |

### 44 cycles

| 6 bytes |

```text

```
| A9 0A LDA #$0A ;hides 'ASL A' EA ... NOP × 2 10 FB BPL *-3 | Clobbers A, Z&N, and C |

```text

```
| A0 88 LDY #136 ;hides 'DEY' EA NOP 88 DEY 30 FB BMI *-3 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| A6 A6 LDX $A6 A2 08 LDX #8 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |
| 9 bytes |

```text

```
| C5 C5 CMP $C5 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A5 A5 LDA $A5 A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 04 LDX #4 EA ... NOP × 2 CA DEX D0 FB BNE *-3 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 04 LDY #4 EA ... NOP × 2 88 DEY D0 FB BNE *-3 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| EA NOP 48 PHA 98 TYA A0 06 LDY #6 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA | Clobbers Z&N |
| 11 bytes |

```text

```
| 08 PHP 48 PHA 98 TYA A0 05 LDY #5 88 DEY D0 FD BNE *-1 A8 TAY 68 PLA 28 PLP | No requirements |

### 45 cycles

| 7 bytes |

```text

```
| 98 TYA A0 08 LDY #8 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 2 A2 08 LDX #8 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| EA ... NOP × 2 A0 08 LDY #8 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 38 SEC A9 69 LDA #$69 ;hides 'ADC #$EA' EA NOP ;first loop only B0 FC BCS *-2 68 PLA | Clobbers Z&N, C, and V |

```text

```
| 08 PHP 38 SEC A9 69 LDA #$69 ;hides 'ADC #$EA' EA NOP ;first loop only B0 FC BCS *-2 28 PLP | Clobbers A |

```text

```
| EA NOP 08 PHP A2 07 LDX #7 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| EA NOP 08 PHP A0 06 LDY #6 88 DEY 10 FD BPL *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA 18 CLC A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 46 cycles

| 5 bytes |

```text

```
| A2 08 LDX #8 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| A0 09 LDY #9 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 6 bytes |

```text

```
| 48 PHA A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 28 PLP | Clobbers A |
| 9 bytes |

```text

```
| 08 PHP A6 A6 LDX $A6 A2 07 LDX #7 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A4 A4 LDY $A4 A0 06 LDY #6 88 DEY 10 FD BPL *-1 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| 48 PHA 98 TYA A0 88 LDY #136 ;hides 'DEY' 88 ... DEY × 2 30 FB BMI *-3 A8 TAY 68 PLA | Clobbers Z&N |
| 11 bytes |

```text

```
| 08 PHP 48 PHA A9 2A LDA #$2A ;hides 'ROL A' EA ... NOP × 3 10 FA BPL *-4 68 PLA 28 PLP | No requirements |

### 47 cycles

| 8 bytes |

```text

```
| 98 TYA A0 06 LDY #6 EA NOP 88 DEY D0 FC BNE *-2 A8 TAY | Clobbers A, and Z&N |

```text

```
| EA ... NOP × 3 A2 08 LDX #8 CA DEX D0 FD BNE *-1 | Clobbers X, and Z&N |

```text

```
| 08 PHP A2 05 LDX #5 ;hides 'ORA zp' EA NOP CA DEX D0 FB BNE *-3 28 PLP | Clobbers A, and X |

```text

```
| EA ... NOP × 3 A0 08 LDY #8 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |

```text

```
| 08 PHP A0 05 LDY #5 ;hides 'ORA zp' EA NOP 88 DEY D0 FB BNE *-3 28 PLP | Clobbers A, and Y |
| 9 bytes |

```text

```
| 48 PHA 98 TYA A0 06 LDY #6 88 DEY 10 FD BPL *-1 A8 TAY 68 PLA | Clobbers Z&N |

```text

```
| 08 PHP 98 TYA A0 06 LDY #6 88 DEY 10 FD BPL *-1 A8 TAY 28 PLP | Clobbers A |

```text

```
| EA ... NOP × 2 08 PHP A2 07 LDX #7 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| EA ... NOP × 2 08 PHP A0 06 LDY #6 88 DEY 10 FD BPL *-1 28 PLP | Clobbers Y |
| 10 bytes |

```text

```
| 08 PHP 48 PHA 18 ... CLC × 2 A9 0A LDA #$0A ;hides 'ASL A' 90 FD BCC *-1 68 PLA 28 PLP | No requirements |

### 48 cycles

| 6 bytes |

```text

```
| EA NOP A2 08 LDX #8 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |

```text

```
| EA NOP A0 09 LDY #9 88 DEY D0 FD BNE *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 48 PHA 38 SEC A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 38 SEC A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 08 LDX #8 CA DEX D0 FD BNE *-1 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 08 LDY #8 88 DEY D0 FD BNE *-1 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA A9 0A LDA #$0A ;hides 'ASL A' 18 CLC 10 FC BPL *-2 68 PLA 28 PLP | No requirements |

### 49 cycles

| 4 bytes |

```text

```
| A0 88 LDY #136 ;hides 'DEY' 30 FD BMI *-1 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 18 CLC A9 2A LDA #$2A ;hides 'ROL A' 08 PHP 28 PLP 90 FB BCC *-3 | Clobbers A, Z&N, and C |

```text

```
| A6 A6 LDX $A6 A2 08 LDX #8 CA DEX 10 FD BPL *-1 | Clobbers X, and Z&N |
| 8 bytes |

```text

```
| C5 C5 CMP $C5 48 PHA A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP A5 A5 LDA $A5 A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 28 PLP | Clobbers A |
| 10 bytes |

```text

```
| 08 PHP 48 PHA A9 2A LDA #$2A ;hides 'ROL A' 08 PHP 28 PLP 10 FB BPL *-3 68 PLA 28 PLP | No requirements |

### 50 cycles

| 6 bytes |

```text

```
| A9 E9 LDA #$E9 ;hides 'SBC #$2A' 2A ROL A ;first loop only EA NOP B0 FB BCS *-3 | Clobbers A, Z&N, C, and V |

```text

```
| A2 07 LDX #7 EA NOP CA DEX D0 FC BNE *-2 | Clobbers X, and Z&N |

```text

```
| A0 06 LDY #6 EA NOP 88 DEY 10 FC BPL *-2 | Clobbers Y, and Z&N |
| 7 bytes |

```text

```
| 98 TYA A0 09 LDY #9 88 DEY D0 FD BNE *-1 A8 TAY | Clobbers A, and Z&N |
| 8 bytes |

```text

```
| 48 PHA 38 ... SEC × 2 A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 68 PLA | Clobbers Z&N, and C |

```text

```
| 08 PHP 38 ... SEC × 2 A9 4A LDA #$4A ;hides 'LSR A' D0 FD BNE *-1 28 PLP | Clobbers A |

```text

```
| 08 PHP A2 05 LDX #5 EA NOP CA DEX 10 FC BPL *-2 28 PLP | Clobbers X |

```text

```
| 08 PHP A0 06 LDY #6 EA NOP 88 DEY D0 FC BNE *-2 28 PLP | Clobbers Y |
| 9 bytes |

```text

```
| 08 PHP 48 PHA A9 E9 LDA #$E9 ;hides 'SBC #$2A' 2A ROL A ;first loop only B0 FC BCS *-2 68 PLA 28 PLP | No requirements |

## Sanity checks

It is possible to verify on compile time that no page wrap occurs, by replacing all branches with these macros:

```text
.macro branch_check opc, dest
    opc dest
    .assert >* = >(dest), warning, "branch_check: failed, crosses page"
.endmacro
.macro bccnw dest
        branch_check bcc, dest
.endmacro
.macro bcsnw dest
        branch_check bcs, dest
.endmacro
.macro beqnw dest
        branch_check beq, dest
.endmacro
.macro bnenw dest
        branch_check bne, dest
.endmacro
.macro bminw dest
        branch_check bmi, dest
.endmacro
.macro bplnw dest
        branch_check bpl, dest
.endmacro
.macro bvcnw dest
        branch_check bvc, dest
.endmacro
.macro bvsnw dest
        branch_check bvs, dest
.endmacro
```

## See also
- Cycle counting
- Delay codefor functions that produce runtime-determined amount of delay
- Bisqwit’s “vending machine” for producing a ca65-compatible delay_n macro for arbitrary number of cycles, with more fine-grained configurable constraints: http://bisqwit.iki.fi/utils/nesdelay.phpThe samples on this page are excerpts from files generated by this online tool.
