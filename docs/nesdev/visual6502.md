# visual6502

# Visual6502wiki

Source: https://www.nesdev.org/wiki/Visual6502wiki

In July 2021, the Visual6502 project's wiki ceased to be accessible. The non-stub pages have since been copied here:
- Visual6502wiki/6502DecimalMode
- Visual6502wiki/6502Observations
- Visual6502wiki/6502TestPrograms
- Visual6502wiki/6502 - simulating in real time on an FPGA
- Visual6502wiki/6502 BRK and B bit
- Visual6502wiki/6502 Interrupt Hijacking
- Visual6502wiki/6502 Interrupt Recognition Stages and Tolerances
- Visual6502wiki/6502 Opcode 8B (XAA, ANE)
- Visual6502wiki/6502 Stack Register High Bits
- Visual6502wiki/6502 State Machine
- Visual6502wiki/6502 Timing States
- Visual6502wiki/6502 Timing of Interrupt Handling
- Visual6502wiki/6502 Unsupported Opcodes
- Visual6502wiki/6502 all 256 Opcodes
- Visual6502wiki/6502 datapath
- Visual6502wiki/6502 datapath control timing fix
- Visual6502wiki/6502 increment PC control
- Visual6502wiki/6502 traces of 6501
- Visual6502wiki/6507 Decode ROM
- Visual6502wiki/650X Schematic Notes
- Visual6502wiki/Atari's 6507 Schematics
- Visual6502wiki/Balazs' schematic and documents
- Visual6502wiki/Educational Resources
- Visual6502wiki/Hanson's Block Diagram
- Visual6502wiki/Incrementers and adders
- Visual6502wiki/JssimUserHelp
- Visual6502wiki/MOS 6502
- Visual6502wiki/Motorola 6800
- Visual6502wiki/Other Chip Image Sites
- Visual6502wiki/Photos of MOS 6502D
- Visual6502wiki/Photos of R6502
- Visual6502wiki/RCA 1802E
- Visual6502wiki/The ChipSim Simulator
- Visual6502wiki/The reverse engineering process

