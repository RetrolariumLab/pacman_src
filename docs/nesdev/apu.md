# apu

# APU

Source: https://www.nesdev.org/wiki/APU

The NES APU is the audio processing unit in the NES console which generates sound for games. It is implemented in the RP2A03 (NTSC) and RP2A07 (PAL) chips. Its registersare mapped in the range $4000–$4013, $4015 and $4017.

## Overview
For a simple subset of APU functionality oriented toward music engine developers rather than emulator developers, see APU basics.

The APU has five channels: two pulse wave generators, a triangle wave, noise, and a delta modulation channel for playing DPCM samples.

Each channel has a variable-rate timer clocking a waveform generator, and various modulators driven by low-frequency clocks from the frame counter. The DMCplays samples while the other channels play waveforms. Each sub-unit of a channel generally runs independently and in parallel to other units, and modification of a channel's parameter usually affects only one sub-unit and doesn't take effect until that unit's next internal cycle begins.

The read/write status registerallows channels to be enabled and disabled, and their current length counter statusto be queried.

The outputs from all the channels are combined using a non-linear mixingscheme.

### Conditions for channel output

The pulse, triangle, and noise channels will play their corresponding waveforms (at either a constant volume or at a volume controlled by an envelope) only when (and in the model given here, precisely when) their length countersare all non-zero (this includes the linear counter for the triangle channel). There are two exceptions for the pulse channels, which can also be silenced either by having a frequency above a certain threshold (see below), or by a sweeptowards lower frequencies (longer periods) reaching the end of the range.

The DMC channel always outputs the value of its counter, regardless of the status of the DMC enable bit; the enable bit only controls automatic playback of delta-encoded samples (which is done through counter updates).

### Notes
- This reference describes the abstract operation of the APU. The exact hardware implementation is not necessarily relevant to an emulator, but the Visual 2A03project can be used to determine detailed information about the hardware implementation.
- The Famicomhad an audio return loop on its cartridge connectorallowing extra audio from individual cartridges. See Expansion audiofor details on the audio produced by various mappers.
- For a basic usage guide to the APU, see APU basics, or Nerdy Nights: APU overview.
- The APU may have additional diagnostic features if CPU pin 30 is pulled high. See diagram by Quietust.

## Specification

### Registers
- See APU Registersfor a complete APU register diagram.

| Registers | Channel | Units |
| $4000–$4003 | Pulse 1 | Timer, length counter, envelope, sweep |
| $4004–$4007 | Pulse 2 | Timer, length counter, envelope, sweep |
| $4008–$400B | Triangle | Timer, length counter, linear counter |
| $400C–$400F | Noise | Timer, length counter, envelope, linear feedback shift register |
| $4010–$4013 | DMC | Timer, memory reader, sample buffer, output unit |
| $4015 | All | Channel enable and length counter status |
| $4017 | All | Frame counter |

### Pulse ($4000–$4007)
- See APU Pulse

The pulse channels produce a variable-width pulse signal, controlled by volume, envelope, length, and sweep units.

| $4000 / $4004 | DDLC VVVV | Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $4001 / $4005 | EPPP NSSS | Sweep unit: enabled (E), period (P), negate (N), shift (S) |
| $4002 / $4006 | TTTT TTTT | Timer low (T) |
| $4003 / $4007 | LLLL LTTT | Length counter load (L), timer high (T) |
- $4000 :
  - D : The width of the pulse is controlled by the duty bits in $4000/$4004. See APU Pulsefor details.
  - L : 1 = Infinite play, 0 = One-shot. If 1, the length counter will be frozen at its current value, and the envelope will repeat forever.
    - The length counter and envelope units are clocked by the frame counter.
    - If the length counter's current value is 0 the channel will be silenced whether or not this bit is set.
    - When using a one-shot envelope, the length counter should be loaded with a time longer than the length of the envelope to prevent it from being cut off early.
    - When looping, after reaching 0 the envelope will restart at volume 15 at its next period.
  - C : If C is set the volume will be a constant. If clear, an envelope will be used, starting at volume 15 and lowering to 0 over time.
  - V : Sets the direct volume if constant, otherwise controls the rate which the envelope lowers.
- The frequency of the pulse channels is a division of the CPU Clock( f CPU ; 1.789773MHz NTSC, 1.662607MHz PAL). The output frequency ( f ) of the generator can be determined by the 11-bit period value ( t ) written to $4002–$4003/$4006–$4007. If t < 8, the corresponding pulse channel is silenced.
  - f = f CPU / (16 × ( t + 1))
  - t = ( f CPU / (16 × f )) − 1
- Writing to $4003/$4007 reloads the length counter, restarts the envelope, and resets the phase of the pulse generator. Because it resets phase, vibrato should only write the low timer register to avoid a phase reset click. At some pitches, particularly near A440, wide vibrato should normally be avoided (e.g. this flaw is heard throughout the Mega Man 2 ending).
- Registers $4001/$4005 control the sweep unit. Enabling the sweep causes the pitch to constantly rise or fall. When the frequency reaches the end of the generator's range of output, the channel is silenced. See APU Sweepfor details.
- The two pulse channels are combined in a nonlinear mix (see mixerbelow).

### Triangle ($4008–$400B)
- See APU Triangle

The triangle channel produces a quantized triangle wave. It has no volume control, but it has a length counter as well as a higher resolution linear counter control (called "linear" since it uses the 7-bit value written to $4008 directly instead of a lookup table like the length counter).

| $4008 | CRRR RRRR | Length counter halt / linear counter control (C), linear counter load (R) |
| $4009 | ---- ---- | Unused |
| $400A | TTTT TTTT | Timer low (T) |
| $400B | LLLL LTTT | Length counter load (L), timer high (T), set linear counter reload flag |
- The triangle wave has 32 steps that output a 4-bit value.
- C : This bit controls both the length counter and linear counter at the same time.
  - When set this will stop the length counter in the same way as for the pulse/noise channels.
  - When set it prevents the linear counter's internal reload flag from clearing, which effectively halts it if $400B is written after setting C .
  - The linear counter silences the channel after a specified time with a resolution of 240Hz in NTSC (see frame counterbelow).
  - Because both the length and linear counters are be enabled at the same time, whichever has a longer setting is redundant.
  - See APU Trianglefor more linear counter details.
- R : This reload value will be applied to the linear counter on the next frame counter tick, but only if its reload flag is set.
  - A write to $400B is needed to raise the reload flag.
  - After a frame counter tick applies the load value R , the reload flag will only be cleared if C is also clear, otherwise it will continually reload (i.e. halt).
- The pitch of the triangle channel is one octave below the pulse channels with an equivalent timer value (i.e. use the formula above but divide the resulting frequency by two).
- Silencing the triangle channel merely halts it. It will continue to output its last value rather than 0.
- There is no way to reset the triangle channel's phase.

### Noise ($400C–$400F)
- See APU Noise

The noise channel produces noise with a pseudo-random bit generator. It has a volume, envelope, and length counter like the pulse channels.

| $400C | --LC VVVV | Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $400D | ---- ---- | Unused |
| $400E | M--- PPPP | Noise mode (M), noise period (P) |
| $400F | LLLL L--- | Length counter load (L) |
- The frequency of the noise is determined by a 4-bit value in $400E, which loads a period from a lookup table (see APU Noise).
- If bit 7 of $400E is set, the period of the random bit generation is drastically shortened, producing a buzzing tone (e.g. the metallic ding during Solstice 's gameplay). The actual timbre produced depends on whatever bits happen to be in the generator when it is switched to periodic, and is somewhat random.

### DMC ($4010–$4013)
- See APU DMC

The delta modulation channel outputs a 7-bit PCM signal from a counter that can be driven by DPCM samples.

| $4010 | IL-- RRRR | IRQ enable (I), loop (L), frequency (R) |
| $4011 | -DDD DDDD | Load counter (D) |
| $4012 | AAAA AAAA | Sample address (A) |
| $4013 | LLLL LLLL | Sample length (L) |
- DPCM samples are stored as a stream of 1-bit deltas that control the 7-bit PCM counter that the channel outputs. A bit of 1 will increment the counter, 0 will decrement, and it will clamp rather than overflow if the 7-bit range is exceeded.
- DPCM samples may loop if the loop flag in $4010 is set, and the DMC may be used to generate an IRQ when the end of the sample is reached if its IRQ flag is set.
- The playback rate is controlled by register $4010 with a 4-bit frequency index value (see APU DMCfor frequency lookup tables).
- DPCM samples must begin in the memory range $C000–$FFFF at an address set by register $4012 (address = `%11AAAAAA AA000000 `).
- The length of the sample in bytes is set by register $4013 (length = `%LLLL LLLL0001 `).

#### Other Uses
- The $4011 register can be used to play PCM samples directly by setting the counter value at a high frequency. Because this requires intensive use of the CPU, when used in games all other gameplay is usually halted to facilitate this.
- Because of the APU's nonlinear mixing, a high value in the PCM counter reduces the volume of the triangle and noise channels. This is sometimes used to apply limited volume control to the triangle channel (e.g. Super Mario Bros. adjusts the counter between levels to accomplish this).
- The DMC's IRQ can be used as an IRQ-based timer when the mapperused does not have one available.

### Status ($4015)

The status register is used to enable and disable individual channels, control the DMC, and can read the status of length counters and APU interrupts.

| $4015 write | ---D NT21 | Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1) |
- Writing a zero to any of the channel enable bits (NT21) will silence that channel and halt its length counter.
- If the DMC bit is clear, the DMC bytes remaining will be set to 0 and the DMC will silence when it empties.
- If the DMC bit is set, the DMC sample will be restarted only if its bytes remaining is 0. If there are bits remaining in the 1-byte sample buffer, these will finish playing before the next sample is fetched.
- Writing to this register clears the DMC interrupt flag.
- Power-up and resethave the effect of writing $00, silencing all channels.

| $4015 read | IF-D NT21 | DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1) |
- N/T/2/1 will read as 1 if the corresponding length counter has not been halted through either expiring or a write of 0 to the corresponding bit. For the triangle channel, the status of the linear counter is irrelevant.
- D will read as 1 if the DMC bytes remaining is more than 0.
- Reading this register clears the frame interrupt flag (but not the DMC interrupt flag).
- If an interrupt flag was set at the same moment of the read, it will read back as 1 but it will not be cleared.
- This register is internal to the CPU and so the external CPU data bus is disconnected when reading it. Therefore the returned value cannot be seen by external devices and the value does not affect open bus.
- Bit 5 is open bus. Because the external bus is disconnected when reading $4015, the open bus value comes from the last cycle that did not read $4015.

### Frame Counter ($4017)
- See APU Frame Counter

| $4017 | MI-- ---- | Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I) |

The frame counter is controlled by register $4017, and it drives the envelope, sweep, and length units on the pulse, triangle and noise channels. It ticks approximately 4 times per frame (240Hz NTSC), and executes either a 4 or 5-step sequence, depending how it is configured. It may optionally issue an IRQon the last tick of the 4-step sequence.

The following diagram illustrates the two modes, selected by bit 7 of $4017:

```text
mode 0:    mode 1:       function
---------  -----------  -----------------------------
 - - - f    - - - - -    IRQ (if bit 6 is clear)
 - l - l    - l - - l    Length counter and sweep
 e e e e    e e e - e    Envelope and linear counter

```

Both the 4 and 5-step modes operate at the same rate, but because the 5-step mode has an extra step, the effective update rate for individual units is slower in that mode (total update taking ~60Hz vs ~48Hz in NTSC). Writing to $4017 resets the frame counter and the quarter/half frame triggers happen simultaneously, but only on "odd" cycles (and only after the first "even" cycle after the write occurs) – thus, it happens either 2 or 3 cycles after the write (i.e. on the 2nd or 3rd cycle of the next instruction). After 2 or 3 clock cycles (depending on when the write is performed), the timer is reset. Writing to $4017 with bit 7 set ($80) will immediately clock all of its controlled units at the beginning of the 5-step sequence; with bit 7 clear, only the sequence is reset without clocking any of its units.

Note that the frame counter is not exactly synchronized with the PPU NMI; it runs independently at a consistent rate which is approximately 240Hz (NTSC). Some games (e.g. The Legend of Zelda , Super Mario Bros. ) manually synchronize it by writing $C0 or $FF to $4017 once per frame.

#### Length Counter
- See APU Length Counter

The pulse, triangle, and noise channels each have their own length counter unit. It is clocked twice per sequence, and counts down to zero if enabled. When the length counter reaches zero, the channel is silenced. It is reloaded by writing a 5-bit value to the appropriate channel's length counter register, which will load a value from a lookup table. (See APU Length Counterfor the table.)

The triangle channel has an additional linear counter unit which is clocked four times per sequence (like the envelope of the other channels). It functions independently of the length counter, and will also silence the triangle channel when it reaches zero.

### Mixer
- See APU Mixer

The APU audio output signal comes from two separate components. The pulse channels are output on one pin, and the triangle/noise/DMC are output on another, after which they are combined. Each of these channels has its own nonlinear DAC. For details, see APU Mixer.

After combining the two output signals, the final signal may go through a lowpass and highpass filter. For instance, RF demodulation in televisions usually results in a strong lowpass. The NES' RCA output circuitry has a more mild lowpass filter.

## Glossary
- All APUchannels have some form of frequency control. The term frequency is used where larger register value(s) correspond with higher frequencies, and the term period is used where smaller register value(s) correspond with higher frequencies.
- In the block diagrams, a gate takes the input on the left and outputs it on the right, unless the control input on top tells the gate to ignore the input and always output 0.
- Some APUunits use one or more of the following building blocks:
  - A divider outputs a clock periodically. It contains a period reload value, P, and a counter, that starts at P. When the divider is clocked, if the counter is currently 0, it is reloaded with P and generates an output clock, otherwise the counter is decremented. In other words, the divider's period is P + 1.
  - A divider can also be forced to reload its counter immediately (counter = P), but this does not output a clock. Similarly, changing a divider's period reload value does not affect the counter. Some counters offer no way to force a reload, but setting P to 0at least synchronizes it to a known state once the current count expires.
  - A divider may be implemented as a down counter (5, 4, 3, …) or as a linear feedback shift register(LFSR). The dividers in the pulse and triangle channels are linear down-counters. The dividers for noise, DMC, and the APU Frame Counter are implemented as LFSRs to save gates compared to the equivalent down counter.
  - A sequencer continuously loops over a sequence of values or events. When clocked, the next item in the sequence is generated. In this APU documentation, clocking a sequencer usually means either advancing to the next step in a waveform, or the event sequence of the Frame Counterdevice.
  - A timer is used in each of the five channels to control the sound frequency. It contains a divider which is clocked by the CPUclock. The triangle channel's timer is clocked on every CPU cycle, but the pulse, noise, and DMC timers are clocked only on every second CPU cycle and thus produce only even periods.

## References
- Blargg's NES APU Reference
- Brad Taylor's 2A03 Technical Reference

# APU DMC

Source: https://www.nesdev.org/wiki/APU_DMC

The NES APU'sdelta modulation channel (DMC) can output 1-bit delta-encoded samplesor can have its 7-bit counter directly loaded, allowing flexible manual sample playback.

## Overview

The DMC channel contains the following: memory reader, interrupt flag, sample buffer, timer, output unit, 7-bit output level with up and down counter.

```text
                         Timer
                           |
                           v
Reader ---> Buffer ---> Shifter ---> Output level ---> (to the mixer)

```

| $4010 | IL--.RRRR | Flags and Rate (write) |
| bit 7 | I---.---- | IRQ enabled flag. If clear, the interrupt flag is cleared. |
| bit 6 | -L--.---- | Loop flag |

```text

```

| bits 3-0 | ----.RRRR | Rate index Rate $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $A $B $C $D $E $F ------------------------------------------------------------------------------ NTSC 428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54 PAL 398, 354, 316, 298, 276, 236, 210, 198, 176, 148, 132, 118, 98, 78, 66, 50 The rate determines for how many CPU cycles happen between changes in the output level during automatic delta-encoded sample playback. For example, on NTSC (1.789773 MHz), a rate of 428 gives a frequency of 1789773/428 Hz = 4181.71 Hz. These periods are all even numbers because there are 2 CPU cycles in an APU cycle. A rate of 428 means the output level changes every 214 APU cycles. |
|  |
| $4011 | -DDD.DDDD | Direct load (write) |
| bits 6-0 | -DDD.DDDD | The DMC output level is set to D, an unsigned value. If the timer is outputting a clock at the same time, the output level is occasionally not changed properly.[1] |
|  |
| $4012 | AAAA.AAAA | Sample address (write) |
| bits 7-0 | AAAA.AAAA | Sample address = %11AAAAAA.AA000000 = $C000 + (A * 64) |
|  |
| $4013 | LLLL.LLLL | Sample length (write) |
| bits 7-0 | LLLL.LLLL | Sample length = %LLLL.LLLL0001 = (L * 16) + 1 bytes |

The output level is sent to the mixerwhether the channel is enabled or not. It is loaded with 0 on power-up, and can be updated by $4011 writes and delta-encoded sample playback.

Automatic 1-bit delta-encoded sampleplayback is carried out by a combination of three units. The memory reader fills the 8-bit sample buffer whenever it is emptied by the sample output unit . The status registeris used to start and stop automatic sample playback.

The sample buffer either holds a single 8-bit sample byte or is empty. It is filled by the reader and can only be emptied by the output unit; once loaded with a sample byte it will be played back.

### Pitch table

|  | NTSC | PAL |
| $4010 | Period | Frequency | Note (raw) | Note (1-byte loop) | Note (17-byte loop) | Note (33-byte loop) | Period | Frequency | Note (raw) | Note (1-byte loop) | Note (17-byte loop) | Note (33-byte loop) |
| $0 | $1AC | 4181.71 Hz | C-8 -2c | C-5 -2c | B-0 -7c | infrasound | $18E | 4177.40 Hz | C-8 -4c | C-5 -4c | B-0 -9c | infrasound |
| $1 | $17C | 4709.93 Hz | D-8 +4c | D-5 +4c | C#1 -1c | infrasound | $162 | 4696.63 Hz | D-8 -1c | D-5 -1c | C#1 -6c | infrasound |
| $2 | $154 | 5264.04 Hz | E-8 -3c | E-5 -3c | Eb1 -8c | infrasound | $13C | 5261.41 Hz | E-8 -4c | E-5 -4c | Eb1 -9c | infrasound |
| $3 | $140 | 5593.04 Hz | F-8 +2c | F-5 +2c | E-1 -3c | E-0 +48c | $12A | 5579.22 Hz | F-8 -3c | F-5 -3c | E-1 -8c | E-0 +44c |
| $4 | $11E | 6257.95 Hz | G-8 -4c | G-5 -4c | F#1 -9c | F#0 +43c | $114 | 6023.94 Hz | G-8 -70c | G-5 -70c | F#1 -75c | F#0 -23c |
| $5 | $0FE | 7046.35 Hz | A-8 +2c | A-5 +2c | Ab1 -3c | Ab0 +48c | $0EC | 7044.94 Hz | A-8 +1c | A-5 +1c | Ab1 -4c | Ab0 +48c |
| $6 | $0E2 | 7919.35 Hz | B-8 +4c | B-5 +4c | Bb1 -1c | Bb0 +50c | $0D2 | 7917.18 Hz | B-8 +3c | B-5 +3c | Bb1 -2c | Bb0 +50c |
| $7 | $0D6 | 8363.42 Hz | C-9 -2c | C-6 -2c | B-1 -7c | B-0 +45c | $0C6 | 8397.01 Hz | C-9 +5c | C-6 +5c | B-1 +0c | B-0 +52c |
| $8 | $0BE | 9419.86 Hz | D-9 +4c | D-6 +4c | C#2 -1c | C#1 +51c | $0B0 | 9446.63 Hz | D-9 +9c | D-9 +9c | C#2 +4c | C#1 +56c |
| $9 | $0A0 | 11186.1 Hz | F-9 +2c | F-6 +2c | E-2 -3c | E-1 +48c | $094 | 11233.8 Hz | F-9 +9c | F-6 +9c | E-2 +4c | E-1 +56c |
| $A | $08E | 12604.0 Hz | G-9 +8c | G-6 +8c | F#2 +3c | F#1 +55c | $084 | 12595.5 Hz | G-9 +7c | G-6 +7c | F#2 -2c | G-1 +54c |
| $B | $080 | 13982.6 Hz | A-9 -12c | A-6 -12c | Ab2 -17c | Ab1 +35c | $076 | 14089.9 Hz | A-9 +1c | A-6 +1c | Ab2 -4c | Ab1 +48c |
| $C | $06A | 16884.6 Hz | C-10 +14c | C-7 +14c | B-2 +10c | B-1 +61c | $062 | 16965.4 Hz | C-10 +23c | C-7 +23c | B-2 +18c | B-1 +69c |
| $D | $054 | 21306.8 Hz | E-10 +17c | E-7 +17c | Eb3 +12c | Eb2 +64c | $04E | 21315.5 Hz | E-10 +18c | E-7 +18c | Eb3 +13c | Eb2 +65c |
| $E | $048 | 24858.0 Hz | G-10 -16c | G-7 -16c | F#3 -21c | F#2 +31c | $042 | 25191.0 Hz | G-10 +7c | G-7 +7c | F#3 +2c | F#2 +54c |
| $F | $036 | 33143.9 Hz | C-11 -18c | C-8 -18c | B-3 -23c | B-2 +29c | $032 | 33252.1 Hz | C-11 -12c | C-8 -12c | B-3 -17c | B-2 +34c |

(Deviation from note is given in cents, which are defined as 1/100th of a semitone.)

Note that on PAL systems, the pitches at $4 and $C appear to be incorrect with respect to their intended A-440 tuning scheme [1].

### Memory reader

When the sample buffer is emptied, the memory reader fills the sample buffer with the next byte from the currently playing sample. It has an address counter and a bytes remaining counter.

When a sample is (re)started, the current address is set to the sample address, and bytes remaining is set to the sample length.

Any time the sample buffer is in an empty state and bytes remaining is not zero (including just after a write to $4015 that enables the channel, regardless of where that write occurs relative to the bit counter mentioned below), the following occur:
- The CPUis stalled for 1-4 CPU cycles to read a sample byte. The exact cycle count depends on many factors and is described in detail in the DMAarticle.
- The sample buffer is filled with the next sample byte read from the current address, subject to whatever mapping hardwareis present.
- The address is incremented; if it exceeds $FFFF, it is wrapped around to $8000.
- The bytes remaining counter is decremented; if it becomes zero and the loop flag is set, the sample is restarted (see above); otherwise, if the bytes remaining counter becomes zero and the IRQ enabled flag is set, the interrupt flag is set.

At any time, if the interrupt flag is set, the CPU's IRQ lineis continuously asserted until the interrupt flag is cleared. The processor will continue on from where it was stalled.

### Output unit

The output unit continuously outputs a 7-bit value to the mixer. It contains an 8-bit right shift register, a bits-remaining counter, a 7-bit output level (the same one that can be loaded directly via $4011), and a silence flag.

The bits-remaining counter is updated whenever the timeroutputs a clock, regardless of whether a sample is currently playing. When this counter reaches zero, we say that the output cycle ends. The DPCM unit can only transition from silent to playing at the end of an output cycle.

When an output cycle ends, a new cycle is started as follows:
- The bits-remaining counter is loaded with 8.
- If the sample buffer is empty, then the silence flag is set; otherwise, the silence flag is cleared and the sample buffer is emptied into the shift register.

When the timer outputs a clock, the following actions occur in order:
- If the silence flag is clear, the output level changes based on bit 0 of the shift register. If the bit is 1, add 2; otherwise, subtract 2. But if adding or subtracting 2 would cause the output level to leave the 0-127 range, leave the output level unchanged. This means subtract 2 only if the current level is at least 2, or add 2 only if the current level is at most 125.
- The right shift register is clocked.
- As stated above, the bits-remaining counter is decremented. If it becomes zero, a new output cycle is started.

Nothing can interrupt a cycle; every cycle runs to completion before a new cycle is started.

## Conflict with controller and PPU read

On the 2A03 CPU used in the NTSC NES and Famicom, if a new sample byte is fetched from memory at the same time the program is reading a register that has read side effects (such as controllers via $4016 or $4017, PPU data via $2007, or the vblank flag via $2002), that register will see multiple extra reads that result in data loss or corruption. This is mostly a problem for controllers, and special controller reading codeis necessary to work around this.

This problem is fixed on the 2A07 series of PAL CPUs by forcing DMA to halt on the first cycle of an instruction, which fetches an instruction opcode and thus isn't normally reading from registers.

See DMAfor a thorough explanation of how DMA works and how it conflicts with register reads.

## Usage of DMC for syncing to video

DMC IRQs can be used for timed video operations. The following method was discussed on the forum in 2010. [2]

### Concept

The NES hardware only has limited tools for syncing the code with video rendering. The VBlank NMI and sprite 0 hit are the only two reasonably reliable flags that can be used, so only 2 synchronizations per frame can be done easily. In addition, only the VBlank NMI can trigger an interrupt; the sprite 0 hit flag has to be polled, potentially wasting a lot of CPU cycles.

However, the DMC channel can hypothetically be used for syncing with video instead of using it for sound. Unfortunately it's a bit complicated, but used correctly, it can function as a crude scanline counter, eliminating the need for an advanced mapper.

The DMC's timing is completely separate from the video. The DMC's timer is always running, and samples can only start every 8 clock cycles. However, because the DMC's timer isn't synchronized to the PPU in any way, these 8-clock boundaries occur on different scanlines each frame.

