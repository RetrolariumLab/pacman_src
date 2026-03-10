# docs

# FDS disk format

Source: https://www.nesdev.org/wiki/FDS_disk_format

The Famicom Disk Systemuses disks that are a modified version of Mitsumi Quick Disk hardware, with a custom data format stored on the disk.

Each side can hold more than 64KB of data.

For archive and emulation, dumps of these disks are often preserved using the FDS file format(.FDS).

## FDS Disk Side format

Each disk side must be structured into block as follows :

1, 2, 3, 4, 3, 4, ...., 3, 4

The 3, 4 pattern should be repeated once per file present on the disk.

Blocks type 1 and 2 represent information about the disk and how many files it has, and each block type 3 and 4 pair represents a single file. See Block formatbelow.

### Gaps

Physically on the disk, there are "gaps" of 0 recorded between blocks and before the start of the disk. Length of the gaps are as follows:
- Before the start of the disk : At least 26150 bits, 28300 typical.
- Gap between blocks : At least 480 bits, 976 bits typical.

Gaps are teminated by a single '1' bit. In terms of bytes, it would be $80, as the data is stored in little endian format.

### CRCs

At the end of each block, a 16-bit CRC is stored. This CRC is not calculated by the CPU executing the BIOS code, but by the RP2C33handling the disk drive signals. It will automatically set $4030.D4 = 1 (leading to error code 27) if a block's CRC value does not match the calculated one during loading.

The CRC algorithm used is the common CRC-16/KERMITalgorithm. The '1' bit at the end of the gap is included in the calculation.

### True disk capacity

The commonly used FDS file formatis limited to 65500 bytes per side and does not contain CRCs or gaps. The QD file formatobserved in rereleases on Nintendo platforms is limited to 65536 bytes per side and contains CRCs, but no gaps.

The actual disk capacity is somewhat larger, and there are a few variant disk formats that may have even more capacity.

## Block format

### Disk info block (block 1)

| Offset | Length (bytes) | Description | Details |
| $00 | 1 | Block code | Raw byte: $01 |

| $01 | 14 | Disk verification | Literal ASCII string: *NINTENDO-HVC*Used by BIOS to verify legitimate disk image |
| $0F | 1 | Licensee code | See Licensee codes |
| $10 | 3 | Game name | 3-letter ASCII code per game (e.g. ZEL for The Legend of Zelda) |

| $13 | 1 | Game type | $20 = " " — Normal disk$45 = "E" — Event (e.g. Japanese national DiskFax tournaments)$4A = "J" — Unknown. May indicate Family Computer Network Adapter$52 = "R" — Reduction in price via advertising |
| $14 | 1 | Game version | Starts at $00, increments per revision |
| $15 | 1 | Side number | $00 = Side A, $01 = Side B. Single-sided disks use $00 |
| $16 | 1 | Disk number | First disk is $00, second is $01, etc. |
| $17 | 1 | Disk type (FMC) | $01 for FMC blue-disk releases, and $00 otherwise [1] |
| $18 | 1 | Unknown | $00 in all known games |
| $19 | 1 | Boot read file code | Refers to the file code/file number to load upon boot/start-up |
| $1A | 5 | Unknown | Raw bytes: $FF $FF $FF $FF $FF |
| $1F | 3 | Manufacturing date | See Date format |
| $22 | 1 | Country code | $49 = Japan |
| $23 | 1 | Unknown | Raw byte: $61. Speculative: Region code? |
| $24 | 1 | Unknown | Raw byte: $00. Speculative: Location/site? |
| $25 | 2 | Unknown | Raw bytes: $00 $02 |
| $27 | 5 | Unknown | Speculative: some kind of game information representation? |

| $2C | 3 | "Rewritten disk" date | See Date format. It's speculated this refers to the date the disk was formatted and rewritten by something like a Disk Writer kiosk.In the case of an original (non-copied) disk, this should be the same as Manufacturing date |
| $2F | 1 | Unknown |  |
| $30 | 1 | Unknown | Raw byte: $80 |
| $31 | 2 | Disk Writer serial number |  |
| $33 | 1 | Unknown | Raw byte: $07 |
| $34 | 1 | Disk rewrite count | Value stored in BCD format. $00 = Original (no copies). |
| $35 | 1 | Actual disk side | $00 = Side A, $01 = Side B |
| $36 | 1 | Disk type (other) | $00 = yellow disk, $FF = blue disk, $FE = prototype, sample, or internal-use (white or pink) disk. Some prototype disks have been observed with value $00, but this may indicate the field was simply not filled in. |
| $37 | 1 | Disk version | Unknown how this differs from game version ($14). Disk version numbers indicate different software revisions. Speculation is that disk version incremented with each disk received from a licensee. |
| $38 | 2 | CRC | (Omitted from .FDS files) |

The *NINTENDO-HVC* string, stored in ASCII, proves that this is a FDS disk. If the string doesn't match, the BIOS will refuse to read the disk further.

If the FDS is started with a disk whose side number and disk number aren't both $00, it will be prompted to insert the first disk side. However, some games make this number $00, even for the second disk to make it bootable too.

All files with IDs smaller or equals to the boot read file code will be loaded when the game is booting.

#### Date format

All bytes are stored in BCD format, in order of year, month, and day. The year is usually represented as the 1-indexed number of years since the start of the current Japanese calendarera, either the Shōwa era (1926) or Heisei era (1989). Values observed are $61-63 for 1986-1988 and $01-03 for 1989-1991. Disk Writer kiosks continued to use Shōwa era dates beyond the end of the Shōwa era, so disks written by the service up to its discontinuation in 2003 may have year values as high as $78.

A small number of games used the last two digits of the current year instead of a Japanese calendar date. Values observed are $85-$86 for 1985-1986.