Orphans: (Listed here to remove from the wiki's Orphaned pageslist)
- Visual6502wiki/6502 increment PC control
- Visual6502wiki/650X Schematic Notes
- Visual6502wiki/Incrementers and adders
- Visual6502wiki/JssimUserHelp
- Visual6502wiki/Motorola 6800
- Visual6502wiki/Other Chip Image Sites
- Visual6502wiki/RCA 1802E
- Visual6502wiki/The reverse engineering process

# Visual6502wiki/6502DecimalMode

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502DecimalMode

The 6502 had a couple of unique selling points compared to its predecessor the 6800, and the decimal mode was crucial because it was patent protected. It saves an instruction and a couple of cycles from each byte of decimal arithmetic, and removes the half-carry from the status byte - it also works for both addition and subtraction.

Decimal mode only affects ADC and SBC instructions, and on the NMOS 6502 only usefully sets the C flag. The N, V and Z flags are set, but don't correspond to what you might expect from a 10's complement decimal operation.

Nonetheless, all four flags are set, so it's worth understanding how they are set, and why. (See Ijor's paper, and Bruce Clark's tutorial)

Many (software) emulators have decimal mode correct, and many have it incorrect or missing. The same is true for various re-implemented 6502 cores. Because the CMOS 6502 and later parts set the flags differently from the NMOS 6502, correctness can only be judged relative to a specific part.

Bruce Clark's tutorial contains a test program which can test all the flags (for the various CPU models) and will report the first failing case. Using this, we can collect some specific 'difficult' cases for use on a slow model, or for a rapid test of new code, or for illustration of the 6502 datapath in action. Some of the following tests are now found in the py65 test suite

We need a list of interesting signals to probe to observe the decimal mode adjustments. (The presently released JSSim doesn't have C34 named, but it will on next update)

The two operands, and the carry in, are added as a pair of nibbles. The carry-out from bit3 is adjusted in decimal mode, but only for ADC. So the ALU is not a binary byte-wide ALU with a decimal adjustment, it is a pair of binary nibble ALUs with a decimal adjustment. In the tests, we don't specifically need to test that carry-in is used (except to prove that carry-out is changing the carry bit, if we have that freedom)

Some of the tests below are found in Bruce Clark's V flag tutorial. Others are taken from failing cases when running his decimal mode test suite.

(For other test suites, see Visual6502wiki/6502TestPrograms)

### Tests for ADC
- 00 + 00 and C=0 gives 00 and N=0 V=0 Z=1 C=0 ( simulate)
- 79 + 00 and C=1 gives 80 and N=1 V=1 Z=0 C=0 ( simulate)
- 24 + 56 and C=0 gives 80 and N=1 V=1 Z=0 C=0 ( simulate)
- 93 + 82 and C=0 gives 75 and N=0 V=1 Z=0 C=1 ( simulate)
- 89 + 76 and C=0 gives 65 and N=0 V=0 Z=0 C=1 ( simulate)
- 89 + 76 and C=1 gives 66 and N=0 V=0 Z=1 C=1 ( simulate)
- 80 + f0 and C=0 gives d0 and N=0 V=1 Z=0 C=1 ( simulate)
- 80 + fa and C=0 gives e0 and N=1 V=0 Z=0 C=1 ( simulate)
- 2f + 4f and C=0 gives 74 and N=0 V=0 Z=0 C=0 ( simulate)
- 6f + 00 and C=1 gives 76 and N=0 V=0 Z=0 C=0 ( simulate)

### Tests for SBC
- 00 - 00 and C=0 gives 99 and N=1 V=0 Z=0 C=0 ( simulate)
- 00 - 00 and C=1 gives 00 and N=0 V=0 Z=1 C=1 ( simulate)
- 00 - 01 and C=1 gives 99 and N=1 V=0 Z=0 C=0 ( simulate)
- 0a - 00 and C=1 gives 0a and N=0 V=0 Z=0 C=1 ( simulate)
- 0b - 00 and C=0 gives 0a and N=0 V=0 Z=0 C=1 ( simulate)
- 9a - 00 and C=1 gives 9a and N=1 V=0 Z=0 C=1 ( simulate)
- 9b - 00 and C=0 gives 9a and N=1 V=0 Z=0 C=1 ( simulate)

One form of test program sets all the input flags using PLP:

```text
lda #$c8
pha
lda #$00
plp
adc #$00
nop

```

and to calculate what that initial value of PLP should be, we can use a bit more code

```text
php
pla
eor #$c3   // #$c2 if we don't want to invert the carry
nop

```

### Decimal mode and the NES' RP2A03G

The CPU in the NES' RP2A03G does not implement decimal mode for ADC and SBC operations, but it does correctly handle the setting and clearing of the D flag.

In this blog postby Nathan Altice, Brian Bagnall’s "On the Edge: The Spectacular Rise and Fall of Commodore (2006)" is quoted:

[Commodore 64 programmer] Robert Russell investigated the NES, along with one of the original 6502 engineers, Will Mathis. “I remember we had the chip designer of the 6502,” recalls Russell. “He scraped the [NES] chip down to the die and took pictures.”

The excavation amazed Russell. “The Nintendo core processor was a 6502 designed with the patented technology scraped off,” says Russell. “We actually skimmed off the top of the chip inside of it to see what it was, and it was exactly a 6502. We looked at where we had the patents and they had gone in and deleted the circuitry where our patents were.”

With visual6502 and images from Quietust's investigation of the 2A03 we can see that a small number of changes, only to the polysilicon mask, disable the decimal adjustment by removing 5 transistors. When poly shapes are deleted, the former source and drain of transistor become contiguous, so the effect is of shorting the transistor, or making it permanently on. (These are pulldown transistors, and it's normal for them to be on, although they would typically have a 10k resistance. Shorting them will cause some additional power dissipation from the corresponding pullup but presumably insignificant compared to the thousands of other pullups which will be active at any give time.)

The first note of the difference is this odd contact cut which has no surrounding poly or active: see this image- which turns out to be due to the removal of the t1329 transistor. It's one of two transistors normally used by the "dpc22_#DSA"signal as a pulldown to effect decimal adjust during subtraction. The other is t3212which is just off the top of the two images linked above.

The corresponding adjustment for ADC (dpc18_#DAA)affects three transistors: t2750, t2202, t2556

In the case of t2556 the control line runs through the transistor - but still the poly is removed locally with a minimal change. That leaves some floating poly, but as the other two transistors don't exist any more, it's irrelevant.

With these 5 transistors removed, there was no need to change the decode ROM and no need to change the status register.

### References
- Post"What Commodore Found in the NES" on NESdev forum
- Blog post"Whence Came the Famicom’s Brain?" by Nathan Altice
- 2A03 chip imageson Quietus' reverse-engineering site

# Visual6502wiki/6502Observations

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502Observations

We've found some interesting things on the 6502, from the layout level, up through circuit level to the programmer visible level. Programmer Visible

Notes here on bugs and undocumented behaviour.
- BRK, the B bit, and other interrupts
- Timing of Interrupt Handlingnoting that a taken branch delays interrupt handling, also that CLI/PLP allow one further instruction to execute, unlike RTI.
- Unsupported or undocumented opcodessuch as SAX and XAA
- The ROR bugwhich is found only in rare early devices

See also our catalogue of 6502 test programs, useful to verify simulators or emulators. Circuit and Logic

Notes here on timing fixes and non-digital circuit techniques, and departures from NMOS design style orthodoxy.
- Signs of a fixto datapath control timing
Layout

Notes here on the traces of bug fixes, and remnants of the original 6501 layout.
- Traces in the layoutof the original 6501 part which was withdrawn after legal wrangling

# Visual6502wiki/6502 - simulating in real time on an FPGA

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_-_simulating_in_real_time_on_an_FPGA

### Introduction

In September 2010 the visual6502 project released the JavaScript simulator, which ran a chip animation at about one clock cycle per second - a million times slower than the original 6502 - in a web browser.

In fact the transistor level model had already run faster than that, at about 55Hz, as a python implementation (as yet unreleased.) One major difference there is that the graphics animation was done with OpenGL, much faster than JavaScript's Canvas.

But to run a test suite, or any demo program or normal game or application, it's desirable to run much faster. It's even more desirable to run at real time, especially if it's possible to interact with original hardware.

### Simulating in software

The original bring-up (see presentation) was in a simulated Atari context, and the accuracy of the simulated video output was a useful clue to the correctness of the simulation. But it was not real time.

By January 2011 the browser wars had produced faster browsers, we had significantly improved our code, and we'd also released an expert mode which didn't update a chip animation. The result was an in-browser simulation which could run at 250Hz or better.

But in the meantime, only a week or so after the release of the browser version, Michael Steiland some collaborators had ported the code to C and were able to run at about 1kHz - they could run up the "COMMODORE 64 BASIC V2" banner within about 10 seconds (but skipping the memory test.)

This was only a thousand times slower than the original, running on a computer that was perhaps two million times faster.

All of the simulators mentioned so far - in python, JavaScript, and C - are switch-level. They model each pull-down transistor in the circuit and each pass transistor, with some special handling for pullups. The circuit is re-evaluated after each input signal change until it stabilises, which takes several iterations because transistors act bidirectionally. Each signal in the circuit is modelled as high, low or floating. It's possible that this simple model will need to be revised as we tackle chips with more subtle circuits, but it seems good enough for 6502.

### Simulating in hardware

From November 2010, Mike J had started a project to convert the transistor-level netlist into a higher-level RTL description, which is presently working in simulation but is not yet published.

From mid-December, Peter Monta has been working on a projectto convert the transistor-level netlist into a synthesisable form which can be placed on an FPGA and run in-circuit. Most of the chip is converted to logic gates and storage elements, and the remainder is simulated with a 6-bit model of node voltages and edge currents (using approximately 48 levels during simulation.) So the FPGA is clocked at 50MHz or thereabouts, and manages to simulate a 6502 or 6507 at 1MHz or just above.

Note that this verilog design will run at about 4kHz when simulated with the open-source verilator simulator - which is therefore the fastest model available to date.

In January 2010 user Xor on the 6502.org forum finaliseda verilog model of 6502 which was informed by the transistor netlist found in visual6502, but written by hand as a high level document of the function. On the 18th he published a videoof a starfield demo, running at 1MHz. Some code is published on the forum but there's no public release yet.

By late January 2010 Peter had his model running Space Invaders, on an OHO FPGA module replacing the 6507 in an original Atari 2600 console.

File:6507-demo0.jpg

File:6507-demo1.jpg

### Passing a test suite

Since then, Peter has made further improvements, and Ingo Korb has joined in, and run Wolfgang Lorenz' testsuitein a 1541 disk drive, passing all legal opcodes and failing on 16 unsupported opcodes. (It is expected that a simulated digital model will not behave precisely as a physical CPU when it comes to these deservedly unsupported opcodes - they cause essentially analogue behaviour. It's also true that the FPGA module does not behave, electrically, precisely like an NMOS part.)

Ingo has also had success running on FPGA in real time as a CPU replacement in other systems: an Apple IIe clone, VIC20, C64. Ingo has implemented a manual tuning system for the clock delay. (The Apple II Europlus was an unsuccessful experiment - it is thought that the clock skew compensation cannot deal with the slow RAM access times.)

File:6502-fpga-apple2-img 0040.jpg

File:6502-fpga-vic20-img 0039.jpg

More pictures, showing functioning vintage software (click through for full size):

File:6502-fpga-apple2-overview-IMG 1086.jpgFile:6502-fpga-vic20-overview-IMG 1081.jpgFile:6502-fpga-c64-overview-IMG 1080.jpg

### Further work

Work continues on stability and on the maximum speed of the FPGA model. For this to work at all, the model running on the FPGA has to mimic the delays, especially of the clock signals, as well as the CPU logical behaviour. The FPGA module has to be electrically compatible with the motherboard, including delays, voltage levels and possibly in some cases edge rates.

### Resources
- verilator, a fast open-source verilog simulator
- Xor's threadon 6502.org forum
- original FPGA-netlist-tools projecton github
- Ingo's forkof FPGA-netlist-tools project, for apple2, C64, VIC20
- OHO FPGA modules
- Enterpoint's FPGA modules

# Visual6502wiki/6502 BRK and B bit

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_BRK_and_B_bit

The 6502 has 4 sources of interrupt-like behaviour: BRK, RESET, IRQ and NMI.

Much has been said about these - it's common to find confusion about the behaviour of the B bit in the pushed status word - and we can say a little more, with reference to our in-browser simulation of the NMOS 6502.

## the B flag and the various mechanisms

First technical point: the B flag position in the status register is not a bit in the status register: it is unaffected by PLP and RTI. However, the 6502 does push the register with either a 1 or 0. The intention is to distinguish a BRK from an IRQ, which is needed because these two share the same vector. Brad Taylor says:
- software instructions BRK & PHP will push the B flag as being 1.
- hardware interrupts IRQ & NMI will push the B flag as being 0.

As it happens, there are bugs such that this description isn't strictly true in all situations, and the root cause is that the machinery for
- recording a pending hardware interrupt (using a control signal called D1x1)
- forcing zero into the IR so the PLA performs the interrupt actions (uses D1x1, but at a different time to saving B)
- saving a value in the B position (distinguishing BRK/PHP from a pending hardware interrupt)
- forcing the appropriate values on the address bus to fetch the vector destination

are separate and independent.

(Note that the visual6502 sim reports the P register as if B was a storage element: in fact it is observing the node which conditionally drives the data bus during a push of P. See here.This node is the output of an inverter and is a doubly-inverted D1x1.)

## IRQ preceding a BRK instruction

(D1x1 was named by Balazs Beregnyei in his giant schematic. By all means refer to the schematic but note that it is a description of Rockwell's version of the 6502)

Here's an URLwhich uses CLI and sets off a very short IRQ pulse.

You'll see that the D1x1 signal latches the pending interrupt, causes the pushed B to be zero, and is then cleared during the vector pull. This same signal is gated by 'Fetch' to produce 'ClearIR' (which jams zero into the IR)

Note also that the address pushed is for the instruction after the BRK. The BRK has masked the IRQ, because the IRQ handler will inspect the saved P and process the BRK.

## late NMI will not half-modify vector reads

This is a (necessary) feature: if an NMI occurs during the read of high and low vectors, it must not modify only the second read: modifying neither or both will determine whether the interrupt acts like an NMI or like the BRK/IRQ which is in progress.

We note it here because we can point out the mechanism: transistor t970, where the logic is:

```text
 1368 := NMIP and not NMIL and not <VEC>.phi2
 NMIG := <1368>.phi1 or (<NMIG>.phi2 and not <brk-done>.phi1)

```

(Note that not all these signal names are presently known to the visual6502 netlist. Will be fixed.)

## NMI preceding a BRK
- Here's an exampleshowing the RTI and resumption - note that the BRK has never been executed.

Because the B bit is stored as a 1, even though the NMI vector has been followed, in this case, the NMI handler could inspect the saved P register, in case a BRK was interrupted. It would then have to adjust the saved PC. This all takes time, and yet NMI is usually for rapid interrupt servicing.

As the NMI handler would not normally inspect P, this is a case of NMI masking BRK. If BRK is an OS call, it would not be made, and so you can't do that on a system using NMI.

## NMI masked by BRK

We thought we'd seen a late NMI during a BRK being ignored. Watch this space: we might have to retract that.
- late NMI during BRK

## masking of the stack writes during RESET

This is a feature of the NMOS 6502 but not all other versions.
- Here'sa reset, showing that the 3 stack writes happen as reads.

The logic which causes these writes to be suppressed is as follows:

```text
 WR := op-T-mem-store
   or op-T2-php/pha
   or op-T4-brk
   or SD1 or SD2
   or (PCH/DB) or (PCL/DB)
 (R/#W) := not (<WR>.phi2 and not RESG and RDY)
 R/#W := <(R/#W)>.phi1

```

with the writes during RESET suppressed by transistor t3455

## Resources
- back to parent page Visual6502wiki/6502Observations
- Internals of BRK/IRQ/NMI/RESET on a MOS 6502by Michael Steil on pagetable.com
- Interrupts in 65xx processors(wikipedia)
- The B flagby Brad Taylor
- B flag discussionon 6502.org
- Investigating Interruptstutorial by Garth Wilson
- Register Preservation Using The Stack (and a BRK handler)tutorial by Bruce Clark
- IRQ handler in the BBC micro OS1.20
- CPU interruptson Nesdev wiki

# Visual6502wiki/6502 Interrupt Hijacking

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Interrupt_Hijacking

The following is based upon drawing the node and transistor networks out on paper from visual6502 data, and conducting experiments with the simulator. In explaining the various behaviors, references are made to 6502 clock states and stages of interrupt recognition that are described in 6502 Timing Statesand 6502 Interrupt Recognition Stages and Tolerances, which may be used as primers for this exposition.

## Introduction

Systems typically engineered around the 6502 generate interrupt signals that stay low for very appreciable lengths of time in terms of the applied clock rate. Manual resets may keep the RES line down at least a few tenths of a second when a reset button is quickly struck and released, and resets invoked by hardware when power is first applied may last for 0.1 to 0.3 seconds. Devices invoking NMI and IRQ will keep the respective lines down until the 6502 programmatically answers the interrupt with a finishing access to the device, which may be in the hundreds of microseconds to the 1+ milliseconds level. All of the above durations range from hundreds to hundreds of thousands of clock transitions.

Some obscure niches of behavior may be observed instead when the interrupt lines are held low for only a handful of clock transitions or less.

## NMI Hijacking IRQ/BRK

First introduced to this wiki by the link, "late NMI", in 6502 Timing of Interrupt Handling, it is possible for higher-priority interrupts to hijack lower priority interrupts during the BRK instruction that is serving them.

The "late NMI" is an example of a full hijack, where a higher priority interrupt arrives after the BRK instruction for a lower priority interrupt has already started. The higher priority interrupt changes the addresses used when the BRK instruction actually fetches the vector during clock states T5 and T6: the vector selection is not fixed and "remembered" when the BRK instruction starts, or at any time before. Vector selection is independently parameterized by the NMI and RES interrupts, instead.

For NMI to hijack an IRQ (or a soft BRK instruction), stage 1 of its recognition may appear as late as T5 phase 1 during the BRK instruction's execution. This requires the NMI line to go down no later than the end of clock cycle T4 (up to just before clocking in T5 phase 1). With the node ~NMIG low during T5 and T6, the low and high bytes of the vector for indirect jump to the NMI handler are fetched together.

This is perfectly allowable if an IRQ caused the hijacked BRK, as NMI is higher priority than IRQ, and is serviced first. The IRQ will get its chance for attention after the RTI from the NMI handler has finished.

To recover from hijacking a soft BRK, the NMI handler must check the Break bit in the processor status register written to the stack. If it is true, then the handler must finish by performing a JMP ($FFFE) instead of an RTI. If it does an RTI for a soft BRK, then the soft BRK ends up being ignored: execution will resume with code after the BRK instruction instead of being processed by the system's soft BRK handler. The jump indirect to the IRQ/BRK handler will cause the soft BRK to be processed instead of missed. This special end for NMI would not have been necessary without a hijacking phenomenon.

Back to the subject of actual hijackings: If NMI could appear one cycle later, it would affect only the fetch of the high byte of the vector, while the low byte would have already been fetched for IRQ/BRK: it would be a half-hijack.

Unfortunately for this scenario (or fortunately, from the designer's P.O.V.), the 6502 has some explicit engineering to prevent an NMI half-hijacking IRQ and BRK. The node chain ~VEC, pipe~VEC, 1578, 1368 is the secret sauce. ~VEC is low during T5 and T6 of a BRK instruction, which are the cycles that internally command the low and high byte fetches, respectively, of the jump vector (each internal command takes one cycle to appear at the address pins and Read/Write pin externally). The node pipe~VEC is connected to ~VEC only during phase 2. pipe~VEC grounds 1578 and it grounds 1368 in turn. The therapeutic effect is that node 1368 is kept grounded from T5 phase 2 through T0 phase 1. That prevents NMI low from being passed through to cause the NMI to be recognized at stage 1 and affect the vector fetches. NMI stage 1 is not allowed to be recognized through all of T6 and T0 at the tail end of BRK execution. As long as the NMI line stays down, the NMI will finally be stage-1-recognized at T1 phase 1. That will allow the first instruction of the IRQ/BRK handler to run before the BRK for the NMI is started.

If NMI is released under the above circumstances before T1 phase 1 is clocked in, then the NMI is entirely missed. See also the "lost NMI" condition noted in 6502 Timing of Interrupt Handling.

## RES Hijacking NMI and IRQ/BRK

How about RES hijacking NMI and IRQ/BRK? It turns out that full hijack can't quite happen, but half-hijack can.

To (attempt to) invoke a RES full hijack, the RES line must be brought low strictly during clock cycle T4 of the running BRK instruction (that's from just after clocking in T4 phase 1 to just before clocking in T5 phase 1). It must be released strictly during T5 (apply analogous boundaries).

The RES interrupt's effect upon the 6502 clock ends up getting in the way of the full hijack situation. RES stage 2 recognition is in control of selecting the vector at T5, so it fetches the low byte correctly in the next cycle. Things start to go awry on that next cycle (T6) because RES recognition stage 1 is also affecting the clock by that time, forcing it to also reset to T0. T6 still also remains in effect, though, because the BRK instruction uses an extension of the clock that RES reset cannot affect, and T6 is a part of that extension. The combined T0 T6 clock state causes actions in the same cycle that normally happen in separate cycles, and the T0 part also advances the schedule to the opcode fetch cycle (T1) by one cycle too early for fetching the vector high byte. Instead of having the full intact RES vector to address the next instruction with, it has the low byte of the RES vector used as the high byte of the opcode address, and the low byte of the address of the high byte of the RES vector appears as the low byte of the opcode address.

Restated: <RES low>FD is fetched instead of <RES high><RES low> for the jumped-to opcode. The 'FD' comes from FFFD addressing the high byte of the RES vector. Due to being both T0 and T6, the T6 phase 2 part of the state was still controlling the low byte of the address at fetch phase 1, and the T0 phase 2 part of the state was controlling the high byte of the address at fetch phase 1. Normally, the high byte of the vector is what was just read and is used for the high byte of the fetch address, but the low byte was what was just read and available instead.

The foiled full hijack behavior is actually a subset of what happens when RES is released too early after having been put down during T4 of a BRK instruction. Releasing RES one cycle later than for this full hijack case results in a different nonsensical address for the jumped-to opcode. Tipping the hat, the effective address is <<RES low>FD><RES low>. In this case, the 6502 has had the extra cycle needed to separately fetch the high byte of the jump vector (the cycle it was starved of in the other case), but fetched from <RES low>FD (like the opcode in the other case) instead of FFFD. The extra cycle also allows the low byte of the RES vector to appear in its proper position as the low byte of the opcode address.

Releasing RES two cycles later results in starting a new BRK instruction that jumps normally to the RES handler. This is because RES is held down long enough to prevent RES recognition stage 2 from being shut off by the already-running BRK instruction, and stage 2 still being alive will cause the next fetch cycle to start a new BRK instruction. The full description of what happens is covered by the worst-case RES invocation section under "Tolerances" in 6502 Interrupt Recognition Stages and Tolerances. Demonstrations of all cases are present there.

For RES half-hijacking, the RES line must be put down a full cycle later than for the full hijack case, strictly during T5. It must also be released a cycle later than for full, strictly during T6.

RES stage 2 will be recognized when T6 phase 2 is clocked in and control the fetch of the high byte of the RES vector after the lower-priority interrupt has already controlled the fetch of the low byte of its vector in T5. T0 will arrive separately (when it normally does) and the combined vector of <RES high><NMI or IRQ/BRK low> will send execution to a likely nonsensical location for code (but not as nonsensical as the results of the 2 failed full hijacks).

If RES is released later than strictly during T6, the same behavior happens as for the case of releasing two cycles later than T5 on full hijack: a new BRK instruction runs and jumps normally to the RES handler.

## BRK Protected from NMI vs. Unprotected from RES

So why is BRK protected against NMI half-hijack and not from RES? In the case of NMI, why is it left vulnerable to missing NMI entirely?

Hijacks (both successful half and failed full) by RES depend only upon RES coming up one to four transitions after recognition. In a healthy real system, it will not come up so soon, so real systems are safe from all RES hijacks. As a secondary matter, protecting BRK from RES hijack goes against the purpose of RES. It needs to be all-powerful to reliably redirect the processor to abandon its work in progress. Protection denies it the necessary power. Instead of complicating the design for a tiny niche of execution whose issue is already resolved another way, it is left simpler by being unprotected. Protection from RES is neither advisable nor necessary.

In contrast with RES, NMI half hijack is not dependent upon the NMI line coming up at all. A hijack will happen whether the surrounding system's NMI line comes up quickly or not, and the latter is normal hardware behavior. That demands protection. Without it, half-hijacks would inevitably occur during normal operation, making the system built around 6502s unreliable. The work-around of putting a JMP to NMI handling at the mixed address in ROM is just not acceptable. It would be like a fourth interrupt and would have to be documented.

The issue of potentially missing NMI (the side effect of protection) is prevented by the same real system behavior that prevents RES hijacking. A device exerting NMI will let the line up only after being answered by software action (a long time later).

It is only us hackers that can drive the simulator with transient interrupt signals that act like flaky hardware.

## Demonstrations

In all demonstrations, the NMI handler is set to F810, RES handler set to F920, and IRQ/BRK handler set to FA30.

Just in time full hijack of an IRQ by NMI.

The BRK instruction started by an IRQ is co-opted by an NMI and runs the NMI handler instead of the IRQ handler.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 11 IRQ0 during T1 phase 2 of 1st NOP
Halfcycle 12 IRQ1 during T0 T2 phase 1 of 1st NOP
Halfcycle 21 NMI0 during T4 phase 2 of IRQ BRK
Halfcycle 22 NMI1 during T5 phase 1 of IRQ BRK

```

Thwarted half-hijack of an IRQ by NMI(and NMI line held long enough for the NMI to not be missed. See also "lost NMI" in 6502 Timing of Interrupt Handling).

The BRK instruction started by an IRQ is not successfully co-opted by a late NMI and runs the first instruction of the IRQ handler, then interrupted by the NMI and runs the NMI handler.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 11 IRQ0 during T1 phase 2 of 1st NOP
Halfcycle 12 IRQ1 during T0 T2 phase 1 of 1st NOP
Halfcycle 23 NMI0 during T5 phase 2 of IRQ BRK
Halfcycle 28 NMI1 during T1 phase 1 of PHA (IRQ handler)

```

Thwarted full hijack of an IRQ by RES.

The BRK instruction started by an IRQ is co-opted by a RES that then ties its own shoes together and stumbles to an address of 20FD in the middle of nowhere. A JMP instruction placed there redirects to the RES handler anyway.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 11 IRQ0 during T1 phase 2 of 1st NOP
Halfcycle 12 IRQ1 during T0 T2 phase 1 of 1st NOP
Halfcycle 21 RES0 during T4 phase 2 of IRQ BRK
Halfcycle 22 RES1 during T5 phase 1 of IRQ BRK

```

Successful half-hijack of an IRQ by RES.

The BRK instruction started by an IRQ is co-opted late by RES, mixing high and low bytes of the different vectors to a hybrid nonsense address of F930 (F9 of RES and 30 of IRQ). A JMP instruction placed there redirects to the RES handler.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 11 IRQ0 during T1 phase 2 of 1st NOP
Halfcycle 12 IRQ1 during T0 T2 phase 1 of 1st NOP
Halfcycle 23 RES0 during T5 phase 2 of IRQ BRK
Halfcycle 24 RES1 during T6 phase 1 of IRQ BRK

```

Successful half-hijack of an NMI by RES.

The BRK instruction started by an NMI is co-opted late by RES, mixing high and low bytes of the different vectors to a hybrid nonsense address of F910 (F9 of RES and 10 of NMI). A JMP instruction placed there redirects to the RES handler.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 11 NMI0 during T1 phase 2 of 1st NOP
Halfcycle 12 NMI1 during T0 T2 phase 1 of 1st NOP
Halfcycle 23 RES0 during T5 phase 2 of NMI BRK
Halfcycle 24 RES1 during T6 phase 1 of NMI BRK

```

Coding of the program used in all of the demonstrations:

```text
;                  Interrupted user code
0200 NOP
0201 NOP           ; IRQ BRK or NMI BRK instead of running this instruction
;
;                  Intercept botched RES full-hijack of anything
20FD JMP F920      ; Jump to RES handler
;
;                  NMI handler
F810 RTI
;
;                  Intercept RES half-hijack of NMI
F910 JMP F920      ; Jump to RES handler
;
;                  RES handler (where visual6502 starts running code when finished starting up)
F920 CLI           ; Enable IRQs
F921 JMP 0200      ; Jump to user code
;
;                  Intercept RES half-hijack of IRQ/BRK
F930 JMP F920      ; Jump to RES handler
;
;                  IRQ/BRK handler
FA30 PHA           ; Save accumulator (something different than NMI's handler)
FA31 PLA           ; Pull back
FA32 RTI

```

## External References

"late NMI" and "lost NMI" in 6502 Timing of Interrupt Handling6502 Timing States6502 Interrupt Recognition Stages and Tolerances

# Visual6502wiki/6502 Interrupt Recognition Stages and Tolerances

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Interrupt_Recognition_Stages_and_Tolerances

The following is based upon drawing the node and transistor networks out on paper from visual6502 data, and conducting experiments with the simulator. References are made to 6502 clock states that are described in 6502 Timing States, which may be used as a primer for this exposition.

## Stages of Interrupt Recognition

There are four stages of recognition of interrupt signals within the 6502, numbered from zero to three.

Stage 0 of interrupt recognition converts the asynchronous interrupt signals into synchronous interrupt signals. It is a subnetwork of nodes and transistors that react to the change in the interrupt line only when one particular phase is in effect. The synchronous interrupt signals change with the phase changes caused by clock pulses, allowing them to mesh with the processor's cycle-structured operation and thus instruction execution. The output of the sync complexes change only during one half of a cycle, and stay stable for the other half of a cycle.

Stage 0 of interrupt recognition (or clearing of recognition) happens at phase 2. When an interrupt line changes state during phase 1, the output node of the complex will switch state when phase 2 is clocked in. When an interrupt line changes state during phase 2, the output node of the complex will switch state immediately.

The synchronization of IRQ and NMI have identical topologies and the output for a recognized interrupt is high at phase 2. RES has a variation on the sync topology that makes its output the opposite (low) at phase 2 for a recognized RES.

Stage 1 of interrupt recognition happens at phase 1, immediately after the phase 2 of stage 0 recognition. Later on we'll see an exceptional case for the immediacy of the NMI interrupt.

Stage 1 of RES is represented by the node RESP going high and starting a signal chain that will set the 6502 clock to the T0 state one cycle later, at the next phase 1.

Stage 1 of NMI is represented by node ~NMIG grounded low. In addition to being stage 1 of pending NMI status, it is also responsible for selecting the NMI vector used by BRK.

Stage 1 of IRQ is represented by node IRQP high.

Independently, both ~NMIG and IRQP connect two signal chains that ordinarily stay unconnected. The sending chain carries a signal from the clock and PLA that can be described as clock-T0/branch-T2, and the receiving chain sets NMI/IRQ stage 2 recognition. When the IRQ disable bit is high, it prevents the connection enabled by IRQP. ~NMIG low will always enable the connection (one of the ways it exerts a higher priority).

The progression from stage 1 to stage 2 differs markedly at this point between RES and NMI/IRQ together. RES always proceeds to stage 2 after stage 1 in the same cycle, at phase 2. NMI and IRQ have to wait until the 6502 clock reaches its T0 or its T2 state, depending upon what kind of instruction is executing. This is the feature that allows the currently running instruction to finish before being interrupted by IRQ or NMI. IRQ and NMI's stage 2 also happens at phase 2 during the required clock state.

Stage 2 of interrupt recognition enables the next fetch cycle to invoke the interrupt instruction BRK. It also drives the Break bit low.

Stage 2 of RES recognition is represented by node RESG going high. As stated above, it happens when phase 2 is clocked in immediately after the phase 1 that recognized stage 1 of RES. RESG is responsible for putting the 6502 into write disabled mode, starting with the next phase 1. It is also responsible for selecting the RES vector used by BRK.

Stage 2 of NMI and IRQ recognition is represented by node INTG going high. It happens when T0 phase 2 is clocked in for non-branch instructions and branches that page-cross. It also happens when T2 phase 2 is clocked in for all branch instructions.

Stage 3 of interrupt recognition arrives with the next fetch cycle (T1) that the clock advances to. RESG or INTG high causes the fetch cycle to prepare to substitute a BRK instruction into the IR in phase 2 instead of the opcode that was read from memory in phase 1. The following T2 phase 1 sees the BRK instruction loaded into the IR and issuing its earliest execution signals. Seven cycles later, the first instruction of the appropriate interrupt handler is starting.

With the RES interrupt, the RES line must be released in order to allow stage 3 actions to be taken. While RES is down, stage 1 recognition is maintained, and that sends a signal to the 6502 clock to reset to its T0 state and suppress opcode fetch. Continued assertion of clock reset while the clock tries to advance results in a time state of T0 T+ on subsequent cycles, and fetch will still be suppressed by RES stage 1. Releasing RES stops the continued resetting of the clock, allowing it to advance to load and execute the BRK instruction for stage 3.

The latency for releasing the clock after raising the RES line is the same as the latency for recognizing stage 1 after lowering RES, plus one cycle. That's a total of just under two cycles. Stage 0 recognition must clear first at phase two of the cycle in which it was released, followed by stage 1 clearing at the very next phase 1, then one more cycle for stage 1 clearance to reach the clock to stop resetting it. Re-summarized, there will be the RES raise cycle, a cycle where stage 1 is clear and the clock is still affected by the previous cycle's stage 1, then the first cycle of the clock being free and fetch permitted. That will be 3 or 4 clock transitions: 4 if RES is raised during phase 1, 3 if RES is raised during phase 2.

### IRQ recognition tabulation

| Stage 0 | Any cycle, phase 2 |
| Stage 1 | Any cycle + 1, phase 1 |

| Stage 1 signal bridge | If IRQ disable bit is low: immediately at Stage 1 Else upon IRQ disable bit reset to low from high (and stage 1 still persists) |

| Stage 2 | If IRQ disable bit is low (stage 1 signal bridge connected): T2 phase 2 for all branch instructions T0 phase 2 for non-branch instructions and page-crossing branches Break bit goes low |

### NMI recognition tabulation

| Stage 0 | Any cycle, phase 2 |

| Stage 1 | Any cycle + 1, phase 1 Stage 1 signal bridge always happens for NMI at Stage 1 NMI vector selection on |

| Stage 2 | T2 phase 2 for all branch instructions T0 phase 2 for non-branch instructions and page-crossing branches Break bit goes low |

### RES recognition tabulation

| Stage 0 | Any cycle, phase 2 |

| Stage 1 | Any cycle + 1, phase 1 Clock reset signal starts |

| Stage 2 | Any cycle + 1, phase 2 Write disable signal starts RES vector selection on Break bit goes low |

| * | Any cycle + 2, phase 1 Clock reset to T0 Processor is write disabled |

## Clearing the Interrupt Stages

Clearance of the various stages of interrupt recognition is divided between merely releasing the corresponding interrupt line(s) to go high again, and the BRK instruction explicitly clearing the recognition. NMI edge detection reset depends upon both.

Tabulation of what BRK clears

| When | BRK actions |
-
-
| T6 phase 2 | NMI/IRQ stage 2 cleared (INTG low). IRQ stage 1 directly temporarily interdicted for one cycle (blocks IRQ stage 1 without clearing it), apparent as node Pout2 low. If there was no NMI to recognize, then this will disconnect NMI/IRQ stage 2 recognition from the clock-T0/branch-T2 signal chain. |
-
-
-
| T0 phase 1 | RES stage 2 cleared (RESG low) if RES stage 1 was cleared when T6 phase 1 was clocked in or earlier. Processor is immediately enabled to perform writes to memory. NMI stage 1 cleared (~NMIG high). This always disconnects NMI/IRQ stage 2 recognition from the clock-T0/branch-T2 signal chain. IRQ disable bit set (blocks IRQ stage 1 without clearing it). |
-
| T0 phase 2 | RES stage 2 cleared (RESG low) if RES stage 1 was cleared when T0 phase 1 was clocked in. Processor is enabled to perform writes to memory on the next phase 1 (next clock transition). |

The Break bit goes high again when all forms of stage 2 interrupt recognition (RESG OR INTG) have been cleared. Tabulated above, that ranges from as early as T6 phase 2 to as late as T0 phase 2.

NMI falling edge detection reset requires the action of BOTH the BRK instruction above AND releasing the NMI line to go high. They may happen in either order. The reset is not independently controlled by the NMI line rising high again by itself. Edge detection is reset by NMI already being up when the BRK instruction clears NMI stage 1 recognition, or by coming up after that.

The soonest that NMI can come down and cause NMI recognition again is just after T0 phase 1 is clocked in. That NMI will be recognized when T+ T1 phase 1 is clocked in. That will allow the first instruction of the NMI handler to run before another BRK instruction starts due to the new NMI.

Stage 1 of IRQ and RES recognition is cleared only by letting the respective line rise high again. The next phase 1 clocked in after releasing the line will clear stage 1.

Stage 0 of all the interrupts are cleared by raising the respective line, and clearance is recognized during phase 2.

## Tolerances

In real world systems, the interrupt lines stay down until the issuing device is answered, so minimal thresholds for invoking respective interrupts are not an issue. They can stay down for hundreds to hundreds of thousands of clock transitions typically. RES invoked manually can last at least a few tenths of seconds, as do power on invocations by dedicated hardware.

For us hackers of visual6502, extremely small durations of interrupt line activity are more relevant. Merely one clock transition while a line is down is sufficient. There are niche cases where more is required. Here's the guidance.

### Absolute minimum action needed to invoke the respective interrupt

#### IRQ

It's a little complex for IRQ.

For non-branch instructions and page-crossing branch instructions, put the IRQ line down during phase 2 of the clock cycle immediately before T0 (depends upon instruction, and watch out for indexed memory-read instructions that terminate a cycle early when they don't page-cross), then clock in T0 phase 1, IRQ line up during T0 phase 1.

For all branch instructions, IRQ line down during phase 2 of T1 (fetch cycle), clock in T2 phase 1, IRQ line up during T2 phase 1.

The page-crossing branch instructions may be treated either way.

#### NMI

NMI line down during phase 2, clock in phase 1, NMI line up during phase 1.

#### RES

RES line down during phase 2, clock in phase 1, RES line up during phase 1.

In all the above cases, the interrupt line may be put down one phase earlier just after clocking in phase 1 of the same cycle, and may be let up one phase later during phase two just before clocking in phase 1 of the next cycle.

### Maximal action needed to invoke the respective interrupt (such as when clock state and phase are unknown or not being monitored).

#### IRQ

Varies with execution time and current state of the currently running instruction, due to IRQ's level sensitivity: Simply put the IRQ line down and wait for the current instruction to finish: release when SYNC goes high (after having been low), which is T1 phase 1 of the invoked BRK instruction.

#### NMI

NMI line down and kept down for at least six (6) clock transitions. This covers the worst case of NMI coming down during T5 phase 1 of a BRK instruction, which has protection against NMI stage 1 recognition causing a mixed vector indirect jump (low byte of BRK/IRQ and high byte of NMI), and also protects against BRK failing to clear NMI stage 1 recognition.

After six transitions when put down at the worst case time, the NMI line may be safely raised during T1 phase 1, and NMI stage 1 will have been successfully recognized when that state, T1 phase 1, was clocked in. The first instruction of the IRQ/BRK handler will run and then stage 2 of NMI will be recognized, causing the next fetch cycle to start a new BRK instruction that jumps to the NMI handler.

Putting NMI down at T5 phase 1 or later and raising it back up again before T1 phase 1 will cause the "lost NMI" condition noted in 6502 Timing of Interrupt Handling.

#### RES

RES line down and kept down for at least six (6) clock transitions. This covers the worst case of RES coming down during T4 phase 1 of a BRK instruction. The long duration is needed to keep stage 2 of RES recognition alive despite the BRK instruction's attempt to shut it off.

RES stage 1 recognition resets the 6502 clock to the T0 state in the next cycle, but the BRK instruction uses an extension of the clock that RES stage 1 cannot affect. The clock ends up with a state called T0 T6 instead of pure T0. It is the T6 part that sends the signal to clear stage 2 of RES recognition, and it is the reason that the RES line must be held down extra long. The cycle after this case's T0 T6 (and otherwise pure T6) cycle is when stage 2 is normally shut off.

Stage 1 of RES recognition must be kept true during the cycle after T0 T6 to prevent stage 2 being cleared. The RES line may be safely raised during phase 1 of the cycle after T0 T6. Stage 1 of RES recognition will then not become false until phase 1 of the next cycle is clocked in (2nd after T0 T6), after the danger has passed.

With stage 2 having survived the tail end of a BRK instruction, it will cause the next fetch cycle to start a new BRK instruction that jumps to the RES handler.

##### Tabular synopsis

of the worst-case BRK events that affect RES stage 2, dual-labeled with clock time states for RES line high (Normal) and for RES line low (RES Altered).

Alternate labeling in terms of the T0 T+ clock states is clearer than the prose terms of, "cycle after T0 T6", and provides an easy cross-reference with the earlier tabulation of what BRK clears. Recall that T0 T+ clock states are caused by the continued assertion of clock reset while the clock tries to advance, due to the extended time that RES is down.

| Normal | RES Altered | Events |

| T4 | T4 | RES line down during phase 1. Stage 0 recognized at phase 2. |

| T5 | T5 | Stage 1 recognized (RESP) at phase 1. Stage 2 recognized (RESG) at phase 2. |

| T6 | T0 T6 | Stage 1 resets clock at phase 1 (& later cycles). THIS CYCLE phase 2 initiates stage 2 clear signal (node brk-done high). |

| T0 | 1st T0 T+ | Stage 2 clear effective during both phases. Stage 1 must persist to counter it. RES may be released during phase 1. |

| T+ T1 | 2nd T0 T+ | Stage 2 clear signal no longer exists. Stage 1 allowed to have gone false. |

What happens when RES is let up too early? Opcode execution jumps to one of two nonsense addresses depending upon when RES is let up. The possibilities are tabulated below, along with repeating the recommended hold time case.

| With RES down (stage 0 recognized) when T5 phase 1 is clocked in, then... |

| RES up (stage 0 cleared) when T0 T6 phase 1 is clocked in: The BRK ends one cycle early and jumps to an address of <RES low>FD, where <RES low> is the low byte of the RES vector, and it appears as the high byte of the jumped-to address. FD for the low byte of the jumped-to address is a copy of the low byte of where the RES vector high byte is located (FFFD). A new BRK instruction for the RES is NOT invoked. |

| RES up (stage 0 cleared) when 1st T0 T+ phase 1 is clocked in: The BRK ended one cycle early and is followed by a non-fetch held-clock cycle of T0 T+, then jumps to an address of <<RES low>FD><RES low>. The address formed for the opcode fetch in the previous case is used to read the high byte of the address for this case. Meanwhile, the low byte of the RES vector appears in its proper place as the low byte of the address for this case. A new BRK instruction for the RES is NOT invoked. |

| RES up (stage 0 cleared) when 2nd T0 T+ phase 1 is clocked in: The recommendation for holding down RES long enough is satisfied. The BRK ended one cycle early and is followed by two non-fetch held-clock cycles of T0 T+, then invokes a new BRK instruction for the RES. Control is transferred to the RES handler when it finishes (unless it is disturbed by RES going down again). |

Holding RES down for a cycle longer beyond the minimum time merely adds another T0 T+ cycle to the end and still results in a new BRK for RES, ad infinitum.

## Demonstrations

For all the following demonstrations, the RES vector is set to F933.

RES up before T0 T6 phase 1

A soft BRK instruction is interrupted by a brief RES that causes it to jump to <RES low>FD (33FD) where a JMP instruction redirects it to the RES handler again.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 12 RES0 during T4 phase 1 of soft BRK (phase 2 at 13 would work just as well)
Halfcycle 14 RES1 during T5 phase 1 of soft BRK (or phase 2 at 15)

```

RES up before 1st T0 T+ phase 1

A soft BRK instruction is interrupted by a one-cycle-longer RES that causes it to jump to <<RES low>FD><RES low> (<33FD>33 => 4C33) where another JMP instruction redirects it to the RES handler again.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 12 RES0 during T4 phase 1 of soft BRK (or phase 2 at 13)
Halfcycle 16 RES1 during T0 T6 phase 1 of soft BRK (or phase 2 at 17)

```

RES down long enough

A soft BRK instruction is interrupted by a two-cycle-longer (long enough) RES that causes a new BRK instruction to be started for RES, which jumps normally to the RES handler.

Schedule of the interrupts (Halfcycle numbers are 0-based):

```text
Halfcycle 12 RES0 during T4 phase 1 of soft BRK (or phase 2 at 13)
Halfcycle 18 RES1 during 1st T0 T+ phase 1 of soft BRK (or phase 2 at 19)

```

### Test program

Coding of the program used in all of the demonstrations:

```text
;                User code
0200 BRK +01     ; Soft BRK interrupted by late RES
;
;                Intercept earliest-release RES jump result
33FD JMP F933    ; Redirect to RES handler from <RES low>FD
                 ; JMP opcode of 4C used as high byte of next-earliest-release jump point
;
;                Intercept next-earliest-release RES jump result
4C33 JMP F933    ; Redirect to RES handler from <<RES low>FD><RES low>
;
;                RES handler (where visual6502 starts running code when finished starting up)
F933 JMP 0200    ; Jump to user code

```

## External References
- "lost NMI" in 6502 Timing of Interrupt Handling
- 6502 Timing States

## Further Reading
- Visual6502wiki/6502 Interrupt Hijacking

# Visual6502wiki/6502 Opcode 8B (XAA, ANE)

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Opcode_8B_(XAA,_ANE)

Of all the unsupported opcodes, 8B has had a lot of attention because it seems unpredictable. Even the same computer has been seen to act differently even with the same inputs.

## Explanation

The reason is that this opcode connects the A register to SB (the Special Bus) at both input and output: in a sense, A is both read from and written to at the same time. Unlike the stack pointer, the A register is not designed to do that, and the result is a circuit configuration which behaves in an interesting way.

Note that our switch-level simulation tends to produce wired-AND behaviour: if two logic gates both drive the same wire, then either of them can drive it low. A real 6502 usually does the same, which is why 8B - often called XAA - will more or less AND together the three inputs: the X register, the A register, and the immediate operand.

Why more or less? Two reasons: the A register is fed back on itself, and because of an interaction with the RDY input.

The A register drives the SB directly, and bits 0 and 4 read SB directly. The other 6 bits read SB through the Decimal Adjust logic, which doesn't affect the logic value but does affect the timing, the logic thresholds and the drive strengths. Exactly what happens is an analogue problem, not a digital one, so it will depend on the exact model of CPU, the variations of chip manufacture, the power supply and the temperature. We can't even model this without knowing the transistor strengths and having some idea of the transistor parameters - which we can only guess at.

The RDY input is a more digital influence on the outcome. RDY is intended to stall the CPU during read accesses, so it can read from slow memory. As it happens, the 6502 samples the databus on every falling clock edge, and loads the IDL (Input Data Latch), and then drives into the target register. Normally, the final cycle is the one which counts, overwriting the stray external values. In some computers, RDY is used to stall the CPU while the bus is used for DMA, which means the bus contains data such as video data for several cycles, except the last. In the case of XAA, every cycle's data is ANDed into A, and this is why the final value of A changes even for the same values of operand, X and A.

## Circuit Diagram

Here's an abridged circuit diagram. Note that bits 0 and 4 have direct A feedback whereas the other bits have indirect feedback. Note that phi1 is when A is written, but the preceding phi2 is when the operand is loaded and the two busses precharged high.

(Logic gate pullups shown as resistors, although in NMOS logic pullups are not usually depletion-mode transistors. They pull up to the positive rail. The pass transistors and precharges cannot pull up to the rail: they drop a threshold voltage. These considerations will affect an analogue analysis.)

## Testing this opcode

This opcode has 3 bytes of input, supposing that we're not allowing RDY to stall the machine and add more operands. We have a test program which tests 256^3 combinations of inputs and compares the final A and the two affected flags against a model. We also have a few specific combinations we've used to characterise different chips.
- <describe or define the programs here>
- <also mention the Java simulation which tests the robustness of the switch simulator results (against the order of evaluation)>

## Modelling this opcode

<mention and link to an emulator code fragment>

The base formula for XAA seens to be:

```text
A = (A | magic) & X & imm

```

"magic" defines which bits of A shine through.

## Tested CPUs

We collect here some results of testing this opcode on various CPUs from different manufacturers and in various computers.

| manufacturer | type | YYWW | country | markings | on back | device tested in | tester | magic | RDY clears #4 | stable* | N,Z flags OK** | notes |

| MOS | 6502 | 7551 | USA? | MOSMCS 65025175 | ? | KIM-1 | Michael | FF | ? | ? | ? | only minimal testing done |

| MOS | 6502 | 8402 | Philippines | MOS65020284 | PHILIPPINESIH434564 | CBM1541 | Michael | EE | ? | yes | ? | this is the chip that came with this disk drive |

| MOS | 6502B | 8207 | Korea | MOSC014377060782 | 6502KOREA5231 0703-82 | CBM1541 | Michael | EE | ? | yes | ? | from my Atari 800 |

| Rockwell | 6502 | 8228 | Mexico | R6502PR6502-118228 | R6502FMEXICO0737 | CBM1541 | Michael | FF | ? | yes | ? | Simon's; spare part bought from retailer |

| MOS | 6510 | 8337 | ? | MOS6510CBM3783 | ? | C64NTSC250407/REV.B | Michael | FF | no | yes | ? |  |

| MOS | 6510 | 8431 | Hong Kong | MOS6510CBM3184 | HONG KONGHH265111 | C64NTSC250407/REV.A | Michael | FF | no | yes | ? |  |

| MOS | 8500 | 8551 | ? | MOS8500R35185 | ? | C64PAL250425/REV.B | Michael | FE | yes | yes | ? | very early 8500 |

| MOS | 8500 | 9009 | Hong Kong | CSG85000990 24 | HONG KONGHH096205MP150SG | C64PAL250469/REV.B | Michael | FE | yes | yes | ? | very late 6502-like CPU |

| MOS | 6502AD | 8521 | ? | MOS6502AD2185 | ? | CBM1541 | Michael | FF | ? | no | ? | bit #3 of X input gets treated as "bit #3 of X & bit #4 of X" most of the time (depends on A though)very unstable1 MHz mode tested, can also do 2 MHz; chip is from a VC1571 |

| Pravetz | CM630P | 8744 | Hungary | (symbol)CM630P8744 | (none) | CBM1541 | Michael | FE | ? | no | yes | bit #4 anomalies |

| Synertek | 6502 | ???? | ? | SY6502TODO | ? | CBM1541 | Michael |  |  |  | ? | Simon's; yet to test |

| MOS | 8502 | ???? | ? | MOS8502TODO | ? | C128D | Michael |  |  |  | ? | yet to test; can do 1 MHz and 2 MHz |

| MOS | 6502 | ???? | ? | MOS6502TODO | ? | VC1581 | Michael |  |  |  | ? | yet to test; can do 1 MHz and 2 MHz |

| Synertek | SALLY | 8323 | ? | C014806-038323 | ? | Atari 800XL | Hias | 00 | - | yes | yes |  |

| Synertek | SALLY | 8320 | ? | C014806-038320 | ? | Atari 800XL | Hias | 00 | - | almost | ? | 40 errors in 256^3 full testsometimes bit 3 was set |

| Synertek | SALLY | 8408 | ? | C014806-038408 | ? | Atari 800XL | Hias | 00 | - | no | yes | ~150k - 450k errors (1% - 2.7%) in full testsometimes bit 3 set, for example A=03 X=FF imm=FF results either in 03 or 0B in repeated tests |

| Rockwell | SALLY | 8322 | ? | C014806-1211151-128322 | ? | Atari 800XL | Hias | 00 | - | no | almost | ~30k - 80k errors (0.2% - 0.5%) in full testsometimes bit 3 is set, but also bit 2 and 5 were set sometimesfor example A=5F or A=87 resulted in a set bit 3 (quite frequently), bit 5 (less frequently) or bit 2 (least frequent)only flipping from 0 to 1 observed, no flipping from 1 to 0flags were wrong 115 times (~7ppm) |

| NCR | SALLY | 8737 | ? | NCR C014806C-29F826948 S8737 | ? | Atari 800XE | Hias | 00 | - | yes | ? |  |

| ? | SALLY | ? | ? | C014806-35(C) ATARI 1980 | ? | Atari 65XE | Hias | 00 | - | no | no | This one is highly unstable and the formula seems to be more like A & X & (imm | 6E)when the CPU is cold A=FF X=FF imm=00 result in 46, later 66 and then 6E (when the CPU is warm)bit 0 often flips from 0 to 1, for example A=01 X=01 imm=0C results in 00 or 01 (01 occurring more frequently when the CPU is warm)Also bit 3 flipping from 1 to 0 was observed with A=09 X=E5 and imm=05 or 41 (result: 00 instead of 08)also the Z flag is often incorrectly set to 1 when the result is non-zero. N flag seems to be OK. |

| Rockwell | SALLY | 8328 | ? | C014806-1211151-120579 8328 | ? | Atari 130XE | Hias | 00 | - | yes | ? |  |

| Synertek | SALLY | 8324 | ? | C014806-038324 | ? | Atari 600XL | Hias | 00 | - | yes | ? |  |

| Synertek | SALLY | 8321 | ? | C014806-038321 | ? | Atari 600XL | Hias | 00 | - | no | ? | ~95k errors (0.6%) in full test, sometimes bit 3 was set |

| Synertek | SALLY | 8407 | ? | C014806-038407 | ? | Atari 800XL | Hias | 00 | - | yes | ? |  |

| Rockwell | ? | 8402 | Mexico? | R6502APR6502-138407 | ? | BBC Model B | EdS | ? | ? | ? | ? | ? |

(*)Note: "stable" means that the formula, the "magic" value and the potential #4 clearing by RDY fully describe the behavior.
(**)Note: N and Z flags are set according to the result of XAA

## Resources
- For a list of all opcodes and some explanation of what they do, see Visual6502wiki/6502 all 256 Opcodes.
- For notes on other opcodes we've explored in our simulations, see Visual6502wiki/6502 Unsupported Opcodes.
- VICE notes: 64docby John West and Marko Mäkelä
- 2004 forum threadon plus/4 world and followup thread
- 2006 forum threadon CSDb
- This issuein the VICE bugtracker on sourceforge
- This simulationon visual6502 stops at the appropriate step and traces the appropriate busses and control signals
- This simulationstalls the 6502 using RDY to show the influence of the databus

# Visual6502wiki/6502 Stack Register High Bits

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Stack_Register_High_Bits

A series of aligned photographs of the chip surface, chip substrate, and polygon model.

|  |  |  |  |  |
6507D register section

A series of aligned photographs: brightfield, brightfield with crossed polarizers, darkfield

|  |  |  |  |  |

# Visual6502wiki/6502 State Machine

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_State_Machine

This article contributed by Segher Boessenkool

There are many timing bits/flags/states in the 6502.

The ones I will discuss here are all valid for whole cycles, i.e. a phi1 followed by a phi2. There of course are others that are latched on phi2, to link everything together, but we'll ignore those.

One thing that complicates matters is the RDY input, with which you can stall the CPU for as many (non-write) cycles as you want. RDY is not handled in a uniform way at all.

Another complication is the conditional branch instructions, which take only two cycles if not taken, three if no page crossing, and four otherwise; to get such efficiency for these important instructions, evil shortcuts are taken.

And there is an assortment of optimisations and implementation tricks that we'll see when we get there.

Okay, so what states are there? The PLA has T0,T1,T2,T3,T4,T5 as inputs. There is another signal that is more like a "real" T1 as we'll see, which I'll call T1F. This is output on the SYNC pin. There is also what I call T01 (node 1357 / not node 223 in jssim), but we can optimise that away as we'll see.

The BRK instruction needs a T6; it gets a VEC1 instead (and a VEC0).

Some load instructions have the last cycle skipped if there is no page crossing in its addressing; the corresponding store instructions don't do that. And the read-modify-write (RMW) instructions have two extra cycles tucked on: SD1 and SD2 (store instructions store in the last cycle; RMW instructions read in the last "normal" cycle, and store in both SD1 and SD2).

Every instructions starts with the fetching of its first two bytes (the PC isn't incremented for the second fetch for most one-byte opcodes; exceptions are BRK RTI RTS). During this time, the PLA still decodes the previous instruction, and most of the datapath still handles that as well (even the cycle after this, the datapath is a bit behind). So the T0 and T1 inputs to the PLA actually come behind everything else; e.g. you have T2-T3-T0-T1 for a four cycle normal instruction, or T2-T3-T4-SD1-SD2-T0-T1 for a seven cycle RMW instruction. None of the decoding (except the predecode) sees the instruction during the two cycles that come before this; instead, T01 and T1F are used.

Here's a state diagram to scare you. "T01,T0" means both T01 and T0 are active; horizontal arrows are transitions when not RDY; vertical arrows are transitions when RDY. If no arrow for not RDY is given, it means the state is kept.

```text
          T01,T0  ------------------------->  T0
             |                                |
             |                                |
             v                                v
        T01,T1F,T1  ---->  T01,T1F  <----  T1F,T1
             |                |               |
             +-------------+  |  +------------+
                           |  |  |
                           v  v  v
                              T2
     (or T01,T0 if the next insn is a twocycle insn)

```

This does not show the various entries into this state diagram. The usual entry point is T01,T0. The exceptions are non-taken branches (which do T2 - T01,T1F) and taken branches that do not cross page (T2 - T3 - T01,T1F). RESET will behave quite oddly, but will end up at T01,T0 after a few cycles clocking (with RDY asserted).

Let's simplify this. We know that this state diagram is always entered somewhere with T01 asserted. T01 does two things: it clears T2,T3,T4,T5, and it asserts T0 if T1F isn't already asserted. So we do not actually need to consider it, since we know it is always on when the state diagram is entered, it won't do anything more that we don't have in there already. So we get:

```text
            T0
             |
             |
             v
          T1F,T1  -------->  T1F
             |                |
             +-------------+  |
                           |  |
                           v  v
                            T2
     (or T01,T0 if the next insn is a twocycle insn)

```

This shows that T1F is more the "real" T1. T1 is only asserted for one cycle, and then forgotten, with no successor, even when not RDY. It is the last cycle for normal instructions, and it cannot do anything external anymore anyway (the bus is used to play fetch), and it doesn't do anything spectacularly interesting (only register writeback, in fact), so it can just as well do it at once and forget about it.

The instructions with bitpatterns xxx010x1, 1xx000x0 and xxxx10x0 except 0xx01000 are two cycle instructions: resp. A immediate, X/Y immediate, and all the rest (push/pull is the excluded pattern). These instructions do not switch to T2 but immediately back to T0.

Push instructions (0x001000) switch to T0 after T2; pull instructions (0x101000) after T3; direct jump (01001100) after T2; indirect jump (01101100) after T4; jsr (00100000) after T5; rts and rti (01x00000) after T5; and brk (including all other interrupts) (00000000) after VEC1 ("T6").

Conditional branch instructions switch to T0 after T3. But they can be shortcut, we'll get to that in a minute.

Everything else is a "memory" instruction, which can have various addressing modes. "Immediate" is already handled in the two cycle stuff. For the rest we define a "Tmem" that is one of T2 to T5, depending on addressing mode:

```text
-- T2 for xxx001xx, zero page
-- T3 for xxx011xx, zero page indexed
-- T3 for xxx101xx, absolute
-- T4 for xxx11xxx, absolute indexed
-- T5 for xxxx00xx, indirect indexed / indexed indirect

```

For an instruction that does not store to memory, Tmem is followed by T0. Except, the absolute indexed and indexed indirect start T0 a cycle earlier if there was no page crossing. In Tmem the CPU issued the read to the system bus; in T0 and T1 it will do whatever it needs to do with it for the current instruction. So T2,T3,etc. are for the memory addressing part, and T0,T1 are for the actual operation.

For pure stores, it works the same, except there is never a shortcut.

For RMW instructions, after Tmem there are SD1 and SD2 cycles, and after that T0 and T1 as usual. During Tmem the original value is read; during SD1 it is written back, and the modified result computed; during SD2 the result is written.

For the "brk" instruction, there is this extra VEC1 cycle. VEC0 is active when T5 and RDY and the current instruction is a brk instruction; during VEC0, the low byte of the address of the interrupt routine is read. VEC0 is immediately followed by VEC1, and then (surprise!) the high byte is read. The cycle after VEC1 various interrupt bookkeeping tasks are done (the IRQ/NMI/RES request flop is cleared, the I (interrupt prohibit) bit is set, that kind of thing).

All interrupts are implemented by forcing a brk instruction into the instruction stream. This is done by clearing all bits in the predecode reg during T1F, if the previous cycle was T0, or it was T2 and the instruction is a branch (and of course an interrupt is pending). (All bits in the predecode reg are cleared whenever T1F is deasserted: that way, neither the two-cycle or one-byte signals will trigger at the wrong time!)

So, branches. Our journey is almost at an end!

We have seen a branch will take four cycles by the normal mechanism. If the branch stays within the current page, this can be cut to three cycles; and if the branch is not taken, it can be cut to only two.

The timing diagram for branches in the MOS hardware manual is wrong (it's the last half page of this ~180 pages excellent manual). The correct sequence is:

```text
Tn  address bus     data bus         comments
--------------------------------------------------------
T0  PC              branch opcode    fetch opcode
T1  PC + 1          offset           fetch offset
T2  PC + 2          next opcode      fetch for branch not taken
T3  PC + 2 + off    next opcode      fetch for branch taken, same page
    (w/o carry)
T0  PC + 2 + off    next opcode      fetch for branch taken, other page
    (with carry)

(T3/T4 or just T4 are left away if branch not taken or no
page crossing).

```

But that's not quite the whole story: the next instruction will start at T1, not T0: it has its first (opcode) byte fetched already. For either of the short versions, only T1F will be active; only the four-cycle branch has T1 as well. (In all cases T01 will be active, but you're supposed to have forgotten about that by now :-) )

So for the three cases, you get respectively:

```text
[ fetch our two bytes, T0/T1, yadda yadda ]
T2      PC + 2                                      next opcode
T1F     PC + 3                                      2nd byte of next

```

```text
[ fetch our two bytes, T0/T1, yadda yadda ]
T2      PC + 2                                      useless read
T3      PC + 2 + off (w/o carry)                    next opcode
T1F     PC + 3 + off                                2nd byte of next

```

```text
[ fetch our two bytes, T0/T1, yadda yadda ]
T2      PC + 2                                      useless read
T3      PC + 2 + off (w/o carry)                    useless read
T0      PC + 2 + off (with carry)                   next opcode
T1F,T1  PC + 2 + off                                2nd byte of next

```

For the "branch taken, same page" case there is an oddity with interrupts. In this case, T1F is preceded by T3 (not T0 or T2), so no interrupt can happen on the next instruction! You can mask NMIs this way even (but not reset, it messes up the timing directly).

# Visual6502wiki/6502 Timing States

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Timing_States

## Introduction

There are two things that are critical for correct instruction execution in the 6502 (indeed, for any complex CPU chip): the pattern of bits in the instruction register AND the pattern of "time code" bits from the timing control block of circuits.

Both sets of bits (IR and time code), in combination, control the output bits of the Programmable Logic Array (PLA) block of circuits. PLA outputs, in turn, affect the Random Control Logic (RCL) block of circuits, and their control outputs directly operate the connections among the registers, busses, and ALU on the other end of the chip die to actually get the instructions' work done.

In some situations, time code and PLA interaction merely starts a parallel chain of timing signals through the RCL part of the chip network that manage some actions themselves, instead of burdening the PLA with controlling them. The full state of timing control presented here includes such parallel processes.

The, "some situations", mentioned are for the Read-Modify-Write (RMW) instructions.

With all the combinations of parallel independent control and PLA-based control, the 6502's timing control has 24 states. A total of eleven nodes ("bits") comprise these states. Six of them are the time code applied to the PLA, the remaining five are part of the non-PLA control. The latter five are further divided up into three and two: three are internal-state members of timing generation, and the last two are in the RCL block.

Labeling of the time states derives from the "TIMING GENERATION LOGIC" block and the "CONTROL FLIP-FLOPS" sub-block inside the "RANDOM CONTROL LOGIC" block in Dr. Donald Hanson's block diagram, and from discussion of timing states in 6502 State Machine.

The notation developed for trace/debug output, and the notation presented hereafter in this document, uses eight fields. It lists the six explicit (PLA controlling) output nodes in numeric order first, followed by square brackets around the non-explicit internal state of timing generation (three nodes), followed by the state of the two RCL nodes.

Wherever one of the explicit nodes is inactive, a blank placeholder of ".." is present for it. Similar logic also applies to the last two fields: if *all* the nodes that they correspond to are inactive, the blank placeholder appears in the respective field (".." within square brackets for the seventh field, "..." for the eighth field). Only one node at a time is active for each of the last two fields.

The six PLA controlling nodes are T0, T+, T2, T3, T4, and T5. The second one, called T+, corresponds to T1X in the Hanson diagram. It is presented as T+ instead to correspond to the names of the PLA nodes that it affects in the visual6502 project. The PLA controllers are active when their logic states are low.

The other five nodes (squeezed into fields seven and eight) are active when their logic states are high. The seventh field, in square brackets, shows three states (due to three nodes) called T1, V0 (short for VEC0), and T6 (a synonym for VEC1). The eighth field shows two states, due to two nodes, called SD1 and SD2.

When T1 is displayed inside the seventh (bracketed) field, the external SYNC pin is also being driven high (by the node tested for T1) to indicate that the current memory read operation is for an instruction opcode.

Here are all the combinations of states (labelled, but otherwise without context).

```text
T0 .. T2 .. .. .. [..] ...    ; 1st cycle of 2 cycle opcodes
.. .. T2 .. .. .. [..] ...    ; 1st cycle of 3+ cycle opcodes
.. .. .. T3 .. .. [..] ...    ; 2nd cycle of 4+ cycle opcodes
.. .. .. T3 .. .. [..] SD1    ; 2nd cycle of RMW zp
.. .. .. .. T4 .. [..] ...    ; 3rd cycle of 5+ cycle opcodes
.. .. .. .. T4 .. [..] SD1    ; 3rd cycle of RMW zp,X & abs
.. .. .. .. T4 .. [..] SD2    ; 3rd cycle of RMW zp
.. .. .. .. .. T5 [..] ...    ; 4th cycle of 6+ cycle opcodes
.. .. .. .. .. T5 [..] SD1    ; 4th cycle of RMW abs,X & abs,Y (latter illegal)
.. .. .. .. .. T5 [..] SD2    ; 4th cycle of RMW zp,X & abs
.. .. .. .. .. T5 [V0] ...    ; 4th cycle of BRK
.. .. .. .. .. .. [T6] ...    ; 5th cycle of BRK
.. .. .. .. .. .. [..] SD1    ; 5th cycle of RMW (zp,X) & (zp),Y (illegal)
.. .. .. .. .. .. [..] SD2    ; 5th of RMW abs,X&Y, 6th of RMW (zp,X) & (zp),Y
.. .. .. .. .. .. [..] ...    ; Terminal state of opcodes that run forever
T0 .. .. .. .. .. [..] ...    ; 2nd-to-last cycle of all(*) opcodes
.. T+ .. .. .. .. [T1] ...    ; Last cycle of all(*) opcodes
.. .. .. .. .. .. [T1] ...    ; Last cycle of branches not taken & no page cross
T0 T+ .. .. .. .. [..] ...    ; Clock long-term hold by RES
T0 .. .. .. .. .. [T6] ...    ; 1 cycle after RES of BRK during T5 [V0] cycle
T0 .. .. .. .. .. [..] SD1    ; 1 cycle after RES of RMW during SD cycle
T0 .. .. .. .. .. [..] SD2    ; 1 cycle after RES of RMW just after SD cycle
T0 T+ .. .. .. .. [..] SD2    ; 2 cycles after RES (still held) of RMW during SD cycle
.. T+ .. .. .. .. [T1] SD2    ; 2 cycles after RES (released) of RMW during SD cycle

* All opcodes except branches not taken & branches taken with no page cross

```

As seen above, there are two states where three nodes are active at the same time (three-hot), twelve states where two nodes are active at the same time (two-hot), nine that are one-hot, and a single none-hot state.

The PLA subset itself has two two-hot states, six one-hot states, and one none-hot.

The low-profile "blank" notation of ".." assists visual examination of trace/debug output by keeping consistent placeholders for nodes when they are inactive, with minimized visual clutter. Aligning everything in fixed positions contributes to rapid recognition of changes.

Eight fields is a compromise between a full eleven fields of one node each, and a minimum of three fields to show states that have three nodes active at the same time. This format shows the segregation of timing's external PLA-affecting nodes from its internal nodes and from the RCL nodes. An alternative compact compromise could be to reserve two fields for the external nodes (for its two-hot states) and one field each for the internal and RCL nodes.

## Time States Seen Around Instruction Execution

During normal operation (when the clock is not under the influence of the RES interrupt line being active), only 18 of the 24 possible states actually arises.

The convention for presenting time states for instruction execution here is a a little different from that supplied in the usual programming literature in two ways: by time numbering and by first through last cycles listed.

The time numbering issue applies to matching up the time codes used in Appendix A of "MCS6500 Microcomputer Family Hardware Manual", with the time states documented here. "T0" in the manual matches with the states that have [T1] in them here (most often T+ [T1]). The rest of the time codes in the hardware manual listings match up with those here after being incremented by one. The second-to-last time code in each hardware manual listing corresponds to the T0-containing states here, and the last code in each listing is the [T1] state again.

The convention here for "first" and "last" cycle time states is focused upon when each opcode is actually occupying the instruction register (IR). The emphasis is upon the span of states in which control signals are initiated, and not upon the span over which operations are completed. The typical narrative has the opcode fetch cycle as the first one, listing [T1] through T0. Here, all instructions are listed as beginning with T2 in their time state and ending with [T1] in their time state. Although [T1] reads the opcode from memory, the instruction register (IR) is only set to the new opcode during the first half of T2 (T2 phase 1). That is the first moment of actual execution of the opcode, when it can start sending signals by affecting the states of PLA nodes and the RCL nodes further across the chip. The opcode remains undisturbed inside the IR all the way to the end of the next [T1] clock state ([T1] phase 2). This allows an instruction to do its last signal origination even during the fetching of its successor instruction by other circuits on the chip. These propagated last signals can perform the final operations of an instruction even one cycle later (T2 again) when the next instruction is in the IR. Not all instructions have any work to do by [T1], so it is sometimes an idle cycle in terms of instruction work. The strictly two-cycle instructions are always busy during [T1]. [T1] is always busy for fetching instructions.

After having gone through so much justification to start listing instruction timing states with T2, it must also be noted that there is some opcode identification that happens in the second half of [T1]. This is the predecode register's function that identifies two-cycle instructions and one-byte instructions by binary digital interference pattern. Two-cycle identification determines which of two possible T2 states will start the instruction execution. One-byte instruction identification determines whether the program counter (PC) is auto-incremented after reading the byte after the opcode during T2 (auto-increment is inhibited for one-byte instructions).

Time states with T0 in them have a special significance. All instructions must, at some late point in their execution, generate a signal that propagates around to set the clock to T0. That initiates the fetch for the next instruction at [T1] one cycle later. Instructions that don't do this run forever (but with two exceptions). There are twelve opcodes in the baseline 6502 that have this problem, and they can only be terminated by the RES interrupt. RES is effective because it sets the clock to T0 on its own, among other effects.

By contrast, the IRQ and NMI interrupts depend upon the currently running instruction to set the clock to T0 the normal way: the T0 state lets a pending IRQ or NMI signal propagate to where it causes a BRK instruction to be started at the next T2 state, beginning the response to the interrupt. This is the implementation of the IRQ/NMI feature that allows the currently running instruction to finish before starting the interrupt response. This is also its vulnerability to the "forever" instructions that don't set the clock back to T0: IRQ and NMI interrupts are locked out of having any effect while the non-terminating instruction runs. It is correct behavior that goes on for too long.

Generically, instructions run through time states of

```text
.. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] ...
.. .. .. .. T4 .. [..] ...
.. .. .. .. .. T5 [..] ...
T0 .. .. .. .. .. [..] ...
.. T+ .. .. .. .. [T1] ...

```

The above example is for an instruction that runs for six cycles. Instructions that run for fewer cycles have T0 and [T1] occur sooner:

```text
       Five cycles          |         Four cycles          |         Three cycles
.. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] ...  |  .. .. .. T3 .. .. [..] ...  |  T0 .. .. .. .. .. [..] ...
.. .. .. .. T4 .. [..] ...  |  T0 .. .. .. .. .. [..] ...  |  .. T+ .. .. .. .. [T1] ...
T0 .. .. .. .. .. [..] ...  |  .. T+ .. .. .. .. [T1] ...  |
.. T+ .. .. .. .. [T1] ...  |                              |

```

All of the above examples also apply to instructions that have variable execution times due to using indexed addressing modes: requiring one more cycle when a page crossing is required to access the correct memory address. Variable execution times for memory access applies only to instructions that only perform a read of memory.

The instructions that run in only two cycles have T0 and T2 combined into the same cycle. This is courtesy of the effects of predecode upon the clock, where it identifies two-cycle instructions.

```text
T0 .. T2 .. .. .. [..] ...
.. T+ .. .. .. .. [T1] ...

```

## Branch Instructions Timing States

The mentioned two exceptions to requiring instructions to set the clock to T0 are the conditional branch instructions. For review, branch instruction execution has three cases of behavior:

```text
* Branch not taken. Runs for two cycles.
* Branch taken without crossing a memory page. Runs for three cycles.
* Branch taken and it crosses to another memory page. Runs for four cycles.

```

The first two cases do not set the clock to T0. Instead, they bypass T0, going directly to [T1] for opcode fetch. The third case acts like a normal instruction.

The [T1] state caused by T0-bypassing is qualitatively different:

```text
.. .. .. .. .. .. [T1] ...

```

The T+ (aka T1X) node is inactive. It only appears if the previous clock state had T0 active.

Comparison of all the branch cases:

```text
        No branch           |       Branch, no cross       |      Branch with cross
.. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...
.. .. .. .. .. .. [T1] ...  |  .. .. .. T3 .. .. [..] ...  |  .. .. .. T3 .. .. [..] ...
                            |  .. .. .. .. .. .. [T1] ...  |  T0 .. .. .. .. .. [..] ...
                            |                              |  .. T+ .. .. .. .. [T1] ...

```

There is an issue with the lack of a T0 state for the first two branch instruction cases. NMI and IRQ depend upon T0 happening, so they would be locked out for the brief extra time it takes to get to a non-branch instruction (or a branch instruction of the third case). They would be completely locked out by an infinite loop of non-crossing branch instructions.

This problem is remediated for all the branch instructions by allowing the T2 state to also let a pending NMI or IRQ signal propagate further to cause the interrupt response, just like T0. The T2 window is ONLY available for the branch instructions. This window for a branch catching IRQ and NMI for the first two cases is admittedly a little narrow (2 cycles wide: [T1] followed by T2), so if it is missed, one will still have to wait until the end of the instruction after the branch (or T2 if that next instruction is a branch) to catch them. The saving grace is the prevention of IRQ and NMI lock-out by the infinite loop scenario.

In all branch cases where IRQ and NMI are caught early at T2, the branch instruction does finish. Confirming the reader's suspicions, the page-crossing case gives IRQ and NMI TWO opportunities to be caught and processed.

## BRK Instruction Timing States

The BRK instruction has a special extension of the clock for itself. The extensions originate the control signals needed to clear the interrupt state(s) of the 6502. BRK is the instruction for the processor's response to an interrupt. It is also available as a readable opcode, providing a software interrupt for debugging. It is helpful, and most general, to think of there being four ways to run a BRK instruction: pulling the RES line, pulling the NMI line, pulling the IRQ line, and reading a BRK opcode. The internal difference between the interrupt line invocation and the opcode read invocation occurs when clock state T2 phase 1 is clocked in. For the interrupt cases, the IR is cleared to all zero bits (set to the BRK opcode) instead of being set to whatever was read from memory during [T1]. For the opcode case, the same thing happens as with all other opcodes: IR is set to the bitwise NOT of the predecode register (the predecode register is itself the bitwise NOT of what was read from memory).

BRK has a different T5 state from all other instructions, and a unique T6 state of its own.

```text
.. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] ...
.. .. .. .. T4 .. [..] ...
.. .. .. .. .. T5 [V0] ...
.. .. .. .. .. .. [T6] ...
T0 .. .. .. .. .. [..] ...
.. T+ .. .. .. .. [T1] ...

```

The "V0" in the T5 state is short for VEC0. It is a node that is activated by a PLA node when the clock enters the T5 state. The signal carried independently by VEC0 propagates one cycle later to a node called VEC1: this is the T6 state. The signal continues back to the main clock one cycle later to set it to T0.

## The RMW Instructions' Timing States

These are the remaining normal operation timing states: the ones that use the independent timing signal paths in the RCL. Nodes in the PLA initiate the SD1 and SD2 states, and that signal propagation ends with setting the clock to T0.

The alignment of SD1 and SD2 with the clock states shown so far depends upon the addressing mode used by the RMWs. There are six RMW instructions: ASL, DEC, INC, LSR, ROL, and ROR. They use 4 addressing modes that reach into memory.

```text
        Zero Page           |    ZP Indexed & Absolute     |       Absolute Indexed
.. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...  |  .. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] SD1  |  .. .. .. T3 .. .. [..] ...  |  .. .. .. T3 .. .. [..] ...
.. .. .. .. T4 .. [..] SD2  |  .. .. .. .. T4 .. [..] SD1  |  .. .. .. .. T4 .. [..] ...
T0 .. .. .. .. .. [..] ...  |  .. .. .. .. .. T5 [..] SD2  |  .. .. .. .. .. T5 [..] SD1
.. T+ .. .. .. .. [T1] ...  |  T0 .. .. .. .. .. [..] ...  |  .. .. .. .. .. .. [..] SD2
                            |  .. T+ .. .. .. .. [T1] ...  |  T0 .. .. .. .. .. [..] ...
                            |                              |  .. T+ .. .. .. .. [T1] ...

```

In all of the examples above, the time state before the SD1 state is the one that initiates the separate SD1 SD2 signal chain. For zero page addressing mode, the signal is initiated at T2 by a PLA node, and it clock phase propagates to the SD1 node by one cycle later. Contrast this against V0 being activated immediately at T5 by a PLA node for the BRK instruction.

There are still more instructions that use SD1 and SD2. They happen to be RMWs among the illegal/undocumented opcodes. They use all of the addressing modes above (plus Absolute Indexed Y that the official RMWs do not use). They also use the two indirect indexed addressing modes, (zp,X) and (zp),Y. That takes eight cycles, and those addressing modes initiate the signal chain at T5. The mnemonics for the opcodes, according to 6502 all 256 Opcodesare SLO, RLA, SRE, RRA, DCP, and ISC.

```text
.. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] ...
.. .. .. .. T4 .. [..] ...
.. .. .. .. .. T5 [..] ...
.. .. .. .. .. .. [..] SD1  <-- Unique to illegal RMW (zp,X) and (zp),Y
.. .. .. .. .. .. [..] SD2
T0 .. .. .. .. .. [..] ...
.. T+ .. .. .. .. [T1] ...