Here are the steps to achieve stable timing:
- At a fixed point in video rendering (we'll use the start of vblank as an example), a dummy single-byte sample at rate $F is started. Due to a hardware quirk†, the sample needs to be started three times in a row like this:

```text
sei
lda #$10
sta $4015
sta $4015
sta $4015
cli

```
- The amount of cycles before a DMC IRQ happens is then measured (either using an actual IRQ, or by polling $4015).
  - At rate $F, there are 54 CPU cycles between clocks, so there are 432 CPU cycles (432 × 3 ÷ 341 = about 3.8 scanlines) between boundaries.
- The main sample that will be used for the timing is then started (please refer to the table below to have sample lengths for various waiting times)
- When the main IRQ happens, the measurement from before is retrieved, and a timing loop with variable delay is used. In order to synchronize with vblank, after a DMC IRQ we should wait 432 CPU cycles minus the time we measured.

† Note: The hardware quirk mentioned above deals with how DMC IRQs are generated. Basically, the IRQ is generated when the last byte of the sample is read , not when the last sample of the sample plays . The sample buffer sometimes has enough time to empty itself between writes to $4015, meaning your next write to $4015 will trigger an immediate IRQ. Fortunately, writing to $4015 three times will avoid this issue.

Still using vblank as an example, the measurement tells how far into the 8-clock boundary vblank occurred, and by delaying after a DMC IRQ, we perform a raster effect at the same point within the 8-clock boundary, aligning it with vblank. By performing this same method each frame, the raster effect will have a reasonably stable timing to it. As a bonus, since mostly using IRQs are being used, the CPU is free to do something else, instead of waiting in a timed loop.

It's possible to use more than one IRQ per frame - but the measurement part needs to be done at the same time within each frame, before the usage of any IRQ.

Only a single split-point per IRQ is possible, with the shortest IRQ being 3.8 scanlines. For split points closer than this amount, timed code has to be used.

In order to remain silent, samples should be made up of all $00 bytes, and $00 should have been previously written to $4011. Otherwise, audio will unintentionally be created. This is a sound channel, after all.

### Timing table

This table converts sample length in scanline length (all values are rounded to the higher integer).

```text
NTSC               Rate
Length              $0    $1   $2   $3   $4   $5   $6   $7   $8   $9   $a   $b   $c   $d   $e   $f
----------------------------------------------------------------------------------------------------
1-byte (8 bits)     31    27   24   23   21   18   16   16   14   12   10   10   8    6    6    4
17-byte (136 bits)  **    **   **   **   **   **   **   **   228  192  170  154  127  101  87   65
33-byte (264 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   196  168  126
49-byte (392 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   **   **   187

PAL                Rate
Length              $0    $1   $2   $3   $4   $5   $6   $7   $8   $9   $a   $b   $c   $d   $e   $f
----------------------------------------------------------------------------------------------------
1-byte (8 bits)     30    27   24   23   21   18   16   15   14   12   10   9    8    6    5    4
17-byte (136 bits)  **    **   **   **   **   **   **   **   225  189  169  151  126  100  85   64
33-byte (264 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   194  164  124
49-byte (392 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   **   **   184

```

### Number of scanlines to wait table

This table gives the best sample length and frequency combinations for all possible scanlines interval to wait. They are best because they are where the CPU will have to kill the least time. However, it's still possible to use options to wait for fewer lines and kill more time during the interrupt before the video effect.

Because a PAL interrupt will always happen about the same time or a bit sooner than a NTSC interrupt, the NTSC table will be used to set the "best" setting here :

```text
Scanlines  Best opt. for IRQ

1-3        Timed code
4-5        Length $0, rate $f
6-7        Length $0, rate $d
8-9        Length $0, rate $c
10-11      Length $0, rate $a
12-13      Length $0, rate $9
14-15      Length $0, rate $8
16-17      Length $0, rate $6
18-20      Length $0, rate $5
21-22      Length $0, rate $4
23         Length $0, rate $3
24-26      Length $0, rate $2
27-30      Length $0, rate $1
31-64      Length $0, rate $0
65-86      Length $1, rate $f
87-100     Length $1, rate $e
101-125    Length $1, rate $d
126        Length $2, rate $f
127-153    Length $1, rate $c
154-167    Length $1, rate $b
168-169    Length $2, rate $e
170-186    Length $1, rate $a
187-191    Length $3, rate $f
192-195    Length $1, rate $9
196-227    Length $2, rate $d
228-239    Length $1, rate $8

```

## References
- ↑Forum post: PAL DPCM frequency table contains 2 errors.
- ↑Forum thread: DMC IRQ as a video timer.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU Envelope

Source: https://www.nesdev.org/wiki/APU_Envelope

In a synthesizer, an envelopeis the way a sound's parameter changes over time. The NES APUhas an envelope generator that controls the volume in one of two ways: it can generate a decreasing saw envelope (like a decay phase of an ADSR) with optional looping, or it can generate a constant volume that a more sophisticated software envelope generator can manipulate. Volume values are practically linear (see: APU Mixer).

Each volume envelope unit contains the following: start flag, divider, and decay level counter.

```text
                                   Loop flag
                                        |
               Start flag  +--------.   |   Constant volume
                           |        |   |        flag
                           v        v   v          |
Quarter frame clock --> Divider --> Decay --> |    |
                           ^        level     |    v
                           |                  | Select --> Envelope output
                           |                  |
        Envelope parameter +----------------> |

```

| Address | Bitfield | Description |
| $4000 | ddLC.VVVV | Pulse channel 1 duty and volume/envelope (write) |
| $4004 | ddLC.VVVV | Pulse channel 2 duty and volume/envelope (write) |
| $400C | --LC.VVVV | Noise channel volume/envelope (write) |
| bit 5 | --L- ---- | APU Length Counter halt flag/envelope loop flag |
| bit 4 | ---C ---- | Constant volume flag (0: use volume from envelope; 1: use constant volume) |
| bits 3-0 | ---- VVVV | Used as the volume in constant volume (C set) mode. Also used as the reload value for the envelope's divider (the period becomes V + 1 quarter frames). |
|  |
| $4003 | LLLL.Lttt | Pulse channel 1 length counter load and timer (write) |
| $4007 | LLLL.Lttt | Pulse channel 2 length counter load and timer (write) |
| $400F | LLLL.L--- | Noise channel length counter load (write) |
| Side effects | Sets start flag |

When clocked by the frame counter, one of two actions occurs: if the start flag is clear, the divider is clocked, otherwise the start flag is cleared, the decay level counter is loaded with 15, and the divider's period is immediately reloaded.

When the divider is clocked while at 0, it is loaded with V and clocks the decay level counter. Then one of two actions occurs: If the counter is non-zero, it is decremented, otherwise if the loop flag is set, the decay level counter is loaded with 15.

The envelope unit's volume output depends on the constant volume flag: if set, the envelope parameter directly sets the volume, otherwise the decay level is the current volume. The constant volume flag has no effect besides selecting the volume source; the decay level will still be updated when constant volume is selected.

Each of the three envelope units' output is fed through additional gates at the sweep unit(pulse only), waveform generator ( sequenceror LFSR), and length counter.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU Length Counter

Source: https://www.nesdev.org/wiki/APU_Length_Counter

The length counter provides automatic duration control for the NES APUwaveform channels. Once loaded with a value, it can optionally count down (when the length counter halt flag is clear). Once it reaches zero, the corresponding channel is silenced.

| Address | Bitfield | Description |
| $4015 | ---d.nt21 | DMC control and length counter enabled flags (write) |
|  |
| $4000 | ssHc.vvvv | Pulse channel 1 duty cycle, length counter halt, constant volume flag, and volume/envelope (write) |
| $4004 | ssHc.vvvv | Pulse channel 2 duty cycle, length counter halt, constant volume flag, and volume/envelope (write) |
| $400C | --Hc.vvvv | Noise channel length counter halt, constant volume flag, and volume/envelope (write) |
| bit 5 | --H- ---- | Halt length counter (this bit is also the envelope's loop flag) |
|  |
| $4008 | Hlll.llll | Triangle channel length counter halt and linear counter load (write) |
| bit 7 | H--- ---- | Halt length counter (this bit is also the linear counter's control flag) |
|  |
| $4003 | LLLL.Lttt | Pulse channel 1 length counter load and timer (write) |
| $4007 | LLLL.Lttt | Pulse channel 2 length counter load and timer (write) |
| $400B | LLLL.Lttt | Triangle channel length counter load and timer (write) |
| $400F | LLLL.L--- | Noise channel length counter load (write) |

```text

```
| bits 7-3 | LLLL L--- | If the enabled flag is set, the length counter is loaded with entry L of the length table: | 0 1 2 3 4 5 6 7 8 9 A B C D E F -----+---------------------------------------------------------------- 00-0F 10,254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14, 10-1F 12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30 |
| Side effects | The envelope is restarted, for pulse channels phase is reset, for triangle the linear counter reload flag is set. |

## Clocking

When the enabledbit is cleared (via $4015 ), the length counter is forced to 0 and cannot be changed until enabled is set again (the length counter's previous value is lost). There is no immediate effect when enabled is set.

When clocked by the frame counter, the length counter is decremented except when:
- The length counter is 0, or
- The halt flag is set

## Table structure

The structure of the length table becomes clearer when rearranged like in the following index to length map (which corresponds to the order in which the values appear in the internal APU lookup table):

```text
Legend:
<bit pattern> (<value of bit pattern>) => <note length>

Linear length values:
1 1111 (1F) => 30
1 1101 (1D) => 28
1 1011 (1B) => 26
1 1001 (19) => 24
1 0111 (17) => 22
1 0101 (15) => 20
1 0011 (13) => 18
1 0001 (11) => 16
0 1111 (0F) => 14
0 1101 (0D) => 12
0 1011 (0B) => 10
0 1001 (09) => 8
0 0111 (07) => 6
0 0101 (05) => 4
0 0011 (03) => 2
0 0001 (01) => 254

Notes with base length 12 (4/4 at 75 bpm):
1 1110 (1E) => 32  (96 times 1/3, quarter note triplet)
1 1100 (1C) => 16  (48 times 1/3, eighth note triplet)
1 1010 (1A) => 72  (48 times 1 1/2, dotted quarter)
1 1000 (18) => 192 (Whole note)
1 0110 (16) => 96  (Half note)
1 0100 (14) => 48  (Quarter note)
1 0010 (12) => 24  (Eighth note)
1 0000 (10) => 12  (Sixteenth)

Notes with base length 10 (4/4 at 90 bpm, with relative durations being the same as above):
0 1110 (0E) => 26  (Approx. 80 times 1/3, quarter note triplet)
0 1100 (0C) => 14  (Approx. 40 times 1/3, eighth note triplet)
0 1010 (0A) => 60  (40 times 1 1/2, dotted quarter)
0 1000 (08) => 160 (Whole note)
0 0110 (06) => 80  (Half note)
0 0100 (04) => 40  (Quarter note)
0 0010 (02) => 20  (Eighth note)
0 0000 (00) => 10  (Sixteenth)

```

With the least significant bit set, the remaining bits select a linear length (with the exception of the 0 entry). Otherwise, we get note lengths based on a base length of 10 (MSB clear) or 12 (MSB set).

## Length counter internals

In the actual APU, the length counter silences the channel when clocked while already zero (provided the length counter halt flag isn't set). The values in the above table are the actual values the length counter gets loaded with plus one , to allow us to use a model where the channel is silenced when the length counter becomes zero.

The triangle's linear counter works differently, and does silence the channel when it reaches zero.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU

Source: https://www.nesdev.org/wiki/APU_Misc

The NES APU is the audio processing unit in the NES console which generates sound for games. It is implemented in the RP2A03 (NTSC) and RP2A07 (PAL) chips. Its registersare mapped in the range $4000–$4013, $4015 and $4017.

## Overview
For a simple subset of APU functionality oriented toward music engine developers rather than emulator developers, see APU basics.

The APU has five channels: two pulse wave generators, a triangle wave, noise, and a delta modulation channel for playing DPCM samples.

Each channel has a variable-rate timer clocking a waveform generator, and various modulators driven by low-frequency clocks from the frame counter. The DMCplays samples while the other channels play waveforms. Each sub-unit of a channel generally runs independently and in parallel to other units, and modification of a channel's parameter usually affects only one sub-unit and doesn't take effect until that unit's next internal cycle begins.

The read/write status registerallows channels to be enabled and disabled, and their current length counter statusto be queried.

The outputs from all the channels are combined using a non-linear mixingscheme.

### Conditions for channel output

The pulse, triangle, and noise channels will play their corresponding waveforms (at either a constant volume or at a volume controlled by an envelope) only when (and in the model given here, precisely when) their length countersare all non-zero (this includes the linear counter for the triangle channel). There are two exceptions for the pulse channels, which can also be silenced either by having a frequency above a certain threshold (see below), or by a sweeptowards lower frequencies (longer periods) reaching the end of the range.

The DMC channel always outputs the value of its counter, regardless of the status of the DMC enable bit; the enable bit only controls automatic playback of delta-encoded samples (which is done through counter updates).

### Notes
- This reference describes the abstract operation of the APU. The exact hardware implementation is not necessarily relevant to an emulator, but the Visual 2A03project can be used to determine detailed information about the hardware implementation.
- The Famicomhad an audio return loop on its cartridge connectorallowing extra audio from individual cartridges. See Expansion audiofor details on the audio produced by various mappers.
- For a basic usage guide to the APU, see APU basics, or Nerdy Nights: APU overview.
- The APU may have additional diagnostic features if CPU pin 30 is pulled high. See diagram by Quietust.

## Specification

### Registers
- See APU Registersfor a complete APU register diagram.

| Registers | Channel | Units |
| $4000–$4003 | Pulse 1 | Timer, length counter, envelope, sweep |
| $4004–$4007 | Pulse 2 | Timer, length counter, envelope, sweep |
| $4008–$400B | Triangle | Timer, length counter, linear counter |
| $400C–$400F | Noise | Timer, length counter, envelope, linear feedback shift register |
| $4010–$4013 | DMC | Timer, memory reader, sample buffer, output unit |
| $4015 | All | Channel enable and length counter status |
| $4017 | All | Frame counter |

### Pulse ($4000–$4007)
- See APU Pulse

The pulse channels produce a variable-width pulse signal, controlled by volume, envelope, length, and sweep units.

| $4000 / $4004 | DDLC VVVV | Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $4001 / $4005 | EPPP NSSS | Sweep unit: enabled (E), period (P), negate (N), shift (S) |
| $4002 / $4006 | TTTT TTTT | Timer low (T) |
| $4003 / $4007 | LLLL LTTT | Length counter load (L), timer high (T) |
- $4000 :
  - D : The width of the pulse is controlled by the duty bits in $4000/$4004. See APU Pulsefor details.
  - L : 1 = Infinite play, 0 = One-shot. If 1, the length counter will be frozen at its current value, and the envelope will repeat forever.
    - The length counter and envelope units are clocked by the frame counter.
    - If the length counter's current value is 0 the channel will be silenced whether or not this bit is set.
    - When using a one-shot envelope, the length counter should be loaded with a time longer than the length of the envelope to prevent it from being cut off early.
    - When looping, after reaching 0 the envelope will restart at volume 15 at its next period.
  - C : If C is set the volume will be a constant. If clear, an envelope will be used, starting at volume 15 and lowering to 0 over time.
  - V : Sets the direct volume if constant, otherwise controls the rate which the envelope lowers.
- The frequency of the pulse channels is a division of the CPU Clock( f CPU ; 1.789773MHz NTSC, 1.662607MHz PAL). The output frequency ( f ) of the generator can be determined by the 11-bit period value ( t ) written to $4002–$4003/$4006–$4007. If t < 8, the corresponding pulse channel is silenced.
  - f = f CPU / (16 × ( t + 1))
  - t = ( f CPU / (16 × f )) − 1
- Writing to $4003/$4007 reloads the length counter, restarts the envelope, and resets the phase of the pulse generator. Because it resets phase, vibrato should only write the low timer register to avoid a phase reset click. At some pitches, particularly near A440, wide vibrato should normally be avoided (e.g. this flaw is heard throughout the Mega Man 2 ending).
- Registers $4001/$4005 control the sweep unit. Enabling the sweep causes the pitch to constantly rise or fall. When the frequency reaches the end of the generator's range of output, the channel is silenced. See APU Sweepfor details.
- The two pulse channels are combined in a nonlinear mix (see mixerbelow).

### Triangle ($4008–$400B)
- See APU Triangle

The triangle channel produces a quantized triangle wave. It has no volume control, but it has a length counter as well as a higher resolution linear counter control (called "linear" since it uses the 7-bit value written to $4008 directly instead of a lookup table like the length counter).

| $4008 | CRRR RRRR | Length counter halt / linear counter control (C), linear counter load (R) |
| $4009 | ---- ---- | Unused |
| $400A | TTTT TTTT | Timer low (T) |
| $400B | LLLL LTTT | Length counter load (L), timer high (T), set linear counter reload flag |
- The triangle wave has 32 steps that output a 4-bit value.
- C : This bit controls both the length counter and linear counter at the same time.
  - When set this will stop the length counter in the same way as for the pulse/noise channels.
  - When set it prevents the linear counter's internal reload flag from clearing, which effectively halts it if $400B is written after setting C .
  - The linear counter silences the channel after a specified time with a resolution of 240Hz in NTSC (see frame counterbelow).
  - Because both the length and linear counters are be enabled at the same time, whichever has a longer setting is redundant.
  - See APU Trianglefor more linear counter details.
- R : This reload value will be applied to the linear counter on the next frame counter tick, but only if its reload flag is set.
  - A write to $400B is needed to raise the reload flag.
  - After a frame counter tick applies the load value R , the reload flag will only be cleared if C is also clear, otherwise it will continually reload (i.e. halt).
- The pitch of the triangle channel is one octave below the pulse channels with an equivalent timer value (i.e. use the formula above but divide the resulting frequency by two).
- Silencing the triangle channel merely halts it. It will continue to output its last value rather than 0.
- There is no way to reset the triangle channel's phase.

### Noise ($400C–$400F)
- See APU Noise

The noise channel produces noise with a pseudo-random bit generator. It has a volume, envelope, and length counter like the pulse channels.

| $400C | --LC VVVV | Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $400D | ---- ---- | Unused |
| $400E | M--- PPPP | Noise mode (M), noise period (P) |
| $400F | LLLL L--- | Length counter load (L) |
- The frequency of the noise is determined by a 4-bit value in $400E, which loads a period from a lookup table (see APU Noise).
- If bit 7 of $400E is set, the period of the random bit generation is drastically shortened, producing a buzzing tone (e.g. the metallic ding during Solstice 's gameplay). The actual timbre produced depends on whatever bits happen to be in the generator when it is switched to periodic, and is somewhat random.

### DMC ($4010–$4013)
- See APU DMC

The delta modulation channel outputs a 7-bit PCM signal from a counter that can be driven by DPCM samples.

| $4010 | IL-- RRRR | IRQ enable (I), loop (L), frequency (R) |
| $4011 | -DDD DDDD | Load counter (D) |
| $4012 | AAAA AAAA | Sample address (A) |
| $4013 | LLLL LLLL | Sample length (L) |
- DPCM samples are stored as a stream of 1-bit deltas that control the 7-bit PCM counter that the channel outputs. A bit of 1 will increment the counter, 0 will decrement, and it will clamp rather than overflow if the 7-bit range is exceeded.
- DPCM samples may loop if the loop flag in $4010 is set, and the DMC may be used to generate an IRQ when the end of the sample is reached if its IRQ flag is set.
- The playback rate is controlled by register $4010 with a 4-bit frequency index value (see APU DMCfor frequency lookup tables).
- DPCM samples must begin in the memory range $C000–$FFFF at an address set by register $4012 (address = `%11AAAAAA AA000000 `).
- The length of the sample in bytes is set by register $4013 (length = `%LLLL LLLL0001 `).

#### Other Uses
- The $4011 register can be used to play PCM samples directly by setting the counter value at a high frequency. Because this requires intensive use of the CPU, when used in games all other gameplay is usually halted to facilitate this.
- Because of the APU's nonlinear mixing, a high value in the PCM counter reduces the volume of the triangle and noise channels. This is sometimes used to apply limited volume control to the triangle channel (e.g. Super Mario Bros. adjusts the counter between levels to accomplish this).
- The DMC's IRQ can be used as an IRQ-based timer when the mapperused does not have one available.

### Status ($4015)

The status register is used to enable and disable individual channels, control the DMC, and can read the status of length counters and APU interrupts.

| $4015 write | ---D NT21 | Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1) |
- Writing a zero to any of the channel enable bits (NT21) will silence that channel and halt its length counter.
- If the DMC bit is clear, the DMC bytes remaining will be set to 0 and the DMC will silence when it empties.
- If the DMC bit is set, the DMC sample will be restarted only if its bytes remaining is 0. If there are bits remaining in the 1-byte sample buffer, these will finish playing before the next sample is fetched.
- Writing to this register clears the DMC interrupt flag.
- Power-up and resethave the effect of writing $00, silencing all channels.

| $4015 read | IF-D NT21 | DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1) |
- N/T/2/1 will read as 1 if the corresponding length counter has not been halted through either expiring or a write of 0 to the corresponding bit. For the triangle channel, the status of the linear counter is irrelevant.
- D will read as 1 if the DMC bytes remaining is more than 0.
- Reading this register clears the frame interrupt flag (but not the DMC interrupt flag).
- If an interrupt flag was set at the same moment of the read, it will read back as 1 but it will not be cleared.
- This register is internal to the CPU and so the external CPU data bus is disconnected when reading it. Therefore the returned value cannot be seen by external devices and the value does not affect open bus.
- Bit 5 is open bus. Because the external bus is disconnected when reading $4015, the open bus value comes from the last cycle that did not read $4015.

### Frame Counter ($4017)
- See APU Frame Counter

| $4017 | MI-- ---- | Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I) |

The frame counter is controlled by register $4017, and it drives the envelope, sweep, and length units on the pulse, triangle and noise channels. It ticks approximately 4 times per frame (240Hz NTSC), and executes either a 4 or 5-step sequence, depending how it is configured. It may optionally issue an IRQon the last tick of the 4-step sequence.

The following diagram illustrates the two modes, selected by bit 7 of $4017:

```text
mode 0:    mode 1:       function
---------  -----------  -----------------------------
 - - - f    - - - - -    IRQ (if bit 6 is clear)
 - l - l    - l - - l    Length counter and sweep
 e e e e    e e e - e    Envelope and linear counter

```

Both the 4 and 5-step modes operate at the same rate, but because the 5-step mode has an extra step, the effective update rate for individual units is slower in that mode (total update taking ~60Hz vs ~48Hz in NTSC). Writing to $4017 resets the frame counter and the quarter/half frame triggers happen simultaneously, but only on "odd" cycles (and only after the first "even" cycle after the write occurs) – thus, it happens either 2 or 3 cycles after the write (i.e. on the 2nd or 3rd cycle of the next instruction). After 2 or 3 clock cycles (depending on when the write is performed), the timer is reset. Writing to $4017 with bit 7 set ($80) will immediately clock all of its controlled units at the beginning of the 5-step sequence; with bit 7 clear, only the sequence is reset without clocking any of its units.

Note that the frame counter is not exactly synchronized with the PPU NMI; it runs independently at a consistent rate which is approximately 240Hz (NTSC). Some games (e.g. The Legend of Zelda , Super Mario Bros. ) manually synchronize it by writing $C0 or $FF to $4017 once per frame.

#### Length Counter
- See APU Length Counter

The pulse, triangle, and noise channels each have their own length counter unit. It is clocked twice per sequence, and counts down to zero if enabled. When the length counter reaches zero, the channel is silenced. It is reloaded by writing a 5-bit value to the appropriate channel's length counter register, which will load a value from a lookup table. (See APU Length Counterfor the table.)

The triangle channel has an additional linear counter unit which is clocked four times per sequence (like the envelope of the other channels). It functions independently of the length counter, and will also silence the triangle channel when it reaches zero.

### Mixer
- See APU Mixer

The APU audio output signal comes from two separate components. The pulse channels are output on one pin, and the triangle/noise/DMC are output on another, after which they are combined. Each of these channels has its own nonlinear DAC. For details, see APU Mixer.

After combining the two output signals, the final signal may go through a lowpass and highpass filter. For instance, RF demodulation in televisions usually results in a strong lowpass. The NES' RCA output circuitry has a more mild lowpass filter.

## Glossary
- All APUchannels have some form of frequency control. The term frequency is used where larger register value(s) correspond with higher frequencies, and the term period is used where smaller register value(s) correspond with higher frequencies.
- In the block diagrams, a gate takes the input on the left and outputs it on the right, unless the control input on top tells the gate to ignore the input and always output 0.
- Some APUunits use one or more of the following building blocks:
  - A divider outputs a clock periodically. It contains a period reload value, P, and a counter, that starts at P. When the divider is clocked, if the counter is currently 0, it is reloaded with P and generates an output clock, otherwise the counter is decremented. In other words, the divider's period is P + 1.
  - A divider can also be forced to reload its counter immediately (counter = P), but this does not output a clock. Similarly, changing a divider's period reload value does not affect the counter. Some counters offer no way to force a reload, but setting P to 0at least synchronizes it to a known state once the current count expires.
  - A divider may be implemented as a down counter (5, 4, 3, …) or as a linear feedback shift register(LFSR). The dividers in the pulse and triangle channels are linear down-counters. The dividers for noise, DMC, and the APU Frame Counter are implemented as LFSRs to save gates compared to the equivalent down counter.
  - A sequencer continuously loops over a sequence of values or events. When clocked, the next item in the sequence is generated. In this APU documentation, clocking a sequencer usually means either advancing to the next step in a waveform, or the event sequence of the Frame Counterdevice.
  - A timer is used in each of the five channels to control the sound frequency. It contains a divider which is clocked by the CPUclock. The triangle channel's timer is clocked on every CPU cycle, but the pulse, noise, and DMC timers are clocked only on every second CPU cycle and thus produce only even periods.

## References
- Blargg's NES APU Reference
- Brad Taylor's 2A03 Technical Reference

# APU Mixer

Source: https://www.nesdev.org/wiki/APU_Mixer

The NES APUmixer takes the channel outputs and converts them to an analog audio signal. Each channel has its own internal digital-to-analog convertor (DAC), implemented in a way that causes non-linearity and interaction between channels, so calculation of the resulting amplitude is somewhat involved. In particular, games such as Super Mario Bros. and StarTropics use the DMC level ($4011) as a crude volume control for the triangle and noise channels.

The following formula [1]calculates the approximate audio output level within the range of 0.0 to 1.0. It is the sum of two sub-groupings of the channels:

```text
output = pulse_out + tnd_out

                            95.88
pulse_out = ------------------------------------
             (8128 / (pulse1 + pulse2)) + 100

                                       159.79
tnd_out = -------------------------------------------------------------
                                    1
           ----------------------------------------------------- + 100
            (triangle / 8227) + (noise / 12241) + (dmc / 22638)

```

The values for pulse1, pulse2, triangle, noise, and dmcare the output values for the corresponding channel. The dmc value ranges from 0 to 127 and the others range from 0 to 15. When the values for one of the groups are all zero, the result for that group should be treated as zero rather than undefined due to the division by 0 that otherwise results.

Faster but less accurate approximations are also possible: using an efficient lookup table, or even rougher with a linear formula.

The NES hardware follows the DACs with a surprisingly involved circuitthat adds several low-pass and high-pass filters:
- A first-order high-pass filter at 90 Hz
- Another first-order high-pass filter at 440 Hz
- A first-order low-pass filter at 14 kHz

See also:
- blargg's data and analysis, and lidnariq's matching analog components to filters

The Famicom hardware instead ONLY specifies a first-order high-pass filter at 37 Hz, followed by the unknown (and varying) properties of the RF modulator and demodulator.

## Emulation

The NES APU Mixercan be efficiently emulated using a lookup table or a less-accurate linear approximation.

### Lookup Table

The APU mixer formulas can be efficiently implemented using two lookup tables: a 31-entry table for the two pulse channelsand a 203-entry table for the remaining channels (due to the approximation of tnd_out, the numerators are adjusted slightly to preserve the normalized output range).

```text
    output = pulse_out + tnd_out

    pulse_table [n] = 95.52 / (8128.0 / n + 100)

    pulse_out = pulse_table [pulse1 + pulse2]

```

The tnd_out table is approximated (within 4%) by using a base unit close to the DMC'sDAC.

```text
    tnd_table [n] = 163.67 / (24329.0 / n + 100)

    tnd_out = tnd_table [3 * triangle + 2 * noise + dmc]

```

### Linear Approximation

A linear approximation can also be used, which results in slightly louder DMC samples, but otherwise fairly accurate operation since the wave channels use a small portion of the transfer curve. The overall volume will be reduced due to the headroom required by the DMC approximation.

```text
    output = pulse_out + tnd_out

    pulse_out = 0.00752 * (pulse1 + pulse2)

    tnd_out = 0.00851 * triangle + 0.00494 * noise + 0.00335 * dmc

```

## References
- ↑apu_ref.txtby blargg

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU Noise

Source: https://www.nesdev.org/wiki/APU_Noise

The NES APUnoise channel generates pseudo-random 1-bit noise at 16 different frequencies.

The noise channel contains the following: envelope generator, timer, Linear Feedback Shift Register, length counter.

```text
   Timer --> Shift Register   Length Counter
                   |                |
                   v                v
Envelope -------> Gate ----------> Gate --> (to mixer)

```

| $400C | --lc.vvvv | Length counter halt, constant volume/envelope flag, and volume/envelope divider period (write) |
|  |
| $400E | M---.PPPP | Mode and period (write) |
| bit 7 | M--- ---- | Mode flag |

```text

```

| bits 3-0 | ---- PPPP | The timer period is set to entry P of the following: Rate $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $A $B $C $D $E $F -------------------------------------------------------------------------- NTSC 4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068 (2046 in old) PAL 4, 8, 14, 30, 60, 88, 118, 148, 188, 236, 354, 472, 708, 944, 1890, 3778 The period determines how many CPU cycles happen between shift register clocks. These periods are all even numbers because there are 2 CPU cycles in an APU cycle. |
|  |
| $400F | llll.l--- | Length counter load and envelope restart (write) |

The shift register is 15 bits wide, with bits numbered
14 - 13 - 12 - 11 - 10 - 9 - 8 - 7 - 6 - 5 - 4 - 3 - 2 - 1 - 0

When the timer clocks the shift register, the following actions occur in order:
- Feedback is calculated as the exclusive-OR of bit 0 and one other bit: bit 6 if Mode flag is set, otherwise bit 1.
- The shift register is shifted right by one bit.
- Bit 14, the leftmost bit, is set to the feedback calculated earlier.

This results in a pseudo-random bit sequence, 32767 steps long when Mode flag is clear, and randomly 93 or 31 steps long otherwise. (The particular 31- or 93-step sequence depends on where in the 32767-step sequence the shift register was when Mode flag was set).

The mixerreceives the current envelope volumeexcept when
- Bit 0 of the shift register is set, or
- The length counteris zero

Within the mixer, the DMC level has a noticeable effect on the noise's level.

On power-up, the shift register is loaded with the value 1.

In the earliest revisions of the 2A03 CPU, the Mode flag was nonexistent: the shift register always used bits 0 and 1 for feedback, and the lowest period (rate $F) lasts 2046 M2 cycles instead of 4068 (e.g. Bowser's flames in Super Mario Bros. ). These CPUs were used in the first batch of Famicom consoles (which were recalled), in Vs. System boards, and in the arcade games that used the 2A03 as a sound coprocessor. [1][2]

The 93-step sequence is about a quarter tone (50 cents) sharp relative to A440 tuning. The approximate frequencies and pitches (in LilyPond's variant of Helmholtz notation) are as follows:

|  | NTSC | PAL |
| Register value | Sample rate | Repeat rate | MIDI note | Pitch | Sample rate | Repeat rate | MIDI note | Pitch |
| $80 | 447443.2 Hz | 4811.2 Hz | 110.41 | d''''' + 41¢ | 415651.8 Hz | 4469.4 Hz | 109.13 | c#''''' + 13¢ |
| $81 | 223721.6 Hz | 2405.6 Hz | 98.41 | d'''' + 41¢ | 207825.9 Hz | 2234.7 Hz | 97.13 | c#'''' + 13¢ |
| $82 | 111860.8 Hz | 1202.8 Hz | 86.41 | d''' + 41¢ | 118757.6 Hz | 1277.0 Hz | 87.45 | d#''' + 45¢ |
| $83 | 55930.4 Hz | 601.4 Hz | 74.41 | d'' + 41¢ | 55420.2 Hz | 595.9 Hz | 74.25 | d'' + 25¢ |
| $84 | 27965.2 Hz | 300.7 Hz | 62.41 | d' + 41¢ | 27710.1 Hz | 298.0 Hz | 62.25 | d' + 25¢ |
| $85 | 18643.5 Hz | 200.5 Hz | 55.39 | g + 39¢ | 18893.3 Hz | 203.2 Hz | 55.62 | g + 62¢ |
| $86 | 13982.6 Hz | 150.4 Hz | 50.41 | d + 41¢ | 14089.9 Hz | 151.5 Hz | 50.54 | d + 54¢ |
| $87 | 11186.1 Hz | 120.3 Hz | 46.55 | a#, + 55¢ | 11233.8 Hz | 120.8 Hz | 46.62 | a#, + 62¢ |
| $88 | 8860.3 Hz | 95.3 Hz | 42.51 | f#, + 51¢ | 8843.7 Hz | 95.1 Hz | 42.48 | f#, + 48¢ |
| $89 | 7046.3 Hz | 75.8 Hz | 38.55 | d, + 55¢ | 7044.9 Hz | 75.8 Hz | 38.54 | d, + 54¢ |
| $8A | 4709.9 Hz | 50.6 Hz | 31.57 | g,, + 57¢ | 4696.6 Hz | 50.5 Hz | 31.52 | g,, + 52¢ |
| $8B | 3523.2 Hz | 37.9 Hz | 26.55 | d,, + 55¢ | 3522.5 Hz | 37.9 Hz | 26.54 | d,, + 54¢ |
| $8C | 2348.8 Hz | 25.3 Hz | 19.53 | g,,, + 53¢ | 2348.3 Hz | 25.3 Hz | 19.52 | g,,, + 52¢ |
| $8D | 1761.6 Hz | 18.9 Hz | 14.55 | d,,, + 55¢ | 1761.2 Hz | 18.9 Hz | 14.54 | d,,, + 54¢ |
| $8E | 879.9 Hz | 9.5 Hz | 2.53 | d,,,, + 53¢ | 879.7 Hz | 9.5 Hz | 2.52 | d,,,, + 52¢ |
| $8F | 440.0 Hz | 4.7 Hz | -9.47 | d,,,,, + 53¢ | 440.1 Hz | 4.7 Hz | -9.47 | d,,,,, + 53¢ |

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU Pulse

Source: https://www.nesdev.org/wiki/APU_Pulse

Each of the two NES APUpulse (square) wave channels generate a pulse wave with variable duty.

Each pulse channel contains the following:
- envelope generator
- sweep unit
- timer
- 8-step sequencer
- length counter

```text
                     Sweep -----> Timer
                       |            |
                       |            |
                       |            v
                       |        Sequencer   Length Counter
                       |            |             |
                       |            |             |
                       v            v             v
    Envelope -------> Gate -----> Gate -------> Gate --->(to mixer)

```

## Registers

Note : the addresses below are write-only! Reading from these addresses exhibits open-bus behavior.

| Address | Bitfield | Description |
| $4000 | DDlc.vvvv | Pulse 1 Duty cycle, length counter halt, constant volume/envelope flag, and volume/envelope divider period |
| $4004 | DDlc.vvvv | Pulse 2 Duty cycle, length counter halt, constant volume/envelope flag, and volume/envelope divider period |
| Side effects | The duty cycle is changed (see table below), but the sequencer's current position isn't affected. |
|  |
| $4001 | EPPP.NSSS | See APU Sweep |
| $4005 | EPPP.NSSS | See APU Sweep |
|  |
| $4002 | LLLL.LLLL | Pulse 1 timer Low 8 bits |
| $4006 | LLLL.LLLL | Pulse 2 timer Low 8 bits |
|  |
| $4003 | llll.lHHH | Pulse 1 length counter load and timer High 3 bits |
| $4007 | llll.lHHH | Pulse 2 length counter load and timer High 3 bits |
| Side effects | The sequencer is immediately restarted at the first value of the current sequence. The envelope is also restarted. The period divider is not reset.[1] |

## Sequencer behavior

The sequencer is clocked by an 11-bit timer. Given the timer value t = HHHLLLLLLLL formed by timer high and timer low, this timer is updated every APU cycle (i.e., every second CPU cycle), and counts t, t-1, ..., 0, t, t-1, ... , clocking the waveform generator when it goes from 0 to t. Since the period of the timer is t+1 APU cycles and the sequencer has 8 steps, the period of the waveform is 8*(t+1) APU cycles, or equivalently 16*(t+1) CPU cycles.

Hence
- f pulse = f CPU /(16*(t+1)) (where f CPU is 1.789773 MHz for NTSC, 1.662607 MHz for PAL, and 1.773448 MHz for Dendy)
- t = f CPU /(16*f pulse ) - 1

Note: A period of t < 8 , either set explicitly or via a sweep period update, silences the corresponding pulse channel . The highest frequency a pulse channel can output is hence about 12.4 kHz for NTSC. ( TODO: PAL behavior?)

Duty Cycle Sequences

| Duty | Output waveform |
| 0 | 0 1 0 0 0 0 0 0 (12.5%) |
| 1 | 0 1 1 0 0 0 0 0 (25%) |
| 2 | 0 1 1 1 1 0 0 0 (50%) |
| 3 | 1 0 0 1 1 1 1 1 (25% negated) |

Notice that a few Famiclone units have swapped APU duty cycles, as 12.5 [0], 50 [1], 25 [2] and 25 negated [3] instead.

Implementation details

The reason for the odd output from the sequencer is that the counter is initialized to zero but counts downward rather than upward. Thus it reads the sequence lookup table in the order 0, 7, 6, 5, 4, 3, 2, 1.

| Duty | Sequence lookup table | Output waveform |
``| 0 | 0 0 0 0 0 0 0 1 | 0 1 0 0 0 0 0 0 (12.5%) |
``| 1 | 0 0 0 0 0 0 1 1 | 0 1 1 0 0 0 0 0 (25%) |
``| 2 | 0 0 0 0 1 1 1 1 | 0 1 1 1 1 0 0 0 (50%) |
``| 3 | 1 1 1 1 1 1 0 0 | 1 0 0 1 1 1 1 1 (25% negated) |

## Pulse channel output to mixer

The mixerreceives the pulse channel's current envelope volume(lower 4 bits from $4000 or $4004) except when
- The sequencer output is zero, or
- overflow from the sweepunit's adder is silencing the channel, or
- the length counteris zero, or
- the timer has a value less than eight ( t<8 , noted above).

If any of the above are true, then the pulse channel sends zero (silence) to the mixer.

## Pulse channel 1 vs Pulse channel 2 behavior

The behavior of the two pulse channels differs only in the effect of the negate mode of their sweep units.

## See also
- Pulse Channel frequency chart

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU

Source: https://www.nesdev.org/wiki/APU_Status

The NES APU is the audio processing unit in the NES console which generates sound for games. It is implemented in the RP2A03 (NTSC) and RP2A07 (PAL) chips. Its registersare mapped in the range $4000–$4013, $4015 and $4017.

## Overview
For a simple subset of APU functionality oriented toward music engine developers rather than emulator developers, see APU basics.

The APU has five channels: two pulse wave generators, a triangle wave, noise, and a delta modulation channel for playing DPCM samples.

Each channel has a variable-rate timer clocking a waveform generator, and various modulators driven by low-frequency clocks from the frame counter. The DMCplays samples while the other channels play waveforms. Each sub-unit of a channel generally runs independently and in parallel to other units, and modification of a channel's parameter usually affects only one sub-unit and doesn't take effect until that unit's next internal cycle begins.

The read/write status registerallows channels to be enabled and disabled, and their current length counter statusto be queried.

The outputs from all the channels are combined using a non-linear mixingscheme.

### Conditions for channel output

The pulse, triangle, and noise channels will play their corresponding waveforms (at either a constant volume or at a volume controlled by an envelope) only when (and in the model given here, precisely when) their length countersare all non-zero (this includes the linear counter for the triangle channel). There are two exceptions for the pulse channels, which can also be silenced either by having a frequency above a certain threshold (see below), or by a sweeptowards lower frequencies (longer periods) reaching the end of the range.

The DMC channel always outputs the value of its counter, regardless of the status of the DMC enable bit; the enable bit only controls automatic playback of delta-encoded samples (which is done through counter updates).

### Notes
- This reference describes the abstract operation of the APU. The exact hardware implementation is not necessarily relevant to an emulator, but the Visual 2A03project can be used to determine detailed information about the hardware implementation.
- The Famicomhad an audio return loop on its cartridge connectorallowing extra audio from individual cartridges. See Expansion audiofor details on the audio produced by various mappers.
- For a basic usage guide to the APU, see APU basics, or Nerdy Nights: APU overview.
- The APU may have additional diagnostic features if CPU pin 30 is pulled high. See diagram by Quietust.

## Specification

### Registers
- See APU Registersfor a complete APU register diagram.

| Registers | Channel | Units |
| $4000–$4003 | Pulse 1 | Timer, length counter, envelope, sweep |
| $4004–$4007 | Pulse 2 | Timer, length counter, envelope, sweep |
| $4008–$400B | Triangle | Timer, length counter, linear counter |
| $400C–$400F | Noise | Timer, length counter, envelope, linear feedback shift register |
| $4010–$4013 | DMC | Timer, memory reader, sample buffer, output unit |
| $4015 | All | Channel enable and length counter status |
| $4017 | All | Frame counter |

### Pulse ($4000–$4007)
- See APU Pulse

The pulse channels produce a variable-width pulse signal, controlled by volume, envelope, length, and sweep units.

| $4000 / $4004 | DDLC VVVV | Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $4001 / $4005 | EPPP NSSS | Sweep unit: enabled (E), period (P), negate (N), shift (S) |
| $4002 / $4006 | TTTT TTTT | Timer low (T) |
| $4003 / $4007 | LLLL LTTT | Length counter load (L), timer high (T) |
- $4000 :
  - D : The width of the pulse is controlled by the duty bits in $4000/$4004. See APU Pulsefor details.
  - L : 1 = Infinite play, 0 = One-shot. If 1, the length counter will be frozen at its current value, and the envelope will repeat forever.
    - The length counter and envelope units are clocked by the frame counter.
    - If the length counter's current value is 0 the channel will be silenced whether or not this bit is set.
    - When using a one-shot envelope, the length counter should be loaded with a time longer than the length of the envelope to prevent it from being cut off early.
    - When looping, after reaching 0 the envelope will restart at volume 15 at its next period.
  - C : If C is set the volume will be a constant. If clear, an envelope will be used, starting at volume 15 and lowering to 0 over time.
  - V : Sets the direct volume if constant, otherwise controls the rate which the envelope lowers.
- The frequency of the pulse channels is a division of the CPU Clock( f CPU ; 1.789773MHz NTSC, 1.662607MHz PAL). The output frequency ( f ) of the generator can be determined by the 11-bit period value ( t ) written to $4002–$4003/$4006–$4007. If t < 8, the corresponding pulse channel is silenced.
  - f = f CPU / (16 × ( t + 1))
  - t = ( f CPU / (16 × f )) − 1
- Writing to $4003/$4007 reloads the length counter, restarts the envelope, and resets the phase of the pulse generator. Because it resets phase, vibrato should only write the low timer register to avoid a phase reset click. At some pitches, particularly near A440, wide vibrato should normally be avoided (e.g. this flaw is heard throughout the Mega Man 2 ending).
- Registers $4001/$4005 control the sweep unit. Enabling the sweep causes the pitch to constantly rise or fall. When the frequency reaches the end of the generator's range of output, the channel is silenced. See APU Sweepfor details.
- The two pulse channels are combined in a nonlinear mix (see mixerbelow).

### Triangle ($4008–$400B)
- See APU Triangle

The triangle channel produces a quantized triangle wave. It has no volume control, but it has a length counter as well as a higher resolution linear counter control (called "linear" since it uses the 7-bit value written to $4008 directly instead of a lookup table like the length counter).

| $4008 | CRRR RRRR | Length counter halt / linear counter control (C), linear counter load (R) |
| $4009 | ---- ---- | Unused |
| $400A | TTTT TTTT | Timer low (T) |
| $400B | LLLL LTTT | Length counter load (L), timer high (T), set linear counter reload flag |
- The triangle wave has 32 steps that output a 4-bit value.
- C : This bit controls both the length counter and linear counter at the same time.
  - When set this will stop the length counter in the same way as for the pulse/noise channels.
  - When set it prevents the linear counter's internal reload flag from clearing, which effectively halts it if $400B is written after setting C .
  - The linear counter silences the channel after a specified time with a resolution of 240Hz in NTSC (see frame counterbelow).
  - Because both the length and linear counters are be enabled at the same time, whichever has a longer setting is redundant.
  - See APU Trianglefor more linear counter details.
- R : This reload value will be applied to the linear counter on the next frame counter tick, but only if its reload flag is set.
  - A write to $400B is needed to raise the reload flag.
  - After a frame counter tick applies the load value R , the reload flag will only be cleared if C is also clear, otherwise it will continually reload (i.e. halt).
- The pitch of the triangle channel is one octave below the pulse channels with an equivalent timer value (i.e. use the formula above but divide the resulting frequency by two).
- Silencing the triangle channel merely halts it. It will continue to output its last value rather than 0.
- There is no way to reset the triangle channel's phase.

### Noise ($400C–$400F)
- See APU Noise

The noise channel produces noise with a pseudo-random bit generator. It has a volume, envelope, and length counter like the pulse channels.

| $400C | --LC VVVV | Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $400D | ---- ---- | Unused |
| $400E | M--- PPPP | Noise mode (M), noise period (P) |
| $400F | LLLL L--- | Length counter load (L) |
- The frequency of the noise is determined by a 4-bit value in $400E, which loads a period from a lookup table (see APU Noise).
- If bit 7 of $400E is set, the period of the random bit generation is drastically shortened, producing a buzzing tone (e.g. the metallic ding during Solstice 's gameplay). The actual timbre produced depends on whatever bits happen to be in the generator when it is switched to periodic, and is somewhat random.

### DMC ($4010–$4013)
- See APU DMC

The delta modulation channel outputs a 7-bit PCM signal from a counter that can be driven by DPCM samples.

| $4010 | IL-- RRRR | IRQ enable (I), loop (L), frequency (R) |
| $4011 | -DDD DDDD | Load counter (D) |
| $4012 | AAAA AAAA | Sample address (A) |
| $4013 | LLLL LLLL | Sample length (L) |
- DPCM samples are stored as a stream of 1-bit deltas that control the 7-bit PCM counter that the channel outputs. A bit of 1 will increment the counter, 0 will decrement, and it will clamp rather than overflow if the 7-bit range is exceeded.
- DPCM samples may loop if the loop flag in $4010 is set, and the DMC may be used to generate an IRQ when the end of the sample is reached if its IRQ flag is set.
- The playback rate is controlled by register $4010 with a 4-bit frequency index value (see APU DMCfor frequency lookup tables).
- DPCM samples must begin in the memory range $C000–$FFFF at an address set by register $4012 (address = `%11AAAAAA AA000000 `).
- The length of the sample in bytes is set by register $4013 (length = `%LLLL LLLL0001 `).

#### Other Uses
- The $4011 register can be used to play PCM samples directly by setting the counter value at a high frequency. Because this requires intensive use of the CPU, when used in games all other gameplay is usually halted to facilitate this.
- Because of the APU's nonlinear mixing, a high value in the PCM counter reduces the volume of the triangle and noise channels. This is sometimes used to apply limited volume control to the triangle channel (e.g. Super Mario Bros. adjusts the counter between levels to accomplish this).
- The DMC's IRQ can be used as an IRQ-based timer when the mapperused does not have one available.

### Status ($4015)

The status register is used to enable and disable individual channels, control the DMC, and can read the status of length counters and APU interrupts.

| $4015 write | ---D NT21 | Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1) |
- Writing a zero to any of the channel enable bits (NT21) will silence that channel and halt its length counter.
- If the DMC bit is clear, the DMC bytes remaining will be set to 0 and the DMC will silence when it empties.
- If the DMC bit is set, the DMC sample will be restarted only if its bytes remaining is 0. If there are bits remaining in the 1-byte sample buffer, these will finish playing before the next sample is fetched.
- Writing to this register clears the DMC interrupt flag.
- Power-up and resethave the effect of writing $00, silencing all channels.

| $4015 read | IF-D NT21 | DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1) |
- N/T/2/1 will read as 1 if the corresponding length counter has not been halted through either expiring or a write of 0 to the corresponding bit. For the triangle channel, the status of the linear counter is irrelevant.
- D will read as 1 if the DMC bytes remaining is more than 0.
- Reading this register clears the frame interrupt flag (but not the DMC interrupt flag).
- If an interrupt flag was set at the same moment of the read, it will read back as 1 but it will not be cleared.
- This register is internal to the CPU and so the external CPU data bus is disconnected when reading it. Therefore the returned value cannot be seen by external devices and the value does not affect open bus.
- Bit 5 is open bus. Because the external bus is disconnected when reading $4015, the open bus value comes from the last cycle that did not read $4015.

### Frame Counter ($4017)
- See APU Frame Counter

| $4017 | MI-- ---- | Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I) |

The frame counter is controlled by register $4017, and it drives the envelope, sweep, and length units on the pulse, triangle and noise channels. It ticks approximately 4 times per frame (240Hz NTSC), and executes either a 4 or 5-step sequence, depending how it is configured. It may optionally issue an IRQon the last tick of the 4-step sequence.

The following diagram illustrates the two modes, selected by bit 7 of $4017:

```text
mode 0:    mode 1:       function
---------  -----------  -----------------------------
 - - - f    - - - - -    IRQ (if bit 6 is clear)
 - l - l    - l - - l    Length counter and sweep
 e e e e    e e e - e    Envelope and linear counter

```

Both the 4 and 5-step modes operate at the same rate, but because the 5-step mode has an extra step, the effective update rate for individual units is slower in that mode (total update taking ~60Hz vs ~48Hz in NTSC). Writing to $4017 resets the frame counter and the quarter/half frame triggers happen simultaneously, but only on "odd" cycles (and only after the first "even" cycle after the write occurs) – thus, it happens either 2 or 3 cycles after the write (i.e. on the 2nd or 3rd cycle of the next instruction). After 2 or 3 clock cycles (depending on when the write is performed), the timer is reset. Writing to $4017 with bit 7 set ($80) will immediately clock all of its controlled units at the beginning of the 5-step sequence; with bit 7 clear, only the sequence is reset without clocking any of its units.

Note that the frame counter is not exactly synchronized with the PPU NMI; it runs independently at a consistent rate which is approximately 240Hz (NTSC). Some games (e.g. The Legend of Zelda , Super Mario Bros. ) manually synchronize it by writing $C0 or $FF to $4017 once per frame.

#### Length Counter
- See APU Length Counter

The pulse, triangle, and noise channels each have their own length counter unit. It is clocked twice per sequence, and counts down to zero if enabled. When the length counter reaches zero, the channel is silenced. It is reloaded by writing a 5-bit value to the appropriate channel's length counter register, which will load a value from a lookup table. (See APU Length Counterfor the table.)

The triangle channel has an additional linear counter unit which is clocked four times per sequence (like the envelope of the other channels). It functions independently of the length counter, and will also silence the triangle channel when it reaches zero.

### Mixer
- See APU Mixer

The APU audio output signal comes from two separate components. The pulse channels are output on one pin, and the triangle/noise/DMC are output on another, after which they are combined. Each of these channels has its own nonlinear DAC. For details, see APU Mixer.

After combining the two output signals, the final signal may go through a lowpass and highpass filter. For instance, RF demodulation in televisions usually results in a strong lowpass. The NES' RCA output circuitry has a more mild lowpass filter.

## Glossary
- All APUchannels have some form of frequency control. The term frequency is used where larger register value(s) correspond with higher frequencies, and the term period is used where smaller register value(s) correspond with higher frequencies.
- In the block diagrams, a gate takes the input on the left and outputs it on the right, unless the control input on top tells the gate to ignore the input and always output 0.
- Some APUunits use one or more of the following building blocks:
  - A divider outputs a clock periodically. It contains a period reload value, P, and a counter, that starts at P. When the divider is clocked, if the counter is currently 0, it is reloaded with P and generates an output clock, otherwise the counter is decremented. In other words, the divider's period is P + 1.
  - A divider can also be forced to reload its counter immediately (counter = P), but this does not output a clock. Similarly, changing a divider's period reload value does not affect the counter. Some counters offer no way to force a reload, but setting P to 0at least synchronizes it to a known state once the current count expires.
  - A divider may be implemented as a down counter (5, 4, 3, …) or as a linear feedback shift register(LFSR). The dividers in the pulse and triangle channels are linear down-counters. The dividers for noise, DMC, and the APU Frame Counter are implemented as LFSRs to save gates compared to the equivalent down counter.
  - A sequencer continuously loops over a sequence of values or events. When clocked, the next item in the sequence is generated. In this APU documentation, clocking a sequencer usually means either advancing to the next step in a waveform, or the event sequence of the Frame Counterdevice.
  - A timer is used in each of the five channels to control the sound frequency. It contains a divider which is clocked by the CPUclock. The triangle channel's timer is clocked on every CPU cycle, but the pulse, noise, and DMC timers are clocked only on every second CPU cycle and thus produce only even periods.

## References
- Blargg's NES APU Reference
- Brad Taylor's 2A03 Technical Reference

# APU Sweep

Source: https://www.nesdev.org/wiki/APU_Sweep

An NES APUsweep unit can be made to periodically adjust a pulse channel'speriod up or down.

Each sweep unit contains the following:
- divider
- reload flag

## Registers

| $4001 | EPPP.NSSS | Pulse channel 1 sweep setup (write) |
| $4005 | EPPP.NSSS | Pulse channel 2 sweep setup (write) |
| bit 7 | E--- ---- | Enabled flag |
| bits 6-4 | -PPP ---- | The divider's period is P + 1 half-frames |

| bit 3 | ---- N--- | Negate flag0: add to period, sweeping toward lower frequencies1: subtract from period, sweeping toward higher frequencies |

| bits 2-0 | ---- -SSS | Shift count (number of bits).If SSS is 0, then behaves like E=0. |
| Side effects | Sets the reload flag |

## Calculating the target period

The sweep unit continuously calculates each pulse channel's target period in this way:
- A barrel shifter shifts the pulse channel's 11-bit raw timer periodright by the shift count, producing the change amount.
- If the negate flag is true, the change amount is made negative.
- The target period is the sum of the current period and the change amount, clamped to zero if this sum is negative.

For example, if the negate flag is false and the shift amount is zero, the change amount equals the current period, making the target period equal to twice the current period.

The two pulse channels have their adders' carry inputs wired differently, which produces different results when each channel's change amount is made negative:
- Pulse 1 adds the ones' complement( −c − 1 ). Making 20 negative produces a change amount of −21.
- Pulse 2 adds the two's complement( −c ). Making 20 negative produces a change amount of −20.

Whenever the current period or sweep setting changes, whether by $400x writes or by sweep updating the period, the target period also changes.

## Muting

Muting means that the pulse channel sends 0 to the mixerinstead of the current volume. Muting happens regardless of whether the sweep unit is disabled (because either the Enabled flag or the Shift count are zero) and regardless of whether the sweep divider is outputting a clock signal.

Two conditions cause the sweep unit to mute the channel until the condition ends:
- If the current period is less than 8, the sweep unit mutes the channel.
- If at any time the target period is greater than $7FF, the sweep unit mutes the channel.

In particular, if the negate flag is false, the shift count is zero, and the current period is at least $400, the target period will be large enough to mute the channel. (This is why several publishers' NES games never seem to use the bottom octave of the pulse waves.)

Because the target period is computed continuously, a target period overflow from the sweep unit's adder can silence a channel even when the sweep unit is disabled and even when the sweep divider is not outputting a clock signal. Thus to fully disable the sweep unit, a program must additionally turn on the Negate flag, such as by writing $08. This ensures that the target period is not greater than the current period and therefore not greater than $7FF.

## Updating the period

When the frame countersends a half-frame clock (at 120 or 96 Hz), two things happen:
- If the divider's counter is zero, the sweep is enabled, the shift count is nonzero,
  - and the sweep unit is not muting the channel: The pulse's period is set to the target period.
  - and the sweep unit is muting the channel: the pulse's period remains unchanged, but the sweep unit's divider continues to count down and reload the divider's period as normal.
- If the divider's counter is zero or the reload flag is true: The divider counter is set to P and the reload flag is cleared. Otherwise, the divider counter is decremented.

If the sweep unit is disabled including because the shift count is zero, the pulse channel's period is never updated, but muting logic still applies.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU Triangle

Source: https://www.nesdev.org/wiki/APU_Triangle

The NES APUtriangle channel generates a pseudo-triangle wave. It has no volume control; the waveform is either cycling or suspended. It includes a linear counter , an extra duration timer of higher accuracy than the length counter.

The triangle channel contains the following: timer, length counter, linear counter, linear counter reload flag, control flag, sequencer.

```text
      Linear Counter   Length Counter
            |                |
            v                v
Timer ---> Gate ----------> Gate ---> Sequencer ---> (to mixer)

```

| $4008 | CRRR.RRRR | Linear counter setup (write) |
| bit 7 | C---.---- | Control flag (this bit is also the length counter halt flag) |
| bits 6-0 | -RRR RRRR | Counter reload value |
|  |
| $400A | LLLL.LLLL | Timer low (write) |
| bits 7-0 | LLLL LLLL | Timer low 8 bits |
|  |
| $400B | llll.lHHH | Length counter load and timer high (write) |
| bits 2-0 | ---- -HHH | Timer high 3 bits |
| Side effects | Sets the linear counter reload flag |

The sequencer is clocked by a timerwhose period is the 11-bit value ( %HHH.LLLLLLLL ) formed by timer high and timer low, plus one . Given t = HHHLLLLLLLL , the timer counts t, t-1, ..., 0, t, t-1, ... , clocking the waveform generator when it goes from 0 to t. Unlike the pulsechannels, this timer ticks at the rate of the CPU clock rather than the APU (CPU/2) clock. So given the following:
- f CPU = the clock rateof the CPU
- tval = the value written to the timer high and low registers
- f = the frequency of the wave generated by this channel

The following relationships hold:
- f = f CPU /(32*(tval + 1))
- tval = f CPU /(32*f) - 1

Unlike the pulsechannels, the triangle channel supports frequencies up to the maximum frequency the timer will allow, meaning frequencies up to f CPU /32 (about 55.9 kHz for NTSC) are possible - far above the audible range. Some games, e.g. Mega Man 2, "silence" the triangle channel by setting the timer to zero, which produces a popping sound when an audible frequency is resumed, easily heard e.g. in Crash Man's stage. At the expense of accuracy, these can be eliminated in an emulator e.g. by halting the triangle channel when an ultrasonic frequency is set (a timer value less than 2).

Other games, e.g. Zombie Nation and Bullet-Proof Software's Tetris, "silence" the triangle channel by setting the timer to $7FF, which produces a deep rumble and quiet whine.

When the frame countergenerates a linear counter clock, the following actions occur in order:
- If the linear counter reload flag is set, the linear counter is reloaded with the counter reload value, otherwise if the linear counter is non-zero, it is decremented.
- If the control flag is clear, the linear counter reload flag is cleared.

Note that the reload flag is not cleared unless the control flag is also clear, so when both are already set a value written to $4008 will be reloaded at the next linear counter clock.

The sequencer is clocked by the timer as long as both the linear counter and the length counterare nonzero.

The sequencer sends the following looping 32-step sequence of values to the mixer:

```text
15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15

```

Within the mixer, the DMC level has a noticeable effect on the triangle's level.

The triangle channel can be silenced by several methods:
- Write $80 to $4008, which will halt and reload the linear counter with 0 at the next frame sequence tick. This can be simply resumed by writing $FF to $4008. (When using this method the control flag and reload flag should be permanently set.)
  - Optionally: a write to $4017 after the write to $4008 can trigger an immediate frame sequence tick, if the 1/4 frame delay of the frame sequence is undesirable. This has all the other consequences of the frame sequence tick, however.
- Use $4015 to turn off the channel, which will clear its length counter. To resume, turn it back on via $4015, then write to $400B to reload the length counter.
  - When using DPCM samples, it is difficult to manipulate a single bit in $4015 without risking conflict with the DPCM control.
- Write a period value of 0 or 1 to $400A/$400B, causing a very high frequency. Due to the averaging effect of the lowpass filter, the resulting value is halfway between 7 and 8.
  - This sudden jump to "7.5" causes a harder popping noise than other triangle silencing methods, which will instead halt it in whatever its current output position is.
  - Mega Man 1 and 2 use this technique.
- Either the length counter or linear counter can be used to automatically halt the triangle after a period of time.
  - Unfortunately this is limited to very short durations because the linear counter can only go as high as 127 quarter frames.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU basics

Source: https://www.nesdev.org/wiki/APU_basics

This tutorial covers basic usage of the APU's four waveform channels on an NTSC NES. It does not cover the DMC or more advanced usage. Any registers unrelated to basic operation are not even mentioned here. A simplified though fully usable model of the APU is presented, one that will serve many programmers.

## Channels

The APU has five channels: two pulse waves, triangle wave, noise, and DMC (sample playback). Only the first four are covered here.

The channel registers begin at $4000, and each channel has four registers devoted to it. All but the triangle wave have 4-bit volume control (the triangle just has an un-mute flag).

| $4000-$4003 | First pulse wave |
| $4004-$4007 | Second pulse wave |
| $4008-$400B | Triangle wave |
| $400C-$400F | Noise |

In register descriptions below, bits listed as - can have any value written to them, while bits listed as 1 must have a 1 written, otherwise other APU features will be enabled, causing the registers to behave differently than described here.

## Register initialization

Before using the APU, first initialize all the registers to known values that silence all channels.

```text
init_apu:
        ; Init $4000-4013
        ldy #$13
@loop:  lda @regs,y
        sta $4000,y
        dey
        bpl @loop

        ; We have to skip over $4014 (OAMDMA)
        lda #$0f
        sta $4015
        lda #$40
        sta $4017

        rts
@regs:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00

```

The initialization above prepares the APU to a known state, ready to be used by the examples below. In particular, it disables hardware sweep, envelope, and length, which this tutorial does not use.

## Pulse wave channels
Main article: APU Pulse

There are two pulse wave channels, each with pitch, volume, and timbre controls.

| $4000 | $4004 | %DD11VVVV | Duty cycle and volume DD: 00=12.5% 01=25% 10=50% 11=75% VVVV: 0000=silence 1111=maximum |
| $4002 | $4006 | %LLLLLLLL | Low 8 bits of raw period |
| $4003 | $4007 | %-----HHH | High 3 bits of raw period |

To determine the raw period for a given frequency in Hz, use this formula (round the result to a whole number):: raw period = 111860.8/frequency - 1

The following code plays a 400 Hz square wave (50% duty) at maximum volume:

```text
jsr init_apu

lda #<279
sta $4002

lda #>279
sta $4003

lda #%10111111
sta $4000

```

All parameters can be changed while the tone is playing. To fade a note out, for example, write to $4000 or $4004 with the lower 4 bits decreasing every few frames.

Note that writing to $4003 and $4007 resets the phase, which causes a slight pop. This is an issue when doing vibrato, for example, and beyond the scope of this article.

## Triangle wave channel
Main article: APU Triangle

The triangle channel allows control over frequency and muting.

| $4008 | %1U------ | Un-mute |
| $400A | %LLLLLLLL | Low 8 bits of raw period |
| $400B | %-----HHH | High 3 bits of raw period |
| $4017 | %1------- | Apply un-muting immediately |

For any given period, the triangle channel's frequency is half that of the pulse channel, or a pitch one octave lower. To determine the raw period for a given frequency in Hz, use this formula (round the result to a whole number): raw period = 55930.4/frequency - 1

The following code plays a 400 Hz triangle wave:

```text
jsr init_apu

lda #<139
sta $400A

lda #>139
sta $400B

lda #%11000000
sta $4008
sta $4017

```

The raw period can be changed while the channel is playing.

To silence the wave, write %10000000 to $4008 and then $4017. Writing a raw period of 0 also silences the wave, but produces a pop, so it's not the preferred method.

## Noise channel
Main article: APU Noise

The noise channel allows control over frequency, volume, and timbre.

| $400C | %--11VVVV | Volume VVVV: 0000=silence 1111=maximum |
| $400E | %T---PPPP | Tone mode enable, Period |

The following code plays a tone-like noise at maximum volume:

```text
jsr init_apu

lda #%10000101
sta $400E

lda #%00111111
sta $400C

```

All parameters can be changed while the noise is playing.

## Playing a musical note

To easily play a musical note, use the APU period table. The following code sets the first pulse wave's frequency based on the note number in the X register:

```text
; Set first pulse channel's frequency to note code in X register
lda periodTableHi,x
sta $4003

lda periodTableLo,x
sta $4002

...

; NTSC period table generated by mktables.py
periodTableLo:
  .byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byte $1f,$1d,$1b,$1a,$18,$17,$15,$14

periodTableHi:
  .byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00

```

The triangle plays an octave lower for the same raw period. There are two ways to compensate for this. One way is to halve the value from the above table to get the desired note:

```text
; Set triangle frequency to note code in X register
lda periodTableHi,x
lsr a
sta $400B

lda periodTableLo,x
ror a
sta $400A

```

The other way is to read period values one octave later in the table:

```text
; Set triangle frequency to note code in X register
lda periodTableHi+12,x
sta $400B

lda periodTableLo+12,x
sta $400A

```

The following full program plays pulse and triangle scales:

apu_scale.s

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU period table

Source: https://www.nesdev.org/wiki/APU_period_table

APU Pulseand APU Triangleuse "period" values to set the pitch of the note. But some people might not know the piano key frequenciesor how to convert them to periods for the NES. Fortunately, this has been done for you.

## Lookup table

Here's a lookup table from note numbers to the values to write to the pulse and triangle period registers. For the triangle channel, the first value corresponds to the lowest key on a standard piano (an A). The pulse waves sound one octave higher.

```text
; NTSC period table generated by mktables.py
.export periodTableLo, periodTableHi
.segment "RODATA"
periodTableLo:
  .byt $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byt $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byt $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byt $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byt $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byt $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byt $1f,$1d,$1b,$1a,$18,$17,$15,$14
periodTableHi:
  .byt $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byt $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byt $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00

```

## Table generator

This Python program generated the above lookup table. You can use it to make a table for a PAL NES, which has a different CPU clock rate.

```text
#!/usr/bin/env python3
#
# Lookup table generator for note periods
# Copyright 2010, 2020 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#
assert str is not bytes
import sys

lowestFreq = 55.0
ntscOctaveBase = 39375000.0/(22 * 16 * lowestFreq)
palOctaveBase = 266017125.0/(10 * 16 * 16 * lowestFreq)
maxNote = 80

def makePeriodTable(filename, pal=False):
    semitone = 2.0**(1./12)
    octaveBase = palOctaveBase if pal else ntscOctaveBase
    relFreqs = [(1 << (i // 12)) * semitone**(i % 12)
                for i in range(maxNote)]
    periods = [int(round(octaveBase / freq)) - 1 for freq in relFreqs]
    systemName = "PAL" if pal else "NTSC"
    with open(filename, 'wt') as outfp:
        outfp.write("""; %s period table generated by mktables.py
.export periodTableLo, periodTableHi
.segment "RODATA"
periodTableLo:\n"""
                    % systemName)
        for i in range(0, maxNote, 12):
            outfp.write('  .byt '
                        + ','.join('$%02x' % (i % 256)
                                   for i in periods[i:i + 12])
                        + '\n')
        outfp.write('periodTableHi:\n')
        for i in range(0, maxNote, 12):
            outfp.write('  .byt '
                        + ','.join('$%02x' % (i >> 8)
                                   for i in periods[i:i + 12])
                        + '\n')

def makePALPeriodTable(filename):
    return makePeriodTable(filename, pal=True)

tableNames = {
    'period': makePeriodTable,
    'palperiod': makePALPeriodTable
}

def main(argv):
    if len(argv) >= 2 and argv[1] in ('/?', '-?', '-h', '--help'):
        print("usage: %s TABLENAME FILENAME" % argv[0])
        print("known tables:", ' '.join(sorted(tableNames)))
    elif len(argv) < 3:
        print("mktables: too few arguments; try %s --help" % argv[0])
    elif argv[1] in tableNames:
        tableNames[argv[1]](argv[2])
    else:
        print("mktables: no such table %s; try %s --help" % (argv[1], argv[0]))

if __name__=='__main__':
    main(sys.argv)

```

The following are exercises for the reader:
- Adapt to FDS audioand other mapper sound chips by changing `ntscOctaveBase `and the formula for `periods `
  - Hint: `fdsOctaveBase = lowestFreq * 65536 * 64 * 22.0 / 39375000.0 `and `octaveBase * freq `
- Adapt to other musical tuningsystems by changing the formula for `relFreqs `
- Adapt to assemblers other than ca65

## See also
- Celius' NTSC table
- Celius' PAL table

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# APU registers

Source: https://www.nesdev.org/wiki/APU_registers

The following memory-mapped registers are used by the NES APU. They are write-only except $4015 which is read/write. Unused registers aren't listed.

For Famicom expansion audio registers, see also: Expansion audio

| Address | 7654.3210 | Function |
|  | Pulse 1 channel (write) |
| $4000 | DDLC NNNN | Duty, loop envelope/disable length counter, constant volume, envelope period/volume |
| $4001 | EPPP NSSS | Sweep unit: enabled, period, negative, shift count |
| $4002 | LLLL LLLL | Timer low |
| $4003 | LLLL LHHH | Length counter load, timer high (also resets duty and starts envelope) |
|  |
|  | Pulse 2 channel (write) |
| $4004 | DDLC NNNN | Duty, loop envelope/disable length counter, constant volume, envelope period/volume |
| $4005 | EPPP NSSS | Sweep unit: enabled, period, negative, shift count |
| $4006 | LLLL LLLL | Timer low |
| $4007 | LLLL LHHH | Length counter load, timer high (also resets duty and starts envelope) |
|  |
|  | Triangle channel (write) |
| $4008 | CRRR RRRR | Length counter disable/linear counter control, linear counter reload value |
| $400A | LLLL LLLL | Timer low |
| $400B | LLLL LHHH | Length counter load, timer high (also reloads linear counter) |
|  |
|  | Noise channel (write) |
| $400C | --LC NNNN | Loop envelope/disable length counter, constant volume, envelope period/volume |
| $400E | L--- PPPP | Loop noise, noise period |
| $400F | LLLL L--- | Length counter load (also starts envelope) |
|  |
|  | DMC channel (write) |
| $4010 | IL-- FFFF | IRQ enable, loop sample, frequency index |
| $4011 | -DDD DDDD | Direct load |
| $4012 | AAAA AAAA | Sample address %11AAAAAA.AA000000 |
| $4013 | LLLL LLLL | Sample length %0000LLLL.LLLL0001 |
|  |
| $4015 | ---D NT21 | Control (write): DMC enable, length counter enables: noise, triangle, pulse 2, pulse 1 |
| $4015 | IF-D NT21 | Status (read): DMC interrupt, frame interrupt, length counter status: noise, triangle, pulse 2, pulse 1 |
| $4017 | SD-- ---- | Frame counter (write): 5-frame sequence, disable frame interrupt |

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# Audio drivers

Source: https://www.nesdev.org/wiki/Audio_drivers

An audio driver or replayer is a program that runs on a game console to play music. An audio driver for NES reads music sequences and instrument definitions from the ROM and writes to the APUports, usually once per frame.

## Tracker replayers

NSFs exported from FamiTracker and similar trackers contain replayers that can handle all tracker features, but they are not optimized for game use. They use a lot of ROM and RAM, CPU time, and can't handle sound effects. In addition, the embedded replayer may change in size/capability depending on the exported track's features (i.e., expansion audio support, bankswitching)
- FamiTracker
  - Forks (different features / behaviors)
    - Dn-FamiTracker
    - 0CC-FamiTracker
- Musetracker
- Nerdtracker II
- PPMCK/MML
- Famistudio

## Game replayers

Replayers intended for use in games have limits on the instrument, effect, and expansion features they can use. Most can't handle expansions at all, as NES games in an unmodified NES cannot use expansion audio. They usually operate by translating a text export into assembly language data files that are included into the game's source code.

### Famistudio music engine

Famistudio music engineby bleubleu

Famistudio's driver is originally of FamiTone2 genealogy, but has been massively reworked. Some of its key features is being highly configurable to cater for different needs, and extensive expansion audio support.
- Meant to go with its own music tool (Famistudio). Famitracker projects are importable.
- NESASM, CA65, ASM6 versions

Basic features:
- Pulse channels, triangle channel, noise channels
- C0-B7 note range (96 notes)
- Instruments with duty cycle, volume, pitch and arpeggio envelopes
- Absolute and relative pitch envelopes
- Looping sections in envelopes
- Release points for volume envelopes
- Ability to change the speed (FamiTracker tempo mode only)
- Ability to loop over a portion of the song
- Up to 64 instruments per export, an export can consist of as little as 1 song, or as many as 17
- Can enable/disable features to save ROM and RAM
- VRC6, VRC7, FDS, Sunsoft 5B, Namco 163 support (only one at a time)
- PAL/NTSC playback
- DPCM
- Sound effect support (configurable number of streams)
- Blaarg Smooth Vibrato technique to eliminate "pops" on square channels (incompatible with SFX at the moment)
- FamiTracker/FamiStudio tempo mode.
- Volume track
- Fine pitch track
- Slide notes
- Vibrato effect
- Arpeggio effect (not arpeggio envelopes in instruments, which are always available)

### FamiTone2

FamiTone2by Shiru
- Notes limited to C-1 through D-6
- Instrument: volume, arpeggio, and pitch envelopes. Duty envelopes longer than 1 frame unsupported. Pitch limited to accumulated distance of 63 units in each direction. No release phase.
- No volume column
- DPCM for instrument 0 only
- Limit of 64 instruments, 17 songs, and 16 KiB of DPCM

Effects:
- `Fxx `(speed / tempo)
- `Dxx `(pattern cut / skip to next frame and start at xx)
- `Bxx `(loop / jump to frame)

Requirements:
- 3 bytes ZP
- 186 bytes other RAM
- 1636 bytes ROM (source: README)

### FamiTone 5.0

FamiTone 5.0by dougeff

Modification of FamiTone2 that adds
- Adds volume column support
- Note range A0 - B7
- Duty cycle envelopes
- Sound effects that are bigger than 256 bytes

and adds effects:
- `1xx `(portamento up)
- `2xx `(portamento down)
- `3xx `(glissando)
- `4xy `(vibrato)
- `Qxx `(slide up to note)
- `Rxx `(slide down to note)

### GGSound

https://github.com/gradualgames/ggsoundby Gradual Games
- NESASM3, ASM6, and ca65 syntax supported
- Note range: C0 - B7
- Instrument: volume, arpeggio, pitch, and duty envelopes, all looping
- SFX playback on up to two channels
- Pause / Unpause
- Note cuts
- 128 instruments (each with its own set of envelopes)
- 128 songs
- 128 SFX

Effects:
- `Bxx `(loop / jump to frame).

Difference vs famitracker: Loops each channel individually, so must be placed in all channels for proper song looping.

Requirements:
- 66 bytes ZP (57 without DPCM)
- 168 bytes other RAM (144 without DPCM)
- 3048 bytes ROM (out of date, needs test on current version)

### Lizard music engine

Lizard music engineby Rainwarrior

Features (subset of Famitracker):
- Volume column supported
- No DPCM
- No Hi-Pitch macros (but regular pitch works)
- Tempo fixed at 150 (use Speed instead)
- SFX on square 1 and/or noise channel

Effects:
- `Bxx `(loop / jump to frame)
- `D00 `(Skip to next frame; no row support)
- `F0x `(just speed, not tempo)

Requirements:
- 22 bytes ZP
- 105 bytes other RAM
- 2152 bytes of code and tables
- ~1800 cycles per frame

### NSD.Lib

NSD.Libby S.W.

Focuses on providing as many features as possible while providing low CPU and memory usage (including features many other drivers do not support). It should be noted that the driver defaults to A=442 tuning, although a tuning table generatorexists if desired.

Best known for its application in games like 8Bit Music Power , Astro Ninja Man , and Kira Kira Star Night .

Features:
- Designed with low CPU usage and small code size in mind.
- Sequence data format optimized to minimize ROM space.
- Library functions callable from both Assembly and C (cc65 __fastcall__ convention).
- Can output either assembly source code for CA65 or NSF music files.
- Includes a C++ MML compiler that converts MML into sequence data usable by the driver.
- Provides a variety of effects and commands for expressive music creation.

Effects:
- Tempo (1-255)
- Note, Rest
- Octave (1-8)
- Volume (0-15)
- Detune(Pitch)
- Voice
- Envelope (Volume, Detune(Pitch), Note, Voice)
- Portamento
- Quantize
- Repeat
- Etc..

### Penguin

Penguinby pubby
- Constant cycle count of 790, allowing use in a raster effect
- Plays sound effects without using additional cycles
- Famitracker Exported
- Allegedlyhas similar features to FamiTone2, but also has duty envelopes
- No DPCM
- 12 bytes ZP
- 86 bytes other RAM
- Music data not particularly size-optimized
- Sound effects are expensive in terms of size
- Tempo fixed at 150 (use Speed instead)
- Minimum speed of 4

Effects:
- `D00 `(terminate pattern)
- Sound effects support all effects

### PUF (NesFab)

PUFby pubby

This audio driver is included with the NesFab programming language, with built-in conversion support. It is likely too difficult to use outside of NesFab. The driver is based on the Penguin driver, also by pubby.
- Low cycle count
- Plays sound effects without using many additional cycles
- Famitracker Exported
- Has similar features to FamiTone2, but also has duty envelopes
- Supports DPCM
- Supports MMC5 and Rainbow (VRC6) expansion audio
- Music data mildly optimized
- Sound effects are expensive in terms of size
- Tempo fixed at 150 (use Speed instead)
- Supports any speed, but speeds below 4 have a processing cost

Effects:
- `D00 `(terminate pattern)
- Sound effects support all effects

### Pently

Pentlyby Damian Yerrick
- Notes limited to A-0 through C-7; changeable at build time
- Instrument: volume, duty, and (absolute) arpeggio envelopes. Pitch envelopes unsupported. The volume envelope can't loop, and the duty and arpeggio envelopes stop at the end of the volume envelope. No release phase.
- Volume column limited to 4 levels
- No DPCM
- Limit of 51 instruments, 25 drums, and 255 patterns
- tempo ("Rows per minute" tempo model allows runtime correction for NTSC, PAL, and Dendy)

Effects:
- `45x `(vibrato)
- `3xx `(portamento)
- `Sxx `grace note / delayed note
- `Gxx `grace note / delayed cut
- legato (change note pitch without restarting envelope)
- `0xy `(arpeggio with 1- or 2-tick scheme)
- and loop ( `Bxx `)
- Vibrato and portamento use "linear pitch" model similar to that of 0CC-FamiTracker

Requirements:
- 32 bytes ZP
- 112 bytes other RAM
- 1918 bytes ROM
- Some effects are space-intensive and can be disabled at build time through a configuration file to reduce ROM and RAM size. A feature set comparable to FamiTone2uses 1283 bytes of ROM.
- Compatible with ca65. In 2019, an experimental ASM6 port was added. Python 3 is used to preprocess the score and generate the RAM map.

The native input format ("Pently score") is inspired by MML and intended to be familiar to users of PPMCK or LilyPond. Conversion from FT text export is through ft2pentlyby NovaSquirrel. As Pently score was originally intended for human writability, some features don't map well onto FamiTracker features, requiring manual configuration of ft2pently or manual editing of the Pently score it produces:
- Pattern start has row granularity, allowing a pattern such as a drum fill to replace the end of another pattern.
- Pattern length is not fixed, allowing long melodic patterns and short drum loops.
- Patterns are shared among channels. Use this with delayed pattern start for 2-channel echo.
- Patterns can be transposed. Use this for parallel fourths, fifths, or octaves, or for gear changes like that in the Mermaids of Atlantis soundtrack.
- Drum channel instead of noise channel. Drums are played as pairs of sound effects that interrupt a note played on the same channel, making Tim Follin-style triangle+noise drums somewhat easier than with the fixed arpeggio that one would use in FT.
- Envelope divided into an attack phase, similar to FT envelopes, and a decay phase with a constant duty and decreasing volume, similar to NerdTracker II envelopes.
- "Attack track" mode, where the attack phase of a note on MMC5 channel 1 temporarily overrides the note on pulse channel 1. Useful for staccato ostinatos and occasionally 1-channel echo.
- Automatic conversion doesn't use the newest features (linear portamento and 2-frame arpeggio) due to converter author's unfamiliarity with 0CC-FamiTracker.

### OFGS

http://offgao.net/ofgs/

### Sabre

https://github.com/CutterCross/Sabreby CutterCross

Features:
- CA65 and ASM6 syntax supported
- Note range: A0-B7 (full pulse/tri note range)
- Note cuts
- Speed and tempo
- DPCM supported for music (not for SFX)
- Instrument envelopes: Volume, arpeggio (absolute), pitch (relative) and duty.
- Loop points for all supported envelope types
- 63 instruments
- 255 unique envelopes total shared between instruments.
- 256 tracks
- 256 SFX
- 128 patterns per track
- 1 pattern per SFX
- NTSC, PAL, Dendy tempo & period adjustments
- Linear counter trill for Triangle channel
- Play / Pause / Stop Track routines
- Mute / Unmute channel routines

Effects supported:
- `Bxx `(loop / skip to frame)
- `C00 `(halt / end song)
- `D00 `(skip to next frame; specify row not supported)
- `Fxx `(speed / tempo)
- `Zxx `(set DPCM delta counter ($4011); affects tri, noise and DPCM volume)

Requirements:
- 42 bytes ZP
- 121 bytes other RAM
- 1749 bytes ROM

Notable usage notes:
- Instruments share a common envelope set.
- Song format doesn't lay down redundant note period data if the instrument or length changes
- Loop/forward points should be in first channel, rather than all channels

# APU DMC

Source: https://www.nesdev.org/wiki/DMC

The NES APU'sdelta modulation channel (DMC) can output 1-bit delta-encoded samplesor can have its 7-bit counter directly loaded, allowing flexible manual sample playback.

## Overview

The DMC channel contains the following: memory reader, interrupt flag, sample buffer, timer, output unit, 7-bit output level with up and down counter.

```text
                         Timer
                           |
                           v
Reader ---> Buffer ---> Shifter ---> Output level ---> (to the mixer)

```

| $4010 | IL--.RRRR | Flags and Rate (write) |
| bit 7 | I---.---- | IRQ enabled flag. If clear, the interrupt flag is cleared. |
| bit 6 | -L--.---- | Loop flag |

```text

```

| bits 3-0 | ----.RRRR | Rate index Rate $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $A $B $C $D $E $F ------------------------------------------------------------------------------ NTSC 428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54 PAL 398, 354, 316, 298, 276, 236, 210, 198, 176, 148, 132, 118, 98, 78, 66, 50 The rate determines for how many CPU cycles happen between changes in the output level during automatic delta-encoded sample playback. For example, on NTSC (1.789773 MHz), a rate of 428 gives a frequency of 1789773/428 Hz = 4181.71 Hz. These periods are all even numbers because there are 2 CPU cycles in an APU cycle. A rate of 428 means the output level changes every 214 APU cycles. |
|  |
| $4011 | -DDD.DDDD | Direct load (write) |
| bits 6-0 | -DDD.DDDD | The DMC output level is set to D, an unsigned value. If the timer is outputting a clock at the same time, the output level is occasionally not changed properly.[1] |
|  |
| $4012 | AAAA.AAAA | Sample address (write) |
| bits 7-0 | AAAA.AAAA | Sample address = %11AAAAAA.AA000000 = $C000 + (A * 64) |
|  |
| $4013 | LLLL.LLLL | Sample length (write) |
| bits 7-0 | LLLL.LLLL | Sample length = %LLLL.LLLL0001 = (L * 16) + 1 bytes |

The output level is sent to the mixerwhether the channel is enabled or not. It is loaded with 0 on power-up, and can be updated by $4011 writes and delta-encoded sample playback.

Automatic 1-bit delta-encoded sampleplayback is carried out by a combination of three units. The memory reader fills the 8-bit sample buffer whenever it is emptied by the sample output unit . The status registeris used to start and stop automatic sample playback.

The sample buffer either holds a single 8-bit sample byte or is empty. It is filled by the reader and can only be emptied by the output unit; once loaded with a sample byte it will be played back.

### Pitch table

|  | NTSC | PAL |
| $4010 | Period | Frequency | Note (raw) | Note (1-byte loop) | Note (17-byte loop) | Note (33-byte loop) | Period | Frequency | Note (raw) | Note (1-byte loop) | Note (17-byte loop) | Note (33-byte loop) |
| $0 | $1AC | 4181.71 Hz | C-8 -2c | C-5 -2c | B-0 -7c | infrasound | $18E | 4177.40 Hz | C-8 -4c | C-5 -4c | B-0 -9c | infrasound |
| $1 | $17C | 4709.93 Hz | D-8 +4c | D-5 +4c | C#1 -1c | infrasound | $162 | 4696.63 Hz | D-8 -1c | D-5 -1c | C#1 -6c | infrasound |
| $2 | $154 | 5264.04 Hz | E-8 -3c | E-5 -3c | Eb1 -8c | infrasound | $13C | 5261.41 Hz | E-8 -4c | E-5 -4c | Eb1 -9c | infrasound |
| $3 | $140 | 5593.04 Hz | F-8 +2c | F-5 +2c | E-1 -3c | E-0 +48c | $12A | 5579.22 Hz | F-8 -3c | F-5 -3c | E-1 -8c | E-0 +44c |
| $4 | $11E | 6257.95 Hz | G-8 -4c | G-5 -4c | F#1 -9c | F#0 +43c | $114 | 6023.94 Hz | G-8 -70c | G-5 -70c | F#1 -75c | F#0 -23c |
| $5 | $0FE | 7046.35 Hz | A-8 +2c | A-5 +2c | Ab1 -3c | Ab0 +48c | $0EC | 7044.94 Hz | A-8 +1c | A-5 +1c | Ab1 -4c | Ab0 +48c |
| $6 | $0E2 | 7919.35 Hz | B-8 +4c | B-5 +4c | Bb1 -1c | Bb0 +50c | $0D2 | 7917.18 Hz | B-8 +3c | B-5 +3c | Bb1 -2c | Bb0 +50c |
| $7 | $0D6 | 8363.42 Hz | C-9 -2c | C-6 -2c | B-1 -7c | B-0 +45c | $0C6 | 8397.01 Hz | C-9 +5c | C-6 +5c | B-1 +0c | B-0 +52c |
| $8 | $0BE | 9419.86 Hz | D-9 +4c | D-6 +4c | C#2 -1c | C#1 +51c | $0B0 | 9446.63 Hz | D-9 +9c | D-9 +9c | C#2 +4c | C#1 +56c |
| $9 | $0A0 | 11186.1 Hz | F-9 +2c | F-6 +2c | E-2 -3c | E-1 +48c | $094 | 11233.8 Hz | F-9 +9c | F-6 +9c | E-2 +4c | E-1 +56c |
| $A | $08E | 12604.0 Hz | G-9 +8c | G-6 +8c | F#2 +3c | F#1 +55c | $084 | 12595.5 Hz | G-9 +7c | G-6 +7c | F#2 -2c | G-1 +54c |
| $B | $080 | 13982.6 Hz | A-9 -12c | A-6 -12c | Ab2 -17c | Ab1 +35c | $076 | 14089.9 Hz | A-9 +1c | A-6 +1c | Ab2 -4c | Ab1 +48c |
| $C | $06A | 16884.6 Hz | C-10 +14c | C-7 +14c | B-2 +10c | B-1 +61c | $062 | 16965.4 Hz | C-10 +23c | C-7 +23c | B-2 +18c | B-1 +69c |
| $D | $054 | 21306.8 Hz | E-10 +17c | E-7 +17c | Eb3 +12c | Eb2 +64c | $04E | 21315.5 Hz | E-10 +18c | E-7 +18c | Eb3 +13c | Eb2 +65c |
| $E | $048 | 24858.0 Hz | G-10 -16c | G-7 -16c | F#3 -21c | F#2 +31c | $042 | 25191.0 Hz | G-10 +7c | G-7 +7c | F#3 +2c | F#2 +54c |
| $F | $036 | 33143.9 Hz | C-11 -18c | C-8 -18c | B-3 -23c | B-2 +29c | $032 | 33252.1 Hz | C-11 -12c | C-8 -12c | B-3 -17c | B-2 +34c |

(Deviation from note is given in cents, which are defined as 1/100th of a semitone.)

Note that on PAL systems, the pitches at $4 and $C appear to be incorrect with respect to their intended A-440 tuning scheme [1].

### Memory reader

When the sample buffer is emptied, the memory reader fills the sample buffer with the next byte from the currently playing sample. It has an address counter and a bytes remaining counter.

When a sample is (re)started, the current address is set to the sample address, and bytes remaining is set to the sample length.

Any time the sample buffer is in an empty state and bytes remaining is not zero (including just after a write to $4015 that enables the channel, regardless of where that write occurs relative to the bit counter mentioned below), the following occur:
- The CPUis stalled for 1-4 CPU cycles to read a sample byte. The exact cycle count depends on many factors and is described in detail in the DMAarticle.
- The sample buffer is filled with the next sample byte read from the current address, subject to whatever mapping hardwareis present.
- The address is incremented; if it exceeds $FFFF, it is wrapped around to $8000.
- The bytes remaining counter is decremented; if it becomes zero and the loop flag is set, the sample is restarted (see above); otherwise, if the bytes remaining counter becomes zero and the IRQ enabled flag is set, the interrupt flag is set.

At any time, if the interrupt flag is set, the CPU's IRQ lineis continuously asserted until the interrupt flag is cleared. The processor will continue on from where it was stalled.

### Output unit

The output unit continuously outputs a 7-bit value to the mixer. It contains an 8-bit right shift register, a bits-remaining counter, a 7-bit output level (the same one that can be loaded directly via $4011), and a silence flag.

The bits-remaining counter is updated whenever the timeroutputs a clock, regardless of whether a sample is currently playing. When this counter reaches zero, we say that the output cycle ends. The DPCM unit can only transition from silent to playing at the end of an output cycle.

When an output cycle ends, a new cycle is started as follows:
- The bits-remaining counter is loaded with 8.
- If the sample buffer is empty, then the silence flag is set; otherwise, the silence flag is cleared and the sample buffer is emptied into the shift register.

When the timer outputs a clock, the following actions occur in order:
- If the silence flag is clear, the output level changes based on bit 0 of the shift register. If the bit is 1, add 2; otherwise, subtract 2. But if adding or subtracting 2 would cause the output level to leave the 0-127 range, leave the output level unchanged. This means subtract 2 only if the current level is at least 2, or add 2 only if the current level is at most 125.
- The right shift register is clocked.
- As stated above, the bits-remaining counter is decremented. If it becomes zero, a new output cycle is started.

Nothing can interrupt a cycle; every cycle runs to completion before a new cycle is started.

## Conflict with controller and PPU read

On the 2A03 CPU used in the NTSC NES and Famicom, if a new sample byte is fetched from memory at the same time the program is reading a register that has read side effects (such as controllers via $4016 or $4017, PPU data via $2007, or the vblank flag via $2002), that register will see multiple extra reads that result in data loss or corruption. This is mostly a problem for controllers, and special controller reading codeis necessary to work around this.

This problem is fixed on the 2A07 series of PAL CPUs by forcing DMA to halt on the first cycle of an instruction, which fetches an instruction opcode and thus isn't normally reading from registers.

See DMAfor a thorough explanation of how DMA works and how it conflicts with register reads.

## Usage of DMC for syncing to video

DMC IRQs can be used for timed video operations. The following method was discussed on the forum in 2010. [2]

### Concept

The NES hardware only has limited tools for syncing the code with video rendering. The VBlank NMI and sprite 0 hit are the only two reasonably reliable flags that can be used, so only 2 synchronizations per frame can be done easily. In addition, only the VBlank NMI can trigger an interrupt; the sprite 0 hit flag has to be polled, potentially wasting a lot of CPU cycles.

However, the DMC channel can hypothetically be used for syncing with video instead of using it for sound. Unfortunately it's a bit complicated, but used correctly, it can function as a crude scanline counter, eliminating the need for an advanced mapper.

The DMC's timing is completely separate from the video. The DMC's timer is always running, and samples can only start every 8 clock cycles. However, because the DMC's timer isn't synchronized to the PPU in any way, these 8-clock boundaries occur on different scanlines each frame.

Here are the steps to achieve stable timing:
- At a fixed point in video rendering (we'll use the start of vblank as an example), a dummy single-byte sample at rate $F is started. Due to a hardware quirk†, the sample needs to be started three times in a row like this:

```text
sei
lda #$10
sta $4015
sta $4015
sta $4015
cli

```
- The amount of cycles before a DMC IRQ happens is then measured (either using an actual IRQ, or by polling $4015).
  - At rate $F, there are 54 CPU cycles between clocks, so there are 432 CPU cycles (432 × 3 ÷ 341 = about 3.8 scanlines) between boundaries.
- The main sample that will be used for the timing is then started (please refer to the table below to have sample lengths for various waiting times)
- When the main IRQ happens, the measurement from before is retrieved, and a timing loop with variable delay is used. In order to synchronize with vblank, after a DMC IRQ we should wait 432 CPU cycles minus the time we measured.

† Note: The hardware quirk mentioned above deals with how DMC IRQs are generated. Basically, the IRQ is generated when the last byte of the sample is read , not when the last sample of the sample plays . The sample buffer sometimes has enough time to empty itself between writes to $4015, meaning your next write to $4015 will trigger an immediate IRQ. Fortunately, writing to $4015 three times will avoid this issue.

Still using vblank as an example, the measurement tells how far into the 8-clock boundary vblank occurred, and by delaying after a DMC IRQ, we perform a raster effect at the same point within the 8-clock boundary, aligning it with vblank. By performing this same method each frame, the raster effect will have a reasonably stable timing to it. As a bonus, since mostly using IRQs are being used, the CPU is free to do something else, instead of waiting in a timed loop.

It's possible to use more than one IRQ per frame - but the measurement part needs to be done at the same time within each frame, before the usage of any IRQ.

Only a single split-point per IRQ is possible, with the shortest IRQ being 3.8 scanlines. For split points closer than this amount, timed code has to be used.

In order to remain silent, samples should be made up of all $00 bytes, and $00 should have been previously written to $4011. Otherwise, audio will unintentionally be created. This is a sound channel, after all.

### Timing table

This table converts sample length in scanline length (all values are rounded to the higher integer).

```text
NTSC               Rate
Length              $0    $1   $2   $3   $4   $5   $6   $7   $8   $9   $a   $b   $c   $d   $e   $f
----------------------------------------------------------------------------------------------------
1-byte (8 bits)     31    27   24   23   21   18   16   16   14   12   10   10   8    6    6    4
17-byte (136 bits)  **    **   **   **   **   **   **   **   228  192  170  154  127  101  87   65
33-byte (264 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   196  168  126
49-byte (392 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   **   **   187

PAL                Rate
Length              $0    $1   $2   $3   $4   $5   $6   $7   $8   $9   $a   $b   $c   $d   $e   $f
----------------------------------------------------------------------------------------------------
1-byte (8 bits)     30    27   24   23   21   18   16   15   14   12   10   9    8    6    5    4
17-byte (136 bits)  **    **   **   **   **   **   **   **   225  189  169  151  126  100  85   64
33-byte (264 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   194  164  124
49-byte (392 bits)  **    **   **   **   **   **   **   **   **   **   **   **   **   **   **   184

```

### Number of scanlines to wait table

This table gives the best sample length and frequency combinations for all possible scanlines interval to wait. They are best because they are where the CPU will have to kill the least time. However, it's still possible to use options to wait for fewer lines and kill more time during the interrupt before the video effect.

Because a PAL interrupt will always happen about the same time or a bit sooner than a NTSC interrupt, the NTSC table will be used to set the "best" setting here :

```text
Scanlines  Best opt. for IRQ

1-3        Timed code
4-5        Length $0, rate $f
6-7        Length $0, rate $d
8-9        Length $0, rate $c
10-11      Length $0, rate $a
12-13      Length $0, rate $9
14-15      Length $0, rate $8
16-17      Length $0, rate $6
18-20      Length $0, rate $5
21-22      Length $0, rate $4
23         Length $0, rate $3
24-26      Length $0, rate $2
27-30      Length $0, rate $1
31-64      Length $0, rate $0
65-86      Length $1, rate $f
87-100     Length $1, rate $e
101-125    Length $1, rate $d
126        Length $2, rate $f
127-153    Length $1, rate $c
154-167    Length $1, rate $b
168-169    Length $2, rate $e
170-186    Length $1, rate $a
187-191    Length $3, rate $f
192-195    Length $1, rate $9
196-227    Length $2, rate $d
228-239    Length $1, rate $8

```

## References
- ↑Forum post: PAL DPCM frequency table contains 2 errors.
- ↑Forum thread: DMC IRQ as a video timer.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# Expansion Port Sound Module

Source: https://www.nesdev.org/wiki/Expansion_Port_Sound_Module

The NES Expansion Port Sound Moduleis an aftermarket homebrew addition that adds 6 channels of 4-operator FM, 3 channels of Sunsoft 5B audio, and a six-instrument sampled drumkit to the front-loading NES. Your NES does not need to be modified - just plug it in the bottom expansion portand connect audio to it instead, where it's mixed with the 2A03 audio.

The EPSM uses Yamaha's YMF288(OPN3) chip, which is a lower-power and smaller variant of the YM2608without most of the sample playback abilities.

It can operate in two different access methods:

## Universal access

Rising and falling edges of the OUT1 pin transmit 10 total bits, specifying two address lines and eight data lines. In this mode, it is compatible with all existing cartridges and can operate without any assistance from the cartridge.

Note that YMF288 address bits are in reverse order .

### $4016 Write (OUT1 rising)

```text
7  bit  0
DDDD AA1.
|||| |||
|||| ||+-- DDDD and AA latched when this bit goes from 0 to 1
|||| ++--- D3=YMF288 A0, D2=YMF288 A1
++++------ YMF288 D7-D4

```

### $4016 Write (OUT1 falling)

```text
7  bit  0
DDDD ..0.
||||   |
||||   +-- DDDD latched and write triggered when this bit goes from 1 to 0
++++------ YMF288 D3-D0

```

### Caveat and workarounds

A barely-noticed design flaw of the 2A03 imposes strict timing constraints on using the universal method: OUT0 through OUT2 are only updated on every APU clock, while the CPU only drives the intended value to the data bus for one CPU clock. Therefore, the EPSM may see OUT1 toggle on the cycle after the data was on the bus, causing it to instead read other, incorrect data.

Two approaches exist to work around this issue:
- Long writes : This method keeps the data on the bus for both cycles so the EPSM sees the correct data even if the OUT1 toggle is delayed. It works in all cases and can be handled entirely by a library, so it is the preferred method, but it has a per-write overhead that reduces throughput.
- Synchronized writes : This method involves synchronizing EPSM writes so OUT1 always toggles on the correct cycle. This is done by placing the CPU and APU into a known alignment and then using timed code to do EPSM writes on the correct cycle parity. The current alignment can be detected with controller reads, or the CPU and APU can be forced into an alignment with OAM or DMC DMA. This works because the DMA unit is aligned with the APU clock and alternates between being able to put (write) on one CPU cycle and get (read) on the next, and the OUT delay only occurs for writes on put cycles. Synchronized writes are much more difficult and limited than long writes, but have the potential for higher throughput.

#### Long writes

This is the preferred method for safely writing to the EPSM.

The EPSM is guaranteed to see the OUT1 toggle either on the CPU cycle $4016 is written or on the next cycle. Therefore, if the data is present on the CPU bus for both cycles, then the data cannot be missed and synchronization between the CPU and APU is unnecessary. The first cycle after the $4016 write is always a read of the following instruction's opcode. By choosing an instruction whose opcode matches the data written to the EPSM, the write will remain valid for both cycles. This mechanism is also interrupt-safe and DMA-safe because the opcode is fetched even when an interrupt or DMA halt occurs between the two instructions.

The EPSM only reads the upper 6 bits of the written value. This means there are 64 values that need a corresponding opcode. Because the lower 2 bits aren't used by the EPSM, there are 4 possible instructions for each value. By carefully choosing input registers and targeting specific locations in RAM, a safe instruction for each value can be chosen that avoids corrupting RAM or reading outside zero page.

A long-write library by Fiskbitautomates this process. [1]

#### DMC DMA sync

If the DMCchannel is not in use, DMC DMA can be used to synchronize the CPU and APU because it always ends on a get cycle. Starting a silent, one-byte, non-looping sample will trigger a DMA 3 or 4 cycles later. By delaying the earlier of these with a write cycle, the DMA always occurs on the 4th cycle, synchronizing the following code. Write cycles to $4016 afterward must then be aligned to land on get cycles.

This approach allows writes to be done with little overhead, but has numerous caveats:
- An obscure DMC DMA bug can cause a second DMA to halt the CPU on the third cycle after the first DMA, and this second DMA is aborted after just one cycle, inverting the synchronization. The aborted DMA is prevented altogether if it is delayed by a write cycle. The following code compensates for this and successfully synchronizes:

```text
STx $4015  ; Initiate DMC DMA.
STx zp     ; Force DMA to 4 cycles later.
STx zp     ; Override the second DMA.
; The first cycle of the next instruction is a PUT cycle.

```
In this code, the stores can be from any registers and the zp writes must use the zero page addressing mode targeting any zero page address, required to force write cycles into specific timings that delay the DMA. Note that an interrupt must not occur between the first two writes, as this would prevent the second DMA from being overridden.
- DMC DMA cannot be used to synchronize too frequently. The DMA fills a sample buffer which is consumed by the DMC output unit periodically, as determined by the DMC rate. DMA occurs whenever the sample buffer is empty. This synchronization method requires that the buffer be empty, and so it cannot be used more frequently than the DMC rate. The fastest rate (432 CPU cycles) should be chosen to empty the buffer most quickly, and each series of writes to the EPSM should be synced relative to each other rather than repeatedly triggering DMC DMA.
- Any interrupts that can be handled in the synchronized region must take an even number of cycles to avoid breaking sync. As described above, however, interrupts may also prevent the second-DMA override from working, inverting the alignment.

#### OAM DMA sync

If DMC DMA is not in use, OAM DMAcan be used to synchronize the CPU and APU because it always ends on a put cycle, causing the next instruction to begin on a get cycle. Placing OAM DMA last in vblank and following it with synchronized EPSM writes allows the EPSM to be safely written without wasting vblank time or spending additional time aligning. OAM DMA can also be done at any other time to synchronize, but takes many CPU cycles and may corrupt OAM.

This approach also has caveats:
- DMC DMA occurring on the last or 3rd-to-last cycles of OAM DMA will halt the CPU for an odd number of cycles, inverting the alignment. This prevents OAM DMA sync from working properly while DMC DMA is in use in most situations. If this can be worked around, the first cycle after any contiguous sequence of write cycles in the synchronized region must be a put, as described below in Controller strobe detection.
- Any interrupts that can be handled in the synchronized region must take an even number of cycles to avoid breaking sync.

#### Controller strobe detection

If an official standard controlleris present, any reads after the button report is finished return 1. Incrementing $4016 with the controller in this state will perform a single-cycle strobe. Whether the controller sees this strobe depends on the alignment. Because opposite directions on a controller cannot be pressed, at least two D-pad bits are guaranteed to be 0, so reading the D-pad bits with synchronized code to see if any are 0 will indicate whether the strobe was seen. The code can then correct the alignment, if necessary, and perform synchronized EPSM writes.

Caveats:
- This is only guaranteed to work in the presence of official standard controllers. Third-party standard controllers may give 0's instead of 1's after the button report. Other kinds of controllers have their own behavior that may not be compatible, and the console may not even have controllers plugged in.
- If DMC DMA occurs on the same cycle as a $4016 read, one extra read may occur, deleting a bit from the report. However, because the D-pad has at least two 0 bits, at least one of them can still be seen. (Note that some console types, such as the RF Famicom, do an extra joypad read on each halted, non-DMA cycle, which could cause all 0's to be missed, but this is not the case on the NES-001, the only console with the EPSM's required expansion port.)
- DMA for refilling the DMC sample buffer normally halts on a put cycle and takes 4 CPU cycles unless delayed by a write cycle, in which case it may take 3. The synchronized code can be kept synchronized in the presence of DMC DMA by ensuring the first cycle after any contiguous sequence of write cycles is a put. This includes the 3 write cycles that occur when handling an interrupt, so maintaining sync in the presence of both DMC DMA and interrupts may be infeasible.
- Any interrupts that can be handled in the synchronized region must take an even number of cycles to avoid breaking sync.

## Mapper-specific access

In this addressing mode, five of the ten EXP pinson the cartridgegain defined function:

```text
EXP1 = EPSM /CE1
EXP3 = EPSM /CE2
EXP4 = EPSM A1
EXP7 = EPSM A0
EXP8 = EPSM CE3

```

For example, if connected as follows, the EPSM will have a suitable memory map for software that expects Sunsoft 5B audio

```text
EXP1 - EPSM /CE1 = CPU R/W
EXP3 - EPSM /CE2 = /ROMSEL
EXP4 - EPSM A1   = CPU A1
EXP7 - EPSM A0   = CPU A13
EXP8 - EPSM CE3  = CPU A14

```

## Tool support

Mesen2 and Mesen-X both support EPSM. The ROM should use an NES 2.0 header specifying the EPSM console type. This enables both the universal access method and mapper-specific access at these fully-decoded addresses:

```text
$401C = Reg write A1=0
$401D = Data write A1=0
$401E = Reg write A1=1
$401F = Data write A1=1

```

FamiStudio has support for EPSM with NSF and ROM exports using mapper-specific addressing, it does also offer sourcecode for it's audio driver in CA65,ASM6 and NESASM.

## References
- ↑GitHub:Fiskbit's long write library for safe EPSM universal access.

# List of games with expansion audio

Source: https://www.nesdev.org/wiki/Expansion_audio_games

The following is a list of games that use the Famicom's expansion audio.

## Nintendo FDS

See FDS audio.
- Ai Senshi Nicol
- Aki to Tsukasa no Fushigi no Kabe
- Apple Town Monogatari – Little Computer People
- Arumana no Kiseki
- Backgammon
- Big Challenge! Go! Go! Bowling
- Big Challenge! Dogfight Spirit
- Bio Miracle Bokutte Upa
- Bishoujo Hanafuda Club Vol. 1 – Oichokabu-hen
- Bishoujo Hanafuda Club Vol. 2 – Koikoi Bakappana-hen
- Bishoujo Sexy Derby
- Chinou Game Series 3 – Chisoko Tairiku Orudora
- Chinou Game Series 2 – Super Boy Allan
- Chinou Game Series 1 – Adian no Tsue
- Chitei Tairiku Orudoora
- Cleopatra no Mahou
- Dead Zone
- Deep Dungeon 2 – Yuushi no Monshou
- Dirty Pair – Project Eden (SFX only)
- Doki Doki Panic
- Dracula 2 – Noroi no Fuuin (Castlevania II: Simon's Quest)
- Egger Land
- Vs. Excitebike
- Exciting Baseball
- Exciting Basket
- Exciting Billiard
- Exciting Soccer – Konami Cup
- Falsion
- Famicom Grand Prix II – 3D Hot Rally
- Famicom Golf – Japan Course
- Famicom Golf – US Course
- Famicom Mukashi Banashi – Shin Onigashima
- Famicom Mukashi Banashi – Yuuyuuki
- Famicom Tantei Club – Kieta Koukeisha
- Famicom Tantei Club II – Ushiro ni Tatsu Shoujo
- Family Composer
- Fire Bam
- Gall Force – Eternal Story
- Ginga Denshou – Galaxy Odyssey
- Gyruss
- Hao-kun no Fushigi na Tabi
- I am a Teacher – Super Mario no Sweater
- I am a Teacher – Teami no Kiso
- Idol Hotline – Nakayama Miho no Tokimeki High School
- Kaettekita Mario Bros.
- Kalin no Tsurugi
- Kick and Run
- Kiki Kaikai – Dotou-hen
- Knight Move
- Link no Bouken (Zelda II: The Adventure of Link)
- Lutter
- Matou no Houkai – The Hero of Babel
- Meikyuu Jiin Dababa
- Metroid
- Monty no Doki Doki Daisassou – Monty on the Run
- Nankin no Adventure
- Nazo no Magazine Disk – Nazoler Land Dai 2 Gou
- Nazo no Magazine Disk – Nazoler Land Dai 3 Gou
- Nazo no Magazine Disk – Nazoler Land Soukan Gou
- Nazo no Murasamejou
- 19 Neunzehn
- Otocky
- Parutena no Kagami (Kid Icarus)
- Pulsar no Hikari – Space Wars Simulation
- Risa no Yousei Densetsu
- Santa Claus no Takarabako
- Seiken Psycho Calibur – Maju no Mori Densetsu
- Sexy Invaders
- Suishou no Ryuu
- Super Mario Bros. 2
- Tarot Uranai
- Time Twist
- Tobidase Daisakusen
- Transformers – The Head Masters
- Zelda no Densetsu (The Legend of Zelda)

## Namco 163

See Namco 163 audio.
- Final Lap (4 channel)
- Mappy Kids (4)
- Megami Tensei II: Digital Devil Story (4)
- Namco Classic 2 (4)
- Rolling Thunder (4)
- Sangokushi – Chuugen no Hasha (4)
- Sangokushi 2 – Haou no Tairiku (4)
- Youkai Douchuuki (4, SFX only)
- King of Kings (8 channel)
- Erika to Satoru no Yumebouken (8)

## Nintendo MMC5

See MMC5 audio.
- Ishin no Arashi (SFX only)
- Just Breed
- Metal Slader Glory (very sparingly, mostly in SFX)
- Shin 4-Nin Uchi Mahjong (uses PCM)
- Uchuu Keibitai SDF (SFX only)

## Konami VRC6

See VRC6 audio.
- Akumajou Densetsu
- Esper Dream 2
- Madara

## Konami VRC7

See VRC7 audio.
- Lagrange Point

## Sunsoft 5B (YM2149F)

See Sunsoft 5B audio.
- Gimmick! (does not use envelope or noise)

## NEC µPD7755C (Jaleco)

See mapper 18.
- Terao no Dosukoi Oozumou

## NEC µPD7756C (Jaleco)

See mappers 18, 72, 86, and 92.
- Moe Pro! '90: Kandou-hen
- Moe Pro!: Saikyou-hen
- Moero!! Pro Tennis
- Moero!! Pro Yakyuu
- Moero!! Pro Yakyuu '88: Kettei Ban
- Shin Moero!! Pro Yakyuu

## Mitsubishi M50805 (Bandai)

See CNROM, thread 1, thread 2
- Family Trainer 3: Aerobics Studio

## 4-Bit DAC
- City Fighter IV

## 3-bit ADPCM

See: NES 2.0 Mapper 419
- 真 Samurai Spirits - 武士道列传꞉ 侍魂 (from Nanjing)

## K-663A (YM2413)

See: NES 2.0 Mapper 515
- 패밀리 노래방 - Family Noraebang

## LPC-PE Speech Synthesis (TMS5220-compatible)
- Art-Pro Genius (BS-9000)
- Educational Computer 2000 48-in-1 (English)
- Educational Computer 2000 64-in-1 (Arabic)
- Español de Estudio 32-in-1
- Sistema Cyber
- Smart Kids
- Sunsonic Educational Computer Learning Card
- Sunsonic English Blaster - Make for Boys and Girls
- Zhong Tian Speech Educational Software
- Магистр Гений 2 Говорящий Картридж
- 声霸 for Doctor PC jr.
- 大华电脑 超級教学卡 (WH-453)
- 打字练习集合 18-in-1
- 昌大 多媒体学生电脑
- 東昇 英語 聲霸 - Sound-Word Blaster
- 电脑教室 (WH-453)
- 英语发声词霸 - ABC 声霸

## LPC-D6 Speech Synthesis (TSP50C04)
- 小学语文 达标乐园
- 小霸王 中英文电脑学习机 V
- 有声词霸 - A-V Word Blaster

## LPC Speech Synthesis (unknown chip)
- 리틀-킴 PC-95-KO01

## References
- Famicom games with expansion audio - complete list(NESDev forums)
- Famicom expansion hardware recordings(NESDev forums)
- Mitsubishi M50805(NESDev forums)
- Cartridge connector

# FDS audio

Source: https://www.nesdev.org/wiki/FDS_audio

The Famicom Disk System audio is an audio channel generated by the 2C33 chip on the Famicom Disk System's RAM card and output through the Famicom cart edge connector's expansion audio pins.

This channel rapidly repeats a wavetableset up by the CPU in a manner similar to channel 3 of the Game Boy but with more sophisticated modulation. By changing the waveform, the program can have it simulate many different instruments, such as in the musical game Otocky.

## Registers

### Master I/O enable ($4023)

This register must be written to with bit 1 set for the sound registers to function. The FDS bios initializes this by writing $00 followed by $83 to it.

```text
7  bit  0
---------
xxxx xxSD
       ||
       |+- Enable disk I/O registers
       +-- Enable sound I/O registers

```

### Wavetable RAM ($4040-$407F)

The 64-step waveform to be fed to the DAC. Each step consists of an unsigned sample value in the range [0, 63]. However, it cannot be modified unless it is write-enabled, and it cannot be write-enabled while the sound is being played. When writing is disabled ($4089.7), reading anywhere in 4040-407F returns the value at the current wave position. (See also $4089 below.)

```text
7  bit  0  (read/write)
---- ----
OOSS SSSS
|||| ||||
||++-++++- Sample
++-------- Returns 01 on read, likely from open bus

```

### Volume envelope ($4080)

The envelope speed is set by this register whether or not the envelope is enabled by the high bit, but the current volume is set only if the high bit is set.

The volume gain can range from 0 to 63; however, volume values above 32 are clamped to 32 before output.

Changes to the volume envelope only take effect while the wavetable pointer (top 6 bits of wave accumulator) is 0. The volume envelope is a PWM unit, so apparently (wave_addr==0) is its comparator latch signal.

However, muting the volume by directly writing volume gain to 0 takes effect immediately.

Writing to this register immediately resets the clock timer that ticks the volume envelope (delaying the next tick slightly).

```text
7  bit  0  (write; read through $4090)
---- ----
MDVV VVVV
|||| ||||
||++-++++- (M=0) Volume envelope speed
||         (M=1) Volume gain and envelope speed.
|+-------- Volume change direction (0: decrease; 1: increase)
+--------- Volume envelope mode (0: on; 1: off)

```

### Frequency low ($4082)

```text
7  bit  0  (write)
---- ----
FFFF FFFF
|||| ||||
++++-++++- Bits 0-7 of frequency

```

### Frequency high ($4083)

The high bit of this register halts the waveform and resets its phase to 0. Note that if halted it will output the constant value at $4040, and writes to the volume register $4080 or master volume $4089 will affect the output. The envelopes are not ticked while the waveform is halted.

Bit 6 halts just the envelopes without halting the waveform, and also resets both of their timers.

```text
7  bit  0  (write)
---- ----
MExx FFFF
||   ||||
||   ++++- Bits 8-11 of frequency
|+-------- Disable volume and sweep envelopes (but not modulation)
+--------- When enabled, envelopes run 4x faster. Also stops the mod table accumulator.

```

### Mod envelope ($4084)

The envelope speed is set by this register whether or not the envelope is enabled by the high bit, but the current mod gain is set only if the high bit is set.

Writing to this register immediately resets the clock timer that ticks the modulator envelope (delaying the next tick slightly).

```text
7  bit  0  (write; read through $4092)
---- ----
MDSS SSSS
|||| ||||
||++-++++- (M=0) Mod envelope speed
||         (M=1) Mod gain and envelope speed.
|+-------- Mod envelope direction (0: decrease; 1: increase)
+--------- Mod envelope mode (0: on; 1: off)

```

### Mod counter ($4085)

This directly sets the 7-bit signed modulator counter that is otherwise controlled by the mod unit.

Because the current playback position of the modulator unit is generally hard to predict while active, it is bad practice to write $4085 unless the mod unit is disabled via $4087, because it will generally result in a detuned note. Bio Miracle Bokutte Upa does this, and it requires cycle-accurate timing to emulate correctly. Some emulators incorrectly treat $4085 as a phase-reset for the mod table, which will obviate this timing issue.

It is generally good practice to write 0 to $4085 to reset the counter after writing the mod table via $4088.

```text
7  bit  0  (write)
---- ----
xBBB BBBB
 ||| ||||
 +++-++++- Mod counter (7-bit signed; minimum $40; maximum $3F)

```

### Mod frequency low ($4086)

If the 12-bit frequency is set to 0, mod table counter is stopped. The freq mod formula of the modulation unit is always in effect, $4084/$4085 still modify the wave frequency.

```text
7  bit  0  (write)
---- ----
FFFF FFFF
|||| ||||
++++-++++- Bits 0-7 of modulation unit frequency

```

### Mod frequency high ($4087)

Setting the high bit of this register halts the mod unit, and allows the mod table to be written via $4088.

Disabling the mod unit resets its timer accumulator, delaying the first tick after re-enabling.

```text
7  bit  0  (write)
---- ----
HFxx FFFF
||   ||||
||   ++++- Bits 8-11 of modulation frequency
|+-------- Force a carry out from bit 11 of mod accumulator. Step every clock.
+--------- Halt mod table counter. (Freq mod table of modulation unit is always in effect.)

```

On a carry out from bit 11 of the mod, update the mod counter (increment $4085 with mod table).

### Mod table write ($4088)

This register has no effect unless the mod unit is disabled via the high bit of $4087.

The mod table is a ring buffer containing 32 entries. Writing to this register replaces an entry at the current mod table playback position with the written value, then advances the playback position to the following entry.

The position of the mod table actually has 64 steps, but the least significant bit is not used to index the 32 entry table. Each entry will get applied twice as the mod table is stepped through.

Writing to this register 32 times will effectively reset the phase of the mod table, having advanced the playback position back to its starting point. You should normally always write all 32 entries at once, since the starting write position is not easily predictable.

Writing $4088 also increments the address (bits 13-17 of wave accumulator) when $4087.7=1.

```text
7  bit  0  (write)
---- ----
xxxx xMMM
      |||
      +++- Modulation input

```

### Wave write / master volume ($4089)

When the high bit is set, the current waveform output is held at its current level until the bit is cleared again. During this time, the wave unit will continue to run, even though the output level is held.

```text
7  bit  0  (write)
---- ----
Wxxx xxVV
|      ||
|      ++- Master volume (0: full; 1: 2/3; 2: 2/4; 3: 2/5)
|          Output volume = current volume (see $4080 above) * master volume
+--------- Wavetable write enable
           (0: write protect RAM; 1: write enable RAM and hold channel)

```

### Envelope speed ($408A)

This sets a clock multiplier for the volume and modulator envelopes. Few FDS NSFs write to this register. The BIOS initializes this to $E8.

```text
7  bit  0  (write)
---- ----
SSSS SSSS
|||| ||||
++++-++++- Sets speed of volume envelope and sweep envelope
           (0: disable them)

```

### Volume gain ($4090)

```text
7  bit  0  (read; write through $4080)
---- ----
OOVV VVVV
|||| ||||
||++-++++- Current volume gain level
++-------- Returns 01 on read, likely from open bus

```

### Wave accumlator ($4091)

```text
7  bit  0  (read)
---- ----
AAAA AAAA
|||| ||||
++++-++++- Bits 12-19 of the wavetable address accumulator

```

### Mod gain ($4092)

```text
7  bit  0  (read; write through $4084)
---- ----
OOVV VVVV
|||| ||||
||++-++++- Current mod gain level
++-------- Returns 01 on read, likely from open bus

```

### Mod table address accumulator ($4093)

```text
7  bit  0  (read)
---- ----
OAAA AAAA
|||| ||||
|+++-++++- Bits 5-11 of the modtable address accumulator
+--------- Returns 0 on read, likely from open bus

```

### Mod counter*gain result ($4094)

The mod unit uses a sequential multiplier. By reading $4094 at different times, you can see the result.

```text
7  bit  0  (read)
---- ----
MMMM MMMM
|||| ||||
++++-++++- Bits 4-11 of mod counter*gain intermediate result.

```

### Mod counter increment ($4095)

This shows the mod table contents at its current position, translated to mod counter increment value (0,1,2,3,4,5,6,7 ==> 0,1,2,4,C,C,E,F). In other words, what will be added to the counter (sign extend to 7 bits) on the next address tick.

```text
7  bit  0  (read)
---- ----
???? MMMM
|||| ||||
|||| ++++- Next mod counter ($4085) increment.
++++------ Unknown counter

```

### Wavetable value ($4096)

```text
7  bit  0  (read)
---- ----
OOVV VVVV
|||| ||||
||++-++++- Value at current wavetable position, masked by PWM from volume envelope. (What's being fed to the DAC, probably.)
++-------- Returns 01 on read, likely from open bus.

```

### Mod counter value ($4097)

```text
7  bit  0  (read)
---- ----
OCCC CCCC
|||| ||||
|+++-++++- Current mod counter ($4085) value
+--------- Returns 0 from read, likely from open bus.

```

## Unit tick

### Envelopes

If enabled, when the volume or mod table envelope is ticked by its timer, it will do one of the following based on $4080/$4084 bit 6:
- Increase: if gain is less than 32, increase it by 1
- Decrease: if gain is more than 0, decrease it by 1

Note that the gains manually can be set higher than 32, but they can no longer be increased at this point. The gain can still be decreased if above 32.

The volume gain's final output will always be clamped to 32, even though the internal gain can be higher. This is because the pulse width modulation has a period of 32 CPU cycles, and the volume gain is applied as the duty cycle. (32/32 = 100%).

Otherwise, the volume and mod envelopes are functionally identical.

Volume gain changes will only take effect when the current wavetable position is 0.

### Modulation unit

When the modulation unit is ticked, it advances to the next position in its modulation table according to the address value in its accumulator.

The modulation unit is ticked every 16 CPU cycles.

The modulation unit applies the modulation value to the counter when bit 11 of its accumulator carries over (i.e. the first 12 bits gets set back to 0 and bit 12 gets incremented).

Note that because the least significant bit is not used to index the 32 entry modulation table, the same value will always be written twice on consecutive ticks.

Each 3-bit value in the mod table corresponds to one of the following adjustment of the mod counter when ticked:

```text
0 = %000 -->  0
1 = %001 --> +1
2 = %010 --> +2
3 = %011 --> +4
4 = %100 --> reset to 0
5 = %101 --> -4
6 = %110 --> -2
7 = %111 --> -1

```

The mod counter is a signed 7-bit value, and will wrap if overflowed, i.e. 63 + 1 = -64 after wrap, and -64 - 1 = 63.

The value of the mod counter will modify the pitch of the wave output unit in a complicated way, described by the following C-style code:

```text
// pitch   = $4082/4083 (12-bit unsigned pitch value)
// counter = $4085 (7-bit signed mod counter)
// gain    = $4084 (6-bit unsigned mod gain)

// 1. multiply counter by gain
temp = counter * gain;

// 2. round up to 6 bits only if sign positive (ignoring bit 4)
if((temp & 0x0f) && !(temp & 0x800))
    temp += 0x20;

// 3. drop 4 bits and center to 0x40
temp += 0x400;
temp = (temp >> 4) & 0xff;

// 4. multiply by pitch to get the 20-bit unsigned result
wave_pitch = (pitch * temp) & 0xFFFFF;

```

### Wave output unit

When this unit is ticked, it advances to the next position in its wave table according to the wave position address value in its accumulator.

The wave output unit is ticked every 16 CPU cycles.

## Frequency calculation and timing

### Envelopes

The volume and modulator envelopes tick once after a specific number of CPU cycles, calculated in the following way:

```text
c = CPU clocks per tick
e = envelope speed ($4080/4084)
m = master envelope speed ($408A)

c =  8 * (e + 1) * (m + 1)

```

To determine the frequency:

```text
f = frequency of tick
n = CPU clock rate (≈1789773 Hz)

f = n / c

```

Writing the envelope control registers for these units will reset the timer for the respective unit, meaning that it will next tick c cycles after the write.

### Wavetables

The wave output accumulates a 6-bit wave position address value by adding the 20-bit modulated pitch result to its accumulator every 16 CPU cycles.

```text
      ++++++++--------------- 4091 read (bits 12-19)
      ||||||||
[ AAAAAAXXXXXXXXXXXXXXXXXX ]  Wave accumulator
  ||||||||||||||||||||||||
  ||||++++++++++++++++++++--- +wave_pitch (bits 0-19) add
  ||||||
  ++++++--------------------- wave address (bits 23-18)

```

The initial frequency for wave output tick (not period) without modulation can be calculated as follows:

```text
f = frequency of wave table tick
n = CPU clock rate (≈1789773 Hz)
p = current pitch value ($4082/$4083)

f = n * p / 16 / 2^12

```

The pitch value for the wave output is not simply the 12-bit value from registers $4082/$4083, but is modified by the modulator counter in an obtuse way. See abovefor details.

To calculate the momentary final frequency output:

```text
f = frequency of wave table tick
n = CPU clock rate (≈1789773 Hz)
w = wave_pitch as calculated above

f = n * w / 16 / 2^18

```

To calculate for the frequency of the entire period , divide the result by 64.

Disabling the wave unit via the high bit of $4083 immediately resets its accumulator, delaying the next tick after they are enabled again until the next overflow.

Consequently, this also resets the wave position to 0 (i.e. the $4040 value).

### Modulation unit

The modulation unit accumulates a 5-bit mod table address value by adding the 12-bit modulation pitch ($4086/$4087) to its accumulator every 16 CPU cycles.

```text
          ++++-+++-------- 4093 read
          |||| |||
[ AAAAA a FFFF ffff ffff ]  Mod accumulator
  ||||| | |||| |||| ||||
  ||||| | |||| ++++-++++-- +freq low (4086[7:0]) add
  ||||| | ++++------------ +freq hi (4087[3:0]) add
  ||||| +----------------- "ghost" modtable address bit(0) makes mod unit step thru each entry twice
  +++++------------------- modtable address

```

The frequency for the modulation unit tick (not period) can be calculated as follows:

```text
f = frequency of modulation tick
n = CPU clock rate (≈1789773 Hz)
p = current pitch value ($4086/$4087)

f = n * p / 16 / 2^12

```

To calculate for the frequency of the entire period , divide the result by 64.

Disabling the modulation unit via the high bit of $4087 immediately resets its accumulator, in a similar manner to the wave unit.

The modulation table position address (bits 13-17) however does not reset.

## Mixing

The current wave output value is attenuated by the current volume gain and master volume. This output signal is affected by a filter that attenuates higher frequencies. This filter can be approximated as a 1-pole lowpass with a cutoff of ~2000Hz.

The maximum volume of the FDS signal on a Famicom is roughly 2.4x the maximum volume of the APU square, and the polarity is the same as the 2A03. On other machines, such as the Twin Famicom, the output may be significantly louder.

The DAC output of the waveform is 6-bits (0-63), and ideally should be linear, but recent tests have revealed jagged discontinuities at binary nodes. (More works needs to be done to measure this effect.)

The volume is applied by a pulse width modulation every 32 CPU cycles. The duty cycle is controlled by the volume gain (volume gain / 32). Because this modulation is above the audible threshold (55.930 kHz), it may be emulated simply as a linear volume control.

## References
- Modulator unit notesby Loopy
- FDS decap DAC schematicsfrom Yuri213212
- FDS output notes(from forums)
- FDS Soundby Disch
- Famicom Disk System technical referenceby Brad Taylor (old/outdated)
- US Patent 4783812 on the FDS sound system

# List of games with expansion audio

Source: https://www.nesdev.org/wiki/List_of_games_with_expansion_audio

The following is a list of games that use the Famicom's expansion audio.

## Nintendo FDS

See FDS audio.
- Ai Senshi Nicol
- Aki to Tsukasa no Fushigi no Kabe
- Apple Town Monogatari – Little Computer People
- Arumana no Kiseki
- Backgammon
- Big Challenge! Go! Go! Bowling
- Big Challenge! Dogfight Spirit
- Bio Miracle Bokutte Upa
- Bishoujo Hanafuda Club Vol. 1 – Oichokabu-hen
- Bishoujo Hanafuda Club Vol. 2 – Koikoi Bakappana-hen
- Bishoujo Sexy Derby
- Chinou Game Series 3 – Chisoko Tairiku Orudora
- Chinou Game Series 2 – Super Boy Allan
- Chinou Game Series 1 – Adian no Tsue
- Chitei Tairiku Orudoora
- Cleopatra no Mahou
- Dead Zone
- Deep Dungeon 2 – Yuushi no Monshou
- Dirty Pair – Project Eden (SFX only)
- Doki Doki Panic
- Dracula 2 – Noroi no Fuuin (Castlevania II: Simon's Quest)
- Egger Land
- Vs. Excitebike
- Exciting Baseball
- Exciting Basket
- Exciting Billiard
- Exciting Soccer – Konami Cup
- Falsion
- Famicom Grand Prix II – 3D Hot Rally
- Famicom Golf – Japan Course
- Famicom Golf – US Course
- Famicom Mukashi Banashi – Shin Onigashima
- Famicom Mukashi Banashi – Yuuyuuki
- Famicom Tantei Club – Kieta Koukeisha
- Famicom Tantei Club II – Ushiro ni Tatsu Shoujo
- Family Composer
- Fire Bam
- Gall Force – Eternal Story
- Ginga Denshou – Galaxy Odyssey
- Gyruss
- Hao-kun no Fushigi na Tabi
- I am a Teacher – Super Mario no Sweater
- I am a Teacher – Teami no Kiso
- Idol Hotline – Nakayama Miho no Tokimeki High School
- Kaettekita Mario Bros.
- Kalin no Tsurugi
- Kick and Run
- Kiki Kaikai – Dotou-hen
- Knight Move
- Link no Bouken (Zelda II: The Adventure of Link)
- Lutter
- Matou no Houkai – The Hero of Babel
- Meikyuu Jiin Dababa
- Metroid
- Monty no Doki Doki Daisassou – Monty on the Run
- Nankin no Adventure
- Nazo no Magazine Disk – Nazoler Land Dai 2 Gou
- Nazo no Magazine Disk – Nazoler Land Dai 3 Gou
- Nazo no Magazine Disk – Nazoler Land Soukan Gou
- Nazo no Murasamejou
- 19 Neunzehn
- Otocky
- Parutena no Kagami (Kid Icarus)
- Pulsar no Hikari – Space Wars Simulation
- Risa no Yousei Densetsu
- Santa Claus no Takarabako
- Seiken Psycho Calibur – Maju no Mori Densetsu
- Sexy Invaders
- Suishou no Ryuu
- Super Mario Bros. 2
- Tarot Uranai
- Time Twist
- Tobidase Daisakusen
- Transformers – The Head Masters
- Zelda no Densetsu (The Legend of Zelda)

## Namco 163

See Namco 163 audio.
- Final Lap (4 channel)
- Mappy Kids (4)
- Megami Tensei II: Digital Devil Story (4)
- Namco Classic 2 (4)
- Rolling Thunder (4)
- Sangokushi – Chuugen no Hasha (4)
- Sangokushi 2 – Haou no Tairiku (4)
- Youkai Douchuuki (4, SFX only)
- King of Kings (8 channel)
- Erika to Satoru no Yumebouken (8)

## Nintendo MMC5

See MMC5 audio.
- Ishin no Arashi (SFX only)
- Just Breed
- Metal Slader Glory (very sparingly, mostly in SFX)
- Shin 4-Nin Uchi Mahjong (uses PCM)
- Uchuu Keibitai SDF (SFX only)

## Konami VRC6

See VRC6 audio.
- Akumajou Densetsu
- Esper Dream 2
- Madara

## Konami VRC7

See VRC7 audio.
- Lagrange Point

## Sunsoft 5B (YM2149F)

See Sunsoft 5B audio.
- Gimmick! (does not use envelope or noise)

## NEC µPD7755C (Jaleco)

See mapper 18.
- Terao no Dosukoi Oozumou

## NEC µPD7756C (Jaleco)

See mappers 18, 72, 86, and 92.
- Moe Pro! '90: Kandou-hen
- Moe Pro!: Saikyou-hen
- Moero!! Pro Tennis
- Moero!! Pro Yakyuu
- Moero!! Pro Yakyuu '88: Kettei Ban
- Shin Moero!! Pro Yakyuu

## Mitsubishi M50805 (Bandai)

See CNROM, thread 1, thread 2
- Family Trainer 3: Aerobics Studio

## 4-Bit DAC
- City Fighter IV

## 3-bit ADPCM

See: NES 2.0 Mapper 419
- 真 Samurai Spirits - 武士道列传꞉ 侍魂 (from Nanjing)

## K-663A (YM2413)

See: NES 2.0 Mapper 515
- 패밀리 노래방 - Family Noraebang

## LPC-PE Speech Synthesis (TMS5220-compatible)
- Art-Pro Genius (BS-9000)
- Educational Computer 2000 48-in-1 (English)
- Educational Computer 2000 64-in-1 (Arabic)
- Español de Estudio 32-in-1
- Sistema Cyber
- Smart Kids
- Sunsonic Educational Computer Learning Card
- Sunsonic English Blaster - Make for Boys and Girls
- Zhong Tian Speech Educational Software
- Магистр Гений 2 Говорящий Картридж
- 声霸 for Doctor PC jr.
- 大华电脑 超級教学卡 (WH-453)
- 打字练习集合 18-in-1
- 昌大 多媒体学生电脑
- 東昇 英語 聲霸 - Sound-Word Blaster
- 电脑教室 (WH-453)
- 英语发声词霸 - ABC 声霸

## LPC-D6 Speech Synthesis (TSP50C04)
- 小学语文 达标乐园
- 小霸王 中英文电脑学习机 V
- 有声词霸 - A-V Word Blaster

## LPC Speech Synthesis (unknown chip)
- 리틀-킴 PC-95-KO01

## References
- Famicom games with expansion audio - complete list(NESDev forums)
- Famicom expansion hardware recordings(NESDev forums)
- Mitsubishi M50805(NESDev forums)
- Cartridge connector

# APU

Source: https://www.nesdev.org/wiki/NES_APU

The NES APU is the audio processing unit in the NES console which generates sound for games. It is implemented in the RP2A03 (NTSC) and RP2A07 (PAL) chips. Its registersare mapped in the range $4000–$4013, $4015 and $4017.

## Overview
For a simple subset of APU functionality oriented toward music engine developers rather than emulator developers, see APU basics.

The APU has five channels: two pulse wave generators, a triangle wave, noise, and a delta modulation channel for playing DPCM samples.

Each channel has a variable-rate timer clocking a waveform generator, and various modulators driven by low-frequency clocks from the frame counter. The DMCplays samples while the other channels play waveforms. Each sub-unit of a channel generally runs independently and in parallel to other units, and modification of a channel's parameter usually affects only one sub-unit and doesn't take effect until that unit's next internal cycle begins.

The read/write status registerallows channels to be enabled and disabled, and their current length counter statusto be queried.

The outputs from all the channels are combined using a non-linear mixingscheme.

### Conditions for channel output

The pulse, triangle, and noise channels will play their corresponding waveforms (at either a constant volume or at a volume controlled by an envelope) only when (and in the model given here, precisely when) their length countersare all non-zero (this includes the linear counter for the triangle channel). There are two exceptions for the pulse channels, which can also be silenced either by having a frequency above a certain threshold (see below), or by a sweeptowards lower frequencies (longer periods) reaching the end of the range.

The DMC channel always outputs the value of its counter, regardless of the status of the DMC enable bit; the enable bit only controls automatic playback of delta-encoded samples (which is done through counter updates).

### Notes
- This reference describes the abstract operation of the APU. The exact hardware implementation is not necessarily relevant to an emulator, but the Visual 2A03project can be used to determine detailed information about the hardware implementation.
- The Famicomhad an audio return loop on its cartridge connectorallowing extra audio from individual cartridges. See Expansion audiofor details on the audio produced by various mappers.
- For a basic usage guide to the APU, see APU basics, or Nerdy Nights: APU overview.
- The APU may have additional diagnostic features if CPU pin 30 is pulled high. See diagram by Quietust.

## Specification

### Registers
- See APU Registersfor a complete APU register diagram.

| Registers | Channel | Units |
| $4000–$4003 | Pulse 1 | Timer, length counter, envelope, sweep |
| $4004–$4007 | Pulse 2 | Timer, length counter, envelope, sweep |
| $4008–$400B | Triangle | Timer, length counter, linear counter |
| $400C–$400F | Noise | Timer, length counter, envelope, linear feedback shift register |
| $4010–$4013 | DMC | Timer, memory reader, sample buffer, output unit |
| $4015 | All | Channel enable and length counter status |
| $4017 | All | Frame counter |

### Pulse ($4000–$4007)
- See APU Pulse

The pulse channels produce a variable-width pulse signal, controlled by volume, envelope, length, and sweep units.

| $4000 / $4004 | DDLC VVVV | Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $4001 / $4005 | EPPP NSSS | Sweep unit: enabled (E), period (P), negate (N), shift (S) |
| $4002 / $4006 | TTTT TTTT | Timer low (T) |
| $4003 / $4007 | LLLL LTTT | Length counter load (L), timer high (T) |
- $4000 :
  - D : The width of the pulse is controlled by the duty bits in $4000/$4004. See APU Pulsefor details.
  - L : 1 = Infinite play, 0 = One-shot. If 1, the length counter will be frozen at its current value, and the envelope will repeat forever.
    - The length counter and envelope units are clocked by the frame counter.
    - If the length counter's current value is 0 the channel will be silenced whether or not this bit is set.
    - When using a one-shot envelope, the length counter should be loaded with a time longer than the length of the envelope to prevent it from being cut off early.
    - When looping, after reaching 0 the envelope will restart at volume 15 at its next period.
  - C : If C is set the volume will be a constant. If clear, an envelope will be used, starting at volume 15 and lowering to 0 over time.
  - V : Sets the direct volume if constant, otherwise controls the rate which the envelope lowers.
- The frequency of the pulse channels is a division of the CPU Clock( f CPU ; 1.789773MHz NTSC, 1.662607MHz PAL). The output frequency ( f ) of the generator can be determined by the 11-bit period value ( t ) written to $4002–$4003/$4006–$4007. If t < 8, the corresponding pulse channel is silenced.
  - f = f CPU / (16 × ( t + 1))
  - t = ( f CPU / (16 × f )) − 1
- Writing to $4003/$4007 reloads the length counter, restarts the envelope, and resets the phase of the pulse generator. Because it resets phase, vibrato should only write the low timer register to avoid a phase reset click. At some pitches, particularly near A440, wide vibrato should normally be avoided (e.g. this flaw is heard throughout the Mega Man 2 ending).
- Registers $4001/$4005 control the sweep unit. Enabling the sweep causes the pitch to constantly rise or fall. When the frequency reaches the end of the generator's range of output, the channel is silenced. See APU Sweepfor details.
- The two pulse channels are combined in a nonlinear mix (see mixerbelow).

### Triangle ($4008–$400B)
- See APU Triangle

The triangle channel produces a quantized triangle wave. It has no volume control, but it has a length counter as well as a higher resolution linear counter control (called "linear" since it uses the 7-bit value written to $4008 directly instead of a lookup table like the length counter).

| $4008 | CRRR RRRR | Length counter halt / linear counter control (C), linear counter load (R) |
| $4009 | ---- ---- | Unused |
| $400A | TTTT TTTT | Timer low (T) |
| $400B | LLLL LTTT | Length counter load (L), timer high (T), set linear counter reload flag |
- The triangle wave has 32 steps that output a 4-bit value.
- C : This bit controls both the length counter and linear counter at the same time.
  - When set this will stop the length counter in the same way as for the pulse/noise channels.
  - When set it prevents the linear counter's internal reload flag from clearing, which effectively halts it if $400B is written after setting C .
  - The linear counter silences the channel after a specified time with a resolution of 240Hz in NTSC (see frame counterbelow).
  - Because both the length and linear counters are be enabled at the same time, whichever has a longer setting is redundant.
  - See APU Trianglefor more linear counter details.
- R : This reload value will be applied to the linear counter on the next frame counter tick, but only if its reload flag is set.
  - A write to $400B is needed to raise the reload flag.
  - After a frame counter tick applies the load value R , the reload flag will only be cleared if C is also clear, otherwise it will continually reload (i.e. halt).
- The pitch of the triangle channel is one octave below the pulse channels with an equivalent timer value (i.e. use the formula above but divide the resulting frequency by two).
- Silencing the triangle channel merely halts it. It will continue to output its last value rather than 0.
- There is no way to reset the triangle channel's phase.

### Noise ($400C–$400F)
- See APU Noise

The noise channel produces noise with a pseudo-random bit generator. It has a volume, envelope, and length counter like the pulse channels.

| $400C | --LC VVVV | Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) |
| $400D | ---- ---- | Unused |
| $400E | M--- PPPP | Noise mode (M), noise period (P) |
| $400F | LLLL L--- | Length counter load (L) |
- The frequency of the noise is determined by a 4-bit value in $400E, which loads a period from a lookup table (see APU Noise).
- If bit 7 of $400E is set, the period of the random bit generation is drastically shortened, producing a buzzing tone (e.g. the metallic ding during Solstice 's gameplay). The actual timbre produced depends on whatever bits happen to be in the generator when it is switched to periodic, and is somewhat random.

### DMC ($4010–$4013)
- See APU DMC

The delta modulation channel outputs a 7-bit PCM signal from a counter that can be driven by DPCM samples.

| $4010 | IL-- RRRR | IRQ enable (I), loop (L), frequency (R) |
| $4011 | -DDD DDDD | Load counter (D) |
| $4012 | AAAA AAAA | Sample address (A) |
| $4013 | LLLL LLLL | Sample length (L) |
- DPCM samples are stored as a stream of 1-bit deltas that control the 7-bit PCM counter that the channel outputs. A bit of 1 will increment the counter, 0 will decrement, and it will clamp rather than overflow if the 7-bit range is exceeded.
- DPCM samples may loop if the loop flag in $4010 is set, and the DMC may be used to generate an IRQ when the end of the sample is reached if its IRQ flag is set.
- The playback rate is controlled by register $4010 with a 4-bit frequency index value (see APU DMCfor frequency lookup tables).
- DPCM samples must begin in the memory range $C000–$FFFF at an address set by register $4012 (address = `%11AAAAAA AA000000 `).
- The length of the sample in bytes is set by register $4013 (length = `%LLLL LLLL0001 `).

#### Other Uses
- The $4011 register can be used to play PCM samples directly by setting the counter value at a high frequency. Because this requires intensive use of the CPU, when used in games all other gameplay is usually halted to facilitate this.
- Because of the APU's nonlinear mixing, a high value in the PCM counter reduces the volume of the triangle and noise channels. This is sometimes used to apply limited volume control to the triangle channel (e.g. Super Mario Bros. adjusts the counter between levels to accomplish this).
- The DMC's IRQ can be used as an IRQ-based timer when the mapperused does not have one available.

### Status ($4015)

The status register is used to enable and disable individual channels, control the DMC, and can read the status of length counters and APU interrupts.

| $4015 write | ---D NT21 | Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1) |
- Writing a zero to any of the channel enable bits (NT21) will silence that channel and halt its length counter.
- If the DMC bit is clear, the DMC bytes remaining will be set to 0 and the DMC will silence when it empties.
- If the DMC bit is set, the DMC sample will be restarted only if its bytes remaining is 0. If there are bits remaining in the 1-byte sample buffer, these will finish playing before the next sample is fetched.
- Writing to this register clears the DMC interrupt flag.
- Power-up and resethave the effect of writing $00, silencing all channels.

| $4015 read | IF-D NT21 | DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1) |
- N/T/2/1 will read as 1 if the corresponding length counter has not been halted through either expiring or a write of 0 to the corresponding bit. For the triangle channel, the status of the linear counter is irrelevant.
- D will read as 1 if the DMC bytes remaining is more than 0.
- Reading this register clears the frame interrupt flag (but not the DMC interrupt flag).
- If an interrupt flag was set at the same moment of the read, it will read back as 1 but it will not be cleared.
- This register is internal to the CPU and so the external CPU data bus is disconnected when reading it. Therefore the returned value cannot be seen by external devices and the value does not affect open bus.
- Bit 5 is open bus. Because the external bus is disconnected when reading $4015, the open bus value comes from the last cycle that did not read $4015.

### Frame Counter ($4017)
- See APU Frame Counter

| $4017 | MI-- ---- | Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I) |

The frame counter is controlled by register $4017, and it drives the envelope, sweep, and length units on the pulse, triangle and noise channels. It ticks approximately 4 times per frame (240Hz NTSC), and executes either a 4 or 5-step sequence, depending how it is configured. It may optionally issue an IRQon the last tick of the 4-step sequence.

The following diagram illustrates the two modes, selected by bit 7 of $4017:

```text
mode 0:    mode 1:       function
---------  -----------  -----------------------------
 - - - f    - - - - -    IRQ (if bit 6 is clear)
 - l - l    - l - - l    Length counter and sweep
 e e e e    e e e - e    Envelope and linear counter

```

Both the 4 and 5-step modes operate at the same rate, but because the 5-step mode has an extra step, the effective update rate for individual units is slower in that mode (total update taking ~60Hz vs ~48Hz in NTSC). Writing to $4017 resets the frame counter and the quarter/half frame triggers happen simultaneously, but only on "odd" cycles (and only after the first "even" cycle after the write occurs) – thus, it happens either 2 or 3 cycles after the write (i.e. on the 2nd or 3rd cycle of the next instruction). After 2 or 3 clock cycles (depending on when the write is performed), the timer is reset. Writing to $4017 with bit 7 set ($80) will immediately clock all of its controlled units at the beginning of the 5-step sequence; with bit 7 clear, only the sequence is reset without clocking any of its units.

Note that the frame counter is not exactly synchronized with the PPU NMI; it runs independently at a consistent rate which is approximately 240Hz (NTSC). Some games (e.g. The Legend of Zelda , Super Mario Bros. ) manually synchronize it by writing $C0 or $FF to $4017 once per frame.

#### Length Counter
- See APU Length Counter

The pulse, triangle, and noise channels each have their own length counter unit. It is clocked twice per sequence, and counts down to zero if enabled. When the length counter reaches zero, the channel is silenced. It is reloaded by writing a 5-bit value to the appropriate channel's length counter register, which will load a value from a lookup table. (See APU Length Counterfor the table.)

The triangle channel has an additional linear counter unit which is clocked four times per sequence (like the envelope of the other channels). It functions independently of the length counter, and will also silence the triangle channel when it reaches zero.

### Mixer
- See APU Mixer

The APU audio output signal comes from two separate components. The pulse channels are output on one pin, and the triangle/noise/DMC are output on another, after which they are combined. Each of these channels has its own nonlinear DAC. For details, see APU Mixer.

After combining the two output signals, the final signal may go through a lowpass and highpass filter. For instance, RF demodulation in televisions usually results in a strong lowpass. The NES' RCA output circuitry has a more mild lowpass filter.

## Glossary
- All APUchannels have some form of frequency control. The term frequency is used where larger register value(s) correspond with higher frequencies, and the term period is used where smaller register value(s) correspond with higher frequencies.
- In the block diagrams, a gate takes the input on the left and outputs it on the right, unless the control input on top tells the gate to ignore the input and always output 0.
- Some APUunits use one or more of the following building blocks:
  - A divider outputs a clock periodically. It contains a period reload value, P, and a counter, that starts at P. When the divider is clocked, if the counter is currently 0, it is reloaded with P and generates an output clock, otherwise the counter is decremented. In other words, the divider's period is P + 1.
  - A divider can also be forced to reload its counter immediately (counter = P), but this does not output a clock. Similarly, changing a divider's period reload value does not affect the counter. Some counters offer no way to force a reload, but setting P to 0at least synchronizes it to a known state once the current count expires.
  - A divider may be implemented as a down counter (5, 4, 3, …) or as a linear feedback shift register(LFSR). The dividers in the pulse and triangle channels are linear down-counters. The dividers for noise, DMC, and the APU Frame Counter are implemented as LFSRs to save gates compared to the equivalent down counter.
  - A sequencer continuously loops over a sequence of values or events. When clocked, the next item in the sequence is generated. In this APU documentation, clocking a sequencer usually means either advancing to the next step in a waveform, or the event sequence of the Frame Counterdevice.
  - A timer is used in each of the five channels to control the sound frequency. It contains a divider which is clocked by the CPUclock. The triangle channel's timer is clocked on every CPU cycle, but the pulse, noise, and DMC timers are clocked only on every second CPU cycle and thus produce only even periods.

## References
- Blargg's NES APU Reference
- Brad Taylor's 2A03 Technical Reference

# Category:Expansion audio

Source: https://www.nesdev.org/wiki/NES_Audio

The Famicomhad the capability of audio expansion, via an audio return loop on its cartridge connector. Cartridges containing additional hardware would mix the incoming 2A03 audiosignal with their own audio signal produced by the mapperchip. The FDSalso produced expansion sound which operated through the same cartridge connector.

# Namco 163 audio

Source: https://www.nesdev.org/wiki/Namco_163_audio

The Namco 163offers up to 8 additional sound channels that play wavetable samples while the 175 and 340do not. Each waveform can be of a configurable length, and each channel has linear volume control. It has $80 bytes of sound RAM shared by channel registers and wavetable samples; at least $40 bytes are dedicated to samples, with more available if not all channels are used.

The chip is unable to clock every channel at once, so it cycles though channels, updating one every 15 CPU cycles. Because of this, the chip allows the game to configure the number of enabled channels. When fewer channels are enabled, the channels are clocked more often, allowing for higher tones with longer, more detailed waveforms. When more channels are enabled, clocking slows down since each channel has to wait its turn, resulting in lower tones and a high-pitched whining noise at the switching frequency. Most games using this IC used only 4 channels.

## Registers

### Sound Enable ($E000-E7FF)

```text
7  bit  0
---- ----
.SPP PPPP
 ||| ||||
 |++-++++- Select 8KB page of PRG-ROM at $8000-$9FFF
 +-------- Disables sound if set.

```

Sound is enabled on the 163 by writing a clear bit 6 to this register (0 is sufficient).

### Address Port ($F800-$FFFF)

```text
7  bit  0   (write only)
---- ----
IAAA AAAA
|||| ||||
|+++-++++- Address
+--------- Auto-increment

```

Writing to this register sets the internal address to write to or read from. If the 'I' bit is set, the address will increment on writes and reads to the Data Port ($4800). Despite previous statements, it does not wrap, instead stopping at $7F. [1]

### Data Port ($4800-$4FFF)

```text
7  bit  0   (read / write)
---- ----
DDDD DDDD
|||| ||||
++++-++++- Data

```

This Port accesses the 163's internal $80 bytes of sound RAM. Which of the $80 bytes is determined by the Address register ($F800). When read, the appropriate byte is returned. When written, the appropriate byte is stored.

Caution: Do not read from sound RAM while auto-increment is enabled and DMCis playing. Otherwise, you are likely to miss bytes because of the DMA multiple-read bug. Writing with auto-increment while DMC is playing behaves as expected.

This RAM is used primarily for wavetables. The sound channel control registers are also set by writing to certain addresses in sound RAM:

#### Sound RAM $78 - Low Frequency

```text
7  bit  0
---------
FFFF FFFF
|||| ||||
++++-++++- Low 8 bits of Frequency

```

#### Sound RAM $79 - Low Phase

```text
7  bit  0
---------
PPPP PPPP
|||| ||||
++++-++++- Low 8 bits of Phase

```

#### Sound RAM $7A - Mid Frequency

```text
7  bit  0
---------
FFFF FFFF
|||| ||||
++++-++++- Middle 8 bits of Frequency

```

#### Sound RAM $7B - Mid Phase

```text
7  bit  0
---------
PPPP PPPP
|||| ||||
++++-++++- Middle 8 bits of Phase

```

#### Sound RAM $7C - High Frequency and Wave Length

```text
7  bit  0
---------
LLLL LLFF
|||| ||||
|||| ||++- High 2 bits of Frequency
++++-++--- Length of waveform ((64-L)*4 4-bit samples)

```

Equivalently, the waveform length = `256 - %LLLLLL00 `samples.

The Namco 129 was never released with a game that used audio. However, on the Namco 129 this register instead only encodes length, supporting any length of waveform and not only multiple of 4 samples. In exchange, the high 2 bits of frequency can't be configured and are effectively always 0.

#### Sound RAM $7D - High Phase

```text
7  bit  0
---------
PPPP PPPP
|||| ||||
++++-++++- High 8 bits of Phase

```

The high byte of the 24-bit phase value directly determines the current sample position of the channel. Every time a channel is updated, the 18-bit frequency value is added to the 24-bit phase accumulator, which is stored in these three registers.

The phase registers may be written to immediately set the phase of the wave. It is good practice to set the frequency to 0 before doing so.

#### Sound RAM $7E - Wave Address

```text
7  bit  0
---------
AAAA AAAA
|||| ||||
++++-++++- Address of waveform (in 4-bit samples)

```

#### Sound RAM $7F - Volume

```text
7  bit  0
---------
.CCC VVVV
 ||| ||||
 ||| ++++- Linear Volume
 +++------ Enabled Channels (1+C)

```

Note 'C' is available on register $7F ONLY. Those bits have no effect in other registers.
- When C=0, only channel 8 enabled
- When C=1, channels 8 and 7 enabled
- When C=2, channels 8, 7, 6 enabled
- etc...

#### Other Channels

Above Sound RAM register descriptions ($78-$7F) are for the 8th channel. The other 7 channels are accessed via the same pattern, but each 8 bytes before the last:

```text
Channel 8:  $78-$7F
Channel 7:  $70-$77
Channel 6:  $68-$6F
Channel 5:  $60-$67
Channel 4:  $58-$5F
Channel 3:  $50-$57
Channel 2:  $48-$4F
Channel 1:  $40-$47

```

Again note that the 'C' bits in the final register is only available at address $7F.

When channels are disabled, their registers are unused, and can be used for waveform data instead.

## Waveform

Each enabled channel cycles through its waveform at a rate determined by the 18-bit frequency value 'F'. Each step in the waveform is 4-bits wide, and the number of steps is determined by the 'L' bits ((64-L)*4). Two samples are stored to a byte, which is little-endian (unlike the Game Boy's wavetable channel).

The 'A' bits dictate where in the internal sound RAM the waveform starts. 'A' is the address in 4-bit samples, therefore a value of $02 would be the low 4 bits of address $01. A value of $03 would be the high 4 bits of address $01.

For a visual example, assume you have the following sound RAM:

```text
$00:    00 00 00 A8 DC EE FF FF EF DE AC 58 23 11 00 00
$10:    10 21 53 00 00 00 00 00 00 00 00 00 00 00 00 00

```

And assume a channel has an 'A' value of $06, and an 'L' value of $38. That channel's waveform would be a sine wave, looking like the following:

```text
F -       *****
E -     **     **
D -    *         *
C -   *           *
B -
A -  *             *
9 -
8 - *               *
7 -
6 -
5 -                  *             *
4 -
3 -                   *           *
2 -                    *         *
1 -                     **     **
0 -                       *****

```

## Channel Update

Namco's 163 does not internally mix its channels. Instead, each channel is output one at a time. It takes exactly 15 CPU cycles to update and output one channel. When multiple channels are used it will cycle between them. With 6 or fewer channels, the time to update all channels is a rate faster than any audible frequency, and the difference between this serial output and mixing cannot be heard, but for 8 channels it creates a very loud and apparent noise at the update rate. For a Famicom through RF output, this noise is attenuated during demodulation (which performs a lowpass filter), but through A/V output to a TV that does not filter high frequencies, it can be very unpleasant. Only two games used all 8 channels: King of Kings and Erika to Satoru no Yume Bouken .

| ChannelsEnabled | Update Rate(NTSC) | Update Rate(PAL) |
| 1 | 119.318 kHz | 110.840 kHz |
| 2 | 59.659 kHz | 55.420 kHz |
| 3 | 39.773 kHz | 36.947 kHz |
| 4 | 29.830 kHz | 27.710 kHz |
| 5 | 23.864 kHz | 22.168 kHz |
| 6 | 19.886 kHz | 18.473 kHz |
| 7 | 17.045 kHz | 15.834 kHz |
| 8 | 14.915 kHz | 13.855 kHz |

The following is a speculative version of a single channel update, occurring every 15 CPU cycles:

```text
* w[$80] = the 163's internal memory
* sample(x) = (w[x/2] >> ((x&1)*4)) & $0F
* phase = (w[$7D] << 16) + (w[$7B] << 8) + w[$79]
* freq = ((w[$7C] & $03) << 16) + (w[$7A] << 8) + w[$78]
* length = 256 - (w[$7C] & $FC)
* offset = w[$7E]
* volume = w[$7F] & $0F

```

```text
phase = (phase + freq) % (length << 16)
output = (sample(((phase >> 16) + offset) & $FF) - 8) * volume

```

The output will be held until the next channel update. The 24-bit phase value will be stored back into w [$7D/$7B/$79].

The sample value is biased by -8, meaning that a waveform value of 8 represents the centre voltage. This means that volume changes have no effect on a sample of 8, will tend negative if <8 and positive if >8.

## Frequency

The wave position is driven by the high 8 bits of a 24-bit accumulator. Every 15 CPU clocks, one channel will add its 18-bit frequency to the accumulator. Because only one channel is updated per tick, the output frequency is thus divided by the number of channels enabled.

```text
f = wave frequency
l = wave length
c = number of channels
p = 18-bit frequency value
n = CPU clock rate (≈1789773 Hz)

f = (n * p) / (15 * 65536 * l * c)

```

## Mixing

The relative volume of the IC varies from game to game, unfortunately. The following samples have been recorded using various test programs.

| Difference between loudest APU square and loudest N163 square in 1-channel mode (dB) |
| Game | NewRisingSun | jrlepage | Rainwarrior |
| Final Lap | 12.7 | 11.2 |  |
| Sangokushi II: Haou no Tairiku | 12.9 |  |  |
| Megami Tensei II | 13.0 | 11.9 |  |
| Rolling Thunder | 16.9 | 16.0 | 16.9 |
| King of Kings | 18.0 | 17.3 |  |
| Mappy Kids | 18.6 |  |  |
| Erika to Satoru no Yume Bouken | 18.8 |  | 18.9 |
| Youkai Douchuu-ki | 18.9 |  |  |
| Sangokushi: Chuugen no Hasha | 19.5 |  |  |

Based on these measurements, the following submappers were allocated:

| INES Mapper 019 submapper table |
| Submapper # | Meaning | Note |
| 0 | Default | Expansion sound volume unspecified |

| 1 | Deprecated | Internal 128b RAM is battery backed, no external PRG-RAM is present. No expansion sound. (Equivalent to submapper 2 with 0 in PRG-NVRAM field.) |
| 2 | No expansion sound |  |
| 3 | N163 expansion sound: 11.0-13.0 dB louder than NES APU |  |
| 4 | N163 expansion sound: 16.0-17.0 dB louder than NES APU |  |
| 5 | N163 expansion sound: 18.0-19.5 dB louder than NES APU |  |

Because the high frequency generated by the channel cycling can be unpleasant, and emulation of high frequency audio can be difficult, it is often preferred to simply sum the channel outputs, and divide the output volume by the number of active channels. For 6 channels or more, where the switching frequency crosses the threshold of audibility, this approximation will become slightly too loud as it fails to compensate for the transferred energy.

## References
- Namcot 163 family pinout- diagram of the chip
- Namcot 106 Mapper Informationby Goroh, ZW4, nori
- NES Music Format Specby Kevin Horton, N106 info by Mamiya
- ↑https://forums.nesdev.org/viewtopic.php?p=294940#p294940

# Nerdy Nights: APU overview

Source: https://www.nesdev.org/wiki/Nerdy_Nights:_APU_overview

Music and sound effects on the NES are generated by the APU(Audio Processing Unit), the sound chip inside the CPU. The CPU "talks" to the APU through a series of I/O ports, much like it does with the PPU and joypads.
- PPU: $2000-$2007
- Joypads: $4016-$4017
- APU: $4000-$4015, $4017

## Channels

The APU has 5 channels: Square 1, Square 2, Triangle, Noise and DMC. The first four play waves and are used in just about every game. The DMC channel plays samples (pre-recorded sounds) and is used less often.

### Square

The square channelsproduce square waveforms. A square wave is named for its shape. It looks like this:

```text
+-----------+
|           |
|           |
|           |
|           |
| . . . . . | . . . . . |
            |           |
            |           |
            |           |
            |           |
            +-----------+

```

As you can see the wave transitions instantaneously from its high point to its low point (where the lines are vertical). This gives it a hollow sound like a woodwind or an electric guitar.

### Triangle

The triangle channelproduces triangle waveforms. A triangle wave is also named for its shape. It looks like this:

```text
    /\
   /  \
  /    \
 /      \
/ . . . .\ . . . ./
          \      /
           \    /
            \  /
             \/

```

The sound of a triangle wave is smoother and less harsh than a square wave. On the NES, the triangle channel is often used for bass lines (in low octaves) or a flute (in high octaves). It can also be used for drums.

### Noise

The noise channelhas a random generator, which makes the waves it produces sound like.. noise. This channel is generally used for percussion and explosion sounds.

### DMC

The delta modulation channelplays samples, which are pre-recorded sounds. It is often used to play voice recordings ("Blades of Steel") and percussion samples. Samples take up a lot of ROM space, so not many games make use of the DMC channel.

## Enabling channels

Before you can use the channels to produce sounds, you need to enable them. Channels are toggled on and off via port $4015:

```text
7654 3210  APUFLAGS ($4015)
   | ||||
   | |||+- Square 1 (0: disable; 1: enable)
   | ||+-- Square 2
   | |+--- Triangle
   | +---- Noise
   +------ DMC

```

Here are some code examples using $4015 to enable and disable channels:

```text
  lda #%00000001
  sta $4015 ;enable Square 1 channel, disable others

  lda #%00010110
  sta $4015 ;enable Square 2, Triangle and DMC channels.  Disable Square 1 and Noise.

  lda #$00
  sta $4015 ;disable all channels

  lda #$0F
  sta $4015 ;enable Square 1, Square 2, Triangle and Noise channels.  Disable DMC.
            ;this is the most common usage.

```

Try opening up some of your favorite games in FCEUXD SP and set a breakpoint on writes to $4015. Take a look at what values are getting written there. If you don't know how to do this, follow these steps:
- Open FCEUXD SP
- Load a ROM
- Open up the Debugger by pressing F1 or going to Tools->Debugger
- In the top right corner of the debugger, under "BreakPoints", click the "Add..." button
- Type "4015" in the first box after "Address:"
- Check the checkbox next to "Write"
- Set "Memory" to "CPU Mem"
- Leave "Condition" and "Name" blank and click "OK"

Now FCEUX will pause emulation and snap the debugger anytime your game makes a write (usually via STA) to $4015. The debugger will tell you the contents of the registers at that moment, so you can check what value will be written to $4015. Some games will write to $4015 every frame, and some only do so once at startup. Try resetting the game if your debugger isn't snapping.

What values are being written to $4015? Can you tell what channels your game is using?

# Nerdy Nights: Square 1

Source: https://www.nesdev.org/wiki/Nerdy_Nights:_Square_1

## Square 1 Channel

Let's make a beep. This week we'll learn how to produce a sound on the Square 1 channel. The Square channels are everybody's favorites because you can control the volume and tone and perform sweeps on them. You can produce a lot of interesting effects using the Squares.

Square 1 is controlled via ports $4000-$4003. The first port, $4000, controls the duty cycle (ie, tone) and volume for the channel. It looks like this:

```text
7654 3210  SQ1_ENV ($4000)
|||| ||||
|||| ++++- Volume
|||+------ Saw Envelope Disable (0: use internal counter for volume; 1: use Volume for volume)
||+------- Length Counter Disable (0: use Length Counter; 1: disable Length Counter)
++-------- Duty Cycle

```

For our purposes, we will focus on Volume and Duty Cycle. We will set Saw Envelope Disable and Length Counter Disable to 1 and then forget about them. If we leave Saw Envelopes on, the volume of the channel will be controlled by an internal counter. If we turn them off, WE have control of the volume. If WE have control, we can code our own envelopes (much more versatile). Same thing with the Length Counter. If we disable it, we have more control over note lengths. If that didn't make sense, don't worry. It will become clearer later. For now we're just going to disable and forget about them.

Volume controls the channel's volume. It's 4 bits long so it can have a value from 0-F. A volume of 0 silences the channel. 1 is very quiet and F is loud.

Duty Cycle controls the tone of the Square channel. It's 2 bits long, so there are four possible values:
- 00 = a weak, grainy tone. Think of the engine sounds in RC Pro-Am. (12.5% Duty)
- 01 = a solid mid-strength tone. (25% Duty)
- 10 = a strong, full tone, like a clarinet or a lead guitar (50% Duty)
- 11 = sounds a lot like 01 (25% Duty negated)

The best way to know the difference in sound is to listen yourself. I recommend downloading FamiTracker and playing with the different Duty settings in the Instrument Editor.

For those interested, Duty Cycle actually refers to the percentage of time that the wave is in "up" position vs. "down" position. Here are some pictures:

[diagram missing]

Don't sweat it if graphs and waves aren't your thing. Use your ears instead.

Here's a code snippet that sets the Duty and Volume for the Square 1 channel:

```text
   lda #%10111111; Duty 10 (50%), volume F (max!)
   sta $4000

```

$4001 controls sweeps for Square 1. We'll skip them for now.

### Setting the note

$4002 and $4003 control the period of the wave, or in other words what note you hear (A, C#, G, etc). Periods are 11-bits long. $4002 holds the low 8-bits and $4003 holds the high 3-bits of the period. We'll get into more detail in a future tutorial, but for now just know that changing the values written to these ports will change the note that is played.

```text
7654 3210  SQ1_LO ($4002)
|||| ||||
++++-++++- Low 8-bits of period

7654 3210  SQ1_HI ($4003)
|||| ||||
|||| |+++- High 3-bits of period
++++-+---- Length Counter

```

The Length Counter, if enabled, controls how long the note is played. We disabled it up in the $4000 section, so we can forget about it for now.

Here is some code that will produce an eternal beep on the Square 1 channel:

```text
   lda #%00000001
   sta $4015 ;enable square 1

   lda #%10111111 ;Duty 10, Volume F
   sta $4000

   lda #$C9    ;0C9 is a C# in NTSC mode
   sta $4002
   lda #$00
   sta $4003

```

### Putting it all together

Download and unzip the square1.zipsample files. All the code above is in the square1.asm file. Make sure square1.asm and square1.bat are all in the same folder as NESASM3, then double click square1.bat. That will run NESASM3 and should produce the square1.nes file. Run that NES file in FCEUXD SP to listen to your beep! Edit square1.asm to change the Volume (0 to F), or to change the Duty Cycle for the square wave. Try changing the period to produce different notes.

# Nerdy Nights sound

Source: https://www.nesdev.org/wiki/Nerdy_Nights_sound

- Nerdy Nights: APU overview
- Nerdy Nights: Square 1
- Nerdy Nights: Square 2
- Nerdy Nights: Triangle

## References
- Original version starts at Nerdy Nights Sound: Part 1by MetalSlime ( Original link, now broken)

## External links

Future sections to be wikified:
- Square 2 and Triangle
- Periods and Lookup Tables
- Starting our sound engine
- Sound data, pointers, and tables
- Timing
- Envelopes
- Opcodes and looping
- Finite looping, key changes, and chord progressions
- Noise, simple drums
- Sound effects (not yet written)

# Sunsoft 5B audio

Source: https://www.nesdev.org/wiki/Sunsoft_5B_audio

The Sunsoft 5B is a superset of the Sunsoft FME-7. It is identical to the FME-7 except it contains extra audio hardware. This audio hardware was only used in one game, Gimmick! Because this game did not use many features of the chip (e.g. noise, envelope), its features are often only partially implemented by emulators.

The audio hardware is a type of Yamaha YM2149F, which is itself a variant of the General Instrument AY-3-8910 PSG.

## Registers

The two audio registers on the 5B correspond to writes to the internal YM2149F registers, first selecting the internal register through $C000, then writing to it through $E000.

### Audio Register Select ($C000-$DFFF)

```text
7......0
DDDDRRRR
||||++++- The 4-bit internal register to select for use with $E000
++++----- Disable writes to $E000 if nonzero (like the original AY-3-8910)

```

### Audio Register Write ($E000-$FFFF)

```text
7......0
VVVVVVVV
++++++++- The 8-bit value to write to the internal register selected with $C000

```

### Internal audio registers

The YM2149F has 16 internal audio registers, selected with $C000 and written to with $E000.

| Register | Bitfield | Description |
| $00 | LLLL LLLL | Channel A low period |
| $01 | ---- HHHH | Channel A high period |
| $02 | LLLL LLLL | Channel B low period |
| $03 | ---- HHHH | Channel B high period |
| $04 | LLLL LLLL | Channel C low period |
| $05 | ---- HHHH | Channel C high period |
| $06 | ---P PPPP | Noise period |
| $07 | --CB Acba | Noise disable on channels C/B/A, Tone disable on channels c/b/a |
| $08 | ---E VVVV | Channel A envelope enable (E), volume (V) |
| $09 | ---E VVVV | Channel B envelope enable (E), volume (V) |
| $0A | ---E VVVV | Channel C envelope enable (E), volume (V) |
| $0B | LLLL LLLL | Envelope low period |
| $0C | HHHH HHHH | Envelope high period |
| $0D | ---- CAaH | Envelope reset and shape: continue (C), attack (A), alternate (a), hold (H) |
| $0E | ---- ---- | I/O port A (unused) |
| $0F | ---- ---- | I/O port B (unused) |

## Sound

There are three channels that output a square wave tone. In addition there is one noise generator, and one envelope generator, both of which may be shared by any of the three channels.

The 5B's audio is driven by the CPU clock(1.789773 MHz). It operates equivalent to a YM2149F with its SEL pin held low (see datasheet). This causes the tone and noise channels to operate at half the speed of an AY-3-8190 with an equivalent clock.

To use an AY-3-8910 as a substitute, you would need an external divider to reduce the clock speed by half.

Unlike the 2A03and VRC6pulse channels' frequency formulas, the formula for 5B does not add 1 to the period. A period value of 0 appears to produce the same result as a period value of 1, for tone [1], noise and envelope [2].

Correct behaviour can be implemented as a counter that counts up on every 16th clock cycle until it is equal to or greater than the period register, at which point the output flips and the counter resets to 0. (This means that shortening the period can cause an immediate flip if the phase counter is already past the new new period value. [3])

None of the various generators (tone, noise, envelope) can be halted. Setting them to volume or disabling their output does not affect their internal continued operation [4].

### Tone

The tone generators produce a square wave with a period controlled by the CPU clock and the 12-bit period value in registers $00-05.
- Frequency = Clock / (32 * Period )
- Period = Clock / (32 * Frequency )

This means that the high/low state of the square wave is toggled every 16 clocks.

Register $07 controls the mixing of tone and noise components of each channel. A bit of 0 enables the noise/tone on the specified channel, and a bit of 1 disables it. If both bits are 1, the channel outputs a constant signal at the specified volume. If both bits are 0, the result is the logical and of noise and tone.

If bit 4 of registers $08-$0A is set, the volume of the channel is controlled by the envelope generator (see below). Otherwise, it is controlled by the 4-bit value in bits 3-0 of the same register. Volume 0 is completely silent [5].

### Noise

The noise generator produces a 1-bit random output with a period controlled by the CPU clock and the 5-bit period value in register $06.
- Frequency = Clock / (32 * Period )
- Period = Clock / (32 * Frequency )

This produces a new random bit every 32 clocks.

It is implemented as a 17-bit linear feedback shift register with taps at bits 16 and 13. [6]

### Envelope

The envelope produces a ramp that can be directed up or down, or to oscillate by various shape parameters.

It has a 5-bit series of output levels. Its maximum level 31 corresponds to the 4-bit volume register level 15 [7]. Every 2 down from maximum is equivalent to 1 step down in the 4-bit volume register, and finally envelope levels 0 and 1 are both equivalent to volume 0 (silent). The others fall in between at 1.5db logarithmic steps.

| 5-bit envelope | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 |
| 4-bit volume | 0 | 0 |  | 1 |  | 2 |  | 3 |  | 4 |  | 5 |  | 6 |  | 7 |  | 8 |  | 9 |  | 10 |  | 11 |  | 12 |  | 13 |  | 14 |  | 15 |

#### Period

The ramp has a frequency controlled by the CPU clock and the 16-bit period value in registers $0B-0C. Note this formula is the frequency of a single step of the ramp.
- Frequency = Clock / (16 * Period )
- Period = Clock / (16 * Frequency )

The 5B divides each ramp into 32 steps, so for continued ("sawtooth") envelope shapes the resulting frequency will be 1/32 of the step frequency, and for the continued alternating ("triangle") envelope shapes it will sound at 1/64 of the step frequency. Thus the overall period for the continued envelope has a factor of 512 (or 1024 if alternating), rather than just 16.

Because the envelope is primarily intended for low (sub-audio) frequencies, its pitch control is not as accurate in audio frequency ranges as the tone channels.

#### Shape

Writing register $0D resets the envelope [8]and chooses its shape. The shape has four parameters: continue, attack, alternate, and hold.
- Continue specifies whether the envelope continues to oscillate after the attack. If it is 0, the alternate and hold parameters have no effect.
- Attack specifies whether the attack goes from high to low (0) or low to high (1).
- Alternate specifies whether the signal continues to alternate up and down after the attack. If combined with hold it provides an immediate flip after the attack followed by the hold.
- Hold specifies that the value shall be held after the attack. If combined with alternate, the value at the end of the attack will be immediately flipped before holding.

| Value | Continue | Attack | Alternate | Hold | Shape |
| $00 - $03 | 0 | 0 | x | x | \_______ |
| $04 - $07 | 0 | 1 | x | x | /_______ |
| $08 | 1 | 0 | 0 | 0 | \\\\\\\\ |
| $09 | 1 | 0 | 0 | 1 | \_______ |
| $0A | 1 | 0 | 1 | 0 | \/\/\/\/ |
| $0B | 1 | 0 | 1 | 1 | \¯¯¯¯¯¯¯ |
| $0C | 1 | 1 | 0 | 0 | //////// |
| $0D | 1 | 1 | 0 | 1 | /¯¯¯¯¯¯¯ |
| $0E | 1 | 1 | 1 | 0 | /\/\/\/\ |
| $0F | 1 | 1 | 1 | 1 | /_______ |

### Output

The tone channels each produce a 5-bit signal which is then converted to analog with a logarithmic DAC. Note that the least significant bit cannot be controlled by the volume register, it is only used by the YM2149F's double-resolution envelope generator. The logarithmic curve increases by 1.5 decibels for each step in the 5-bit signal. This can easily be implemented as a lookup table.

Some emulator implementations that are based on the AY-3-8190 instead treat it as a 4-bit signal with a 3dB per step curve. Since the only extant 5B game does not use the envelope, the difference is unimportant unless accuracy is desired for homebrew 5B work.

The three output channels are mixed together linearly. The output is mixed with the 2A03 and amplified. It is very loud compared to other audio expansion carts.

The amplifier becomes nonlinear at higher amplitudes, and includes some filtering. [9]

## References
- YM2149 datasheet: http://pdf1.alldatasheet.com/datasheet-pdf/view/103366/ETC/YM2149.html
- GI AY-3-8910 datasheet: http://www.speccy.org/hardware/datasheet/ay38910.pdf
- ↑Period 0 verification for tone/noise
- ↑Period 0 verification for envelope
- ↑Phase counting verification
- ↑No halt verification
- ↑Volume 0 silence verification
- ↑LFSR verification
- ↑Envelope-Volume equivalence verification
- ↑Envelope phase reset verification
- ↑Sunsoft 5B amplifier investigation(ongoing)

# Sunsoft 5B audio

Source: https://www.nesdev.org/wiki/Sunsoft_audio

The Sunsoft 5B is a superset of the Sunsoft FME-7. It is identical to the FME-7 except it contains extra audio hardware. This audio hardware was only used in one game, Gimmick! Because this game did not use many features of the chip (e.g. noise, envelope), its features are often only partially implemented by emulators.

The audio hardware is a type of Yamaha YM2149F, which is itself a variant of the General Instrument AY-3-8910 PSG.

## Registers

The two audio registers on the 5B correspond to writes to the internal YM2149F registers, first selecting the internal register through $C000, then writing to it through $E000.

### Audio Register Select ($C000-$DFFF)

```text
7......0
DDDDRRRR
||||++++- The 4-bit internal register to select for use with $E000
++++----- Disable writes to $E000 if nonzero (like the original AY-3-8910)

```

### Audio Register Write ($E000-$FFFF)

```text
7......0
VVVVVVVV
++++++++- The 8-bit value to write to the internal register selected with $C000

```

### Internal audio registers

The YM2149F has 16 internal audio registers, selected with $C000 and written to with $E000.

| Register | Bitfield | Description |
| $00 | LLLL LLLL | Channel A low period |
| $01 | ---- HHHH | Channel A high period |
| $02 | LLLL LLLL | Channel B low period |
| $03 | ---- HHHH | Channel B high period |
| $04 | LLLL LLLL | Channel C low period |
| $05 | ---- HHHH | Channel C high period |
| $06 | ---P PPPP | Noise period |
| $07 | --CB Acba | Noise disable on channels C/B/A, Tone disable on channels c/b/a |
| $08 | ---E VVVV | Channel A envelope enable (E), volume (V) |
| $09 | ---E VVVV | Channel B envelope enable (E), volume (V) |
| $0A | ---E VVVV | Channel C envelope enable (E), volume (V) |
| $0B | LLLL LLLL | Envelope low period |
| $0C | HHHH HHHH | Envelope high period |
| $0D | ---- CAaH | Envelope reset and shape: continue (C), attack (A), alternate (a), hold (H) |
| $0E | ---- ---- | I/O port A (unused) |
| $0F | ---- ---- | I/O port B (unused) |

## Sound

There are three channels that output a square wave tone. In addition there is one noise generator, and one envelope generator, both of which may be shared by any of the three channels.

The 5B's audio is driven by the CPU clock(1.789773 MHz). It operates equivalent to a YM2149F with its SEL pin held low (see datasheet). This causes the tone and noise channels to operate at half the speed of an AY-3-8190 with an equivalent clock.

To use an AY-3-8910 as a substitute, you would need an external divider to reduce the clock speed by half.

Unlike the 2A03and VRC6pulse channels' frequency formulas, the formula for 5B does not add 1 to the period. A period value of 0 appears to produce the same result as a period value of 1, for tone [1], noise and envelope [2].

Correct behaviour can be implemented as a counter that counts up on every 16th clock cycle until it is equal to or greater than the period register, at which point the output flips and the counter resets to 0. (This means that shortening the period can cause an immediate flip if the phase counter is already past the new new period value. [3])

None of the various generators (tone, noise, envelope) can be halted. Setting them to volume or disabling their output does not affect their internal continued operation [4].

### Tone

The tone generators produce a square wave with a period controlled by the CPU clock and the 12-bit period value in registers $00-05.
- Frequency = Clock / (32 * Period )
- Period = Clock / (32 * Frequency )

This means that the high/low state of the square wave is toggled every 16 clocks.

Register $07 controls the mixing of tone and noise components of each channel. A bit of 0 enables the noise/tone on the specified channel, and a bit of 1 disables it. If both bits are 1, the channel outputs a constant signal at the specified volume. If both bits are 0, the result is the logical and of noise and tone.

If bit 4 of registers $08-$0A is set, the volume of the channel is controlled by the envelope generator (see below). Otherwise, it is controlled by the 4-bit value in bits 3-0 of the same register. Volume 0 is completely silent [5].

### Noise

The noise generator produces a 1-bit random output with a period controlled by the CPU clock and the 5-bit period value in register $06.
- Frequency = Clock / (32 * Period )
- Period = Clock / (32 * Frequency )

This produces a new random bit every 32 clocks.

It is implemented as a 17-bit linear feedback shift register with taps at bits 16 and 13. [6]

### Envelope

The envelope produces a ramp that can be directed up or down, or to oscillate by various shape parameters.

It has a 5-bit series of output levels. Its maximum level 31 corresponds to the 4-bit volume register level 15 [7]. Every 2 down from maximum is equivalent to 1 step down in the 4-bit volume register, and finally envelope levels 0 and 1 are both equivalent to volume 0 (silent). The others fall in between at 1.5db logarithmic steps.

| 5-bit envelope | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 |
| 4-bit volume | 0 | 0 |  | 1 |  | 2 |  | 3 |  | 4 |  | 5 |  | 6 |  | 7 |  | 8 |  | 9 |  | 10 |  | 11 |  | 12 |  | 13 |  | 14 |  | 15 |

#### Period

The ramp has a frequency controlled by the CPU clock and the 16-bit period value in registers $0B-0C. Note this formula is the frequency of a single step of the ramp.
- Frequency = Clock / (16 * Period )
- Period = Clock / (16 * Frequency )

The 5B divides each ramp into 32 steps, so for continued ("sawtooth") envelope shapes the resulting frequency will be 1/32 of the step frequency, and for the continued alternating ("triangle") envelope shapes it will sound at 1/64 of the step frequency. Thus the overall period for the continued envelope has a factor of 512 (or 1024 if alternating), rather than just 16.

Because the envelope is primarily intended for low (sub-audio) frequencies, its pitch control is not as accurate in audio frequency ranges as the tone channels.

#### Shape

Writing register $0D resets the envelope [8]and chooses its shape. The shape has four parameters: continue, attack, alternate, and hold.
- Continue specifies whether the envelope continues to oscillate after the attack. If it is 0, the alternate and hold parameters have no effect.
- Attack specifies whether the attack goes from high to low (0) or low to high (1).
- Alternate specifies whether the signal continues to alternate up and down after the attack. If combined with hold it provides an immediate flip after the attack followed by the hold.
- Hold specifies that the value shall be held after the attack. If combined with alternate, the value at the end of the attack will be immediately flipped before holding.

| Value | Continue | Attack | Alternate | Hold | Shape |
| $00 - $03 | 0 | 0 | x | x | \_______ |
| $04 - $07 | 0 | 1 | x | x | /_______ |
| $08 | 1 | 0 | 0 | 0 | \\\\\\\\ |
| $09 | 1 | 0 | 0 | 1 | \_______ |
| $0A | 1 | 0 | 1 | 0 | \/\/\/\/ |
| $0B | 1 | 0 | 1 | 1 | \¯¯¯¯¯¯¯ |
| $0C | 1 | 1 | 0 | 0 | //////// |
| $0D | 1 | 1 | 0 | 1 | /¯¯¯¯¯¯¯ |
| $0E | 1 | 1 | 1 | 0 | /\/\/\/\ |
| $0F | 1 | 1 | 1 | 1 | /_______ |

### Output

The tone channels each produce a 5-bit signal which is then converted to analog with a logarithmic DAC. Note that the least significant bit cannot be controlled by the volume register, it is only used by the YM2149F's double-resolution envelope generator. The logarithmic curve increases by 1.5 decibels for each step in the 5-bit signal. This can easily be implemented as a lookup table.

Some emulator implementations that are based on the AY-3-8190 instead treat it as a 4-bit signal with a 3dB per step curve. Since the only extant 5B game does not use the envelope, the difference is unimportant unless accuracy is desired for homebrew 5B work.

The three output channels are mixed together linearly. The output is mixed with the 2A03 and amplified. It is very loud compared to other audio expansion carts.

The amplifier becomes nonlinear at higher amplitudes, and includes some filtering. [9]

## References
- YM2149 datasheet: http://pdf1.alldatasheet.com/datasheet-pdf/view/103366/ETC/YM2149.html
- GI AY-3-8910 datasheet: http://www.speccy.org/hardware/datasheet/ay38910.pdf
- ↑Period 0 verification for tone/noise
- ↑Period 0 verification for envelope
- ↑Phase counting verification
- ↑No halt verification
- ↑Volume 0 silence verification
- ↑LFSR verification
- ↑Envelope-Volume equivalence verification
- ↑Envelope phase reset verification
- ↑Sunsoft 5B amplifier investigation(ongoing)

# VRC6 audio

Source: https://www.nesdev.org/wiki/VRC6_audio

Konami's VRC6mapper provided 3 extra channels for sound: two pulse waves, and one sawtooth. All channels operate similarly to the native channels in the NES APU.

On some boards, the A0 and A1 lines were switched, so for those boards, registers will need adjustment when emulating ($x001 will become $x002 and vice versa). Registers listed here are how they are for 悪魔城伝説 ( Akumajou Densetsu , iNES mapper 024). For Madara and Esper Dream 2 (iNES mapper 026), you will need to adjust the registers.

## Registers

| Base | +0 | +1 | +2 | +3 |
| $9000 | Pulse 1 duty and volume | Pulse 1 period low | Pulse 1 period high | Frequency scaling |
| $A000 | Pulse 2 duty and volume | Pulse 2 period low | Pulse 2 period high |  |
| $B000 | Saw volume | Saw period low | Saw period high | (mirroring control) |

### Frequency Control ($9003)

Normally you should write $00 to this register on startup to initialize it, and not make any further writes to it. This is what all three original VRC6 games do. $9003 controls the overall frequency of the VRC6 audio.

```text
7  bit  0
---- ----
.... .ABH
      |||
      ||+- Halt
      |+-- 16x frequency (4 octaves up)
      +--- 256x frequency (8 octaves up)

```

```text
H - halts all oscillators, stopping them in their current state
B - 16x frequency, all oscillators (4 octave increase)
A - 256x frequency, all oscillators (8 octave increase)

```
- The halt flag overrides the other flags.
- The 256x flag overrides the 16x flag.
- The 16x/256x flags effectively control a 4-bit and 8-bit right shift of the 12-bit period registers.

### Pulse Control ($9000,$A000)
$9000 controls Pulse 1 $A000 controls Pulse 2

```text
7  bit  0
---- ----
MDDD VVVV
|||| ||||
|||| ++++- Volume
|+++------ Duty Cycle
+--------- Mode (1: ignore duty)

```

### Saw Accum Rate ($B000)

```text
7  bit  0
---- ----
..AA AAAA
  ++-++++- Accumulator Rate (controls volume)

```

### Freq Low ($9001,$A001,$B001)
$9001 controls Pulse 1 $A001 controls Pulse 2 $B001 controls Saw

```text
7  bit  0
---- ----
FFFF FFFF
|||| ||||
++++-++++- Low 8 bits of frequency

```

### Freq High ($9002,$A002,$B002)
$9002 controls Pulse 1 $A002 controls Pulse 2 $B002 controls Saw

```text
7  bit  0
---- ----
E... FFFF
|    ||||
|    ++++- High 4 bits of frequency
+--------- Enable (0 = channel disabled)

```

## Pulse Channels

The VRC6 pulse channels operate similarly to the NES's own pulse channels. The CPU clock rate (1.79 MHz) drives the 12-bit divider F . Every cycle the divider counts down until it reaches zero, at which point the divider resets and the duty cycle generator is clocked.

The duty cycle generator takes 16 steps, counting down from 15 to 0. When the current step is less than or equal to the given duty cycle D , the channel volume V is output, otherwise 0 is output.

When the mode bit M is true, the channel ignores the duty cycle generator and outputs the current volume regardless of the current duty.

Therefore, D and M values provide the following duty cycles:

| D value | Duty (percent) |
| 0 | 1/16 | 6.25% |
| 1 | 2/16 | 12.5% |
| 2 | 3/16 | 18.75% |
| 3 | 4/16 | 25% |
| 4 | 5/16 | 31.25% |
| 5 | 6/16 | 37.5% |
| 6 | 7/16 | 43.75% |
| 7 | 8/16 | 50% |
| M | 16/16 | 100% |

When the channel is disabled by clearing the E bit, output is forced to 0, and the duty cycle is immediately reset and halted; it will resume from the beginning when E is once again set. Thus it is possible to reset phase by clearing and immediately setting E .

When using equivalent duty cycle settings for the VRC6 pulse channels, they will appear inverted compared to their 2A03 counterparts.

The frequency of the pulse channels is very similar to the APU pulse channels. It is a division of the CPU Clock(1.789773MHz NTSC). The output frequency (f) of the generator can be determined by the 12-bit period value (t) written to $9001-9002/$A001-A002.

```text
f = CPU / (16 * (t + 1))
t = (CPU / (16 * f)) - 1

```

## Sawtooth Channel

For the sawtooth, the CPU clock rate drives a 12-bit divider F . Every cycle, the divider counts down until it reaches zero, at which point it reloads and clocks the accumulator. However, it seems that the accumulator only reacts on every 2 clocks.

When clocked, the rate value A is added to an internal 8-bit accumulator. The high 5 bits of the accumulator are then output (provided the channel is enabled by having the E bit set). After A has been added 6 times, on the 7th clock, instead of A being added, the internal accumulator is reset to zero.

For an example, assume an A value of $08

| Step | Accumulator | Output | Comment |
| 0 | $00 | $00 |  |
| 1 | $00 | $00 | (odd step, do nothing) |
| 2 | $08 | $01 | (even step, add A to accumulator) |
| 3 | $08 | $01 |  |
| 4 | $10 | $02 |  |
| 5 | $10 | $02 |  |
| 6 | $18 | $03 |  |
| 7 | $18 | $03 |  |
| 8 | $20 | $04 |  |
| 9 | $20 | $04 |  |
| 10 | $28 | $05 |  |
| 11 | $28 | $05 |  |
| 12 | $30 | $06 |  |
| 13 | $30 | $06 |  |
| 0 | $00 | $00 | (14th step, reset accumulator) |
| 1 | $00 | $00 |  |
| 2 | $08 | $01 |  |

If A is more than 42 (floor(255 / 6)), the accumulator will wrap, resulting in distorted sound.

If E is clear, the accumulator is forced to zero until E is again set. The phase of the saw generator can be mostly reset by clearing and immediately setting E . Clearing E does not reset the frequency divider, however, so the first step of the reset saw may appear shortened.

The frequency of the saw is a division of the CPU Clock(1.789773MHz NTSC). The output frequency (f) of the generator can be determined by the 12-bit period value (t) written to $B001-B002. Note that it divides the clock by 14 instead of 16, unlike the pulse channels.

```text
f = CPU / (14 * (t + 1))
t = (CPU / (14 * f)) - 1

```

## Output

At maximum volume, the pulse channels of the VRC6 are roughly equivalent to the pulse channels of the 2A03 (except inverted). The DAC of the VRC6, unlike the 2A03, appears to be linear.

The final mix is a 6-bit DAC summing the two 4-bit pulse outputs and the high 5 bits of the saw accumulator.

## References
- VRCVI Chip Infoby Kevin Horton
- Forum post: VRC6 $9003 audio enable register?

# VRC7 audio

Source: https://www.nesdev.org/wiki/VRC7_audio

The Konami VRC7, in addition to being a mapper chip, also produces 6 channels of 2-operator FM Synthesis Audio. It is a derivative of the Yamaha YM2413 OPLL, implementing a subset of its features and containing a custom fixed patch set.

VRC7 audio was only used in one game, Lagrange Point . The chip also appears in Tiny Toon Adventures 2 , but this cart does not use the audio, and its board lacks required additional audio mixing circuitry.

## Registers

### Audio Reset ($E000)

```text
7  bit  0
---------
RS.. ..MM
 +-------- Reset expansion sound

```

Setting this bit will silence the expansion audio and clear its registers (including tremolo LFO state, but not including vibrato LFO state). [1]

Writes to $9010 and $9030 are disregarded while this bit is set.

Other bits in this register control mirroring and WRAM. See VRC7: Mirroring Control ($E000).

### Audio Register Select ($9010)

```text
7......0
VVVVVVVV
++++++++- The 8-bit internal register to select for use with $9030

```

This register is write-only.

After writing to this register, the program must not write to $9030 (or $9010 again) for at least 6 CPU clock cycles while the VRC7 internally sets up the address.

### Audio Register Write ($9030)

```text
7......0
VVVVVVVV
++++++++- The 8-bit value to write to the internal register selected with $9010

```

This register is write-only.

After writing to this register, the program must not write to $9010 (or $9030 again) for at least 42 CPU clock cycles while the VRC7 internally handles the write.

Addresses $9010 and $9030 differ in bit A5. This signal corresponds to A0 (pin 10) of a YM2413.

### Register Write Delay

Lagrange Point uses the following delay routine after writes to $9010 and $9030 to ensure enough time passes between writes:

```text
wait_9030:          ; JSR to this label immediately after writing to $9030
    STX $82         ; stores X temporarily (address is arbitrary)
    LDX #$08
@wait_loop:
    DEX
    BNE @wait_loop
    LDX $82         ; restores X
wait_9010:          ; JSR to this label immediately after writing to $9010
    RTS

```

### Internal Audio Registers

The VRCVII appears to have 26 internal registers. Registers $00-$07 define a custom patch that can be played on any channel set to use instrument $0. Registers $10-$15, $20-25, and $30-35 control 6 channels for FM synthesis.

Other register values are ignored, except $0F which is a test register with a few special functions.

#### Custom Patch

| Register | Bitfield | Description |
| $00 | TVSK MMMM | Modulator tremolo (T), vibrato (V), sustain (S), key rate scaling (K), multiplier (M) |
| $01 | TVSK MMMM | Carrier tremolo (T), vibrato (V), sustain (S), key rate scaling (K), multiplier (M) |
| $02 | KKOO OOOO | Modulator key level scaling (K), output level (O) |
| $03 | KK-Q WFFF | Carrier key level scaling (K), unused (-), carrier waveform (Q), modulator waveform (W), feedback (F) |
| $04 | AAAA DDDD | Modulator attack (A), decay (D) |
| $05 | AAAA DDDD | Carrier attack (A), decay (D) |
| $06 | SSSS RRRR | Modulator sustain (S), release (R) |
| $07 | SSSS RRRR | Carrier sustain (S), release (R) |

The patch defines a 2-operator FM unit with a single modulator and carrier. The carrier produces the output tone, and the output of the modulator modulates its frequency. The patch has the following parameters:
- $00/$01 T Tremolo applies amplitude modulation at a predefined rate.
- $00/$01 V Vibrato applies pitch modulation at a predefined rate.
- $00/$01 S Sustain determines whether the operator uses the sustain section of the envelope or not.
- $00/$01 K Key rate scaling adjusts the ADSR envelope speed, faster for high frequencies, slower for low ones.
- $00/$01 MMMM Multiplier is a multiplier on the operator's frequency according to a lookup table (see below).
- $02/$03 KK Key level scaling attenuates the operator at higher frequencies $0 = none, $3 = most.
- $02 OOOOOO Modulator output level, this value reduces the modulator volume in 0.75db increments.
- $03 Q/W Operator waveform, 0 = sine, 1 = half-wave rectified sine (where sine values less than 0 are clipped to 0).
- $03 FFF Feedback applied to modulator according to a lookup table (see below).
- $04/$05 AAAA Attack is the speed of the attack fade in after key-on. $0 = halt, $1 = slowest, $F = fastest.
- $04/$05 DDDD Decay is the speed of the decay fade to sustain after attack. $0 = halt, $1 = slowest, $F = fastest.
- $06/$07 SSSS Sustain is the attenuation after decay, in 3db increments. $0 = highest volume, $F = lowest.
- $06/$07 RRRR Release is the speed of the release fade to silent after sustain. $0 = halt, $1 = slowest, $F = fastest.

If a note is released before the attack or decay finishes, release begins from the current volume level. If the sustain bit is not set in $00/$01 S , release begins immediately after decay.

If the sustain bit is set in the channel control register $2X S (see Channels section below), the release value in the patch is ignored and replaced with $5.

The modulator's sustain bit ( $00 S ) also disables the release section of its envelope. If its sustain bit is set, the Attack, Decay, and Sustain portions of the envelope are used, but when the note is released the modulator will continue to sustain while the carrier releases. The carrier does not behave this way: its envelope always enters release when the note is released.

| $00/$01 MMMM | $0 | $1 | $2 | $3 | $4 | $5 | $6 | $7 | $8 | $9 | $A | $B | $C | $D | $E | $F |
| Multiplier | 1/2 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 10 | 12 | 12 | 15 | 15 |

| $03 FFF | $0 | $1 | $2 | $3 | $4 | $5 | $6 | $7 |
| Modulation Index | 0 | π/16 | π/8 | π/4 | π/2 | π | 2π | 4π |

#### Channels

| Register | Bitfield | Description |
| $10-$15 | LLLL LLLL | Channel low 8 bits of frequency |
| $20-$25 | --ST OOOH | Channel sustain (S), trigger (T), octave (O), high bit of frequency (H) |
| $30-$35 | IIII VVVV | Channel instrument (I), volume (V) |

Each channel X is controlled by three registers at $1X , $2X , and $3X .

The 8 bits of $1X with a 9th bit from bit 0 of $2X create a 9-bit frequency value ( freq ). This is combined with a 3-bit octave value from $2X ( octave ) to define the output frequency ( F ):

```text
     49716 Hz * freq
F = -----------------
     2^(19 - octave)

```

The VRC7 is clocked by an external ceramic oscillator running at 3.58 MHz (roughly twice the NTSC NES CPU clock rate, but not synchronized with it), and it takes 72 internal clock cycles to update all of its channels, which means each channel is updated with a frequency of 49716 Hz (or roughly 36 NES CPU clocks). During these 72 cycles, the channels are output in series rather than mixed (like Namco's 163), but because the frequency is so high it is not audibly different from mixed output.

Writing to register $2X can begin a key-on or key-off event, depending on the value in the trigger bit (T). If the trigger bit changes from 0 to 1 (key-on), a new note begins. If it changes from 1 to 0 (key-off), it will begin the release portion of its envelope which will eventually silence the channel (unless release is $0). If the trigger bit does not change, no new key-on or key-off will be generated.

Using the sustain bit (S) in $2X overrides the normal release value for the patch with a value of $5.

Register $3X selects the instrument patch to use, and chooses a volume. Note that volume value is inverted: $F is the lowest volume and $0 is the highest. There is no silent volume value; its output scale is logarithmic in 3db increments.

#### Test Register $0F

At $0F is an additional test register that responds to the low 4 bits. [2]
- Bit 0: The envelope generators are replaced with constant 0 output (full volume) for both modulator and carrier. The envelopes are still running while their output is overridden.
- Bit 1: Hold LFO phase at zero. This halts, disables, and resets both the tremolo and vibrato LFO.
- Bit 2: Holds and resets waveform phase to zero. The envelopes are not halted, though the output will be silent.
- Bit 3: Update tremolo and vibrato LFOs every sample instead of once every several samples. (Tremolo is 64x faster, and vibrato is 1024x faster.)

## Internal patch set

There are 16 different instrument patches available on the VRC7. With the exception of instrument $0, which can be controlled by registers $00-$07 (see above), these are hardwired into the chip and cannot be altered.

Exact values for the fixed patch were dumped using the VRC7 rewired into a debug mode [3]:

```text
   | 00 01 02 03 04 05 06 07 | Name
---+-------------------------+----------------
 0 | -- -- -- -- -- -- -- -- | (Custom Patch)
 1 | 03 21 05 06 E8 81 42 27 | Buzzy Bell
 2 | 13 41 14 0D D8 F6 23 12 | Guitar
 3 | 11 11 08 08 FA B2 20 12 | Wurly
 4 | 31 61 0C 07 A8 64 61 27 | Flute
 5 | 32 21 1E 06 E1 76 01 28 | Clarinet
 6 | 02 01 06 00 A3 E2 F4 F4 | Synth
 7 | 21 61 1D 07 82 81 11 07 | Trumpet
 8 | 23 21 22 17 A2 72 01 17 | Organ
 9 | 35 11 25 00 40 73 72 01 | Bells
 A | B5 01 0F 0F A8 A5 51 02 | Vibes
 B | 17 C1 24 07 F8 F8 22 12 | Vibraphone
 C | 71 23 11 06 65 74 18 16 | Tutti
 D | 01 02 D3 05 C9 95 03 02 | Fretless
 E | 61 63 0C 00 94 C0 33 F6 | Synth Bass
 F | 21 72 0D 00 C1 D5 56 06 | Sweep

```

The VRC7 instrument ROM dump also shows 3 drum patches. It is believed that these additional patches are an artifact from the YM2413 and are not playable on the VRC7. Curiously, byte $07 of the snare drum ($68) differs from YM2413 ($48):

```text
   | 01 01 18 0F DF F8 6A 6D | Bass Drum
   | 01 01 00 00 C8 D8 A7 68 | Snare Drum / Hi-Hat
   | 05 01 00 00 F8 AA 59 55 | Tom / Top Cymbal

```

## Debug Mode

Pin 15 of the VRC7 is an active-low input that enables a debug mode. In debug mode, it is possible to dump instrument patches from internal ROM, read and write the DAC value, and access serial data similar to the Yamaha YM2413 and other related synthesizers. The VRC7 uses the normal CPU data bus for reading and writing data in this mode, but uses a modified pinout to select the data. The modified pinout is not compatible with the normal Famicom connections in a cartridge. Since the /Debug pin will be tied high in a cartridge, this mode is not normally accessible without physical modification.

Pins 2 and 47 select a high-level mode, while pins 4, 16, and 28 change meaning depending on which mode is selected.

| Mode | Pin 15 | Pin 47 | Pin 2 | Pin 28 | Pin 4 | Pin 16 |
| VRC7 | /DEBUG | CPU M2 | PPU A13 | CPU A13 | CPU R/W | CPU A5 |
| Normal usage | 1 | x | x | x | x | x |
| YM2413 | /DEBUG | MODE0 | MODE1 | /CS | /WR | A0 | Data bus |
| No operation | 0 | 1 | 0 | 1 | x | x |
| Write Address | 0 | 1 | 0 | 0 | 0 | 0 |
| Write Data | 0 | 1 | 0 | 0 | 0 | 1 |
| Read Serial | 0 | 1 | 0 | 0 | 1 | 0 | ---- --DF |
| No operation | 0 | 1 | 0 | 0 | 1 | 1 |
| DAC Test | /DEBUG | MODE0 | MODE1 | /CS | /WR | A0 | Data bus |
| No operation | 0 | 0 | 0 | 1 | x | x |
| Override DAC | 0 | 0 | 0 | 0 | 0 | x | Lower 8 bits |
| No operation | 0 | 0 | 0 | 0 | 1 | x |
| DAC Query | /DEBUG | MODE0 | MODE1 | /CS | /WR | A0 | Data bus |
| Read DAC | 0 | 1 | 1 | x | x | x | Upper 8 bits |
| Instrument Query | /DEBUG | MODE0 | MODE1 | /A2 | /A1 | /A0 | Data bus |
| Read InstROM 0 | 0 | 0 | 1 | 1 | 1 | 1 | SSSS RRRR |
| Read InstROM 1 | 0 | 0 | 1 | 1 | 1 | 0 | AAAA DDDD |
| Read InstROM 2 | 0 | 0 | 1 | 1 | 0 | 1 | MMMM --KK |
| Read InstROM 3 | 0 | 0 | 1 | 1 | 0 | 0 | -FFF TVSK |
| Read InstROM 4 | 0 | 0 | 1 | 0 | 1 | 1 | OOOO OOQW |
| Read 0 | 0 | 0 | 1 | 0 | 1 | 0 | (legend) |
| Read 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| Read 0 | 0 | 0 | 1 | 0 | 0 | 0 |

When /DEBUG (pin 15) is low, CPU A12 (pin 27) acts as an active-low Reset signal (instead of the active-high signal in register $E000) for the YM2413, meaning that it must be high at all times for the audio circuit to be driven.

In "Read Serial" mode, data is returned on the CPU data bus as follows:
- CPU D0: lower 9 bits of phase and envelope amplitude, as seen in the normal self-test mode of the YM2413
- CPU D1: DAC value
- CPU D2-D7: logic 0

In "Override DAC" mode, the lower 8 bits of the DAC are instead driven with the contents of the external data bus. The DAC goes back to normal as soon as this mode is exited.

In "Read InstROM" mode, the current operator's parameters are returned, using the same legend as used above in §Custom Patch. Any bit marked with "-" reads as 0.

#### Rhythm Register $0E

In normal operation, the "rhythm mode" bit in register $0Eis treated as though it were always enabled, resulting only six audible FM channels. The VRC7 has no rhythm DAC, so the 5 rhythm channels are always inaudible.

In debug mode, the rhythm mode bit can be disabled, permitting 9 channels of OPLL audio. (It can also be enabled, but without the rhythm DAC, there is almost no utility in doing so)

## Differences from OPLL

The synthesis core is related to the Yamaha YM2413 OPLL, which is itself a cost-reduced version of the YM3182 OPL2 chip made popular by AdLib and SoundBlaster sound cards.
- Register layout is the same.
- VRC7 has 6 channels, OPLL has 9.
- VRC7 has no rhythm channels, OPLL does (the last 3 channels are either FM or Rhythm on OPLL).
- VRC7 built-in instruments are not the same as OPLL instruments.
- VRC7 has no readily-accessible status register, under normal circumstances it is write-only; OPLL has an undocumented, 2-bit 'internal state' register.
- VRC7 has one DAC and output pin for audio, multiplexed for all 6 channels; OPLL has two DACs and output pins, one for FM and one for Rhythm.

A recording comparing the fixed patches of VRC7(left) and YM2413(right) is available here: File:VRC7 and YM2413 on FAMICOM LP intro.ogg

## References
- VRC7 chip info by Kevin Horton: http://kevtris.org/nes/vrcvii.txt
- YM2413 datasheets: http://www.datasheetarchive.com/YM2413-datasheet.html
- VRC7 audio test program: http://zzo38computer.org/nes_program/vrc7test.zip
- VRC7 patch set revisions 2012, 2017, 2018: http://forums.nesdev.org/viewtopic.php?f=6&t=9141
- Discussion of modulator sustain: http://famitracker.com/forum/posts.php?id=6804
- ↑Forum post:VRC7 and 5B amplifier investigation, and function of silence bit.
- ↑VRC7 test register described
- ↑siliconpr0n: VRC7 Instrument ROM Dump

## External links
- Programmer's guide to the YM2413 from SMSPower
- How logsin and exp tables work in OPL2
- Yamaha FM internal bit depths
- VRC7 discussion on NESdev BBS
- siliconpr0n VRC7 decapsulation photographs

# VT02+ Sound

Source: https://www.nesdev.org/wiki/VT02%2B_Sound

The VT02+ Famiclone consolesinclude a second APU, doubling the number of pulse, triangle and noise channels. Furthermore the single PCM/DPCM channel can use DMA for raw PCM as well, and fetch data from the entire CPU address range. Address Map

```text
$4000-$4003   Pulse 1
$4004-$4007   Pulse 2
$4008-$400B   Triangle 1
$400C-$400F   Noise 1
$4010-$4013   DMC
$4015         Channel enable and length counter status for $4000-$4013
$4020-$4023   Pulse 3
$4024-$4027   Pulse 4
$4028-$402B   Triangle 2
$402C-$402F   Noise 2
$4030         DPCM/Raw PCM selection, output control
$4031         Write 8 bit raw PCM data
$4035         Channel enable and length counter status for $4020-$402F

```
Registers

The meaning of registers $4020-$402F resembles that of registers $4000-$400F. Note that all V.R. Technology Famiclones reverse the 25% and 50% duty cycles, even as V.R. Technology's official emulator EmuVT does not.

## DPCM/Raw PCM selection, output control ($4030)

```text
7654 3210
---- ----
LlMR EeAA
|||| |||+- APU DMA address bit 14 (inverted)
|||| ||+-- APU DMA address bit 15 (inverted)
|||| |+--- 0: Enable output from first APU ($4000-$400F, DPCM or raw PCM written to $4011)
|||| |     1: Disable output from first APU ($4000-$400F, DPCM or raw PCM written to $4011)
|||| +---- 0: Disable output from second APU ($4020-$402F, raw PCM written to $4031 or via DMA)
||||       1: Enable output from second APU ($4020-$402F, raw PCM written to $4031 or via DMA)
|||+------ 0: APU DMA uses DPCM
|||        1: APU DMA uses raw PCM
||+------- 0: Maximum DMA transfer length is 4,081 bytes
||         1: Maximum DMA transfer length is 4,096 bytes
|+-------- 0: Enable loudness of first APU ($4000-$400F, DPCM or raw PCM written to $4011)
|          1: Disable loudness of first APU ($4000-$400F, DPCM or raw PCM written to $4011)
+--------- 0: Enable loudness of second APU ($4020-$402F, raw PCM written to $4031 or via DMA)
           1: Disable loudness of second APU ($4020-$402F, raw PCM written to $4031 or via DMA)

```

Note that the meaning of bit 2 is the exact opposite of bit 3. The direction of the bits' effect is chosen so that writing $00 will result in perfect NES/Famicom-compatible behavior: DMA address A14/A15 set so that transfers are limited to $C000-$FFFF, output enabled from the first and disabled from the second APU, DMA uses DPCM, maximum length is 4,081 bytes, and both APUs loud.

Playing raw PCM via DMA uses the same sampling rates as DPCM. Note that when playing raw PCM data via DMA, the output of the second APU must be enabled first.

## Write 8 bit raw PCM data ($4031)

Identical to register $4011, except that the resolution is eight rather than seven bits.

## Channel enable and length counter status for second APU channels ($4035)

This register is the equivalent of $4015, only that it applies to the second APU's channels.

Write:

```text
7654 3210
---- ----
.... NT43
     |||+- Enable Pulse channel 3
     ||+-- Enable Pulse channel 4
     |+--- Enable Triangle channel 2
     +---- Enable Noise channel 2

```

Read:

```text
7654 3210
---- ----
.... NT43
     |||+- 1=Pulse channel 3's length counter >0
     ||+-- 1=Pulse channel 4's length counter >0
     |+--- 1=Triangle channel 2's length counter >0
     +---- 1=Noise channel 2's length counter >0

```

## Links
- Santa ClausNSF rip
- 100 In 1 (101 In 1) Arcade Action II (AT-103)NSF rip

# APU Frame Counter

Source: https://www.nesdev.org/wiki/APU_Frame_Counter

The NES APUframe counter (or frame sequencer ) generates low-frequency clocks for the channels and an optional 60 Hz interrupt. The name "frame counter" might be slightly misleading because the clocks have nothing to do with the video signal.

The frame counter contains the following: divider, looping clock sequencer, frame interrupt flag.

The sequencer is clocked on every other CPU cycle, so 2 CPU cycles = 1 APU cycle. The sequencer keeps track of how many APU cycles have elapsed in total, and each step of the sequence will occur once that total has reached the indicated amount (with an additional delay of one CPU cycle for the quarter and half frame signals). Once the last step has executed, the count resets to 0 on the next APU cycle.

| Address | Bitfield | Description |
| $4017 | MI--.---- | Set mode and interrupt (write) |
| Bit 7 | M--- ---- | Sequencer mode: 0 selects 4-step sequence, 1 selects 5-step sequence |
| Bit 6 | -I-- ---- | Interrupt inhibit flag. If set, the frame interrupt flag is cleared, otherwise it is unaffected. |

| Side effects | After 3 or 4 CPU clock cycles*, the timer is reset.If the mode flag is set, then both "quarter frame" and "half frame" signals are also generated. |

* If the write occurs during an APU cycle, the effects occur 3 CPU cycles after the $4017 write cycle, and if the write occurs between APU cycles, the effects occurs 4 CPU cycles after the write cycle.

PAL behavior is currently assumed to be the same.

The frame interrupt flag is connected to the CPU's IRQline. It is set at a particular point in the 4-step sequence (see below) provided the interrupt inhibit flag in $4017 is clear, and can be cleared either by reading $4015 (which also returns its old status) or by setting the interrupt inhibit flag.

### Mode 0: 4-Step Sequence (bit 7 of $4017 clear)

| Step | APU cycles | Envelopes & triangle's linear counter(Quarter frame) | Length counters & sweep units(Half frame) | Frame interrupt flag |
| NTSC | PAL |
| 1 | 3728, PUT | 4156, PUT | Clock |  |  |
| 2 | 7456, PUT | 8313, PUT | Clock | Clock |  |
| 3 | 11185, PUT | 12469, PUT | Clock |  |  |
| 4 | 14914, GET | 16626, GET |  |  | Set if interrupt inhibit is clear |
| 14914, PUT | 16626, PUT | Clock | Clock | Set if interrupt inhibit is clear |
| 0 (14915), GET | 0 (16627), GET |  |  | Set if interrupt inhibit is clear |

|  |  | NTSC: 240 Hz (approx.)PAL: 200 Hz (approx) | NTSC: 120 Hz (approx.)PAL: 100 Hz (approx) | NTSC: 60 Hz (approx.)PAL: 50 Hz (approx) |

In this mode, the interrupt flag is set every 29830 CPU cycles, which is slightly (0.166%) slower than the 29780.5 CPU cycles per NTSC PPU frame.

On the PAL RP2A07, this is every 33254 CPU cycles, still slower than the 33247.5 CPU cycles per PAL PPU frame but much closer (only off by 0.0196%).

This IRQ allows the CPU to keep time in scenarios where no NMIsignal is provided.

### Mode 1: 5-Step Sequence (bit 7 of $4017 set)

| Step | APU cycles | Envelopes & triangle's linear counter(Quarter frame) | Length counters & sweep units(Half frame) |
| NTSC | PAL |
| 1 | 3728, PUT | 4156, PUT | Clock |  |
| 2 | 7456, PUT | 8313, PUT | Clock | Clock |
| 3 | 11185, PUT | 12469, PUT | Clock |  |
| 4 | 14914, PUT | 16626, PUT |  |  |
| 5 | 18640, PUT | 20782, PUT | Clock | Clock |
| 0 (18641), GET | 0 (20783), GET |  |  |

|  |  | NTSC: 192 Hz (approx.), uneven timingPAL: 160 Hz (approx.), uneven timing | NTSC: 96 Hz (approx.), uneven timingPAL: 80 Hz (approx.), uneven timing |

In this mode, the frame interrupt flag is never set.

This mode seems to be intended for use with a NMI handler that writes to $4017 once each PPU frame and resets the sequence before it ever reaches step 5, thereby synchronizing the various APU counters to the PPU frame rate and yielding exactly four quarter-frame clocks and two half-frame clocks per PPU frame. This mode has been observed to be primarily used by first-party titles, including the FDS BIOS, and these titles do use it in the way described.

Punch-Out!!and Donkey Kong 3are arcade boards not directly based on the NES, which use the 2A03 CPU as a sound processor in this mode.

| V | T APU |
| Concepts | Registers | Basics | Period table |
| Channels | Pulse 1 and Pulse 2 | Triangle | Noise | DMC |
| Components | Envelope | Sweep | Frame Counter | Length Counter | DMA | Mixer |
| Expansion audio | 2C33 (Disk System) | MMC5 | VRC6 | VRC7 | Namco 163 | Sunsoft 5B | µPD7756 |

# Music

Source: https://www.nesdev.org/wiki/Music

Music is available for the NES. It is most often stored in NSF files, which package the data for one or more songs along with 6502 machine code to play it back. NSF files can be played on a NES or on a PC with an appropriate player which emulates the NES sound hardware and CPU.

The music from a large number of NES games has been "ripped" into NSF format, and people are actively creating new NES musicwith sequencing tools.

Refer to the Music toolswiki page for details.

Some of these general-purpose music engines are designed for making NSFs where the only thing executing is the music player. This means they can be fairly large, and in an NROMgame, their features might not justify their size.

If you want to write your own music engine that targets the NES APU, you'll first need a lookup table for the note periods. This means you'll need the frequencies that correspond to various pitches. See APU period table, Wikipedia:Pitch (music), Wikipedia:Semitone, and Wikipedia:Equal temperament.

## NES Audio
- NES APU

# NSF

Source: https://www.nesdev.org/wiki/NSF

The NES Sound Format (.nsf) is used for storing and playing music from the NES and related systems. It is similar to the PSID file format for C64 music/sound, where one rips the music/sound code from an NES game and prepends a small header to the data. An NSF player puts the music code into memory at the proper place, based on the header, prepares sound hardware, then runs it to make music. An NSF can be played on NES/Famicom hardware or in an emulator (NSF player or NES emulator).

There are two extensions of the NSF format:
- NSFe- Allows a playlist with track titles and times, as well as other metadata.
- NSF2- A backward compatible extension including NSFe's metadata, IRQ and other features.

## Header Overview

All 2-byte address and period values are little endian. For example, an NTSC play speed of `FF 40 `means $40FF, or 16639 microseconds.

```text
offset  # of bytes   Function
----------------------------
$000    5   STRING  'N','E','S','M',$1A (denotes an NES sound format file)
$005    1   BYTE    Version number $01 (or $02 for NSF2)
$006    1   BYTE    Total songs   (1=1 song, 2=2 songs, etc)
$007    1   BYTE    Starting song (1=1st song, 2=2nd song, etc)
$008    2   WORD    (lo, hi) load address of data ($8000-FFFF)
$00A    2   WORD    (lo, hi) init address of data ($8000-FFFF)
$00C    2   WORD    (lo, hi) play address of data ($8000-FFFF)
$00E    32  STRING  The name of the song, null terminated
$02E    32  STRING  The artist, if known, null terminated
$04E    32  STRING  The copyright holder, null terminated
$06E    2   WORD    (lo, hi) Play speed, in 1/1000000th sec ticks, NTSC (see text)
$070    8   BYTE    Bankswitch init values (see text, and FDS section)
$078    2   WORD    (lo, hi) Play speed, in 1/1000000th sec ticks, PAL (see text)
$07A    1   BYTE    PAL/NTSC bits
                bit 0: if clear, this is an NTSC tune
                bit 0: if set, this is a PAL tune
                bit 1: if set, this is a dual PAL/NTSC tune
                bits 2-7: reserved, must be 0
$07B    1   BYTE    Extra Sound Chip Support
                bit 0: if set, this song uses VRC6 audio
                bit 1: if set, this song uses VRC7 audio
                bit 2: if set, this song uses FDS audio
                bit 3: if set, this song uses MMC5 audio
                bit 4: if set, this song uses Namco 163 audio
                bit 5: if set, this song uses Sunsoft 5B audio
                bit 6: if set, this song uses VT02+ audio
                bit 7: reserved, must be zero
$07C    1   BYTE    Reserved for NSF2
$07D    3   BYTES   24-bit length of contained program data.
                If 0, all data until end of file is part of the program.
                If used, can be used to provide NSF2 metadata
                in a backward compatible way.
$080    nnn ----    The music program/data follows

```

Strings are usually encoded in plain ASCII. In most game rips Japanese titles have been romanized into plain ASCII. More rarely NSFs have also used extended characters, the most common of which is Windows CP-932(Shift-JIS) for Japanese titles. Windows CP-1252(Latin) encoding examples may also exist.

NSF2and NSFeshould use UTF-8 instead, or plain ASCII for backward compatibility.

## Loading a tune into RAM

If file offsets $070 to $077 have $00 in them, then bank switching is not used. Data should be read from the file beginning at $080 and loaded contiguously into the 6502 address space beginning at the load address until the end of file is reached.

Some FDS NSFs use a load address below $8000 to fill in the $6000-7FFF range. It is recommended to use bankswitching to accomplish this instead, because it is not universally supported.

### Bank Switching

If any of the bytes from $070 to $077 in the file header are nonzero then bank switching is used. In this case, take the logical AND of the load address with $0FFF, and the result specifies the number of bytes of padding at the start of the ROM image. The ROM image should consist of a contiguous set of 4k banks, read directly from the NSF file beginning at $080 after inserting the requested number of pad bytes. If the file does not have enough data to fill the last bank completely, it may be padded out.

The 6502's address space is divided into 8 4k bank switchable blocks. For each block the current bank is controlled by writing the bank number to at corresponding register at $5FF8 through $5FFF. The initial bank assignment is determined by bytes $070 through $077 in the file.

```text
NSF    Address      Register
====   ==========   ========
$070   $8000-8FFF   $5FF8
$071   $9000-9FFF   $5FF9
$072   $A000-AFFF   $5FFA
$073   $B000-BFFF   $5FFB
$074   $C000-CFFF   $5FFC
$075   $D000-DFFF   $5FFD
$076   $E000-EFFF   $5FFE
$077   $F000-FFFF   $5FFF

```

The initial bank assignment should be done before any call to the INIT routine. Once the ROM image has been built from the NSF file, this can be set up simply by writing the 8 values from the file header $070-077 to the corresponding registers $5FF8-$5FFF.

If the INIT routine needs to change the bank assignments based on the selected song, it may do so by writing the bank control registers.

#### FDS Bankswitching

If the FDS expansion is enabled, bank switching operates slightly differently. Two additional registers at $5FF6 and $5FF7 control the banks $6000-6FFF and $7000-7FFF respectively, and the initial load values at $076 and $077 now specify the banks used for $6000-7FFF as well as $E000-FFFF (these regions will both be set up to use the same banks before INIT is called).

Because the FDS has a RAM area at $8000-DFFF for the disk image to be loaded to, that means this area is writable when the FDS expansion is enabled. Some NSF player implementations will treat this like bankswitched RAM, and some players will treat an FDS bank switch operation as a copy into RAM. Hardware players are more likely to use bankswitched RAM.

This has a number of caveats:
- Writes may be mirrored if the same bank is used in multiple places. Care should be taken to avoid accidental overwrites when the same bank appears more than once in the bankswitch table. In particular, unique banks should be used for memory regions that must be written to.
- Since the FDS itself was incapable of mirrored writes like this and many players will not have them, mirrored writes should not intentionally be used to store the same data in two memory locations. It is a side effect, not a supported feature.
- Writes to the area may or may not persist in the bank written to if it is switched out and then switched back in. This is another side effect that should be accounted for, but not relied upon.
- Writes may or may not persist between songs, depending on whether the NSF player reloads the NSF image when the song is changed. Hardware players are not likely to reload, but software players may.

See also the notes on multi-chip tunesbelow.

#### Example

METROID.NSF will be used for the following explanation.

```text
The file is set up like so:  (starting at $070 in the file)

$070: 05 05 05 05 05 05 05 05
$078: 00 00 00 00 00 00 00 00
$080: ... music data goes here...

```

Since $070-$077 are something other than $00, this NSF is using bank switching. The load address given is $8000. The load address AND $0FFF specifies 0 bytes of padding, so we set up our ROM image with contiguous data starting from $080 in the file.

This NSF has 6 4k banks in it, numbered 0 through 5. It specifies that each of the 8 memory regions should be switched to bank 5, which begins at $05 * $1000 bytes in the ROM image.

## Initializing a tune

The desired song number is loaded into the accumulator register A, and the X register is set to specify specify PAL (X=1) or NTSC (X=0).

Valid song numbers are 0 to one less than the number of songs (specified at $006 in the header). The first selected song is in the header at $007. The NSF player should display to the user song numbers from 1 up to and including the number of songs, and these should correspond to the same number - 1 loaded into register A. Note that when choosing the first song from the value in $007, subtract 1 from it before loading that value into register A.
- Write $00 to all RAM at $0000-$07FF and $6000-$7FFF.
- Initialize the sound registers by writing $00 to $4000-$4013, and $00 then $0F to $4015.
- Initialize the frame counterto 4-step mode ($40 to $4017).
- If the tune is bank switched, load the bank values from $070-$077 into $5FF8-$5FFF.
- Set the A register for the desired song.
- Set the X register for PAL or NTSC.
- Call the music INIT routine.

The INIT routine MUST finish with an RTS instruction before music playback will begin. At this point, the NSF player will begin executing the PLAY routine at the specified interval.

If this is a single standard tune (PAL or NTSC but not both) the INIT routine MAY ignore the X register. Otherwise, it SHOULD use this value to determine how to set pitches and tempo for the appropriate platform.

The use of the $4017 register is not well supported by existing NSF players. The NSF should not normally clear bit 6 (the IRQ disable bit), though the Pseudo-IRQ Techniquerelies on being able to do this.

While the NSF1 specification never guaranteed anything for Y on entry to INIT, for better forward compatibility with NSF2's non-returning INITfeature, it is recommended that the player set Y to 0, or at least some value that is not $80 or $81, before calling INIT.

## Playing a tune

Once the tune has been initialized, it can now be played. To do this, simply call the routine at the PLAY address at the rate determined by the file header at $06E-06F (NTSC) or $078-079 (PAL).

The playback rate is determined by this formula:

```text
        1000000                  1000000
rate = ---------       period = ---------
        period                    speed

```

Where period is the value you place at $06E-$06F in the file, and rate is how often the PLAY routine should be called in Hz.

The following playback rates are common:
- 60.002 Hz (recommended by the original NSF specification, close to APU timer IRQ rate): 16666 ($411A)
- 60.099 Hz (actual NTSC NES frame rate): 16639 ($40FF)
- 50.007 Hz (suggested PAL NES frame rate): 19997 ($4E1D)

Nonstandard rates may be difficult for hardware players. If the rate is much faster the PLAY routine may not be short enough to execute in the specified amount of time.

The PLAY routine will be called at the specified interval. If the X register passed to INIT was 1 (PAL), it will be called at the rate specified by $078-079, and if 0 (NTSC), it will use the rate at $06E-06F.

A PLAY routine should normally finish with an RTS instruction, but is not required to do so. A non-returning PLAY will cause problems for NSF players that use the same CPU to control the user interface and to run the NSF, such as NSF players that run on an NES. It is strongly recommended to return every few frames if at all possible, such as when no PCM is playing. If PLAY takes longer to finish than the specified interval, that interval may be skipped and PLAY may not be called again until the next one.

Some popular modern NSF engines use a non-returning PLAY to implement an output stream of PCM sound (e.g. SuperNSF, MUSE, Deflemask), and this can also be combined with a Pseudo-IRQ technique.

## Sound Chip Support

Byte $07B of the file stores the sound chip flags. If a particular flag is set, those sound registers should be enabled. If the flag is clear, then those registers should be disabled. All I/O registers within $8000-FFFF are write only and must not disrupt music code that happens to be stored there. Some audio register addresses have mirrors in their original hardware mappers, but NSF code should use only the lowest address for each register, listed here.

### APU
- Uses registers $4000-4013, and $4015. See APUfor more information.
- $4015 is set to 0F on reset by most players. It is better if the NSF does not assume this and initializes this register itself, but there are several existing NSF files that require it (Battletoads, Castlevania and Gremlins 2 are examples).
- The APU interrupts that can be generated via $4015 and $4017 are not reliably available across NSF players, and have usually been considered out of bounds for NSF rips. NSF2can explicitly allow them, however.
- $4017 has other features that are not consistently supported across NSF players.

### VRCVI
- Uses registers $9000-9003, $A000-A002, and $B000-B002, write only. See VRC6 Audiofor more information.
- The A0 and A1 lines are flipped on a few games. If you rip the music and it sounds all funny, flip around the xxx1 and xxx2 register pairs. (i.e. 9001 and 9002) Esper2 and Madara will need this change, while Castlevania 3j will not.

### VRCVII
- Uses registers $9010 and $9030, write only. See VRC7 Audiofor more information.

### FDS Sound
- Uses registers from $4040 through $4092. See FDS Audiofor more information.

Notes:
- $6000-DFFF is assumed to be RAM, since $6000-DFFF is RAM on the FDS. $E000-FFFF is usually not included in FDS games because it is the BIOS ROM. However, it can be used on FDS rips to help the ripper (for modified PLAY / INIT addresses).
- Bank switching is different if FDS is enabled. $5FF6 and $5FF7 control banks at $6000-6FFF and $7000-7FFF, and the NSF header $076-$077 initialized both $6000-7FFF and $E000-FFFF. See above.

### MMC5 Sound
- Uses registers $5000-5015, write only as well as $5205 and $5206, and $5C00-5FF5. see MMC5 Audiofor more information.

Notes:
- $5205 and $5206 are a hardware 8 * 8 multiplier. The idea being you write your two bytes to be multiplied into 5205 and 5206 and after doing so, you read the result back out.
- $5C00-5FF5 should be RAM to emulate EXRAM while in MMC5 mode.

### Namco 163 Sound
- Uses registers $4800 and $F800. See Namco 163 audiofor more information.

### Sunsoft 5B Sound
- Audio in the Sunsoft 5B mapper, a variant of the FME-7, uses registers $C000 and $E000. See Sunsoft audio.
- Many players do not implement the noise or envelope capabilities of the 5B, as they were not used in the only 5B game, Gimmick.

### Multi-chip tunes

Multiple expansion chips can be used at the same time, but because this was not something that was ever supported by an original Famicom games, actual practice with multi-expansion NSF varies.

Some mappers mirror their audio registers at addresses that would conflict. Many NSF players only support the lowest address, which avoids these conflicts, but the following conflicts may need resolution in an attempted hardware multi-chip implementation:
- N163's address port $F800 overlaps a mirror of Sunsoft 5B's data port $E000. This can be avoided by setting Sunsoft 5B's address port $C000 to $0E or $0F (unused internal registers) before writing to the N163.
- VRC6 and VRC7 have a conflict at ports $9010 and $9030, where the VRC6's pulse 1 control port is mirrored.
- VRC7 and N163 each have a mute or reset register at $E000, which conflicts with Sunsoft 5B's data port. Since writing $E000 with bit 6 set will silence either of these, an emulator may wish to ignore writes to $E000 for VRC7/N163 if 5B is also present.
- FDS will make the normally read-only area from $8000-$DFFF writable. This may cause corruption of these areas when writing to VRC6, VRC7, or 5B audio registers. The safest way to avoid this is to make sure your code and data do not fall within these addresses, so that you may safely write to them. NSF player implementations may wish to disable memory writes at these addresses to avoid the conflict.

## Caveats
- The starting song number and maximum song numbers start counting at 1, while the INIT address of the tune starts counting at 0. Remember to pass the desired song number minus 1 to the INIT routine.
- The NTSC speed word is used only for NTSC tunes and dual PAL/NTSC tunes. The PAL speed word is used only for PAL tunes and dual PAL/NTSC tunes.
- If bit 1 of the PAL/NTSC is set, indicating a dual PAL/NTSC NSF, bit 0 may be interpreted as a preference for PAL or NTSC. Most players do not support this, however, and some older players may have problems if bit 0 is set.
- The length of the text in the name, artist, and copyright fields must be 31 characters or less. There has to be at least a single NULL byte ($00) after the text, between fields.
- If a field is not known (name, artist, copyright) then the field must contain the string "<?>" (without quotes).
- There should be 8K of RAM present at $6000-7FFF. MMC5 tunes need RAM at $5C00-5FF7 to emulate its $EXRAM. $8000-FFFF should be read-only (not writable) after a tune has loaded. The only time this area should be writable is if an FDS tune is being played.
- Do not assume the state of anything on entry to the INIT routine except A and X. Y can be anything, as can the flags.
- Do not assume the state of anything on entry to the PLAY routine. Flags, X, A, and Y could be at any state.
- The stack sits at $01FF and grows down. The precise position of the stack on INIT or PLAY is not guaranteed, as the NSF player may need to use the top area of the stack for its own internal purpose. Make sure the tune does not attempt to modify $01F0-01FF directly. (Armed Dragon Villigust did, and was relocated to 2xx for its NSF.)
- The NSF should not initialize the stack pointer in INIT or PLAY . These subroutines are called from the player; some software emulators may not have a problem with this, but it will almost certainly cause an error on a hardware player. It is the player's job to initialize the stack pointer, and some hardware players (e.g. PowerPak) will place their own variables on the stack.
- RAM should be addressed from $0000-07FF, and should not expect mirror addresses to work. If the tune writes outside this range, e.g. $1400 it should be relocated. (Terminator 3 did this and was relocated to 04xx for NSF.)
- The vector table at $FFFA-FFFF should not be filled with code or data by the NSF. These can be overridden by hardware NSF players.
- Instructions which modify the stack, PLP, PHP, and TXS must be used with great care, as a player may need to rely on being able to store data at the end of the stack. An NSF should use the stack pointer given; the stack past this pointer should remain intact, as it may be needed by the player.
- Instructions CLI, SEI, and BRK are problematic, and should usually be avoided. The NSF itself should generally not attempt to interfere with IRQs, as many NSF players do not have an IRQ implementation. One notable exception is using SEI in a non-returning PLAY routine for a pseudo-IRQ technique. BRK should generally not be used, as it reads the IRQ routine address from the vector table which is reserved for the player's use.
- PowerPak's NSF play incorrectly does not restore the startup banks when switching tracks, so unless the PLAY routine always leaves with the INIT routine in its starting bank, switching tracks will fail on it.

## Summary of Addresses

These lists all the addresses which should be readable by the code in the NSF; no other addresses should ever be accessed for reading:
- $0000-$01EF
- $01F0-$01FF (may be used internally by NSF player)
- $0200-$07FF
- $4015
- $4040-$407F (if FDS is enabled)
- $4090 (if FDS is enabled)
- $4092 (if FDS is enabled)
- $4800 (if Namco 163 is enabled)
- $5205-$5206 (if MMC5 is enabled)
- $5C00-$5FF5 (if MMC5 is enabled)
- $6000-$FFF9

These lists all the addresses which should be writable by the code in the NSF; no other addresses should ever be accessed for writing:
- $0000-$01EF
- $01F0-$01FF (may be used internally by NSF player; do not use for non-stack variables)
- $0200-$07FF
- $4000-$4013 (always clear bit7 of $4010)
- $4015
- $4040-$4080 (if FDS is enabled)
- $4082-$408A (if FDS is enabled)
- $4800 (if Namco 163 is enabled)
- $5205-$5206 (if MMC5 is enabled)
- $5C00-$5FF5 (if MMC5 is enabled)
- $5FF6-$5FF7 (if bankswitching and FDS is enabled)
- $5FF8-$5FFF (if bankswitching is enabled)
- $6000-$7FFF
- $8000-$DFFF (if FDS is enabled)
- $9000-$9003 (if VRC6 is enabled)
- $9010 (if VRC7 is enabled)
- $9030 (if VRC7 is enabled)
- $A000-$A002 (if VRC6 is enabled)
- $B000-$B002 (if VRC6 is enabled)
- $C000 (if Sunsoft 5B is enabled)
- $E000 (if Sunsoft 5B is enabled)
- $F800 (if Namco 163 is enabled)

Reading/writing anything other than specified here results in undefined behaviour.

## Pseudo-IRQ Technique

Some modern NSFs use a trick [1]first made popular by Deflemask, primarily intended to support PCM sample playback. This technique is not universally supported, because it may rely on a lack of conflict with the player's implementation. Some hardware implementations do support it correctly (e.g. PowerPak), and it also works with several software NSF players.

The technique uses a non-returning PLAY in the following way:
- Use SEI to mask interrupts.
- Enable the APU interrupt by writing to $4017.
- Enter a sample playback loop, polling $4015 to see if an APU IRQ is pending.
- When the poll registers the APU IRQ flag (occurring at 60 hz on NTSC), temporarily exit the sample playback loop to do other tasks.
- Return to step 3, never returning from PLAY .

## See also
- List of NES music composers
- Emulation Libraries: NSF Players
- iNES Mapper 031: Cart mapper with NSF-inspired bankswitching
- NSFDRV

## References
- Kevtris' Official NSF spec- the original NSF specification
- Kevtris' HardNES- a hardware NSF player project
- ↑NSF PCM technique (via Deflemask)forum post

# NSF2

Source: https://www.nesdev.org/wiki/NSF2

NSF2 is an extension of the NSFfile format, first publicly implemented in 2019, with the following additions:
- Backward compatibility with the original NSF format where the new features are optional.
- Extensible metadatathrough incorporation of the NSFeformat, of both optional and mandatory varieties.
- A programmable timer IRQ, as well as explicit access to the existing DMCand Frame CounterIRQ devices.
- An alternative non-returning INITparadigm for playback.
- All strings contained in NSF2 should be encoded in UTF-8 format.

## File Format

This header is the same as the original NSF header, but with the following additions:

```text
offset  # of bytes   Function
----------------------------
$005    1   BYTE    Version number, equal to 2
$07C    1   BYTE    NSF2 feature flags
                bits 0-3: reserved, must be 0
                bit 4: if set, this NSF may use the IRQ support features
                bit 5: if set, the non-returning INIT playback feature will be used
                bit 6: if set, the PLAY subroutine will not be used
                bit 7: if set, the appended NSFe metadata may contain a mandatory chunk required for playback
$07D    3   BYTES   24-bit length of the NSF program data, allowing metadata to follow the data

```

If a non-zero value appears in $7D-7F, NSFe metadatamay be appended to the file immediately following the end of the data.

Non-mandatory metadata is available even in the original version 1 NSFby using these bytes to indicate a data length, but older players will assume that this metadata is part of the program ROM. Since NSF playback is mostly deterministic, it's reasonable to ensure that misinterpreted appended data isn't used by the NSF and won't harm playback. For this reason if the metadata is optional information (e.g. track names), and no other NSF2 features are required, it may be preferable to leave the version as 1.

If the file version is 1, any flags in byte $7C should be ignored.

## IRQ Support

This bit explicitly allows use of IRQs by the NSF program. It provides its own programmable cycle timed IRQ, but also allows the use of APU IRQs generated by the DMCor Frame Counter.

Using this bit implies a vector overlay provided by the player at $FFFA-$FFFF. The NMI and Reset vectors at $FFFA and $FFFC are reserved for the player implementation (see: #Non-Returning INIT) but the IRQ vector at $FFFE-$FFFF will be provided as RAM. This is an overlay on top of any underlying NSF data, so the NSF program must explicitly write a vector to $FFFE before enabling interrupts.

For convenience, before INIT the host system should initialize the IRQ vector RAM with the starting contents of $FFFE-$FFFF. (Added 2022-12-4)

The first time INIT is called, the IRQ inhibit flag will be set (SEI), and the IRQ timer device will be set to inactive. The NSF program will be responsible for enabling interrupts (CLI). The NSF player will never change the IRQ flag directly, though if used in combination with the non-returning INIT feature the PLAY routine will have an implied SEI via being called from an NMI (see below).

### IRQ Timer

A cycle counting timer device will be supplied with three readable and writable registers:

```text
$401B R/W - Low 8 bits of counter reload.
$401C R/W - High 8 bits of counter reload.
$401D W - Activate with bit 0 set, deactivate with bit 0 clear.
$401D R - Acknowledges IRQ. Bit 7 returns IRQ flag before clearing it. Bit 0 returns active status.

```

If active, every cycle the counter will be decremented. When the counter goes below 0 it will enable its IRQ flag, and be reloaded with the value given at $401B/C.

If inactive it will instead reload the counter on every cycle.

The IRQ line will be asserted whenever the IRQ flag is set as the counter underflows, until it is acknowledged by reading $401D.

Bit 7 read from $401D might be used to distinguish between different IRQ sources, if this is required.

The period of this timer with a reload value of N will repeat every N+1 cycles . A reload value of 0 means it will repeat every 1 cycle.

The automatic reload allows an IRQ to repeat at a dependable interval of cycles, minimizing jitter.

## Non-Returning INIT

This bit changes the method of playback to a paradigm where INIT is allowed to run indefinitely, and PLAY will interrupt it as an NMI:
- The INIT routine will be called twice.
- The first call of INIT will be as NSF, but additionally the Y register will contain $80. This call must return.
- NMI is be enabled.
- A second call of INIT, with the same 'A' and 'X' as the first call, but Y will now contain $81. This call does not have to return.
- PLAY will be called by an NMI wrapper, interrupting the still running INIT function.

The NMI wrapper is implementation-defined, and part of the player. PLAY will not be called directly by the NMI vector, and must end with an RTS, not an RTI.

The NMI wrapper will be responsible for saving and restoring A,X,Y. When PLAY is called, there is an implied SEI by the enclosing NMI, which should be considered if also using the IRQ feature. The NMI wrapper should disable and re-enable the NMI signal to prevent re-entry if PLAY runs long.

After PLAY returns, the NMI wrapper may also want to do additional things like check user input or update its UI. An ideal NSF2 player should keep this wrapper as minimal as possible, but for wider compatibility the NSF program should not rely on any specific timing for this.

As with the IRQ feature, this also requires a vector memory overlay at $FFFA-FFFF. This replaces any data from the NSF program at that location, and the specific vectors for $FFFA (NMI) and $FFFC (Reset) are reserved to be provided by the player.

The second INIT is allowed to return, in which case the player should fall back to its own infinite loop. (INIT will not be called a third time.)

A Y value other than $80 or $81 can be interpreted as a player that doesn't support this feature, which may be used to create a fallback for compatibility. No existing pre-NSF2 players are known to have used these values for Y on INIT [1].

## Suppressed PLAY

If this bit is set, the PLAY routine will never be called. This is mostly intended for use with the non-returning INIT feature, allowing it to continue uninterrupted.

Hardware player implementations may reserve the need to still execute brief NMI interruptions during non-returning INIT, even if suppressed, to allow its player program to remain responsive to user interaction. Ideally, however, the non-returning INIT should not be interrupted at all if PLAY is disabled.

This bit does not by itself imply NMI-driven PLAY, even though the non-returning INIT does.

## Metadata

Optional metadata may be appended immediately following the data. It appears at a file offset of the 24-bit data length at $7D-7F (little-endian) plus $80 for the length of the NSF header.

It is identical to the format described at NSFe, but with the following differences:
- There is no 'NSFE' fourCC at the start of the NSF2 metadata. The first byte begins the first contained chunk header.
- Chunks that are already part of the NSF format must not be included. 'INFO', 'DATA', 'BANK' and 'NSF2' chunks should not be used.

The 'RATE' and 'regn' chunks, while partially redundant, may be included to provide additional Dendy region playback information. The fields in the NSF header can supply a backward compatible fallback for this case if the metadata is not parsed.

If bit 7 of header byte $7C is set, parsing the metadata becomes mandatory . This means that the appended metadata contains a mandatory chunk, indicated by a fourCC of capital letters, that must be parsed and understood by the player to be able to play back the file.

The mandatory bit is intended for cases where extra information may be needed for correct emulation. Examples:
- A 'VRC7' chunk can be used to substitute VRC7 with the related but not compatible YM2413 chip.
- A chip with embedded sample data could be provided in an appropriate chunk.

This mandatory indication allows future expansion to the format without having to redefine the NSF header.

Metadata should end with an NEND chunk.

## Players

The following implementations of NSF2 exist:
- NSFPlay2.4 beta 9 (2019-3-1)

## Notes

Though the ideal NSF2 player will not be encumbered by these problems, the are a few suggestions for NSF programs for increased compatibility with potential hardware players that might not be able to provide all features:
- For non-returning INIT use a standard PLAY rate specified in the header. Hardware players may not be able to adjust their NMI timing.
- If using IRQ or non-returning INIT, do not bankswitch $F000. This allows the vector overlay to be applied directly to the NSF data on load instead of requiring an extra decoder.
- Some NSF players already have some IRQ support. Placing the IRQ vector at $FFFE as well as writing to it can be compatible with both NSF1+IRQ and NSF2.
- The older NSF1 had no specification for string encoding. UTF-8 is the standard for NSF2, but for backward compatibility only ASCII should be used for the fields in the header. An NSFe 'auth' chunk can be used to override the header's title/author/copyright with UTF-8 strings.

The vector overlay is not implied by the header version 2, it will only be used if either the IRQ or non-returning INIT features are specified in byte $7C.

## Reference
- nes-audio-tests- Test NSF files for NSF2 features
- nsfe_to_nsf2.py- Tool for converting NSFe files to NSF + Metadata
- nsf2_strip.py- Tool for stripping NSFe metadata from NSF
- 2018 forum discussion- rainwarrior's 2018 NSF2 proposal
- NSF 2.0 forum discussion- Kevtris' 2010 NSF2 proposal
- ↑NSF player Y INIT survey

# NSFe

Source: https://www.nesdev.org/wiki/NSFe

NSFe is the Extended Nintendo Sound Format created by Disch and popularized by the NotSoFatsoNSF player. It is based on the original NSFfile format, but its data is organized differently and is not backward compatible with it.

The primary goal of NSFe was to add easily extensible metadata that the NSF format could not accommodate, such track names and times.

NSFe's chunky metadata has subsequently been incorporated into the NSF2format.

All integers use a little-endian format.

## Structure

The NSFe begins with a four byte header, containing the four characters 'NSFE'.

```text
offset  # of bytes   Function
----------------------------
$0000   4   FOURCC   'N','S','F','E' (header)

```

After the header, a series of chunks will appear.

UTF-8 encoding is recommended for all strings used by this format.

## Chunks

All chunks have the same primary structure:

```text
offset  # of bytes   Function
----------------------------
$0000   4   DWORD    Length of chunk data (n). Does not include the chunk's 8 byte header.
$0004   4   FOURCC   Four character chunk ID.
$0008   n   ----     Chunk data of specified length.

```

There are three chunks that are required for a well formed NSFe:
- 'INFO' - Similar to an NSF header, must appear before 'DATA' chunk.
- 'DATA' - Raw ROM data.
- 'NEND' - Last NSFe chunk in file.

Note the 'INFO' chunk must precede the 'DATA' chunk, and the 'NEND' chunk marks the end of the file; no further chunks should be read past 'NEND'.

If the first byte of a chunk's FourCC ID is a capital letter (i.e. 'A' to 'Z'), it indicates that this chunk is mandatory, and if the NSFe player cannot read this type of chunk it should not attempt to play the file. All other chunks are considered optional, and may be skipped by the NSFe player if necessary.

The NSFe format does not have a version number. Future revisions of the format, if necessary, can be accomplished with new mandatory chunk types.

### INFO

This required chunk describes the music data contained. This is similar to the NSF header.

```text
offset  # of bytes   Function
----------------------------
$0000   2   WORD    (lo, hi) load address of data ($8000-FFFF)
$0002   2   WORD    (lo, hi) init address of data ($8000-FFFF)
$0004   2   WORD    (lo, hi) play address of data ($8000-FFFF)
$0006   1   BYTE    PAL/NTSC bits
                bit 0: if clear, this is an NTSC tune
                bit 0: if set, this is a PAL tune
                bit 1: if set, this is a dual PAL/NTSC tune
                bits 2-7: not used. they *must* be 0
$0007   1   BYTE    Extra Sound Chip Support
                bit 0: if set, this song uses VRC6 audio
                bit 1: if set, this song uses VRC7 audio
                bit 2: if set, this song uses FDS audio
                bit 3: if set, this song uses MMC5 audio
                bit 4: if set, this song uses Namco 163 audio
                bit 5: if set, this song uses Sunsoft 5B audio
                bit 6: if set, this song uses VT02+ audio
                bit 7: future expansion: *must* be 0
$0008   1   BYTE    Total songs   (1=1 song, 2=2 songs, etc)
$0009   1   BYTE    Starting song (0=1st song, 1=2nd song, etc)

```

Note the following differences from NSF:
- Title, author, and copyright information is not mandatory. See the 'auth' chunk for details.
- If bankswitching is required, it is specified in a subsequent 'BANK' chunk.
- The play routine will be called at the NMI rate for the specified system (NTSC or PAL) unless a 'RATE' chunk is used.
- The first song in the NSFe is 0, unlike NSF which begins with 1.

This chunk must be at least 9 bytes long. If starting song is missing, 0 may be assumed. Any extra data in this chunk may be ignored.

This chunk may not be used in NSF2metadata.

### DATA

This chunk contains the raw ROM data. It will be placed at the load address specified by the 'INFO' chunk, unless bankswitched (the same as in NSF). There is no minimum length for this chunk, but data past 1MB is unusable due to the bank switching mechanisms of the NSF mapper.

This chunk may not be used in NSF2metadata.

### NEND

This chunk may be any length, but any contained data may be ignored. Typically it will have 0 length.

Any data following the 'NEND' chunk will be ignored.

### BANK

If the bank chunk is present, this NSFe should use bankswitching, and it contains 8 bytes specifying the 8 banks to initialize with. See NSFfor bankswitching details.

If this chunk is less than 8 bytes, presume 0 for the missing bytes. If longer, ignore the extra bytes.

This chunk may not be used in NSF2metadata.

### RATE

```text
offset  # of bytes   Function
----------------------------
$0000   2   WORD    (lo, hi) Play speed, in 1/1000000th sec ticks, NTSC
$0002   2   WORD    (lo, hi) Play speed, in 1/1000000th sec ticks, PAL (Optional)
$0004   2   WORD    (lo, hi) Play speed, in 1/1000000th sec ticks, Dendy (Optional)

```

This chunk has 4 bytes. If present, the NSFe should use a custom rate for calling the PLAY routine. See equivalent in NSFheader at $06E and $078.

If the NSFe uses the default video refresh rates for PLAY, this chunk should be omitted for compatibility with older players.

If the Dendy speed is omitted, any Dendy playback should use the PAL speed. (If the PAL speed is omitted, its default rate should be used.) Use with the regnchunk to enable Dendy playback.

(Added 2018-1-2)

### NSF2

A 1 byte chunk containing the equivalent of the NSF2flags byte from its header at offset $7C. This permits the use of NSF2 features from an NSFe file.

This chunk may not be used in NSF2metadata.

(Added 2019-3-2)

### VRC7

The first byte designates a variant device replacing the VRC7 at the same register addresses.
- 0 = VRC7
- 1 = YM2413

The next 128 or 152 bytes are optional, and contain a replacement patch set for the device. The first 8 bytes of this patch set are expected to be zero, since on the VRC7 patch 0 is custom-only. The larger 152-byte version of the patch set may additionally customize the rhythm mode instruments of YM2413 (not accessible on VRC7).

If a replacement patch set is not contained in this chunk, an appropriate default patch set should be used for the selected device.

(Added 2019-3-12)

### plst

This optional chunk specifies the order in which to play tracks. Each byte specifies a track from the NSFe (note that the first track in the NSFe is track 0).

The length of the playlist is specified by the length of this chunk. It is not required to play all tracks, and they may be duplicated.

A player should normally stop when the playlist is finished. It may be useful to allow the user to turn off the playlist and select tracks from the NSFe manually.

### psfx

This optional chunk contains a tracks which are "sound effects" rather than music. Each byte specifies a track from the NSFe (note that the first track in the NSFe is track 0).

The length of this list is specified by the length of this chunk. Duplicate tracks may appear.

A player implementation may treat this as an optional alternate playlist for sound effects, like the 'plst' chunk above, where the 'plst' is the music only playlist, and 'psfx' is the sound effects playlist. It can also be treated as adding a "sound effect" flag to every listed track. (As a result, the user could be given the option not to listen to sound effects.)

(Added 2018-8-25)

### time

This optional chunk contains a list of 4 byte signed integers. Each integer represents the length in milliseconds for the corresponding NSFe track. Note this is unrelated to the 'plst' chunk; the times are for the tracks in the NSFe, not the tracks int he playlist. When the track has played for the specified time, it should begin fading out. A time of 0 is valid, and should begin fadeout immediately. A time of less than 0 represents the "default" time, which should be handled accordingly by the player.

This chunk should come after the 'INFO' chunk, so that the number of tracks is already known.

If this chunk is not long enough to specify all tracks in the NSF, a default time should be assumed for these tracks. Any extra data should be ignored.

### fade

This optional chunk contains a list of 4 byte signed integers. It is like the 'time' chunk, but instead specifies a fadeout length in milliseconds for each track. A fade time of 0 means the track should immediately end rather than fading out. A fade time of less than 0 represents the default fade time.

This chunk should come after the 'INFO' chunk, so that the number of tracks is already known.

If this chunk is not long enough to specify all tracks in the NSF, a default time should be assumed for these tracks. Any extra data should be ignored.

### tlbl

This optional chunk contains names for each track (tlbl = track label). This contains a series of null-terminated strings, in track order. (Like 'time' and 'fade', this is not related to the 'plst' chunk's playlist.)

This chunk should come after the 'INFO' chunk, so that the number of tracks is already known.

If there are not enough strings for every track, subsequent tracks should receive a default label (or no label) according to the player. Extra strings can be ignored.

### taut

This optional chunk contains an author name for each track (taut = track author), useful if several composers contributed to this NSF. This contains a series of null-terminated strings, in track order. (Not related to 'plst' order.)

This chunk should come after the 'INFO' chunk, so that the number of tracks is already known.

If there are not enough strings for every track, subsequent tracks should receive an empty author. Extra strings can be ignored.

(Added 2018-8-25)

### auth

This optional chunk contains four null-terminated strings describing in order:
- Game title
- Artist
- Copyright
- Ripper

If not all strings are present, a default string (typically "<?>") can be assumed by the player.

### text

This optional chunk contains a single null-terminated string of any length. This may include a description of the contents, or any message from the author.

Newlines may either be CR+LF or LF, as commonly found in text files.

(Added 2012-12-16)

### mixe

```text
offset  # of bytes   Function
----------------------------
$0000   1   BYTE    Specify output device (see below).
$0001   2   WORD    Signed 16-bit integer specifying millibels (1/100 dB) comparison with APU square volume

```

This optional chunk contains a list of output devices, and mixing information for each of them.

The comparison specifies relatively how loud a square wave played on the device at maximum volume (or other suitable waveform) compared to one at the same frequency from the built-in APU square channel. Any omitted device should instead use a default mix.

The primary use of this is for N163games, which mix the expansion audio at different levels on a per-game basis. For other expansion audio there is no evidence of variation on that basis, so this chunk should not be used if the default mix is appropriate for the rip.

The secondary use is for homebrew music, especially multi-chip NSF, where the user may wish to be specific about the mix. For this reason all expansions are accessible here.

Device byte values:
- 0 - APU Squares - Default: 0
- 1 - APU Triangle / Noise / DPCM - Comparison: Triangle - Default: -20
- 2 - VRC6 - Default: 0
- 3 - VRC7 - Comparison: Pseudo-square - Default: 1100
- 4 - FDS - Default: 700
- 5 - MMC5 - Default: 0
- 6 - N163 - Comparison: 1-Channel mode - Default: 1100 or 1900
- 7 - Sunsoft 5B - Comparison: Volume 12 ($C) - Default: -130

Reference test ROMs: https://github.com/bbbradsmith/nes-audio-tests

Reference test results: Forum: Audio levels survey, expansion audio etc.

These comparisons should be done at a matched frequency, close to A440Hz, using a single channel at its maximum volume, playing a square wave if possible. Level comparisons, particularly for non-square waves, are based on RMS amplitude.
- Device 1 (APU triangle / noise / DPCM) uses a triangle instead of a square wave because the nonlinear mix and lack of triangle phase control makes it the most deterministic available volume. For this comparison, noise is silenced and $4011 is set to 0.
- Device 3 (VRC7) uses a "pseudo square" FM instrument with the modulator at a 2:1 ratio and 50% modulation strength with full feedback (instrument data: $22, $21, $20, $07, $F0, $F0, $0F, $0F).
- Device 6 (N163) is compared in 1-channel mode.
- Device 7 (5B) is compared using only volume 12 ($C) due to nonlinearity of its internal amplifier at higher volumes.

All values are relative to the APU squares at their default volume. If you set a different volume for device 0, other devices are still relative to the default volume, not the new one.

(Added 2018-8-6)

### regn

```text
offset  # of bytes   Function
----------------------------
$0000   1   BYTE    Bitfield of supported regions.
                bit 0: NTSC
                bit 1: PAL
                bit 2: Dendy
                bit 3-7: Reserved (always clear)
$0001   1   BYTE    Specifies preferred region if multiple regions are supported. (Optional)
                0 - NTSC
                1 - PAL
                2 - Dendy

```

This chunk adds support for the Dendy region, and the ability to specify which region is preferred (for players that can support multiple regions). This chunk should appear after the INFO chunk, and overrides its region data (byte 6).

If this chunk is present, and Dendy region is chosen by the player, the X register should be set to 2 for the INIT call. If otherwise unspecified, Dendy playback will use the PAL rate (see RATEchunk above).

(Added 2018-8-21)

## Players
- Audio Overload- Multi format player. Windows, Mac Linux.
- Game Emu Player- Multi format player. Foobar2000 plugin.
- Cog- Multi format player. Macintosh.
- VLC Player- Multi format video and music player. Windows, Mac, Linux, Android, iOS.
- NSFPlay- NSF/NSFe player. Windows, Winamp plugin.
- Mesen- NES emulator, but can play NSF/NSFe files. Windows, Mac, Linux.
- NotSoFatso- The original NSFe player. Winamp plugin.

## References
- NSFe specification by Disch, revision 2. (9/3/2003)
- NSFe Archive- a collection of NSFe files by Disch.

# Tools

Source: https://www.nesdev.org/wiki/Tools

Useful tools for NES development.

See also:
- Projects
- Emulator tests

## Assemblers, compilers, and PRG-oriented tools

### Assemblers

#### Commonly used assemblers
- asm6- written by Loopy because most other assemblers "were either too finicky, had weird syntax, took too much work to set up, or too bug-ridden to be useful".
- asm6f- fork of asm6, providing support for illegal opcodes, NES 2.0 headers, symbol files for FCEUX/Mesen/Lua, and other features. See Releases for Windows binaries
- CC65- A portable 6502/65c02/65c816 assembler, linker, and C compiler.
- NESASM (MagicKit)by Charles Doty, David Michel, and J.H. Van Ornum.
- Unofficial MagicKitby zzo38. Based on MagicKit but with many improvements; includes PPMCK support
- WLA DX- A portable GB-Z80/Z80/6502/6510/65816 macro assembler. Linux and MS-DOS versions are also available.

#### Other assemblers
- AS65- written by Andrew John Jacobs. A macro assembler for 8 and 16-bit 65xx. Available for DOS/Win32 and Java. The Java port is strongly recommended.
- ACME- Marco Baye's ACME 6502/65c02/65c816 cross-assembler. Runs on several platforms, including Amiga, DOS, and Linux. Supports macros, local labels, and many other features.
- dasm- by Matthew Dillon of the DragonflyBSD project, extended and maintained by various other authors. A macro assembler intended for 6502, 6507, 6803, HD6303, 68HC11, 68705, and F8 architectures.
- FASM v1.0by Toshi Morita. FASM was written as a quick replacement for the 2500 AD assembler for Nintendo 8-bit development. Licensed under the GPL.
- Merlin 32- by Brutal Deluxe Software. 6502/65816 cross-assembler/linker for Win32, Linux, and OS X. Influenced by the Merlin/16+ assembler/linker for the Apple IIGS.
- nescom- Joel Yliluoma's 6502 assembler; written in C++, based on xa65 and largely compatible with it, including with the o65 object file format.
- NESHLAby Brian Provinciano. A 6502 assembler specifically geared towards NES development.
- Ophis Assemblerby Michael C. Martin. An open-source 6502 assembler written in Python.
- P65 Assembler- A portable 6502 assembler written in Perl.
- Telemark Cross Assembler- A shareware assembler for numerous 8-bit processors, including the 6502, Z80, and 8051.
- x816 v1.12fby minus. An assembler for 6502/65c02/65c816. MS-DOS only.
- xa65- Andre Fachat's open-source cross-assembler; written in C and supports the standard 6502 and 65c816 opcode lists. Sports a C-like preprocessor and supports label-hiding in a block structure. Produces plain binary files, as well as special o65 object files. Further tools include a linker, file and relocation utilities for o65 files.
- XORcyst- "... a rather platform-independent set of tools and languages for 6502 software development" written by Kent Hanson, aka SnowBro.
- XTOOLS- table-based assembler and toolkit. Includes an assembler, disassembler, and several tools. Shareware (US$49); registered version includes a table-based assembly source translator. Note: files are generated as Motorola formatted hex files; you will need a converter (see Convertersbelow)
- Kick Assembler- 6510 assembler with high level scripting. KickC targets at this assembler.
- NESASM CE- fork of NESASM (MagicKit) by Alexey Avdyukhin (Cluster)with additional NES features: NES 2.0 headers, symbol files for FCEUX, etc.

### Disassemblers
- 6502d- by Cortez Ralph. Win32 (GUI-based) rewrite of original 6502 disassembler (MS-DOS) by Bart Trzynadlowski.
- clever-disasm- by Bisqwit/Joel Yliluoma. Part of the nescom assembler suite (see above).
- da65- part of the cc65 suite. Primarily intended for individuals using tools in the cc65 suite (ex. ca65).
- disasm6- PHP-based 6502 (NES-oriented) disassembler intended for use with asm6 assembler. Pre-compiled Windows binaries are available.
- GhidraNes- Ghidra extension by Kyle Lacy
- NES Disassember- by Morgan Johansson. MS-DOS.
- nesgodisasm- a tracing disassembler that can generate output compatible with asm6/ca65/nesasm
- SmartRENES- by Hyde. Supports mappers 0, 1, 2, 3, and 7. Windows binaries only.
- TRaCER- by koitsu/Jeremy Chadwick. 6502/65816 disassembler intended for NES and SNES platforms. MS-DOS. (Does contain a confirmed bug related to one 65816-specific opcode)

### IDEs
- NESfabWhile NESfab is a programming language, it's also an IDE with asset management and level editing capabilities.
- NESkitA commercial development kit using cc65 and a number of python tools, including a simple level editor. Has template routines for platformer type games.
- NESmakerA commercial, semi-walled garden, GameMaker-like IDE with asset management and level editing capabilities. Based on prewritten assembly engine modules. Runs on top of Asm6.
- Retro Puzzle MakerAnother simplified, gamemaker-like puzzle games IDE. Can be run in browser or on desktop.
- NESICIDE(WIP) source code only, Github link for the NESICIDE IDE by cpow (Chris Pow)
- WUSDNAn NES IDE as of 2012 by the WUSDN team, Originally for Atari 8-Bit computers, Now also comes with NES capability, Requires Java Runtime Environment and Eclipse to run.

### Compilers
- CC65- A portable 6502/65c02/65c816 assembler, linker, and C compiler.
- GBDK- GBDK is a cross-platform development kit for sm83, z80 and 6502 based gaming consoles.
- KickC- C-compiler for creating optimized and readable 6502 assembler code. ( NesDev forum)
- llvm-mos- llvm-mos is a fork of LLVM supporting the MOS Technology 65xx series of microprocessors and their clones.
- Millfork- A middle-level programming language targeting 6502- and Z80-based microcomputers and home consoles.
- Pas 6502- Pascal cross-compiler for 6502-based machines.
- NESFab- A new programming language for creating NES games.
- vbcc- vbcc is a highly optimizing portable and retargetable ISO C compiler.

### Converters
- Converters for INTEL/MOTOROLA HEX formatsto Binary (BIN) and back, for assemblers like XTOOLS.

### Pre-processors and other code (PRG) tools
- shuffle.pyby Damian Yerrick - Preprocessor to rearrange variables, subroutines, and instructions in a file, for using other variables as memory canariesor watermarkingbeta builds

### Compression related tools
- Compress Tools- A multi-featured open-source compressor featuring many algorithms, extendable to new algorithms. Allows to break data in many small independent blocks and more by the usage of scripts.
- Huffmunch- A generic compression library for NES/6502 with very low RAM requirements.
- Donut- A fast and efficient CHR compression library by JRoatch.

## Graphics-oriented tools

### General NES graphics studios

Collected here are editors that offer a holistic approach to the creation and editing of various NES native graphics assets. These tools may offer in more or less equal measures the editing of tiles, screens, maps, sprites, metasprites and palettes in tandem; allowing for a resource efficient approach.
- NES Assets Workshop (NAW), by Nesrocks. Built in GameMaker with a thematic GUI. NAW opts for a classic toolbox menu with toggle hotkeys, similar to Photoshop, Aseprite and many more. Has a special "Overlay" editing mode which lets you draw sprite overlays on top of backgrounds.
- NEXXT, a continuation of NESST maintained by FrankenGraphics. Adds an arsenal of new drawing & layout tools, toolboxes, and asset management (such as meta-tiles and collision), along with speed-improved workflows, work safety, and bugfixes.
- NES Screen Tool (NESST)by Shiru (Deprecated). Tile oriented pixel art studio capable of editing CHR, backgrounds, sprites, metasprites, and palettes. Facilitates a modifier-key approach to make editing quicker, at some cost of discoverability (browsing through the readme is recommended).
- RetroSpriteEditor, by xverizex. a tile and nametable editor for Windows and Linux.

### Animation tools
- DONERby Codemeow. Generates easing tables to use for position animations. Output is suitable for 6502 C or Assembly.

### Asset Converters

Converters are good choices for when you prefer to work on an asset in a general purpose graphics studio such as Photoshop, GIMP, Aseprite, GraphicsGale etc, and need to convert or extrapolate NES ready data from that work.
- I-CHRby Kasumi. Converts PC images and image sequences into NES compatible tilesets and nametables. Can also produce a NES ROM program displaying the graphics.
- NesTilerby Alexey Avdyukhin (Cluster). Converts PC images into pattern tables, nametables, attribute tables and palettes. This application can accept multiple images as input, the main point is to use single set of palettes (and tiles if required) for all of them, so it's possible to switch CHR banks and base nametable on a certain line, in the middle of rendering process. Can produce lossy result if image doesn't meet the limitations of NES. Uses command-line interface, so it can be used as a part of toolchain. Multiplatform.
- NEXXTporterby Eigenvector32. A command line tool for extracting NES binaries (such as .chr, .nam and .pal) out of an NEXXT session file, to help with buildtime asset updates and version control. Also able to render PNGs.
- OverlayPalby Michel Iwaniec (Bananmos). An image-to-NES-assets converterter that specializes in splitting the source image into a background layer and an "overlay" sprite layer.
- pilbmp2nes.pyby Damian Yerrick - Command-line converter from indexed BMP or PNG to multiple consoles' tile formats.
- NES Pixelerby pubby. Quantizes images into the NES color palette.
- png2chr.pyby Zeta0134. Takes any paletted image file, exactly 128px by 128px, and outputs it as 4KiB CHR ROM.
- Tilificatorby Michel Iwaniec (Bananmos) - sprite optimisation tool. Takes an image and finds resource effective hardware tiles for sprite usage. Can import/export to NESST .msb formats. A tutorialis available.

### Tile (CHR) editors
- 8tedby Damian Yerrick (deprecated).
- Famitile- (Note: the link is recovered from archive.org ) Old, super-minimalist graphics tool by zzo38. Requires an sdl of version 1.x, which can be gotten (here). Includes command-line and graphical mode; supports editing CHR, but also standard nametables, and MMC5extension nametables.
- Nasuby 100 rabbits. A Minimalist NES tile editor with features such as quick colour selection via hotkeys. For win/mac/linux via an "UXN" emulator.
- Tile Molesterby SnowBro, Central MiB, Lab313, and Mewster.
- YY-CHR, by YY. A tile editor that works like visual hex editor. Particularly popular in the romhacking scene, since you may modify an already assembled ROM image. Also has provisionary tile layout (nametable) capabilities.
- Tile Layera program for modifying graphics in NES ROMs.

### Map (nametable) editors
- 8nameby Damian Yerrick
- 8name.pyby Damian Yerrick
- Famitile(mentioned above). While primarily a CHR editor, there is some support for nametable editing.
- YY-CHR(mentioned above). Has provisionary tools for nametable layouts.

## Music tools

### Trackers/sequencers
- FamiTrackertracker-style music editor
- MCK driverand MML translator for music creation (includes source code)
- Musetrackertracker-style music editor (formerly known as PornoTracker).
- Nerd Tracker IItracker-style music editor
- PPMCK unofficial versionby zzo38(includes MagicKit as well)
- NTRQnative NES tracker by Neil Baldwin
- Pulsarnative NES tracker in LSDJ style by Neil Baldwin
- NijuuNES music macro language assembler by Neil Baldwin

### DMC conversion tools
- FamiTrackercan import .wav files and convert to DMC samples, which can then be exported as .dmc files.
- NSF Live!NSF player that can export DMC samples from NSF songs as .dmc files.
- Pin Eight NES Toolsincludes a command-line encoder and decoder by Damian Yerrick.

### Other conversion tools
- Drum sample to noise sound effect/channel converterby lidnariq. Written in C.

### Engines

Runtime engines for playing music and sound: see Audio drivers

## Multicart Tools
- Action 53 mapper- a multicart mapper designed for homebrew games.
- Double Crossing: The Forbidden Four- a hack of The Legend of Zelda to add a menu and three NROM games using MMC1.

## Miscellaneous other tools
- Visual 2A03- circuit simulator of the 2A03
  - Visual circuit tutorial- usage guide
- Visual 6502- circuit simulator of the 6502 processor
  - Visual6502wiki- mirror/archive of its wiki documentation
- Serial Bootloader- tool for uploading from PC to the controller or expansion port
- ADOS NES- an operating system project
- NESDev old homepage development tools list

# Family Computer

Source: https://www.nesdev.org/wiki/Famicom

The Family Computer (HVC-001: Famicom , FC for short) is a video game console made by Nintendo and sold in Japan starting in 1983. The console would later be sold in Taiwan and Hong Kong.

The Nintendo Entertainment System (NES), which Nintendo sold outside Japan a couple years later, is nearly identical in behavior but with several changes in the cords, controllers, and system look. While the Famicom was made to look friendly and well matched for a Japanese household with bright colors, the NES was designed as an "entertainment system" in order to get it into American retail stores who had been burned by the video game crash(known in Japan as the Atari shock).

The New Famicom (HVC-101: also known as the AV Famicom ) is a Famicom model released in 1993 which outputs AV composite video. It is similar to the New-Style NES (NES-101). The original Famicom is sometimes called the RF Famicom to retroactively distinguish it from the AV Famicom, which is what this article will use.

## Differences from the NES

### Input
- On the RF Famicom, two controllers are hard-wired to the console. The AV Famicom uses standard NES controller ports.
- Controller2 on the RF Famicom has a microphone in place of the Select and Start buttons; the missing buttons always return "not pressed".
- The controllers on early RF Famicom revisions had square rubber buttons, which were replaced with round plastic buttons on later revisions.
- There is a 15-pin expansion portwhere the Zapperand other peripherals connect to. 1- and 2-player games tend to merge inputsfrom from controllers 1 and 2 with controllers 3 and 4 connected this way.
- Only one peripheral may be connected at once. Despite using NES controller ports, the AV Famicom isn't wired to accept peripherals made for the NES. If a peripheral was made for both the NES and the Famicom, the protocol may differ between the two, such as the Power Pad, Arkanoid controller, and Four Score.

### Output
- The RF Famicom had only RF output, not the AV output seen on the front-loading NES. Modifications to produce an AV output are common on second-hand units.
- The Famicom is always NTSC. PAL Famiclones were designed for compatibility with the Famicom; the clock ratepreserved the ratio of PPU to CPU cycles, and extra scanlines were added to the post-render period instead of vertical blanking so that cycle-counting mapper IRQs and cycle-timed NMI handlers continue to work.
- The Sharp Famicom Titler (AN-510) and Sharp C1(Famicom TV) have different palettesand emphasisbehavior compared to other Famicom models due to them using RGB PPUs. Some commercial Famicom games are labelled as incompatible with these models.
- The APU on the earliest Famicom revisions doesn't support 93-step noise(instead playing it as normal noise), and has a different noise period for rate $F.
- The Famicom audio path loops through the cartridge connector. This allows cartridges to generate their own audio and mix it with the console's audio. A number of cartridges have their own audio synthesizers. Famicom Karaoke Studio is an example of a cartridge that provides its own microphone. The Sharp C1 is incompatible with these games as it uses the audio path to detect inserted cartridges.

### Other
- Reset acts like a top-loading NES, not a front-loading NES: the Reset button resets only the CPU, not the PPU.
- The "cassette" connector on the Famicom is smaller than the "Game Pak" connector on the NES. Famicom cassettes have 60 pins instead of 72. However, the pin pitch is slightly wider: 2.54 mm (0.1 in) on the Famicom vs. a non-standard 2.50 mm on the NES.
- No expansion port on the bottom, and no ten pass-through pins on the cassette connector.
- No CIC lockout chip.

## References
- Family Computer - Nintendo(Japanese)
- Family Computer - FamiWiki
- Family Computer - MarioWiki
- Family Computer - Wikipedia(Japanese)
- System « Famicom World

# Family Computer Disk System

Source: https://www.nesdev.org/wiki/FDS

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

# NES 2.0 Mapper 515

Source: https://www.nesdev.org/wiki/NES_2.0_Mapper_515

NES 2.0 Mapper 515 is used for 패밀리 노래방 Family Noraebang , a Korean karaoke cartridge that uses UNROM-style PRG banking, has provisions for an expansion cartridge, an ADC for Microphone input, and a clone of the Yamaha YM2413chip for expansion audio: the K-663A.

## Banks
- CPU $8000-$BFFF: 16 KB switchable PRG ROM bank
- CPU $C000-$FFFF: 16 KB PRG ROM bank, fixed to the last bank

## PRG-ROM bankswitching

```text
Mask $E00F:
  W 8000: [RBBB BBBB] - R:0-select external ROM; 1-select internal ROM; B-select bank at $8000-$BFFF
                        $C000-$FFFF is always last bank of internal ROM

```

The board does not seem to suffer from bus conflicts. The existing ROM images are arranged similarly to INES Mapper 188: The last 1 MiB of PRG-ROM are the main cartridge, the first (total PRG-ROM size minus 1 MiB) are the expansion cartridge.

## Expansion sound

```text
Mask: $E003:
  W 6000: YM2413 index
  W 6001: YM2413 data
  R 6000: YM2413 read back test register contents

```

Note that the board does not allow the 2A03 audio to be mixed with the YM2413 output.

## Microphone input

```text
Mask: $E003:
   R 6003: [D... ....] - SPI (ADC) data
Mask not yet known:
   W C002: [S... ....] - SPI (ADC) chip select
   W C003: [K... ....] - SPI clock / ADC conversion clock

```

## See also

http://forums.nesdev.org/viewtopic.php?f=9&t=16124

# MMC5 audio

Source: https://www.nesdev.org/wiki/MMC5_audio

Nintendo's MMC5mapper provides extra sound output, consisting of two pulse wave channels and a PCM channel. The pulse wave channels behave almost identically to the native pulse channels in the NES APU.

The sound output of the square channels are equivalent in volume to the corresponding APU channels, but the polarity of all MMC5 channels is reversed compared to the APU.

The PCM channel is similarly equivalent in volume to the APU with equivalent input, and inverted, but using the extra high bit of input it can become twice as loud.

## Pulse 1 ($5000-$5003)
- Write only
- Reset detection not used

These registers manipulate the MMC5's first pulse wavechannel, which functions the same as to those found in the NES APUexcept for the following differences:
- $5001 is not implemented. The MMC5 pulse channels will not sweep, as they have no sweep unit.
- $5003 only contains bits 2,1,0. The other bits are not implemented.
- Frequency values less than 8 do not silence the MMC5 pulse channels; they can output ultrasonic frequencies.
- Length counter operates twice as fast as the APU length counter (might be clocked at the envelope rate).
- MMC5 does not have an equivalent frame sequencer(APU $4017); envelope and length counter are fixed to a 240hz update rate.

Other features such as the envelope and phase reset are the same as their APU counterparts.

## Pulse 2 ($5004-$5007)

These registers manipulate the MMC5's second pulse channel.

## PCM Mode/IRQ ($5010)
- Read/Write
- Reset detection is used

### Write

```text
7  bit  0
---- ----
0xxx xxx0  Reset Value
---- ----
Ixxx xxxM
|       |
|       +- Mode select (0 = write mode. 1 = read mode.)
+--------- PCM IRQ enable (1 = enabled.)

```

### Read

```text
7  bit  0
---- ----
Ixxx xxxM  MMC5A default power-on read value = $01
|       |
|       +- Unknown
+--------- IRQ (0 = No IRQ triggered. 1 = IRQ was triggered.) Reading $5010 acknowledges the IRQ and clears this flag.

```

Note: $5010.0 read bit appears to exist exclusively in the MMC5A and its function is unknown.

## Raw PCM ($5011)
- Write only
- Write-by-read writes to this register in PCM read-mode.
- Reset detection not used

### Write

```text
7  bit  0
---- ----
WWWW WWWW
|||| ||||
++++-++++- 8-bit PCM data

```

This functions similarly to the NES APU's register $4011, except that all 8 bits are used.

Shin 4 Nin Uchi Mahjong is the only game to use the extra PCM channel ($5011).

Writing $00 to this register will have no effect on the output sound, and does not change the PCM counter.

### Pin 2 DAC Characteristic

Pin 2 no-load voltage very closely follows the equation:

Voltage = [(DAC value / 255) * (0.4 * AVcc)] + (0.1 * AVcc)

The DAC output is very low impedance -- it holds its voltage true under load. To protect itself, the output also has a current limit. The current limit level depends on AVcc. MMC5A measured current limit in microAmps = (42.178 * Avcc) - 36.808. It is unknown, but quite doubtful, that prolonged exposure to current limit mode could cause damage to the DAC or other parts of the MMC5. Since current limit mode would cause audible distortion, it should be considered a self-protection feature that should be avoided. In practice, with Avcc = 5V, the DAC output pin should drive 15kohms or higher to avoid current limit mode.

The same MMC5A chip, tested with repeated power cycles on different days of the week and different moon phases, etc, has been observed to power on with a DAC voltage equivalent to DAC value $EF or $FF. No other power-on values have been observed. This voltage is not affected by a reset detected when M2 stops toggling.

## PCM description

MMC5's DAC is changed either by writing a value to $5011 (in write mode) or reading a value from $8000-BFFF (in read mode). If you try to assign a value of $00, the DAC is not changed; an IRQ is generated instead. This could be used to read stream 8-bit PCM from ROM and terminate at $00.

### IRQ operation

(pseudocode)

```text
(On DAC write)
    if(value=0)
        irqTrip=1
    else
        irqTrip=0

(On $5010 write)
    irqEnable=value.bit7

(On $5010 read)
    value.bit7=(irqTrip AND irqEnable)
    irqTrip=0

Cart IRQ line=(irqTrip AND irqEnable)

```

## Status ($5015)
- Read/Write
- Reset detection not used

This register is analogous to the APU Statusregister found within the NES at $4015, except that only the bottom 2 bits are used; being for the MMC5's two pulse channels.

## Hardware

Expansion audio hardware configuration from HVC-ETROM-02:

```text
            R3 15k   C4 100n
From 2A03 ---/\/\/-----||------+           R4 10k
(Cart.45)                      |   +--------/\/\/---------+
                               |   |           _          |
            R2 15k   C3 100n   |   | (MMC5.1) | \         +--- To RF
MMC5 DAC ----/\/\/-----||------+---+----------|+  \       |    (Cart.46)
(MMC5.2)                       |              |    >------+
                               |       GND ---|-  / (MMC5.100)
            R1 15k   C2 100n   |              |_/
MMC5 Pulse --/\/\/-----||------+
(MMC5.3)

```

## References
- Famicom expansion hardware recordings- forum thread with MMC5 test ROMs and recordings confirming various MMC5 audio features.
- MMC5 volume test- hotswap test ROM for investigating MMC5 volume.