### File amount block (block 2)

This block contains the total number of files recorded on disk.

| Offset | Length (bytes) | Description | Details |
| $00 | 1 | Block code | Raw byte: $02 |
| $01 | 1 | File Amount |  |
| $02 | 2 | CRC | (Omitted from .FDS files) |

More files might exist on the disk, but the BIOS load routine will ignore them, those files are called "hidden" files. Some games have a simple copy protection this way: They have their own loading routine similar to the one from the BIOS but hard-code the file amount to a higher number, which will allow for loading hidden files. This also allows the game to load faster because the BIOS will stop reading the disk after the last non-hidden file.

### File header block (block 3)

This block stores metadata for the file data block which follows it. Because the BIOS has to manually seek through the disk one byte at a time, it relies on the header block fields to correctly load or skip file data blocks.

| Offset | Length (bytes) | Description | Details |
| $00 | 1 | Block code | Raw byte: $03 |
| $01 | 1 | File Number |  |
| $02 | 1 | File ID | The ID specified at disk-read function call. |
| $03 | 8 | File Name | Typically in uppercase ASCII. |
| $0B | 2 | File Address | 16-bit little-endian. The destination address when loading. |
| $0D | 2 | File Size | 16-bit little-endian. |

| $0F | 1 | File Type | 0: Program (PRG-RAM)1: Character (CHR-RAM)2: Nametable (VRAM) |
| $10 | 2 | CRC | (Omitted from .FDS files) |

File Numbers are generally in increasing order, first file is 0. The BIOS does not use file Numbers during reads, and file Numbers written when calling AppendFile/WriteFile are manually counted from the first file.

File IDs can be freely assigned, and this is the number which will decide which file is loaded from the disk (instead of the file number). For example, the parameter disks for Quick Hunter uses identical file Numbers for everything except the first file and only distinguishes them by file IDs. A file ID smaller or equal to than the boot read file code means the file is a boot file, and will be loaded on first start up.

The BIOS only writes to the PPU when the file type is not equal to 0, so types 2 and above are functionally identical to type 1.

### File data block (block 4)

This block stores the actual file data.

| Offset | Length (bytes) | Description | Details |
| $00 | 1 | Block code | Raw byte: $04 |
| $01 | -- | File data |  |
| -- | 2 | CRC | (Omitted from .FDS files) |

### Test data block (block 5)

| Offset | Length (bytes) | Description | Details |
| $00 | 1 | Block code | Raw byte: $05 |
| $01 | -- | Test data | Repeating sequence of $6D, $B6, $DB to fill the disk side. |
| -- | 2 | CRC | (Omitted from .FDS files) |

This block type and fragments of its data has been observed in retail disks. It appears to be test data used during the disk formatting process. FMC Disk Card Checker is capable of writing and verifying this block.

## Non-standard disk formats

Because the disk format is only enforced in software by the BIOS disk I/O routines, custom formats are possible through the use of low-level disk I/O routines.

Some unlicensed disks have been observed to use non-standard formats, often as a means of copy-protection:
- Kosodate Gokko stores its main program without any block indicator and loads it using the BIOS' disk IRQ handler. (data is prefixed with a $12 byte)
- Quick Hunter uses a block type of 0 to store its encrypted main program. (data is XORed with $C9) Note that common dumps of this disk lack the needed 0 byte.
- Graphic Editor Hokusai and Jingorou use a custom format (interleaved + encrypted PRG/CHR data) with fake file header/data blocks for their main programs.
- Game Doctor/Magic Card devices switch in a replacement BIOS to load custom disk formats.
  - Block type 5 is used by some Magic Card 1M/2M/4M disks to store trainer data.

## See also
- FDS file format( .FDS )
- QD file format( .QD )
- FDS technical reference.txtby Brad Taylor
- Enri's Famicom Disk System page(Japanese)
- Enri's Famicom Disk System page(Japanese) (old/outdated)
- Fantasy's FDS Maniacs page(Japanese). Technical information is in the ディスクシステム資料室section.
- FDS Study sitevia archive.org (Japanese). The FDSStudy program can still be found here.
- fds-nori.txt- FDS reference in Japanese by Nori
- Forum post: .fds format: Can checksums be heuristically detected? - Includes a CRC implementation in C.
- Forum thread: Block type 5 in non-Game-Doctor FDS disks
- Forum thread: Copy protection methods on FDS disks

## References
- ↑FamicomWorld:FMC and FSC product codes

# FDS file format

Source: https://www.nesdev.org/wiki/FDS_file_format

fwNES was an NES emulatordeveloped by Fan Wan Yang and Shu Kondo. Its most lasting contribution to the NES scene was its disk image file format, an image of the Quick Disk media.

## fwNES FDS file format

The FDS format (filename suffix `.fds `) is a way to store Famicom Disk Systemdisk data. It consists of the following sections, in order:
- Header (16 bytes), sometimes omitted
- Disk data (65500 * x bytes)

The format of the header is as follows:

| Bytes | Description |
| 0-3 | Constant $46 $44 $53 $1A ("FDS" followed by MS-DOS end-of-file) |
| 4 | Number of disk sides |
| 5-15 | Zero filled padding |

Some .FDS images may omit the header .

### Disk data

The disk data follows the FDS disk format, but gaps and CRCs are not included in the .FDS image.

Most games are an even number of sides. Ports from NROM were one side. No commercial FDS game had an odd number of sides greater than 1. Disk sides comes in the following order:
- Disk 1 Side A
- Disk 1 Side B
- Disk 2 Side A
- Disk 2 Side B
- etc...

After the last file block, fill a side with all 0 so that the disk side reaches exactly 65500 bytes.

## See also
- QD file format( .QD )

# NSFDRV

Source: https://www.nesdev.org/wiki/NSFDRV