```

The unique timing state added to the collection that doesn't happen with any of the official instructions is the all blank state with SD1.

## Forever Instructions

There's one more time state from normal operation to be introduced.

```text
.. .. T2 .. .. .. [..] ...
.. .. .. T3 .. .. [..] ...
.. .. .. .. T4 .. [..] ...
.. .. .. .. .. T5 [..] ...
.. .. .. .. .. .. [..] ...
.. .. .. .. .. .. [..] ...  <-- etc, never changes

```

The above is from any of the twelve illegal opcodes that runs forever. The all blank time state shows that there is no signal in progress that will set the clock back to T0 to initiate the fetch of a new instruction.

## Time States That Do Not Occur During Normal Instruction Execution

```text
T0 .. .. .. .. .. [T6] ...    ; 1 cycle after RES of BRK during T5 [V0] cycle
T0 T+ .. .. .. .. [..] ...    ; Clock long-term hold by RES
T0 .. .. .. .. .. [..] SD1    ; 1 cycle after RES of RMW during SD cycle
.. T+ .. .. .. .. [T1] SD2    ; 2 cycles after RES (released) of RMW during SD cycle
T0 T+ .. .. .. .. [..] SD2    ; 2 cycles after RES (still held) of RMW during SD cycle
T0 .. .. .. .. .. [..] SD2    ; 1 cycle after RES of RMW just after SD cycle

