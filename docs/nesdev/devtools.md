# devtools

# Emulator tests

Source: https://www.nesdev.org/wiki/Emulator_Tests

There are many ROMs available that test an emulator for inaccuracies.

## Validation ROMs

### CPU Tests

| Name | Author | Description | Resources |
| branch_timing_tests | blargg | These ROMs test timing of the branch instruction, including edge cases |  |
| cpu_dummy_reads | blargg | Tests the CPU's dummy reads | thread |
| cpu_dummy_writes | bisqwit | Tests the CPU's dummy writes | thread |
| cpu_exec_space | bisqwit | Verifies that the CPU can execute code from any possible memory location, even if that is mapped as I/O space | thread |
| cpu_flag_concurrency | bisqwit | Unsure what results are meant to be, see thread for more info. | thread |
| cpu_interrupts_v2 | blargg | Tests the behavior and timing of CPU in the presence of interrupts, both IRQ and NMI; see CPU interrupts. | thread |
| cpu_reset | blargg | Tests CPU registers just after power and changes during reset, and that RAM isn't changed during reset. |  |
| cpu_timing_test6 | blargg | This program tests instruction timing for all official and unofficial NES 6502 instructions except the 8 branch instructions (Bxx) and the 12 halt instructions (HLT) | thread |
| coredump | jroatch | Coredump tool for displaying contents of RAM | thread |
| instr_misc | blargg | Tests some miscellaneous aspects of instructions, including behavior when 16-bit address wraps around, and dummy reads. |  |
| instr_test_v5 | blargg | Tests official and unofficial CPU instructions and lists which ones failed. It will work even if emulator has no PPU and only supports NROM, writing a copy of output to $6000 (see readme). This more thoroughly tests instructions, but can't help you figure out what's wrong beyond what instruction(s) are failing, so it's better for testing mature CPU emulators. |  |
| instr_timing | blargg | Tests timing of all instructions, including unofficial ones, page-crossing, etc. |  |
| nestest (doc) | kevtris | fairly thoroughly tests CPU operation. This is the best test to start with when getting a CPU emulator working for the first time. Start execution at $C000 and compare execution with a known good log (created using Nintendulator, an emulator chosen by the test's author because its CPU was verified to function correctly, aside from some minor details of the power-up state). |  |
| ram_retain | rainwarrior | RAM contents test, for displaying contents of RAM at power-on or after reset | thread |

### PPU Tests

| Name | Author | Description | Resources |
| color_test | rainwarrior | Simple display of any chosen color full-screen | thread |
| blargg_ppu_tests_2005.09.15b | blargg | Miscellaneous PPU tests (palette ram, sprite ram, etc.) | thread |
| full_nes_palette | blargg | Displays the full palette with all emphasis states, demonstrates direct PPU color control | thread |
| nmi_sync | blargg | Verifies NMI timing by creating a specific pattern on the screen (NTSC & PAL versions) | thread |
| ntsc_torture | rainwarrior | NTSC Torture Test displays visual patterns to demonstrate NTSC signal artifacts | thread |
| oam_read | blargg | Tests OAM reading ($2004), being sure it reads the byte from OAM at the current address in $2003. | thread |
| oam_stress | blargg | Thoroughly tests OAM address ($2003) and read/write ($2004) | thread |
| oamtest3 | lidnariq | Utility to upload OAM data via $2003/$2004 - can be used to test for the OAMADDR bug behavior | thread 1 thread 2 |
| palette | rainwarrior | Palette display requiring only scanline-based palette changes, intended to demonstrate the full palette even on less advanced emulators | thread |
| ppu_open_bus | blargg | Tests behavior when reading from open-bus PPU bits/registers |  |
| ppu_read_buffer | bisqwit | Mammoth test pack tests many aspects of the NES system, mostly centering around the PPU $2007 read buffer | thread |
| ppu_sprite_hit | blargg | Tests sprite 0 hit behavior and timing | thread |
| sprite_overflow_tests | blargg | Tests sprite overflow behavior and timing | thread |
| ppu_vbl_nmi | blargg | Tests the behavior and timing of the NTSC PPU's VBL flag, NMI enable, and NMI interrupt. Timing is tested to an accuracy of one PPU clock. | thread |
| scanline | Quietust | Displays a test screen that will contain glitches if certain portions of the emulation are not perfect. |  |
| sprdma_and_dmc_dma | blargg | Tests the cycle stealing behavior of the DMC DMA while running Sprite DMAs | thread |
| sprite_hit_tests_2005.10.05 | blargg | Generally the same as ppu_sprite_hit (older revision of the tests - ppu_sprite_hit is most likely better) | thread |
| sprite_overflow_tests | blargg | Generally the same as ppu_sprite_overflow (older revision of the tests - ppu_sprite_overflow is most likely better) | thread |
| tvpassfail | tepples | NTSC color and NTSC/PAL pixel aspect ratio test ROM (older revision of the tests - 240p Test Suite is most likely better) | thread |
| vbl_nmi_timing | blargg | Generally the same as ppu_vbl_nmi (older revision of the tests - ppu_vbl_nmi is most likely better) | thread |

### APU Tests

| Name | Author | Description | Resources |
| apu_mixer | blargg | Verifies proper operation of the APU's sound channel mixer, including relative volumes of channels and non-linear mixing. recordings when run on NES are available for comparison, though the tests are made so that you don't really need these. | thread |
| apu_phase_reset | Rahsennor | Tests the correct square channel behavior when writing to $4003/4007 (reset the duty cycle sequencers but not the clock dividers) | thread |
| apu_reset | blargg | Tests initial APU state at power, and the effect of reset. |  |
| apu_test | blargg | Tests many aspects of the APU that are visible to the CPU. Really obscure things are not tested here. |  |
| blargg_apu_2005.07.30 | blargg | Tests APU length counters, frame counter, IRQ, etc. |  |
| dmc_dma_during_read4 | blargg | Tests register read/write behavior while DMA is running |  |
| dmc_tests | ? | ? |  |
| dpcmletterbox | tepples | Tests accuracy of the DMC channel's IRQ |  |
| pal_apu_tests | blargg | PAL version of the blargg_apu_2005.07.30 tests |  |
| square_timer_div2 | blargg | Tests the square timer's period |  |
| test_apu_2 (1-10) (11) | x0000 | 11 tests that verify a number of behaviors with the APU (including the frame counter) | thread |
| test_apu_env | blargg | Tests the APU envelope for correctness. |  |
| test_apu_sweep | blargg | Tests the sweep unit's add, subtract, overflow cutoff, and minimum period behaviors. |  |
| test_apu_timers | blargg | Tests frequency timer of all 5 channels |  |
| test_tri_lin_ctr | blargg | Tests triangle's linear counter and clocking by the frame counter |  |
| volume_tests | tepples | Plays tones on all the APU's channels to show their relative volumes at various settings of $4011. Package includes a recording from an NES's audio output for comparison. |  |

### Mapper-specific Tests

| Name | Author | Description | Resources |
| 31_test | rainwarrior | Tests for mapper 31 (see thread for ROMs in various PRG sizes) | thread |
| BNTest | tepples | Tests how many PRG banks are reachable in BxROM and AxROM. | thread GitHub |
| bxrom_512k_test | rainwarrior | Similar to the BxROM test in BNTest above. | thread |
| FdsIrqTests (v7) | Sour | Tests various elements of the FDS' IRQ | thread |
| FDS-Mirroring-Test | TakuikaNinja | Tests the FDS' nametable arrangement/mirroring switching functionality ($4025.D3 write, $4030.D3 read, $4023.D0=0 write) | thread GitHub |
| FDS-4023-Test | TakuikaNinja | Displays the state of FDS registers when toggling $4023 bits | thread GitHub |
| FDS-4030D1-Addr | TakuikaNinja | Visualises IRQs generated by the FDS' DRAM refresh watchdog, reported in $4030.D1 | thread GitHub |
| exram | Quietust | MMC5 exram test |  |
| famicom_audio_swap_tests | rainwarrior | Hotswap tests for Famicom expansion audio (5B, MMC5, VRC6, VRC7, N163, FDS) | thread |
| fme7acktest-r1 | tepples | Checks some IRQ acknowledgment behiaviors of Sunsoft FME-7 that emulators were getting wrong in 2015. | thread |
| fme7ramtest-r1 | tepples | Checks how much work RAM the Sunsoft FME-7 can access | thread GitHub |
| Holy Mapperel | tepples | Detects over a dozen mappers and verifies that all PRG ROM and CHR ROM banks are reachable, that PRG RAM and CHR RAM can be written and read back without error, and that nametable mirroring, IRQ, and WRAM protection work. (Formerly Holy Diver Batman) | thread GitHub |
| mmc3bigchrram | tepples | MMC3 test for large 32kb CHR RAM with NES 2.0 headers | thread GitHub |
| mmc3_test_2 | blargg | MMC3 scanline counter and IRQ generation tests. |  |
| mmc3irqtest | N-K | MMC3 scanline IRQ test and $C000 glitch investigation. | thread |
| mmc5test | Drag | MMC5 scanline counter | thread |
| mmc5test_v2 | AWJ | MMC5 tests | thread |
| serom | lidnariq | Tests the constraints of SEROM / SHROM / SH1ROM variations of the MMC1 boards. | thread |
| NES 2.0 Submapper Tests | rainwarrior | 2_test - Mapper 2, Submappers 0, 1 and 2 | thread |
| rainwarrior | 3_test - Mapper 3, Submappers 0, 1 and 2 | thread |
| rainwarrior | 7_test - Mapper 7, Submappers 0, 1 and 2 | thread |
| rainwarrior | 34_test - Mapper 34, Submappers 1 and 2 | thread |
| test28 | tepples | Tests for mapper 28 | thread GitHub |
| vrc24test | AWJ | Detects and tests all VRC 2/4 variants | thread |
| vrc6test | natt | VRC6 mirroring tests | thread |
| mmc5ramsize | rainwarrior | MMC5 large PRG-RAM support tests | thread |
| mmc1atest | tepples | Characterizes behavior of MMC1A vs. MMC1B | thread GitHub |
| n163_soundram | rainwarrior | Test for Namco 163 audio sound RAM read-back. | thread |
| n163_soundram_init | rainwarrior | Test for Namco 163 audio sound RAM contents at power-on. | thread |

### Input Tests

| Name | Author | Description | Resources |
| allpads | tepples | Multiple controller test supporting NES controller, Super NES controller, Famicom microphone, Four Score, Zapper, NES Arkanoid controller, and Super NES Mouse; also has raw 32-bit report mode | thread GitHub |
| dma_sync_test_v2 | Rahsennor | Tests DMC DMA read corruption | thread |
| PaddleTest3 | 3gengames | Test for the Arkanoid controller | thread |
| vaus | lidnariq | Arkanoid controller 9-bit result test | thread |
| read_joy3 | blargg | Various NES controllers tests, including read corruption due to DMC DMA | thread |
| Zap Ruder | tepples | Test for the Zapper, including dual wield but not the serial Vs. variant | thread GitHub |
| spadtest-nes | tepples | Super Nintendo controller test (when connected to a NES) | thread |
| vaus_test | tepples | Another test for the Arkanoid controller | thread GitHub |
| mset | rainwarrior | SNES mouse test | thread |
| mict | rainwarrior | Famicom microphone test | thread |
| Telling LYs? | tepples | Tests whether input can change on any scanline | thread GitHub |
| ctrltest | rainwarrior | Generic log of 16-bit report on all 5 input data lines. | thread |

| raw pack2 | lidnariq | Immediate state of 32-bit report on all 5x2 input data lines. Immediate state of 64-bit report on all 5x2 input data lines. | thread |
| zapper tests | rainwarrior | Simple tests for displaying output of zapper reads. | thread |
| powerpadgesture | tepples | Gesture test for Power Pad displaying log of presses and releases. | thread |
| POWERPAD.NES | Tennessee Carmel-Veilleux | Old simple test for Power Pad. | powerpad.txt |
| d34test | rainwarrior | Generic log of 32-bit report on D3 and D4 data lines, with 16-bit report on D0. | thread |
| kmbtest | rainwarrior | Input test for a proposed USB Keyboard and Mouse interface. | thread |

### Misc Tests

| Name | Author | Description | Resources |
| 240pee-0.22 | tepples | 240p Test Suite (an NES version of the 240p Test Suite by Artemio Urbina), including an MDFourier tone generator | thread GitHub |
| characterize-vs | lidnariq | VS System tests | thread |
| NEStress | Flubba | Old test - some of the tests are supposed to fail on real hardware. |  |
| oc-r1a | tepples | Detects and displays accurate clock rate of the NES (since incorporated into 240p Test Suite) | thread |
| nes-audio-tests | rainwarrior | NSF and NES ROM tests for expansion audio sound, NSF behaviour, and other various audio related things. |  |

## Automated testing

It's best if your emulator can automatically run a suite of tests at the press of a button. This allows you to re-run them every time you make a change, without any effort. Automation can be difficult, because the emulator must be able to determine success/failure without your help.

The first part of automated testing is support for a "movie" or "demo", or a list of what buttons were pressed when. An emulator makes a movie by recording presses while the user is playing, and then it plays the movie by feeding the recorded presses back through the input system. This not only helps automated testing but also makes your emulator attractive to speedrunners.

To create a test case, record a movie of the player activating all tests in a ROM, take a screenshot of each result screen, and log the time and a hashof each screenshot. The simplest test ROMs won't require any button presses. ROMs that test more than one thing are more likely to require them, and an actual gamewill require a playthrough. Then to run a test case, play the movie in fast-forward (no delay between frames) and take screenshots at the same times. If a screenshot's hash differs from that of the corresponding screenshot from when the test case was created, make a note of this difference in the log. Then you can compare the emulator's output frame-by-frame to that of the previous release of your emulator running the same test case.

## See also
- Emulators

# Emulator tests

Source: https://www.nesdev.org/wiki/Emulator_tests

There are many ROMs available that test an emulator for inaccuracies.

## Validation ROMs

### CPU Tests

| Name | Author | Description | Resources |
| branch_timing_tests | blargg | These ROMs test timing of the branch instruction, including edge cases |  |
| cpu_dummy_reads | blargg | Tests the CPU's dummy reads | thread |
| cpu_dummy_writes | bisqwit | Tests the CPU's dummy writes | thread |
| cpu_exec_space | bisqwit | Verifies that the CPU can execute code from any possible memory location, even if that is mapped as I/O space | thread |
| cpu_flag_concurrency | bisqwit | Unsure what results are meant to be, see thread for more info. | thread |
| cpu_interrupts_v2 | blargg | Tests the behavior and timing of CPU in the presence of interrupts, both IRQ and NMI; see CPU interrupts. | thread |
| cpu_reset | blargg | Tests CPU registers just after power and changes during reset, and that RAM isn't changed during reset. |  |
| cpu_timing_test6 | blargg | This program tests instruction timing for all official and unofficial NES 6502 instructions except the 8 branch instructions (Bxx) and the 12 halt instructions (HLT) | thread |
| coredump | jroatch | Coredump tool for displaying contents of RAM | thread |
| instr_misc | blargg | Tests some miscellaneous aspects of instructions, including behavior when 16-bit address wraps around, and dummy reads. |  |
| instr_test_v5 | blargg | Tests official and unofficial CPU instructions and lists which ones failed. It will work even if emulator has no PPU and only supports NROM, writing a copy of output to $6000 (see readme). This more thoroughly tests instructions, but can't help you figure out what's wrong beyond what instruction(s) are failing, so it's better for testing mature CPU emulators. |  |
| instr_timing | blargg | Tests timing of all instructions, including unofficial ones, page-crossing, etc. |  |
| nestest (doc) | kevtris | fairly thoroughly tests CPU operation. This is the best test to start with when getting a CPU emulator working for the first time. Start execution at $C000 and compare execution with a known good log (created using Nintendulator, an emulator chosen by the test's author because its CPU was verified to function correctly, aside from some minor details of the power-up state). |  |
| ram_retain | rainwarrior | RAM contents test, for displaying contents of RAM at power-on or after reset | thread |

### PPU Tests

| Name | Author | Description | Resources |
| color_test | rainwarrior | Simple display of any chosen color full-screen | thread |
| blargg_ppu_tests_2005.09.15b | blargg | Miscellaneous PPU tests (palette ram, sprite ram, etc.) | thread |
| full_nes_palette | blargg | Displays the full palette with all emphasis states, demonstrates direct PPU color control | thread |
| nmi_sync | blargg | Verifies NMI timing by creating a specific pattern on the screen (NTSC & PAL versions) | thread |
| ntsc_torture | rainwarrior | NTSC Torture Test displays visual patterns to demonstrate NTSC signal artifacts | thread |
| oam_read | blargg | Tests OAM reading ($2004), being sure it reads the byte from OAM at the current address in $2003. | thread |
| oam_stress | blargg | Thoroughly tests OAM address ($2003) and read/write ($2004) | thread |
| oamtest3 | lidnariq | Utility to upload OAM data via $2003/$2004 - can be used to test for the OAMADDR bug behavior | thread 1 thread 2 |
| palette | rainwarrior | Palette display requiring only scanline-based palette changes, intended to demonstrate the full palette even on less advanced emulators | thread |
| ppu_open_bus | blargg | Tests behavior when reading from open-bus PPU bits/registers |  |
| ppu_read_buffer | bisqwit | Mammoth test pack tests many aspects of the NES system, mostly centering around the PPU $2007 read buffer | thread |
| ppu_sprite_hit | blargg | Tests sprite 0 hit behavior and timing | thread |
| sprite_overflow_tests | blargg | Tests sprite overflow behavior and timing | thread |
| ppu_vbl_nmi | blargg | Tests the behavior and timing of the NTSC PPU's VBL flag, NMI enable, and NMI interrupt. Timing is tested to an accuracy of one PPU clock. | thread |
| scanline | Quietust | Displays a test screen that will contain glitches if certain portions of the emulation are not perfect. |  |
| sprdma_and_dmc_dma | blargg | Tests the cycle stealing behavior of the DMC DMA while running Sprite DMAs | thread |
| sprite_hit_tests_2005.10.05 | blargg | Generally the same as ppu_sprite_hit (older revision of the tests - ppu_sprite_hit is most likely better) | thread |
| sprite_overflow_tests | blargg | Generally the same as ppu_sprite_overflow (older revision of the tests - ppu_sprite_overflow is most likely better) | thread |
| tvpassfail | tepples | NTSC color and NTSC/PAL pixel aspect ratio test ROM (older revision of the tests - 240p Test Suite is most likely better) | thread |
| vbl_nmi_timing | blargg | Generally the same as ppu_vbl_nmi (older revision of the tests - ppu_vbl_nmi is most likely better) | thread |

### APU Tests

| Name | Author | Description | Resources |
| apu_mixer | blargg | Verifies proper operation of the APU's sound channel mixer, including relative volumes of channels and non-linear mixing. recordings when run on NES are available for comparison, though the tests are made so that you don't really need these. | thread |
| apu_phase_reset | Rahsennor | Tests the correct square channel behavior when writing to $4003/4007 (reset the duty cycle sequencers but not the clock dividers) | thread |
| apu_reset | blargg | Tests initial APU state at power, and the effect of reset. |  |
| apu_test | blargg | Tests many aspects of the APU that are visible to the CPU. Really obscure things are not tested here. |  |
| blargg_apu_2005.07.30 | blargg | Tests APU length counters, frame counter, IRQ, etc. |  |
| dmc_dma_during_read4 | blargg | Tests register read/write behavior while DMA is running |  |
| dmc_tests | ? | ? |  |
| dpcmletterbox | tepples | Tests accuracy of the DMC channel's IRQ |  |
| pal_apu_tests | blargg | PAL version of the blargg_apu_2005.07.30 tests |  |
| square_timer_div2 | blargg | Tests the square timer's period |  |
| test_apu_2 (1-10) (11) | x0000 | 11 tests that verify a number of behaviors with the APU (including the frame counter) | thread |
| test_apu_env | blargg | Tests the APU envelope for correctness. |  |
| test_apu_sweep | blargg | Tests the sweep unit's add, subtract, overflow cutoff, and minimum period behaviors. |  |
| test_apu_timers | blargg | Tests frequency timer of all 5 channels |  |
| test_tri_lin_ctr | blargg | Tests triangle's linear counter and clocking by the frame counter |  |
| volume_tests | tepples | Plays tones on all the APU's channels to show their relative volumes at various settings of $4011. Package includes a recording from an NES's audio output for comparison. |  |

### Mapper-specific Tests

| Name | Author | Description | Resources |
| 31_test | rainwarrior | Tests for mapper 31 (see thread for ROMs in various PRG sizes) | thread |
| BNTest | tepples | Tests how many PRG banks are reachable in BxROM and AxROM. | thread GitHub |
| bxrom_512k_test | rainwarrior | Similar to the BxROM test in BNTest above. | thread |
| FdsIrqTests (v7) | Sour | Tests various elements of the FDS' IRQ | thread |
| FDS-Mirroring-Test | TakuikaNinja | Tests the FDS' nametable arrangement/mirroring switching functionality ($4025.D3 write, $4030.D3 read, $4023.D0=0 write) | thread GitHub |
| FDS-4023-Test | TakuikaNinja | Displays the state of FDS registers when toggling $4023 bits | thread GitHub |
| FDS-4030D1-Addr | TakuikaNinja | Visualises IRQs generated by the FDS' DRAM refresh watchdog, reported in $4030.D1 | thread GitHub |
| exram | Quietust | MMC5 exram test |  |
| famicom_audio_swap_tests | rainwarrior | Hotswap tests for Famicom expansion audio (5B, MMC5, VRC6, VRC7, N163, FDS) | thread |
| fme7acktest-r1 | tepples | Checks some IRQ acknowledgment behiaviors of Sunsoft FME-7 that emulators were getting wrong in 2015. | thread |
| fme7ramtest-r1 | tepples | Checks how much work RAM the Sunsoft FME-7 can access | thread GitHub |
| Holy Mapperel | tepples | Detects over a dozen mappers and verifies that all PRG ROM and CHR ROM banks are reachable, that PRG RAM and CHR RAM can be written and read back without error, and that nametable mirroring, IRQ, and WRAM protection work. (Formerly Holy Diver Batman) | thread GitHub |
| mmc3bigchrram | tepples | MMC3 test for large 32kb CHR RAM with NES 2.0 headers | thread GitHub |
| mmc3_test_2 | blargg | MMC3 scanline counter and IRQ generation tests. |  |
| mmc3irqtest | N-K | MMC3 scanline IRQ test and $C000 glitch investigation. | thread |
| mmc5test | Drag | MMC5 scanline counter | thread |
| mmc5test_v2 | AWJ | MMC5 tests | thread |
| serom | lidnariq | Tests the constraints of SEROM / SHROM / SH1ROM variations of the MMC1 boards. | thread |
| NES 2.0 Submapper Tests | rainwarrior | 2_test - Mapper 2, Submappers 0, 1 and 2 | thread |
| rainwarrior | 3_test - Mapper 3, Submappers 0, 1 and 2 | thread |
| rainwarrior | 7_test - Mapper 7, Submappers 0, 1 and 2 | thread |
| rainwarrior | 34_test - Mapper 34, Submappers 1 and 2 | thread |
| test28 | tepples | Tests for mapper 28 | thread GitHub |
| vrc24test | AWJ | Detects and tests all VRC 2/4 variants | thread |
| vrc6test | natt | VRC6 mirroring tests | thread |
| mmc5ramsize | rainwarrior | MMC5 large PRG-RAM support tests | thread |
| mmc1atest | tepples | Characterizes behavior of MMC1A vs. MMC1B | thread GitHub |
| n163_soundram | rainwarrior | Test for Namco 163 audio sound RAM read-back. | thread |
| n163_soundram_init | rainwarrior | Test for Namco 163 audio sound RAM contents at power-on. | thread |

### Input Tests

| Name | Author | Description | Resources |
| allpads | tepples | Multiple controller test supporting NES controller, Super NES controller, Famicom microphone, Four Score, Zapper, NES Arkanoid controller, and Super NES Mouse; also has raw 32-bit report mode | thread GitHub |
| dma_sync_test_v2 | Rahsennor | Tests DMC DMA read corruption | thread |
| PaddleTest3 | 3gengames | Test for the Arkanoid controller | thread |
| vaus | lidnariq | Arkanoid controller 9-bit result test | thread |
| read_joy3 | blargg | Various NES controllers tests, including read corruption due to DMC DMA | thread |
| Zap Ruder | tepples | Test for the Zapper, including dual wield but not the serial Vs. variant | thread GitHub |
| spadtest-nes | tepples | Super Nintendo controller test (when connected to a NES) | thread |
| vaus_test | tepples | Another test for the Arkanoid controller | thread GitHub |
| mset | rainwarrior | SNES mouse test | thread |
| mict | rainwarrior | Famicom microphone test | thread |
| Telling LYs? | tepples | Tests whether input can change on any scanline | thread GitHub |
| ctrltest | rainwarrior | Generic log of 16-bit report on all 5 input data lines. | thread |

| raw pack2 | lidnariq | Immediate state of 32-bit report on all 5x2 input data lines. Immediate state of 64-bit report on all 5x2 input data lines. | thread |
| zapper tests | rainwarrior | Simple tests for displaying output of zapper reads. | thread |
| powerpadgesture | tepples | Gesture test for Power Pad displaying log of presses and releases. | thread |
| POWERPAD.NES | Tennessee Carmel-Veilleux | Old simple test for Power Pad. | powerpad.txt |
| d34test | rainwarrior | Generic log of 32-bit report on D3 and D4 data lines, with 16-bit report on D0. | thread |
| kmbtest | rainwarrior | Input test for a proposed USB Keyboard and Mouse interface. | thread |

### Misc Tests

| Name | Author | Description | Resources |
| 240pee-0.22 | tepples | 240p Test Suite (an NES version of the 240p Test Suite by Artemio Urbina), including an MDFourier tone generator | thread GitHub |
| characterize-vs | lidnariq | VS System tests | thread |
| NEStress | Flubba | Old test - some of the tests are supposed to fail on real hardware. |  |
| oc-r1a | tepples | Detects and displays accurate clock rate of the NES (since incorporated into 240p Test Suite) | thread |
| nes-audio-tests | rainwarrior | NSF and NES ROM tests for expansion audio sound, NSF behaviour, and other various audio related things. |  |

## Automated testing

It's best if your emulator can automatically run a suite of tests at the press of a button. This allows you to re-run them every time you make a change, without any effort. Automation can be difficult, because the emulator must be able to determine success/failure without your help.

The first part of automated testing is support for a "movie" or "demo", or a list of what buttons were pressed when. An emulator makes a movie by recording presses while the user is playing, and then it plays the movie by feeding the recorded presses back through the input system. This not only helps automated testing but also makes your emulator attractive to speedrunners.

To create a test case, record a movie of the player activating all tests in a ROM, take a screenshot of each result screen, and log the time and a hashof each screenshot. The simplest test ROMs won't require any button presses. ROMs that test more than one thing are more likely to require them, and an actual gamewill require a playthrough. Then to run a test case, play the movie in fast-forward (no delay between frames) and take screenshots at the same times. If a screenshot's hash differs from that of the corresponding screenshot from when the test case was created, make a note of this difference in the log. Then you can compare the emulator's output frame-by-frame to that of the previous release of your emulator running the same test case.

## See also
- Emulators

# Emulators

Source: https://www.nesdev.org/wiki/Emulators

This is a list of NES emulators .

## Commercial

| Emulator name | Author | Platform(s) | Ports and/or other details |
| acNES | Nintendo | Nintendo 64, GameCube | Used in the first generation Animal Crossing games. The commonly used "acNES" name is unofficial, as Nintendo has not released this emulator as a distinct product. A decompilation of Animal Crossing uses "ksNes". Information from TCRF indicates that it may be called "QFC" internally. |
| Classic NES Series | Nintendo | Game Boy Advance | Used for the Classic NES Series. |
| Virtual Console | Nintendo | Wii, Wii U, 3DS | Most games were priced at 500 Nintendo Points on the Wii Shop Channel, or similar prices on the Wii U/3DS eShop. The 3DS version uses the TNES file format. |
| PocketNES | loopy, FluBBa, and Dwedit | Game Boy Advance, Nintendo DS | Used commercially for some emulated re-releases by Atlus, Jaleco, and Konami. |
| Heritage | Nintendo | Wii U, 3DS | Used for the NES/Famicom Remix series. |
| Kachikachi | Nintendo | Linux | Used for the NES Classic Edition/Famicom Classic Mini (+ Shōnen Jump version). Pre-installed game selection differs between versions. |
| Nintendo Entertainment System/Family Computer - Nintendo Switch Online | Nintendo | Nintendo Switch | Available for users with a Nintendo Switch Online Membership. Pre-installed game selection differs between regions. |

## Popular

These are commonly used or well-established.

| Emulator name | Author | Platform(s) | Ports and/or other details |
| BizHawk | Multiple authors | Win32, Linux |
| FCE Ultra GX | Tantric | Wii, GameCube |
| FCEUX | Anthony Giorgio / Mark Doliner | Win32, macOS, Linux |
| higan | Near (formerly as byuu) | Win32, FreeBSD, Linux, macOS |
| iNES | Marat Fayzullin | Win32 and Linux |
| Jnes | Jabosoft | Win32 |
| Mesen | Sour | Win32, Linux/.NET | Announcement / Source, excellent debugger |
| nemulator | James Slepicka | Win32 | Source |
| nesemu2 | holodnak | Win32, OS X, Linux |

| Nestopia UE | rdanbrook | Linux, BSD, Win7+ | a.k.a. Nestopia Undead Edition. Contains bugfixes/etc.Windows binaries are available at Sourceforge or at EmuCR |
| Nintaco | zeroone | Java (Windows, GNU/Linux, macOS) | Announcement Source API FAQ Screenshots |
| Nintendulator | Quietust | Win32 | Nintendulator DX (by thefox) for an even more-improved debugger |
| NO$NES | Martin Korth | Win32 |
| PocketNES | loopy, FluBBa, and Dwedit | Game Boy Advance | Updates on Dwedit's board |
| RockNES | Zepper (formerly Fx3) | Win32 |

## Under development

The following is a list of NES emulators that are under development, who their authors are, relevant home pages/sites, and the source of the announcement (direct or indirect). Only projects are listed that had a release in form of source or binary.

| Emulator name | Author | Technology(s) / Platform(s) | Ports and/or other details |
| NESICIDE | cpow | Qt, C++ / Win32 / Win64, Linux32, Linux64, macOS | Source |
| kindred | Overload | Win32 | Announcement |
| A/NES | Morgan Johansson | AmigaOS | Announcement |
| puNES | FHorse | Qt, C++ / Linux, FreeBSD, OpenBSD, Win32 | Announcement |
| jaNES | crudelios | C++ / Win32 | Announcement |
| HDNes | mkwong98 | C++ / Win32 | Announcement |
| Fergulator | fergus_maximus | Golang, SDL / Linux, Windows, macOS | Announcement |
| Pretendo | proxy | C++ / Linux/BeOS/Win32 | Announcement |
| NES-Emulator | Dartht33bagger | C, SDL | Announcement |
| nintengo | nwidger | Golang, SDL / Linux, Windows, macOS |  |
| ffnes | rockcarry | C / Win32 | Announcement |
| WebNES | peteward44 | Javascript | Announcement / Live demo |
| O-Nes-Sama | Fumarumota, aLaix | C++, SDL2 / Win32, Linux) | Announcement |
| cfxnes | jonyzz | Javascript | Announcement / Live demo |
| nes-emu | daroou | C++, SDL2 / Win32, Linux | Announcement |
| fogleman/nes | Michael Fogleman | Golang, OpenGL, PortAudio / Linux, Windows, macOS | Medium article |
| NES-Emu | imid | C#, .NET | Announcement |
| nSide | hex_usr | C++ | Fork of byuu's higan-nes. Announcement |
| HalfNES | Grapeshot | Java |  |
| fpgaNES | Feuerwerk42 | VHDL, Verilog / FPGA (hardware) | Announcement |
| Nintendoish | drewying | Swift / Win32, macOS | Announcement |
| triforce | tdondich | JavaScript, VueJS | Announcement |
| Project-Nested | Myself086 | Assembly / SNES | Announcement |
| nescore | rodri042 | JavaScript | Announcement |
| agnes | kgabis | C with libSDL examples | Announcement |
| HydraNES | BadFoolPrototype | C++, Glew/OpenGL / Win32 | Announcement / First mention |
| TetaNES | lukexor | Rust, wgpu / Linux, Windows, macOS, WebAssembly | Announcement / Source / TetaNES Web |
| nos | olivecc | C++, SDL2 / Linux | Announcement |
| nin | Nax | C++, Qt , OpenAL, OpenGL | Announcement |
| q00.nes | LilaQ | C++ / Win32 | Announcement |
| BeesNES | L. Spiro | C++ / Win32 / Win64 | First mention |
| uNESsential | Johannes Holmberg | QBasic / DOS, Linux, Windows, macOS | Source |
| nes-emulator | CreatureOX | Python | Announcement |
| NES260 | fenzo | Verilog / FPGA (hardware) | Announcement for Xilinx KV260 FPGA board |
| ArkNESS | thekamal | C++ / Windows | Announcement |
| NesEmulator | daxnet | C#, .NET |  |
| dendy | Max Poletaev | Golang, raylib, Ebitengine / Linux, Windows, macOS |  |
| ChibiNES | Koki Oyatsu | Golang, OpenGL, PortAudio / Linux, Windows, macOS |  |
| NES-Emulator | junnys6018 | C / Linux, Windows, WebAssembly |  |
| NESTang | nand2mario | Verilog / FPGA (hardware) | For Sipeed Tang Primer 25K, Nano 20K and Primer 20K boards |
| DenverEMU | nIghtorius | C++, SDL2, OpenGL3 / Win, Linux | Announcement |
| plastic | Amjad Alsharafi | Rust, alsa, libudev / Linux |  |
| CalascioNES | Franco1262 | C++, SDL2, ImGui |  |
| Nen Emulator | Comba92 | Rust, SDL2 |  |
| lucynes | lucypero | Odin, raylib |  |
| FNES | Hamed Rezaee | Dart, Flutter / Linux, Windows, macOS, Web, Android, iOS | Online Emulator |
| Emu910D0 | Diwas Adhikari | C++, SDL2, ImGui / Linux, Windows |  |

## Discontinued

These are emulators which are known to be officially discontinued, i.e. abandoned or are no longer in development.

| Emulator name | Author | Technology(s) / Platform(s) | Last update | Other details |
| LandyNES | Alex Krasivsky | MS-DOS | 1996 | One of the first NES emulators |
| NESticle | Icer Addis | MS-DOS / Win95 | 1998 |
| fwNES | Fan Wan Yang, Shu Kondo | MS-DOS | 1998 | Popularized the FDS file format |
| iNES | John Stiles | Classic Mac OS | 2000 |
| Famtasia | nori, taka2 | Win32 | 2001 | First emulator to be supported by TASVideos |
| NESten | TNSe | Win32 | 2003 |
| VirtuaNES | Norix | Win32 | 2007 | Has a real-time memory hex-editor |
| FCEUXD SP | sp | Win32 | 2007 | was merged with other FCEU forks under the name FCEUX |
| NEStopia | Martin Freij | Win32, OS X, Linux | 2008 | Linux, MacOS |
| FPGA NES | kevtris | FPGA (hardware) | 2008 |
| AminNes | amin2312 | Flash | 2009 | Announcement |
| VeriNES | jwdonal | FPGA (hardware) | 2010 | Announcement - Website is not working |
| iNES | Marat Fayzullin | MS-DOS | 2010 | Win32 and Linux versions still active. Popularized the iNES file format. |
| UberNES | M \ K Productions | Win32 | 2011 |
| NESFaCE | 6T4 | Win32 | 2011 | Announcement |
| nesemu1 | Bisqwit | libSDL (portable), testing under Linux | 2011 | Announcement |
| Nezulator | Zelex | JavaScript | 2011 | Announcement |
| FPGA NES | Dan Strother | FPGA (hardware) | 2011 |
| Kryptonware | rubenhbaca | Java | 2012 | Initial development announcement. Website has reported "under maintenance" for a very long time |
| MSE | Alegend45 | ? | 2012 | Initial development announcement. GitHub account has been deleted |
| NESSIM | MottZilla | Win32 | 2012 | Announcement |
| ? | graham | Javascript | 2013 | Initial development announcement. Website returns internal server error |
| MoarNES | miker00lz | Win32 | 2013 | Announcement |
| EMUya | Zelex | Ouya | 2013 | Announcement - Website not working anymore |
| VPNES | x0000 | Win32 w/ SDL | 2013 | Announcement |
| ? | submarine600 | PC-8801 | 2013 | Announcement - Website not working anymore |
| FPGA NES | Ludde | FPGA (hardware) | 2014 |
| famique | sahib | Mac OS X, Win32, Linux | 2015 | Announcement - GitHub repository has been deleted |
| Yanese | Anes | Win32 | 2015 | Announcement Website not working anymore |
| finalnes | austere | Win32 | 2015 | Announcement |
| macifom | Auston Stewart | OS X, iOS | 2015 | Announcement |
| macifomlite | Auston Stewart | iOS | 2015 |
| Yane | roku6185 | libSDL (portable), testing under Linux | 2015 | Announcement |
| MahNES | HLorenzi | Win32 | 2015 | Announcement |
| phibiaNES | nIghtorius | SDL / Win32 | 2015 | Announcement |
| nesalizer | Ulfalizer | libSDL (portable), tested on Linux | 2016 |
| EduNes | thomson | SDL2 | 2016 | Announcement |
| MacFC | T.Aoyama | Classic Mac OS, Mac OS X | 2016 |
| fixNES | FIX94 | C, Win32, Linux | 2020 |
| NESizm | tswilliamson | C++, Casio Prizm graphics calculators | 2021 |
| vbNES | mikechambers84 | Visual Basic 6 | 2021 |
| Retro Imitator | JRoatch | C, SDL1, Libretro | 2025 | Announcement, not a serious emulator, just an imitation |

## See also
- Releasing on modern platforms

# Installing CC65

Source: https://www.nesdev.org/wiki/Installing_CC65

An assembler is a program that translates assembly language source code into machine code. A commonly used assembler that produces machine code for 6502 CPUs is CA65 , which is distributed as part of the CC65 package. These instructions tell how to install and run CA65.

## Installing CC65 on Windows

### Downloading CC65
- Go to the links portion of the main page of CC65's web site.
- Click on the "Windows Snapshot" link. This will take you to CC65's SourceForge download page for `cc65-snapshot-win32.zip `.
  - There is also a 64-bit version available for computers with the appropriate architecture. Go to CC65's SourceForge page's files sectionand download `cc65-snapshot-win64.zip `.
  - Documentation is contained in `cc65-snapshot-docs.zip `.
- Extract `cc65-snapshot-win**.zip `to a known folder, such as `C:\cc65 `for example.

### Adding CC65 to Path

CC65 binaries are now contained in `<known_folder>\cc65\bin `. In order to run the binaries from anywhere, we must add the binary folder to the path environment variable.
- In the search bar, look for "Edit the system environment variables" and select it. Alternatively, type `sysdm.cpl `in the search bar and run it. You may need to confirm a UAC prompt.
- In the Advanced tab, click on the "Environment Variables..." button. A new window will appear.
- In the list of "System variables", select the "Path" variable and click the "Edit" button. A new window will appear with the list of paths.
- Click on the "New" button, and type the location of the CC65 binaries ( `<known_folder>\cc65\bin `).
- Press OK on all three of the windows.
- You may need to restart any command-line terminals running, or log out and log back in.

### Showing file extensions

Windows is shipped with file name extensions hidden in the File Explorer. However, hiding them makes it easier to accidentally create a file name with two extensions, which may interfere with compiling. Therefore the first thing to do is turn on the display of file name extensions.

For Windows 8 and onward, this setting can be changed from the View tab in the File Explorer's ribbon interface. (Check the "Show File Extensions" checkbox).

For Windows 7 and earlier:
- Open Explorer and click on the Tools tab > Folder Options...
- Go to the the View tab. In the scrolling list of Advanced Options, make sure that "Hide extensions for known file types" is not checked.
- Press OK to put the change into effect.

## Installing CC65 on Linux

### Installing with Package Managers

The easiest method is to install CC65 using the package manager of your choice. Here are some examples from popular distributions:
- Debian-based: apt/apt-get
- Arch-based: yay (or any other AUR helper)
- RedHat-based: dnf/yum

### Building from git

If CC65 is not available via your package manager, or you wish to use features/bugfixes not yet present in release versions, you can build it from the source code instead. On Debian-based distributions, open a terminal and enter the following commands. On other distributions, the `apt `command will need to be changed.

```text
sudo apt install build-essential git
mkdir -p ~/develop
cd ~/develop
git clone https://github.com/cc65/cc65.git
cd cc65
nice make -j2
make install PREFIX=~/.local
which cc65

```

If your account has been configured to run applications built from source and installed for one user, the last step should show `/home/<username>/.local/bin/cc65 `. If it does not, add `~/.local/bin `to your `PATH `environment variable:

```text
nano ~/.bashrc

# and add the following at the end of the file
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

```

Press Ctrl+O Enter to save, then Ctrl+X to quit, and the change to `PATH `will take effect the next time you log in.

## Installing CC65 on Mac OS X

Using Homebrew: On computer with Homebrew installed, open Terminal and type the following command: `brew install cc65 `. Everything else should be automatic.

Using Macports: Alternatively macports can be used for easy and fast installation. Open a terminal and enter the following command: `sudo port install cc65 `. This will install cc65, ca65 and ld65 on the computer.

# NES 2.0 header for ca65

Source: https://www.nesdev.org/wiki/NES_2.0_header_for_ca65

This macro pack for ca65 constructs a 16-byte NES 2.0header.

A port for cc65 C code is available NES 2.0 header for cc65

```text
;
; NES 2.0 header generator for ca65 (nes2header.inc)
;
; Copyright 2016 Damian Yerrick
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;

;;
; Puts ceil(log2(sz / 64)) in logsz, which should be
; local to the calling macro.  Used for NES 2 RAM sizes.
.macro _nes2_logsize sz, logsz
  .assert sz >= 0 .and sz <= 1048576, error, "RAM size must be 0 to 1048576"
  .if sz < 1
    logsz = 0
  .elseif sz <= 128
    logsz = 1
  .elseif sz <= 256
    logsz = 2
  .elseif sz <= 512
    logsz = 3
  .elseif sz <= 1024
    logsz = 4
  .elseif sz <= 2048
    logsz = 5
  .elseif sz <= 4096
    logsz = 6
  .elseif sz <= 8192
    logsz = 7
  .elseif sz <= 16384
    logsz = 8
  .elseif sz <= 32768
    logsz = 9
  .elseif sz <= 65536
    logsz = 10
  .elseif sz <= 131072
    logsz = 11
  .elseif sz <= 262144
    logsz = 12
  .elseif sz <= 524288
    logsz = 13
  .else
    logsz = 14
  .endif
.endmacro

;;
; Sets the PRG ROM size to sz bytes. Must be multiple of 16384;
; should be a power of 2.
; example: nes2prg 131072
.macro nes2prg sz
.local sz1
  sz1 = (sz) / 16384
_nes2_prgsize = <sz1
_nes2_prgsizehi = >sz1
.endmacro

;;
; Sets the CHR ROM size to sz bytes. Must be multiple of 8192;
; should be a power of 2.  Default is 0, meaning only CHR RAM.
; example: nes2chr 32768
.macro nes2chr sz
.local sz1
  sz1 = (sz) / 8192
_nes2_chrsize = <sz1
_nes2_chrsizehi = >sz1
.endmacro

;;
; Sets the (not battery-backed) work RAM size in bytes.
; Default is 0.
.macro nes2wram sz
.local logsz
  _nes2_logsize sz, logsz
  _nes2_wramsize = logsz
.endmacro

;;
; Sets the battery-backed work RAM size in bytes.  Default is 0.
.macro nes2bram sz
.local logsz
  _nes2_logsize sz, logsz
  _nes2_bramsize = logsz
.endmacro

;;
; Sets the (not battery-backed) CHR RAM size in bytes.  Default is 0
; if CHR ROM or battery-backed CHR RAM is defined; otherwise 8192.
.macro nes2chrram sz
.local logsz
  _nes2_logsize sz, logsz
  _nes2_chrramsize = logsz
.endmacro

;;
; Sets the battery-backed CHR RAM size in bytes.  Default is 0.
.macro nes2chrbram sz
.local logsz
  _nes2_logsize sz, logsz
  _nes2_chrbramsize = logsz
.endmacro

;;
; Sets nametable arrangement to one of these values:
; 'V' (vertical arrangement, horizontal mirroring)
; 'H' (horizontal arrangement, vertical mirroring)
; '4' (four-screen VRAM)
; 218 (four-screen and vertical bits on, primarily for mapper 218)
; Default is 'V'.
.macro nes2arrange arr
.local mi1
  mi1 = arr
  .if mi1 = 'v' .or mi1 = 'V'
    _nes2_mirror = 0
  .elseif mi1 = 'h' .or mi1 = 'H'
    _nes2_mirror = 1
  .elseif mi1 = '4'
    _nes2_mirror = 8
  .elseif mi1 = 218
    _nes2_mirror = 9
  .else
    .assert 0, error, "Nametable arrangement must be 'H', 'V', or '4'"
  .endif
.endmacro

;;
; Same as nes2arrange, except 'H' and 'V' are swapped to use the
; "mirroring" terminology introduced by the emulation scene.
.macro nes2mirror mir
.local mi1
  mi1 = mir
  .if mi1 = 'h' .or mi1 = 'H'
    _nes2_mirror = 0
  .elseif mi1 = 'v' .or mi1 = 'V'
    _nes2_mirror = 1
  .elseif mi1 = '4'
    _nes2_mirror = 8
  .elseif mi1 = 218
    _nes2_mirror = 9
  .else
    .assert 0, error, "Nametable mirroring must be 'H', 'V', or '4'"
  .endif
.endmacro

;;
; Sets the mapper (board class) ID.  For example, MMC3 is usually
; mapper 4, but TLSROM is 118 and TQROM is 119.  Some mappers have
; variants.
.macro nes2mapper mapperid, submapper
.local mi1, ms1
  mi1 = mapperid
  .assert mi1 >= 0 .and mi1 < 4096, error, "Mapper must be 0 to 4095"
  .ifnblank submapper
    .assert ms1 >= 0 .and ms1 < 16, error, "Submapper must be 0 to 15"
    ms1 = submapper
  .else
    ms1 = 0
  .endif
  _nes2_mapper6 = (mi1 & $0F) << 4
  _nes2_mapper7 = mi1 & $F0
  _nes2_mapper8 = (mi1 >> 8) | (ms1 << 4)
.endmacro

;;
; Sets the ROM's intended TV system:
; 'N' for NTSC NES/FC/PC10
; 'P' for PAL NES
; 'N','P' for dual compatible, preferring NTSC
; 'P','N' for dual compatible, preferring PAL NES
; Default is 'N'.
.macro nes2tv tvsystem, dual_compatible
.local tv1, tv2
  tv1 = tvsystem
  .ifnblank dual_compatible
    tv2 = $02
  .else
    tv2 = $00
  .endif
  .if tv1 = 'n' .or tv1 = 'N'
    _nes2_tvsystem = $00 | tv2
  .elseif tv1 = 'p' .or tv1 = 'P'
    _nes2_tvsystem = $01 | tv2
  .else
    .assert 0, error, "TV system must be 'N' or 'P'"
  .endif
.endmacro

;;
; Writes the header configured by previous nes2 macros.
.macro nes2end
.local battery_bit
  ; Apply defaults
  .ifndef _nes2_chrsize
    nes2chr 0
  .endif
  .ifndef _nes2_mirror
    nes2arrange 'V'
  .endif
  .ifndef _nes2_wramsize
    nes2wram 0
  .endif
  .ifndef _nes2_bramsize
    nes2bram 0
  .endif
  .ifndef _nes2_chrbramsize
    nes2chrbram 0
  .endif
  .ifndef _nes2_chrramsize
    .if _nes2_chrsize .or _nes2_chrsizehi .or _nes2_chrbramsize
      nes2chrram 0
    .else
      nes2chrram 8192
    .endif
  .endif
  .ifndef _nes2_tvsystem
    nes2tv 'N'
  .endif
  .if _nes2_bramsize .or _nes2_chrbramsize
    battery_bit = $02
  .else
    battery_bit = $00
  .endif

  .pushseg
  .segment "INESHDR"
  .byte "NES",$1A
  .byte _nes2_prgsize, _nes2_chrsize
  .byte _nes2_mapper6 | _nes2_mirror | battery_bit
  .byte _nes2_mapper7 | $08  ; not supporting vs/pc10 yet

  .byte _nes2_mapper8
  .byte (_nes2_chrsizehi << 4) | _nes2_prgsizehi
  .byte (_nes2_bramsize << 4) | _nes2_wramsize
  .byte (_nes2_chrbramsize << 4) | _nes2_chrramsize

  .byte _nes2_tvsystem, 0, 0, 0
  .popseg
.endmacro

```

## Linker script requirement

Your linker configuration file will need to have a segment called `INESHDR `in the first ROM memory area.

```text
MEMORY {
  HEADER: start = 0, size = $0010, type = ro, file = %O, fill=yes, fillval=$00;
  # Other memory area definitions appropriate for your board
}
SEGMENTS {
  INESHDR:  load = HEADER, type = ro, align = $10;
  # Other segment definitions appropriate for your board
}

```

## Examples

A CNROMboard with vertical arrangement (V pad bridged, also called horizontal mirroring) for NTSC systems:

```text
.include "nes2header.inc"
nes2mapper 3
nes2prg 32768
nes2chr 32768
nes2arrange 'V'
nes2tv 'N'
nes2end

```

An SLROMboard with 128 KiB PRG ROM, 128 KiB CHR ROM, 8 KiB battery-backed WRAM, and PAL-preferred but dual-compatible program:

```text
.include "nes2header.inc"
nes2mapper 1
nes2prg 131072
nes2chr 131072
nes2bram 8192
nes2tv 'P','N'
nes2end

```

An MMC3board with 512 KiB PRG ROM, 32 KiB CHR RAM, and NTSC-only program:

```text
.include "nes2header.inc"
nes2mapper 4
nes2prg 524288
nes2chrram 32768
nes2tv 'N'
nes2end

```

# NES 2.0 header for cc65

Source: https://www.nesdev.org/wiki/NES_2.0_header_for_cc65

A cc65 compatible header file for generating a NES 2.0with macros

The original ASM version for ca65 is available NES 2.0 header for ca65

```text
/**
 * NES 2.0 header generator for cc65 (nes2header.h)
 *
 * USAGE: Generates a header for the NES2 format with C macros
 *
 * NES2_HEADER(segmentname) - Creates a NES header in the segment provided by segment name.
 * The values can be configured using all the of the options described below.
 *
 * EXAMPLE:
 *
 * #define NES2_MAPPER 4    // REQUIRED: Choose mapper number 4
 * #define NES2_PRG 65536   // REQUIRED: With 64kb PRG ROM
 * #define NES2_BRAM 8192   // And 8kb PRG RAM
 * #define NES2_MIRROR 'V'  // Vertical screen mirroring
 * #define NES2_TV 'N'      // For NTSC tvs
 * NES2_HEADER("INESHDR");  // and now build the header into the segment named `INESHDR`
 *
 * DESCRIPTION: The following values can be defined to set the corresponding NES 2.0 header fields
 *
 * - NES2_MAPPER, NES2_SUBMAPPER
 *    Sets the mapper (board class) ID.  For example, MMC3 is usually
 *    mapper 4, but TLSROM is 118 and TQROM is 119.  Some mappers have
 *    variants.
 *    NO DEFAULT (Required)
 *    Example: (sets the mapper to MMC3 with submapper variant 1 used by StarTropics)
 *     #define NES2_MAPPER 4
 *     #define NES2_SUBMAPPER 1
 *
 * - NES2_PRG
 *    Sets the PRG ROM size to sz bytes. Must be multiple of 16384;
 *    should be a power of 2.
 *    NO DEFAULT (Required)
 *    Example: #define NES2_PRG 131072
 *
 * - NES2_CHR
 *    Sets the CHR ROM size to sz bytes. Must be multiple of 8192;
 *    should be a power of 2.
 *    Default value: 0
 *    Example: #define NES2_CHR 32768
 *
 * - NES2_WRAM
 *    Sets the (not battery-backed) work RAM size in bytes.
 *    Default is 0.
 *    Example: #define NES2_WRAM 8192
 *
 * - NES2_BRAM
 *    Sets the battery-backed work RAM size in bytes.
 *    Default is 0.
 *    Example: #define NES2_BRAM 8192
 *
 * - NES2_CHRBRAM
 *    Sets the battery-backed CHR RAM size in bytes.
 *    Default is 0.
 *    Example: #define NES2_CHRBRAM 8192
 *
 * - NES2_MIRROR
 *    Sets the mirroring to one of these values:
 *    'H' (horizontal mirroring, vertical arrangement)
 *    'V' (vertical mirroring, horizontal arrangement)
 *    '4' (four-screen VRAM)
 *    '8' (four-screen and vertical bits on, primarily for mapper 218)
 *    Default is 'H'
 *    Example: #define NES2_MIRROR 'V'
 *
 * - NES2_TV
 *    Sets the ROM's intended TV system:
 *    'N' for NTSC NES/FC/PC10
 *    'P' for PAL NES
 *    '1' for dual compatible, preferring NTSC
 *    '2' for dual compatible, preferring PAL NES
 *    Default is 'N'
 *    Example: #define NES2_TV '1'
 *
 * Original ca65 macro Copyright 2016 Damian Yerrick
 * cc65 macro Copyright 2022 James Rowe
 * Copying and distribution of this file, with or without
 * modification, are permitted in any medium without royalty provided
 * the copyright notice and this notice are preserved in all source
 * code copies.  This file is offered as-is, without any warranty.
 *
 */

#ifndef NES2HEADER_P_H
#define NES2HEADER_P_H

#ifndef NES2_SUBMAPPER
  #define NES2_SUBMAPPER 0x0
#endif //NES2_SUBMAPPER

// Define the bytes for the mapper fields
#define _NES2_MAPPER6 (((NES2_MAPPER) & 0x0F) << 4)
#define _NES2_MAPPER7 ((NES2_MAPPER) & 0xF0)
#define _NES2_MAPPER8 (((NES2_MAPPER) >> 8) | ((NES2_SUBMAPPER) << 4))

#define _NES2_PRG_SIZE (((NES2_PRG) / 16384) & 0xFF)
#define _NES2_PRG_SIZE_HI ((((NES2_PRG) / 16384) >> 8) & 0xFF)

// Define the defaults for the constants
#ifdef NES2_CHR
  #define _NES2_CHR_SIZE (((NES2_CHR) / 8192) & 0xFF)
  #define _NES2_CHR_SIZE_HI ((((NES2_CHR) / 8192) >> 8) & 0xFF)
#else
  #define _NES2_CHR_SIZE 0
  #define _NES2_CHR_SIZE_HI 0
#endif //NES2_CHR_SIZE

// Helper function: Computes ceil(log2(sz / 64)) Used for NES2 RAM sizes.
#define _NES2_ERROR -1
#define _NES2_LOGSIZE(sz) \
  (((sz) < 1L)       ? 0  : \
   ((sz) <= 128L)    ? 1  : \
   ((sz) <= 256L)    ? 2  : \
   ((sz) <= 512L)    ? 3  : \
   ((sz) <= 1024L)   ? 4  : \
   ((sz) <= 2048L)   ? 5  : \
   ((sz) <= 4096L)   ? 6  : \
   ((sz) <= 8192L)   ? 7  : \
   ((sz) <= 16384L)  ? 8  : \
   ((sz) <= 32768L)  ? 9  : \
   ((sz) <= 65536L)  ? 10 : \
   ((sz) <= 131072L) ? 11 : \
   ((sz) <= 262144L) ? 12 : \
   ((sz) <= 524288L) ? 13 : \
   ((sz) <= 1048576L)? 14 : _NES2_ERROR)

#define _NES2_MIRROR_HELPER(x) \
    (((x) == 'h' || (x) == 'H') ? 0 : \
     ((x) == 'v' || (x) == 'V') ? 1 : \
     ((x) == '4') ? 8 : \
     ((x) == '8') ? 9 : _NES2_ERROR)

#ifdef NES2_MIRROR
  #define _NES2_MIRROR_OUT (_NES2_MIRROR_HELPER(NES2_MIRROR))
#else
  #define _NES2_MIRROR_OUT (_NES2_MIRROR_HELPER('H'))
#endif //NES2_MIRROR

#ifdef NES2_WRAM
  #define _NES2_WRAM_SIZE (_NES2_LOGSIZE(NES2_WRAM))
#else
  #define _NES2_WRAM_SIZE (_NES2_LOGSIZE(0))
#endif //NES2_WRAM

#ifdef NES2_BRAM
  #define _NES2_BRAM_SIZE (_NES2_LOGSIZE(NES2_BRAM))
#else
  #define _NES2_BRAM_SIZE (_NES2_LOGSIZE(0))
#endif //NES2_BRAM

#ifdef NES2_CHRBRAM
  #define _NES2_CHRBRAM_SIZE (_NES2_LOGSIZE(NES2_CHRBRAM))
#else
  #define _NES2_CHRBRAM_SIZE (_NES2_LOGSIZE(0))
#endif //NES2_CHRBRAM

#ifdef NES2_CHRRAM
  #define _NES2_CHRRAM_SIZE (_NES2_LOGSIZE(NES2_CHRRAM))
#else
  // CHRRAM size depends on if the mapper has CHRBRAM or CHR already defined
#define _NES2_CHRRAM_SIZE \
  ((((_NES2_CHR_SIZE) + _NES2_CHR_SIZE_HI + (_NES2_CHRBRAM_SIZE)) > 0) ? 0 : _NES2_LOGSIZE(32768L))
#endif

// Battery bit is set if we have either BRAM or CHRBRAM
#define _NES2_BATTERY_BIT \
  ((((_NES2_BRAM_SIZE) + (_NES2_CHRBRAM_SIZE)) > 0) ? 0x02 : 0x0)

#define _NES2_TV_HELPER(x) \
    (((x) == 'n' || (x) == 'N') ? 0 : \
     ((x) == 'p' || (x) == 'P') ? 1 : \
     ((x) == '1') ? 2 : \
     ((x) == '2') ? 3 : -1)

#ifdef NES2_TV
  #define _NES2_TV_SYSTEM _NES2_TV_HELPER(NES2_TV)
#else
  #define _NES2_TV_SYSTEM _NES2_TV_HELPER('N')
#endif //NES2_TV

#define _NES2_STRINGIFY(a) #a

#define NES2_HEADER(segment) \
  _Pragma( _NES2_STRINGIFY( rodata-name ## ( ## push, ## segment ## ) ## ) ); \
  _Static_assert (_NES2_WRAM_SIZE != _NES2_ERROR, "WRAM size must be 0 to 1048576"); \
  _Static_assert (_NES2_BRAM_SIZE != _NES2_ERROR, "BRAM size must be 0 to 1048576"); \
  _Static_assert (_NES2_CHRBRAM_SIZE != _NES2_ERROR, "CHRBRAM size must be 0 to 1048576"); \
  _Static_assert (_NES2_MIRROR_OUT != _NES2_ERROR, "Mirroring mode must be 'H', 'V', '4', or '8'"); \
  _Static_assert (_NES2_TV_SYSTEM != _NES2_ERROR, "TV system must be 'N', 'P', '1', or '2'"); \
  const unsigned char nes2header[16] = {\
    'N', 'E', 'S', 0x1A,\
    _NES2_PRG_SIZE, _NES2_CHR_SIZE,\
    _NES2_MAPPER6 | _NES2_MIRROR_OUT | _NES2_BATTERY_BIT, \
    _NES2_MAPPER7 | 0x08, \
    _NES2_MAPPER8, \
    (_NES2_CHR_SIZE_HI << 4) | _NES2_PRG_SIZE_HI, \
    (_NES2_BRAM_SIZE << 4) | _NES2_WRAM_SIZE, \
    (_NES2_CHRBRAM_SIZE << 4) | _NES2_CHRRAM_SIZE, \
    _NES2_TV_SYSTEM, 0, 0, 0 \
  };\
  _Pragma("rodata-name(pop)");

#endif //NES2HEADER_P_H

```

## Linker script requirement

Your linker configuration file will need to have a segment for the header in the first ROM memory area. This segment can have any name, but should have 16 bytes of size.

```text
MEMORY {
  HEADER: start = 0, size = $0010, type = ro, file = %O, fill=yes, fillval=$00;
  # Other memory area definitions appropriate for your board
}
SEGMENTS {
  INESHDR:  load = HEADER, type = ro, align = $10;
  # Other segment definitions appropriate for your board
}

```

## Examples

A CNROMboard with horizontal mirroring(V pad) for NTSC systems:

```text
#include "nes2header.h"
#define NES2_MAPPER 3
#define NES2_PRG 32768
#define NES2_CHR 32768
#define NES2_MIRROR 'H'
#define NES2_TV 'N'
NES2_HEADER("INESHDR");

```

An SLROMboard with 128 KiB PRG ROM, 128 KiB CHR ROM, 8 KiB battery-backed WRAM, and PAL-preferred but dual-compatible program:

```text
#include "nes2header.inc"
#define NES2_MAPPER 1
#define NES2_PRG 131072
#define NES2_CHR 131072
#define NES2_BRAM 8192
#define NES2_TV 'P','N'
NES2_HEADER("INESHDR");

```

An MMC3board with 512 KiB PRG ROM, 32 KiB CHR RAM, and NTSC-only program:

```text
#include "nes2header.inc"
#define NES2_MAPPER 4
#define NES2_PRG 524288
#define NES2_CHRRAM 32768
#define NES2_TV 'N'
NES2_HEADER("INESHDR");

```

# Emulators

Source: https://www.nesdev.org/wiki/NES_emulator

This is a list of NES emulators .

## Commercial

| Emulator name | Author | Platform(s) | Ports and/or other details |
| acNES | Nintendo | Nintendo 64, GameCube | Used in the first generation Animal Crossing games. The commonly used "acNES" name is unofficial, as Nintendo has not released this emulator as a distinct product. A decompilation of Animal Crossing uses "ksNes". Information from TCRF indicates that it may be called "QFC" internally. |
| Classic NES Series | Nintendo | Game Boy Advance | Used for the Classic NES Series. |
| Virtual Console | Nintendo | Wii, Wii U, 3DS | Most games were priced at 500 Nintendo Points on the Wii Shop Channel, or similar prices on the Wii U/3DS eShop. The 3DS version uses the TNES file format. |
| PocketNES | loopy, FluBBa, and Dwedit | Game Boy Advance, Nintendo DS | Used commercially for some emulated re-releases by Atlus, Jaleco, and Konami. |
| Heritage | Nintendo | Wii U, 3DS | Used for the NES/Famicom Remix series. |
| Kachikachi | Nintendo | Linux | Used for the NES Classic Edition/Famicom Classic Mini (+ Shōnen Jump version). Pre-installed game selection differs between versions. |
| Nintendo Entertainment System/Family Computer - Nintendo Switch Online | Nintendo | Nintendo Switch | Available for users with a Nintendo Switch Online Membership. Pre-installed game selection differs between regions. |

## Popular

These are commonly used or well-established.

| Emulator name | Author | Platform(s) | Ports and/or other details |
| BizHawk | Multiple authors | Win32, Linux |
| FCE Ultra GX | Tantric | Wii, GameCube |
| FCEUX | Anthony Giorgio / Mark Doliner | Win32, macOS, Linux |
| higan | Near (formerly as byuu) | Win32, FreeBSD, Linux, macOS |
| iNES | Marat Fayzullin | Win32 and Linux |
| Jnes | Jabosoft | Win32 |
| Mesen | Sour | Win32, Linux/.NET | Announcement / Source, excellent debugger |
| nemulator | James Slepicka | Win32 | Source |
| nesemu2 | holodnak | Win32, OS X, Linux |

| Nestopia UE | rdanbrook | Linux, BSD, Win7+ | a.k.a. Nestopia Undead Edition. Contains bugfixes/etc.Windows binaries are available at Sourceforge or at EmuCR |
| Nintaco | zeroone | Java (Windows, GNU/Linux, macOS) | Announcement Source API FAQ Screenshots |
| Nintendulator | Quietust | Win32 | Nintendulator DX (by thefox) for an even more-improved debugger |
| NO$NES | Martin Korth | Win32 |
| PocketNES | loopy, FluBBa, and Dwedit | Game Boy Advance | Updates on Dwedit's board |
| RockNES | Zepper (formerly Fx3) | Win32 |

## Under development

The following is a list of NES emulators that are under development, who their authors are, relevant home pages/sites, and the source of the announcement (direct or indirect). Only projects are listed that had a release in form of source or binary.

| Emulator name | Author | Technology(s) / Platform(s) | Ports and/or other details |
| NESICIDE | cpow | Qt, C++ / Win32 / Win64, Linux32, Linux64, macOS | Source |
| kindred | Overload | Win32 | Announcement |
| A/NES | Morgan Johansson | AmigaOS | Announcement |
| puNES | FHorse | Qt, C++ / Linux, FreeBSD, OpenBSD, Win32 | Announcement |
| jaNES | crudelios | C++ / Win32 | Announcement |
| HDNes | mkwong98 | C++ / Win32 | Announcement |
| Fergulator | fergus_maximus | Golang, SDL / Linux, Windows, macOS | Announcement |
| Pretendo | proxy | C++ / Linux/BeOS/Win32 | Announcement |
| NES-Emulator | Dartht33bagger | C, SDL | Announcement |
| nintengo | nwidger | Golang, SDL / Linux, Windows, macOS |  |
| ffnes | rockcarry | C / Win32 | Announcement |
| WebNES | peteward44 | Javascript | Announcement / Live demo |
| O-Nes-Sama | Fumarumota, aLaix | C++, SDL2 / Win32, Linux) | Announcement |
| cfxnes | jonyzz | Javascript | Announcement / Live demo |
| nes-emu | daroou | C++, SDL2 / Win32, Linux | Announcement |
| fogleman/nes | Michael Fogleman | Golang, OpenGL, PortAudio / Linux, Windows, macOS | Medium article |
| NES-Emu | imid | C#, .NET | Announcement |
| nSide | hex_usr | C++ | Fork of byuu's higan-nes. Announcement |
| HalfNES | Grapeshot | Java |  |
| fpgaNES | Feuerwerk42 | VHDL, Verilog / FPGA (hardware) | Announcement |
| Nintendoish | drewying | Swift / Win32, macOS | Announcement |
| triforce | tdondich | JavaScript, VueJS | Announcement |
| Project-Nested | Myself086 | Assembly / SNES | Announcement |
| nescore | rodri042 | JavaScript | Announcement |
| agnes | kgabis | C with libSDL examples | Announcement |
| HydraNES | BadFoolPrototype | C++, Glew/OpenGL / Win32 | Announcement / First mention |
| TetaNES | lukexor | Rust, wgpu / Linux, Windows, macOS, WebAssembly | Announcement / Source / TetaNES Web |
| nos | olivecc | C++, SDL2 / Linux | Announcement |
| nin | Nax | C++, Qt , OpenAL, OpenGL | Announcement |
| q00.nes | LilaQ | C++ / Win32 | Announcement |
| BeesNES | L. Spiro | C++ / Win32 / Win64 | First mention |
| uNESsential | Johannes Holmberg | QBasic / DOS, Linux, Windows, macOS | Source |
| nes-emulator | CreatureOX | Python | Announcement |
| NES260 | fenzo | Verilog / FPGA (hardware) | Announcement for Xilinx KV260 FPGA board |
| ArkNESS | thekamal | C++ / Windows | Announcement |
| NesEmulator | daxnet | C#, .NET |  |
| dendy | Max Poletaev | Golang, raylib, Ebitengine / Linux, Windows, macOS |  |
| ChibiNES | Koki Oyatsu | Golang, OpenGL, PortAudio / Linux, Windows, macOS |  |
| NES-Emulator | junnys6018 | C / Linux, Windows, WebAssembly |  |
| NESTang | nand2mario | Verilog / FPGA (hardware) | For Sipeed Tang Primer 25K, Nano 20K and Primer 20K boards |
| DenverEMU | nIghtorius | C++, SDL2, OpenGL3 / Win, Linux | Announcement |
| plastic | Amjad Alsharafi | Rust, alsa, libudev / Linux |  |
| CalascioNES | Franco1262 | C++, SDL2, ImGui |  |
| Nen Emulator | Comba92 | Rust, SDL2 |  |
| lucynes | lucypero | Odin, raylib |  |
| FNES | Hamed Rezaee | Dart, Flutter / Linux, Windows, macOS, Web, Android, iOS | Online Emulator |
| Emu910D0 | Diwas Adhikari | C++, SDL2, ImGui / Linux, Windows |  |

