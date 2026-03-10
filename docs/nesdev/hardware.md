# hardware

# AxROM

Source: https://www.nesdev.org/wiki/AMROM

AxROM

| Company | Nintendo, Rare, others |
| Games | 34 in NesCartDB |
| Complexity | Discrete logic |

| Boards | AMROM, ANROM, AN1ROM, AOROM, others |
| PRG ROM capacity | 256K |
| PRG ROM window | 32K |
| PRG RAM capacity | None |
| PRG RAM window | n/a |
| CHR capacity | 8K |
| CHR window | n/a |
| Nametable arrangement | 1 page switchable |
| Bus conflicts | AMROM/AOROM only |
| IRQ | No |
| Audio | No |
| iNES mappers | 007 |
NESCartDB

| iNES 007 |
| AxROM |
| AMROM |
| ANROM |
| AN1ROM |
| AOROM |

The generic designation AxROM refers to Nintendo cartridge boards NES-AMROM , NES-ANROM , NES-AN1ROM , NES-AOROM , their HVCcounterparts, and clone boards. AxROM and compatible boards are implemented in iNESformat with iNES Mapper 7 .

## Board types

The following AxROM boards are known to exist:

| Board | PRG ROM | Bus conflicts |
| AMROM | 128 KB | Yes |
| ANROM | 128 KB | No |
| AN1ROM | 64 KB | No |
| AOROM | 128 / 256 KB | Depends on +CE wiring |

## Overview
- PRG ROM size: up to 256 KB
- PRG ROM bank size: 32 KB
- PRG RAM: None
- CHR capacity: 8 KB RAM
- CHR bank size: Not bankswitched
- Nametable mirroring: Single-screen, mapper-selectable
- Subject to bus conflicts: AMROM/AOROM only

## Banks
- CPU $8000-$FFFF: 32 KB switchable PRG ROM bank

## Solder pad config

No solder pad config is needed on the AxROM board family.

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxxM xPPP
   |  |||
   |  +++- Select 32 KB PRG ROM bank for CPU $8000-$FFFF
   +------ Select 1 KB VRAM page for all 4 nametables

```

## Hardware

The AxROM boards contain a 74HC161binary counter used as a quad D latch (4-bit register). The ANROM and AN1ROM boards also contains a 74HC02which is used to disable the PRG ROM during writes, thus avoiding bus conflicts.

## Various notes

On the AOROM board, special mask ROMs with an additional positive CE on pin 31 (which is connected to PRG R/W) can be used to prevent bus conflicts without an additional chip. Some 128 KB games were made with AOROM to save the cost of a 74HC02. It seems that only Double Dare and Wheel of Fortune employ this trick noticeably--that is, if emulated with bus conflicts enabled, the games will glitch. The list of AxROM games in NesCartDBlacks quality coverage of the PCB backs for the AOROM games, so it is hard to determine yet which games may be wired this way.

It is likely that every retail AOROM game could be emulated correctly without emulating bus conflicts.

## Variants

BNROMis the same as AMROM except it uses a fixed horizontal or vertical mirroring.

Some emulators allow bit 3 to be used to select up to 512 KB of PRG ROM for an oversized AxROM. In hardware this could be implemented by using an octal latch in place of the quad latch ( 74HC377).

The pirate multicart and unlicensed music game Hot Dance 2000 uses a 512 KB AxROM variant.

A ROM Hack of Battletoads expanded the ROM size to 512 KB.

## See also
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.

# AxROM

Source: https://www.nesdev.org/wiki/ANROM

AxROM

| Company | Nintendo, Rare, others |
| Games | 34 in NesCartDB |
| Complexity | Discrete logic |

| Boards | AMROM, ANROM, AN1ROM, AOROM, others |
| PRG ROM capacity | 256K |
| PRG ROM window | 32K |
| PRG RAM capacity | None |
| PRG RAM window | n/a |
| CHR capacity | 8K |
| CHR window | n/a |
| Nametable arrangement | 1 page switchable |
| Bus conflicts | AMROM/AOROM only |
| IRQ | No |
| Audio | No |
| iNES mappers | 007 |
NESCartDB

| iNES 007 |
| AxROM |
| AMROM |
| ANROM |
| AN1ROM |
| AOROM |

The generic designation AxROM refers to Nintendo cartridge boards NES-AMROM , NES-ANROM , NES-AN1ROM , NES-AOROM , their HVCcounterparts, and clone boards. AxROM and compatible boards are implemented in iNESformat with iNES Mapper 7 .

## Board types

The following AxROM boards are known to exist:

| Board | PRG ROM | Bus conflicts |
| AMROM | 128 KB | Yes |
| ANROM | 128 KB | No |
| AN1ROM | 64 KB | No |
| AOROM | 128 / 256 KB | Depends on +CE wiring |

## Overview
- PRG ROM size: up to 256 KB
- PRG ROM bank size: 32 KB
- PRG RAM: None
- CHR capacity: 8 KB RAM
- CHR bank size: Not bankswitched
- Nametable mirroring: Single-screen, mapper-selectable
- Subject to bus conflicts: AMROM/AOROM only

## Banks
- CPU $8000-$FFFF: 32 KB switchable PRG ROM bank

## Solder pad config

No solder pad config is needed on the AxROM board family.

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxxM xPPP
   |  |||
   |  +++- Select 32 KB PRG ROM bank for CPU $8000-$FFFF
   +------ Select 1 KB VRAM page for all 4 nametables

```

## Hardware

The AxROM boards contain a 74HC161binary counter used as a quad D latch (4-bit register). The ANROM and AN1ROM boards also contains a 74HC02which is used to disable the PRG ROM during writes, thus avoiding bus conflicts.

## Various notes

On the AOROM board, special mask ROMs with an additional positive CE on pin 31 (which is connected to PRG R/W) can be used to prevent bus conflicts without an additional chip. Some 128 KB games were made with AOROM to save the cost of a 74HC02. It seems that only Double Dare and Wheel of Fortune employ this trick noticeably--that is, if emulated with bus conflicts enabled, the games will glitch. The list of AxROM games in NesCartDBlacks quality coverage of the PCB backs for the AOROM games, so it is hard to determine yet which games may be wired this way.

It is likely that every retail AOROM game could be emulated correctly without emulating bus conflicts.

## Variants

BNROMis the same as AMROM except it uses a fixed horizontal or vertical mirroring.

Some emulators allow bit 3 to be used to select up to 512 KB of PRG ROM for an oversized AxROM. In hardware this could be implemented by using an octal latch in place of the quad latch ( 74HC377).

The pirate multicart and unlicensed music game Hot Dance 2000 uses a 512 KB AxROM variant.

A ROM Hack of Battletoads expanded the ROM size to 512 KB.

## See also
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.

# AxROM

Source: https://www.nesdev.org/wiki/AOROM

AxROM

| Company | Nintendo, Rare, others |
| Games | 34 in NesCartDB |
| Complexity | Discrete logic |

| Boards | AMROM, ANROM, AN1ROM, AOROM, others |
| PRG ROM capacity | 256K |
| PRG ROM window | 32K |
| PRG RAM capacity | None |
| PRG RAM window | n/a |
| CHR capacity | 8K |
| CHR window | n/a |
| Nametable arrangement | 1 page switchable |
| Bus conflicts | AMROM/AOROM only |
| IRQ | No |
| Audio | No |
| iNES mappers | 007 |
NESCartDB

| iNES 007 |
| AxROM |
| AMROM |
| ANROM |
| AN1ROM |
| AOROM |

The generic designation AxROM refers to Nintendo cartridge boards NES-AMROM , NES-ANROM , NES-AN1ROM , NES-AOROM , their HVCcounterparts, and clone boards. AxROM and compatible boards are implemented in iNESformat with iNES Mapper 7 .

## Board types

The following AxROM boards are known to exist:

| Board | PRG ROM | Bus conflicts |
| AMROM | 128 KB | Yes |
| ANROM | 128 KB | No |
| AN1ROM | 64 KB | No |
| AOROM | 128 / 256 KB | Depends on +CE wiring |

## Overview
- PRG ROM size: up to 256 KB
- PRG ROM bank size: 32 KB
- PRG RAM: None
- CHR capacity: 8 KB RAM
- CHR bank size: Not bankswitched
- Nametable mirroring: Single-screen, mapper-selectable
- Subject to bus conflicts: AMROM/AOROM only

## Banks
- CPU $8000-$FFFF: 32 KB switchable PRG ROM bank

## Solder pad config

No solder pad config is needed on the AxROM board family.

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxxM xPPP
   |  |||
   |  +++- Select 32 KB PRG ROM bank for CPU $8000-$FFFF
   +------ Select 1 KB VRAM page for all 4 nametables

```

## Hardware

The AxROM boards contain a 74HC161binary counter used as a quad D latch (4-bit register). The ANROM and AN1ROM boards also contains a 74HC02which is used to disable the PRG ROM during writes, thus avoiding bus conflicts.

## Various notes

On the AOROM board, special mask ROMs with an additional positive CE on pin 31 (which is connected to PRG R/W) can be used to prevent bus conflicts without an additional chip. Some 128 KB games were made with AOROM to save the cost of a 74HC02. It seems that only Double Dare and Wheel of Fortune employ this trick noticeably--that is, if emulated with bus conflicts enabled, the games will glitch. The list of AxROM games in NesCartDBlacks quality coverage of the PCB backs for the AOROM games, so it is hard to determine yet which games may be wired this way.

It is likely that every retail AOROM game could be emulated correctly without emulating bus conflicts.

## Variants

BNROMis the same as AMROM except it uses a fixed horizontal or vertical mirroring.

Some emulators allow bit 3 to be used to select up to 512 KB of PRG ROM for an oversized AxROM. In hardware this could be implemented by using an octal latch in place of the quad latch ( 74HC377).

The pirate multicart and unlicensed music game Hot Dance 2000 uses a 512 KB AxROM variant.

A ROM Hack of Battletoads expanded the ROM size to 512 KB.

## See also
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.

# Arkanoid II prototype controller

Source: https://www.nesdev.org/wiki/Arkanoid_II_prototype_controller

The Arkanoid II prototype controlleris a Famicom expansion port controller that was discovered through a prototype of Arkanoid II , which expects a different interface and behavior than that of the production Arkanoid controller. This behavior has been inferred purely from software.

## Summary

The prototype controller has the following known differences compared to the production controller:
- The analog control knob data and button data for both players are returned on different register bits.
- The control knob data is 8 bits instead of 9. Reading past 8 bits returns 1.

It is suspected the prototype controller also has these differences, but they don't matter for the prototype software and thus cannot be confirmed:
- Both players' controllers may be hardwired together rather than using an additional port for daisy chaining.
- The write interface may use OUT0 to latch the shift register and OUT1 to start a conversion, rather than simply using OUT0 to start a conversion and automatically latching when finished.

## Layout

The prototype controller has the same knob and button controls as the production controller, so it is expected to have a similar layout. It is not known if it contains potentiometers for calibration. It is suspected that the prototype may have had two controllers connected to the same expansion port plug, rather than the daisy chain design of the production Arkanoid II controller. This is because the prototype checks for the presence of controller 1 but not controller 2, while checking for both would make more sense in a daisy chain design.

## Interface

### Input ($4016 write)

The write interface for the prototype controller is not known for certain, but it is compatible with the OUT0 strobe interfaceused for production Arkanoid controllers and may function the same way. However, like the final version of the game, the prototype also strobes OUT1 after it is done reading both players' inputs, which normally has no effect. Although it is impossible to verify this without access to the controller itself, it is speculated that the prototype may use OUT0 to latch the control knob data into the shift register and OUT1 to start a conversion. In contrast, the production Arkanoid II controller works the same way as the original Arkanoid controller, using OUT0 to start a conversion and automatically loading the result into the shift register when the conversion completes.

### Output ($4016/$4017 read)

```text
$4016 read:
7  bit  0
---- ----
xxxx xxDx
       |
       +- Controller 1 serial control knob data (8-bit, inverted, MSb first, followed by 1's)

$4017 read:
7  bit  0
---- ----
xxxB BxDx
   | | |
   | | +- Controller 2 serial control knob data (8-bit, inverted, MSb first, followed by 1's)
   | +--- Controller 1 fire button
   +----- Controller 2 fire button

```

Notably, the prototype controller appears to only expose an 8-bit control knob conversion value, not 9-bit like the production version. The production controllers connect the least significant bit of the 9-bit conversion value to the shift register's serial input, while the prototype appears to connect this to ground, causing it to return 1. This is inferred from the prototype game replacing the control knob data with $FF if bit 8 is not 1. This was likely done to detect whether the controller is plugged in; if it isn't, this bit is 0.

### Control knob data

It is not known what the control knob's value range is nor whether there are potentiometers for centering or scaling. However, the Arkanoid II prototype expects the following value ranges:
- 1P mode: $26-$B9
- VS player 1: $4C-$D3
- VS player 2: $5D-$E4

Values outside of these ranges are clamped, so the game is playable even if allowing the full 8-bit range.

# Arkanoid controller

Source: https://www.nesdev.org/wiki/Arkanoid_controller

The Arkanoid controller(commonly called the Vaus controller) was included with Arkanoid and Arkanoid II , and is only used for these and Taito Chase HQ . Multiple versions of this controller were produced. The Famicom and NES versions use different joypad bits and must be handled by software separately. The Arkanoid II controller has a Famicom expansion portintended for multiplayer using another Famicom Arkanoid controller of either type. No version is compatible with four player adapters.

## Layout

The controller has a single fire button and a control knob connected to a potentiometer. Some Arkanoid I controllers have a centering pot accessible under a plastic cover to adjust the control knob's value range; others do not have this pot at all. Arkanoid II controllers have this centering pot and also a scaling pot under this cover that adjusts the size of the control knob's value range, and have a Famicom expansion port next to the cord for connecting a second Arkanoid controller for multiplayer.

```text
Arkanoid I controller:
             ,--------------------------------------.   |
             |                  %%                  |   |
             |   ,---.          %%                % |   |
             |  /     \         %%         ,-.   %% |   |
  Control--->| |       |        %%        (   )  %% |<- Fire button
    knob     |  \     /         %%         `-'   %% |   |
             |   `---'          %%                % |==/
 Centering ->|     ()           %%                  |
 pot cover   `--------------------------------------'

Arkanoid II controller:
             ,--------------------------------------.   |
             |                  %%                  |   |
             |   ,---.          %%                  |==/
             |  /     \         %%       ,-.        |
  Control--->| |       |        %%      (   )       |<- Fire button
    knob     |  \     /         %%       `-'        |
             |   `---'          %%                  |<- Famicom EXP port
Calibration->|    (    )        %%                  |
 pots cover  `--------------------------------------'

```

## Interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxC
        |
        +- Start ADC

```

When C goes from 0 to 1, a conversionis started. The results of this conversion are collected in a counter that is reset while C is 1, so C should be quickly returned to 0. Once the conversion is complete, the shift registeris automatically loaded with the results of the counter. Additional strobes during a conversion do not restart the conversion. Keeping C at 1 or strobing again before the conversion is complete will negatively shift the result's range (shift it left) based on when during the conversion C was last set to 0.

The analog to digital conversion time depends on the control knob's position; smaller results will convert faster. Experimentally, the conversion takes up to 7 ms, so at least this amount of time should pass between strobes. Strobing again too soon will return bad data.

Arkanoid II and Taito Chase H.Q. perform a strobe of OUT1, but the controller cannot see this because the pin is not connected, so it has no effect. The reason for this strobe is not known.

### Output ($4016/$4017 read)

Famicom:

```text
$4016:
7  bit  0
---- ----
xxxx xxBx
       |
       +-- Fire button (1: pressed)

$4017:
7  bit  0
---- ----
xxxx xxDx
       |
       +-- Serial control knob data (9-bit, inverted, MSb first)

```

NES:

```text
7  bit  0
---- ----
xxxD Bxxx
   | |
   | +---- Fire button (1: pressed)
   +------ Serial control knob data (9-bit, inverted, MSb first)

```

Fire button status is returned directly from the button and is not affected by the strobe.

Control knob data is returned in 9 bits, most-significant-bit first. Each bit's data is returned inverted, but is discussed in this article according to its raw, pre-inverted state. Turning the knob left reduces the value, and turning it right increases the value. The data is stored in an 8-bit shift register, which latches when a requested conversion completes. The 9th bit is the shift register's serial input, which is latched after the shift register has been read at least once. It is recommended that data be read before sending a strobe pulse.

Outside of a conversion, reading beyond the 9th bit simply repeats the 9th bit, because that bit is the shift register's serial in. During a conversion, the serial in is the current 9th bit according to the in-progress conversion, so each read latches transient conversion state that is returned 8 reads later. Software can use this to determine the rate at which the conversion is counting, which can be useful for calibration.

Because conversions take so long (more than a millisecond), the 8 latched bits can be safely read after strobing the controller and before the new conversion completes. However, because the 9th bit is not initially latched, it is lost if a conversion is started before reading. The licensed games using this controller send a strobe, read 8 bits afterward, and disregard the 9th bit.

### Control knob data

The control knob range depends on the controller and, if present, on the centering and scaling pot settings. Different games have different expectations. The physical knob has a 180 degree range and the canonical value range is believed to be approximately $140 steps (or $A0 steps for an 8-bit read), though the Arkanoid II controller's scaling pot can change the number of steps. The knob boundaries are set by plastic, so wear or additional force may result in values beyond the norm, and fast clockwise turns have been observed returning values briefly exceeding the maximum.

To avoid requiring adjustment of the centering pot, which is not even present on all versions, new games can attempt to find the edges programmatically. Software can attempt to determine the number of steps by measuring the rate of the inner timer (see #Conversionsbelow), and can set a range by watching for the leftmost position (smallest value) returned by the controller, because the leftmost edge is more reliable. Another approach is to track the minimum and maximum positions seen and use the middle $A0 steps. Note that values may wrap around, complicating this detection.

Arkanoid I controller 8-bit measurements:
- Centering pot minimum: $0D-AD
- Centering pot maximum: $5C-FC
- Variations in the analog-to-digital conversion components and pot physical range can vary the results slightly.

Software expectations:
- Arkanoid 8-bit range: $62-$02
- Arkanoid II 8-bit range: $4D-$E2 (normal paddle), $4D-$F2 (tiny paddle)
  - With $A0 steps, the tiny paddle cannot reach right-side warps.

### Conversion

Conversions use two timers and a 12-bit binary counter. The inner timer runs repeatedly and increments the counter each time it expires, and its duration is determined by the scaling pot. The outer timer controls the length of the conversion, and its duration is determined by the control knob and centering pot. The value contained in the counter is latched by a shift registerupon completion of the conversion. The conversion completes when the outer timer expires, and the inner timer only runs during the conversion.

From a hardware perspective, each timer works by charging a capacitor from empty up to a voltage threshold, where the pots control the speed at which the capacitor charges. If the timers are modeled using an integer count, this means the pots control the rate at which it increments, rather than the limit it is counting toward. This distinction matters if the pot is rotated during a conversion; the rate changes as the knob is turned, affecting the total accumulation so far. Players regularly turn the control knob while conversions are in progress, so this happens in practice on real hardware, but it may not be relevant for emulation. If the knob is treated as being at a fixed position throughout the conversion, then using a fixed timer length per position is sufficient.

When the outer timer is not running, it holds the inner timer in reset and watches OUT0 for a rising edge. When this edge occurs, both timers begin running. A conversion always runs until completion; toggling OUT0 will not interrupt or restart an in-progress conversion. While OUT0 is 1, the counter is also continuously cleared. This causes the counter to ignore increments while set, and clears the counter if set mid-conversion.

When the conversion ends, the inner timer is put back in reset and bits 8-1 of the counter are latched into the shift register. Bit 0 is the shift register's serial in, so this value is shifted into the shift register on every CPU read. Bit 0 maintains its value while a conversion is not running. During a conversion, it changes each time the counter increments, and reading brings its current value into the shift register. If the CPU repeatedly reads during a conversion, these transient values expose the rate at which the inner timer is incrementing the counter.

Conversions have the following quirks:
- If OUT0 is 1 when a conversion would complete, the conversion instead continues until OUT0 is cleared. In hardware, this is because the timer capacitor's voltage must exceed that of a signal produced from OUT0, which it can't do when OUT0 is set.
- There is a small race condition where a conversion may be able to start while the timer capacitors are discharging at the end of the previous conversion, causing them to start the next conversion with a non-zero value. It is estimated that the length of this race is on the order of 10 cycles for the outer timer and 1 cycle for the inner timer.

## Arkanoid II expansion port

Arkanoid II' s controller has its own Famicom expansion port. The connected device is able to see OUT0 and Joypad 2 /OE, and its Joypad 1 and 2 D1 outputs are redirected to Joypad 2 D3 and D4. No other signals are passed through. Because of this, any additional devices daisy-chained beyond two Arkanoid II controllers will be unable to send input to the console, but will still receive OUT0 and Joypad 2 /OE.

```text
 Arkanoid II EXP |  | Famicom EXP
-----------------+--+-----------------
         GND   1 |--| 1   GND
 Joypad 2 D1   7 |->| 4   Joypad 2 D4
Joypad 2 /OE   9 |<-| 9   Joypad 2 /OE
        OUT0  12 |<-| 12  OUT0
 Joypad 1 D1  13 |->| 5   Joypad 2 D3
          5V  15 |--| 15  5V

(All other Arkanoid II EXP pins not connected)

```

This port is intended to be used with another Arkanoid controller, but is not limited to this. When used with an Arkanoid controller, $4017 works as follows:

```text
$4017 read:
7  bit  0
---- ----
xxxD BxDx
   | | |
   | | +-- Controller 1 serial control knob data
   | +---- Controller 2 fire button
   +------ Controller 2 serial control knob data

```

It has been observed that adjustments on one controller's control knob can cause slight changes in the result from the other controller's knob.

Although Arkanoid II uses a Family BASIC Keyboardwith Family BASIC Data Recorderfor saving and loading custom levels, the device cannot work correctly over the Arkanoid II controller's expansion port because OUT2, a required input, is not connected. Thus, the keyboard must be plugged directly into the console to save and load.

## DPCM safety

The Arkanoid controller is particularly susceptible to the bugs caused by DMC DMA when using DPCM playback (see DMA register conflictsand DPCM safetyfor details). It is not compatible with the common repeated readssolution because conversions take as long as nearly half a frame to complete, so reads synced with OAM DMAare required. However, even when using synced reads, the controller state may still become corrupted elsewhere. This is because any CPU read in the range $4000-401F can cause DMC DMA to trigger a joypad read, deleting bits from the Arkanoid controller's latched state before the controller reading code can safely access it. These reads are commonly present in sound engines as a side effect of absolute indexed stores (e.g. STA $4000,X). This problem can be worked around in two ways:
- Ensure that only the joypad reading code ever reads from the range $4000-401F. This may require modifying the sound engine or using a different sound engine.
- Ensure that reads from $4000-401F do not occur between the time a conversion completes and when the latched data is read. This can be done by deliberately ordering the code so that these unsafe reads occur after the controller reading code, but before the strobe that starts another conversion. This requires that this unsafe code does not take so long that the conversion may not complete in time for the next controller read, something that is not a problem for most sound engines that are likely the only thing causing these unsafe reads. For most games, the ordering would be: vblank tasks, OAM DMA, synced controller reads, sound engine, controller strobe, game logic.

Software can also attempt to detect and ignore corrupted controller reads by checking for spurious accelerations, where the second differencex t - 2 x t - 1 + x t - 2 exceeds about eight units.

## Hardware

The controller uses a 556 timer (containing 2 timers), a 4040B 12-bit binary counter, and an 8-bit shift register. One timer repeatedly clocks the binary counter and the other measures the control knob position. A centering pot adjusts the control knob timer and a scaling pot adjusts the counter timer. When OUT0 goes high, the counter clears and the control knob timer starts and releases the counter timer from reset, allowing it to begin incrementing the counter. When the control knob timer expires, it puts the counter timer back into reset and latches bits 8-1 of the counter into the shift register. Bit 0 of the counter connects to the shift register's serial input.

## Test ROMs
- Vaus Testshows adaptation to trimpot setting, repeated read rate, and first and second differences
- 9-bit resultsshows and visualizes the 9-bit result
- ADC conversion snoopingshows the number of counter toggles detected in a fixed period of time

# Battery holder

Source: https://www.nesdev.org/wiki/Battery_holder

Adding a battery holder to an NES Game Pak PCB with a dead battery lets a player use that Game Pak to save again. There are many tutorials online that show one how to replace batteries by using electrical tape to wrap the new battery onto the cartridge and hold it in place. This method does not seem very stable. Both methods listed herein differentiate themselves by replacing the battery with a battery holder, which allows for easy replacement of batteries as they wear out and ensures that the battery is always held in rigidly by the design of the holder itself. The first method details how to do this by hot-gluing the battery holder to the bottom side of the NES cartridge. The second method shows how to do this by hot-gluing the battery holder beside the NES cartridge.

## Disclaimer

This tutorial is not a guarantee that anyone utilizing the same method will have the same results. Even the youngest Nintendo cartridges are now 15 years old and applying heat to an electronic component shortens its lifespan. I can only guarantee that these methods have worked for me and I have had only positive results from employing them. Follow the instructions in this tutorial AT YOUR OWN RISK.

## Materials

The first 11 items are shown in Figure 1 with numbers to show their location. Some of the other materials will be shown in their own sections.
- 3.8mm Security Bit
- CR2032 Battery
- CR2032 Battery Holder
- Soldering Iron
- Diagonal Cutter
- Wire Stripper
- Hot glue gun (low temp)
- Solder
- 22 or 24 AWG (0.2-0.3 mm²) Stranded Wire
- Solder Wick
- Solder Sucker

Other materials:
- Rubbing Alcohol
- Q-Tips (Between 2-6)
- Dremel or other rotary tool (Method 1 Only)
  - 2-56 x ¼” screws (Optional – used only if cart screws are lost)
- Needle-Nose pliers (Optional)

### Notes

The 3.8mm security bit is not available at stores and can only be purchased online. You will almost certainly want some sort of driver that the bit will attach to, so that you can make turning it easier.

Make sure that the CR2032 battery holder is an insertion mount type rather than a surface mount type. A surface mount type would be much more difficult to apply with this method. I use Radio Shack model 270-009.

You will want a soldering iron with a thin tip so that you only heat the components that you want to heat. The iron that I employee is 40 watts which may be too much for a small scale electronic application such as this one. If you are unused to soldering or have little confidence in your technique then I recommend using a 30 or 25 watt iron so that you do not cause unnecessary damage from heat.

Choosing the right diagonal cutters is difficult. I often employ two of various sizes. This is because you want a small cutter to be able to work on the small confines of the board, but I have only been able to cut through the “prongs” holding the battery on to the circuit board by using a much larger cutter.

For the wire strippers, simply choose a type that has a setting for the size of wire that you will be using.

Make sure that your hot glue gun is the low temp variety. High temp may be stronger over a greater range of temperatures but it also takes much longer to set. The NES cartridge is unlikely to get hot enough to melt the low temp glue under normal operating conditions so it should be sufficient for your needs. However, if you have the time and wish to hold your battery holder in place long enough for high temp variety to set then that is also a valid option.

I use 60/40 0.32 diameter rosin-core solder but any small gauge solder should work.

## Method 1

This is my preferred method for replacing the batteries on NES carts with battery holders.

### Opening the case

Take your NES security bit and apply it to the NES cartridge screws as shown in Figure 2. Turn counter-clockwise and turn slowly. The screws easily strip out the threads on the cartridge but don’t worry if you do that, we’ll cover a solution later on.

### Removing the battery

After you have removed the security screws, you should be able to locate the battery as shown in Figure 3. Please note that the boards within NES cartridges do vary so your board and the location of the battery may change but the battery itself will look the same as shown in the picture every time. From here on we will always refer to this side of the board as the “top”.

You will note that the battery is held in place by two metal prongs – one below the battery and one above. Take your diagonal cutters and cut both prongs. Try to be careful by removing the battery in such a way that it doesn’t touch any part of the board. When you are done, your board should look like it does in Figure 4.

At this point I would desolder the remains of the prongs. Use your solder wick and solder sucker in combination to remove enough solder to pull these free. Discussing soldering and desoldering technique is beyond the scope of this tutorial but there are plenty of references on the internet. The only real thing to keep in mind is that you should not apply heat to the board for extended periods of time as this can only shorten the life of the cart. If you are worried about your technique then I suggest practicing on old circuit boards or buying a demo board from Radio Shack or some other hardware store.

### Adding the battery holder

Take the CR2032 battery holder and find the end with the two pointed metal terminals that look like legs. Cut about half of the leg off with your diagonal cutters. Then “tin” the leg. Tinning refers to melting a small amount of solder on the leg which will make it easier to solder a wire to it easier. Now take your battery holder press it up against the edge of the board so that the main circular part of the holder is aligned with the flat edge of the board. I find it best to do this as close as possible to where the battery was positioned on the board in the first place (such as on the left hand side of the board shown in Figure 4). Also make sure that the battery holder’s “arm” which holds the battery down is also facing toward you and that the side of the holder where the arm is mounted is closer to the “+” terminal on the board.

Now flip the entire set over so that you are looking at the “bottom” of the board and the battery holder. The previous step of aligning everything while looking at the top of the board can be skipped once you have done this enough times. While holding everything steady, now take your hot glue gun and glue the battery holder to the board. Hold the battery holder in place for some time to allow the glue to dry. Once it is dry you may want to add more glue in various locations to make a stronger hold. Make sure that you provide some support while doing this since the existing glue can be heated up by new glue and become soft again. The finished product should look like Figure 5.

### Wiring the holder

You are now ready to wire from the “+” and “-“ terminals of the board shown in Figure 4 to the battery holder. Cut two pieces of wire longer than what you think that you need. Strip back the wire about ¼” and tin the exposed portion. Place each wire in the “+” and “-“ terminals placing them in from the bottom side of the board so that you can only see a small portion of the tinned wire on the top side of the board. Now flip the board so that the top is facing up and solder the wire in place on the board.

If you have positioned the battery holder as shown in Figure 5 then each wire will connect to the side of the battery terminal closest to it. Now measure how much wire you need from end to the other , giving yourself about an extra ¼”. Now cut the wire at that point, strip back ¼”, and tin the exposed wire. Place the tinned portion of the wire against the leg of the battery holder. You should be able to briefly touch this pair with the solder iron to cause them to melt together. We do this step this way for speed so that the glue won’t get to hot and go soft.

If you look at the top of the board now, it should look like Figure 6 shown below.

### Finishing up

Now place a battery in the CR2032 battery holder so that the “+” side is facing toward the arm. Place the board back in your NES cartridge shell as it was when you removed it. Put the two halves of the shell together and use the security bit to put the screws back in again. This time turn clockwise and remember to do it slowly or you will strip the threads on the cartridge. If this does happen or if you lose one of the screws then buy enough #2-56 x ¼” screws at your local hardware store for your needs and screw those in their place. These are large enough that they will create their own threads on the cartridge.

### Pros and cons

The main advantage to this method is that there is no internal pressure in the cartridge. Nothing on the board sticks out enough for you to have to force the two sides of the NES shell together.

The one con that I have heard is that the long-term strength of the glue is untested. While this is true, this method ensures that even if the glue does get soft and the battery holder does fall, nothing bad will happen. Basically, the battery holder will move down a millimeter or two and touch the NES shell which will then stop it from moving. The shell is made of an insulator and will not conduct electricity. At the same time, the wires are semi-rigid and will keep the battery from sliding around so there will be no damage.

## Method 2

This is not my preferred method but it is tried and true and developed by a professional NES reproduction cart maker. After you have done steps 4.1 and 4.2, do the following:

### Adding the battery holder

Turn the board so that the bottom is facing toward you. Place the battery holder on top of the board so that the legs are just hanging off of the longer edge opposite the copper terminals. Place it as near as possible on this edge to the position that the battery originally resided in. Turn the battery holder so that the side where the arm that holds the battery down is nearer the “+” terminal on the board as shown in Figure 4.

Now take your hot glue gun and glue it in place. You should only have to keep the battery holder from moving around while you wait for the glue to set. The finished product should look like Figure 7 shown below.

### Wiring the battery holder

You are now ready to wire from the “+” and “-“ terminals of the board shown in Figure 4 to the battery holder. Cut two pieces of wire longer than what you think that you need. Strip back the wire about ¼” and tin the exposed portion. Place each wire in the “+” and “-“ terminals placing them in from the top side of the board so that you can only see a small portion of the tinned wire on the bottom side of the board. Now flip the board so that the facing is facing up and solder the wire in place on the board.

If you have positioned the battery holder as shown in Figure 8 then each wire will connect to the side of the battery terminal closest to it. Now measure how much wire you need from end to the other , giving yourself about an extra ¼”. Now cut the wire at that point, strip back ¼”, and tin the exposed wire. Place the tinned portion of the wire against the leg of the battery holder. You should be able to briefly touch this pair with the solder iron to cause them to melt together. We do this step this way for speed so that the glue won’t get to hot and go soft.

If you look at the top of the board now, it should look like Figure 9 shown below.

### Finishing up

Now place a battery in the CR2032 battery holder so that the “+” side is facing toward the arm. Your battery holder has now made the NES board taller so you will have to modify your cart now. As you can see in Figure 10, there are two ridges on the inside of the cart shell. One of these is right above where the battery will reside and will hit against the battery. Take your dremel and grind down this ridge. You can see the after picture in Figure 11.

Now you will want to put the two halves of your NES shell together. Note that even with the ridge ground down, the cart will hit against the battery and you may have trouble putting the two halves together. Do not be surprised if you see something like Figure 12 if you are not applying any pressure to the two halves to keep them together.

Take your NES security bit with one hand and force the two halves of the shell together with your others and screw in the security screws. Turn clockwise and turn slowly to prevent stripping the threads in the NES cartridge shell. Remember to use #2-56 x ¼” screws if stripping does occur. It is normal for the shell to make a creaking noise whenever you touch it due to the forces on the inside trying to push the two halves apart.

### Pros and cons

I no longer use this method because I am concerned about the long-term effect that it will have on the shell and board mechanically. Because the shell is plastic, it bows slightly since the battery holder is constantly pressing against it. I fear that cracks will form and eventually the shell might break. It definitely has a bad effect on the threads in the NES carts. Their tendency to strip becomes much higher since the shell is constantly fighting against the screws to snap open and it is difficult to remove the screws slowly enough for this not to become a problem.

The main pro is that this method definitely has far greater mechanical strength with respect to the battery holder. The battery holder is certain to remain in place rigidly on the board with this method.

## Acknowledgements

Thanks to Nesreproductions.com for developing Method 2 which inspired me to create Method 1.

# BNROM

Source: https://www.nesdev.org/wiki/BxROM

Redirect to:
- INES Mapper 034

# CHR ROM vs. CHR RAM

Source: https://www.nesdev.org/wiki/CHR-ROM_vs_CHR-RAM

An NES cartridge has at least two memory chips on it: PRG (connected to the CPU) and CHR(connected to the PPU). There is always at least one PRG ROM, and there may be an additional PRG RAM to hold data. Some cartridges have a CHR ROM, which holds a fixed set of graphics tile data available to the PPU from the moment it turns on. Other cartridges have a CHR RAM that holds data that the CPU has copied from PRG ROM through a port on the PPU. ( A fewhave both CHR ROM and CHR RAM.)

The PPU can see only 8 KiB of tile data at once. So once your game has more than that much tile data, you'll need to use a mapperto load more data into the PPU. Some mappers bankswitch the CHR ROM so that the PPU can see different "pages". Other mappers are designed for CHR RAM; they let the CPU switch to a PRG ROM bank containing CHR data and copy it to CHR RAM.

## CHR ROM

### Advantages
- Takes less time and code for a beginner to get at least something displayed. The "hello world" program for a CHR ROM mapper is about 16 lines shorter.
- Switching tiles is fast, needs no vblank time, and can be done mid-frame or even mid-scanline.
- Can be used together with MMC3and PRG RAM on a donor cartridge. Only six gameshave a board with MMC3 + PRG RAM + CHR RAM, and all are Japan-exclusive. Only three NES games use TGROM(MMC3 + CHR RAM) and two NES games use TQROM(MMC3 + CHR RAM + CHR ROM) even without PRG RAM. However, this should become less of a consideration as MMC3-compatible cartridges with all new parts hit the market.

### Applications
Big static screens Smash TV's title screen alone uses more than 8 KB of tile data. Dedicated bank for status bar A horizontal status bar might use a separate set of tiles from the playfield. This needs either a mapper with a raster interrupt or a sprite 0 overlap trigger. (e.g. Super Mario Bros. 3) Artifact blanking A game that scrolls in all four directions will often have artifacts on one side of the screen because the NES doesn't have enough VRAM to keep the "seam" where new map data is loaded clean. To hide this, a game such as Jurassic Park might display tiles from a blank pattern table for the first or last 8 to 16 scanlines. [1]Pseudo texture mapping In some pseudo-3D games, each row of the floor texture can be stored in a separate bank. Both CHR ROM and CHR RAM let the program switch the background between CHR banks in $0000 and $1000 using PPUCTRL, [2]but CHR ROM allows far more than two banks to be used, as seen in a forward-scrolling shooter called Cosmic Epsilon. Workaround for PRG/CHR divide A drawback of using CHR ROM is that the split between PRG ROM and CHR ROM fragments your data, but it can be worked around. If your PRG ROM is slightly bigger than a power of two, but you have a bit of spare CHR ROM left, you can stash the data in CHR ROM and read it out through PPUADDR/ PPUDATA. For instance, Super Mario Bros. keeps its title screen map data at the end of CHR ROM and copies it into RAM to draw it. However, you can't read this data while rendering is turned on, and due to the DMA glitch, reading PPUDATAwhile playing sampled sound is unreliable.

## CHR RAM

### Advantages
- Can switch tiles in small increments, and the granularity of switching does not depend on the mapper's complexity.
- Tile data can be compressed in ROM.
- Tile data can be otherwise generated in real time.
- Only one chip to rewire and put on the board when replicating your work on cartridge.
- All data is stored in one address space, as opposed to a small amount being inaccessible when rendering is on and unreliable when DPCM is on.

### Applications
Compositing Sometimes you need to draw piles of things that aren't aligned to an 8x8 pixel grid, and there are more of them than will fit into the limit of 8 sprites per scanline. Hatris , Shanghai II , Blockout , and its clone 3D Block have a large playfield containing large stacks of such objects. Cocoron creates the player character's animation frames by piecing together several customizable body parts. Text flexibility A font is a set of glyphs, or pictures that represent the characters of a script. Compositing these glyphs with CHR RAM allows drawing text in a proportional font (also called a variable-width font, or VWF). Not a lot of NES games used a VWF, but something like Word Munchers or Fraction Munchers might benefit. The Super NES version of Mario Is Missing uses a VWF, as do a lot of Super NES RPGs, the Action 53menu, and text boxes in RHDEand Nova the Squirrel. It's also the most practical way to display characters in connected scripts such as Arabic or heavily accented scripts such as Vietnamese. Compression Compressionrefers to transforming a block of data to reduce its size in bits, so that another transformation on the compressed data can recover the original data. This is fairly common with tile data in games that use CHR RAM. The graphics in Konami games ( Blades of Steel , the US version of Contra , and the Japanese version of Simon's Quest ) and Codemasters games (such as Bee 52 ) are compressed using a run-length encoding scheme: Konami's codec works on bytes, while Codemasters' works on pixels. If your game has a lot of tile data, especially if it's just a shade over the power of two boundary between one ROMsize and the next larger power of 2, consider compression. Drawing A few games allow the user to edit tiles. These include paint programs such as Videomation and Color a Dinosaur , or moddable titles such as the Japan-only shooter maker Dezaemon (whose stock sprites were reused in Recca ). Vector graphics Qix has horizontal lines, vertical lines, and filled areas that aren't aligned to a tile grid. Graphics in Elite are wireframe 3D. Juxtaposition Some CHR ROM games restrict which objects can be seen together because of what bank their CHR data is stored in. CHR RAM has no such problem because any object's tile data can be loaded at any position. This proves useful in a game like Final Fantasy , where any player characters can meet any monsters, or in a game like Dizzy or RHDE or Animal Crossing , where the player can have any of several dozen items in his inventory. The extreme of this is Battletoads , which keeps only one frame of each player's animation loaded. To switch frames of animation, it copies them into CHR RAM. But then it has to turn off rendering at the top of the screen, creating a blank strip in the status bar, in order to fit the copy into blanking time. Whether you are using 8x8 or 8x16 pixel sprites, there is enough space in $1000-$1FFF to hold the current and next cel for all 64 sprites. This effect is used even more intensely in platforms with dual-ported VRAM (TurboGrafx-16, Game Boy Advance) and in platforms which have hardware-assisted memory copying to video ports other than OAM (Genesis, Super NES, Game Boy Color, Game Boy Advance). And it's required if you want to display text in a language whose script has more than 250 or so glyphs, such as the logographic characters in some Chinese games and the Japanese versions of Faxanadu and Bionic Commando . One chip CHR RAM means you don't need to program a separate flash chip to act as the CHR ROM. Battery RAM NES 2.0 supports CHR battery RAM. If not all of the memory is used for tiles, you can store save game data in there, which means you don't have to install CHR ROM or PRG RAM on the cartridge. (However not many mappers officially support this; as far as I know not many emulators do either.)

## Effects possible with both types

Tile animation. Think of the animated ? blocks, coins, and conveyor belts in Super Mario Bros. 3 or the animated grass and quicksand in Super Mario Bros. 2, spinning fans or cogs in some games, or the independent parallax scrolling of distant repeating tile patterns in Batman: Return of the Joker, Crisis Force, and Metal Storm.

With CHR ROM, you'd make a separate bank for each frame of animation that you want to display, or for each offset between the distant pattern's scroll position and the foreground pattern's scroll position. It works best on a mapper with CHR banks smaller than 4 KB, such as MMC3.

With CHR RAM, you'd copy the tiles into VRAM as needed. Assuming moderately unrolled VRAM loading code, the NTSC vblank is long enough to copy about 160 bytes per frame plus the OAMdisplay list without turning rendering on late. This is enough for 10 tiles alone, or 8 tiles plus a nametable row, nametable column, or entire palette.

In cases where player 1 and player 2 can select a character, and each character has his own frames of animation, the game needs to use either CHR RAM or a CHR ROM mapper with 1 KiB sprite banks so that both player 1's animation and player 2's animation can be loaded at once. According to an article in Nintendo Power , character selection in Pro Wrestling was the driving force behind the invention of UNROM.

Technically, juxtaposition isn't impossible with CHR ROM mappers, but almost no mappers support assigning a separate tile bank for each space in a nametable. MMC5has an "ExGrafix" mode that allows this, regardless of page boundaries within the CHR ROM, as long as the game doesn't scroll vertically or uses the effect only in the playfield or only in the status bar. ( MMC4also supports automatically switching CHR ROM banks, although in a much more limited way than MMC5.) Thus only MMC5 can properly handle Chinese characters without needing each message to be rendered to a separate page.

## Switching to CHR RAM

It's straightforward to change an existing project using NROMto use CHR RAM.
- Start with an NROM-256 project, and make sure at least 8300 bytes are free in the PRG ROM. We want to make sure CHR RAM works before dealing with mapper bankswitch.
- Remove the CHR ROM data from your build process, whether it be `.incbin "mytiles.chr" `after the IRQ vector or `copy /b game.prg+mytiles.chr game.nes `after assembly and linking.
- In your program's iNESheader, set the number of CHR banks to 0 (which signifies CHR RAM). (If you are using a NES 2.0header, also set the CHR RAM size byte to $07, which denotes 64 × 2 7 bytes.)
- In your program's init code, after the PPU has stabilized but before you turn on rendering, `jsr copy_mytiles_chr `which is listed below (or you can inline the code).
- Rebuild your project. The size should end up as 32,784 bytes (16 bytes of header and 32,768 bytes of PRG ROM).

```text
; for ca65
PPUMASK = $2001
PPUADDR = $2006
PPUDATA = $2007

.segment "CODE"
.proc copy_mytiles_chr
src = 0
  lda #<mytiles_chr  ; load the source address into a pointer in zero page
  sta src
  lda #>mytiles_chr
  sta src+1

  ldy #0       ; starting index into the first page
  sty PPUMASK  ; turn off rendering just in case
  sty PPUADDR  ; load the destination address into the PPU
  sty PPUADDR
  ldx #32      ; number of 256-byte pages to copy
loop:
  lda (src),y  ; copy one byte
  sta PPUDATA
  iny
  bne loop  ; repeat until we finish the page
  inc src+1  ; go to the next page
  dex
  bne loop  ; repeat until we've copied enough pages
  rts
.endproc

.segment "RODATA"
mytiles_chr: .incbin "mytiles.chr"

```

The original NROM-256 board is designed to take a mask ROM or a JEDEC-pinout EPROMin the CHR ROM position, not a 6264 SRAM. Because the board needs to be rewired slightly for CHR RAM, a few emulators do not emulate iNES Mapper 000(NROM) with CHR RAM. For these, you'll need to use iNES Mapper 034(BNROM), which has CHR RAM and 32 KiB bank switching.

The next step after this is to switch to a mapper that allows switching PRG banks. See Programming UNROMand Programming MMC1.

## Notes
- Based on forum posts: 42576and 61957

# CIC lockout chip

Source: https://www.nesdev.org/wiki/CIC

The frontloading NES has a CIC Lockout Chip , a microcontroller that performs a proprietary handshake, as an anticompetitive measure. The Famicomand toploading NES consoles do not contain this chip. The abbreviation CIC is short for "Checking Integrated Circuit" according to Nintendo's patents.

## Overview

Both the lockout chip inside the NES and the one on the cartridge are the same IC. The one inside the NES acts as a lock and the one in the cartridge a key. The difference is how they are hooked up. The system is wired so that the output of one CIC is connected to the input of other and vice versa. LOCK/KEY is pulled to +5V inside the NES and grounded on the Cart. Both share the same 4MHZ clock on pin 6. The RESET pin on the key is connected to SLAVE CIC RESET on the lock. The lock's RESET pin is connected to the system reset bus. This can be demonstrated by inserting a game with the system already on. The NES will not work until you press the reset button which will reset the lock CIC, which in turn resets the key. /CPU & PPU RESET is not connected on the key, on the lock it is connected to the CPU and PPU reset pins. Pins 11-15 are grounded on both CIC's in an NES; these are actually used in multi-game systems so that multiple CICs may be addressed within one system. Finally VCC goes to +5V.

Once the system comes out of power-on or reset, the Lock sends the appropriate reset and initialization signals to the key. The key must then return the correct response, otherwise the lock will pull the /CPU & PPU RESET line low with a 1Hz square wave. Since both share the same clock and the lock is able to reset the key, both CIC's stay in sync with each other.

## Regions

One purpose of the CIC was to restrict the usage of NES consoles and games to the regions they were distributed in, in order to combat out-of-region imports. This was especially important for the PAL and Asian regions since third-parties such as Mattel, ASD, and Bandai were responsible for distributing the NES in those regions before Nintendo subsidiaries were created.

The table below summaries the CIC regions used in 72-pin cartridges. (The Famicom Network Systemcontains CICs but does not use 72-pin connectors)

| CIC Code | CIC Region |
| 3193 | NTSC |
| 6113 | NTSC |
| 3197 | PAL-A |
| 3195 | PAL-B |
| 3196 | Asia |
| 3198 | FamicomBox |

### Determining cartridge CIC regions

It may be useful to identify the CIC region of a game without physical access to a frontloader NES, screwdriver, or the cartridge itself. To determine the CIC region of a licensed NES game:
- Inspect the cartridge's front label. If it contains an ID code (e.g. NES-SM-USA for the USA release of Super Mario Bros. ) or only a region code, then look up the region code in the table below.
  - Some PAL games may specify PAL-A/B on the front label.
  - FamicomBox cartridges have yellow labels with no ID code, and are upside-down compared to standard NES cartridges.
- If the ID code is not present (such as in early first-party releases), check the rear label, box, or manual for possible region codes.
- Otherwise, open the cartridge using the correct screwdriver and inspect the CIC itself.

The table below maps the known region codes to their respective CIC regions.

| Region Code | Meaning | CIC Region |
| USA | United States of America | NTSC |
| CAN | Canada | NTSC |
| AUS | Australia | PAL-A |
| GBR | Great Britain | PAL-A |
| ITA | Italy | PAL-A |
| UKV | United Kingdom | PAL-A |
| EEC | European Economic Community | PAL-B |
| ESP | España (Spain) | PAL-B |
| FRA | France | PAL-B |
| FRG | Federal Republic of Germany | PAL-B |
| GPS | Multiple countries (English box with local-language sticker & manual) | PAL-B |
| HOL | Holland (Netherlands) | PAL-B |
| KOR | Korea (Hyundai Comboy) | PAL-B |
| NOE | Nintendo of Europe | PAL-B |
| SCN | Scandinavia (Denmark, Norway, Sweden, Finland, Iceland) | PAL-B |
| SWE | Sweden | PAL-B |
| ASI | Asia | Asia |
| HKG | Hong Kong | Asia |

Codes which only appear on boxes/manuals (TODO: CIC regions):
- GRE - Greece
- ISR - Israel

Codes which only appear on rear cartridge labels (usually to denote languages):
- ASD - logo for Audio Sound Distribution (distributor of early FRA releases, later merged/replaced by Bandai)
- DAS - Deutsch (German) & Spanish
- EAI - England, Australia (Oceania), Italy
- FAH - French & Hollands (Dutch)

Officially rebranded regional variants (TODO: verify console CICs):
- Playtronic (Brazil) - NTSC?
- Samurai (India) - Asia?

## Disabling

Disabling the CIC is a popular after-market modification which allows out-of-region games to boot on the frontloader NES, though game compatibility is not guaranteed. This is especially useful on PAL units due to the A/B region split.

### Two-wire method

Using just two wires, the CIC can be held in reset and the console's reset button can directly control the CPU and PPU's /RESET inputs instead. Compared to the pin 4 method, this has the advantage of being reversible while still being fairly simple to do. It is done by connecting the lock CIC's pin 7 (CIC RESET in) to the 74HCU04 inverter's pin 1 (oscillator), and the 74HCU04 inverter's pin 2 to the lock CIC's pin 9 (CPU and PPU /RESET in).

### Pin 4 method

When communication between the two CICs fails, it is only the lock, not the key, the asserts its reset output. Therefore, configuring the CIC in the console as a key prevents it from resetting. This can be done by disconnecting the console CIC's pin 4 from the board. Optionally, this disconnected pin can be tied to ground, but the CIC has internal pulldowns that make the pin read as 0 even if left floating.

## Defeating

Boards made by Camerica, Color Dreams, AVE, and AGCI, as well as older Famicom to NES adapters, contain a charge pump to create waveforms involving -5V, which freezes the CIC. Later runs of frontloading NES consoles have diodes to protect against out-of-spec voltages on the CIC data pins, but not on the reset pins.

In late 2006, Tengen's "Rabbit" chip was completely reverse-engineered and a PIC-based clonewas successfully made.

## Pinout
- CIC lockout chip pinout

## Reference
- The CIC is explained in US patents 4,799,635 and 5,070,479.
- A clone CIC is patented in US patent 5,004,232 which doesn't look like it should actually work unless it inadvertently stuns the CIC. A chip based on this patent was used by AVE.
- https://www.thelegendofnes.com/ntsc-pal
- https://www.thelegendofnes.com/id-codes

# CIC lockout chip

Source: https://www.nesdev.org/wiki/CIC_lockout_chip

The frontloading NES has a CIC Lockout Chip , a microcontroller that performs a proprietary handshake, as an anticompetitive measure. The Famicomand toploading NES consoles do not contain this chip. The abbreviation CIC is short for "Checking Integrated Circuit" according to Nintendo's patents.

## Overview

Both the lockout chip inside the NES and the one on the cartridge are the same IC. The one inside the NES acts as a lock and the one in the cartridge a key. The difference is how they are hooked up. The system is wired so that the output of one CIC is connected to the input of other and vice versa. LOCK/KEY is pulled to +5V inside the NES and grounded on the Cart. Both share the same 4MHZ clock on pin 6. The RESET pin on the key is connected to SLAVE CIC RESET on the lock. The lock's RESET pin is connected to the system reset bus. This can be demonstrated by inserting a game with the system already on. The NES will not work until you press the reset button which will reset the lock CIC, which in turn resets the key. /CPU & PPU RESET is not connected on the key, on the lock it is connected to the CPU and PPU reset pins. Pins 11-15 are grounded on both CIC's in an NES; these are actually used in multi-game systems so that multiple CICs may be addressed within one system. Finally VCC goes to +5V.

Once the system comes out of power-on or reset, the Lock sends the appropriate reset and initialization signals to the key. The key must then return the correct response, otherwise the lock will pull the /CPU & PPU RESET line low with a 1Hz square wave. Since both share the same clock and the lock is able to reset the key, both CIC's stay in sync with each other.

## Regions

One purpose of the CIC was to restrict the usage of NES consoles and games to the regions they were distributed in, in order to combat out-of-region imports. This was especially important for the PAL and Asian regions since third-parties such as Mattel, ASD, and Bandai were responsible for distributing the NES in those regions before Nintendo subsidiaries were created.

The table below summaries the CIC regions used in 72-pin cartridges. (The Famicom Network Systemcontains CICs but does not use 72-pin connectors)

| CIC Code | CIC Region |
| 3193 | NTSC |
| 6113 | NTSC |
| 3197 | PAL-A |
| 3195 | PAL-B |
| 3196 | Asia |
| 3198 | FamicomBox |

### Determining cartridge CIC regions

It may be useful to identify the CIC region of a game without physical access to a frontloader NES, screwdriver, or the cartridge itself. To determine the CIC region of a licensed NES game:
- Inspect the cartridge's front label. If it contains an ID code (e.g. NES-SM-USA for the USA release of Super Mario Bros. ) or only a region code, then look up the region code in the table below.
  - Some PAL games may specify PAL-A/B on the front label.
  - FamicomBox cartridges have yellow labels with no ID code, and are upside-down compared to standard NES cartridges.
- If the ID code is not present (such as in early first-party releases), check the rear label, box, or manual for possible region codes.
- Otherwise, open the cartridge using the correct screwdriver and inspect the CIC itself.

The table below maps the known region codes to their respective CIC regions.

| Region Code | Meaning | CIC Region |
| USA | United States of America | NTSC |
| CAN | Canada | NTSC |
| AUS | Australia | PAL-A |
| GBR | Great Britain | PAL-A |
| ITA | Italy | PAL-A |
| UKV | United Kingdom | PAL-A |
| EEC | European Economic Community | PAL-B |
| ESP | España (Spain) | PAL-B |
| FRA | France | PAL-B |
| FRG | Federal Republic of Germany | PAL-B |
| GPS | Multiple countries (English box with local-language sticker & manual) | PAL-B |
| HOL | Holland (Netherlands) | PAL-B |
| KOR | Korea (Hyundai Comboy) | PAL-B |
| NOE | Nintendo of Europe | PAL-B |
| SCN | Scandinavia (Denmark, Norway, Sweden, Finland, Iceland) | PAL-B |
| SWE | Sweden | PAL-B |
| ASI | Asia | Asia |
| HKG | Hong Kong | Asia |

Codes which only appear on boxes/manuals (TODO: CIC regions):
- GRE - Greece
- ISR - Israel

Codes which only appear on rear cartridge labels (usually to denote languages):
- ASD - logo for Audio Sound Distribution (distributor of early FRA releases, later merged/replaced by Bandai)
- DAS - Deutsch (German) & Spanish
- EAI - England, Australia (Oceania), Italy
- FAH - French & Hollands (Dutch)

Officially rebranded regional variants (TODO: verify console CICs):
- Playtronic (Brazil) - NTSC?
- Samurai (India) - Asia?

## Disabling

Disabling the CIC is a popular after-market modification which allows out-of-region games to boot on the frontloader NES, though game compatibility is not guaranteed. This is especially useful on PAL units due to the A/B region split.

### Two-wire method

Using just two wires, the CIC can be held in reset and the console's reset button can directly control the CPU and PPU's /RESET inputs instead. Compared to the pin 4 method, this has the advantage of being reversible while still being fairly simple to do. It is done by connecting the lock CIC's pin 7 (CIC RESET in) to the 74HCU04 inverter's pin 1 (oscillator), and the 74HCU04 inverter's pin 2 to the lock CIC's pin 9 (CPU and PPU /RESET in).

### Pin 4 method

When communication between the two CICs fails, it is only the lock, not the key, the asserts its reset output. Therefore, configuring the CIC in the console as a key prevents it from resetting. This can be done by disconnecting the console CIC's pin 4 from the board. Optionally, this disconnected pin can be tied to ground, but the CIC has internal pulldowns that make the pin read as 0 even if left floating.

## Defeating

Boards made by Camerica, Color Dreams, AVE, and AGCI, as well as older Famicom to NES adapters, contain a charge pump to create waveforms involving -5V, which freezes the CIC. Later runs of frontloading NES consoles have diodes to protect against out-of-spec voltages on the CIC data pins, but not on the reset pins.

In late 2006, Tengen's "Rabbit" chip was completely reverse-engineered and a PIC-based clonewas successfully made.

## Pinout
- CIC lockout chip pinout

## Reference
- The CIC is explained in US patents 4,799,635 and 5,070,479.
- A clone CIC is patented in US patent 5,004,232 which doesn't look like it should actually work unless it inadvertently stuns the CIC. A chip based on this patent was used by AVE.
- https://www.thelegendofnes.com/ntsc-pal
- https://www.thelegendofnes.com/id-codes

# CPU memory map

Source: https://www.nesdev.org/wiki/CPU_memory_map

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

# CPU power up state

Source: https://www.nesdev.org/wiki/CPU_power_up_state

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

# Coconuts Japan Pachinko Controller

Source: https://www.nesdev.org/wiki/Coconuts_Japan_Pachinko_Controller

The Coconuts Japan Pachinko Controller(CJPC-102) is a Famicom expansion port controller designed by Hori Electric Co. that combines a standard controller with a large analog dial with a range of about 90 degrees. The dial uses a spring to return it to its rest position. This controller was used in the following games:
- Pachinko Daisakusen
- Pachinko Daisakusen 2
- Pachio Kun 4
- Pachio Kun 5

## Layout

```text
    |
,--------.   \-,-------.
|        |    |         |
|       |    |           |
|       |   /|           |
|   +   |  /_|   B   A   /
|        |    |         /
|         `--'         /
|                     /
|  Se St             /
`-------------------'

```

The Pachinko Controller is a thick controller with a front surface that slopes downward. Its button layout matches that of the standard controller, but with the select and start buttons positioned for use with the left hand rather than a more-ambidextrous central location. A large gap runs down most of the center of the controller, and the right half is rounded. On the right half, sandwiched between the front and back plastic shells of the controller is a dial with a slightly larger radius than the controller. On the left of the dial are two angled ridges. The controller is intended to be stabilized or held with the left hand and the dial manipulated with the right hand, using a palm grip that places the right hand's thumb below the larger ridge, index finger to the left of the smaller ridge, and other fingers placed on the dial, allowing clockwise rotation against the spring and counterclockwise rotation with the spring. The dial can also be used with the right index finger when holding the controller as a standard controller, but not as effectively.

## Interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Strobe controller shift register

```

This matches the normal strobe behavior used by the standard controller.

### Output ($4016 read)

```text
7  bit  0
---- ----
xxxx xxEx
       |
       +-- Controller status bit

```

The controller status is returned in a 16-bit serial report:

```text
 Bits
 0-7  - Standard controller
 8    - (Always 1)
 9-15 - 7-bit analog value, inverted (high bits first)

 16+  - (Always 1)

```

Note that the analog value is provided to the CPU inverted. This article will discuss the raw, non-inverted values.

Unlike the Arkanoid controller, which starts an analog-to-digital conversion in response to a strobe, the Pachinko Controller converts constantly. The controller has a 7-bit counter that is always counting up at a rate of approximately 20 kHz. A voltage based on all 7 bits of the counter is compared against a voltage based on the dial's potentiometer. When the counter voltage exceeds the potentiometer voltage, the 7 counter bits are simultaneously latched. When the controller is strobed, it is this latched conversion that is latched for the report, so the controller always provides a single complete conversion in its report.

The counter wraps every 128 counts, which takes about 6.4 ms, so conversions will latch at this rate on average. However, conversions will occur faster or slower than this as the dial is turned because the conversion occurs when exceeding the potentiometer voltage, which varies. In fact, if the potentiometer voltage increases faster than the counter voltage, multiple conversions could occur on a single pass, but this may be infeasible in practice because of the limits of human movement speed and capacitors that restrict how quickly the voltages can change.

At power-on, if the dial is in its rest position, the latched value is usually 0, but a conversion may occur immediately, typically producing a value of $01 or $02. Once the dial has been used, its minimum value is $03 and its maximum value is approximately $72-74, depending on mechanical factors. The maximum value is restricted by the plastic components and thus may vary by controller and by elastic deformation of the plastic. On the other hand, the minimum value is restricted by the conversion circuit, and there is a small deadzone around the rest position of the dial where turning does not change the value.

When the potentiometer voltage is sufficiently low, the counter voltage always exceeds it, preventing the conversion latches from taking a new value. Thus, if it is below the voltage that would produce the minimum value of $03, no conversions occur and the stale value continues to be latched. If the dial is returned to rest quickly enough, this means that larger values than the minimum can be latched until the dial is turned far enough to trigger conversions again. For this reason, it is common in normal use for the at-rest value to be $04 rather than the actual minimum of $03, and values as large as $06 have been observed by allowing the spring to freely return the dial to rest from the maximum position. Software should extend the deadzone to accommodate this quirk.

Contemporary software expects a range of $00-63, clamping values above $63. If bit 8 of the report does not match the expected 1, these games ignore the analog value. Note that the controller cannot report values less than $03 under normal operation, so ball launching cannot be completely stopped.

## Hardware

The controller contains two PCBs, with these chips:
- Two 4021 shift registers
- A 4024 7 bit ripple counter
- A 74HC574 8-bit D register
- A µPC393 dual comparator

One half of the µPC393 is used to form the 20kHz clock, nominally 75kΩ·470pF·2·ln(2). This clock feeds the 4024. The 4024's RESET input is always disabled. The output of the 4024 goes into a binary-weighted DAC, forming a sawtooth wave. The dial angle sets a voltage using a potentiometer. The other half of the µPC393 is used to detect when the sawtooth wave exceeds the voltage from the potentiometer. This latches the current count from the 4024 in the 74HC574. The shift registers are daisy-chained to form a single 16-bit report, like in the early SNES controllers or Virtual Boy controller.

## Images

### PCBs

## See Also
- Video demonstrating how the dial maps to gameplay

# Consistent frame synchronization

Source: https://www.nesdev.org/wiki/Consistent_frame_synchronization

## Introduction

This page describes a method for consistently synchronizing with the PPUevery frame from inside an NMIhandler, without having to cycle-time everything. This method allows synchronization just as good as is possible with completely cycle-timed code. At the beginning, the PPU is precisely synchronized with, ensuring that the code behaves the same every time it's run, every time the NES is powered up or reset. It's fully predictable.

Currently only PALversion is covered, since the PAL PPU's frame timing is simpler. The NTSC version operates in a similar manner, and will be covered eventually.

## PAL timing
See also: Cycle reference chart

The PAL NES has a master clock shared by the PPU and CPU. The CPU divides the master clock by 16 to get its instruction cycle clock, which we'll call cycle for simplicity. For example, a NOP instruction takes 2 cycles. The PPU divides the master clock by 5 to get its pixel clock, which we'll call pixel for simplicity. There are 16/5 = 3.2 pixels per cycle.

A video frame consists of 312 scanlines, each 341 pixels long. Unlike NTSC, there are no short frames, and rendering being enabled or disabled has no effect on frame length. Thus, every frame is exactly 312*341 = 106396 pixels = 33247.5 cycles long. We'll have pixel 0 refer to the first pixel of a frame, and pixel 106395 refer to the last pixel of a frame.

A frame begins with the vertical blanking interval (VBL), then the visible scanlines. The notation VBL+N refers to N cycles after the cycle that VBL began within, VBL+0. To talk about pixels since VBL, we simply refer to pixel P, where pixel 0 is the beginning of VBL, and pixel 106395 is the last pixel in the frame.

## Basic synchronization

If we're going to write at a particular pixel, we must first synchronize the CPU to the beginning of a frame, so that pixel 0 begins at the beginning of a cycle, and we know how many cycles ago that was. Reading $2002gives the current status of the VBL flag in bit 7, then clears it. The VBL flag is set at pixel 0 of each frame, and cleared around when VBL ends. We can use the VBL flag to achieve synchronization.

A frame is 33247.5 cycles long. If we could somehow read $2002 every 33247.5 cycles, we'd read at the same point in each frame. But if we read $2002 every 33248 cycles, we'll be reading 0.5 cycles (1.6 pixels) later each successive frame. If we have a loop do this until it finds the VBL flag set, it will synchronize with the PPU. Each time through, it will read later in the frame, until it reads just as the VBL flag for the next frame is set.

```text
        ; Fine synchronize
:       delay 33241
        bit $2002
        bpl :-

```

| Cycle | PPU | CPU |
| 0 |  |  |
| 1 |  |  |
| ... |
| 33246 |  | Read $2002 = 0 |
| 33246.5 |  |  |
| 33247 |  |  |
| 33247.5 | Set VBL flag |  |
| ... |
| 66494 |  | Read $2002 = 0 |
| 66494.5 |  |  |
| 66495 | Set VBL flag |  |
| ... |
| 99742 |  | Read $2002 = 0 |
| 99742.5 | Set VBL flag |  |
| ... |
| 132990 | Set VBL flag | Read $2002 = $80 |

Looking at it relative to each frame, we more clearly see how the CPU effectively reads later by half a cycle each frame.

| Cycle | Frame 1 | Frame 2 | Frame 3 | Frame 4 | Event |
| -1.5 | read |  |  |  |  |
| -1.0 |  | read |  |  |  |
| -0.5 |  |  | read |  |  |
| 0 |  |  |  | read | VBL flag set |

The loop must be started so that the first $2002 read is slightly before the end of the frame, otherwise it might start out reading well after the flag has been set. We can do this by starting with a simpler coarse synchronization loop.

```text
sync_ppu:
        ; Coarse synchronize
        bit $2002
:       bit $2002
        bpl :-

        delay 33231
        jmp first

        ; Fine synchronize
:       delay 33241
first:  bit $2002
        bpl :-

        rts

```

The coarse synchronization loop might read $2002 just as the VBL flag was set, or read it nearly 7 cycles after it was set. Then, in the fine synchronization loop, $2002 is read 33240 to 33247 cycles later. In most cases, this will be slightly before the VBL flag is set, so the loop will delay and read $2002 again 33248 cycles later, etc.

Once done, the CPU will have executed two cycles after the final $2002 read that found the VBL flag just set.

## Writing to a particular pixel

In order to achieve some graphical effect, we want to write to the PPU at a particular pixel every frame. As an example, we'll write to $2006 at pixel 30400, which is near the upper-center of the screen. To simplify things, we'll not care what value we write. This requires that we write to $2006 at VBL+9500.

```text
        ; Synchronize to PPU
        jsr sync_ppu

        ; Delay almost a full frame, so that the code below begins on
        ; a frame.
        delay 33238

vbl:    ; VBL begins in this cycle

        delay 9497
        sta $2006

```

| Pixel | Cycle | Event |

| 0 | 0 | VBL begins delay 9497 |
| ... |
|  | 9497 | STA $2006 |
|  | 9498 |  |
|  | 9499 |  |
| 30400 | 9500 | $2006 write |

If we try to make this write to the same pixel each frame, we run into a problem: the frame length isn't a whole number of cycles. We'll count frames and treat odd frames as being 33247 cycles long, and even frames 33248 cycles long, which will average to the correct 33247.5 cycles per frame.

```text
        ; Synchronize to PPU
        jsr sync_ppu

        ; Delay almost a full frame, so that the code below begins on
        ; a frame.
        delay 33233

        ; We were on frame 1 after sync_ppu, but vbl will begin on frame 2
        lda #2
        sta frame_count

vbl:    ; VBL begins in this cycle

        delay 9497
        sta $2006

        delay 23731

        ; Delay extra cycle on even frames
        lda frame_count
        and #$01
        beq extra
extra:  inc frame_count

        jmp vbl

```

Now our write time doesn't drift, but it still doesn't write to the same pixel each frame. Since even frames begin in the middle of a cycle, our write is half a cycle/1.6 pixels earlier.

| Odd frame pixel | Even frame pixel | Cycle | Event |

| 0 |  | 0 | VBL begins delay 9497 |
|  | 0 | 0.5 |
| ... |
|  |  | 9497 | STA $2006 |
|  |  | 9498 |  |
|  |  | 9499 |  |
| 30400 | 30398.4 | 9500 | $2006 write |

Our write will thus fall on pixel 30400 on odd frames, and pixel 30398.4 on even frames. That's the best we can do, regardless of how we write our code, as this is a hardware limitation.

Another similar limitation is that when the NES is powered up or reset, the CPU and PPU master clock dividers start in random states, adding up to 1.6 additional pixels of variance. This offset doesn't change until the NES is powered off or reset.

## Ideal NMI

Above, all the code had to be cycle-timed to ensure that each write occurred at the correct time. This isn't practical in most programs, which instead use NMI for synchronizing roughly to VBL. In these programs, timing-critical code is at the beginning of the NMI handler, followed by code that isn't carefully timed. Thus, such code relies on NMI occurring shortly after VBL, and not being delayed.

Ideally, NMI would begin a fixed number of cycles after VBL, without waiting for the current instruction to finish. If that were the case, we'd have it nearly as easy as before. Here, we'll imagine NMI always occurs at VBL+2. NMI takes 7 cycles to vector to our NMI handler, so that our NMI handler begins at VBL+9. To simplify the code and timing diagrams, we won't bother saving any registers as we'd normally do in an NMI handler.

```text
nmi:    ; VBL+9
        delay 9488
        sta $2006         ; write at VBL+9500

```

| Even frame pixel | Odd frame pixel | Cycle | Event |
| 0 |  | 0 | VBL begins |
|  | 0 | 0.5 |
|  |  | 1 |  |
|  |  | 2 | NMI vectored |
|  |  | 3 |  |
|  |  | 4 |  |
|  |  | 5 |  |
|  |  | 6 |  |
|  |  | 7 |  |
|  |  | 8 |  |
|  |  | 9 | delay 9488 |
| ... |
|  |  | 9497 | STA $2006 |
|  |  | 9498 |  |
|  |  | 9499 |  |
| 30400 | 30398.4 | 9500 | $2006 write |

## NMI delay

In reality, NMI waits until the current instruction completes before vectoring to the NMI handler, adding an extra delay as compared to the ideal NMI described above. Also, sometimes the NES powers up with the PPU and CPU dividers such that the NMI occurs an additional cycle later.

By ensuring that a short instruction is executing when VBL occurs, we can minimize the delay before NMI is vectored. For example, if we have a series of NOP instructions executing when VBL occurs, NMI will occur from 2 to 4 cycles after VBL. The table shows the four possible timings, with each column titled with the time NMI vectoring begins.

```text
        nop
        nop
        nop

```

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | Event |
| -1 |  | NOP |  |  |
| 0 | NOP |  | NOP | VBL begins |
| 1 |  | NOP |  |  |
| 2 | NMI vectored |  | NOP |  |
| 3 |  | NMI vectored |  |  |
| 4 |  |  | NMI vectored |  |

So, at best, we have 2 to 4 cycles of delay between VBL and our NMI handler.

Using a long sequence of NOP instructions isn't practical, because it requires either a large number of NOP instructions, or that we know how long the code before them takes so that we can delay entry into the NOP sequence until NMI is about to occur. If we instead have a simple infinite loop made of a single JMP instruction, we only increase the maximum delay by one cycle, to 5.

```text
 loop:   jmp loop

```

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 | Event |
| -1 | JMP |  |  | JMP |  |
| 0 |  | JMP |  |  | VBL begins |
| 1 |  |  | JMP |  |  |
| 2 | NMI vectored |  |  | JMP |  |
| 3 |  | NMI vectored |  |  |  |
| 4 |  |  | NMI vectored |  |  |
| 5 |  |  |  | NMI vectored |  |

## Compensating for NMI delay

With a JMP loop to wait for NMI, we have 2 to 5 cycles of delay between VBL and our NMI handler. We want to compensate for this delay D by delaying an additional 5-D cycles. Here, we have the NOP always begin at VBL+12. We can't actually do this, but it shows what we must do the equivalent of.

```text
nmi:	delay 5-D
	nop

```

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 | Event |
| -1 | JMP |  |  | JMP |  |
| 0 |  | JMP |  |  | VBL begins |
| 1 |  |  | JMP |  |  |
| 2 | NMI vectored |  |  | JMP |  |
| 3 |  | NMI vectored |  |  |  |
| 4 |  |  | NMI vectored |  |  |
| 5 |  |  |  | NMI vectored |  |
| 6 |  |  |  |  |  |
| 7 |  |  |  |  |  |
| 8 |  |  |  |  |  |
| 9 | delay 3 |  |  |  |  |
| 10 |  | delay 2 |  |  |  |
| 11 |  |  | delay 1 |  |  |
| 12 | NOP | NOP | NOP | NOP (no delay) |  |

We just have to find out how to determine the number of cycles of delay to add.

## Sprite DMA always ends on even cycle

When sprite DMA ($4014) is written to, the next instruction always begins on an odd cycle. If the $4014 write is on an odd cycle, it pauses the CPU for an additional 513 cycles, otherwise 514 cycles. We can use this aspect to partially compensate for NMI's variable delay.

```text
nmi:    lda #$07          ; sprites at $700
        sta $4014
        nop

```

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 |
| 0 | VBL begins |
| 1 |  |  |  |  |
| 2 | NMI |  |  |  |
| 3 |  | NMI |  |  |
| 4 |  |  | NMI |  |
| 5 |  |  |  | NMI |
| 6 |  |  |  |  |
| 7 |  |  |  |  |
| 8 |  |  |  |  |
| 9 | LDA #$07 |  |  |  |
| 10 |  | LDA #$07 |  |  |
| 11 | STA $4014 |  | LDA #$07 |  |
| 12 |  | STA $4014 |  | LDA #$07 |
| 13 |  |  | STA $4014 |  |
| 14 | $4014 write |  |  | STA $4014 |
| 15 | 514-cycle DMA | $4014 write |  |  |
| 16 |  | 513-cycle DMA | $4014 write |  |
| 17 |  |  | 514-cycle DMA | $4014 write |
| 18 |  |  |  | 513-cycle DMA |
| ... |
| 527 |  |  |  |  |
| 528 | DMA finishes | DMA finishes |  |  |
| 529 | NOP | NOP |  |  |
| 530 |  |  | DMA finishes | DMA finishes |
| 531 |  |  | NOP | NOP |

This reduces the number of different delays from four to two. The NOP always executes at either VBL+529 or VBL+531. This is an improvement. We just need a way to determine which time DMA finished at, and delay two extra cycles if it was the earlier one.

## VBL flag cleared at end of VBL

The VBL flag is cleared near the end of VBL. If we read $2002 around the time the flag is cleared, we can determine whether the read occurred before or after the flag was cleared. We will have to avoid reading $2002 elsewhere in the NMI handler, since reading $2002 clears the flag.

The VBL flag is cleared around pixel 23869, sometimes one less, so we want to read $2002 at VBL+7458 or VBL+7460. It works out nicely that sprite DMA leaves two cycles between the possible ending times, as this ensures that our $2002 read is several pixels before or after when the flag is cleared, giving us a good margin for error. If we find the flag set, we know we are on the earlier of the two DMA ending times, so we delay an extra two cycles.

```text
nmi:    lda #$07          ; sprites at $700
        sta $4014
        delay 6926
        bit $2002         ; read at VBL+7458 or VBL+7460
        bpl skip
        bit 0
skip:   nop

```

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 |
| 0 | VBL begins |
| 1 |  |  |  |  |
| 2 | NMI |  |  |  |
| 3 |  | NMI |  |  |
| 4 |  |  | NMI |  |
| 5 |  |  |  | NMI |
| 6 |  |  |  |  |
| 7 |  |  |  |  |
| 8 |  |  |  |  |
| 9 | LDA #$07 |  |  |  |
| 10 |  | LDA #$07 |  |  |
| 11 | STA $4014 |  | LDA #$07 |  |
| 12 |  | STA $4014 |  | LDA #$07 |
| 13 |  |  | STA $4014 |  |
| 14 | $4014 write |  |  | STA $4014 |
| 15 | 514-cycle DMA | $4014 write |  |  |
| 16 |  | 513-cycle DMA | $4014 write |  |
| 17 |  |  | 514-cycle DMA | $4014 write |
| 18 |  |  |  | 513-cycle DMA |
| ... |
| 527 |  |  |  |  |
| 528 | DMA finishes | DMA finishes |  |  |
| 529 | delay 6926 | delay 6926 |  |  |
| 530 |  |  | DMA finishes | DMA finishes |
| 531 |  |  | delay 6926 | delay 6926 |
| ... |
| 7455 | BIT $2002 | BIT $2002 |  |  |
| 7456 |  |  |  |  |
| 7457 |  |  | BIT $2002 | BIT $2002 |
| 7458 | $2002 read = $80 | $2002 read = $80 |  |  |
| 7459 | BPL not taken | BPL not taken | VBL cleared | VBL cleared |
| 7460 |  |  | $2002 read = 0 | $2002 read = 0 |
| 7461 | BIT 0 | BIT 0 | BPL taken | BPL taken |
| 7462 |  |  |  |  |
| 7463 |  |  |  |  |
| 7464 | NOP | NOP | NOP | NOP |

This achieves our goal, but not in all cases.

## VBL begins on odd cycles

Unfortunately, VBL doesn't always begin during an even cycle, as we've so far assumed. When VBL begins during an odd cycle, our code doesn't work so well:

| Cycle | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 |
| 1 | VBL begins |
| 2 |  |  |  |  |
| 3 | NMI |  |  |  |
| 4 |  | NMI |  |  |
| 5 |  |  | NMI |  |
| 6 |  |  |  | NMI |
| 7 |  |  |  |  |
| 8 |  |  |  |  |
| 9 |  |  |  |  |
| 10 | LDA #$07 |  |  |  |
| 11 |  | LDA #$07 |  |  |
| 12 | STA $4014 |  | LDA #$07 |  |
| 13 |  | STA $4014 |  | LDA #$07 |
| 14 |  |  | STA $4014 |  |
| 15 | $4014 write |  |  | STA $4014 |
| 16 | 513-cycle DMA | $4014 write |  |  |
| 17 |  | 514-cycle DMA | $4014 write |  |
| 18 |  |  | 513-cycle DMA | $4014 write |
| 19 |  |  |  | 514-cycle DMA |
| ... |
| 527 |  |  |  |  |
| 528 | DMA finishes |  |  |  |
| 529 |  |  |  |  |
| 530 |  | DMA finishes | DMA finishes |  |
| 531 |  |  |  |  |
| 532 |  |  |  | DMA finishes |

Now DMA ends at three different times, covering a wider range than the original NMI times did, thus making things worse!

We need to keep track of when VBL begins during an odd cycle, and compensate before we begin DMA. After our PPU synchronization routine finishes, the last $2002 read it makes will have just found the VBL flag set. In the following table, that is cycle 0.

| Pixel | Cycle | Frame |
| 0 | 0 | 1 |
| 106392 | 33247.5 | 2 |
| 212784 | 66495 | 3 |
| 319176 | 99742.5 | 4 |
| 425568 | 132990 | 5 |
| 531960 | 166237.5 | 6 |
| 638352 | 199485 | 7 |
| 744744 | 232732.5 | 8 |

Looking at which cycle each frame begins on, we see they follow a four-frame pattern: even, odd, odd, even. So we'll just have a variable that starts out at 1 and increments every frame, then examine bit 1 and delay an extra cycle if it's clear. This extra code takes 8 cycles on frames where VBL begins during an even cycle, and 7 cycles otherwise.

But we also need to insert a complementary delay after DMA, before the $2002 read, since on frames where VBL begins during an odd cycle we'll need to read $2002 one cycle later after DMA than for even frames.

```text
nmi:    lda frame_count
        and #$02
        beq even
even:   lda #$07          ; sprites at $700
        sta $4014
        delay 6911
        lda frame_count
        and #$02
        bne odd
odd:    bit $2002
        bpl skip
        bit 0
skip:   inc frame_count
        delay 2028
        sta $2006

```

| Cycle | Frames 1, 4, 5, 8 ... | Frames 2, 3, 6, 7 ... |
| VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 | VBL + 2 | VBL + 3 | VBL + 4 | VBL + 5 |
| 0 | VBL | VBL | VBL | VBL |  |  |  |  |
| 1 |  |  |  |  | VBL | VBL | VBL | VBL |
| 2 | NMI |  |  |  |  |  |  |  |
| 3 |  | NMI |  |  | NMI |  |  |  |
| 4 |  |  | NMI |  |  | NMI |  |  |
| 5 |  |  |  | NMI |  |  | NMI |  |
| 6 |  |  |  |  |  |  |  | NMI |
| 7 |  |  |  |  |  |  |  |  |
| 8 |  |  |  |  |  |  |  |  |
| 9 | LDA frame_count |  |  |  |  |  |  |  |
| 10 |  | LDA frame_count |  |  | LDA frame_count |  |  |  |
| 11 |  |  | LDA frame_count |  |  | LDA frame_count |  |  |
| 12 | AND #$02 |  |  | LDA frame_count |  |  | LDA frame_count |  |
| 13 |  | AND #$02 |  |  | AND #$02 |  |  | LDA frame_count |
| 14 | BEQ taken |  | AND #$02 |  |  | AND #$02 |  |  |
| 15 |  | BEQ taken |  | AND #$02 | BEQ not taken |  | AND #$02 |  |
| 16 |  |  | BEQ taken |  |  | BEQ not taken |  | AND #$02 |
| 17 | LDA #$07 |  |  | BEQ taken | LDA #$07 |  | BEQ not taken |  |
| 18 |  | LDA #$07 |  |  |  | LDA #$07 |  | BEQ not taken |
| 19 | STA $4014 |  | LDA #$07 |  | STA $4014 |  | LDA #$07 |  |
| 20 |  | STA $4014 |  | LDA #$07 |  | STA $4014 |  | LDA #$07 |
| 21 |  |  | STA $4014 |  |  |  | STA $4014 |  |
| 22 | $4014 write |  |  | STA $4014 | $4014 write |  |  | STA $4014 |
| 23 | 514-cycle DMA | $4014 write |  |  | 514-cycle DMA | $4014 write |  |  |
| 24 |  | 513-cycle DMA | $4014 write |  |  | 513-cycle DMA | $4014 write |  |
| 25 |  |  | 514-cycle DMA | $4014 write |  |  | 514-cycle DMA | $4014 write |
| 26 |  |  |  | 513-cycle DMA |  |  |  | 513-cycle DMA |
| ... |
| 535 |  |  |  |  |  |  |  |  |
| 536 | DMA finishes | DMA finishes |  |  | DMA finishes | DMA finishes |  |  |
| 537 | delay 6911 | delay 6911 |  |  | delay 6911 | delay 6911 |  |  |
| 538 |  |  | DMA finishes | DMA finishes |  |  | DMA finishes | DMA finishes |
| 539 |  |  | delay 6911 | delay 6911 |  |  | delay 6911 | delay 6911 |
| ... |
| 7448 | LDA frame_count | LDA frame_count |  |  | LDA frame_count | LDA frame_count |  |  |
| 7449 |  |  |  |  |  |  |  |  |
| 7450 |  |  | LDA frame_count | LDA frame_count |  |  | LDA frame_count | LDA frame_count |
| 7451 | AND #$02 | AND #$02 |  |  | AND #$02 | AND #$02 |  |  |
| 7452 |  |  |  |  |  |  |  |  |
| 7453 | BNE not taken | BNE not taken | AND #$02 | AND #$02 | BNE taken | BNE taken | AND #$02 | AND #$02 |
| 7454 |  |  |  |  |  |  |  |  |
| 7455 | BIT $2002 | BIT $2002 | BNE not taken | BNE not taken |  |  | BNE taken | BNE taken |
| 7456 |  |  |  |  | BIT $2002 | BIT $2002 |  |  |
| 7457 |  |  | BIT $2002 | BIT $2002 |  |  |  |  |
| 7458 | $2002 read = $80 | $2002 read = $80 |  |  |  |  | BIT $2002 | BIT $2002 |
| 7459 | BPL not taken | BPL not taken | VBL cleared | VBL cleared | $2002 read = $80 | $2002 read = $80 |  |  |
| 7460 |  |  | $2002 read = 0 | $2002 read = 0 | BPL not taken | BPL not taken | VBL cleared | VBL cleared |
| 7461 | BIT 0 | BIT 0 | BPL taken | BPL taken |  |  | $2002 read = 0 | $2002 read = 0 |
| 7462 |  |  |  |  | BIT 0 | BIT 0 | BPL taken | BPL taken |
| 7463 |  |  |  |  |  |  |  |  |
| 7464 | INC frame_count | INC frame_count | INC frame_count | INC frame_count |  |  |  |  |
| 7465 |  |  |  |  | INC frame_count | INC frame_count | INC frame_count | INC frame_count |
| 7466 |  |  |  |  |  |  |  |  |
| 7467 |  |  |  |  |  |  |  |  |
| 7468 |  |  |  |  |  |  |  |  |
| 7469 | delay 2028 | delay 2028 | delay 2028 | delay 2028 |  |  |  |  |
| 7470 |  |  |  |  | delay 2028 | delay 2028 | delay 2028 | delay 2028 |
| ... |
| 9497 | STA $2006 | STA $2006 | STA $2006 | STA $2006 |  |  |  |  |
| 9498 |  |  |  |  | STA $2006 | STA $2006 | STA $2006 | STA $2006 |
| 9499 |  |  |  |  |  |  |  |  |
| 9500 | $2006 write at VBL+9500 | $2006 write at VBL+9500 | $2006 write at VBL+9500 | $2006 write at VBL+9500 |  |  |  |  |
| 9501 |  |  |  |  | $2006 write at VBL+9500 | $2006 write at VBL+9500 | $2006 write at VBL+9500 | $2006 write at VBL+9500 |

The $2006 write is done at VBL+9500 in all cases. Remember that the right four columns have VBL beginning on cycle 1 (an odd cycle), which is why the final writes appear to be one cycle later than the others.

## Synchronizing with even CPU cycle

Since our final synchronization method relies on knowing whether a given frame begins during an even or odd cycle, we must initially ensure that our PPU synchronization routine's final $2002 read is also during an even cycle. Since the fine synchronization loop takes an even number of cycles, we merely need to ensure that the first time through that the $2002 read is on an even cycle. We can do this by initiating sprite DMA before the fine synchronization loop.

```text
sync_ppu:
        ; Coarse synchronize
        bit $2002
:       bit $2002
        bpl :-

        sta $4014
        delay 32713
        jmp first

        ; Fine synchronize
:       delay 33241
first:  bit $2002
        bpl :-

        ; NMI won't be fired until frame 2
        lda #2
        sta frame_count

        rts

```

The STA $4014 takes up to 518 cycles, so we subtract that from the initial delay. After the STA $4014, the delay begins on an odd cycle. Since also it's an odd number of cycles until the $2002 read, it will occur on an even cycle, as desired.

## Simpler synchronization routine

The PPU synchronization routine is pretty short, but it requires use of the delay macro, which takes a fair amount of code to implement. It's possible to eliminate that without any negative impact.

The fine synchronization loop needs to read $2002 every 33248 cycles, so it can find when the VBL flag is set just before the read. This seems to require a long delay between reads. Until the final iteration, it must not find the VBL flag set. If it were like the coarse loop and read the VBL flag every 7 cycles, it would clearly stop somewhere near the beginning of the first frame, but rarely right at the beginning. It might read $2002 one cycle before the VBL flag is set, loop, then read it 7 cycles later and find it now set. This isn't what we want. If we read it slightly more often, like every 33248/2 = 16624 cycles, it would still work, since the VBL flag is automatically cleared near the end of VBL.

```text
sync_ppu:
        ; Coarse synchronize
        bit $2002
:       bit $2002
        bpl :-

        sta $4014
        delay 16089
        jmp first

        ; Fine synchronize
:       delay 16617
first:  bit $2002
        bpl :-

        rts

```

| Cycle | PPU | CPU |
| 0 | Set VBL flag |  |
| 7459 | Clear VBL flag |  |
| 16622 |  | Read $2002 = 0 |
| 33246 |  | Read $2002 = 0 |
| 33247.5 | Set VBL flag |  |
| 40706.5 | Clear VBL flag |  |
| 49870 |  | Read $2002 = 0 |
| 66494 |  | Read $2002 = 0 |
| 66495 | Set VBL flag |  |
| 73954 | Clear VBL flag |  |
| 83118 |  | Read $2002 = 0 |
| 99742 |  | Read $2002 = 0 |
| 99742.5 | Set VBL flag |  |
| 107201.5 | Clear VBL flag |  |
| 116366 |  | Read $2002 = 0 |
| 132990 | Set VBL flag | Read $2002 = $80 |

That works, but reducing the delays doesn't eliminate the need for them. The important thing is that the $2002 read only be able to happen just after the VBL flag is set, rather than many cycles after it was set. Rather than rely on the PPU to clear the VBL flag, we can clear it ourselves. 16 is a factor of 33248, so we can have the loop take only 16 cycles and still synchronize properly.

```text
sync_ppu:
        ; Coarse synchronize
        bit $2002
:       bit $2002
        bpl :-

        sta $4014
        bit <0

        ; Fine synchronize
:       bit <0
        nop
        bit $2002
        bit $2002
        bpl :-

        rts

```

| Cycle | PPU | CPU |
| 0 | Set VBL flag |  |
| 10 |  | Dummy read $2002 = $80 |
| 14 |  | Read $2002 = 0 |
| 26 |  | Dummy read $2002 = 0 |
| 30 |  | Read $2002 = 0 |
| ... |
| 33242 |  | Dummy read $2002 = 0 |
| 33246 |  | Read $2002 = 0 |
| 33247.5 | Set VBL flag |  |
| 33258 |  | Dummy read $2002 = $80 |
| 33262 |  | Read $2002 = 0 |
| ... |
| 66490 |  | Dummy read $2002 = 0 |
| 66494 |  | Read $2002 = 0 |
| 66495 | Set VBL flag |  |
| 66506 |  | Dummy read $2002 = $80 |
| 66510 |  | Read $2002 = 0 |
| ... |
| 99738 |  | Dummy read $2002 = 0 |
| 99742 |  | Read $2002 = 0 |
| 99742.5 | Set VBL flag |  |
| 99754 |  | Dummy read $2002 = $80 |
| 99758 |  | Read $2002 = 0 |
| ... |
| 132986 |  | Dummy read $2002 = 0 |
| 132990 | Set VBL flag | Read $2002 = $80 |

Essentially there's a four-cycle window that the second $2002 read in the loop is watching for the VBL flag to be set within. On entry to the loop, we ensure that the flag will never be set within this window. Every 33248/16 = 2078 iterations, the second $2002 read is half a cycle later in the frame, just like the original version. On every other iteration, the dummy $2002 read four cycles before has ensured that the VBL flag is cleared.

# Controller detection

Source: https://www.nesdev.org/wiki/Controller_detection

In some NES programs, it's worthwhile to support multiple controllers. Because different controllers use different protocols, a program supporting multiple controllers should follow a process of elimination to determine what protocol to use. This can be done after reset; real-time controller detection isn't very useful because connecting a controller often causes a voltage sag that freezes the CPU. However, this also means that the player needs to use the same controller for selecting an activity and for actually using it. And when a single cartridge contains activities designed to use different controllers, the menu has to support all of them. For example, the Action 53menu supports a standard controller or Super NES Mouse in port 1, a standard controller in the Famicom expansion port, and the Zapper in port 2.

The following procedure is intended to distinguish among a standard controller, a Four Score, a Super NES Mouse, an Arkanoid controller, a Zapper, and a Power Pad.

## Detection

Much of the detection involves strobing the controller (write 1 then 0 to $4016) and reading nine times. Circuits that ignore the clock will return the same value nine times in a row; circuits that use the clock will return values that vary. So keep track of which bits were 0 throughout and which bits were 1 throughout. In some cases, detection will be inconclusive if the player is holding a button. Repeat the detection each frame until the player releases the button.

### Four Score

A Four Score or Satellite has four controller ports and produces a 24-bit report. $4016 D0 has eight buttons for player 1, eight buttons for player 3, followed by a signature $10. $4017 D0 has eight buttons for player 2, eight buttons for player 4, and signature $20. The momentary movements of two mice may produce the signature, appearing as if players 3 and 4 held Right, but this is exceedingly unlikely. If player 3 is not pressing Right, and player 4 is not pressing Right, and the signature is present on both ports, the controllers in both ports are a Four Score.

The Famicom counterpart to the Four Score is the Hori 4 Players Adapter. It behaves just like a Four Score, with the ports wired so as to swap the signatures: $20 on $4016 D1 and $10 on $4017 D1.

### Zapper

A Zapper has a photosensor (1=dark) on D3 and a trigger (1=half pulled) on D4. After a few lines into vblank, the photosensor should return dark. Strobe the controller ports and read $4017 nine times. If D3 is constant 1 and D4 is constant 0, the controller is a Zapper. A standard controller or mouse will never have D3=1, a correctly calibrated Arkanoid controller will never have D4 constant, and a Power Pad will have D3=1 starting at the ninth read. If both D3 and D4 are constant 1, the controller is either a Zapper with its trigger half pulled or a Power Pad with all buttons held down.

### Arkanoid controller

An Arkanoid controller for NES has a fire button (1=pressed) on D3 and a control knob (serial) on D4. If D3 is constant 0 and D4 is not constant, the controller is an Arkanoid controller. If D3 is constant 1 and D4 is not constant, the controller could be an Arkanoid controller with the fire button held down or a Power Pad with buttons 1-2, 5-7, and 9-11 held down. Wait for the player to let go of the fire button.

### Power Pad

The Power Pad has 8-bit serial on D3 and 4-bit serial on D4, in both cases followed by constant 1 values. We need not require the player to step off the Power Pad, just to not intentionally press all 12 buttons. If D3 is not constant, D4 is not constant, the bit corresponding to button 4 is 0, and the last 4 of the first 8 bits from D4 are 1, the controller is a Power Pad.

### Mouse

A Super NES Mousecan be connected with an adapter to port 1 or 2 of an NES or AV Famicom or to the Famicom expansion port. It returns a 32-bit report on D0 or D1 whose 13th through 16th bits are the signature 0001. If this signature is present, the controller is a SNES mouse.

### Standard controller

If D4 and D3 are constant 0, and the controller is not a mouse or Four Score, it's probably a standard controller. The hardwired controllers on a Famicom and the 7-pin ports on an NES or AV Famicom are connected to D0. A Famicom expansion port adapter adds two additional controllers on D1. In Famicom games with one or two players, the user expects to be able to use the expansion controllers as players 1 and 2 in case the hardwired controllers are worn.

The bits after the report aren't quite as predictable as they are with the other serial devices. The Super NES controller has four more buttons and four zero bits after the existing buttons. Some clone controllers return a stream of 0 after the report instead of a stream of 1.

## Confirmation

Just because a controller is connected doesn't mean a player is holding it. Wait for a player to claim ownership of a controller before expecting further input from it. Standard controller, Four Score Wait for an A (10000000) or Start (00010000) press. Mouse Show a sprite for the mouse pointer and controls for "Start" and the current mouse speed. Wait for the player to move the pointer over a control and press the left mouse button. Clicking the mouse speed changes it to the next setting; clicking Start confirms the mouse. Zapper Once a player pulls the trigger, brighten the screen and count scanlines until the photodiode goes bright. If it doesn't, the player shot offscreen. Arkanoid controller Wait for the fire button to be pressed. Power Pad Wait for button 4 (top right) to be 0 then 1.

# Controller reading

Source: https://www.nesdev.org/wiki/Controller_reading

NES and Famicom controllers are operated through a register interface that is connected to the controller portand expansion port, as well as hardwired controllers on the Famicom.

For most input devicesa standard procedure is used for reading input:
- Write 1 to $4016 to signal the controller to poll its input
- Write 0 to $4016 to finish the poll
- Read polled data one bit at a time from $4016 or $4017

## $4016 Write

```text
7  bit  0
---- ----
xxxx xEES
      |||
      ||+- Controller port latch bit
      ++-- Expansion port latch bits

```

The low 3 bits written to this register will be latched and held. Its output will be continuously available on the OUT line of the controller port, and the expansion port.

Other bits are ignored.

On the standard controllerthis is connected to the parallel/serial control of a 4021 8-bit shift register. Writing 1 to $4016 causes the register to fill its parallel inputs from the buttons currently held. Writing 0 to $4016 returns it to serial mode, waiting to be read out one bit at a time. Most other input devicesoperate in a similar way.

## $4016 / $4017 Read

```text
7  bit  0
---- ----
xxxD DDDD
|||+-++++- Input data lines D4 D3 D2 D1 D0
+++------- Open bus

```

Reading from this register causes a clock pulse to be sent to the controller portCLK line on one controller, and one bit will be read from the connected input lines. $4016 reads only from controller port 1, and $4017 reads only from controller port 2. The read value is inverted: a high signal from the data line will read as 0, and a low signal will read as 1.

For most devices it is necessary to read several times from these registers to collect multiple output bits from the device.

The specific use of each data line depends on the input deviceconnected. For the standard controller and Zapperwhich commonly came with the NES/Famicom:

| Line | Used by |
| D0 | NES standard controller, Famicom hardwired controller |
| D1 | Famicom expansion port controller |
| D2 | Famicom microphone (controller 2 only) |
| D3 | Zapper light sense |
| D4 | Zapper trigger |

The NES controller portmakes only D0, D3 and D4 available for peripherals. The Famicom hardwired controllers connect to D0, and $4016.D2 (microphone) only. Some of the other lines can be connected through the expansion porton the Famicom. The NES expansion port was never used commercially, but connects all 5 data lines to both ports.

The Four Scoremultiplayer adapter for NES only passes D0 from the connected controllers.

### Clock timing

The CLK line for controller port is R/W nand (ADDRESS == $4016/$4017) (i.e., CLK is low only when reading $4016/$4017, since R/W high means read). When this transitions from high to low, the buffer inside the NES latches the output of the controller data lines, and when it transitions from low to high, the shift register in the controller shifts one bit. [1]

### DPCM conflict

Using DPCM sample playback while trying to read the controller can cause problems because of a bug in its hardware implementation.

If the DMCDMA is running, and happens to start a read in the same cycle that the CPU is trying to read from $4016 or $4017, the values read will become invalid. Since the address bus will change for one cycle, the shift register will see an extra rising clock edge (a "double clock"), and the shift register will drop a bit out. The program will see this as a bit deletion from the serial data. Not correcting for this results in spurious presses. On the standard controllerthis is most often seen as a right-press as a trailing 1 bit takes the place of the 8th bit of the report (right).

This glitch is fixed in the 2A07 CPU used in the PAL NES.

This detail is poorly represented in emulators. [2]Because it is not normally a compatibility issue, many emulators do not simulate this glitch at all.

#### Multiple Read Solution

The standard solution used in most games using DMC will read the controller multiple times and compare the results to avoid this problem. This is not suitable for controllers that can't be reread, such as the Super NES Mouse.

See: Controller reading code

#### Synchronized OAM Solution

The APU alternates between "get" and "put" cycles. OAM DMA synchronizes the CPU and APU such that the following cycle (usually an opcode fetch) is a "get". Because reads on a "get" cycle never overlap a glitch, a program on an NTSC NES can miss all the glitches by triggering an OAM DMA as the last thing in vblank just before reading the controller, so long as all $401x reads are spaced an even number of cycles apart. [3]If the execution time of the read routine can span more than one DPCM sample fetch, additional care must be taken to align all CPU writes. [4]

Because this is a relatively new discovery, many current emulated implementations of the DMC glitch may be inadequate for testing this technique. [5]In Mesen 2, set a breakpoint on reading $4016-$4017 with `IsDma `as the condition. Hardware testing is recommended as well.

See: Controller reading code: DPCM Safety using OAM DMA

### Unconnected data lines and open bus

The behaviour of unconnected lines is more complicated. For the most part, unconnected lines are either pulled to 0, or exhibit open busbehaviour.

|  | NES-001$4016/$4017 | NES-101$4016/$4017 | Famicom$4016 | Famicom$4017 |
| D0 | 0 if not connected | 0 if not connected[6] | 0 if not connected[6] |
| D1 | always 0 | 0 if not connected | 0 if not connected |
| D2 | always 0 | open bus[7] | microphone on controller 2 | 0 if not connected |
| D3 | 0 if not connected | open bus | 0 if not connected |
| D4 | 0 if not connected | open bus | 0 if not connected |
| D5 | open bus |
| D6 |
| D7 |

## See Also
- Controller reading code
- Standard controller
- Input devices

## References
- ↑Forum post:DPCM generates extra $4016 read pulse
- ↑http://forums.nesdev.org/viewtopic.php?p=231604#p231604
- ↑Forum post: Rahsennor's OAM-synchronized controller read
- ↑Forum post: demonstration of how ROL instruction affects alignment for OAM DMA synchronized controller reading.
- ↑Forum post: as of May 2016, Nintendulator and Nestopia do not accurately emulate OAM-synchronized controller reading.
- ↑ 6.06.1Famicom controllers are not user-replacable, however they can be easily disconnected (or even replaced with external connectors) after disassembling the console. In that case, $4016/$4017 D0 reads 0.
- ↑Forum post: Riding the open bus (NES-101 D2 behaviour)

# Controller reading code

Source: https://www.nesdev.org/wiki/Controller_reading_code

This page contains example code for reading the NES controller.

See also: Controller reading

## Controller Reading Code

### Basic Example

This is a tutorial example of the bare minimum needed to read the controller. It will explain the basic principles in detail, but once understood, you may wish to continue to the Standard Readexample that follows, as a more complete and ready-to-use code example.

This code describes an efficient method of reading the standard controllerusing ca65syntax.

The result byte buttons should be placed in zero page to save a cycle each time through the loop.

```text
; we reserve one byte for storing the data that is read from controller
.zeropage
buttons .res 1

```

When reading from JOYPAD* what is read might be different from $01/$00 for various reasons. (See Controller reading.) In this code the only concern is bit 0 read from JOYPAD*. .

```text
JOYPAD1 = $4016
JOYPAD2 = $4017

```

This is the end result that will be stored in buttons . 1 if the button was pressed, 0 otherwise.

| bit | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
| button | A | B | Select | Start | Up | Down | Left | Right |

This subroutine takes 132 cycles to execute but ignores the Famicom expansion controller. Many controller reading subroutines use the X or Y register to count 8 times through the loop. But this one uses a more clever ring countertechnique: $01 is loaded into the result first, and once eight bits are shifted in, the 1 bit will be shifted out, terminating the loop.

```text
; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta JOYPAD1
    sta buttons
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta JOYPAD1
loop:
    lda JOYPAD1
    lsr a        ; bit 0 -> Carry
    rol buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc loop
    rts

```

Continue to the next example for a more complete read routine that handles both controllers and the standard Famicom expansion controllers.

### Standard Read for 2 Controllers and Famicom

Adding support for controllers on the Famicom's DA15 expansion port and for player 2's controller is straightforward. Something similar to the following routine is used in most Famicom games. Even though the expansion port is unused on the NES, the unconnected bit will read as 0, so this solution works safely with both Famicom and NES hardware.

```text
.zeropage
buttons: .res 2     ; space for 2 reads

.code
readjoyx2:
    ldx #$00
    jsr readjoyx    ; X=0: read controller 1
    inx
    ; fall through to readjoyx below, X=1: read controller 2

readjoyx:           ; X register = 0 for controller 1, 1 for controller 2
    lda #$01
    sta JOYPAD1
    sta buttons, x
    lsr a
    sta JOYPAD1
loop:
    lda JOYPAD1, x
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol buttons, x  ; Carry -> bit 0; but 7 -> Carry
    bcc loop
    rts

```

If playing DPCM samples, there is an additional reread step to prevent errors ( see below).

Note that the and to ignore bits is not optional, as the upper bits of JOYPAD1 read are not guaranteed to be 1 or 0 [1].

### Alternative 2 Controllers Read

Alternatively, we could combine both controller reads into 1 loop with a single strobe, though this routine is not safe to use with DPCM samples playing ( see below).

```text
.zeropage
buttons: .res 2

.code
readjoy2:
    lda #$01
    sta JOYPAD1
    sta buttons+1 ; player 2's buttons double as a ring counter
    lsr a
    sta JOYPAD1
loop:
    lda JOYPAD1
    and #%00000011
    cmp #$01
    rol buttons+0
    lda JOYPAD2
    and #%00000011
    cmp #$01
    rol buttons+1
    bcc loop
    rts

```

### DPCM Safety

The NTSC CPU has a bug where the DMAthat fetches DPCM sample data for the APU's DMC channelcan cause extra reads of the joypads. This is fixed on PAL. For standard controllers, this bug results in at least one bit being deleted from the controller's serial report, causing the following buttons to be shifted over and usually resulting in the right direction appearing to be pressed. Software cannot directly detect that this bug has happened, so controller reading code in games using sampled audio has to be resilient against it. There are currently two approaches for dealing with this problem, each with significant pros and cons.

Note that both approaches share some limitations:
- They may become unsafe if interrupted by NMI or IRQ.
- Poor support across most emulators can make it hard to know if the code works correctly on hardware.
- Using third party controllers may make testing harder: official standard controllers shift in 1's on extra reads that cause obvious errant right presses, while third party controllers may shift in 0's.
- It is possible for joypad state to corrupt even if the controller reading code works as intended. Any read from $4000-401F provides an opportunity for DMC DMA to trigger a joypad read, and this can cause controllers with state that is slow or impossible to recover (e.g. Arkanoid controller) to lose that state before the controllers are intentionally read. Some sound engines cause such reads by doing indexed stores to sound registers. For controllers with normal strobe behavior where the full current state is immediately loaded on strobe, this is not a problem.

Neither approach is a one-size-fits-all solution; there are cases where one or the other solution does not work.

#### DPCM Safety using Repeated Reads

Controllers can be read safely by quickly reading a controller twice, checking whether the reads match, and re-reading if they don't until the two most recent reads do match. This method was used by commercial games [2]and was the only solution known at the time, though not all implementations of it work properly.

```text
readjoy2_safe:
    ldx #$00
    jsr readjoyx_safe  ; X=0: safe read controller 1
    inx
    ; fall through to readjoyx_safe, X=1: safe read controller 2

readjoyx_safe:
    jsr readjoyx
reread:
    lda buttons, x
    pha
    jsr readjoyx
    pla
    cmp buttons, x
    bne reread
    rts

```

Note that the time between the start of one read and the end of the next read must be less than the length of the fastest DMC fetch period minus 4 (428 cycles). This is because multiple bit deletions could cause both passes to result in the same incorrect data. For this reason, it is normal to read controllers one at a time with this method, rather than attempting both at once. (Note: `readjoy2 `above takes too long to be suitable.) Gimmick! has such a bugresulting from trying to read both at once.

Most often a controller will be read 2 times, and 3 or 4 in the case of a DPCM corruption, or the player pressing a button during the read. With the assistance of tools, a malicious controller input could change the buttons on every read, holding it in this reread loop indefinitely [3][4], but this is generally not an important edge case to account for.

This approach to DPCM safety has these benefits:
- The code is easy to understand and modify.
- It is position-independent: branching across page boundaries does not inherently break it, and it can be done at any time in the frame.
- It works in all emulators, even if they don't implement the bug correctly or at all.

It also has these drawbacks:
- Repeated reads cannot be used for controllers that lose state on reads (e.g. SNES mouse), take a long time before data is available to read again (e.g. Arkanoid controller), or have too much data to read twice within the cycle budget (e.g. Famicom Network Controller).
- It can be hard to know if the code is safe:
  - The budget limitations are not obvious because of obscure edge cases with the bug. All joypad reads for 2 complete passes must finish within one DMC period minus 4 (usually 428 cycles). Reading both controllers in a single pass takes too long; they must be handled individually.
  - Hardware differences can make real hardware testing difficult: the bug behaves one way on the AV Famicom and NES, and another way on other Famicom models. The Famicom behavior may mitigate the bug when using repeated reads.
  - Even most accurate emulators don't emulate all the ways repeated reads can fail. Mesen v2 does and is recommended.
- This approach does not prevent the bug, it merely works around it, so other negative side effects of the bug still happen:
  - The sample byte read by the APU can be corrupted when the bug occurs. However, it is difficult to hear this corruption.
  - The APU's frame IRQ may be lost when the bug occurs. However, this feature is very rarely used.
- It makes controller reads take at least twice as long and does not guarantee a maximum runtime. Normally, it will take up to 4 passes.

#### DPCM Safety using OAM DMA

Because halts for DPCM fetches have very specific timing, it is possible to get glitch-free controller reads by timing all $4016 and $4017 reads to fall on one cycle parity. This is because the CPU alternates between two kinds of cycles: 'get' and 'put'. DPCM fetches normally occur only on put cycles, and because the first cycle after OAM DMA is normally guaranteed to be a get cycle, timed code can use OAM DMA to ensure the joypad reads land on get cycles. [5]This is a relatively new technique and is not supported by several older emulators [6], but generally works in currently-supported emulators. In the following example code, the controller1 and controller2 labels must be in zeropage for the timing to work.

This solution might be ideal, using fewer cycles than doing repeated reads, and taking a consistent amount of time. It can also be adapted for DPCM-conflict free reading of controllers that require a longer report, like four player adaptersor the SNES mouse(see notes below).

However, unlike the repeated reads solution, it can't be executed at any time. Instead it must be integrated into your NMI routine to coincide with your sprite OAM DMA once per frame.

```text
    lda #OAM
    sta $4014          ; ------ OAM DMA ------
    ldx #1             ; get put          <- strobe code must take an odd number of cycles total
    stx buttons+0      ; get put get      <- buttons must be in the zeropage
    stx $4016          ; put get put get
    dex                ; put get
    stx $4016          ; put get put get
loop:
    lda $4017          ; put get put GET  <- loop code must take an even number of cycles total
    and #3             ; put get
    cmp #1             ; put get
    rol buttons+1, x   ; put get put get put get (X = 0; waste 1 cycle for alignment)
    lda $4016          ; put get put GET
    and #3             ; put get
    cmp #1             ; put get
    rol buttons+0      ; put get put get put
    bcc loop           ; get put [get]    <- this branch must not be allowed to cross a page

```

Note that this example routine only reads two 8-bit controllers and does not take enough time to span more than one DPCM fetch. Routines longer than this must contend with two additional constraints:
- When DMC DMA is delayed by an odd number of cycles, it takes 3 cycles instead of 4, changing the cycle parity. If extending this function to read more bits, care must be taken so that all CPU write cycles are aligned. Instructions with a single write cycle must align the write to avoid conflict with the DPCM fetch, and double-write instructions like ROL need to align both writes so that the DPCM fetch falls on the first write. [7]If an interrupt can occur during the routine, it must be aligned so the fetch can only fall on the second of the three automatic stack writes.
- When DMC DMA occurs near the end of OAM DMA, it steals an odd number of cycles, inverting the cycle parity. Every DMC period after that, a misaligned DPCM fetch will occur. Care must be taken to ensure this does not land on a joypad read. For longer functions, these misaligned cases can be resynced by landing the DPCM fetch on a single write cycle.

See DMAfor detailed information on DMA timing. However, game developers writing synced code may find it easier to consider just the specific case of DMC DMA used for reloading the sample buffer. These timings do not apply to the initial DMC DMA load caused by writing to $4015, and they are not sufficient for emulating DMA timings; emulator authors should refer to DMAfor comprehensive information. A DMC DMA reload takes these cycle counts in these cases:
- 4 cycles if it falls on a CPU read cycle
- 3 cycles if it falls on an odd number of CPU write cycles
- 4 cycles if it falls on an even number of CPU write cycles
- An even number of cycles if it occurs during OAM DMA
- An odd number of cycles if it occurs at the end of OAM DMA (changing cycle parity for the following code)

This approach to DPCM safety has these benefits:
- It can support any controller because it only does one pass and has no cycle budget.
- It is nearly as fast as standard reads.
- It avoids the bug and thus does not corrupt the sample byte or interfere with the APU's frame IRQ.

It also has these drawbacks:
- It uses timed code and relies on complicated DMA behavior, so it is harder to understand and modify.
- Moving the code can break it by causing branches to cross a page boundary, changing the timing.
- It must directly follow OAM DMA. Unusual features that skip OAM DMA on gameplay frames are not compatible with this approach. (On lag frames, normally both OAM DMA and controller reads are skipped. This is not a problem for synced reads.)
- It does not work in emulators that emulate the bug but have incorrect DMA timing (e.g. Nestopia). Many modern emulators either don't emulate the bug or have correct-enough DMA timing.
- Synced code that lasts longer than one DMC period minus 4 (usually 428 cycles) is difficult to write correctly. This is because write cycles must also be synced and specific desync cases occur if DMC DMA lands at the end of OAM DMA. However, this is the only approach that supports code of this length.

## Other Useful Operations

### Button Flags

It is helpful to define the buttons as a series of bit flags:

```text
BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

```

And then buttons can be checked as follows:

```text
    lda buttons
    and #BUTTON_A | BUTTON_B
    beq notPressingAorB
    ; Handle presses.
notPressingAorB:

```

### Calculating Presses and Releases

To calculate newly pressed and newly released buttons by comparing against the last frame's buttons:

```text
    ; newly pressed buttons: not held last frame, and held now
    lda last_frame_buttons, x
    eor #%11111111
    and buttons, x
    sta pressed_buttons, x

    ; newly released buttons: not held now, and held last frame
    lda buttons, x
    eor #%11111111
    and last_frame_buttons, x
    sta released_buttons, x

```

### Directional Safety

Opposing directions (Up+Down and Left+Right) are possible on non-standard controllers, or even on a worn out standard one. Both directions can be tested for at the same time in an efficient bitwise operation:

```text
    lda buttons, x
    and #%00001010    ; Compare Up and Left...
    lsr a
    and buttons, x    ; to Down and Right
    beq not_opposing
        ; Use previous frame's directions
        lda buttons, x
        eor last_frame_buttons, x
        and #%11110000
        eor last_frame_buttons, x
        sta buttons, x
    not_opposing:

```

Diagonal directions can also be detected at the same time as opposing ones, by testing if more than 1 directional bit is set. This could be used as part of a 4-way joystick style control scheme:

```text
    lda buttons, x
    and #%00001111    ; If A & (A - 1) is nonzero, A has more than one bit set
    beq not_diagonal
    sec
    sbc #1
    and buttons, x
    beq not_diagonal
        ; Use previous frame's directions
        lda buttons, x
        eor last_frame_buttons, x
        and #%11110000
        eor last_frame_buttons, x
        sta buttons, x
    not_diagonal:

```

As an example, the code above rejects the detected cases by using the direction bits from the previous frame, but depending on the situation another response might be more appropriate (e.g. cancel just the opposing bits, or clear all directions).

## External Examples
- Forum post:Blargg's DMC-fortified controller read routine
- Forum post:Rahsennor's OAM-synchronized controller read
- Forum post:Drag's bitwise DMC-safe controller reading
- pads.s:pinobatch's NROM-template controller read routine

## References
- ↑Controller reading: Unconnected data lines and open bus
- ↑Super Mario Bros. 3 controller reread method
- ↑Ars Technica: How to beat Super Mario Bros. 3 in less than a second
- ↑https://tasvideos.org/6466STool-Assisted Speedrun of Super Mario Bros. 3 which first demonstrated abusing controller reread routines.
- ↑Forum post:Rahsennor's OAM-synchronized controller read
- ↑Forum post:as of May 2016, Nintendulator and Nestopia do not accurately emulate OAM-synchronized controller reading.
- ↑Forum post:demonstration of how ROL instruction affects alignment for OAM DMA synchronized controller reading.

# ELROM

Source: https://www.nesdev.org/wiki/ELROM

ELROM (NES-ELROM and HVC-ELROM) is a common board within the ExROMset. Like other ExROM boards, ELROM uses the Nintendo MMC5ASIC.

## Overview
- PRG ROM size: 128, 256 or 512 KB (DIP-28/32 Nintendo pinout)
- PRG ROM bank size: 8 KB, 16 KB, or 32 KB
- PRG RAM: none
- CHR capacity: 128, 256 or 512 KB ROM (DIP-32 Nintendo pinout)
- CHR bank size: 1 KB, 2 KB, 4 KB, or 8 KB
- Nametable mirroring: Controlled by mapper
- Subject to bus conflicts: No

## Solder Pad Config
- MMC5 in 'CL mode' : 'CL3', 'CL4', 'CL5' and 'CL6' connected, 'SL3', 'SL4', 'SL5' and 'SL6' disconnected.
- MMC5 in 'SL mode' : 'CL3', 'CL4', 'CL5' and 'CL6' disconnected, 'SL3', 'SL4', 'SL5' and 'SL6' connected.
- Sound circuitry used : R1, R2, R4, C2, C3 present, R9 present (NES-ELROM only) or R3 and C4 present (HVC-ELROM only). An American or European NES must be modified to output cartridge audio, even if the audio circuitry is implemented.
- Sound circuitry unused : R1, R2, R3, R4, R9, C2, C3 and C4 not present.

Note : Maybe there are more than two ways to put the MMC5 in 'CL mode' or 'SL mode' if some pads are set to CL and some other to SL. More testing on this should be done.

## See also
- Nintendo MMC5

# ExROM

Source: https://www.nesdev.org/wiki/ETROM

The generic designation ExROM refers to cartridge boards made by Nintendo that use the Nintendo MMC5mapper.

## Board Types

The following ExROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR |
| EKROM | 128 / 256 / 512 / 1024 KB | 8 KB | 128 / 256 / 512 / 1024 KB ROM |
| ELROM | 128 / 256 / 512 / 1024 KB |  | 128 / 256 / 512 / 1024 KB ROM |
| ETROM | 128 / 256 / 512 / 1024 KB | 16 KB (2x 8KB) | 128 / 256 / 512 / 1024 KB ROM |
| EWROM | 128 / 256 / 512 / 1024 KB | 32 KB | 128 / 256 / 512 / 1024 KB ROM |

## Solder Pad Config
- MMC5 in 'CL mode' (default) : 'CL4', 'CL5', and 'CL6' connected; 'SL4', 'SL5', and 'SL6' disconnected.
- MMC5 in 'SL mode' : 'CL4', 'CL5', and 'CL6' disconnected; 'SL4', 'SL5', and 'SL6' connected.

Unlike SOROM, which battery-backs the second RAM, ETROM battery-backs the first RAM.
- RAM chip with data retention (default) : 'CL2' connected, 'SL2' disconnected, with Battery, D1, R5, R6, and R8 present.
- RAM chip without data retention : 'CL2' disconnected, 'SL2' connected, with Battery, D1, R5, and R6 removed.
- Second RAM chip (if present) with data retention : 'CL1' disconnected, with battery, D1, R7, and R8 present.
- Second RAM chip (if present) without data retention (default) : 'CL1' connected, 'SL1' disconnected, R7 removed.
- NES-ETROM can be trivially modified to support 2×32 KiB RAMs without needing rewiring, using the CL15 and SL15 solder jumpers. 'CL15' by default connects SRAM pin 26 (PRG RAM +CE on an 8 KiB RAM) to MMC5 pin 83 (PRG RAM +CE). 'SL15' instead connects the same pin 26 (PRG RAM A13 on a 32 KiB RAM) to MMC5 pin 69 (PRG RAM A13). PRG RAM pin 1 (no connection / PRG RAM A14) is always connected to the MMC5.

- Sound circuitry used (Famicom): R1, R2, R3, R4, C2, C3, and C4 present (HVC-ExROM). No Famicom cartridges ever disabled the MMC5 audio as the traces on the circuit board do not permit the MMC5's amplifier to be bypassed.
- Sound circuitry used (NES) : R1, R2, R4, R9, C2, C3 present (NES-ExROM). An American or European NES must be modified to output cartridge audio, even if the audio circuitry is implemented.
- Sound circuitry unused : R1, R2, R4, R9, C2, and C3 not present (NES-ExROM).

NES-ExROM boards entirely omitted R3 and C4, and added R9 (nominally 10kΩ) between R4 and the output to the cartridge edge. The silkscreened values on NES-EKROM and NES-EWROM, and Famicom games that actually used the expansion audio, replace R1 with 6.8kΩ. This increases the volume of the pulse waves by 6.9dB, and is believed to equalize the volume of the MMC5 pulse waves to the internal ones. MMC5 pins 1 and 100 are some kind of inverter used as an amplifier.

# ExROM

Source: https://www.nesdev.org/wiki/EWROM

The generic designation ExROM refers to cartridge boards made by Nintendo that use the Nintendo MMC5mapper.

## Board Types

The following ExROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR |
| EKROM | 128 / 256 / 512 / 1024 KB | 8 KB | 128 / 256 / 512 / 1024 KB ROM |
| ELROM | 128 / 256 / 512 / 1024 KB |  | 128 / 256 / 512 / 1024 KB ROM |
| ETROM | 128 / 256 / 512 / 1024 KB | 16 KB (2x 8KB) | 128 / 256 / 512 / 1024 KB ROM |
| EWROM | 128 / 256 / 512 / 1024 KB | 32 KB | 128 / 256 / 512 / 1024 KB ROM |

## Solder Pad Config
- MMC5 in 'CL mode' (default) : 'CL4', 'CL5', and 'CL6' connected; 'SL4', 'SL5', and 'SL6' disconnected.
- MMC5 in 'SL mode' : 'CL4', 'CL5', and 'CL6' disconnected; 'SL4', 'SL5', and 'SL6' connected.

Unlike SOROM, which battery-backs the second RAM, ETROM battery-backs the first RAM.
- RAM chip with data retention (default) : 'CL2' connected, 'SL2' disconnected, with Battery, D1, R5, R6, and R8 present.
- RAM chip without data retention : 'CL2' disconnected, 'SL2' connected, with Battery, D1, R5, and R6 removed.
- Second RAM chip (if present) with data retention : 'CL1' disconnected, with battery, D1, R7, and R8 present.
- Second RAM chip (if present) without data retention (default) : 'CL1' connected, 'SL1' disconnected, R7 removed.
- NES-ETROM can be trivially modified to support 2×32 KiB RAMs without needing rewiring, using the CL15 and SL15 solder jumpers. 'CL15' by default connects SRAM pin 26 (PRG RAM +CE on an 8 KiB RAM) to MMC5 pin 83 (PRG RAM +CE). 'SL15' instead connects the same pin 26 (PRG RAM A13 on a 32 KiB RAM) to MMC5 pin 69 (PRG RAM A13). PRG RAM pin 1 (no connection / PRG RAM A14) is always connected to the MMC5.

- Sound circuitry used (Famicom): R1, R2, R3, R4, C2, C3, and C4 present (HVC-ExROM). No Famicom cartridges ever disabled the MMC5 audio as the traces on the circuit board do not permit the MMC5's amplifier to be bypassed.
- Sound circuitry used (NES) : R1, R2, R4, R9, C2, C3 present (NES-ExROM). An American or European NES must be modified to output cartridge audio, even if the audio circuitry is implemented.
- Sound circuitry unused : R1, R2, R4, R9, C2, and C3 not present (NES-ExROM).

NES-ExROM boards entirely omitted R3 and C4, and added R9 (nominally 10kΩ) between R4 and the output to the cartridge edge. The silkscreened values on NES-EKROM and NES-EWROM, and Famicom games that actually used the expansion audio, replace R1 with 6.8kΩ. This increases the volume of the pulse waves by 6.9dB, and is believed to equalize the volume of the MMC5 pulse waves to the internal ones. MMC5 pins 1 and 100 are some kind of inverter used as an amplifier.

# FamicomBox database

Source: https://www.nesdev.org/wiki/FamicomBox_database

The FamicomBox menu cartridge contains a database of game checksums for games that do not have a Nintendo header, allowing them to be detected by the menu software as valid (assuming they have a matching 3198 CIC) and displayed in the menu with an appropriate title. This enabled some games in this list to be released without any modification to the ROM, which could be expensive and invasive.

## Format

Each entry is 32 bytes long:
- $00-$01 : Full PRG checksum. Big-endian sum of the largest region detected to contain unique data ($E000-$FFFF, $C000-$FFFF, or $8000-$FFFF).
- $02 : Title length - 1 (1-15 = 2-16 bytes).
- $03-$12 : Title of the game, in ASCII, left-justified. Normally padded with spaces ($20).
- $13-$1C : Padding. These are always padded in valid entries with spaces ($20).
- $1D-$1E : Upper PRG checksum. If present, big-endian sum of $E000-$FFFF if that is the largest region with unique data, or of $C000-$FFFF otherwise. This allows just the upper half of the unique data to be checked, which can work around collisions or unreliable mapper power-on state.
- $1F : Upper PRG checksum present (0 = present).

Invalid entries are filled with $FF.

## Lookup algorithm

The FamicomBox software only falls back on a database lookup if it does not find a valid Nintendo headerat $FFE0-$FFF9 in the CPU address space. To generate a database checksum, it does the following steps:
- $00 is written to the first address containing $00 that it finds starting at $8000; this configures some mappers, such as UNROM and GNROM, to use bank 0. If there is no $00 value in $8000-$FFFF, address $0000 is harmlessly read then written.
- Two checksums are produced: a "full-checksum" that includes all of the unique data and an "upper-checksum" that sums only $E000-$FFFF if that is the largest region with unique data or $C000-$FFFF otherwise.
  - First, it sums $C000-$DFFF for the full-checksum and $E000-$FFFF for the upper-checksum. While summing, each byte of the two regions is compared. If the regions are byte-for-byte identical, checksumming is complete and both checksums contain the sum of $E000-$FFFF.
  - Otherwise, it sums $8000-$BFFF for the full-checksum and $C000-$FFFF for the upper-checksum. If the regions are byte-for-byte identical, checksumming is complete and both checksums contain the sum of $C000-$FFFF.
  - Otherwise, it combines the full- and upper-checksums and stores the result as the full-checksum. The full-checksum contains the sum of $8000-$FFFF and the upper-checksum contains the sum of $C000-$FFFF.
- If the full-checksum is $FFFF, the database search is skipped and the cartridge is marked as valid with no title, and the process is complete.
- The database is searched from the beginning ($A000).
  - If byte $1F of the database entry is 0, bytes $1D-$1E are compared against the upper-checksum. If they match, the cart is valid and we use this entry for the title. If the low bytes differ, this database entry is skipped. If only the high byte differs, or if byte $1F isn't 0, it continues on to the full-checksum.
  - Bytes $00-$01 are compared against the full-checksum. If they match, the cart is valid and we use this entry for the title. Otherwise, we advance to the next entry.
  - If we advanced to $C000, the cart is not valid.

## Entries

The default sorting for this table is the order they appear in the database. Said ordering appears to consist of two blocks - one block for later game revisions and another block for earlier revisions, roughly in release date order. (E.g. Famicom launch titles come first in each block: Donkey Kong , Donkey Kong Jr. , and Popeye ) There are empty entries with checksum $FFFF, which are noted as such. There are 82 more empty entries beyond "BABEL", the last valid entry, which are omitted from the table for brevity.

| Title | Checksum | Game version | Notes |
| Full | Upper |
| DONKEY KONG | $1104 |  | Donkey Kong (World) (Rev 1) |  |
| DONKEY KONG JR. | $F97C |  | Donkey Kong Jr. (World) (Rev 1) |  |
| POPEYE | $2F81 |  | Popeye (World) (Rev 1) |  |
| MARIO BROS. | $AAB1 |  | Mario Bros. (World) |  |
| MAH-JONG | $E300 |  | Mahjong (Japan) (Rev 1), Mahjong (Japan) (Rev 2) |  |
| GOMOKU-NARABE | $A54B |  | Gomoku Narabe (Japan) |  |
| SANSUU ASOBI | $02AF |  | Donkey Kong Jr. no Sansuu Asobi (Japan) |  |
| EIGO ASOBI | $62DB |  | Popeye no Eigo Asobi (Japan) |  |
| BASEBALL | $7792 |  | Baseball (Japan) |  |
| PINBALL | $6B06 |  | Pinball (Japan, USA) |  |
| TENNIS | $076A |  | Tennis (Japan, USA) |  |
| WILD GUNMAN | $1783 |  | Wild Gunman (World) (Rev 1) |  |
| DUCK HUNT | $8261 |  | Duck Hunt (World) |  |
| GOLF | $AF78 |  | Golf (Japan) |  |
| HOGAN'S ALLEY | $E84A |  | Hogan's Alley (World) |  |
| DONKEY KONG 3 | $8C5F |  | Donkey Kong 3 (World) |  |
| NUTS & MILK | $A00E |  | Nuts & Milk (Japan) |  |
| LODE RUNNER | $6407 |  | Lode Runner (Japan) |  |
| DEVIL WORLD | $081A |  | Devil World (Japan) (Rev 1) |  |
| YONIN-UCHI | $0D81 |  | 4 Nin Uchi Mahjong (Japan) (Rev 1) |  |
| F1 RACE | $9342 |  | F1 Race (Japan) |  |
| URBAN CHAMPION | $FB3C |  | Urban Champion (World) |  |
| CLU CLU LAND | $BB8A |  | Clu Clu Land (World) |  |
| EXCITEBIKE | $A6A0 |  | Excitebike (Japan, USA) |  |
| BALOON FIGHT | $BDF9 |  | Balloon Fight (Japan) |  |
| ICE CLIMBER | $E710 |  | Ice Climber (Japan) |  |
| BUNGELING BAY | $8C9C |  | Raid on Bungeling Bay (Japan) (Rev 1) |  |
| CHAMPIONSHIP | $3683 |  | Championship Lode Runner (Japan) |  |
| SOCCER | $FD07 |  | Soccer (Japan, USA) |  |
| FLAPPY | $3809 |  | Flappy (Japan) |  |
| STAR FORCE | $5BD4 |  | Star Force (Japan) |  |
| WRECKING CREW | $6935 |  | Wrecking Crew (World) |  |
| SPARTAN X | $4270 |  | Spartan X (Japan) |  |
| DOOR DOOR | $411E |  | Door Door (Japan) |  |
| ASTRO-ROBO SASA | $C964 |  | Astro Robo Sasa (Japan) |  |
| GEIMO | $A73E |  | Geimos (Japan) | The title data contains "GEIMOS", but the title length is off by 1 |
| POOYA | $92F4 |  | Pooyan (Japan) | The title data contains "POOYAN", but the title length is off by 1 |
| SUPER MARIO | $44B9 |  | Super Mario Bros. (World) |  |
| CHALLENGER | $AF86 |  | Challenger (Japan) |  |
| PACHICON | $9114 |  | Pachicom (Japan) |  |
| MACH RIDER | $13DE |  | Mach Rider (Japan, USA) (Rev 1) |  |
| PORTPIA | $086E |  | Portopia Renzoku Satsujin Jiken (Japan) |  |
| ONYANKO TOWN | $3939 |  | Onyanko Town (Japan) |  |
| PENGUIN-KUN WARS | $832B |  | Penguin-kun Wars (Japan) |  |
| DOUGH BOY | $F9F9 |  | Dough Boy (Japan) |  |
| LUNAR BALL | $5C2F |  | Lunar Ball (Japan) |  |
| EXED EXES | $4E76 |  | Chou Fuyuu Yousai Exed Exes (Japan) |  |
| LOT LOT | $FB6E |  | Lot Lot (Japan) |  |
| KARATEKA | $B09C |  | Karateka (Japan) |  |
| 1942 | $024F |  | 1942 (Japan, USA) |  |
| SON SON | $BDDE |  | Son Son (Japan) |  |
| VOL GUARD 2 | $EBF4 |  | Volguard II (Japan) |  |
| THEXDER | $B14B |  | Thexder (Japan) |  |
| ZUNO-SENKAN GARU | $B224 |  | Zunou Senkan Galg (Japan) |  |
| BOKOSUKA WARS | $03FD |  | Bokosuka Wars (Japan) |  |
| BINARYLAND | $82A8 |  | Binary Land (Japan) |  |
| HATTORI-KUN | $287A |  | Ninja Hattori-kun - Ninja wa Syugyou de Gozaru no Maki (Japan) |  |
| BOMBER MAN | $BF54 |  | Bomberman (Japan) |  |
| MAGMAX | $58E3 |  | Magmax (Japan) |  |
| CIRCUS CHARLIE | $178E |  | Circus Charlie (Japan) |  |
| BALTRON | $A8BA |  | Baltron (Japan) |  |
| HYDLIDE SPECIAL | $4207 |  | Hydlide Special (Japan) |  |
| DRAGON QUEST | $34AE |  | Dragon Quest (Japan) |  |
| KEISAN-GAME 1 | $38BC |  | Sansuu 1 Nen - Keisan Game (Japan) |  |
| KEISAN-GAME 2 | $F339 |  | Sansuu 2 Nen - Keisan Game (Japan) |  |
| KEISAN-GAME 3 | $6D4F |  | Sansuu 3 Nen - Keisan Game (Japan) |  |
| SUPAI VS SUPAI | $1A81 |  | Spy vs Spy (Japan) |  |
| SECROSS | $0AF7 |  | Seicross (Japan) (Rev 1) |  |
| MIGHTY BOMB JACK | $C3CE |  | Mighty Bomb Jack (Japan) (Rev 1) |  |
| B-WING | $6673 |  | B-Wings (Japan) |  |
| BIRD-WEEK | $84BC |  | Bird Week (Japan) |  |
| STAR SOLDIER | $8355 |  | Star Soldier (Japan) |  |
| YIE AR KUNG-FU | $8C18 |  | Yie Ar Kung-Fu (Japan) (Rev 1.2) |  |
| EXERION | $7332 |  | Exerion (Japan) |  |
| ELEVATOR ACTION | $CDBA |  | Elevator Action (Japan) (Rev 0) |  |
| GALAGA | $83E4 | $83E4 | Galaga (Japan) | Specifies checksums for both $8000-$BFFF and $C000-$FFFF |
| ZIPPY RACE | $E95E |  | Zippy Race (Japan) |  |
| ANTAR. ADVENTURE | $7B59 |  | Kekkyoku Nankyoku Daibouken (Japan) (Rev 0) |  |
| SUPER ARABIAN | $9F1E |  | Super Arabian (Japan) |  |
| SPACE INVADERS | $3001 |  | Space Invaders (Japan) |  |
| XEVIOUS | $C6A9 |  | Xevious (Japan) (Rev 1) |  |
| CHACK'N POP | $BC5F |  | Chack'n Pop (Japan) |  |
| DIG DUG | $3745 |  | Dig Dug (Japan) |  |
| 10-YARD FIGHT | $0339 |  | 10-Yard Fight (Japan) (Rev 0) |  |
| NINJA-KUN | $F6E8 |  | Ninja-kun - Majou no Bouken (Japan) (Rev 1) |  |
| HYPER OLYMPIC | $A4A4 |  | Hyper Olympic (Japan) |  |
| PAC-MAN | $2C69 |  | Pac-Man (Japan) (Rev 0) |  |
| FIELD COMBAT | $F147 |  | Field Combat (Japan) |  |
| FORMATION Z | $4656 |  | Formation Z (Japan) (Rev 1) |  |
| FRONT LINE | $11C1 |  | Front Line (Japan) |  |
| MAPPY | $E929 |  | Mappy (Japan) |  |
| ROAD FIGHTER | $C7CF |  | Road Fighter (Japan) |  |
| DRUAGA | $83E4 | $B88D | Druaga no Tou (Japan) | Relies on $C000-$FFFF checksum because of collision with Galaga |
| BATTLE CITY | $4218 |  | Battle City (Japan) |  |
| WARPMAN | $08D8 |  | Warpman (Japan) |  |
| HYPER SPORTS | $5600 |  | Hyper Sports (Japan) (Rev 0) |  |
| HONSHOGI | $9B81 |  | Honshougi - Naitou 9 Dan Shougi Hiden (Japan) |  |
| CITY CONNECTION | $D8EE |  | City Connection (Japan) |  |
| ROUTE-16 TURBO | $1876 |  | Route-16 Turbo (Japan) |  |
| PAC-LAND | $9D5B |  | Pac-Land (Japan) |  |
| BURGER TIME | $9B98 |  | BurgerTime (Japan) |  |
| JAJAMARU-KUN | $2052 |  | Ninja Jajamaru-kun (Japan) |  |
| SKY DESTROYER | $76B0 |  | Sky Destroyer (Japan) |  |
| TWIN BEE | $0300 |  | TwinBee (Japan) |  |
| KINNIKUMAN | $7F7B |  | Kinnikuman - Muscle Tag Match (Japan) (Rev 1) |  |
| STAR LUSTER | $8742 |  | Star Luster (Japan) |  |
| IKKI | $A2D3 |  | Ikki (Japan) |  |
| OBAKE-NO Q-TARO | $5DD6 |  | Obake no Q Tarou - Wanwan Panic (Japan) |  |
|  | $FFFF |  |  | (Empty) |
| MACROSS | $7BB9 |  | Choujikuu Yousai - Macross (Japan) |  |
|  | $FFFF |  |  | (Empty) |
| SPELUNKER | $99D0 |  | Spelunker (Japan) |  |
| GYRODINE | $1D0D |  | Gyrodine (Japan) |  |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
| MAKAIMURA | $B7A5 |  | Makaimura (Japan) | UNROM - Checksum is bank 0 + bank 7 |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
| SUPER CHINESE | $E74A |  |  | This doesn't seem to match any configuration of banks for Super Chinese (Japan) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
|  | $FFFF |  |  | (Empty) |
| DONKEY KONG | $03EC |  | Donkey Kong (Japan) (Rev 0) |  |
| DONKEY KONG JR. | $E7C4 |  | Donkey Kong Jr. (Japan) (Rev 0) |  |
| POPEYE | $2950 |  | Popeye (Japan) (Rev 0) |  |
| MAH-JONG | $C446 |  | Mahjong (Japan) (Rev 0) |  |
| WILD GUNMAN | $2ED6 |  | Wild Gunman (Japan, USA) (Rev 0) |  |
| DEVIL WORLD | $07FB |  | Devil World (Japan) (Rev 0) |  |
| YONIN-UCHI | $11BA |  | 4 Nin Uchi Mahjong (Japan) (Rev 0) |  |
| MACH RIDER | $0F7E |  | Mach Rider (Japan, USA) (Rev 0) |  |
| BUNGELING BEY | $9108 |  | Raid on Bungeling Bay (Japan) (Rev 0) |  |
| CASTLE EXCELLENT | $BCBD |  | Castle Excellent (Japan) |  |
| MIGHTY BOMB JACK | $3777 |  | Mighty Bomb Jack (Japan) (Rev 0) |  |
| A S | $8523 |  | ASO - Armored Scrum Object (Japan) | The title data contains "A S O", but the title length specifies only 3 bytes |
| SOROMON NO KAGI | $1A7C |  | Solomon no Kagi (Japan) |  |
| KING' KNIGHT | $3652 |  | King's Knight (Japan) |  |
| HOKUTO NO KEN | $1F3F |  | Hokuto no Ken (Japan) |  |
| TERRA CRESTA | $3EB7 |  | Terra Cresta (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| BANANA | $801E |  | Banana (Japan) |  |
| SUPER PITFALL | $F7BD |  | Super Pitfall (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| GHOSTBUSTERS | $C0CA |  | Ghostbusters (Japan) |  |
| BOUKENJIMA | $7D7E |  | Takahashi Meijin no Bouken-jima (Japan) |  |
| SENJYO NO OHKAMI | $2B2F |  | Senjou no Ookami (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| SPACE HUNTER | $2B9C |  | Space Hunter (Japan) |  |
| BUGGY POPPER | $934B |  | Buggy Popper (Japan) |  |
| OTHELLO | $BC8D |  | Othello (Japan) (Rev 0) |  |
| SUPER STAR FORCE | $E152 |  | Super Star Force (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| TRANSFORMER | $78E6 |  | Tatakae! Chou Robot Seimeitai Transformers - Convoy no Nazo (Japan) |  |
| KEISAN GAME 4 | $28D3 |  | Sansuu 4 Nen - Keisan Game (Japan) |  |
| KEISAN GAME 5-6 | $9F2B |  | Sansuu 5 & 6 Nen - Keisan Game (Japan) |  |
| SUPER MONKEY | $9458 |  | Ganso Saiyuuki - Super Monkey Daibouken (Japan) |  |
| DAIVA | $CF6B |  | Daiva - Imperial of Nirsartia (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| IKARI | $8C23 |  | Ikari (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| CAT IN BOOTS | $1C9B |  | Nagagutsu o Haita Neko - Sekai Isshuu 80 Nichi Daibouken (Japan) |  |
| MEIKYU-KUMIKYOKU | $B1C0 |  | Meikyuu Kumikyoku - Milon no Daibouken (Japan) |  |
| AIGINA | $70DC |  | Aigina no Yogen - Balubalouk no Densetsu Yori (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| TIGER HELI. | $3E3F |  | Tiger-Heli (Japan) |  |
| HOTTERMAN | $349E |  | Hottarman no Chitei Tanken (Japan) |  |
| CRAZY CLIMBER | $F13F |  | Crazy Climber (Japan) | Mapper 180 - Checksum is bank 0 |
| TOKI NO TABIBITO | $8E14 |  | Toki no Tabibito - Time Stranger (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| SHERLOCK HOLMES | $A4CE |  | Sherlock Holmes - Hakushaku Reijou Yuukai Jiken (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| SEIKIMATSU | $0161 |  | Seikima II - Akuma no Gyakushuu! (Japan) |  |
| DORAEMON | $952D |  | Doraemon (Japan) (Rev 0), Doraemon (Japan) (Rev 1) | GNROM - Checksum is bank 0 |
| TATAKAI NO BANKA | $4F73 |  | Tatakai no Banka (Japan) (Rev 0) | UNROM - Checksum is bank 0 + bank 7 |
| LAYLA | $0CEB |  | Layla (Japan) | UNROM - Checksum is bank 0 + bank 7 |
| SKYKID | $3707 |  | Sky Kid (Japan) | Mapper 206 (no banking) - Checksum is bank 0 + bank 1 + bank 2 + bank 3 |
| SUPER CHINESE | $0B16 |  | Super Chinese (Japan) | Mapper 206 (no banking) - Checksum is bank 0 + bank 1 + bank 2 + bank 3 |
| BABEL | $F4C8 |  | Babel no Tou (Japan) | Mapper 206 - Checksum is bank 0 + bank 0 + bank 2 + bank 3 |

# Famicom 3D System

Source: https://www.nesdev.org/wiki/Famicom_3D_System

The Famicom 3D Systemis a Famicom expansion port device that uses active LCD shutter glasses to provide 3D visuals. The headset (HVC-031) plugs into a control box (HVC-032) using a 3.5mm connector. The control box has two such ports, allowing up to two headsets, and passes through a Famicom expansion port so other controllers can be used. Compatible games manually control which eye sees which frame, alternating to give each eye a unique perspective that creates a 30 Hz stereoscopic image. While these glasses do not require a CRT TV to correctly function, they do require very low latency and some kind of impulse display such as black frame insertion.

The 3D System is supported by the following Famicom games:
- Attack Animal Gakuen (1987)
- Cosmic Epsilon (1989)
- Falsion (1987)
- Famicom Grand Prix II: 3D Hot Rally (1988)
- Fuuun Shourin Ken: Ankoku no Maou (1988)
- Highway Star (1987)
- JJ: Tobidase Daisakusen Part II (1987)
- Tobidase Daisakusen (1987)

In these games, the 3D mode can be toggled with the select button except in Fuuun Shourin Ken: Ankoku no Maou , where the mode is enabled by holding A while pressing start on the title screen.

Note that the 3D System was only released in Japan. Versions of these games released internationally ( 3-D WorldRunner and Rad Racer ) instead achieve 3D with an anaglyph mode using passive red and cyan glasses.

### Output ($4016 write)

```text
7  bit  0
---- ----
xxxx xxFx
       |
       +--- 0: Next field of video is for left eye (left eye lens is transparent; right eye lens is opaque)
            1: Next field of video is for right eye

```

Because the Famicom only generated images at 60Hz, each resultant image will flicker at 30Hz.

### Hardware

The glasses used here take the same signal as Sega's Master System 3D and several other contemporary active shutter systems. There is a 3.5mm headphone jack, with the same mapping as headphones (tip to sleeve: left eye; ring to sleeve: right eye).

The "active shutter" glasses themselves use this convention: 10V peak, 20V peak-to-peak, indicates that the corresponding eye should be opaque. 0V indicates that it should become transparent. No DC component is ever permitted: that will damage the liquid crystal displays.

The adapter itself (HVC-032) contains a JRC4558 dual opamp and an proprietary logic chip made by Sharp labeled 'IX0043AE'. This IX0043AE emits a clock for other hardware to generate 10V, -10V, and somehow converts the above-described control into signals for the two eyes; specifics are not known.

### See Also
- https://forums.nesdev.org/viewtopic.php?t=20036(Krzysiobal's reverse engineering of HVC-032)
- https://nicole.express/2023/the-third-dimension-and-the-eight-bits.html
- http://cmpslv3.stars.ne.jp/Mark3/M33d.png(Enri's schematic of Sega's 3-D glasses adapter)

# Famicom 3D System

Source: https://www.nesdev.org/wiki/Famicom_3D_glasses

The Famicom 3D Systemis a Famicom expansion port device that uses active LCD shutter glasses to provide 3D visuals. The headset (HVC-031) plugs into a control box (HVC-032) using a 3.5mm connector. The control box has two such ports, allowing up to two headsets, and passes through a Famicom expansion port so other controllers can be used. Compatible games manually control which eye sees which frame, alternating to give each eye a unique perspective that creates a 30 Hz stereoscopic image. While these glasses do not require a CRT TV to correctly function, they do require very low latency and some kind of impulse display such as black frame insertion.

The 3D System is supported by the following Famicom games:
- Attack Animal Gakuen (1987)
- Cosmic Epsilon (1989)
- Falsion (1987)
- Famicom Grand Prix II: 3D Hot Rally (1988)
- Fuuun Shourin Ken: Ankoku no Maou (1988)
- Highway Star (1987)
- JJ: Tobidase Daisakusen Part II (1987)
- Tobidase Daisakusen (1987)

In these games, the 3D mode can be toggled with the select button except in Fuuun Shourin Ken: Ankoku no Maou , where the mode is enabled by holding A while pressing start on the title screen.

Note that the 3D System was only released in Japan. Versions of these games released internationally ( 3-D WorldRunner and Rad Racer ) instead achieve 3D with an anaglyph mode using passive red and cyan glasses.

### Output ($4016 write)

```text
7  bit  0
---- ----
xxxx xxFx
       |
       +--- 0: Next field of video is for left eye (left eye lens is transparent; right eye lens is opaque)
            1: Next field of video is for right eye

```

Because the Famicom only generated images at 60Hz, each resultant image will flicker at 30Hz.

### Hardware

The glasses used here take the same signal as Sega's Master System 3D and several other contemporary active shutter systems. There is a 3.5mm headphone jack, with the same mapping as headphones (tip to sleeve: left eye; ring to sleeve: right eye).

The "active shutter" glasses themselves use this convention: 10V peak, 20V peak-to-peak, indicates that the corresponding eye should be opaque. 0V indicates that it should become transparent. No DC component is ever permitted: that will damage the liquid crystal displays.

The adapter itself (HVC-032) contains a JRC4558 dual opamp and an proprietary logic chip made by Sharp labeled 'IX0043AE'. This IX0043AE emits a clock for other hardware to generate 10V, -10V, and somehow converts the above-described control into signals for the two eyes; specifics are not known.

### See Also
- https://forums.nesdev.org/viewtopic.php?t=20036(Krzysiobal's reverse engineering of HVC-032)
- https://nicole.express/2023/the-third-dimension-and-the-eight-bits.html
- http://cmpslv3.stars.ne.jp/Mark3/M33d.png(Enri's schematic of Sega's 3-D glasses adapter)

# Family Computer Disk System

Source: https://www.nesdev.org/wiki/Famicom_Disk_System

FDS

| Company | Nintendo |
| Complexity | ASIC |
| Pinout | RP2C33 pinout |
| BIOS PRG ROM size | 8K |
| PRG RAM capacity | 32K |
| CHR capacity | 8K |
| Disk capacity | ~64K per side |
| Mirroring | H or V, switchable |
| Bus conflicts | No |
| IRQ | Yes |
| Audio | Yes |

The Family Computer Disk System ( Famicom Disk System , FDS for short) is a video game add-on made by Nintendo for the Famicom and sold in Japan and Hong Kong. It was designed to reduce the cost of making copies of software by switching from mask ROMchips to Nintendo's proprietary Disk Card, a storage medium based on Mitsumi's Quick Disk (QD).

Unfortunately for Nintendo, it also reduced the pirates' cost of making copies of software. Software is stored on one or multiple disk sides. The FDS BIOSis responsible for controlling the disk drive to load data from disks to PRG RAM or VRAM before giving control to the software. Additional hardware features include a timer IRQand a wavetable channel.

## Hardware

The FDS comes in two parts: The disk drive (HVC-022) and the RAM adapter (HVC-023).

The RAM adapter is a special shaped cartridge that contains the RAM chips and an ASIC with DRAM controller, IRQ hardware, sound generation hardware, serial interface for the disk drive, and parallel port. The disk drive has to be powered separately and is only connected to the console via a serial cableto the RAM adapter.

The disk drive is a modified version of the Mistumi Quick Disk (QD) drive. Conventional floppy disk drives contain two motors: a spindle motor that spins the disk at a specific speed, and a stepper motor which moves the read/write head between each circular data track. By comparison, QD drives only contain a single motor which does both at once, so it instead stores the data in a single spiral-shaped track. There is a mechanism that detects when the head reaches the end of the disk and makes it return to the start (making an audible click). Because of this limitation, random access to the disk is impossible, making QD drive data access behave similarly to a reel of tape (but much faster). Data can only be accessed by spinning the disk, waiting for the head to reach the inner edge, then waiting again until the desired data file is reached. A complete cycle through an entire disk side takes about 7 seconds.

The QD drive only contains basic electronics, there is no "intelligence" in it; therefore, the serial interface almost directly represents what is stored on the disk.

### Protections

Some protections were added to the FDS drive in an attempt to thwart unlicensed software (primarily disk copiers):
- The FDS disk drive contains a physical lockout in the form of molds which only fit disks with recesses spelling "NINTENDO", in order to prevent regular QDs from being used (also a similar trademark protection as the license screen). This can be bypassed by using disks with custom recesses, including adapters which can be fitted onto regular QDs.
- Later revisions of the drive controller power board/IC contain protections against long data write operations performed by disk copiers. This can be bypassed through hardware modifications.
  - TODO: Measure/determine how much data can be written on protected drives.

### Disks

The FDS Disk Card (HVC-021) is a modified version of the Mitsumi Quick Disk. The recesses spelling "NINTENDO" is designed to fit with molds on the FDS disk drive (see protections above).

See:
- FDS disk format- the disk data format and file structure.
- FDS file format( .FDS ) - an archival file format for storing and emulating FDS disks.
- QD file format( .QD ) - an archival file format used in emulators by Nintendo.

## Banks

All Banks are fixed
- PPU $0000-$1FFF: 8k CHR RAM
- CPU $6000-$DFFF: 32k PRG RAM
- CPU $E000-$FFFF: 8k BIOS PRG ROM

## Registers

$402x registers are write-only, $403x registers are read-only

### Timer IRQ reload value low ($4020)

```text
7  bit  0
---------
LLLL LLLL
|||| ||||
++++-++++- 8 LSB of timer IRQ reload value

```

### Timer IRQ reload value high ($4021)

```text
7  bit  0
---------
LLLL LLLL
|||| ||||
++++-++++- 8 MSB of timer IRQ reload value

```

Unlike $4022, $4020 and $4021 are not affected by the $4023.0 (disk registers enabled) flag - the reload value can be altered even when disk registers are disabled.

### Timer IRQ control ($4022)

```text
7  bit  0
---------
xxxx xxER
       ||
       |-- Timer IRQ Repeat Flag
       +-- Timer IRQ Enabled

```

When $4022 is written to with bit 1 (IRQ enabled) set, the reload value is copied into the IRQ's counter. Each CPU clock cycle the counter is decremented by one if the enable flag is set.

When the counter's value is 0 and the IRQ enable flag is on, the following happens on every CPU cycle:
- An IRQ is generated.
- The IRQ counter is reset to its reload value (contained in $4020+$4021)
- If the IRQ repeat flag is NOT set, the IRQ enabled flag is cleared and the counter stops.

Notes:
- This register is affected by the $4023.0 (Enable disk I/O registers) flag - if disk registers are disabled, it is impossible to start the IRQ counter (writing to $4022 has no effect).
- Clearing $4023.0 will immediately stop the IRQ counter and acknowledge any pending timer IRQs.
- Writing to $4022 with bit 1 (IRQ enabled) cleared will stop the IRQ counter and acknowledge any pending timer IRQs.
- Enabling timer IRQs when the reload value is set to 0 will cause an IRQ immediately. Doing this with the repeat flag enabled will cause an infinite loop of IRQs on every CPU cycle.
- Since the disk transfer routine also uses IRQs, it's very important to disable timer IRQs before doing any access to the disk.

There are only 3 known ways to acknowledge the timer IRQ:
- Read $4030
- Disable timer IRQs by writing to $4022
- Disable disk registers by writing to $4023

### Master I/O enable ($4023)

```text
7  bit  0
---------
?xxx xxSD
|      ||
|      |+- Enable disk I/O registers
|      +-- Enable sound I/O registers
+--------- Unknown (TODO)

```

The FDS BIOS writes $00, then $83 to it during reset. The purpose of bit 7 is unknown.

Disabling disk registers disables both disk and timer IRQs.

### Write data register ($4024)

The data that this register is programmed with will be the next 8-bit quantity to load into the shift register (next time the byte transfer flag raises), and to be shifted out and appear on pin 5 of the RAM adapter cable (2C33 pin 52).

Writing to this register acknowledges disk IRQs. [ citation needed ]

### FDS Control ($4025)

```text
7  bit  0
---------
IE1C MRDT
|||| ||||
|||| |||+- Transfer Reset
|||| |||     1: Reset transfer timing to the initial state.
|||| ||+-- Drive Motor Control (0: start, 1: stop)
|||| |+--- Transfer Mode (0: write; 1: read)
|||| +---- Nametable Arrangement
||||         0: Horizontal ("Vertical Mirroring")
||||         1: Vertical ("Horizontal Mirroring")
|||+------ CRC Transfer Control (1: transfer CRC value)
||+------- Unknown, always set to '1'
|+-------- CRC Enabled (0: disable/reset, 1: enable)
+--------- Interrupt Enabled
             1: Generate an IRQ every time the byte transfer flag is raised.

```

Notes:
- The BIOS and commercial software are known to always write 1 to bit 5. Writing 0 to it alters bits 1 and 2 of the external connector ($4026/$4033) but its purpose is currently unknown. (TODO: this supposedly also affects byte transfer IRQs?)
- CRC values are stored on the diskand verified when reading/writing a given file.
- Disabling the CRC resets its state. The FDS BIOS disables the CRC between file blocks, then enables it before accessing each file block to calculate/verify their CRC values.
- To change the nametable arrangement on the fly, a read-modify-write of its mirror variableshould be done to prevent altering unrelated bits.

Writing to this register acknowledges disk IRQ.

### External connector ($4026)

Output of expansion terminalwhere there's a shutter on the back of the RAM adapter. The outputs of $4026 (open-collector with 4.7K ohm pull-ups (except on bit 7)), are shared with the inputs on $4033.

TODO: Setting $4025.D5 to 0 alters bits 1 and 2 of the output, which are also reflected in $4033. Its purpose is currently unknown.

### Disk Status register ($4030)

```text
7  bit  0
---------
TExB Mx?D
|| | | ||
|| | | |+- Timer Interrupt (1: an IRQ occurred)
|| | | +-- Unknown Interrupt source (TODO)
|| | +---- Nametable Arrangement (from $4025.D3)
|| +------ CRC control (0: CRC passed; 1: CRC error)
|+-------- End of Head (1 when disk head is on the most inner track)
+--------- Byte transfer flag. Set every time 8 bits have been transferred between the RAM adaptor & disk drive (service $4024/$4031).
           Reset when $4024, $4031, or $4030 has been serviced.

```

Reading this register acknowledges timer and disk IRQs.

### Read data register ($4031)

This register is loaded with the contents of an internal shift register every time the byte transfer flag raises. The shift register receives its serial data via pin 9 of the RAM adapter cable (2C33 pin 51).

Reading this register acknowledges disk IRQs.

### Disk drive status register ($4032)

```text
7  bit  0
---------
xxxx xPRS
      |||
      ||+- Disk flag  (0: Disk inserted; 1: Disk not inserted)
      |+-- Ready flag (0: Disk readу; 1: Disk not ready)
      +--- Protect flag (0: Not write protected; 1: Write protected or disk ejected)

```

Notes:
- The Ready flag corresponds to the drive head's position. It is set to 1 when the head reaches the end of the disk, and cleared once it returns to the beginning of the disk.
- The Protect flag corresponds to the write protect tab present on the upper-left corner of the inserted disk side. It is set to 1 if the tab is broken.

Reading this register acknowledges disk IRQs. [ citation needed ]

### External connector read ($4033)

```text
7  bit  0
---------
BIII IIII
|||| ||||
|+++-++++- Input from expansion terminal where there's a shutter on the back of the RAM adapter.
+--------- Battery status (0: Voltage is low; 1: Good).

```

When a bit is clear in $4026 port it will read back as '0' here (including battery bit) because of how open collector input works. Battery bit should be checked when the motor is on, otherwise it always will be read as 0.

### Sound ($4040-$4092)

For details on sound information, see FDS audio.

## BIOS

The FDS contains a fixed 8KB BIOS at $E000-FFFF. This controls the Famicom at power-on and reset, dispatches the NMI and IRQ, and offers an API for accessing the data on disk. Routines for common tasks including controller reading and PPU handling are also provided for programmer convenience.

See: FDS BIOS

## See Also
- FDS BIOS
- FDS disk format
- FDS file format( .FDS )
- QD file format( .QD )
- FDS audio
- FDS RAM adaptor cable pinout
- FDS expansion port pinout
- RP2C33 pinout
- FdsIrqTests(v7)by Sour - Test program for various elements of the FDS' IRQ
- FDS-Mirroring-Testby TakuikaNinja - Test program for the FDS' nametable arrangement/mirroring switching functionality
- iNES mapper 20- Reserved for FDS dumps, but not widely used for it.
- TNES- Nintendo 3DS Virtual Console ROM format with support for .QD images.
- GitHub repository:Simple FDS example for ca65
- GitHub repository:Simple FDS example for asm6f
- Forum post:Skipping the FDS license screen
- FDS Listby ccovell - command line utility to inspect FDS disk image contents.
- FDS Listerby ccovell - utility to inspect FDS disk contents that runs on an FDS.
- Triton Quick Disk Drive- a QD drive peripheral which was sold for various home computers.

## References
- https://www.nintendo.com/jp/famicom/hardware/disksystem.html(Japanese)
- FDS technical reference.txtby Brad Taylor (old/outdated)
- Enri's Famicom Disk System page(Japanese) - Descriptions for $4025 and $4030 are inaccurate.
- Enri's Famicom Disk System page(Japanese) (old/outdated)
- fds-nori.txt- FDS reference in Japanese by Nori (old/outdated)
- Forum post: .fds format: Can checksums be heuristically detected? - Includes a CRC implementation in C.
- Forum post: FDS IRQ reload flag/value
- https://www.famicomdisksystem.com/disks/
- https://famicomworld.com/workshop/tech/famicom-disk-system-fd3206-write-mod/
- https://famicomworld.com/workshop/tech/fds-power-board-modifications/

# Famicom Network Controller

Source: https://www.nesdev.org/wiki/Famicom_Network_Controller

The Famicom Network Controller(HVC-051) is a 23-button controller for use with the Famicom Network System. It is essentially a standard controllerthat adds a number pad, and can be used with normal games.

## Layout

```text
 .------------------------------------------.
 | (<)   (>)  (1) (2) (3) (*) (C)           |
 | SEL _ STA                        (END)   |
 |   _| |_    (4) (5) (6) (#) (.)           |
 |  |_   _|                                 |
 |    |_|     (7) (8) (9) (  0  )  (B)  (A) |
 '------------------------------------------'

```

(ASCII art courtesy Nocash)
- The Select button has the additional text 前ぺージ = Previous Page
- The Start button has the additional text 次ページ = Next Page
- The B button has the additional text 目次 = Table of Contents
- The A button has the additional text 実行 = Execute
- The button marked "END" instead has the text 通信終了 = End of Communication

## Protocol

The protocol looks like a standard Famicom expansion portcontroller, returning its result via reads from $4016 D1. After the initial eight reads, the following sixteen reads return the following bits in order:

```text
 0-7 - see Standard controller
 8 - 0
 9 - 1
10 - 2
11 - 3
12 - 4
13 - 5
14 - 6
15 - 7
16 - 8
17 - 9
18 - *
19 - #
20 - .
21 - C
22 - (Always 0)
23 - 通信終了

```

Like the standard controller, reads after the first 24 read as logic 1.

## Sources
- Raphnet
- astro187 on the forum

# Family Computer Network System

Source: https://www.nesdev.org/wiki/Famicom_Network_System

System Overview

The Famicom Network System is a complicated device with its own memory mapping system and internal CPU. The RF5C66 chip provides the main mapper functionality, delegating its own registers at $40A0, RF5A18 Famicom registers at $40D0, an internal Kanji ROM at $5000, an internal 8kByte W-RAM at $6000. It also controls the bank of a built-in 16 KiB CHR RAM (using two 8 KiB CHR RAM chips).

The RF5A18 contains CPU2, which is a 65 C 02 processor with its own independent CPU clock. It has a built-in 4kByte ROM. This chip is responsible for controlling the modem communications. It communicates with the Famicom CPU through four bidirectional registers at $40Dx.

The Famicom Network System plugs into the Famicom through its cartridge connector and provides the user a ZIF style slot to insert a tsuushin card . The card is similar to a normal cartridge but does not have access to any PPU signals. Commercial cards are observed to have their own MMC1 memory mapper, which does not interfere with any of the registers of the Famicom Network System. CPU R/W and the CPU data bus are routed through the RF5C66 chip before making it to the card and other internal hardware. It effectively blocks the Famicom Network System from driving the data bus for certain regions of memory, and possibly also is intended to act as a bidirectional buffer / signal conditioner. It is also used for blocking writes when the lid switch is open or when the CIC fails. Older revisions of Famicom Network System also buffered the Famicom address bus with 74HC541 chips, so it is plausible that signal conditioning was a concern. LH5323M1 Kanji Graphic ROM

The LH5323M1 is a 256kByte graphics ROM containing primarily Kanji data that is mapped at $5000-5FFF. Each index in this range is a 32-byte space containing 16x16 1bpp graphics, usually for a single character, and each read automatically advances to the next byte in the sequence. There are 2 128kByte banks, and the low bank is default at power-on. Writing 1 to $40B0.0 selects the high bank. Reading from $40B0 resets to the beginning of the 32-byte sequence. Writing $40B0 does not reset the sequence however. No values written to $40B0 have been observed to arbitrarily change or reset the position in the sequence. Commercial software has been observed to use throwaway reads when accessing data that does not start at the beginning of the 32-byte area.

The Kanji ROM chip is connected directly to the non-buffered Famicom CPU data bus. Writes in the range $5000-5FFF do activate Kanji ROM /CE and are subject to bus conflict. Expansion Audio

The Famicom Network System does have expansion audio capabilities. The Famicom audio is routed through the modem module, but nowhere directly to either of the large ASICs. Dial tones have been observed through the television speakers. It is unlikely but unknown if there are other possible sources of sound. Disk Drive Support

According to a block diagram with potentially dubious origins, the RF5C66 chip contains a disk drive controller. Similar design in several ways to the Famicom Disk System, it is suspected that a disk drive can be connected to the expansion port and controlled by the RF5C66. Since this feature was never used, it is unknown how to use or activate it, or even if that feature is fully implemented. The original FDS has a large DRAM that is not present as a discrete chip in the Famicom Network System. It is unknown if such a DRAM could be already integrated into the RF5C66, or could be attached externally and simply not populated, or if a special tsuushin card was to be constructed containing this RAM. All original FDS registers are notably absent and all discovered registers start immediately after where the FDS registers would normally be. There is no obvious path to produce FDS expansion audio. This remains a mystery presently.

One possibility if the RF5C66 follows a similar pinout to the FDS RP2C33:

```text
        79 / -> Exp P3-2  (reg unknown) Serial Out (observed 95.95kHz)
       78 / <- Exp P3-3  (reg unknown) Serial In
      77 / -> Exp P3-4  (!$40A4.2)    Read / Write
     76 / -> Exp P3-5  (!$40A4.1)    Reset Transfer Timing
    75 / -> Exp P3-6  ($40A3.0)     Turn on Motor
   74 / <- Exp P3-7  ($40A5.2)     Write Protect
  73 / <- Exp P3-8  ($40A5.1)     Disk Not Ready
 72 / <- Exp P3-9  ($40A5.0)     Disk Missing
71 / <- Exp P3-11 ($40A5.7)     Battery Health

```
Memory Map

```text
+================+ $0000 - Famicom Internam RAM
| Famicom        |
| Internal RAM   |
+----------------+ $0800
|   (Mirrors of  |
|   $0000-$07FF) |
+================+ $2000 - Famicom PPU Registers
| Famicom PPU    |
| Registers      |
+----------------+ $2008
|   (Mirrors of  |
|   $2000-$2007) |
+================+ $4000 - Famicom APU, IO, and Test Registers
| FC APU and IO  |
| Registers      |
+----------------+ $4018
| FC Test Mode   |
| Registers      |
+----------------+ $4020
|   (Open Bus)   |
+================+ $40A0 - Famicom Network System Internal Registers
| Famicom Modem  |
| RF5C66         |
| Registers      |
+----------------+ $40D0
| Famicom Modem  |
| RF5A18 (CPU2)  |
| Registers      |
+----------------+ $40D8
|   (Mirror of   |
|   $40D0-$40D7) |
+----------------+ $40E0
| Unused Device  |
| Registers      |
| (Open Bus)     |
+----------------+ $40F0
|   (Open Bus)   |
+----------------+ $4100
|   (Open Bus)   |
+----------------+ $41A0
|   (Mirror of   |
|   $40A0-$40FF) |
+----------------+ $4200
|   (Mirrors of  |
|   $4100-$41FF) |
+================+ $5000 - Famicom Network System Internal Kanji ROM
| FNS            |
| LH5323M1       |
| Kanji ROM      |
+================+ $6000 - Famicom Network System Internal RAM and Tsuushin Card RAM
| FNS            |
| Internal RAM   |
+================+ $8000 - Tsuushin Card ROM Space
| Tsuushin Card  |
| Space          |
|                |
+================+ $10000

```

## Data Bus Behavior

The CPU data bus is buffered in both directions through the RF5C66 chip before making it to the tsuushin card and other internal hardware, with the exception of the Kanji graphics ROM and the RF5C66's own registers, which sit directly on the CPU data bus. It appears that the buffer goes from CPU Data Bus to Card Data Bus, or Card Data Bus to CPU Data Bus only. There has not been a high-impedance state observed when testing each possible address in read and write directions on a standalone RF5C66 chip. The CPU Data Bus and Card Data Bus were always observed to be equal despite attaching opposite pull-up and pull-down resistors.

When RF5C66 pin 29 is driven low by the master CIC chip's pin 11, it forces Card R/W always high, thereby preventing most RAM and register writes in the Famicom Network System. Potentially, the data bus buffer has an additional behavior in this mode in order to prevent bus conflicts. The lid switch also imposes such a behavior when the lid is open, but it does not appear that the RF5C66 has a way of knowing when the switch is open, so the bus conflicts do not appear to be prevented in that case.

The propagation delay of the CPU data bus buffer and CPU R/W buffer are measured to be about 16 nsec.

| Address Range | Buffer Direction When Reading | Buffer Direction When Writing | Notes |
| $0x00-$4x1F | CPU -> Card | CPU -> Card | Famicom internal RAM and registers |
| $4x20-$4x9F | CPU -> Card | CPU -> Card | (unknown; FDS registers exactly fit here) |
| $4xA0-$4xCF | CPU -> Card | CPU -> Card | RF5C66 registers |
| $4xD0-$4xDF | CPU <- Card | CPU -> Card | CPU 2 registers, /CE at RF5C66 pin 42 |
| $4xE0-$4xEF | CPU <- Card | CPU -> Card | Unused device registers1, /CE at RF5C66 pin 41 |
| $4xF0-$4xFF | CPU -> Card | CPU -> Card | (unknown) |
| $5x00-$5xFF | CPU -> Card | CPU -> Card2 | Kanji graphic ROM, /CE at RF5C66 pin 50 |
| $6x00-$7xFF | CPU <- Card | CPU -> Card | Famicom Network System internal RAM, /CE at RF5C66 pin 40 |
| $8x00-$FxFF | CPU <- Card | CPU -> Card | Tsuushin card, /CE is /ROMSEL |

1 Address range $4xE0-$4xEF was meant for a second device similar to CPU 2. Since that device doesn't exist, a tsuushin card could theoretically exploit those 256 addresses for its own purposes; for example, its own read/write registers.

2 Writes here are subject to bus conflict on the CPU data bus. Known Registers

Note: All registers available to the Famicom ignore address bits 8-11 because those bits are not physically connected to the RF5C66. Therefore, register $4xA0 has mirrors that exist at $40A0, $41A0 ... $4FA0. For simplicity, this page shows all registers as the $40xx mirror.

| Address | ReadHasEffect | ReadHasData | Write | Owner | Function |

```text

```

| Reference Data |
-
| Bench test found open bus when reading this register. |
$40A1 Unknown Yes Unknown RF5C66 Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- Bits exist but function is unknown

```

| Reference Data |
-
-
| Bench test observed value $FF with pull-downs. Test code writing values $01,02,04,08,10,20,40,80 always read back $FF after each write. |
$40A2 Yes Yes Unknown RF5C66 IRQ Acknowledge, similar to FDS register $4030

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- Timer Interrupt (1: an IRQ occurred)
||||||+--- Bit exists but function is unknown
||||++---- (unlikely to exist)
++++------ Bits exist but function is unknown

```
- Reading this register acknowledges /IRQ.
  - Observed inconsistent behavior acknowledging, possibly suggesting multiple IRQ sources.

| Reference Data |
-
-
-
  -
  -
-
| Bench test observed value $20 with pull-downs, $2C with pull-ups. Test code writing values $01,02,04,08,10,20,40,80 always read back $20 after each write. JRA-PAT: Reads this register with a BIT op-code right before CLI op-code. Reads this register and makes a decision based on D7. Super Mario Club reads this register with BIT op-code. |
$40A3 Unknown No Yes RF5C66 Unknown Function.

```text
Write
76543210
|||||||+-- EXP 6 = $40A3.0 (POR value = 0)
+++++++--- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Various values written to this register affect the behavior of pulses on pin 79.

| Reference Data |
-
-
-
| Bench test found open bus when reading this register. JRA-PAT writes $2F to this register and appears to keep a RAM copy at $15. Super Mario Club writes $2F to this register and appears to keep a RAM copy at $15. |
$40A4 Unknown No Yes RF5C66 Expansion Port Control

```text
Write
76543210
|||||||+-- (unknown)
||||||+--- EXP 5 = !($40A4.1) (POR value = 0)
|||||+---- EXP 4 = !($40A4.2) (POR value = 0)
+++++----- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Note: Reading test should be repeated with pull-ups and pull-downs on expansion pins.
- This register has not been observed read or written to by any commercial software.

| Reference Data |
-
| Bench test found open bus when reading this register. |
$40A5 Unknown Yes Unknown RF5C66 Expansion Port Input Data

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- Input value of EXP 9
||||||+--- Input value of EXP 8
|||||+---- Input value of EXP 7
|++++----- (unlikely to exist)
+--------- Input value of EXP 11

```

| Reference Data |
-
| Bench test observed value $00 with pull-downs, $78 with pull-ups. |
$40A6 Unknown Yes Yes RF5C66 M2 Cycle Counter LSB, similar to FDS register $4020

```text
Write
76543210
++++++++-- Cycle counter reload value (LSB)

Read
76543210
++++++++-- Cycle counter present value (LSB)

```
- Writing to this register writes to the cycle counter reload value.
- Reading this register gives the present value of the counter.
- Writing any value to $40A8 resets the counter to the reload value.
- This value counts down.
- When the value reaches $0000, the next count rolls over to $FFFF or auto-reloads depending on $40A8.0.
$40A7 Unknown Yes Yes RF5C66 M2 Cycle Counter MSB, similar to FDS register $4021

```text
Write
76543210
++++++++-- Cycle counter reload value (MSB)

Read
76543210
++++++++-- Cycle counter present value (MSB)

```
- Refer to description in $40A6, this register being the MSB portion of the counter.
$40A8 Unknown No Yes RF5C66 IRQ Control, similar to FDS register $4022

```text
Write
76543210
|||||||+-- IRQ Repeat Flag
||||||+--- IRQ Enable
++++++---- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Writing anything to this register resets the cycle counter to the reload value.
- Observed writing $02 makes /IRQ go low, $00 makes /IRQ go high.
  - Reading $40A2 with /IRQ low acknowledges it back high.
  - Acknowledging with $40A2 first before writing $02 here prevents IRQ immediately going low.
- Observed rollover of cycle counter to $FFFF with repeat flag = 0 and auto-reload when flag = 1.

| Reference Data |
-
-
  -
  -
  -
  -
    -
    -
    -
    -
-
  -
  -
| Bench test found open bus when reading this register. JRA-PAT: Writes $00 to this register. Writes $00 again later, potentially connected to RAM $4F. Later, right after having written $25 to $40A7 and $20 to $40A6, writes $02 to this register. Has these various sequences hard-coded: $25->$40A7, $20->$40A6, $02->$40A8 $1C->$40A7, $10->$40A6, $02->$40A8 $03->$40A7, $19->$40A6, $02->$40A8 $06->$40A7, $F1->$40A6, $02->$40A8 Super Mario Club: Writes $00 to this register. Later, right after having written $24 to $40A7 and $F8 to $40A6, writes $02 to this register. |
$40A9 Yes Yes Unknown RF5C66 Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- Bits exist but function is unknown

```
- Bench test observed value $00 with pull-ups.
- When driving RF5C66 pin 45 high, this 8-bit value changes.
- Pin 45 high causes the value to change continuously, as if counting cycles.
- The value does not appear to match $40A7 or $40A6, though further testing is required to say that for sure.
- Reading this register causes its contents to be loaded into register $40AA.
$40AA No Yes Unknown RF5C66 Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- Bits exist but function is unknown

```
- This register maintains the most recent value that was read from $40A9.

| Reference Data |
-
| Bench test observed value $00 with pull-ups. |
$40AB Yes No Yes RF5C66 Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Reading this register resets the value of $40A9 back to $00.

| Reference Data |
-
-
-
| Bench test found open bus when reading this register. JRA-PAT writes $00 to this register. Super Mario Club writes $00 to this register. |
$40AC Yes No Unknown RF5C66 Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Reading this register prevents timed toggle on RF5C66-69 (see notes in pinout).

| Reference Data |
-
  -
-
-
| Bench test: Observed $00 with pull-downs and $FF with pull-ups (totally open bus). JRA-PAT reads this register with a BIT op-code and throws away the result. Super Mario Club reads this register with a BIT op-code. |
$40AD Unknown Yes Yes RF5C66 Mirroring Control

```text
Write
76543210
|+++++++-- (unknown)
+--------- Mirroring (POR value = 0)
             0 = Vertical Mirroring (CIRAM A10 = PPU A10)
             1 = Horizontal Mirroring (CIRAM A10 = PPU A11)

Read
76543210
|+++++++-- (unlikely to exist)
+--------- Present value of CIRAM A10

```

| Reference Data |
-
-
-
| Bench test observed $00 with pull-downs, $7F with pull-ups. JRA-PAT writes $00 to this register. Super Mario Club writes $80 to this register. |
$40AE Unknown No Yes RF5C66 Unknown Function.

```text
Write
76543210
|||||||+-- Built-in RAM /CE control (POR value = 1)
|||||||      1 = Built-in RAM /CE enabled to go low for reads and writes in the range $6000-7FFF.
|||||||          Pin 5C66.28 = 1 at all address ranges.  (This pin normally n/c.)
|||||||      0 = Built-in RAM /CE is always high, preventing all reads and writes of the built-in RAM.
|||||||          Pin 5C66.28 = 0 at all address ranges.  (This pin normally n/c.)
+++++++--- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Refer also to $40C0.0 for built-in RAM enabling.

| Reference Data |
-
-
  -
  -
-
  -
  -
| Bench test found open bus when reading this register. JRA-PAT: Writes $00 to this register. Later writes $01 to this register. Super Mario Club: Writes $00 to this register. Later writes $01 to this register. |
$40B0 Yes No Yes RF5C66 Kanji Graphic ROM Control

```text
Write
76543210
|||||||+-- Kanji ROM Bank Select (POR value = 0)
+++++++--- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- All reads reset the Kanji auto-increment counter.
- D0 is written with 0 or 1 in Kanji graphics-loading code depending on the Kanji character index, changing the Kanji bank.
- For an unknown reason, RF5C66 registers can't be written on test setups. They only work in a real Famicom so far.

| Reference Data |
-
-
-
  -
  -
| Bench test found open bus when reading this register. Is read with BIT and results discarded before reading Kanji data out of $5000-5FFF. Super Mario Club: Stores X to this register after incrementing X (observed value $20). Reads this register and throws away the value read. |
$40B1 Unknown Yes Yes RF5C66 Modem Control

```text
Write
76543210
|||||||+-- Modem Module pin 29 = $40B1.0, rises slowly, goes low fast (POR value = 1)
||||||+--- Modem Module pin 32 = $40B1.1, rises slowly, goes low fast (POR value = 1)
|||||+---- Modem Module pin 31 = $40B1.2, rises slowly, goes low fast (POR value = 1)
||||+----- Pin 5C66.68: CPU2 Reset on new revision Famicom Network Systems (POR value = 1)
||||         CPU2 /Reset = !($40B1.3)
||||         CPU2 runs when $40B1.3 = 0.
||||         See also $40C0.2.
|||+------ Exp 15 = $40B1.4, rises slowly, goes low fast (POR value = 1)
||+------- Exp 14 = $40B1.5, rises slowly, goes low fast (POR value = 1)
|+-------- Exp 13 = $40B1.6, rises slowly, goes low fast (POR value = 1)
+--------- Exp 12 = $40B1.7, rises slowly, goes low fast (POR value = 1)

Read
76543210
|||||||+-- Input value of Modem Module pin 29
||||||+--- Input value of Modem Module pin 32
|||||+---- Input value of Modem Module pin 31
||||+----- Input value of 5C66 pin 63 (normally n/c)
|||+------ Input value of EXP 15
||+------- Input value of EXP 14
|+-------- Input value of EXP 13
+--------- Input value of EXP 12

```

| Reference Data |
-
-
  -
  -
  -
-
  -
  -
| Bench test observed value $FF with pull-downs. JRA-PAT: Writes $F7 to this register and appears to keep a RAM copy at $17. Later writes the value from $17, ORed with #$08. (Bit 3 being set to 1.) Also writes the value from $17, ANDed with #$F7. (Bit 3 being set to 0.) Super Mario Club: Writes $F7 to this register and appears to keep a RAM copy at $17. Later writes the value from $17, ORed with #$08. (Bit 3 being set to 1.) |
$40C0 Unknown Yes Yes RF5C66 CIC Status, CHR Bank, and RAM Control

```text
Write
76543210
|||||||+-- Pin 5C66.35 = $40C0.0 (POR value = 0)
|||||||      RAM +CE Enable (1 = enabled, 0 = disabled)
||||||+--- Pin 5C66.36 = $40C0.1 (POR value = 0)
||||||       (This pin normally n/c)
|||||+---- Pin 5C66.37 = $40C0.2 (POR value = 0)
|||||        Old Revision Famicom Network System: CPU2 /Reset (This pin n/c on newer revisions)
|||||        CPU2 runs on old revisions when $40C0.2 = 1.
|||||        See also $40B1.3.
||||+----- Pin 5C66.38 = $40C0.3 (POR value = 0)
||||         CHR RAM Bank Select (selects between two 8 KiB CHR RAM chips)
++++------ (unknown)

Read
76543210
|||||||+-- Input value of pin 5C66.31:
|||||||      From FNS CIC (Key) pin 10, or jumpered to GND on models without a CIC chip.
||||||+--- Input value of pin 5C66.32:
||||||       From FNS CIC (Key) pin 15, or jumpered to GND on models without a CIC chip.
|||||+---- Input value of pin 5C66.33:
|||||        CPU2 /Reset fed back in for all models, regardless which model-specific 5C66 pin is sending it out.
||||+----- Input value of pin 5C66.34:
||||         Selected CHR RAM Bank, fed back in from 5C66.38.
|+++------ (unlikely to exist)
+--------- Input value of pin 5C66.29:
             /CPU R/W Inhibit, from FNS CIC (Key) pin 11, or floating up to logic high on models without a CIC chip.
             1 = Writes to card, W-RAM, and $40Dx are allowed
             0 = Blocked (CPU R/W is overriden high, i.e. "read" for these writes)

```
- RAM +CE always reflects bit 0 of this register regardless of address space.
  - Refer also to $40AE.0 for built-in RAM enabling.
- All examined software waits for D7 = 1 at initialization.
- D7 is controlled by the CIC key chip, if present. If the CIC fails authentication, it latches to 0 until a power cycle.
- D1 and D0 always observed low in all cases, regardless if the model does not have CIC key chip, or does have the chip and authentication passes or fails.
  - It is unknown in what scenario that the CIC chip could generate logic high on these pins.
  - Theories:
    - These pins may reflect detection of different lock CIC chips in the tsuushin card, for different regions or "disk drive mode" or something like that.
    - Transient role at power-on, indicating when the CIC is ready.
    - Showing internal error state of the CIC.

| Reference Data |
-
-
  -
  -
-
  -
  -
  -
| Bench test observed value $00 with pull-downs, $70 with pull-ups. JRA-PAT: Writes to this register from what appears to be a RAM copy at $18 ORed with #$01. Also writes from $18 ANDed with #$FE. Super Mario Club: Writes $00 to this register and appears to keep a RAM copy at $18. Later writes the value from $18, ANDed with #$FB. (Bit 2 being set to 0.) Reads this register and makes a decision using D7. |
$40D0 Unknown Yes Yes RF5A18 Famicom CPU <-> CPU2 Interface, Data Byte 0

```text
Write
76543210
++++++++-- 8-bit value written here can be read by CPU2 from register $4123.

Read
76543210
++++++++-- 8-bit value read here was written by CPU2 to register $4123.

```

| Reference Data |
-
  -
  -
-
  -
| Super Mario Club: Does multiple writes of various values to this register when opening a connection. Reads this register when closing a modem connection, which reports value $80 and stores it at $701. Writing a value to this register does not cause the read value to change. This shows that Famicom -> CPU2 and CPU2 -> Famicom directions each use separate physical registers. |
$40D1 Unknown Yes Yes RF5A18 Famicom CPU <-> CPU2 Interface, Data Byte 1

```text
Write
76543210
++++++++-- 8-bit value written here can be read by CPU2 from register $4124.

Read
76543210
++++++++-- 8-bit value read here was written by CPU2 to register $4124.

```

| Reference Data |
-
  -
  -
-
  -
| Super Mario Club: Does multiple writes of various values to this register when opening a connection. Reads this register when closing a modem connection, which reports value $01 and stores it at $702. Writing a value to this register does not cause the read value to change. This shows that Famicom -> CPU2 and CPU2 -> Famicom directions each use separate physical registers. |
$40D2 Unknown Yes Yes RF5A18 Famicom CPU <-> CPU2 Interface, Data Byte 2

```text
Write
76543210
++++++++-- 8-bit value written here can be read by CPU2 from register $4125.

Read
76543210
++++++++-- 8-bit value read here was written by CPU2 to register $4125.

```

| Reference Data |
-
  -
  -
-
  -
| Super Mario Club: Does multiple writes of various values to this register when opening a connection. Reads this register when closing a modem connection, which reports value $00 and stores it at $703. Writing a value to this register does not cause the read value to change. This shows that Famicom -> CPU2 and CPU2 -> Famicom directions each use separate physical registers. |
$40D3 Unknown Yes Yes RF5A18 Famicom CPU <-> CPU2 Interface, Data Acknowledge

```text
Write
76543210
|||+++++-- (unknown)
+++------- 3-bit value written here can be read by CPU2 from register $4122.

Read
76543210
|||+++++-- (unlikely to exist)
+++------- 3-bit value read here was written by CPU2 to register $4122.

```

| Reference Data |
-
-
  -
  -
    -
  -
  -
-
-
  -
| JRA-PAT writes $FF to this register and appears to keep a RAM copy at $19. Super Mario Club: Writes $FF to this register and appears to keep a RAM copy at $19. Does a BIT operation on this register and makes decisions based on D7 and D6. Probably the same: Reads this register once per frame, which reports value $E0. Also writes value $BF to this register, not in connection with $19. Does multiple writes of various values to this register when opening and closing a connection. Bits 4,3,2,1,0 follow pull-ups and downs on the data bus. Writing a value to this register does not cause the read value to change. This shows that Famicom -> CPU2 and CPU2 -> Famicom directions each use separate physical registers. |
$40D4 Unknown Yes Yes RF5A18 Tone Rx and Expansion I/O Control

```text
Write
76543210
|||||||+-- RF5A18 Pin 65 (Exp 17) = $40D4.0 (open-drain)
||||||+--- RF5A18 Pin 67 (Exp 19) = $40D4.1 (push-pull)
|||||+---- RF5A18 Pin 66 (Exp 18) = $40D4.2 (open-drain)
+++++----- (unknown)

Read
76543210
|||||||+-- $40D4.0 = I/O value of RF5A18 Pin 65 (Exp 17)
||||||+--- $40D4.1 = output value of RF5A18 Pin 67 (Exp 19)
|||||+---- $40D4.2 = I/O value of RF5A18 Pin 66 (Exp 18)
||||+----- $40D4.3 = input value of RF5A18 Pin 69 (Tone Rx D1)
|||+------ $40D4.4 = input value of RF5A18 Pin 70 (Tone Rx D2)
||+------- $40D4.5 = input value of RF5A18 Pin 71 (Tone Rx D4)
|+-------- $40D4.6 = input value of RF5A18 Pin 72 (Tone Rx D8)
+--------- $40D4.7 = input value of RF5A18 Pin 73 (Tone Rx DV)

```

| Reference Data |
-
-
-
-
| JRA-PAT writes $FF to this register and appears to keep a RAM copy at $1A. Super Mario Club writes $FF to this register and appears to keep a RAM copy at $1A. Bits 7,6,5,4,3 read back as always 0 when writing inverting values to these bits. Bits 2,1,0 read back with the same value that was written. |
$40D5 Unknown Yes Unknown RF5A18 Clocks

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
||++++++-- Bits exist but function is unknown
++-------- (unlikely to exist)

```
- The purpose is unknown but it could potentially serve to generate random numbers.
  - The Famicom CPU and CPU2 have separate clocks and are asynchronous, making the value read especially random.
- Bit 5 is a 0.05% duty square wave, measured 1.200kHz (19.6608MHz CPU2 crystal / 16384)
  - Negative pulse width measures 406 nsec, the same as period of bit 2.
- Bit 4 is a 50% duty square wave, depending on $4114.1 and $4114.0:
  - (0,0) measured 19.20kHz (19.6608MHz CPU2 crystal / 1024)
  - (0,1) measured 38.40kHz (19.6608MHz CPU2 crystal / 512)
  - (1,0) measured 76.80kHz (19.6608MHz CPU2 crystal / 256)
  - (1,1) measured 153.6kHz (19.6608MHz CPU2 crystal / 128)
- Bit 3 is a 50% duty square wave, measured 307.3kHz (19.6608MHz CPU2 crystal / 64)
- Bit 2 is a 50% duty square wave, measured 2.451MHz (19.6608MHz CPU2 crystal / 8)
- Bit 1 is a 50% duty square wave, measured 4.902MHz (19.6608MHz CPU2 crystal / 4)
  - This bit toggles at the same rate as RF5A18 pin 42, though there is a 129.9 degree phase difference.
- Bit 0 is a 50% duty square wave, measured 9.804MHz (19.6608MHz CPU2 crystal / 2)
- The phasing of these signals do not line up nicely but they do stay in perfect sync with CPU2 M2.

| Reference Data |
-
  -
  -
-
| $40Dx registers can be monitored in real-time by statically giving the RF5A18 the bus signals for a read from this register. M2 = 1, Card R/W (i.e. buffered CPU R/W) = 1, Famicom /CE = 0, CPU A0,A1,A2 = x,x,x Unimplemented bits will latch the Famicom data bus's last value when toggling M2. Bits 7,6 follow pull-ups and downs on the data bus. |
$40D6 Unknown Yes Unknown RF5A18 UART Status

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- Bit exists but function is unknown
||||||+--- $40D6.1 = !($4112.0) read by CPU2.  (0 = $4110 UART Rx buffer has a byte ready to be read.)
|||||+---- $40D6.2 = !($4112.1) read by CPU2.  (0 = $4110 UART Tx buffer can be written.)
||||+----- $40D6.3 = !($4113.1 OR $4113.2) written by CPU2.
|||+------ $40D6.4 = !($4113.7) written by CPU2.  (1 = Transmit repeat.)
||+------- $40D6.5 = !($4113.6) written by CPU2.
++-------- (unlikely to exist)

```

$40D6.2 previously observed to equal !($4113.7 AND $4112.1) written by CPU2. It was later discovered that this bit also follows the $4112.1 read value (Tx buffer ready), which makes a lot more sense being beside $40D6.1 (Rx buffer ready). The previous observation can be explained because writing to those CPU2 bits both likely changed the availability of the Tx buffer.

| Reference Data |
-
-
-
| Bits 7,6 follow pull-ups and downs on the data bus. Bit 0 only ever observed with value 1 regardless of various techniques writing to lots of CPU2 registers. Writing a value to this register does not seem to cause its own read value to change. |
RF5A18 Internal 65C02 CPU

The RF5A18 contains its own CPU, termed "CPU2" on this page. It is a 65C02 supporting bitwise set/clear/branch instructions. Note that CPU2 has its own parallel execution with its own address and data busses that are not available to the Famicom's CPU. CPU2 also has its own clock source, so it does not execute synchronously with the Famicom CPU. CPU2 clock speed is 2.4576 MHz (19.6608 MHz crystal / 8). This section describes CPU2's own memory mapping and its own internal registers.

CPU2 /Reset is controlled 2 different ways depending on the revision of Famicom Network System. To support all revisions when enabling CPU2, both of these bits should be written:
- $40B1.3 = 0 (new revisions Famicom Network System, and old revisions with J1 closed)
- $40C0.2 = 1 (old revisions Famicom Network System with J2 closed)

## CPU2 Memory Map

### RF5A18 Pin 26 Low (default)

```text
+================+ $0000
| CPU2 RAM       |
| (U6)           |
+================+ $2000
|   (Returns     |
|   last fetch)  |
+================+ $4100
| CPU2 Control   |
| Registers      |
+================+ $4140
|   (Returns     |
|   last fetch)  |
+================+ $C000
| External ROM   |
| (not used)     |
+================+ $E000
| RF5A18         |
| Internal ROM   |
+================+ $10000

```

### RF5A18 Pin 26 High

```text
+================+ $0000
| CPU2 RAM       |
| (U6)           |
+================+ $2000
|   (Returns     |
|   last fetch)  |
+================+ $4100
| CPU2 Control   |
| Registers      |
+================+ $4140
|   (Returns     |
|   last fetch)  |
+================+ $C000
|                |
|                |
| External ROM   |
|                |
|                |
+================+ $10000

```

## CPU2 Known Registers

| Address | ReadHasEffect | ReadHasData | Write | Function |

```text

```
-
  -
-

| Reference Data |
-
  -
-
-
-
  -
    -
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. When tone dialing, the digit length is $0078 (~100ms) and the inter-digit gap is $0046 (~60ms). Slow pulse dialing uses on-hook pulses of $004f (~67ms) and off-hook gaps of $0027 (~33ms) and the inter-digit gap is $031e (~666ms). Fast pulse dialing uses on-hook pulses of $0027 (~33ms) and off-hook gaps of $0013 (~17ms) and the inter-digit gap is $027e (~533ms). The times are approximate and assume a 1200Hz clock source, but the actual clock source is unknown. Theory: 19.6608MHz RF5A18 crystal / 2^14 = 1200Hz. |
$4101 No No Yes NMI Timer 1 Period, high byte.

```text
Write
76543210
++++++++-- NMI timer 1 period high byte.

Read
76543210
++++++++-- (does not exist)

```
- Time (seconds) * 1200 = 16-bit timer 1 register value.
  - 1 count = 2048 CPU cycles.
- This is the MSB of the 16-bit period. Refer to $4100 for the LSB.

| Reference Data |
-
  -
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. |
$4102 No No Yes NMI Timer 1 Restart.

```text
Write
76543210
|||||||+-- $4102.0 = timer 1 loop.  1 = Loop, 0 = One-Shot
||||||+--- $4102.1 = timer 1 restart.  1 = Restart.
++++++---- (unknown)

Read
76543210
++++++++-- (does not exist)

```
- When setting bit 1 = 1, timer 1 restarts with the period specified in $4100, $4101.
- The values of $4100, $4101 are not affected by running timer 1 and need not be rewritten each time.
- NMI will be generated when timer 1 expires if $412F.0 = 1.
- The behavior is untested when setting bits 0 or 1 = 1 while timer 1 is already running.

| Reference Data |
-
  -
-
-
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $E136 writes value #$02 to this address. ROM $F3D6 writes value #$00 to this address (initialization). ROM $F840 writes value #$00 to this address (Famicom command $61). |
$4103 Yes Yes Unknown NMI Timer 1 Acknowledge.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- $4103.0 = Timer 1 NMI flag.  1 = Timer 1 NMI triggered.
+++++++--- (does not exist)

```
- Reading from this register likely acknowledges timer 1 NMI.
- The read value of $4103.0 reflects the timer 1 NMI flag, but does not reflect external NMI via pin 29.

| Reference Data |
-
  -
  -
  -
  -
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $40. ($41 XOR $40 = $01 existence mask) Value $40 from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $BE. ($BF XOR $BE = $01 existence mask) $01 OR $01 = $01 accumulated existence mask. ROM $E825 reads from this register at the beginning of the NMI handler and throws away the value. ROM $F3D9 reads from this register during initialization and throws away the value. |
$4104 No No Yes IRQ Timer 2 Period, low byte.

```text
Write
76543210
++++++++-- IRQ timer 2 period low byte.

Read
76543210
++++++++-- (does not exist)

```
- Time (seconds) * 2,457,600 = 16-bit timer 2 register value.
  - 1 count = 1 CPU cycle.
- This is the LSB of the 16-bit period. Refer to $4105 for the MSB

| Reference Data |
-
  -
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $F415 writes value #$FD to this address. |
$4105 No No Yes IRQ Timer 2 Period, high byte.

```text
Write
76543210
++++++++-- IRQ Timer 2 Period, high byte.

Read
76543210
++++++++-- (does not exist)

```
- Time (seconds) * 2,457,600 = 16-bit timer 2 register value.
  - 1 count = 1 CPU cycle.
- This is the MSB of the 16-bit period. Refer to $4104 for the LSB

| Reference Data |
-
  -
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $F410 writes value #$2F to this address. |
$4106 No No Yes IRQ Timer 2 Restart.

```text
Write
76543210
|||||||+-- $4106.0 = timer 2 loop.  1 = Loop, 0 = One-Shot
||||||+--- $4106.1 = timer 2 restart.  1 = Restart.
++++++---- (unknown)

Read
76543210
++++++++-- (does not exist)

```
- Theory: When setting bit 1 = 1, timer 2 restarts with the period specified in $4100, $4101.
- Theory: The values of $4104, $4105 are not affected by running timer 2 and need not be rewritten each time.
- IRQ will be generated when timer 2 expires if $412F.6 = 1.
- The behavior is untested when setting bits 0 or 1 = 1 while timer 2 is already running.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $F3DE writes value #$00 to this address. ROM $F41A writes value #$03 to this address. |
$4107 Yes Yes Unknown IRQ Timer 2 Acknowledge.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- (unlikely to exist)
||||||+--- Likely to be the Timer 2 IRQ flag
++++++---- (unlikely to exist)

```
- Reading from this register likely acknowledges timer 2 IRQ.
- $4107.1 is probably the timer 2 IRQ flag.

| Reference Data |
-
  -
  -
-
-
| Read Bit Existence: Value $41 and $40 from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $BD. ($BF XOR $BD = $02 existence mask) ROM $E78A reads from this register directly after seeing IRQ flag $412F.6 and throws away the value. ROM $F3E1 reads from this register during initialization and throws away the value. |
$4110 Yes Yes Yes UART Rx/Tx Data Buffer

```text
Write
76543210
++++++++-- UART Tx Data Byte
             Bits 7:0 in 8-bit mode, bits 6:0 in 7-bit mode

Read
76543210
++++++++-- UART Rx Data Byte
             Bits 7:0 in 8-bit mode, bits 6:0 in 7-bit mode

```
- Writing a byte to this register automatically clears $4112.1 read value and triggers the byte to be sent on UART Tx.
- Reading a byte from this register automatically clears $4112.0 read value, to be triggered high again next byte received on UART Rx.
- This UART is connected to the MSM6827L TXD and RXD pins.
- The byte is ready to read here when the IRQ flag $4112.0 is high.
- The byte is ready to be written here when flag $4112.1 is high.
- Writes to $4110 are specifically prevented by built-in ROM in modes 0 and 5.
- Bench testing confirmed reads and writes of this register correspond to data read by UART Rx and written to UART Tx.
  - In 7-bit mode, Rx bit 7 (unused in this case) observed to be 0 but not confirmed always to be 0.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $41 from previous fetch also observed changed to $00. ($41 XOR $00 = $41 existence mask) Value $40 from previous fetch observed changed to $00. ($40 XOR $00 = $40 existence mask) Value $BF from previous fetch observed changed to $00. ($BF XOR $00 = $BF existence mask) $BE OR $41 OR $40 OR $BF = $FF accumulated existence mask. ROM $E69B reads from this address inside of an IRQ handler, seemingly caused by its own IRQ, with flag at $4112.0. ROM $E72F writes to this address inside of an IRQ handler, which may have been caused by timer 2. ROM $E754 writes to this address inside of an IRQ handler, which may have been caused by timer 2. |
$4111 Unknown Yes Yes UART Configuration

```text
Write
76543210
|||||||+-- $4111.0 = UART Rx Enable (1 = enabled)
||||||+--- $4111.1 = UART Tx Enable (1 = enabled)
|||||+---- $4111.2 = Baudrate Scaler (0 = multiply baudrate x4)
||||+----- $4111.3 = Data bits (0 = 7 bits, 1 = 8 bits)
|||+------ $4111.4 = Tx Stop bits (0 = 1 stop bit, 1 = 2 stop bits)
||+------- $4111.5 = Parity bit (0 = don't use, 1 = append parity bit)
|+-------- $4111.6 = Parity type (0 = odd parity, 1 = even parity)
+--------- $4111.7 = Send Tx Break (1 = force UART Tx low (break), 0 = normal)

Read
76543210
++++++++-- Reads back the value written.

```
- See register $4114 for baudrate table.
- Confirmed write bits 2,3,5,6 apply to both Rx and Tx.
- Write bit $4111.4 confirmed not to enforce 2 stop bits for UART Rx.
  - Consecutive Rx bytes with 1 stop bit separation can still be received when $4111.4 = 1.
- Write bit $4111.7 requires manual operation to send a break character and has no effect on Rx operation.

| Reference Data |
-
  -
  -
  -
  -
-
  -
  -
  -
  -
  -
-
-
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $00. ($41 XOR $00 = $41 existence mask) Value $40 from previous fetch observed changed to $00. ($40 XOR $00 = $40 existence mask) Value $BF from previous fetch observed changed to $00. ($BF XOR $00 = $BF existence mask) $41 OR $40 OR $BF = $FF accumulated existence mask. The built-in ROM function at $E1BC determines the UART settings to be written to this register. Clears bits 0,1,7. Sets bit 2 (slow baudrate scaler). Figures out bits 3,4,5,6 (UART bits/parity settings). Returns that $4111 value in accumulator A. Also sets baudrate to 1200 bits/sec by writing to $4114 before returning. ROM $E151 runs $E1BC, sets bits [1,0] = 0,0, and writes it to this register. ROM $ECE3 runs $E1BC, sets bits [1,0] = 1,1, and writes it to this register. ROM $ED20 runs $E1BC, sets bits [1,0] = 0,1, and writes it to this register. ROM $ED4E reads from this address, OR's it with #$03 (i.e. sets bits [1,0] = 1,1), and writes it back to this register. ROM $EE83 runs $E1BC, sets bits [1,0] = 0,1, and writes it to this register. ROM $F0E8 reads from this address, AND's it with #$FE (i.e. clears bit 7), and writes it back to this register. ROM $F2DC runs $E1BC, sets bits [1,0] = 0,1, and writes it to this register. |
$4112 Unknown Yes Yes UART Status

```text
Write
76543210
|||||||+-- Bit exists but function is unknown
||||||+--- $4112.1: Tx Silence
||||||       0 = Set UART Tx directly high (idle state), 1 = Allow sending data.
||||||       This bit figures into $40D6.2 read by the Famicom. (See register $40D6.)
|+++++---- (unknown)
+--------- $4112.7 = $4110 UART Rx Data IRQ Acknowledge, 1 = Acknowledge IRQ.

Read
76543210
|||||||+-- $4112.0 = $4110 UART Rx Buffer Ready Flag (1 = $4110 buffer has a byte ready to be read.)
||||||+--- $4112.1 = $4110 UART Tx Buffer Ready Flag (1 = $4110 buffer can be written.)
|||||+---- $4112.2 = UART Tx Idle, 1 = Idle, 0 = Active.
||||+----- Bit exists but function is unknown
|||+------ $4112.4 = Rx Parity Error. (1 = error detected)
||+------- $4112.5 = Rx Framing Error. (1 = error detected)
|+-------- $4112.6 = Rx Break Received. (1 = break detected)
+--------- Bit exists but function is unknown

```
- Error and Break bits persist through $4110 operations, but can be cleared by writing 1 to $4112.7.
- Found $4112.4 read became 1 when setting in parity mode ($4111.5 = 1) and injecting a wrong parity bit.
  - Confirmed this flag not getting set anymore with the same test when changing parity even/odd (i.e. inverted $4111.6).
- $4112.6 = 1 (break) comes accompanied with $4112.5 = 1 (framing error).

| Reference Data |
-
  -
  -
  -
  -
-
-
-
-
-
  -
-
-
-
-
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $04. ($41 XOR $04 = $45 existence mask) Value $40 from previous fetch observed changed to $04. ($40 XOR $04 = $44 existence mask) Value $BF from previous fetch observed changed to $04. ($BF XOR $04 = $BB existence mask) $45 OR $44 OR $BB = $FF accumulated existence mask. ROM implements a shadow read register at $0011. ROM implements a shadow write register at $0012. ROM $E159 writes value #$80 to this address when disconnecting. ROM $E4D8 reads from this address in the IRQ handler and uses bit 0. ROM $E4F9 writes to this address in the IRQ handler after having set bit 7 in its shadow register. If $4112.0 read = 1, it writes a 1 to $4112.7. ROM $ECDB writes value #$81 to this address. ROM $ED18 writes value #$81 to this address. ROM $ED4B writes value #$81 to this address. ROM $EE7B writes value #$81 to this address. ROM $F2D4 writes value #$81 to this address. ROM $E4F2 uses read bit 0. ROM $E67C uses read bit 5. ROM $E68E uses read bit 4. ROM $E703 uses read bit 1. |
$4113 Unknown Yes Yes UART Configuration

```text
Write
76543210
|||||||+-- (unknown)
||||||+--- $4113.1 figures into $40D6.3 read by the Famicom. (See register $40D6.)
|||||+---- $4113.2 figures into $40D6.3 read by the Famicom. (See register $40D6.)
||+++----- (unknown)
|+-------- $4113.6 figures into $40D6.5 read by the Famicom. (See register $40D6.)
+--------- $4113.7: Tx Repeat
             1 = Send once on pin 90 (UART Tx), 0 = Send repeatedly
             This figures into $40D6.2 and $40D6.4 read by the Famicom. (See register $40D6.)

Read
76543210
++++++++-- Bits exist but function is unknown

```

| Reference Data |
-
-
  -
  -
  -
  -
  -
-
-
-
-
-
-
-
-
| Writing to Bit 4 appeared to have an effect in some tests, apparently sending only 1 bit on the UART Tx, but this was not able to be reproduced in later tests. Read Bit Existence: Value $41 from previous fetch observed changed to $10. ($41 XOR $10 = $51 existence mask) Value $40 from previous fetch observed changed to $10. ($40 XOR $10 = $50 existence mask) Value $04 from previous fetch observed changed to $10. ($04 XOR $10 = $14 existence mask) Value $BF from previous fetch observed changed to $10. ($BF XOR $10 = $AF existence mask) $51 OR $50 OR $14 OR $AF = $FF accumulated existence mask. ROM implements a shadow write register at $0013. ROM $E161 writes value #$00 to this address. ROM $ECD3 writes value #$C0 to this address. ROM $ED11 writes value #$40 to this address. ROM $ED44 writes value #$C0 to this address. ROM $EE73 writes value #$40 to this address. ROM $F2CD writes value #$40 to this address. Bits 7 and 6 differ in these writes, suggesting that they exist. |
$4114 Unknown No Yes UART Baudrate

```text
Write
76543210
||||||++-- UART Baud Rate (Rx and Tx)
||||||       This is a clock divider that also affects frequency seen on $40D5.4.
++++++---- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Baud Rate Selection:

| $4111.2 | $4114.1 | $4114.0 | Baudrate |
| 0 | 0 | 0 | 1200 |
| 0 | 0 | 1 | 2400 |
| 0 | 1 | 0 | 4800 |
| 0 | 1 | 1 | 9600 |
| 1 | 0 | 0 | 300 |
| 1 | 0 | 1 | 600 |
| 1 | 1 | 0 | 1200 |
| 1 | 1 | 1 | 2400 |

| Reference Data |
-
  -
  -
  -
  -
-
-
  -
-
| $40D5.4 shows these frequencies depending on $4114 bits 1 and 0: (0,0) measured 19.20kHz (19.6608MHz CPU2 crystal / 1024) (0,1) measured 38.40kHz (19.6608MHz CPU2 crystal / 512) (1,0) measured 76.80kHz (19.6608MHz CPU2 crystal / 256) (1,1) measured 153.6kHz (19.6608MHz CPU2 crystal / 128) Note: $40D5.4 is not affected by $4111.2. Read Bit Existence: Values $41, $40, $FF, and $BF from previous fetch observed unaffected. ROM $E1DE writes value #$02 to this address. |
$4120 Unknown Yes Yes Unknown Function.

```text
Write
76543210
|||||||+-- Pin 39 (MSM6827L AD0) = $4120.0
||||||+--- Pin 38 (MSM6827L AD1) = $4120.1
|||||+---- Pin 37 (n/c) = $4120.2
||||+----- Pin 36 (MSM6827L /RD) = $4120.3
|||+------ Pin 35 (MSM6827L /WR) = $4120.4
||+------- Pin 34 (MSM6827L EXCLK) = $4120.5
|+-------- Pin 32 (MSM6827L Data): Direction = $4120.6: 1 = input, 0 = output (refer to $4121.0)
+--------- (unknown)

Read
76543210
|+++++++-- Bits exist but function is unknown
+--------- $4120.7 = Pin 33 (MSM6827L /INT)

```
- When pin 32 is set as input, it is unknown if or how the value can be read.
- Pin 32 floats in input mode, regardless of the value written to $4121.0.
- When pin 32 is set as output, it is a push-pull output.

| Reference Data |
-
  -
  -
  -
  -
-
  -
  -
  -
  -
  -
  -
  -
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BE OR $BF OR $40 = $FF accumulated existence mask. Sequence: ROM $E3BC writes value #$38 to this address. ROM $E3C7 writes value #$38 & #$DF = #$18 to this address. ROM $E3CC writes value #$18 | #$20 = #$38 to this address. ROM $E3D4 writes value #$38 & #$DF = #$18 to this address. ROM $E3D9 writes value #$18 & #$EF = #$08 to this address. ROM $E3DE writes value #$08 | #$10 = #$18 to this address. ROM $E3E3 writes value #$58 to this address. ROM $E3E9 writes value #$5A to this address. ROM $E3EE writes value #$52 to this address. ROM $E3F5 writes value #$72 to this address. ROM $E3FA writes value #$52 to this address. ROM $E402 writes value #$72 to this address. |
$4121 Unknown Yes Yes Unknown Function.

```text
Write
76543210
|||||||+-- Pin 32 (MSM6827L Data) = $4121.0 when set as output (refer to $4120.6)
+++++++--- (unknown)

Read
76543210
++++++++-- Bits exist but function is unknown

```
- Reading $4121.0 reflects the value written to $4121.0 when $4120.6 is set as output.
- Surprisingly, reading $4121.0 is always 1 when $4120.6 is set as input regardless of:
  - Driving pin 32 high or low.
  - Writing 1 or 0 to $4121.0.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BE OR $BF OR $40 = $FF accumulated existence mask. ROM $E3BF writes to this address. ROM $E405 reads this address. |
$4122 Unknown Yes Yes Famicom CPU <-> CPU2 Interface, Data Acknowledge

```text
Write
76543210
|||+++++-- (unlikely to exist)
+++------- 3-bit value written here can be read by Famicom CPU from register $40D3.

Read
76543210
|||+++++-- (unlikely to exist)
+++------- 3-bit value read here was written by Famicom CPU to register $40D3.

```
- Read and write directions are represented by separate physical registers.
- The read value can only be affected by the Famicom CPU.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $E1. ($41 XOR $E1 = $A0 existence mask) Value $40 from previous fetch observed changed to $E0. ($40 XOR $E0 = $A0 existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $A0 OR $A0 OR $40 = $E0 accumulated existence mask. ROM $F3E6 writes value #$FF to this address. ROM $FA70 writes value #$E0 to this address. ROM $FA78 writes value #$E0 to this address. ROM $FA89 reads this address using BIT operation and uses BMI, indicating bit 7 used. ROM $FAA7 reads this address using BIT operation and uses BPL, indicating bit 7 used. ROM $FAB4 reads this address and checks if bits 7 and 6 both = 1. ROM $FABF writes #$40 to this address, reads it right back, and checks if bits 7 and 6 both = 1. ROM $FACF writes value #$20 to this address. ROM $FAF3 writes value #$A0 to this address. ROM $FB00 writes value #$20 to this address. ROM $FB0D writes value #$A0 to this address. ROM $FB15 writes value #$E0 to this address. ROM $FB1D writes value #$20 to this address. ROM $FB25 writes value #$E0 to this address. ROM $FB8F writes value #$E0 to this address. ROM $FC02 writes value #$E0 to this address. ROM $FC13 reads this address using BIT operation and uses BMI, indicating bit 7 used. ROM $FC2D reads this address using BIT operation and uses BPL, indicating bit 7 used. ROM $FC3A reads this address and checks if bits 7 and 6 both = 1. ROM $FC43 writes value #$60 to this address. ROM $FC69 writes value #$E0 to this address. ROM $FC76 writes value #$60 to this address. ROM $FC83 writes value #$E0 to this address. ROM $FC8D reads this address using BIT operation and uses BPL and BVC, indicating bits 7 and 6 are used. ROM $FC96 writes value #$E0 to this address. ROM $FCA4 writes value #$60 to this address. |
$4123 Unknown Yes Yes Famicom CPU <-> CPU2 Interface, Data Byte 0

```text
Write
76543210
++++++++-- 8-bit value written here can be read by Famicom CPU from register $40D0.

Read
76543210
++++++++-- 8-bit value read here was written by Famicom CPU to register $40D0.

```
- Read and write directions are represented by separate physical registers.
- The read value can only be affected by the Famicom CPU.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BE OR $BF OR $40 = $FF accumulated existence mask. ROM $F3E9 writes value #$FF to this address. ROM $FAD9 writes to this address. ROM $FB32 writes to this address. ROM $FC49 reads from this address. ROM $FCAE reads from this address. |
$4124 Unknown Yes Yes Famicom CPU <-> CPU2 Interface, Data Byte 1

```text
Write
76543210
++++++++-- 8-bit value written here can be read by Famicom CPU from register $40D1.

Read
76543210
++++++++-- 8-bit value read here was written by Famicom CPU to register $40D1.

```
- Read and write directions are represented by separate physical registers.
- The read value can only be affected by the Famicom CPU.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BE OR $BF OR $40 = $FF accumulated existence mask. ROM $F3EC writes value #$FF to this address. ROM $FADF writes to this address. ROM $FB38 writes to this address. ROM $FC55 reads from this address and checks if it equals $00, indicating all bits exist. ROM $FCB5 reads from this address. |
$4125 Unknown Yes Yes Famicom CPU <-> CPU2 Interface, Data Byte 2

```text
Write
76543210
++++++++-- 8-bit value written here can be read by Famicom CPU from register $40D2.

Read
76543210
++++++++-- 8-bit value read here was written by Famicom CPU to register $40D2.

```
- Read and write directions are represented by separate physical registers.
- The read value can only be affected by the Famicom CPU.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BE OR $BF OR $40 = $FF accumulated existence mask. ROM $F3EF writes value #$FF to this address. ROM $FAE7 writes to this address. ROM $FB3E writes to this address. ROM $FC4F reads from this address. ROM $FCBC reads from this address. |
$4126 Unknown Yes Unknown Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- $4126.0 = Pin 47 (+5V)
||||||+--- $4126.1 = !(Pin 48) (+5V)
|||||+---- $4126.2 = Pin 49 (from 5C66-69)
||||+----- $4126.3 = Pin 51 (Switch SW1-2)
|||+------ $4126.4 = Pin 52 (Switch SW1-4)
||+------- $4126.5 = Pin 53 (Modem P4-25)
|+-------- $4126.6 = Pin 54 (Modem P4-28)
+--------- $4126.7 = Pin 55 (Modem P4-23)

```
- SW1 selects between pulse and DTMF dialing.

| Reference Data |
-
  -
  -
  -
  -
  -
  -
-
-
-
-
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $FB. ($41 XOR $FB = $BA existence mask) Value $41 from previous fetch also observed changed to $FF. ($41 XOR $FF = $BE existence mask) Value $40 from previous fetch observed changed to $FF. ($40 XOR $FF = $BF existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $BA OR $BE OR $BF OR $40 = $FF accumulated existence mask. ROM $E482 reads this address and checks Bit 2. ROM $E7BC reads this address and checks Bits 7 and 6. ROM $E886 reads this address and checks Bits 7 and 6. ROM $E8DC reads this address. ROM $E8FC reads this address and checks Bits 7 and 6. ROM $E9C0 reads this address. ROM $EBAB reads this address and checks Bits 7 and 6. ROM $F1B6 reads this address. ROM $F4F2 reads this address. |
$4127 Unknown No Yes Unknown Function.

```text
Write
76543210
|||||||+-- Pin 56 MSM6827L +Reset = $4127.0
||||||+--- Pin 57 /Red LED = $4127.1
|||||+---- Pin 58 /Green LED = $4127.2
||||+----- Pin 59 (n/c) = $4127.3
|||+------ Pin 60 /Phone Off Hook = $4127.4
||+------- Pin 61 /DTMF Output Enable = $4127.5
|+-------- Pin 62 /Phone Audio Enable = $4127.6
+--------- Pin 63 (Modem P4-19) = $4127.7

Read
76543210
++++++++-- (unlikely to exist)

```
- Pin 60 observed low corresponding to off hook and pulse dialing pulses.
- Pin 61 observed low for the duration of DTMF numbers being dialed, but not in pulse mode.
- Pin 62 observed low corresponding to modem sounds coming through the TV speakers.
- Pin 63 observed always high.

| Reference Data |
-
  -
-
-
-
-
-
-
-
-
-
-
| Read Bit Existence: Values $41, $40, $FF, and $BF from previous fetch observed unaffected. ROM implements a shadow write register at $0014. ROM $E237 writes the shadow register $0014 to this register, modified bit 6 (/Phone Audio Enable). ROM $E24D writes the shadow register $0014 to this register, modified bit 7 (Modem P4-19). ROM $E263 writes the shadow register $0014 to this register, modified bit 4 (/Phone Off Hook). ROM $E27D writes the shadow register $0014 to this register, modified bit 1 (/Red LED). ROM $E29A writes the shadow register $0014 to this register, modified bit 2 (/Green LED). ROM $E3B0 writes the shadow register $0014 to this register, modified bit 5 (/DTMF Output Enable). ROM $E987 writes the shadow register $0014 to this register, modified bit 4 (/Phone Off Hook). ROM $EA83 writes the shadow register $0014 to this register, modified bit 4 (/Phone Off Hook). ROM $F3BF writes value #$FF directly to this register, then clears bit 0 with value #$FE via the shadow register $0014. |
$4128 Unknown Yes Yes Unknown Function.

```text
Write
76543210
|||||||+-- Pin 68 (Tone Rx GT) = $4128.0
+++++++--- (unknown)

Read
76543210
|||||+++-- (unlikely to exist)
||||+----- $4128.3 = Pin 69 (Tone Rx D1)
|||+------ $4128.4 = Pin 70 (Tone Rx D2)
||+------- $4128.5 = Pin 71 (Tone Rx D4)
|+-------- $4128.6 = Pin 72 (Tone Rx D8)
+--------- $4128.7 = Pin 73 (Tone Rx DV)

```

| Reference Data |
-
  -
  -
  -
  -
  -
  -
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $01. ($41 XOR $01 = $40 existence mask) Value $41 from previous fetch also observed changed to $F9. ($41 XOR $F9 = $B8 existence mask) Value $40 from previous fetch observed changed to $F8. ($40 XOR $F8 = $B8 existence mask) Value $FF from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $FF. ($BF XOR $FF = $40 existence mask) $40 OR $B8 OR $B8 OR $40 = $F8 accumulated existence mask. ROM $E599 reads from this address. ROM $E5BB reads from this address and uses bits 3,4,5,6. ROM $F3F7 writes value #$00 to this address. |
$4129 Unknown Unknown Yes P5 Expansion Port

```text
Write
76543210
||||++++-- Data nybble written to device attached to P5 connector.
||++------ Used for sequencing writes to the device.
++-------- (unknown)

Read
76543210
||++++++-- Controlled by device attached to P5 connector, though the ROM code never reads it.
++-------- Not used

```
- The data bus floats when reading this register, presumably to be driven by a device connected to P5.
- Pin 23 is a /CE low when writing to this register (untested for reads).
- Data bits 6 and 7 are not available in the P5 connector.

| Reference Data |
-
  -
  -
  -
  -
  -
-
  -
  -
  -
| Read Bit Existence: Value $41 from previous fetch observed changed to $FF with pull-ups on data bus. Value $41 from previous fetch observed changed to $00 with pull-downs on data bus. Value $41 from previous fetch observed changed to $BF, when data bus configured with pull-ups and -downs to make $BF. Value $40 from previous fetch observed changed to $BF, when data bus configured with pull-ups and -downs to make $BF. Value $FF from previous fetch observed changed to $BF, when data bus configured with pull-ups and -downs to make $BF. Sequence: ROM $E4B6 writes a value to this address. ROM $E4BB writes previous value again, OR'd with #$10. ROM $E4C0 writes previous value again, AND'd with #$2F. |
$412F Unknown Yes Yes Unknown Function.

```text
Write
76543210
|||||||+-- $412F.0 = Timer 1 NMI enable.  1 = Enabled.
||||+++--- (unknown)
|||+------ $412F.4 = Pin 33 (MSM6827L /INT) IRQ enable. 1 = Enabled.
||+------- $412F.5 = Pin 73 (Tone Rx DV) IRQ enable.  1 = Enabled.
|+-------- $412F.6 = Timer 2 IRQ enable.  1 = Enabled.
+--------- $412F.7 = UART Rx IRQ enable.  1 = Enabled.

Read
76543210
|||||||+-- Bit exists but function is unknown
|||||++--- (unlikely to exist)
||||+----- Bit exists but function is unknown
|||+------ $412F.4 = !(Pin 33) (MSM6827L /INT)
||+------- $412F.5 is set when IRQ is triggered by writing 1 to $412F.5.
||           This is probably the Tone Rx DV interrupt flag.
|+-------- $412F.6 is an IRQ flag.  1 = IRQ pending.
+--------- Bit exists but function is unknown

```
- ROM tends to clear $412F.0 immediately after disabling interrupts with SEI, and sets it right before enabling with CLI.
  - The ROM is apparently disabling/enabling both IRQs and the timer NMI this way.
- None of the write bits in this register prevent external NMI generated from pin 29 low.
- None of the write bits prevent exteral IRQ generated from pin 28 low either.
- Pin 33 (MSM6827L /INT) low triggers interrupt.
- Pin 73 (Tone Rx DV) high triggers interrupt.

| Reference Data |
-
  -
  -
  -
  -
  -
-
-
-
-
-
-
-
-
-
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $08. ($41 XOR $08 = $49 existence mask) Value $41 from previous fetch also observed changed to $20. ($41 XOR $20 = $61 existence mask) Value $40 from previous fetch observed changed to $20. ($40 XOR $20 = $60 existence mask) Value $BF from previous fetch observed changed to $26. ($BF XOR $26 = $99 existence mask) $49 OR $61 OR $60 OR $99 = $F9 accumulated existence mask. ROM implements a shadow read register at $0015. ROM implements a shadow write register at $0016. ROM $E31C clears bit 0 of this register. ROM $E33B writes to this address, setting bit 0 to 1. ROM $E4D3 reads from this address in the IRQ handler and uses bit 6. ROM $F377 writes value #$00 to this address. ROM $F40A writes value #$C1 to this address. ROM $F4E1 writes value #$00 to this address. ROM $F4E9 writes the shadow register to this address. ROM $F99C writes value #$00 to this address. Bits 7, 6, and 0 differ in values written, suggesting that they exist. |
$4130 Unknown No Yes Unknown Function.

```text
Write
76543210
|||||||+-- Serial bit to be written
+++++++--- (unknown, unlikely to exist)

Read
76543210
++++++++-- (unlikely to exist)

```
- The buffer at RAM $0330 is written to this register 1 bit at a time, seemingly using only bit 0 of the register.
- The most significant bit of each byte is sent first.
- 40 bytes are sent from $0330, then only the 6 most significant bits of the 41st byte.
  - A total of 326 bits are sent to this register.
- Note: CPU2 commands $10 and $11 fill this buffer.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, $26, and $BF from previous fetch observed unaffected. ROM $FF2D writes to this address. ROM $FF40 writes to this address. |
$4131 Unknown No Yes Unknown Function.

```text
Write
76543210
|||||||+-- Serial bit to be written
+++++++--- (unknown, unlikely to exist)

Read
76543210
++++++++-- (unlikely to exist)

```
- The buffer at RAM $0360 is written to this register 1 bit at a time, seemingly using only bit 0 of the register.
- The most significant bit of each byte is sent first.
- 40 bytes are sent from $0360, then only the 6 most significant bits of the 41st byte.
  - A total of 326 bits are sent to this register.
- Note: CPU2 commands $10, $11, and $6A fill this buffer.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $FF51 writes to this address. ROM $FF64 writes to this address. |
$4132 Unknown No Yes Unknown Function.

```text
Write
76543210
|||||||+-- Serial bit to be written
+++++++--- (unknown, unlikely to exist)

Read
76543210
++++++++-- (unlikely to exist)

```
- The buffer at RAM $0390 is written to this register 1 bit at a time, seemingly using only bit 0 of the register.
- The most significant bit of each byte is sent first.
- 40 bytes are sent from $0390, then only the 6 most significant bits of the 41st byte.
  - A total of 326 bits are sent to this register.
- Note: CPU2 commands $10, $11, and $6A fill this buffer.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $FF75 writes to this address. ROM $FF88 writes to this address. |
$4133 Unknown No Yes Unknown Function.

```text
Write
76543210
|||||||+-- Serial bit to be written
+++++++--- (unknown, unlikely to exist)

Read
76543210
++++++++-- (unlikely to exist)

```
- The buffer at RAM $0320 is written to this register 1 bit at a time, seemingly using only bit 0 of the register.
- The most significant bit of each byte is sent first.
- 4 bytes are sent from $0320, then only the 4 most significant bits of the 5th byte.
  - A total of 36 bits are sent to this register.
- Note: CPU2 commands $10 and $11 fill this buffer.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, and $BF from previous fetch observed unaffected. ROM $FF99 writes to this address. ROM $FFAC writes to this address. |
$4134 Yes Yes Unknown Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- Bit exists but function is unknown
+++++++--- (unlikely to exist)

```
- This register has serial data that can be read 1 bit at a time from $4134.0.
  - Without any other register reads/writes, the next bit is provided the next time this register is read.
- In each byte read, the most significant bit comes first.
- CPU2 built-in ROM reads 40 bytes this way and stores them starting at RAM $03C0.
  - Then 6 additional bits are read and stored as the 41st byte bits 7:2, and 0 for bits 1:0.

| Reference Data |
-
  -
  -
  -
  -
-
-
| Read Bit Existence: Value $41 from previous fetch observed changed to $40. ($41 XOR $40 = $01 existence mask) Value $40 from previous fetch observed unaffected. Value $BF from previous fetch observed changed to $BE. ($BF XOR $BE = $01 existence mask) $01 OR $01 = $01 accumulated existence mask. ROM $FFB8 reads this address and uses bit 0 ROM $FFCD reads this address and uses bit 0 |
$4135 Unknown Yes Unknown Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
|||||||+-- $4135.0 = $4134 Serial Data Ready (1 = ready)
+++++++--- (unlikely to exist)

```
- If $4135.0 = 1, Built-in ROM proceeds to read the serial data from $4134.
- Note: Built-in ROM only treats this register as a flag and does not treat it as serial data.

| Reference Data |
-
  -
  -
  -
  -
-
| Read Bit Existence: Values $41, $40, and $BE from previous fetch observed unaffected. Value $41 from previous fetch also observed changed to $40. ($41 XOR $40 = $01 existence mask) Value $BF from previous fetch observed changed to $BE. ($BF XOR $BE = $01 existence mask) $01 OR $01 = $01 accumulated existence mask. ROM $FD35 reads this address and uses bit 0. |
$4136 Unknown No Yes Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Built-in ROM writes #$00 to $4137, then writes serial data to $4130, $4131, $4132, $4133, then writes #$00 to this register.
- Theory: This is a "start" flag that starts using new data from $4130-4133 when the flag is cleared.

| Reference Data |
-
  -
-
| Read Bit Existence: Values $41, $40, and $BE from previous fetch observed unaffected. ROM $F74A writes value #$00 to this address. |
$4137 Unknown No Yes Unknown Function.

```text
Write
76543210
++++++++-- (unknown)

Read
76543210
++++++++-- (unlikely to exist)

```
- Built-in ROM writes #$00 to this register, then writes serial data to $4130, $4131, $4132, $4133, then writes #$00 to $4136.
- Theory: This is a "clear" flag that resets write bit counters and/or clears old data from $4130-4133 when the flag is cleared.

| Reference Data |
-
  -
-
-
| Read Bit Existence: Values $41, $40, and $BE from previous fetch observed unaffected. ROM $F3FA writes value #$00 to this address. ROM $F73B writes value #$00 to this address. |
Communication Between Famicom and CPU2

Registers $40D0, $40D1, $40D2, and $40D3 are used for communication between Famicom and CPU2. One would tend to expect the Famicom to receive the same value from any of these four registers if read back right after writing. However, each register is actually a separate register in each direction. The Famicom only controls the value read by CPU2, and CPU2 only controls the value read by the Famicom. It may be that CPU2 echoes the value back in some cases, but don't be fooled.

Data packets are sent in both directions between the Famicom and CPU2 using these registers. The data flow is controlled by status and acknowledge flags in $40D3, and data is sent 3 bytes at a time using registers $40D0, $40D1, and $40D2. When CPU2 receives each 3-byte chunk, it buffers it in its RAM starting at address $0401 until the full message has been received. The maximum message length is at most 255 bytes, possibly less.

Each message starts with a command byte, followed by a byte count. The byte after the byte count is not used and not counted towards the byte count in most commands. There are a total of 25 command bytes, which are stored in a lookup table at CPU2 ROM address $FB52. The index of this lookup table corresponds to the index of a function pointer table at address $FBB2, and a command mode support bitfield table at address $FB6B. This is how CPU2 efficiently directs to a unique message handler function for each command byte. The mode bitfield checks against the mode byte at $0051. It is probably used for enforcing the correct sequence of commands, as the command handlers themselves seem to be a major contributor changing the mode. It seems there are 6 possible modes: 0, 1, 2, 3, 4, and 5, though command $03 is set to support modes 6 and 7 as well. The mode may actually represent a global state machine, such as 0 = disconnected, 1 = dialing, etc.

## CPU2 Commands

### Commands Read by the Famicom from CPU2

| CommandByte | Description |
| $80 | This command is received by the Famicom in response to writing to command $00. (See next section for details.) |

```text

```
-
-
-
-
| $81 | Unknown function. [$81] [count=$01] [$00] [connection status] It is unknown what events trigger this command to be sent to the Famicom. [connection status] comes from RAM $0052, see section below for enumerated values. This response can only happen in mode 3 via NMI. Theory: This command is a response to writing to command $01. |

```text

```
-
-

-
  -
  -
-
-
-
| $82 | Unknown function. [$82] [count=$01] [$00] [connection status] It is unknown what events trigger this command to be sent to the Famicom. [connection status] comes from RAM $0052, see section below for enumerated values. Response: [parameter] $00 means success, all other values indicate an error. When successful, the mode changes to $02. When unsuccessful, the mode changes to $00. [parameter] comes from RAM $0052 This response can only happen in mode 4 via NMI. Theory: This command is a response to writing to command $02. |
| $83 | This command is received by the Famicom in response to writing to command $03. (See next section for details.) |
| $90 | This command is received by the Famicom in response to writing to command $10. (See next section for details.) |
| $91 | This command is received by the Famicom in response to writing to command $11. (See next section for details.) |
| $92 | This command is received by the Famicom in response to writing to command $12. (See next section for details.) |

```text

```
-
-
-
-
-
-

```text

```
-
-
-
-
| $C0 | UART Rx Packet There are 2 different parts of the CPU2 code that can send this message: [$C0] [count=N] [parameter] [...N bytes...] This command can only be sent to the Famicom in mode 2. [parameter] comes from RAM $0024. [...N bytes...] are read from register $4110, most recent reads first, 1 byte read from $4110 per IRQ. Count N does not include the parameter byte. This is serial data received from the Oki MSM6827L integrated modem chip. This response can only happen in mode 2 via IRQ. [$C0] [count=$01] [$00] [parameter] It is unknown what events trigger this command to be sent to the Famicom. The modem abruptly disconnects when sending this command. [parameter] can be #$00 or #$01. This response can only happen in mode 2 via IRQ. |

```text

```
-

```text

```
-
  -
-
-
| $C1 | Tone Rx Data Packet. When the packet only contains 1 nybble: [$C1] [count=$01] [$80] [tone Rx nybble] [tone Rx nybble] is register ($4128 read value >> 3) & 0x0F. When there is more than 1 nybble in the packet: [$C1] [count=N] [parameter] [tone Rx bytes] [parameter] is either $00 or $01 based on the value of RAM $007A. Theory: [parameter] may indicate an even or odd number of nybbles in the packet. Each Tone Rx byte is packed with 2 nybbles. Count N does not include the parameter byte. |

```text

```
-
-
  -

```text

```
| $E1 | This command indicates that CPU2 had a failure receiving a command from the Famicom. Command from Famicom that failed due to invalid command byte, or a command not supported in the present mode: Message from Famicom: [invalid command] [count] [byte 0] [byte 1] ... Response back to Famicom: [$E1] [count=$03] [?] [$00] [invalid command] [byte 1] [?] byte appears to be open to sending an artifact from the previous response. Observed JRA-PAT rev 05 read this response after attempting to write to command $01 after a failed connection. E1 03 (00) 00 01 01 Command from Famicom that failed due to invalid byte count: Message from Famicom: [command] [invalid count] [byte 0] [byte 1] ... Response back to Famicom: [$E1] [count=$03] [$00] [$01] [command] [byte 1] |
| $F0 | This command is received by the Famicom in response to writing to command $7C. (See next section for details.) |

### Commands Written by the Famicom to CPU2

Note that most descriptions are incomplete .

| CommandByte | CPU2HandlerAddress | ByteCountExpected | ModesSupported | Description |

```text

```
-
-
-
-
  -
  -
    -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -
  -

-
  -
  -
-

| Reference Data |
-
  -
  -
  -
-
  -
    -
    -
    -
  -
    -
    -
  -
    -
    -
  -
    -
    -
  -
    -
    -
  -
    -
    -

-
  -
  -
  -
-
  -
  -
-
  -
  -
  -
-
| Starts NMI timer 1 with period $0006 (5 msec), one-shot: Writes #$06 to $4100 Writes #$00 to $4101 Writes #$02 to $4102 Observed Messages (unused bytes in parentheses): Super Mario Club rev 09: 00 13 (00) 42 31 20 36 33 57 30 36 30 37 38 31 34 34 31 33 25 67 25 (A2 01) "...B1 63W0607814413%g%¢." Note: The first '%' is definitely not a '$' in this one. Heart no Benrikun Mini rev 01 A: 00 13 (00) 42 31 20 36 33 57 30 36 30 33 31 33 35 38 35 35 24 67 25 (37 31) "...B1 63W0603135855$g%71" Okasan no Famicom Trade rev 01: 00 13 (00) 42 31 20 36 33 57 30 36 30 33 31 33 33 33 39 30 24 67 25 (00 00) "...B1 63W0603133390$g%.." JRA-PAT rev 05: 00 0F (00) 88 30 42 30 20 36 34 32 35 36 34 36 36 36 24 "...ˆ0B0 642564666$" JRA-PAT rev 05, with phone number manually set to 6666666666 00 0F (00) 42 36 20 36 36 36 36 36 36 36 36 36 24 67 25 "...B6 666666666$g%" PiT Motorboat Race rev 02, with phone number manually set to 1234567890: 00 0E (00) 24 42 31 20 32 33 34 35 36 37 38 39 30 00 (00) "...$B1 234567890.." Okasan no Famicom Trade rev 01 responses observed: 80 01 00 01 after failure due to no phone line connected, reported Error 4001. 80 01 00 03 after failure due to dial tone not going away, reported Error 4003. 80 01 00 06 after failure due to server never answering, reported Error 4006. PiT Motorboat Race rev 02 responses observed: 80 01 00 01 after failure due to no phone line connected. 80 01 00 0D after failure due to server never answering. JRA-PAT rev 05 responses observed: 80 01 00 01 after failure due to no phone line connected, reported Error 390010019999. 80 01 00 03 after failure due to dial tone not going away, reported Error 390030019999. 80 01 00 04 after failure due to server never answering, reported Error 390040019999. The response [parameter] byte comes from RAM $0052. |
$01 $F46C 1 2 Unknown Function.

```text
Message Bytes:
[$01] [count=$01] [xx] [parameter]
```
- [xx] byte is ignored.
- [parameter] Values:
  - $00 = Write #$00 to $0031
  - $01-FF = Write #$02 to $0031
- JRA-PAT and PiT Motorboat Race use this command when closing a connection.
- Observed Messages (unused bytes in parentheses):
  - JRA-PAT rev 05:
    - 01 01 (00) 01 (30 42)
  - PiT Motorboat Race rev 02:
    - 01 01 (00) 01 (02 31)
- Checks if the byte received is 00 and if so, acts differently.
- Starts NMI timer 1 with period $0006 (5 msec), one-shot:
  - Writes #$06 to $4100
  - Writes #$00 to $4101
  - Writes #$02 to $4102
- Changes to Command Mode 3 when complete.
- Theory: This command generates response command $81 (see previous section).
$02 $F48A 2 0 Unknown Function.

```text
Message Bytes:
[$02] [count=$02] [xx] [parameter 0] [parameter 1]
```
- [xx] byte is ignored.
- [parameter 0] gets written to $002E.
- [parameter 1] gets written to $002B and $002C.
- 9 zero-page addresses get zeroed out; seems to be initializing something.
- Starts NMI timer 1 with period $0006 (5 msec), one-shot:
  - Writes #$06 to $4100
  - Writes #$00 to $4101
  - Writes #$02 to $4102
- Changes to Command Mode 4 when complete.
- Theory: This command generates response command $82 (see previous section).
$03 $F4BB 0 0,1,2,3,
4,5,6,7 System Revision and Status Information

```text
Message Bytes:
[$03] [count=$00]

Response:
[$83] [count=$0A] [$00] [ROM revision] [ROM checksum MSB] [ROM checksum LSB] [byte 4] ... [byte 10]
```
- Writes to $4120.
- Writes $412F shadow register to $412F (update only, no apparent modification).
- Response:
  - [byte 1] = Comes from ROM address $FFF9, which seems to be a ROM revision byte. Observed value $03.
  - [byte 2], [byte 3] = 16-bit ROM checksum. Computed at bootup with the function located at $FD7D. It adds each byte of ROM.
  - [byte 4] = Value read from register $4121 & #$3F. If RAM $0023 is not equal to #$04, it also sets bit 7.
  - [byte 5] = Value read from register $4126.
  - [byte 6] = Value most recently written to $4127.
  - [byte 7] = Present mode.
  - [byte 8] = Number of 256-byte data blocks presently queued up in RAM range $1300-$1FFF.
  - [byte 9] = Value of RAM $0076.
  - [byte 10] = Value of RAM $0077.
- Observed Messages (unused bytes in parentheses):
  - Super Mario Club rev 09 at power-on:
    - Write: 03 00 (00)
    - Read: 83 0A 00 03 0C AF A1 FB FE 00 0D 00 00
  - JRA-PAT rev 05 and 06 at power-on:
    - Write: 03 00 (00)
    - Read: 83 0A 00 03 0C AF 81 FB FE 00 0D 00 00
$10 $F71A 40 0,2,5 Unknown $413x Function.

```text
Message Bytes:
[$10] [count=$28] [parameter] [...40 bytes...]

Response:
[$90] [count=$28] [response parameter] [...40 bytes...]
```
- This command is similar to command $11, except using pre-defined data from ROM instead of the additional chunks in command $11.
- [parameter] is used but does not count towards the byte count.
- [parameter] value #$00 - #$0F:
  - Pre-defined ROM data gets copied from tables.
  - 40 bytes from ROM are copied starting at RAM address $0360. ROM table index using parameter bits 2,1,0.
    - $0388 (i.e. 41st byte) set to #$00.
    - See Register $4131.
  - 40 bytes from ROM are copied starting at RAM address $0390. ROM table index using parameter bits 1,0.
    - $03B8 (i.e. 41st byte) set to #$00.
    - See Register $4132.
  - 40 bytes from the command are copied starting at RAM address $0330.
    - $0358 (i.e. 41st byte) set to #$00.
    - $0330 (i.e. 1st byte) set to #$00.
    - See Register $4130.
  - 5 static bytes from ROM are copied starting at RAM address $0320: 01 40 50 00 60
    - See Register $4133.
- [parameter] value #$10:
  - Skips the $0360 and $0390 ROM copy routines if RAM $0055 == #$00.
  - If $0055 is not #$00, it aborts the command.
- Writes #$00 to $4137
- Writes the 4 data chunks shifting 1 bit at a time to $4130, $4131, $4132, $4133
- Writes #$00 to $4136
- For the response, the count has not been confirmed to include [response parameter] or not.
- The response comes from RAM starting at $03C0. (See register $4134.)

| ROM Data |

| Data Loaded to $0330 (which later gets written to register $4130): (These are the 40 bytes supplied by the Famicom to this command, with 1st byte and 41st byte set to $00.) |

| Parameter Bits | Data |
| xxxxx000 | 00000c6bbc41351b1e0fa372963f7af704415090ee9a139ff87c60ca610dec66f74bd5b992c8868300 |
| xxxxx001 | 0000027473468ebd1f161331ad0e5512ba56487f7b30037dac78ed9c51b308b6d8c597ca8b59cc1300 |
| xxxxx010 | 000001c89b4630b518cbc342a45282fa0908773df56830150ec1955c9ec1abbd1100d4d878604afd00 |
| xxxxx011 | 00000939c25f1859304000e9fdab927959a49d1acdd136da4ddb2b551b2bc942a36077d1d09dbc3500 |
| xxxxx100 | 3cfed7ad4cd7435c3544144572d1d0e83d1859864bf8c7412cac015ced49a1cabce13fbd6262af0b00 |
| xxxxx101 | 8aac02df739c8c0a2572493bd95755450b06ea0d77f1f08bc665636ed3cf317cb89f6f301ef03a2f00 |
| xxxxx110 | 39b07c4f12614dadb4eb214af3a6a0dc046b47d10c184b04d16c91d9eeb5e0c21a052529738c6f0100 |
| xxxxx111 | 36a6a31fa79ba49a9f1d1985c640ad9a6c79a4195d06ece8726fc006e1d347efa5d129cdb79017b900 |

Data Loaded to $0390 (which later gets written to register $4132):

| Parameter Bits | Data |
| xxxxxx00 | 882a14099f3f32b2419d0b09237a252ece6534274700628043a6df86657a84c0c4463fa72b49ad4900 |
| xxxxxx01 | bbb57552f19d8a71d6ed68fd037188b700eab270071acedc624ff4c64b53ed1c4e1046ed89e775fd00 |
| xxxxxx10 | cfb8e78ec54b81a1100f02f524acf0e05a45cc36a98f161c115a41082abb587ecabad5453511877100 |
| xxxxxx11 | aa189432166db82500fffbb1107ced2469b12f0959b263c63a0332bb4a8e6ea378a0a47150cb296100 |

Data Loaded to $0320 (which later gets written to register $4133):

| Parameter Bits | Data |
| xxxxxxxx | 0140500060 |
$11 $F75C 127 0,2,5 Unknown $413x Function.

```text
Message Bytes:
[$11] [count=$7F] [...5 byte chunk...] [...41 byte chunk 0...]
                  [...41 byte chunk 1...] [...41 byte chunk 2...]

Response:
[$91] [count=$29] [response parameter] [...41 bytes...]
```
- Note that the first byte of the 5 byte chunk is not ignored in this command like it is in most others, though it still does not count towards the byte count.
- The 5 byte chunk gets written to RAM starting at $0320 with lots of bit shifting and byte swapping. (See Register $4133.)
- The 41 byte chunk 0 gets copied to RAM starting at $0330. (See Register $4130.)
- The 41 byte chunk 1 gets copied to RAM starting at $0360. (See Register $4131.)
- The 41 byte chunk 2 gets copied to RAM starting at $0390. (See Register $4132.)
- Shares the remaining code in common with command $10.
- For the response, the count has not been confirmed to include [response parameter] or not.
- The response comes from RAM starting at $03C0. (See register $4134.)
$12 $F773 >= 3
<= 252 0,2,5 CRC Calculator

```text
Message Bytes:
[$12] [count=N] [initial] [polynomial 1] [polynomial 2] [...N-2 bytes...]

Response:
[$92] [count=$02] [$00] [CRC 2] [CRC 1]
```
- The [initial] byte does not count towards the byte count.
- See next section for information about CRC keys.
- Doesn't seem to write to any registers.
$40 $F7AF >= 1
<= 252 2 Unknown Function.

```text
Message Bytes:
[$40] [count=N] [xx] [...N-1 bytes...]
```
- [xx] byte is ignored, but does count towards the byte count.
- Copies the N-1 bytes data directly into memory starting at the location +2 pointed to by $0000:0001.
- Copies the byte count to the location +1 pointed to by $0000:0001.
- Writes value $FF directly to the location pointed to by $0000:0001.
  - Not known what sets up that pointer.
- This command is tricky to disassemble because it actually does copy the [xx] byte, then writes over it with the byte count, ultimately not using it.
- Theory: This command sends a UART Tx Packet to the Oki MSM6827L, and connected with response command $C0.
$41 $F7D0 >= 1
<= 100 5 Unknown Function.

```text
Message Bytes:
[$41] [count=N] [xx] [...N bytes...]
```
- [xx] byte is ignored and does not count towards the byte count.
- Writes ((Byte count + 2) * 2) to the location +1 pointed to by $0000:0001.
- Writes value $00 to the location +2 pointed to by $0000:0001.
- Writes value $0F to the location +3 pointed to by $0000:0001.
- For each of N bytes:
  - Writes upper nybble of the byte (>> 4) to the next byte pointed to by $0000:0001.
  - Writes the lower nybble of the byte (& $0F) to the next byte pointed to by $0000:0001.
- Appends the value of $007C similarly as 2 nybbles at the end.
- Writes value $FF directly to the location pointed to by $0000:0001.
  - Not known what sets up that pointer.
- Theory: This command is something to do with the Tone Rx chip, and connected with response command $C1.
$60 $F829 6 0 Unknown Function.

```text
Message Bytes:
[$60] [count=$06] [...6 data bytes...]
```
- Note that the first data byte is not ignored in this command, and it does count towards the byte count.
- The 6 data bytes written by this command get copied to CPU2 RAM starting at address $84.
- PiT Motorboat Race uses this command when opening a connection.
- Observed Messages (unused bytes in parentheses):
  - PiT Motorboat Race rev 02:
    - 60 06 00 01 80 00 00 00 (00)
$61 $F839 0 1,3,4 Disconnect

```text
Message Bytes:
[$61] [count=$00]
```
- This command abruptly disconnects the modem.
- Writes #$00 to register $4102. (Stops NMI timer 1.)
- Changes mode to 0 when complete.
$62 $F849 1 0,2,5 Unknown Function.

```text
Message Bytes:
[$62] [count=$01] [xx] [parameter]
```
- [xx] byte is ignored.
- Disables interrupts while executing this command.
- Valid values of the [parameter] byte are $00 and $01.
  - Other values abort the command.
- Appears to write to $4120
$63 $F887 0 0,1,2,3,
4,5 NOP Command

```text
Message Bytes:
[$63] [count=$00]
```
- This command only validates the byte count = #$00 and is then complete.
$64 $F88D 1 0,2,5 Modem Off Hook Control

```text
Message Bytes:
[$64] [count=$01] [xx] [Modem Off Hook mode]
```
- [xx] byte is ignored.
- [Modem Off Hook mode] Values:
  - $00 = Don't update but save mode as $00.
  - $01 = Set $4127.4 (/Modem Off Hook) = 0 (off hook). (Also stores #$00 to $0049)
  - $02-FF = Set $4127.4 (/Modem Off Hook) = 1 (hang up). (Also stores #$00 to $0049)
  - Value gets saved to $004E.
- PiT Motorboat Race uses this command when closing a connection.
- Observed Messages (unused bytes in parentheses):
  - PiT Motorboat Race rev 02:
    - 64 01 (00) 02 (A9 31)
- Note: This description is fairly complete.
$65 $F89D 2 0,2,5 Modem Audio Enable and P4-19 Control

```text
Message Bytes:
[$65] [count=$02] [xx] [Modem Audio Enable mode] [P4-19 mode]
```
- [xx] byte is ignored.
- [Modem Audio Enable mode] Values:
  - $00 = Don't update but save mode as $00.
  - $01 = Set $4127.6 (/Modem Audio Enable) = 0 (enabled to TV speakers).
  - $02-FF = Set $4127.6 (/Modem Audio Enable) = 1 (disabled).
  - Value gets saved to $004F.
- [P4-19 mode] Values:
  - $00 = Don't update but save mode as $00.
  - $01 = Set $4127.7 (Modem P4-19) = 0.
  - $02-FF = Set $4127.7 (Modem P4-19) = 1.
  - Value gets saved to $0050.
- Heart no Benrikun Mini rev 01 A uses this command when closing a connection.
- Observed Messages (unused bytes in parentheses):
  - Heart no Benrikun Mini rev 01 A:
    - 65 02 (00) 02 00 (20)
- Note: This description is fairly complete.
$66 $F8B7 2 0,2,5 LED Control

```text
Message Bytes:
[$66] [count=$02] [xx] [red LED mode] [green LED mode]
```
- [xx] byte is ignored.
- [red LED mode] Values:
  - $00 = Don't update but save mode as $00.
  - $01 = Set Red LED on.
  - $02-7F = Set Red LED off.
  - $80-FF = Set Red LED to be controlled automatically by network status.
  - Value gets saved to $004C.
- [green LED mode] Values:
  - $00 = Don't update but save mode as $00.
  - $01 = Set Green LED on.
  - $02-7F = Set Green LED off.
  - $80-FF = Set Green LED to be controlled automatically by network status.
  - Value gets saved to $004D.
- PiT Motorboat Race uses this command when closing a connection.
- Observed Messages (unused bytes in parentheses):
  - PiT Motorboat Race rev 02:
    - 66 02 (00) 02 02 (31)
- Note: This description is fairly complete.
$67 $F8D1 2 0,5 Unknown Function.

```text
Message Bytes:
[$67] [count=$02] [xx] [parameter 0] [parameter 1]
```
- [xx] byte is ignored.
- If [parameter 0] is $00:
  - Abruptly disconnects the modem.
  - Zeroes out RAM $0076 and $0077.
  - Changes to mode 0 when complete.
- Else if [parameter 0] is not $00:
  - Writes [parameter 0] to $74.
  - Writes [parameter 1] to $75.
  - Refreshes Green LED based on its mode.
  - Refreshes P4-27 (Phone Off Hook) based on its mode.
  - Zeroes out RAM $76,77,37,39,38.
  - Refreshes P4-21 (Phone Audio Enable) based on its mode.
  - Zeroes out all queued up outgoing modem Tx messages at RAM $1300-1FFF.
    - Each message has space $100 and number of queued messages is at RAM $0100.
  - Zeroes out Tone Rx incoming data buffer at RAM $0500-05FF.
  - Changes to mode 5 when complete.
$68 $F912 1 0,5 Unknown Function.

```text
Message Bytes:
[$68] [count=$01] [xx] [parameter]
```
- [xx] byte is ignored.
- The code has 3 different paths depending on parameter.
  - [parameter] < #$10
  - [parameter] == #$FF
  - All other values of [parameter]
$69 $F951 10 0 Unknown Function.

```text
Message Bytes:
[$69] [count=$0A] [xx] [...10 data bytes...]
```
- [xx] byte is ignored.
- Observed Messages (unused bytes in parentheses):
  - PiT Motorboat Race rev 02 when opening a connection:
    - 69 0A (00) 00 04 14 1D 28 80 00 30 26 21 (00 00)
  - JRA-PAT rev 05 and 06 at power-on:
    - 69 0A (00) 00 04 14 1D 28 30 00 30 26 21 (00 00)
- The 10 data bytes are copied to CPU2 RAM starting at $8A.
- If the 6th data byte (location $8F) is > #$FC, it gets overwritten by #$01.
$6A $F96F 80 0,2,5 Unknown $413x Function.

```text
Message Bytes:
[$6A] [count=$50] [xx] [...40 byte chunk 0...] [...40 byte chunk 1...]
```
- [xx] byte is ignored.
- Copies the 40 byte chunk 0 to RAM starting at $0360. (See Register $4131.)
- Copies the negative (2's complement) of each byte in 40 byte chunk 1 to RAM starting at $0390. (See Register $4132.)
- Writes #$00 to $0388 and $03B8. (i.e. 41st byte of each.)
- Writes #$10 to $0055.
- Observations:
  - No updates were made to buffers at $0320, $0330 from this command. (i.e. register $4133, $4130 data)
  - The command does not appear to initiate any operations to the $413x registers.
- Note: This description is fairly complete.
$7B $F994 No
Check 0,1,2,3,
4,5 Software Reset

```text
Message Bytes:
[$7B] [count=xx] [xx]
```
- Does not care about any bytes beyond the command byte.
- Refreshes the green LED.
- Disables interrupts.
- Writes #$00 to $412F.
- Sorts through some memory comparing values then generates a software reset.
  - Stores #$09 as the reset type code into $00FF.
$7C $F9AC 5 0,1,2,3,
4,5 Arbitrary Memory Read

```text
Message Bytes:
[$7C] [count=$05] [xx] [CRC 1] [CRC 2] [address MSB] [address LSB] [read count N]

Response:
[$F0] [read count N] [$00] ...N bytes from memory...
```
- [xx] byte does not count towards the byte count.
- See next section for information about CRC bytes.
- If [address MSB] >= #$80, exits early with no response. (Prevent ROM dump?? :) )
- If [read count N] >= #$39, exits early with no response.
$7D $F9D9 >= 5 0,1,2,3,
4,5 Arbitrary Memory Write

```text
Message Bytes:
[$7D] [count=N] [xx] [CRC 1] [CRC 2] [address MSB] [address LSB] [...N-4 bytes...]
```
- [xx] byte does not count towards the byte count.
- See next section for information about CRC bytes.
- count - 4 is the number of bytes to write to memory.
- Writes $00 to $006E.
- Super Mario Club rev 09 uses this command at the welcome screen.
  - 7D 1A (00) 07 60 01 04 09 01 06 E0 16 A2 90 A5 29 F0 06 C9 FF D0 04 A2 01 86 29 4C 20 F4 (30)
  - CRC bytes: 07 60
  - Starting address: $0104 (farthest reaches of the stack)

| Disassembly |

```text

```
| .org $0104 .dd2 T0109 ;Wrote over Main Super-loop Function Pointer, now executes code below. .dd2 TE006 ;Wrote over IRQ Handler Function Pointer, now immediately exits IRQ. .dd1 $16 ;Satisfy periodic checksum of bytes $102-109. T0109 ldx #$90 ;Arbitrary code inserted. lda $29 beq L0115 cmp #$ff bne L0117 ldx #$01 L0115 stx $29 L0117 jmp $f420 ;Continue to original main super-loop. ; Code Below Existing In CPU2 ROM: .org $e006 TE006 jmp TE502 .org $e502 TE502 ply ;Return from IRQ. plx pla rti |
- JRA-PAT rev 05 and 06 use this command at power-on.
  - 7D 29 (00) EC AD 01 02 1A 01 09 01 06 E0 DB A2 90 A5 29 F0 06 C9 FF D0 04 A2 01 86 29 4C 20 F4 AD 32 00 C9 05 D0 03 EE 32 00 4C 39 E8 (00)
  - CRC bytes: EC AD
  - Starting address: $0102 (farthest reaches of the stack)

| Disassembly |

```text

```
| .org $0102 .dd2 T011A ;Wrote over NMI function pointer, now executes code below. .dd2 T0109 ;Wrote over Main Super-loop Function Pointer, now executes code below. .dd2 TE006 ;Wrote over IRQ Handler Function Pointer, now immediately exits IRQ. .dd1 $db ;Satisfy periodic checksum of bytes $102-109. T0109 ldx #$90 ;Arbitrary code inserted. lda $29 beq L0115 cmp #$ff bne L0117 ldx #$01 L0115 stx $29 L0117 jmp $f420 ;Continue to original main super-loop. T011A lda $0032 ;Arbitrary NMI handler code inserted. cmp #$05 bne L0124 inc $0032 L0124 jmp TE839 ; Code Below Existing In CPU2 ROM: .org $e006 TE006 jmp TE502 .org $e502 TE502 ply ;Return from IRQ. plx pla rti .org $e839 TE839 ply ;Return from NMI. plx pla rti |
$7E $F9FE 5 0,1,2,3,
4,5 Unknown Function.

```text
Message Bytes:
[$7E] [count=$05] [xx] [CRC 1] [CRC 2] [parameter 0] [parameter 1] [parameter 2]
```
- [xx] byte does not count towards the byte count.
- See next section for information about CRC bytes.
- Writes a lot of stuff to $4120 and $4121
- Writes to $4127 bit 5 (/DTMF Output Enable)
$7F $FA16 5 0,1,2,3,
4,5 Unknown Function.

```text
Message Bytes:
[$7F] [count=$05] [parameter 0] [CRC 1] [CRC 2] [parameter 1] [parameter 2] [parameter 3]
```
- [parameter 0] byte does not count towards the byte count.
- See next section for information about CRC bytes.
- If [parameter 0] is $00-7F, write value $0C out the P5 Expansion Port.
- If [parameter 0] is $80-FF, dump RAM $0240-$0280 out the P5 Expansion Port.
  - The P5 Expansion port sequences out 1 nybble at a time.
- [parameter 1] gets written to $00B7.
- [parameter 2] gets written to $00B6.
- [parameter 3] gets written to $00B8.
- [parameter 0] gets written to $00B5.

### CPU2 Commands with CRC key bytes

CPU2 command $12 calculates the CRC-16 of its message using [polynomial 1] and [polynomial 2] as the CRC polynomial, with [initial] placed in both bytes of the initial value, and performs the calculation LSB-first or "reflected". This command requires the polynomial to be specified in reciprocal form. For example, to calculate the standard CRC-16 with polynomial $8005, [polynomial 1] would be set to $40, [polynomial 2] would be set to $03, and [initial] would be set to $00.

CPU2 Commands $7C, $7D, $7E, and $7F use CRC key bytes [CRC 1] and [CRC 2] to validate the message. These commands calculate a CRC-16 across the message backwards, starting from the last byte and ending at [CRC 1]. The result must be 0 or the command is ignored. The CRC-16 polynomial is $8385 and the initial value is $35AC. The calculation is done LSB-first, or "reflected".

### Connection Status Byte

Response commands $80, $81, and $82 send an enumerated value indicating the result when attempting to make a telephone connection. These enumerations are used clearly in the CPU2 ROM: 00, 01, 02, 03, 04, 05, 06, 07, 08, 0B, 0C, 0D, 0E. CPU2 ROM keeps track of this value at RAM location $0052. $00 indicates a successful connection, and all other values indicate a failure. Super Mario Club shows these failures with error code 40xx, xx directly reflecting this byte. Super Mario Club's manual gives troubleshooting information for most of these values. That information was used to create the table below.

| StatusByte | ErrorCode | Description |
| $00 | (n/a) | Connection was successful. |

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

-
-

-
-
| 電話線がはずれています。 The telephone line is off. | 通信アダプタの電話回線の差し込みへ電話線を接続してください。 Connect the telephone line to the telephone line plug of the communication adapter. 回線テストのテスト1(29ページ) を行ってください。 Perform Test 1 (page 29) of the line test. |

| 既に電話が使われています。 The phone is already in use. | 通話が終わるまで待ってください。 Please wait until the call ends. |

| ホー厶テレホン用のモジュラーコンセントなどにテレホンスイッチを取りつけていませんか? Is the telephone switch attached to a modular outlet for the Ho 厶 telephone? | テレホンスイッチがNTT の局線に直接取りつけられるように工事を行ってください。 Make sure that the telephone switch can be attached directly to the NTT station line. |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |

| 電話線は正常に接続されていますか？ Is the telephone line connected normally? 自宅の電話が使用中ではありませんか？ Is your home phone in use? |
$02 4002 An incoming phone call is being received.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

| 電話がかかってきました。 I got a call. | 受話器をお取りください。 Please pick up the handset. |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |

| もう一度ご利用ください。 Please use it again. |
$03 4003 Pulse vs. Tone setting is incorrect.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

-

-
| プッシュ回線とダイヤル回線の設定を誤っています。 The push line and dial line settings are incorrect. | 通信アダプタ裏の切換スイッチを回線に合わせてください。 Set the changeover switch on the back of the communication adapter to match the line. (番号をかけた時にプッシュ回線の場合はピ・ポ・パと鳴りますのでPBにセットしてください。それ以外はダイヤル回線ですので、20にセットしてください。 部の地域では 10 にセットしていただく場合があります。) (If you use a push line when you dial a number, you will hear a beep, so set it to PB. Other than that, it is a dial line, so set it to 20. Set it to 10 in some areas. You may be asked to do so.) |

| テレホンスイッチを新電電アダプタ等の後に取りつけていませんか? Is the telephone switch installed after the new electric adapter, etc.? | テレホンスイッチを新電電アダプタより前(NTTの局線側)に取りつけてください。 Install the telephone switch in front of the new electric adapter (NTT station line side). |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |

| ご利用電話の種類の設定が誤っています。 The phone type setting is incorrect. 通信アダプタ裏の電話回線切換スイッチをセットしください。 Set the telephone line selector switch on the back of the communication adapter. 任天堂の通信アダプタセット取扱説明書をご覧下さい。 Please refer to the Nintendo communication adapter set instruction manual. |
$04 4004 "0" Outgoing call setting is incorrect.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

| 0発信の設定が誤っています。 The 0 outgoing call setting is incorrect. (0発信電話なのに0発信の設定がなされていません。 又は直通電話なのに0発信の設定がされています。) (0 outgoing call is not set even though it is a 0 outgoing call, or 0 outgoing call is set even though it is a direct call.) | 登録内容を見直してください。(訂正する場合は、28ページをご参照ください。) Please review the registered contents. (Refer to page 28 for corrections.) |

| テレホンスイッチの取りつけが誤っています Wrong installation of telephone switch | 通信機器の接続 (7,8ページ) をご確認ください。 Check the connection of communication devices (pages 7 and 8). |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |

| 電話回線は利用可能となっていますか？ Is the telephone line available? ご利用の電話は「ゼロ発信」ではありませんか？ Isn't your phone "zero call"? |
$05 4005 DDX-TP connection completed earlier than expected.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

-
-

-
-
| DDX-TPの開通 (工事) が完了していないと思われます。 It seems that the opening (construction) of DDX-TP has not been completed. | 回線テストのテスト2 (29ページ) を行ってください。(DDX-TP網IDの場合) Perform Test 2 (page 29) of the line test. (For DDX-TP network ID) NTTの113番に電話して確認してください。 Please call NTT 113 to confirm. |

| テレホンスイッチの取りつけが誤っています。 The telephone switch is installed incorrectly. | 通信機器の接続(7, 8ページ) をご確認ぐださい。 Check the connection of communication devices (pages 7 and 8). |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |
-
-
| 113に電話して、NTTにDDXの工事完了を確認して下さい。 Call 113 to confirm with NTT that the DDX construction has been completed. |
$06 4006 Unknown. $07 4007 Unknown. $08 4008 Server was busy, disconnected, or rejected the password.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

| センター側が混雑しています。 The center side is crowded. | しばらく経ってから再度お試しください。 Please try again after a while. |

| センターが停止しています。 The center is stopped. | サービス時間を確認してください。 Please check the service time. |

-
-

-
-
| DDX-TP の開通 (工事) が完了していないと思われます。 It seems that the opening (construction) of DDX-TP has not been completed. | 回線テストのテスト2(29ページ) を行ってください。(DDX- TP綱IDの場合) Perform Test 2 (page 29) of the line test. (For DDX-TP rope ID) NTTの113番に電話して確認してください。 Please call NTT 113 to confirm. |

| テレホンスイッチの取りつけが誤っています。 The telephone switch is installed incorrectly. | 通信機器の接続(7,8ページ) をご確認ください。 Check the connection of communication devices (pages 7 and 8). |

| DDX-TPパスワードで、登録に誤りがあります。 There is an error in the registration of the DDX-TP password. | パスワード番号とパスワード登録電話番号をご確認ください。 Please check your password number and password registration phone number. |

Kangyou Sumimaru no Famicom Trade Manual:
Same as 4005.
$09 4009 Server was busy.

| Reference Data |

| 原 因•対応方法 (Cause • Countermeasure) |

| 相手方が話中です。しばらくして、再度かけ返して下さい。 The other party is busy. Please call back again after a while. |
$0A 400A DDX-TP registration incorrect or server disconnected.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

| DDX-TPの登録内容に誤りがあります。 There is an error in the registered contents of DDX-TP. | NTTの113番に電話して登録内容の確認をしてください。 Please call NTT 113 to confirm your registration details. |

| センターが停止しています。 The center is stopped. | サービス時間を確認してください。(15ページ) Please check the service time. (Page 15) |

Kangyou Sumimaru no Famicom Trade Manual:

| 原 因•対応方法 (Cause • Countermeasure) |

| 再度、お試し下さい。 Please try again. 頻繁に発生する場合にはファミコントレード事務局へお電話下さい。 If it occurs frequently, please call the NES Trade Secretariat. |
$0B 400B $0C 400C $0D 400D Problem with telephone line connection.

| Reference Data |

| おもな原因 (Main Cause) | 対処方法 (Workaround) |

| 通信アダプタから電話線がはずれました。 The telephone line has been disconnected from the communication adapter. | 通信アダプタと電話線の接続を確認してください。 Check the connection between the communication adapter and the telephone line. |
$0E 400E Problem with telephone line connection or server.

| Reference Data |

| Super Mario Club Manual: Same as 400D. Kangyou Sumimaru no Famicom Trade Manual: Same as 400A. |
Pinouts

## RF5C66 Mapper and Disk Drive Controller

```text
                                                       _____
                                                      /     \
                                           CPU A0 -> / 1 100 \ -- +5Vcc
                                          CPU A1 -> / 2    99 \ -- n/c
                                         CPU A2 -> / 3      98 \ <> CPU D0
                                        CPU A3 -> / 4        97 \ <> CPU D1
                                       CPU A4 -> / 5          96 \ <> CPU D2
                                      CPU A5 -> / 6            95 \ <> CPU D3
                                     CPU A6 -> / 7              94 \ <> CPU D4
                                    CPU A7 -> / 8                93 \ <> CPU D5
                                  CPU A12 -> / 9                  92 \ <> CPU D6
                                 CPU A13 -> / 10                   91 \ <> CPU D7
                                CPU A14 -> / 11                     90 \ -- GND
                               /ROMSEL -> / 12                       89 \ <> Card D0
                              CPU R/W -> / 13                         88 \ <> Card D1
                                  M2 -> / 14                           87 \ <> Card D2
          P6-1 Lid Switch, Card R/W <- / 15                             86 \ <> Card D3
          (20k resistor to 5Vcc) ? -> / 16                               85 \ <> Card D4
                             /IRQ <- / 17                                 84 \ <> Card D5
                           +5Vcc -- / 18                                   83 \ <> Card D6
                            n/c -- / 19                                     82 \ <> Card D7
              21.47727MHz Xtal -- / 20                                       81 \ -- +5Vcc
                         Xtal -- / 21                                            \
                         n/c -- / 22                                     O       /
                        GND -- / 23                                          80 / -- n/c
        (n/c) Xtal Osc Out <- / 24                                          79 / -> Exp P3-2
                      n/c -- / 25                                          78 / <- Exp P3-3
   ToneRx Xin, CIC Clock <- / 26              Nintendo RF5C66             77 / -> Exp P3-4
                    n/c -- / 27       Package QFP-100, 0.65mm pitch      76 / -> Exp P3-5
         (n/c) $40AE.0 <- / 28                                          75 / -> Exp P3-6
 CIC /CPU R/W Inhibit -> / 29                Mapper and                74 / <- Exp P3-7
      Key CIC-12 (?) <- / 30           Disk Drive Controller          73 / <- Exp P3-8
                       /       O                                     72 / <- Exp P3-9
                       \                                            71 / <- Exp P3-11
      Key CIC-10 (?) -> \ 31                                       70 / -- GND
       Key CIC-15 (?) -> \ 32                                     69 / -> 5A18-49
           CPU2 /Reset -> \ 33                                   68 / -> CPU2 /Reset (new rev)
    CHR RAM /CE (input) -> \ 34                                 67 / <> Exp P3-12           Orientation:
                 RAM +CE <- \ 35                               66 / <> Exp P3-13            --------------------
            (n/c) $40C0.1 <- \ 36                             65 / <> Exp P3-14                 80         51
 CPU2 /Reset (old rev: J2) <- \ 37                           64 / <> Exp P3-15                   |         |
                CHR RAM /CE <- \ 38                         63 / <- $40B1.3 (n/c)               .-----------.
                         GND -- \ 39                       62 / <> Modem P4-31               81-|O Nintendo |-50
Built-in RAM /CE ($6000-7FFF) <- \ 40                     61 / <> Modem P4-32                   |  RF5C66   |
      (n/c) ? /CE ($4xE0-4xEF) <- \ 41                   60 / <> Modem P4-29                100-|  GCD 4R  O|-31
       5A18-85 /CE ($4xD0-4xDF) <- \ 42                 59 / -- +5Vcc                           \-----------'
                         (GND) ? -> \ 43               58 / -- n/c                               |         |
                          (GND) ? -> \ 44             57 / -> Kanji ROM A17                     01         30
                           (GND) ? -> \ 45           56 / -> Kanji ROM A4
                            (GND) ? -> \ 46         55 / -> Kanji ROM A3          Legend:
                           CIRAM A10 <- \ 47       54 / -> Kanji ROM A2           ------------------------------
                              PPU A11 -> \ 48     53 / -> Kanji ROM A1            --[RF5C66]-- Power
                               PPU A10 -> \ 49   52 / -> Kanji ROM A0             ->[RF5C66]<- RF5C66 input
             Kanji ROM /CE ($5000-5FFF) <- \ 50 51 / -- n/c                       <-[RF5C66]-> RF5C66 output
                                            \     /                               <>[RF5C66]<> Bidirectional
                                             \   /                                    f      Famicom connection
                                              \ /                                     r      ROM chip connection
                                               V                                      R      RAM chip connection
Notes:
- +5Vcc pins 18, 59, 81, 100 are all connected together internally.
- GND pins 23, 39, 70, 90 are all connected together internally.
- 43, 44, 45, 46 are GND on the PCB, but have internal protection diodes from GND, suggesting they are logic pins.
  - Pins 45-46, when pulled high, causes oscillation on pin 56.
- 24, 28, 36, 37, 41, 63 are n/c on the PCB, but function as noted.
- /CE Pins 40, 41, 42, 50 behaviors:
  - Pin 40 (Built-in RAM /CE) activates low in range $6000-7FFF, regardless of CPU R/W, but only when M2 is high.
  - Pin 41 (Unknown /CE) always activates low in range $4xE0-4xEF, regardless of CPU R/W and M2.
  - Pin 42 (RF5A18 CPU2 /CE) always activates low in range $4xD0-4xDF, regardless of CPU R/W and M2.
  - Pin 50 (Kanji ROM /CE) activates low in range $5000-5FFF, regardless of CPU R/W.  (It appears to go low only when M2 is high but not specifically proven.)
- Pin 29:
  - If the FNS has a CIC chip, CIC-11 drives this pin high after 24.8msec, and remains high as long as the CIC authentication is successful.  There is a low-pass filter in this case.
  - If the FNS does not have a CIC chip, the pin floats high.  There may be a pull-up resistor somewhere.  The delay to go high (if any) has not been measured.
  - When this pin is low, it resets pins 52-57 low and possibly lots of other things.
  - Card R/W is always high when this pin is low.
- Pin 31 (CIC-10) and Pin 32 (CIC-15):
  - Both are jumpered direct to GND if the FNS does not have a CIC chip.
  - If it does have a CIC chip, these signals are both always low with or without tsuushin card inserted.
  - In no observed case are these signals ever high.
- Pin 16 Pull-up of 20k to 5V is also required in order to avoid triggering reset.
- Pin 16 seems to be related to pin 29.  With pin 29 floating and pin 16 pulled high at power on, the chip runs for 5 seconds, then enters reset.
- Tested 10k instead of 20k (per original PCB) on pin 16, found no difference in time or function.
- Pin 69 has a high pulse of 11.9085 usec at any time that register $4xAC has not been read for 12.4892 seconds.
  - Each additional 12.4892 seconds generates another pulse.
  - It has very repeatable precision, at least 6 figures on each.
  - It is not synchronized to M2 or any other inputs.
  - Note that 12.4892 sec * 21.47727 MHz = 2^28, with an error of 0.075%. (Nominal would be 12.4986 sec.)
  - Note that 11.9085 usec * 21.47727 MHz = 2^8, with an error of 0.093%. (Nominal would be 11.9196 usec.)
- Pins 52-56 drive the address pins of the Kanji ROM.  (See notes below the LH5323M1 pinout.)
- Pin 15 (Card R/W) is a non-inverted buffer of CPU R/W.  This signal connects through the lid switch.
- Pin 26 puts out a 3.58 MHz square wave, ~50% duty.  This corresponds to 21.47727 MHz / 6.
- Pin 79 (Exp 2) puts out a 95.95 kHz square wave, 93.7% duty.  Clock source unknown.
  - Note that this seems similar to FDS serial bitrate.
  - Standalone chip can get into a 341.2 kHz mode when touching pin 80, though pulling 80 high or low doesn't correlate.
  - Either frequency, the negative pulse width is 650 nsec.
- Pins 71-79 appear strikingly similar to an FDS interface.
- CIRAM A10 follows PPU A10 by default.

```

## RF5A18 CPU2 / Modem Controller

```text
                                                     _____
                                                    /     \
                                        CPU2 A0 <- / 1 100 \ -- GND
                                       CPU2 A1 <- / 2    99 \ <> CPU2 D0
                                      CPU2 A2 <- / 3      98 \ <> CPU2 D1
                                     CPU2 A3 <- / 4        97 \ <> CPU2 D2
                                    CPU2 A4 <- / 5          96 \ <> CPU2 D3
                                   CPU2 A5 <- / 6            95 \ <> CPU2 D4
                                  CPU2 A6 <- / 7              94 \ <> CPU2 D5
                                 CPU2 A7 <- / 8                93 \ <> CPU2 D6
                                  +5Vcc -- / 9                  92 \ <> CPU2 D7
                               CPU2 A8 <- / 10                   91 \ -- +5Vcc
                              CPU2 A9 <- / 11                     90 \ -> UART Tx (MSM6827L TXD)
                            CPU2 A10 <- / 12                       89 \ <- UART Rx (MSM6827L RXD)
                           CPU2 A11 <- / 13                         88 \ <- CPU A2
                          CPU2 A12 <- / 14                           87 \ <- CPU A1
                   (n/c) CPU2 A13 <- / 15                             86 \ <- CPU A0
                  (n/c) CPU2 A14 <- / 16                               85 \ <- /CE (5C66-42)
                 (n/c) CPU2 A15 <- / 17                                 84 \ <- P6-1 Lid Switch, Card R/W
                           GND -- / 18                                   83 \ <- M2
   (2.4576 MHz) (n/c) CPU2 M2 <- / 19                                     82 \ <> Card D7
                    CPU2 R/W <- / 20                                       81 \ <> Card D6
       RAM /CE ($0000-1FFF) <- / 21                                            \
(n/c) ROM /CE ($C000-xFFF) <- / 22                                     O       /
      P5 /CE ($4129 Only) <- / 23                                          80 / <> Card D5
       (GND) CPU2 +Reset -> / 24                                          79 / <> Card D4
                (GND) ? -> / 25                                          78 / -- GND
  /Internal ROM Enable -> / 26             Nintendo RF5A18              77 / <> Card D3
(5C66-68) CPU2 /Reset -> / 27      Package QFP-100, 0.65mm pitch       76 / <> Card D2
  (10k up) CPU2 /IRQ -> / 28                                          75 / <> Card D1
 (10k up) CPU2 /NMI -> / 29             Modem Controller             74 / <> Card D0
               n/c -- / 30                   CPU2                   73 / <- Tone Rx DV
                     /       O                                     72 / <- Tone Rx D8
                     \                                            71 / <- Tone Rx D4
             +5Vcc -- \ 31                                       70 / <- Tone Rx D2
      MSM6827L DATA <> \ 32                                     69 / <- Tone Rx D1
       MSM6827L /INT -> \ 33                                   68 / -> Tone Rx GT
         MSM6827L /RD <- \ 34                                 67 / -> Exp P3-19
          MSM6827L /WR <- \ 35                               66 / <> Exp P3-18
         MSM6827L EXCLK <- \ 36                             65 / <> Exp P3-17
           (n/c) $4120.2 <- \ 37                           64 / -- +5Vcc                  Orientation:
             MSM6827L AD1 <- \ 38                         63 / -> Modem P4-19             --------------------
              MSM6827L AD0 <- \ 39                       62 / -> /Phone Audio Enable          80         51
              (n/c) CPU2 D0 <- \ 40                     61 / -> /DTMF Output Enable            |         |
                     (n/c) ? <- \ 41                   60 / -> /Phone Off Hook                .-----------.
       (4.9152 MHz) Exp P3-16 <- \ 42                 59 / -> $4127.3 (n/c)                81-|O  RF5A18  |-50
                           GND -- \ 43               58 / -> /Green LED                       |  Nintendo |
                19.6608MHz Xtal -- \ 44             57 / -> /Red LED                      100-|  GCD 8C  O|-31
                      1k to Xtal -- \ 45           56 / -> MSM6827L +Reset                    \-----------'
                              GND -- \ 46         55 / <- Audio from phone line                |         |
                   (+5Vcc) $4126.0 -> \ 47       54 / <- Modem P4-28                          01         30
                 (+5Vcc) !($4126.1) -> \ 48     53 / <- Modem P4-25
                             5C66-69 -> \ 49   52 / <- Switch SW1-4             Legend:
                                  n/c -- \ 50 51 / <- Switch SW1-2              ------------------------------
                                          \     /                               --[RF5A18]-- Power, n/a
                                           \   /                                ->[RF5A18]<- RF5A18 input
                                            \ /                                 <-[RF5A18]-> RF5A18 output
                                             V                                  <>[RF5A18]<> Bidirectional
Notes:
- This chip contains its very own 65C02 CPU, with built-in ROM.
- +5Vcc pins 9, 31, 64, 91 are all connected together internally.
- GND pins 18, 43, 46, 78, 100 are all connected together internally.
- 24, 26 are GND on the PCB, but function as noted.
- 25 is GND on the PCB, but has internal protection diode from GND, suggesting it is a logic pin.
- 47, 48 are +5Vcc on the PCB, but function as noted.
- 15, 16, 17, 19, 22, 37, 40, 59 are n/c on the PCB, but function as noted.
- 41 is n/c on the PCB, but has protection diode from GND, suggesting it may have a function.
- Pin 42 (Exp 16) puts out a 4.92 MHz square wave, ~50% duty.  This is 19.6608 MHz / 4.
- CPU2 /Reset comes from RF5C66 pin 68 on new revisions and selectable with J1, J2 on old revisions:
  - J2 closed = RF5C66 pin 37 (default)
  - J1 closed = RF5C66 pin 68
- Pin 24 prevents CPU2 functioning when held high at power-on.  If the pin is then driven low, the reset vector is then fetched after that.
  - Pin 24 can be freely used as a +reset at any time this way.
- Pin 25 low at any time causes address bus to go to $FFFF and data bus shows a toggle on bits 2,5,6,7: period 208.7 usec, low for 7.93 usec.
  - Other data bits always low.
  - Shortly after applying power, the toggle has a lot of variations for a period of about 1.5 seconds, including a 225 msec gap where the bits are low.
  - The mentioned data bits all appear to have the same data.
  - Held low at power-on will fetch the reset vector later when driven high.
  - Held high at power-on, driven low later, enters the data bus toggle mode but:
    - Does not appear to fetch the reset vector when driven high after that.
    - Does execute code, possibly resuming from where it left off.
- When pin 26 is set low (default case: This pin is tied directly to GND on the PCB):
  - Internal ROM is enabled in CPU2 range $E000-FFFF.
  - Open Bus in CPU2 range $C000-DFFF.
  - Pin 22 (ROM /CE) is enabled low in range $C000-DFFF
  - This mode allows ROM expansion at $C000-DFFF, with internal ROM (and its vector table) in place.
- When pin 26 is set high:
  - Internal ROM is disabled, leaving open bus in CPU2 range $E000-FFFF.
  - Open Bus in CPU2 range $C000-DFFF.
  - Pin 22 (ROM /CE) is enabled low in the entire range $C000-FFFF.
  - This mode allows a totally custom external CPU2 ROM with its own interrupt vector table.

```

## LH5323M1 Kanji Graphic ROM

```text
                              _____  Note: Flat spot does not correspond to pin 1.
                             /     \
                     n/c -- / 12 11 \ -- n/c
           (5C66-52) A0 -> / 13   10 \ -- n/c
                CPU D0 <> / 14      9 \ <- A1 (5C66-53)
               CPU D1 <> / 15        8 \ <- A2 (5C66-54)
              CPU D2 <> / 16          7 \ <- A3 (5C66-55)
                GND -- / 17            6 \ -- GND
            CPU D3 <> / 18              5 \ <- A5 (CPU A0)
           CPU D4 <> / 19                4 \ -- n/c
          CPU D5 <> / 20                  3 \ <- A6 (CPU A1)
         CPU D6 <> / 21                    2 \ <- A7 (CPU A2)
        CPU D7 <> / 22  Nintendo LH5323M1   1 \ -- n/c
                 /        Package QFP-44       \
                 \         0.8mm pitch         /
           n/c -- \ 23                     44 / <- A8 (CPU A3)
            n/c -- \ 24   Kanji Graphic   43 / <- A13 (CPU A8)
       (GND) /OE -- \ 25       ROM       42 / <- A16 (CPU A11)
     (CPU A6) A11 -> \ 26               41 / <- A4 (5C66-56)         Orientation:
     (5C66-50) /CE -> \ 27             40 / -- n/c                   --------------------
                GND -- \ 28           39 / -- n/c                        33         23
        (CPU A7) A12 -> \ 29         38 / -- +5Vcc                        |         |
         (CPU A5) A10 -> \ 30       37 / <- A17 (5C66-57 Bankswitch)     .-----------.
                   n/c -- \ 31     36 / <- A15 (CPU A10)              34-| Nintendo O|-22
                    n/c -- \ 32   35 / -- n/c                            |  CCR-01   |
             (CPU A4) A9 -> \ 33 34 / <- A14 (CPU A9)                    | LH5323M1  |
                             \     /                                  44-|O 9528 D   |-12
                              \   /                                      '-----------/
                               \ /                                        |         |
                                V                                        01         11

Notes:
- 6 & 28 are connected together internally.
- 17 has no measurable connection to 6 & 28.
- All logic pins have protection diode from pin 17, suggesting this is the true GND.
- Pin 25 also appears as a logic pin with respect to pin 17.
- When pins 25 and 27 are both driven low, the data bus becomes an output.  Otherwise it is hi-z.
- Pins 13, 9, 8, 7, 41, 37 are controlled by the RF5C66.
  - Pins 13, 9, 8, 7, 41 are controlled with auto-increment function.
  - The value of these pins increments each M2 falling edge when the CPU is in range $5000-5FFF.
  - Pin 37 is a bankswitch, controlled by register $40B0.0
  - At reset and when reading from register $40B0, these pins reset to 0.
  - The conditions resetting or maintaining the bankswitch pin to 1 are still unknown.

```

## 8633 Famicom Network System CIC Key Chip

Unlike the NES console, the Famicom Network System appears to have the CIC key.

```text
                                 _______   _______
                                 |      \_/      |
 (To Card CIC Pin 2) Data Out <- | 1          18 | -- +5Vcc
(From Card CIC Pin 1) Data In -> | 2  O       17 | -- n/c
                          n/c -- | 3   8633   16 | -- n/c
                          n/c -- | 4          15 | -> ? (5C66-32) always observed low
                          n/c -- | 5    CIC   14 | -- n/c
                          n/c -- | 6    Key   13 | -- n/c
                        Clock -> | 7          12 | <- ? (5C66-30)
(From Card CIC Pin 11) +Reset -> | 8    U8    11 | -> /CPU R/W Inhibit (5C66-29)
                          GND -- | 9          10 | -> ? (5C66-31) always observed low
                                 |_______________|

```
- When the CIC key drives pin 11 low, this stops operation of the Famicom Network System by means of holding Card R/W high.
- The clock is 3.58 MHz, coming from RF5C66 pin 26.

## 8634A Tsuushin Card CIC Lock Chip

Unlike the NES cartridge, the tsuushin card appears to have the CIC lock.

```text
                                 _______   _______
                                 |      \_/      |
  (To FNS CIC Pin 2) Data Out <- | 1          18 | -- +5Vcc
 (From FNS CIC Pin 1) Data In -> | 2  O       17 | -- n/c
                          n/c -- | 3   8634A  16 | ?? GND
                          n/c -- | 4          15 | -- n/c
                          n/c -- | 5    CIC   14 | -- n/c
                          n/c -- | 6   Lock   13 | ?? +5V
                        Clock -> | 7          12 | ?? Card-33, n/c in Famicom Network System
           (Cap to 5V) +Reset -> | 8          11 | -> CIC Key +Reset (To FNS CIC Pin 8)
                          GND -- | 9          10 | -- n/c
                                 |_______________|

```
- +Reset is connected with a ceramic capacitor to 5V. This gives a momentary positive pulse at power-on.
- The clock is 3.58 MHz, coming from RF5C66 pin 26.
- Note: Some assumptions made on CIC chips based on similarity to F411A from Super NES.

## 8kByte CHR RAM

```text
                   _______   _______
                   |      \_/      |
           n/c? -- | 1          28 | -- +5Vcc
        PPU A12 -> | 2  O       27 | <- PPU /WR
         PPU A7 -> | 3          26 | <- +CE: U3=RF5C66 34/38, U4=PPU /A13
         PPU A6 -> | 4          25 | <- PPU A8
         PPU A5 -> | 5  LH5268  24 | <- PPU A9
         PPU A4 -> | 6    CHR   23 | <- PPU A11
         PPU A3 -> | 7    RAM   22 | <- /OE: PPU /RD
         PPU A2 -> | 8   U3/U4  21 | <- PPU A10
         PPU A1 -> | 9          20 | <- /CE: U3=PPU A13, U4=RF5C66 34/38
         PPU A0 -> | 10         19 | <> PPU D7
         PPU D0 <> | 11         18 | <> PPU D6
         PPU D1 <> | 12         17 | <> PPU D5
         PPU D2 <> | 13         16 | <> PPU D4
            GND -- | 14         15 | <> PPU D3
                   |_______________|

```

## 8kByte W-RAM

```text
                   _______   _______
                   |      \_/      |
           n/c? -- | 1          28 | -- +5Vcc
        CPU A12 -> | 2  O       27 | <- /WR: Card R/W (P6-2 Lid Switch)
         CPU A7 -> | 3          26 | <- +CE: RAM +CE
         CPU A6 -> | 4          25 | <- CPU A8
         CPU A5 -> | 5  LH5268  24 | <- CPU A9
         CPU A4 -> | 6 Built-in 23 | <- CPU A11
         CPU A3 -> | 7  W-RAM   22 | <- /OE: GND
         CPU A2 -> | 8    U5    21 | <- Card A10
         CPU A1 -> | 9          20 | <- /CE: Built-in RAM /CE
         CPU A0 -> | 10         19 | <> Card D7
        Card D0 <> | 11         18 | <> Card D6
        Card D1 <> | 12         17 | <> Card D5
        Card D2 <> | 13         16 | <> Card D4
            GND -- | 14         15 | <> Card D3
                   |_______________|

```

## 8kByte CPU2 RAM

```text
                   _______   _______
                   |      \_/      |
           n/c? -- | 1          28 | -- +5Vcc
       CPU2 A12 -> | 2  O       27 | <- /WR: CPU2 R/W
        CPU2 A7 -> | 3          26 | <- +CE: +5Vcc
        CPU2 A6 -> | 4          25 | <- CPU2 A8
        CPU2 A5 -> | 5  LH5268  24 | <- CPU2 A9
        CPU2 A4 -> | 6   CPU2   23 | <- CPU2 A11
        CPU2 A3 -> | 7    RAM   22 | <- /OE: GND
        CPU2 A2 -> | 8    U6    21 | <- CPU2 A10
        CPU2 A1 -> | 9          20 | <- /CE: CPU2 RAM /CE
        CPU2 A0 -> | 10         19 | <> CPU2 D7
        CPU2 D0 <> | 11         18 | <> CPU2 D6
        CPU2 D1 <> | 12         17 | <> CPU2 D5
        CPU2 D2 <> | 13         16 | <> CPU2 D4
            GND -- | 14         15 | <> CPU2 D3
                   |_______________|

```

## P4: Modem Module Edge Connector

```text
       Famicom     | Modem  |    Famicom
    Network System | Module | Network System
                   __________
                   |        |
          +5Vcc -- | 1   19 | <- 5A18-63
MSM6827L +Reset -> | 2   20 | <- Tone Rx GT
   MSM6827L AD0 <> | 3   21 | <- /Phone Audio Enable
            GND -- | 4   22 | -> Tone Rx DV
   MSM6827L AD1 <> | 5   23 | -> 5A18-55, Audio from phone line
   MSM6827L RXD <- | 6   24 | <- Tone Rx Xin, from 5C66-26
  MSM6827L DATA <- | 7   25 | -> 5A18-53
   MSM6827L TXD -> | 8   26 | -- GND
   MSM6827L /WR -> | 9   27 | <- /Phone Off Hook
 MSM6827L EXCLK -> | 10  28 | -> 5A18-54
   MSM6827L /RD -> | 11  29 | <> 5C66-60
          +5Vcc -- | 12  30 | <- /DTMF Output Enable
     Tone Rx D1 <- | 13  31 | <> 5C66-62           __________________________
  MSM6827L /INT <- | 14  32 | <> 5C66-61           | Modem Module           |
          +5Vcc -- | 15  33 | <- Audio from 2A03   | Orientation            |
     Tone Rx D2 <- | 16  34 | -> Audio to RF       |                        |
     Tone Rx D8 <- | 17  35 | -- GND               |    19 _____________ 36 |
     Tone Rx D4 <- | 18  36 | -- GND               |     1 |___________| 18 |
                   |________|                      |________________________|

Note: The modem module uses modem chip Oki MSM6827L and Dual Tone Receiver MC14LC5436P.

```

## P2: Tsuushin Card Connector

Note that the tsuushin card may appear to have a metric 1mm pin pitch, but in fact it has an imperial 0.040" (40 thousandths) pin pitch.

```text
Card |  | Famicom Network System
-----+--+-------------------------
  1  |--| +5Vcc
  2  |--| +5Vcc
  3  |??| n/c in JRA-PAT card, n/c in FNS
  4  |??| n/c in JRA-PAT card, FNS has 10k pull-up only.
  5  |<>| Card D0
  6  |<>| Card D1
  7  |<>| Card D2
  8  |<>| Card D3
  9  |<>| Card D4
 10  |<>| Card D5
 11  |<>| Card D6
 12  |<>| Card D7
 13  |<-| Card R/W (P6-2 Lid Switch)
 14  |<-| M2
 15  |<-| /ROMSEL
 16  |<-| CPU A0
 17  |<-| CPU A1
 18  |<-| CPU A2
 19  |<-| CPU A3
 20  |<-| CPU A4
 21  |<-| CPU A5
     |  |
     |  |
 22  |<-| CPU A6
 23  |<-| CPU A7
 24  |<-| CPU A8
 25  |<-| CPU A9
 26  |<-| CPU A10
 27  |<-| CPU A11
 28  |<-| CPU A12
 29  |<-| CPU A13
 30  |<-| CPU A14
 31  |??| n/c in JRA-PAT card, FNS has 10k pull-up only.
 32  |??| n/c in JRA-PAT card, FNS has 10k pull-up only.
 33  |??| connected to Card Lock CIC-12 in JRA-PAT, n/c in FNS
 34  |??| n/c in JRA-PAT card, n/c in FNS
 35  |->| CIC Key Reset (Card Lock CIC-11 -> FNS Key CIC-8)
 36  |->| CIC Lock-to-Key Data (Card Lock CIC-1 -> FNS Key CIC-2)
 37  |<-| CIC Key-to-Lock Data (Card Lock CIC-2 <- FNS Key CIC-1)
 38  |<-| CIC Clock (3.58 MHz, from 5C66.26)
 39  |??| n/c in JRA-PAT card, FNS has 10k pull-up only.
 40  |<-| RAM +CE (n/c in JRA-PAT card)
 41  |--| GND
 42  |--| GND

```

## P3: Expansion Connector

```text
                 Outside    |  FNS  |    Outside                   _____________________
                            _________                             / Orientation        /|
                            |       |                            /____________________/ |
                    /IRQ -> | 1  20 | -- +5Vcc                   |o|_| ==      |_||_|o|/
(95.94kHz Clock) 5C66-79 <- | 2  19 | -> 5A18-67                 \_  _  _ _||_  _  _ _/|
                 5C66-78 -> | 3  18 | -> 5A18-66                  |-| |    || HVC-050| |
                 5C66-77 <- | 4  17 | -> 5A18-65                  |-|_|    ||        | |
                 5C66-76 <- | 5  16 | -> 5A18-42 (4.92MHz Clock)  |        ||        | |
                 5C66-75 <- | 6  15 | <> 5C66-64                  |  20 __/__\__ 11  | |
                            |       |                             |o  1 |______| 10 o| |
                 5C66-74 -> | 7  14 | <> 5C66-65                  | ________________ | |
                 5C66-73 -> | 8  13 | <> 5C66-66                  |/_______________/|| |
                 5C66-72 -> | 9  12 | <> 5C66-67                  ||______________|/ | |
                     GND -- | 10 11 | <- 5C66-71                  |                  | |
                            |_______|                             |      ______      | |
                                                                  |o    | |    |    o| |
                                                                  \_____|/     |_____|/

```

## P5: Expansion Connector

Note: This connector only exists on old revisions of Famicom Network System. Expansion P5 /CE is activated low specifically at CPU2 address $4129.

```text
Outside |  | Famicom Network System
--------+--+-------------------------
    9   |--| GND
    8   |<>| CPU2 D5
    7   |<>| CPU2 D4
    6   |<>| CPU2 D3
    5   |<>| CPU2 D2
    4   |<>| CPU2 D1
    3   |<>| CPU2 D0
    2   |<-| Expansion P5 /CE
    1   |--| +5V

```

## CN07: Dataship 1200 AV Port

```text
Outside    |FNS|    Outside
            ___
           /   |
  +5Vcc -- |1|2| -> audio
    n/c -- |3|4| -> video
    GND -- |5|6| -- GND
           \___|

```

The Dataship 1200 uses the same port for AV as the Game Boy link cable. The official AV cable uses pins 2, 4, and 5. The official RF cable uses pins 1, 2, 4, 5, and 6. Note that pin 4 is frequently missing from link cables, so care must be taken to find a compatible aftermarket cable when making a reproduction AV cable. See Also
- Famicom Network Controller
- https://forums.nesdev.org/viewtopic.php?f=9&t=18530
- https://niwanetwork.org/wiki/Tsuushin_Cartridge
- https://niwanetwork.org/wiki/List_of_Famicom_Network_System_software

# Famicom cartridge dimensions

Source: https://www.nesdev.org/wiki/Famicom_cartridge_dimensions

This page documents the dimensions of common Famicom cartridges, including their cartridge shell and their corresponding PCB type. The source files are open-source and available on Github.

TODO: identify more cartridge shell forms

## Famicom cartridge shell outline

### Small cartridge form

#### HVC-TxROM

TODO: measure and publish dimensions

#### HVC-NROM/CNROM

TODO: measure and publish dimensions

### Large cartridge form

#### HVC-ExROM

TODO: measure and publish dimensions

### Miscellaneous cartridge forms

TODO: document and measure other forms

## Famicom cartridge PCB outline

These outlines of different cartridge PCB types are based on the most space-filling variant, so that designers may choose to cut off unused portions that their designs may not need. Some outlines of cartridges with no maximally space filling PCB are thus modified to be such, with measurements being based on adjacent types made by the same producer.

Each cartridge type varies in how the 60 pin card edge is implemented. The pin pitch is 2.54mm, with 2 rows of 30 pads. Each pad may be uniform in dimensions, or slightly thicker and longer for power/ground.

### HVC-Ax/Fx/Px/Sx/TxROM (MMC1-4 mapper boards)

This outline is based on measurements from a HVC-TGROM-01 type cartridge PCB, compatible with any cartridge shell that supports any HVC-Ax/Fx/Px/Sx/TxROM PCB or similar/bigger. These measurements are measured with vernier calipers with 0.05 mm accuracy. Note that this outline also details where the soldermask ends for the card edge.

| Dimensions |
| Designator | Dimensions in mm (±0.05 mm) | Description |
| A | 90 | Board width |
| A.1 | 78.4 | Card edge width |
| A.2 | 81 | Notched width |
| A.2.1 | 43 | Inset board width 1 |
| A.2.2 | 33 | Inset board width 2 |
| B | 46.1 | Board height |
| B.1 | 23.2 | Inset board height 1 |
| B.2 | 20.9 | Inset board height 2 |
| B.3 | 10.7 | Card edge depth |
| C | 1.2 | Board thickness |
| D.1 | 3 | Card edge base to pad top |
| D.2 | 4 | Card edge base to soldermask keepout |
| D.3 | 6.7 | Power pad height |
| D.4 | 5.7 | Signal pad height |
| E.1 | 0.57 | Power pad to card edge side |
| E.2 | 1.57 | Signal pad to card edge side |
| E.3 | 2.6 | Power pad width |
| E.4 | 1.6 | Signal pad width |
| E.5 | 0.94 | Space between pads |
| E.6 | 2.54 | Pad spacing |

### HVC-ExROM

TODO: measure and publish dimensions

### HVC-N/Cx/Gx/UxROM 01-05 (discrete mapper boards)

This outline is based on measurements from a HVC-CNROM-256K-01 type cartridge PCB, augmented with dimensions from a HVC-TGROM-01 type PCB. This is compatible with any cartridge shell that supports any HVC-N/Cx/Gx/UxROM 01-05 PCB or similar/bigger. These measurements are measured with vernier calipers with 0.05 mm accuracy. Note that this outline also details where the soldermask ends for the card edge.

| Dimensions |
| Designator | Dimensions in mm (±0.05 mm) | Description |
| A | 90 | Board width |
| A.1 | 78.4 | Card edge width |
| A.2 | 68 | Notched width |
| A.2.1 | 31.5 | Inset board width 1 |
| A.2.2 | 26.5 | Inset board width 2 |
| A.3 | 39.5 | Hole 1 to board edge |
| A.4 | 1/2 of A | Hole 2 to board edge |
| A.5 | 3 | Hole 1 diameter |
| A.6 | 5 | Hole 2 diameter |
| B | 46.1 | Board height |
| B.1 | 23.2 | Inset board height 1 |
| B.2 | 20.9 | Inset board height 2 |
| B.3 | 10.7 | Card edge depth |
| B.4 | 19.8 | Hole 1 center height |
| B.5 | 10.3 | Hole 2 center height |
| C | 1.2 | Board thickness |
| D.1 | 3 | Card edge base to pad top |
| D.2 | 4 | Card edge base to soldermask keepout |
| D.3 | 6.7 | Power pad height |
| D.4 | 5.7 | Signal pad height |
| E.1 | 0.57 | Power pad to card edge side |
| E.2 | 1.57 | Signal pad to card edge side |
| E.3 | 2.6 | Power pad width |
| E.4 | 1.6 | Signal pad width |
| E.5 | 0.94 | Space between pads |
| E.6 | 2.54 | Pad spacing |

# Category:Flash Cartridge

Source: https://www.nesdev.org/wiki/Flashcart



# GxROM

Source: https://www.nesdev.org/wiki/GNROM

GxROM

| Company | Nintendo, others |
| Boards | GNROM,MHROM |
| PRG ROM capacity | 128KiB (512KiB oversize) |
| PRG ROM window | 32KiB |
| PRG RAM capacity | None |
| CHR capacity | 32KiB (128KiB oversize) |
| CHR window | 8KiB |
| Nametable arrangement | Fixed H or V, controlled by solder pads |
| Bus conflicts | Yes |
| IRQ | No |
| Audio | No |
| iNES mappers | 066 |
NESCartDB

| iNES 066 |
| GNROM |
| MHROM |

The designation GxROM refers to Nintendo cartridge boards labeled NES-GNROM and NES-MHROM (and their HVCcounterparts), which use discrete logic to provide up to four 32 KB banks of PRG ROM and up to four 8 KB banks of CHR ROM. The iNESformat assigns mapper 66 to these boards.

The Jaleco board assigned to iNES Mapper 140is sometimes confused with GNROM, as they are very similar but with the bankswitch register in a different location.

Example games:
- Doraemon
- Dragon Power
- Gumshoe
- Thunder & Lightning
- Super Mario Bros. + Duck Hunt (MHROM)

## Board Types

The following GxROM boards are known to exist:

| Board | PRG ROM | CHR |
| GNROM | 128 KB | 32 KB ROM |
| MHROM | 64 KB | 16 / 32 KB ROM |

## Banks
- CPU $8000-$FFFF: 32 KB switchable PRG ROM bank
- PPU $0000-$1FFF: 8 KB switchable CHR ROM bank

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxPP xxCC
  ||   ||
  ||   ++- Select 8 KB CHR ROM bank for PPU $0000-$1FFF
  ++------ Select 32 KB PRG ROM bank for CPU $8000-$FFFF

```

Bit 5 is not used on MHROM, which supports only 64 KB PRG.

## Solder pad config
- Horizontal mirroring : 'H' disconnected, 'V' connected.
- Vertical mirroring : 'H' connected, 'V' disconnected.

## Hardware

The GNROM board contains a 74HC161binary counter used as a quad D latch (4-bit register) to select the current PRG and CHR banks. MHROM, on the other hand, was often a glop-top, as it was used for pack-in games, such as the Super Mario Bros./Duck Hunt multicart, and needed to be very inexpensive to produce in huge quantities.

## Variants

Placing the bank register in $6000-$7FFF instead of $8000-$FFFF gives mapper 140. The Color Dreamsboard leaves the port at $8000-$FFFF, swaps the nibbles, expands CHR by two bits, and adds two bits for charge pump control.

Theoretically the bank select register could be implemented with a 74HC377octal D latch, allowing up to 512 KB of PRG ROM and 128 KB of CHR ROM. There are a large numberof other variants on GNROM, where the bits or the writeable address were moved around.

## See also
- NES Mapper Listby Disch
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.

# MMC6

Source: https://www.nesdev.org/wiki/HKROM

MMC6
HxROM

| Company | Nintendo |
| Games | 2 in NesCartDB |
| Complexity | ASIC |
| Boards | HKROM |
| Pinout | MMC6 pinout |
| PRG ROM capacity | 512K |
| PRG ROM window | 8K |
| PRG RAM capacity | 1K |
| PRG RAM window | 1K |
| CHR capacity | 256K |
| CHR window | 1K + 2K |
| Nametable arrangement | H or V, switchable |
| Bus conflicts | No |
| IRQ | Yes |
| Audio | No |
| iNES mappers | 004 |

The Nintendo MMC6 is a mapperASICused in Nintendo's NES-HKROM Game Pak board. This board, along with most common TxROMboards (which use the Nintendo MMC3) are assigned to iNES Mapper 004. The MMC3C and the MMC6 are alike, except the MMC6 has 1 KB of internal PRG RAM with different write/enable controls. This page only explains the differences, see MMC3for full details on the rest of the mapper.

The NES 2.0 submapper 004:1was assigned to disambiguate MMC6 from the MMC3 mapper it shares an iNES mapper with.

This chip first appeared in December 1990. A total of two commercial games were released using the MMC6:
- StarTropics
- Zoda's Revenge: StarTropics II

## Banks
- CPU $7000-$7FFF: 1 KB PRG RAM, mirrored
- CPU $8000-$9FFF (or $C000-$DFFF): 8 KB switchable PRG ROM bank
- CPU $A000-$BFFF: 8 KB switchable PRG ROM bank
- CPU $C000-$DFFF (or $8000-$9FFF): 8 KB PRG ROM bank, fixed to the second-last bank
- CPU $E000-$FFFF: 8 KB PRG ROM bank, fixed to the last bank
- PPU $0000-$07FF (or $1000-$17FF): 2 KB switchable CHR bank
- PPU $0800-$0FFF (or $1800-$1FFF): 2 KB switchable CHR bank
- PPU $1000-$13FF (or $0000-$03FF): 1 KB switchable CHR bank
- PPU $1400-$17FF (or $0400-$07FF): 1 KB switchable CHR bank
- PPU $1800-$1BFF (or $0800-$0BFF): 1 KB switchable CHR bank
- PPU $1C00-$1FFF (or $0C00-$0FFF): 1 KB switchable CHR bank

## Registers

The MMC6 has 4 pairs of registers at $8000-$9FFF, $A000-$BFFF, $C000-$DFFF, and $E000-$FFFF - even addresses ($8000, $8002, etc.) select the low register and odd addresses ($8001, $8003, etc.) select the high register in each pair. Only $8000 and $A001 are covered here. For the rest of the registers, see MMC3.

### Bank select ($8000-$9FFE, even)

```text
7  bit  0
---- ----
CPMx xRRR
|||   |||
|||   +++- Specify which bank register to update on next write to Bank Data register
||+------- PRG RAM enable
|+-------- PRG ROM bank configuration (0: $8000-$9FFF swappable, $C000-$DFFF fixed to second-last bank;
|                                      1: $C000-$DFFF swappable, $8000-$9FFF fixed to second-last bank)
+--------- CHR ROM bank configuration (0: two 2 KB banks at $0000-$0FFF, four 1 KB banks at $1000-$1FFF;
                                       1: four 1 KB banks at $0000-$0FFF, two 2 KB banks at $1000-$1FFF)

```

### PRG RAM protect ($A001-$BFFF, odd)

```text
7  bit  0
---- ----
HhLl xxxx
||||
|||+------ Enable writing to RAM at $7000-$71FF
||+------- Enable reading RAM at $7000-$71FF
|+-------- Enable writing to RAM at $7200-$73FF
+--------- Enable reading RAM at $7200-$73FF

```

## Hardware

The MMC6 exists in a 64-pin TQFP package. At least two revisions exist [ citation needed ] , though only MMC6B has been observed.

The PRG RAM protect bits control mapping of two 512B banks of RAM. If neither bank is enabled for reading, the $7000-$7FFF area is open bus. If only one bank is enabled for reading, the other reads back as zero. The write-enable bits only have effect if that bank is enabled for reading, otherwise the bank is not writable. Both banks may be enabled for reading (and optionally writing) at the same time.

When PRG RAM is disabled via $8000, the mapper continuously sets $A001 to $00, and so all writes to $A001 are ignored.

# Jissen Mahjong controller

Source: https://www.nesdev.org/wiki/Jissen_Mahjong_controller

This is a 21-button controller used by the following Capcom games:
- Ide Yousuke Meijin no Jissen Mahjong
- Ide Yousuke Meijin no Jissen Mahjong 2

## Button layout

| A | B | C | D | E | F | G | H | I | J | K | L | M | Ⓝ |
|  | SEL | ST | カン | ポン | チー | リーチ | ロン |

The カン (kan), ポン (pon), チー (chii), リーチ (riichi)and ロン (ron)buttons are Mahjong-related.

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xRRS
      |||
      ||+- Strobe
      |+-- Row selection (bit 0)
      +--- Row selection (bit 1)

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxx xxDx
       |
       +- Serial data

```

Reading the buttons is very similar to the standard controller, but one of three rows is selected for loading values into the shift register depending on the contents of the two Row selection pins while the Strobe bit is high.

After toggling the strobe bit from 1 to 0, the controller will return 8 bits worth of data (1 bit per read) based on the "row selection" bits.

```text
Row 3 returns: <empty>, ロン, リーチ, チー, ポン, カン, Start, Select
Row 2 returns: H, G, F, E, D, C, B, A
Row 1 returns: <empty>, <empty>, N, M, L, K, J, I
Row 0 returns the bitwise OR of rows 1 and 2.

```

Like the standard controller, buttons return 1 when extant and held down, 0 otherwise.

The buttons are arranged as a 3x8 keyboard matrix similar to the Famicom keyboard. A variety of diodes, resistors, and an NPN BJT pull one of the rows low; the eight columns are then loaded into the same 4021 shift register as used on the standard controller. [1]The Serial Input to the 4021 is tied to ground; all subsequent reads beyond the first eight should return 0V (logic 1 due to the 74368 inside the Famicom).

Like the Family BASIC Keyboard, there are no diodes to prevent ghosting, and pressing three buttons simultaneously could cause the incorrect detection of a 4th button press.

There are (at least) two hardware revisions of the PCB inside, [1]but no behavioral differences between the two are known nor any believed to exist.

## References
- ↑(?whose?) reverse engineered schematic
- EveryNES§Jissen Mahjong controller specs
- Koi-Koi's pictures on the forum

# KrzysioCart

Source: https://www.nesdev.org/wiki/KrzysioCart

The KrzysioCart (Chris' MicroSD Cartridge) is a CPLD and SD card based Flash Cartridgemade by krzysiobal. It is intended to be a lower budget flash cartridge compared to the Everdrive. The cartridge targets the most commonly used mappers, and supports about 82% of the NES / Famicom game library. [1]

Specifications:
- PRG-ROM size: 1 MB
- CHR size: 256 KB
- PRG-RAM size: 8 KB

Product Links:
- Website: http://krzysiobal.com/krzysiocart/
- Nesdev Forum Topic: https://forums.nesdev.org/viewtopic.php?t=15757
- Ebay: https://www.ebay.com/itm/392943601934

## Mapper Compatibility

The KrzysioCart supports a relatively small number of mappers, specifically supporting only the most popular mappers and a few personal choices.

- NROM
  - iNES Mapper 000
- MMC1
  - iNES Mapper 001
- UNROM
  - iNES Mapper 002
- CNROM
  - iNES Mapper 003
- MMC3
  - iNES Mapper 004
- ANROM
  - iNES Mapper 007
- K-1029
  - iNES Mapper 015
- UNROM 512
  - iNES Mapper 030
- Camerica
  - iNES Mapper 071
- Camerica Quattro
  - iNES Mapper 232

Supported mappers:

| 000 | 001 | 002 | 003 | 004 | 005 | 006 | 007 | 008 | 009 | 010 | 011 | 012 | 013 | 014 | 015 |
| 016 | 017 | 018 | 019 | 020 | 021 | 022 | 023 | 024 | 025 | 026 | 027 | 028 | 029 | 030 | 031 |
| 032 | 033 | 034 | 035 | 036 | 037 | 038 | 039 | 040 | 041 | 042 | 043 | 044 | 045 | 046 | 047 |
| 048 | 049 | 050 | 051 | 052 | 053 | 054 | 055 | 056 | 057 | 058 | 059 | 060 | 061 | 062 | 063 |
| 064 | 065 | 066 | 067 | 068 | 069 | 070 | 071 | 072 | 073 | 074 | 075 | 076 | 077 | 078 | 079 |
| 080 | 081 | 082 | 083 | 084 | 085 | 086 | 087 | 088 | 089 | 090 | 091 | 092 | 093 | 094 | 095 |
| 096 | 097 | 098 | 099 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | 108 | 109 | 110 | 111 |
| 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119 | 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
| 128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 | 139 | 140 | 141 | 142 | 143 |
| 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 |
| 160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 |
| 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 |
| 192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 | 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 |
| 208 | 209 | 210 | 211 | 212 | 213 | 214 | 215 | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 |
| 224 | 225 | 226 | 227 | 228 | 229 | 230 | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 |
| 240 | 241 | 242 | 243 | 244 | 245 | 246 | 247 | 248 | 249 | 250 | 251 | 252 | 253 | 254 | 255 |

# List of games that run code from outside of PRG-ROM

Source: https://www.nesdev.org/wiki/List_of_games_that_run_code_from_outside_of_PRG-ROM

This is an incomplete list of games that execute code from CPU addresses $0000 to $7fff , i.e., from outside of PRG-ROM.
- The 3-D Battles of WorldRunner
- Action 52
- Action 53 (all volumes)
- The Addams Family
- The Adventures of Gilligan's Island
- The Adventures of Rad Gravity
- Arch Rivals
- Athletic World
- Attack of the Killer Tomatoes
- Barbie
- The Bard's Tale
- Batman: Return of the Joker (from PRG RAM)
- Battletoads
- Beetlejuice
- The Blue Marlin
- A Boy and His Blob: Trouble on Blobolonia
- Burai Fighter
- Cabal
- California Games
- Captain Skyhawk
- Castelian
- Chessmaster
- Conflict
- Cool World
- Cowboy Kid
- Crash 'n the Boys: Street Challenge
- Crystalis
- Dance Aerobics
- Deadly Towers
- Death Race
- Destiny of an Emperor
- Digger T. Rock: Legend of the Lost City
- Disney's The Jungle Book
- Double Dragon
- Double Dragon II: The Revenge
- Double Dragon III: The Sacred Stones
- Dragon Warrior
- Dragon Warrior III
- Dragon Warrior IV
- Dudes with Attitude
- Elevator Action
- Family Jockey
- Fantasy Zone
- Ferrari Grand Prix Challenge
- Final Combat
- Fleet Commander
- The Flintstones: The Rescue of Dino & Hoppy
- The Flintstones: Surprise at Dinosaur Peak
- Flying Warriors
- Fun House
- G.I. Joe: A Real American Hero
- G.I. Joe: The Atlantis Factor
- The Game Genie ROM (from zero page)
- Gauntlet
- Goal!
- Golgo 13: Top Secret Episode
- The Great Wall
- Guerrilla War
- Haunted: Halloween '85
- Hell Fighter
- High Speed
- Home Alone 2: Lost in New York
- Hydlide
- Impossible Mission II
- The Incredible Crash Dummies
- Indiana Jones and the Last Crusade
- Indiana Jones and the Temple of Doom
- Iron Tank
- Ironsword: Wizards & Warriors II
- The Jetsons: Cogswell's Caper!
- Kabuki Quantum Fighter
- Kickle Cubicle
- Kid Icarus
- King Neptune's Adventure
- King of Kings: The Early Years
- King's Quest V: Absence Makes the Heart Go Yonder!
- Kirby's Adventure
- Kiwi Kraze (from main RAM)
- The Krion Conquest
- The Legend of Zelda
- Lemmings
- The Lone Ranger
- M.C. Kids
- Mach Rider
- Magic Johnson's Fast Break
- Major League Baseball
- Maniac Mansion
- Mappy-Land
- Michael Andretti's World GP
- Micro Machines
- Might and Magic Book One: The Secret of the Inner Sanctum
- Mission: Impossible
- Monster Party
- Monster Truck Rally
- NARC
- Nigel Mansell's World Championship Racing
- A Nightmare on Elm Street
- Nintendo World Cup
- Overlord
- Pictionary
- Pinball Quest
- Pirates!
- Portopia Renzoku Satsujin Jiken
- Qix
- Quattro Adventure
- Quattro Arcade
- Quattro Sports
- River City Ransom
- Rocket Ranger
- Section Z
- Sesame Street: 1-2-3
- Sesame Street: A-B-C
- Silver Surfer
- The Simpsons: Bart vs. the Space Mutants
- The Simpsons: Bart vs. the World
- The Simpsons: Bartman Meets Radioactive Man
- Skate or Die 2: The Search for Double Trouble
- Skull & Crossbones
- Sky Shark
- Slalom (from zero page)
- Snake Rattle 'n' Roll
- Snow Brothers
- Solstice: The Quest for the Staff of Demnos
- Spot: The Video Game
- Stadium Events / World Class Track Meet
- Street Cop
- Strike Wolf
- Super Dodge Ball
- Super Jeopardy!
- Super Spike V'Ball
- Super Spy Hunter
- Super Team Games
- Target: Renegade
- Tecmo World Wrestling
- Teenage Mutant Ninja Turtles II: The Arcade Game
- Teenage Mutant Ninja Turtles III: The Manhattan Project
- To the Earth
- Tom and Jerry
- Top Gun: The Second Mission
- Total Recall
- Treasure Master
- Trolls on Treasure Island
- The Untouchables
- Videomation
- Wally Bear and the NO! Gang
- Wheel of Fortune: Featuring Vanna White
- Winter Games
- Wizards & Warriors
- Wizards & Warriors III: Kuros: Visions of Power
- Wolverine
- World Champ
- World Games

## See also
- Tricky-to-emulate games

# GxROM

Source: https://www.nesdev.org/wiki/MHROM

GxROM

| Company | Nintendo, others |
| Boards | GNROM,MHROM |
| PRG ROM capacity | 128KiB (512KiB oversize) |
| PRG ROM window | 32KiB |
| PRG RAM capacity | None |
| CHR capacity | 32KiB (128KiB oversize) |
| CHR window | 8KiB |
| Nametable arrangement | Fixed H or V, controlled by solder pads |
| Bus conflicts | Yes |
| IRQ | No |
| Audio | No |
| iNES mappers | 066 |
NESCartDB

| iNES 066 |
| GNROM |
| MHROM |

The designation GxROM refers to Nintendo cartridge boards labeled NES-GNROM and NES-MHROM (and their HVCcounterparts), which use discrete logic to provide up to four 32 KB banks of PRG ROM and up to four 8 KB banks of CHR ROM. The iNESformat assigns mapper 66 to these boards.

The Jaleco board assigned to iNES Mapper 140is sometimes confused with GNROM, as they are very similar but with the bankswitch register in a different location.

Example games:
- Doraemon
- Dragon Power
- Gumshoe
- Thunder & Lightning
- Super Mario Bros. + Duck Hunt (MHROM)

## Board Types

The following GxROM boards are known to exist:

| Board | PRG ROM | CHR |
| GNROM | 128 KB | 32 KB ROM |
| MHROM | 64 KB | 16 / 32 KB ROM |

## Banks
- CPU $8000-$FFFF: 32 KB switchable PRG ROM bank
- PPU $0000-$1FFF: 8 KB switchable CHR ROM bank

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxPP xxCC
  ||   ||
  ||   ++- Select 8 KB CHR ROM bank for PPU $0000-$1FFF
  ++------ Select 32 KB PRG ROM bank for CPU $8000-$FFFF

```

Bit 5 is not used on MHROM, which supports only 64 KB PRG.

## Solder pad config
- Horizontal mirroring : 'H' disconnected, 'V' connected.
- Vertical mirroring : 'H' connected, 'V' disconnected.

## Hardware

The GNROM board contains a 74HC161binary counter used as a quad D latch (4-bit register) to select the current PRG and CHR banks. MHROM, on the other hand, was often a glop-top, as it was used for pack-in games, such as the Super Mario Bros./Duck Hunt multicart, and needed to be very inexpensive to produce in huge quantities.

## Variants

Placing the bank register in $6000-$7FFF instead of $8000-$FFFF gives mapper 140. The Color Dreamsboard leaves the port at $8000-$FFFF, swaps the nibbles, expands CHR by two bits, and adds two bits for charge pump control.

Theoretically the bank select register could be implemented with a 74HC377octal D latch, allowing up to 512 KB of PRG ROM and 128 KB of CHR ROM. There are a large numberof other variants on GNROM, where the bits or the writeable address were moved around.

## See also
- NES Mapper Listby Disch
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.

# Make sram

Source: https://www.nesdev.org/wiki/Make_sram

This program make_sram.py creates .sav files for all iNESformat ROMs in a folder and its subfolders that have the battery bit turned on. It's useful for users of PowerPak, which can't create files by itself. It is written in Python and has been tested on Python 2.6 on Ubuntu Karmic and (to a lesser extent) Python 2.5 on Windows. If you have trouble getting to run under your copy of Python, tell me about it hereor on the forum.

```text
#!/usr/bin/env python
"""
make_sram
See versionText below for copyright information.

Change log:
0.02 (2009-12-30): fixed a 'with' statement that I missed
0.01 (2009-12-29): initial release
"""
import os
# I'd use python 2.5's with statement, but the last time I posted a
# python program on pocket heaven, people were complaining about not
# being able to run my program on python 2.4.

helpText = """Usage: make_sram [foldername]
Makes empty 8192 byte .sav files for .nes files that need it.
"""
versionText = """make_sram 0.02 (2009-12-30)

Copyright 2009 Damian Yerrick
Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
"""

def findAllRoms(folder='.'):
    pathnames = []
    for (root, folders, files) in os.walk(folder):
        for filename in files:
            if filename.lower().endswith('.nes'):
                pathnames.append(os.path.join(root, filename))
    return pathnames

def getINESBatteryBit(filename):
    infp = None
    try:
        infp = open(filename, 'rb')
        infp.seek(6)
        c = ord(infp.read(1))
        return (c & 0x02) != 0
    finally:
        if infp is not None:
            infp.close()

def getSavName(filename):
    (folder, filename) = os.path.split(filename)
    (filename, ext) = os.path.splitext(filename)
    return os.path.join(folder, filename + '.sav')

def processFolder(folder='.', dry=False):
    # First find the corresponding .sav filename for each .nes rom
    # with a battery bit
    savFiles = [getSavName(filename)
                for filename in findAllRoms(folder)
                if getINESBatteryBit(filename)]
    # Then find the ones that don exits (like tires)
    savFiles = [filename
                for filename in savFiles
                if not os.path.exists(filename)]
    blankSavData = chr(0) * 8192
    for filename in savFiles:
        print filename
        if not dry:
            r = open(filename, 'wb')
            r.write(blankSavData)
            r.close()

def main(argv=None):
    if argv is None:
        import sys
        argv = sys.argv
    if len(argv) > 1:
        folderName = argv[1]
        if folderName in ('--help', '-?', '/?', '-h'):
            print helpText
            return
        elif folderName == '--version':
            print versionText
            return
    else:
        folderName = '.'
    processFolder(folderName)

if __name__=='__main__':
    main()

```

# NES Classic Controller for Wii

Source: https://www.nesdev.org/wiki/NES_Classic_Controller_for_Wii

This tutorial will instruct you in how to build yourself a Mayflash NES/SNES-to-Wiimote controller adapter with a full fledged standard 7-pin NES connector instead of the provided DE-9 pin connector.

## Background

In late 2009, a Chinese peripheral manufacturer called Mayflash released an interesting controller adapter for the Wii. With this adapter, one could use NES or Super NES controllers on the Wii by connecting them to the adapter and then the adapter to a Wii Remote, essentially fooling the Wii into thinking these older controllers are in fact the Wii Classic Controller.

Using NES or Super NES controllers on a Wii is really a matter of preference and nostalgia. Holding the Wii Remote on its side emulates the style of control that the NES provided. Holding a real NES controller is a lot more satisfying. If you didn't grow up with an NES, getting used to the brick design can be difficult. For you guys, I recommend the NES2 Dogbone. These are more difficult to find, but definitely more comfortable. The Wii Classic Controller is basically a dumbed down copy of the SNES pad with two thumbsticks attached. Most games that support the Classic Controller do not need either thumbstick and they just sort of get in the way. Most retro gamers agree that the original SNES controller is one of the best ever designed, so why wouldn't you want to use it on the Wii?

The idea is to allow you to plug in your oldschool controllers both on the Wii and their original hardware. But unfortunately, A: Unfortunately, Mayflash designed their adapter to use a DE-9pin connector for NES controller functionality. In Asia, most clones of the NES hardware (commonly called Famiclones) use this type of controller connector. In America, Europe and even Japan, the Nintendo hardware used a NES 7-pin connector instead.

In the 1980s, many videogame systems including the Atari 2600, Commodore 64 and even Sega Genesis used a standard nine pin controller port called a DE-9, which had a simple parallel interface for the buttons. This meant that many controllers were interchangeable with each other, allowing gamers to use Genesis controllers to play Atari games.

However, the Nintendo Entertainment System (NES) used a proprietary 7-pin controller plug with an SPI-like serial interface. The two plugs are shaped very differently. This mod project involves replacing the DE-9 pin connector with a standard NES 7-pin.

The Retroports that Retrozone sell are marketed as NES & SNES to Wii adapters, but they are in reality only NES & SNES to Gamecube adapters. This means that they work on all Gamecube games that support digital control, but on the Wii they only work with games that alllow the use of Gamecube controllers. Increasingly, more games are being released on the Wii that support the Wii Remote on its side and Classic Controller only, such as Tetris, Dr. Mario, Mega Man 9, and Mega Man 10. Also, since the Mayflash adapter plugs into the Wii Remote and not the Wii itself, it sort of makes the NES/SNES wired controllers wireless, preventing trip hazards.

The Mayflash SNES controller has the correct size and pinout and does not need replacing.

## Materials

You'll need a Wii console, a Wii Remote, and Mayflash NES/SNES to Wii adapter - various online stores, ebay NES and SNES controller - check your local used game stores. eBay has them, but be careful of knock-offs. Always look for Nintendo's logo. The design patents for the controllers have expired, but knock-offs will never have Nintendo written on them.

salvaged female NES 7pin controller plug - Out of an old front-loading NES or a Four Score accessory. The ideal place to find one is if you have or know someone who has a dead/unwanted NES. Alternatively, check ebay for the part itself that someone has already removed or buy an NES for parts. Getting it out of the system is real easy - Simply remove the screws holding the case together, remove the RF shield and simply unplug one of the controller ports. Finally unscrew both screws on the black plastic piece that keeps the 7pin connectors in place.

small star screwdriver - your garage/junk drawer/hardware store. soldering iron - hardware store. desoldering pump/braid - hardware store. scissors - your kitchen/department store glue - may not be needed, depending on your skill. a sharp work knife - your kitchen/craft store. small pair of pliers - garage/hardware store.

## Procedure
- Disclaimer: Following this tutorial should allow you to achieve desirable results, but that being said I take no responsibility for following my advice here. By continuing to read this you take full responsibility of damaging your hardware, burning or cutting yourself. Don't be a jackass and you should be fine.

1. Take your Mayflash NES/SNES to Wii adapter apart by removing the four screws on the back. Set aside the top part of the shell along with the four small screws and the turbo fire button in a safe place, preferably in a bowl so you don't lose anything.

2. Unhook the cord and remove the PCB from the bottom tray. Place bottom tray in bowl with the other side and the screws.

3. Carefully examine the PCB. You'll notice that the Famiclone DE-9 plug is connected to the PCB using all nine pins, even though Famicom/NES controllers only use five pins. On the real hardware, the two extra pins to make of the 7pin connector were only used by specialty controllers such as the Zapper or PowerGlove. You will notice a pattern that looks like this:

```text
    _________
1 \ o o o o o / 5
   \ o o o o /
   6 `"""""' 9

```

Note that this diagram shows the correct pins that face away from the PCB. In other words, the pins that are normally visible and plug into DE-9 controllers.

4. Use a soldering iron and soldering pump/braid to heat and remove the solder that holds the DE-9 pin plug. This is a slow process, be patient: Don't try to forcefully remove the pins as that will most likely result in damaging the entire PCB.

5. Once you have the old DE-9 pin adapter removed, either discard or keep for a future project. Either way, you're done with the stock DE-9 pin connector for now.

6. Prepare your salvaged NES 7pin adapter. If you're using one taken from an old NES, you can easily finish this project just by soldering the correctly colored wires. Wires may be different for third party NES female plugs, I'm not sure.

I number the controller pinsthis way, with, the wire color and the job each does:

```text
      .-
GND - |1\
CLK - |32\ - +5V
OUT - |54| - D3
 D0 - |76| - D4
      '--'

```
- Brown Ground
- White 5 Volts
- Red Clock
- Purple Not Used on standard controllers.
- Orange Latch/Strobe
- Blue Not Used on standard controllers.
- Yellow Data

You will need only the brown, white, red, orange and yellow wires. Clip the blue and purple (used for expansion controllers like the Zapperand Power Pad) right out of the way so you don't get confused by them.

7. Back where the DE-9 pin adapter was, remove any excess solder and ensure you can place wires in each small hole. Here is the DE-9 standard layout for most Famiclone DE-9 connectors, including the Mayflash:
- N/A
- DATA
- LATCH/STROBE
- CLOCK
- N/A
- +5V
- N/A
- GND
- N/A

Reading the pins of a DE-9 is simple. The top row is 1-5 and the bottom is 6-9.

DE-9 pins you need to solder to are in represented by "o". "x" shows pins that you can leave disconnected.

```text
    __________
1 \ x o o o x / 5
   \ o x o x /
    6 `"""' 9

```

Just to double check specifically, solder the NES wires to these places:
- 2 Yellow
- 3 Orange
- 4 Red
- 6 White
- 8 Brown

8. Simply solder away. Take your time. Remember to solder on the underside only.

9. Before reassembly, try it out. Your oldschool NES controllers should now work perfectly.

10. Depending on where you want to place the NES 7pin connector, use your knife to cut away plastic in the way and possibly glue it in place. On my adapter I simply cut away enough plastic for the new NES connector to fit snugly in place and tightened up the screws to hold it in place. No plug, no mess.

11. Boot up your favorite NES, TurboGrafx, Select Genesis WiiWare or Wii games including both Megaman 9 and 10 and enjoy them using an authentic NES controller - that will still also work with the real NES!

## Video

http://www.youtube.com/watch?v=WYWVrFq3Cu4

## References
- SatoshiMatrix's post on BBS
- Newer version of tutorial; please import pictures

# NES cartridge dimensions

Source: https://www.nesdev.org/wiki/NES_cartridge_dimensions

This page documents the dimensions of most licensed NES cartridges, including their cartridge shell and their corresponding PCB type. The source files are open-source and available on Github.

## NES cartridge shell outline

TODO: measure and publish dimensions

## NES Cartridge PCB Outline

This outline is based on measurements from a NES-EWROM-01 type cartridge PCB, segmented with cutouts of of other cartridge types. These measurements are measured with vernier calipers with 0.05 mm accuracy, Base measurements assume 0.05 mm grid. Note that this outline also details where the soldermask ends for the card edge.

| Dimensions |
| Designator | Dimensions in mm (±0.05 mm) | Description |
| A | 100 | Board width |
| A.1 | 97 | Notched width |
| A.2 | 90 | Notched width |
| A.3 | 93.5 | Card edge width |
| A.4 | 50 | Tab width for cutout 2 |
| A.5 | 50 | Hole center to PCB edge for cutout 4 / 5 |
| A.6 | 44.5 | Hole center to PCB edge for cutout 4 / 5 |
| A.7 | 3 | Hole diameter for cutout 4 / 5 |
| A.8 | 5 | Hole diameter for cutout 4 / 5 |
| A.9 | 3.5 | Notched width |
| B.1 | 25.5 | Board height for cutout 1 |
| B.2 | 40.5 | Board height for cutout 2 |
| B.3 | 44.5 | Board height for cutout 3 |
| B.4 | 65.5 | Board height for cutout 4 |
| B.5 | 95.5 | Board height for cutout 5 |
| B.6 | 14.5 | Card edge depth |
| B.7 | 6 | Notch height |
| B.8 | 2.5 | Notch height |
| B.9 | 9 | Hole center to PCB edge for cutout 4 / 5 |
| B.10 | 18.5 | Hole center to PCB edge for cutout 4 / 5 |
| C | 1.2 | Board thickness |
| D.1 | 6.5 | Card edge base to front soldermask keepout |
| D.2 | 3.5 | Card edge base to back soldermask keepout |
| D.3 | 1.5 | Card edge base to pad top |
| D.4 | 12 | Card edge pad height |
| E.1 | 1 | Card edge to edge pad side |
| E.2 | 3 | Edge pad width |
| E.3 | 0.5 | Distance between pads |
| E.4 | 2 | Pad width |
| E.5 | 2.5 | Pad spacing |

## Label dimensions

An NES Game Pak label measures roughly 55x97 mm, with the top 7 mm of that in the fold-over. But actual printing will need a bit of extra space for the bleed area. Here's a templateshowing the approximate size of a label for a standard NES cartridge.

acfrazier recommended printing cart labels on Avery 5164, Avery 5264, or Avery 8164 (4x3.33 in) labels.

# Standard controller

Source: https://www.nesdev.org/wiki/NES_controller

All NES units come with at least one standard controller - without it, you wouldn't be able to play any games!

Standard controllers can be used in both controller ports, or in a Four scoreaccessory. For code examples, see: Controller reading code

## Report

The standard NES controller will report 8 bits on its data line:

```text
0 - A
1 - B
2 - Select
3 - Start
4 - Up
5 - Down
6 - Left
7 - Right

```

After 8 bits are read, all subsequent bits will report 1 on a standard NES controller, but third party and other controllers may report other values here.

If using DPCM audio samples, read conflicts must be corrected with a software technique. The most common symptom of this is spurious Right presses as the DPCM conflict deletes one bit of the report, and an extra 1 bit appears in the Right press position. See: Controller reading: DPCM conflict.

## Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

While S ( strobe) is high, the shift registers in the controllers are continuously reloaded from the button states, and reading $4016/$4017 will keep returning the current state of the first button (A). Once S goes low, this reloading will stop. Hence a 1/0 write sequence is required to get the button states, after which the buttons can be read back one at a time.

(Note that bits 2-0 of $4016/write are stored in internal latches in the 2A03/07.)

## Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxx xMES
      |||
      ||+- Primary controller status bit
      |+-- Expansion controller status bit (Famicom)
      +--- Microphone status bit (Famicom, $4016 only)

```

Though both are polled from a write to $4016, controller 1 is read through $4016, and controller 2 is separately read through $4017.

Each read reports one bit at a time through D0. The first 8 reads will indicate which buttons or directions are pressed (1 if pressed, 0 if not pressed). All subsequent reads will return 1 on official Nintendo brand controllers but may return 0 on third party controllers such as the U-Force.

Status for each controller is returned as an 8-bit report in the following order: A, B, Select, Start, Up, Down, Left, Right.

In the NES and Famicom, the top three (or five) bits are not driven, and so retain the bits of the previous byte on the bus. Usually this is the most significant byte of the address of the controller port—0x40. Certain games (such as Paperboy) rely on this behavior and require that reads from the controller ports return exactly $40 or $41 as appropriate. See: Controller reading: unconnected data lines.

When no controller is connected, the corresponding status bit will report 0. This is due to the presence of internal pull-up resistors, and the internal inverter. (See: Controller reading)

### Famicom

The original Famicom's hard-wired second controller (II) is missing the Select and Start buttons. Its corresponding bits will read as 0, so Famicom games must not rely on the second player being able to push Start or Select.

This hard-wired second controller also contains a microphone, which gives an immediate 1-bit report at $4016 D2 whenever it is read. It was common for Famicom games to track when the report changes its state (0 to 1 and vice versa), rather than relying on a specific state representing microphone activity. (TODO: There appears to have been cases where the report was inverted on some units, possibly due to the microphone being installed backwards?) As a result, the microphone report is most useful for detecting noisy audio sources such as a player blowing into the microphone. The microphone audio itself is mixed with the APUoutput before being sent to the cartridge edge. (i.e. before expansion audiois mixed in by the cartridge)

The later AV Famicom used detachable controllers, with connectors identical to the NES. Its second controller was the same as the first, with Select and Start present, and no microphone.

The expansion port of the Famicom could be used to connect external controllers. These gave the same standard 8-bit report, but through D1 instead of D0. It was common for Famicom games to combine D1 and D0 (logical OR) when reading to permit players to use expansion controllers instead, though several games do not support this [1]. Alternatively, these could be used as extra controllers for 4-playergames.

## Hardware

The 4021 ICis an 8-bit parallel-to-serial shift register. This allows the 8 button states to be latched into the register simultaneously (parallel), then read out one bit at a time (serial).

From the controller port pinouts:
- OUT ( $4016:0 ) controls the 4021's Parallel/Serial Control . When this goes high, the current state of the 8 buttons are read into the 4021's 8-bit register.
- CLK controls the 4021's Clock input. On a low-to-high transition this will shift each bit of the register to the next higher bit. This is normally held high, and becomes low during a read of $4016 or $4017 . When the read is finished, it returns high, triggering the shift to prepare for the next bit to be read.
- D0 reads the 4021's Q8 output. This is the current state of the last bit in the register. Note that the NES will invert this signal, so for the 4021 unpressed buttons are stored as 1, but will read to the NES CPU as 0.
- +5V powers the 4021 through its Vcc pin.
- GND provides ground to the 4021 through Vss but is also connected to its Serial In input, which will shift a 0 into each empty bit as the 4021 is clocked. This is why (after inversion) the standard controller will read back all 1s once the 8 buttons have been read.

Each of the 8 PI parallel input pins is connected to +5V through its own pull-up resistor (~10k), keeping it high normally. When a button is pressed, it connects the input to ground, bypassing the pull-up, creating a low signal when latched. PI-8 corresponds to the first button read: the A button.

If using DPCM audio samples, read conflicts may occur requiring a software technique to correct for them. See: Controller reading: DPCM conflict.

### PAL

Some PAL region consoles (for example FRA, HOL, NOE) have internal diodes on their controller port. (See: Controller port pinout: Protection Diodes)

These diodes prevent the Clock and Latch signals from functioning unless they are pulled high. PAL controllers for these regions (model NES-004E) each contain a 3.6KΩ resistor between these two inputs and 5V. [2]

On these systems, only PAL controllers with the pull-ups can be read. NTSC systems, along with early PAL market systems (at least SCN) can read controllers of either type. Modifying the internal controller port to bypass these diodes will make the PAL system compatible with both. Conversely, modifying a controller to add the pull-up resistors makes it compatible with both types of systems.

This also extends to the 4-score peripheral: Model NESE-034 ver1.1 is also diode protected and will require pull-up-equipped controllers.

### Schematic

```text
                     .-----\/-----.
*--------- A Button -|PI-8     Vcc|- 5V
                  x -|Q6      PI-7|- B Button -------*
   +------------ D0 -|Q8      PI-6|- Select Button --*
*--|----- Up Button -|PI-4    PI-5|- Start Button ---*
*--|--- Down Button -|PI-3      Q7|- x                    |\
*--|--- Left Button -|PI-2   SerIn|- GND             GND -|o\
*--|-- Right Button -|PI-1   Clock|---+------------- CLK -|oo|- 5V
   |            GND -|Vss    Latch|---|--+---------- OUT -|oo|- D3 --x
   |                 .____4021____.   |  |  +-------- D0 -|oo|- D4 --x
   |                                  |  |  |             .__.
   +----------------------------------|--|--+            (Port)
                                      |  |
8 x *--+--[ 10k ]-- 5V                |  | (PAL pullups)
       |                              +--|--[ 3.6k ]--+-- 5V
       |   __+__ (Button)                |            |
       +---o   o--- GND                  +--[ 3.6k ]--+

```

## Turbo

A turbo controller such as the NES Max or NES Advantage is read just like a standard controller, but the user can switch some of its buttons to be toggled by an oscillator. Such an oscillator turns the button on and off at 15 to 30 Hz, producing rapid fire in games.

A controller should not toggle the button states on each strobe pulse. Doing so will cause problems for games that poll the controller in a loop until they get two identical consecutive reads (see DMC conflict above). The game may halt while the turbo button is held, or crash, or cause other unknown behaviour.

## See also
- Controller reading
- Controller detection
- Controller port pinout
- Four Score4-player adapter
- SNES controllerhas backward compatible protocol with the NES

## References
- ↑Famicom World forum post: Famicom games that do not work with pads connected through the expansion port.
- ↑Forum post: explaining PAL controller diodes and their function.
- Forum post:Famicom controller PCB and exterior photographs
- Hori controller schematic- Third party controller similar to the NES or Famicom controller, and contains the Clock/Latch pull-ups needed for PAL compatibility.

# Non-power-of-two ROM size

Source: https://www.nesdev.org/wiki/Non-power-of-two_ROM_size

Because of the cost of soldering multiple DIP chips to a board, it wasn't common to have more than one PRG ROM or more than one CHR ROM on an NES cartridge board. Below is a list of such boards:

```text
Board Name        | Mpr | Type                | What switches | Games                                 | PCB
------------------+-----+---------------------+---------------+---------------------------------------+------
STROM             | 0   | PRG 2x8k            | Transistor    | Baseball                              | [1]
                  |     |                     |               | Pinball                               | [2]
------------------+-----+---------------------+---------------+---------------------------------------+-------
?                 | ?   | PRG 1M + 256k       | PAL16L8       | PEGASUS 5 in 1                        | [3]
B-5064            | ?   | PRG 512k + 3x256k   | PAL16L8       | PEGASUS 5 in 1                        | [4]
------------------+-----+---------------------+---------------+---------------------------------------+-------
SMROM             | 1   | PRG 2x128k          | ROM +CE (*)   | Hokkaidou Rensa Satsujin: Okhotsu ... | [5]
023-N507          | 228 | PRG 3x512k          | PAL16L8       | Action 52                             | [6]
JUMP A            | 16  | PRG 2x128k          | 74139         | Famicom Jump: Eiyuu Retsuden          | [7]
TENGEN-800042     | 68  | CHR 2x128k          | 7402?         | After Burner                          | [8]
UNK-SUNSOFT-AFB   | 68  | CHR 2x128k          | ROM +CE (*)   | After Burner                          | [9]
AKIRA-A           | 33  | CHR 2x128k          | 74139         | Akira                                 | [10]
TH2180-2          | 193 | CHR 2x128k          | NTDEC TC-112  | Fighting Hero                         | [11]
FB-N-128-02       | 0   | PRG 2x16k           | 7420          | Family BASIC                          | [12]
RTROM             | 0   | PRG 2x8k            | Transistor    | Excitebike                            | [13]
UNK-HVC-023-PROTO | 2   | PRG 4x32k           | 74139         | Chester Field: Ankoku Shin ... (Proto)| [14]
NES-EVENT-02      | 105 | PRG 2x128k          | 7404          | Nintendo World Championships 1990     | [15]
NES-SNWEPROM      | 1   | PRG 2x128           | Transistor?   | Final Fantasy II (Proto)              | [16]
BLUE TRAIN        | 16  | CHR 2x128           | 74139         | Nishimura Kyoutarou Mystery: Blue T...| [17]
SAP-E301          | 69  | CHR 2x128           | 7404          | Batman: Return of the Joker (Proto)   | [18]
------------------+-----+---------------------+---------------+---------------------------------------+-------
NES-TKEPROM-01    | 4   | CHR 2x128           | 74139         | Days of Thunder (Proto)               | [19]
NES-TKEPROM-01    | 4   | CHR 2x128           | 74139         | Gremlins 2: The New Batch (Proto)     | [20]
NES-TKEPROM-01    | 4   | PRG 2x128           | 74139         | Mega Man 3 (Prototype)                | [21]
NES-TKEPROM-01    | 4   | CHR 2x128           | 74139         | Where in Time Is Carmen Sandiego?     | [22]
NES-TKEPROM-02    | 4   | PRG 4x128, CHR 2x128| 74139         | Kirby's Adventure (Proto)             | [23]
NES-TKEPROM-02    | 4   | PRG 2x128           | 74139         | Tecmo Super Bowl (Proto)              | [24]
NES-TKEPROM-02    | 4   | PRG 2x128, CHR 2x128| 74139         | Wario's Woods (Proto)                 | [25]
------------------+-----+---------------------+---------------+---------------------------------------+-------
NoSA-8802B        | 513 | PRG 6x256k          | 7400          | Princess Maker                        | [26]

(*) "ROM +CE" means the circuitry is effectively built into the ROMs.  One of two memories connected
    in parallel has a positive chip enable input while the other has negative.

This list does not include many pirate versions of official cartriges or multicarts, which often had PRG/CHR
split into many 128k chips, for example: [27]

```

Even then, because there were almost always two ROMs of the same size on the PRG or CHR side, the PRG ROM size and the CHR ROM size were each almost always a power of two. The most notable exception on NES is Action 52, whose mapper is defined to support up to four 512Kx8 (4 Mbit) PRG ROMs. Three are populated on the board, totaling 12 Mbit (1.5 MiB).

Non-power-of-two ROM size became more common in the 16-bit era, when games contained only a PRG ROM. Games of size 10, 12, 20, 24, and 48 Mbit (1.25, 1.5, 2.5, 3, and 6 MiB) exist. In the memory space, the larger ROM is at a lower address, and the smaller ROM is mirroredto appear as large as the larger ROM. A 12 Mbit ROM usually shows up as one copy of the first 8 Mbit and two copies of the last 4 Mbit (ABCC). A 20 Mbit ROM is one copy of the first 16 Mbit and four copies of the last 4 Mbit (ABCDEEEE). This interpretation matches the checksum values in Super NES ROMs' internal header.

The following doubling algorithm should produce reasonable results for most ROMs with non-power-of-two sizes:

```text
While ROM size is not a power of two:
    Find the place value of the least significant 1 bit in ROM size
    Double up that many bytes at the end

```

For example, 10 Mbit is 1310720 ($140000) bytes. Doubling the last $40000 bytes produces 12 Mbit, or 1572864 ($180000) bytes. Further doubling the last $80000 bytes of this produces 16 Mbit, or 2097152 ($200000) bytes.

For Action 52 , this produces reasonable results from an emulation perspective. Though ROM slots 0, 1, and 3 are populated on the actual board (ABxC), this algorithm additionally populates slot 2 with a copy of slot 3's data (ABCC).

# MMC2

Source: https://www.nesdev.org/wiki/PNROM

MMC2
PxROM

| Company | Nintendo |
| Games | 1 in NesCartDB |
| Complexity | ASIC |
| Boards | PNROM, PEEOROM |
| Pinout | MMC2 pinout |
| PRG ROM capacity | 128K |
| PRG ROM window | 8K + 24K fixed |
| PRG RAM capacity | 8K (PC10 ver.) |
| PRG RAM window | Fixed |
| CHR capacity | 128K |
| CHR window | 4K + 4K (triggered) |
| Nametable arrangement | H or V, switchable |
| Bus conflicts | No |
| IRQ | No |
| Audio | No |
| iNES mappers | 009 |

The Nintendo MMC2 is an ASICmapper, used on the PNROM and PEEOROM Nintendo Game Pak boards for Mike Tyson's Punch Out!! . The iNESformat assigns Mapper 009 to PxROM . This chip appeared in November 1987.

## Banks
- CPU $6000-$7FFF: 8 KB PRG RAM bank (PlayChoice version only; contains a 6264 and 74139)
- CPU $8000-$9FFF: 8 KB switchable PRG ROM bank
- CPU $A000-$FFFF: Three 8 KB PRG ROM banks, fixed to the last three banks
- PPU $0000-$0FFF: Two 4 KB switchable CHR ROM banks
- PPU $1000-$1FFF: Two 4 KB switchable CHR ROM banks

The two 4 KB PPU banks each have two 4 KB banks, which can be switched during rendering by using the special tiles $FD or $FE in either a sprite or the background. See CHR bankingbelow.

## Registers

### PRG ROM bank select ($A000-$AFFF)

```text
7  bit  0
---- ----
xxxx PPPP
     ||||
     ++++- Select 8 KB PRG ROM bank for CPU $8000-$9FFF

```

### CHR ROM $FD/0000 bank select ($B000-$BFFF)

```text
7  bit  0
---- ----
xxxC CCCC
   | ||||
   +-++++- Select 4 KB CHR ROM bank for PPU $0000-$0FFF
           used when latch 0 = $FD

```

### CHR ROM $FE/0000 bank select ($C000-$CFFF)

```text
7  bit  0
---- ----
xxxC CCCC
   | ||||
   +-++++- Select 4 KB CHR ROM bank for PPU $0000-$0FFF
           used when latch 0 = $FE

```

### CHR ROM $FD/1000 bank select ($D000-$DFFF)

```text
7  bit  0
---- ----
xxxC CCCC
   | ||||
   +-++++- Select 4 KB CHR ROM bank for PPU $1000-$1FFF
           used when latch 1 = $FD

```

### CHR ROM $FE/1000 bank select ($E000-$EFFF)

```text
7  bit  0
---- ----
xxxC CCCC
   | ||||
   +-++++- Select 4 KB CHR ROM bank for PPU $1000-$1FFF
           used when latch 1 = $FE

```

### Mirroring ($F000-$FFFF)

```text
7  bit  0
---- ----
xxxx xxxM
        |
        +- Select nametable mirroring (0: vertical; 1: horizontal)

```

## CHR banking

The main interest of the MMC2 and MMC4mappers is that they allow switching two pairs of 4 KB CHR-ROM banks at the same time, automatically alternating between banks within one pair during rendering. When the PPU reads from specific tiles ($FD or $FE) in the pattern tables, the MMC2/4 sets a latch that switches between two different 4 KB banks. This allows the tile limit to increase from 256 to 512 with bank splits, without involving the CPU or an IRQ.
- PPU reads $0FD8: latch 0 is set to $FD for subsequent reads
- PPU reads $0FE8: latch 0 is set to $FE for subsequent reads
- PPU reads $1FD8 through $1FDF: latch 1 is set to $FD for subsequent reads
- PPU reads $1FE8 through $1FEF: latch 1 is set to $FE for subsequent reads

Notice that latch 0 only responds to one address, but latch 1 responds to a range of addresses. This means that:
- The left ($0000-0FFF) pattern table only switches on the top row of the 8x8 tile
- The right ($1000-1FFF) pattern table switches on every row of the 8x8 tile

With this mapper, the left pattern table ($0000) is intended for use with sprites, and the right pattern ($1000) table for background. Backgrounds require a switch on every row. Because sprites aren't constrained to an 8x8 grid, triggering on only the first row allows switching sprites to be placed closer together if needed. This nuance is absent in the MMC4, where both pattern table switches from the entire tiles in a symmetrical fashion.

Note that the latch is updated after either pattern table byte is fetched, so the switching tiles $FD or $FE themselves are drawn using the old CHR-bank before the latch value is changed. [1]As the PPU fetches 34 background tiles per scanline (and at most 33 are drawn), if vertical mirroringis used, background switching tiles can be placed past the edge of the screen where they will be unseen.

Additionally, because unused sprite slots still perform fetches with a tile number of $FF, using 8x16 sprites will result in PPU $1000-$1FFF unexpectedly changing to the bank number written to $E000 at the ends of certain scanlines (7-14, 23-30, 39-46, etc.).

## Hardware

The MMC2 is implemented in a 40-pin shrink-DIP package. At least two revisions are known to exist, the MMC2 and the MMC2-L.

The PEEOROM board is used in the re-issue of Mike Tyson's Punch-Out!! . Unlike PNROM, and unlike most other boards used in NES Game Paks sold to the public, it can be configured to support EPROM memory through jumpers on the board.

A pirate clone that exclusively uses discrete logic has been found and reverse-engineered. [2]

## Variants

Nintendo's MMC4, used in the FxROMboard set, is a similar mapper with PRG RAM support and PRG bank sizes of 16kb instead of 8kb. It also suppresses the different banking behavior of the left pattern table.

Because of the extreme similarity between the MMC2 and MMC4, it is possible to make a circuit that simulates an MMC4 from an MMC2 with the help of a 7402quad-NOR gate and a 74204-input NAND gate to decode PRG RAM. The following circuit "tricks" the MMC2 into thinking the program is still in the $8000-$9FFF range when reading from $A000-$BFFF, but doesn't affect mapper writes. It also shifts all addresses left one bit so that it switches 16kB instead of 8kB banks, and it shortcuts around the different behavior for pattern tables at $0000 and $1000.

```text
MMC2 A16  ----------------------------------  PRG A17

MMC2 A15  ----------------------------------  PRG A16

MMC2 A14  ----------------------------------  PRG A15
                ____              ___
MMC2 A13  -----\    `.       ,---\   `.
                )     )o-----+    )    )o---  PRG A14
CPU A14   -----/____,'       `---/___,'

CPU A13   ---+------------------------------  PRG A13
             |    ___
             +---\   `.         ___
             |    )    )o------\   `.
             `---/___,'         )    )o-----  MMC2 A13
                          ,----/___,'
R/W       ----------------'

GND       --------------------+-------------  MMC2 PA2
                              |
                              +-------------  MMC2 PA1
                              |
                              `-------------  MMC2 PA0

```

## See also
- Nintendo MMC201/29/98 by Jim Geffre.
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state and lates are inaccurate.
- NES Mapper listby Disch.

## References
- ↑nesdev forum: Glitch in the Matrix ???
- ↑nesdev forum: Punch Out Cartridge have only TTLs instead of MMC2!

# PPU frame timing

Source: https://www.nesdev.org/wiki/PPU_frame_timing

The following behavior is tested by the ppu_vbl_nmi_timing test ROMs. Only the NTSC PPU is covered, though most probably applies to the PAL PPU.

## Even/Odd Frames
- The PPU has an even/odd flag that is toggled every frame, regardless of whether rendering is enabled or disabled.
- With rendering disabled (background and sprites disabled in PPUMASK ($2001)), each PPU frame is 341*262=89342 PPU clocks long. There is no skipped clock every other frame.
- With rendering enabled, each odd PPU frame is one PPU clock shorter than normal. This is done by skipping the first idle tick on the first visible scanline (by jumping directly from (339,261) on the pre-render scanline to (0,0) on the first visible scanline and doing the last cycle of the last dummy nametable fetch there instead; see this diagram).
- By keeping rendering disabled until after the time when the clock is skipped on odd frames, you can get a different color dot crawl pattern than normal (it looks more like that of interlace, where colors flicker between two states rather than the normal three). Presumably Battletoads (and others) encounter this, since it keeps the BG disabled until well after this time each frame.

## CPU-PPU Clock Alignment

The NTSC PPU runs at 3 times the CPU clock rate, so for a given power-up PPU events can occur on one of three relative alignments with the CPU clock they fall within. Since the PPU divides the master clock by four, there are actually more than just three alignments possible: The beginning of a CPU tick could be offset by 0-3 master clock ticks from the nearest following PPU tick. The results below only cover one particular set of alignments, namely the one which gives the fewest number of special cases, where a read will see a change to a flag if and only if it starts at or after the PPU tick where the flag changes. (Other alignments might cause the change to be visible 1 PPU tick earlier or later; see this thread.)

### Synchronizing the CPU and PPU clocks

If rendering is off, each frame will be 341*262/3 = 29780 2/3 CPU clocks long. If the CPU checks the VBL flag in a loop every 29781 clocks, the read will occur one PPU tick later relative to the start of the frame each frame, until at some point the CPU "catches up" to the location where the flag gets set. At this point, the CPU and PPU synchronization is known down the PPU tick.

```text
During frame 5 below, the CPU will read the VBL flag as set, and the loop will stop.

Frame 1: ...-C---V-...
Frame 2: ...--C--V-...
Frame 3: ...---C-V-...
Frame 4: ...----CV-...
Frame 5: ...-----*-...

-: PPU tick
C: Location where the CPU starts reading $2002
V: Location where the VBL flag is set in $2002
*: Beginning of $2002 read synched with VBL flag setting

(This assumes the alignment with the fewest number of special cases as mentioned above.)

```

## VBL Flag Timing
See also: NMI
- Reading $2002 within a few PPU clocks of when VBL is set results in special-case behavior. Reading one PPU clock before reads it as clear and never sets the flag or generates NMI for that frame. Reading on the same PPU clock or one later reads it as set, clears it, and suppresses the NMI for that frame. Reading two or more PPU clocks before/after it's set behaves normally (reads flag's value, clears it, and doesn't affect NMI operation). This suppression behavior is due to the $2002 read pulling the NMI line back up too quickly after it drops (NMI is active low) for the CPU to see it. (CPU inputs like NMI are sampled each clock.)
- On an NTSC machine, the VBL flag is cleared 6820 PPU clocks, or exactly 20 scanlines, after it is set. In other words, it's cleared at the start of the pre-render scanline. ( TO DO: confirmation on PAL NES and common PAL famiclone)

## See Also
- PPU rendering
- Cycle reference chart

# PPU memory map

Source: https://www.nesdev.org/wiki/PPU_memory_map

### PPU memory map

The PPUaddresses a 14-bit (16kB) address space, $0000-$3FFF, completely separate from the CPU's address bus. It is either directly accessed by the PPU itself, or via the CPU with memory mapped registersat $2006 and $2007.

| Address range | Size | Description | Mapped by |
| $0000-$0FFF | $1000 | Pattern table 0 | Cartridge |
| $1000-$1FFF | $1000 | Pattern table 1 | Cartridge |
| $2000-$23BF | $03c0 | Nametable 0 | Cartridge |
| $23C0-$23FF | $0040 | Attribute table 0 | Cartridge |
| $2400-$27BF | $03c0 | Nametable 1 | Cartridge |
| $27C0-$27FF | $0040 | Attribute table 1 | Cartridge |
| $2800-$2BBF | $03c0 | Nametable 2 | Cartridge |
| $2BC0-$2BFF | $0040 | Attribute table 2 | Cartridge |
| $2C00-$2FBF | $03c0 | Nametable 3 | Cartridge |
| $2FC0-$2FFF | $0040 | Attribute table 3 | Cartridge |
| $3000-$3EFF | $0F00 | Unused | Cartridge |
| $3F00-$3F1F | $0020 | Palette RAM indexes | Internal to PPU |
| $3F20-$3FFF | $00E0 | Mirrors of $3F00-$3F1F | Internal to PPU |

## Hardware mapping

The NES has 2kB of RAM dedicated to the PPU, usually mapped to the nametable address space from $2000-$2FFF, but this can be rerouted through custom cartridge wiring. The mappings above are the addresses from which the PPU uses to fetch data during rendering. The actual devices that the PPU fetches pattern, name table and attribute table data from is configured by the cartridge.
- $0000-1FFF is normally mapped by the cartridge to a CHR-ROM or CHR-RAM, often with a bank switching mechanism.
- $2000-2FFF is normally mapped to the 2kB NES internal VRAM, providing 2 nametables with a mirroringconfiguration controlled by the cartridge, but it can be partly or fully remapped to ROM or RAM on the cartridge, allowing up to 4 simultaneous nametables.
- $3000-3EFF is usually a mirror of the 2kB region from $2000-2EFF. The PPU does not render from this address range, so this space has negligible utility.
- $3F00-3FFF is not configurable, always mapped to the internal palette control.

## OAM

In addition, the PPU internally contains 256 bytes of memory known as Object Attribute Memorywhich determines how sprites are rendered. The CPU can manipulate this memory through memory mapped registersat OAMADDR($2003), OAMDATA($2004), and OAMDMA($4014). OAM can be viewed as an array with 64 entries. Each entry has 4 bytes: the sprite Y coordinate, the sprite tile number, the sprite attribute, and the sprite X coordinate.

| Address Low Nibble | Description |
| $0, $4, $8, $C | Sprite Y coordinate |
| $1, $5, $9, $D | Sprite tile # |
| $2, $6, $A, $E | Sprite attribute |
| $3, $7, $B, $F | Sprite X coordinate |

# PPU power up state

Source: https://www.nesdev.org/wiki/PPU_power_up_state

In March 2008, Blargg reverse-engineered the power-up/reset state and behavior of the NES PPU, NTSC version.

| Register | At Power | After Reset |
| PPUCTRL ($2000) | 0000 0000 | 0000 0000 |
| PPUMASK ($2001) | 0000 0000 | 0000 0000 |
| PPUSTATUS ($2002) | +0+x xxxx | U??x xxxx |
| OAMADDR ($2003) | $00 | unchanged1 |
| $2005 / $2006 latch | cleared | cleared |
| PPUSCROLL ($2005) | $0000 | $0000 |
| PPUADDR ($2006) | $0000 | unchanged |
| PPUDATA ($2007) read buffer | $00 | $00 |
| odd frame | no | no |
| OAM | unspecified | unspecified |
| Palette | unspecified | unchanged |
| NT RAM (external, in Control Deck) | unspecified | unchanged |
| CHR RAM (external, in Game Pak) | unspecified | unchanged |

? = unknown, x = irrelevant, + = often set, U = unchanged
- The PPU comes out of power and reset at the top of the picture. See: PPU rendering.
- Writes to the following registers are ignored if earlier than ~29658 CPU clocks after reset: PPUCTRL, PPUMASK, PPUSCROLL, PPUADDR. This also means that the PPUSCROLL/ PPUADDRlatch will not toggle. The other registers work immediately: PPUSTATUS, OAMADDR, OAMDATA($2004), PPUDATA, and OAMDMA($4014).
  - There is an internal reset signal that clears PPUCTRL, PPUMASK, PPUSCROLL, PPUADDR, the PPUSCROLL/ PPUADDRlatch, and the PPUDATAread buffer. (Clearing PPUSCROLLand PPUADDRcorresponds to clearing the VRAM address latch (T)and the fine X scroll. Note that the VRAM address itself (V) is not cleared.) This reset signal is set on reset and cleared at the end of VBlank, by the same signal that clears the VBlank, sprite 0, and overflow flags. Attempting to write to a register while it is being cleared has no effect, which explains why writes are "ignored" after reset.
- If the NES is powered on after having been off for less than 20 seconds, register writes are ignored as if it were a reset, and register starting values differ: PPUSTATUS= $80 (VBlank flag set), OAMADDR= $2F or $01, and PPUADDR= $0001.
- The VBL flag ( PPUSTATUSbit 7) is random at power, and unchanged by reset. It is next set around 27384, then around 57165.
- Preliminary testing on a PAL NES shows that writes are ignored until ~33132 CPU clocks after power and reset, 9 clocks less than 311 scanlines. It is conjectured that the first VBL flag setting will be close to 241 * 341/3.2 cycles (241 PAL scanlines); further testing by nocash has confirmed this.
- It is known that after power and reset, it is as if the APU's $4017 were written 10 clocks before the first code starts executing. This delay is probably the same source of the 9 clock difference in the times for PPU writes being ignored. The cause is likely the reset sequence of the 2A03, when it reads the reset vector.
- 1 : Although OAMADDRis unchanged by reset, it is changed during rendering and cleared at the end of normal rendering, so you should assume its contents will be random.
- On front-loading consoles (NES-001), the Reset button on the Control Deck resets both the CPU and PPU. On top-loaders (Famicom, NES-101), only the CPU is reset.

Some of the initial state has unspecified values. Different lots of chips have different initial values due to the relative strengths of pull-down and pull-up elements in each bit cell, and the exact values of some bits may vary from one power-on to the next with ambient temperature or electromagnetic noise.
- The contents of OAM are unspecified both at power on and at reset due to DRAM decay.
- The contents of the palette are unspecified at power on and unchanged at reset. During the warmup state, the PPU outputs a solid color screen based on the value at $3F00.
- The contents of nametable RAM (in the Control Deck) and CHR RAM (in the Game Pak) are unspecified at power on and unchanged at reset.
- In almost all mappers, CHR bank values are unspecified at power on and unchanged at reset. The few exceptions, if any, are described on each mapper's page.

## Best practice

The easiest way to make sure that 29658 cycles have passed, and the way used by commercial NES games, involves a pair of loops like this in your init code:

```text
  bit PPUSTATUS  ; clear the VBL flag if it was set at reset time
vwait1:
  bit PPUSTATUS
  bpl vwait1     ; at this point, about 27384 cycles have passed
vwait2:
  bit PPUSTATUS
  bpl vwait2     ; at this point, about 57165 cycles have passed

```

Due to the $2002 race condition, alignment between the CPU and PPU clocks at reset may cause the NES to miss an occasional VBL flag setting, but the only consequence of this is that your program will take one frame longer to start up. You might want to do various other initialization, such as getting the mapper and RAM into a known state, between the two loops.

## Famicom

On the NTSC NES, the PPU and CPU are reset at the exact same time. On the Famicom, the PPU does not respond to the reset button, only the CPU is reset.

At power-on, on the Famicom, the PPU initialization begins approximately one frame before the CPU reset, because PPU /reset is tied to 5V, and CPU /reset is connected to a 0.47µF capacitor. The exact timing has not been measured, and may vary.

In particular, the Famicom game Magic John only waits 9217 CPU cycles before trying to enable NMI. This is before the required 29658 cycles required by the NTSC NES, so the game will not boot on that system, but using a Game Genie will allow the game to boot. This was corrected for the international release of the game, retitled as Totally Rad . This also affected The Lord of King , internationally known as Astyanax [1]. Both of these games were developed by Aicom for Jaleco.

## Dendy

Reading $2002 at the exact start of vblank clears the flag to 0 without reading back a 1. On most consoles and with most wait loops, an alignment is eventually reached such that the flag is read other than on at the exact start of vblank. However, Dendy-style PAL famiclones have a frame of exactly 113.667 by 312 = 35464 cycles, and 35464 is a multiple of 8. A `bit `/ `bpl `loop that crosses a page boundary, such as that found in the game Eliminator Boat Duel , lasts 8 cycles. On some alignments, it hits the start of vblank every time and thus always fails to advance.

So for the $2002 wait loop, do not make a wait loop whose length in cycles evenly divides the frame length.

## See also
- CPU power up state

## References
- Confirmation by nocash
- Notes on reset color
- PPU warmup testing by Blargg
- Famicom CPU/PPU reset capacitor notes by lidnariq
- ↑Forum thread: Re: PPU wait for ready in Donkey Kong - Test reports of Magic John and The Lord of King on different consoles.

# PPU programmer reference

Source: https://www.nesdev.org/wiki/PPU_programmer_reference

## PPU Registers

The PPUexposes eight memory-mapped registers to the CPU. These nominally sit at $2000 through $2007 in the CPU's address space, but because their addresses are incompletely decoded, they're mirroredin every 8 bytes from $2008 through $3FFF. For example, a write to $3456 is the same as a write to $2006.

The PPU starts rendering immediately after power-on or reset, but ignores writes to most registers (specifically $2000, $2001, $2005 and $2006) until reaching the pre-render scanline of the next frame; more specifically, for around 29658 NTSC CPU cycles or 33132 PAL CPU cycles, assuming the CPU and PPU are reset at the same time. See PPU power up stateand Init codefor details.

## Summary

| Common Name | Address | Bits | Type | Notes |
| PPUCTRL | $2000 | VPHB SINN | W | NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B), sprite tile select (S), increment mode (I), nametable select / X and Y scroll bit 8 (NN) |
| PPUMASK | $2001 | BGRs bMmG | W | color emphasis (BGR), sprite enable (s), background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G) |
| PPUSTATUS | $2002 | VSO- ---- | R | vblank (V), sprite 0 hit (S), sprite overflow (O); read resets write pair for $2005/$2006 |
| OAMADDR | $2003 | AAAA AAAA | W | OAM read/write address |
| OAMDATA | $2004 | DDDD DDDD | RW | OAM data read/write |
| PPUSCROLL | $2005 | XXXX XXXX YYYY YYYY | Wx2 | X and Y scroll bits 7-0 (two writes: X scroll, then Y scroll) |
| PPUADDR | $2006 | ..AA AAAA AAAA AAAA | Wx2 | VRAM address (two writes: most significant byte, then least significant byte) |
| PPUDATA | $2007 | DDDD DDDD | RW | VRAM data read/write |
| OAMDMA | $4014 | AAAA AAAA | W | OAM DMA high address |

Register types:
- R - Readable
- W - Writeable
- x2 - Internal 2-byte state accessed by two 1-byte accesses

## MMIO registers

The PPU has an internal data bus that it uses for communication with the CPU. This bus, called `_io_db `in Visual 2C02and `PPUGenLatch `in FCEUX, [1]behaves as an 8-bit dynamic latch due to capacitance of very long traces that run to various parts of the PPU. Writing any value to any PPU port, even to the nominally read-only PPUSTATUS, will fill this latch. Reading any readable port (PPUSTATUS, OAMDATA, or PPUDATA) also fills the latch with the bits read. Reading a nominally "write-only" register returns the latch's current value, as do the unused bits of PPUSTATUS. At least one bit in this value decays after 3ms to 30ms, faster when the PPU is warm. [2]

### PPUCTRL - Miscellaneous settings ($2000 write)

```text
7  bit  0
---- ----
VPHB SINN
|||| ||||
|||| ||++- Base nametable address
|||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
|||| |+--- VRAM address increment per CPU read/write of PPUDATA
|||| |     (0: add 1, going across; 1: add 32, going down)
|||| +---- Sprite pattern table address for 8x8 sprites
||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
|||+------ Background pattern table address (0: $0000; 1: $1000)
||+------- Sprite size (0: 8x8 pixels; 1: 8x16 pixels – see PPU OAM#Byte 1)
|+-------- PPU master/slave select
|          (0: read backdrop from EXT pins; 1: output color on EXT pins)
+--------- Vblank NMI enable (0: off, 1: on)

```

PPUCTRL (the "control" or "controller" register) contains a mix of settings related to rendering, scroll position, vblank NMI, and dual-PPU configurations. After power/reset, writes to this register are ignored until the first pre-render scanline.

#### Vblank NMI

Enabling NMI in PPUCTRL causes the NMI handler to be called at the start of vblank (scanline 241, dot 1). This provides a reliable time source for software so it can run at the display's frame rate, and it signals vblank to the software. Vblank is the only time with rendering enabled that the software can send data to VRAM and OAM, and this NMI is the only reliable way to detect vblank; polling the vblank flag in PPUSTATUScan miss vblank entirely.

Changing NMI enable from 0 to 1 while the vblank flag in PPUSTATUSis 1 will immediately trigger an NMI. This happens during vblank if the PPUSTATUS register has not yet been read. It can result in graphical glitches by making the NMI routine execute too late in vblank to finish on time, or cause the game to handle more frames than have actually occurred. To avoid this problem, it is prudent to read PPUSTATUS first to clear the vblank flag before enabling NMI in PPUCTRL.

#### Scrolling

The current nametable bits in PPUCTRL bits 0 and 1 can equivalently be considered the most significant bit of the scroll coordinates, which are 9 bits wide (see Nametablesand PPUSCROLL):

```text
7  bit  0
---- ----
.... ..YX
       ||
       |+- X scroll position bit 8 (i.e. add 256 to X)
       +-- Y scroll position bit 8 (i.e. add 240 to Y)

```

These two bits go to the same internal t registeras the values written to PPUSCROLL, and they must be written alongside PPUSCROLLin order to fully specify the scroll position.

#### Master/slave mode and the EXT pins

Bit 6 of PPUCTRL should never be set on stock consoles because it may damage the PPU.

When this bit is clear (the usual case), the PPU gets the palette indexfor the backdrop color from the EXT pins. The stock NES grounds these pins, making palette index 0 the backdrop color as expected. A secondary picture generator connected to the EXT pins would be able to replace the backdrop with a different image using colors from the background palette, which could be used for features such as parallax scrolling.

Setting bit 6 causes the PPU to output the lower four bits of the palette memory index on the EXT pins for each pixel. Since only four bits are output, background and sprite pixels can't normally be distinguished this way. Setting this bit does not affect the image in the PPU's composite video output. As the EXT pins are grounded on an unmodified NES, setting bit 6 is discouraged as it could potentially damage the chip whenever it outputs a non-zero pixel value (due to it effectively shorting Vcc and GND together). Note that EXT output for transparent pixels is not a backdrop color as normal, but rather entry 0 of that background sliver's palette. When rendering is disabled, EXT output is always index 0 regardless of backdrop override.

#### Bit 0 race condition

Be careful when writing to this register outside vblank if using a horizontal nametable arrangement (a.k.a. vertical mirroring) or 4-screen VRAM. For specific CPU-PPU alignments, a write that startson dot 257will cause only the next scanline to be erroneously drawn from the left nametable. This can cause a visible glitch, and it can also interfere with sprite 0 hit for that scanline (by being drawn with the wrong background).

The glitch has no effect in horizontal or one-screen mirroring because the left and right nametables are identical. Only writes that start on dot 257 and continue through dot 258 can cause this glitch: any other horizontal timing is safe. The glitch specifically writes the value of open bus to the register, which will almost always be the upper byte of the address. Writing to this register or the mirror of this register at $2100 according to the desired nametable appears to be a functional workaround.

This produces an occasionally visible glitchin Super Mario Bros. when the program writes to PPUCTRL at the end of game logic. It appears to be turning NMI off during game logic and then turning NMI back on once the game logic has finished in order to prevent the NMI handler from being called again before the game logic finishes. Another workaround is to use a software flag to prevent NMI reentry, instead of using the PPU's NMI enable.

### PPUMASK - Rendering settings ($2001 write)

```text
7  bit  0
---- ----
BGRs bMmG
|||| ||||
|||| |||+- Greyscale (0: normal color, 1: greyscale)
|||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
|||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
|||| +---- 1: Enable background rendering
|||+------ 1: Enable sprite rendering
||+------- Emphasize red (green on PAL/Dendy)
|+-------- Emphasize green (red on PAL/Dendy)
+--------- Emphasize blue

```

PPUMASK (the "mask" register) controls the rendering of sprites and backgrounds, as well as color effects. After power/reset, writes to this register are ignored until the first pre-render scanline.

Most commonly, PPUMASK is set to $00 outside of gameplay to allow transferring a large amount of data to VRAM, and $1E during gameplay to enable all rendering with no color effects.

#### Rendering control

Rendering is the PPU's process of actively fetching memory and drawing an image to the screen. Rendering as a whole is enabled as long as one or both of sprite and background rendering is enabled in PPUMASK. If one component is enabled and the other is not, the disabled component is simply treated as transparent; the rendering process is otherwise unaffected. When both components are disabled via bits 3 and 4, the rendering process stops and the PPU displays the backdrop color.

During rendering, the PPU is actively using VRAM and OAM. This prevents the CPU from being able to access VRAM via PPUDATAor OAM via OAMDATA, so these accesses must be done outside of rendering: either during vblank (for data transfers during gameplay) or with rendering turned off (for large data transfers, such as when loading a level). To avoid numerous hardware bugs and limitations, it is generally recommended that rendering be turned on or off only during vblank. This can be done by writing the desired PPUMASK value to a variable rather than the register itself and then only copying that variable to PPUMASK during vblank in the NMI handler.

The PPU can optionally hide sprites and backgrounds in just the leftmost 8 pixels of the screen, making them transparent and thus drawing the backdrop color there. For sprites, this can be useful to avoid sprite pop-in, a limitation where sprites cannot partially hang off the left edge of the screen like they can off the right edge. For backgrounds, this can eliminate tile artifacts and reduce attribute artifacts when scrolling horizontally with either a vertical or one-screen nametable arrangement, as these arrangements do not allow hiding the scroll seam off-screen. Note that the backdrop color may not match the color used by the art for the background, so disabling the left column may be more distracting than minor artifacts.

Notes:
- Writing to PPUDATA during rendering can corrupt VRAM, so writes must be done in vblank or with rendering disabled in PPUMASK bits 3 and 4.
- Sprite 0 hit does not trigger in any area where the background or sprites are disabled.
- Toggling rendering takes effect approximately 3-4 dots after the write. This delay is required by Battletoads to avoid a crash.
- Toggling rendering mid-screen often corrupts 1 row of OAM and draws incorrect sprites for the current and next scanline. (See: Errata)
- Turning rendering off mid-screen can corrupt palette RAM if the low 14 bits of the internal v registerhave a value between $3C00-$3FFF.
- Turning rendering on late causes the dot at the end of pre-render to never be skipped, which can cause dot crawl on stationary screens.
- Turning rendering on late causes the PPU to have an incorrect scroll value unless it is set manually with a complicated series of writes.

#### Color control

Greyscale mode forces all colors to be a shade of grey or white. This is done by bitwise ANDing the color with $30, causing all colors to come from the grey column ($00, $10, $20, $30), which notably lacks a black color. Note that this AND behavior means that RGB PPUs with scrambled colors (the 2C04 series) do not actually get shades of grey, but rather whatever colors are in the $x0 column. When reading from palette RAM, the returned value reflects this AND behavior, but the underlying data is preserved. Palette writes function normally regardless of greyscale mode.

Color emphasiscauses a color tint effect that works by darkening the other two color components, making the selected component comparatively brighter and thus emphasized. Emphasizing all 3 components simply dims all colors. This works independently of greyscale, allowing greys to be tinted. Note that PAL and Dendy PPUs have a different emphasis bit order, so ports and dual-region games should reorder the bits. Furthermore, emphasis on RGB PPUs is completely different, instead maximizing the brightness of the emphasized component and producing a completely white screen when all components are emphasized. RGB emphasis is far less useful and generally best avoided.

### PPUSTATUS - Rendering events ($2002 read)

```text
7  bit  0
---- ----
VSOx xxxx
|||| ||||
|||+-++++- (PPU open bus or 2C05 PPU identifier)
||+------- Sprite overflow flag
|+-------- Sprite 0 hit flag
+--------- Vblank flag, cleared on read. Unreliable; see below.

```

PPUSTATUS (the "status" register) reflects the state of rendering-related events and is primarily used for timing. The three flags in this register are automatically cleared on dot 1 of the prerender scanline; see PPU renderingfor more information on the set and clear timing.

Reading this register has the side effect of clearing the PPU's internal w register. It is commonly read before writes to PPUSCROLLand PPUADDRto ensure the writes occur in the correct order.

#### Vblank flag

The vblank flag is set at the start of vblank (scanline 241, dot 1). Reading PPUSTATUS will return the current state of this flag and then clear it. If the vblank flag is not cleared by reading, it will be cleared automatically on dot 1 of the prerender scanline.

Reading the vblank flag is not a reliable way to detect vblank. NMIshould be used, instead. Reading the flag on the dot before it is set (scanling 241, dot 0) causes it to read as 0 and be cleared, so polling PPUSTATUS for the vblank flag can miss vblank and cause games to stutter. NMI is also suppressed when this occurs, and may even be suppressed by reads landing on the following dot or two. On NTSC and PAL, it is guaranteed that the flag cannot be dropped two frames in a row, but on Dendy, it is possible for it to happen every frame, crashing the game. Using NMI ensures that software correctly detects vblank every frame. It is also required by PlayChoice-10, which will reject the game if NMI is disabled for too long. Polling the vblank flag is still required while booting up the console, but timing at this point is not critical (see Init codefor more information on booting safely).

The vblank flag is used in the generation of NMI, and enabling NMI while this flag is 1 will cause an immediate NMI (see PPUCTRL).

#### Sprite 0 hit flag

Sprite 0 hitis a hardware collision detection feature that detects pixel-perfect collision between the first sprite in OAM (sprite 0) and the background. The sprite 0 hit flag is immediately set when any opaque pixel of sprite 0 overlaps any opaque pixel of background, regardless of sprite priority. 'Opaque' means that the pixel is not 'transparent' — that is, its two pattern bitsare not %00. The flag stays set until dot 1 of the prerender scanline; thus, it can only detect one collision per frame.

Although this flag detects collision, it is primarily used for timing. Many games place sprite 0 at a fixed location on the screen and poll this flag until it becomes set. This allows the CPU to know its approximate location on the screen so it can time mid-screen writes to hardware registers. Commonly, this is used to change the scroll position mid-screen to allow for a background-based HUD, like in Super Mario Bros. However, some modern homebrew games use this for actual collision, such as Lunar Limitand Irritating Ship.

Sprite 0 hit cannot detect collision at X=255, nor anywhere where either sprites or backgrounds are disabled via PPUMASK. This includes X=0..7 when the leftmost 8 pixels are hidden. However, it is not affected by the cropping on the left and right edges on PAL.

There are some important considerations when using this flag for timing:
- Because sprite 0 hit is not cleared until the prerender scanline, software can potentially mistake the previous frame's hit as being from the current frame. Therefore, it may be necessary to poll the flag until it becomes clear before then polling for it to be set again.
- If a game expects sprite 0 hit to occur and it does not, this often results in a crash. If there is any risk that the hit may not occur (perhaps because an overlap may not happen when scrolling or because it relies on precise mid-screen timings that may vary across power cycles, consoles, or emulators), it can be critical to have another way to exit the poll loop. For example, this may be done by also polling the vblank flag or having the NMI handler check if the game is still polling for sprite 0 hit.
- Games often don't handle sprite 0 hit on lag frames, preventing the mid-screen event from occurring. A common result of this is HUD flickering during lag. Handling sprite 0 hit in the NMI handler, at least on lag frames, can work around this.

#### Sprite overflow flag

The sprite overflow flag was intended to be set any time there are more than 8 sprites on a scanline. Unfortunately, the logic for detecting this does not work correctly, resulting in the PPU checking incorrect indices in OAM when searching for a 9th sprite. This produces both false positives and false negatives. See PPU sprite evalutionfor details on its incorrect behavior. In practice, sprite overflow is usually used for timing like sprite 0 hit, but because of its buggy behavior and its cost of 9 sprite tiles, it is generally only used when more than one timing source is required. Like sprite 0 hit, this flag is cleared at the start of the prerender scanline and can only be set once per frame.

Using sprite overflow is often a last resort. When mapper IRQs are not available, the DMC IRQcan be an effective alternative for timing, albeit complicated to use.

#### 2C05 identifier

The 2C05 series of arcade PPUs returns an identifier in bits 4-0 instead of PPU open bus. This value is checked by games as a form of copy protection. Note that this does not apply to the consumer 2C05-99, which returns open bus as usual. While we haven't yet collected data directly from the PPUs, 2C05 games expect the following values:

| PPU | Mask | Value |
| 2C05-02 | $3F | $3D |
| 2C05-03 | $1F | $1C |
| 2C05-04 | $1F | $1B |

### OAMADDR - Sprite RAM address ($2003 write)

```text
7  bit  0
---- ----
AAAA AAAA
|||| ||||
++++-++++- OAM address

```

Write the address of OAMyou want to access here. Most games just write $00 here and then use OAMDMA. (DMA is implemented in the 2A03/7 chip and works by repeatedly writing to OAMDATA)

#### Values during rendering

OAMADDR is set to 0 during each of ticks 257–320 (the sprite tile loading interval) of the pre-render and visible scanlines. This also means that at the end of a normal complete rendered frame, OAMADDR will always have returned to 0.

If rendering is enabled mid-scanline [3], there are further consequences of an OAMADDR that was not set to 0 before OAM sprite evaluation begins at tick 65 of the visible scanline. The value of OAMADDR at this tick determines the starting address for sprite evaluation for this scanline, which can cause the sprite at OAMADDR to be treated as it was sprite 0, both for sprite-0 hitand priority. If OAMADDR is unaligned and does not point to the Y position (first byte) of an OAM entry, then whatever it points to (tile index, attribute, or X coordinate) will be reinterpreted as a Y position, and the following bytes will be similarly reinterpreted. No more sprites will be found once the end of OAM is reached, effectively hiding any sprites before the starting OAMADDR.

#### OAMADDR precautions

On the 2C02G, writes to OAMADDR corrupt OAM. The exact corruption isn't fully described, but this usually seems to copy sprites 8 and 9 (address $20) over the 8-byte row at the target address. The source address for this copy seems to come from the previous value on the CPU BUS (most often $20 from the $2003 operand). [3][4]There may be other possible behaviors as well. This can then be worked around by writing all 256 bytes of OAM, though due to the limited time before OAM decaywill begin this should normally be done through OAMDMA.

It is also the case that if OAMADDR is not less than eight when rendering starts, the eight bytes starting at OAMADDR & 0xF8 are copied to the first eight bytes of OAM; it seems likely that this is related. On the Dendy, the latter bug is required for 2C02 compatibility.

It is known that in the 2C03, 2C04, 2C05 [5], and 2C07, OAMADDR works as intended. It is not known whether this bug is present in all revisions of the 2C02.

### OAMDATA - Sprite RAM data ($2004 read/write)

```text
7  bit  0
---- ----
DDDD DDDD
|||| ||||
++++-++++- OAM data

```

Write OAM data here. Writes will increment OAMADDRafter the write; reads do not. Reads during vertical or forced blanking return the value from OAM at that address.

Do not write directly to this register in most cases. Because changes to OAM should normally be made only during vblank, writing through OAMDATA is only effective for partial updates, as it is too slow to update all of OAM within one vblank interval, and as described above, partial writes cause corruption. Most games use the DMA feature through OAMDMAinstead.
- Reading OAMDATA while the PPU is rendering will expose internal OAM accesses during sprite evaluation and loading; Micro Machines does this.
- Writes to OAMDATA during rendering (on the pre-render line and the visible lines 0–239, provided either sprite or background rendering is enabled) do not modify values in OAM, but do perform a glitchy increment of OAMADDR, bumping only the high 6 bits (i.e., it bumps the [n] value in PPU sprite evaluation– it's plausible that it could bump the low bits instead depending on the current status of sprite evaluation). This extends to DMA transfers via OAMDMA, since that uses writes to $2004. For emulation purposes, it is probably best to completely ignore writes during rendering.
- It used to be thought that reading from this register wasn't reliable [6], however more recent evidence seems to suggest that this is solely due to corruption by OAMADDRwrites.
- In the oldest instantiations of the PPU, as found on earlier Famicoms and NESes, this register is not readable [7]. The readability was added on the RP2C02G, found on most NESes and later Famicoms. [8]
- In the 2C07, sprite evaluation can never be fully disabled, and will always start 24 scanlines after the start of vblank [9](same as when the prerender scanline would have been on the 2C02). As such, any updates to OAM should be done within the first 24 scanlines after the 2C07 signals vertical blanking.

### PPUSCROLL - X and Y scroll ($2005 write)

```text
1st write
7  bit  0
---- ----
XXXX XXXX
|||| ||||
++++-++++- X scroll bits 7-0 (bit 8 in PPUCTRL bit 0)

2nd write
7  bit  0
---- ----
YYYY YYYY
|||| ||||
++++-++++- Y scroll bits 7-0 (bit 8 in PPUCTRL bit 1)

```

This register is used to change the scroll position, telling the PPU which pixel of the nametable selected through PPUCTRLshould be at the top left corner of the rendered screen. PPUSCROLL takes two writes: the first is the X scroll and the second is the Y scroll. Whether this is the first or second write is tracked internally by the w register, which is shared with PPUADDR. Typically, this register is written to during vertical blanking to make the next frame start rendering from the desired location, but it can also be modified during rendering in order to split the screen. Changes made to the vertical scroll during rendering will only take effect on the next frame. Together with the nametable bits in PPUCTRL, the scroll can be thought of as 9 bits per component, and PPUCTRL must be updated along with PPUSCROLL to fully specify the scroll position.

After reading PPUSTATUSto clear w (the write latch), write the horizontal and vertical scroll offsets to PPUSCROLL just before turning on the screen:

```text
 ; Set the high bit of X and Y scroll.
 lda ppuctrl_value
 ora current_nametable
 sta PPUCTRL

 ; Set the low 8 bits of X and Y scroll.
 bit PPUSTATUS
 lda cam_position_x
 sta PPUSCROLL
 lda cam_position_y
 sta PPUSCROLL

```

Horizontal offsets range from 0 to 255. "Normal" vertical offsets range from 0 to 239, while values of 240 to 255 cause the attributes data at the end of the current nametable to be used incorrectly as tile data. The PPU normally skips from 239 to 0 of the next nametable automatically, so these "invalid" scroll positions only occur if explicitly written.

By changing the scroll values here across several frames and writing tiles to newly revealed areas of the nametables, one can achieve the effect of a camera panning over a large background.

### PPUADDR - VRAM address ($2006 write)

```text
1st write  2nd write
15 bit  8  7  bit  0
---- ----  ---- ----
..AA AAAA  AAAA AAAA
  || ||||  |||| ||||
  ++-++++--++++-++++- VRAM address

```

Because the CPU and the PPU are on separate buses, neither has direct access to the other's memory. The CPU writes to VRAM through a pair of registers on the PPU by first loading an address into PPUADDRand then writing data repeatedly to PPUDATA. The VRAM address only needs to be set once for every series of data writes because each PPUDATA access automatically increments the address by 1 or 32, as configured in PPUCTRL.

The 16-bit address is written to PPUADDR one byte at a time, high byte first. Whether this is the first or second write is tracked by the PPU's internal w register, which is shared with PPUSCROLL. If w is not 0 or its state is not known, it must be cleared by reading PPUSTATUSbefore writing the address. For example, to set the VRAM address to $2108 after w is known to be 0:

```text
  lda #$21
  sta PPUADDR
  lda #$08
  sta PPUADDR

```

The PPU address spaceis 14-bit, spanning $0000–$3FFF. Bits 14 and 15 of the value written to this register are ignored. However, bit 14 of the internal t registerthat holds the data written to PPUADDR is forced to 0 when writing the PPUADDR high byte. This detail doesn't matter when using PPUADDR to set a VRAM address, but is an important limitation when using it to control mid-screen scrolling (see PPU scrollingfor more information).

#### Note

Access to PPUSCROLLand PPUADDRduring screen refresh produces interesting raster effects; the starting position of each scanline can be set to any pixel position in nametable memory. For more information, see PPU scrolling.

#### Palette corruption

In specific circumstances, entries of the PPU's palette can be corrupted. It's unclear exactly how or why this happens, but all revisions of the NTSC PPU seem to be at least somewhat susceptible. [10]

When done writing to palette memory, the workaround is to always
- Update the address, if necessary, so that it's pointing at $3F00, $3F10, $3F20, or any other mirror.
- Only then change the address to point outside of palette memory.

A code fragment to implement this workaround is present in vast numbers of games: [11]

```text
  lda #$3F
  sta PPUADDR
  lda #0
  sta PPUADDR
  sta PPUADDR
  sta PPUADDR

```

#### Bus conflict

During raster effects, if the second write to PPUADDR happens at specific times, at most one axis of scrolling will be set to the bitwise AND of the written value and the current value. The only safe time to finish the second write is during blanking; see PPU scrollingfor more specific timing. [1]

### PPUDATA - VRAM data ($2007 read/write)

```text
7  bit  0
---- ----
DDDD DDDD
|||| ||||
++++-++++- VRAM data

```

VRAM read/write data register. After access, the video memory address will increment by an amount determined by bit 2 of $2000.

When the screen is turned off by disabling the background/sprite rendering flag with the PPUMASKor during vertical blank, data can be read from or written to VRAM through this port. Since accessing this register increments the VRAM address, it should not be accessed outside vertical or forced blanking because it will cause graphical glitches, and if writing, write to an unpredictable address in VRAM. However, a handful of games are known to read from PPUDATA during rendering, causing scroll position changes. See PPU scrollingand Tricky-to-emulate games.

VRAM reading and writing shares the same internal address register that rendering uses. Therefore, after loading data into video memory, the program should reload the scroll position afterwards with PPUSCROLLand PPUCTRL(bits 1-0) writes in order to avoid wrong scrolling.

#### The PPUDATA read buffer

Reading from PPUDATA does not directly return the value at the current VRAM address, but instead returns the contents of an internal read buffer. This read buffer is updated on every PPUDATA read, but only after the previous contents have been returned to the CPU, effectively delaying PPUDATA reads by one. This is because PPU bus reads are too slow and cannot complete in time to service the CPU read. Because of this read buffer, after the VRAM address has been set through PPUADDR, one should first read PPUDATA to prime the read buffer (ignoring the result) before then reading the desired data from it.

Note that the read buffer is updated only on PPUDATA reads. It is not affected by writes or other PPU processes such as rendering, and it maintains its value indefinitely until the next read.

#### Reading palette RAM

Later PPUs added an unreliable feature for reading palette data from $3F00-$3FFF. These reads work differently than standard VRAM reads, as palette RAM is a separate memory space internal to the PPU that is overlaid onto the PPU address space. The referenced 6-bit palette data is returned immediately instead of going to the internal read buffer, and hence no priming read is required. Simultaneously, the PPU also performs a normal read from PPU memory at the specified address, "underneath" the palette data, and the result of this read goes into the read buffer as normal. The old contents of the read buffer are discarded when reading palettes, but by changing the address to point outside palette RAM and performing one read, the contents of this shadowed memory ( usually mirrored nametables) can be accessed. On PPUs that do not support reading palette RAM, this memory range behaves the same as the rest of PPU memory.

This feature is supported by the 2C02G, 2C02H, and PAL PPUs. The byte returned when reading palettes contains PPU open busin the top 2 bits, and the value is returned after it is modified by greyscale mode, which clears the bottom 4 bits if enabled. Unfortunately, on some consoles, palette reads can be corrupted on one of the 4 CPU/PPU alignments relative to the master clock. This corruption depends on when the PPU /CSsignal that indicates register access is deasserted, which varies by console. Combined with this feature not being present in all PPUs, developers should not rely on reading from palette RAM.

#### Read conflict with DPCM samples

If currently playing DPCM samples, there is a chance that an interruption from the APU's sample fetch will cause an extra read cycle if it happened at the same time as an instruction that reads $2007. This will cause an extra increment and a byte to be skipped over, resulting in the wrong data being read. See: APU DMC

### OAMDMA - Sprite DMA ($4014 write)

```text
7  bit  0
---- ----
AAAA AAAA
|||| ||||
++++-++++- Source page (high byte of source address)

```

OAMDMA is a CPU register that suspends the CPU so it can quickly copy a page of CPU memory to PPU OAM using DMA. It always copies 256 bytes and the source address always starts page-aligned (ending in $00). The value written to this register is the high byte of the source address, and the copy begins on the cycle immediately after the write. The copy takes 513 or 514 cycles and is implemented as 256 pairs of a read from CPU memory and a write to OAMDATA. Because vblank is so short and because changing OAMADDRoften corrupts OAM, OAM DMA is normally the only realistic option for updating sprites each frame. 0 should be written to OAMADDR before initiating DMA to ensure the data is properly aligned and to avoid corruption. [4]While OAM DMA is possible to do mid-frame while rendering is disabled, it is normally only done in vblank.

OAM consists of dynamic RAM (DRAM) which decays if not refreshed often enough, and this requires different considerations on NTSC and PAL. Refresh happens automatically any time a row of DRAM is read or written, so it is refreshed every scanline during rendering by the sprite evaluation process. On NTSC, vblank is short enough that OAM will not decay before rendering begins again, so OAM DMA can be done anytime in vblank. On PAL, vblank is much longer, so to avoid decay during that time, the PPU automatically performs a forced refresh starting 24 scanlines after NMI, during which OAM cannot be written. This means that OAM DMA is limited to the start of vblank on PAL. Note that NTSC vblank is shorter than 24 PAL scanlines, so NTSC-compatible NMI handlers will finish before the forced refresh and therefore should work on PAL regardless of their OAM DMA timing. In either case, OAM does not decay if it is not updated during vblank, and in fact it should generally not be updated on lag frames (frames where the CPU did not finish its work before vblank) to avoid copying incomplete sprite data to the PPU.

## Internal registers

The PPU also has 4 internal registers, described in detail on PPU scrolling:
- v : During rendering, used for the scroll position. Outside of rendering, used as the current VRAM address.
- t : During rendering, specifies the starting coarse-x scroll for the next scanline and the starting y scroll for the screen. Outside of rendering, holds the scroll or VRAM address before transferring it to v.
- x : The fine-x position of the current scroll, used during rendering alongside v.
- w : Toggles on each write to either PPUSCROLLor PPUADDR, indicating whether this is the first or second write. Clears on reads of PPUSTATUS. Sometimes called the 'write latch' or 'write toggle'.

## References
- ↑ppu.cppby Bero and Xodnizel
- ↑replies to lidnariq's PPU decay test ROM
- ↑ 3.03.1OAMDATA $2003 corruption clarification?- forum thread
- ↑ 4.04.1Manual OAM write glitchynessthread by blargg
- ↑Writes to $2003 appear to not cause OAM corruptionpost by lidnariq
- ↑$2004 reading reliable?thread by blargg
- ↑$2004 not readable on early revisionsreply by jsr
- ↑hardware revisions and $2004 readsreply by Great Hierophant
- ↑2C07 PPU sprite evaluation notesthread by thefox
- ↑Problem with palette discoloration when PPU is turned off during renderingthread by N·K
- ↑Weird PPU writesthread by Fiskbit

## Pattern tables

The pattern table is an area of memory connected to the PPU that defines the shapes of tiles that make up backgrounds and sprites. This data is also known as CHR , and the memory attached to the PPU which contains it may either be CHR-ROM or CHR-RAM. CHR comes from "character", as related to computer text displays where each tile might represent a single letter character.

Each tile in the pattern table is 16 bytes, made of two planes. Each bit in the first plane controls bit 0 of a pixel's color index; the corresponding bit in the second plane controls bit 1.
- If neither bit is set to 1: The pixel is background/transparent.
- If only the bit in the first plane is set to 1: The pixel's color index is 1.
- If only the bit in the second plane is set to 1: The pixel's color index is 2.
- If both bits are set to 1: The pixel's color index is 3.

This diagram depicts how a tile for ½ (one-half fraction) is encoded, with `. `representing a transparent pixel.

```text
Bit Planes            Pixel Pattern
$0xx0=$41  01000001
$0xx1=$C2  11000010
$0xx2=$44  01000100
$0xx3=$48  01001000
$0xx4=$10  00010000
$0xx5=$20  00100000         .1.....3
$0xx6=$40  01000000         11....3.
$0xx7=$80  10000000  =====  .1...3..
                            .1..3...
$0xx8=$01  00000001  =====  ...3.22.
$0xx9=$02  00000010         ..3....2
$0xxA=$04  00000100         .3....2.
$0xxB=$08  00001000         3....222
$0xxC=$16  00010110
$0xxD=$21  00100001
$0xxE=$42  01000010
$0xxF=$87  10000111

```

The pattern table is divided into two 256-tile sections: a first pattern table at $0000-$0FFF and a second pattern table at $1000-$1FFF. Occasionally, these are nicknamed the "left" and "right" pattern tables based on how emulators with a debugger display them. (See #Display conventionbelow.)

An important aspect of a mapper's capability is how finely it allows bank switching parts of the pattern table.

## Addressing

PPU addresses within the pattern tables can be decoded as follows:

```text
DCBA98 76543210
---------------
0HNNNN NNNNPyyy
|||||| |||||+++- T: Fine Y offset, the row number within a tile
|||||| ||||+---- P: Bit plane (0: less significant bit; 1: more significant bit)
||++++-++++----- N: Tile number from name table
|+-------------- H: Half of pattern table (0: "left"; 1: "right")
+--------------- 0: Pattern table is at $0000-$1FFF

```

The value written to PPUCTRL($2000) controls whether the background and sprites use the first pattern table ($0000-$0FFF) or the second pattern table ($1000-$1FFF). PPUCTRL bit 4 applies to backgrounds, bit 3 applies to 8x8 sprites, and bit 0 of each OAM entry's tile number applies to 8x16 sprites.

For example, if rows of a tile are numbered 0 through 7, row 1 of tile $69 in the left pattern table is stored with plane 0 in $0691 and plane 1 in $0699.

## Display convention

It is conventional for debugging emulators' video memory viewers to display the pattern table as two 16x16-tile grids side by side. They draw the pattern table at $0000-$0FFF on the left and the pattern table at $1000-$1FFF on the right. Each pattern table is commonly represented as a 128 by 128 pixel square, with 16 rows of 16 tiles. Usually the tiles are shown left to right, top to bottom, in Western reading order: $00 in the top left, $01 to the right of that, through $0F at the top right, then $10 through $1F on the second row, all the way through $FF at the bottom right. Some emulators have an option to rearrange the view for 8x16 sprites, where the first two rows are $00, $02, $04, ..., $1E, and $01, $03, $05, ..., $1F, and then each pair of rows below that shows another 16 pairs of tiles.

## OAM

The OAM (Object Attribute Memory) is internal memory inside the PPU that contains a display list of up to 64 sprites, where each sprite's information occupies 4 bytes.

## OAM (Sprite) Data

### Byte 0 - Y position

Y position of top of sprite

Sprite data is delayed by one scanline; you must subtract 1 from the sprite's Y coordinate before writing it here. Hide a sprite by moving it down offscreen, by writing any values between #$EF-#$FF here. Sprites are never displayed on the first line of the picture, and it is impossible to place a sprite partially off the top of the screen.

### Byte 1 - Tile/index

Tile index number

For 8x8 sprites, this is the tile number of this sprite within the pattern table selected in bit 3 of PPUCTRL($2000).

For 8x16 sprites (bit 5 of PPUCTRLset), the PPU ignores the pattern table selection and selects a pattern table from bit 0 of this number.

```text
76543210
||||||||
|||||||+- Bank ($0000 or $1000) of tiles
+++++++-- Tile number of top of sprite (0 to 254; bottom half gets the next tile)

```

Thus, the pattern table memory map for 8x16 sprites looks like this:
- $00: $0000-$001F
- $01: $1000-$101F
- $02: $0020-$003F
- $03: $1020-$103F
- $04: $0040-$005F
[...]
- $FE: $0FE0-$0FFF
- $FF: $1FE0-$1FFF

### Byte 2 - Attributes

Attributes

```text
76543210
||||||||
||||||++- Palette (4 to 7) of sprite
|||+++--- Unimplemented (read 0)
||+------ Priority (0: in front of background; 1: behind background)
|+------- Flip sprite horizontally
+-------- Flip sprite vertically

```

Flipping does not change the position of the sprite's bounding box, just the position of pixels within the sprite. If, for example, a sprite covers (120, 130) through (127, 137), it'll still cover the same area when flipped. In 8x16 mode, vertical flip flips each of the subtiles and also exchanges their position; the odd-numbered tile of a vertically flipped sprite is drawn on top. This behavior differs from the behavior of the unofficial 16x32 and 32x64 pixel sprite sizes on the Super NES, which will only vertically flip each square sub-region.

The three unimplemented bits of each sprite's byte 2 do not exist in the PPU and always read back as 0 on PPU revisions that allow reading PPU OAM through OAMDATA($2004). This can be emulated by ANDing byte 2 with $E3 either when writing to or when reading from OAM. Bits that have decayed also read back as 0 through OAMDATA. These are side effects of the DRAM controller precharging an internal data bus with 0 to prevent writing high-impedance values to OAM DRAM cells. [1]

### Byte 3 - X position

X position of left side of sprite.

X-scroll values of $F9-FF results in parts of the sprite to be past the right edge of the screen, thus invisible. It is not possible to have a sprite partially visible on the left edge. Instead, left-clipping through PPUMASK ($2001)can be used to simulate this effect.

## Details

### DMA

Most programs write to a copy of OAM somewhere in CPU addressable RAM (often $0200-$02FF) and then copy it to OAM each frame using the OAMDMA($4014) register. Writing N to this register causes the DMA circuitry inside the 2A03/07 to fully initialize the OAM by writing OAMDATA256 times using successive bytes from starting at address $100*N). The CPU is suspended while the transfer is taking place.

The address range to copy from could lie outside RAM, though this is only useful for static screens with no animation.

Not counting the OAMDMAwrite tick, the above procedure takes 513 CPU cycles (+1 on odd CPU cycles): first one (or two) idle cycles, and then 256 pairs of alternating read/write cycles. (For comparison, an unrolled LDA/STA loop would usually take four times as long.)

### Sprite 0 hits

Sprites are conventionally numbered 0 to 63. Sprite 0 is the sprite controlled by OAM addresses $00-$03, sprite 1 is controlled by $04-$07, ..., and sprite 63 is controlled by $FC-$FF.

While the PPU is drawing the picture, when an opaque pixel of sprite 0 overlaps an opaque pixel of the background, this is a sprite 0 hit . The PPU detects this condition and sets bit 6 of PPUSTATUS($2002) to 1 starting at this pixel, letting the CPU know how far along the PPU is in drawing the picture.

Sprite 0 hit does not happen:
- If background or sprite rendering is disabled in PPUMASK($2001)
- At x=0 to x=7 if the left-side clipping window is enabled (if bit 2 or bit 1 of PPUMASK is 0).
- At x=255, for an obscure reason related to the pixel pipeline.
- At any pixel where the background or sprite pixel is transparent (2-bit color index from the CHR pattern is %00).
- If sprite 0 hit has already occurred this frame. Bit 6 of PPUSTATUS ($2002) is cleared to 0 at dot 1 of the pre-render line. This means only the first sprite 0 hit in a frame can be detected.

Sprite 0 hit happens regardless of the following:
- Sprite priority. Sprite 0 can still hit the background from behind.
- The pixel colors. Only the CHR pattern bits are relevant, not the actual rendered colors, and any CHR color index except %00 is considered opaque.
- The palette. The contents of the palette are irrelevant to sprite 0 hits. For example: a black ($0F) sprite pixel can hit a black ($0F) background as long as neither is the transparent color index %00.
- The PAL PPU blanking on the left and right edges at x=0, x=1, and x=254 (see Overscan).

### Sprite overlapping

Priority between spritesis determined by their address inside OAM. So to have a sprite displayed in front of another sprite in a scanline, the sprite data that occurs first will overlap any other sprites after it. For example, when sprites at OAM $0C and $28 overlap, the sprite at $0C will appear in front.

### Internal operation

In addition to the primary OAM memory, the PPU contains 32 bytes (enough for 8 sprites) of secondary OAM memory that is not directly accessible by the program. During each visible scanline this secondary OAM is first cleared (set to all $FF), and then a linear search of the entire primary OAM is carried out to find sprites that are within y range for the next scanline (the sprite evaluation phase). The OAM data for each sprite found to be within range is copied into the secondary OAM, which is then used to initialize eight internal sprite output units.

See PPU renderingfor information on precise timing.

The reason sprites at lower addresses in OAM overlap sprites at higher addresses is that sprites at lower addresses also get assigned a lower address in the secondary OAM, and hence get assigned a lower-numbered sprite output unit during the loading phase. Output from lower-numbered sprite output units is wired inside the PPU to take priority over output from higher-numbered sprite output units.

Sprite 0 hit detection relies on the fact that sprite 0, when it is within y range for the next scanline, always gets assigned the first sprite output unit. The hit condition is basically sprite 0 is in range AND the first sprite output unit is outputting a non-zero pixel AND the background drawing unit is outputting a non-zero pixel . (Internally the PPU actually uses two flags: one to keep track of whether sprite 0 occurs on the next scanline, and another one—initialized from the first—to keep track of whether sprite 0 occurs on the current scanline. This is to avoid sprite evaluation, which takes place concurrently with potential sprite 0 hits, trampling on the second flag.)

### Dynamic RAM decay

Because OAM is implemented with dynamic RAM instead of static RAM, the data stored in OAM memory will quickly begin to decay into random bits if it is not being refreshed. The OAM memory is refreshed once per scanline while rendering is enabled (if either the sprite or background bit is enabled via the register at $2001), but on an NTSC PPU this refresh is prevented whenever rendering is disabled.

When rendering is turned off, or during vertical blanking between frames, the OAM memory will hold stable values for a short period before it begins to decay. It will last at least as long as an NTSC vertical blank interval (~1.3ms), but not much longer than this. [2]Because of this, it is not normally useful to write to OAM outside of vertical blank, where rendering is expected to start refreshing its data soon after the write. Writes to $4014or $2004should usually be done in an NMI routine, or otherwise within vertical blanking.

If using an advanced technique like forced blanking to manually extend the vertical blank time, it may be necessary to do the OAM DMA last, before enabling rendering mid-frame, to avoid decay.

Because OAM decay is more or less random, and with timing that is sensitive to temperature or other environmental factors, it is not something a game could normally rely on. Most emulators do not simulate the decay, and suffer no compatibility problems as a result. Software developers targeting the NES hardware should be careful not to rely on this.

Because PAL machines have a much longer vertical blanking interval, the 2C07 (PAL PPU) forcibly refreshes OAM during scanlines 265 through 310 (starting 24 scanlines after the start of NMI [3][4][5]), incrementing the OAM address once every 2 pixels (except at pixel 0). This prevents the values in DRAM from decaying in the remaining 46 scanlines before the picture starts and is long enough to allow unmodified NTSC vblank code to run correctly on PAL. As a result of this, software taking advantage of PAL's longer vblank must do OAM DMA early in vblank. In exchange, OAM decay does not occur at all on the PAL NES provided that rendering remains enabled - if rendering is turned off, then OAM can still decay during scanlines 311 and 0-264 (and mid-frame DMA can still be performed if necessary).

## See also
- PPU sprite evaluation
- PPU sprite priority
- Sprite overflow games

## References
- ↑"OAM"on Breaking NES Wiki. Accessed 2022-04-19.
- ↑Forum post:Re: Just how cranky is the PPU OAM?
- ↑Forum post:OAM reading on PAL NES
- ↑Forum post:PAL NES, sprite evaluation and $2004 reads/writes
- ↑BreakingNESWiki:PAL circuit analysis

## Nametables

A nametable is a 1024 byte area of memory used by the PPU to lay out backgrounds. Each byte in the nametable controls one 8x8 pixel character cell, and each nametable has 30 rows of 32 tiles each, for 960 ($3C0) bytes; the 64 ($40) remaining bytes are used by each nametable's attribute table. With each tile being 8x8 pixels, this makes a total of 256x240 pixels in one map, the same size as one full screen.

```text
     (0,0)     (256,0)     (511,0)
       +-----------+-----------+
       |           |           |
       |           |           |
       |   $2000   |   $2400   |
       |           |           |
       |           |           |
(0,240)+-----------+-----------+(511,240)
       |           |           |
       |           |           |
       |   $2800   |   $2C00   |
       |           |           |
       |           |           |
       +-----------+-----------+
     (0,479)   (256,479)   (511,479)

```
See also: PPU memory map

## Mirroring
Main article: Mirroring

The NES has four logical nametables, arranged in a 2x2 pattern. Each occupies a 1 KiB chunk of PPU address space, starting at $2000 at the top left, $2400 at the top right, $2800 at the bottom left, and $2C00 at the bottom right.

But the NES system board itself has only 2 KiB of VRAM (called CIRAM, stored in a separate SRAM chip), enough for two physical nametables; hardware on the cartridge controls address bit 10 of CIRAM to map one nametable on top of another.
- Horizontal arrangement: $2000 and $2800 contain the first nametable, and $2400 and $2C00 contain the second nametable (e.g. Super Mario Bros. ), accomplished by connecting CIRAM A10 to PPU A10
- Vertical arrangement: $2000 and $2400 contain the first nametable, and $2800 and $2C00 contain the second nametable (e.g. Kid Icarus ), accomplished by connecting CIRAM A10 to PPU A11
- Single-screen: All nametables refer to the same memory at any given time, and the mapper directly manipulates CIRAM A10 (e.g. many Raregames using AxROM)
- Four-screen nametables: The cartridge contains additional VRAM used for all nametables (e.g. Gauntlet , Rad Racer 2 )
- Other: Some advanced mappers can present arbitrary combinations of CIRAM, VRAM, or even CHR ROM in the nametable area. Such exotic setups are rarely used.

## Background evaluation
Main article: PPU rendering

Conceptually, the PPU does this 33 times for each scanline:
- Fetch a nametable entry from $2000-$2FFF.
- Fetch the corresponding attribute table entry from $23C0-$2FFF and increment the current VRAM address within the same row.
- Fetch the low-order byte of an 8x1 pixel sliver of pattern table from $0000-$0FF7 or $1000-$1FF7.
- Fetch the high-order byte of this sliver from an address 8 bytes higher.
- Turn the attribute data and the pattern table data into palette indices, and combine them with data from sprite datausing priority.

It also does a fetch of a 34th (nametable, attribute, pattern) tuple that is never used, but some mappersrely on this fetch for timing purposes.

## See also
- PPU attribute tables

## Attribute tables

An attribute table is a 64-byte array at the end of each nametablethat controls which palette is assigned to each part of the background.

Each attribute table, starting at $23C0, $27C0, $2BC0, or $2FC0, is arranged as an 8x8 byte array:

```text
       2xx0    2xx1    2xx2    2xx3    2xx4    2xx5    2xx6    2xx7
     ,-------+-------+-------+-------+-------+-------+-------+-------.
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xC0:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xC8:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xD0:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xD8:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xE0:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xE8:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
2xF0:| - + - | - + - | - + - | - + - | - + - | - + - | - + - | - + - |
     |   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     +-------+-------+-------+-------+-------+-------+-------+-------+
2xF8:|   .   |   .   |   .   |   .   |   .   |   .   |   .   |   .   |
     `-------+-------+-------+-------+-------+-------+-------+-------'

```

```text
,---+---+---+---.
|   |   |   |   |
+ D1-D0 + D3-D2 +
|   |   |   |   |
+---+---+---+---+
|   |   |   |   |
+ D5-D4 + D7-D6 +
|   |   |   |   |
`---+---+---+---'

```

Each byte controls the palette of a 32×32 pixel or 4×4 tile part of the nametable and is divided into four 2-bit areas. Each area covers 16×16 pixels or 2×2 tiles, the size of a [?] block in Super Mario Bros. Given palette numbers topleft, topright, bottomleft, bottomright, each in the range 0 to 3, the value of the byte is

```text
value = (bottomright << 6) | (bottomleft << 4) | (topright << 2) | (topleft << 0)

```

Or equivalently:

```text
7654 3210
|||| ||++- Color bits 3-2 for top left quadrant of this byte
|||| ++--- Color bits 3-2 for top right quadrant of this byte
||++------ Color bits 3-2 for bottom left quadrant of this byte
++-------- Color bits 3-2 for bottom right quadrant of this byte

```

Most games for the NES use 16×16 pixel metatiles(size of Super Mario Bros. ? block) or 32x32 pixel metatiles (width of SMB pipe) in order to align the map with the attribute areas.

## Worked example

Consider the byte at $23F2:

```text
 ,---- Top left
 3 1 - Top right
 2 2 - Bottom right
 `---- Bottom left

```

The byte has color set 2 at bottom right, 2 at bottom left, 1 at top right, and 3 at top left. Thus its attribute is calculated as follows:

```text
value = (bottomright << 6) | (bottomleft << 4) | (topright << 2) | (topleft << 0)
      = (2           << 6) | (2          << 4) | (1        << 2) | (3       << 0)
      = $80                | $20               | $04             | $03
      = $A7

```

To find the address of an attribute byte corresponding to a nametable address, see: PPU scrolling: Tile and attribute fetching

## Glitches

There are some well-known glitches when rendering attributes in NES and Famicom games.

While an attribute table specifies one of four three-color palettes for each 16x16 pixel region, the left-side clipping window in PPUMASK ($2001)is only 8 pixels wide.

This is the reason why games that use either horizontal or vertical mirroringmodes for arbitrary-direction scrollingoften have color artifacts on one side of the screen (on the right side in Super Mario Bros. 3 ; on the trailing side of the scroll in Kirby's Adventure ; and at the top and bottom in Super C ).

The game Alfred Chicken hides glitches on the left and right sides by using both left clipping and hiding the right side of the screen under solid-colored sprites. To mask the entire 240-scanline height, this approach would occupy 15 entries of 64 in the sprite table in 8x16 sprite mode, or 30 entries in the 8x8 mode.

## Expansion

There are two bits of memory in the attribute table that control the palette selection for each 16x16 pixel area on the screen. Because the PPU actually fetches that memory redundantly for each 8x1 pixel area as it draws the display, it is possible for a mapper to control this memory and supply different data for each read. The MMC5mapper does this for its 8x8 extended attribute mode.

## Palettes

The NES has a limited selection of color outputs. A 6-bit value in the palette memory area corresponds to one of 64 outputs. The emphasisbits of the PPUMASKregister ($2001) provide an additional color modifier.

For more information on how the colors are generated on an NTSC NES, see: NTSC video. For additional information on how the colors are generated on a PAL NES, see: PAL video.

## Palette RAM

|  | Palette 0 | Palette 1 | Palette 2 | Palette 3 |
| $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| Background | $3F0x | 0* | 1 | 2 | 3 | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 |
| Sprite | $3F1x | 1 | 2 | 3 | 1 | 2 | 3 | 1 | 2 | 3 | 1 | 2 | 3 |

* Note: Entry 0 of palette 0 is used as the backdrop color.

Backgrounds and sprites each have 4 palettes of 4 colors, located at $3F00-$3F1F in VRAM. Each byte in this palette RAM contains a 6-bit color value referencing one of the PPU's 64 colors. Entry 0 of each palette is unique in that it is transparent, so its color value is normally unused. However, because of the PPU's EXT functionality, entry 0 of palette 0 has the unique behavior of being the backdrop color. The backdrop color is the single color shown behind both the background and sprites, wherever both layers are transparent. Artistically, the backdrop color is usually considered a fourth color of the background and is sometimes called the universal background color .

A single element on the screen can only use a single palette. For backgrounds, this is usually a 16x16 pixel region, but may be as small as an 8x1 pixel sliver with assistance from a cartridge mapper. For sprites, this is a single sprite object, which is 8x8 or 8x16 pixels, depending on the current sprite size. The palette is selected with a 2-bit value referred to as attributes .

Ultimately, the color of a pixel is determined by background vs sprite (which selects the set of 4 palettes), the 2 bits of attributes (which select 1 of those 4 palettes), and the 2 bits of graphics or tile pattern data (which select the color from that palette). These create a 5-bit index into palette RAM:

```text
4bit0
-----
SAAPP
|||||
|||++- Pixel value from tile pattern data
|++--- Palette number from attributes
+----- Background/Sprite select

```

Note that entry 0 of each palette is also unique in that its color value is shared between the background and sprite palettes, so writing to either one updates the same internal storage. This means that the backdrop color can be written through both $3F00 and $3F10. Palette RAM as a whole is also mirroredthrough the entire $3F00-$3FFF region.

## Color Value Significance (Hue / Value)

As in some second-generation game consoles, values in the NES palette are based on hue and brightness:

```text
5 bit 0
-------
VV HHHH
|| ||||
|| ++++- Hue (phase, determines NTSC/PAL chroma)
++------ Value (voltage, determines NTSC/PAL luma)

```

Hue $0 is light gray, $1-$C are blue to red to green to cyan, $D is dark gray, and $E-$F are mirrors of $1D (black).

It works this way because of the way colors are represented in a composite NTSC or PAL signal, with the phase of a color subcarrier controlling the hue. For details regarding signal generation and color decoding, see NTSC video.

The canonical code for "black" is $0F.

The 2C03 RGB PPU used in the PlayChoice-10 and 2C05-99 in the Famicom Titler renders hue $D as black, not dark gray. The 2C04 PPUs used in many Vs. Systemarcade games have completely different palettes as a copy protection measure.

## Palettes

The 2C02 (NTSC) and 2C07 (PAL) PPU is used to generate an analog composite video signal. These were used in most home consoles.

The 2C03, 2C04, and 2C05, on the other hand, all output analog red, green, blue, and sync (RGBS) signals. The sync signal contains horizontal and vertical sync pulses in the same format as an all-black composite signal. Each of the three video channels uses a 3-bit DAC driven by a look-up table in a 64x9-bit ROM inside the PPU. The look-up tables (one digit for each of red, green, and blue, in order) are given below.

RGB PPUs were used mostly in arcade machines (e.g. Vs. System, Playchoice 10), as well as the Sharp Famicom Titler.

### 2C02

The RF Famicom, AV Famicom, NES (both front- and top-loading), and the North American version of the Sharp Nintendo TV use the 2C02 PPU. Unlike some other consoles' video circuits, the 2C02 does not generate RGB video and then encode that to composite. Instead it generates NTSC videodirectly in the composite domain, decoded by the television receiver into RGB to drive its picture tube.

Most emulators can use a predefined palette, such as one commonly stored in common .palformat, in which each triplet represents the 8bpc sRGB color that results from decoding a large flat area with a given palette value.

The palette seen on real hardware connected to a real television set has at least four sources of variation:
- variation in impedance mismatch between console and television set; this variance leads to different signal reflections with different differential phase distortion, which manifests itself in brighter colors losing saturation and shifting in hue.
- variation in user-adjustable settings of the television set (in particular, hue and saturation);
- variation in how television sets decode composite video into their native RGB display colorspace;
- variation in the native RGB colorspaces of television sets (red/green/blue phosphor chromaticities, color temperature).

The combined effect is that no single composite palette can match the intended display of every possible game title. Nintendo never specified a reference monitor to licensed developers, either. Emulators reproducing a palette or a signal decoding chain must decide on parameters for differential phase distortion, user-adjustable hue and saturation, composite decoding and assumed monitor colorimetry. For composite decoding and assumed monitor colorimetry, the coefficients from published standards such as SMPTE 170M can serve as reasonable defaults.

See this pagefor more details on a general algorithm to decode a PPU composite signal to color RGB.

The following palette was generated using Pally v0.22.1with the following arguments:

```text
pally.py --skip-plot -cld -phd 4 -e -o docs/NESDev/2C02G_wiki.pal

```

Download: File:2C02G wiki.pal

| $00 | $01 | $02 | $03 | $04 | $05 | $06 | $07 | $08 | $09 | $0A | $0B | $0C | $0D | $0E | $0F |
| $10 | $11 | $12 | $13 | $14 | $15 | $16 | $17 | $18 | $19 | $1A | $1B | $1C | $1D | $1E | $1F |
| $20 | $21 | $22 | $23 | $24 | $25 | $26 | $27 | $28 | $29 | $2A | $2B | $2C | $2D | $2E | $2F |
| $30 | $31 | $32 | $33 | $34 | $35 | $36 | $37 | $38 | $39 | $3A | $3B | $3C | $3D | $3E | $3F |

Other tools for generating a palette include one by Bisqwitand one by Drag. These simulate generating a large area of one flat color and then decoding that with the adjustment knobs set to various settings.

### 2C07

The PAL PPU (2C07) generates a composite PAL videosignal, which has a -15 degree hue shift relative to the 2C02 due to a different colorburst reference phase generated by the PPU ($x7 rather than $x8), in addition to the PAL colorburst phase being defined as -U ± 45 degrees.

Like NTSC, the PAL composite signal is affected by differential phase distortion to the same degree, if not slightly worse. Unlike NTSC, PAL composite has a mechanism to correct hue errors by shifting the phase of the colorburst reference on every line; thus the colors on the 2C07 will remain consistent on most PAL sets at the cost of slight further saturation loss.

The following palette was generated using Pally v0.22.1with the following arguments:

```text
python3 pally.py --skip-plot -cld -ppu "2C07" -phd 4 --delay-line-filter -e -o docs/NESDev/2C07_wiki.pal

```

Download: File:2C07 wiki.pal

| $00 | $01 | $02 | $03 | $04 | $05 | $06 | $07 | $08 | $09 | $0A | $0B | $0C | $0D | $0E | $0F |
| $10 | $11 | $12 | $13 | $14 | $15 | $16 | $17 | $18 | $19 | $1A | $1B | $1C | $1D | $1E | $1F |
| $20 | $21 | $22 | $23 | $24 | $25 | $26 | $27 | $28 | $29 | $2A | $2B | $2C | $2D | $2E | $2F |
| $30 | $31 | $32 | $33 | $34 | $35 | $36 | $37 | $38 | $39 | $3A | $3B | $3C | $3D | $3E | $3F |

### 2C03 and 2C05

This palette is intentionally similar to the NES's standard palette, but notably is missing the greys in entries $2D and $3D. The 2C03 is used in Vs. Duck Hunt , Vs. Tennis , all PlayChoice games, and the Sharp C1(Famicom TV). The 2C05 is used in some later Vs. games as a copy protection measure. A variant of the 2C05 without copy protection measures is present in the Sharp Famicom Titler, albeit with adjustments to the output (see below). Both have historically been used in RGB mods for the NES, as a circuit implementing `A0' = A0 xor (A1 nor A2) `can swap PPUCTRL and PPUMASK to make a 2C05 behave as a 2C03.

The formula for mapping the DAC integer channel value to 8-bit per channel color is `C = 255 * DAC / 7 `.

Download: File:2C03 wiki.pal

|  | $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| $0x | 333 | 014 | 006 | 326 | 403 | 503 | 510 | 420 | 320 | 120 | 031 | 040 | 022 | 000 | 000 | 000 |
| $1x | 555 | 036 | 027 | 407 | 507 | 704 | 700 | 630 | 430 | 140 | 040 | 053 | 044 | 000 | 000 | 000 |
| $2x | 777 | 357 | 447 | 637 | 707 | 737 | 740 | 750 | 660 | 360 | 070 | 276 | 077 | 000 | 000 | 000 |
| $3x | 777 | 567 | 657 | 757 | 747 | 755 | 764 | 772 | 773 | 572 | 473 | 276 | 467 | 000 | 000 | 000 |

Note that some of the colors are duplicates: $0B and $1A = 040, $2B and $3B = 276.

Monochrome works the same as the 2C02 (consistent across all RGB PPUs), but unlike the 2C02, emphasis on the RGB chips works differently; rather than "darkening" the specific color chosen, it sets the corresponding channel to full brightness instead.

### 2C05-99

The Sharp Famicom Titler (AN-510) contains a RC2C05-99 PPU, whose RGB output is fed into a X0858CEtranscoder chip. This chip handles the conversion from RGBS into Composite, and S-Video. The additional components outside the chip reduce the saturation of the output palette by half with the use of a voltage divider [1], specifically both the R-Y and B-Y color difference channels on pin 11 and pin 12 ( `U = U * 0.5; V = V * 0.5 `). This was likely done due to the highly saturated colors of RGB video, especially the 2C05-99's raw RGBS output, which may cause excessive color bleed on composite video.

Otherwise, the raw internal palette of the 2C05-99 PPU itself is believed to be identical to that of the 2C03.

| $00 | $01 | $02 | $03 | $04 | $05 | $06 | $07 | $08 | $09 | $0A | $0B | $0C | $0D | $0E | $0F |
| $10 | $11 | $12 | $13 | $14 | $15 | $16 | $17 | $18 | $19 | $1A | $1B | $1C | $1D | $1E | $1F |
| $20 | $21 | $22 | $23 | $24 | $25 | $26 | $27 | $28 | $29 | $2A | $2B | $2C | $2D | $2E | $2F |
| $30 | $31 | $32 | $33 | $34 | $35 | $36 | $37 | $38 | $39 | $3A | $3B | $3C | $3D | $3E | $3F |

### 2C04

All four 2C04 PPUs contain the same master palette, but in different permutations. It's almost a superset of the 2C03/5 palette, adding four greys, six other colors, and making the bright yellow more pure.

Much like the 2C03 and 2C02, using the greyscale bit in PPUMASKwill remap the palette by index, not by color. This means that with the scrambled palettes, each row will remap to the colors in the $0X column for that 2C04 version.

Visualization tool: RGB PPU Palette Converter

No version of the 2C04 was ever made with the below ordering , but it shows the similarity to the 2C03:

| 333 | 014 | 006 | 326 | 403 | 503 | 510 | 420 | 320 | 120 | 031 | 040 | 022 | 111 | 003 | 020 |
| 555 | 036 | 027 | 407 | 507 | 704 | 700 | 630 | 430 | 140 | 040 | 053 | 044 | 222 | 200 | 310 |
| 777 | 357 | 447 | 637 | 707 | 737 | 740 | 750 | 660 | 360 | 070 | 276 | 077 | 444 | 000 | 000 |
| 777 | 567 | 657 | 757 | 747 | 755 | 764 | 770 | 773 | 572 | 473 | 276 | 467 | 666 | 653 | 760 |

The PPUMASKmonochrome bit has the same implementation as on the 2C02, and so it has an unintuitive effect on the 2C04 PPUs; rather than forcing colors to grayscale, it instead forces them to the first column.

#### RP2C04-0001

MAME's source claims that Baseball , Freedom Force , Gradius , Hogan's Alley , Mach Rider , Pinball , and Platoon require this palette.

```text
755,637,700,447,044,120,222,704,777,333,750,503,403,660,320,777
357,653,310,360,467,657,764,027,760,276,000,200,666,444,707,014
003,567,757,070,077,022,053,507,000,420,747,510,407,006,740,000
000,140,555,031,572,326,770,630,020,036,040,111,773,737,430,473

```
Palette colors

|  | $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| $0x | 755 | 637 | 700 | 447 | 044 | 120 | 222 | 704 | 777 | 333 | 750 | 503 | 403 | 660 | 320 | 777 |
| $1x | 357 | 653 | 310 | 360 | 467 | 657 | 764 | 027 | 760 | 276 | 000 | 200 | 666 | 444 | 707 | 014 |
| $2x | 003 | 567 | 757 | 070 | 077 | 022 | 053 | 507 | 000 | 420 | 747 | 510 | 407 | 006 | 740 | 000 |
| $3x | 000 | 140 | 555 | 031 | 572 | 326 | 770 | 630 | 020 | 036 | 040 | 111 | 773 | 737 | 430 | 473 |

#### RP2C04-0002

MAME's source claims that Castlevania , Mach Rider (Endurance Course) , Raid on Bungeling Bay , Slalom , Soccer , Stroke & Match Golf (both versions), and Wrecking Crew require this palette.

```text
000,750,430,572,473,737,044,567,700,407,773,747,777,637,467,040
020,357,510,666,053,360,200,447,222,707,003,276,657,320,000,326
403,764,740,757,036,310,555,006,507,760,333,120,027,000,660,777
653,111,070,630,022,014,704,140,000,077,420,770,755,503,031,444

```
Palette colors

|  | $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| $0x | 000 | 750 | 430 | 572 | 473 | 737 | 044 | 567 | 700 | 407 | 773 | 747 | 777 | 637 | 467 | 040 |
| $1x | 020 | 357 | 510 | 666 | 053 | 360 | 200 | 447 | 222 | 707 | 003 | 276 | 657 | 320 | 000 | 326 |
| $2x | 403 | 764 | 740 | 757 | 036 | 310 | 555 | 006 | 507 | 760 | 333 | 120 | 027 | 000 | 660 | 777 |
| $3x | 653 | 111 | 070 | 630 | 022 | 014 | 704 | 140 | 000 | 077 | 420 | 770 | 755 | 503 | 031 | 444 |

#### RP2C04-0003

MAME's source claims that Balloon Fight , Dr. Mario , Excitebike (US), Goonies , and Soccer require this palette.

```text
507,737,473,555,040,777,567,120,014,000,764,320,704,666,653,467
447,044,503,027,140,430,630,053,333,326,000,006,700,510,747,755
637,020,003,770,111,750,740,777,360,403,357,707,036,444,000,310
077,200,572,757,420,070,660,222,031,000,657,773,407,276,760,022

```
Palette colors

|  | $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| $0x | 507 | 737 | 473 | 555 | 040 | 777 | 567 | 120 | 014 | 000 | 764 | 320 | 704 | 666 | 653 | 467 |
| $1x | 447 | 044 | 503 | 027 | 140 | 430 | 630 | 053 | 333 | 326 | 000 | 006 | 700 | 510 | 747 | 755 |
| $2x | 637 | 020 | 003 | 770 | 111 | 750 | 740 | 777 | 360 | 403 | 357 | 707 | 036 | 444 | 000 | 310 |
| $3x | 077 | 200 | 572 | 757 | 420 | 070 | 660 | 222 | 031 | 000 | 657 | 773 | 407 | 276 | 760 | 022 |

#### RP2C04-0004

MAME's source claims that Clu Clu Land , Excitebike (Japan), Ice Climber (both versions), and Super Mario Bros. require this palette.

```text
430,326,044,660,000,755,014,630,555,310,070,003,764,770,040,572
737,200,027,747,000,222,510,740,653,053,447,140,403,000,473,357
503,031,420,006,407,507,333,704,022,666,036,020,111,773,444,707
757,777,320,700,760,276,777,467,000,750,637,567,360,657,077,120

```
Palette colors

|  | $x0 | $x1 | $x2 | $x3 | $x4 | $x5 | $x6 | $x7 | $x8 | $x9 | $xA | $xB | $xC | $xD | $xE | $xF |
| $0x | 430 | 326 | 044 | 660 | 000 | 755 | 014 | 630 | 555 | 310 | 070 | 003 | 764 | 770 | 040 | 572 |
| $1x | 737 | 200 | 027 | 747 | 000 | 222 | 510 | 740 | 653 | 053 | 447 | 140 | 403 | 000 | 473 | 357 |
| $2x | 503 | 031 | 420 | 006 | 407 | 507 | 333 | 704 | 022 | 666 | 036 | 020 | 111 | 773 | 444 | 707 |
| $3x | 757 | 777 | 320 | 700 | 760 | 276 | 777 | 467 | 000 | 750 | 637 | 567 | 360 | 657 | 077 | 120 |

#### Games compatible with multiple different PPUs

Some games don't require that arcade owners have the correct physical PPU.

At the very least, the following games use some of the DIP switches to support multiple different PPUs:
- Atari RBI Baseball
- Battle City
- Star Luster
- Super Sky Kid
- Super Xevious
- Tetris (Tengen)
- TKO Boxing

#### LUT approach

Emulator authors may implement the 2C04 variants as a LUT indexing the "ordered" palette. This has the added advantage of being able to use preexisting .pal files if the end user wishes to do so.

Repeating colors such as 000 and 777 may index into the same entry of the "ordered" palette, as this is functionally identical.

```text
 const unsigned char PaletteLUT_2C04_0001 [64] ={
    0x35,0x23,0x16,0x22,0x1C,0x09,0x1D,0x15,0x20,0x00,0x27,0x05,0x04,0x28,0x08,0x20,
    0x21,0x3E,0x1F,0x29,0x3C,0x32,0x36,0x12,0x3F,0x2B,0x2E,0x1E,0x3D,0x2D,0x24,0x01,
    0x0E,0x31,0x33,0x2A,0x2C,0x0C,0x1B,0x14,0x2E,0x07,0x34,0x06,0x13,0x02,0x26,0x2E,
    0x2E,0x19,0x10,0x0A,0x39,0x03,0x37,0x17,0x0F,0x11,0x0B,0x0D,0x38,0x25,0x18,0x3A
};

const unsigned char PaletteLUT_2C04_0002 [64] ={
    0x2E,0x27,0x18,0x39,0x3A,0x25,0x1C,0x31,0x16,0x13,0x38,0x34,0x20,0x23,0x3C,0x0B,
    0x0F,0x21,0x06,0x3D,0x1B,0x29,0x1E,0x22,0x1D,0x24,0x0E,0x2B,0x32,0x08,0x2E,0x03,
    0x04,0x36,0x26,0x33,0x11,0x1F,0x10,0x02,0x14,0x3F,0x00,0x09,0x12,0x2E,0x28,0x20,
    0x3E,0x0D,0x2A,0x17,0x0C,0x01,0x15,0x19,0x2E,0x2C,0x07,0x37,0x35,0x05,0x0A,0x2D
};

const unsigned char PaletteLUT_2C04_0003 [64] ={
    0x14,0x25,0x3A,0x10,0x0B,0x20,0x31,0x09,0x01,0x2E,0x36,0x08,0x15,0x3D,0x3E,0x3C,
    0x22,0x1C,0x05,0x12,0x19,0x18,0x17,0x1B,0x00,0x03,0x2E,0x02,0x16,0x06,0x34,0x35,
    0x23,0x0F,0x0E,0x37,0x0D,0x27,0x26,0x20,0x29,0x04,0x21,0x24,0x11,0x2D,0x2E,0x1F,
    0x2C,0x1E,0x39,0x33,0x07,0x2A,0x28,0x1D,0x0A,0x2E,0x32,0x38,0x13,0x2B,0x3F,0x0C
};

const unsigned char PaletteLUT_2C04_0004 [64] ={
    0x18,0x03,0x1C,0x28,0x2E,0x35,0x01,0x17,0x10,0x1F,0x2A,0x0E,0x36,0x37,0x0B,0x39,
    0x25,0x1E,0x12,0x34,0x2E,0x1D,0x06,0x26,0x3E,0x1B,0x22,0x19,0x04,0x2E,0x3A,0x21,
    0x05,0x0A,0x07,0x02,0x13,0x14,0x00,0x15,0x0C,0x3D,0x11,0x0F,0x0D,0x38,0x2D,0x24,
    0x33,0x20,0x08,0x16,0x3F,0x2B,0x20,0x3C,0x2E,0x27,0x23,0x31,0x29,0x32,0x2C,0x09
};

```

## Backdrop color

The backdrop color ($3F00) is shown wherever backgrounds and sprites are both transparent, as well as in the border regionon NTSC and RGB PPUs. When only one of background or sprite rendering is disabled, the disabled component is treated as transparent. Disabling components in the left column via PPUMASKalso treats them as transparent there.

### Backdrop override

When both background and sprite rendering are disabled, this is called forced blank. During forced blank, the PPU normally draws the backdrop color. However, if the current VRAM address in vpoints into palette RAM ($3F00-$3FFF), then the color at that address will be drawn, instead, overriding the backdrop color. This can allow the CPU to deliberately select colors to draw to the screen, including in the border region, for effects such as color bars or to draw more colors on the screen than is possible during rendering. It can also be used to show the normally-unused transparent colors in $3Fx4/$3Fx8/$3FxC.

More commonly, though, backdrop override results in a glitch where updating palettes outside of vblank causes the palette to be briefly drawn on the screen. Because of this, palette updates should be timed to occur during vblank. Backdrop override can also occur naturally based on scroll position if v points into palette RAM when rendering disables, usually resulting in colors flashing in the 2 scanlines of border at the bottom of the screen. Fortunately, this border flashing is normally hidden by overscan.

Backdrop override is not a deliberate PPU feature, but rather a side effect of how palette RAM is addressed. Palette RAM has just one address input, which is normally the address produced by the rendering hardware. However, when palettes are written by the CPU, it instead needs to use the CPU's target address. The PPU draws whatever color is output from palette RAM, so changing the address to allow CPU access also changes the color drawn to the screen. This is similar to color RAM dots on some Sega consoles, but occurs continuously rather than just during the CPU access.

## Color names

When programmers and artists are communicating, it's often useful to have human-readable names for colors. Many graphic designers who have done web or game work will be familiar with HTML color names.

### Luma
- $0F: Black
- $00: Dark gray
- $10: Light gray or silver
- $20: White
- $01-$0C: Dark colors, medium mixed with black
- $11-$1C: Medium colors, similar brightness to dark gray
- $21-$2C: Light colors, similar brightness to light gray
- $31-$3C: Pale colors, light mixed with white

### Chroma

Names for hues:
- $x0: Gray
- $x1: Azure
- $x2: Blue
- $x3: Violet
- $x4: Magenta
- $x5: Rose
- $x6: Red or maroon
- $x7: Orange
- $x8: Yellow or olive
- $x9: Chartreuse
- $xA: Green
- $xB: Spring
- $xC: Cyan

### RGBI

These NES colors approximate colors in 16-color RGBI palettes, such as the CGA, EGA, or classic Windows palette, though the NES doesn't really have particularly good approximations:
- $0F: 0/Black
- $02: 1/Navy
- $1A: 2/Green
- $1C: 3/Teal
- $06: 4/Maroon
- $14: 5/Purple
- $18: 6/Olive ($17 for the brown in CGA/EGA in RGB)
- $10: 7/Silver
- $00: 8/Gray
- $12: 9/Blue
- $2A: 10/Lime
- $2C: 11/Aqua/Cyan
- $16: 12/Red
- $24: 13/Fuchsia/Magenta
- $28: 14/Yellow
- $30: 15/White

## See also
- NTSC video- details of the NTSC signal generation and how it produces the palette
- PAL video
- Palettes (gallery)- a few different visualizations of PPU palettes.
- Another palette test- Simple test ROM to display the palette.
- Full palette demo- Demo that displays the entire palette with all emphasis settings at once.
- RGB PPU Palette Converter- RGB PPU palette conversion and visualization tool, written by WhoaMan.

## References
- Re: Various questions about the color palette and emulators- 2012 collection of 2C03, 2C04, 2C05 palettes.

## Memory map

### PPU memory map

The PPUaddresses a 14-bit (16kB) address space, $0000-$3FFF, completely separate from the CPU's address bus. It is either directly accessed by the PPU itself, or via the CPU with memory mapped registersat $2006 and $2007.

| Address range | Size | Description | Mapped by |
| $0000-$0FFF | $1000 | Pattern table 0 | Cartridge |
| $1000-$1FFF | $1000 | Pattern table 1 | Cartridge |
| $2000-$23BF | $03c0 | Nametable 0 | Cartridge |
| $23C0-$23FF | $0040 | Attribute table 0 | Cartridge |
| $2400-$27BF | $03c0 | Nametable 1 | Cartridge |
| $27C0-$27FF | $0040 | Attribute table 1 | Cartridge |
| $2800-$2BBF | $03c0 | Nametable 2 | Cartridge |
| $2BC0-$2BFF | $0040 | Attribute table 2 | Cartridge |
| $2C00-$2FBF | $03c0 | Nametable 3 | Cartridge |
| $2FC0-$2FFF | $0040 | Attribute table 3 | Cartridge |
| $3000-$3EFF | $0F00 | Unused | Cartridge |
| $3F00-$3F1F | $0020 | Palette RAM indexes | Internal to PPU |
| $3F20-$3FFF | $00E0 | Mirrors of $3F00-$3F1F | Internal to PPU |

## Hardware mapping

The NES has 2kB of RAM dedicated to the PPU, usually mapped to the nametable address space from $2000-$2FFF, but this can be rerouted through custom cartridge wiring. The mappings above are the addresses from which the PPU uses to fetch data during rendering. The actual devices that the PPU fetches pattern, name table and attribute table data from is configured by the cartridge.
- $0000-1FFF is normally mapped by the cartridge to a CHR-ROM or CHR-RAM, often with a bank switching mechanism.
- $2000-2FFF is normally mapped to the 2kB NES internal VRAM, providing 2 nametables with a mirroringconfiguration controlled by the cartridge, but it can be partly or fully remapped to ROM or RAM on the cartridge, allowing up to 4 simultaneous nametables.
- $3000-3EFF is usually a mirror of the 2kB region from $2000-2EFF. The PPU does not render from this address range, so this space has negligible utility.
- $3F00-3FFF is not configurable, always mapped to the internal palette control.

## OAM

In addition, the PPU internally contains 256 bytes of memory known as Object Attribute Memorywhich determines how sprites are rendered. The CPU can manipulate this memory through memory mapped registersat OAMADDR($2003), OAMDATA($2004), and OAMDMA($4014). OAM can be viewed as an array with 64 entries. Each entry has 4 bytes: the sprite Y coordinate, the sprite tile number, the sprite attribute, and the sprite X coordinate.

| Address Low Nibble | Description |
| $0, $4, $8, $C | Sprite Y coordinate |
| $1, $5, $9, $D | Sprite tile # |
| $2, $6, $A, $E | Sprite attribute |
| $3, $7, $B, $F | Sprite X coordinate |
- ↑Sharp CZ-880 service manual schematic, which uses the same X0858CE transcoder chip and voltage divider resistors on the color-difference I/O pins

# PRG RAM circuit

Source: https://www.nesdev.org/wiki/PRG_RAM_circuit

The iNESformat implies 8 KiB of PRG RAM at $6000–$7FFF, which may or may not be battery backed, even for discrete boardssuch as NROMand UxROMthat never actually had RAM there. This inspired some people on the nesdev.org BBS to come up with circuits to add PRG RAM to the original boards, so that games relying on it can run on an NES. The primary problem is in producing the enable signals for a 62256or 6264 static RAMor compatible PSRAM.

On the forum, kyuusaku and Bregalad discussed PRG RAM decoder circuits built from 7400 series partsto approximate this behavior in an NES cartridge board. The first tries took two chips [1]or had possible timing problems. [2][3]They settled on the following circuits:

## Decoding

### Using 7410

kyuusaku suggested a circuit based on a 74HC10(triple three-input NAND) stick a pulldown on CE2 to take advantage of Phi2 going high-impedance during reset in order to "offer some write protection". [4]

```text
           ,-------------- ROM /CE
          |   ____
/ROMSEL --+--|    `-.
             |       \
A14 ---------|        )o-- RAM /CE
             |       /
A13 ---------|____,-'

              ____
+5V ------+--|    `-.
          |  |       \
          `--|        )o-- ROM /OE
             |       /
R/W ------+--|____,-'
          |
          `--------------- RAM /WE

Phi2 ---------+----------- RAM CE2
              |
              <
              < "big R"
              <
              |
GND ----------+----------- RAM /OE

```

### Using 7420

He also suggested a circuit based on a 74HC20 (double 4-input NAND), which appears to be the same one in Family BASIC : Or you could just use a NAND4 to decode any active low memory, also using the /WE priority method. If this is done with a two gate 7420, the second gate could be used to invert r/w to prevent bus conflicts as in the circuit above. This is probably the *final* best way unless you happen to need the extra AND3 from the 7410 and have a positive CE.

The pinout:
- A = Phi2
- B = /ROMSEL
- C = A14
- D = A13
- Y = PRG RAM /CE
- PRG RAM /OE = GND
- PRG RAM /WE = Vcc or R//W, depending on the Family BASIC cart's write-protect switch

Kevin Horton suggested the same circuit.

You could also use the other gate to invert R//W for /OE on the ROM to prevent bus conflicts.

### Using 74139

If you don't need bus conflict prevention, you can use a 74HC139(double 2-to-4 decoder), which may be cheaper or have better timing than a 74HC20. This circuit resembles the decoder in Jaleco's discrete mappers ( 87and 140), which uses a 74139 to decode a single mapper register to $6000–$7FFF.
- 1/E = GND
- 1A0 = M2
- 1A1 = A14
- 2/E = 1/Y3
- 2A0 = A13
- 2A1 = /ROMSEL
- PRG RAM /CE = 2/Y3

Proof:

| 1A0 | 1A1 | 1/Y3 | 2A0 | 2A1 | 2/Y3 |
| 0 | x | 1 | x | x | 1 |
| 1 | 0 | 1 | x | x | 1 |
| 1 | 1 | 0 | 1 | x | 1 |
| 1 | 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 | 1 | 0 |

See further suggestions from kyuusaku.

The PlayChoice version of Mike Tyson's Punch-Out!! uses an extra IC to add battery-backed RAM. The digits in existing photos are hard to read, but it is believed to be a 74HC139. Its wiring has not been traced.

## /ROMSEL delay

One thing that can complicate adding PRG RAM to a board is the fact that /ROMSEL and M2, used together to decode $6000–$7FFF, do not change at the same time. /ROMSEL is the logical NAND of M2 and PRG A15. This is accomplished by sending M2 and PRG A15 into a 74LS139two-to-four line decoder on the NES main board. This introduces a small delay of up to 33 ns between the time M2 rises and the time /ROMSEL falls.

If this delay is too long it can cause unintentional writes to PRG RAM when writing to mapper registers $E000-$FFFF.

This is not a problem for the original cartridge hardware because the RAM chips used to require a /WE (Write Enable) pulse of at least 50ns to 70ns depending on the chip. This means that the spurious /WE signal generated by this delay (max. 33ns) will not be sufficient to trigger a write on the RAM chip. The circuits above give even more headroom as they tie PRG RAM /OE to ground and decode to /CE. The /CE to end of write timing is typically longer than the minimum /WE pulse width.

If your RAMs are faster than these timing specifications, your decoding logic must delay M2 by about 33 ns to match the /ROMSEL delay, as in the 74139-based circuit shown above. In this post, lidnariq suggested adding a resistor and capacitor:

```text
card edge M2 --- 1k --- + --- 7420
                        |
                       33pF
                        |
                       GND

```

### /ROMSEL delay issues

This delay is obtained by decreasing the voltage rise according to R·C. However, digital chips have minimum permissible rising speed, so the rise speed cannot be too slow because it might produce oscillation inside the digital input. Another option might be not to delay M2 but instead filter quick pulses on RAM /CE down by using capacitor connected to ground or a power supply:

```text
                      ______________________________________________________
card edge M2 --------| combinatory circuit that outputs                     |----+-----|/CE
card edge /ROMSEL ---| 0 when M2 = '1', /ROMSEL = '0', A14 = '1', A13 = '1' |    |     |
card edge A14     ---| 1 otherwise                                          |    1nF   |   RAM
card edge A13 -------|______________________________________________________|    |     |_________
                                                                             GND or +5V

```

If you latch data/address on the falling edge of M2 of writes to $4020–$7FFF, you don't need to worry about this delay because /ROMSEL still has the correct logic level at this point.

## Battery backup

Adding battery backup to RAM may be desired for maintaining data while the console is off. Most RAMs have a special low-power data retention mode, which decreases current consumption to few microamps, but the following need to be fulfilled:
- voltage supply in data retention mode "Vret" should be ≥ 2V (the "data retention voltage" in the datasheet)
- with this schematic, the voltage supply must be ≤ ordinary power supply voltage Vcc
- memory must become deselected before supply voltage drops from Vcc to Vret,
- memory must remain deselected for the whole time Vret is supplied.

```text
                    D1           ___________
    5V -------------|>|--+      |       RAM
                         |---+--| VCC
    3.3V battery----|>|--+   |  |
                    D2       R1 |
                             |  |
   RAM /CE decoding logic----+--| /CE
                                |___________

```

D1 ensures that the 3.3 V battery only powers the RAM, not the whole cartridge when in standby mode. D2 keeps the 5 V from charging the battery (permissible if the battery is rechargeable). R1 (100k should be enough) ties /CE at high level when power is cut off.

Note that not all diodes are created equal. It is tempting to use Schottky diodes for their lower forward voltage drop. However, Schottky diodes generally have a high reverse leakage current. If D1 is a Schottky, the battery will drive some current backwards through this diode, attempting to power the ROMs and other chips on the cart. Though it isn't much current and it is hard to measure, it is still much more current than normal and the battery's life will be shortened. If D2 is a Schottky, the reverse leakage will attempt to charge the battery from the console's power. For a CR2032, the maximum charging current before damage is 1uA and the leakage may or may not exceed this. So, in general, you shouldn't use Schottky diodes. There are likely to be more exotic solutions or different diodes that are technically superior. Sticking to the ordinary 1N4148/1N914 may be the best advice though, especially if you are interested in maintaining the original spirit of simpler times in your design.

If your RAM /CE decoding logic does not become high impedance in power off mode, the voltage at RAM /CE might drop after power down (for example, the AX5202P DIL40 pirate MMC3 chip seems to have its RAM /CE output at very low resistance with respect to ground when not powered, and the above circuit after power loss makes RAM /CE voltage drop to 1 V which leads to data corruption). To protect against that situation, RAM /CE decoding logic path must become open circuit after powering off. The following transistor is essentially a switch that does the job:

```text
                                 D1           ___________
    5V --------------------------|>|--+      |       RAM
                                      |---+--| VCC
    3.3V battery-----------------|>|--+   |  |
                                 D2       R1 |
                                          |  |
    RAM /CE decoding logic--- E   C ------+--| /CE
                              \___/          |___________
                                | B  NPN
    5V -----------------1k------+

```

When no 5V is present or 5V is present but RAM /CE decoding circuit outputs high level, transistor is open. When 5V is present and RAM /CE decoding circuit outputs low level, RAM /CE becomes low.

See also: Battery circuit schematic

## References
- Loopy pointed out the /ROMSEL delay here.
- Further investigation performed in this thread.
- 6264P-12 8Kx8 SRAM Data Sheet
- PRG RAM decoding circuitry - problems [5]

# Palette change mid frame

Source: https://www.nesdev.org/wiki/Palette_change_mid_frame

Changing palette entries in the middle of a frame on the NES is difficult, but marginally possible.

A few games are known to change palette entries for a status bar region:
- Day Dreamin' Davey
- Fantastic Adventures of Dizzy
- Startropics
- Wizards & Warriors
- Wizards & Warriors 3

Indiana Jones and the Last Crusade changes its background color many times across the title screen for a gradient sky effect:

Other games using mid frame palette changes:
- Ivan Ironman Stewart's Super Off-Road - on the "Speed Shop" screen, swaps colors for the 4 panels below.

## Details

To write to the palette in the middle of the screen, the following sequence of operations need to be done:
- Disable rendering ($2001)
- Set PPU address ($2006)
- Write new palette ($2007)
- Restore PPU address ($2006)
- Re-enable rendering ($2001)

Ideally, these should be done within or mostly within horizontal blanking to minimize the appearance of visual errors. There are several problems:
- NTSC horizontal blank only lasts 21 cycles, which is not enough time to fit all of these steps at once.
  - Half of the address may be written to $2006 early.
  - Three values can be loaded into the A, X, Y registers in advance of blanking to avoid extra load cycles.
  - Most IRQ or $2002 polling techniques for timing are subject to jitter, varying by about 7 cycles, which cuts into the usable horizontal blank time significantly.
- Because sprites are evaluated one line in advance, turning off rendering will cause the first line of sprites to be corrupted after re-enabling.
  - The write to disable rendering ($2001) should be done after pixel 240 on a scanline to avoid corrupting all sprites on the next frame (see: Errata).
  - After the change, one line with background rendering enabled but sprites hidden can be used to flush the invalid sprite evaluation buffer. (With background rendering on, sprite evaluation will resume but remain hidden.)
- While rendering is turned off, and the PPU address is pointing at a palette entry at the same time, this will become the current background color,
  - If the background color is unchanged and stored redundantly at PPU $3F00/4/8/C... BIT $2007 can be used to skip over the background color, followed by 3 writes to $2007, returning the PPU address to point at the background color again. This can be used to change 3 colors in a single horizontal blank, and if rendering is kept off 3 more colors may be updated in each subsequent line. An extra empty line is needed after the palette writes are finished, since there is not enough time in horizontal blank to write 3 colors and restore the PPU address and return to rendering.

Because of these issues, it is best not to use this techniques where sprites may overlap the affected lines. Indiana Jones hides some potential visual errors by only working where the background is already blank, and only changing the background color. Games that change colors for a status bar can use blank lines at the top of the status bar to similarly avoid visual errors.

PPUADDR Pointer technique: While rendering is turned off, it may be marginally useful to point the PPUADDR to one of the 16 palette entries to have the background rendered as that colour. This can serve to create lines of colours not otherwise available; or available otherwise only available to the sprite plane. Once done, you should restore the scrolling position and nametable selection before turning rendering on again. In practice, you prepare the palettes as per normal during vblank and then have the PPU look up any palette entry as if it was the backdrop colour; mid-frame.

## See Also
- PPU palettes
- PPU scrolling
- PPU rendering
- PPU sprite evaluation
- Consistent frame synchronization
- Errata

## References
- Re: The quest for mid-screen palette changes!- useful summary post, discussion thread
- Re: would screen splitting give extra 13 colours for tiles?- annotated analysis of Indiana Jones
- Palette swap within the game region?- discussion thread
- Hblank - Palette swap mid frame, etc....- discussion thread
- Update of my Window demo with mid-frame palette writes- ROM/src demonstration of background color changes
- Another palette test- ROM/src displays the full NES palette on a single screen, updating the colors in horizontal blank

# Port test controller

Source: https://www.nesdev.org/wiki/Port_test_controller

The port test controlleris a test device with two standard controllers that also provides a fixed signature on D3 and D4 of both joypads via an NES-INP-01 board. The device plugs into both controller ports using a single two-plug connector, like the Four Score. It was used in factories for validating NES controller port input.

## Input ($4016 write)

```text
7  bit  0
---- ----
.... ...S
        |
        +- Controller shift register strobe

```

This matches the normal strobe behavior used by the standard controllerand applies to all shift registers in the device.

## Output ($4016/4017 read)

```text
$4016:
7  bit  0
---- ----
xxx4 3xxD
   | |  |
   | |  +- Joypad 1 standard controller status bit
   | +---- Joypad 1 D3 signature
   +------ Joypad 1 D4 signature

$4017:
7  bit  0
---- ----
xxx4 3xxD
   | |  |
   | |  +- Joypad 2 standard controller status bit
   | +---- Joypad 2 D3 signature
   +------ Joypad 2 D4 signature

```

The results from the device's two standard controllers are returned in bit 0 of the corresponding register, as normal. Bits 3 and 4 of each register return a signature from a shift register. The 4 signatures use only 2 shift registers in total, with 1 shift register handling each joypad register. D4 taps the last bit, Q8, of the shift register as normal, while D3 taps Q6, causing it to skip the first two bits, returning now what D4 will return two reads later.

```text
Joypad 1 signature:
0  - (Always 1)  <-- D4 starts here
1  - (Always 0)
2  - (Always 1)  <-- D3 starts here
3  - (Always 0)
4  - (Always 1)
5  - (Always 0)
6  - (Always 1)
7  - (Always 0)

8+ - (Always 1)

Joypad 2 signature:
0  - (Always 0)  <- D4 starts here
1  - (Always 1)
2  - (Always 0)  <- D3 starts here
3  - (Always 1)
4  - (Always 0)
5  - (Always 1)
6  - (Always 0)
7  - (Always 1)

8+ - (Always 0)

```

## References
- Forum post:Port Test Cart - How does this work?

# PowerPak

Source: https://www.nesdev.org/wiki/PowerPak

The PowerPak is a Flash Cartridgemade by RetroUSB. It uses an FPGAto emulate a wide variety of mappers, allowing the user to store a large collection of ROMs on a single Compact Flash card and run them on an NES. It is widely used by homebrew NES developers to test their software. It's also compatible with the CopyNES.

In addition to NES ROMs, the PowerPak is able to play FDSdisk images, as well as NSFmusic files.

Famicom expansion audio is supported, and output on the EXP 6 expansion pin on the cartridge connector. A simple modification to the NES allows the expansion audio to be mixed with its output.

Specifications:
- PRG size: 512 KB (252 KB for NSF)
- CHR size: 512 KB
- Auxiliary PRG-RAM size: 32 KB

Product page: http://www.retrousb.com/product_info.php?products_id=34

## Mapper Compatibility

The PowerPak mappers have undergone several revisions, gradually improving compatibility. After official development ceased in 2010, Loopy and TheFox have each created a supplemental set of PowerPak mappers to improve its capabilities.

The commonly recommended setup is:
- Begin with the Official mapper set.
- Add Loopy's mapper set on top, replacing files.
- Add the PowerMapper set on top if you want savestate support (see its readme).
- Add any of the additional single mappers if needed.
- Replace the N.MAP loader with a patched versionso newer ROMs with header byte 15 setcan be loaded.

### PowerMappers

TheFox created a set of revised PowerPak mappers to supplement or augment the existing ones, most notably adding a savestate feature for the mappers it contains, but removing the Game Genie feature.

Download: http://fo.aspekt.fi
- NROM( 0)
- MMC1( 1)
- UxROM( 2)
- CxROM( 3)
- MMC3( 4)
- AxROM( 7)
- MMC2( 9)
- MMC4( 10)
- ColorDreams( 11)
- BxROM( 34)
- GxROM( 66)
- FME-7( 69, no expansion audio)
- Codemasters( 71)
- MMC3/ TxSROM( 118)
- MMC3/ TQROM( 119)

Known problems:
- Mapper 4 IRQ is delayed by 2 cycles like RAMBO-1to work around noise issues with PPU A12. This does not significantly affect most games.
- Mapper 69 does not support the Sunsoft 5B expansion audioused in Gimmick!

### Loopy's Mappers

Loopy released a set of revised PowerPak mappers in 2011, adding fixes and additional support for several mappers:

Download: http://3dscapture.com/NES/powerpak_loopy.zip
- CNROM( 3)
- MMC3( 4)
- MMC5( 5, no expansion audio)
- N163( 19)
- VRC4( 21, 23, 25)
- VRC6( 24, 26)
- BxROM( 34)
- Sunsoft-5B( 69)
- Codemasters( 71)
- JY Company( 90, partial)
- FDS
- NSF(no MMC5 audio, no VRC7 audio)

Known problems:
- Mapper 4 IRQ has reliability issues due to PPU A12 noise, causing status bars etc. to jitter up and down on some systems. (A fixed version is available: forum thread.)

Notes:
- Mapper 3 now supports unlicensed oversize variants (e.g. used by Panesian games).
- Mapper 4 now supports Startropics.
- Mapper 5 does not support the MMC5 expansion audio.

### Myask's Mappers (WIP)

Myaskmade a few mappers not yet covered by others.

Download: here. BBS Thread: here.
- Irem G-101 ( 032, but Major League hack/submapper not implemented)
- Irem H3001 ( 065)
- Taito TC0190 ( 033)
  - Note that some mapper 48 roms have been mislabeled as mapper 33.
- Taito TC0690, TC0190+PAL16R4 ( 048, very buggy)
- Magicseries Corp ( 107)

### Miscellaneous
- Action 53 mapper ( 028): forum thread
- GTROM( 111): forum thread
- Magic Kid GooGoo ( 190): forum thread
- UNROM 512( 030): forum post
- UXROM 512Support up to 512k PRG: forum post
- SXROM( 001): packaged with PR8, but created by bunnyboy
- NES 2.0 Default Expansion Deviceheader incompatibility fix: forum thread
- Nova's Rad PowerPak Menu: forum thread(alternative PowerPak menu)

### Offical Mappers V1.35b

The last official release of mappers was in 2010. It supports a wide variety of popular mappers.

Download: here

Supported mappers:

| 000 | 001 | 002 | 003 | 004 | 005 | 006 | 007 | 008 | 009 | 010 | 011 | 012 | 013 | 014 | 015 |
| 016 | 017 | 018 | 019 | 020 | 021 | 022 | 023 | 024 | 025 | 026 | 027 | 028 | 029 | 030 | 031 |
| 032 | 033 | 034 | 035 | 036 | 037 | 038 | 039 | 040 | 041 | 042 | 043 | 044 | 045 | 046 | 047 |
| 048 | 049 | 050 | 051 | 052 | 053 | 054 | 055 | 056 | 057 | 058 | 059 | 060 | 061 | 062 | 063 |
| 064 | 065 | 066 | 067 | 068 | 069 | 070 | 071 | 072 | 073 | 074 | 075 | 076 | 077 | 078 | 079 |
| 080 | 081 | 082 | 083 | 084 | 085 | 086 | 087 | 088 | 089 | 090 | 091 | 092 | 093 | 094 | 095 |
| 096 | 097 | 098 | 099 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | 108 | 109 | 110 | 111 |
| 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119 | 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
| 128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 | 139 | 140 | 141 | 142 | 143 |
| 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 |
| 160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 |
| 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 |
| 192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 | 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 |
| 208 | 209 | 210 | 211 | 212 | 213 | 214 | 215 | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 |
| 224 | 225 | 226 | 227 | 228 | 229 | 230 | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 |
| 240 | 241 | 242 | 243 | 244 | 245 | 246 | 247 | 248 | 249 | 250 | 251 | 252 | 253 | 254 | 255 |

Known problems:
- Mapper 2 limited to 256k PRG. (An oversized version exists for 512k PRG: forum thread.)
- Mapper 3 limited to CNROM support, excluding unlicensed oversize variants (e.g. used by Panesian games).
- Mapper 4 does not support Startropics. (See mapper 4 and MMC6.)
- Mapper 5 (MMC5) is incomplete, and fails to run most MMC5 games.
- Mapper 23 (VRC2/4 variants) is listed as buggy.
- Mapper 92 (Jaleco-JF variant) is listed as buggy.
- Mapper 95 (Namcot-3425) is listed as buggy.
- Mapper 96 (Oeka Kids) is listed as buggy.

## Software development limitations

Aside from mapper incompatibility, there are minor differences between running NES programs on the PowerPak versus a traditional single-game cartridge.
- The PowerPak does not accurately simulate power-on state. Because power-on always boots the PowerPak menu, RAM and various registers will be initialized to a consistent state before any NES ROM is chosen to run. (Reset state, however, is not affected by this problem.)
- Open bus behaviormay be different in several memory regions that are used by the PowerPak, but would not be connected on a regular cartridge. ( forum post)

## Utilities
- make_sram: a program written in Python to create PowerPak save files for all NES ROMs in a folder or on a CF card

## PowerPak development resources
- PowerPak Menu- information about the organization of the PowerPak's operating system.
- Collection of information and photos, source code for menu and loader: http://nespowerpak.com/
- Source code for CNROM example (Xilinx ISE Webpack 9.1): powerpakdev1.zip
- Source code for some of Loopy's mappers (Verilog): powerpak_loopy_src.zip/ powerpak_loopy.zip
- Source code for NSF player: powerpak_nsf_src.zip
- Source code for Mapper 190 (Magic Kid GooGoo): forum thread
- Source code for Mapper 111 (GTROM): forum thread

# Power Pad

Source: https://www.nesdev.org/wiki/Power_Pad

The Power Pad ( Family Fun Fitness in Europe) exercise mat for the Nintendo Entertainment System has twelve sensors arranged in a 3x4 grid, which the player steps on to control the action on the screen. It can be used in either controller port, though most games will only allow you to use it in controller port #2, leaving port #1 for a standard controller used for navigating through options.

The Family Trainer Mat is the equivalent exercise mat for the Family Computer, with the exception of its input protocol.

The Tap-tap Mat used for the game Super Mogura Tataki!! - Pokkun Moguraa uses the same protocol as the Family Trainer Mat.

## Pad Layouts

The sensors on the Power Pad are spaced at 252 mm across by 285 mm front and back. Most games used side B, with the numbers on top. A few games turned the pad over to side A, whose markings lack numerals and lack markings for spaces 1, 4, 9, and 12 entirely (but they still send a signal).

```text
          |                        |
,---------+---------.    ,---------+---------.
| POWER PAD  side B |    | POWER PAD  side A |
|  (1) (2) (3) (4)  |    |      (O) (O)      |
|                   |    |                   |
|  (5) (6) (7) (8)  |    |  (O) (X) (X) (O)  |
|                   |    |                   |
|  (9) (10)(11)(12) |    |      (O) (O)      |
|                   |    |                   |
`-------------------'    `-------------------'

```

The Tap-tap Mat is smaller but uses a layout equivalent to side A of the Power Pad:

```text
 _________.-------------._________
|         |// Tap-tap   |  igs    |
|         |/    Mat     |         |
|---------'============='---------|
|  .---.   .---.   .---.   .---.  |   <--- Tap-tap numbering is identical
| (dragn) (BANG!) (croco) (BANG!) |        to SIDE A of the Power Pad, i.e.
|  '---'   '---'   '---'   '---'  |                 4  3  2  1
|  .---.   .---.   .---.   .---.  |                 8  7  6  5
| (BANG!) (monky) (BANG!) (chick) |                12 11 10  9
|  '---'   '---'   '---'   '---'  |
|  .---.   .---.   .---.   .---.  |
| (frank) (BANG!) (shark) (BANG!) |
|  '---'   '---'   '---'   '---'  |
|_________________________________|

```

There is a third possible configuration, which no official game used, but which may be useful for homebrew dance simulation games in the style of Dance Dance Revolution : side B rotated 90 degrees anticlockwise, placing sensors 4, 8, and 12 toward the display.

```text
| ,---------------.           | ,---------------.
| |  SIDE B       |           | |  SIDE DDR     |
| |  (4) (8) (12) |           | | (Sel)    (St) |
| |               |           | |               |
| |  (3) (7) (11) |    ____   | |  (X) (U) (O)  |
`-+               |    ____   `-+               |
  |  (2) (6) (10) |             |  (L)     (R)  |
  |               |             |               |
  |  (1) (5) (9)  |             |      (D)      |
  |               |             |               |
  `---------------'             `---------------'

```

## Pinout

The Power Pad uses pins D3 and D4.

```text
        .-
 GND -- |O\
 CLK <- |OO\ -- +5V
 OUT <- |OO| <- D3
  D0 xx |OO| <- D4
        '--'

     NES port

 * Directions are relative to the jack on the from of console

```

Standard wire colors:

| Signal | Power Pad |
| +5V | White |
| OUT | Orange |
| D3 | Blue |
| D4 | Yellow |
| GND | Brown |
| CLK | Red |

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

Writing 1 to this bit will record the state of each button. Writing 0 afterwards will allow the buttons to be read back, two at a time.

### Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxH Lxxx
   | |
   | +---- Serial data from buttons 2, 1, 5, 9, 6, 10, 11, 7
   +------ Serial data from buttons 4, 3, 12, 8 (following 4 bits read as H=1)

```

The first 8 reads will indicate which buttons are pressed (1 if pressed, 0 if not pressed); all subsequent reads will return H=1 and L=1.

Remember to save both bits that you get from each read. If you're playing samples, beware of bit deletions.

## Family Trainer Mat

The Family Trainer Mat looks similar to the Power Pad, but has an entirely different protocol that took advantage of the greater number of digital outputs on the Famicom expansion port. The Tap-tap Mat uses the same interface as the Family Trainer Mat.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xABC
      |||
      ||+-- 1: Ignore bottom row, 0: include bottom row (buttons 9-12)
      |+--- 1: Ignore middle row, 0: include middle row (buttons 5-8)
      +---- 1: Ignore top row, 0: include top row (buttons 1-4)

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxD EFGx
   | |||
   | ||+-- right-most column (buttons 4,8,12)
   | |+--- right-center column (buttons 3,7,11)
   | +---- left-center column (buttons 2,6,10)
   +------ left-most column (buttons 1,5,9)

```

If a button is pressed in the currently selected rows, then the output returns 0. If no button is pressed, the output for that column is 1.

The matrix must be manually scanned in software; additionally it seems that there are quite large parasitic capacitances on the Family Trainer Mat which may require waiting a whole millisecond before going on to the next row.

The Family Trainer Mat does have the needed diodes for n-key-rollover. [1]

## Programs
- Controller testby Damian Yerrick (Supports NES version)
- powerpadgestureby Damian Yerrick
- powerpd.zipby Tennessee Carmel-Veilleux, 1999

## References
- powerpad.txt- documentation by Tennessee Carmel-Veilleux, 2000
- https://problemkaputt.de/everynes.htm#controllersmats- documentation by nocash

# Program compatibility

Source: https://www.nesdev.org/wiki/Program_Compatibility

This page describes defects in homebrew games. For defects in games prior to 1996, see Game bugs.

Homebrew development is as subject to bugs as old software was, but many suffer from additional compatibility problemswith the NES hardware due to being tested on emulators exclusively. It is often the case that early homebrew ROMs will not run correctly on hardware. Since the release of the PowerPakin 2008, and general improvement in emulators over time, these problems have become less frequent.

For a partial list of homebrew projects, see: Projects

## Common compatibility problems

This is a list of issues that commonly appear due to lack of popular support in emulators, or sometimes even hardware limitations of flash-carts like the PowerPak. Many emulators are merely trying to be compatible with existing games, rather than accurately reflecting the hardware, making them inadequate for verifying the correctness of new software.
- Use of DPCM samples causes a conflictwith controller and PPU reads during sample playback.
- Writes to PPU registersoutside of VBlankwith rendering enabled conflicts with internal use of the PPU address, causing graphical corruption.
- Failure to initialize registers not guaranteed by the CPU power up stateor the PPU power up state.
- Failure to initialize RAM, nametables, or mapperregisters. (Few mappers have guaranteed power up states.)
- Failure to delay use of the PPU after power/reset to avoid conflicts with its warm up state.

## References

# Program compatibility

Source: https://www.nesdev.org/wiki/Program_compatibility

This page describes defects in homebrew games. For defects in games prior to 1996, see Game bugs.

Homebrew development is as subject to bugs as old software was, but many suffer from additional compatibility problemswith the NES hardware due to being tested on emulators exclusively. It is often the case that early homebrew ROMs will not run correctly on hardware. Since the release of the PowerPakin 2008, and general improvement in emulators over time, these problems have become less frequent.

For a partial list of homebrew projects, see: Projects

## Common compatibility problems

This is a list of issues that commonly appear due to lack of popular support in emulators, or sometimes even hardware limitations of flash-carts like the PowerPak. Many emulators are merely trying to be compatible with existing games, rather than accurately reflecting the hardware, making them inadequate for verifying the correctness of new software.
- Use of DPCM samples causes a conflictwith controller and PPU reads during sample playback.
- Writes to PPU registersoutside of VBlankwith rendering enabled conflicts with internal use of the PPU address, causing graphical corruption.
- Failure to initialize registers not guaranteed by the CPU power up stateor the PPU power up state.
- Failure to initialize RAM, nametables, or mapperregisters. (Few mappers have guaranteed power up states.)
- Failure to delay use of the PPU after power/reset to avoid conflicts with its warm up state.

## References

# Programming Basics

Source: https://www.nesdev.org/wiki/Programming_Basics

NES runs on the 6502microprocessor, an 8-bit microprocessor with a 16-bit address bus. The 6502 has powered systems like Commodore 64, Apple II, Atari 2600 and Nintendo Entertainment System. The 6502 has different mnemonics than what some assembly programmers might be used to and some useful instructions like `mul `(used for multiplication) are not available in the 6502 and hence present the need to program them on our own.

## Stack
Main article: Stack

Stack is a data structure used to store data which is very simple and much faster than a heap-based memory structure. It runs by the principle of last-in-first-out , where any new data that is to be entered, is put at the top of the stack (pushing data to the stack) and when removing data from the stack (popping data from the stack), the data that was entered last (the data that is at the top) will be removed first.

## Instructions and Opcodes

### Instructions

Instructions are actions that the processor performs. The 6502 has 56 of such instruction including instructions for operations such as addition, subtraction, AND, OR, ROR, etc. All the instructions are denoted by a 3-letter mnemonic and are then followed by their operands.

There are some instructions which perform operation on a specific register or need a specific register for its operation, such instructions contain the register mnemonic of the specific register in their instruction mnemonic only. For Example - `LDA `loads a byte of memory into the accumulator register denoted by `A `.

### Opcodes

Opcodes (abbreviated from operation codes) are the part of instruction in machine language which specifies the operation to be performed by the processor. Operands are the data on which the operation is performed. The 6502 processor has a total of 256 possible opcodes, but only 151 were used originally, arranged into 56 instructions which the NES used.

## Registers

The 6502 processor has six 8-bit registers, with the exception of the Program Counter, which is 16-bit. The registers are as follows:
- Accumulator(A) - The accumulator can read and write to memory. It is used to store arithmetic and logic results such as addition and subtraction.
- X Index(X) - The x index is can read and write to memory. It is used primarily as a counter in loops, or for addressing memory, but can also temporarily store data like the accumulator.
- Y Index(Y) - Much like the x index, however they are not completely interchangeable. Some operations are only available for each register.
- Flag(P) - The register holds value of 7 different flags which can only have a value of 0 or 1 and hence can be represented in a single register. The bits represent the status of the processor.
- Stack Pointer(SP) - The stack pointer hold the address to the current location on the Stack. The stack is a way to store data by pushing or popping data to and from a section of memory.
- Program Counter(PC) - This is a 16-bit register unlike other registers which are only 8-bit in length, it indicates where the processor is in the program sequence.

## Math Operations

The 6502 processor only has instruction for addition and subtraction, it unfortunately doesn't have an instruction for multiplication or division and hence puts the need to implement them on our own.

### Simple operations
- Addition: The 6502 processor has the instruction `ADC `for addition. It adds the value of an 8-bit number to the accumulator along with the carry bit.
- Subtraction: The `SBC `instruction is used to subtract a value to the accumulator together with the `NOT `of the carry bit.

### Complex operations

#### Multiplication

As multiplication is repeated addition, one can implement a simple loop to add the value of multiplicand (the quantity to be multiplied) to itself times the value of multiplier (the value multiplicand is to be multiplied with). This is a valid approach but a more efficient solution would be to use left shifts and additions which can significantly reduce the number of operations.

The following routine multiplies two unsigned 16-bit numbers, and returns an unsigned 32-bit value.

```text
mulplr	= $c0		; ZP location = $c0
partial	= mulplr+2	; ZP location = $c2
mulcnd	= partial+2	; ZP location = $c4

_usmul:
  pha
  tya
  pha

_usmul_1:
  ldy #$10	; Setup for 16-bit multiply
_usmul_2:
  lda mulplr	; Is low order bit set?
  lsr a
  bcc _usmul_4

  clc		; Low order bit set -- add mulcnd to partial product
  lda partial
  adc mulcnd
  sta partial
  lda partial+1
  adc mulcnd+1
  sta partial+1
;
; Shift result into mulplr and get the next bit of the multiplier into the low order bit of mulplr.
;
_usmul_4:
  ror partial+1
  ror partial
  ror mulplr+1
  ror mulplr
  dey
  bne _usmul_2
  pla
  tay
  pla
  rts

```

Here's an example of the above _usmul routine in action, which multiplies 340*268:

```text
  lda #<340	; Low byte of 16-bit decimal value 340  (value: $54)
  sta mulplr
  lda #>340	; High byte of 16-bit decimal value 340 (value: $01) (makes $0154)
  sta mulplr+1
  lda #<268	; Low byte of 16-bit decimal value 268  (value: $0C)
  sta mulcnd
  lda #>268	; High byte of 16-bit decimal value 268 (value: $01) (makes $010C)
  sta mulcnd+1
  lda #0		; Must be set to zero (0)!
  sta partial
  sta partial+1
  jsr _usmul	; Perform multiplication
;
; RESULTS
;    mulplr    = Low byte of lower word  (bits 0 through 7)
;    mulplr+1  = High byte of lower word (bits 8 through 15)
;    partial   = Low byte of upper word  (bits 16 through 23)
;    partial+1 = High byte of upper word (bits 24 through 31)
;

```

# Programming NROM

Source: https://www.nesdev.org/wiki/Programming_NROM

NROMand the other boards that make up mapper 0 are the simplest of all NES cartridge boards. All address decoding and chip enable handling are handled by the NES hardware; the only integrated circuits on the board are the PRG-ROM, CHR-ROM, and (in 72-pin carts) the CIC. This simplicity lends itself well to small-scale, beginner-level tutorials and projects.

## Configuration

NROM has two major board configurations:
- NROM-256 with 32KiB PRG-ROM and 8KiB CHR-ROM
- NROM-128 with 16KiB PRG-ROM and 8KiB CHR-ROM

Your program is mapped into $8000-$FFFF (NROM-256) or both$8000-$BFFF and $C000-$FFFF (NROM-128). Most NROM-128 games actually run in $C000-$FFFF rather than $8000-$BFFF because it makes the program easier to assemble and link. Some kinds of data used by the NES CPU, such as the interrupt vectors and DPCM samples, have to be in $C000-$FFFF, and it simplifies the linker script if everything is in the same memory region. There are probably a few games that rely on the mirroring, but experiments with a multicart engineshow that most can run with garbage in $8000-$BFFF.

## NES 2.0 header

Below is an example NES 2.0header for NROM boards. It should be backward-compatible with emulators supporting only the older iNESheader format, but they may emulate extra RAM at $6000-$7FFF, whereas official boards (except for Family BASIC ) have open businstead.

```text
.segment "HEADER"
  .byte "NES", $1A
  .byte 2         ; PRG-ROM size: 1 or 2 x 16KiB for NROM-128 or NROM-256 respectively
  .byte 1         ; CHR-ROM size: 1 x 8KiB
  .byte $00       ; Mapper 0; No battery; Vertical arrangement ("Horizontal mirroring")
  .byte $08       ; Mapper 0; NES 2.0 identifier
  .byte $00       ; No submapper
  .byte $00       ; PRG-ROM not 4 MiB or larger
  .byte $00       ; No PRG-RAM
  .byte $00       ; No CHR-RAM
  .byte $00       ; CPU/PPU timing: NTSC
  .byte $00       ; Not a Vs. System or extended console type
  .byte $00       ; No misc. ROMs
  .byte $00       ; Default expansion device: Unspecified

```

To use horizontal arrangement ("vertical mirroring") instead of vertical arrangement ("horizontal mirroring"), change the first `.byte $00 `after the CHR-ROM size field to `.byte $01 `.

## Common problems

Here are some common problems encountered in NROM (or similar discrete logic mapper) projects and their associated workarounds:
- No on-board IRQsource for scroll splits or other raster effects - Use Sprite-0 hit. DMC IRQ, Sprite overflow, and/or cycle-timed codecan also work but are trickier to get right.
- No CHR-ROM banking for tile animations - Use PPUCTRLbits 4-3 as a "poor man's CNROM" by swapping the pattern table access between PPU $0000 and $1000.
- No game save capabilities (outside of Family BASIC ) - Use a password system.

More advanced requirements, such as fine-grained PRG/CHR bankswitching, nametable arrangement switching at runtime, or IRQ generation, will necessitate a mapper change (sometimes to an ASIC mapper). The project scope and budget should be evaluated beforehand if this is the case, especially if publishers and boardmakersare involved.

## Example programs

CA65:
- https://github.com/pinobatch/nrom-template- Contains linker configurations for both NROM-128 and NROM-256.

# Programming with unofficial opcodes

Source: https://www.nesdev.org/wiki/Programming_with_unofficial_opcodes

The NES CPU has unofficial opcodesthat were officially discouraged, but nevertheless had specific function that can be made useful. This article covers practical ways to make use of them.
- See: CPU unofficial opcodes

## Disadvantages

Code written with unofficial opcodes is not portable to other variations of the CPU such as the 65C02, HuC6280, 65C816, SPC700, and the like. If sharing code between an NES program and version for another platform with a 6502 family CPU, such as Commodore 64, Atari computers, TurboGrafx-16, or Super NES, consider using unofficial opcodes only in platform-specific code, not shared code.

Because of their rarity of use, some emulators fail to implement unofficial instructions properly and will fail on games that require them.

There are no official mnemonics for unofficial instructions, so the names of various opcodes will vary between documents and implementations. Hex values are used in this document to disambiguate.

Assemblers may have poor support for unofficial mnemonics. ca65 has a 6502X modethat enables some of them.

Some unofficial opcodes have unpredictable behaviour, such as opcode $8B (XAA)which depends on analog effects.

## Combined operations

Because of how the 6502's microcode is compressed, some opcodes that share bits with two other opcodes will end up performing operations from both opcodes. A lot of these involve a bitwise AND operation, which is a side effect of the open-drainbehavior of NMOS logic. When two instructions put a value into a temporary register inside the 6502 core called "special bus", this creates a bus conflict, and the lower voltage wins because transistors can pull down stronger than resistors can pull up. ALR #i ($4B ii; 2 cycles) Equivalent to AND #i then LSR A. Some sources call this "ASR"; we do not follow this out of confusion with the mnemonic for a pseudoinstructionthat combines CMP #$80 (or ANC #$FF) then ROR. Note that ALR #$FE acts like LSR followed by CLC. Unfortunately, this instruction doesn't work reliably on at least the UM6561AF-2 famiclone chip, and possibly others. ANC #i ($0B ii, $2B ii; 2 cycles) Does AND #i, setting N and Z flags based on the result. Then it copies N (bit 7) to C. ANC #$FF could be useful for sign-extending, much like CMP #$80. ANC #$00 acts like LDA #$00 followed by CLC. ARR #i ($6B ii; 2 cycles) Similar to AND #i then ROR A, except sets the flags differently. N and Z are normal, but C is bit 6 and V is bit 6 xor bit 5. A fast way to perform signed division by 4 is: CMP #$80; ARR #$FF; ROR. This can be extended to larger powers of two. AXS #i ($CB ii, 2 cycles) Sets X to {(A AND X) - #value without borrow}, and updates NZC. One might use TXA AXS #-element_size to iterate through an array of structures or other elements larger than a byte, where the 6502 architecture usually prefers a structure of arrays. For example, TXA AXS #$FC could step to the next OAMentry or to the next APUchannel, saving one byte and four cycles over four INXs. Also called SBX . LAX (d,X) ($A3 dd; 6 cycles) LAX d ($A7 dd; 3 cycles) LAX a ($AF aa aa; 4 cycles) LAX (d),Y ($B3 dd; 5 or 6 cycles) LAX d,Y ($B7 dd; 4 cycles) LAX a,Y ($BF aa aa; 4 or 5 cycles) Shortcut for LDA value then TAX. Saves a byte and two cycles and allows use of the X register with the (d),Y addressing mode. Notice that the immediate is missing; the opcode that would have been LAX is affected by line noise on the data bus. MOS 6502: even the bugs have bugs. SAX (d,X) ($83 dd; 6 cycles) SAX d ($87 dd; 3 cycles) SAX a ($8F aa aa; 4 cycles) SAX d,Y ($97 dd; 4 cycles) Stores the bitwise AND of A and X. As with STA and STX, no flags are affected.

## RMW instructions

The read-modify-write instructions (INC, DEC, ASL, LSR, ROL, ROR) have few valid addressing modes. These instructions have three more: (d,X), (d),Y, and a,Y. Like store instructions, RMW instructions with a,X, a,Y, and (d),Y addressing modes always have a page crossing penalty even if not crossing a page. And like other RMW instructions, they take two cycles longer than a non-RMW write instruction with the same addressing modes. In some cases, it could be worth it to use these and ignore the side effect on the accumulator. DCP (d,X) ($C3 dd; 8 cycles) DCP d ($C7 dd; 5 cycles) DCP a ($CF aa aa; 6 cycles) DCP (d),Y ($D3 dd; 8 cycles) DCP d,X ($D7 dd; 6 cycles) DCP a,Y ($DB aa aa; 7 cycles) DCP a,X ($DF aa aa; 7 cycles) Equivalent to DEC value then CMP value, except supporting more addressing modes. LDA #$FF followed by DCP can be used to check if the decrement underflows, which is useful for multi-byte decrements. ISC (d,X) ($E3 dd; 8 cycles) ISC d ($E7 dd; 5 cycles) ISC a ($EF aa aa; 6 cycles) ISC (d),Y ($F3 dd; 8 cycles) ISC d,X ($F7 dd; 6 cycles) ISC a,Y ($FB aa aa; 7 cycles) ISC a,X ($FF aa aa; 7 cycles) Equivalent to INC value then SBC value, except supporting more addressing modes. RLA (d,X) ($23 dd; 8 cycles) RLA d ($27 dd; 5 cycles) RLA a ($2F aa aa; 6 cycles) RLA (d),Y ($33 dd; 8 cycles) RLA d,X ($37 dd; 6 cycles) RLA a,Y ($3B aa aa; 7 cycles) RLA a,X ($3F aa aa; 7 cycles) Equivalent to ROL value then AND value, except supporting more addressing modes. LDA #$FF followed by RLA is an efficient way to rotate a variable while also loading it in A. RRA (d,X) ($63 dd; 8 cycles) RRA d ($67 dd; 5 cycles) RRA a ($6F aa aa; 6 cycles) RRA (d),Y ($73 dd; 8 cycles) RRA d,X ($77 dd; 6 cycles) RRA a,Y ($7B aa aa; 7 cycles) RRA a,X ($7F aa aa; 7 cycles) Equivalent to ROR value then ADC value, except supporting more addressing modes. Essentially this computes A + value / 2, where value is 9-bit and the division is rounded up. SLO (d,X) ($03 dd; 8 cycles) SLO d ($07 dd; 5 cycles) SLO a ($0F aa aa; 6 cycles) SLO (d),Y ($13 dd; 8 cycles) SLO d,X ($17 dd; 6 cycles) SLO a,Y ($1B aa aa; 7 cycles) SLO a,X ($1F aa aa; 7 cycles) Equivalent to ASL value then ORA value, except supporting more addressing modes. LDA #0 followed by SLO is an efficient way to shift a variable while also loading it in A. SRE (d,X) ($43 dd; 8 cycles) SRE d ($47 dd; 5 cycles) SRE a ($4F aa aa; 6 cycles) SRE (d),Y ($53 dd; 8 cycles) SRE d,X ($57 dd; 6 cycles) SRE a,Y ($5B aa aa; 7 cycles) SRE a,X ($5F aa aa; 7 cycles) Equivalent to LSR value then EOR value, except supporting more addressing modes. LDA #0 followed by SRE is an efficient way to shift a variable while also loading it in A.

## Duplicated instructions

Some instructions are equivalent to others. One possible use of these is for watermarkingyour binary if you want to make leaked executables traceable, such as copies of the ROM sent to testers or even individual cartridges sent to end users. ADC #i ($69 ii, $E9 ii^$FF, $EB ii^$FF; 2 cycles) SBC #i ($69 ii^$FF, $E9 ii, $EB ii; 2 cycles) $69 and $E9 are official; $EB is not. These three opcodes are nearly equivalent, except that $E9 and $EB add 255-i instead of i.

## Unimplemented addressing modes
SHX a, Y ($9E aa aa; 5 cycles) An incorrectly-implemented version of STX a,Y. Unless interrupted by DMC DMA on the 4th clock (i.e. RDY goes low between fetching the high byte of the address and the dummy read), data written is ANDed with (high byte of literal address +1). In case there's a page crossing, the high byte of the computed address is ANDed with X regardless of what RDY does. SHY a, X ($9C aa aa; 5 cycles) An incorrectly-implemented version of STY a,X. Exact same as SHX a, Y but swap X and Y.

## NOPs

No-operation instructions do nothing at all. These can be useful for wasting a small number of cycles, or for skipping past bytes to change the program's control flow, or for adding an in-ROM breakpoint that a specially configured debugging emulator recognizes. They can also be useful for padding or watermarking. NOP ($1A, $3A, $5A, $7A, $DA, $EA, $FA; 2 cycles) The official NOP ($EA) and six unofficial NOPs do nothing. SKB #i ($80 ii, $82 ii, $89 ii, $C2 ii, $E2 ii; 2 cycles) These unofficial opcodes just read an immediate byte and skip it, like a different address mode of NOP. One of these even works almost the same way on 65C02, HuC6280, and 65C816: BIT #i ($89 ii), whose only difference from the 6502 is that it affects the NVZ flags like the other BIT instructions. Use this SKB if you want your code to be portable to Lynx, TG16, or Super NES. Puzznic uses $89, and Beauty and the Beast uses $80. Also called DOP , NOP (distinguished from the 1-byte encoding by the addressing mode). IGN a ($0C aa aa; 4 cycles) IGN a,X ($1C aa aa, $3C aa aa, $5C aa aa, $7C aa aa, $DC aa aa, $FC aa aa; 4 or 5 cycles) IGN d ($04 dd, $44 dd, $64 dd; 3 cycles) IGN d,X ($14 dd, $34 dd, $54 dd, $74 dd, $D4 dd, $F4 dd; 4 cycles) Reads from memory at the specified address and ignores the value. Affects no register nor flags. The absolute version can be used to increment PPUADDR or reset the PPUSTATUS latch as an alternative to BIT. The zero page version has no side effects. IGN d,X reads from both d and (d+X)&255 . IGN a,X has the same penalty behavior as other a,X reads, reading from a+X-256 it crosses a page boundary (i.e. if ((a & 255) + X) > 255 ) Sometimes called TOP (triple-byte no-op), SKW (skip word), DOP (double-byte no-op), or SKB (skip byte). CLD ($D8; 2 cycles) CLV ($B8; 2 cycles) SED ($F8; 2 cycles) These are official. CLD and SED control decimal mode, but on second-source 6502 CPUs without decimal mode such as the 2A03, they do almost nothing; their effect is visible only after a PHP or BRK. You can use them like NOP. And the V flag that CLV clears is rarely used; only ADC, BIT, SBC, the stack ops PLP and RTI, and the unofficial instructions ARR, ISC, and RRA affect it; the BVC and BVS instructions will check it.

The clockslide(technique for delaying a variable number of cycles) can make use of some of these alternate NOP instructions to perform the slide without affecting the status flags.

## External links
- 65xx Processor Data

# RAM cartridge

Source: https://www.nesdev.org/wiki/RAM_cartridge

Although the NES/Famicom was originally designed to only accept cartridges containing game code and data in read-only memory chips ( ROM), both Nintendo and unlicensed third parties released cartridges that allowed games to be played from RAM chips, with data loaded from floppy disks or solid-state flash cards controlled by a small ROM-based BIOS. Licensed RAM cartridges

The Famicom Disk System's RAM Adapter provides 32 KiB of PRG-RAM and 8 KiB of CHR-RAM. Data is loaded from Mitsumi QuickDisk-format 2.8 inch floppy disks. Games have to be specifically written for the FDS RAM Adapter's memory map, for saving game progress to floppy disk, and if more than 32 KiB of PRG or 8 KiB of CHR data are to be used, for loading additional data from disk. Unlicensed RAM cartridges

All unlicensed RAM cartridges are primarily designed to run games that originally were released on ROM cartridges. As a consequence, they closely mimic the memory map of ROM cartridges, load the entire game code and data at boot and do not load any data afterwards.

## First generation

Early unlicensed RAM cartridges had 128 or 256 KiB of PRG-RAM and 32 KiB of CHR-RAM. They could directly mimic discrete mappers such as UNROM, CNROMand GNROM. Games that originally ran on ASIC mappers such as the Nintendo MMC1or MMC3had to be modified to run on these RAM cartridges. If the games used more than 32 KiB of CHR-ROM, or banked it in amounts smaller than 8 KiB, then further modification was necessary, using a technique of caching the most recently-used 32 KiB of CHR-ROM.

These devices have been called "copiers" in the early NES emulation scene, even though none of them actually have the capability to copy a ROM cartridge game to floppy disk. [1]. Instead, users had to purchase (or copy) suitable disks from the manufacturer of the RAM cartridge or some other company close to it. Disks were usually specific to a particular RAM cartridge manufacturer and model, with later devices being backwards-compatible only to models by the same manufacturer and the original Bung Game Doctor , often containing detection code to specifically lock-out competing RAM cartridges.

All of these devices are connected between the Famicom main unit and the FDS RAM adapter. The loading process is based on the process of loading a normal FDS game: the original FDS BIOS starts loading a game once a disk has been inserted. Disks targeting these deviceswill contain a file that is loaded by the FDS BIOS to a CPU address unused by the FDS RAM adapter, but that when written to switches in the RAM cartridges's own BIOS and memory map.
- Bung Game Doctor (in 128 KiB and 256 KiB PRG-RAM versions)
- Venus Game Converter
- Front Fareast Magicard (adds 8 KiB PRG-"ROM" banking mode)
- Bung Super Game Doctor (in 256 KiB and 512 KiB versions; adds 8 KiB PRG-"ROM" banking mode and cycle-based IRQ counter)
- Venus Turbo Game Doctor 4M (512 KiB PRG-RAM, adds 8 KiB PRG-ROM banking mode, cycle-based IRQ counter, and real-time saving capability)

## Second generation

Later unlicensed RAM cartridges increase the PRG-RAM size to 512 KiB, and the CHR-RAM size to 256 KiB bankable in amounts smaller than 8 KiB. Games still had to be modified to run on these devices.
- Venus Turbo Game Doctor 6M/6+
- Front Fareast Super Magic Card. Adds PA12-based IRQ counter. Can also load games from a 3.5 inch MS-DOS-format floppy disk drive (720 KiB or 1.44 MiB), or from a parallel interface connected to a PC with CD-ROM drive.

## Third generation

The Bung Game Master has a Xilinx XC3042 FPGA to mimic most ASIC-based mappers, no longer requiring modifications to the games themselves. The mapper-specific fusemap is loaded from floppy disk (called "preboot disk"), just like the games themselves. It can load games from 2.8 inch QuickDisks like earlier models, or from a 3.5 inch MS-DOS-format floppy disk drive.

## Fourth generation

Modern RAM cartridges such as the PowerPakor Everdrive N8are similar to the Bung Game Master in using an FPGA to mimic almost any mapper hardware, but load games and fusemaps from solid state flash cards exclusively. For this reason, they are called "flashcarts". See also
- Venus Mini Doctor- a simple plug-through cartridge for loading NROM/CNROM games.
- I2 Souseiki Fammy- capable of dumping NROM cartridges to a disk format playable on the device.
- Info on various Famicom "copiers"
- ↑The contemporary term in their East Asian target markets was "RAM disk", while actual copiers were called "wild card".

# ROM

Source: https://www.nesdev.org/wiki/ROM

Read-only memory is any of several types of computer memory designed to hold constant data and cannot be modified during the ordinary course of operation.

## Solid state ROM

These forms of ROM are integrated circuits with no moving parts: Mask ROMProgram is encoded on the "mask", or the shape of the integrated circuit, when the chip is fabricated. During the NES's commercial era, retail NES games were mass-produced as mask ROM because they were very cheap in volume. Programmable read-only memory(PROM), One-time programmable (OTP) Early PROMs were an array of fuses that could be changed from 1 to 0. Later PROMs were UVEPROMs without a window. Ultraviolet erasable programmable read-only memory(UVEPROM) Variant of PROM using field-effect transistors that turn back to 1 upon exposure to strong ultraviolet light through a window over the chip. In general, one would erase one of them by putting it in a box that shines UV on them for about 20 minutes. Developer carts during the NES's commercial era used this sort of EPROM. Electrically erasable programmable read-only memory(EEPROM) Variant of PROM using floating-gate transistors that can be set to 0 using electricity or set to 1 using more electricity. Early solid-state disk devices were EEPROM based. Flash memoryEEPROM that can be erased a page at a time, where a page can be several thousand bytes or more. Modern developer and retail carts use flash memory.

An NES Game Pak has a PRG ROM connected to the CPUand either a second CHR ROM or a CHR RAM (or, rarely, both) connected to the PPU.

Solid-state ROMs are measured by the number of words times the length of each word. On the NES and Super NES, each word is 8 bits; on the Sega Genesis it is 16 bits. The size in words of the vast majority of ROMs is a power of 2: 16384, 32768, etc. Some Super NES carts support multiple PRG ROM chipsallowing a non-power-of-two as a sum of different ROM sizes, but on the NES, no Nintendo board supports more than one PRG ROM or more than one CHR ROM, except for some very early mapper 0 boards ( RTROM and STROM) that took two 8 KiB PRG ROMs and one 8 KiB CHR ROM.

## Optical disc
CD-ROMAn optical disc that holds data to be copied into a RAM and used there. There are three kinds of CD: CD-ROM acts like Mask ROM, CD-R acts like PROM, and CD-RW with packet writingacts like flash memory. Access to CD is much slower than access to solid-state ROM.

## ROM images

The term ROM can also refer to a ROM image , a computer file that represents the entire contents of a ROM or a set of ROMs. The majority of NES ROM images are distributed in the iNESor NES 2.0format.

# RP2A03 Programmable Interval Timer

Source: https://www.nesdev.org/wiki/RP2A03_Programmable_Interval_Timer

The original RP2A03 contains an unfinished and inaccessible 24-bit programmable interval timer , capable of generating an IRQ. Most of the traces connecting it to the rest of the chip have been cut, physically disconnecting it and preventing its use. This timer was discovered through visual inspection of the RP2A03 die and its behavior was reverse engineered visually and through simulation. It was removed in subsequent revisions of the CPU (RP2A03E and onward).

## Inferred operation

The timer uses a 24-bit counter and counts up or down by one each clock, setting a timer flag approximately when the counter reaches 0. If the timer flag is set and the timer IRQ is enabled, the CPU's /IRQ input is asserted until the timer flag is read, clearing the flag. The counter can be configured to reload automatically upon expiration and can also be reloaded manually.

The input clock is selectable between two prescaled M2 clocks and one of either edge of joypad 2 /OE. The M2 prescaler is reset when the counter is manually reloaded. Joypad 1 /OE toggles when the timer expires.

## Inferred register interface

Because the timer is unfinished, there appear to be numerous bugs in its register interface. The register definitions below include corrections for these, representing how it is believed the registers were intended to function. The bugs are discussed in the Erratasection.

### Counter reload value ($401C, $401D, $401E write)

```text
  $401E       $401D       $401C
7  bit  0   7  bit  0   7  bit  0
---- ----   ---- ----   ---- ----
HHHH HHHH   MMMM MMMM   LLLL LLLL
|||| ||||   |||| ||||   |||| ||||
++++-++++---++++-++++---++++-++++- 24-bit counter reload value

```

### Current counter value ($401C, $401D, $401E read)

```text
  $401E       $401D       $401C
7  bit  0   7  bit  0   7  bit  0
---- ----   ---- ----   ---- ----
HHHH HHHH   MMMM MMMM   LLLL LLLL
|||| ||||   |||| ||||   |||| ||||
++++-++++---++++-++++---++++-++++- Current 24-bit counter value

```

### Timer settings ($401F write)

```text
  $401F
7  bit  0
---- ----
ELAC DTZC
|||| ||||
|||+----+- Clock source:
|||  |||    00: M2÷16
|||  |||    01: M2÷256
|||  |||    10: Rising edges of joypad 2 /OE
|||  |||    11: Falling edges of joypad 2 /OE
|||  ||+-- Unused. Latched value toggles on timer expiration.
|||  |+--- Value to output on joypad 1 /OE. Toggles on timer expiration. (0 = low, 1 = high)
|||  +---- Counter direction (0 = down, 1 = up)
||+------- Enable automatic reload on expiration (1 = enable)
|+-------- Trigger immediate counter reload and M2 prescaler reset (1 = trigger)
+--------- Enable timer IRQ (1 = enable)

```

### Timer status ($401F read)

```text
  $401F
7  bit  0
---- ----
Ixxx xxxT
|||| ||||
|||| |||+- Timer flag (1 = timer expired)
|+++-+++-- (Open bus)
+--------- Timer IRQ enabled (1 = enabled)

On read: T = 0

```

The timer expired flag becomes set when the timer expires (reaches 0). The timer asserts an IRQ while that flag and the timer IRQ enable are both 1. Reading this register clears the flag, acknowledging the interrupt.

## Observations

It's not clear what the intended purpose of this timer was.
- A 24-bit counter with the maximum M2 prescaler can support times as long as 40 minutes, which is exceptionally long in terms of gameplay.
- Joypad 2 /OE can be used as a clock source and has a history of being used for watchdogs (such as on the Vs. Systemand FamicomBox), but as a watchdog, it would need to be used as a counter reset, not a clock source. It's also not clear why the clock can be selected between rising or falling edges on joypad 2 /OE, as both edges occur in close proximity and should be roughly equivalent.
- Joypad 1 /OE acts as a timer-controlled clock, but it's not clear why you would want this outputted to a joypad, and you can't use the timer without causing at least one toggle on this output. Perhaps the joypad 1 /OE pin would no longer go to the joypad and would serve some other purpose.

## Errata
- The counter reload bit is stored as dynamic memory and will decay. The approximate time until decay and direction of decay aren't known.
- The condition for whether the counter should count is backward, causing the counter to count when it is 0 rather than non-zero.
- It looks intended that the timer would expire a clock after becoming 0, but a missing via complicates this behavior, likely making it expire when becoming 0 (and possibly at other times, too).
- The M2 prescalers appear to only divide by 8 and 128; in simulation, the first stage is nonfunctional.
- All 4 readable registers are activated by writes instead of reads. The IRQ acknowledge on $401F works on reads as it should, though.
- Joypad 1 /OE as a timer expiration output is not compatible with the use of a standard controller.

## References
- Forum: Memory map and 2A03 register map / 2A03 cutting-room floormetal
- See: CPU pin out and signal description

# SxROM

Source: https://www.nesdev.org/wiki/SBROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SEROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SGROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SHROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SJROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SKROM

Redirect to:
- MMC1#SxROM board types

# SNES controller

Source: https://www.nesdev.org/wiki/SNES_controller

The Super NES Controller (SHVC-005, SNS-005, SNS-102) is very similar to the NES's standard controller, with a collection of digital inputs that are latched and read in series. With a suitable adapter, reading the SNES controller is like reading an NES controller with 4 extra buttons.

The 16 bit report will read, in order:

```text
 0 - B
 1 - Y
 2 - Select
 3 - Start
 4 - Up
 5 - Down
 6 - Left
 7 - Right

```

```text
 8 - A
 9 - X
10 - L
11 - R
12 - 0
13 - 0
14 - 0
15 - 0

```

Note that the first 8 values map directly to the original NES controller's 8 inputs (SNES B = NES A , and SNES Y = NES B ). The Virtual Boy controllerlikewise returns button states in nearly the same order, with the right Control Pad corresponding to ABXY on the Super NES.

The last 4 bits will always read 0 from a standard SNES controller. Other values here may indicate other devices, [1]such as a mouseor a Virtual Boy controller.

After the 16 bit report, subsequent bits will read as 1.

## Games

An incomplete list of NES games with special support for SNES controllers:
- Spook-O-Tron
- Nova the Squirrel [2]
- Full Quiet [3]

## See also
- Controller port pinout
- Controller reading

## References
- Standard controllerat SNESdev Wiki
- ↑FullSNES:SNES Controller Hardware ID Codes
- ↑Nova the Squirrel (WIP)- forum post discussing SNES controller support.
- ↑Tweet by E.C. Myers

# SxROM

Source: https://www.nesdev.org/wiki/SNROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SOROM

Redirect to:
- MMC1#SxROM board types

# SxROM

Source: https://www.nesdev.org/wiki/SUROM

Redirect to:
- MMC1#SxROM board types

# Sample RAM map

Source: https://www.nesdev.org/wiki/Sample_RAM_map

Documents about programming for systems using the 6502 CPU often refer to RAM in 256-byte "pages". As described in CPU memory map, the NES has a 2048 byte RAM connected to the CPU, which provides eight such pages at $0000-$07FF. The optional PRG RAM chip on some cartridge boards is an 8192 byte SRAM that provides 32 pages at $6000-$7FFF.

It's up to you to find uses for this memory, within certain restrictions imposed by the NES's architecture. Indirect addressing modes on 6502 rely on the "zero page" (or "direct page"), which lies at $0000-$00FF. Some other addressing modes can read or write the zero page slightly faster. The stack instructions (PHA, PLA, PHP, PLP, JSR, RTS, BRK, RTI) always access the "stack page", which lies at $0100-$01FF. But you can use the parts of the stack page that those instructions aren't using.

Here's a sketch of a memory map that may work for your programs. Feel free to adapt it to fit your needs.

| Addresses | Size | What can go there |
| $0000-$000F | 16 bytes | Local variables and function arguments |
| $0010-$00FF | 240 bytes | Global variables accessed most often, including certain pointer tables |
| $0100-$019F | 160 bytes | Data to be copied to nametable during next vertical blank (see The frame and NMIs) |
| $01A0-$01FF | 96 bytes | Stack |
| $0200-$02FF | 256 bytes | Data to be copied to OAM during next vertical blank |
| $0300-$03FF | 256 bytes | Variables used by sound player, and possibly other variables |
| $0400-$07FF | 1024 bytes | Arrays and less-often-accessed global variables |

# Standard controller

Source: https://www.nesdev.org/wiki/Standard_controller

All NES units come with at least one standard controller - without it, you wouldn't be able to play any games!

Standard controllers can be used in both controller ports, or in a Four scoreaccessory. For code examples, see: Controller reading code

## Report

The standard NES controller will report 8 bits on its data line:

```text
0 - A
1 - B
2 - Select
3 - Start
4 - Up
5 - Down
6 - Left
7 - Right

```

After 8 bits are read, all subsequent bits will report 1 on a standard NES controller, but third party and other controllers may report other values here.

If using DPCM audio samples, read conflicts must be corrected with a software technique. The most common symptom of this is spurious Right presses as the DPCM conflict deletes one bit of the report, and an extra 1 bit appears in the Right press position. See: Controller reading: DPCM conflict.

## Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

While S ( strobe) is high, the shift registers in the controllers are continuously reloaded from the button states, and reading $4016/$4017 will keep returning the current state of the first button (A). Once S goes low, this reloading will stop. Hence a 1/0 write sequence is required to get the button states, after which the buttons can be read back one at a time.

(Note that bits 2-0 of $4016/write are stored in internal latches in the 2A03/07.)

## Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxx xMES
      |||
      ||+- Primary controller status bit
      |+-- Expansion controller status bit (Famicom)
      +--- Microphone status bit (Famicom, $4016 only)

```

Though both are polled from a write to $4016, controller 1 is read through $4016, and controller 2 is separately read through $4017.

Each read reports one bit at a time through D0. The first 8 reads will indicate which buttons or directions are pressed (1 if pressed, 0 if not pressed). All subsequent reads will return 1 on official Nintendo brand controllers but may return 0 on third party controllers such as the U-Force.

Status for each controller is returned as an 8-bit report in the following order: A, B, Select, Start, Up, Down, Left, Right.

In the NES and Famicom, the top three (or five) bits are not driven, and so retain the bits of the previous byte on the bus. Usually this is the most significant byte of the address of the controller port—0x40. Certain games (such as Paperboy) rely on this behavior and require that reads from the controller ports return exactly $40 or $41 as appropriate. See: Controller reading: unconnected data lines.

When no controller is connected, the corresponding status bit will report 0. This is due to the presence of internal pull-up resistors, and the internal inverter. (See: Controller reading)

### Famicom

The original Famicom's hard-wired second controller (II) is missing the Select and Start buttons. Its corresponding bits will read as 0, so Famicom games must not rely on the second player being able to push Start or Select.

This hard-wired second controller also contains a microphone, which gives an immediate 1-bit report at $4016 D2 whenever it is read. It was common for Famicom games to track when the report changes its state (0 to 1 and vice versa), rather than relying on a specific state representing microphone activity. (TODO: There appears to have been cases where the report was inverted on some units, possibly due to the microphone being installed backwards?) As a result, the microphone report is most useful for detecting noisy audio sources such as a player blowing into the microphone. The microphone audio itself is mixed with the APUoutput before being sent to the cartridge edge. (i.e. before expansion audiois mixed in by the cartridge)

The later AV Famicom used detachable controllers, with connectors identical to the NES. Its second controller was the same as the first, with Select and Start present, and no microphone.

The expansion port of the Famicom could be used to connect external controllers. These gave the same standard 8-bit report, but through D1 instead of D0. It was common for Famicom games to combine D1 and D0 (logical OR) when reading to permit players to use expansion controllers instead, though several games do not support this [1]. Alternatively, these could be used as extra controllers for 4-playergames.

## Hardware

The 4021 ICis an 8-bit parallel-to-serial shift register. This allows the 8 button states to be latched into the register simultaneously (parallel), then read out one bit at a time (serial).

From the controller port pinouts:
- OUT ( $4016:0 ) controls the 4021's Parallel/Serial Control . When this goes high, the current state of the 8 buttons are read into the 4021's 8-bit register.
- CLK controls the 4021's Clock input. On a low-to-high transition this will shift each bit of the register to the next higher bit. This is normally held high, and becomes low during a read of $4016 or $4017 . When the read is finished, it returns high, triggering the shift to prepare for the next bit to be read.
- D0 reads the 4021's Q8 output. This is the current state of the last bit in the register. Note that the NES will invert this signal, so for the 4021 unpressed buttons are stored as 1, but will read to the NES CPU as 0.
- +5V powers the 4021 through its Vcc pin.
- GND provides ground to the 4021 through Vss but is also connected to its Serial In input, which will shift a 0 into each empty bit as the 4021 is clocked. This is why (after inversion) the standard controller will read back all 1s once the 8 buttons have been read.

Each of the 8 PI parallel input pins is connected to +5V through its own pull-up resistor (~10k), keeping it high normally. When a button is pressed, it connects the input to ground, bypassing the pull-up, creating a low signal when latched. PI-8 corresponds to the first button read: the A button.

If using DPCM audio samples, read conflicts may occur requiring a software technique to correct for them. See: Controller reading: DPCM conflict.

### PAL

Some PAL region consoles (for example FRA, HOL, NOE) have internal diodes on their controller port. (See: Controller port pinout: Protection Diodes)

These diodes prevent the Clock and Latch signals from functioning unless they are pulled high. PAL controllers for these regions (model NES-004E) each contain a 3.6KΩ resistor between these two inputs and 5V. [2]

On these systems, only PAL controllers with the pull-ups can be read. NTSC systems, along with early PAL market systems (at least SCN) can read controllers of either type. Modifying the internal controller port to bypass these diodes will make the PAL system compatible with both. Conversely, modifying a controller to add the pull-up resistors makes it compatible with both types of systems.

This also extends to the 4-score peripheral: Model NESE-034 ver1.1 is also diode protected and will require pull-up-equipped controllers.

### Schematic

```text
                     .-----\/-----.
*--------- A Button -|PI-8     Vcc|- 5V
                  x -|Q6      PI-7|- B Button -------*
   +------------ D0 -|Q8      PI-6|- Select Button --*
*--|----- Up Button -|PI-4    PI-5|- Start Button ---*
*--|--- Down Button -|PI-3      Q7|- x                    |\
*--|--- Left Button -|PI-2   SerIn|- GND             GND -|o\
*--|-- Right Button -|PI-1   Clock|---+------------- CLK -|oo|- 5V
   |            GND -|Vss    Latch|---|--+---------- OUT -|oo|- D3 --x
   |                 .____4021____.   |  |  +-------- D0 -|oo|- D4 --x
   |                                  |  |  |             .__.
   +----------------------------------|--|--+            (Port)
                                      |  |
8 x *--+--[ 10k ]-- 5V                |  | (PAL pullups)
       |                              +--|--[ 3.6k ]--+-- 5V
       |   __+__ (Button)                |            |
       +---o   o--- GND                  +--[ 3.6k ]--+

```

## Turbo

A turbo controller such as the NES Max or NES Advantage is read just like a standard controller, but the user can switch some of its buttons to be toggled by an oscillator. Such an oscillator turns the button on and off at 15 to 30 Hz, producing rapid fire in games.

A controller should not toggle the button states on each strobe pulse. Doing so will cause problems for games that poll the controller in a loop until they get two identical consecutive reads (see DMC conflict above). The game may halt while the turbo button is held, or crash, or cause other unknown behaviour.

## See also
- Controller reading
- Controller detection
- Controller port pinout
- Four Score4-player adapter
- SNES controllerhas backward compatible protocol with the NES

## References
- ↑Famicom World forum post: Famicom games that do not work with pads connected through the expansion port.
- ↑Forum post: explaining PAL controller diodes and their function.
- Forum post:Famicom controller PCB and exterior photographs
- Hori controller schematic- Third party controller similar to the NES or Famicom controller, and contains the Clock/Latch pull-ups needed for PAL compatibility.

# Super Famicom NTT Data Keypad

Source: https://www.nesdev.org/wiki/Super_Famicom_NTT_Data_Keypad

The Super Famicom NTT Data Keypad(NDK10) is intended to be used in conjunction with the Super Famicom NTT Data Communication Modem. It adds 15 buttons to an otherwise-normal SNES controller.

## Protocol

This controller extends the SNES controllerprotocol to 32 bits to support the additional buttons. Bits 0-15 match the SNES controllerexcept with a different signature, while bits 16-31 match the last 16 bits of a Famicom Network Controller.

```text
 0 - B
 1 - Y
 2 - ᐊ / 前ページ (Previous page)
 3 - ᐅ / 次ページ (Next page)
 4 - Up
 5 - Down
 6 - Left
 7 - Right
 8 - A
 9 - X
10 - L
11 - R
12 - (Always 0)
13 - (Always 1)
14 - (Always 0)
15 - (Always 0)
16 - 0
17 - 1
18 - 2
19 - 3
20 - 4
21 - 5
22 - 6
23 - 7
24 - 8
25 - 9
26 - *
27 - #
28 - .
29 - C
30 - (Always 0)
31 - 通信終了 (End communication)

32+ - (Always 1)

```

## Links

NTT Data Keypadat SNESdev Wiki

# TxROM

Source: https://www.nesdev.org/wiki/TEROM

NESCartDB

| TxROM |
| TBROM |
| TEROM |
| TFROM |
| TGROM |
| TKROM |
| TK1ROM |
| TKSROM |
| TLROM |
| TL1ROM |
| TL2ROM |
| TLSROM |
| TNROM |
| TQROM |
| TR1ROM |
| TSROM |
| TVROM |

The generic designation TxROM refers to cartridge boards made by Nintendo that use the Nintendo MMC3mapper.

## Board Types

The following TxROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR | Comments |
| TBROM | 64 KB |  | 16 / 32 / 64 KB ROM |  |
| TEROM | 32 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TFROM | 128 / 256 / 512 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TGROM | 128 / 256 / 512 KB |  | 8 KB RAM/ROM |  |
| TKROM | 128 / 256 / 512 KB | 8 KB | 128 / 256 KB ROM |  |
| TK1ROM | 128 KB | 8KB | 128KB ROM | Uses 7432 for 28-pin CHR ROM |
| TKSROM | 128 / 256 / 512 KB | 8 KB | 128 KB ROM | Alternate mirroring control, Famicom only |
| TKEPROM | four 128KB ROMs | 8 KB | two 128KB ROMs | Prototyping board |
| TLROM | 128 / 256 / 512 KB |  | 128 / 256 KB ROM |  |
| TL1ROM | 128 KB |  | 128 KB | Uses 7432 for 28-pin CHR ROM |
| TL2ROM |  |  |  | Nonstandard pinout |
| TLBROM | 128 KB |  | 128 KB ROM | Uses 74541 to compensate for too-slow CHR ROM |
| TLSROM | 128 / 256 / 512 KB |  | 128 KB ROM | Alternate mirroring control |
| TNROM | 128 / 256, 512 KB | 8 KB | 8 KB RAM/ROM | Famicom only |
| TQROM | 128 KB |  | 16 / 32 / 64 KB ROM + 8 KB RAM |  |
| TR1ROM | 128 / 256 / 512 KB |  | 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |
| TSROM | 128 / 256 / 512 KB | 8 KB (no battery) | 128 / 256 KB ROM |  |
| TVROM | 64 KB |  | 16 / 32 / 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |

## Solder pad config

### Namco 108 backwards compatibility (TEROM and TFROM)
- Normal mode: 'CL1' connected, 'CL2' connected, 'H' disconnected, 'V' disconnected.
- Backwards compatible with horizontal mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' disconnected, 'V' connected
- Backwards compatible with vertical mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' connected, 'V' disconnected

Connecting 'CL1' enables MMC3-controlled mirroring, while connecting 'CL2' enables IRQs. However, the additional bankswitching modes available by the MMC3 that weren't available with the Namco chip used on DEROM boards are still present and activated by bits 7-6 of port $8000.

### Battery retention (TNROM, TKROM and TKSROM)
- PRG RAM retaining data: 'SL' disconnected, Battery, D1, D2, R1 R2 and R3 present.
- PRG RAM not retaining data: 'SL' connected, leave slots for Battery, D1, D2, R1, R2 and R3 free.

## Various notes

Boards with 4-screen mirroring uses a 8 KB SRAM chip, but only 4 KB is actually used. The 2 KB VRAM inside of the console is always disabled, and the CIRAM A10 pin of the MMC3 doesn't go to anything.

TLSROM and TKSROM boards have different mirroring control than other MMC3 boards. The mirroring is controlled directly by MMC3's CHR A17 line, and MMC3's CIRAM A10 pin doesn't go to anything. Due to their incompatibility with other MMC3 boards on a software viewpoint, they are assigned to INES Mapper 118instead of mapper 4.

TQROM board has both CHR ROM and RAM. Bit 6 of the bank number, which appears on MMC3's CHR A16 line, controls whenever CHR RAM or CHR-ROM is enabled. A 74HC32chip is used to combine this with other chip enable signals for the CHR-ROM and the CHR-RAM chips. Due to this incompatibility with the other MMC3 boards on a software viewpoint, this board is assigned to INES Mapper 119instead of mapper 4.

# TxROM

Source: https://www.nesdev.org/wiki/TKROM

NESCartDB

| TxROM |
| TBROM |
| TEROM |
| TFROM |
| TGROM |
| TKROM |
| TK1ROM |
| TKSROM |
| TLROM |
| TL1ROM |
| TL2ROM |
| TLSROM |
| TNROM |
| TQROM |
| TR1ROM |
| TSROM |
| TVROM |

The generic designation TxROM refers to cartridge boards made by Nintendo that use the Nintendo MMC3mapper.

## Board Types

The following TxROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR | Comments |
| TBROM | 64 KB |  | 16 / 32 / 64 KB ROM |  |
| TEROM | 32 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TFROM | 128 / 256 / 512 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TGROM | 128 / 256 / 512 KB |  | 8 KB RAM/ROM |  |
| TKROM | 128 / 256 / 512 KB | 8 KB | 128 / 256 KB ROM |  |
| TK1ROM | 128 KB | 8KB | 128KB ROM | Uses 7432 for 28-pin CHR ROM |
| TKSROM | 128 / 256 / 512 KB | 8 KB | 128 KB ROM | Alternate mirroring control, Famicom only |
| TKEPROM | four 128KB ROMs | 8 KB | two 128KB ROMs | Prototyping board |
| TLROM | 128 / 256 / 512 KB |  | 128 / 256 KB ROM |  |
| TL1ROM | 128 KB |  | 128 KB | Uses 7432 for 28-pin CHR ROM |
| TL2ROM |  |  |  | Nonstandard pinout |
| TLBROM | 128 KB |  | 128 KB ROM | Uses 74541 to compensate for too-slow CHR ROM |
| TLSROM | 128 / 256 / 512 KB |  | 128 KB ROM | Alternate mirroring control |
| TNROM | 128 / 256, 512 KB | 8 KB | 8 KB RAM/ROM | Famicom only |
| TQROM | 128 KB |  | 16 / 32 / 64 KB ROM + 8 KB RAM |  |
| TR1ROM | 128 / 256 / 512 KB |  | 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |
| TSROM | 128 / 256 / 512 KB | 8 KB (no battery) | 128 / 256 KB ROM |  |
| TVROM | 64 KB |  | 16 / 32 / 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |

## Solder pad config

### Namco 108 backwards compatibility (TEROM and TFROM)
- Normal mode: 'CL1' connected, 'CL2' connected, 'H' disconnected, 'V' disconnected.
- Backwards compatible with horizontal mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' disconnected, 'V' connected
- Backwards compatible with vertical mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' connected, 'V' disconnected

Connecting 'CL1' enables MMC3-controlled mirroring, while connecting 'CL2' enables IRQs. However, the additional bankswitching modes available by the MMC3 that weren't available with the Namco chip used on DEROM boards are still present and activated by bits 7-6 of port $8000.

### Battery retention (TNROM, TKROM and TKSROM)
- PRG RAM retaining data: 'SL' disconnected, Battery, D1, D2, R1 R2 and R3 present.
- PRG RAM not retaining data: 'SL' connected, leave slots for Battery, D1, D2, R1, R2 and R3 free.

## Various notes

Boards with 4-screen mirroring uses a 8 KB SRAM chip, but only 4 KB is actually used. The 2 KB VRAM inside of the console is always disabled, and the CIRAM A10 pin of the MMC3 doesn't go to anything.

TLSROM and TKSROM boards have different mirroring control than other MMC3 boards. The mirroring is controlled directly by MMC3's CHR A17 line, and MMC3's CIRAM A10 pin doesn't go to anything. Due to their incompatibility with other MMC3 boards on a software viewpoint, they are assigned to INES Mapper 118instead of mapper 4.

TQROM board has both CHR ROM and RAM. Bit 6 of the bank number, which appears on MMC3's CHR A16 line, controls whenever CHR RAM or CHR-ROM is enabled. A 74HC32chip is used to combine this with other chip enable signals for the CHR-ROM and the CHR-RAM chips. Due to this incompatibility with the other MMC3 boards on a software viewpoint, this board is assigned to INES Mapper 119instead of mapper 4.

# TxROM

Source: https://www.nesdev.org/wiki/TLROM

NESCartDB

| TxROM |
| TBROM |
| TEROM |
| TFROM |
| TGROM |
| TKROM |
| TK1ROM |
| TKSROM |
| TLROM |
| TL1ROM |
| TL2ROM |
| TLSROM |
| TNROM |
| TQROM |
| TR1ROM |
| TSROM |
| TVROM |

The generic designation TxROM refers to cartridge boards made by Nintendo that use the Nintendo MMC3mapper.

## Board Types

The following TxROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR | Comments |
| TBROM | 64 KB |  | 16 / 32 / 64 KB ROM |  |
| TEROM | 32 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TFROM | 128 / 256 / 512 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TGROM | 128 / 256 / 512 KB |  | 8 KB RAM/ROM |  |
| TKROM | 128 / 256 / 512 KB | 8 KB | 128 / 256 KB ROM |  |
| TK1ROM | 128 KB | 8KB | 128KB ROM | Uses 7432 for 28-pin CHR ROM |
| TKSROM | 128 / 256 / 512 KB | 8 KB | 128 KB ROM | Alternate mirroring control, Famicom only |
| TKEPROM | four 128KB ROMs | 8 KB | two 128KB ROMs | Prototyping board |
| TLROM | 128 / 256 / 512 KB |  | 128 / 256 KB ROM |  |
| TL1ROM | 128 KB |  | 128 KB | Uses 7432 for 28-pin CHR ROM |
| TL2ROM |  |  |  | Nonstandard pinout |
| TLBROM | 128 KB |  | 128 KB ROM | Uses 74541 to compensate for too-slow CHR ROM |
| TLSROM | 128 / 256 / 512 KB |  | 128 KB ROM | Alternate mirroring control |
| TNROM | 128 / 256, 512 KB | 8 KB | 8 KB RAM/ROM | Famicom only |
| TQROM | 128 KB |  | 16 / 32 / 64 KB ROM + 8 KB RAM |  |
| TR1ROM | 128 / 256 / 512 KB |  | 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |
| TSROM | 128 / 256 / 512 KB | 8 KB (no battery) | 128 / 256 KB ROM |  |
| TVROM | 64 KB |  | 16 / 32 / 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |

## Solder pad config

### Namco 108 backwards compatibility (TEROM and TFROM)
- Normal mode: 'CL1' connected, 'CL2' connected, 'H' disconnected, 'V' disconnected.
- Backwards compatible with horizontal mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' disconnected, 'V' connected
- Backwards compatible with vertical mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' connected, 'V' disconnected

Connecting 'CL1' enables MMC3-controlled mirroring, while connecting 'CL2' enables IRQs. However, the additional bankswitching modes available by the MMC3 that weren't available with the Namco chip used on DEROM boards are still present and activated by bits 7-6 of port $8000.

### Battery retention (TNROM, TKROM and TKSROM)
- PRG RAM retaining data: 'SL' disconnected, Battery, D1, D2, R1 R2 and R3 present.
- PRG RAM not retaining data: 'SL' connected, leave slots for Battery, D1, D2, R1, R2 and R3 free.

## Various notes

Boards with 4-screen mirroring uses a 8 KB SRAM chip, but only 4 KB is actually used. The 2 KB VRAM inside of the console is always disabled, and the CIRAM A10 pin of the MMC3 doesn't go to anything.

TLSROM and TKSROM boards have different mirroring control than other MMC3 boards. The mirroring is controlled directly by MMC3's CHR A17 line, and MMC3's CIRAM A10 pin doesn't go to anything. Due to their incompatibility with other MMC3 boards on a software viewpoint, they are assigned to INES Mapper 118instead of mapper 4.

TQROM board has both CHR ROM and RAM. Bit 6 of the bank number, which appears on MMC3's CHR A16 line, controls whenever CHR RAM or CHR-ROM is enabled. A 74HC32chip is used to combine this with other chip enable signals for the CHR-ROM and the CHR-RAM chips. Due to this incompatibility with the other MMC3 boards on a software viewpoint, this board is assigned to INES Mapper 119instead of mapper 4.

# TxROM

Source: https://www.nesdev.org/wiki/TNROM

NESCartDB

| TxROM |
| TBROM |
| TEROM |
| TFROM |
| TGROM |
| TKROM |
| TK1ROM |
| TKSROM |
| TLROM |
| TL1ROM |
| TL2ROM |
| TLSROM |
| TNROM |
| TQROM |
| TR1ROM |
| TSROM |
| TVROM |

The generic designation TxROM refers to cartridge boards made by Nintendo that use the Nintendo MMC3mapper.

## Board Types

The following TxROM boards are known to exist:

| Board | PRG ROM | PRG RAM | CHR | Comments |
| TBROM | 64 KB |  | 16 / 32 / 64 KB ROM |  |
| TEROM | 32 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TFROM | 128 / 256 / 512 KB |  | 16 / 32 / 64 KB ROM | Supports fixed mirroring |
| TGROM | 128 / 256 / 512 KB |  | 8 KB RAM/ROM |  |
| TKROM | 128 / 256 / 512 KB | 8 KB | 128 / 256 KB ROM |  |
| TK1ROM | 128 KB | 8KB | 128KB ROM | Uses 7432 for 28-pin CHR ROM |
| TKSROM | 128 / 256 / 512 KB | 8 KB | 128 KB ROM | Alternate mirroring control, Famicom only |
| TKEPROM | four 128KB ROMs | 8 KB | two 128KB ROMs | Prototyping board |
| TLROM | 128 / 256 / 512 KB |  | 128 / 256 KB ROM |  |
| TL1ROM | 128 KB |  | 128 KB | Uses 7432 for 28-pin CHR ROM |
| TL2ROM |  |  |  | Nonstandard pinout |
| TLBROM | 128 KB |  | 128 KB ROM | Uses 74541 to compensate for too-slow CHR ROM |
| TLSROM | 128 / 256 / 512 KB |  | 128 KB ROM | Alternate mirroring control |
| TNROM | 128 / 256, 512 KB | 8 KB | 8 KB RAM/ROM | Famicom only |
| TQROM | 128 KB |  | 16 / 32 / 64 KB ROM + 8 KB RAM |  |
| TR1ROM | 128 / 256 / 512 KB |  | 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |
| TSROM | 128 / 256 / 512 KB | 8 KB (no battery) | 128 / 256 KB ROM |  |
| TVROM | 64 KB |  | 16 / 32 / 64 KB ROM + 4 KB VRAM (4-screen Mirroring) | NES only |

## Solder pad config

### Namco 108 backwards compatibility (TEROM and TFROM)
- Normal mode: 'CL1' connected, 'CL2' connected, 'H' disconnected, 'V' disconnected.
- Backwards compatible with horizontal mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' disconnected, 'V' connected
- Backwards compatible with vertical mirroring: 'CL1' disconnected, 'CL2' disconnected, 'H' connected, 'V' disconnected

Connecting 'CL1' enables MMC3-controlled mirroring, while connecting 'CL2' enables IRQs. However, the additional bankswitching modes available by the MMC3 that weren't available with the Namco chip used on DEROM boards are still present and activated by bits 7-6 of port $8000.

### Battery retention (TNROM, TKROM and TKSROM)
- PRG RAM retaining data: 'SL' disconnected, Battery, D1, D2, R1 R2 and R3 present.
- PRG RAM not retaining data: 'SL' connected, leave slots for Battery, D1, D2, R1, R2 and R3 free.

## Various notes

Boards with 4-screen mirroring uses a 8 KB SRAM chip, but only 4 KB is actually used. The 2 KB VRAM inside of the console is always disabled, and the CIRAM A10 pin of the MMC3 doesn't go to anything.

TLSROM and TKSROM boards have different mirroring control than other MMC3 boards. The mirroring is controlled directly by MMC3's CHR A17 line, and MMC3's CIRAM A10 pin doesn't go to anything. Due to their incompatibility with other MMC3 boards on a software viewpoint, they are assigned to INES Mapper 118instead of mapper 4.

TQROM board has both CHR ROM and RAM. Bit 6 of the bank number, which appears on MMC3's CHR A16 line, controls whenever CHR RAM or CHR-ROM is enabled. A 74HC32chip is used to combine this with other chip enable signals for the CHR-ROM and the CHR-RAM chips. Due to this incompatibility with the other MMC3 boards on a software viewpoint, this board is assigned to INES Mapper 119instead of mapper 4.

# TV-NET Rank 2 controller

Source: https://www.nesdev.org/wiki/TV-NET_Rank_2_controller

The TV-NET Rank 2 controlleris an expansion port device intended for use with the TV-NET Rank 2 MC-4800 modem. It is compatible with software expecting the TV-NET controllerand provides 8 additional buttons, though some button labels do not match those of any TV-NET controller variant. It is suspected the extra buttons are used for software built into the modem. The P/T switch on the back signals to software whether to dial using pulse or Touch-Tone. This controller can be used alongside the TV-NET MCP-24 printer, which also connects through the Famicom expansion port, by using a multi-port adapter believed to have been bundled with the printer.

## Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

This matches the normal strobe behavior used by the standard controller.

## Output ($4016 read)

```text
7  bit  0
---- ----
xxxx xxSx
       |
       +- Controller status bit

```

## Protocol

Button state is returned in a 32-bit report across 32 reads. The first 24 bits match those of the TV-NET controller.

```text
 0 - P/T switch (1 if T)
 1 - • / 終了 (End)
 2 - 後退 (Backspace) / F3
 3 - (Always 1)
 4 - F1
 5 - 番組 (Program) / F2
 6 - 印字 (Typing) / F4
 7 - 取消 (Cancel) / F5
 8 - 1
 9 - 4
10 - 7
11 - (Always 1)
12 - 2
13 - 3
14 - 5
15 - 6
16 - *
17 - Left
18 - # / 実行 (Run)
19 - Right
20 - 8
21 - 9
22 - 0
23 - ,
24 - 入力 (Input)
25 - Up
26 - Down
27 - 文字 (Character)
28 - 機能 (Function)
29 - 切替 (Exchange) / F6
30 - 再送 (Resend) / F7
31 - 停再 (Stop again) / F8

32+ - (Always 1)

```

# TV-NET controller

Source: https://www.nesdev.org/wiki/TV-NET_controller

The TV-NET controlleris an expansion port device intended for use with TV-NET MC-1200 modem software. It comes in at least 4 variations that differ only in how the buttons are labeled. It has 21 buttons and 1 switch, all of which function independently. The P/T switch on the back signals to software whether to dial using pulse or Touch-Tone.

## Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

This matches the normal strobe behavior used by the standard controller.

## Output ($4016 read)

```text
7  bit  0
---- ----
xxxx xxEx
       |
       +- Controller status bit

```

## Protocol

Button state is returned in a 24-bit report across 24 reads. The different variations are all functionally identical, but use different naming for several buttons.

### TV-NET

```text
 0 - P/T switch (1 if T)
 1 - 終了 (End)
 2 - F3
 3 - (Always 1)
 4 - F1
 5 - F2
 6 - F4
 7 - F5
 8 - 1
 9 - 4
10 - 7
11 - (Always 1)
12 - 2
13 - 3
14 - 5
15 - 6
16 - *
17 - Left
18 - 実行 (Run)
19 - Right
20 - 8
21 - 9
22 - 0
23 - .

24+ - (Always 1)

```

### Piste

```text
 0 - P/T switch (1 if T)
 1 - 終了 (End)
 2 - Memory
 3 - (Always 1)
 4 - Menu
 5 - 投票 (Vote)
 6 - Submenu
 7 - Clear
 8 - 1
 9 - 4
10 - 7
11 - (Always 1)
12 - 2
13 - 3
14 - 5
15 - 6
16 - Up
17 - Left
18 - 実行 (Run)
19 - Right
20 - 8
21 - 9
22 - 0
23 - Down

24+ - (Always 1)

```

### Nikko no Home Trade One

```text
 0 - P/T switch (1 if T)
 1 - 終了 (End)
 2 - 口座入力 (Account entry)
 3 - (Always 1)
 4 - Menu
 5 - Submenu
 6 - #
 7 - 項目消去 (Item deletion)
 8 - 1
 9 - 4
10 - 7
11 - (Always 1)
12 - 2
13 - 3
14 - 5
15 - 6
16 - *
17 - Left
18 - 実行 (Run)
19 - Right
20 - 8
21 - 9
22 - 0
23 - .

24+ - (Always 1)

```

### Daiwa no My Trade, Universal no My Trade

```text
 0 - P/T switch (1 if T)
 1 - 終了 (End)
 2 - ᐊ / 前ページ (Previous page)
 3 - (Always 1)
 4 - Menu
 5 - Submenu
 6 - ᐅ / 次ページ (Next page)
 7 - C
 8 - 1
 9 - 4
10 - 7
11 - (Always 1)
12 - 2
13 - 3
14 - 5
15 - 6
16 - *
17 - #
18 - ◎ / 実行 (Run)
19 - Right
20 - 8
21 - 9
22 - 0
23 - .

24+ - (Always 1)

```

## Sources
- Re: TV-NET MC-1200

# The frame and NMIs

Source: https://www.nesdev.org/wiki/The_frame_and_NMIs

The PPUgenerates a video signal for one frame of animation, then it rests for a brief period called vertical blanking. The CPU can load graphics data into the PPU only during this rest period. From NMIto the pre-render scanline, the NTSC NES PPU stays off the bus for 20 scanlines or 2273 cycles. Taking into account overhead to get in and out of the NMI handler, you can probably use roughly 2250 cycles. To get the most out of limited vblank time, don't compute your changes in vblank time. Instead, prepare a buffer in main RAM (for example, use unused parts of the stack at $0100-$019F) before vblank, and then copy from that buffer into VRAM during vblank. On NTSC, count on being able to copy 160 bytes to nametables or the palette using a moderately unrolled loop, plus one 256-byte display list to OAM.

Original Source: The frame and NMIsby Disch

## VBlank, Rendering Time, and NMIs

Many tutorials don't stress how important understanding the frame layout is - in fact, most don't even cover it. At best, they'll casually say something like "you can only draw during VBlank", leaving the reader wondering what in the world VBlank is. This lack of understanding is a major cause of bugs for new NESDev'ers.

Contrary to how it may seem when you run these programs, the code is not executed instantaneously. All code takes a little bit of time to run. While the CPU is spending this time reading your program and executing code, the PPU is simultaneously doing its own work, like things related to outputting video to the TV. When your program communicates with the PPU via one of the registers, you will be poking it at different stages in this process. During some stages, the PPU will be too busy to deal with you, and you will screw things up by trying. This is why it's important to know what stage the PPU is in.

The PPU operates on a series of frames . The PPU does all this work to output a frame to the TV, then it repeats the exact same process for the next frame, and the next, and the next. The frame can further be split into two generalized sections: VBlank and Rendering time .

Rendering time makes up the bulk of the frame. This is the time during which the PPU is fetching tiles, evaluating sprites, and outputting pixels to the screen. The PPU is very busy during this time, so busy that if you try to access it with drawing code, you will screw it up and have visible and possibly disastrous glitches in your game. VBlank, on the other hand, is when the PPU is idle. This is when you can do all of your drawing code safely.

A good way to visualize this by thinking of a clock face, and imagining one frame as one hour. VBlank would be a small portion of that hour, say the first 5 minutes (when the minute hand is between 12 and 1). No matter what you do in your program the minute hand is always spinning around the clock, moving in and out of that 5-minute butterzone... and the PPU is always moving in and out of VBlank. In order to update the PPU in your game, you must make sure your drawing code falls within that small period of time. Failure to do this will cause all sorts of display glitches.

To make matters even more complicated, as a programmer you have no way to actually see this clock in your code, so there is no way to tell whether or not the PPU is currently in VBlank, or how close to VBlank it is, or how much VBlank time is left. There is , however, a way your program can be notified when VBlank first starts (as soon as the minute hand hits the 12 on the clock). This notification comes in the form of an NMI, or "non-maskable interrupt".

Every time that clock hand reaches the 12 and the PPU starts VBlank again, the PPU will attempt to notify you that this has happened. It does this by sending an NMI to your program. These NMIs can be disabled so that you don't have to use them all the time (this is controlled via $2000 (PPUCTRL)). However, in a game you must use them because they are the only [reliable] way to catch VBlank (and thus allow for realtime drawing without turning the PPU off). Plus they are the easiest, most natural, and most convenient logic framerate regulator.

Now, the drawing code I'm talking about so far is stuff that is to be drawn while rendering is enabled. In your program, you can disable rendering (aka, "turn off the PPU") via $2001 (PPUMASK). If rendering is disabled, it is perfectly sane to perform drawing code at any time (even during rendering time). This, however, does not stop that clock hand from moving. Even when 'disabled'. The PPU is still moving in and out of VBlank, and NMIs will still be generated (if enabled).

Note, however, the clear difference between NMI and VBlank. NMI is a notification, whereas VBlank is a time period. A lot of newbies wonder why their drawing code is spilling outside of VBlank when they finish it all before their `rti `. They think that because NMI happens at the start of VBlank, then `rti `must be the end of VBlank. This, of course, is totally wrong. As soon as VBlank happens, it's like a race for you to get all of your drawing code done before time is up. Time may run out long before you hit your `rti `.

## Separating Drawing from Logic

The key to ensuring that all of your drawing code happens in VBlank is to separate your drawing code from your logic code. A lot of newbies have a "do it now" mentality when it comes to drawing. Say, for example, they want to draw a text message to the user when the A button is pressed. They might try something like this:

```text
lda a_button
bne draw_message

```

This might seem like a good way to do it, but it is bad, bad, bad . You should almost never write code like this. This is mixing logic code (examining user input and deciding what to do) with drawing code (actually outputting something to the screen).

The reason this is bad is because drawing code requires you be in VBlank. Therefore the above code must be run in VBlank because it draws. However it also does non-drawing stuff (logic), which can be done any time. Putting logic code in VBlank means you're wasting precious VBlank time on code that doesn't need to use it. This means you burn up your VBlank time that much faster, which reduces the amount of drawing you can get done in a frame, and increases the risk of having drawing code spill outside of VBlank.

A solution to this is to flag that the drawing needs to be done, and then actually do it next VBlank. This could be done like so:

```text
  ;; when processing game logic
  lda a_button
  beq :+          ; if a was pressed...
    inc drawflag  ; set the draw flag
:

  ;; --------------------
  ;;  then, next vblank:

  lda drawflag
  beq :+              ; if draw flag is set
    jsr draw_message  ; actually draw the message
:

```

However, this in and of itself isn't much of an improvement. `draw_message `might require some additional logic of its own. And this method isn't very versatile at all. What if there are 10 different ways the screen could update? Do we keep 10 flags and check them all every VBlank? Not very efficient. In practice, you'll want to do something a little more generalized than this, something that will work with virtually everything.

The better solution to this is to buffer your drawing. That is, you copy what you want drawn somewhere to memory, then copy it to the PPU next VBlank. This extra copy might seem wasteful, but in practice it isn't really. It's not as efficient as direct drawing, but the idea is you're sacrificing Rendering time (which you have lots of), to gain more VBlank time (which you have very little of). Doing a little extra work in your logic code to ease up on your drawing code goes a long way.

Buffering is a very common and practical way to accomplish drawing. In fact, you've probably already done it with sprites in your programs. When you update sprite data, you don't write to OAM ($2004)directly (or at least I should hope not), you write to shadow OAM (i.e. a 256-byte region in standard system RAM, most commonly $0200-$02FF) and then later copy that to OAM with Sprite DMA ($4014). That is the same concept that we're doing here. Instead of drawing to the PPU immediately, we're getting it ready to be drawn, and then saying "don't draw it now, draw it next VBlank".

## Buffer Formats

In order to employ this buffering technique, you need to give yourself room for the buffer in RAM. Just like you need to designate a full page of RAM to shadow OAM, you should probably designate a significant portion of RAM to your drawing buffer. It doesn't have to be a full page, but you don't want to run out of space.

You also need to decide on a data format in which to store the information that tells your drawing code what to draw, and how to draw it. The best way to do this is to have the drawing code know as little as possible about the rest of your program. Make this format as generic and flexible as possible. Most techniques use a system where you have a chain of " strings " and each "string" tells the drawing code what to draw, where, and how. This is actually much simpler than it sounds. For example, here's a very simple implementation of such a format, and an example of how it would be used:

```text
  byte    0 = length of data (0 = no more data)
  byte    1 = high byte of target PPU address
  byte    2 = low byte of target PPU address
  bytes 3-X = the data to draw (number of bytes determined by the length)

```

If the drawing buffer contains the following data:

```text
 05 20 16 CA AB 00 EF 05 01 2C 01 00 00
  | \___/ \____________/  | \___/  |  |
  |   |         |         |   |    |  |
  |   |         |         |   |    |  length (0, so no more)
  |   |         |         |   |    byte to copy
  |   |         |         |   PPU Address $2C01
  |   |         |         length=1
  |   |         bytes to copy
  |   PPU Address $2016
  length=5

```

Your drawing code, upon coming across this data, would then do the following:
- Copy 5 bytes ( `CA AB 00 EF 05 `) to PPU address $2016
- Copy 1 byte ( `00 `) to PPU address $2C01
- Come across a length of 0, and thus stop drawing.

To make this work, you fill this buffer during your logic code instead of drawing straight to the PPU. Then in VBlank, you read this buffer and copy the data to the PPU. Because the format lays it out in simple terms, there isn't any heavy calculation that needs to be done to perform this drawing, and thus the drawing can be done very quickly, helping to make sure that it doesn't spill out of VBlank. A format like this is also very flexible. In fact if you make the format flexible enough, you should be able to use it for everything in the game .

The above format, while simple and somewhat flexible, does have one major flaw. That being it doesn't allow you to specify whether or not you want to draw vertical rows of tiles (inc-by-32). To add that functionality, you could tweak the format by adding a flags byte:

```text
  byte    0 = length of data (0 = no more data)
  byte    1 = high byte of target PPU address
  byte    2 = low byte of target PPU address
  byte    3 = drawing flags:
                bit 0 = set if inc-by-32, clear if inc-by-1
  bytes 4-X = the data to draw (number of bytes determined by the length)

```

Same idea, but now we can draw rows or columns of tiles! This makes the format generic enough so that you can use it to do any drawing task.

But wait. We can add even more to this. What if the data we want to draw is already sitting in ROM somewhere? It's a little wasteful to copy it to RAM, then copy it to the PPU when we can just copy it straight from ROM. Maybe you want to tweak the format a bit to allow for that:

```text
  byte    3 = drawing flags:
                bit 0 = set if inc-by-32, clear if inc-by-1
                bit 1 = set if copy-from-ROM, clear if copy-from-RAM

     if copy-from-RAM:
  bytes 4-X = the data to draw (number of bytes determined by the length)

     if copy-from-ROM:
  bytes 4,5 = CPU address from which to read the data

```

But wait , there's more! What if you want to draw a bunch of zeros? Like to clear a row of tiles or something? Why copy a bunch of zeros to RAM when you can put in a basic RLE scheme:

```text
  byte    3 = drawing flags:
                bit 0 = set if inc-by-32, clear if inc-by-1
                bit 1 = set if copy-from-ROM, clear if copy-from-RAM
                bit 2 = set if RLE, clear if not RLE

     if copy-from-RAM, not RLE:
  bytes 4-X = the data to draw (number of bytes determined by the length)

     if copy-from-ROM, not RLE:
  bytes 4,5 = CPU address from which to read the data

     if RLE:
  byte    4 = single byte to repeat 'length' times

```

The possibilities are endless! Beware, however, that the more of these special conditions you add, the bigger and slower your drawing routine gets, which means less stuff can be drawn. It's up to you how far you want to go before drawing the line. Don't get too carried away with super complicated features you don't really need. Remember, the whole point of this is to simplify and quicken the process of drawing, not to make the most feature-rich routine imaginable.

One buffer format appearing in several games is Stripe Image. It supports both the increment and RLE modes but doesn't support copying from ROM. The Popslide librarycan be used to rapidly copy a Stripe Image buffer from a buffer on the stack page to VRAM.

## Buffering Other Things

Drawing code is not the only thing that can be buffered. Changes in PPU state, such as scroll changes, turning the PPU on/off, etc, can (and should) be buffered as well, provided the effect truly isn't desired immediately (timed raster effects, for example, might be desired immediately, but that's a later topic).

The first instinct for the newbie is to turn the PPU on and off directly. They'll finish all the drawing they needed to do to get the first screen to display, and they go to switch the PPU on:

```text
lda #%00011000
sta $2001

```

They then are shocked to see that when they do this, the screen "jumps" because the PPU was in the middle of Rendering time when they turned it on. The solution for this is simple: Buffer the changes to $2000 (PPUCTRL) and $2001 (PPUMASK). I say you should keep variables called `soft2000 `and `soft2001 `(really, call them whatever you like). You should then copy these values to the real $2000/$2001 next VBlank. With this setup, when you want to turn the PPU on, you can do the following:

```text
lda #%00011000
sta soft2001

```

And take comfort knowing that the PPU will be [safely] turned on next VBlank. This works for turning the PPU off as well, or any other state change. If you need the change to happen " now ", like for instance if you want to turn the PPU off so you can draw a full new screen to the nametable you'd need to shut the PPU off before you could do any drawing. You can do the following:

```text
lda #%00011000
sta soft2001
jsr WaitFrame

```

...where `WaitFrame `is a routine which waits for an NMI to occur before returning. This will ensure the state is changed before the logic code proceeds, but also makes sure the change is safe (in VBlank).

## When to Turn Off PPU, NMIs

Drawing can be separated into two general types of drawing. You have bulk drawing which will happen during a major transition in a game, and you'll have updating which will happen constantly as the user is playing the game.

For an example of each of these types, let's say you're making an RPG where the player walks around a scrolling map. When the player takes a step, new tiles will have to be drawn to show the area of the map they're walking towards. This is an example of updating . Now when the player gets in a battle, or enters a town or dungeon, you'll have to draw an entirely different image on the screen. This is an example of bulk drawing .

Updates should be done in the method we've talked about. Buffer them, and make sure they happen in VBlank. The reason we need VBlank is because you can't switch off the PPU in order to do the drawing otherwise the visual display will black out. Could you imagine the screen flashing black every time you took a step?

Conversely, bulk drawing should not be done with the methods described so far. Buffering bulk drawing serves no benefit, since all the drawing couldn't fit in VBlank time anyway. What's more, turning the screen off and having it black for a few frames might even be desirable during such transitions. Therefore, you should [safely] switch the PPU off, then do your bulk drawing. It doesn't even hurt to put the bulk drawing right in with the logic code! Go ahead and mix it right in. The only reason that was a bad idea before is because you want to keep unnecessary logic code out of precious VBlank. But now since the PPU is off and we can draw whatever we want, that's a nonissue.

The one exception to the "everything is safe if PPU is off" rule is palette updates. Palette updates should be in VBlank (buffered), even if the PPU is off. This is due to a particular quirk of the NES PPU where pointing its I/O address at the palette while rendering is disabled will cause it to display that particular color on the screen - it won't kill anything, but you'll have a weird "rainbow stripe" flash across your screen. This isn't terribly relevant if your game is still booting up, though.

Now you might be thinking, "Well if I'm doing a bulk drawing routine, I want to disable NMIs too because I don't want an NMI to interrupt me while I'm drawing." That is a reasonable thought, but ultimately it's a bad way to go. As a general rule of thumb, leave NMIs on all the time . The only time they should be off is during your startup code where you're initializing everything. After that, once you turn them on, leave them on unless you have a very compelling reason to turn them off. There are many reasons for this:
- If you code your NMI handler properly, it will know to do nothing when it has nothing to do. There's no real harm in letting it run even if you don't need it to (other than losing a very small handful of cycles).
- There are things you might want to happen every frame, even during these transitions. For example, you might want the music to keep playing rather than require it pause/stop during the transition. This can be done by updating the music engine in your NMI handler, but is virtually impossible to do if you disable NMIs.
- Once you turn NMIs off, it is very easy to forget to turn them back on. What's worse, if you forget to read $2002 and you turn them on in the middle of VBlank, it will immediately trigger an NMI and cause your handler to run past the end of VBlank, starting all sorts of havoc.

## Take Full Advantage of NMI

Another newbie issue is that they are often unsure how to use NMI. Some of them either have NMI change a single variable and exit immediately ("everything in main"), or they enable NMIs, then run the main code into an infinite loop, and have their whole game run from the NMI handler ("everything in NMI"). Both of these are ill advised for a full, complex game. If you've done things this way, don't feel bad - even some commercial games do it like that. So it's not that those methods don't work, it's just that they're not as advantageous.

What you should realize is that your NMI handler is extremely valuable in that (provided you leave NMIs on) it is the only area of code in your program that is guaranteed to run every single frame. Not only every frame, but every VBlank . Utilizing this gives you a much tighter grip around how you want the game to operate.

The shortcomings of these "everything in XXX" approaches are that they handle game slowdown poorly, and prevent you from doing some basic things that you should be able to do. For example, taking the "everything in NMI" approach causes all sorts of problems:
- You probably have to disable NMIs when one trips, then re-enable them when logic is done. Otherwise an NMI could trip when you're still doing NMI stuff, which could be disastrous.
- You can't keep the music updated during slowdown, or during bulk drawing transitions, because NMIs will be disabled.
- Slowdown will cause you to "miss" frames. If you're doing a screen split or other raster effect, you won't be able to set it up properly, and the status bar or other effect will be visually glitchy in the next frame.

The "everything in main" approach is none better, and it suffers from the same problems, just introduced differently.

So how do you use NMI to take full advantage of it? All you have to do is keep it enabled all the time, and have it do things that you will always want done every frame. You can have a series of flags to make some tasks conditional for some frames (so you don't have to draw anything if there's nothing to draw, etc). Here's an example of what a better NMI handler and some supporting routines might look like:

```text
   ;---------------------------------------

   ;  note I use 'varname = x' for simplicity, but there are many good reasons not
   ; to use this method in a real game.  Assume all these variables have a
   ; unique space in memory

   ; designate a oam and drawing buffer
   oam          = $0200    ; shadow oam
   drawingbuf   = $0300    ; buffer for PPU drawing

   ; other variables
   soft2000     = x    ; buffering $2000 writes
   soft2001     = x    ; buffering $2001 writes

   needdma      = x    ; nonzero if NMI should perform sprite DMA
   needdraw     = x    ; nonzero if NMI needs to do drawing from the buffer
   needppureg   = x    ; nonzero if NMI should update $2000/$2001/$2005
   sleeping     = x    ; nonzero if main thread is waiting for VBlank

   xscroll      = x
   yscroll      = x

   ;--------------------------------------
   ; WaitFrame - waits for VBlank, returns after NMI handler is done

   WaitFrame:
     inc sleeping
     @loop:
       lda sleeping
       bne @loop
     rts

   ;--------------------------------------
   ; DoFrame - same idea as WaitFrame, but also does some other stuff
   ;   that the game logic will want done every frame.  Things that
   ;   shouldn't be put in NMI

   DoFrame:
     lda #1
     sta needdraw
     sta needoam
     sta needppureg
     jsr WaitFrame
     jmp UpdateJoypadData

   ;--------------------------------------
   ; NMI - the NMI handler

   NMI:
     pha         ; back up registers (important)
     txa
     pha
     tya
     pha

     lda needdma
     beq :+
       lda #0      ; do sprite DMA
       sta $2003   ; conditional via the 'needdma' flag
       lda #>oam
       sta $4014

  :  lda needdraw       ; do other PPU drawing (NT/Palette/whathaveyou)
     beq :+             ;  conditional via the 'needdraw' flag
       bit $2002        ; clear VBl flag, reset $2005/$2006 toggle
       jsr DoDrawing    ; draw the stuff from the drawing buffer
       dec needdraw

  :  lda needppureg
     beq :+
       lda soft2001   ; copy buffered $2000/$2001 (conditional via needppureg)
       sta $2001
       lda soft2000
       sta $2000

       bit $2002
       lda xscroll    ; set X/Y scroll (conditional via needppureg)
       sta $2005
       lda yscroll
       sta $2005

  :  jsr MusicEngine

     lda #0         ; clear the sleeping flag so that WaitFrame will exit
     sta sleeping   ;   note that you should not 'dec' here, as sleeping might
                    ;   already be zero (will be the case during slowdown)

     pla            ; restore regs and exit
     tay
     pla
     tax
     pla
     rti

   ;-----------------------------------------

```

With the above code structure, all your program has to do is keep NMI enabled, and all your drawing, scroll setting, and music updating will be done automagically. All you have to do from there is put the stuff you want drawn in your drawing buffer, and `jsr `to 'DoFrame' to keep the game going. It couldn't be easier! This will allow you to keep your logic code easy to follow and straightforward, as well as providing all the other benefits talked about in this doc.

A few things to note about the order and the way in which this example routine does things:
- Timing-critical stuff (drawing code) is done first. Then it moves on to setting the scroll, then to stuff that can be done any time (music updating).
- Nearly everything is conditional (you can make everything conditional if you want). Making the drawing and DMA conditional will prevent the NMI from drawing data that is "not yet finished" (for example, if NMI occurs while you're filling one of the buffers).

## Being Interrupt-Aware

The above mentioned approach might seem bulletproof. NMI just does its own thing, the logic code is freed from timing concerns, and all you have to do to make it work is update a few variables when you want an onscreen change. Really, though, this approach opens itself up to a different set of problems that the "everything in XXX" methods don't normally have to worry about. Because your handler for NMIs (and your handler for IRQs, for that matter) are doing a substantial workload, and because they are left enabled most/all of the time, they can cause conflicts with your main code and can really cause you serious problems if they happen when your logic code isn't expecting them. In order to prevent these conflicts from occurring, your code needs to be interrupt-aware .

Conflicts, in this context, are when the NMI/IRQ changes something (either a variable, reg, or other system state) that the main code is using, resulting in the main code doing something totally unexpected. A very simple way to visualize this is changing a 6502 reg:

```text
;;  if this is your NMI handler
NMI:
  lda #0
  rti

;;  and if you do this somewhere else in your program

RefillPlayerHP:
  lda playermaxhp
  sta playerhp
  rts

```

Do you see the problem? It's subtle, but `RefillPlayerHP `might actually end up killing the player! The reason why is because NMIs can happen any time, and if an NMI happens between your `lda `and `sta `commands, you get totally screwed. Here's a flow of what might happen:

```text
  lda playermaxhp
                   ; -------->NMI------>
                                      lda #0
                                      rti
                   ; <--------RTI<------
  sta playerhp
  rts

```

The problem is much more obvious when you draw it out like this. You can see that if an NMI happens at that point, you'll be setting the player's hp to zero, instead of refilling it.

Believe it or not, this is much more likely to happen than you might think. And if you're using IRQs, it's almost a guarantee that cases like this will come up. What's worse, these problems are very hard to diagnose from the symptoms, because they're not easily reproduced. This is why it's so important for your code to be interrupt-aware from day 1.

An easy and very common solution to this particular problem is to backup and restore the 6502's registers by pushing them to the stack first thing in your NMI and IRQ handlers and then restoring them just before your `rti `. This is why many examples (including my example NMI handler above) start with the `pha txa pha tya pha `business. This ensures that A, X, and Y will be unchanged from their original value when NMI exits.

It's not just cpu registers, though. Variable conflicts can also occur. Say you have a generic `ptr `variable that you use somewhere in your logic code to read map data that you're loading. And say the NMI handler is also using it in its drawing routine. The conflict here happens if an NMI occurs during your map loading routine. NMI will overwrite the pointer with what it needs, and when control returns to the main path, you'll start reading map data from whatever NMI was pointing to, rather than what you really wanted.

The solution here is also very simple and easy. Just do not have NMI or IRQ share variables or RAM space with your main code (or with each other -- remember that while an IRQ during NMI is impossible, an NMI during IRQ is very possible!). Of course, you'll still need some variables that both your interrupts and your main code use in order to communicate between them, such as `needdraw `in the above example.

Beware, however, that these variables need to be quickly accessible. You are most vulnerable to conflicts when something critical takes multiple instructions. For example, looking at the above you might think "He's got 3 'needsomething' flags up there, and they're all separate variables. That's wasteful. I'm going to combine all of those into a single variable where each bit is a flag." Sounds smart, right? Use 1 byte of RAM instead of 3, and all the flags are consolidated into a single variable. The downside to this, however, is it makes you vulnerable to conflicts because changing a flag now requires a series of instructions, rather than a single `sta `command:

```text
  lda needflags     ; grab the need flags
  ora #NEEDFLG_DMA  ; flip on the flag marking sprite DMA
  sta needflags     ; write back

```

The conflict here happens when NMI trips between the `lda `and `sta `commands, and when the NMI routine changes `needflags `. This will happen sometimes. For instance, the previous NMI handler example performs `dec needflags `after it finishes drawing. It's a good thing that it does this, because otherwise it will waste time drawing the same thing over and over every frame.

Another interesting and often overlooked problem is a subtle system state change. Say you're doing a bulk drawing routine and you set the PPU address to $2400:

```text
  lda #>$2400
  sta $2006
  lda #<$2400
  sta $2006

;; elsewhere, in your NMI handler:
NMI:
  pha
  bit $2002    ; clear vblank flag

  lda xscroll  ; set the scroll
  sta $2005
  lda yscroll
  sta $2005

  pla
  rti

```

Harmless, right? But there is a disastrous conflict there. Do you see it? It happens when an NMI occurs between the $2006 writes. It's bad in two ways:
- `bit $2002 `will reset the PPU toggle so that the next write to $2006 is the first write. This means that your main code won't actually be setting the PPU address to $2400, because the second write actually becomes another first write because of the toggle.
- Setting the scroll changes the temp PPU address (aka `loopy_t`). This messes with the address the main code is trying to set with its $2006 writes.

Yet another example of this happening is on mappers which require two or more writes in order to bankswitch. If the NMI or IRQ also needs to bankswitch, you have yourself yet another conflict.

Just remember the key to being interrupt-aware is to spot vulnerabilities. You're most vulnerable when something seemingly basic takes several instructions to do. Just be extra careful when writing code like that in your program, and make state changing code in your NMI/IRQ handlers conditional so that your main code can disable it for sections where it might introduce conflict vulnerabilities.

# INES Mapper 118

Source: https://www.nesdev.org/wiki/TxSROM

TxSROM is used to designate TKSROMand TLSROMboards, both of which use the Nintendo MMC3in a nonstandard way. The only known difference between these boards and TKROMand TLROMis the mirroring configuration. The CHR A17 line connects directly to CIRAM A10 line instead of MMC3's CIRAM A10 output, to compensate for the MMC3's lack of single-screen mirroring. The iNESformat assigns iNES Mapper 118 to these boards.

Example games:
- Armadillo
- Pro Sport Hockey

## Registers

The behavior of these boards differs from that of a typical MMC3 board in the use of the upper CHR address line. This board relies on the fact that the MMC3's CHR bank circuit ignores A13 when calculating CHR A10-A17, responding to nametablefetches from $2000-$2FFF the same way as fetches from the first pattern table at $0000-$0FFF. This means that the 1KB/2KB banking scheme used for CHR bankswitching is active even during nametable fetches while the CHR ROM/RAM is disabled.

However, on these particular boards, the CHR bankswitching directly affects the mirroringmapping the nametable RAM. This allows programs to select which nametable is mapped to each slot, much like CHR banks are mapped to pattern table slots, in either two 2KB banks (allowing only single-screen or horizontal mirroring) or four 1KB banks (allowing all mirroring modes one can think of, because this is equal to the size of a nametable) at the price of mapping the 1KB CHR banks to the first pattern table by setting bit 7 of $8000. If the IRQ counter is being used in a standard way, this involves having sprites bankswitched in 2KB banks and backgrounds in 1KB banks.

### Bank data ($8001-$9FFF, odd)

```text
7  bit  0
---- ----
MDDD DDDD
|||| ||||
|+++-++++- New bank value, based on last value written to Bank select register
|          0: Select 2 KB CHR bank at PPU $0000-$07FF (or $1000-$17FF);
|          1: Select 2 KB CHR bank at PPU $0800-$0FFF (or $1800-$1FFF);
|          2: Select 1 KB CHR bank at PPU $1000-$13FF (or $0000-$03FF);
|          3: Select 1 KB CHR bank at PPU $1400-$17FF (or $0400-$07FF);
|          4: Select 1 KB CHR bank at PPU $1800-$1BFF (or $0800-$0BFF);
|          5: Select 1 KB CHR bank at PPU $1C00-$1FFF (or $0C00-$0FFF);
|          6, 7: as standard MMC3
|
+--------- Mirroring configuration, based on the last value
           written to Bank select register
           0: Select Nametable at PPU $2000-$27FF
           1: Select Nametable at PPU $2800-$2FFF
           Note : Those bits are ignored if corresponding CHR banks
           are mapped at $1000-$1FFF via $8000.

           2 : Select Nametable at PPU $2000-$23FF
           3 : Select Nametable at PPU $2400-$27FF
           4 : Select Nametable at PPU $2800-$2BFF
           5 : Select Nametable at PPU $2C00-$2FFF
           Note : Those bits are ignored if corresponding CHR banks
           are mapped at $1000-$1FFF via $8000.

```

### Mirroring ($A000-$BFFE, even)

```text
7  bit  0
---- ----
xxxx xxxM
        |
        +- Mirroring
           This bit is bypassed by the configuration described above, so writing here has no effect.

```

Note: In theory, the CHR limitation is 256 KB like all MMC3boards. But because CHR A17 has another usage, having a CHR greater than 128 KB would require very careful CHR ROM layout because CHR bankswitching and mirroring will be linked through the same selection bits. Probably for this reason, official Nintendo TLSROM boards doesn't allow for 256 KB CHR-ROMs. However, a mapper 118 game that uses a third party MMC3/board, using 1-screen mirroring could draw the playfield with the lower 128 KB of CHR ROM and the lower nametable, and draw the status bar and menus with the upper 128 KB of CHR ROM and the upper nametable. Sprite tile banks could go in whatever space remains in either or both halves.

## Variants

Mappers 158and 207do the exact same thing but with Tengen's RAMBO-1and Taito's X1-005, respectively. Mapper 95is almost the same thing, but with a reduced MMC3 made by Namcoinstead of a full MMC3 and with the nametable select bit on A15 instead of A17 because the Namco mapper has only six CHR bank bits.

## References
- NES Mapper listby Disch.

# UxROM

Source: https://www.nesdev.org/wiki/UOROM

UxROM

| Company | Nintendo, others |
| Games | 155 in NesCartDB |
| Complexity | Discrete logic |
| Boards | UNROM, UOROM |
| PRG ROM capacity | 256K/4096K |
| PRG ROM window | 16K + 16K fixed |
| PRG RAM capacity | None |
| CHR capacity | 8K |
| CHR window | n/a |
| Nametable arrangement | Fixed H or V, controlled by solder pads |
| Bus conflicts | Yes/No |
| IRQ | No |
| Audio | No |
| iNES mappers | 002, 094, 180 |
NESCartDB

| iNES 002 |
| UxROM |
| UNROM |
| UOROM |

The generic designation UxROM refers to the Nintendo cartridge boards NES-UNROM , NES-UOROM , their HVCcounterparts, HVC-UN1ROM, and clone boards.
- iNESMapper 002 is the implementation of the most common usage of UxROM compatible boards, described in this article.
- iNES Mapper 094describes UN1ROM, used only in Senjou no Ookami .
- iNES Mapper 180describes a reconfiguration of UNROM used only in Crazy Climber .

Example games:
- Mega Man
- Castlevania
- Contra
- Duck Tales
- Metal Gear

## Banks
- CPU $8000-$BFFF: 16 KB switchable PRG ROM bank
- CPU $C000-$FFFF: 16 KB PRG ROM bank, fixed to the last bank

## Solder pad config
- Horizontal mirroring : 'H' disconnected, 'V' connected.
- Vertical mirroring : 'H' connected, 'V' disconnected.

## Registers

### Bank select ($8000-$FFFF)

```text
7  bit  0
---- ----
xxxx pPPP
     ||||
     ++++- Select 16 KB PRG ROM bank for CPU $8000-$BFFF
          (UNROM uses bits 2-0; UOROM uses bits 3-0)

```

Emulator implementations of iNES mapper 2 treat this as a full 8-bit bank select register, without bus conflicts. This allows the mapper to be used for similar boards that are compatible.

To make use of all 8-bits for a 4 MB PRG ROM, an NES 2.0header must be used ( iNEScan only effectively go to 2 MB).

The original UxROM boards used by Nintendo were subject to bus conflicts, and the relevant games all work around this in software. Some emulators (notably FCEUX) will have bus conflicts by default, but others have none. NES 2.0 submapperswere assigned to accurately specify whether the game should be emulated with bus conflicts.

## Hardware

The UNROM, UN1ROM, and UOROM boards contain a 74HC161binary counter used as a quad D latch (4-bit register) and a 74HC32quad 2-input OR gate to make one bank always visible.

The circuit behaves as if it were as follows:

```text
      /PRGSEL               A14  A13-A0
       |                      |      |
       |                      |      |
       | D2-D0-.       ,------'      |
       |       |     . |             |
       | ,-----+--.  |`+.            |
       | |Register+--+0  `.          |
       | `--------'  |    |__.       |
       |       |     |    |  |       |
       | R/W --'   7-+1  ,'  |       |
       |             | ,'    |       |
       |             |'      |       |
       |                     |       |
      ,+---------------------+-------+-----.
      |/CE              A16-A14  A13-A0    |
      |         128K by 8 bit ROM     D7-D0+-- to 2A03 data bus
      |                                    |
      `------------------------------------'

```

(This diagram is for UNROM. UOROM has one more bit in the register, multiplexer output, and address input A17, and the multiplexer's other input is $F. Homebrew boards capable of 512 KiB have one more of each, and the multiplexer's input is $1F.)

The quad OR gate here acts as a multiplexer. A 74HC02quad NOR gate can be used instead if the banks are stored in reverse order in the ROM. If the program is 128 KiB or smaller, the 7402 way leaves one NOR gate free to invert R/W into /OE to avoid bus conflicts. [1]

If an actual multiplexer ( 74HC157quad 2:1) is cheaper than an OR gate, a third-party UxROM-compatible board can use that instead of the 74HC32, as kyuusaku suggested.

## Variants

The mapperused in Codemasters games published by Camerica extends UxROM with CICdefeat circuitry.

Nintendo's HVC-UN1ROMboard moves the bankswitching bits within the byte.

Crazy Climber replaces the 74HC32quad-OR gate by a 74HC08quad-AND gate, so that the first bank is fixed at $8000-$bfff and the switchable bank is present at $c000-$ffff. This configuration is assigned to iNES Mapper 180, which uses the same UNROM PCB.

With an 8-bit latch ( 74HC377or an additional 74HC161) and an additional 74HC32 to control A18-A21, a third-party board implementing this mapper can switch 4 MiB of PRG ROM.

Battle Kid 2: Mountain of Tormentimplements a 512kB UxROM mapper.

UNROM 512implements a superset of 512kB UxROM, with additional CHR-RAM banking and the possibility of flash save.

The homebrew game Alwa's Awakening adds 8 KiB of battery-backed PRG-RAM in the usual $6000-$7FFF address range. A few Subor educational cartridges have non-battery-backed PRG-RAM in the same range as well. Emulators should support this PRG-RAM at least in the presence of a NES 2.0 header that explicitly specifies it.

## See also
- Programming UNROM

## External links
- Comprehensive NES Mapper Documentby \Firebug\, information about mapper's initial state is inaccurate.
- NES mapper list by Disch [2]
- Converting UNROM to UOROM

# VT02+ CHR-ROM Bankswitching

Source: https://www.nesdev.org/wiki/VT02%2B_CHR-ROM_Bankswitching

In OneBus mode, VT02+ consoles combine the Famicom cartridge connector's CPU and PPU address lines into one 32 MiB address space, with separate CPU and PPU bankswitch registers pointing to appropriately-placed code and picture data. The bankswitching scheme is based on, and indeed backwards-compatible to, the Nintendo MMC3's. The PPU address range reserved for CHR pattern data ($0000-$1FFF) is divided into 2x2 KiB and 4x1 KiB banks (2x4 KiB and 4x2 KiB in 4bpp modes), with the bank numbers always specified with 1 KiB granularity (2 KiB granularity in 4bpp modes). The final bank number is made up of five components:
- an Extended Video Address (EVA) if Address Extensionis active,
- an Inner Bank that resembles the MMC3's bank registers,
- a Middle Bank that can replace zero to eight bits of the lower bank number,
- an Intermediate Bank if Address Extension if not active,
- an Outer Bank that extend the address range up to 32 MiB,

## Extended Video Address

If either Background or Sprite Address Extension is active while the respective pattern data are fetched, or either is active while data is read or written via $2007, the Extended Video Address (EVA) provides the lowest three bits of the CHR bank number. Please refer to the VT02+ Video Modesarticle for information on the way that the three bits of the Extended Video Address are derived.

## Inner CHR Bank number

The lower bits bits of the 8 KiB PRG-ROM bank number, constituting the Inner Bank number, are normally the main ones that are manipulated by individual games.

```text
PPU $0000-$03FF: Selected by register $2016 (RV4) AND $FE, akin to MMC3 register 0.
PPU $0400-$07FF: Selected by register $2016 (RV5) OR $01, akin to MMC3 register 0.
PPU $0800-$0BFF: Selected by register $2017 (RV5) AND $FE, akin to MMC3 register 1.
PPU $0C00-$0FFF: Selected by register $2017 (RV5) OR $01, akin to MMC3 register 1
PPU $1000-$13FF: Selected by register $2012 (RV0), akin to MMC3 register 2.
PPU $1400-$17FF: Selected by register $2013 (RV1), akin to MMC3 register 3.
PPU $1800-$1BFF: Selected by register $2014 (RV2), akin to MMC3 register 4.
PPU $1C00-$1FFF: Selected by register $2015 (RV3), akin to MMC3 register 5.

```

If $4105 bit 7 (COMR7) is 1, then the sources of the $0000-$0FFF bank numbers are swapped with the $1000-$1FFF banks', just as on the MMC3, or in other words, PPU A12 is inverted.

## Middle CHR Bank number

The Middle Bank is normally only used on multicarts. It allows masking off and replacing bits of the Inner Bank number, so that several games may be put into one Outer Bank. Bits 0-2 of register $201A (VB0S) select the AND mask that is applied to the Inner Bank number. Only the bits that have been masked off that way are then replaced with the respective bits from register $201A bits 3-7 (RV6):

```text
$201A     Inner Bank  Middle Bank Effective
bits 0-2  AND Mask    AND Mask    Inner Bank Size
--------  ----------  --------    ---------------
0         FF          00          256 KiB
1         7F          80          128 KiB
2         3F          C0          64 KiB
3         invalid
4         1F          E0          32 KiB
5         0F          F0          16 KiB
6         07          F8          8 KiB
7         invalid

```

A second use of the Middle CHR Bank number is to eschew 1 KiB CHR-ROM granularity and switch 8 KiB of CHR-ROM at once in a CNROM-like fashion, by setting the Inner Bank AND Mask to zero and then using the Middle CHR Bank number as an 8 KiB bank number. A few multicarts use this technique to include CNROM games with minimal modification.

## Intermediate CHR Bank number

The Intermediate CHR Bank is only used if Background or Sprite Address Extension is not active while the respective pattern data are fetched, or neither is active while data is read or written via $2007. It provides three bits that go between the Middle and Outer CHR Bank number. A single Intermediate Bank number applies to all six CHR banks.

```text
PPU $0000-$1FFF: Selected by register $2018 bits 4-6 (VA18-20).

```

## Outer CHR Bank number

The Outer Bank number is used mostly by multicarts, but also by semi-large games for which the maximum Inner Bank size of 256 KiB is insufficient. A single Outer CHR Bank number applies to all six CHR banks.

```text
PPU $0000-$1FFF: Selected by register $4100 bits 0-3 (VA21-24).

```

## Final CHR Bank Number

The final 1 KiB (2 KiB in 4bpp modes) CHR Bank number therefore is:

If Address Extension not active:

```text
BankNumber =                          ((InnerBank &InnerBankMask) | (MiddleBank &~InnerBankMask) | (IntermediateBank <<8)) | (OuterBank <<11);

```

If Address Extension is active:

```text
BankNumber = ExtendedVideoAddress | ( ((InnerBank &InnerBankMask) | (MiddleBank &~InnerBankMask)                    ) <<3) | (OuterBank <<11);

```

This scheme implies that when Address Extension is active, the Inner and Middle Bank number registers must be loaded with values SHR 3 compared to the values they would have if Address Extension were inactive. It also shows that using only Background or Sprite Address Extension, but not both, becomes difficult to use if the Middle Bank is to be used. The Outer Bank is not affected by Address Extension.

## Final effective CHR address

The actual CHR-ROM address being accessed depends on the number of bits per pixel, the data bus width, and whether address extension is enabled: 2 bpp, address extension disabled:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOOIIIMMMMMMMMTTTTTTPRRR
||||||||||||||||||||||+++- Tile row
|||||||||||||||||||||+---- Bit plane
|||||||||||||||++++++----- Tile number D0..D5
|||||||++++++++----------- MMC3-compatible inner bank number,
|||||||                    Bank register selected by Tile number D6..D7 and $2000.3-4,
|||||||                    Masked via $201A.0-2, substituted via $201A.3-7
||||+++------------------- Intermediate bank number ($2018.4-6)
++++---------------------- Outer bank number ($4100.0-3)

```

2 bpp, address extension enabled:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOOMMMMMMMMEEETTTTTTPRRR
||||||||||||||||||||||+++- Tile row
|||||||||||||||||||||+---- Bit plane
|||||||||||||||++++++----- Tile number D0..D5
||||||||||||+++----------- Enhanced Video Address
||||++++++++-------------- MMC3-compatible inner bank number,
||||                       Bank register selected by Tile number D6..D7 and $2000.3-4,
||||                       Masked via $201A.0-2, substituted via $201A.3-7
++++---------------------- Outer bank number ($4100.0-3)

```

4 bpp, address extension disabled, 8-bit bus:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOIIIMMMMMMMMTTTTTTPPRRR
||||||||||||||||||||||+++- Tile row
||||||||||||||||||||++---- Bit plane
||||||||||||||++++++------ Tile number D0..D5
||||||++++++++------------ MMC3-compatible inner bank number,
||||||                     Bank register selected by Tile number D6..D7 and $2000.3-4,
||||||                     Masked via $201A.0-2, substituted via $201A.3-7
|||+++-------------------- Intermediate bank number ($2018.4-6)
+++----------------------- Outer bank number ($4100.0-2)

```

4 bpp, address extension enabled, 8-bit bus:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOMMMMMMMMEEETTTTTTPPRRR
||||||||||||||||||||||+++- Tile row
||||||||||||||||||||++---- Bit plane
||||||||||||||++++++------ Tile number D0..D5
|||||||||||+++------------ Enhanced Video Address
|||++++++++--------------- MMC3-compatible inner bank number,
|||                        Bank register selected by Tile number D6..D7 and $2000.3-4,
|||                        Masked via $201A.0-2, substituted via $201A.3-7
+++----------------------- Outer bank number ($4100.0-2)

```

4 bpp, address extension disabled, 16-bit bus:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOIIIMMMMMMMMTTTTTTPRRRp
||||||||||||||||||||||||+- Bit plane D0
|||||||||||||||||||||+++-- Tile row
||||||||||||||||||||+----- Bit plane D1
||||||||||||||++++++------ Tile number D0..D5
||||||++++++++------------ MMC3-compatible inner bank number,
||||||                     Bank register selected by Tile number D6..D7 and $2000.3-4,
||||||                     Masked via $201A.0-2, substituted via $201A.3-7
|||+++-------------------- Intermediate bank number ($2018.4-6)
+++----------------------- Outer bank number ($4100.0-2)

```

4 bpp, address extension enabled, 16-bit bus:

```text
       Address bit
-------------------------
2222211111111110000000000
4321098765432109876543210
OOOMMMMMMMMEEETTTTTTPRRRp
||||||||||||||||||||||||+- Bit plane D0
|||||||||||||||||||||+++-- Tile row
||||||||||||||||||||+----- Bit plane D1
||||||||||||||++++++------ Tile number D0..D5
|||||||||||+++------------ Enhanced Video Address
|||++++++++--------------- MMC3-compatible inner bank number,
|||                        Bank register selected by Tile number D6..D7 and $2000.3-4,
|||                        Masked via $201A.0-2, substituted via $201A.3-7
+++----------------------- Outer bank number ($4100.0-2)

```

This scheme implies that when 4bpp are used, all bank register numbers must be loaded with values SHR 1 compared to the values they would have if 2bpp were used. It also becomes clear that choosing bank numbers properly when using 4bpp only for background or sprites, but not both, becomes quite difficult and requires careful planning of one's CHR-ROM layout.

## Mapping into 16-bit PPU address space

When accessing pattern tables via $2007 in 4bpp modes, the now-16 KiB per pattern tables are spread across two address ranges:

```text
PPU $0000-$1FFF: CHR pattern data, bit planes 0 and 1
PPU $4000-$5FFF: CHR pattern data, bit planes 2 and 3

```

In other words, PPU A14 becomes bit 1 of the bit plane number.

# VT02+ PRG-ROM Bankswitching

Source: https://www.nesdev.org/wiki/VT02%2B_PRG-ROM_Bankswitching

In OneBus mode, VT02+ consoles combine the Famicom cartridge connector's CPU and PPU address lines into one 32 MiB address space, with separate CPU and PPU bankswitch registers pointing to appropriately-placed code and picture data. The bankswitching scheme is based on, and indeed backwards-compatible to, the Nintendo MMC3's. The CPU address range is divided into four 8 KiB banks. For each of these four 8 KiB banks, the bank number is made up of three components:
- an Inner Bank that resembles the MMC3's bank registers,
- a Middle Bank that can replace zero to eight bits of the lower bank number,
- an Outer Bank that extend the address range up to 32 MiB.

The final 8 KiB PRG-ROM bank number therefore is:

```text
BankNumber = (InnerBank &InnerBankMask) | (MiddleBank &~InnerBankMask) | (OuterBank <<8);

```

## Inner PRG Bank number

The lower bits bits of the 8 KiB PRG-ROM bank number, constituting the Inner Bank number, are normally the only ones that are manipulated by individual games. By default, they resemble the MMC3's original bank registers; accordingly, two of the four banks are fixed. By setting bit 6 in register $410B (PQ2EN), the $C000-$DFFF bank may be turned into a selectable bank as well.

```text
CPU $8000-$9FFF: Selected by register $4107 (PQ0), akin to MMC3 register 6.
CPU $A000-$BFFF: Selected by register $4108 (PQ1), akin to MMC3 register 7.
CPU $C000-$DFFF: If $410B bit 6 (PQ2EN)=0: Fixed to $FE, or second-to-last bank (within the Middle/Outer Bank), as on the MMC3.
                 If $410B bit 6 (PQ2EN)=1: Selected by register $4109 (PQ2), an enhancement over the MMC3.
CPU $E000-$FFFF: Fixed to $FF, or last bank (within the Middle/Outer Bank), as on the MMC3.

```

If $4105 bit 6 (COMR6) is 1, then the sources of the $8000-$9FFF/$A000-$BFFF bank numbers are swapped with the $C000-$DFFF/$E000-$FFFF banks', just as on the MMC3, or in other words, CPU A14 is inverted.

## Middle PRG Bank mask and number

The Middle Bank is normally only used on multicarts. It allows masking off and replacing bits of the Inner Bank number, so that several games may be put into one Outer Bank. Bits 0-2 of register $410B (PS) select the AND mask that is applied to the Inner Bank number. Only the bits that have been masked off that way are then replaced with the respective bits from register $410A (PQ3):

```text
$410B     Inner Bank  Middle Bank Effective
bits 0-2  AND Mask    AND Mask    Inner Bank Size
--------  ----------  --------    ---------------
0         3F          C0          512 KiB
1         1F          E0          256 KiB
2         0F          F0          128 KiB
3         07          F8          64 KiB
4         03          FC          32 KiB
5         01          FE          16 KiB
6         00          FF          8 KiB
7         FF          00          2048 KiB

```

## Outer PRG Bank number

The Outer Bank number is used mostly by multicarts, but also by very large games for which the maximum Inner Bank size of 2 MiB is insufficient. On the VT02 and VT03, bits 4-7 of register $4100 simply select the 2 MiB Outer Bank number for all four banks.

VT02, VT03; with $411C bit 5 (EXT2421)=0:

```text
CPU $8000-$FFFF: Selected by register $4100 bits 4-7 (PQ7).

```

If $4105 bit 6 (COMR6) is 1, then the sources of the $8000-$9FFF/$A000-$BFFF bank numbers are swapped with the $C000-$DFFF/$E000-$FFFF banks', as was the case with the Inner Bank number.

# Virtual Boy controller

Source: https://www.nesdev.org/wiki/Virtual_Boy_controller

The Virtual Boy controller has an NES-compatible protocol, and has been used in homebrew games.
- Spook-O'-Tron
- Candelabra - Estoscerro

After strobing the controller, the following 16 bits can be read from the data line:

```text
 0 - Right D-pad Down
 1 - Right D-pad Left
 2 - Select
 3 - Start
 4 - Left D-pad Up
 5 - Left D-pad Down
 6 - Left D-pad Left
 7 - Left D-pad Right

```

```text
 8 - Right D-pad Right
 9 - Right D-pad Up
10 - L (rear left trigger)
11 - R (rear right trigger)
12 - B
13 - A
14 - Always 1
15 - Battery voltage; 1 = low voltage

```

This is very analogous to the SNES controller, which reports its 4 face buttons where the VB reports its right d-pad. However, the last 4 bits (B, A, 1, battery) have no correspondence in the SNES controller report. Use this 1 to distinguish the Virtual Boy controller from that controller or a mouse.

## References
- VB Sacred Tech Scroll: Virtual Boy Specifications
- PlanetVB: Documents
- Sly Dog Studios: Candelabra - Estoscerro demo available
- Forum post: Spook-o'-tron - Virtual Boy Controller Fun

# Zapper

Source: https://www.nesdev.org/wiki/Zapper

The Zapper is a light gun, often associated with the game Duck Hunt . It reads light from a CRT SDTV and sends the brightness of the area where it is pointed on the controller port.

The Zapper can be used in either controller port, though most games will only allow you to use it in controller port #2, leaving port #1 for a standard controller used for navigating through options, moving the view, changing weapons, etc.

The Famicom Zapper is logically compatible, but can only be plugged into the Famicom expansion portand so only read from $4017 (i.e. controller port #2). The Vs. System Zapper is not compatible [1](see below).

### Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxT WxxS
   | |  |
   | |  +- Serial data (Vs.)
   | +---- Light sensed at the current scanline (0: detected; 1: not detected) (NES/FC)
   +------ Trigger (0: released or fully pulled; 1: half-pulled) (NES/FC)

```

There are three hardware variants: NES Light sense and trigger are output on bit 3 and 4 of $4016 or $4017, depending on the port. Famicom Light sense and trigger are output on bit 3 and 4 of $4017, as if the Zapper were plugged into port 2 of the NES. The pins for bits 3 and 4 in an AV Famicom's controller ports are normally not connected, but there is a published hardware modification to use an NES Zapper. Vs. System This Zapper communicates with the same protocol as the standard controller, returning an 8-bit report after being strobed: 0, 0, 0, 0, 1, 0, Light sense (inverted), Trigger The "light sense" status corresponds to Left and the "trigger" to Right, and Up is always pressed. Unlike the NES/Famicom Zapper, the Vs. Zapper's "light sense" is 1 when detecting and 0 when not detecting.

Tests in the Zap Ruder test ROM show that the photodiode stays on for about 26 scanlines with pure white, 24 scanlines with light gray, or 19 lines with dark gray. For an emulator developer, one useful model of the light sensor's behavior is that luminance is collected as voltage into a capacitor, whose voltage drains out exponentially over the course of several scanlines, and the light bit is active while the voltage is above a threshold.

The official Zapper's trigger returns 0 while the trigger is fully open, 1 while it is halfway in, and 0 again after it has been pulled all the way to where it goes clunk. The large capacitor (10µF) inside the Zapper when combined with the 10kΩ pullup inside the console means that it will take approximately 100ms to change to "released" after the trigger has been half-pulled.

Some clone zappers, like the Tomee Zapp Gun implement a simpler switch that returns 1 while the trigger is not pulled, and 0 when it is pulled. This works with most existing zapper games which usually fire on a transition from 1 to 0.

### Light Sensor

The light sensor in the NES Zapper has a filter tuned approimately to the CRT scanline frequency (~15 kHz). This helps filter out more slowly changing light signals (e.g. light bulbs), but unfortunately will strongly attenuate the light signal from many modern televisions (e.g. LCD based). Some clone zappers (e.g. Tomee Zapp Gun, or Simba's Jr) have a much weaker filter that responds more readily to these slower changing light sources.

Light gun games also tend to expect no effective delay from the CRT, allowing the sensor to give a reading immediately as the picture is being drawn on the TV screen. This is also a problem for most modern televisions, which tend to have inherent delay (display lag).

A combination of clone hardware with a weaker filter, and a software patch to compensate for the display lag delay can be effective for getting some zapper games to work with a modern television. [2]

### Sequence of operations

The common way to implement Zapper support in a game is as follows:
- Each frame, check if the player has pulled the trigger. Keep running the game loop and remain in this step until the trigger is pulled.
- During vertical blanking, verify that the light gun is not detecting light, to ensure that the player is actually pointing the gun at the screen. If bit 3 is false during vblank, a standard controlleris probably plugged in. Do this near the end of your vertical blank code to let the light "drain out" if the gun happens to be pointed near the bottom of the screen. If you are using sprite 0 hit, a good time to read it is right after the sprite 0 hit flag turns off.
- Optional: Turn the entire screen white or display white boxes on all targets, and use timed code or a scanline IRQ handler to wait for the Zapper to start detecting light in order to see how far down the screen the Zapper is pointed. This can narrow the set of targets that must be checked in the next step.
- For each target the player may hit, display a black screen with a single white ($20) or light colored ($31-$3C) box at the target's location. Wait the entire frame to check if the light sense bit goes low. The sensor may turn on and off in 10 to 25 scanlines, so continue to check throughout a whole frame. If any of the targets is hit, register a 'hit' within the game; if not, move on to the next target or, if there are no additional targets, register a 'miss'.
- Restore the screen to its original state.

## Trivia

In Wild Gunman (mode: GAME A: 1 OUTLAW), game's engine does not check what light gun is pointing at but just the time when trigger is pressed. As a result, this title is good choice nowadays for (partial) test of Zapper, where analog CRT TVs are quite rare to find.

## External Links
- Forum post:Zapper test ROMs
- Forum post:Zap Ruder: The Zapper test ROM project
- Forum post:Zapruder calibration
- Forum post:Detecting screen (X,Y) location for the NES Zapper

## References
- ↑Forum post:VS zapper info?
- ↑NES zapper + LCD: forum thread discussing the "NES LCD Mod" project.

# Input devices

Source: https://www.nesdev.org/wiki/Input_devices

The NES has two general-purpose controller portson the front of the console, as well as a (rarely used) 48-pin expansion portunderneath.

The Famicom's standard controllers are hardwired to the front of the unit, and a special 15-pin expansion portis commonly used for third-party controllers. The AV Famicom, however, features detachable controllers using the same ports as the NES.

The NES and Famicom have a set of I/O ports used for controllers and other peripherals, consisting of the following:
- One output port, 3 bits wide, accessible by writing the bottom 3 bits of $4016.
  - The values latched by $4016/write appear on the OUT0-OUT2output pins of the 2A03/07, where OUT0 is routed to the controller ports and OUT0-OUT2 to the expansion port on the NES.
- Two input ports, each 5 bits wide, accessible by reading the bottom 5 bits of $4016 and $4017. Reading $4016 and $4017 activates the /OE1 and /OE2signals, respectively, which are routed to the controller ports and the expansion port.
  - On the NES, only D0, D3, and D4 are connected to both controller ports, while all of D0-D4 are connected to the expansion port.
  - On the original Famicom, the two ports differ: $4016 D0 and D2 and $4017 D0 are permanently connected to both controllers, while $4016 D1 and all of $4017's D0-D4 are connected to the expansion port.
  - On the AV Famicom, only D0 is connected to the controller ports. The expansion port is unchanged.

## Programmer's reference
- Controller reading

## Hardware
- Controller port pinout
- Controllers
  - NES Standard controller
  - Arkanoid controller
  - Bandai Hyper Shot
  - Coconuts Pachinko
  - Doremikko Keyboard
  - Exciting Boxing Punching Bag
  - Family BASIC Keyboard
  - Four Score, NES Satellite4-player adapters
  - Hori 4 Players Adapterfor Famicom
  - Jissen Mahjong controller
  - Konami Hyper Shot
  - Miracle Piano
  - Mouse(SNES Mouse, Subor Mouse)
  - Oeka Kids tablet
  - Partytap
  - Pokkun Moguraa Mat
  - Power Glove
  - Power Pad, Family Trainer, Pokkun Moguraa Tap-tapmats
  - RacerMate Bicycle
  - SNES controller
  - Top Rider Bike
  - U-Force
  - Virtual Boy controller
  - Zapperlightgun
- Infrared controllers

## Other I/O devices
- Famicom 3D glasses
- Family BASIC Data Recorder
- R.O.B.
- Battle Box
- Turbo File
- Barcode Battler
- TV-NET Rank 2 controller
- FAM-NET Keyboard
- Family Computer Network Adapter
- Super Famicom NTT Data Keypad

## Usage of port pins by hardware type

| type | output | Joypad 1 | Joypad 2 | audio output |
| signal | OUT2 | OUT1 | OUT0 | /OE1 | D4 | D3 | D2 | D1 | D0 | /OE2 | D4 | D3 | D2 | D1 | D0 | AUDIO |
| access method | write $4016 | [1] | read $4016 | [2] | read $4017 |  |
| available on these ports |  |  |  |  |  |  |
| Controller port 1 (AV Famicom) |  |  | OUT0 | /OE1 |  |  |  |  | D0 |  |  |  |  |  |  |  |
| Controller port 1 (Famicom (internal)) |  |  | OUT0 | /OE1 |  |  |  |  | D0 |  |  |  |  |  |  |  |
| Controller port 1 (NES) |  |  | OUT0 | /OE1 | D4 | D3 |  |  | D0 |  |  |  |  |  |  |  |
| Controller port 2 (AV Famicom) |  |  | OUT0 |  |  |  |  |  |  | /OE2 |  |  |  |  | D0 |  |
| Controller port 2 (Famicom (internal)) |  |  | OUT0 |  |  |  | D2 |  |  | /OE2 |  |  |  |  | D0 |  |
| Controller port 2 (NES) |  |  | OUT0 |  |  |  |  |  |  | /OE2 | D4 | D3 |  |  | D0 |  |
| Expansion port (Famicom) | OUT2 | OUT1 | OUT0 | /OE1 |  |  |  | D1 |  | /OE2 | D4 | D3 | D2 | D1 | D0 | AUDIO |
| Expansion port (NES) | OUT2 | OUT1 | OUT0 | /OE1 | D4 | D3 | D2 | D1 | D0 | /OE2 | D4 | D3 | D2 | D1 | D0 | AUDIO |
| used by these devices |  |  |  |  |  |  |
| Controller (port 1)[3] |  |  | OUT0 | /OE1 |  |  |  |  | D0 |  |  |  |  |  |  |  |
| Controller (port 2)[3] |  |  | OUT0 |  |  |  |  |  |  | /OE2 |  |  |  |  | D0 |  |
| Controller (Famicom controller 2)[4] |  |  | OUT0 |  |  |  | D2 |  |  | /OE2 |  |  |  |  | D0 |  |
| Controller (expansion port) |  |  | OUT0 | /OE1 |  |  |  | D1 |  |  |  |  |  |  |  | AUDIO[5] |
| Arkanoid controller (port 2)[3] |  |  | OUT0 |  |  |  |  |  |  | /OE2 | D4 | D3 |  |  |  |  |
| Arkanoid controller (expansion port) |  |  | OUT0 |  |  |  |  | D1 |  | /OE2 |  |  |  | D1 |  |  |
| Arkanoid II controller (2 controllers) |  |  | OUT0 |  |  |  |  | D1 |  | /OE2 | D4 | D3 |  | D1 |  |  |
| Bandai Hyper Shot | OUT2 | OUT1 | OUT0 | /OE1 |  |  |  | D1 |  |  | D4 | D3 |  |  |  | AUDIO |
| Exciting Boxing Punching Bag |  | OUT1 |  |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| FAM-NET Keyboard | OUT2 | OUT1 | OUT0 |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| Family Trainer Mat | OUT2 | OUT1 | OUT0 |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| Family BASIC Keyboard | OUT2 | OUT1 | OUT0 |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| Famicom 3D System |  | OUT1 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Famicom Network System controller |  |  | OUT0 | /OE1 |  |  |  | D1 |  |  |  |  |  |  |  |  |
| Four player adapter (Four Score) |  |  | OUT0 | /OE1 |  |  |  |  | D0 | /OE2 |  |  |  |  | D0 |  |
| Four player adapter (Hori 4 Players Adapter) |  |  | OUT0 | /OE1 |  |  |  | D1 |  | /OE2 |  |  |  | D1 |  |  |
| Hori Track |  |  | OUT0 |  |  |  |  |  |  | /OE2 |  |  |  | D1 |  |  |
| Jissen Mahjong controller | OUT2 | OUT1 | OUT0 |  |  |  |  |  |  | /OE2 |  |  |  | D1 |  |  |
| Konami Hyper Shot | OUT2 | OUT1 |  |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| Oeka Kids tablet |  | OUT1 | OUT0 |  |  |  |  |  |  |  |  | D3 | D2 |  |  |  |
| Pachinko controller |  |  | OUT0 | /OE1 |  |  |  | D1 |  |  |  |  |  |  |  |  |
| Party Tap |  |  | OUT0 |  |  |  |  |  |  | /OE2 | D4 | D3 | D2 |  |  |  |
| Pokkun Moguraa Tap-tap Mat | OUT2 | OUT1 | OUT0 |  |  |  |  |  |  |  | D4 | D3 | D2 | D1 |  |  |
| Power Pad (port 2)[3] |  |  | OUT0 |  |  |  |  |  |  | /OE2 | D4 | D3 |  |  |  |  |
| Port test controller |  |  | OUT0 | /OE1 | D4 | D3 |  |  | D0 | /OE2 | D4 | D3 |  |  | D0 |  |
| TV-NET controller |  |  | OUT0 | /OE1 |  |  |  | D1 |  |  |  |  |  |  |  |  |
| TV-NET Rank 2 controller |  |  | OUT0 | /OE1 |  |  |  | D1 |  |  |  |  |  |  |  |  |
| Zapper (port 2) |  |  |  |  |  |  |  |  |  |  | D4 | D3 |  |  |  |  |
| Zapper (expansion port) |  |  |  |  |  |  |  |  |  |  | D4 | D3 |  |  |  | [6] |
| Zapper (Vs. System) (port 1)[3] |  |  | OUT0 | /OE1 |  |  |  |  | D0 |  |  |  |  |  |  |  |
- ↑/OE1 is activated by reading $4016.
- ↑/OE2 is activated by reading $4017.
- ↑ 3.03.13.23.33.4Controllers using NES ports can be plugged into either port, using that port's /OE and data lines. However, games may expect a controller to only be in a specific port.
- ↑The Famicom controller 2 has a microphone that sends audio input over $4016 D2. This is not affected by OUT0 nor /OE2.
- ↑A Famicom expansion controller may connect the audio output signal to a headphone jack (for example: IQ502 joypad).
- ↑The Casel Zapper plays audio when the trigger is pulled, but this is done entirely by the controller independent of the console's audio out.

# Exciting Boxing Punching Bag

Source: https://www.nesdev.org/wiki/Exciting_Boxing_Punching_Bag

This punching bag/doll is used in a single game:
- Exciting Boxing

It contains 8 sensors, each returned as a single bit when reading $4017:
- Left/Right Hook
- Left/Right Jab
- Left/Right Move
- Straight
- Body

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxAx
       |
       +- Select output sensors (see below)

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxE DCBx
   | |||
   | ||+-- Left Hook (A = 0), Left Jab (A = 1)
   | |+--- Move Right (A = 0), Body (A = 1)
   | +---- Move Left (A = 0), Right Jab (A = 1)
   +------ Right Hook (A = 0), Straight (A = 1)

```

## See Also
- image and English description

# FAM-NET Keyboard

Source: https://www.nesdev.org/wiki/FAM-NET_Keyboard

The FAM-NET Keyboardis a stripped-down Family BASIC Keyboardintended for use with the FAM-NET modem. It has only 16 keys and no support for the Family BASIC Data Recorder, but is otherwise functionally identical. The mapping from FAM-NET keys to Family BASIC keys is as follows:

```text
FAM-NET Keyboard | Family BASIC Keyboard
-----------------+----------------------
            LINE | F1
               ← | ←
               • | .
              EB | F7
               0 | 0
               1 | 1
               2 | 2
               3 | 3
               4 | 4
               5 | 5
               6 | 6
               7 | 7
               8 | 8
               9 | 9
               * | SPACE
               # | RETURN

```

The FAM-NET I and II modems both come with a keyboard. They are believed to be the same, but this has not been confirmed. This information is based on the FAM-NET I version.

# Family BASIC Keyboard

Source: https://www.nesdev.org/wiki/Family_BASIC_Keyboard

The Family BASIC Keyboard (HVC-007) was a peripheral released with the Family BASIC package in 1984. With the data recorderthat could be attached to it, it allowed the Famicomto have the abilities of the average home computer of around that time (including using cassette tape to load/store data in supported games). It is a generic 72 button keyboard (using common matrix logic) which is connected to the Famicom's expansion port.

## Keyboard map

In text format:

```text
F1  F2  F3  F4  F5  F6  F7  F8
 1 2 3 4 5 6 7 8 9 0 - ^ ¥ STOP    CH* INS DEL
ESC Q W E R T Y U I O P @ [ RETURN     UP
CTR A S D F G H J K L ; : ] KANA   LEFT RIGHT
SHIFT Z X C V B N M , . / _ SHIFT     DOWN
       GRPH   SPACE

* CH = CLR HOME

```

If you have proper font support, with full-width spaces (i.e. "=" is above "-"):

```text

　　　Ｆ１　　　　　　Ｆ２　　　　　　Ｆ３　　　　　　Ｆ４　　　　　　Ｆ５　　　　　　Ｆ６　　　　　　Ｆ７　　　　　　Ｆ８

　　　　！　　　＂　　　＃　　　＄　　　％　　　＆　　　＇　　　（　　　）　　　　　　　＝
　　　１　ァ　２　ィ　３　ゥ　４　ェ　５　ォ　６　　　７　　　８　　　９　　　０　　　－　　　＾　　　￥　　　 STOP
　　　　ア　　　イ　　　ウ　　　エ　　　オ　　　ナ　　　ニ　　　ヌ　　　ネ　　　ノ　　　ラ　　　リ　　　ル　　　　　　　　ＣＬＲ
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　ＩＮＳ　ＤＥＬ
　ＥＳＣ　Ｑ　　　Ｗ　　　Ｅ　　　Ｒ　　　Ｔ　　　Ｙ　パ　Ｕ　ピ　Ｉ　プ　Ｏ　ペ　Ｐ　ポ　＠　　　［　「　ＲＥＴＵＲＮ　　 HOME
　　　　　　カ　　　キ　　　ク　　　ケ　　　コ　　　ハ　　　ヒ　　　フ　　　ヘ　　　ホ　　　レ　　　ロ

　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＋　　　＊　　　　　　　　　　　　　　　　　▲
　　ＣＴＲ　Ａ　　　Ｓ　　　Ｄ　　　Ｆ　　　Ｇ　　　Ｈ　　　Ｊ　　　Ｋ　　　Ｌ　　　；　　　：　　　］　」　 カナ
　　　　　　　サ　　　シ　　　ス　　　セ　　　ソ　　　マ　　　ミ　　　ム　　　メ　　　モ　　　ー　　　。

　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　〈　　　〉　　　？　　　␣　　　　　　　　　　　　　◀　　　　　　　▶
ＳＨＩＦＴ　　Ｚ　　　Ｘ　　　Ｃ　　　Ｖ　　　Ｂ　　　Ｎ　　　Ｍ　　　，　　　．　　　／　　　　　　　　ＳＨＩＦＴ
　　　　　　　　タ　　　チ　　　ツ　　　テ　　　ト　　　ヤ　　　ユ　　　ヨ　　　ワ　　　ヲ　　　ン
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　▼

　　　　　　　　　　　 GRPH ［．．．．．．．．．．．．ＳＰＡＣＥ．．．．．．．．．．．．］

```

Mind that the DEL key function is actually that of Backspace we all know and love.

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xKCR
      |||
      ||+-- Reset the keyboard to the first row.
      |+--- Select column, row is incremented if this bit goes from high to low.
      +---- Enable keyboard matrix (if 0, all voltages inside the keyboard will be 5V, reading back as logical 0 always)

```

Incrementing the row from the (keyless) 10th row will cause it to wrap back to the first row.

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxK KKKx
   | |||
   +-+++--- Receive key status of currently selected row/column.

```

Any key that is held down, will read back as 0.

($4016 reads from the data recorder.)

Similar to the Family Trainer Mat, there are parasitic capacitances that the program must wait for to get a valid result. Family BASIC and the FDS BIOSwait at least 12 cycles (16 if load instructions are considered) between resetting the keyboard and reselecting column 0, and approximately 50 cycles after selecting each column before assuming the output is valid.

## Usage

Family BASIC and the FDS BIOS read the keyboard state with the following procedure:
- Write $05 to $4016 (reset to row 0, column 0), followed by 6 NOPs (12 cycles)
- Write $04 to $4016 (select column 0, next row if not just reset), followed by a delay of ~50 cycles
- Read column 0 data from $4017
- Write $06 to $4016 (select column 1), followed by a delay of ~50 cycles
- Read column 1 data from $4017
- Repeat steps 2-5 eight more times

Differences between Family BASIC and the FDS BIOS:
- The FDS BIOS terminates the routine early if all keys are pressed on column 0 of any row (it determines that the keyboard is disconnected). Family BASIC always reads all rows/columns.
- The FDS BIOS writes to $4016 with bit 2 clear at the end of the routine (thus disabling the keyboard matrix), but Family BASIC does not.

There are currently no known commercial FDSgames which use the BIOS routine for keyboard reading [footnotes 1].

## Matrix

|  | Column 0 | Column 1 |
| $4017 bit | 4 | 3 | 2 | 1 | 4 | 3 | 2 | 1 |
| Row 0 | ] | [ | RETURN | F8 | STOP | ¥ | RSHIFT | KANA |
| Row 1 | ; | : | @ | F7 | ^ | - | / | _ |
| Row 2 | K | L | O | F6 | 0 | P | , | . |
| Row 3 | J | U | I | F5 | 8 | 9 | N | M |
| Row 4 | H | G | Y | F4 | 6 | 7 | V | B |
| Row 5 | D | R | T | F3 | 4 | 5 | C | F |
| Row 6 | A | S | W | F2 | 3 | E | Z | X |
| Row 7 | CTR | Q | ESC | F1 | 2 | 1 | GRPH | LSHIFT |
| Row 8 | LEFT | RIGHT | UP | CLR HOME | INS | DEL | SPACE | DOWN |

## Hardware

The Family BASIC Keyboard is implemented using a CD4017 decade counter (to scan the rows of the keyboard matrix), a CD4019 quad AND-OR gate, and one sixth of a CD4069 hex inverter. The latter two are combined to make a quad 1-of-2 selector, equivalent to a CD4519 or a 74'157. (Another three inverters are used to interface to the Family BASIC Data Recorder)

## Miscellaneous
- Unlike the PC keyboard, but similar to the Commodore 64 keyboard, the sixteen keys corresponding to ASCII $2C-$3B all specify the ASCII code point should be XORed with $10 when the SHIFT key is pressed. This can be used to simplify the keyboard decoding logic in your program.
- There is no backslash key, however, historical reasons have given to using the yen key and symbol for the same meaning.
- The kana are arranged in (grid) alphabetical order, not in the way that modern Japanese computers are.

## Keyboard detection in other games

Lode Runner allows saving level data to tape by pressing Select during Edit Mode, but will only provide that option if it detects the Family BASIC Keyboard. The detection procedure (CPU $E9B8) selects the tenth row and expects $4017 AND $1E to return $1E, then writes $00 to $4016 to disable the keyboard and expects $4017 AND $1E to return $00.

## See Also
- Standalone Family BASIC Keyboard tests:
  - Key status report only
  - Key status report + display
  - FDS keyboard test(single key display, uses BIOS routine)

## Notes
- ↑Forum post:The NES version of Zanac reuses the FDS BIOS keyboard reading routine for its debug mode, but the FDS version does not appear to use it.

## References
- Reverse-engineered schematics by Enri:
  - http://cmpslv3.stars.ne.jp/Famic/Fambas.htm
  - Also available hereand here
- Photographs of the keyboard by Evan-Amos
- Stylized keycaps diagramfrom PFU's Happy Hacking Keyboard keyboard history library

# Four player adapters

Source: https://www.nesdev.org/wiki/Four_player_adapters

Four player adaptersare devices that plug into controller or expansion ports and provide additional ports. These ports can be used as alternatives to hardwired controllers or for multiplayer with more than 2 simultaneous players. Contemporary adapters allow some consoles to interface with up to 8 controllers. These adapters come in multiple forms, each with their own interfaces and limitations. Adapters

## "Simple" Famicom adapters

Because the Famicom only has one expansion port, a device such as the JoyPair or Twin Adapter is required to attach multiple controllers to it. Standard expansion controllers respond on D1 of $4016, and these passive multi-port devices redirect the second port to D1 of $4017. These may be used as players 3 and 4. In 1- or 2-player games for the Famicom, though, it is common to OR together the D1 and D0 bits of a joypad read to allow players to use external controllers as substitutes for the hardwired ones.

The expansion ports on these multi-port devices do not pass through all of the signals and thus are limited in functionality compared to the console's expansion port. Because of this, many controllers are not compatible with these adapters.

### Pinout

```text
     JoyPair CN1 |  | Famicom EXP
-----------------+--+-----------------
         GND  01 |--| 01  GND
        OUT0  12 |<-| 12  OUT0
Joypad 1 /D1  13 |->| 13  Joypad 1 /D1
Joypad 1 /OE  14 |<-| 14  Joypad 1 /OE
          5V  15 |--| 15  5V

     JoyPair CN2 |  | Famicom EXP
-----------------+--+-----------------
         GND  01 |--| 01  GND
        OUT0  12 |<-| 12  OUT0
Joypad 1 /D1  13 |->| 07  Joypad 2 /D1
Joypad 1 /OE  14 |<-| 09  Joypad 2 /OE
          5V  15 |--| 15  5V

(All other JoyPair pins not connected)

```

## Hori 4 Players Adapter

The Hori 4 Players Adapter is a Famicom expansion port device that provides 4 ports, usable in 2- and 4-controller modes selected using a switch. In 2-controller mode, ports 1 and 2 on the adapter function exactly like a "simple" Famicom adapter, and ports 3 and 4 are disabled. In 4-controller mode, ports 1 and 3 are multiplexed onto $4016 D1 and ports 2 and 4 onto $4017 D1. The first 8 reads from an address provide the joypad 1 D1 report from the first controller, the next 8 reads the joypad 1 D1 report from the second controller, and the next 8 reads a signature unique to that address. The read counter is reset as long as OUT0 is 1. The same connection limitations of the "simple" adapters still apply in 4-controller mode, which combined with the 8 read limit restricts the set of usable contemporary controllers to those compatible with the standard controller.

### Protocol

#### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller read strobe

```

This matches the normal strobe behavior used by the standard controllerand strobes all 4 at once.

#### Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxx xxDx
       |
       +-- Serial controller data

```

#### Report

```text
$4016 read D1:
  0-7  - Joypad 1 D1 bits 0-7 from controller #1
  8-15 - Joypad 1 D1 bits 0-7 from controller #3
 16-17 - (Always 0)
 18    - (Always 1)
 19-23 - (Always 0)

 24+   - (Always 1)

$4017 read D1:
  0-7  - Joypad 1 D1 bits 0-7 from controller #2
  8-15 - Joypad 1 D1 bits 0-7 from controller #4
 16-18 - (Always 0)
 19    - (Always 1)
 20-23 - (Always 0)

 24+   - (Always 1)

```

Note: Joypad 1 and joypad 2 are names used on the controller-side Famicom expansion portpin interface, as compared to $4016 and $4017 on the CPU side. While joypad 1 normally connects to $4016, this adapter routes each controller's joypad 1 /D1 to $4016 or $4017 as needed.

## Four Score

The Four Score is an adapter that plugs into both NES controller ports and provides 4 ports, usable in 2- and 4-controller modes. This device is nearly identical to the Hori 4 Players Adapter, differing in that D0 is used instead of D1 and the addresses' signatures are swapped. This device also provides two turbo switches.

### Protocol

#### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller read strobe

```

This matches the normal strobe behavior used by the standard controllerand strobes all 4 at once.

#### Output ($4016/$4017 read)

```text
7  bit  0
---- ----
xxxx xxxD
        |
        +- Serial controller data

```

#### Report

```text
$4016 read D0:
  0-7  - Joypad D0 bits 0-7 from controller #1
  8-15 - Joypad D0 bits 0-7 from controller #3
 16-18 - (Always 0)
 19    - (Always 1)
 20-23 - (Always 0)

 24+   - (Always 1)

$4017 read D0:
  0-7  - Joypad D0 bits 0-7 from controller #2
  8-15 - Joypad D0 bits 0-7 from controller #4
 16-17 - (Always 0)
 18    - (Always 1)
 19-23 - (Always 0)

 24+   - (Always 1)

```

Note: Joypad D0 refers to the data normally available on $4016 or $4017 bit 0. Unlike the Famicom expansion port, NES controller port wiring is relative to the port used, so while a controller normally chooses which data inputs to use, it does not choose whether those are joypad 1 or joypad 2.

### Turbo

The Four Score includes separate turbo enables intended for the A and B buttons. Each of these applies universally to all attached controllers and in both 2- and 4-controller modes. These turbos force their respective bits to 0 at a fixed rate by ANDing with a mask that alternates between 0 and 1, making a held button appear as though it is being rapidly pressed and released. After a strobe, the A turbo applies to the first read of each controller's report and the B turbo to the second read. In 2-controller mode, each turbo also applies again after every 32 additional reads, causing toggles in the stream of 1's that follow the report from official controllers.

The toggle rate is based on the Four Score's internal clock and is approximately 2 frames.

## NES Satellite

The NES Satellite is a 4-controller wireless adapter similar to the Four Score. Specific details are not yet known. Instead of a mode switch for 2 or 4 controllers, the NES Satellite has a mode switch selecting between standard controllers and the Zapper. Like the Four Score, it also features A and B turbo switches. Hardware

Inside the Four Score and 4 Players Adapter is a 22-pin DIP labeled FPA-S01. This IC consists of a decoder and one set of shift register, 5-bit counter, and multiplexer per joypad address, allowing each address to return the 8-bit contents of joypads 1 and 3 or 2 and 4 in series, followed by the signature byte.

In case you want to build a four player adapter into an arcade cabinet or some other permanent installation, you don't need to use a Four Score or other adapter: you just need six total shift registers. The inputs to these shift registers are parallel, so you need separate wires for each signal, like from SMS or ZX Spectrum controllers. 5+ controllers

These adapters can be used in combination with each other on the AV Famicom for up to 8 controllers, or on the Famicom with the hardwired controllers for up to 6. Because nonstandard controllers are not compatible with 4-controller modes, using them reduces the maximum possible controller count, but if a single nonstandard controller such as a mouse is desired, it can be used with a "simple" adapter alongside up to 6 standard controllers on an AV Famicom using a Four Score in the NES controller ports, a "simple" adapter in the expansion port, and a Hori 4 Players Adapter with controllers in ports 1 and 3 in the other "simple" adapter port. Compatible Games

Games known to support 3 or more simultaneous controllers:

| Game | Hori 4-player Adapter | Four Score | Simple |
| A Nightmare on Elm Street | yes | yes | ? |
| Bomber Man II (J) | no | no | yes |
| Bomberman II (U) | no | yes | ? |
| Downtown Nekketsu Koushinkyoku: Soreyuke Daiundoukai | yes | yes | yes |
| Gauntlet II | no | yes | no |
| Greg Norman's Golf Power | yes | yes | ? |
| Harlem Globetrotters | no | yes | ? |
| Ike Ike! Nekketsu Hockey Bu: Subette Koronde Dai Rantou | no | ? | yes |
| Indy Heat | yes | yes | ? |
| Kings of the Beach | yes | yes | ? |
| Kunio-kun no Nekketsu Soccer League | no | unlikely | yes |
| M.U.L.E. | no | yes | ? |
| Magic Johnson's Fast Break | yes | yes | ? |
| Millionaire (Sachen) | no | no | yes |
| Moero TwinBee: Cinnamon-hakase o Sukue! | no | ? | yes |
| Monster Truck Rally | no | yes | ? |
| NES Play Action Football | yes | yes | ? |
| Nekketsu Kakutou Densetsu | no | ? | yes |
| Nekketsu Koukou Dodge Ball Bu | no | ? | yes |
| Nekketsu Street Basket: Ganbare Dunk Heroes | no | ? | yes |
| Nintendo World Cup (U) | yes | yes | ? |
| R.C. Pro-Am II | yes | yes | ? |
| Rackets and Rivals | no | yes | ? |
| Roundball: 2-on-2 Challenge | no | yes | ? |
| Smash T.V. (twin-stick for 2 players) | no | yes | ? |
| Spot | yes | yes | no |
| Super Jeopardy! | yes | yes | ? |
| Super Off Road | yes | yes | no |
| Super Spike V'Ball | everywhere but title screen | everywhere but title screen | yes |
| Swords and Serpents | no | yes | ? |
| Top Players' Tennis | yes | yes | ? |
| U.S. Championship V'Ball | only during 3+player gameplay | only during 3+player gameplay | yes |
| Wit's | yes | yes | yes |

Homebrew games:
- Double Action Blaster Guys becomes Quadruple Action Blaster Guys when Four Score is connected (NES)
- Micro Mages (NES and Famicom)
- NESert Golfing (NES and Famicom)
- Spacey McRacey (NES)
- Super PakPak (NES and Famicom)

Tech demos:
- Eighty (NES and Famicom)
- allpads (NES and Famicom)

Hacks:
- Battle City - 4 Players v1.3 Ti (NES and Famicom)
- Battle City Mario - 4 players v1.0 NesDraug (NES and Famicom)
- Battletoads - 4 players v2.2 NakeuD2007 (emulator only)
- Battletoads & Double Dragon - 4 players v0.9 NakeuD2007 (emulator only)
- Super Dodge Ball - 4 Player Hack v1.00 akatranslations (Famicom)
Incompatible Games

This section lists games that provide four player game modes without supporting a four player adapter. They are explicitly enumerated here because various lists, including one in Wikipedia, frivolously keep listing (and re-adding after an edit to remove them) these games as supporting a four player adapter.
- Championship Bowling : Manual clearly states "Players One and Three use Control Pad 1, and Players Two and Four use Control Pad 2".
- Jeopardy! series: Players 1 and 3 share controller 1.
References
- Forum post: Analysis of Wit's controller reading, and speculation about the Hori 4 Players adapter.
- NintendoAge forum thread: Photos of Four Score PCB and hardware discussion.
- Famicom World forum post: List of Famicom games and their behaviour with Hori 4 Players adapter.
- Forum post: Discussion of Hori 4 Players support in Micro Mages .

# Hori Track

Source: https://www.nesdev.org/wiki/Hori_Track

Hori produced a trackball compatible with Moero Pro Soccer , Putt Putt Golf , Operation Wolf , and US Championship V'Ball . It was released in Japan, and what appears to be a prototype U.S. version was exhibited behind glass in Nintendo World, but the U.S. version never reached stores.

Report byte 1 is the embedded standard controller.

Byte 2, MSB first:

```text
7654 3210
|||| ++++- Axis 2, signed 4 bit, XOR with $F
++++------ Axis 1, signed 4 bit, XOR with $F

```

Byte 3, MSB first:

```text
7654 3210
|||| ++++- Unknown (read and unused by games)
||++------ ID bits (1 or 2 depending on version)
|+-------- Speed switch (0: Hi, 1: Lo)
+--------- Rotation mode switch (0: R, 1: L)

```

In rotation mode L, Up on the Control Pad points up, axis 1 points down, and axis 2 points right. In rotation mode R, Up on the Control Pad points right, axis 1 points left, and axis 2 points down.

Unlike the rotation mode switch, the speed switch will alter the axis values before they are presented to the console.

The ID bits are in the same place as those of the Four Scorehub, which is also based on a Hori design. It is speculated that axis 2 can be used to distinguish them.

# Konami Hyper Shot

Source: https://www.nesdev.org/wiki/Konami_Hyper_Shot

The Konami Hyper Shot is used (and required for gameplay) in the following games:
- Hyper Olympic (J) Konami (1985)
- Hyper Sports (J) Konami (1985)

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xEFx
      ||
      |+- 0=Enable Player 1 Buttons
      +-- 0=Enable Player 2 Buttons

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxD CBAx
   | |||
   | ||+-- Player 1 Run
   | |+--- Player 1 Jump
   | +---- Player 2 Run
   +------ Player 2 Jump

```

The Jump/Run bits for a player will always be 0 if the corresponding enable bit in $4016 is set.

## See Also
- video of outside, teardown, and game play
- SG-1000 version

# Macro Winners Mouse

Source: https://www.nesdev.org/wiki/Macro_Winners_Mouse

A mouse that came with cartridges and keyboard famiclones manufactured by Macro Winners , also known as Belsonic , usually using their GameStar branding. GameStar -branded cartridges that did not come bundled with a keyboard famiclone tend to use the Subor Mouseinstead.

Example games:
- Smart Genius
- Магистр Гений 2 Говорящий Картридж
- Мооспирв Обучающий Компьютер 2000 (a.k.a. Educational Computer 2000, though there are others with that title)

The Mega Book Mouse is virtually identical to the Macro Winners Mouse; the only difference is that the two bits that indicate the "byte number" are in a different bit position.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Strobe

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxx xxxD
        |
        +- Serial data (bit 7->bit 6->...->bit 0)

```

The mouse returns either 1-byte or 3-byte responses based on the size of the x/y axis movement since the last read. If the movement value for both the X and Y axis is between -1 and 1 (inclusively), the mouse returns a 1-byte response. Otherwise, a 3-byte response is sent. In this case, the strobe bit must be toggled 3 times in a row to read the entire response (e.g read $4017 8 times, toggle strobe bit, read 8 more times, etc.)

#### 1-byte response format

Macro Winners:

```text
LRXXYY00
||||||||
||||||++- Always 0
||||++--- Y movement (0: no movement, 1 or 2 = went down 1 unit, 3 = went up 1 unit)
||++----- X movement (0: no movement, 1 or 2 = went right 1 unit, 3 = went left 1 unit)
|+------- Right mouse button (1: pressed)
+-------- Left mouse button (1: pressed)

```

The mouse button order is opposite that of the Super NES Mouse.

Mega Book:

```text
LR00XXYY
||||||||
||||||||
||||||++--- Y movement (0: no movement, 1 or 2 = went down 1 unit, 3 = went up 1 unit)
||||++----- X movement (0: no movement, 1 or 2 = went right 1 unit, 3 = went left 1 unit)
||++----- Always 0
|+------- Right mouse button (1: pressed)
+-------- Left mouse button (1: pressed)

```

#### 3-byte response format

Macro Winners:

Byte 1

```text
LRSXTY01
||||||||
||||||++- Always 01
|||||+--- Y movement (Bit 4)
||||+---- Y movement direction (1: up, 0: down)
|||+----- X movement (Bit 4)
||+------ X movement direction (1: left, 0: right)
|+------- Right mouse button (1: pressed)
+-------- Left mouse button (1: pressed)

```

Byte 2

```text
--XXXX10
  ||||||
  ||||++- Always 10
  ++++--- X movement (Bits 0-3)

```

Byte 3

```text
--YYYY11
  ||||||
  ||||++- Always 11
  ++++--- Y movement (Bits 0-3)

```

Mega Book:

Byte 1

```text
LR01SXTY
||||||||
||||||||
|||||||+--- Y movement (Bit 4)
||||||+---- Y movement direction (1: up, 0: down)
|||||+----- X movement (Bit 4)
||||+------ X movement direction (1: left, 0: right)
||++----- Always 01
|+------- Right mouse button (1: pressed)
+-------- Left mouse button (1: pressed)

```

Byte 2

```text
--10XXXX
  ||||||
  ||||||
  ||++++--- X movement (Bits 0-3)
  ++------- Always 10

```

Byte 3

```text
--11YYYY
  ||||||
  ||||||
  ||++++--- Y movement (Bits 0-3)
  ++------- Always 11

```

## References
- Nocash's EveryNES documentation(incorrectly calls it the "Subor Mouse")

# Oeka Kids tablet

Source: https://www.nesdev.org/wiki/Oeka_Kids_tablet

The Oeka Kids tablet is a Famicom accessory from Bandai that resembles a drawing tablet, and plugs into the expansion port. There are two known games that use this peripheral, using iNES Mapper 096, both of which contain a variety of activities, such as painting, drawing lessons, hiragana lessons, and a variety of minigames such as mazes and sliding puzzles.

Very little information about this accessory is available, and only basic reverse engineeringhas been performed so far. As such, this information may be incorrect , but it seems to be acceptable for the two commercial games that use it.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxAS
       ||
       |+- Strobe (0 = Latch, 1 = Read mode)
       +-- Advance to next bit

```

Bits can be read only while S is 1. It advances to the next bit when S is 1 and A transitions from 0 to 1.

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxx DSxx
     ||
     |+-- 0 if strobe is 1, 1 otherwise.
     +--- (Inverted) Serial data if strobe is 1, 0 if strobe is 0.

```

The serial data is returned most significant bit first , and inverted (including the touch and click bits).

```text
$4017.2
   ^
   |  <-- <-- <-- <--
   XXXXXXXXYYYYYYYYBA
   ||||||||||||||||||
   |||||||||||||||||+- Click (gray "space bar" at bottom of tablet is held)
   ||||||||||||||||+-- Stylus is touching tablet
   ||||||||++++++++--- Stylus Y, scaled to 0-255
   ++++++++----------- Stylus X, scaled to 0-239

```

The fact that X and Y are scaled backwards is not an error - the games which use this mapper rescale the coordinates by multiplying X by 256/240 and multiplying Y by 240/256.

Note that the Stylus X and Y values are nonsense when the stylus is not touching the tablet.

# Partytap

Source: https://www.nesdev.org/wiki/Partytap

The Partytap is used in the following games:
- Casino Derby
- Gimmi a Break - Shijou Saikyou no Quiz OuKetteisen
- Gimmi a Break - Shijou Saikyou no Quiz OuKetteisen 2
- Project Q

It consists of 6 separate 1-button controllers (labelled buttons 1 to 6 below).

## Hardware interface

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Controller shift register strobe

```

### Output ($4017 read)

```text
7  bit  0
---- ----
xxxC BAxx
   | ||
   | |+- Serial data (Button 1, Button 4)
   | +-- Serial data (Button 2, Button 5)
   +---- Serial data (Button 3, Button 6)

```

The first read returns the state of buttons 1 to 3, the 2nd read gives buttons 4 to 6. The third read apparently returns a detection value ($14).

The device supposedly requires a relatively large number of cycles between writes/reads (games wait up to 80-500 cycles in-between some operations).

## References
- nocash's NES documentation
- Forums - Party Tap(in Japanese)

# Subor Mouse

Source: https://www.nesdev.org/wiki/Subor_Mouse

The Subor Mouse is a third party accessory, used not only by Subor themselves for their later educational cartridges, but also by a number of third-party titles by other developers. It responds to the same strobe signal as a standard controller, and the first eight bits returned are defined such that a standard controller's response will be that of a mouse that returns a movement amount of 1. As a result, the mouse pointer can be moved with a standard controller, and the movement of the Subor Mouse will be seen by non-mouse-aware programs as an equivalent standard controller response.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Strobe

```

### Output ($4016 or $4017 read)

```text
7  bit  0
---- ----
xxxx xxxD
        |
        +- Serial data (bit 23->bit 22->...->bit 0)

```

### 24-bit response

```text
222211111111110000000000
321098765432109876543210
------------------------
lrE.UDLR.XXXXXXX.YYYYYYY
||| |||| ||||||| +++++++- absolute amount of Y movement (0-127) if E=1
||| |||| +++++++--------- absolute amount of X movement (0-127) if E=1
||| |||+----------------- positive X movement detected (right)
||| ||+------------------ negative X movement detected (left)
||| |+------------------- positive Y movement detected (down)
||| +-------------------- negative Y movement detected (up)
||+---------------------- 1: movement amount greater than 1 or lesser than -1 detected, X/Y bits must be interpreted
|+----------------------- 1: right mouse button pressed
+------------------------ 1: left mouse button pressed

```

### Notes
- GameStar Fun Educator꞉ 32-in-1 will only recognize mouse button presses if the E bit is set. This suggests that some models of the Subor Mouse may have that bit set all the time.

# Super NES Mouse

Source: https://www.nesdev.org/wiki/Super_NES_Mouse

The Super NES Mouse (SNS-016) is a peripheral for the Super NES that was originally bundled with Mario Paint . It can be used with an NES through an adapter, made from an NES controller extension cord and a Super NES controller extension cord, that connects the respective power, ground, clock, latch, and data pins. The Hyper Click Retro Style Mouse by Hyperkin is an optical mouse mostly compatible with software for the Super NES Mouse, with some behavior quirks.

As with the standard controller, the mouse is read by turning the latch ($4016.d0) on and off, and then reading bit 0 or bit 1 of $4016 or $4017 several times, but its report is 32 bits long as opposed to 8 bits.

On an NES or AV Famicom, the mouse may be connected to bit 0 through the front controller ports. On the original Famicom, it would normally have to be connected to bit 1 instead through the expansion port.

## Report

The report is divided functionally into four bytes. The most significant bit is delivered first:

```text
76543210  First byte
++++++++- Always zero: 00000000

76543210  Second byte
||||++++- Signature: 0001
||++----- Current sensitivity (0: low; 1: medium; 2: high)
|+------- Left button (1: pressed)
+-------- Right button (1: pressed)

76543210  Third byte
|+++++++- Vertical displacement since last read
+-------- Direction (1: up; 0: down)

76543210  Fourth byte
|+++++++- Horizontal displacement since last read
+-------- Direction (1: left; 0: right)

```

After the fourth byte, subsequent bits will read as all 1, though the Hyperkin clone mouse instead reads a single 1 then all 0s. [1]

The Hyper Click mouse will not give a stable report if it is read too fast. Between each read and the next, there should be at least 14 CPU cycles. Between the 2nd and 3rd byte (16th and 17th bit) of the report should be at least 28 CPU cycles. Reading faster than this will result in corrupted values. [2].

## Motion

Motion of the mouse is given as a displacement since the last mouse read, delivered in the third and fourth bytes of the report.

The displacements are in sign-and-magnitude, not two's complement. For example, $05 represents five mickeys (movement units) in one direction and $85 represents five mickeys in the other. To convert these to two's complement, use negation:

```text
  ; Convert to two's complement
  lda third_byte
  bpl :+
  eor #$7F
  sec
  adc #$00
:
  sta y_velocity

  lda fourth_byte
  bpl :+
  eor #$7F
  sec
  adc #$00
:
  sta x_velocity

```

When the magnitude of motion is 0, the reported sign will repeat the last used sign value for that coordinate.

## Sensitivity

The mouse can be set to low, medium, or high sensitivity.

On the original SNES mouse this can be changed by sending a clock while the latch ($4016.d0) is turned on:

```text
  ldy #1
  sty $4016
  lda $4016
  dey
  sty $4016

```

Some revisions of the mouse's microcontroller power up in an unknown state and may return useless values before the sensitivity is changed for the first time. [3]

The Hyper Click mouse will not cycle its sensitivity this way. Instead it has a manual button on the underside that must be pressed by the user to cycle sensitivity. It will always report 0 for sensitivity, regardless of its manual setting. For this reason, it is not advised to use the software sensitivity cycling to automatically detect the presence of a mouse. [4]

On the original SNES mouse, sensitivity setting 0 responds linearly to motion, at a rate of 50 counts per inch [5]. Values range from 0 to 63, but values higher than 25 are increasingly difficult to produce. [6]

Sensitivity settings 1 and 2 appear to remap the equivalent setting 0 values 0-7 to a table, and clamping at the highest value. (Rarely, however, other values may be seen in settings 1 and 2.)

| Sensitivity | Value |
| 0 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | ... |
| 1 | 0 | 1 | 2 | 3 | 8 | 10 | 12 | 21 | 21 | 21 | ... |
| 2 | 0 | 1 | 4 | 9 | 12 | 20 | 24 | 28 | 28 | 28 | ... |

The Hyper Click's two manually selected sensitivities both scale linearly with motion speed. Low sensitivity produces 0-31, and high sensitivity produces 0-63. The magnitude of the result is not dependent on the rate of polling, so it appears to report the current speed rather than the distance travelled since the last poll. The maximum value (31/63) at either sensitivity appears to correspond roughly to a speed of 8 inches per second. (This mouse should be used on a surface with a visible texture.) [7]

## Other notes

Using more than two mice on an AV Famicom is not recommended for two reasons:
- A mouse draws 50 mA, which is much more current than the standard controller draws. Drawing too much current is likely to cause the voltage regulator to overheat.
- Changing player 1's sensitivity also affects player 3's, and changing player 2's sensitivity also affects player 4's.

Some documents about interfacing with the mouse recommend reading the first 16 bits at one speed, delaying a while, and reading the other 16 bits at another speed, following logic analyzer traces from a Super NES console. However, these different speeds are merely an artifact of the main loop of Mario Paint , and the authentic mouse will give a correct report when read at any reasonable speed. For example, a program could read 8 bits, wait a couple thousand cycles, and then read the other 24. The Hyper Click needs a delay after the first 16 bits, though not nearly as much as these documents recommend.

## DPCM-safe code

Reading controllers while DPCM is playingcan result in bits being lost on non-PAL consoles. This is often solved by reading the controller repeatedly, but this solution is not compatible with the mouse because the mouse returns a delta since its last read, so reading it changes its state. The mouse also cannot be read fast enough to work with repeated reads. Therefore, DPCM-safe mouse reads require that the reads be synced with OAM DMAso that they never occur on the same cycle as DMC DMA. See DMAand especially register conflictsfor more information.

The following code can safely read both the mouse (official or Hyperkin) and either an NES or SNES controller. It requires 5 or 6 zero page variables and its branches must not cross a page boundary. This code must not be interrupted by an NMI or IRQ.

```text
CONFIG_JOYPAD_SIZE = 2        ; Report size in bytes. 1 for NES controller or 2 for SNES controller.
CONFIG_MOUSE_SENSITIVITY = 1  ; 1: Allow mouse sensitivity to be clocked. 0: Disable.

; This code assumes fixed ports for the mouse and joypad. You can swap them here. If you want to be able
; to support both in the same game, it's recommended to make two copies of this function, one for each
; configuration, and then call the correct copy for the configuration you detected. These must not be
; the same register.
CONFIG_JOYPAD_REGISTER = $4016
CONFIG_MOUSE_REGISTER = $4017

; These zero page variables MUST be in zero page; the code relies on zero page timing.
.segment "ZEROPAGE"

mouse: .res 4 + CONFIG_JOYPAD_SIZE
  kMouseZero = 0  ; The mouse's 0 signature is written here. Can be replaced with joypad 1 state after.
  kMouseButtons = 1
  kMouseY = 2
  kMouseX = 3
joypad1_down := mouse+4  ; This must immediately follow the mouse variables.

; This mask tells the code which register bit to use for reading the mouse. The idea is that the game
; will detect which bit the mouse is using at power-on and then set that bit to 1 in here, with all the
; other bits 0. When using an NES controller port, this will normally have just bit 0 set (#$01). When
; using a Famicom expansion port, this will normally have just bit 1 set (#$02).
mouse_mask: .res 1

.segment "BSS"

.if CONFIG_MOUSE_SENSITIVITY <> 0
; If non-zero, tells the mouse reading code to clock the mouse sensitive once. The variable is then
; cleared. Sensitivity clocking works with the official mouse, but not the Hyperkin mouse.
advance_sensitivity: .res 1
.endif  ; CONFIG_MOUSE_SENSITIVITY

.segment "CODE"

; Performs OAM DMA and reads a mouse and one controller.
.proc OamDmaAndJoypads
  ; Strobe the joypads.
  ldx #$00
  ldy #$01
  sty mouse
  sty JOYPAD1

 .if CONFIG_MOUSE_SENSITIVITY <> 0
  ; Clock official mouse sensitivity.
  lda advance_sensitivity
  beq :+
  lda CONFIG_MOUSE_REGISTER
  stx advance_sensitivity
 :
 .endif  ; CONFIG_MOUSE_SENSITIVITY

  stx JOYPAD1

  ; Do OAM DMA.
  lda #>oam_buffer
  sta OAM_DMA

  ; Desync cycles: 432, 576, 672, 848, 432*2-4 (860)

  ; DMC DMA:                  ; PUT GET PUT GET        ; Starts: 0

mouse_loop:
  lda mouse_mask              ; get put get*     *576  ; Starts: 4, 158, 312, 466, [620]
  and CONFIG_MOUSE_REGISTER   ; put get put GET
  cmp #$01                    ; put get
  rol mouse, x                ; put get put get* PUT GET  *432
  bcc mouse_loop              ; put get (put)          ; Must not cross page boundary.

  inx                         ; put get
  cpx #$04                    ; put get
  sty mouse, x                ; put get put GET
  bne mouse_loop              ; put get (put)          ; Must not cross page boundary.

standard_loop1:
  lda CONFIG_JOYPAD_REGISTER  ; put get put GET        ; Starts: 619
  and #$03                    ; put get*         *672
  cmp #$01                    ; put get
  rol joypad1_down            ; put get put get put    ; This can desync, but we finish before it matters.
  bcc standard_loop1          ; get put (get)          ; Must not cross page boundary.

  ; Next cycle: 746

  ; For the SNES controller, we read another byte.
 .if CONFIG_JOYPAD_SIZE > 1
  sty joypad1_down+1          ; get put get
  nop                         ; put get
standard_loop2:
  lda CONFIG_JOYPAD_REGISTER  ; put get* put GET *848  ; Starts: 751, [879]
  and #$03                    ; put get
  cmp #$01                    ; put get
  rol joypad1_down+1          ; put get put get put    ; This can desync, but we finish before it matters.
  bcc standard_loop2          ; get* put (get)   *860  ; Must not cross page boundary.

  ; Next cycle: 878
 .endif  ; CONFIG_JOYPAD_SIZE

  ; -- Reads are finished and we no longer need to be synced. Now we can calculate button presses here. --

  rts
.endproc

```

## Example games

Games
- Thwaite
- Sliding Blaster
- NESert Golfing

Applications
- Theremin
- Pently Sound Effects Editor
- The menu of any Action 53volume including a game or application with mouse support

Tests
- Meece, the first
- allpads
- 240p Test Suite

## References
- Mouseat SNESdev Wiki
- ↑forum post: Hyperkin SNES mouse investigation
- ↑forum post: Hyperkin mouse reads have a speed limit
- ↑Martin Korth. " Fullsnes: SNES Controllers Mouse Two Button Mouse".
- ↑forum post: Hyperkin SNES Mouse cannot software-cycle sensitivity
- ↑FullSNES- Nocash SNES Mouse documentation
- ↑forum post: SNES Mouse sensitivity measurements
- ↑forum post: Hyperkin Mouse sensitivity measurements

# Yuxing Mouse

Source: https://www.nesdev.org/wiki/Yuxing_Mouse

The 裕兴 (Yùxìng) Mouse is a nearly bog-standard serial mouse that can be connected to either controller port. The only difference is that the X and Y axes are swapped compared to the normal serial mouse protocol, most likely for purposes of vendor lock-in.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xxxS
        |
        +- Inverted strobe

```

The mouse is read by first writing 0, then 1, to $4016 -- the opposite of what is written to read a standard controller.

### Output ($4016 or $4017 read)

```text
7  bit  0
---- ----
xxxx xxxD
        |
        +- Inverted serial data

```

### Response

The serial data consists of three nine-bit packets: one 0 start bit, seven data bits, one 1 stop bit.

```text
#1 [0 1LRXXYY 1]
    | ||||||| +- Stop bit
    | |||||++--- Y movement, bits 7..6
    | |||++----- X movement, bits 7..6
    | ||+------- 1: right mouse button pressed
    | |+-------- 0: left mouse button pressed
    | +--------- Synchronization, indicates first of three packets
    +----------- Start bit

#2 [0 0YYYYYY 1]
    |  |||||| +- Stop bit
    |  ++++++--- Y movement, bits 5..0
    +----------- Start bit

#3 [0 0XXXXXX 1]
    |  |||||| +- Stop bit
    |  ++++++--- X movement, bits 5..0
    +----------- Start bit

```

# Everdrive N8

Source: https://www.nesdev.org/wiki/Everdrive_N8

The Everdrive N8 is a Flash Cartridgemade by Krikzz. It uses an FPGA to emulate a wide variety of mappers, allowing the user to store a large collection of ROMs on a single SD card and run them on an NES or Famicom.

In addition to NES ROMs, the Everdrive N8 is able to play FDS disk images.

Famicom expansion audio is supported, and on the NES version is output on the EXP 6 expansion pin on the cartridge connector as used by the PowerPak. A simple modification to the NES allows the expansion audio to be mixed with its output.

Specifications:
- PRG size: 512 KB
- CHR size: 512 KB

NES product: https://krikzz.com/store/home/31-everdrive-n8-nes.html

Famicom product: https://krikzz.com/store/home/32-everdrive-n8-famicom.html

This flashcart was eventually discontinued and succeeded by the much newer Everdrive N8 Pro.

## Hardware

Cartridge consists of:
- Altera Cyclone II FPGA (EP2C5T144), which is reprogrammed with mapper of preselected ROM
- Altera Max II CPLD (EPM240T100C5), which is glue logic
- 2 x CY7C1049CV33T (PRG-ROM, CHR-RAM/ROM)
- 29W160 (2MB) Flash (BIOS)
- IS52LV1024 (128kB PRG-RAM)
- SN74LVCR162245A 3.3V-5V buffers
- an optional FT245RL, that is responsible for communication between USB port and the CPLD

The software part consist of:
- CPLD - logic code inside EPM240T100C5 that is pre-programmed at factory and cannot be updated
- BIOS - program code inside 29W160 that is executed just after powering up the console (by default, it cannot be updated, unless a jumper at back side of the cartridge is closed)
- OS - program code that is stored on the flash card

## Mapper compatibility

As of the OS update v1.26 in 2021, the Everdrive N8 supports the following mappers: [1]

| 000 | 001 | 002 | 003 | 004 | 005 | 006 | 007 | 008 | 009 | 010 | 011 | 012 | 013 | 014 | 015 |
| 016 | 017 | 018 | 019 | 020 | 021 | 022 | 023 | 024 | 025 | 026 | 027 | 028 | 029 | 030 | 031 |
| 032 | 033 | 034 | 035 | 036 | 037 | 038 | 039 | 040 | 041 | 042 | 043 | 044 | 045 | 046 | 047 |
| 048 | 049 | 050 | 051 | 052 | 053 | 054 | 055 | 056 | 057 | 058 | 059 | 060 | 061 | 062 | 063 |
| 064 | 065 | 066 | 067 | 068 | 069 | 070 | 071 | 072 | 073 | 074 | 075 | 076 | 077 | 078 | 079 |
| 080 | 081 | 082 | 083 | 084 | 085 | 086 | 087 | 088 | 089 | 090 | 091 | 092 | 093 | 094 | 095 |
| 096 | 097 | 098 | 099 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | 108 | 109 | 110 | 111 |
| 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119 | 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
| 128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 | 139 | 140 | 141 | 142 | 143 |
| 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 |
| 160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 |
| 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 |
| 192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 | 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 |
| 208 | 209 | 210 | 211 | 212 | 213 | 214 | 215 | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 |
| 224 | 225 | 226 | 227 | 228 | 229 | 230 | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 |
| 240 | 241 | 242 | 243 | 244 | 245 | 246 | 247 | 248 | 249 | 250 | 251 | 252 | 253 | 254 | 255 |

Known problems:
- Mapper 71 only supports the memory controller used by FireHawk, all other Mapper 71 games must be reassigned to Mapper 2 to work correctly.

## Obsolete Mappers

A few mappers have been created by others to supplement the Everdrive's provided set, but have since been integrated into or replaced by official mappers:
- UNROM 512( 030): forum post(lacks flash save)
- GTROM( iNES Mapper 111): forum post(lacks flash save)

## Software development limitations

Aside from mapper incompatibility, there are minor differences between running NES programs on the Everdrive versus a traditional single-game cartridge.
- The Everdrive does not accurately simulate power-on state. Because power-on always boots the Everdrive menu, RAM and various registers will be initialized to a consistent state before any NES ROM is chosen to run. (Reset state, however, is not affected by this problem.)
- Open bus behaviormay be different in several memory regions that are used by the Everdrive, but would not be connected on a regular cartridge. ( forum post)
- The Everdrive is incompatible with an NES that has the CopyNESmodification installed, due to a bus conflict with its boot code.

## Everdrive development resources
- Software tools and example mapper source code: http://krikzz.com/pub/support/everdrive-n8/original-series/development/

# Everdrive N8 Pro

Source: https://www.nesdev.org/wiki/Everdrive_N8_Pro

The Everdrive N8 Pro is a Flash Cartridgemade by Krikzz, and it is an upgrade to the original Everdrive N8. It uses an FPGA to emulate a wide variety of mappers, allowing the user to store a large collection of ROMs on a single SD card and run them on an NES or Famicom. Compared to the original Everdrive N8, the N8 Pro has a larger ROM size and several new features, such as support for multiple save states slots, and a USB port for directly copying data to the SD card. [1]

In addition to NES ROMs, the Everdrive N8 PRO is able to play FDS disk images and NSF files (including NSF with expansion audio.)

Famicom expansion audio is supported, and on the NES version is output on the EXP 6 expansion pin on the cartridge connector as used by the PowerPak. A simple modification to the NES allows the expansion audio to be mixed with its output.

Specifications:
- PRG size: 8 MB
- CHR size: 8 MB
- Battery RAM: 256 KB
- ARM I/O co-processor for SD and USB acceleration

NES product: https://krikzz.com/our-products/cartridges/everdrive-n8-pro-72pin.html

Famicom product: https://krikzz.com/our-products/cartridges/n8-pro-fami.html

## Mapper compatibility

As of the OS update v2.14 in 2022, the Everdrive N8 Pro supports the following 204 mappers: [2]

| 000 | 001 | 002 | 003 | 004 | 005 | 006 | 007 | 008 | 009 | 010 | 011 | 012 | 013 | 014 | 015 |
| 016 | 017 | 018 | 019 | 020 | 021 | 022 | 023 | 024 | 025 | 026 | 027 | 028 | 029 | 030 | 031 |
| 032 | 033 | 034 | 035 | 036 | 037 | 038 | 039 | 040 | 041 | 042 | 043 | 044 | 045 | 046 | 047 |
| 048 | 049 | 050 | 051 | 052 | 053 | 054 | 055 | 056 | 057 | 058 | 059 | 060 | 061 | 062 | 063 |
| 064 | 065 | 066 | 067 | 068 | 069 | 070 | 071 | 072 | 073 | 074 | 075 | 076 | 077 | 078 | 079 |
| 080 | 081 | 082 | 083 | 084 | 085 | 086 | 087 | 088 | 089 | 090 | 091 | 092 | 093 | 094 | 095 |
| 096 | 097 | 098 | 099 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | 108 | 109 | 110 | 111 |
| 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119 | 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
| 128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 | 139 | 140 | 141 | 142 | 143 |
| 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 |
| 160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 |
| 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 |
| 192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 | 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 |
| 208 | 209 | 210 | 211 | 212 | 213 | 214 | 215 | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 |
| 224 | 225 | 226 | 227 | 228 | 229 | 230 | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 |
| 240 | 241 | 242 | 243 | 244 | 245 | 246 | 247 | 248 | 249 | 250 | 251 | 252 | 253 | 254 | 255 |

Matrix Legend:

| supported | unsupported |

## Everdrive development resources
- Software tools and example mapper source code: https://github.com/krikzz/EDN8-PRO
- ED-Link build for USB connection: https://krikzz.com/pub/support/everdrive-n8/pro-series/usb-tool/
- Lastest OS firmware: https://krikzz.com/pub/support/everdrive-n8/pro-series/OS/
- User manual: https://krikzz.com/pub/support/everdrive-n8/pro-series/n8-pro-manual.pdf

# Family BASIC Data Recorder

Source: https://www.nesdev.org/wiki/Family_BASIC_Data_Recorder

The Family BASIC Data Recorder (HVC-008) is a device manufactured by Matsushita/Panasonic for Nintendo and was released sometime in 1984 only in Japan. The device serves as an addition to the Family BASIC Keyboardto read and write data from BASIC programs created by users. Several Famicom titles also used it to save its own data. The device itself can be substituted with any compact cassette player device or other audio capable devices that plug into the 3.5mm monaural phone jacks.

Example Titles:
- Family BASIC
- Family BASIC V3
- Arkanoid II
- Castle Excellent
- Excitebike
- Lode Runner
- Mach Rider
- Wrecking Crew

## Hardware interface

The Family BASIC Keyboardprovides two ⅛" (3.5mm) monaural phone jacks which can be plugged into the data recorder. Other expansion portdevices may also provide this interface (e.g. Hori SD Station, ASCII Stick II Turbo, etc.). This circuitwill provide the same interface on the NES.

### Input ($4016 write)

```text
7  bit  0
---- ----
xxxx xExS
      | |
      | +- 1-bit DAC audio to audio cassette
      +--- When 0, force audio readback to always read as binary 0 (5V)

```

The audio to the cassette recorder goes through a first-order highpass at 100Hz and is attenuated to 5mVPP at the input to the recorder.

### Output ($4016 read)

```text
7  bit  0
---- ----
xxxx xxAx
       |
       +-- 1-bit ADC audio from audio cassette

```

Because of how magnetic tape works, playing back the tape will produce a signal that is the lowpassed derivative of the original. Then this audio from the cassette recorder goes through a highpass with corner frequency of 800Hz before being discretized. In simulation, square waves of frequency 600 Hz up to the bandwidth of the tape appear to be recovered by this processing.

For an emulator, just play back the same bit stream as it was emitted.

## Software

It is not known whether Family BASIC uses Kansas City Standardencoding, Bell 103or 202, or some other arbitrary home-grown convention for encoding the audio on the tape. Castle Excellent's recorder handling code mostly exists between $8000 and $80FE, and provides save games using the 1200 baud ('CUTS') and bit-reversed variant of Kansas City Standard. Wrecking Crew uses the tape formatfrom the Sharp MZpersonal computer.

For homebrew use, Chris Covell wrote a set of KCS -generatingand -decodingroutines, which could easily be adapted to work with the data recorder.

## References

Reverse-engineered schematics by Enri:
- http://cmpslv3.stars.ne.jp/Famic/Fambas.htm
- Also available hereand here
- ccovell identified Wrecking Crew's encoding

# Fukutake Study Box

Source: https://www.nesdev.org/wiki/Fukutake_Study_Box

The Study Box is a tape drive/RAM cartridge combination from Fukutake Shoten. Games were loaded off standard stereo audio cassettes. One channel contains game audio, the other encoded game data.

The StudyBox file formatholds the content of such tapes. Mesen and NintendulatorNRS fully emulate the device.

See also:
- http://cah4e3.shedevr.org.ru/dumping_2005.php
- https://github.com/TASEmulators/fceux/blob/master/src/boards/186.cpp
- https://tcrf.net/StudyBox
- https://github.com/SourMesen/Mesen/files/2920256/studybox.org.txt

# Turbo File

Source: https://www.nesdev.org/wiki/Turbo_File

The Turbo File (for Family Computer) is a Famicom expansion portperipheral developed by ASCII Corporation, and is used to store save data for certain games. Variants of the device were also produced for the Game Boy (Turbo File GB), Game Boy Advance (Turbo File Advance), and Super Famicom (Turbo File Twin). Original Famicom Turbo File devices can be connected to a Super Famicom using an adapter unit, allowing certain SFC games to use the device in lieu of the TFTwin.

The device exists in two iterations:
- The original model (AS-TFO2) containing 8K of battery-backed SRAM. This has two variants which connect to either the Famicom expansion port or the ASCII Stick II Turbo's "OPTION" port.
- The Turbo File II (AS-TF21) containing 32K of battery-backed SRAM (HM62256ALP-15), which is split into four 8K banks that can be manually switched to allow for four individual game saves.
  - The TFII also includes a proprietary cartridge slot which accepts "データROM" (Data ROM) packs that can add extra functionality to supported titles. Data ROM packs have a switch that changes between either accessing the contents of the ROM (in which case the bank select switch is used to move between four 8K ROM banks) or the TFII's save RAM.

Both devices have an LED that illuminates when connected to a Famicom that is powered on, as well as a write protect switch to prevent accidentally overwriting save data.

## Supported titles

Famicom games that support the Turbo File include:
- Best Keiba - Derby Stallion (1991)
- Best Play Pro Yakyuu (1988)
- Best Play Pro Yakyuu '90 (1990)
- Best Play Pro Yakyuu II (1990)
- Best Play Pro Yakyuu Shin Data (1988)
- Best Play Pro Yakyuu Special (1992)
- Castle Excellent (1986)
- Derby Stallion - Zenkoku Ban (1992)
- Downtown - Nekketsu Monogatari (1989)
- Dungeon Kid (1990)
- Famicom Shougi - Ryuuousen (1991)
- Fleet Commander (1988)
- Haja no Fuuin (1987)
- Itadaki Street - Watashi no Mise ni Yottette (1990)
- The Money Game 2 - Kabutochou no Kiseki (1989)
- Ninjara Hoi! (1990)
- Wizardry - Legacy of Llylgamyn (1989)
- Wizardry - Proving Grounds of the Mad Overlord (1987)
- Wizardry - The Knight of Diamonds (1991)

Most titles bear a "TF" logo on the cartridge label signifying their compatibility.

Games that are believed to potentially work with the device (but remain unconfirmed) include:
- Castlequest (1989) (US version of Castle Excellent .)
- Kunio 8-in-1 (Pirate multicart that contains Downtown - Nekketsu Monogatari listed as "HEROS STORY" in the selection menu.)

## Hardware interface

TODO: Transcribe nocash's interface description into the standard wiki style.

## Memory Setup and File Format

The first byte of memory (offset 0000h) is unused, potentially out of fear that certain games with controller access might disrupt it, so a dummy byte is used to skip it after resetting the address. All the rest of the space (0001h-1FFFh) is used to store save data, with files being attached directly after each other. Invalid file IDs indicate the start of free memory.

The majority of Turbo File games utilize this format for save files:

```text
2   ID "AB" (41h,42h)
2   Filesize (16+N+2) (including title and checksum)
16  Title in ASCII (terminated by 00h or 01h)
N   Data Portion
2   Checksum (all N bytes in Data Portion added together)

```

The exception to this, Castle Excellent , uses a unique file format, shown here:

```text
1   Don't care (should be 00h)    ;fixed, at offset 0001h
2   ID AAh,55h                    ;fixed, at offset 0002h..0003h
508 Data Portion (Data, end code "BEDEUTUN", followed by some unused bytes)

```

This game also forgoes a filename and utilizes a hardcoded memory offset of 511 bytes (0001h-01FFh). Due to the hardcoded memory offset, Castle Excellent will destroy any other file that is located at the same address. Some later games for both the Famicom and Super Famicom (including Fleet Commander ) are able to properly manage the Castle Excellent save file.

## Reference
- nocash's NES documentation: https://problemkaputt.de/everynes.htm#storageturbofile