```

These are all due to the RES interrupt aborting various instructions at specific times during their operation. Some background on when RES is sensed and its short term effects on the clock is necessary.

The RES interrupt line being down (asserted) is first sensed when clock phase 2 is changed to clock phase 1 (when phase 1 is "clocked in"). If RES is asserted after the processor is already in phase 1, it will not be sensed until the next time that phase 1 is clocked in.

The clock cycle that begins with this phase 2 to phase 1 transition shall be called the "sense cycle". Its clock time state is not affected. The time state for the next clock cycle IS affected: it is changed to T0 by RES having been sensed.

```text
    Tn-1 Phase 1
    Tn-1 Phase 2

RES asserted (low)
    Tn Phase 1              <==+
RES de-asserted (high)         |- RES sense cycle
    Tn Phase 2              <==+

    T0 Phase 1              <==\_ T0 cycle caused by RES
    T0 Phase 2              <==/

```

The newly invented term, "sense cycle", shall be used shortly.

The time state:

```text
T0 .. .. .. .. .. [T6] ...

```

is caused by RES interrupting a BRK instruction at a sense cycle of T5 [V0].

The time state:

```text
T0 T+ .. .. .. .. [..] ...

```

arises when RES is down when a T0 phase 1 clock state is clocked in. This can be either the T0 that is usually scheduled by an instruction's imminent termination, or the T0 caused by instruction abort shown above. Holding down RES long enough causes the T0 T+ state to arise.

```text
   Instruction's own T0   |     T0 caused by RES
--------------------------|--------------------------
      Tn Phase 2          |      Tn-1 Phase 2
                          |
  RES asserted (low)      |  RES asserted (low)
      T0 Phase 1          |      Tn Phase 1
  RES de-asserted (high)  |      Tn Phase 2
      T0 Phase 2          |
                          |      T0 Phase 1
      T0 T+ Phase 1       |  RES de-asserted (high)
      ...etc.             |      T0 Phase 2
                          |
                          |      T0 T+ Phase 1
                          |      ...etc.

```

The sense cycle for T0 T+ can be any clock time for all instructions other than the RMWs. For the RMW instructions, the sense cycle must not be its SD chain initiation cycle. That cycle is T2 for zero page mode, T3 for zero page indexed and absolute (unindexed) modes, T4 for absolute indexed modes (X and Y), and T5 for the indirect and indexed modes (illegal RMWs).

The rest of the time states occur only with the RMW instructions.

The time state:

```text
T0 .. .. .. .. .. [..] SD1

```

occurs if the sense cycle for RES is the SD chain initiation cycle of an RMW. If RES rises back up before this (T0) cycle's phase 1 is clocked in, then the next time state will be:

```text
.. T+ .. .. .. .. [T1] SD2

```

If, however, RES stays down until after the T0 SD1 cycle's phase 1 is clocked in, then the next time state will instead be:

```text
T0 T+ .. .. .. .. [..] SD2

```

This is exactly the same situation as the T0 T+ state without SD2: the SD signal just happens to be propagating independently in parallel with T0 T+.

An extra phenomenon to note with T0 SD1 followed by T+ [T1] SD2: the T0 SD1 state would have caused the opcode read state (T+ [T1] SD2) to be in write mode (!) were it not for RES having already forced the 6502 to be in read-only mode. Elaborating further: the 6502 will have been in read-only mode since during the T0 SD1 cycle, which is the cycle after the sense cycle. The effect of SD1 commanding a write operation shows up at the external read-write pin one cycle later, when we are in the T+ [T1] SD2 state, but RES has already overridden that to be a read (and maintaining consistency with SYNC being high to indicate opcode read).

The final time state to present,

```text
T0 .. .. .. .. .. [..] SD2

```

occurs if the sense cycle for RES is the SD1 cycle for an RMW (the cycle after the SD chain initiating cycle).

## Demonstration of All Time States

This linkruns the expert version of visual6502 with a minimal 6502 program, including five RES interrupts, that causes the appearance of all the time code states documented above.

The human readable coding of the program:

```text
;                  Test 1
02EC LDA #0B       ; Change RES vector to 030B for test 2
02EE STA FFFC
02F1 LDA #03
02F3 STA FFFD
02F6 LDA (00,X)    ; Show all common T states (a 6 cycle instruction)
02F8 CLC           ; Show T0 T2 (a 2-cycle instruction)
02F9 BCS 02FB      ; Show [T1] at end (AKA next opcode fetch), after this one's T2 (no branch)
02FB BCC 02FD      ; Show [T1] at end (AKA next opcode fetch), after this one's T3 (branch, no page cross)
02FD BCC 0300      ; Show branch with page cross
02FF FF            ; FF padding
0300 INC 00        ; Show T3 SD1 and T4 SD2
0302 INC 0000      ; Show T4 SD1 and T5 SD2
0305 INC 0000,X    ; Show T5 SD1 and blank SD2
0308 SLO (00),Y    ; Show blank SD1 and blank SD2
030A KIL           ; Show all blank
Phase 123, RES0    ; RES down during second T blank Phase 2
Phase 126, RES1    ; RES up after clocking in T0 Phase 1
                   ; Shows T0 T+ state before invoking RES BRK
                   ; The RES invoked BRK shall also show the T5 [V0] and the [T6] states
;
;                  Test 2
030B LDA #12       ; Change RES vector to 0312 for test 3
030D STA FFFC
0310 INC 00
Phase 157, RES0    ; RES down during T+ [T1] Phase 2
Phase 158, RES1    ; RES up after clocking in T2 Phase 1
                   ; Shows T0 SD1 and T+ [T1] SD2 states before RES BRK
                   ; Also hiccups a second T0 and T+ [T1] before RES BRK
;
;                  Test 3
0312 LDA #19       ; Change RES vector to 0319 for test 4
0314 STA FFFC
0317 INC 00
Phase 193, RES0    ; RES down during T+ [T1] Phase 2
Phase 196, RES1    ; RES up after clocking in T0 Phase 1
                   ; Shows T0 T+ SD2 state before RES BRK
;
;                  Test 4
0319 LDA #20       ; Change RES vector to 0320 for test 5
031B STA FFFC
031E INC 00
Phase 229, RES0    ; RES down during T2 Phase 2
Phase 230, RES1    ; RES up after clocking in T3 Phase 1
                   ; Shows T0 SD2 before RES BRK
;
;                  Test 5
0320 LDA #27       ; Change RES vector to 0327 for end (not absolutely necessary)
0322 STA FFFC
0325 BRK #01
Phase 267, RES0    ; RES down during T4 Phase 2
Phase 272, RES1    ; RES up after clocking in first T0 T+ Phase 1
                   ; Shows T0 [T6] before RES BRK
                   ; Only needs RES down for one clock pulse to cause T0 [T6], but needs RES down for five clock pulses
                   ; to outlast the signal from T6 that turns off the interrupt state, allowing us to successfully
                   ; invoke a RES BRK
                   ; That's preferable to the unpredictable PC after a failed invocation of RES BRK (0000, 00FD seen)
0327 NOP           ; Confirm end

```

Some extra effects are noticed from the interaction of RES and the interrupted instruction. The RMW instructions can "hiccup" an extra pair of T0 and T+ [T1] states after the T0 and T+ [T1] states caused directly by RES. This happens when the sense cycle for RES is the SD initiating cycle for the instruction's addressing mode, and RES is let back up before the T0 caused by RES is clocked in (before T0 phase 1). The second T0 is caused by the SD signal chain propagating back to the clock, re-setting it to T0 when it would have gone to the T2 state.

The RMW hiccup phenomenon delays the reset response by an extra two cycles. The delay can be reduced to only one extra cycle by holding RES down long enough to clock in T0 phase 1, and then let RES up before clocking in the next phase 1. After T0 SD1, that will cause the T0 T+ SD2 state to arise (instead of T+ [T1] SD2), and then T+ [T1] after that. The T+ [T1] state will be unaffected by the arrival of the clock resetting signal, unlike states T2 and beyond.

The other extra effect is the requirement for RES to be held down for longer than the minimum needed to be sensed when the instruction being interrupted is a BRK, and it is interrupted with a sense cycle of T5 [V0] or [T6]. The signal chain through the clock extension for BRK will normally turn off the interrupt state (nodes RESG and INTG in visual6502) in phase 1 of the cycle after the _T6_ cycle ("_T6_" meaning a time state that has [T6] active in it, of which there are two: plain [T6] and T0 [T6]). Sustaining RESG through that cycle after _T6_ requires RES to be held down until after phase 1 of that cycle has been clocked in. That's a minimum of five clock pulses for sense at T5 [V0], and three clock pulses for sense at [T6]. Holding RES down so long keeps another node (RESP) on for both phases of that cycle-after-_T6_. RESP keeps the RESG node from being grounded by the shut-off signal. The shut-off signal is fully extinct at phase 1 of the second cycle after _T6_.

When RES is not held down for long enough, one can see RESG turned off late at phase 2 of the cycle after _T6_. When RESP changes state in phase 1, its effect upon RESG is not immediate: there's a further node that is connected to RESP only during phase 2, and that further node (named pipephi2Reset0x) has direct influence upon RESG. Only when phase 2 arrives is that further node connected to RESP again and changed to the same state.

In our case of the further node being driven false by phase 2 connection to a false RESP, it allows RESG to be grounded by the shut-off signal. The phase 2 delay also causes the opposite behavior when RESP goes true: phase 2 of the sense cycle sees RESG ungrounded and become true.

The phase 2 shut-off of RESG happens when RES is held for 4 and 3 clock pulses after sense at T5 [V0], and held for less than three pulses after sense at [T6]. RES hold for 2 and 1 clock pulses after sense at T5 [V0] results in the normal RESG shut-off time.

The normal RESG shut-off (phase 1) corresponds to RESP false during _T6_ and the cycle after _T6_. The late RESG shut-off at phase 2 corresponds to RESP true during _T6_ and false during the cycle after _T6_. Prevention of RESG shut-off corresponds to RESP true during _T6_ and the cycle after _T6_.

We can conclude this last tangent with what happens to BRK execution when RES is not held long enough. Sense cycle of T5 [V0] with all RES holds less than five pulses messes up the PC and fetches the next opcode from an unpredictable address (0000 and 00FD have been witnessed). Sense cycle of [T6] with RES holds of two and one pulses merely substitutes the RES vector for the BRK/IRQ vector and puts control into the RES handler. The original BRK instruction otherwise finishes normally without really being interrupted.

## External References

Dr. Donald Hanson's block diagram

6502 State Machine

"MCS6500 Microcomputer Family Hardware Manual"

6502 all 256 Opcodes

"A taken branch delays interrupt handling by one instruction"forum thread

# Visual6502wiki/6502 Timing of Interrupt Handling

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Timing_of_Interrupt_Handling

This page contains some as-yet unpolished extracts from postings by user Hydrophilic on commodore128.org, material used by permission.

This page contains work in progress and unanswered questions, which should be answered by reference to visual6502 simulation URLs.

### Interrupt handling sequence

The 6502 performs an interrupt as a 7-cycle instruction sequence which starts with an instruction fetch. (Is this true when the interrupted instruction is a branch?) The fetched instruction is substituted by a BRK in the IR.
- IRQ during INCshowing the latest point at which an IRQ will affect the next instruction.
- IRQ during SEIwhich does take effect before the I bit is set
- IRQ one half-cycle later during SEIwhich does not take effect: I has been set and masks the interrupt

### Interrupts colliding
- this needs to be studied and verified. Observations by Hydrophilic follow

This simulationshows a lost NMI. NMI is brought low when doing an IRQ acknowledge. Specifically, 1/2 cycle before fetching the IRQ vector (cycle 13 phase 2). NMI remains low for 2.5 cycles. NMI returns high on cycle 16 phase 1.

The NMI is never serviced. This *might* be due #NMIP being automatically cleared after fetching PC high during any interrupt response...

### Interrupts and changes to I mask bit

Instructions such as SEI and CLI affect the status register during the following instruction, due the the 6502 pipelining. Therefore the masking of the interrupt does not take place until the following instruction is already underway. However, RTI restores the status register early, and so the restored I mask bit already is in effect for the next instruction.
- IRQ during CLI(IRQ has no effect on following instruction, interrupt occurs on the one after that.) Described as "effect of CLI is delayed by one opcode"

### Interrupts during branches

### Some simulations for discussion
- late NMI(NMI during IRQ handling, causing NMI vector to be fetched and followed.)
- later NMI(NMI during IRQ handling, just prior to vector fetch, too late to usurp the IRQ, does not even interrupt the first instruction of the IRQ handler, but the second one.)

```text
 Perhaps this is because 'doIRQ' (line 480) is not set during the last vector fetch; that is, during cycle 15 when fetching $FFFF, 'doIRQ' is still false.  I don't know why, considering both INTG and 'normal' (line 629) have 'standard' values and there is NMI pending.
 After starting to work on INX, 'doIRQ' finally gets set correctly so that 'normal' and INTG get triggered at the end of its execution (cycle 18).  And then finally (cycle 19) the NMI is processed