## Discontinued

These are emulators which are known to be officially discontinued, i.e. abandoned or are no longer in development.

| Emulator name | Author | Technology(s) / Platform(s) | Last update | Other details |
| LandyNES | Alex Krasivsky | MS-DOS | 1996 | One of the first NES emulators |
| NESticle | Icer Addis | MS-DOS / Win95 | 1998 |
| fwNES | Fan Wan Yang, Shu Kondo | MS-DOS | 1998 | Popularized the FDS file format |
| iNES | John Stiles | Classic Mac OS | 2000 |
| Famtasia | nori, taka2 | Win32 | 2001 | First emulator to be supported by TASVideos |
| NESten | TNSe | Win32 | 2003 |
| VirtuaNES | Norix | Win32 | 2007 | Has a real-time memory hex-editor |
| FCEUXD SP | sp | Win32 | 2007 | was merged with other FCEU forks under the name FCEUX |
| NEStopia | Martin Freij | Win32, OS X, Linux | 2008 | Linux, MacOS |
| FPGA NES | kevtris | FPGA (hardware) | 2008 |
| AminNes | amin2312 | Flash | 2009 | Announcement |
| VeriNES | jwdonal | FPGA (hardware) | 2010 | Announcement - Website is not working |
| iNES | Marat Fayzullin | MS-DOS | 2010 | Win32 and Linux versions still active. Popularized the iNES file format. |
| UberNES | M \ K Productions | Win32 | 2011 |
| NESFaCE | 6T4 | Win32 | 2011 | Announcement |
| nesemu1 | Bisqwit | libSDL (portable), testing under Linux | 2011 | Announcement |
| Nezulator | Zelex | JavaScript | 2011 | Announcement |
| FPGA NES | Dan Strother | FPGA (hardware) | 2011 |
| Kryptonware | rubenhbaca | Java | 2012 | Initial development announcement. Website has reported "under maintenance" for a very long time |
| MSE | Alegend45 | ? | 2012 | Initial development announcement. GitHub account has been deleted |
| NESSIM | MottZilla | Win32 | 2012 | Announcement |
| ? | graham | Javascript | 2013 | Initial development announcement. Website returns internal server error |
| MoarNES | miker00lz | Win32 | 2013 | Announcement |
| EMUya | Zelex | Ouya | 2013 | Announcement - Website not working anymore |
| VPNES | x0000 | Win32 w/ SDL | 2013 | Announcement |
| ? | submarine600 | PC-8801 | 2013 | Announcement - Website not working anymore |
| FPGA NES | Ludde | FPGA (hardware) | 2014 |
| famique | sahib | Mac OS X, Win32, Linux | 2015 | Announcement - GitHub repository has been deleted |
| Yanese | Anes | Win32 | 2015 | Announcement Website not working anymore |
| finalnes | austere | Win32 | 2015 | Announcement |
| macifom | Auston Stewart | OS X, iOS | 2015 | Announcement |
| macifomlite | Auston Stewart | iOS | 2015 |
| Yane | roku6185 | libSDL (portable), testing under Linux | 2015 | Announcement |
| MahNES | HLorenzi | Win32 | 2015 | Announcement |
| phibiaNES | nIghtorius | SDL / Win32 | 2015 | Announcement |
| nesalizer | Ulfalizer | libSDL (portable), tested on Linux | 2016 |
| EduNes | thomson | SDL2 | 2016 | Announcement |
| MacFC | T.Aoyama | Classic Mac OS, Mac OS X | 2016 |
| fixNES | FIX94 | C, Win32, Linux | 2020 |
| NESizm | tswilliamson | C++, Casio Prizm graphics calculators | 2021 |
| vbNES | mikechambers84 | Visual Basic 6 | 2021 |
| Retro Imitator | JRoatch | C, SDL1, Libretro | 2025 | Announcement, not a serious emulator, just an imitation |

## See also
- Releasing on modern platforms

# Nerdtracker player in NESASM

Source: https://www.nesdev.org/wiki/Nerdtracker_player_in_NESASM

```text
   .inesprg 2
   .ineschr 0
   .inesmir 0
   .inesmap 0

   .bank 1
   .org $FFFA
   .dw nmi
   .dw reset
   .dw irq

init = $8083
play = $8080
load = $8000

   .bank 0

   .org $8000
   .incbin "song.nsf"

reset:

    lda #0 ; song 0
    ldx #0 ; NTSC speed
    jsr init

   lda #%10000000
   sta $2000 ; <- enable play after init

loop:
   jmp loop

nmi:
    jsr play
irq:
    rti

```