NSFDRV is an 8-byte header ID in the ROM of an NSFfile used to identify the sound driver used.

## Usage and applications
- NSF players can use this ID to identify old sound drivers developed with inaccurate emulation, and therefore patch the drivers accordingly.
- Authors can assert that their NSF is original (i.e. NSF is not ripped from a ROM).
- In sound driver bug reporting, the developer can use this ID to identify the driver version.

## File Format

The tag consists of 8 bytes on the actual program data of the NSF file.

Since the program data follows immediately after the NSF header, these 8 bytes are defined as follows:

```text
Offset          Bytes   Function
-------------------------------------------------
$0000 - $007F   128     NSF Header
$0080 - $0085   6       Sound driver ID
$0086           1       Major version number
$0087           1       Minor version number

```

## List of NSFDRV sound driver IDs
- OFGS ( http://offgao.no-ip.org/ofgs/)

```text
ASCII  :      "OFGS  "
Binary :      $4F $46 $47 $53 $20 $20

```
- FamiTracker NSF Driver ( http://www.famitracker.com)

```text
ASCII  :      "FTDRV "
Binary :      $46 $54 $44 $52 $56 $20

```
- NES Sound Driver & Library ( https://github.com/Shaw02/nsdlib)

```text
ASCII  :      "NSDL  "
Binary :      $4E $53 $44 $4C $20 $20

```

A blank NSFDRV ID may be used for sound drivers under development.

```text
ASCII  :      "      "
Binary :      $20 $20 $20 $20 $20 $20

```

## Player implementations

The following players implement NSFDRV identification:
- TNS-HFC4
- hoot

# QD

Source: https://www.nesdev.org/wiki/QD_file_format

The QD file format is an image of Quick Disk media and is the format used for FDSgames in emulators by Nintendo.

## QD file format

The QD format (filename suffix `.qd `) is a way to store Famicom Disk Systemdisk data. It consists of:
- Disk data ( 65536 * x bytes)

### Disk data

The disk data follows the FDS disk format, and includes CRCs after each block. Gaps are not included in the .QD image.

Most games are an even number of sides. Ports from NROM were one side. No commercial FDS game had an odd number of sides greater than 1. Disk sides come in the following order:
- Disk 1 Side A
- Disk 1 Side B
- Disk 2 Side A
- Disk 2 Side B
- etc...

After the CRC value of the last file block, fill a side with all 0 so that the disk side reaches exactly 65536 bytes.

## Differences from FDS file format

The QD format has significant differences from the popular FDS file format( `.fds `):
- No header. This means that the number of disk sides must always be calculated based on the file size.
- 65536 bytes per disk side instead of 65500 bytes per disk side.
- CRC values are included after each file block. Emulators should treat these as bytes that can always be read from/written to the disk, regardless of if they are being used for CRC calculation/verification.
  - Some Virtual Console releases are known to have patched the .QD image without updating the CRCs, so images extracted from these may trigger unexpected load errors. ( BIOS error code= 27)

## See also
- TNES- 3DS Virtual Console ROM format, which can also encapsulate .QD images.
- FDS file format( .FDS )
- GitHub Gist- Python script to convert between QD/FDS formats.

## References
- FDS .qd format

# Serial Cable Routines

Source: https://www.nesdev.org/wiki/Serial_Cable_Routines

This page covers implementation of bit-banged serial read/write routines for use with a serial cable. It's meant if you're implementing your own, or want to understand how the library routines work. Serial

## Encoding

Serial data bytes are transferred as a series of bits followed by an idle state until the next byte. Each bit lasts the same amount of time. An 8-bit byte is transferred as 10 bits, with the first and last bits serving as markers of the start and end of the byte. The start bit is encoded as a 0, and the stop bit and idle state as a 1. Data bit 0 is first.

```text
-----       ----- ----- ----- ----- ----- ----- ----- ----- ---------
     \     /     X     X     X     X     X     X     X     /
      ----- ----- ----- ----- ----- ----- ----- ----- -----
      start   0     1     2     3     4     5     6     7   stop

```

For example, the byte 00110001 ($31) is encoded as

```text
--------       -----                   -----------             ----------
        \     /     \                 /           \           /
         -----       -----------------             -----------
           0     1     0     0     0     1     1     0     0     1

```

## Decoding

To decode a byte, the receiver must read each bit, ideally in its center:

```text
--------       ----- ----- ----- ----- ----- ----- ----- ----- ---------
        \     /     X     X     X     X     X     X     X     /
         ----- ----- ----- ----- ----- ----- ----- ----- -----
                 *     *     *     *     *     *     *     *

```

The transmitter and receiver each have their own clock to time the bits, and these might differ. So the receiver might slowly shift towards one edge due to timing differences. If it weren't aiming for the center, it would be more likely to hit an edge. At that point, it might read an adjacent bit.

The receiver must re-synchronize on each byte because its clock can't be accurate enough stay in sync with the transmitter's over long periods. The beginning of the start bit provides a known transition it can wait for. Once this occurs, it knows a byte is beginning, and that it should wait 1.5 bits before reading bit 0 (one bit to skip the start bit, and a half bit to get to the middle of bit 0).

```text
--------       ----- ----- ----- ----- ----- ----- ----- ----- ---------
        \     /     X     X     X     X     X     X     X     /
         ----- ----- ----- ----- ----- ----- ----- ----- -----
                 *     *     *     *     *     *     *     *
        ^     ^  ^
      edge    1  .5

```

Above the receiver waits for the edge, then one bit, then a half bit to read bit 0.

## Stop bit/idle

The idle state between bytes is also a 1, so it's as if the stop bit lasts until the next start bit. It can last any amount longer than a normal bit, and doesn't have to be a multiple of a bit long. That is, two bytes may be back-to-back, have a stop bit that's slightly longer than normal, or have one that's much longer than normal:

```text
--- ----- ----- ----- ----- ----- -----       ----- ----- ----- ----- -----
   X     X     X     X     X     /     \     X     X     X     X     X
--- ----- ----- ----- ----- -----       ----- ----- ----- ----- ----- -----
      3     4     5     6     7   stop  start   0     1    2      3     4

```

```text
--- ----- ----- ----- ----- ----- -------       ----- ----- ----- ----- ---
   X     X     X     X     X     /       \     X     X     X     X     X
--- ----- ----- ----- ----- -----         ----- ----- ----- ----- ----- ---
      3     4     5     6     7    stop   start   0     1    2      3

```

```text
--- ----- ----- ----- ----- ----- -------------------------------       ---
   X     X     X     X     X     /                               \     X
--- ----- ----- ----- ----- -----                                 ----- ---
      3     4     5     6     7   stop          idle              start

```
Implementation

The following implementation is for clarity rather than usability or efficiency.

## Timing

A serial rate of 57600 bits per second is the most useful on the NES. This gives the following timings:

|  | NTSC | PAL |
| CPU Clock | 1789773Hz | 1662607Hz |
| Clocks per bit | 31.07 | 28.86 |
| Rounded clocks | 31 | 29 |
| Error | -0.2% | +0.5% |

Rounding to 31 (29 PAL) cycles per bit gives less than half a percent timing error, well within RS-232 tolerances. This allows the code to be written as simple loops.

## Initialization

Before transmitting or receiving for the first time, write $03 to $4016 and delay:

```text
        ldx #$03
        stx $4016
        ldx #350/5      ; delay 350 cycles, more than 10 bit lengths on NTSC
wait:   dex
        bne wait

```

This puts an idle state on the output lines so that the first byte sent will not be corrupt. It also prevents Famicom or other controllers also connected from interfering with receiving (as long as the A button isn't being pressed).

## Transmit

To transmit a byte, output each of the 10 bits for 31 cycles each (29 for PAL).

|  | NTSC | PAL |
| Output start bit (0) |
| Delay | 31 | 29 |
| Output bit 0 |
| Delay | 31 | 29 |
| ... |
| Output bit 7 |
| Delay | 31 | 29 |

```text
        clc             ; start bit
        ldx #10
loop:   tay
        lda #$ff        ; replicate carry in low two bits and output
        adc #0
        eor #$ff
        and #%11
        sta $4016
        tya
        sec             ; stop bit
        ror a           ; next bit into carry, stop bit into shift reg
        nop             ; delay 6 cycles
        nop
        nop             ; remove for PAL timing
        dex
        bne loop

```

Remove the indicated NOP for PAL timing.

This outputs the start bit (0), 8 data bits, and the stop bit (1), each lasting 31 cycles. Note how it only outputs on bits 0 and 1 of $4016, and clears the others. Some serial connections may be using bit 1 in the future, so a routine should write to both bits if possible. Other devices may be using higher bits, so these should always be clear.

## Receive

The NES inverts serial input, but not output, so when receiving data, things are inverted: a start bit is 1, a stop bit 0, and data bits are inverted.

To receive a byte, wait for the start bit, delay 1.5 bits = 46.5 cycles (42.5 for PAL), read bit 0, delay 31 cycles (29 for PAL), read bit 1, etc.

|  | NTSC | PAL |
| Wait for beginning of start bit |
| Delay | 46.5 | 42.5 |
| Input bit 0 |
| Delay | 31 | 29 |
| ... |
| Input bit 7 |

```text
        lda #%10111 ; wait for start bit
start:  bit $4017
        beq start
                    ; LDA $4017 here would be 9.5 cycles after start bit
        nop         ; delay 17 cycles
        nop
        nop
        nop
        nop
        pha
        pla
        ldx #8      ; read 8 data bits
        nop         ; remove for PAL timing
loop:   nop         ; remove for PAL timing
        nop         ; delay 10 cycles
        nop
        nop
        nop
        nop
        tay
        lda #%10111 ; mask input lines and put into carry
        and $4017
        cmp #1
        tya
        ror a       ; shift into output byte
        dex
        bne loop
        eor #$FF    ; invert final byte

```

Remove both indicated NOPs for PAL timing.

The receive loop masks the bits serial data might come in on, and sets the carry if any of these is not zero. It shifts this bit into the shift register, and un-inverts everything in the end.

The start bit loop waits for the beginning of the start bit. It reads $4017 every 7 cycles:

```text
bit $4017 ; 4 read
beq start ; 3
bit $4017 ; 4 read
beq start ; 2 (not taken)
nop
...

```

The start bit could occur anywhere between two of these reads, so the next read to notice it will be seeing it from 0 to almost 7 cycles later. It might read just as the start bit begins and see it immediately, or it might read just before it begins and not see it until 7 cycles later when it reads again. On average it thus notices it 3.5 cycles after it began. So we must add 3.5 cycles to our calculations of how long it's been since the start bit began. This means that if we put an LDA $4017 just after the BEQ, it would read on average 9.5 cycles after the start bit began (3.5+4+2):

```text
bit $4017 ; 4 read
beq start ; 3
bit $4017 ; 4 read
beq start ; 2 (not taken)
lda $4017 ; 4 reads 9.5 cycles on average after start bit began

```

## Timing accuracy

The 31/29 and 46.5/42.5 delays give the following timings, in cycles relative to the beginning of the start bit. The actual NTSC/PAL time is listed, then the ideal time, and the error (difference).

Transmit timing is only a quarter of a percent off for NTSC and half a percent for PAL. Listed is the starting time for each bit.

| Bit | NTSC | Ideal | Error | PAL | Ideal | Error |
| Start | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |
| 0 | 31.0 | 31.1 | -0.1 | 29.0 | 28.9 | 0.1 |
| 1 | 62.0 | 62.1 | -0.1 | 58.0 | 57.7 | 0.3 |
| 2 | 93.0 | 93.2 | -0.2 | 87.0 | 86.6 | 0.4 |
| 3 | 124.0 | 124.3 | -0.3 | 116.0 | 115.5 | 0.5 |
| 4 | 155.0 | 155.4 | -0.4 | 145.0 | 144.3 | 0.7 |
| 5 | 186.0 | 186.4 | -0.4 | 174.0 | 173.2 | 0.8 |
| 6 | 217.0 | 217.5 | -0.5 | 203.0 | 202.1 | 0.9 |
| 7 | 248.0 | 248.6 | -0.6 | 232.0 | 230.9 | 1.1 |
| Stop | 279.0 | 279.7 | -0.7 | 261.0 | 259.8 | 1.2 |

Receive timing is good on average, though all the times can be +/- 3.5 cycles shifted due to the start bit loop. Listed is the times the routine reads each bit in the middle, along with the ideal and error.

| Bit | NTSC | Ideal | Error | PAL | Ideal | Error |
| 0 | 46.5 | 46.6 | -0.1 | 42.5 | 43.3 | -0.8 |
| 1 | 77.5 | 77.7 | -0.2 | 71.5 | 72.2 | -0.7 |
| 2 | 108.5 | 108.8 | -0.3 | 100.5 | 101.0 | -0.5 |
| 3 | 139.5 | 139.8 | -0.3 | 129.5 | 129.9 | -0.4 |
| 4 | 170.5 | 170.9 | -0.4 | 158.5 | 158.8 | -0.3 |
| 5 | 201.5 | 202.0 | -0.5 | 187.5 | 187.6 | -0.1 |
| 6 | 232.5 | 233.0 | -0.5 | 216.5 | 216.5 | 0.0 |
| 7 | 263.5 | 264.1 | -0.6 | 245.5 | 245.3 | 0.2 |

In the above tables, the best we can do in software is to keep the error within -0.5 to +0.5 cycles, so we can't improve on most of the above timings. To correct the rest, we'd do the following. Transmit, NTSC: extra cycle during bit 6, PAL: one fewer cycle during bit 3. Receive, NTSC: extra cycle after bit 5, PAL: extra cycle before bit 0, one fewer cycle after bit 2. This requires unrolled loops so these special actions can be done on particular iterations.

# Serial Cable Specification

Source: https://www.nesdev.org/wiki/Serial_Cable_Specification

The RS-232 serial protocol allows two devices to communicate over just a few wires. This page describes a serial cable connection scheme for the NES and Famicom that can use the second controller port or expansion port. Cable connections

Each of the two serial signals may be connected to any one of the listed pins.

| Serial | NES 2nd controller | Famicom expansion port | NES expansion port |
| TX | D0 (data) or D4 | 2nd controller D4 | 2nd controller D2 |
| RX & /CTS | OUT0 (strobe) | OUT0 | OUT0 |

TX, RX, and /CTS are TTL-level signals, not RS-232-level signals. TX and RX use +5V for Mark, 0V for Space. Do not connect the NES directly to RS-232; see Serial Cable Constructionfor proper connection.

## One-way cable

A one-way cable connects TX to the second controller D0 or D4. On the NES, D0 and D4 are available on the second controller port. On the NES and Famicom, second controller D4 is available on the expansion port.

Any other devices connected to D0, D1, D2 or D4 must drive the line high whenever OUT0 (strobe) is high, as is done when nothing is connected or a controller/Zapper is connected and no buttons are being held.

## Two-way cable

A two-way cable additionally connects OUT0 to RX & /CTS. On the NES, OUT0 (strobe) is available on the second controller port. On the NES and Famicom, OUT0 is available on the expansion port. Software interface

The TX line is available inverted as the logical OR of bits D0, D1, D2, and D4 of $4017. If zero, TX is high (Mark state). Bits D1 and D2 are included because future serial devices might connect to them.

The RX & /CTS pair is controlled by $4016 D0. /CTS might not be supported by a given cable, in which case flow control can't be done. Software should write zero bits for D2, D3, and D4, in case they are used for other things. Also, at some point D1 may be used by some devices for serial output (since it avoids junk bytes when reading the controllers), so software should output serial data on bits 0 and 1 of $4016. Port pinouts

D0 (data) and D4 are inputs for second controller ($4017). OUT0 (strobe) is from the CPU ($4016). For clarity, unused pins are not numbered or labeled.

## NES controller port

```text
      _
 GND |1\
     |.5| +5V
OUT0 |3.|
  D0 |47| D4
     '--'

```

## Famicom expansion port

Male connector.

```text
  GND          D4
-----------------------------------
\  1   .   .   4   .   .   .   .  /
 \                               /
  \  .   .   .  12   .   .  15  /
   `---------------------------'
               OUT0        +5V

```

## NES expansion port

```text
          -------
         |  ___  |
     +5V | 1  48 | +5V
     GND | 2  47 | GND
         | [   ] |
         | [   ] |
         | [   ] |
         | [  43 | OUT0
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
(back)   | [   ] |   (front of NES)
         | [   ] |
         | [   ] |
      D2 | 15  ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         | [   ] |
         |  ---  |
          -------

```
Design rationale

TX connected to four bits: The NES controller port exposes D0, D3, and D4. The expansion ports of NES and Famicom expose D0-D4. The second Famicom controller is hardwired to D0, so we need something in addition to D0. D3 and D4 are available on both, but many NES controller cables don't connect either one. D2 is available on both, but it requires connecting to the NES expansion port, for which the connector is rare/non-existent. External Famicom controllers typically use D1, and might not connect to other data bits. So we use D0, D1, D2, and D4.

D0 allows use of the common NES controller cable. D1 allows use with common Famicom external controller cables. D4 allows modification of a NES extension cable to pass through D0 to a controller, and connect serial at the same time. The Zapper connects to D3 and D4 and has the trigger connected to D4, so it won't generate any false data unless pressed. D2 allows connection via the expansion connector, without disturbing any controllers on NES/Famicom, even the Zapper.

In software, it's simplest to support just D0, since it can be shifted into carry easily. Once it must support multiple bits, any combination of bits becomes just as easy as any other, since it's set by a bit mask to an AND instruction.

Active-high TX and RX: A serial cable should be as easy to construct as possible. The FTDI TTL-232R USB-to-RS-232 cable outputs TTL levels, allowing construction of a serial cable with no soldering, just splicing it to a NES controller cable. The MAX232 also uses these levels. Further, simple transistor inverters match these as well. Since RX and /CTS are connected together, and CTS is normally non-inverted, we get the inverted /CTS.

# StudyBox file format

Source: https://www.nesdev.org/wiki/StudyBox_file_format

The StudyBox file format contains the mono audio and decoded data of a single cassette tape for the Fukutake StudyBoxin a chunked format. The file extension is ".studybox". It starts with the following file header:

```text
Offset Length          Meaning
$0     char[4]         "STBX" identifier
$4     uint32_le       Length of all following fields ($00000004)
$8     uint32_le       Version number *0x100 (0x100 =1.00)

```

The header must be followed by decoded PAGE data chunks. A page chunk has the following format:

```text
Offset Length          Meaning
$0     char[4]         "PAGE" identifier
$4     uint32_le       Length of all following fields
$8     uint32_le       Audio offset in samples into the audio chunk at which the lead-in section (0-bits followed by a single 1-bit) originally began
$C     uint32_le       Audio offset in samples into the audio chunk at which the data originally began
$10    uint8[]         Decoded data for this page (size varies)

```

Each page chunk's audio offset must be greater than the previous page chunk's audio offset.

The page chunks must be followed by an AUDI chunk representing the audio portion of the cassette tape:

```text
Offset Length          Meaning
$0     char[4]         "AUDI" identifier
$4     uint32_le       Length of all following fields
$8     uint32_le       File type
                       $0: .WAV
                       $1: .flac
                       $2: .ogg
                       $3: .mp3
$C     uint8[]         Embedded audio file

```

The audio chunk must come after the page chunks. Since the "Audio offset" field in the page chunks refer to samples in this audio, trimming the audio or changing the sampling rate will require changing the audio offsets of all the page chunks.

# Super Magic Card file format

Source: https://www.nesdev.org/wiki/Super_Magic_Card_file_format

The Front Fareast Super Magic Cardcan load games and real-time save states from 3.5" MS-DOS FAT12 floppy disks in a custom file format that is also known just as the "FFE format" by fwNES and uCON64. Similar to iNES, it contains a 512-byte header describing the game's mapper and size as well as trainer, PRG and CHR data. Unlike iNES, it only supports the mappers that the Super Magic Carditself supports.

Format of the 512-byte header:

```text
+$0   8 bytes   Doctor header
+$8   2 bytes   Signature $AA $BB
+$A   1 byte    File type, 0=Game, 1=Realtime save state
+$B   501 bytes Unused
-----
$200

```

In the case of "Game" files, the 512-byte header is followed by
- 512 bytes of trainer data if the Doctor Header file's byte $0 bit 6 was set;
- PRG data, size determined by
  - Doctor header byte $3 times 8192 bytes if Doctor header byte $7=$AA (i.e. a Super Magic Card game);
  - Doctor header byte $0 bit 5 clear=128 KiB, set=256 KiB bytes if Doctor header byte 0 bits 4 or 5 are set (i.e. a Magic Card 4M game);
  - Doctor header byte $1 bits 5-7 otherwise (i.e. a Magic Card 1M or 2M game):

```text
Byte $1 bits 5-7   PRG size
 0,4               128 KiB
 1-3               256 KiB
 5-7               32 KiB

```
- CHR data, size determined by
  - Doctor header byte $4 times 8192 bytes if Doctor header byte $7=$AA (i.e. a Super Magic Card game);
  - Doctor header byte $0 bit 4 clear=128 KiB, set=256 KiB bytes if Doctor header byte 0 bits 4 or 5 are set (i.e. a Magic Card 4M game);
  - Doctor header byte $1 bits 5-7 otherwise (i.e. a Magic Card 1M or 2M game):

```text
Byte $1 bits 5-7   CHR size
 0-3               0 KiB
 4-5               32 KiB
 6                 16 KiB
 7                 8 KiB

```

The SMC Game file format is supported (to varying degrees) by:
- the Super Magic Card's BIOS when using 3.5" MS-DOS FAT12 floppy disks;
- Front Fareast's "VGS.EXE" utility to remotely control the Super Magic Card from an MS-DOS PC;
- uCON64;
- NintendulatorNRS;
- fwNES.

# .pal

Source: https://www.nesdev.org/wiki/.pal

.pal is an extension used by palette files for NES emulators. Palette files are required for emulation of the RGB PPUs of the VS Unisystem, PlayChoice 10, and Famicom Titler systems. Before NTSC videowas fully understood, emulators also used palette files to translate the PPU's color valuesinto sRGB values for the PC display.

Most palette files used by NES emulators are 192 bytes in size, consisting of 64 3-byte entries, one for each of 64 NES color values.

Each entry consists of three unsigned 8-bit bytes, in this order:
- red intensity
- green intensity
- blue intensity

Intensity is most commonly ranged from 0 (black) to 255 (full intensity), presuming the sRGBcolor space used by most monitors.

Most emulators will ignore any entries past the first 64, but an optional extension of the .pal format (currently only known to be supported by Nintendulator 0.965 and later, and FCEUX 2.3.0) lengthens the file to 1536 bytes in order to store each palette value when colour (de-)emphasis bits are applied. This allows customization of the emphasis behaviour, and is particularly useful for representing the alternative emphasis behaviour of the RGB PPU used in the Vs. Systemand PlayChoice.

## See Also
- PPU palettes

## External links
- VGA Palette on ModdingWiki
- Editing custom NES palettes in Linuxinstructions on editing .pal files in GIMP

# PC10 ROM-Images

Source: https://www.nesdev.org/wiki/PC10_ROM-Images

Playchoice 10 ROM images can be stored in two formats:

## iNES Format

PC10 games in iNESformat are indicated by Bit1 of Byte 7 of the iNES header. If the flag is set, then the file should contain some additional entries after the PRG ROM and CHR ROM areas:
- 8Kbyte INST ROM (containing data and Z80 code for instruction screens)
- 16 bytes RP5H01 PROM Data output (needed to decrypt the INST ROM)
- 16 bytes RP5H01 PROM CounterOut output (needed to decrypt the INST ROM) (usually constant: 00,00,00,00,FF,FF,FF,FF,00,00,00,00,FF,FF,FF,FF)

The two required PROM sections are missing in older ROM images. A tool for upgrading such incomplete dumps can be found at http://problemkaputt.de/pc10make.zip

Note: Some very old ROM images don't have the PC10 flag set in the header, and, instead, they declare the 8K INST ROM as an additional CHR ROM bank.

## MAME Format

Instead of using a single ROM image file, MAME stores all ROM, EPROM, and PROM chips in separate files.

The PROM data is typically stored in a file called "security.prm". It contains only the 16 Data bytes (not the CounterOut bytes). All bits in the PROM file are inverted, and the bit ordering is reversed: bit0 (the first bit of the PROM's serial bitstream) is stored in bit7 of the 1st byte of the file).

## PC10 Emulators

The iNES format is used by no$nes. The MAME format is used by MAME.

# QD

Source: https://www.nesdev.org/wiki/QD

The QD file format is an image of Quick Disk media and is the format used for FDSgames in emulators by Nintendo.

## QD file format

The QD format (filename suffix `.qd `) is a way to store Famicom Disk Systemdisk data. It consists of:
- Disk data ( 65536 * x bytes)

### Disk data

The disk data follows the FDS disk format, and includes CRCs after each block. Gaps are not included in the .QD image.

Most games are an even number of sides. Ports from NROM were one side. No commercial FDS game had an odd number of sides greater than 1. Disk sides come in the following order:
- Disk 1 Side A
- Disk 1 Side B
- Disk 2 Side A
- Disk 2 Side B
- etc...

After the CRC value of the last file block, fill a side with all 0 so that the disk side reaches exactly 65536 bytes.

## Differences from FDS file format

The QD format has significant differences from the popular FDS file format( `.fds `):
- No header. This means that the number of disk sides must always be calculated based on the file size.
- 65536 bytes per disk side instead of 65500 bytes per disk side.
- CRC values are included after each file block. Emulators should treat these as bytes that can always be read from/written to the disk, regardless of if they are being used for CRC calculation/verification.
  - Some Virtual Console releases are known to have patched the .QD image without updating the CRCs, so images extracted from these may trigger unexpected load errors. ( BIOS error code= 27)

## See also
- TNES- 3DS Virtual Console ROM format, which can also encapsulate .QD images.
- FDS file format( .FDS )
- GitHub Gist- Python script to convert between QD/FDS formats.

## References
- FDS .qd format

# TNES

Source: https://www.nesdev.org/wiki/TNES

The TNES file format was discovered in Nintendo 3DS Virtual Console games. It fulfills much the same role as the iNESformat, but it can also encapsulate QDimages for FDSgames and avoids allegations of having misappropriated a format from the emulation scene.

## TNES Header Format

| Offset | Contents |
| 0-3 | "TNES" ($54 $4E $45 $53) |
| 4 | Mapper (TNES codes, not iNES codes) |
| 5 | PRG ROM size in 8192 byte units |
| 6 | CHR ROM size in 8192 byte units |
| 7 | WRAM (0 for none, 1 for 8192 bytes) |
| 8 | Mirroring (0 mapper-controlled; 1 horizontal; 2 vertical) |
| 9 | Battery (0 none; 1 battery present) |
| 10-11 | Used only for FDS images; purpose unknown, possibly side count |
| 12-15 | Zero |

### TNES Mapper Numbers

Mappernumbers differ, and Nintendo's own ASIC mappers have a contiguous block:

| TNES mapper | iNES mapper | Meaning | Notes |
| 0 | 0 | NROM |  |
| 1 | 1 | SxROM (MMC1) |  |
| 2 | 9 | PNROM (MMC2) |  |
| 3 | 4 | TxROM (MMC3) | And presumably HKROM (MMC6) |
| 4 | 10 | FxROM (MMC4) |  |
| 5 | 5 | ExROM (MMC5) |  |
| 6 | 2 | UxROM |  |
| 7 | 3 | CNROM |  |
| 9 | 7 | AxROM |  |
| 31 | 86 | Jaleco JF-13 |  |

| 100 |  | FDS | ROM image consists of a modified 8192 byte BIOS[1] followed by QD sides. Size bytes 5-9 are zero, but 10-11 are used. |

## References
- Based on TNES formatby einstein95, via TCRF forum post
- FDS .qd format
- ↑TCRF: FDS BIOS modifications in 3DS VC

# UNIF

Source: https://www.nesdev.org/wiki/UNIF

UNIF (Universal NES Image Format) is an alternative format for holding NES and Famicom ROM images.

Its motivation was to offer more description of the mapper board than the popular iNES 1.0format, but it suffered from other limiting constraints and a lack of popularity. The format is considered deprecated, replaced by the NES 2.0revision of the iNES format, which better addresses the issues it had hoped to solve.

There are a small number of game rips that currently only exist as UNIF.

## History

The originator of the UNIF format, Tennessee Carmel-Veilleux, publically abandoned the format in December of 2008, and had its website deleted.

Since 2011 the UNIF standard has been maintained as part of the libunif project, a library for loading and creating UNIF files.

UNIF is currently considered a deprecated standard. Further updates to UNIF are unlikely, and it is recommended that new games or rips requiring special mapper specifications use the NES 2.0format instead of attempting to extend UNIF.

## Format

The suggested file extension for UNIF is .unf or .unif .

("LE16" and "LE32" below denote little-endian 16/32-bit integers.)

UNIF images start with a 32-byte header:

| Offset | Length (bytes) | Value |
| 0 | 4 | "UNIF" |
| 4 | 4 | LE32, minimum version number required to parse all chunks in file |
| 8 | 24 | all nulls |

The header is followed by any number of Type+Length+Value blocks:

| Offset | Length (bytes) | Value |
| 0 | 4 | Type, varies, defined below |
| 4 | 4 | LE32, length |
| 8 | length | content encoding varies by type |

### Types

The following Types are known:

| Type | Length | Minimum version required | Encoding | Content meaning |
| MAPR | variable | 1 | null-terminated UTF-8 | A unique human-readable identifier specifying the exact hardware used; not an iNES mapper number, and not a full text description of the mapper; required |
| PRGn | variable, usually power of two | 4 | raw | the contents of the nth PRG ROM; at least PRG0 is required; n is in hexadecimal |
| CHRn | variable, usually power of two | 4 | raw | the contents of the nth CHR ROM |
| PCKn | 4 | 5 | LE32 | the CRC-32 of the nth PRG ROM |
| CCKn | 4 | 5 | LE32 | the CRC-32 of the nth CHR ROM |
| NAME | variable | 1 | null-terminated UTF-8 | the name of the game |
| WRTR | variable | unknown | null-terminated UTF-8 | unofficial, invalid. The name of the dumping software. Should be in a DINF chunk instead |
| READ | variable | 1 | null-terminated UTF-8 | comments about the game, especially licensing information for homebrew |

| Offset | Length (bytes) | Value |
| 0 | 100 | null-terminated UTF-8 dumper name |
| 100 | 1 | day-of-month of dump |
| 101 | 1 | month-of-year of dump |
| 102 | 2 | LE16, year of dump |
| 104 | 100 | null-terminated UTF-8 the name of the dumping software or mechanism |
TVCI 1 6 byte TV standard compatibility information-

| 0. | NTSC only |
| 1. | PAL only |
| 2. | compatible with both |
CTRL 1 7 byte Controllers usable by this game (bitmask)

| 1. | Standard controller |
| 2. | Zapper |
| 4. | R.O.B. |
| 8. | Arkanoid controller |
| 16. | Power Pad |
| 32. | Four Score |
| 64. | expansion (leave cleared) |
| 128. | expansion (leave cleared) |
BATR 1 5 byte Boolean specifying whether the RAM is battery-backed. VROR 1 5 byte "If this chunk is present, then the CHR-ROM area will be considered as RAM even if ROM is present." MIRR 1 5 byte What CIRAM A10 is connected to:

| 0. | PPU A11 (horizontal mirroring) |
| 1. | PPU A10 (vertical mirroring) |
| 2. | Ground (one-screen A) |
| 3. | Vcc (one-screen B) |
| 4. | Extra memory has been added (four-screen) |
| 5. | Mapper-controlled |

## Shortcomings

Prior to 2013, no encoding was specified for any of the fields; 7-bit-clean ASCII was assumed, making NAME inadequate for the vast majority of non-US games. In the first quarter of 2013, UTF-8 became the encoding.

Chunks can come in any order, so conventional patching tools cannot work without going through an "unpacked" intermediary stage.

MAPR chunks are nominally supposed to use the text on the PCB, such as "NES-SNROM". However, some games have no identifying text on the PCB at all. Other games have only symbols in Japaneseor Chinese. Sometimes the same PCBcan have different incompatible behavior, depending on how things are populated or what things are jumpered. The workaround has been to add extra text in the MAPR chunk (in the Crazy Climber case, "HVC-UNROM+74HC08").

There is no ability to specify PRG RAM outside of the MAPR chunk. Two games using VRC4 ( Gradius IIand Bio Miracle Bokutte Upa) use the exact same PCB, but the former adds 2KiB PRG RAM and the latter adds none.

For greater emulator compatibility, people sometimes use already-known-supported MAPR chunks to get something that's "close enough", rather than specifying a new MAPR for not-necessarily-identical behavior.

BATR chunks do not disambiguate which RAM is battery-backed, if more than one is present.

It's not clear exactly what VROR is supposed to mean—"Do not throw an error if this MAPR normally has CHR ROM but there are no CHR n chunks, just give me 8KiB of CHR RAM"? "All the data I gave you for CHR-ROM, that was actually RAM, make it writeable"? As such, Nestopia, Nintendulator, and FCEUX just ignore it.

CTRL chunks do not specify which controller should be plugged into which port, nor Famicom-only controllers, nor Super NES controllers plugged into a Famiclone or through an adapter (such as the 12-key controlleror the mouse).

There is no way to fully describe PlayChoice 10 or Vs. Systemgames.

## References
- libunif project on Github
- Last published version of the standard

## See also
- UNIF to NES 2.0 Mapping