```
- lost NMI(NMI during IRQ handling, showing that 2.5 cycles is too short for an NMI to be serviced if it falls during this critical time of fetching the IRQ vector)
- IRQ delayed by branch. As can be seen from previous simulations, the CPU will normally examine 'do IRQ' on the last cycle of an instruction and if it is set, will clear 'normal' (line 629) and set INTG.

However, in the last cycle of BNE (branch taken, no page cross), although the IRQ has been asserted and 'do IRQ' has been set true (cycle 6), the 'normal' and INTG lines are not updated. So the CPU continues with the next instruction, also BNE. Again 'do IRQ' is examined and the 'normal' and INTG are updated, but not during the last cycle of the instruction (as per MOS Tech specs) but actually during the next-to-last cycle (see cycle 13). Note if the branch were not taken, it would be the last cycle of the instruction.

Perhaps the designers considered cycle 2 of any branch instruction to be the 'natural' end and check 'do IRQ' there... and only there... unless a page boundary is crossed.

Now that I think of it, the fact that INTG is set on the second cycle of any branch instruction (regardless if branch is taken or not), means this line is set 1 cycles earlier than normal if the branch does get taken, and 2 cycles earlier than normal if the branch crosses a page boundary.

(The above commentary, as a pastebomb, should be revisited and tidied up and reconciled with other sources. If we fail to explain, we can remove our explanations and leave only our evidence.)

### Resources
- back to parent page Visual6502wiki/6502Observations
- A taken branch delays interrupt handling by one instructionforum thread on 6502.org
- A Taken branch before NMI delays NMI execution by one full instructionforum thread on AtariAge
- CLI - My 8502 is defective ???forum thread on commodore128.org
- Effects of SEI and CLI delayed by one opcode?forum thread on 6502.org
- How can POKEY IRQ Timers mess up NMI timing?forum thread on AtariAge (missed NMI)

# Visual6502wiki/6502 Unsupported Opcodes

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_Unsupported_Opcodes

The 6502 is famous for doing interesting and sometimes useful things when the program includes invalid (or unspecified) opcodes.

For a list of all opcodes and some explanation of what they do, see Visual6502wiki/6502 all 256 Opcodes.

The visual6502 simulator can help when investigating what these opcodes do, and why - see below for a few cases and pointers for exploration.

## examples
- LAXwill load both A and X - notice signals SBX and SBAC which control the writes to X and to A.
- KILwill put the T-state counter into an unrecoverable state
- XAA #$5A(also known as ANE) with A=FF
  - and with A=00shows A is OR with 00 before AND with X and the immediate value
  - for more detail see the explanation page: Visual6502wiki/6502 Opcode 8B (XAA, ANE)

## some background

Beware: different revisions of 6502 and versions from different manufacturers may have different behaviours.

For some of these opcodes, the chip does something logically predictable and our model has the same behaviour. But there may be opcodes which are not logically predictable, because they cause marginal voltages on the chip as different drivers fight one another, or a node which is undriven is sampled at a later time. In those cases, our visual6502 simulator, which is just a switch-level simulator with a couple of coarse heuristics for modelling contention and charge storage, won't do the same as a chip.

In fact, as some opcodes produce results which vary from one chip to another, no deterministic simulator could be 'accurate'. (A simulator could let you know that something is amiss)

But note that the underlying circuit data which we now have includes transistor strengths and an approximation of capacitative load: it could easily be extended for resistance and more accurate capacitance. So a more refined (lower level) simulation might shed more light on these undocumented opcodes. In fact, the FPGA modelworks differently - it moves charge from one node to another - and it might be more accurate for the difficult cases.

## resources
- back to parent page Visual6502wiki/6502Observations
- Michael Steil's presentation at 27C3youtube link direct to section on illegal opcodes
- How MOS 6502 Illegal Opcodes really workon Michael Steil's blog
- 64doc.txtby VICE team
- Extra Instructions Of The 65XX Series CPUby Adam Vardy
- 6502 Undocumented Opcodesby Freddy Offenga
- 6502/6510/8500/8502 Opcode matrixby "Graham"
- Full 6502 Opcode List Including Undocumented Opcodesby J.G.Harston
- Michael Steil's presentation at 27C3(pagetable.com links to 6 sections on youtube)
- Vice BUGS documentmentions XAA being used in a Mastertronic loader
- An examination of an early tape loaderby Fungus/Nostalgia/Onslaught

# Visual6502wiki/6502 all 256 Opcodes

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_all_256_Opcodes

Starting from Graham's table, Michael Steil constructed a 3 column table containing the opcode, the mnemomic, the addressing mode and the number of clock cycles.

Then, using the C model 'perfect6502' (available on Github) which uses the same switch-level approach as the visual6502 simulator, he wrote automated tests that feed in all kinds of instructions, and measures cycles, instruction length, memory accesses and register inputs and outputs. It takes about 3 minutes to go through the opcode space.

This is what the output means:
- bytes: opcode is followed by 0s, size is calculated by the BRK address put onto the stack
- cycles: opcode is followed by 0s, on a page boundary, the time is the number of cycles between the opcode fetch and the next fetch.
  - (This does not measure the "one more if branch taken/index crosses page boundary" case.)
- AXYSP=>: registers that are used as inputs (S: stack P: status), i.e. behavior (register contents or bus I/O) changes if inputs change
- =>AXYSP=>: registers that are used as outputs, i.e. register changes if inputs (registers, memory) change
- RW: whether this opcode does memory reads and/or writes (instruction fetches are not counted)
- abs, absx, absy, zp, zpx, zpy, izx, izx: addressing mode
- CRASH is printed if the BRK instruction is not detected after 100 half-cycles

This is the output (Graham's list to the left!):

```text
 00 BRK 7        $00: bytes: 0 cycles: 0 _____=>_____ __
 01 ORA izx 6    $01: bytes: 2 cycles: 6 A____=>____P R_ izx
 02 *KIL         $02: CRASH
 03 *SLO izx 8   $03: bytes: 2 cycles: 8 A____=>____P RW izx
 04 *NOP zp 3    $04: bytes: 2 cycles: 3 _____=>_____ R_ zp
 05 ORA zp 3     $05: bytes: 2 cycles: 3 A____=>A___P R_ zp
 06 ASL zp 5     $06: bytes: 2 cycles: 5 _____=>____P RW zp
 07 *SLO zp 5    $07: bytes: 2 cycles: 5 A____=>A___P RW zp
 08 PHP 3        $08: bytes: 1 cycles: 3 ___SP=>___S_ _W
 09 ORA imm 2    $09: bytes: 2 cycles: 2 _____=>A___P __
 0A ASL 2        $0A: bytes: 1 cycles: 2 A____=>A___P __
 0B *ANC imm 2   $0B: bytes: 2 cycles: 2 A____=>____P __
 0C *NOP abs 4   $0C: bytes: 3 cycles: 4 _____=>_____ R_ abs
 0D ORA abs 4    $0D: bytes: 3 cycles: 4 A____=>A___P R_ abs
 0E ASL abs 6    $0E: bytes: 3 cycles: 6 _____=>____P RW abs
 0F *SLO abs 6   $0F: bytes: 3 cycles: 6 A____=>A___P RW abs
 10 BPL rel 2*   $10: bytes: 2 cycles: 3 ____P=>_____ __
 11 ORA izy 5*   $11: bytes: 2 cycles: 5 A____=>____P R_ izy
 12 *KIL         $12: CRASH
 13 *SLO izy 8   $13: bytes: 2 cycles: 8 A____=>____P RW izy
 14 *NOP zpx 4   $14: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 15 ORA zpx 4    $15: bytes: 2 cycles: 4 A____=>A___P R_ zpx
 16 ASL zpx 6    $16: bytes: 2 cycles: 6 _____=>____P RW zpx
 17 *SLO zpx 6   $17: bytes: 2 cycles: 6 A____=>A___P RW zpx
 18 CLC 2        $18: bytes: 1 cycles: 2 _____=>____P __
 19 ORA aby 4*   $19: bytes: 3 cycles: 4 A____=>A___P R_ absy
 1A *NOP 2       $1A: bytes: 1 cycles: 2 _____=>_____ __
 1B *SLO aby 7   $1B: bytes: 3 cycles: 7 A____=>A___P RW absy
 1C *NOP abx 4*  $1C: bytes: 3 cycles: 4 _____=>_____ R_ absx
 1D ORA abx 4*   $1D: bytes: 3 cycles: 4 A____=>A___P R_ absx
 1E ASL abx 7    $1E: bytes: 3 cycles: 7 _____=>____P RW absx
 1F *SLO abx 7   $1F: bytes: 3 cycles: 7 A____=>A___P RW absx
 20 JSR abs 6    $20: bytes: X cycles: 6 ___S_=>___S_ _W
 21 AND izx 6    $21: bytes: 2 cycles: 6 _____=>A___P R_ izx
 22 *KIL         $22: CRASH
 23 *RLA izx 8   $23: bytes: 2 cycles: 8 ____P=>A___P RW izx
 24 BIT zp 3     $24: bytes: 2 cycles: 3 A____=>____P R_ zp
 25 AND zp 3     $25: bytes: 2 cycles: 3 A____=>A___P R_ zp
 26 ROL zp 5     $26: bytes: 2 cycles: 5 ____P=>____P RW zp
 27 *RLA zp 5    $27: bytes: 2 cycles: 5 A___P=>A___P RW zp
 28 PLP 4        $28: bytes: 1 cycles: 4 ___S_=>___SP __
 29 AND imm 2    $29: bytes: 2 cycles: 2 A____=>A___P __
 2A ROL 2        $2A: bytes: 1 cycles: 2 A___P=>A___P __
 2B *ANC imm 2   $2B: bytes: 2 cycles: 2 A____=>____P __
 2C BIT abs 4    $2C: bytes: 3 cycles: 4 A____=>____P R_ abs
 2D AND abs 4    $2D: bytes: 3 cycles: 4 A____=>A___P R_ abs
 2E ROL abs 6    $2E: bytes: 3 cycles: 6 ____P=>____P RW abs
 2F *RLA abs 6   $2F: bytes: 3 cycles: 6 A___P=>A___P RW abs
 30 BMI rel 2*   $30: bytes: 2 cycles: 2 _____=>_____ __
 31 AND izy 5*   $31: bytes: 2 cycles: 5 _____=>A___P R_ izy
 32 *KIL         $32: CRASH
 33 *RLA izy 8   $33: bytes: 2 cycles: 8 ____P=>A___P RW izy
 34 *NOP zpx 4   $34: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 35 AND zpx 4    $35: bytes: 2 cycles: 4 A____=>A___P R_ zpx
 36 ROL zpx 6    $36: bytes: 2 cycles: 6 ____P=>____P RW zpx
 37 *RLA zpx 6   $37: bytes: 2 cycles: 6 A___P=>A___P RW zpx
 38 SEC 2        $38: bytes: 1 cycles: 2 _____=>____P __
 39 AND aby 4*   $39: bytes: 3 cycles: 4 A____=>A___P R_ absy
 3A *NOP 2       $3A: bytes: 1 cycles: 2 _____=>_____ __
 3B *RLA aby 7   $3B: bytes: 3 cycles: 7 A___P=>A___P RW absy
 3C *NOP abx 4*  $3C: bytes: 3 cycles: 4 _____=>_____ R_ absx
 3D AND abx 4*   $3D: bytes: 3 cycles: 4 A____=>A___P R_ absx
 3E ROL abx 7    $3E: bytes: 3 cycles: 7 ____P=>____P RW absx
 3F *RLA abx 7   $3F: bytes: 3 cycles: 7 A___P=>A___P RW absx
 40 RTI 6        $40: bytes: X cycles: 6 ___S_=>___SP __
 41 EOR izx 6    $41: bytes: 2 cycles: 6 A____=>____P R_ izx
 42 *KIL         $42: CRASH
 43 *SRE izx 8   $43: bytes: 2 cycles: 8 A____=>____P RW izx
 44 *NOP zp 3    $44: bytes: 2 cycles: 3 _____=>_____ R_ zp
 45 EOR zp 3     $45: bytes: 2 cycles: 3 A____=>A___P R_ zp
 46 LSR zp 5     $46: bytes: 2 cycles: 5 _____=>____P RW zp
 47 *SRE zp 5    $47: bytes: 2 cycles: 5 A____=>A___P RW zp
 48 PHA 3        $48: bytes: 1 cycles: 3 A__S_=>___S_ _W
 49 EOR imm 2    $49: bytes: 2 cycles: 2 A____=>A___P __
 4A LSR 2        $4A: bytes: 1 cycles: 2 A____=>A___P __
 4B *ALR imm 2   $4B: bytes: 2 cycles: 2 A____=>A___P __
 4C JMP abs 3    $4C: bytes: X cycles: 3 _____=>_____ __
 4D EOR abs 4    $4D: bytes: 3 cycles: 4 A____=>A___P R_ abs
 4E LSR abs 6    $4E: bytes: 3 cycles: 6 _____=>____P RW abs
 4F *SRE abs 6   $4F: bytes: 3 cycles: 6 A____=>A___P RW abs
 50 BVC rel 2*   $50: bytes: 2 cycles: 3 ____P=>_____ __
 51 EOR izy 5*   $51: bytes: 2 cycles: 5 A____=>____P R_ izy
 52 *KIL         $52: CRASH
 53 *SRE izy 8   $53: bytes: 2 cycles: 8 A____=>____P RW izy
 54 *NOP zpx 4   $54: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 55 EOR zpx 4    $55: bytes: 2 cycles: 4 A____=>A___P R_ zpx
 56 LSR zpx 6    $56: bytes: 2 cycles: 6 _____=>____P RW zpx
 57 *SRE zpx 6   $57: bytes: 2 cycles: 6 A____=>A___P RW zpx
 58 CLI 2        $58: bytes: 1 cycles: 2 _____=>____P __
 59 EOR aby 4*   $59: bytes: 3 cycles: 4 A____=>A___P R_ absy
 5A *NOP 2       $5A: bytes: 1 cycles: 2 _____=>_____ __
 5B *SRE aby 7   $5B: bytes: 3 cycles: 7 A____=>A___P RW absy
 5C *NOP abx 4*  $5C: bytes: 3 cycles: 4 _____=>_____ R_ absx
 5D EOR abx 4*   $5D: bytes: 3 cycles: 4 A____=>A___P R_ absx
 5E LSR abx 7    $5E: bytes: 3 cycles: 7 _____=>____P RW absx
 5F *SRE abx 7   $5F: bytes: 3 cycles: 7 A____=>A___P RW absx
 60 RTS 6        $60: bytes: X cycles: 6 ___S_=>___S_ __
 61 ADC izx 6    $61: bytes: 2 cycles: 6 A___P=>A___P R_ izx
 62 *KIL         $62: CRASH
 63 *RRA izx 8   $63: bytes: 2 cycles: 8 A___P=>A___P RW izx
 64 *NOP zp 3    $64: bytes: 2 cycles: 3 _____=>_____ R_ zp
 65 ADC zp 3     $65: bytes: 2 cycles: 3 A___P=>A___P R_ zp
 66 ROR zp 5     $66: bytes: 2 cycles: 5 ____P=>____P RW zp
 67 *RRA zp 5    $67: bytes: 2 cycles: 5 A___P=>A___P RW zp
 68 PLA 4        $68: bytes: 1 cycles: 4 ___S_=>A__SP __
 69 ADC imm 2    $69: bytes: 2 cycles: 2 A___P=>A___P __
 6A ROR 2        $6A: bytes: 1 cycles: 2 A___P=>A___P __
 6B *ARR imm 2   $6B: bytes: 2 cycles: 2 A___P=>A___P __
 6C JMP ind 5    $6C: bytes: X cycles: 5 _____=>_____ __
 6D ADC abs 4    $6D: bytes: 3 cycles: 4 A___P=>A___P R_ abs
 6E ROR abs 6    $6E: bytes: 3 cycles: 6 ____P=>____P RW abs
 6F *RRA abs 6   $6F: bytes: 3 cycles: 6 A___P=>A___P RW abs
 70 BVS rel 2*   $70: bytes: 2 cycles: 2 _____=>_____ __
 71 ADC izy 5*   $71: bytes: 2 cycles: 5 A___P=>A___P R_ izy
 72 *KIL         $72: CRASH
 73 *RRA izy 8   $73: bytes: 2 cycles: 8 A___P=>A___P RW izy
 74 *NOP zpx 4   $74: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 75 ADC zpx 4    $75: bytes: 2 cycles: 4 A___P=>A___P R_ zpx
 76 ROR zpx 6    $76: bytes: 2 cycles: 6 ____P=>____P RW zpx
 77 *RRA zpx 6   $77: bytes: 2 cycles: 6 A___P=>A___P RW zpx
 78 SEI 2        $78: bytes: 1 cycles: 2 _____=>____P __
 79 ADC aby 4*   $79: bytes: 3 cycles: 4 A___P=>A___P R_ absy
 7A *NOP 2       $7A: bytes: 1 cycles: 2 _____=>_____ __
 7B *RRA aby 7   $7B: bytes: 3 cycles: 7 A___P=>A___P RW absy
 7C *NOP abx 4*  $7C: bytes: 3 cycles: 4 _____=>_____ R_ absx
 7D ADC abx 4*   $7D: bytes: 3 cycles: 4 A___P=>A___P R_ absx
 7E ROR abx 7    $7E: bytes: 3 cycles: 7 ____P=>____P RW absx
 7F *RRA abx 7   $7F: bytes: 3 cycles: 7 A___P=>A___P RW absx
 80 *NOP imm 2   $80: bytes: 2 cycles: 2 _____=>_____ __
 81 STA izx 6    $81: bytes: 2 cycles: 6 A____=>_____ RW izx
 82 *NOP imm 2   $82: bytes: 2 cycles: 2 _____=>_____ __
 83 *SAX izx 6   $83: bytes: 2 cycles: 6 _____=>_____ RW izx
 84 STY zp 3     $84: bytes: 2 cycles: 3 __Y__=>_____ _W zp
 85 STA zp 3     $85: bytes: 2 cycles: 3 A____=>_____ _W zp
 86 STX zp 3     $86: bytes: 2 cycles: 3 _X___=>_____ _W zp
 87 *SAX zp 3    $87: bytes: 2 cycles: 3 _____=>_____ _W zp
 88 DEY 2        $88: bytes: 1 cycles: 2 __Y__=>__Y_P __
 89 *NOP imm 2   $89: bytes: 2 cycles: 2 _____=>_____ __
 8A TXA 2        $8A: bytes: 1 cycles: 2 _X___=>A___P __
 8B *XAA imm 2   $8B: bytes: 2 cycles: 2 _____=>A___P __
 8C STY abs 4    $8C: bytes: 3 cycles: 4 __Y__=>_____ _W abs
 8D STA abs 4    $8D: bytes: 3 cycles: 4 A____=>_____ _W abs
 8E STX abs 4    $8E: bytes: 3 cycles: 4 _X___=>_____ _W abs
 8F *SAX abs 4   $8F: bytes: 3 cycles: 4 _____=>_____ _W abs
 90 BCC rel 2*   $90: bytes: 2 cycles: 3 ____P=>_____ __
 91 STA izy 6    $91: bytes: 2 cycles: 6 A____=>_____ RW izy
 92 *KIL         $92: CRASH
 93 *AHX izy 6   $93: bytes: 2 cycles: 6 _____=>_____ RW izy
 94 STY zpx 4    $94: bytes: 2 cycles: 4 __Y__=>_____ RW zpx
 95 STA zpx 4    $95: bytes: 2 cycles: 4 A____=>_____ RW zpx
 96 STX zpy 4    $96: bytes: 2 cycles: 4 _X___=>_____ RW zpy
 97 *SAX zpy 4   $97: bytes: 2 cycles: 4 _____=>_____ RW zpy
 98 TYA 2        $98: bytes: 1 cycles: 2 __Y__=>A___P __
 99 STA aby 5    $99: bytes: 3 cycles: 5 A____=>_____ RW absy
 9A TXS 2        $9A: bytes: X cycles: 2 _X___=>___S_ __
 9B *TAS aby 5   $9B: bytes: X cycles: 5 __Y__=>___S_ _W
 9C *SHY abx 5   $9C: bytes: 3 cycles: 5 __Y__=>_____ RW absx
 9D STA abx 5    $9D: bytes: 3 cycles: 5 A____=>_____ RW absx
 9E *SHX aby 5   $9E: bytes: 3 cycles: 5 _X___=>_____ RW absy
 9F *AHX aby 5   $9F: bytes: 3 cycles: 5 _____=>_____ RW absy
 A0 LDY imm 2    $A0: bytes: 2 cycles: 2 _____=>__Y_P __
 A1 LDA izx 6    $A1: bytes: 2 cycles: 6 _____=>A___P R_ izx
 A2 LDX imm 2    $A2: bytes: 2 cycles: 2 _____=>_X__P __
 A3 *LAX izx 6   $A3: bytes: 2 cycles: 6 _____=>AX__P R_ izx
 A4 LDY zp 3     $A4: bytes: 2 cycles: 3 _____=>__Y_P R_ zp
 A5 LDA zp 3     $A5: bytes: 2 cycles: 3 _____=>A___P R_ zp
 A6 LDX zp 3     $A6: bytes: 2 cycles: 3 _____=>_X__P R_ zp
 A7 *LAX zp 3    $A7: bytes: 2 cycles: 3 _____=>AX__P R_ zp
 A8 TAY 2        $A8: bytes: 1 cycles: 2 A____=>__Y_P __
 A9 LDA imm 2    $A9: bytes: 2 cycles: 2 _____=>A___P __
 AA TAX 2        $AA: bytes: 1 cycles: 2 A____=>_X__P __
 AB *LAX imm 2   $AB: bytes: 2 cycles: 2 A____=>AX__P __
 AC LDY abs 4    $AC: bytes: 3 cycles: 4 _____=>__Y_P R_ abs
 AD LDA abs 4    $AD: bytes: 3 cycles: 4 _____=>A___P R_ abs
 AE LDX abs 4    $AE: bytes: 3 cycles: 4 _____=>_X__P R_ abs
 AF *LAX abs 4   $AF: bytes: 3 cycles: 4 _____=>AX__P R_ abs
 B0 BCS rel 2*   $B0: bytes: 2 cycles: 2 _____=>_____ __
 B1 LDA izy 5*   $B1: bytes: 2 cycles: 5 _____=>A___P R_ izy
 B2 *KIL         $B2: CRASH
 B3 *LAX izy 5*  $B3: bytes: 2 cycles: 5 _____=>AX__P R_ izy
 B4 LDY zpx 4    $B4: bytes: 2 cycles: 4 _____=>__Y_P R_ zpx
 B5 LDA zpx 4    $B5: bytes: 2 cycles: 4 _____=>A___P R_ zpx
 B6 LDX zpy 4    $B6: bytes: 2 cycles: 4 _____=>_X__P R_ zpy
 B7 *LAX zpy 4   $B7: bytes: 2 cycles: 4 _____=>AX__P R_ zpy
 B8 CLV 2        $B8: bytes: 1 cycles: 2 _____=>____P __
 B9 LDA aby 4*   $B9: bytes: 3 cycles: 4 _____=>A___P R_ absy
 BA TSX 2        $BA: bytes: 1 cycles: 2 ___S_=>_X__P __
 BB *LAS aby 4*  $BB: bytes: 3 cycles: 4 ___S_=>AX_SP R_ absy
 BC LDY abx 4*   $BC: bytes: 3 cycles: 4 _____=>__Y_P R_ absx
 BD LDA abx 4*   $BD: bytes: 3 cycles: 4 _____=>A___P R_ absx
 BE LDX aby 4*   $BE: bytes: 3 cycles: 4 _____=>_X__P R_ absy
 BF *LAX aby 4*  $BF: bytes: 3 cycles: 4 _____=>AX__P R_ absy
 C0 CPY imm 2    $C0: bytes: 2 cycles: 2 __Y__=>____P __
 C1 CMP izx 6    $C1: bytes: 2 cycles: 6 A____=>____P R_ izx
 C2 *NOP imm 2   $C2: bytes: 2 cycles: 2 _____=>_____ __
 C3 *DCP izx 8   $C3: bytes: 2 cycles: 8 A____=>____P RW izx
 C4 CPY zp 3     $C4: bytes: 2 cycles: 3 __Y__=>____P R_ zp
 C5 CMP zp 3     $C5: bytes: 2 cycles: 3 A____=>____P R_ zp
 C6 DEC zp 5     $C6: bytes: 2 cycles: 5 _____=>____P RW zp
 C7 *DCP zp 5    $C7: bytes: 2 cycles: 5 A____=>____P RW zp
 C8 INY 2        $C8: bytes: 1 cycles: 2 __Y__=>__Y_P __
 C9 CMP imm 2    $C9: bytes: 2 cycles: 2 A____=>____P __
 CA DEX 2        $CA: bytes: 1 cycles: 2 _X___=>_X__P __
 CB *AXS imm 2   $CB: bytes: 2 cycles: 2 _____=>_X__P __
 CC CPY abs 4    $CC: bytes: 3 cycles: 4 __Y__=>____P R_ abs
 CD CMP abs 4    $CD: bytes: 3 cycles: 4 A____=>____P R_ abs
 CE DEC abs 6    $CE: bytes: 3 cycles: 6 _____=>____P RW abs
 CF *DCP abs 6   $CF: bytes: 3 cycles: 6 A____=>____P RW abs
 D0 BNE rel 2*   $D0: bytes: 2 cycles: 3 ____P=>_____ __
 D1 CMP izy 5*   $D1: bytes: 2 cycles: 5 A____=>____P R_ izy
 D2 *KIL         $D2: CRASH
 D3 *DCP izy 8   $D3: bytes: 2 cycles: 8 A____=>____P RW izy
 D4 *NOP zpx 4   $D4: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 D5 CMP zpx 4    $D5: bytes: 2 cycles: 4 A____=>____P R_ zpx
 D6 DEC zpx 6    $D6: bytes: 2 cycles: 6 _____=>____P RW zpx
 D7 *DCP zpx 6   $D7: bytes: 2 cycles: 6 A____=>____P RW zpx
 D8 CLD 2        $D8: bytes: 1 cycles: 2 _____=>____P __
 D9 CMP aby 4*   $D9: bytes: 3 cycles: 4 A____=>____P R_ absy
 DA *NOP 2       $DA: bytes: 1 cycles: 2 _____=>_____ __
 DB *DCP aby 7   $DB: bytes: 3 cycles: 7 A____=>____P RW absy
 DC *NOP abx 4*  $DC: bytes: 3 cycles: 4 _____=>_____ R_ absx
 DD CMP abx 4*   $DD: bytes: 3 cycles: 4 A____=>____P R_ absx
 DE DEC abx 7    $DE: bytes: 3 cycles: 7 _____=>____P RW absx
 DF *DCP abx 7   $DF: bytes: 3 cycles: 7 A____=>____P RW absx
 E0 CPX imm 2    $E0: bytes: 2 cycles: 2 _X___=>____P __
 E1 SBC izx 6    $E1: bytes: 2 cycles: 6 A___P=>A___P R_ izx
 E2 *NOP imm 2   $E2: bytes: 2 cycles: 2 _____=>_____ __
 E3 *ISC izx 8   $E3: bytes: 2 cycles: 8 A___P=>A___P RW izx
 E4 CPX zp 3     $E4: bytes: 2 cycles: 3 _X___=>____P R_ zp
 E5 SBC zp 3     $E5: bytes: 2 cycles: 3 A___P=>A___P R_ zp
 E6 INC zp 5     $E6: bytes: 2 cycles: 5 _____=>____P RW zp
 E7 *ISC zp 5    $E7: bytes: 2 cycles: 5 A___P=>A___P RW zp
 E8 INX 2        $E8: bytes: 1 cycles: 2 _X___=>_X__P __
 E9 SBC imm 2    $E9: bytes: 2 cycles: 2 A___P=>A___P __
 EA NOP 2        $EA: bytes: 1 cycles: 2 _____=>_____ __
 EB *SBC imm 2   $EB: bytes: 2 cycles: 2 A___P=>A___P __
 EC CPX abs 4    $EC: bytes: 3 cycles: 4 _X___=>____P R_ abs
 ED SBC abs 4    $ED: bytes: 3 cycles: 4 A___P=>A___P R_ abs
 EE INC abs 6    $EE: bytes: 3 cycles: 6 _____=>____P RW abs
 EF *ISC abs 6   $EF: bytes: 3 cycles: 6 A___P=>A___P RW abs
 F0 BEQ rel 2*   $F0: bytes: 2 cycles: 2 _____=>_____ __
 F1 SBC izy 5*   $F1: bytes: 2 cycles: 5 A___P=>A___P R_ izy
 F2 *KIL         $F2: CRASH
 F3 *ISC izy 8   $F3: bytes: 2 cycles: 8 A___P=>A___P RW izy
 F4 *NOP zpx 4   $F4: bytes: 2 cycles: 4 _____=>_____ R_ zpx
 F5 SBC zpx 4    $F5: bytes: 2 cycles: 4 A___P=>A___P R_ zpx
 F6 INC zpx 6    $F6: bytes: 2 cycles: 6 _____=>____P RW zpx
 F7 *ISC zpx 6   $F7: bytes: 2 cycles: 6 A___P=>A___P RW zpx
 F8 SED 2        $F8: bytes: 1 cycles: 2 _____=>____P __
 F9 SBC aby 4*   $F9: bytes: 3 cycles: 4 A___P=>A___P R_ absy
 FA *NOP 2       $FA: bytes: 1 cycles: 2 _____=>_____ __
 FB *ISC aby 7   $FB: bytes: 3 cycles: 7 A___P=>A___P RW absy
 FC *NOP abx 4*  $FC: bytes: 3 cycles: 4 _____=>_____ R_ absx
 FD SBC abx 4*   $FD: bytes: 3 cycles: 4 A___P=>A___P R_ absx
 FE INC abx 7    $FE: bytes: 3 cycles: 7 _____=>____P RW absx
 FF *ISC abx     $FF: bytes: 3 cycles: 7 A___P=>A___P RW absx

```

Summary:
- The transistor-level emulation seems to be able to successfully emulate illegal opcodes as well, since the outputs for the illegal opcodes look a lot like Graham's list.
- "Unstable" illegal opcodes are probably not caused by transistor ping-pong, but by leftover trash on the external address or data bus, since the transistor calculation loop with the limiter of 100 never goes above 20, even when testing all opcodes.
- The simulator is the perfect tool to understand illegal opcodes... Well, unless you count "understanding the 6502 schematics and what's actually going on".

Note:
- This is still a work in progress.
- Some instructions were checked against the spec while writing the tests, but not everything is verified, including the simulator.
  - BRK, JSR, JMP, branches aren't correct.
- The test could be extended to do special case tests on the illegal opcodes. We can look at bus activity to see what's going on, in order to understand what potential inputs are - it is possible that some instructions do extra write cycles that nobody has measured yet.

# Visual6502wiki/6502 datapath

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_datapath

This page discusses the 6502 datapath, using the terminology from Visual6502wiki/Hanson's Block Diagramand is probably best understood by reference to it

We're interested in which datapath control signals are active in each of the two phases.

A full cycle consists of phi1 and phi2. When we say a signal is "effective", we mean it actually does something.

All datapath control signals are latched during phi2; they are set mostly from opcode and timing data, but also some internal state. We work broadly from left to right. (Which is right to left on Balazs' schematic)

### External busses and signals

DOR is latched from DB during phi1, and driven onto the data pins in phi2, if a write is done (and, on the 6501, only if the asynchronous DBE signal is on).

DL is latched during phi2, and then put on ADL, ADH, or DB on the next phi1; during phi2, the old value in DL is put on that bus.

ABL and ABH can be loaded from ADL and ADH respectively during phi1; they are put on the address pins in that same phi1, and stay there until changed again.

R/#W is latched during phi2, and then delayed until phi1, where it is output.

### Address values
ADL/ABL, ADH/ABH We already saw these. Effective on the next phi1. 0/ADL0, 0/ADL1, 0/ADL2, 0/ADH0, 0/ADH(1-7) These set the interrupt vector fetch address, and the zero page and stack high address. Effective on phi2 and the next phi1.

### The register file
Y/SB, X/SB, SB/Y, SB/X Move the X and Y registers from/to the SB. Latched on phi2, just like everything else; effective on the next phi1. SB/S, S/S, effective on the next phi1. S/SB, S/ADL, effective on phi2 and the next phi1. The S register is actually two latches in series. This makes it possible to read a value from SB and write a value to ADL at the same time. On phi2, the value from the "in" latch is forwarded to the "out" latch (and onto the driven bus, if any).

(Note the two "tuning fork" structures, which have contacts either on the top or bottom, which select whether X, Y, A write SB and DB only during phi1, or slightly longer, during "not phi2". We think this might be a timing fix, or an option left open until after silicon showed which choice worked best)

### ALU inputs
SB/ADD, 0/ADD, nDB/ADD, DB/ADD, ADL/ADD Two options for one side, three for the other. Effective on the next phi1.

### ALU operation selection
ANDS, EORS, ORS, 1/ADDC, SRS, SUMS, DAA, DSA Select the ALU operation. Effective on the next phi1 and phi2.

(The overflow and carry out signals AVR and ACR are output from the ALU back to the control logic, latched during phi2, used in phi1. The decimal carries are picked up at phi2 as well).

### ALU output register

The ALU output register (ADD) is written during phi2. The value can be used the next cycle: ADD/SB7, ADD/SB(0-6), ADD/ADL, effective on phi2 and the next phi1. The ADL output is for address calculations. For output to SB, the top bit is handled separately for rotate right instructions: the ALU always computes a zero there; by not driving it to the bus a one will be read. SB/AC, effective on the next phi1. Lines 1-3,5-7 are fed through the decimal adjust first, to finish the proper BCD add/subtract result if necessary, before writing it to the accumulator. AC/SB, AC/DB, effective on the next phi1. Write the A reg back to one of the busses.

### The Program Counter
ADH/PCH, PCH/PCH, PCL/PCL, ADL/PCL select whether to use the current PC, or take a new value from the internal address busses. Effective on the next phi1. PCH/DB, PCL/DB, PCH/ADH, PCL/ADL write the PC to one of the busses. Effective on phi2 and the next phi1. I/PC, effective during the next phi1 and phi2. Increment the PC, or not. When incrementing, the new value is put on ADL,ADH because there are no internal latches in the PC incrementer. For every instruction, the first two bytes are fetched (during execution of the previous instruction); I/PC peeks ahead (or back, if you want to look at it that way) to the next instruction that is predecoded, so it can skip incrementing PC if that is a one-byte instruction. P/DB Write the flag values to the DB; effective on phi2 and the next phi1. The DB can be read to set the flag values as well; it is read during phi2, and then latched in the flag register on the next phi1. SB/DB, SB/ADH Connect two busses together. Effective on phi2 and the next phi1.

### Precharge

All internal busses (SB, DB, ADL, ADH) are driven high during phi2, as a sort of precharge. In fact commonly they are also driven by data signals during phi2, causing an intermediate voltage to appear on the bus.

### A note on signal naming

In our Javascript simulationthe datapath control signals are tabulated according to Hanson's names, but in the layoutthey are named with a prefix according to their position across the chip. So
- SSB, SADL, SBS, SS

will be found as
- dpc4_SSB,dpc5_SADL,dpc6_SBS,dpc7_SS

in the source. See also the table below.

As Balazs used another naming scheme in his very useful but incomplete schematic, we should also cross-reference his names:

| Balazs | Hanson | JSSim | note |
| R1x7 | Y/SB | dpc0_YSB | drive sb from y |
| R1x6 | SB/Y | dpc1_SBY | load y from sb |
| R1x5 | X/SB | dpc2_XSB | drive sb from x |
| R1x4 | SB/X | dpc3_SBX | load x from sb |
| R1x2 | S/SB | dpc4_SSB | drive sb from stack pointer |
| R1x1 | S/ADL | dpc5_SADL | drive adl from stack pointer |
| R1x3 | SB/S | dpc6_SBS | load stack pointer from sb |
| ? | S/S | dpc7_SS | recirculate stack pointer |
| R2x1 | notDB/ADD | dpc8_nDBADD | alu b side: select not-idb input |
| R2x2 | DB/ADD | dpc9_DBADD | alu b side: select idb input |
| R2x3 | ADL/ADD | dpc10_ADLADD | alu b side: select adl input |
| R2x4 (??) | SB/ADD | dpc11_SBADD | alu a side: select sb |
| R2x5 | 0/ADD | dpc12_0ADD | alu a side: select zero |
| R2x6 | ORS | dpc13_ORS | alu op: a or b |
| R2x7 | SRS | dpc14_SRS | alu op: logical right shift |
| R2x8 | ANDS | dpc15_ANDS | alu op: a and b |
| R2x9 | EORS | dpc16_EORS | alu op: a xor b (?) |
| R2x12 | SUMS | dpc17_SUMS | alu op: a plus b (?) |
| ? | DAA | dpc18_#DAA | decimal related (inverted) |
| R2x14,7 | ADD/SB(7) | dpc19_ADDSB7 | alu to sb bit 7 only |
| R2x14 | ADD/SB(0-6) | dpc20_ADDSB06 | alu to sb bits 6-0 only |
| R2x15 | ADD/ADL | dpc21_ADDADL | alu to adl |
| R2x20,6 | DSA | dpc22_#DSA | decimal related/SBC only (inverted) |
| R3x4 | SB/AC | dpc23_SBAC | (optionally decimal-adjusted) sb to acc |
| R3x1 | AC/SB | dpc24_ACSB | acc to sb |
| R3x3 | SB/DB | dpc25_SBDB | sb pass-connects to idb (bi-directionally) |
| R3x2 | AC/DB | dpc26_ACDB | acc to idb |
| R3x0 | SB/ADH | dpc27_SBADH | sb pass-connects to adh (bi-directionally) |
| R3x5,0 | 0/ADH0 | dpc28_0ADH0 | zero to adh0 bit0 only |
| R3x5 | 0/ADH(1-7) | dpc29_0ADH17 | zero to adh bits 7-1 only |
| R4x2 | ADH/PCH | dpc30_ADHPCH | load pch from adh |
| R4x3 | PCH/PCH | dpc31_PCHPCH | load pch from pch incremented |
| R4x4 | PCH/ADH | dpc32_PCHADH | drive adh from pch incremented |
| R4x1 | PCH/DB | dpc33_PCHDB | drive idb from pch incremented |
| !! | PCLC | dpc34_PCLC | pch carry in and pcl FF detect? |
| Carry | PCHC | dpc35_PCHC | pcl 0x?F detect - half-carry |
| notCarry | I/PC | dpc36_#IPC | pcl carry in (inverted) |
| R5x1 | PCL/DB | dpc37_PCLDB | drive idb from pcl incremented |
| R5x4 | PCL/ADL | dpc38_PCLADL | drive adl from pcl incremented |
| R5x3 | PCL/PCL | dpc39_PCLPCL | load pcl from pcl incremented |
| R5x2 | ADL/PCL | dpc40_ADLPCL | load pcl from adl |
| Dkx2 | DL/ADL | dpc41_DL/ADL | pass-connect adl to mux node driven by idl |
| Dkx3 | DL/ADH | dpc42_DL/ADH | pass-connect adh to mux node driven by idl |
| Dkx1 | DL/DB | dpc43_DL/DB | pass-connect idb to mux node driven by idl |

# Visual6502wiki/6502 datapath control timing fix

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_datapath_control_timing_fix

This odd structure appears several times in the 6502 datapath.

A couple of transistors are connected to one clock (the on-chip phi2), but the shape of the poly shows evidence that they used to be connected to another (an inverted on-chip phi1). See the missing contacts herein the JavaScript simulator. Although contacts are not shown, you can tell that the contacts are missing from the south ends of the highlighted 'tuning fork' shape because the poly is highlighted but the horizontal metal which it crosses is not.

In the picture below, there are yellow rectangles to show the North and South ends of the poly where the shape shows possible contact cut positions. At the North end a contact cut is visible, but not at the South ends.

File:6502 photo wrong-clock-annot.jpg

That is, the gates were originally laid out so they could be clocked by not-phi1 but in fact are clocked by phi2. They control the X and the Y driving onto SB (special bus). There's another pair like them further along, which control the driving of the A onto the SB and the IDB. Seems like a fix for a timing marginality?

# Visual6502wiki/6502 increment PC control

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_increment_PC_control

The 6502 Program Counter (PC) has a dedicated incrementing circuit, which has to be able to increment across all 16 bits of the PC in a single cycle.

It (almost) always increments during an instruction fetch cycle, to fetch a possible operand, but in general the decision whether or not to increment is a complex one. The exception to incrementing during fetch is illustrated here- in the cycle when an interrupt is recognised, the instruction fetch occurs but the instruction is ignored and the PC increment is suppressed in order that the PC value can be stacked.

As it happens, some of the logic implementing that decision is absent from Balazs' schematic, probably because of a bad patch in the die photograph. It also happens to use some unusual NMOS logic techniques.

Here's the layout, as rendered by visual6502's JSSim:

File:6502-ipc-layout.png

The highlighted signal bottom centre is the negative-sense signal "dpc36_#IPC", and the highlighted signal near the middle is "short-circuit-branch-add"

Here's a diagram of the final few logic stages, which react to page-crossing branches, taken branches, single-byte instructions, interrupt handing (D1x1) and stalled cycles (use of RDY):

File:6502-ipc-logic.png

Note that the exclusive OR is implemented as a modified multiplexor which includes the subsequent AND function. The modification ensures that the AND's pulldown doesn't affect the signal notALUcout (node 206) which is used elsewhere, by pulling it down through the multiplexor's pass transistors.

Here's a transistor level view covering most of the same circuit:

File:6502-ipc-circuit.png

# Visual6502wiki/6502 traces of 6501

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502_traces_of_6501

The 6501 was the original product from MOS Technology (who, as a team, had recently left Motorola where they worked on the 6800.) It was pin-compatible but not code-compatible, and was withdrawn in a deal which left MOS free to sell the 6502 (even though it has many resemblances to the 6800)

There are several places on the NMOS 6502 where the layout shows the history: it is a modified 6501 and not an independent design.

## Pinout differences

As a quick piece of background: the 6501 was pinout compatible with 6800 - it could use the same socket. But the pins were not identical - 6501 and 6502 cannot tristate the address pins so 6501 was not compatible with a 6800 socket in a system using DMA.
- Pin 2: /Halt on 6800, +RDY on 6501 and 6502. Compatible if not used.
- Pin 5: VMA (output) on 6800, tied high internally on 6501 (all addresses valid)
- Pin 39: TSC on 6800, no connect on 6501 and 6502. Needed for DMA.

Between the 6501 and 6502 there were pinout changes and bondout changes - some of the chip's pads were bonded to different pins of the package. Of course there were also chip layout changes - but we suspect there were not many. On the 6502, we have:
- Pin 3 is phi1 (output) instead of phi1 (input).
- Pin 7 is sync instead of BA output.
- Pin 36 is no connect instead of DBE input.
- Pin 38 is SO instead of no connect
- Pin 39 is phi2 (output) instead of no connect.

However, there were pad changes - pads on the chip are bonded to posts on the inside of the package and so connect to pins on the outside of the package. Pad assignments can change without pinout assignments if the changes are not too great, and the bond wire rules allow it.

## Sync and BA

On the left hand edgeof 6502, the Sync pad (pin 7) is driven by the on-chip signal 862. This signal is routed in parallel with itself a short distance, and has a poly structure which connects the two parts and has an unused landing pad where it crosses the on-chip pipeline stall signal notRdy0. With one via removed and another added, pin 7 would act as BA (Bus Available) in a 6800-style system.

The JSSim view of this area: File:Rdy-sync-no-via-6502d-jssim.png

This area on the Rockwell R6502: File:Rdy-sync-no-via-R6502-balazs.png

This area on the 2A03: File:Rdy-sync-no-via-2A03.png

## Pad assignment changes

At top left of the 6502 die, you'll see two pads, the lower of which has odd metal routingnext to it.

This is because these two pads are DB0 and RnW, bonded to pins 33 and 34 on 6502. On the 6501, these pads would have been routed - using the odd extra metal - to DB1 and DB0 and bonded to pins 32 and 33.

(We don't know what on 6501 occupied the space where 6502 has pad DB1)

The RnW function would use the next pad around (anticlockwise), so the DBE input would use the next one around. That pushes the clk0 input over to the SO pad - and 6501 doesn't have an SO input, so that's everything. The drive transistors for RnWare already better placed for this original arrangement, and there's room for the metal connectionof the clk0 input.

## Data Bus Enable

The 6502 doesn't have the DBE input found as pin 36 on 6501/6800. But the signal exists on the chip - it's tied to cclk, which is the chip-internal version of phi2. (This is why the 6502 tristates the data bus for approximately the first half of each clock cycle)

Here's the location of the viawhich ties the two signals together.

Here's a picture showing the two signals running in parallel, even though they are on 6502 the same signal. See how they even interleave. This would represent a waste of space and effort if it the 6502 was an original design, but it's a minimal change to the 6501.

Here's a location where the Rockwell version of the chip has an extra short, compared to the MOS 6502D (and also showing that Nintendo's 2A03 has the MOS version of the layout) File:Compare-r6502-balazs-2a03-dbe-short.png

## Resources
- KIM-1 Hardware Manualshowing pinouts of 6800 and 6501 (on erik.vdbroeck's site)
- Byte articleNovember 1975 anticipating the $20 pinout-compatible 6501 (article written in August - 6501 expected in September.) (on Michael Holley's site)
- MOS Technology historymentioning $200k settlement with Motorola
- MOS Technologyarticle on wikipedia

# Visual6502wiki/650X Schematic Notes

Source: https://www.nesdev.org/wiki/Visual6502wiki/650X_Schematic_Notes

Notes on the original 650X schematics from MOS Technology.

### Origin

In 1995 Donald F. Hanson, Ph.D., published a paper based in part on the 6502 blueprints. His original work was to reverse engineer a detailed block diagramof the processor. At the time he received the blueprints from MOS Technology in 1979, he had agreed to keep them confidential, except for educational use. Earlier this year (2011), visual6502.org contacted Dr. Hanson. After some negotiations, he agreed to provide scans of the original blueprints, for educational use only. The blueprints he received were labeled Rev. C and contained a preliminary design. Since the complete and error-free design (which we refer to as Rev D) is already known through the work of visual6502.org, Dr. Hanson felt that he could provide the Rev. C blueprints to visual6502.org for their historical value, provided that they be used for educational use.

On this page we present some reduced-size images of those scans, and some findings from the information on them.

### Overview

The two blueprints, or schematics, are approximately 62 x 44 inches and 63 x 44 inches. The one labelled as 'Sheet 1' and 'bottom half' contains the register file, its drivers, and most of the data and address pads. It is dated '11/74' and bears the names Orgill and Mensch. The one labelled as 'Sheet 2' contains everything else (decode ROM, IR, control logic, timing logic, all the other pads) and is dated 8-12-75, again with the names of Orgill and Mensch.

The labels contain the description '650X-C Logic Diagram'

The broad organisation of features and placement of pads resembles that of the 6502 Rev D chip. These are therefore blueprints as much as they are schematics. The dates place them after the debut of the 6501 and 6502. However, details such as the ordering of the PLA lines differ markedly from the Rev D chip, indicating that these schematics derive from orginals which predate the final layout. (The PLA lines are labelled according to their physical ordering on the Rev D.)

The chip design is mostly represented as logic gates, as transistors, and in the case of the decode ROM as Xs on a grid to mark pulldown transistors. In many cases the physical size of the transistors are given, both for discretely drawn transistors and for logic gates. (In NMOS, electrical drive strength and therefore speed, and also load, are a direct function of size.)

The presumed die size including scribe lane is marked at bottom of sheet 1: 168 mil wide. There's no indication of the scribe lane or die height on sheet 2. (Wikipedia reportsdie height as 153 mil)

### Pin Names

Some of the pad names are different from the modern 6502 pin names:
- pin 5 is labelled VMA (for 6800 compatibility), but is No Connect on 6502
- pin 7 is labelled T1, but is now known as Sync.
- pin 36 is labelled DBE (for 6800 compatibility), but is now No Connect
- pin 38 is labelled C.P.S. but is now known as SO for Set Overflow. There's a storyabout the naming of this pin.

File:650X-CPS-pad.png

### Chip Versions: 6501, 6502 and 6504

As mentioned, the labels indicate that these schematics cover 650X - more than one variant product. Along the top edge of the upper sheet there are several boxes marked with X or O which we believe allow for a 6501 or 6502 variant using only minor changes to the contact mask.

For example here are some options relating to the on-chip clocks, which differ depending on the use of the clock pins:

File:650X-onchipclocking.png

The T1 or SYNC pin is believed to require a slight change too between 6501 and 6502, which is possible in metal, but does not appear on the schematics.

The 6504 is a 28-pin version which requires the inputs NMI, RDY and SO to be tied-off. There is no hint of this in the schematic although a metal-only change is probably possible. Tie off by bond wire might also be possible.

### Chip Revision C, ROR Bug, Other Errors

The Revision C of the 6502 has the famous ROR bug. We can see the cause in the PLA: lines 82 and 83, right in the middle, decode T0:0100101x and 010xxx1x, where they should decode T0:01x0101x and 01xxxx1x. That is, one extra pull-down on each line. Because of this, SRS is not set for ROR instructions, which causes these instructions to set SUMS and therefore shift left, and not to use the carry bit. See Michael Steil's investigationinto this.

These two lines can be seen herein the visual6502 simulation and to the right in the schematic. Note that the PLA lines appear left to right in numeric order on the chip but were drawn in a different order. (This must demonstrate that the form of the schematic predates the final layout.)

Also mention the other discrepancies in the PLA

Any other Rev C versus Rev D observations

### Schematic Errors

TBD

### Logic gates and Transistors

Mention and illustrate the presence of gates and transistors, the transistor sizes and die sizes in mils (thousandths of inch) and the presence of internal signal names - use the cross-coupled D1x1 latch to illustrate. Compare with Balazs' schematic.

### Acknowledgements

Thanks to the following for their observations and assistance
- Edgar F
- Segher Boessenkool
- Michael Steil
- Donald F Hanson, for making the scans of the 6502 available to us
- Department of Electrical Engineering, University of Mississippi, University, MS, for supporting Prof. Hanson’s work on the 6502 including the drafting of the block diagram.

### References
- Donald F. Hanson, "A VHDL Conversion Tool for Logic Equations with Embedded D Latches,", Technical Committee on Computer Architecture Newsletter, pp. 49-56, Spring 1995, IEEE Computer Society.

# Visual6502wiki/Atari's 6507 Schematics

Source: https://www.nesdev.org/wiki/Visual6502wiki/Atari%27s_6507_Schematics

These high-resolution photos of schematics are taken from http://blog.kevtris.org/blogfiles/6502/

We suspect the schematics are not original design documents but part of an industrial re-engineering.

## Atari 6507 Sheets

|  |  |  |
|  |
|  |  |
|  |
|  |  |
|  |  |  |
|  |  |  |  |  |

## Rockwell 6507 Sheets

|  |  |  |  |

# Visual6502wiki/Balazs' schematic and documents

Source: https://www.nesdev.org/wiki/Visual6502wiki/Balazs%27_schematic_and_documents

Beregnyei Balazs (family name first!) derived a schematic from his die photo and wrote up notes on the circuits.

The chip is an R6502 which is a Rockwell part but uses MOS Technology's masks.

Henry S. Courbis worked with a friend of Balazs on an English translation
- Beregnyei Balazs: 6502 Reverse Engineeringdirectory (archived)
- translated documentsdirectory: Doc and pdf.
- single page schematic730kByte pdf

Balazs gave a 40 minute presentation on the reverse engineering at Hacktivity 2011, see here(original Hungarian) and here(English voiceover).

# Visual6502wiki/Educational Resources

Source: https://www.nesdev.org/wiki/Visual6502wiki/Educational_Resources

The Visual6502 Project began with a desire to inspire and educate people about the wonders hidden deep inside their computers. Our online museum and interactive visualization technology have allowed us and the greater public to preserve, study, and collaborate to discover many exciting things about early computer technology. We're very eager to develop better educational material and to collaborate with various institutions and groups toward this end.

Here are some general resources we've found:
- The Elements of Computing Systems:Building a Modern Computer from First Principlesbook and websiteby Noam Nisan.
  - also the video"From Nand to Tetris In 12 Steps"
- SimComan in-browser simple computer by Peter Hewitt
  - the intro page
- Introduction to Vlsi Systems(book) by Mead and Conway ( see also wikipedia)
- Lynn Conway's VLSI Archive(website)
- Structured Computer Organization(book) by Andrew S. Tanenbaum
- With an OLPC XO-1you can program from the metal up using Open Firmware

Others are listed on the links pageof our website.

# Visual6502wiki/Incrementers and adders

Source: https://www.nesdev.org/wiki/Visual6502wiki/Incrementers_and_adders

Two common circuits are the incrementer and the adder. An incrementer takes one input number, and adds 1 to it; an adder takes two input numbers and adds them together, and possibly adds a single bit as well, the "carry in".

There are three ways those circuits are typically implemented in small (NMOS) circuits: bit-serial, alternating polarity carry chain, and Manchester carry chain.

### Bit-serial incrementer

The idea of the bit-serial circuit is to handle one bit per clock, the bit with the lowest numerical value first. At every step, there will be a carry in (which is 1 for the first step), and a carry out (which becomes the carry in for the next step). There also of course is an output bit at every step.

The output bit will be XOR (exclusive-or) of the input bit and the carry in; the carry out will be the logical AND if the input bit and the carry in.

### Alternating polarity carry chain

Instead of clocking N times for N bits, you can put N of those one-bit circuits in series. This would ideally make it then work in one clock period instead of in N. However, things are not so simple.

It takes time for a logic gate to produce an output. The time it takes from when the last input becomes valid to when the output of the gate becomes valid is called the "propagation delay". When you tie many gates together, the propagation delay from any input to any output should be as small as possible.

The critical path is the carry chain: if all bits in the input are 1, you get a carry out from every bit, but that output doesn't become valid until some time after that AND gate's input (the previous carry bit).

AND gates in NMOS are actually two fundamental gates in series (a NAND and a NOT). This would make the critical path take 2N steps. Luckily, there is a trick.

Instead of computing the carry for every bit, you comput the inverse of the carry for the carry out of all the even-numbered bits, and the regular carry for others. So for the even bits, instead of the AND gate, you get a NAND gate, which is a single fundamental gate. For the odd bits, you get an AND with one of its inputs complemented. Now, a NOR gate is the same as an AND with both inputs complemented. That is easy to do: just put an inverter on the input bit (it is not on the critical path, so it won't hurt!)

Now the carry chain is alternatingly a NAND gate and a NOR gate, only N fundamental gates total.

### Manchester carry chain
- tired now, will finish it later*
- TODO: pics!*

### Resources
- Wikipediaon Carry look-ahead

# Visual6502wiki/JssimUserHelp

Source: https://www.nesdev.org/wiki/Visual6502wiki/JssimUserHelp

Welcome to the JSSim javascript simulator which powers the Visual6502 and Visual6800.

Please have a look around this wiki for more informationabout our reverse engineering of various chips and the things we've found outabout them.

For a quick selection of examples of 6502 behaviour and layout, have a look at the links in the URL interface sectionon this page. Sorry, we don't yet have specific help on 6800 features.

The visual6502 simulator has two entry pages:
- The simple mode, also known as kiosk mode, which is the default
- The advanced mode

and this page starts with the basics and works up. There's also
- The visual6800(advanced mode only)

For help on reading the layout, interpreting transistor circuits, and more about digital design, please see the Visual circuit tutorial.

## Help for simple mode

In simple mode, you see the chip graphics on the left, the control buttons and chip status at top right, and the memory table below that. There's a link to the advanced page, and the overall layout is fixed: there are no draggable bars between the sections.

#### Graphics help (basic)

You can pan and zoom the chip graphics using
- '>' on the keyboard to zoom in
- '<' on the keyboard to zoom out
- click and drag to pan

Click in the graphics area to highlight any shape on the chip: all the connected shapes will be highlighted and the name of the node, if any, will be displayed in the chip status area at top right.

For example, if you click on the square shape at top left of the chip, you'll see text like

```text
node: 1297 nmi

```

which tells you that this is the NMI pad - in a real chip, it would be connected to the NMI pin of the package with a gold wire.

The node number is useful only as a unique reference number. If you're interested in the workings of the simulator you'll read the source files and see these numbers used to label all the polygons and transistors which are electrically connected and which therefore are at the same voltage - and therefore represent the same logical signal.

#### Running the program

Towards the top right you see a set of buttons:
- run (or stop) - start the simulation, run for as long as you like, then stop it.
- reset
- back
- forward

As the simulation runs you can see the yellow box in the memory area (bottom right) indicating which memory location is being read or written. You may also see the contents of memory changing: perhaps the location just to the right of {{{0040:}}} will count up.

#### Modifying the program

You can't presently modify the program in the simple page: you need the Advanced page for that.

## Help for advanced mode

In advanced mode, there's an additional area at bottom right which can tabulate the state of the machine, and any signals of interest, phase by phase or instruction by instruction. There's also a console for programs which perform I/O: it's possible to interact with a BASIC interpreter for example.

The layout in advanced mode has a couple of draggable boundaries so you can adjust according to what you're doing.

The chip graphics area has some additional controls, and can be hidden altogether.

Finally, in expert mode you can control the simulator and the graphics using additional URL parameters.

#### Graphics help (advanced)

All the graphics controls are immediately below the chip graphics area.

Use the keyboard to zoom in and out (z and x or < and >) and once you've zoomed in you can use the mouse to pan around, by clicking and dragging.

If you click on any shape in the chip, the status display (top right) will give you the coordinates and the node number, and the node name if it has one. If you click on a transistor gate, it'll give you the transistor number. If you shift-click on a node, it'll highlight all the channel-connected nodes - so you can see which busses are connected by pass gates in the present clock cycle, which gates are writing a bus and which latches are reading it.

The second line of graphics controls allow you to select layer visibility. Chips are designed and fabricated as a series of thin layers in and on the silicon. With these controls you can get a clearer idea of the geometry in each layer. For example, most of the long-distance connections are in metal, with some polysilicon. The logic gates themselves use diffusion and polysilicon only, in general.

The next line of graphics controls allow you to find the geometry corresponding to a node name, or number, or a collection of them. The Clear Highlighting button also clears the logic level indication: all the diffusion becomes yellow, all the polysilicon purple, and the metal translucent.

The 'Animate during simulation' checkbox allows you to run the simulation faster, by skipping the logic level highlighting of the chip graphics.

'Hide Chip Layout' rearranges the page layout so you can concentrate on the right hand side panels - if you're looking at the logical behaviour and not the chip layout.

Finally, 'Link to this location' provides an URL which you can share, corresponding to the current pan and zoom, so you can discuss whichever interesting layout features you find. For example
- instruction predecode
- lower nibble of the ALU
- instruction register and part of the PLA

#### Running the program

At the top of the right hand pane there is a series of buttons:
- Run/Stop will free-run the simulation. It runs faster if the chip layout is not presently visible.
- Reset will reset the chip and set time to zero.
- Back and Forward step by a single clock phase. Note the tabulation of machine state in the lower right pane. When switching direction, you may wish to use the Clear Log button to avoid confusion.
- Step will advance to the next write or the next instruction fetch.
- Fast Forward will run for a configurable number of clock phases without updating the display or the internal trace buffer. (The URL parameter headlesssteps defaults to 1000.) This is useful for benchmarking. Also, if headlesssteps is negative, the machine will free run but poll for input at that interval, which is useful for running interactive programs.

#### Interacting with the program

Any write to location $000f will cause output to the text box at the top of the lower right pane.

Location $D010 acts as a status port and $D011 acts as a data port for reading keyboard input. The status port reads 0 until a character is available.

#### Modifying the program
- interactively, you can click on the memory map and change the content of each location. The memory map is in the top right-hand pane, below the table showing the machine state and the buttons controlling the simulator.
- in the URL, you can use a= and d= to patch any addresses with data. So ...&a=400&d=eaea&... would put a couple of NOPs at $0400. Use the same technique if you wish to adjust the vectors at the top of memory. You can load quite long programs this way (in several sections, usually.)

#### Tracing machine state

The lower right pane offers some means of tracing signals of interest:
- Trace More will add some pre-defined sets of signals to the tabulation
- Trace Less removes those sets in the same order
  - Both the above can also be accessed using the loglevel URL parameter
- Trace these too: allows for a list of signals to be added to the tabulation
  - You may wish to Trace Less and then add back a different subset, or use a different order
  - You may with to explore the chip layout and find other signals to probe
- Log Up/Down allows for the tabulation to act in reverse order if you prefer not to keep scrolling to the bottom.
- Clear Log acts in the obvious way
  - It can be useful to use the single-step forward and backward in combination with log up/down to explore a few cycles of interest, because adding more signals will clear the tabulation but does not reset the cycle counter and does not clear the trace buffer: all signal activity is still stored.

#### Busses and signals of interest

You can use the 'Trace these too' box to list more signals which you're interested in - you might even use 'Trace less' several times to make this the exact list of signals to tabulate.

Some names are handled specially and are not individual signals or busses:
- cycle is the count of cycles since reset
- pc is the program counter, combining pcl and pch
- p is the status register, combining p0 to p7 (there is no p5, and p1 and p2 are probed away from the other P signals)
- tcstate collects the timing control bits, which are labelled 'clock1','clock2','t2','t3','t4','t5'
- State is a more readable version of tcstate, which names the low bits, from T0 to T5. Note that T0 and T1 are not what they seem (link needed)
- Fetch is blank unless the 'sync' pin is active, in which case it is a description of the 6502 opcode on the data bus (db).
- Execute is a description of the 6502 opcode in the ir (Instruction Register)
- plaOutputs is a list of all the active outputs from the instruction decode PLA
- DPControl is a list of all the active control signals into the datapath

If you need to tabulate a signal which is in negative sense, use a leading minus. For example, '-pd' is the instruction predecode register.

The signal names are mostly taken from Donald Hanson's block diagram

#### URL interface

There's a variety of parameters which can be passed on the URL, to make it easy to share examples and discoveries as direct links into the simulator. In all cases these are passed like this:

```text
 http://www.visual6502.org/JSSim?name1=value1&name2=value2

```
positioning the graphics window panx=240&pany=350&zoom=10select a larger canvas for improved graphical detail (uses more RAM) canvas=2000suppress the simulation, for faster startup of a purely graphical session nosim=truesuppressing graphics (same as the Hide Chip Layout button) graphics=falserunning for a fixed number of clock phases steps=10see more groups of interesting signals in the tabulation loglevel=4add specific signals to the tabulation logmore=Execute,State,plaOutputsset the fastforward step count (for benchmarking, or interactive programs) headlesssteps=250load a test program, or patch memory contents a=0000&d=a2d0de2143adjust the reset vector r=0002set up some input pin transitions (Reset, IRQ, NMI, RDY) reset0=12&reset1=13nmi0=4&nmi1=8irq0=3&irq1=20[1](RDY not yet in the released version) Note on timings of input transitions Since 2013-06-27, the displayed data for input transitions is shown one phase earlier than previously. This fixes a bug. When re-using a URL with the new version, all the chip behaviour is unchanged, but shifting the display of the input signals has made everything appear correct too. check every signal value against a golden checksum (for checking simulator code changes) steps=99&checksum=0fa98aablabel some points of interest Annotated floorplanof the 6502Some functional blocksof the 6502

The final reference on the URL capabilities is the source code.

## See also

See also the ChipSim Simulatorpage which goes into some detail on the implementation and history of the simulator, and have a look at the source code.

See also the guide to interpreting NMOS layout at the Visual circuit tutorial.

# Visual6502wiki/MOS 6502

Source: https://www.nesdev.org/wiki/Visual6502wiki/MOS_6502

## MOS 6502 family

We have photographs of the metal and lower layers, the polygons captured, the circuit extracted and we have published a javascript simulator. There is an FPGA projectto implement the simulation in hardware. We have (as yet) unpublished simulators in python and C.

## Our Analysis

Here are some relatively raw materials we've collected:
- Comparative photos of the Stack Registerin 6502 and 6507
- The Decode ROM(describing the Atari 6507, not exactly the same as the NMOS 6502 used in the visual6502 simulator
- All 256 6502 opcodesnamed and tabulated

And here is some more interpretive material from our explorations:
- Collected observationsof 6502 layout and behaviour.
- The 6502 datapath timing
- The unsupported opcodes
  - a detailed explanation of the XAA opcodebehaviour
- Implementing a realtime netlist simulationin historical systems using an FPGA

## 6502 additional information

See also the linkspage on the main site.

### Primary Sources
- Visual6502wiki/Photos of MOS 6502D(also see our website)
- Visual6502wiki/Atari's 6507 Schematics
- Visual6502wiki/Photos of R6502

### Secondary Sources
- Visual6502wiki/Hanson's Block Diagram
- Visual6502wiki/Balazs' schematic and documents

### Previous Analysis
- Beregnyei Balazs: 6502 Reverse Engineering( translation)
- Mark Ormston: 65xx Processor Data (version 0.2b)
- Ivo van Poorten: 6502 Bugs List
- Neil Parker: The 6502/65C02/65C816 Instruction Set Decoded
- Graham: 6502/6510/8500/8502 Opcode matrix
- Freddy Offenga: 6502 Undocumented Opcodes
- Adam Vardy: Extra Instructions Of The 65XX Series CPU

# Visual6502wiki/Motorola 6800

Source: https://www.nesdev.org/wiki/Visual6502wiki/Motorola_6800

See Wikipediafor good technical and historical information and references on the Motorola 6800.

### Chip Photos

We depackaged, deprocessed and photographeda later depletion-load version of the chip, which shows signs in the layout of the previous enhancement-load version. Ijor then captured polygons from the photos - here are JPEG images, which may be easier to explore than the svg format:

Medium sizeFull size (14Mbyte)

The recaptured polygon data closely resembles the original layout which defined the masks used to manufacture the chip, and is a great deal easier to study than the photographs.

### Chip Simulator

From the polygons we were able to construct a netlist, and Segher then labelled many of interior nodes, and so we present our JavaScript simulator: (graphical mode)(non-graphical mode). As with our 6502 simulator, you can explore the layout and the behaviour, find signals and transistors by name, and share short test programs by URL.

### Points of Interest

We've found these interesting features (more detail to be added):
- register circuit using resistive feedback and enhancement-style pullups
- data latch circuit using weak feedback transistor
- clock pulse shaping
  - both node 251and abh/ahdare inverted phi2 signals
  - node 95is phi2 and not abh/ahd and therefore a phi2 with a delayed rising edge
- resistive bus pullup
- Manchester carry chain
- unexplained circuitisolating IRQ and HALT near PHI1 pin

### Block Diagram

Here's the block diagram from the 1976 topology patent(See also this later patent.): File:M6800-arch.png

### Resources
- Wikipedia article
- Datasheet (pdf)(Nick Reeder at Sinclair Community College)
- Instruction set summary(comlab at Oxford University)
- Programming Model(website for SB-assembler)
- US Patent 4090236for single power supply NMOS microprocessor (filed 1976, granted '78) contains block diagrams, state transition diagrams, instruction decode tables, circuit and logic diagrams
- US Patent 3987418for MOS microprocessor topography (filed 1974, granted '76) contains floorplan, low resolution layout mask images, block diagram

# Visual6502wiki/Other Chip Image Sites

Source: https://www.nesdev.org/wiki/Visual6502wiki/Other_Chip_Image_Sites

We're aware of several other similar efforts to reverse engineer historic chips
- A team has analysedthe Commodore SID
- Chris Smith has captured the netlistof (and written a book on) the Sinclair Spectrum ULA
- MAME Guru is working on various locked ROMsfrom arcade games
- John McMaster has several large images under http://siliconpr0n.org/archive/doku.phpincluding slippy maps of several, under http://siliconpr0n.org/map/Includes several TI calculator chips. See also his list of other chip images.
- http://zeptobars.ru/en/publish large images periodically, including PIC and soviet clones of Z80 and 8080.

# Visual6502wiki/Photos of MOS 6502D

Source: https://www.nesdev.org/wiki/Visual6502wiki/Photos_of_MOS_6502D

In the summer of 2009, the Visual6502.org project shot and assembled high resolution photographs of a MOS 6502 revD. The surface of the chip was photographed, then the metal and polysilicon layers were stripped off to reveal the conductive substrate diffusion areas. This substrate was photographed, and the substrate image was aligned to the surface image. These two aligned images were used to create the vector polygons that form the Visual6502 chip simulation.

See our websitefor more.

# Visual6502wiki/Photos of R6502

Source: https://www.nesdev.org/wiki/Visual6502wiki/Photos_of_R6502

Beregnyei Balazs took high resolution photos from which he derived his schematic and descriptive documentation.

Segher Boessenkool annotated these photos with signal names and some tracing of poly and active layers.
- 19Mbyte png fileFull die, distorted aspect ratio

# Visual6502wiki/RCA 1802E

Source: https://www.nesdev.org/wiki/Visual6502wiki/RCA_1802E

The RCA 1802 was a pioneering CMOS microprocessor.

See our main site for some more information and images.

Not only was the C2L CMOS process simpler, denser and faster than previous ones, it lends itself to radiation-hard chips, which led to this CPU being found in various space probes. (The bulk silicon process used for our RCA 1802 is not as radiation tolerant as the later silicon-on-sapphire processes, but it was better than other contemporary processes.)

As it happens, it's also a great process for us to photograph and analyse, because the N and P structures show as different colours, and the layout is very readable. For the same reason, with this chip reverse-engineering the die photo may be feasible without needing to strip the metal.

### Control Logic

File:Rca1802-control-reversed-small.gif

This schematic was derived by tracing the excellent die photo, so the arrangement of the gates pretty much follows the layout on die. There are an extensive use of transparent latches of various enable and output polarities, which are denoted with squares.

The design is much more asynchronous than the 6502 or any of the later CPUs; the clock input at the far left goes through the wait/pause/reset logic, and basically only 2 blocks get clocked at the input rate, which is the signal coming out of U77: the sequencer, and the ALU.

The sequencer is a Johnson counter that uses latches, generating 8 phase-shifted signals I've named seq0 through seq7. It's located southeast of /tpa. Interestingly there's a patent (6020770) by Motorola several decades later on using transparent latches in a Johnson counter. Anyway, seq0-7 feed the logic to the right, which produces signals active for various periods of the sequence - I've denoted these CL0-F. As it's a latch-based design both rising and falling edges of the clock are used.

The ALU in the bottom left is serial and multiplexer-based. 3 latches above it pick off the lower 3 bits of the internal data bus to select the function. U123 is the main output (goes to D_SHIFT_IN of the datapath), and U63 is the carry out which goes to the carry flag latch U177.

North of the ALU, above the internal databus and below the clock/reset logic, is instruction decoding, fed from the 2-to-16 decoder to its left. Each line of 16 opcodes is decoded separately.

On the east, below the seq0-7 logic, is the main state machine with 4 latches for EXECUTE, INTERRUPT, FETCH, and DMA. Below that are latches for Q and the interrupt enable, as well as more datapath control logic. Finally, the top left corner contains the interrupt/DMA input circuitry.

[text contributed by AmyK]

See #Resourcesfor more.

### Datapath

File:1802 dpth-small.png

Note that the register bits are just represented as transparent latches, in reality they are two inverters and NMOS transmission gates. But otherwise everything else should be a mostly accurate representation of the circuit.

#### 1. /ARO, /ALO

Located above the register file are a set of latches that drive the address pad outputs. Since the processor can output either the upper or lower 8 bits of any register, these latches have two inputs and two enable signals; ALO and ARO, when asserted, respectively allow the left or right 8 bits of the selected register to be output, and latch the value when deasserted. Taking the leftmost (A7) address latch as an example, we see the storage loop formed by U1, U22, U23, and U20, with the left and right bits entering via U3 and U28 respectively and their gates U2 and U24. When both control signals are deasserted, the loop is closed to latch the last input value, but either of them can be asserted to break the loop and allow either bit's value to enter.

(Note that in the control logic schematic these are labelled /AHO and /ALO; the inconsistency is because which half of the register file held which bits was not yet known before deciphering the control logic.)

#### 2. REGWL, REGWR

When asserted, these signals cause the respective bit line to be driven via the inverted data-in signal coming from the logic below, to effect register writes. This is shown in the schematic for the leftmost bit as the controlled buffers U4 and U62, and the data-in signal via U64. The storage element of the register file is the standard inverter loop with NMOS pass transistors, and writing is usually accomplished by forcing the bit to the right value, as the bit lines have a stronger drive than the storage inverters. The datapath analysis at http://home.earthlink.net/~schultdw/1802/datapath/index.htmlsuggests that the large rectangular series PMOS transistors in the middle disconnect power to the PMOS inverters in the storage loop during a write, although this would mean the 1802 is not truly static since stopping the clock when either of these control signals is high would result in data loss.

#### 3. /REGRL, /REGRR

These signals control the latch between the register output and the increment- decrement unit. With asserted, the respective 8-bit half of the register chosen are output into the incdec, and the output is latched once deasserted. Taking the leftmost element as an example again, the storage loop is formed from U9, U70, U10, and U73, with entrances via U7/U8 and U65/U67. Notice that the write data line goes up through the middle of this latch unit in the IC layout.

#### 4. /EF1234, SELREG0, SELREG2, and REGSEL

Not part of the datapath proper, but these signals run horizontally through it, to the circuitry to its right. /EF1234 is an input of the value on the selected /EF{1,2,3,4} input. SELREG0 resets all the register selection latches, causing register 0 to be selected, while SELREG2 has the same effect as well as setting bit 1 of the register selection bus, causing register 2 to be selected. REGSEL loads the register selection latches from the register address bus (RAB).

#### 5. DEC, COUT, CIN

Output from the register file enters the incdec, which can optionally increment or decrement the data going through it using transmission-gate XOR logic. The CIN signal provides the carry in, COUT carries out, and DEC allows the circuit to decrement. The ripple carry chain is of the common alternating type, used to reduce gate delay and transistor count by interleaving NOR with NAND.

#### 6. REG_DB_EN, REG_OUT_EN

These control two transmission gates between the vertical databus, incdec output and register write input. Their operation can be summed up as follows:

```text
   REG_DB_EN REG_OUT_EN   Description
   0         0            Registers disconnected; inactive
   0         1            incdec output can be written to a register
   1         0            Databus can be written to a register
   1         1            A register can be output to databus and also written back

```

#### 7. NOUTEN

This is another signal which is not part of the databus proper but only enables output of N0, N1, and N2 from the lowest 3 bits of the IN databus.

#### 8. /LD_IN, /N_TO_RAB, /IN_RESET, INTDB0~INTDB7

The first loads the I and N registers from the vertical databus. Like all the other registers in the 1802, I and N are implemented using transparent latches, so their values are latched once /LD_IN deasserts. For bit 7 (bit 3 of I), the storage loop consists of U16, U92, and U89. They continuously output on the IN databus, INTDB0~INTDB7. The /IN_RESET signal clears both I and N to 0, while /N_TO_RAB causes N to be output to the internal register selection bus too.

#### 9. /SET_P1X2, /P_RAB_OUT, /X_RAB_OUT, /LD_X, /LD_P, LD_FR_DB, LD_FR_N

Below the IN databus are the X and P registers, with X on the left and P on the right. Each register consists of a resettable or settable latch, depending on bit position; the /SET_P1X2 signal makes use of these differences to set P to 1 and X to 2 when it is asserted. /P_RAB_OUT and /X_RAB_OUT gate these registers onto the register address bus where their values can be latched in the register selection logic using REGSEL (see above) or the other register, via the /LD_X, /LD_P, and LD_FR_N (should actually be LD_FR_RAB) signals. LD_FR_DB allows the loading of X and P from the vertical databus. Note that asserting both LD_FR_DB and LD_FR_N connects the vertical databus to the RAB, although conflicts will occur due to the differing bit widths.

#### 10. /LD_T_FR_PX, LD_T_FR_PX, /T_OUT_EN

Immediately below X and P is the 8-bit-wide T register. T can only be loaded to from X and P, via LD_T_FR_PX and its inverse. It is only output to the vertical databus, accomplished by assertion of /T_OUT_EN.

#### 11. /D_ZERO, D_SHIFT_IN, /D_SHIFT, D_OUT_EN, D_SHIFT_OUT

These signals are related to the D register, one slice (bit 7) comprised of the components U110 through U120 in the schematic. /D_ZERO is an output, indicating when all of the bits of D are zero, accomplished by a chain of NAND gates with one inverted input (the rightmost bit has instead an inverter, U919.) It can be seen that the structure has two storage loops, which for bit 7 comprises U112, U113, and U114 for the first, and U115, U117, and U119 for the second. The two loops are connected such that the first is closed when the second is open, and vice-versa, controlled by the /D_SHIFT signal. This forms a master-slave edge- triggered flip-flop, of which 8 are connected in a shift register arrangement. On each negative edge of /D_SHIFT, one bit is shifted into the register via the D_SHIFT_IN input, and another out via D_SHIFT_OUT. D_OUT_EN outputs D onto the vertical databus with asserted. Notice that this means D cannot be loaded from the databus directly, but each bit must be shifted in via the D_SHIFT_IN input. D is a serial in/out, parallel out right-shifting register.

#### 12. B_SHIFT_OUT, B_OUT_EN, /B_SHIFT, /LD_B

The B register is similar to the D register, but there are two differences: the shift input, instead of having a B_SHIFT_IN signal, is permanently grounded so that only 0 bits can be shifted in, and there is the ability to load it in from the databus in parallel, by asserting /LD_B. B_SHIFT_OUT and B_OUT_EN are same as for D, but /B_SHIFT has to be maintained at a low level in order for /LD_B to load the B register, whose main storage loop is U127, U129, U130, and U131 (the lower transparent latch) for bit 7. The upper latch, consisting of U122, U123, and U124, remains transparent except during a shift. Thus, to clear B, it can be done by applying 8 positive-going pulses to /B_SHIFT; to load B from the vertical databus, assert /LD_B, and deassert it to latch the value in the lower transparent latch. Then its bit 0 appears at B_SHIFT_OUT, and successive pulses on /B_SHIFT will shift bits out to the right and zeroes in from the left.

#### 13. EXT_DB_IN, EXT_DB_OUT

These signals are straightforward to understand: they control the interaction between the vertical databus and the external pads. EXT_DB_IN enables the value of the respective databus bond pad to be driven on the vertical databus via a controlled buffer, while EXT_DB_OUT outputs the signal on the vertical databus.

### Simple logic gates

File:Rca1802-detail-annotated.jpg

Above we see a detail of our high-resolution images, showing several logic gates laid out with their complementary pullup and pulldown trees in their respective areas (Orange on green is NMOS, purple on blue is PMOS.) The power supply to each gate is the substrate (or well) so there are fewer contacts than in the usual technologies.

Middle-right is the simplest gate: an inverter, with a single pull-down and single pull-up. Above it is a 2-input NOR gate and to the left is a 3-input NOR gate. The three concentric transistors of the NOR3 are rarely seen on this chip, perhaps because of the reduced drive and speed of having 3 transistors in series.

### NOR4 layout

If a NOR4 were laid out like the NOR3 above, it would be rather large because of the need for 4 concentric transistors. The largest (outside) transistors would present more load to their drivers, but wouldn't contribute more drive to the NOR4 because that will be limited by the innermost transistor.

So here we see an alternative layout technique, where an isolated region is created in the lower right, containing two of the pullups, the upper one of which is operated inside-out.

File:Rca1802-detail2-nor4.png

### Resources
- The CPUs of Spacecraft Computers in Space
- RCA 1802on wikipedia
- Manuals at decodesystems.comand at bitsavers
- A high speed bulk CMOS CCL microprocessor(abstract only)
- A Radiation-Hardened Bulk si-Gate CMOS Microprocessor Familypaper
- C2L: A new high-speed high-density bulk CMOS technology(abstract only)
- RCA's Sarnoff Center archives
- Milestones That Mattered: CMOS pioneer developed a precursor to the processor2006 EDN retrospective
- COS-MOS Could Put Computer Slice on a Chip1970 EDN article
- conventional CMOS NAND gatein wikipedia.
- RCA COSMAC 1802on The Antique Chip Collector's Page
- Galileo spacecraft computeron wikipedia
- Galileo - True distributed computing in spaceon Computers in Spaceflight: The NASA Experience website
- Emma 02emulator by Marcel van Tongeren, source available for non-commerical use. Some copyright by Michael H Riley and others.
- The 1802 CosmicosSingle board computer by Bob Stuurman of Radio Bulletin (website by Hans Otten)
- David Schultz'sanalysis of the layout and circuits
- Chuck Bigham'ssimulation of the control logic
- Oneof several discussion threads in Yahoo "cosmacelf" group

# Visual6502wiki/The ChipSim Simulator

Source: https://www.nesdev.org/wiki/Visual6502wiki/The_ChipSim_Simulator

The visual6502 project offers an in-browser simulation of the 6502 and 6800 microprocessors. The engine for the simulation, written in JavaScript, is variously called JSSim and ChipSim. This page offers some background on how the simulator works and how it came to be written.

The source code is copyright with an open source license and available on github.

### Algorithm

TBC

### Data Files

To simulate each chip's behaviour, ChipSim needs to know at least the list of transistors and the information as to how they are connected. To be useful it also needs the names of the pins and ideally the names of some internal nets (or nodes.) To display the chip layout and animate it as the logic values change it needs the geometric layout data. All this information is found in three files. Each file populates a single Javascript data structure. transdefs.js defines an array transdefs[], with a typical element `['t1', 1608, 657, 349, [5424, 5629, 548, 922],[1007, 1079, 17, 5, 17477] ] `, defining the name, the gate node, the source and drain nodes, the bounding box, and some geometrical information. See this source filefor more detail. nodenames.js defines an object nodenames{}, with a typical element `nodenames['ab7']=1493 `. This structure allows us to give several names to each node. We define a function `nodeName() `to provide an inverse mapping. segdefs.js defines an array segdefs[], with a typical element `[4,'+',1,4351,8360,4351,8334,4317,8334,4317,8360] `, giving the node number, the pullup status, the layer index and a list of coordinate pairs for a polygon. There is one element for each polygon on the chip, and therefore generally several elements for each node. The pullup status can be '+' or '-' and should be consistent for all of a node's entries - it's an historical anomaly that this information is in segdefs. Not all chip layers or polygons appear in segdefs, but enough layers appear for an appealing and educational display.

(These formats are subject to revision, as we model new chips and find information which is worth capturing and modelling. For the 6800, we added a weak/strong indicator to transdefs, which was needed because this chip uses only enhancement mode transistors and had some circuit configurations we hadn't previously encountered.)

Note that the coordinates found in these files are transformed on the way to the JavaScript canvas, so the coordinates in the source files are not the same as those reported in the user interface or used in the URLs.

### History

TBC

### Resources
- source codeon github
- Intel 4004 anniversary projectincludes Lajos Kintli's simulator

# Visual6502wiki/The reverse engineering process

Source: https://www.nesdev.org/wiki/Visual6502wiki/The_reverse_engineering_process

## Overview

To help explain which state each of our projects is at, here's a description of the steps we follow:
- Get a chip, usually just one of a particular kind but sometimes more
- Depackage the chip
  - Chips with a metal lid or a ceramic sandwich packageare preferable since these have no plastic in contact with the die.
  - Chips packaged in plastic must be treated with very hot, very nasty acids which we do at a local laboratory with proper equipment
- Photograph the exposed surface of the chip through a microscope
  - Many separate photographs must be taken to cover the surface at high enough resolution
- Stitch the photographs into a single large image
  - Alignment data is used to correct individual photographs for optical distortions
- Usually, de-layer the chip to reveal hidden or obscured lower features
- Photograph and stitch each layer image
- Align all layer images to each other
- Create polygon models of each part of the chip based on the aligned images
- Convert the polygon data into a description we can simulate
- Investigate the behaviour of the chip by simulation
- Investigate the layout and logic design
- Write up our results on this wiki

## Microphotography

Based on our own work and advice from several professionals in the field
- A 20x objective is great, while 100x is overkill and difficult to work with
  - 10x is sometimes adequate for chips with 4 um to 6 um feature sizes, but its better to shoot at higher magnification and downsample the result.
- Useful whole-chip images are typically 6000 to 10000 pixels on a side
- Use an X-Y table to ensure no rotation between the successive images
  - A position readout is not needed, and position information from the microscope is not used to stitch images
- Try to get the chip dead level so its entire surface is in the focal plane
  - A tip-tilt stage with micrometer drive is essential for this, unless you are very patient
- Use a manual fixed exposure, zoom, and white balance for all images
  - Microscopes with a variable zoom are not helpful and could waste a lot of your time later on
- Save images in RAW format if possible at the highest quality
- Aim for at least 200 pixels of overlap between adjacent images

## De-layering

Stripping away individual layers of a chip to reveal the parts and features below can be one of the most difficult and even hazardous procedures owing to the chemicals involved and their byproducts.
- Some labs may use repeated mechanical or chemical-mechanical polishing and photography to image successive layers
  - This is more common for modern devices, especially those that have been planarized during manufacture
  - It may be riskier and costlier for the older chips we study which have only a single metal layer and whos surfaces are very irregular
- Plasma etching and various chemicals can be used to remove all the material of a particular layer at once

## Resources

Labs:
- Raw Sciencea lab in the UK who deprocessed and photographed the Spectrum ULA
- 3g forensicsa lab in the UK who deprocessed the Tube ULA
- [1]MEFAS, a failure analysis lab mentioned in this postingby Henry of reactivemicro.com on AtariAge forums

Papers and websites:
- [2]Visual6502's PDFs relating to Greg James' presentation at SIGGRAPH 2010
- Degate, GPL software to recover netlist from layout, especially of cell-based designs
- Reverse-Engineering a Cryptographic RFID TagUsenix paper by Nohl, Evans, Starbug and Plötz
- Reverse-engineering the HP-35website by Peter Monta
- The Decapping Projectwebsite on ROM dumping for MAME
- Silicon Pr0n"A Reverse Engineering Wiki"

Mailing lists, blogs and forum postings:
- Reversing the Tube ULA (destructively)post and thread on the BBC-Micro mailing list. Also found here
- postcontaining Christian Sattler's advice on photography
- The Decapping Project WIP Page: A Blog About Decapping For MAME

See also our Visual6502wiki/Educational Resourcespage

# Visual6502wiki/6502TestPrograms

Source: https://www.nesdev.org/wiki/Visual6502wiki/6502TestPrograms

There are a number of test suites for 6502, each with their own intentions and peculiarities. (Instead of using a dedicated test suite, it can also be useful to run a monitor or BASIC interpreter, although the test coverage isn't very high and the run time is. Favourites are: Apple 1 monitor, Apple 1 integer BASIC, C64 BASIC, BBC OS and BASIC.)

For the most part these test programs aim to test emulators, which are subject to different bugs than CPU implementations, and therefore the effective coverage may not be as good as expected. Such tests are generally self-checking - there is no golden results file of bus activity - and generally assume some specific platform's I/O facilities.

Self-testing (6502 ROMs and programs):
- Klaus Dormann's test suiteincludes decimal mode, is standalone and can be assembled to a single image around 16k.
- Wolfgang Lorenz' C64 suiteexhaustive, excluding decimal mode, uses C64 facilities to chain each program ( stubbing instructions hereby Christer Palm) (testsuite on Tom Seddon's site) (11kbyte total) ( some description) ( another version with sources)
- Ruud Baltissen's 8k test ROM from his VHDL 6502 core(includes source, but only a subset of files found in the previous version)
- NES testromby Kevin Horton (24kbyte) (haven't found source for this, he says he hasn't got clean source to release)
- AllSuiteA.asmfrom the hcm-6502 (verilog) project. ROM available. Load at and reset to 0xf000 and set irq vector to 0xf5a4.
- Decimal mode tests by Bruce ClarkADC/SBC (exhaustive, tests all four affected flags.) Some specific Decimal tests here.
- Test code supplied with Rob Finch's 6502 core(archive.org) (1500 bytes)
- Acid800by Avery Lee for 8-bit Atari emulators includes some 6502 tests. See Altirrapage.
- ASAP testsby Piotr Fusik includes an exhaustive test for ADC, SBC and 0x6B as well as a few tests for other undocumented opcodes
- 64doccontains an exhaustive test for BCD mode, by Marko Mäkelä. The document was originally created by Jouko Valta and/or John West.
- Tim C. Schröder's Neskell project has a collation of test suitesincluding a pair by Blarggwhich might not already be mentioned here.
- The VICE project has a collection of test suites.

Test harnesses:
- py65 testsby Mike Naberezny (python)

References:
- Nesdev forum topic: "req: nestest.asm"
- Emulator testsnesdevwiki page
- 6502.org topic "New 6502 core"For Ruud's announcement
- 6502.org topic "Running test6502.a65 on Py65"
- 6502.org topic "who knows a full test code for 6502?"
- 6502.org topic "Looking for test program"
- 6502.org topic "Op-code testing"
- 6502.org topic "Functional Test for the NMOS 6502 - request for verification"

# Visual6502wiki/6507 Decode ROM

Source: https://www.nesdev.org/wiki/Visual6502wiki/6507_Decode_ROM

The Decode ROM Template:Refis a 130x21 bits ROM in the 6502 that is used to decode the instruction and to control various units of the CPU.

Some basic (maybe partially incorrect) information: http://www.pagetable.com/?p=39

This is a verified correct transcription of the ROM, taken from the Atari 6507 diagram sheets (this ROM differs from the one in the NMOS 6502, as simulated by the visual6502 simulator):

```text
100XX1XX 3 X STY
XXX100XX 1 3 T3INDYA
XXX110XX 1 2 T2ABSY
1100XXXX 3 0 T0CPYINY
100110XX 3 0 T0TYAA
1X0010XX 3 0 T0DEYINY
000000XX 3 5 T5INT
10XXXXXX 2 X LDXSDX
XXX1X1XX X 2 T2ANYX
XXX000XX 1 2 T2XIND
100010XX 2 0 T0TXAA
110010XX 2 0 T0DEX
1110XXXX 3 0 T0CPXINX
100110XX 2 0 T0TXS
100XXXXX 2 X SDX
101XXXXX 2 0 T0TALDTSX
110010XX 2 1 T1DEX
111010XX 3 1 T1INX
101110XX 2 0 T0TSX
1X0010XX 3 1 T1DEYINY
101XX1XX 3 0 T0LDY1
1010XXXX 3 0 T0LDY2TAY
0XX0X0XX 3 2 CCC
001000XX 3 0 T0JSR
0X0010XX 3 0 T0PSHASHP
011000XX 3 4 T4RTS
0X1010XX 3 3 T3PLAPLPA
010000XX 3 5 T5RTI
011XXXXX 2 X RORRORA
001000XX 3 2 T2JSR
01X011XX 3 X JMPA
XXXXXXXX X 2 T2
XXX011XX X 2 T2EXT
01X000XX 3 X RTIRTS
XXX000XX 1 4 T4XIND
XXXXXXXX X 0 T0A
XXXX0XXX X 2 T2NANYABS
010000XX 3 4 T4RTIA
00X000XX 3 4 T4JSRINT
0XX0XXXX 3 3 NAME1:T3_RTI_RTS_JSR_JMP_INT_PULA_PUPL
XXX100XX 1 3 T3INDYB
XXX000XX 1 3 T3XIND
XXX100XX 1 4 T4INDYA
XXX100XX 1 2 T2INDY
XXX11XXX X 3 T3ABSXYA
0X1010XX 3 X PULAPULP
111XXXXX 2 X INC
010XXXXX 1 0 T0EOR
110XXXXX 1 0 T0CMP
11X0XXXX 3 0 NAME2:T0_CPX_CPY_INX_INY
X11XXXXX 1 0 T0ADCSBC
111XXXXX 1 0 T0SBC
001XXXXX 2 X ROLROLA
01X011XX 3 3 T3JMP
000XXXXX 1 0 T0ORA
00XXXXXX 2 X NAME8:ROL_ROLA_ASL_ASLA
100110XX 3 0 T0TYAB
100010XX 2 0 T0TXAB
X11XXXXX 1 1 T1ADCSBCA
0XXXXXXX 1 1 NAME7:T1_AND_EOR_OR_ADC
0XX010XX 2 1 NAME4:T1_ASLA_ROLA_LSRA
011010XX 3 0 T0PULA
XXX11XXX X 4 T4ABSXYA
XXX100XX 1 5 T5INDY
101XXXXX 1 0 T0LDA
XXXXXXXX 1 0 T0G1
001XXXXX 1 0 T0AND
0010X1XX 3 0 T0BITA
0XX010XX 2 0 NAME6:T0_ASLA_ROLA_LSRA
101010XX 2 0 T0TAX
101010XX 3 0 T0TAY
01X010XX 2 0 T0LSRA
01XXXXXX 2 X LSRLSRA
001000XX 3 5 T5JSRA
XXX100XX 3 2 T2BR
000000XX 3 2 T2INT
001000XX 3 3 T3JSR
XXXX01XX X 2 T2ANYZP
XXXX00XX 1 2 T2ANYIND
XXXXXXXX X 4 T4
XXXXXXXX X 3 T3
0X0000XX 3 0 T0RTIINT
01X011XX 3 0 T0JMP
0XX0X0XX 3 2 NAME3:T2_RTI_RTS_JSR_INT_PULA_PUPLP_PSHA_PSHP
011000XX 3 5 T5RTS
XXXX1XXX X 2 T2ANYABS
100XXXXX 1 X STA
010010XX 3 2 T2PSHA
XXX100XX 3 0 T0BR
0XX010XX 3 X PSHPULA
XXX000XX 1 5 T5XIND
XXXX1XXX X 3 T3ANYABS
XXX100XX 1 4 T4INDYB
XXX11XXX X 3 T3ABSXYB
0X0000XX 3 X RTIINT
001000XX 3 X JSR
01X011XX 3 X JMPB
11X00XXX 3 1 T1CPX2CY2
00X010XX 2 1 T1ASLARLA
11X011XX 3 1 T1CPX1CY1
110XXXXX 1 1 T1CMP
X11XXXXX 1 1 T1ADCSBCB
00XXXXXX 2 X NAME5:ROL_ROLA_ASL_ASLA
X1XXXXXX 2 X LSRRADCIC
0010X1XX 3 1 T1BIT
000010XX 3 2 T2PSHP
000000XX 3 4 T4INT
100XXXXX X X STASTYSTX
XXX11XXX X 4 T4ABSXYB
XXXX00XX 1 5 T5ANYIND
XXX001XX X 2 T2ZP
XXX011XX X 3 T3ABS
XXX101XX X 3 T3ZPX
0X0010XX 3 2 T2PSHASHP
01X000XX 3 5 T5RTIRTS
001000XX 3 5 T5JSRB
01X011XX 3 5 T4JMP
010011XX 3 2 T2JMPABS
0X1010XX 3 3 T3PLAPLPB
XXX100XX 3 3 T3BR
0010X1XX 3 0 T0BITB
010000XX 3 4 T4RTIB
001010XX 3 0 T0PULP
0XX010XX 3 X PSHPULB
101110XX 3 X CLV
00X110XX 3 0 T0CLCSEC
01X110XX 3 0 T0CLISEI
11X110XX 3 0 T0CLDSED
0XXXXXXX X X NI7P
X0XXXXXX X X NI6P

```

The format is:

```text
76543210 G T NAME

```
- The first column represents the 8 bits of the IR. 1 means the bit has to be 1 for the line to fire, 0 means the bit has to be 0, X is a don't care. Note that the lower two bits are always XX - the decode ROM doesn't actually check these, but check a cooked version of these bits instead.
- The second column is the "G" input, it must match 1, 2, 3 or it's a don't care. G is derived from the lower two bits of the IR:

```text
G1 = IR0
G2 = IR1
G3 = !IR0 & !IR1

```
- The third column is "T", which is the clock cycle in which the line fires (0..5).

Some observations:

1. There are 15 duplicates in the decode ROM:

```text
$ for i in `sort pla.txt | cut -c -12 | uniq -c | sort -n | grep "^   2" | cut -c 6-17 | sed -e "s/ /./g"`; do grep $i pla.txt; done

```

We assume this has been done because they had no way of routing the output of some line where they wanted, so they put the same line at a different location again.

2. As an example, ADC # is 2 cycles, but there are lines that match T=[2..4]. In practice, these will never fire; they are meant for other instructions that have a similar encoding and do have T>2.

3. About G, and how it explains many illegal opcodes: Orlando and I reverse engineered this by dumping operation lists with decode.rb and filtering which Gs made sense. The funny thing here is that this leads to the table:

```text
00 -> G3
01 -> G1
10 -> G2
11 -> G1/2

```

11 is the don't care case, there are no opcodes XXXXXX11 that are documented. So in order to simplify the G encoding, 11 has both G1 and G2 turned on, so all G=1 and G=2 lines fire. And this explains A LOT of things, like how LDA (0xAD, G=1) and LDX (0xAE, G=2) become LAX (0xAF, G=1 and G=2):

```text
LDA T=0
XXXXXXXX X 0 T0A
101XXXXX 1 0 T0LDA
XXXXXXXX 1 0 T0G1
X0XXXXXX X X NI6P

LDX T=0
10XXXXXX 2 X LDXSDX
101XXXXX 2 0 T0TALDTSX
XXXXXXXX X 0 T0A
X0XXXXXX X X NI6P

LAX T0
10XXXXXX 2 X LDXSDX
101XXXXX 2 0 T0TALDTSX
XXXXXXXX X 0 T0A
101XXXXX 1 0 T0LDA
XXXXXXXX 1 0 T0G1
X0XXXXXX X X NI6P

```

...which is pretty much LDA and LDX joined!

If you look at http://www.oxyron.de/html/opcodes02.html, you can see that columns 3, 7, B and F are illegal; this is the G=1+G=3 case. These columns basically execute all operations of the two preceding columns at the same time. Note that (as far as I checked) the cycle count (number in the table) is always the MAX() of the two opcodes it consists of.

This was known:

http://www.viceteam.org/plain/64doc.txt

Other undocumented instructions usually cause two preceding opcodes being executed.

But now we have more of a clue what's happening there...

Column 2 is KIL, column 3 has mostly *8* cycle instructions, which is weird. There are no regular 8 cycles ones. Not sure this is accurate in the docs. I see a correlation between the KIL and the 8 cycles. My theory is that KIL overflows the cycle counter. Not sure why column 3 doesn't inherit that feature.

The MAX() property and the KIL/Column 3 thing might explain how the cycle counter gets reset to 0... what triggers that. Orlando is also looking into this, comparing neighbor opcodes that terminate differently.

Here is the ruby program that accepts an opcode at the command line and prints the sequence of clocks:

```text
#! /usr/bin/env ruby

if ($*.length < 1)
    print "usage: #{$0} <value>\n"
    exit
end

opc = eval($*[0])
b0 = (opc & 1) != 0
b1 = (opc & 2) != 0
gmatch = Array.new
gmatch[1] = b0
gmatch[2] = b1
gmatch[3] = !b0 && !b1

bin = ("%08b" % opc)

input = Array.new

File.open('pla.txt').each_line do |s|
  next if s =~ /^#.*/ # skip lines starting with '#'
  input += [ s.chop.split(/ /) ]
end

6.times do |time|
  print "T=#{time}\n"
  input.each do |ni, g, t, name|
    print "#{ni} #{g} #{t} #{name}\n" if (bin.match(ni.gsub(/X/, ".")) && (t == "X" || time == t.to_i) && (g == "X" || gmatch[g.to_i]))
  end
  print "\n"
end

```

It also needs to read a file 'pla.txt' which has a tabulation as found here.

## Notes
Template:EndnoteThe "Decode ROM" is named as a ROM in Hanson's block diagram, although it has wordline inputs and no address decoder. It is sometimes described as a PLA although it also lacks an AND plane. It is a structured layout of NOR gates with many common inputs, as compared to the unstructured gates found in the central decode logic, sometimes known as the random logic (meaning not structured).

# Visual6502wiki/Hanson's Block Diagram

Source: https://www.nesdev.org/wiki/Visual6502wiki/Hanson%27s_Block_Diagram

See also this article on pagetable.com

The classic and best 6502 block diagram is taken from Donald F. Hanson's paper "A VHDL Conversion Tool for Logic Equations with Embedded D Latches" ( http://www.ncsu.edu/wcae/WCAE1/hanson.pdf), which was presumably presented at Workshops on Computer Architecture Education at HPCA 1, January 1995

"A block diagram for the 6502 microprocessor is shown in Figure 3. This was drawn to correspond to the blueprint."

Source 1

Source 2

Cleaned up version copyrighted 2011 on the author's website."This is the result of work done in 1982 from the blueprint of the 6502 microprocessor"
