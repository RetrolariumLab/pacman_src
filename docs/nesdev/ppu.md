# ppu

# Don't hardcode OAM addresses

Source: https://www.nesdev.org/wiki/Don%27t_hardcode_OAM_addresses

To display sprites (or moving objects), a program builds a display list in a 256-byte page of CPU RAM, sometimes called "shadow OAM". Then the program copies it to OAM in the PPU during the next vertical blanking periodby writing the high byte of the display list's address to $4014. For example, if it places the display list at $0200-$02FF, it writes $02 to $4014.

Occasionally, programmers get the idea to define variables so as to hardcode the position of a particular actor's sprites in the display list, using code similar to the following:

```text
OAM = $0200  ; start of shadow OAM page

player_oam_base = OAM + $04      ; skip sprite 0
player_y = player_oam_base + $00
player_tile = player_oam_base + $01
player_palette = player_oam_base + $02
player_x = player_oam_base + $03

```

In all but the simplest cases, hardcoding OAM addresses of actors is an anti-pattern because it limits the ability to do several things:
- Separate the motion of the camera from motion of game objects
- Change the size of a cel later on, in case some cels need more sprites than others
- Draw a cel half-offscreen
- Reuse movement logic among multiple actor types
- Turn objectionable dropout when more than 8 sprites are briefly on a line into less objectionable flicker by varying from frame to frame which sprite appears earlier in OAM

(A "cel", also called a "metasprite", is a group of sprites that represent one frame of a character's animation.)

A better way:
- Keep separate variables for each actor's position in world space that are stored outside of the display list. Also keep variables for the camera's position.
- Each frame, initialize a variable denoting how many bytes of OAM have been filled so far. This would usually be 0 or 4; it would be 4 if sprite 0 is reserved for sprite 0 hit.
- Each frame, fill shadow OAM from start to finish based on the position of the actor, plus the position of the individual sprites within the actor's cel, minus the position of the camera.
- Replace the Y coordinates of unused sprites with $FF. (Any value below the bottom of the screen, at least $EF, will work.)

That way, you can perform flicker by varying the order in which actors are drawn during step 3. And if you skip drawing a sprite because it is offscreen, you can skip increasing the OAM used variable.

For example, ``player.s in nrom-templateuses a variable called `oam_used `to store an index into shadow OAM, separate `player_xhi `and `player_yhi `variables to store the position of the player character, `player_frame `to store which cel to use, and ``ppuclear.sdemonstrates filling the remainder of the display list after `oam_used `with $FF values.

# PPU

Source: https://www.nesdev.org/wiki/NES_PPU

The NES PPU, or Picture Processing Unit, generates a composite video signal with 240 lines of pixels, designed to be received by a television. When the Famicom chipset was designed in the early 1980s, it was considered quite an advanced 2D picture generator for video games.

It has its own address space, which typically contains 10 kilobytes of memory: 8 kilobytes of ROM or RAM on the Game Pak (possibly more with one of the common mappers) to store the shapes of background and sprite tiles, plus 2 kilobytes of RAM in the console to store a map or two. Two separate, smaller address spaces hold a palette, which controls which colors are associated to various indices, and OAM (Object Attribute Memory), which stores the position, orientation, shape, and color of the sprites, or independent moving objects. These are internal to the PPU itself, and while the palette is made of static memory, OAM uses dynamic memory (which will slowly decay if the PPU is not rendering).

### Programmer's reference
- Registers
- Pattern tables(tile graphics for background and sprites)
- Background graphics
  - Nametables
  - Attribute tables
- OAM(sprites)
- Palettes
- Memory map

- All PPU documentation on one page(printer-friendly)

### Hardware behaviors
- Frame timing
- Power up state
- NMI
- Clock rateand other NTSC/PAL/Dendy differences
- NTSC video
- Scrolling
- Rendering
- Sprite evaluation
- Sprite priority
- PPU signals
- Overscan
- PPU pinout
- NTSC PPU frame timing diagram
- Visual 2C02: A hardware-level PPU simulator
- List of known PPU versions and variants

### Notes
- The NTSC videosignal is made up of 262 scanlines, and 20 of those are spent in vblank state. After the program has received an NMI, it has about 2270 cycles to update the palette, sprites, and nametables as necessary before rendering begins.
- On NTSC systems, the PPU divides the master clock by 4 while the CPU uses the master clock divided by 12. Since both clocks are fed off the same master clock, this means that there are exactly three PPU ticks per CPU cycle, with no drifting over time (though the clock alignment might vary depending on when you press the Reset button).
- On PAL systems, the PPU divides the master clock by 5 while the CPU uses the master clock divided by 16. As a result, there are exactly 3.2 PPU ticks per CPU cycle.

### See also
- 2C02 technical referenceby Brad Taylor. (Pretty old at this point; information on the wiki might be more up-to-date.)

# PPU OAM

Source: https://www.nesdev.org/wiki/OAM

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

# PPU registers

Source: https://www.nesdev.org/wiki/OAMADDR

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

# PPU registers

Source: https://www.nesdev.org/wiki/OAMDATA

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

# PPU registers

Source: https://www.nesdev.org/wiki/OAMDMA

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

# PPU

Source: https://www.nesdev.org/wiki/PPU

The NES PPU, or Picture Processing Unit, generates a composite video signal with 240 lines of pixels, designed to be received by a television. When the Famicom chipset was designed in the early 1980s, it was considered quite an advanced 2D picture generator for video games.

It has its own address space, which typically contains 10 kilobytes of memory: 8 kilobytes of ROM or RAM on the Game Pak (possibly more with one of the common mappers) to store the shapes of background and sprite tiles, plus 2 kilobytes of RAM in the console to store a map or two. Two separate, smaller address spaces hold a palette, which controls which colors are associated to various indices, and OAM (Object Attribute Memory), which stores the position, orientation, shape, and color of the sprites, or independent moving objects. These are internal to the PPU itself, and while the palette is made of static memory, OAM uses dynamic memory (which will slowly decay if the PPU is not rendering).

### Programmer's reference
- Registers
- Pattern tables(tile graphics for background and sprites)
- Background graphics
  - Nametables
  - Attribute tables
- OAM(sprites)
- Palettes
- Memory map

- All PPU documentation on one page(printer-friendly)

### Hardware behaviors
- Frame timing
- Power up state
- NMI
- Clock rateand other NTSC/PAL/Dendy differences
- NTSC video
- Scrolling
- Rendering
- Sprite evaluation
- Sprite priority
- PPU signals
- Overscan
- PPU pinout
- NTSC PPU frame timing diagram
- Visual 2C02: A hardware-level PPU simulator
- List of known PPU versions and variants

### Notes
- The NTSC videosignal is made up of 262 scanlines, and 20 of those are spent in vblank state. After the program has received an NMI, it has about 2270 cycles to update the palette, sprites, and nametables as necessary before rendering begins.
- On NTSC systems, the PPU divides the master clock by 4 while the CPU uses the master clock divided by 12. Since both clocks are fed off the same master clock, this means that there are exactly three PPU ticks per CPU cycle, with no drifting over time (though the clock alignment might vary depending on when you press the Reset button).
- On PAL systems, the PPU divides the master clock by 5 while the CPU uses the master clock divided by 16. As a result, there are exactly 3.2 PPU ticks per CPU cycle.

### See also
- 2C02 technical referenceby Brad Taylor. (Pretty old at this point; information on the wiki might be more up-to-date.)

# PPU registers

Source: https://www.nesdev.org/wiki/PPUADDR

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPUCTRL

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPUDATA

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPUMASK

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPUSCROLL

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPUSTATUS

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

# PPU OAM

Source: https://www.nesdev.org/wiki/PPU_OAM

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

# PPU attribute tables

Source: https://www.nesdev.org/wiki/PPU_attribute_tables

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

# PPU glitches

Source: https://www.nesdev.org/wiki/PPU_glitches

Early Writes

When the CPU writes a value, it signals that a write is happening before driving data onto the bus, leaving a brief window at the start of the write where the bus contents are open bus. Unfortunately, the PPU assumes the data is valid for the entire write, and for many of its registers the PPU will briefly use this open bus value. This can cause visible glitches.

In most cases, the early write value seen by the PPU is the high byte of the PPU register address, because the CPU normally fetches the high byte of the address from the instruction operand on the cycle before doing the write. Therefore, the early write value is normally $20.

## Mitigations

Early write bugs are usually inconsequential because most PPU writes occur outside of rendering, preventing them from causing visible artifacts. Even writes that occur during rendering may only matter during specific vulnerable dots. However, for writes that may be affected, there are mitigations that work by ensuring the open bus value at the start of the write matches the value being written.

Note that the early write issue mostly matters in the case where the old and new value of a register are the same. When they are the same, an early write can cause a brief window where the value is different. However, when the two values are different, early writes only change the timing of the value transition, making it either slightly earlier or later depending on whether the early write matches the old value or new value. This means, though, that bits within the write may change at different times because different bits may match one or the other.

### PPU open bus

The most general solution is to prime the bus using PPU open bus. When a write-only PPU register is read, it will return the last value present on the PPU's internal bus, which is the last value that the CPU read from or wrote to it. This value eventually decays over long time scales of at least 1 ms, but is reliable on shorter timescales. By putting the intended value into PPU open bus and then reading this on the cycle before the write, the CPU open bus value at the start of the write will match the actual write value, preventing the PPU from briefly seeing a different value.

A PPU open bus read can be inserted between the operand read and value write by using an indexed write. These 5-cycle instructions perform a read from the target address on the 4th cycle before writing to it on the 5th cycle, in order to handle page crossings that may result in the address being off by 1 page on the 4th cycle. When writing to a write-only PPU register, this 4th cycle read will read PPU open bus. For example, to avoid the early write issue when writing to PPUMASK:

```text
LDX #$00
STA PPUSTATUS  ; Set the PPU open bus value by writing to a read-only register.
STA PPUMASK,X  ; Read PPU open bus from the target register before writing it.

```

Note that this should not be done when writing to PPUDATA, which does not have early write issues, because this register is both readable and writable, has side effects on read, and takes longer than 1 CPU cycle to handle CPU accesses.

### Register mirrors

Because the value on the bus is normally the high byte of the PPU register address, the bus can also be primed by writing to a PPU register mirror that matches the value being written. Because mirrors only exist in the range $2000-$3FFF, this only mitigates the issue for the low 5 bits; the upper 3 bits will always be %001. However, if those bits are unaffected or inconsequential, this approach can be sufficient. For example, to safely enable rendering mid-screen:

```text
LDA #$1E   ; Fully enables rendering
STA $3E01  ; Mirror of PPUMASK: (PPUMASK | ($1E << 8))

```

For code where the value is not fixed, all 8 bits matter, or certain register bits must change at the same time, the PPU open bus approach is likely superior.

## Hardware explanation

The 6502, and thus also the 2A03, guarantee that R/W and address bus are stable while φ2 (or M2) are high, but do not guarantee the data bus is stable.

Here is a timing diagram for the 2A03G:

```text
 (10ns) 0  40  80 120 160 200 240 280 320 360 400 440 480 520 560 600 640
     M2 \____________________/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\______
/ROMSEL __/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__________________________________/¯¯¯¯ (when relevant)
/PPUSEL ____/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__________________________________/¯¯ (when relevant)
    R/W ¯¯¯¯¯\_________________________________________________________ (read to write cycle)
     D0 ======ZZZZZZZZZZZZZZZZZZZZZZZZZZZ=============================Z
    R/W ____________/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ (write to read cycle)

```

(TODO: Add relative timing of address bus, if different from R/W)

## Affected registers

### PPUCTRL

In the 2C02G, the $C3 bits are processed in an asynchronous manner, and this can cause various problems:
- $01s bit: On every active scanline, a write to PPUCTRL at the exact wrong time ( write starting on dot 257, ending on dot 258) can cause the left nametable to be drawn for the upcoming scanline. [1]This is because the contents of open bus- $20 - are used by the PPU on dot 257, setting the "base nametable" to the left one instead of the intended one. As a work-around, write to the PPU address mirror where the bottom 2 bits of the upper byte of the address match the data that will be written. [2]
- $02s bit: On every active field, a write to PPUCTRL at the exact wrong time ( starting on prerender scanline dot 304, ending on dot 305) can cause the top nametable to be drawn for the upcoming field. Workaround is same as above.
- $40s bit: Any write to PPUCTRL during the active field can temporarily disable "output colors on EXT pins" for one pixel. This is believed to be the cause of certain bugs reported in the HDNES.
- $80s bit: Any write to PPUCTRL during the vertical blanking interval can cause the NMI output to be asserted, or deasserted, for about 80ns. However, this glitch is invisible, because the 6502 ignores its NMI input during this time.

In the 2C02A, it's known that the $18 bits in PPUMASK are also processed in an asynchronous manner, and suspected that all the other bits do also:
- $04s bit: On the 2C02A, it's believed that this will have no effect, because the write to PPUCTRL would have to occur right in the middle of incrementing the PPU address while rendering is disabled.
- $08s bit: On the 2C02A, it's believed that a write during horizontal blanking could cause exactly one bitplane of one sliver of one sprite to be fetched from the wrong pattern table.
- $10s bit: On the 2C02A, it's believed that a write during active redraw could cause exactly one bitplane of one sliver of one background tile to be fetched from the wrong pattern table.
- $20s bit: On the 2C02A, it's believed that a write at any time could cause one sprite sliver could be drawn incorrectly, specifics are unclear.

### PPUMASK

On the 2C02G, the $81 bits are processed in an asynchronous manner and this can cause unimportant glitches:
- $01s bit: Any write to PPUMASK can, at any time, turn off the "monochrome" flag for one pixel. [3]
- $80s bit: Any write to PPUMASK can, regardless of subpixel phase, turn off "blue emphasis" for half of one pixel. [4]

In the 2C02A, it's known that the $18 bits in PPUMASK are also processed in an asynchronous manner, and suspected that all the other bits do also:
- $18 bits: On the 2C02A, it's known that any write to PPUMASK during active redraw will turn off rendering for one pixel, causing all the documented hazards with disabling rendering.
- $06 bits: on the 2C02A, the effects of this will be invisible under the above disabling.
- $60 bits: on the 2C02A, it is suspected that any write to PPUMASK will turn off "red" or "green" emphasis for half of one pixel

### OAMADDR

On the 2C02G, changes to the OAM address can cause a copy from the first address' row of memory to the second address'. Writing OAMADDR can trigger this in multiple ways, one of which is through early writes. Unfortunately, while mitigating the early write issue can make OAMADDR writes work reliably on some CPU/PPU alignments, it is not sufficient to make them work correctly in all CPU/PPU alignments.

### PPUADDR, PPUSCROLL

On the 2C02G, any write starting on dot 257 and ending on dot 258 that updates coarse X in "t" can cause the same symptoms as writes to PPUCTRL. [5]

### PPUADDR

Any second write to PPUADDR will immediately change update the lower three bits of coarse X and five bits of coarse Y to the value of open bus, and will then (on the next pixel, except as covered by the dot 257/258 glitch mentioned above) write the correct value. This is usually invisible but can cause an incorrect sliver.

### PPUSCROLL

Any first write to PPUSCROLL will immediately change fine X to the value of open bus, and will then (on the next pixel) correct fine X. PPU-internal bus conflicts

Any time the PPU both increments v and reloads v from t on the same dot, a bus conflict occurs that sets both v and t to the bitwise AND of the two v inputs. This bus conflict affects just the components that were being incremented (X and/or Y).

This can happen (at least) two different ways:
- A second write of PPUADDR(loading a new scroll location) so that the t to v copy occurs at the same time that the Y bits are incremented(dot 256) or the coarse X bits are incremented(the last dot of every set of 4 background memory fetches). [6]
- A read or write of PPUDATAso that the resulting fine Y and coarse X increments occur at the same time the PPU naturally reloads v from t (dot 257 on each rendering scanline, or dot 304 of the prerender scanline).

# PPU nametables

Source: https://www.nesdev.org/wiki/PPU_nametables

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

# PPU palettes

Source: https://www.nesdev.org/wiki/PPU_palettes

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
- ↑Sharp CZ-880 service manual schematic, which uses the same X0858CE transcoder chip and voltage divider resistors on the color-difference I/O pins

# PPU pattern tables

Source: https://www.nesdev.org/wiki/PPU_pattern_tables

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

# PPU registers

Source: https://www.nesdev.org/wiki/PPU_registers

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

# PPU rendering

Source: https://www.nesdev.org/wiki/PPU_rendering

## Drawing overview

The PPU outputs a picture region of 256x240 pixels and a border region extending 16 pixels left, 11 pixels right, and 2 pixels down (283x242). The picture region is generated by doing memory fetches that fill shift registers, from which a pixel is selected. It is composed of a background region filling the entire screen and smaller sprites that may be placed nearly anywhere on it. In the border and any transparent pixel, the PPU displays the palette index selected by the PPU's EXT input, which is grounded to index 0 in stock consoles.

### Picture region

```text
                                         [BBBBBBBB] - Next tile's pattern data,
                                         [BBBBBBBB] - 2 bits per pixel
                                          ||||||||<----[Transfers every inc hori(v)]
                                          vvvvvvvv
      Serial-to-parallel - [AAAAAAAA] <- [BBBBBBBB] <- [0...] - Parallel-to-serial  (low plane)
         shift registers - [AAAAAAAA] <- [BBBBBBBB] <- [1...] - shift registers     (high plane)
                            vvvvvvvv
                            ||||||||   [Sprites 0..7]----+  [EXT in]----+
                            ||||||||                     |              |
[fine_x selects a bit]---->[  Mux   ]------------>[Priority mux]----->[Mux]---->[Pixel]
                            ||||||||                              |
                            ^^^^^^^^                              +------------>[EXT out]
      Serial-to-parallel - [PPPPPPPP] <- [P] - 1-bit latch
         shift registers - [PPPPPPPP] <- [P] - 1-bit latch
                                          ^
                                          |<--------[Transfers every inc hori(v)]
                                     [  Mux   ]<----[coarse_x bit 1 and coarse_y bit 1 select 2 bits]
                                      ||||||||
                                      ^^^^^^^^
                                     [PPPPPPPP] - Next tile's attributes data

```

To generate the background in the picture region, the PPU performs memory fetches on dots 321-336 and 1-256 of scanlines 0-239 and 261. Each memory fetch takes 2 dots: on the 1st, the full address is placed onto the PPU's address bus and the low 8 bits are stored into an external address latch, and on the 2nd, the read is performed. Fetches require 2 dots because the same physical pins are used for the data bus and low 8 bits of address, so the address must be latched externally before a read can be done.

In each 8-dot window, the PPU performs the 4 memory fetches required to produce 8 pixels, fully occupying the PPU bus. Using the current scroll register, v, to produce the target addresses, the PPU fetches a tile ID from the nametable, attributes data from the attributes table, and the low and then high bitplane of the pattern data for that tile ID. The fetched bytes are stored in internal registers.

On every 8th dot in these background fetch regions (the same dot on which the coarse x component of v is incremented), the pattern and attributes data are transferred into registers used for producing pixel data. For the pattern data, these transfers are into the high 8 bits of two 16-bit shift registers. For the attributes data, only 2 bits are transferred and into two 1-bit latches that feed 8-bit shift registers. The concept for both is the same, differing merely because the attributes data is the same for all 8 pixels, negating the need to store 8 copies of it.

On every dot in these background fetch regions, a 4-bit pixel is selected by the fine x register from the low 8 bits of the pattern and attributes shift registers, which are then shifted.

The PPU then selects between this background pixel and the 4-bit sprite pixel produced by the OAM process. This selection depends on whether each pixel is transparent (low 2 bits are both 0) and the sprite's priority (whether it appears in front of (0) or behind (1) the background). If both are transparent, the background pixel is selected. After the selection, the pixel is now 5-bit, with the new top bit determined by whether background (0) or sprites (1) was selected. If the PPU is configured to output on its EXT pins, it outputs the low 4 bits of the selected pixel.

If the selected pixel is transparent, it is replaced with the EXT input: bit 4 is always 0, and bits 3-0 take the values of EXT3-0. The PPU's 4 EXT pins are grounded in all known console variations, so this input is normally 0. If the PPU is configured for EXT output, then the input value is always 0. (However, because these pins are grounded, EXT should never be in output mode because it could cause physical damage.)

The result of all of this is a 5-bit index used to look up a value from palette RAM. This value is a color, which can be modified by the emphasis and greyscale features of the PPUMASKregister and is then drawn as a pixel.

As-used, EXT input always produces an all-0 value, so transparent pixels always display the color at $3F00 in palette RAM, referred to as the 'backdrop' color.

| BG pixel | Sprite pixel | Priority | Output |
| 0 | 0 | X | EXT in ($3F00) |
| 0 | 1-3 | X | Sprite |
| 1-3 | 0 | X | BG |
| 1-3 | 1-3 | 0 | Sprite |
| 1-3 | 1-3 | 1 | BG |

Notes:
- Sprite have a 1-bit priority relative to backgrounds, but they also have a priority relative to each other depending on their order in OAM. Lower sprite indices are higher priority than higher indices, and the highest priority sprite pixel is selected before background priority is handled. Because of this, a high priority sprite in the background takes precedence over a lower priority sprite even in the foreground, which can cause the background to appear in front of that foreground sprite, referred to as the sprite priority quirk.
- Reads come from an address composed of the latched low 8 bits and the current high 6 bits. If rendering is toggled, these can become desynced, producing a hybrid address sourced from two different addresses and reading from an address the PPU itself never actually outputted.
- The two 16-bit pattern shift registers each shift in a constant value. Because the first 8 bits of the shift registers are reloaded every 8 dots, these constants are normally overwritten with fresh pattern data, but toggling rendering mid-frame may cause more than 8 shifts between loads, allowing these constants to be rendered. The logical value of these constants is 1 for the high bitplane and 0 for the low bitplane. In the circuit, the input for both is 1, but the two bitplanes undergo a different number of inversions, making the constant logically 0 for the low one.
- The storage registers, shift registers, and 1-bit latches described here decay to 0 on a time scale of probably around 2 frames. The results of this decay may be visible when turning rendering on mid-frame. Note that any decay to 0 that occurs in registers holding inverted data will produce a 1 in the resulting pixel data. Shift registers and 1-bit latches for the low bitplane and both attributes bits have the same inversion behavior.

### Border region

The border region displays the palette RAM entry selected by EXT input, either the data on the EXT pins if in input mode or 0 if in output mode. The first pixel on the left border is displayed with greyscale mode enabled. The border is affected by PPUMASKemphasis and greyscale effects.

### Rendering disabled

With rendering disabled, both the picture and border regions display only EXT input. On PPUs that support CPU reads from palette RAM (RP2C02G, RP2C02H), the automatic greyscale effect on the first border pixel is disabled if a CPU palette read occurs at the exact same time. [1]

When the PPU isn't rendering, its v register specifies the current VRAM address (and is output on the PPU's address pins). Whenever the low 14 bits of v point into palette RAM ($3F00-$3FFF), the PPU will continuously draw the color at that address instead of the EXT input, overriding the backdrop color. This is because the only way to access palette RAM is with this drawing mechanism, and is akin to color RAM dots on consoles such as the Master System and Mega Drive / Genesis. Backdrop override is used intentionally by some software.

PPUMASKemphasis and greyscale effects apply even with rendering disabled.

### PAL

PAL PPUs have the same rendering behavior as NTSC PPUs except for the border. The border is always black and extends 1 pixel into the top and 2 pixels into each of the left and right edges of the picture region, whether rendering is enabled or not. Emphasis and greyscale effects do not apply to this border. Note that this border does not change the behavior of sprite 0 hit compared to NTSC.

## Line-by-line timing

The PPU renders 262 scanlines per frame. Each scanline lasts for 341 PPU clock cycles (113.667 CPU clock cycles; 1 CPU cycle = 3 PPU cycles), with each clock cycle producing one pixel. The line numbers given here correspond to how the internal PPU frame counters count lines.

The information in this section is summarized in the diagram in the next section.

The timing below is for NTSC PPUs. PPUs for 50 Hz TV systems differ:
- Dendy PPUs render 51 post-render scanlines instead of 1
- PAL NES PPUs render 70 vblank scanlines instead of 20, and they additionally run 3.2 PPU cycles per CPU cycle, or 106.5625 CPU clock cycles per scanline.

### Pre-render scanline (-1 or 261)

This is a dummy scanline, whose sole purpose is to fill the shift registers with the data for the first two tiles of the next scanline. Although no pixels are rendered for this scanline, the PPU still makes the same memory accesses it would for a regular scanline, using whatever the current value of the PPU's V registeris, and for the sprite fetches, whatever data is currently in secondary OAM (e.g., the results from scanline 239's sprite evaluationfrom the previous frame).

This scanline varies in length, depending on whether an even or an odd frame is being rendered. For odd frames, the cycle at the end of the scanline is skipped (this is done internally by jumping directly from (339,261) to (0,0), replacing the idle tick at the beginning of the first visible scanline with the last tick of the last dummy nametable fetch). For even frames, the last cycle occurs normally. This is done to compensate for some shortcomings with the way the PPU physically outputs its video signal, the end result being a crisper image when the screen isn't scrolling. However, this behavior can be bypassed by keeping rendering disabled until after this scanline has passed, which results in an image with a "dot crawl" effect similar to, but not exactly like, what's seen in interlaced video.

During pixels 280 through 304 of this scanline, the vertical scroll bits are reloaded if rendering is enabled.

### Visible scanlines (0-239)

These are the visible scanlines, which contain the graphics to be displayed on the screen. This includes the rendering of both the background and the sprites. During these scanlines, the PPU is busy fetching data, so the program should not access PPU memory during this time, unless rendering is turned off.

#### Cycle 0

This is an idle cycle. The value on the PPU address bus during this cycle appears to be the same CHR address that is later used to fetch the low background tile byte starting at dot 5 (possibly calculated during the two unused NT fetches at the end of the previous scanline).

#### Cycles 1-256

The data for each tile is fetched during this phase. Each memory access takes 2 PPU cycles to complete, and 4 must be performed per tile:
- Nametable byte
- Attribute table byte
- Pattern table tile low
- Pattern table tile high (8 bytes above pattern table tile low address)

The data fetched from these accesses is placed into internal latches, and then fed to the appropriate shift registers when it's time to do so (every 8 cycles). Because the PPU can only fetch an attribute byte every 8 cycles, each sequential string of 8 pixels is forced to have the same palette attribute.

Sprite 0 hit acts as if the image starts at cycle 2 (which is the same cycle that the shifters shift for the first time), so the sprite 0 flag will be raised at this point at the earliest. Actual pixel output is delayed further due to internal render pipelining, and the first pixel is output during cycle 4.

The shifters are reloaded during ticks 9, 17, 25, ..., 257.

Note: At the beginning of each scanline, the data for the first two tiles is already loaded into the shift registers (and ready to be rendered), so the first tile that gets fetched is Tile 3.

While all of this is going on, sprite evaluationfor the next scanline is taking place as a seperate process, independent to what's happening here.

#### Cycles 257-320

The tile data for the sprites on the next scanline are fetched here. Again, each memory access takes 2 PPU cycles to complete, and 4 are performed for each of the 8 sprites:
- Garbage nametable byte
- Garbage nametable byte
- Pattern table tile low
- Pattern table tile high (8 bytes above pattern table tile low address)

The garbage fetches occur so that the same circuitry that performs the BG tile fetches could be reused for the sprite tile fetches.

If there are less than 8 sprites on the next scanline, then dummy fetches to tile $FF occur for the left-over sprites, because of the dummy sprite data in the secondary OAM (see sprite evaluation). This data is then discarded, and the sprites are loaded with a transparent set of values instead.

In addition to this, the X positions and attributes for each sprite are loaded from the secondary OAM into their respective counters/latches. This happens during the second garbage nametable fetch, with the attribute byte loaded during the first tick and the X coordinate during the second.

All garbage nametable bytes except the first are the same address as the first nametable fetch on the upcoming scanline. The first garbage nametable fetch is a mix due to the PPU's bus being multiplexed, where the lower eight bits reflect both incrementsof v that happen on dot 256but the upper six bits have already been reloaded.

#### Cycles 321-336

This is where the first two tiles for the next scanline are fetched, and loaded into the shift registers. Again, each memory access takes 2 PPU cycles to complete, and 4 are performed for the two tiles:
- Nametable byte
- Attribute table byte
- Pattern table tile low
- Pattern table tile high (8 bytes above pattern table tile low address)

#### Cycles 337-340

Two bytes are fetched, but the purpose for this is unknown. These fetches are 2 PPU cycles each.
- Nametable byte
- Nametable byte

Both of the bytes fetched here are the same nametable byte that will be fetched at the beginning of the next scanline (tile 3, in other words). At least one mapper -- MMC5-- is known to use this string of three consecutive nametable fetches to clock a scanline counter.

### Post-render scanline (240)

The PPU just idles during this scanline. Even though accessing PPU memory from the program would be safe here, the VBlank flag isn't set until after this scanline.

### Vertical blanking lines (241-260)

The VBlank flag of the PPU is set at tick 1 (the second tick) of scanline 241, where the VBlank NMI also occurs. The PPU makes no memory accesses during these scanlines, so PPU memory can be freely accessed by the program.

## PPU address bus contents

During frame rendering, provided rendering is enabled (i.e., when either background or sprite rendering is enabled in $2001:3-4), the value on the PPU address bus is as indicated in the descriptions above and in the frame timing diagram below. During VBlank and when rendering is disabled, the value on the PPU address bus is the current value of the vregister.

To save pins, the PPU multiplexes the lower eight VRAM address pins, also using them as the VRAM data pins. This leads to each VRAM access taking two PPU cycles:
- During the first cycle, the entire VRAM address is output on the PPU address pins and the lower eight bits stored in an external octal latch by asserting the ALE (Address Latch Enable) line. (The octal latch is the lower chip to the right of the PPU in this wiring diagram.)
- During the second cycle, the PPU only outputs the upper six bits of the address, with the octal latch providing the lower eight bits (VRAM addresses are 14 bits long). During this cycle, the value is read from or written to the lower eight address pins.

As an example, the PPU VRAM address pins will have the value $2001 followed by the value $20AB for a read from VRAM address $2001 that returns the value $AB.

## Frame timing diagram

## See also
- Nametable
- Attribute table
- NTSC video
- PPU frame timing
- PPU sprite evaluation
References
- NTSC 2C02 technical reference
- ↑Forum post:Fiskbit's greyscale_column_sparkle_test

# PPU scrolling

Source: https://www.nesdev.org/wiki/PPU_scrolling

Scrolling is the movement of the displayed portion of the map. Games scroll to show an area much larger than the 256x240 pixel screen. For example, areas in Super Mario Bros. are many screens wide. The NES's first major improvement over its immediate predecessors (ColecoVision and Sega SG-1000) was pixel-level scrolling of playfields.

## The common case

Ordinarily, a program writes to two PPU registersto set the scroll position in its NMI handler:
- Find the 9-bit X and Y coordinates of the upper left corner of the visible area (the part seen by the "camera")
- Write the lower 8 bits of the X coordinate to PPUSCROLL($2005)
- Write the lower 8 bits of the Y coordinate to PPUSCROLL
- Write the 9th bit of X and Y to bits 0 and 1, respectively, of PPUCTRL($2000)
  - This is the nametable that's visible in the top-left corner

The scroll position written to PPUSCROLL is applied at the end of vertical blanking, just before rendering begins, therefore these writes need to occur before the end of vblank. Also, because writes to PPUADDR($2006) can overwrite the scroll position, the two writes to PPUSCROLL and the write to PPUCTRL must be done after any updates to VRAM using PPUADDR.

By itself, this allows moving the camera within a usually two-screen area (see Mirroring), with horizontal and vertical wraparound if the camera goes out of bounds. To scroll over a larger area than the two screens that are already in VRAM, you choose appropriate offscreen columns or rows of the nametable, and you write that to VRAM before you set the scroll, as seen in the animation below. The area that needs rewritten at any given time is sometimes called the "seam" of the scroll.

### Frequent pitfalls
Don't take too long If your NMI handler routine takes too long and PPUSCROLL ($2005) is not set before the end of vblank, the scroll will not be correctly applied this frame. Most games do not write more than 64 bytes to the nametable per NMI; more than this may require advanced techniques to fit this narrow window of time. Set the scroll last After using PPUADDR ($2006), the program must always set PPUCTRL and PPUSCROLL again. They have a shared internal register and using PPUADDR will overwrite the scroll position.

## PPU internal registers

If the screen does not use split-scrolling, setting the position of the background requires only writing the X and Y coordinates to $2005 and the high bit of both coordinates to $2000.

Programming or emulating a game that uses complex raster effects, on the other hand, requires a complete understanding of how the various address registers inside the PPU work.

Here are the related registers: v Current VRAM address (15 bits) t Temporary VRAM address (15 bits); can also be thought of as the address of the top left onscreen tile. x Fine X scroll (3 bits) w First or second write toggle (1 bit)

The PPU uses the current VRAM address for both reading and writing PPU memory thru $2007, and for fetching nametable data to draw the background. As it's drawing the background, it updates the address to point to the nametable data currently being drawn. Bits 10-11 hold the base address of the nametable minus $2000. Bits 12-14 are the Y offset of a scanline within a tile.

The 15 bit registers t and v are composed this way during rendering:

```text
yyy NN YYYYY XXXXX
||| || ||||| +++++-- coarse X scroll
||| || +++++-------- coarse Y scroll
||| ++-------------- nametable select
+++----------------- fine Y scroll

```

Note that while the v register has 15 bits, the PPU memory spaceis only 14 bits wide. The highest bit is unused for access through $2007.

## Register controls

In the following, d refers to the data written to the port, and A through H to individual bits of a value.

$2005 and $2006 share a common write toggle w , so that the first write has one behaviour, and the second write has another. After the second write, the toggle is reset to the first write behaviour. This toggle may be manually reset by reading $2002.

### $2000 (PPUCTRL) write

```text
t: ...GH.. ........ <- d: ......GH
   <used elsewhere> <- d: ABCDEF..

```

### $2002 (PPUSTATUS) read

```text
w:                  <- 0

```

### $2005 (PPUSCROLL) first write (w is 0)

```text
t: ....... ...ABCDE <- d: ABCDE...
x:              FGH <- d: .....FGH
w:                  <- 1

```

Note that w is shared between $2005 and $2006. For a worked example of interleaving writes to both, see § Details

### $2005 (PPUSCROLL) second write (w is 1)

```text
t: FGH..AB CDE..... <- d: ABCDEFGH
w:                  <- 0

```

### $2006 (PPUADDR) first write (w is 0)

```text
t: .CDEFGH ........ <- d: ..CDEFGH
       <unused>     <- d: AB......
t: Z...... ........ <- 0 (bit Z is cleared)
w:                  <- 1

```

### $2006 (PPUADDR) second write (w is 1)

```text
t: ....... ABCDEFGH <- d: ABCDEFGH
w:                  <- 0
   (wait 1 to 1.5 dots after the write completes)
v: <...all bits...> <- t: <...all bits...>

```

### $2007 (PPUDATA) reads and writes

Outside of rendering, reads from or writes to $2007 will add either 1 or 32 to v depending on the VRAM increment bit set via $2000. During rendering (on the pre-render line and the visible lines 0-239, provided either background or sprite rendering is enabled), it will update v in an odd way, triggering a coarse X incrementand a Y incrementsimultaneously (with normal wrapping behavior). Internally, this is caused by the carry inputs to various sections of v being set up for rendering, and the $2007 access triggering a "load next value" signal for all of v (when not rendering, the carry inputs are set up to linearly increment v by either 1 or 32). This behavior is not affected by the status of the increment bit. The Young Indiana Jones Chronicles uses this for some effects to adjust the Y scroll during rendering, and also Burai Fighter (U) to draw the scorebar. If the $2007 access happens to coincide with a standard VRAM address increment (either horizontal or vertical), it will presumably not double-increment the relevant counter.

### At dot 256 of each scanline

If rendering is enabled, the PPU increments the vertical position in v . The effective Y scroll coordinate is incremented, which is a complex operation that will correctly skip the attribute table memory regions, and wrap to the next nametable appropriately. See Wrapping aroundbelow.

### At dot 257 of each scanline

If rendering is enabled, the PPU copies all bits related to horizontal position from t to v :

```text
v: ....A.. ...BCDEF <- t: ....A.. ...BCDEF

```

### During dots 280 to 304 of the pre-render scanline (end of vblank)

If rendering is enabled, at the end of vblank, shortly after the horizontal bits are copied from t to v at dot 257, the PPU will repeatedly copy the vertical bits from t to v from dots 280 to 304, completing the full initialization of v from t :

```text
v: GHIA.BC DEF..... <- t: GHIA.BC DEF.....

```

### Between dot 328 of a scanline, and 256 of the next scanline

If rendering is enabled, the PPU increments the horizontal position in v many times across the scanline, it begins at dots 328 and 336, and will continue through the next scanline at 8, 16, 24... 240, 248, 256 (every 8 dots across the scanline until 256). Across the scanline the effective coarse X scroll coordinate is incremented repeatedly, which will also wrap to the next nametable appropriately. See Wrapping aroundbelow.

### Explanation
- The implementation of scrolling has two components. There are two fine offsets, specifying what part of an 8x8 tile each pixel falls on, and two coarse offsets, specifying which tile. Because each tile corresponds to a single byte addressable by the PPU, during rendering the coarse offsets reuse the same VRAM address register ( v ) that is normally used to send and receive data from the PPU. Because of this reuse, the two registers $2005 and $2006 both offer control over v , but $2005 is mapped in a more obscure way, designed specifically to be convenient for scrolling.
- $2006 is simply to set the VRAM address register. This is why the second write will immediately set v ; it is expected you will immediately use this address to send data to the PPU via $2007. The PPU memory space is only 14 bits wide, but v has an extra bit that is used for scrolling only. The first write to $2006 will clear this extra bit (for reasons not known).
- $2005 is designed to set the scroll position before the start of the frame. This is why it does not immediately set v , so that it can be set at precisely the right time to start rendering the screen.
- The high 5 bits of the X and Y scroll settings sent to $2005, when combined with the 2 nametable select bits sent to $2000, make a 12 bit address for the next tile to be fetched within the nametable address space $2000-2FFF. If set before the end of vblank, this 12 bit address gets loaded directly into v precisely when it is needed to fetch the tile for the top left pixel to render.
- The low 3 bits of X sent to $2005 (first write) control the fine pixel offset within the 8x8 tile. The low 3 bits goes into the separate x register, which just selects one of 8 pixels coming out of a set of shift registers. This fine X value does not change during rendering; the only thing that changes it is a $2005 first write.
- The low 3 bits of Y sent to $2005 (second write) control the vertical pixel offset within the 8x8 tile. The low 3 bits goes into the high 3 bits of the v register, where during rendering they are not used as part of the PPU memory address (which is being overridden to use the nametable space $2000-2FFF). Instead they count the lines until the coarse Y memory address needs to be incremented (and wrapped appropriately when nametable boundaries are crossed).

See also: PPU Frame timing

### Summary

The following diagram illustrates how several different actions may update the various internal registers related to scrolling. See Examplesbelow for usage examples.

| Action | Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| (PPUCTRL) $2000 write | ....... ........ | ....... ........ | ... | . | LDA #$00 (%00000000)STA $2000 | ...00.. ........ | ....... ........ | ... | . |  |

| (PPUSTATUS) $2002 read | ...00.. ........ | ....... ........ | ... | . | LDA $2002 | ...00.. ........ | ....... ........ | ... | 0 | Resets paired write latch w to 0. |

| (PPUSCROLL) $2005 write 1 | ...00.. ........ | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | ...00.. ...01111 | ....... ........ | 101 | 1 |  |

| (PPUSCROLL) $2005 write 2 | ...00.. ...01111 | ....... ........ | 101 | 1 | LDA #$5E (%01011110)STA $2005 | 1100001 01101111 | ....... ........ | 101 | 0 |  |

| (PPUADDR) $2006 write 1 | 1100001 01101111 | ....... ........ | 101 | 0 | LDA #$3D (%00111101)STA $2006 | 0111101 01101111 | ....... ........ | 101 | 1 | Bit 14 (15th bit) of t gets set to zero |

| (PPUADDR) $2006 write 2 | 0111101 01101111 | ....... ........ | 101 | 1 | LDA #$F0 (%11110000)STA $2006 | 0111101 11110000 | 0111101 11110000 | 101 | 0 | After t is updated, contents of t copied into v |

## Wrapping around

The following pseudocode examples explain how wrapping is performed when incrementing components of v . This code is written for clarity, and is not optimized for speed.

### Coarse X increment

The coarse X component of v needs to be incremented when the next tile is reached. Bits 0-4 are incremented, with overflow toggling bit 10. This means that bits 0-4 count from 0 to 31 across a single nametable, and bit 10 selects the current nametable horizontally.

```text
if ((v & 0x001F) == 31) // if coarse X == 31
  v &= ~0x001F          // coarse X = 0
  v ^= 0x0400           // switch horizontal nametable
else
  v += 1                // increment coarse X

```

### Y increment

If rendering is enabled, fine Y is incremented at dot 256 of each scanline, overflowing to coarse Y, and finally adjusted to wrap among the nametables vertically.

Bits 12-14 are fine Y. Bits 5-9 are coarse Y. Bit 11 selects the vertical nametable.

```text
if ((v & 0x7000) != 0x7000)        // if fine Y < 7
  v += 0x1000                      // increment fine Y
else
  v &= ~0x7000                     // fine Y = 0
  int y = (v & 0x03E0) >> 5        // let y = coarse Y
  if (y == 29)
    y = 0                          // coarse Y = 0
    v ^= 0x0800                    // switch vertical nametable
  else if (y == 31)
    y = 0                          // coarse Y = 0, nametable not switched
  else
    y += 1                         // increment coarse Y
  v = (v & ~0x03E0) | (y << 5)     // put coarse Y back into v

```

Row 29 is the last row of tiles in a nametable. To wrap to the next nametable when incrementing coarse Y from 29, the vertical nametable is switched by toggling bit 11, and coarse Y wraps to row 0.

Coarse Y can be set out of bounds (> 29), which will cause the PPU to read the attribute data stored there as tile data. If coarse Y is incremented from 31, it will wrap to 0, but the nametable will not switch. For this reason, a write >= 240 to $2005 may appear as a "negative" scroll value, where 1 or 2 rows of attribute data will appear before the nametable's tile data is reached. (Some games use this to move the top of the nametable out of the Overscanarea.)

### Tile and attribute fetching

The high bits of v are used for fine Y during rendering, and addressing nametable data only requires 12 bits, with the high 2 CHR address lines fixed to the 0x2000 region. The address to be fetched during rendering can be deduced from v in the following way:

```text
 tile address      = 0x2000 | (v & 0x0FFF)
 attribute address = 0x23C0 | (v & 0x0C00) | ((v >> 4) & 0x38) | ((v >> 2) & 0x07)

```

The low 12 bits of the attribute address are composed in the following way:

```text
 NN 1111 YYY XXX
 || |||| ||| +++-- high 3 bits of coarse X (x/4)
 || |||| +++------ high 3 bits of coarse Y (y/4)
 || ++++---------- attribute offset (960 bytes)
 ++--------------- nametable select

```

## Examples

### Single scroll

If only one scroll setting is needed for the entire screen, this can be done by writing $2000 once, and $2005 twice before the end of vblank.
- The low two bits of $2000 select which of the four nametables to use.
- The first write to $2005 specifies the X scroll, in pixels.
- The second write to $2005 specifies the Y scroll, in pixels.

This should be done after writes to $2006 are completed, because they overwrite the t register. The v register will be completely copied from t at the end of vblank, setting the scroll.

Note that the series of two writes to $2005 presumes the toggle that specifies which write is taking place. If the state of the toggle is unknown, reset it by reading from $2002 before the first write to $2005.

Instead of writing $2000, the first write to $2006 can be used to select the nametable, if this happens to be more convenient (usually it is not because it will toggle w ).

### Split X scroll

The X scroll can be changed at the end of any scanline when the horizontal components of v get reloaded from t : Simply make writes to $2000/$2005 before the end of the line.
- The first write to $2005 alters the horizontal scroll position. The fine x register (sub-tile offset) gets updated immediately, but the coarse horizontal component of t (tile offset) does not get updated until the end of the line.
- An optional second write to $2005 is inconsequential; the changes it makes to t will be ignored at the end of the line. However, it will reset the write toggle w for any subsequent splits.
- Write to $2000 if needed to set the high bit of X scroll, which is controlled by bit 0 of the value written. Writing $2000 changes other rendering propertiesas well, so make sure the other bits are set appropriately.

Like the single scroll example, reset the toggle by reading $2002 if it is in an unknown state. Since a write to $2005 and a read from $2002 are equally expensive in both bytes and time, whether you use one or the other to prepare for subsequent screen splits is up to you.

The first write to $2005 should usually be made as close to the end of the line as possible, but before the start of hblank when the coarse x scroll is copied from t to v . Because about 4 pixels of timing jitter are normally unavoidable, $2005 should be written a little bit early (once hblank begins, it is too late). The resulting glitch at the end of the line can be concealed by a line of one colour pixels or a sprite.

It is also possible to completely hide this glitch by first writing a combination of the new coarse X and old fine X to a mirror of $2005 before dot 257, then writing the entire new X to $2005 between dot 257 and the end of the scanline. On certain alignments, the PPU will use the contents of open bus to set fine X for one pixel. Thus the correct mirror to use is one where the lowest 3 bits of its upper byte matches the lowest 3 bits of the value you're writing. e.g. Write %xxxxx000 to $2005, write %xxxxx001 to $2105, etc.

The code may look like this:

```text
  lda new_x  ; Combine bits 7-3 of new X with 2-0 of old X
  eor old_x
  and #%11111000
  eor old_x
  sta $2005  ; Write old fine X and new coarse X
  bit $2002  ; Clear first/second write toggle
  lda new_x
  sta old_x
  nop        ; Wait for the next write to land in hblank
  nop
  sta $2005  ; Write entire new X
  bit $2002  ; Clear first/second write toggle

```

For more flexible control, the following more advanced X/Y scroll technique could be used to update v during hblank instead.

### Split X/Y scroll

Cleanly setting the complete scroll position (X and Y) mid-screen takes four writes:
- Nametable number << 2 (that is: $00, $04, $08, or $0C) to $2006
- Y to $2005
- X to $2005
- Low byte of nametable address to $2006, which is ((Y & $F8) << 2) | (X >> 3)

The last two writes should occur during horizontal blanking (cycle 256 or later) to avoid visual errors. (Because of right overscanand the background pixel pipeline, it may be acceptable to land the third write as early as cycle 252.)

The code may look like this:

```text
; The first two PPU writes can come anytime during the scanline:
; Nametable number << 2 to $2006.
lda new_nametable_x
lsr
lda new_nametable_y
rol
asl
asl
sta $2006

; Y position to $2005.
lda new_y
sta $2005

; Prepare for the 2 later writes:
; We reuse new_x to hold (Y & $F8) << 2.
and #%11111000
asl
asl
ldx new_x  ; X position in X for $2005 later.
sta new_x

; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
txa
lsr
lsr
lsr
ora new_x

; Burn cycles until start of hblank
; (Adjust for your application)
nop
nop

; The last two PPU writes must happen during hblank:
stx $2005
sta $2006

; Restore new_x.
stx new_x

```

#### Details

To split both the X and Y scroll on a scanline, we must perform four writes to $2006 and $2005 alternately in order to completely reload v . Without the second write to $2006, only the horizontal portion of v will loaded from t at the end of the scanline. By writing twice to $2006, the second write causes an immediate full reload of v from t , allowing you to update the vertical scroll in the middle of the screen. Because of the background pattern FIFO, the visible effect of a mid-scanline write is delayed by 1 to 2 tiles.

The writes to PPU registers are done in the order of $2006, $2005, $2005, $2006. This order of writes is important, understanding that the write toggle for $2005 is shared with $2006. As always, if the state of the toggle is unknown before beginning, read $2002 to reset it.

In this example we will perform two writes to each of $2005 and $2006. We will set the X scroll (X), Y scroll (Y), and nametable select (N) by writes to $2005 and $2006. Repeating the above summaries:

```text
N: %01
X: %01111101 = $7D
Y: %00111110 = $3E

```

```text
$2005 (w=0) = X                                                          = %01111101 = $7D
$2005 (w=1) = Y                                                          = %00111110 = $3E
$2006 (w=0) = ((Y & %11000000) >> 6) | ((Y & %00000011) << 4) | (N << 2) = %00010100 = $14
$2006 (w=1) = ((X & %11111000) >> 3) | ((Y & %00111000) << 2)            = %11101111 = $EF

```

However, since there is a great deal of overlap between the data sent to $2005 and $2006, only the last write to any particular bit of t matters. This makes the first write to $2006 mostly redundant, and we can simplify its setup significantly:

```text
$2006 (w=0) = N << 2                                                     = %00000100 = $04

```

There are other redundancies in the writes to $2005, but since it is likely the original X and Y values are already available, these can be left as an exercise for the reader.

| Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| ....... ........ | ....... ........ | ... | 0 | LDA #$04 (%00000100)STA $2006 | 0000100 ........ | ....... ........ | ... | 1 | Bit 14 of t set to zero |

| 0000100 ........ | ....... ........ | ... | 1 | LDA #$3E (%00111110)STA $2005 | 1100100 111..... | ....... ........ | ... | 0 | Behaviour of 2nd $2005 write |

| 1100100 111..... | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | 1100100 11101111 | ....... ........ | 101 | 1 | Behaviour of 1st $2005 write |

| 1100100 11101111 | ....... ........ | 101 | 1 | LDA #$EF (%11101111)STA $2006 | 1100100 11101111 | 1100100 11101111 | 101 | 0 | After t is updated, contents of t copied into v |

Timing for this series of writes is important. Because the Y scroll in v will be incremented at dot 256, you must either set it to the intended Y-1 before dot 256, or set it to Y after dot 256. Many games that use split scrolling have a visible glitch at the end of the line by timing it early like this.

Alternatively you can set the intended Y after dot 256. The last two writes ($2005 (w=0) / $2006 (w=1)) can be timed to fall within hblank to avoid any visible glitch. Hblank begins after dot 256, and ends at dot 320 when the first tile of the next line is fetched.

Because this method sets v immediately, it can be used to set the scroll in the middle of the line. This is not normally recommended, as the difficulty of exact timing and interaction of tile fetches makes it difficult to do cleanly.

### Quick coarse X/Y split

Since it is the write to $2006 when w =1 that transfers the contents of t to v , it is not strictly necessary to perform all 4 writes as above, so long as one is willing to accept some trade-offs.

For example, if you only write to $2006 twice, you can update coarse X, coarse Y, N, and the bottom 2 bits of fine y. The top bit of fine y is cleared, and fine x is unchanged.

$2006's contents are in the same order as t , so you can affect the bits as:

```text
   First      Second
/¯¯¯¯¯¯¯¯¯\ /¯¯¯¯¯¯¯\
0 0yy NN YY YYY XXXXX
  ||| || || ||| +++++-- coarse X scroll
  ||| || ++-+++-------- coarse Y scroll
  ||| ++--------------- nametable select
  +++------------------ fine Y scroll

```

## See Also
- PPU rendering
- PPU sprite evaluation
- Palette change mid frame
- Errata

## References
- The skinny on NES scrollingoriginal document by loopy, 1999-04-13
- Drag's X/Y scrolling examplefrom the forums
- VRAM address registerchip photograph analysis by Quietust

# PPU signals

Source: https://www.nesdev.org/wiki/PPU_signals

The PPU has many internal signals for controlling its various actions during the frame. Each signal can control many things in the chip, and each of these can have a different amount of delay between the signal being generated and being used. These delays can be critical for correct operation.

## H decoder

These signals are all generated from the current dot number. Some of these signals are combinations of multiple H decoder signals, and most of them are disabled during vblank (scanlines 240-260) and fblank. For two of them, they are disabled specifically during scanlines 240-261, but since this is so uncommon, it is called out as needed rather than in a dedicated column.

| Dots | Disabled during vblank/fblank | Names | Purpose |
-
-

| dot % 8 == 0..1 | Yes | Breaks: /F_NT | Pattern address register control (Delay: 1 dot) Pattern address register: During 2nd half even dots, this produces a signal that is used in the next half dot to latch data into the register used to generate pattern addresses. This signal latches OAM buffer bit 0 into the bit 12 register, bits 7-0 of the PPU data bus (delayed 0.5 dots) and OAM buffer bytes into the bits 11-4 registers, and bits 3-0 of the OAM in-range result (delayed 0.5 dots) into bits 3-0. The address register selects which data to use for output based on the fetch sprites (256-319) signal. (Delay: 1 dot) Sprite fetch: During 2nd half even dots, this latches the OAM buffer value's in-range result to be used while loading sprite shifters. Commentary: This signal is used for creating pattern addresses for both background and sprites. The latching is delayed half a dot to allow the OAM tile byte to be loaded into the OAM buffer. Much of the data used for this register is latched, but the live inputs are used for the pattern table selection, sprite size, and background fine y. |

-
-

| dot % 8 == 2..3(0..255, 320..335) | Yes | Breaks: F_AT | Background attributes control (Delay: 0.5 dots) VRAM address mux: When a pattern address is not selected, this causes an attributes address to be used instead of a nametable address. (Delay: 1 dot) Background rendering: During 2nd half even dots, this transfers the PPU data bus value into the attributes register. Commentary: This signal is relevant for palette corruption. Palette corruption happens when the palette address changes during 2nd half dots, which normally happens from rendering toggles. The output from the VRAM address mux is used to select between the rendering pipeline output and the low 5 bits of v for the palette RAM address. The low 4 bits are not synchronized and can change any time. Rendering state changes the addresses sent to the VRAM address mux, allowing the mux's output to immediately change and switch the low 4 bits of the palette RAM address. Rendering state controls bits 13-12 of the attributes address sent to the mux, making them either a fixed %10 or bits 13-12 of v. If rendering turns off during an attributes fetch, this mutated address can cause corruption by changing the selected palette RAM address even if v itself wasn't pointing into palette RAM; this happens any time v & $3C00 == $3C00. At other times, the nametable address (which becomes v) becomes selected when rendering disables, so v has to point into palette RAM to trigger corruption (v & $3F00 == $3F00). |

-
| dot % 8 == 4..5(0..255, 320..335) | Yes | Breaks: F_TA | Background low pattern register control (Delay: 1 dot) Background rendering: During 2nd half even dots, this transfers the PPU data bus value into the low pattern bits register. |

-
| dot % 8 == 6..7(0..255, 320..335) | Yes | Breaks: F_TB | Background sliver commit (Delay: 1 dot) Background rendering: During 2nd half even dots, this increments coarse x and transfers data from the PPU data bus and pattern and attributes registers into the background shift registers. |
-
-

| 0..7 | No | Breaks: CLIP_O / CLIP_B | Clipping enable (Delay: 2 dots) Background rendering: This signal permits the left column background masking bit in PPUCTRL to clear the pixels coming out of the background shift registers. (Delay: 1.5 dots) Sprite rendering: This signal permits the left column sprite masking bit in PPUCTRL to clear the pixels coming out of the sprite shifters. Commentary: This same clipping mechanism is used to block pixel output during not-visible pixels and when rendering components are disabled. This signal is actually a combination of a 0-7 or 256-263 signal and a !(0-255 on scanlines 0-239) signal, but only the 0-7 part of it can actually have any impact on the screen. |
-
-
-
-
-
| 0..63 | Yes | Breaks: I_OAM2 | OAM2 init (Delay: 1 dot) OAM2 init: This overrides the input to the OAM buffer with $FF instead of the value read from OAM (so that $FF can be written to OAM2). Note that there's an additional 1 dot of delay before the OAM buffer latches its input (it latches during 2nd half dots and is normally read during 1st half dots), so the $FF exists in the buffer on dots 2-65. (Delay: 1.5 dots) OAM2 init: This suppresses OAM1ADDR increments that normally happen automatically during the 1st half visible odd dots. (Delay: 1.5 dots) OAM2 init: During 1st half odd dots, this increments OAM2ADDR. (Delay: 1 dot) Sprite evaluation: This forces the OAM in-range input to the sprite evaluation in-range circuit to 0 (out of range). (Delay: 1 dot) Sprite evaluation: This continuously clears the eval_done signal (which, when set, forces the sprite evaluation version of the OAM in-range result to 0 and turns OAM2 writes into reads). |

-
-
-
-
-
-
-
-

| 0..255(scanlines 0-239) | Yes | Breaks: /VIS | Handle visible dots (Delay: 1.5 dots) Background rendering: Outside this range, background pixels are clipped (forced to transparent). (Delay: 2.5 dots) Sprite rendering: Outside this range, sprite pixels are clipped (forced to transparent). (Delay: 1.5 dots) Sprite evaluation: During 1st half odd dots, this causes OAM1ADDR to increment unless suppressed by OAM2 init. (Delay: 1 dot) Sprite evaluation: This signal causes odd dots to use OAM1ADDR to address OAM. Otherwise, all dots during rendering use OAM2ADDR. (Delay: 1 dot) Sprite evaluation: When this signal is false, it forces the OAM in-range input to the sprite evaluation in-range circuit to 0 (out of range). (Delay: 1 dot) Sprite evaluation / Sprite fetch: When this signal is false, the automatic writes to OAM on even dots (for writing to OAM2 during OAM2 init and sprite evaluation) are instead reads. (Delay: 1 dot) Sprite rendering: During 2nd half odd dots, this allows sprite shifters to output-and-shift pixels for a dot if they are not counting. (Delay: 1 dot) Sprite 0 hit: When this signal is false, the sprite 0 hit flag cannot be set. Commentary: Most H decoder signals are enabled during the pre-render scanline, but this one is not. This produces unusual behavior for sprite rendering during the pre-render scanline in that it disables OAM2 init and sprite evaluation, but not sprite fetch. This usually (but not always) causes scanline 0 to be sprite-free. |
-

| 0..255, 256..319 | Yes | Breaks: /FO | Handle background (Delay: 1 dot) Background rendering: During 2nd half dots, this clocks the background shift registers. Commentary: This is the signal that limits the 'Every n..n+1' signals for background handling. |
-
-
-
-
-

| 256..319 | Yes | Breaks: OBJ_READ | Sprite fetch (Delay: 1 dot) Sprite evaluation: This continuously resets OAM1ADDR ($2003). (Delay: 1 dot) Sprite 0 hit: During 1st half dots, this enables the sprite_0_on_this_scanline flip-flop so it can store the current output of the sprite_0_on_next_scanline flip-flop. (Delay: 1 dot) Sprite fetch: During 1st half dots, this increments OAM2ADDR (if it's not being otherwise suppressed) if bit 2 of the dot (delayed 0.5 dots) is 0. Because this sprite fetch signal also changes during 1st half dots, this creates asynchronous timing at the start of dot 321, where the signal goes from 1 to 0 while OAM2ADDR is using it to increment. In practice, this reliably causes an extra increment. (Delay: 1 dot) Sprite fetch: This enables a demux that takes the low 3 bits of the dot number (delayed 1 dot) and produces 4 signals that tell the sprite shifters when to load each piece of data. The signals from the demux are latched during 2nd half dots. (Delay: 1 dot) Pattern address register: During 2nd half dots, this selects between background and sprite data for the bits of the pattern address register. Commentary: The extra OAM2ADDR increment that occurs on dot 321 is critical for software because it provides a wide window during sprite idle where rendering can be safely turned off without setting up the conditions for OAM corruption later on. Games rely on this behavior. |
-
-
| 63, 255, 339 | Yes | Breaks: /EVAL | OAM2ADDR reset (Delay: 1.5 dots) OAM2 init / Sprite evaluation / Sprite fetch: During 1st half dots, this clears OAM2ADDR and oam2_overflow. (Delay: 1.5 dots) Sprite evaluation / Sprite fetch: This prevents OAM2ADDR from being able to increment. |
-
| 65 | Yes | Breaks: S_EV | Sprite 0 detection (Delay: 1 dot) Sprite 0 hit: During 1st half dots, this enables the sprite_0_on_next_scanline flip-flop so it can store the sprite evaluation version of the OAM in-range result. |
-
-
| 255 | Yes | Breaks: E_EV | Increment v (Delay: 1 dot) Background rendering: During 2nd half dots, this increments the y component of v. (Delay: 2 dots) Background rendering: During 2nd half dots, this copies the coarse x component of t to v. |
-

| 339 | Yes | Breaks: 0_HPOS | Start sprite shifter counters (Delay: 2.5 dots) Sprite rendering: This sets an SR latch in each sprite shifter that makes the shifter count instead of output-and-shift pixels. When the counter expires, the latch is cleared. Commentary: When the last dot of pre-render is skipped, this signal arrives at the sprite shifters one dot too late, so every shifter outputs its first pixel at X=0 and then they start counting on the next dot, outputting the remaining 7 pixels at their usual time. |
-
| 339 | Yes | Breaks: /HPLA_5 | End of scanline (odd frames) (Delay: 0 dots) Frame end: This signal, along with a scanline 261 (delayed 1 dot) signal, allows an even/odd frame toggle to act as another input to the same end-of-scanline circuit as dot 340. |
-
-
| 340 | No | Breaks: HPLA_23 | End of scanline (Delay: 0 dots) Scanline end: This signal increments the scanline counter. (Delay: 0.5 dots) Scanline end / Frame end: This signal clears the dot counter. If the scanline is 261 (delayed 0.5 dots), it also clears the scanline counter. |

# PPU sprite evaluation

Source: https://www.nesdev.org/wiki/PPU_sprite_evaluation

PPU sprite evaluation is an operation done by the PPU once each scanline. It prepares the set of sprites and fetches their data to be rendered on the next scanline.

This is a separate step from sprite rendering.

## Overview

Each scanline, the PPU reads the spritelist (that is, Object Attribute Memory) to see which to draw:
- First, it clears the list of sprites to draw.
- Second, it reads through OAM, checking which sprites will be on this scanline. It chooses the first eight it finds that do.
- Third, if eight sprites were found, it checks (in a wrongly-implemented fashion) for further sprites on the scanline to see if the sprite overflow flag should be set.
- Fourth, using the details for the eight (or fewer) sprites chosen, it determines which pixels each has on the scanline and where to draw them.

## Details

During all visible scanlines, the PPU scans through OAM to determine which sprites to render on the next scanline. Sprites found to be within range are copied into the secondary OAM, which is then used to initialize eight internal sprite output units.

OAM[n][m] below refers to the byte at offset 4*n + m within OAM, i.e. OAM byte m (0-3) of sprite n (0-63).

During each pixel clock (341 total per scanline), the PPU accesses OAM in the following pattern:
- Cycles 1-64: Secondary OAM (32-byte buffer for current sprites on scanline) is initialized to $FF - attempting to read $2004 will return $FF. Internally, the clear operation is implemented by reading from the OAM and writing into the secondary OAM as usual, only a signal is active that makes the read always return $FF.
- Cycles 65-256: Sprite evaluation
  - On odd cycles, data is read from (primary) OAM
  - On even cycles, data is written to secondary OAM (unless secondary OAM is full, in which case it will read the value in secondary OAM instead)
  - 1. Starting at n = 0, read a sprite's Y-coordinate (OAM[n][0], copying it to the next open slot in secondary OAM (unless 8 sprites have been found, in which case the write is ignored).
    - 1a. If Y-coordinate is in range, copy remaining bytes of sprite data (OAM[n][1] thru OAM[n][3]) into secondary OAM.
  - 2. Increment n
    - 2a. If n has overflowed back to zero (all 64 sprites evaluated), go to 4
    - 2b. If less than 8 sprites have been found, go to 1
    - 2c. If exactly 8 sprites have been found, disable writes to secondary OAM because it is full. This causes sprites in back to drop out.
  - 3. Starting at m = 0, evaluate OAM[n][m] as a Y-coordinate.
    - 3a. If the value is in range, set the sprite overflow flag in $2002 and read the next 3 entries of OAM (incrementing 'm' after each byte and incrementing 'n' when 'm' overflows); if m = 3, increment n
    - 3b. If the value is not in range, increment n and m (without carry). If n overflows to 0, go to 4; otherwise go to 3
      - The m increment is a hardware bug - if only n was incremented, the overflow flag would be set whenever more than 8 sprites were present on the same scanline, as expected.
  - 4. Attempt (and fail) to copy OAM[n][0] into the next free slot in secondary OAM, and increment n (repeat until HBLANK is reached)
- Cycles 257-320: Sprite fetches (8 sprites total, 8 cycles per sprite)
  - 1-4: Read the Y-coordinate, tile number, attributes, and X-coordinate of the selected sprite from secondary OAM
  - 5-8: Read the X-coordinate of the selected sprite from secondary OAM 4 times (while the PPU fetches the sprite tile data)
  - For the first empty sprite slot, this will consist of sprite #63's Y-coordinate followed by 3 $FF bytes; for subsequent empty sprite slots, this will be four $FF bytes
- Cycles 321-340+0: Background render pipeline initialization
  - Read the first byte in secondary OAM (while the PPU fetches the first two background tiles for the next scanline)

This pattern was determined by doing carefully timed reads from $2004 using various sets of sprites, and simulation in Visual 2C02 has subsequently confirmed this behavior.

## Sprite overflow bug

During sprite evaluation, if eight in-range sprites have been found so far, the sprite evaluation logic continues to scan the primary OAM looking for one more in-range sprite to determine whether to set the sprite overflow flag. The first such check correctly checks the y coordinate of the next OAM entry, but after that the logic breaks and starts scanning OAM "diagonally", evaluating the tile number/attributes/X-coordinates of subsequent OAM entries as Y-coordinates (due to incorrectly incrementing m when moving to the next sprite). This results in inconsistent sprite overflow behavior showing both false positives and false negatives.

### Cause of the sprite overflow bug

After investigation in Visual 2C02, the culprit of the sprite overflow bug appears to be the write disable signal that goes high after eight in-range sprites have been found (to prevent further updates to the secondary OAM), along with an error in the sprite evaluation logic.

As seen above, a side effect of the OAM write disable signal is to turn writes to the secondary OAM into reads from it. Once eight in-range sprites have been found, the value being read during write cycles from that point on is the y coordinate of the first sprite copied into the secondary OAM. Due to a logic error, the result of comparing this y coordinate to the current scanline number (which will always yield "in range", since the sprite would have had to be in range to get copied into the secondary OAM) is allowed to influence the sprite address incrementation logic, causing the glitchy updates to the sprite address seen above (due to how the timing works out). Once one more sprite has been found, another signal prevents the comparison from influencing the sprite address incrementation logic, and the bug is no longer in effect.

### Examples of usage

For some examples of games using this bug/quirk, refer to the Sprite overflow gamespage.

## Rendering disable or enable during active scanline

If PPUMASK($2001) with both BG and sprites disabled, rendering will be halted immediately. Changing this state mid-screen can create difficult problems. [1]

If rendering is disabled during an active scanline before evaluation completes, a corruption of OAMADDRlogic may cause sprites to be lost during OAMDMAon the following frame. This appears to be avoidable by making the write with a pixel timing after evaluation:
- x=192 for lines with no sprites
- x=240 for lines with at least one sprite

Disabling rendering mid-frame, then re-enabling it on the same frame may have additional corruption, at least on the first scanline it is re-enabled.

## Notes
- Sprite evaluation does not happen on the pre-render scanline. Because evaluation applies to the next line's sprite rendering, no sprites will be rendered on the first scanline, and this is why there is a 1 line offset on a sprite's Y coordinate.
- Sprite evaluation occurs if either the sprite layer or background layer is enabled via $2001. Unless both layers are disabled, it merely hides sprite rendering.
- Sprite evaluation does not cause sprite 0 hit. This is handled by sprite rendering instead.
- On the 2C02G and 2C02H, if the sprite address ( OAMADDR, $2003) is not zero, the process of starting sprite evaluation triggers an OAM hardware refresh bugthat causes the 8 bytes beginning at OAMADDR & $F8 to be copied and replace the first 8 bytes of OAM. [2][3]
- Visual 2C02might be helpful when trying to understand how the algorithm operates and what the precise timings are.

## References
- ↑Forum: OAM corruption errata when turning off rendering during active scanline.
- ↑Forum: Re: Just how cranky is the PPU OAM? (test notes by quietust)
- ↑Forum: Huge Insect does not fully start

# PPU sprite priority

Source: https://www.nesdev.org/wiki/PPU_sprite_priority

In the NES PPU, sprites may overlap each other and the background. The PPU decides what pixel to display based on priority rules. Each sprite has two values that affect priority: the index of the sprite within OAM(0 to 63), and the sprite-to-background priority bit ( attributebit 5, set to 0 for front or 1 for back).

In short:
- Sprites with lower OAM indices are drawn in front. For example, sprite 0 is in front of sprite 1, which is in front of sprite 63.
- At any given pixel, if the frontmost opaque sprite's priority bit is true (1), an opaque background pixel is drawn in front of it.

Putting a back-priority sprite at a lower OAM index than a front-priority sprite can cover up the the front-priority sprite and let the background show through. Super Mario Bros. 3 uses thisfor power-ups sprouting from blocks, by putting a non-transparent back-priority sprite "behind" the block at a low index and putting the power-up at a higher index. (You can see the corners of the back-priority sprite when Mario hits a note block in World 1-2, as the note block becomes more squared off.) The advantage of this approach is that the power-up can be hidden behind the block and still have front priority, meaning the area above the block doesn't have to be pure bg pixels like in Super Mario Bros.

The Nintendo DS PPU handles priority the "obvious" way, [1]and some NES emulator developers incorrectly think the NES PPU handles it the same manner, i.e.:
- Front priority sprites in front
- The background plane in the middle
- Back priority sprites in back

What really happens in the NES PPU is conceptually more like this:
- During sprite evaluationfor each scanline (cycles 65 through 240), the PPU searches for the eight frontmost sprites on this line. Then during sprite pattern fetch (cycles 257 to 320), these eight sprites get drawn front (lower index) to back (higher index) into a buffer, taking only the first opaque pixel that matches each X coordinate. Priority does not affect ordering in this buffer but is saved with each pixel.
- The background gets drawn to a separate buffer.
- For each pixel in the background buffer, the corresponding sprite pixel replaces it only if the sprite pixel is opaque and front priority or if the background pixel is transparent.

The buffers don't actually exist as full-scanline buffers inside the PPU but instead as a set of counters and shift registers. The above logic is implemented a pixel at a time, as PPU renderingexplains.

## Detailed internals of the sprite priority quirk

During sprite evaluation the PPU copies the sprites that are in y range from the primary to the secondary OAM, from which eight internal sprite output units are then initialized. These sprite output units are wired such that the lowest-numbered unit that outputs a non-transparent pixel always wins, regardless of front/back sprite priority and regardless of what the background pixel at the corresponding location is.

Hence, when a back-priority sprite is hidden behind non-bg background pixels, it will still hide output from higher-numbered sprite output units wherever it has a non-transparent pixel.

## References
- ↑GBATEK reference: DS Video OBJs

# PPU variants

Source: https://www.nesdev.org/wiki/PPU_variants

Beyond the well-studied 2C02G, we know of the following PPU revisions, both made by Ricoh and other manufacturers:

## Official

Chips officially licensed by Nintendo for use in official consoles and arcade systems.

### Composite

#### NTSC

All official NTSC PPUs expect a 21.477272 MHz master clock.

| Part | Picture | First Seen | Last Seen | Notes |

| RP2C02 |  | 1983-06 3F4 13 | 1983-08 3H2 10 | Extremely rare. Likely only a few thousand made. http://web.archive.org/web/20160315221802/kitayama3800.publog.jp/archives/cat_915765.html (pictures not archived)] |

| RP2C02A |  | 1983-08 3H1 43 | 1983-10 3K3 59 | Sometimes erroneous sprite pixels appear in X=255. Some modern PCBs generate almost exclusively glitchy pattern fetches. PPUMASK and PPUCTRL seem to be entirely asynchronous, and writes to PPUMASK can disable rendering for one pixel with the commensurate bugs resulting. |

| RP2C02B |  | 1983-12 3M3 73 | 1984-05 4E1 54 | Erroneous sprite pixels appear at X=255, just like 2C02A. Production seems to have halted to produce the 2C02C, but 2C02C production stopped and 2C02B production resumed, for unknown reasons. |

| RP2C02C |  | 1983-12 3M1 10 | 1984-02 4B4 98 | Eventually stopped being produced in favor of resuming 2C02B production, for unknown reasons. |

| RC2C02C |  | 1984-01 4A3 15 | Comes in a ceramic package.[1] Currently only found inside serviced Famicoms. |

| RP2C02D |  | 1984-07 4G4 27 | 1984-12 4M2 29 |  |

| RP2C02D-0 |  | 1984-10 4K3 63 | 1984-12 4M2 58 |  |

| RP2C02E |  | 1984-12 4M3 14 | 1985-10 5K4 36 |  |

| RP2C02E-0 |  | 1985-03 5C5 46 | 1987-03 7C4 29 | In this and all previous revisions, OAMDATA and palette RAM are not readable. Various OAM evaluation bugs |

| RP2C02G-0 |  | 1987-05 7E2 80 | 1993-10 3KM 1H | Writes to OAMADDR cause corruption of OAM. Leaving OAMADDR at a value of 8 or greater causes OAM corruption when rendering starts. Particularly susceptible to reflections causing OAM corruption, fixed by putting series resistors between the CPU and the cartridge ROM. |

| RP2C02H-0 |  | 1993-12 3MM 40 | 1999-05 9EM 5B | Thought have to have fixed some of the glitches in the previous 2C02G-0 revision(which?). |

| RP2C02H-0 (laser) |  | 2000-10 0KL 40 | 2003-01 3AL 4B | Reported (along with PAL PPUs) to have some kind of difference that caused problems with address bus filtering in earlier versions of the Hi-Def NES firmware. |

#### PAL

All official PAL PPUs expect a 26.601712 MHz master clock.

| Part | Picture | First Seen | Last Seen | Notes |

| RP2C07 |  | 1985-12 5M4 26 | PAL-B PPU. Vblanking is 71 scanlines long. OAM evaluation can never be fully disabled. Red/green color emphasis swapped. OAMADDR works correctly, not corrupting OAM contents] |

| RP2C07-0 |  | 1987-10 7K3 27 | 1991-10 1KM 13 |  |

| RP2C07A-0 |  | 1992-06 2FM 22 | Some subtle differences in PPU that make this work better with Kevtris's HDNES, but otherwise believed identical to 2C07. |

### RGB

All official RGB PPUs are NTSC and expect a 21.477272 MHz master clock.

| Part | Picture | First Seen | Last Seen | Notes |

| RC2C03 |  | 1983-11 3L4 15 | Found in the Sharp C1 TV. Suspected to be same core as 2C02 letterless. |

| RP2C03B |  | 1984-02 4B2 36 | 1989-03 9C4 23 | RGB PPU. Color emphasis bits set the corresponding channel to full brightness. Otherwise believed identical to 2C02B. OAMDATA and PPU palette are not readable. |

| RC2C03B |  | 1984-01 4A2 14 | 1984-01 4A4 30 |  |

| RP2C03C |  | 1984-03 4C2 63 | RGB PPU. Believed to be same core as 2C02C. |

| RC2C03C |  | 1984-01 4A2 10 | Believed identical to RP2C03C. |

| RP2C04 0001 |  | 1984-03 4C2 01 | 1984-05 4E4 35 | RGB PPU with a scrambled palette and some added colors, for copy protection purposes. Equivalent to 2C02D, but keeps 2C03 timing (no skipped dot). |

| RP2C04 0002 |  | 1984-07 4G4 19 | 1984-10 4K2 35 | Scrambles the palette uniquely compared to the previous revision. |

| RP2C04 0003 |  | 1984-10 4K5 13 | 1984-11 4L4 33 | Scrambles the palette uniquely compared to the previous revisions. |

| RP2C04 0004 |  | 1984-11 4L3 18 | 1984-11 4L5 36 | Scrambles the palette uniquely compared to the previous revisions. |

| RC2C05-01 |  | 1985-06 5F5 10 | 1985-06 5F5 11 | PPUCTRL and PPUMASK swap locations. Five LSBs of PPUSTATUS return a constant. Otherwise believed to behave like 2C03. |
| RC2C05-02 |  |  | Believed to be the same as 2C05-01, with the PPUSTATUS constant changed. |

| RC2C05-03 |  | 1985-07 5G1 12 | Believed to be the same as 2C05-01, with the PPUSTATUS constant changed. |

| RC2C05-04 |  | 1987-03 7C3 12 | Believed to be the same as 2C05-01, with the PPUSTATUS constant changed. |

| RC2C05-99 |  | 1988-11 8L4 11 | 1988-12 8M4 14 | An RGB PPU with RP2C02E behavior: OAM and palettes are unreadable, but OAM corruption added in revision E is present. PPUSTATUS behavior is normal (the low 5 bits are PPU open bus). Grayscale is normal (palette & $30). Uses 2C02 timing (a dot is skipped every other frame), unlike other RGB PPUs. The palette and emphasis behavior match other RGB PPUs. PPUCTRL and PPUMASK aren't swapped. Used in the Famicom Titler. (picture of Titler PCBs) |

## Unofficial

These chips are found exclusively inside of Famiclone systems, made by multiple companies.

| Part | Clock | Video | Picture | Notes |

| UA6528 | 21.48MHz | NTSC |  | UMC-made clone of 2C02E (or something earlier) [2] |

| UA6528P | 21.49MHz | PAL-N |  | UMC-made variant for PAL-N (Argentina) [3] System crystal is 21492337.5 Hz (exactly 6×229.2516×15625) |

| UA6538(P??) | 26.60MHz | PAL-B |  | UMC-made variant for playing NTSC games in PAL countries. Emits PAL-B video. Vblank interrupt intentionally emitted 50 scanlines later than 2C07. Video DAC is brighter and more saturated (how so?). See also Clock rate. |

| UA6541 | 26.60MHz | PAL |  | UMC-made clone of 2C07 [4] |

| UA6548 | 21.45MHz | PAL-M |  | UMC-made variant for PAL-M (Brazil) System crystal is 21453671… Hz (exactly 6×227.25×4500000÷286) |

| UM6558 | 21.31MHz | SECAM |  | UMC-made variant of UA6538 for SECAM countries. Emits 8-bit "Color Data" digital bus, for conversion into SECAM by UM6559 IC. Color palette noticeably off. System crystal is 21312500 Hz (exactly 4×341×15625). Maybe supports both 50 and 60 Hz operation? |

| UM6561xx-1 | 21.48MHz | NTSC |  | UMC-made NES-on-a-chip for NTSC. PPU half believed to be mostly identical to UA6528. Revisions "xx" F, AF, BF, CF known. Emphasis is much stronger than on UA6528 and official PPUs. |

| UM6561xx-2 | ? | PAL-B |  | UMC-made NES-on-a-chip for PAL-B. PPU half believed to be mostly identical to UA6538. Revisions "xx" F, AF, BF, CF known. AF revision has graphical and timing glitches in Prince of Persia perhaps caused by sprite 0 hit being missed for reasons not yet understood. F and BF revisions are not affected. Emphasis is much stronger than on UA6538 and official PPUs. |

| TA-02N | 21.48MHz | NTSC |  | ??-made die-mask clone of 2C02G, despite the "6528" label.[5] Chip underside also has two codes of currently unknown purpose. |
| TA-02NP | ? | PAL |  | ??-made PPU, Dendy compatible (not a 6538 clone). Pins 14-17 are background color in, like normal 2C03[6] |
| TA-02NPB | ? | Select |  | ??-made PPU, "NTSC for PAL-B" (NPB) Dendy-compatible. Has a unique video switching capability shared between it and other TA-02NPx chipsets, as well as the WDL chipset. |
| TA-08 | ? | SECAM |  | ??-made PPU, Second source alternative to UM6558. Color Data bus bit-reversed? |
| MG-N-502 | ? | NTSC |  |  |

| MG-P-502 | 26.60MHz | PAL-B |  | Micro Genius / TXC. Die shot matches UA6538. |

| 1818N | 21.48MHz | NTSC |  | ??-made NES-on-a-chip, NTSC timing. |

| 1818P | 26.60MHz | PAL-B |  | SiS-made[7]] NES-on-a-chip.[8]. Requires external 2KiB RAMs for CPU and PPU. UA6538 timing. |
| PM02-1 | ? | PAL-M |  | Gradiente-made variant for PAL-M (Brazil). [9] |
| VT01 | ? | Select |  | V.R.Tech-made clone of UA6561. Only seen as chip-on-board. Supports composite out; RGB out; or 2bpp STN LCD, either greyscale or red/cyan checkerboard, 240 px wide, 80/120/160/240px tall. The chip was extended significantly in VT02 and newer NOACs. |

| GS87008 | 21.48MHz | NTSC |  | (Goldstar??)-made NTSC clone [10] Found in MicroGenius clone with PAL/NTSC switch.[1] |

| KC-6078 | 26.60MHz | PAL-B |  | Found in MT777-DX famiclone, behaves exactly like UA6538 |
| 6022 | ? | NTSC |  | ??-made NTSC clone. Details unknown. |
| 2010 | ? | ? |  |  |
| 2A02E | ? | ? |  | Dendy Timing. On a large solid-color background (especially yellow, green), every other row has a horizontal stripe. |
| 02 | ? | ? |  |  |
| GT-01 | ? | ? |  | In PLCC |
| HA6538 | ? | PAL |  | PAL video output. |
| SENITON 6538U-8 | ? | PAL |  | PAL video output. |
| SENITON 6538A | ? | PAL |  | PAL video output. |

| 6528 (WDL6528) | 21.48MHz | NTSC |  | WDL made chip. NTSC timing. Palette like RP2C02. Often referred to as "WDL6528". |

| 8Z02 | 21.48MHz | NTSC |  | Found in Family Game by NTDEC. |
| TECH28 | ? | PAL |  | PAL video output. |

If you know of other differences or other revisions, please add them!

## See also
- CPU variants
- Clock rate
- NES_2.0#Byte_13_.28Vs._hardware.29
- https://forums.nesdev.org/viewtopic.php?p=150127#p150127
- ↑https://forums.nesdev.org/viewtopic.php?p=241514#p241514

# PPU scrolling

Source: https://www.nesdev.org/wiki/Scrolling

Scrolling is the movement of the displayed portion of the map. Games scroll to show an area much larger than the 256x240 pixel screen. For example, areas in Super Mario Bros. are many screens wide. The NES's first major improvement over its immediate predecessors (ColecoVision and Sega SG-1000) was pixel-level scrolling of playfields.

## The common case

Ordinarily, a program writes to two PPU registersto set the scroll position in its NMI handler:
- Find the 9-bit X and Y coordinates of the upper left corner of the visible area (the part seen by the "camera")
- Write the lower 8 bits of the X coordinate to PPUSCROLL($2005)
- Write the lower 8 bits of the Y coordinate to PPUSCROLL
- Write the 9th bit of X and Y to bits 0 and 1, respectively, of PPUCTRL($2000)
  - This is the nametable that's visible in the top-left corner

The scroll position written to PPUSCROLL is applied at the end of vertical blanking, just before rendering begins, therefore these writes need to occur before the end of vblank. Also, because writes to PPUADDR($2006) can overwrite the scroll position, the two writes to PPUSCROLL and the write to PPUCTRL must be done after any updates to VRAM using PPUADDR.

By itself, this allows moving the camera within a usually two-screen area (see Mirroring), with horizontal and vertical wraparound if the camera goes out of bounds. To scroll over a larger area than the two screens that are already in VRAM, you choose appropriate offscreen columns or rows of the nametable, and you write that to VRAM before you set the scroll, as seen in the animation below. The area that needs rewritten at any given time is sometimes called the "seam" of the scroll.

### Frequent pitfalls
Don't take too long If your NMI handler routine takes too long and PPUSCROLL ($2005) is not set before the end of vblank, the scroll will not be correctly applied this frame. Most games do not write more than 64 bytes to the nametable per NMI; more than this may require advanced techniques to fit this narrow window of time. Set the scroll last After using PPUADDR ($2006), the program must always set PPUCTRL and PPUSCROLL again. They have a shared internal register and using PPUADDR will overwrite the scroll position.

## PPU internal registers

If the screen does not use split-scrolling, setting the position of the background requires only writing the X and Y coordinates to $2005 and the high bit of both coordinates to $2000.

Programming or emulating a game that uses complex raster effects, on the other hand, requires a complete understanding of how the various address registers inside the PPU work.

Here are the related registers: v Current VRAM address (15 bits) t Temporary VRAM address (15 bits); can also be thought of as the address of the top left onscreen tile. x Fine X scroll (3 bits) w First or second write toggle (1 bit)

The PPU uses the current VRAM address for both reading and writing PPU memory thru $2007, and for fetching nametable data to draw the background. As it's drawing the background, it updates the address to point to the nametable data currently being drawn. Bits 10-11 hold the base address of the nametable minus $2000. Bits 12-14 are the Y offset of a scanline within a tile.

The 15 bit registers t and v are composed this way during rendering:

```text
yyy NN YYYYY XXXXX
||| || ||||| +++++-- coarse X scroll
||| || +++++-------- coarse Y scroll
||| ++-------------- nametable select
+++----------------- fine Y scroll

```

Note that while the v register has 15 bits, the PPU memory spaceis only 14 bits wide. The highest bit is unused for access through $2007.

## Register controls

In the following, d refers to the data written to the port, and A through H to individual bits of a value.

$2005 and $2006 share a common write toggle w , so that the first write has one behaviour, and the second write has another. After the second write, the toggle is reset to the first write behaviour. This toggle may be manually reset by reading $2002.

### $2000 (PPUCTRL) write

```text
t: ...GH.. ........ <- d: ......GH
   <used elsewhere> <- d: ABCDEF..

```

### $2002 (PPUSTATUS) read

```text
w:                  <- 0

```

### $2005 (PPUSCROLL) first write (w is 0)

```text
t: ....... ...ABCDE <- d: ABCDE...
x:              FGH <- d: .....FGH
w:                  <- 1

```

Note that w is shared between $2005 and $2006. For a worked example of interleaving writes to both, see § Details

### $2005 (PPUSCROLL) second write (w is 1)

```text
t: FGH..AB CDE..... <- d: ABCDEFGH
w:                  <- 0

```

### $2006 (PPUADDR) first write (w is 0)

```text
t: .CDEFGH ........ <- d: ..CDEFGH
       <unused>     <- d: AB......
t: Z...... ........ <- 0 (bit Z is cleared)
w:                  <- 1

```

### $2006 (PPUADDR) second write (w is 1)

```text
t: ....... ABCDEFGH <- d: ABCDEFGH
w:                  <- 0
   (wait 1 to 1.5 dots after the write completes)
v: <...all bits...> <- t: <...all bits...>

```

### $2007 (PPUDATA) reads and writes

Outside of rendering, reads from or writes to $2007 will add either 1 or 32 to v depending on the VRAM increment bit set via $2000. During rendering (on the pre-render line and the visible lines 0-239, provided either background or sprite rendering is enabled), it will update v in an odd way, triggering a coarse X incrementand a Y incrementsimultaneously (with normal wrapping behavior). Internally, this is caused by the carry inputs to various sections of v being set up for rendering, and the $2007 access triggering a "load next value" signal for all of v (when not rendering, the carry inputs are set up to linearly increment v by either 1 or 32). This behavior is not affected by the status of the increment bit. The Young Indiana Jones Chronicles uses this for some effects to adjust the Y scroll during rendering, and also Burai Fighter (U) to draw the scorebar. If the $2007 access happens to coincide with a standard VRAM address increment (either horizontal or vertical), it will presumably not double-increment the relevant counter.

### At dot 256 of each scanline

If rendering is enabled, the PPU increments the vertical position in v . The effective Y scroll coordinate is incremented, which is a complex operation that will correctly skip the attribute table memory regions, and wrap to the next nametable appropriately. See Wrapping aroundbelow.

### At dot 257 of each scanline

If rendering is enabled, the PPU copies all bits related to horizontal position from t to v :

```text
v: ....A.. ...BCDEF <- t: ....A.. ...BCDEF

```

### During dots 280 to 304 of the pre-render scanline (end of vblank)

If rendering is enabled, at the end of vblank, shortly after the horizontal bits are copied from t to v at dot 257, the PPU will repeatedly copy the vertical bits from t to v from dots 280 to 304, completing the full initialization of v from t :

```text
v: GHIA.BC DEF..... <- t: GHIA.BC DEF.....

```

### Between dot 328 of a scanline, and 256 of the next scanline

If rendering is enabled, the PPU increments the horizontal position in v many times across the scanline, it begins at dots 328 and 336, and will continue through the next scanline at 8, 16, 24... 240, 248, 256 (every 8 dots across the scanline until 256). Across the scanline the effective coarse X scroll coordinate is incremented repeatedly, which will also wrap to the next nametable appropriately. See Wrapping aroundbelow.

### Explanation
- The implementation of scrolling has two components. There are two fine offsets, specifying what part of an 8x8 tile each pixel falls on, and two coarse offsets, specifying which tile. Because each tile corresponds to a single byte addressable by the PPU, during rendering the coarse offsets reuse the same VRAM address register ( v ) that is normally used to send and receive data from the PPU. Because of this reuse, the two registers $2005 and $2006 both offer control over v , but $2005 is mapped in a more obscure way, designed specifically to be convenient for scrolling.
- $2006 is simply to set the VRAM address register. This is why the second write will immediately set v ; it is expected you will immediately use this address to send data to the PPU via $2007. The PPU memory space is only 14 bits wide, but v has an extra bit that is used for scrolling only. The first write to $2006 will clear this extra bit (for reasons not known).
- $2005 is designed to set the scroll position before the start of the frame. This is why it does not immediately set v , so that it can be set at precisely the right time to start rendering the screen.
- The high 5 bits of the X and Y scroll settings sent to $2005, when combined with the 2 nametable select bits sent to $2000, make a 12 bit address for the next tile to be fetched within the nametable address space $2000-2FFF. If set before the end of vblank, this 12 bit address gets loaded directly into v precisely when it is needed to fetch the tile for the top left pixel to render.
- The low 3 bits of X sent to $2005 (first write) control the fine pixel offset within the 8x8 tile. The low 3 bits goes into the separate x register, which just selects one of 8 pixels coming out of a set of shift registers. This fine X value does not change during rendering; the only thing that changes it is a $2005 first write.
- The low 3 bits of Y sent to $2005 (second write) control the vertical pixel offset within the 8x8 tile. The low 3 bits goes into the high 3 bits of the v register, where during rendering they are not used as part of the PPU memory address (which is being overridden to use the nametable space $2000-2FFF). Instead they count the lines until the coarse Y memory address needs to be incremented (and wrapped appropriately when nametable boundaries are crossed).

See also: PPU Frame timing

### Summary

The following diagram illustrates how several different actions may update the various internal registers related to scrolling. See Examplesbelow for usage examples.

| Action | Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| (PPUCTRL) $2000 write | ....... ........ | ....... ........ | ... | . | LDA #$00 (%00000000)STA $2000 | ...00.. ........ | ....... ........ | ... | . |  |

| (PPUSTATUS) $2002 read | ...00.. ........ | ....... ........ | ... | . | LDA $2002 | ...00.. ........ | ....... ........ | ... | 0 | Resets paired write latch w to 0. |

| (PPUSCROLL) $2005 write 1 | ...00.. ........ | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | ...00.. ...01111 | ....... ........ | 101 | 1 |  |

| (PPUSCROLL) $2005 write 2 | ...00.. ...01111 | ....... ........ | 101 | 1 | LDA #$5E (%01011110)STA $2005 | 1100001 01101111 | ....... ........ | 101 | 0 |  |

| (PPUADDR) $2006 write 1 | 1100001 01101111 | ....... ........ | 101 | 0 | LDA #$3D (%00111101)STA $2006 | 0111101 01101111 | ....... ........ | 101 | 1 | Bit 14 (15th bit) of t gets set to zero |

| (PPUADDR) $2006 write 2 | 0111101 01101111 | ....... ........ | 101 | 1 | LDA #$F0 (%11110000)STA $2006 | 0111101 11110000 | 0111101 11110000 | 101 | 0 | After t is updated, contents of t copied into v |

## Wrapping around

The following pseudocode examples explain how wrapping is performed when incrementing components of v . This code is written for clarity, and is not optimized for speed.

### Coarse X increment

The coarse X component of v needs to be incremented when the next tile is reached. Bits 0-4 are incremented, with overflow toggling bit 10. This means that bits 0-4 count from 0 to 31 across a single nametable, and bit 10 selects the current nametable horizontally.

```text
if ((v & 0x001F) == 31) // if coarse X == 31
  v &= ~0x001F          // coarse X = 0
  v ^= 0x0400           // switch horizontal nametable
else
  v += 1                // increment coarse X

```

### Y increment

If rendering is enabled, fine Y is incremented at dot 256 of each scanline, overflowing to coarse Y, and finally adjusted to wrap among the nametables vertically.

Bits 12-14 are fine Y. Bits 5-9 are coarse Y. Bit 11 selects the vertical nametable.

```text
if ((v & 0x7000) != 0x7000)        // if fine Y < 7
  v += 0x1000                      // increment fine Y
else
  v &= ~0x7000                     // fine Y = 0
  int y = (v & 0x03E0) >> 5        // let y = coarse Y
  if (y == 29)
    y = 0                          // coarse Y = 0
    v ^= 0x0800                    // switch vertical nametable
  else if (y == 31)
    y = 0                          // coarse Y = 0, nametable not switched
  else
    y += 1                         // increment coarse Y
  v = (v & ~0x03E0) | (y << 5)     // put coarse Y back into v

```

Row 29 is the last row of tiles in a nametable. To wrap to the next nametable when incrementing coarse Y from 29, the vertical nametable is switched by toggling bit 11, and coarse Y wraps to row 0.

Coarse Y can be set out of bounds (> 29), which will cause the PPU to read the attribute data stored there as tile data. If coarse Y is incremented from 31, it will wrap to 0, but the nametable will not switch. For this reason, a write >= 240 to $2005 may appear as a "negative" scroll value, where 1 or 2 rows of attribute data will appear before the nametable's tile data is reached. (Some games use this to move the top of the nametable out of the Overscanarea.)

### Tile and attribute fetching

The high bits of v are used for fine Y during rendering, and addressing nametable data only requires 12 bits, with the high 2 CHR address lines fixed to the 0x2000 region. The address to be fetched during rendering can be deduced from v in the following way:

```text
 tile address      = 0x2000 | (v & 0x0FFF)
 attribute address = 0x23C0 | (v & 0x0C00) | ((v >> 4) & 0x38) | ((v >> 2) & 0x07)

```

The low 12 bits of the attribute address are composed in the following way:

```text
 NN 1111 YYY XXX
 || |||| ||| +++-- high 3 bits of coarse X (x/4)
 || |||| +++------ high 3 bits of coarse Y (y/4)
 || ++++---------- attribute offset (960 bytes)
 ++--------------- nametable select

```

## Examples

### Single scroll

If only one scroll setting is needed for the entire screen, this can be done by writing $2000 once, and $2005 twice before the end of vblank.
- The low two bits of $2000 select which of the four nametables to use.
- The first write to $2005 specifies the X scroll, in pixels.
- The second write to $2005 specifies the Y scroll, in pixels.

This should be done after writes to $2006 are completed, because they overwrite the t register. The v register will be completely copied from t at the end of vblank, setting the scroll.

Note that the series of two writes to $2005 presumes the toggle that specifies which write is taking place. If the state of the toggle is unknown, reset it by reading from $2002 before the first write to $2005.

Instead of writing $2000, the first write to $2006 can be used to select the nametable, if this happens to be more convenient (usually it is not because it will toggle w ).

### Split X scroll

The X scroll can be changed at the end of any scanline when the horizontal components of v get reloaded from t : Simply make writes to $2000/$2005 before the end of the line.
- The first write to $2005 alters the horizontal scroll position. The fine x register (sub-tile offset) gets updated immediately, but the coarse horizontal component of t (tile offset) does not get updated until the end of the line.
- An optional second write to $2005 is inconsequential; the changes it makes to t will be ignored at the end of the line. However, it will reset the write toggle w for any subsequent splits.
- Write to $2000 if needed to set the high bit of X scroll, which is controlled by bit 0 of the value written. Writing $2000 changes other rendering propertiesas well, so make sure the other bits are set appropriately.

Like the single scroll example, reset the toggle by reading $2002 if it is in an unknown state. Since a write to $2005 and a read from $2002 are equally expensive in both bytes and time, whether you use one or the other to prepare for subsequent screen splits is up to you.

The first write to $2005 should usually be made as close to the end of the line as possible, but before the start of hblank when the coarse x scroll is copied from t to v . Because about 4 pixels of timing jitter are normally unavoidable, $2005 should be written a little bit early (once hblank begins, it is too late). The resulting glitch at the end of the line can be concealed by a line of one colour pixels or a sprite.

It is also possible to completely hide this glitch by first writing a combination of the new coarse X and old fine X to a mirror of $2005 before dot 257, then writing the entire new X to $2005 between dot 257 and the end of the scanline. On certain alignments, the PPU will use the contents of open bus to set fine X for one pixel. Thus the correct mirror to use is one where the lowest 3 bits of its upper byte matches the lowest 3 bits of the value you're writing. e.g. Write %xxxxx000 to $2005, write %xxxxx001 to $2105, etc.

The code may look like this:

```text
  lda new_x  ; Combine bits 7-3 of new X with 2-0 of old X
  eor old_x
  and #%11111000
  eor old_x
  sta $2005  ; Write old fine X and new coarse X
  bit $2002  ; Clear first/second write toggle
  lda new_x
  sta old_x
  nop        ; Wait for the next write to land in hblank
  nop
  sta $2005  ; Write entire new X
  bit $2002  ; Clear first/second write toggle

```

For more flexible control, the following more advanced X/Y scroll technique could be used to update v during hblank instead.

### Split X/Y scroll

Cleanly setting the complete scroll position (X and Y) mid-screen takes four writes:
- Nametable number << 2 (that is: $00, $04, $08, or $0C) to $2006
- Y to $2005
- X to $2005
- Low byte of nametable address to $2006, which is ((Y & $F8) << 2) | (X >> 3)

The last two writes should occur during horizontal blanking (cycle 256 or later) to avoid visual errors. (Because of right overscanand the background pixel pipeline, it may be acceptable to land the third write as early as cycle 252.)

The code may look like this:

```text
; The first two PPU writes can come anytime during the scanline:
; Nametable number << 2 to $2006.
lda new_nametable_x
lsr
lda new_nametable_y
rol
asl
asl
sta $2006

; Y position to $2005.
lda new_y
sta $2005

; Prepare for the 2 later writes:
; We reuse new_x to hold (Y & $F8) << 2.
and #%11111000
asl
asl
ldx new_x  ; X position in X for $2005 later.
sta new_x

; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
txa
lsr
lsr
lsr
ora new_x

; Burn cycles until start of hblank
; (Adjust for your application)
nop
nop

; The last two PPU writes must happen during hblank:
stx $2005
sta $2006

; Restore new_x.
stx new_x

```

#### Details

To split both the X and Y scroll on a scanline, we must perform four writes to $2006 and $2005 alternately in order to completely reload v . Without the second write to $2006, only the horizontal portion of v will loaded from t at the end of the scanline. By writing twice to $2006, the second write causes an immediate full reload of v from t , allowing you to update the vertical scroll in the middle of the screen. Because of the background pattern FIFO, the visible effect of a mid-scanline write is delayed by 1 to 2 tiles.

The writes to PPU registers are done in the order of $2006, $2005, $2005, $2006. This order of writes is important, understanding that the write toggle for $2005 is shared with $2006. As always, if the state of the toggle is unknown before beginning, read $2002 to reset it.

In this example we will perform two writes to each of $2005 and $2006. We will set the X scroll (X), Y scroll (Y), and nametable select (N) by writes to $2005 and $2006. Repeating the above summaries:

```text
N: %01
X: %01111101 = $7D
Y: %00111110 = $3E

```

```text
$2005 (w=0) = X                                                          = %01111101 = $7D
$2005 (w=1) = Y                                                          = %00111110 = $3E
$2006 (w=0) = ((Y & %11000000) >> 6) | ((Y & %00000011) << 4) | (N << 2) = %00010100 = $14
$2006 (w=1) = ((X & %11111000) >> 3) | ((Y & %00111000) << 2)            = %11101111 = $EF

```

However, since there is a great deal of overlap between the data sent to $2005 and $2006, only the last write to any particular bit of t matters. This makes the first write to $2006 mostly redundant, and we can simplify its setup significantly:

```text
$2006 (w=0) = N << 2                                                     = %00000100 = $04

```

There are other redundancies in the writes to $2005, but since it is likely the original X and Y values are already available, these can be left as an exercise for the reader.

| Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| ....... ........ | ....... ........ | ... | 0 | LDA #$04 (%00000100)STA $2006 | 0000100 ........ | ....... ........ | ... | 1 | Bit 14 of t set to zero |

| 0000100 ........ | ....... ........ | ... | 1 | LDA #$3E (%00111110)STA $2005 | 1100100 111..... | ....... ........ | ... | 0 | Behaviour of 2nd $2005 write |

| 1100100 111..... | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | 1100100 11101111 | ....... ........ | 101 | 1 | Behaviour of 1st $2005 write |

| 1100100 11101111 | ....... ........ | 101 | 1 | LDA #$EF (%11101111)STA $2006 | 1100100 11101111 | 1100100 11101111 | 101 | 0 | After t is updated, contents of t copied into v |

Timing for this series of writes is important. Because the Y scroll in v will be incremented at dot 256, you must either set it to the intended Y-1 before dot 256, or set it to Y after dot 256. Many games that use split scrolling have a visible glitch at the end of the line by timing it early like this.

Alternatively you can set the intended Y after dot 256. The last two writes ($2005 (w=0) / $2006 (w=1)) can be timed to fall within hblank to avoid any visible glitch. Hblank begins after dot 256, and ends at dot 320 when the first tile of the next line is fetched.

Because this method sets v immediately, it can be used to set the scroll in the middle of the line. This is not normally recommended, as the difficulty of exact timing and interaction of tile fetches makes it difficult to do cleanly.

### Quick coarse X/Y split

Since it is the write to $2006 when w =1 that transfers the contents of t to v , it is not strictly necessary to perform all 4 writes as above, so long as one is willing to accept some trade-offs.

For example, if you only write to $2006 twice, you can update coarse X, coarse Y, N, and the bottom 2 bits of fine y. The top bit of fine y is cleared, and fine x is unchanged.

$2006's contents are in the same order as t , so you can affect the bits as:

```text
   First      Second
/¯¯¯¯¯¯¯¯¯\ /¯¯¯¯¯¯¯\
0 0yy NN YY YYY XXXXX
  ||| || || ||| +++++-- coarse X scroll
  ||| || ++-+++-------- coarse Y scroll
  ||| ++--------------- nametable select
  +++------------------ fine Y scroll

```

## See Also
- PPU rendering
- PPU sprite evaluation
- Palette change mid frame
- Errata

## References
- The skinny on NES scrollingoriginal document by loopy, 1999-04-13
- Drag's X/Y scrolling examplefrom the forums
- VRAM address registerchip photograph analysis by Quietust

# PPU OAM

Source: https://www.nesdev.org/wiki/Sprite-0_hit

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

# Sprite cel streaming

Source: https://www.nesdev.org/wiki/Sprite_cel_streaming

Sprite cel streaming is a method of animating sprites in games using CHR RAM. When the game wants to change to a new cel (frame of animation), the game copies the cel from PRG ROM to CHR RAM during vertical blanking. Normally, about 8 tiles (128 bytes) can be copied this way in a single NTSC vblank.

Games known to use streaming:
- Battletoads streams the player 1 and 2 sprites and turns rendering on late to increase bandwidth to CHR RAM.
- Solstice not only streams the sprites of Shadax but also clips them against the shape of the background in software.
- Haunted: Halloween '85 reserves two 16-tile buffers for each of six actors, one for the current frame and one for the next. Whenever the video memory transfer buffer isn't in use, the game predicts the next frame for each sprite based on the current one. For example, the most common frame in a walk is the next in the same walk cycle, and the most common frame after a punch or other attack is the next attack in the combo. Thus if most changes are predicted accurately, there's less of a bottleneck in loading the frame when prediction occasionally fails.
- Astérix
- The Lion King

# Sprite overflow games

Source: https://www.nesdev.org/wiki/Sprite_overflow_games

The following is a list of games which rely on putting more than 8 sprites on a scanline.

## Use of sprite overflow flag

The sprite overflow flag is rarely used, mainly due to bugs when exactly 8 sprites are present on a scanline. No games rely on the buggy behavior. See sprite overflow bugfor more details.

Nonetheless, games can intentionally place 9 or more sprites in a scanline to trigger the overflow flag consistently, as long as no previous scanlines have exactly 8 sprites.

### Commercial
- Bee 52 : At the title screen, the game splits the screen with sprite overflow (at scanline 165), then splits the screen with a sprite 0 hit (at scanline 207). If sprite overflow is not emulated, the game will crash at a solid blue-purple screen.

### Homebrew
- blargg's sprite overflow test ROMs: tests behavior of sprite overflow, including the buggy behavior.
- City Trouble uses both the sprite overflow flag and the sprite 0 flag to make two scroll splits.

## Use of excess sprites for masking effects

Some games intentionally place multiple blank sprites early in the OAMat the same Y position so that other sprites on those scanlines are hidden.

### Commercial
- Castlevania II: Simon's Quest (a.k.a. Dracula 2 ): When Simon enters a swamp, the lower half of his body should be hidden. [1]
- Felix the Cat : When entering or exiting a bag.
- Gimmick! : When entering a level. Also used to keep extra sprites out of the status bar.
- Gremlins 2 - The New Batch : Uses multiple blank sprites to mask rows during cutscenes.
- Majou Densetsu II: Daimashikyou Galious : When entering a doorway, Popolon's body should gradually disappear (to imitate walking down stairs). [2]
- Ninja Gaiden 1, 2 and 3 : All sprites in all cutscenes should be confined inside the black background borders.
- The Legend of Zelda (a.k.a. Zelda 1 , Zeruda no Densetsu ): On the top or bottom of dungeon screens.

### Homebrew
- Lizard hides sprites overlapping the pause overlay while the game is paused.

### Detecting masking effects

Games will place 8 consecutive sprites with the same Y coordinate and same tile number. If you see this, then that is a sign that the game is using a masking effect, and the 8-sprite limit should be enforced for that area.

## Misc

### Commercial
- Solstice : during the intro cutscene, there are stray sprites on the screen beyond the 8 per scanline, but the NES won't display the excess sprites. This is not a masking effect, it is merely the hardware covering up a mistake that wasn't caught by the original programmers.

## References
- ↑BBS topicwith screenshots of Castlevania II: Simon's Quest .
- ↑Youtube videodemonstrating the effect on Majou Densetsu II: Daimashikyou Galious .

# PPU sprite priority

Source: https://www.nesdev.org/wiki/Sprite_priority

In the NES PPU, sprites may overlap each other and the background. The PPU decides what pixel to display based on priority rules. Each sprite has two values that affect priority: the index of the sprite within OAM(0 to 63), and the sprite-to-background priority bit ( attributebit 5, set to 0 for front or 1 for back).

In short:
- Sprites with lower OAM indices are drawn in front. For example, sprite 0 is in front of sprite 1, which is in front of sprite 63.
- At any given pixel, if the frontmost opaque sprite's priority bit is true (1), an opaque background pixel is drawn in front of it.

Putting a back-priority sprite at a lower OAM index than a front-priority sprite can cover up the the front-priority sprite and let the background show through. Super Mario Bros. 3 uses thisfor power-ups sprouting from blocks, by putting a non-transparent back-priority sprite "behind" the block at a low index and putting the power-up at a higher index. (You can see the corners of the back-priority sprite when Mario hits a note block in World 1-2, as the note block becomes more squared off.) The advantage of this approach is that the power-up can be hidden behind the block and still have front priority, meaning the area above the block doesn't have to be pure bg pixels like in Super Mario Bros.

The Nintendo DS PPU handles priority the "obvious" way, [1]and some NES emulator developers incorrectly think the NES PPU handles it the same manner, i.e.:
- Front priority sprites in front
- The background plane in the middle
- Back priority sprites in back

What really happens in the NES PPU is conceptually more like this:
- During sprite evaluationfor each scanline (cycles 65 through 240), the PPU searches for the eight frontmost sprites on this line. Then during sprite pattern fetch (cycles 257 to 320), these eight sprites get drawn front (lower index) to back (higher index) into a buffer, taking only the first opaque pixel that matches each X coordinate. Priority does not affect ordering in this buffer but is saved with each pixel.
- The background gets drawn to a separate buffer.
- For each pixel in the background buffer, the corresponding sprite pixel replaces it only if the sprite pixel is opaque and front priority or if the background pixel is transparent.

The buffers don't actually exist as full-scanline buffers inside the PPU but instead as a set of counters and shift registers. The above logic is implemented a pixel at a time, as PPU renderingexplains.

## Detailed internals of the sprite priority quirk

During sprite evaluation the PPU copies the sprites that are in y range from the primary to the secondary OAM, from which eight internal sprite output units are then initialized. These sprite output units are wired such that the lowest-numbered unit that outputs a non-transparent pixel always wins, regardless of front/back sprite priority and regardless of what the background pixel at the corresponding location is.

Hence, when a back-priority sprite is hidden behind non-bg background pixels, it will still hide output from higher-numbered sprite output units wherever it has a non-transparent pixel.

## References
- ↑GBATEK reference: DS Video OBJs

# Sprite size

Source: https://www.nesdev.org/wiki/Sprite_size

The NES PPU offers the choice of 8x8 pixel or 8x16 pixel sprites. Each size has its advantages.

## Advantages of 8x8

If the majority of your objects fit in an 8x8 pixel sprite, choose 8x8. These might include tiny bullets, puffs of smoke, or puzzle pieces. Drawing, say, a 4x4 pixel bullet with an 8x16 pixel sprite would waste pattern table space and increase potential for dropout or flicker on adjacent scanlines.

Some very detailed sprite animations are easier to do in 8x8. For example, 8x8 is more amenable to animating just the legs in an RPG character's walk cycle while reusing the head tiles. An overlay to add more colors to a small area, as in Mega Man series, causes flicker on fewer lines. And it's possible to simulate small amounts of rotation by shearing the sprite, moving individual 8-pixel chunks 1 pixel at a time.

The NES has no way to put a sprite half off the top of the screen, other than by using a top status bar and hiding sprites in $2001while the status bar is being displayed. Sprites entering or leaving have to enter or leave all at once, and this is especially visible on a PAL NES. So 8x8 sprites help diminish this pop-on effect.

Super Mario Bros. 3 uses 8x16 sprites, and some of the enemies inherited from the original Super Mario Bros. had to be modified to fit this. Blooper (the squid), for example, is 24 pixels tall in the original but had to be redrawn smaller for SMB3 .

## Advantages of 8x16

The NES supports 64 8x8 sprites or 64 8x16 sprites. This means 8x16 sprites can cover a larger area of the screen.

Using 8x16 pixel sprites can sometimes save CPU time. Say a game has four characters, each 32x16 pixels in size. It takes more time to write 32 entries to a display list than to write 16.

Some games, such as Crystal Mines (and its retreads Exodus and Joshua ), repeatedly switch game objects from being part of the background to being sprites and back so that they can temporarily leave the tile grid. Super Mario Bros. 2 likewise does this for the mushroom blocks, keys, and the like. Because 8x16 sprites can use both pattern tables, an object can use the same tiles whether it is rendered as background or as sprites. This causes a problem, however, for games using a scanline counter clocked by PA12 like that of the MMC3because fetching from both pattern tables causes extra rises in PA12, which confuses the counter circuit.

The NES supports 4 KiB for the background and 4 KiB for sprites. MMC5, however, has a 12K CHR mode that replaces background patterns with a third pattern table during sprite fetch time in horizontal blanking. This mode works only with 8x16 sprites because 8x8 sprites can use only one pattern table at a time.

Alfred Chicken , Incredible Crash Dummies , Teenage Mutant Ninja Turtles , and Zelda II use a trick to completely hide attribute glitches when scrolling horizontally with horizontally mirrored nametablesthat involves placing a column of black sprites at x=248. This is practical only with 8x16 sprites, as it needs 15 8x16 sprites or 30 8x8 sprites to cover the entire screen height.

## External links
- BBS discussion:
  - Topics 1473, 3649, 4622, 6194, 6223, and 10324
  - Sprite shearing

# PPU scrolling

Source: https://www.nesdev.org/wiki/The_skinny_on_NES_scrolling

Scrolling is the movement of the displayed portion of the map. Games scroll to show an area much larger than the 256x240 pixel screen. For example, areas in Super Mario Bros. are many screens wide. The NES's first major improvement over its immediate predecessors (ColecoVision and Sega SG-1000) was pixel-level scrolling of playfields.

## The common case

Ordinarily, a program writes to two PPU registersto set the scroll position in its NMI handler:
- Find the 9-bit X and Y coordinates of the upper left corner of the visible area (the part seen by the "camera")
- Write the lower 8 bits of the X coordinate to PPUSCROLL($2005)
- Write the lower 8 bits of the Y coordinate to PPUSCROLL
- Write the 9th bit of X and Y to bits 0 and 1, respectively, of PPUCTRL($2000)
  - This is the nametable that's visible in the top-left corner

The scroll position written to PPUSCROLL is applied at the end of vertical blanking, just before rendering begins, therefore these writes need to occur before the end of vblank. Also, because writes to PPUADDR($2006) can overwrite the scroll position, the two writes to PPUSCROLL and the write to PPUCTRL must be done after any updates to VRAM using PPUADDR.

By itself, this allows moving the camera within a usually two-screen area (see Mirroring), with horizontal and vertical wraparound if the camera goes out of bounds. To scroll over a larger area than the two screens that are already in VRAM, you choose appropriate offscreen columns or rows of the nametable, and you write that to VRAM before you set the scroll, as seen in the animation below. The area that needs rewritten at any given time is sometimes called the "seam" of the scroll.

### Frequent pitfalls
Don't take too long If your NMI handler routine takes too long and PPUSCROLL ($2005) is not set before the end of vblank, the scroll will not be correctly applied this frame. Most games do not write more than 64 bytes to the nametable per NMI; more than this may require advanced techniques to fit this narrow window of time. Set the scroll last After using PPUADDR ($2006), the program must always set PPUCTRL and PPUSCROLL again. They have a shared internal register and using PPUADDR will overwrite the scroll position.

## PPU internal registers

If the screen does not use split-scrolling, setting the position of the background requires only writing the X and Y coordinates to $2005 and the high bit of both coordinates to $2000.

Programming or emulating a game that uses complex raster effects, on the other hand, requires a complete understanding of how the various address registers inside the PPU work.

Here are the related registers: v Current VRAM address (15 bits) t Temporary VRAM address (15 bits); can also be thought of as the address of the top left onscreen tile. x Fine X scroll (3 bits) w First or second write toggle (1 bit)

The PPU uses the current VRAM address for both reading and writing PPU memory thru $2007, and for fetching nametable data to draw the background. As it's drawing the background, it updates the address to point to the nametable data currently being drawn. Bits 10-11 hold the base address of the nametable minus $2000. Bits 12-14 are the Y offset of a scanline within a tile.

The 15 bit registers t and v are composed this way during rendering:

```text
yyy NN YYYYY XXXXX
||| || ||||| +++++-- coarse X scroll
||| || +++++-------- coarse Y scroll
||| ++-------------- nametable select
+++----------------- fine Y scroll

```

Note that while the v register has 15 bits, the PPU memory spaceis only 14 bits wide. The highest bit is unused for access through $2007.

## Register controls

In the following, d refers to the data written to the port, and A through H to individual bits of a value.

$2005 and $2006 share a common write toggle w , so that the first write has one behaviour, and the second write has another. After the second write, the toggle is reset to the first write behaviour. This toggle may be manually reset by reading $2002.

### $2000 (PPUCTRL) write

```text
t: ...GH.. ........ <- d: ......GH
   <used elsewhere> <- d: ABCDEF..

```

### $2002 (PPUSTATUS) read

```text
w:                  <- 0

```

### $2005 (PPUSCROLL) first write (w is 0)

```text
t: ....... ...ABCDE <- d: ABCDE...
x:              FGH <- d: .....FGH
w:                  <- 1

```

Note that w is shared between $2005 and $2006. For a worked example of interleaving writes to both, see § Details

### $2005 (PPUSCROLL) second write (w is 1)

```text
t: FGH..AB CDE..... <- d: ABCDEFGH
w:                  <- 0

```

### $2006 (PPUADDR) first write (w is 0)

```text
t: .CDEFGH ........ <- d: ..CDEFGH
       <unused>     <- d: AB......
t: Z...... ........ <- 0 (bit Z is cleared)
w:                  <- 1

```

### $2006 (PPUADDR) second write (w is 1)

```text
t: ....... ABCDEFGH <- d: ABCDEFGH
w:                  <- 0
   (wait 1 to 1.5 dots after the write completes)
v: <...all bits...> <- t: <...all bits...>

```

### $2007 (PPUDATA) reads and writes

Outside of rendering, reads from or writes to $2007 will add either 1 or 32 to v depending on the VRAM increment bit set via $2000. During rendering (on the pre-render line and the visible lines 0-239, provided either background or sprite rendering is enabled), it will update v in an odd way, triggering a coarse X incrementand a Y incrementsimultaneously (with normal wrapping behavior). Internally, this is caused by the carry inputs to various sections of v being set up for rendering, and the $2007 access triggering a "load next value" signal for all of v (when not rendering, the carry inputs are set up to linearly increment v by either 1 or 32). This behavior is not affected by the status of the increment bit. The Young Indiana Jones Chronicles uses this for some effects to adjust the Y scroll during rendering, and also Burai Fighter (U) to draw the scorebar. If the $2007 access happens to coincide with a standard VRAM address increment (either horizontal or vertical), it will presumably not double-increment the relevant counter.

### At dot 256 of each scanline

If rendering is enabled, the PPU increments the vertical position in v . The effective Y scroll coordinate is incremented, which is a complex operation that will correctly skip the attribute table memory regions, and wrap to the next nametable appropriately. See Wrapping aroundbelow.

### At dot 257 of each scanline

If rendering is enabled, the PPU copies all bits related to horizontal position from t to v :

```text
v: ....A.. ...BCDEF <- t: ....A.. ...BCDEF

```

### During dots 280 to 304 of the pre-render scanline (end of vblank)

If rendering is enabled, at the end of vblank, shortly after the horizontal bits are copied from t to v at dot 257, the PPU will repeatedly copy the vertical bits from t to v from dots 280 to 304, completing the full initialization of v from t :

```text
v: GHIA.BC DEF..... <- t: GHIA.BC DEF.....

```

### Between dot 328 of a scanline, and 256 of the next scanline

If rendering is enabled, the PPU increments the horizontal position in v many times across the scanline, it begins at dots 328 and 336, and will continue through the next scanline at 8, 16, 24... 240, 248, 256 (every 8 dots across the scanline until 256). Across the scanline the effective coarse X scroll coordinate is incremented repeatedly, which will also wrap to the next nametable appropriately. See Wrapping aroundbelow.

### Explanation
- The implementation of scrolling has two components. There are two fine offsets, specifying what part of an 8x8 tile each pixel falls on, and two coarse offsets, specifying which tile. Because each tile corresponds to a single byte addressable by the PPU, during rendering the coarse offsets reuse the same VRAM address register ( v ) that is normally used to send and receive data from the PPU. Because of this reuse, the two registers $2005 and $2006 both offer control over v , but $2005 is mapped in a more obscure way, designed specifically to be convenient for scrolling.
- $2006 is simply to set the VRAM address register. This is why the second write will immediately set v ; it is expected you will immediately use this address to send data to the PPU via $2007. The PPU memory space is only 14 bits wide, but v has an extra bit that is used for scrolling only. The first write to $2006 will clear this extra bit (for reasons not known).
- $2005 is designed to set the scroll position before the start of the frame. This is why it does not immediately set v , so that it can be set at precisely the right time to start rendering the screen.
- The high 5 bits of the X and Y scroll settings sent to $2005, when combined with the 2 nametable select bits sent to $2000, make a 12 bit address for the next tile to be fetched within the nametable address space $2000-2FFF. If set before the end of vblank, this 12 bit address gets loaded directly into v precisely when it is needed to fetch the tile for the top left pixel to render.
- The low 3 bits of X sent to $2005 (first write) control the fine pixel offset within the 8x8 tile. The low 3 bits goes into the separate x register, which just selects one of 8 pixels coming out of a set of shift registers. This fine X value does not change during rendering; the only thing that changes it is a $2005 first write.
- The low 3 bits of Y sent to $2005 (second write) control the vertical pixel offset within the 8x8 tile. The low 3 bits goes into the high 3 bits of the v register, where during rendering they are not used as part of the PPU memory address (which is being overridden to use the nametable space $2000-2FFF). Instead they count the lines until the coarse Y memory address needs to be incremented (and wrapped appropriately when nametable boundaries are crossed).

See also: PPU Frame timing

### Summary

The following diagram illustrates how several different actions may update the various internal registers related to scrolling. See Examplesbelow for usage examples.

| Action | Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| (PPUCTRL) $2000 write | ....... ........ | ....... ........ | ... | . | LDA #$00 (%00000000)STA $2000 | ...00.. ........ | ....... ........ | ... | . |  |

| (PPUSTATUS) $2002 read | ...00.. ........ | ....... ........ | ... | . | LDA $2002 | ...00.. ........ | ....... ........ | ... | 0 | Resets paired write latch w to 0. |

| (PPUSCROLL) $2005 write 1 | ...00.. ........ | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | ...00.. ...01111 | ....... ........ | 101 | 1 |  |

| (PPUSCROLL) $2005 write 2 | ...00.. ...01111 | ....... ........ | 101 | 1 | LDA #$5E (%01011110)STA $2005 | 1100001 01101111 | ....... ........ | 101 | 0 |  |

| (PPUADDR) $2006 write 1 | 1100001 01101111 | ....... ........ | 101 | 0 | LDA #$3D (%00111101)STA $2006 | 0111101 01101111 | ....... ........ | 101 | 1 | Bit 14 (15th bit) of t gets set to zero |

| (PPUADDR) $2006 write 2 | 0111101 01101111 | ....... ........ | 101 | 1 | LDA #$F0 (%11110000)STA $2006 | 0111101 11110000 | 0111101 11110000 | 101 | 0 | After t is updated, contents of t copied into v |

## Wrapping around

The following pseudocode examples explain how wrapping is performed when incrementing components of v . This code is written for clarity, and is not optimized for speed.

### Coarse X increment

The coarse X component of v needs to be incremented when the next tile is reached. Bits 0-4 are incremented, with overflow toggling bit 10. This means that bits 0-4 count from 0 to 31 across a single nametable, and bit 10 selects the current nametable horizontally.

```text
if ((v & 0x001F) == 31) // if coarse X == 31
  v &= ~0x001F          // coarse X = 0
  v ^= 0x0400           // switch horizontal nametable
else
  v += 1                // increment coarse X

```

### Y increment

If rendering is enabled, fine Y is incremented at dot 256 of each scanline, overflowing to coarse Y, and finally adjusted to wrap among the nametables vertically.

Bits 12-14 are fine Y. Bits 5-9 are coarse Y. Bit 11 selects the vertical nametable.

```text
if ((v & 0x7000) != 0x7000)        // if fine Y < 7
  v += 0x1000                      // increment fine Y
else
  v &= ~0x7000                     // fine Y = 0
  int y = (v & 0x03E0) >> 5        // let y = coarse Y
  if (y == 29)
    y = 0                          // coarse Y = 0
    v ^= 0x0800                    // switch vertical nametable
  else if (y == 31)
    y = 0                          // coarse Y = 0, nametable not switched
  else
    y += 1                         // increment coarse Y
  v = (v & ~0x03E0) | (y << 5)     // put coarse Y back into v

```

Row 29 is the last row of tiles in a nametable. To wrap to the next nametable when incrementing coarse Y from 29, the vertical nametable is switched by toggling bit 11, and coarse Y wraps to row 0.

Coarse Y can be set out of bounds (> 29), which will cause the PPU to read the attribute data stored there as tile data. If coarse Y is incremented from 31, it will wrap to 0, but the nametable will not switch. For this reason, a write >= 240 to $2005 may appear as a "negative" scroll value, where 1 or 2 rows of attribute data will appear before the nametable's tile data is reached. (Some games use this to move the top of the nametable out of the Overscanarea.)

### Tile and attribute fetching

The high bits of v are used for fine Y during rendering, and addressing nametable data only requires 12 bits, with the high 2 CHR address lines fixed to the 0x2000 region. The address to be fetched during rendering can be deduced from v in the following way:

```text
 tile address      = 0x2000 | (v & 0x0FFF)
 attribute address = 0x23C0 | (v & 0x0C00) | ((v >> 4) & 0x38) | ((v >> 2) & 0x07)

```

The low 12 bits of the attribute address are composed in the following way:

```text
 NN 1111 YYY XXX
 || |||| ||| +++-- high 3 bits of coarse X (x/4)
 || |||| +++------ high 3 bits of coarse Y (y/4)
 || ++++---------- attribute offset (960 bytes)
 ++--------------- nametable select

```

## Examples

### Single scroll

If only one scroll setting is needed for the entire screen, this can be done by writing $2000 once, and $2005 twice before the end of vblank.
- The low two bits of $2000 select which of the four nametables to use.
- The first write to $2005 specifies the X scroll, in pixels.
- The second write to $2005 specifies the Y scroll, in pixels.

This should be done after writes to $2006 are completed, because they overwrite the t register. The v register will be completely copied from t at the end of vblank, setting the scroll.

Note that the series of two writes to $2005 presumes the toggle that specifies which write is taking place. If the state of the toggle is unknown, reset it by reading from $2002 before the first write to $2005.

Instead of writing $2000, the first write to $2006 can be used to select the nametable, if this happens to be more convenient (usually it is not because it will toggle w ).

### Split X scroll

The X scroll can be changed at the end of any scanline when the horizontal components of v get reloaded from t : Simply make writes to $2000/$2005 before the end of the line.
- The first write to $2005 alters the horizontal scroll position. The fine x register (sub-tile offset) gets updated immediately, but the coarse horizontal component of t (tile offset) does not get updated until the end of the line.
- An optional second write to $2005 is inconsequential; the changes it makes to t will be ignored at the end of the line. However, it will reset the write toggle w for any subsequent splits.
- Write to $2000 if needed to set the high bit of X scroll, which is controlled by bit 0 of the value written. Writing $2000 changes other rendering propertiesas well, so make sure the other bits are set appropriately.

Like the single scroll example, reset the toggle by reading $2002 if it is in an unknown state. Since a write to $2005 and a read from $2002 are equally expensive in both bytes and time, whether you use one or the other to prepare for subsequent screen splits is up to you.

The first write to $2005 should usually be made as close to the end of the line as possible, but before the start of hblank when the coarse x scroll is copied from t to v . Because about 4 pixels of timing jitter are normally unavoidable, $2005 should be written a little bit early (once hblank begins, it is too late). The resulting glitch at the end of the line can be concealed by a line of one colour pixels or a sprite.

It is also possible to completely hide this glitch by first writing a combination of the new coarse X and old fine X to a mirror of $2005 before dot 257, then writing the entire new X to $2005 between dot 257 and the end of the scanline. On certain alignments, the PPU will use the contents of open bus to set fine X for one pixel. Thus the correct mirror to use is one where the lowest 3 bits of its upper byte matches the lowest 3 bits of the value you're writing. e.g. Write %xxxxx000 to $2005, write %xxxxx001 to $2105, etc.

The code may look like this:

```text
  lda new_x  ; Combine bits 7-3 of new X with 2-0 of old X
  eor old_x
  and #%11111000
  eor old_x
  sta $2005  ; Write old fine X and new coarse X
  bit $2002  ; Clear first/second write toggle
  lda new_x
  sta old_x
  nop        ; Wait for the next write to land in hblank
  nop
  sta $2005  ; Write entire new X
  bit $2002  ; Clear first/second write toggle

```

For more flexible control, the following more advanced X/Y scroll technique could be used to update v during hblank instead.

### Split X/Y scroll

Cleanly setting the complete scroll position (X and Y) mid-screen takes four writes:
- Nametable number << 2 (that is: $00, $04, $08, or $0C) to $2006
- Y to $2005
- X to $2005
- Low byte of nametable address to $2006, which is ((Y & $F8) << 2) | (X >> 3)

The last two writes should occur during horizontal blanking (cycle 256 or later) to avoid visual errors. (Because of right overscanand the background pixel pipeline, it may be acceptable to land the third write as early as cycle 252.)

The code may look like this:

```text
; The first two PPU writes can come anytime during the scanline:
; Nametable number << 2 to $2006.
lda new_nametable_x
lsr
lda new_nametable_y
rol
asl
asl
sta $2006

; Y position to $2005.
lda new_y
sta $2005

; Prepare for the 2 later writes:
; We reuse new_x to hold (Y & $F8) << 2.
and #%11111000
asl
asl
ldx new_x  ; X position in X for $2005 later.
sta new_x

; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
txa
lsr
lsr
lsr
ora new_x

; Burn cycles until start of hblank
; (Adjust for your application)
nop
nop

; The last two PPU writes must happen during hblank:
stx $2005
sta $2006

; Restore new_x.
stx new_x

```

#### Details

To split both the X and Y scroll on a scanline, we must perform four writes to $2006 and $2005 alternately in order to completely reload v . Without the second write to $2006, only the horizontal portion of v will loaded from t at the end of the scanline. By writing twice to $2006, the second write causes an immediate full reload of v from t , allowing you to update the vertical scroll in the middle of the screen. Because of the background pattern FIFO, the visible effect of a mid-scanline write is delayed by 1 to 2 tiles.

The writes to PPU registers are done in the order of $2006, $2005, $2005, $2006. This order of writes is important, understanding that the write toggle for $2005 is shared with $2006. As always, if the state of the toggle is unknown before beginning, read $2002 to reset it.

In this example we will perform two writes to each of $2005 and $2006. We will set the X scroll (X), Y scroll (Y), and nametable select (N) by writes to $2005 and $2006. Repeating the above summaries:

```text
N: %01
X: %01111101 = $7D
Y: %00111110 = $3E

```

```text
$2005 (w=0) = X                                                          = %01111101 = $7D
$2005 (w=1) = Y                                                          = %00111110 = $3E
$2006 (w=0) = ((Y & %11000000) >> 6) | ((Y & %00000011) << 4) | (N << 2) = %00010100 = $14
$2006 (w=1) = ((X & %11111000) >> 3) | ((Y & %00111000) << 2)            = %11101111 = $EF

```

However, since there is a great deal of overlap between the data sent to $2005 and $2006, only the last write to any particular bit of t matters. This makes the first write to $2006 mostly redundant, and we can simplify its setup significantly:

```text
$2006 (w=0) = N << 2                                                     = %00000100 = $04

```

There are other redundancies in the writes to $2005, but since it is likely the original X and Y values are already available, these can be left as an exercise for the reader.

| Before | Instructions | After | Notes |
| t | v | x | w | t | v | x | w |

| ....... ........ | ....... ........ | ... | 0 | LDA #$04 (%00000100)STA $2006 | 0000100 ........ | ....... ........ | ... | 1 | Bit 14 of t set to zero |

| 0000100 ........ | ....... ........ | ... | 1 | LDA #$3E (%00111110)STA $2005 | 1100100 111..... | ....... ........ | ... | 0 | Behaviour of 2nd $2005 write |

| 1100100 111..... | ....... ........ | ... | 0 | LDA #$7D (%01111101)STA $2005 | 1100100 11101111 | ....... ........ | 101 | 1 | Behaviour of 1st $2005 write |

| 1100100 11101111 | ....... ........ | 101 | 1 | LDA #$EF (%11101111)STA $2006 | 1100100 11101111 | 1100100 11101111 | 101 | 0 | After t is updated, contents of t copied into v |

Timing for this series of writes is important. Because the Y scroll in v will be incremented at dot 256, you must either set it to the intended Y-1 before dot 256, or set it to Y after dot 256. Many games that use split scrolling have a visible glitch at the end of the line by timing it early like this.

Alternatively you can set the intended Y after dot 256. The last two writes ($2005 (w=0) / $2006 (w=1)) can be timed to fall within hblank to avoid any visible glitch. Hblank begins after dot 256, and ends at dot 320 when the first tile of the next line is fetched.

Because this method sets v immediately, it can be used to set the scroll in the middle of the line. This is not normally recommended, as the difficulty of exact timing and interaction of tile fetches makes it difficult to do cleanly.

### Quick coarse X/Y split

Since it is the write to $2006 when w =1 that transfers the contents of t to v , it is not strictly necessary to perform all 4 writes as above, so long as one is willing to accept some trade-offs.

For example, if you only write to $2006 twice, you can update coarse X, coarse Y, N, and the bottom 2 bits of fine y. The top bit of fine y is cleared, and fine x is unchanged.

$2006's contents are in the same order as t , so you can affect the bits as:

```text
   First      Second
/¯¯¯¯¯¯¯¯¯\ /¯¯¯¯¯¯¯\
0 0yy NN YY YYY XXXXX
  ||| || || ||| +++++-- coarse X scroll
  ||| || ++-+++-------- coarse Y scroll
  ||| ++--------------- nametable select
  +++------------------ fine Y scroll

```

## See Also
- PPU rendering
- PPU sprite evaluation
- Palette change mid frame
- Errata

## References
- The skinny on NES scrollingoriginal document by loopy, 1999-04-13
- Drag's X/Y scrolling examplefrom the forums
- VRAM address registerchip photograph analysis by Quietust

# VT01 STN Palette

Source: https://www.nesdev.org/wiki/VT01_STN_Palette

The V.R. Technology VT01 is a regular Famiclone whose only enhancement is the ability to drive particular types of STN displays directly. One of the supported STN displays uses red and cyan color components. When used with such a display, the six-bit color numbers that are written to CGRAM (PPU $3F00-$3F1F) have a different meaning compared to the normal RP2C02 palette:

```text
7654 3210
---- ----
..RR CC..
  || ++--- Cyan color component level, 0=darkest, 3=brightest
  ++------ Red color component level, 0=darkest, 3=brightest

```

Note that when displaying such a color palette on a normal computer screen, differences in contrast range and gamma should be taken into account. There are several ROM images available with the name prefix "Portable FC-LCD" that use color numbers according to this format. As most of the games on them are palette hacks of existing games, the unused bits 0 and 1 may occasionally be set as well. References
- VT01 Data Sheetfrom on V.R. Technology's website, in particular pages 2 and 10.
- Discussion

# VT03+ Enhanced Palette

Source: https://www.nesdev.org/wiki/VT03%2B_Enhanced_Palette

On the VT03 and later consoles, CGRAM is extended from the original RP2C02's 32 bytes (disregarding mirrored bytes) to 256 bytes.

Entries $3F10/$3F14/$3F18/$3F1C are still mirrors of $3F00/$3F04/$3F08/$3F0C, but all the others are not. Using a 4bpp video mode (bits 0 to 3), together with a bit selecting background or sprite index (bit 4) and two attribute bits (bits 5 and 6) yields a total of 128 palette indices, disregarding mirrored bytes.

## Regular 2C02 colors

If register $2010 bit 7 (COLCOMP) is cleared, the RP2C02's standard colors are available, even if 4bpp are used. The greater number of palette indices then allows for greater freedom in combining different colors. This method is used by Jungletac's games. Only the 128 bytes from $3F00-$3F7F are used in this case. The color numbers have the same format as on the RP2C02:

```text
7654 3210
---- ----
..LL HHHH
  || ++++- Hue number. 0=Bright gray (upper oscillation bound),
  ||                   1-12=Colored hues (blue->pink->red->yellow->green),
  ||                   13: Dark gray (lower oscillation bound),
  ||                   14-15: black.
  ++------ Combined luminance and saturation (0: darkest, 3: brightest).
           Colors are saturated for levels 0-2 and pastel-like for level 3.

```

## Extended colors

If register $2010 bit 7 (COLCOMP) is set, then an extended palette becomes available, where each color has twelve instead of six bits. $3F00-$3F7F hold the lower six bits of the color number, $3F80-$3FFF hold the upper six bits of the color number. These extended color numbers separate and expand luminance and saturation to four bits each:

```text
BA98 7654 3210
---- ---- ----
SSSS LLLL HHHH
|||| |||| ++++- Hue number. Same hues as when COLCOMP=0 (exceptions apply).
|||| ++++------ Luminance (0: darkest, F: brightest).
++++----------- Saturation (0: completely desaturated grays, F: maximum saturation).

```

## Inverted extended color numbers

The scheme for the extended color numbers as described in V.R. Technology's datasheet is not applied consistently throughout the entire value range. As saturation increases, more and more colors use an alternative, or inverted, addressing scheme. More precisely, with each increasing level of saturation, the number of luminance levels for which all hues are inverted increases by one, as seen in the following chart:

```text
Saturation	Inverted Luminance Levels	0123456789ABCDEF
0		-				................
1		0                               X...............
2		0 F                             X..............X
3		0,1 F                           XX.............X
4		0,1 E,F                         XX............XX
5 		0,1,2 E,F                       XXX...........XX
6		0,1,2 D,E,F                     XXX..........XXX
7		0,1,2,3 D,E,F                   XXXX.........XXX
8		0,1,2,3 C,D,E,F                 XXXX........XXXX
9		0,1,2,3,4 C,D,E,F               XXXXX.......XXXX
A		0,1,2,3,4 B,C,D,E,F             XXXXX......XXXXX
B		0,1,2,3,4,5 B,C,D,E,F           XXXXXX.....XXXXX
C		0,1,2,3,4,5 A,B,C,D,E,F         XXXXXX....XXXXXX
D		0,1,2,3,4,5,6 A,B,C,D,E,F       XXXXXXX...XXXXXX
E		0,1,2,3,4,5,6 9,A,B,C,D,E,F     XXXXXXX..XXXXXXX
F		0,1,2,3,4,5,6,7 9,A,B,C,D,E,F   XXXXXXXX.XXXXXXX

```

It is not known if this is by design or a mistake during chip design, but all VT03 games make use of these inverted color numbers as well as the non-inverted ones. The pattern can be described as follows:

```text
BOOL inverted = (LuminanceValue< (SaturationValue+1) >>1 || LuminanceValue> 15 -(ChromaValue >>1));

```

Inversion means that
- the saturation value is replaced with 16 minus the original value;
- the luminance value is replaced with (LuminanceValue -8) AND $0F;
- the hue value is replaced with:

```text
Original Hue   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
Replaced Hue   D   7   8   9   A   B   C   1   2   3   4   5   6   0   E   F

```

## Palette Chart

The following table shows the palette that is hard-coded into the EmuVT emulator, which it saves to HSL2RGB.TAB every time it is run:

| Saturation level $0 |
| $000 | $001 | $002 | $003 | $004 | $005 | $006 | $007 | $008 | $009 | $00A | $00B | $00C | $00D | $00E | $00F |
| $010 | $011 | $012 | $013 | $014 | $015 | $016 | $017 | $018 | $019 | $01A | $01B | $01C | $01D | $01E | $01F |
| $020 | $021 | $022 | $023 | $024 | $025 | $026 | $027 | $028 | $029 | $02A | $02B | $02C | $02D | $02E | $02F |
| $030 | $031 | $032 | $033 | $034 | $035 | $036 | $037 | $038 | $039 | $03A | $03B | $03C | $03D | $03E | $03F |
| $040 | $041 | $042 | $043 | $044 | $045 | $046 | $047 | $048 | $049 | $04A | $04B | $04C | $04D | $04E | $04F |
| $050 | $051 | $052 | $053 | $054 | $055 | $056 | $057 | $058 | $059 | $05A | $05B | $05C | $05D | $05E | $05F |
| $060 | $061 | $062 | $063 | $064 | $065 | $066 | $067 | $068 | $069 | $06A | $06B | $06C | $06D | $06E | $06F |
| $070 | $071 | $072 | $073 | $074 | $075 | $076 | $077 | $078 | $079 | $07A | $07B | $07C | $07D | $07E | $07F |
| $080 | $081 | $082 | $083 | $084 | $085 | $086 | $087 | $088 | $089 | $08A | $08B | $08C | $08D | $08E | $08F |
| $090 | $091 | $092 | $093 | $094 | $095 | $096 | $097 | $098 | $099 | $09A | $09B | $09C | $09D | $09E | $09F |
| $0A0 | $0A1 | $0A2 | $0A3 | $0A4 | $0A5 | $0A6 | $0A7 | $0A8 | $0A9 | $0AA | $0AB | $0AC | $0AD | $0AE | $0AF |
| $0B0 | $0B1 | $0B2 | $0B3 | $0B4 | $0B5 | $0B6 | $0B7 | $0B8 | $0B9 | $0BA | $0BB | $0BC | $0BD | $0BE | $0BF |
| $0C0 | $0C1 | $0C2 | $0C3 | $0C4 | $0C5 | $0C6 | $0C7 | $0C8 | $0C9 | $0CA | $0CB | $0CC | $0CD | $0CE | $0CF |
| $0D0 | $0D1 | $0D2 | $0D3 | $0D4 | $0D5 | $0D6 | $0D7 | $0D8 | $0D9 | $0DA | $0DB | $0DC | $0DD | $0DE | $0DF |
| $0E0 | $0E1 | $0E2 | $0E3 | $0E4 | $0E5 | $0E6 | $0E7 | $0E8 | $0E9 | $0EA | $0EB | $0EC | $0ED | $0EE | $0EF |
| $0F0 | $0F1 | $0F2 | $0F3 | $0F4 | $0F5 | $0F6 | $0F7 | $0F8 | $0F9 | $0FA | $0FB | $0FC | $0FD | $0FE | $0FF |
| Saturation level $1 |
| $100 | $101 | $102 | $103 | $104 | $105 | $106 | $107 | $108 | $109 | $10A | $10B | $10C | $10D | $10E | $10F |
| $110 | $111 | $112 | $113 | $114 | $115 | $116 | $117 | $118 | $119 | $11A | $11B | $11C | $11D | $11E | $11F |
| $120 | $121 | $122 | $123 | $124 | $125 | $126 | $127 | $128 | $129 | $12A | $12B | $12C | $12D | $12E | $12F |
| $130 | $131 | $132 | $133 | $134 | $135 | $136 | $137 | $138 | $139 | $13A | $13B | $13C | $13D | $13E | $13F |
| $140 | $141 | $142 | $143 | $144 | $145 | $146 | $147 | $148 | $149 | $14A | $14B | $14C | $14D | $14E | $14F |
| $150 | $151 | $152 | $153 | $154 | $155 | $156 | $157 | $158 | $159 | $15A | $15B | $15C | $15D | $15E | $15F |
| $160 | $161 | $162 | $163 | $164 | $165 | $166 | $167 | $168 | $169 | $16A | $16B | $16C | $16D | $16E | $16F |
| $170 | $171 | $172 | $173 | $174 | $175 | $176 | $177 | $178 | $179 | $17A | $17B | $17C | $17D | $17E | $17F |
| $180 | $181 | $182 | $183 | $184 | $185 | $186 | $187 | $188 | $189 | $18A | $18B | $18C | $18D | $18E | $18F |
| $190 | $191 | $192 | $193 | $194 | $195 | $196 | $197 | $198 | $199 | $19A | $19B | $19C | $19D | $19E | $19F |
| $1A0 | $1A1 | $1A2 | $1A3 | $1A4 | $1A5 | $1A6 | $1A7 | $1A8 | $1A9 | $1AA | $1AB | $1AC | $1AD | $1AE | $1AF |
| $1B0 | $1B1 | $1B2 | $1B3 | $1B4 | $1B5 | $1B6 | $1B7 | $1B8 | $1B9 | $1BA | $1BB | $1BC | $1BD | $1BE | $1BF |
| $1C0 | $1C1 | $1C2 | $1C3 | $1C4 | $1C5 | $1C6 | $1C7 | $1C8 | $1C9 | $1CA | $1CB | $1CC | $1CD | $1CE | $1CF |
| $1D0 | $1D1 | $1D2 | $1D3 | $1D4 | $1D5 | $1D6 | $1D7 | $1D8 | $1D9 | $1DA | $1DB | $1DC | $1DD | $1DE | $1DF |
| $1E0 | $1E1 | $1E2 | $1E3 | $1E4 | $1E5 | $1E6 | $1E7 | $1E8 | $1E9 | $1EA | $1EB | $1EC | $1ED | $1EE | $1EF |
| $1F0 | $1F1 | $1F2 | $1F3 | $1F4 | $1F5 | $1F6 | $1F7 | $1F8 | $1F9 | $1FA | $1FB | $1FC | $1FD | $1FE | $1FF |
| Saturation level $2 |
| $200 | $201 | $202 | $203 | $204 | $205 | $206 | $207 | $208 | $209 | $20A | $20B | $20C | $20D | $20E | $20F |
| $210 | $211 | $212 | $213 | $214 | $215 | $216 | $217 | $218 | $219 | $21A | $21B | $21C | $21D | $21E | $21F |
| $220 | $221 | $222 | $223 | $224 | $225 | $226 | $227 | $228 | $229 | $22A | $22B | $22C | $22D | $22E | $22F |
| $230 | $231 | $232 | $233 | $234 | $235 | $236 | $237 | $238 | $239 | $23A | $23B | $23C | $23D | $23E | $23F |
| $240 | $241 | $242 | $243 | $244 | $245 | $246 | $247 | $248 | $249 | $24A | $24B | $24C | $24D | $24E | $24F |
| $250 | $251 | $252 | $253 | $254 | $255 | $256 | $257 | $258 | $259 | $25A | $25B | $25C | $25D | $25E | $25F |
| $260 | $261 | $262 | $263 | $264 | $265 | $266 | $267 | $268 | $269 | $26A | $26B | $26C | $26D | $26E | $26F |
| $270 | $271 | $272 | $273 | $274 | $275 | $276 | $277 | $278 | $279 | $27A | $27B | $27C | $27D | $27E | $27F |
| $280 | $281 | $282 | $283 | $284 | $285 | $286 | $287 | $288 | $289 | $28A | $28B | $28C | $28D | $28E | $28F |
| $290 | $291 | $292 | $293 | $294 | $295 | $296 | $297 | $298 | $299 | $29A | $29B | $29C | $29D | $29E | $29F |
| $2A0 | $2A1 | $2A2 | $2A3 | $2A4 | $2A5 | $2A6 | $2A7 | $2A8 | $2A9 | $2AA | $2AB | $2AC | $2AD | $2AE | $2AF |
| $2B0 | $2B1 | $2B2 | $2B3 | $2B4 | $2B5 | $2B6 | $2B7 | $2B8 | $2B9 | $2BA | $2BB | $2BC | $2BD | $2BE | $2BF |
| $2C0 | $2C1 | $2C2 | $2C3 | $2C4 | $2C5 | $2C6 | $2C7 | $2C8 | $2C9 | $2CA | $2CB | $2CC | $2CD | $2CE | $2CF |
| $2D0 | $2D1 | $2D2 | $2D3 | $2D4 | $2D5 | $2D6 | $2D7 | $2D8 | $2D9 | $2DA | $2DB | $2DC | $2DD | $2DE | $2DF |
| $2E0 | $2E1 | $2E2 | $2E3 | $2E4 | $2E5 | $2E6 | $2E7 | $2E8 | $2E9 | $2EA | $2EB | $2EC | $2ED | $2EE | $2EF |
| $2F0 | $2F1 | $2F2 | $2F3 | $2F4 | $2F5 | $2F6 | $2F7 | $2F8 | $2F9 | $2FA | $2FB | $2FC | $2FD | $2FE | $2FF |
| Saturation level $3 |
| $300 | $301 | $302 | $303 | $304 | $305 | $306 | $307 | $308 | $309 | $30A | $30B | $30C | $30D | $30E | $30F |
| $310 | $311 | $312 | $313 | $314 | $315 | $316 | $317 | $318 | $319 | $31A | $31B | $31C | $31D | $31E | $31F |
| $320 | $321 | $322 | $323 | $324 | $325 | $326 | $327 | $328 | $329 | $32A | $32B | $32C | $32D | $32E | $32F |
| $330 | $331 | $332 | $333 | $334 | $335 | $336 | $337 | $338 | $339 | $33A | $33B | $33C | $33D | $33E | $33F |
| $340 | $341 | $342 | $343 | $344 | $345 | $346 | $347 | $348 | $349 | $34A | $34B | $34C | $34D | $34E | $34F |
| $350 | $351 | $352 | $353 | $354 | $355 | $356 | $357 | $358 | $359 | $35A | $35B | $35C | $35D | $35E | $35F |
| $360 | $361 | $362 | $363 | $364 | $365 | $366 | $367 | $368 | $369 | $36A | $36B | $36C | $36D | $36E | $36F |
| $370 | $371 | $372 | $373 | $374 | $375 | $376 | $377 | $378 | $379 | $37A | $37B | $37C | $37D | $37E | $37F |
| $380 | $381 | $382 | $383 | $384 | $385 | $386 | $387 | $388 | $389 | $38A | $38B | $38C | $38D | $38E | $38F |
| $390 | $391 | $392 | $393 | $394 | $395 | $396 | $397 | $398 | $399 | $39A | $39B | $39C | $39D | $39E | $39F |
| $3A0 | $3A1 | $3A2 | $3A3 | $3A4 | $3A5 | $3A6 | $3A7 | $3A8 | $3A9 | $3AA | $3AB | $3AC | $3AD | $3AE | $3AF |
| $3B0 | $3B1 | $3B2 | $3B3 | $3B4 | $3B5 | $3B6 | $3B7 | $3B8 | $3B9 | $3BA | $3BB | $3BC | $3BD | $3BE | $3BF |
| $3C0 | $3C1 | $3C2 | $3C3 | $3C4 | $3C5 | $3C6 | $3C7 | $3C8 | $3C9 | $3CA | $3CB | $3CC | $3CD | $3CE | $3CF |
| $3D0 | $3D1 | $3D2 | $3D3 | $3D4 | $3D5 | $3D6 | $3D7 | $3D8 | $3D9 | $3DA | $3DB | $3DC | $3DD | $3DE | $3DF |
| $3E0 | $3E1 | $3E2 | $3E3 | $3E4 | $3E5 | $3E6 | $3E7 | $3E8 | $3E9 | $3EA | $3EB | $3EC | $3ED | $3EE | $3EF |
| $3F0 | $3F1 | $3F2 | $3F3 | $3F4 | $3F5 | $3F6 | $3F7 | $3F8 | $3F9 | $3FA | $3FB | $3FC | $3FD | $3FE | $3FF |
| Saturation level $4 |
| $400 | $401 | $402 | $403 | $404 | $405 | $406 | $407 | $408 | $409 | $40A | $40B | $40C | $40D | $40E | $40F |
| $410 | $411 | $412 | $413 | $414 | $415 | $416 | $417 | $418 | $419 | $41A | $41B | $41C | $41D | $41E | $41F |
| $420 | $421 | $422 | $423 | $424 | $425 | $426 | $427 | $428 | $429 | $42A | $42B | $42C | $42D | $42E | $42F |
| $430 | $431 | $432 | $433 | $434 | $435 | $436 | $437 | $438 | $439 | $43A | $43B | $43C | $43D | $43E | $43F |
| $440 | $441 | $442 | $443 | $444 | $445 | $446 | $447 | $448 | $449 | $44A | $44B | $44C | $44D | $44E | $44F |
| $450 | $451 | $452 | $453 | $454 | $455 | $456 | $457 | $458 | $459 | $45A | $45B | $45C | $45D | $45E | $45F |
| $460 | $461 | $462 | $463 | $464 | $465 | $466 | $467 | $468 | $469 | $46A | $46B | $46C | $46D | $46E | $46F |
| $470 | $471 | $472 | $473 | $474 | $475 | $476 | $477 | $478 | $479 | $47A | $47B | $47C | $47D | $47E | $47F |
| $480 | $481 | $482 | $483 | $484 | $485 | $486 | $487 | $488 | $489 | $48A | $48B | $48C | $48D | $48E | $48F |
| $490 | $491 | $492 | $493 | $494 | $495 | $496 | $497 | $498 | $499 | $49A | $49B | $49C | $49D | $49E | $49F |
| $4A0 | $4A1 | $4A2 | $4A3 | $4A4 | $4A5 | $4A6 | $4A7 | $4A8 | $4A9 | $4AA | $4AB | $4AC | $4AD | $4AE | $4AF |
| $4B0 | $4B1 | $4B2 | $4B3 | $4B4 | $4B5 | $4B6 | $4B7 | $4B8 | $4B9 | $4BA | $4BB | $4BC | $4BD | $4BE | $4BF |
| $4C0 | $4C1 | $4C2 | $4C3 | $4C4 | $4C5 | $4C6 | $4C7 | $4C8 | $4C9 | $4CA | $4CB | $4CC | $4CD | $4CE | $4CF |
| $4D0 | $4D1 | $4D2 | $4D3 | $4D4 | $4D5 | $4D6 | $4D7 | $4D8 | $4D9 | $4DA | $4DB | $4DC | $4DD | $4DE | $4DF |
| $4E0 | $4E1 | $4E2 | $4E3 | $4E4 | $4E5 | $4E6 | $4E7 | $4E8 | $4E9 | $4EA | $4EB | $4EC | $4ED | $4EE | $4EF |
| $4F0 | $4F1 | $4F2 | $4F3 | $4F4 | $4F5 | $4F6 | $4F7 | $4F8 | $4F9 | $4FA | $4FB | $4FC | $4FD | $4FE | $4FF |
| Saturation level $5 |
| $500 | $501 | $502 | $503 | $504 | $505 | $506 | $507 | $508 | $509 | $50A | $50B | $50C | $50D | $50E | $50F |
| $510 | $511 | $512 | $513 | $514 | $515 | $516 | $517 | $518 | $519 | $51A | $51B | $51C | $51D | $51E | $51F |
| $520 | $521 | $522 | $523 | $524 | $525 | $526 | $527 | $528 | $529 | $52A | $52B | $52C | $52D | $52E | $52F |
| $530 | $531 | $532 | $533 | $534 | $535 | $536 | $537 | $538 | $539 | $53A | $53B | $53C | $53D | $53E | $53F |
| $540 | $541 | $542 | $543 | $544 | $545 | $546 | $547 | $548 | $549 | $54A | $54B | $54C | $54D | $54E | $54F |
| $550 | $551 | $552 | $553 | $554 | $555 | $556 | $557 | $558 | $559 | $55A | $55B | $55C | $55D | $55E | $55F |
| $560 | $561 | $562 | $563 | $564 | $565 | $566 | $567 | $568 | $569 | $56A | $56B | $56C | $56D | $56E | $56F |
| $570 | $571 | $572 | $573 | $574 | $575 | $576 | $577 | $578 | $579 | $57A | $57B | $57C | $57D | $57E | $57F |
| $580 | $581 | $582 | $583 | $584 | $585 | $586 | $587 | $588 | $589 | $58A | $58B | $58C | $58D | $58E | $58F |
| $590 | $591 | $592 | $593 | $594 | $595 | $596 | $597 | $598 | $599 | $59A | $59B | $59C | $59D | $59E | $59F |
| $5A0 | $5A1 | $5A2 | $5A3 | $5A4 | $5A5 | $5A6 | $5A7 | $5A8 | $5A9 | $5AA | $5AB | $5AC | $5AD | $5AE | $5AF |
| $5B0 | $5B1 | $5B2 | $5B3 | $5B4 | $5B5 | $5B6 | $5B7 | $5B8 | $5B9 | $5BA | $5BB | $5BC | $5BD | $5BE | $5BF |
| $5C0 | $5C1 | $5C2 | $5C3 | $5C4 | $5C5 | $5C6 | $5C7 | $5C8 | $5C9 | $5CA | $5CB | $5CC | $5CD | $5CE | $5CF |
| $5D0 | $5D1 | $5D2 | $5D3 | $5D4 | $5D5 | $5D6 | $5D7 | $5D8 | $5D9 | $5DA | $5DB | $5DC | $5DD | $5DE | $5DF |
| $5E0 | $5E1 | $5E2 | $5E3 | $5E4 | $5E5 | $5E6 | $5E7 | $5E8 | $5E9 | $5EA | $5EB | $5EC | $5ED | $5EE | $5EF |
| $5F0 | $5F1 | $5F2 | $5F3 | $5F4 | $5F5 | $5F6 | $5F7 | $5F8 | $5F9 | $5FA | $5FB | $5FC | $5FD | $5FE | $5FF |
| Saturation level $6 |
| $600 | $601 | $602 | $603 | $604 | $605 | $606 | $607 | $608 | $609 | $60A | $60B | $60C | $60D | $60E | $60F |
| $610 | $611 | $612 | $613 | $614 | $615 | $616 | $617 | $618 | $619 | $61A | $61B | $61C | $61D | $61E | $61F |
| $620 | $621 | $622 | $623 | $624 | $625 | $626 | $627 | $628 | $629 | $62A | $62B | $62C | $62D | $62E | $62F |
| $630 | $631 | $632 | $633 | $634 | $635 | $636 | $637 | $638 | $639 | $63A | $63B | $63C | $63D | $63E | $63F |
| $640 | $641 | $642 | $643 | $644 | $645 | $646 | $647 | $648 | $649 | $64A | $64B | $64C | $64D | $64E | $64F |
| $650 | $651 | $652 | $653 | $654 | $655 | $656 | $657 | $658 | $659 | $65A | $65B | $65C | $65D | $65E | $65F |
| $660 | $661 | $662 | $663 | $664 | $665 | $666 | $667 | $668 | $669 | $66A | $66B | $66C | $66D | $66E | $66F |
| $670 | $671 | $672 | $673 | $674 | $675 | $676 | $677 | $678 | $679 | $67A | $67B | $67C | $67D | $67E | $67F |
| $680 | $681 | $682 | $683 | $684 | $685 | $686 | $687 | $688 | $689 | $68A | $68B | $68C | $68D | $68E | $68F |
| $690 | $691 | $692 | $693 | $694 | $695 | $696 | $697 | $698 | $699 | $69A | $69B | $69C | $69D | $69E | $69F |
| $6A0 | $6A1 | $6A2 | $6A3 | $6A4 | $6A5 | $6A6 | $6A7 | $6A8 | $6A9 | $6AA | $6AB | $6AC | $6AD | $6AE | $6AF |
| $6B0 | $6B1 | $6B2 | $6B3 | $6B4 | $6B5 | $6B6 | $6B7 | $6B8 | $6B9 | $6BA | $6BB | $6BC | $6BD | $6BE | $6BF |
| $6C0 | $6C1 | $6C2 | $6C3 | $6C4 | $6C5 | $6C6 | $6C7 | $6C8 | $6C9 | $6CA | $6CB | $6CC | $6CD | $6CE | $6CF |
| $6D0 | $6D1 | $6D2 | $6D3 | $6D4 | $6D5 | $6D6 | $6D7 | $6D8 | $6D9 | $6DA | $6DB | $6DC | $6DD | $6DE | $6DF |
| $6E0 | $6E1 | $6E2 | $6E3 | $6E4 | $6E5 | $6E6 | $6E7 | $6E8 | $6E9 | $6EA | $6EB | $6EC | $6ED | $6EE | $6EF |
| $6F0 | $6F1 | $6F2 | $6F3 | $6F4 | $6F5 | $6F6 | $6F7 | $6F8 | $6F9 | $6FA | $6FB | $6FC | $6FD | $6FE | $6FF |
| Saturation level $7 |
| $700 | $701 | $702 | $703 | $704 | $705 | $706 | $707 | $708 | $709 | $70A | $70B | $70C | $70D | $70E | $70F |
| $710 | $711 | $712 | $713 | $714 | $715 | $716 | $717 | $718 | $719 | $71A | $71B | $71C | $71D | $71E | $71F |
| $720 | $721 | $722 | $723 | $724 | $725 | $726 | $727 | $728 | $729 | $72A | $72B | $72C | $72D | $72E | $72F |
| $730 | $731 | $732 | $733 | $734 | $735 | $736 | $737 | $738 | $739 | $73A | $73B | $73C | $73D | $73E | $73F |
| $740 | $741 | $742 | $743 | $744 | $745 | $746 | $747 | $748 | $749 | $74A | $74B | $74C | $74D | $74E | $74F |
| $750 | $751 | $752 | $753 | $754 | $755 | $756 | $757 | $758 | $759 | $75A | $75B | $75C | $75D | $75E | $75F |
| $760 | $761 | $762 | $763 | $764 | $765 | $766 | $767 | $768 | $769 | $76A | $76B | $76C | $76D | $76E | $76F |
| $770 | $771 | $772 | $773 | $774 | $775 | $776 | $777 | $778 | $779 | $77A | $77B | $77C | $77D | $77E | $77F |
| $780 | $781 | $782 | $783 | $784 | $785 | $786 | $787 | $788 | $789 | $78A | $78B | $78C | $78D | $78E | $78F |
| $790 | $791 | $792 | $793 | $794 | $795 | $796 | $797 | $798 | $799 | $79A | $79B | $79C | $79D | $79E | $79F |
| $7A0 | $7A1 | $7A2 | $7A3 | $7A4 | $7A5 | $7A6 | $7A7 | $7A8 | $7A9 | $7AA | $7AB | $7AC | $7AD | $7AE | $7AF |
| $7B0 | $7B1 | $7B2 | $7B3 | $7B4 | $7B5 | $7B6 | $7B7 | $7B8 | $7B9 | $7BA | $7BB | $7BC | $7BD | $7BE | $7BF |
| $7C0 | $7C1 | $7C2 | $7C3 | $7C4 | $7C5 | $7C6 | $7C7 | $7C8 | $7C9 | $7CA | $7CB | $7CC | $7CD | $7CE | $7CF |
| $7D0 | $7D1 | $7D2 | $7D3 | $7D4 | $7D5 | $7D6 | $7D7 | $7D8 | $7D9 | $7DA | $7DB | $7DC | $7DD | $7DE | $7DF |
| $7E0 | $7E1 | $7E2 | $7E3 | $7E4 | $7E5 | $7E6 | $7E7 | $7E8 | $7E9 | $7EA | $7EB | $7EC | $7ED | $7EE | $7EF |
| $7F0 | $7F1 | $7F2 | $7F3 | $7F4 | $7F5 | $7F6 | $7F7 | $7F8 | $7F9 | $7FA | $7FB | $7FC | $7FD | $7FE | $7FF |
| Saturation level $8 |
| $800 | $801 | $802 | $803 | $804 | $805 | $806 | $807 | $808 | $809 | $80A | $80B | $80C | $80D | $80E | $80F |
| $810 | $811 | $812 | $813 | $814 | $815 | $816 | $817 | $818 | $819 | $81A | $81B | $81C | $81D | $81E | $81F |
| $820 | $821 | $822 | $823 | $824 | $825 | $826 | $827 | $828 | $829 | $82A | $82B | $82C | $82D | $82E | $82F |
| $830 | $831 | $832 | $833 | $834 | $835 | $836 | $837 | $838 | $839 | $83A | $83B | $83C | $83D | $83E | $83F |
| $840 | $841 | $842 | $843 | $844 | $845 | $846 | $847 | $848 | $849 | $84A | $84B | $84C | $84D | $84E | $84F |
| $850 | $851 | $852 | $853 | $854 | $855 | $856 | $857 | $858 | $859 | $85A | $85B | $85C | $85D | $85E | $85F |
| $860 | $861 | $862 | $863 | $864 | $865 | $866 | $867 | $868 | $869 | $86A | $86B | $86C | $86D | $86E | $86F |
| $870 | $871 | $872 | $873 | $874 | $875 | $876 | $877 | $878 | $879 | $87A | $87B | $87C | $87D | $87E | $87F |
| $880 | $881 | $882 | $883 | $884 | $885 | $886 | $887 | $888 | $889 | $88A | $88B | $88C | $88D | $88E | $88F |
| $890 | $891 | $892 | $893 | $894 | $895 | $896 | $897 | $898 | $899 | $89A | $89B | $89C | $89D | $89E | $89F |
| $8A0 | $8A1 | $8A2 | $8A3 | $8A4 | $8A5 | $8A6 | $8A7 | $8A8 | $8A9 | $8AA | $8AB | $8AC | $8AD | $8AE | $8AF |
| $8B0 | $8B1 | $8B2 | $8B3 | $8B4 | $8B5 | $8B6 | $8B7 | $8B8 | $8B9 | $8BA | $8BB | $8BC | $8BD | $8BE | $8BF |
| $8C0 | $8C1 | $8C2 | $8C3 | $8C4 | $8C5 | $8C6 | $8C7 | $8C8 | $8C9 | $8CA | $8CB | $8CC | $8CD | $8CE | $8CF |
| $8D0 | $8D1 | $8D2 | $8D3 | $8D4 | $8D5 | $8D6 | $8D7 | $8D8 | $8D9 | $8DA | $8DB | $8DC | $8DD | $8DE | $8DF |
| $8E0 | $8E1 | $8E2 | $8E3 | $8E4 | $8E5 | $8E6 | $8E7 | $8E8 | $8E9 | $8EA | $8EB | $8EC | $8ED | $8EE | $8EF |
| $8F0 | $8F1 | $8F2 | $8F3 | $8F4 | $8F5 | $8F6 | $8F7 | $8F8 | $8F9 | $8FA | $8FB | $8FC | $8FD | $8FE | $8FF |
| Saturation level $9 |
| $900 | $901 | $902 | $903 | $904 | $905 | $906 | $907 | $908 | $909 | $90A | $90B | $90C | $90D | $90E | $90F |
| $910 | $911 | $912 | $913 | $914 | $915 | $916 | $917 | $918 | $919 | $91A | $91B | $91C | $91D | $91E | $91F |
| $920 | $921 | $922 | $923 | $924 | $925 | $926 | $927 | $928 | $929 | $92A | $92B | $92C | $92D | $92E | $92F |
| $930 | $931 | $932 | $933 | $934 | $935 | $936 | $937 | $938 | $939 | $93A | $93B | $93C | $93D | $93E | $93F |
| $940 | $941 | $942 | $943 | $944 | $945 | $946 | $947 | $948 | $949 | $94A | $94B | $94C | $94D | $94E | $94F |
| $950 | $951 | $952 | $953 | $954 | $955 | $956 | $957 | $958 | $959 | $95A | $95B | $95C | $95D | $95E | $95F |
| $960 | $961 | $962 | $963 | $964 | $965 | $966 | $967 | $968 | $969 | $96A | $96B | $96C | $96D | $96E | $96F |
| $970 | $971 | $972 | $973 | $974 | $975 | $976 | $977 | $978 | $979 | $97A | $97B | $97C | $97D | $97E | $97F |
| $980 | $981 | $982 | $983 | $984 | $985 | $986 | $987 | $988 | $989 | $98A | $98B | $98C | $98D | $98E | $98F |
| $990 | $991 | $992 | $993 | $994 | $995 | $996 | $997 | $998 | $999 | $99A | $99B | $99C | $99D | $99E | $99F |
| $9A0 | $9A1 | $9A2 | $9A3 | $9A4 | $9A5 | $9A6 | $9A7 | $9A8 | $9A9 | $9AA | $9AB | $9AC | $9AD | $9AE | $9AF |
| $9B0 | $9B1 | $9B2 | $9B3 | $9B4 | $9B5 | $9B6 | $9B7 | $9B8 | $9B9 | $9BA | $9BB | $9BC | $9BD | $9BE | $9BF |
| $9C0 | $9C1 | $9C2 | $9C3 | $9C4 | $9C5 | $9C6 | $9C7 | $9C8 | $9C9 | $9CA | $9CB | $9CC | $9CD | $9CE | $9CF |
| $9D0 | $9D1 | $9D2 | $9D3 | $9D4 | $9D5 | $9D6 | $9D7 | $9D8 | $9D9 | $9DA | $9DB | $9DC | $9DD | $9DE | $9DF |
| $9E0 | $9E1 | $9E2 | $9E3 | $9E4 | $9E5 | $9E6 | $9E7 | $9E8 | $9E9 | $9EA | $9EB | $9EC | $9ED | $9EE | $9EF |
| $9F0 | $9F1 | $9F2 | $9F3 | $9F4 | $9F5 | $9F6 | $9F7 | $9F8 | $9F9 | $9FA | $9FB | $9FC | $9FD | $9FE | $9FF |
| Saturation level $A |
| $A00 | $A01 | $A02 | $A03 | $A04 | $A05 | $A06 | $A07 | $A08 | $A09 | $A0A | $A0B | $A0C | $A0D | $A0E | $A0F |
| $A10 | $A11 | $A12 | $A13 | $A14 | $A15 | $A16 | $A17 | $A18 | $A19 | $A1A | $A1B | $A1C | $A1D | $A1E | $A1F |
| $A20 | $A21 | $A22 | $A23 | $A24 | $A25 | $A26 | $A27 | $A28 | $A29 | $A2A | $A2B | $A2C | $A2D | $A2E | $A2F |
| $A30 | $A31 | $A32 | $A33 | $A34 | $A35 | $A36 | $A37 | $A38 | $A39 | $A3A | $A3B | $A3C | $A3D | $A3E | $A3F |
| $A40 | $A41 | $A42 | $A43 | $A44 | $A45 | $A46 | $A47 | $A48 | $A49 | $A4A | $A4B | $A4C | $A4D | $A4E | $A4F |
| $A50 | $A51 | $A52 | $A53 | $A54 | $A55 | $A56 | $A57 | $A58 | $A59 | $A5A | $A5B | $A5C | $A5D | $A5E | $A5F |
| $A60 | $A61 | $A62 | $A63 | $A64 | $A65 | $A66 | $A67 | $A68 | $A69 | $A6A | $A6B | $A6C | $A6D | $A6E | $A6F |
| $A70 | $A71 | $A72 | $A73 | $A74 | $A75 | $A76 | $A77 | $A78 | $A79 | $A7A | $A7B | $A7C | $A7D | $A7E | $A7F |
| $A80 | $A81 | $A82 | $A83 | $A84 | $A85 | $A86 | $A87 | $A88 | $A89 | $A8A | $A8B | $A8C | $A8D | $A8E | $A8F |
| $A90 | $A91 | $A92 | $A93 | $A94 | $A95 | $A96 | $A97 | $A98 | $A99 | $A9A | $A9B | $A9C | $A9D | $A9E | $A9F |
| $AA0 | $AA1 | $AA2 | $AA3 | $AA4 | $AA5 | $AA6 | $AA7 | $AA8 | $AA9 | $AAA | $AAB | $AAC | $AAD | $AAE | $AAF |
| $AB0 | $AB1 | $AB2 | $AB3 | $AB4 | $AB5 | $AB6 | $AB7 | $AB8 | $AB9 | $ABA | $ABB | $ABC | $ABD | $ABE | $ABF |
| $AC0 | $AC1 | $AC2 | $AC3 | $AC4 | $AC5 | $AC6 | $AC7 | $AC8 | $AC9 | $ACA | $ACB | $ACC | $ACD | $ACE | $ACF |
| $AD0 | $AD1 | $AD2 | $AD3 | $AD4 | $AD5 | $AD6 | $AD7 | $AD8 | $AD9 | $ADA | $ADB | $ADC | $ADD | $ADE | $ADF |
| $AE0 | $AE1 | $AE2 | $AE3 | $AE4 | $AE5 | $AE6 | $AE7 | $AE8 | $AE9 | $AEA | $AEB | $AEC | $AED | $AEE | $AEF |
| $AF0 | $AF1 | $AF2 | $AF3 | $AF4 | $AF5 | $AF6 | $AF7 | $AF8 | $AF9 | $AFA | $AFB | $AFC | $AFD | $AFE | $AFF |
| Saturation level $B |
| $B00 | $B01 | $B02 | $B03 | $B04 | $B05 | $B06 | $B07 | $B08 | $B09 | $B0A | $B0B | $B0C | $B0D | $B0E | $B0F |
| $B10 | $B11 | $B12 | $B13 | $B14 | $B15 | $B16 | $B17 | $B18 | $B19 | $B1A | $B1B | $B1C | $B1D | $B1E | $B1F |
| $B20 | $B21 | $B22 | $B23 | $B24 | $B25 | $B26 | $B27 | $B28 | $B29 | $B2A | $B2B | $B2C | $B2D | $B2E | $B2F |
| $B30 | $B31 | $B32 | $B33 | $B34 | $B35 | $B36 | $B37 | $B38 | $B39 | $B3A | $B3B | $B3C | $B3D | $B3E | $B3F |
| $B40 | $B41 | $B42 | $B43 | $B44 | $B45 | $B46 | $B47 | $B48 | $B49 | $B4A | $B4B | $B4C | $B4D | $B4E | $B4F |
| $B50 | $B51 | $B52 | $B53 | $B54 | $B55 | $B56 | $B57 | $B58 | $B59 | $B5A | $B5B | $B5C | $B5D | $B5E | $B5F |
| $B60 | $B61 | $B62 | $B63 | $B64 | $B65 | $B66 | $B67 | $B68 | $B69 | $B6A | $B6B | $B6C | $B6D | $B6E | $B6F |
| $B70 | $B71 | $B72 | $B73 | $B74 | $B75 | $B76 | $B77 | $B78 | $B79 | $B7A | $B7B | $B7C | $B7D | $B7E | $B7F |
| $B80 | $B81 | $B82 | $B83 | $B84 | $B85 | $B86 | $B87 | $B88 | $B89 | $B8A | $B8B | $B8C | $B8D | $B8E | $B8F |
| $B90 | $B91 | $B92 | $B93 | $B94 | $B95 | $B96 | $B97 | $B98 | $B99 | $B9A | $B9B | $B9C | $B9D | $B9E | $B9F |
| $BA0 | $BA1 | $BA2 | $BA3 | $BA4 | $BA5 | $BA6 | $BA7 | $BA8 | $BA9 | $BAA | $BAB | $BAC | $BAD | $BAE | $BAF |
| $BB0 | $BB1 | $BB2 | $BB3 | $BB4 | $BB5 | $BB6 | $BB7 | $BB8 | $BB9 | $BBA | $BBB | $BBC | $BBD | $BBE | $BBF |
| $BC0 | $BC1 | $BC2 | $BC3 | $BC4 | $BC5 | $BC6 | $BC7 | $BC8 | $BC9 | $BCA | $BCB | $BCC | $BCD | $BCE | $BCF |
| $BD0 | $BD1 | $BD2 | $BD3 | $BD4 | $BD5 | $BD6 | $BD7 | $BD8 | $BD9 | $BDA | $BDB | $BDC | $BDD | $BDE | $BDF |
| $BE0 | $BE1 | $BE2 | $BE3 | $BE4 | $BE5 | $BE6 | $BE7 | $BE8 | $BE9 | $BEA | $BEB | $BEC | $BED | $BEE | $BEF |
| $BF0 | $BF1 | $BF2 | $BF3 | $BF4 | $BF5 | $BF6 | $BF7 | $BF8 | $BF9 | $BFA | $BFB | $BFC | $BFD | $BFE | $BFF |
| Saturation level $C |
| $C00 | $C01 | $C02 | $C03 | $C04 | $C05 | $C06 | $C07 | $C08 | $C09 | $C0A | $C0B | $C0C | $C0D | $C0E | $C0F |
| $C10 | $C11 | $C12 | $C13 | $C14 | $C15 | $C16 | $C17 | $C18 | $C19 | $C1A | $C1B | $C1C | $C1D | $C1E | $C1F |
| $C20 | $C21 | $C22 | $C23 | $C24 | $C25 | $C26 | $C27 | $C28 | $C29 | $C2A | $C2B | $C2C | $C2D | $C2E | $C2F |
| $C30 | $C31 | $C32 | $C33 | $C34 | $C35 | $C36 | $C37 | $C38 | $C39 | $C3A | $C3B | $C3C | $C3D | $C3E | $C3F |
| $C40 | $C41 | $C42 | $C43 | $C44 | $C45 | $C46 | $C47 | $C48 | $C49 | $C4A | $C4B | $C4C | $C4D | $C4E | $C4F |
| $C50 | $C51 | $C52 | $C53 | $C54 | $C55 | $C56 | $C57 | $C58 | $C59 | $C5A | $C5B | $C5C | $C5D | $C5E | $C5F |
| $C60 | $C61 | $C62 | $C63 | $C64 | $C65 | $C66 | $C67 | $C68 | $C69 | $C6A | $C6B | $C6C | $C6D | $C6E | $C6F |
| $C70 | $C71 | $C72 | $C73 | $C74 | $C75 | $C76 | $C77 | $C78 | $C79 | $C7A | $C7B | $C7C | $C7D | $C7E | $C7F |
| $C80 | $C81 | $C82 | $C83 | $C84 | $C85 | $C86 | $C87 | $C88 | $C89 | $C8A | $C8B | $C8C | $C8D | $C8E | $C8F |
| $C90 | $C91 | $C92 | $C93 | $C94 | $C95 | $C96 | $C97 | $C98 | $C99 | $C9A | $C9B | $C9C | $C9D | $C9E | $C9F |
| $CA0 | $CA1 | $CA2 | $CA3 | $CA4 | $CA5 | $CA6 | $CA7 | $CA8 | $CA9 | $CAA | $CAB | $CAC | $CAD | $CAE | $CAF |
| $CB0 | $CB1 | $CB2 | $CB3 | $CB4 | $CB5 | $CB6 | $CB7 | $CB8 | $CB9 | $CBA | $CBB | $CBC | $CBD | $CBE | $CBF |
| $CC0 | $CC1 | $CC2 | $CC3 | $CC4 | $CC5 | $CC6 | $CC7 | $CC8 | $CC9 | $CCA | $CCB | $CCC | $CCD | $CCE | $CCF |
| $CD0 | $CD1 | $CD2 | $CD3 | $CD4 | $CD5 | $CD6 | $CD7 | $CD8 | $CD9 | $CDA | $CDB | $CDC | $CDD | $CDE | $CDF |
| $CE0 | $CE1 | $CE2 | $CE3 | $CE4 | $CE5 | $CE6 | $CE7 | $CE8 | $CE9 | $CEA | $CEB | $CEC | $CED | $CEE | $CEF |
| $CF0 | $CF1 | $CF2 | $CF3 | $CF4 | $CF5 | $CF6 | $CF7 | $CF8 | $CF9 | $CFA | $CFB | $CFC | $CFD | $CFE | $CFF |
| Saturation level $D |
| $D00 | $D01 | $D02 | $D03 | $D04 | $D05 | $D06 | $D07 | $D08 | $D09 | $D0A | $D0B | $D0C | $D0D | $D0E | $D0F |
| $D10 | $D11 | $D12 | $D13 | $D14 | $D15 | $D16 | $D17 | $D18 | $D19 | $D1A | $D1B | $D1C | $D1D | $D1E | $D1F |
| $D20 | $D21 | $D22 | $D23 | $D24 | $D25 | $D26 | $D27 | $D28 | $D29 | $D2A | $D2B | $D2C | $D2D | $D2E | $D2F |
| $D30 | $D31 | $D32 | $D33 | $D34 | $D35 | $D36 | $D37 | $D38 | $D39 | $D3A | $D3B | $D3C | $D3D | $D3E | $D3F |
| $D40 | $D41 | $D42 | $D43 | $D44 | $D45 | $D46 | $D47 | $D48 | $D49 | $D4A | $D4B | $D4C | $D4D | $D4E | $D4F |
| $D50 | $D51 | $D52 | $D53 | $D54 | $D55 | $D56 | $D57 | $D58 | $D59 | $D5A | $D5B | $D5C | $D5D | $D5E | $D5F |
| $D60 | $D61 | $D62 | $D63 | $D64 | $D65 | $D66 | $D67 | $D68 | $D69 | $D6A | $D6B | $D6C | $D6D | $D6E | $D6F |
| $D70 | $D71 | $D72 | $D73 | $D74 | $D75 | $D76 | $D77 | $D78 | $D79 | $D7A | $D7B | $D7C | $D7D | $D7E | $D7F |
| $D80 | $D81 | $D82 | $D83 | $D84 | $D85 | $D86 | $D87 | $D88 | $D89 | $D8A | $D8B | $D8C | $D8D | $D8E | $D8F |
| $D90 | $D91 | $D92 | $D93 | $D94 | $D95 | $D96 | $D97 | $D98 | $D99 | $D9A | $D9B | $D9C | $D9D | $D9E | $D9F |
| $DA0 | $DA1 | $DA2 | $DA3 | $DA4 | $DA5 | $DA6 | $DA7 | $DA8 | $DA9 | $DAA | $DAB | $DAC | $DAD | $DAE | $DAF |
| $DB0 | $DB1 | $DB2 | $DB3 | $DB4 | $DB5 | $DB6 | $DB7 | $DB8 | $DB9 | $DBA | $DBB | $DBC | $DBD | $DBE | $DBF |
| $DC0 | $DC1 | $DC2 | $DC3 | $DC4 | $DC5 | $DC6 | $DC7 | $DC8 | $DC9 | $DCA | $DCB | $DCC | $DCD | $DCE | $DCF |
| $DD0 | $DD1 | $DD2 | $DD3 | $DD4 | $DD5 | $DD6 | $DD7 | $DD8 | $DD9 | $DDA | $DDB | $DDC | $DDD | $DDE | $DDF |
| $DE0 | $DE1 | $DE2 | $DE3 | $DE4 | $DE5 | $DE6 | $DE7 | $DE8 | $DE9 | $DEA | $DEB | $DEC | $DED | $DEE | $DEF |
| $DF0 | $DF1 | $DF2 | $DF3 | $DF4 | $DF5 | $DF6 | $DF7 | $DF8 | $DF9 | $DFA | $DFB | $DFC | $DFD | $DFE | $DFF |
| Saturation level $E |
| $E00 | $E01 | $E02 | $E03 | $E04 | $E05 | $E06 | $E07 | $E08 | $E09 | $E0A | $E0B | $E0C | $E0D | $E0E | $E0F |
| $E10 | $E11 | $E12 | $E13 | $E14 | $E15 | $E16 | $E17 | $E18 | $E19 | $E1A | $E1B | $E1C | $E1D | $E1E | $E1F |
| $E20 | $E21 | $E22 | $E23 | $E24 | $E25 | $E26 | $E27 | $E28 | $E29 | $E2A | $E2B | $E2C | $E2D | $E2E | $E2F |
| $E30 | $E31 | $E32 | $E33 | $E34 | $E35 | $E36 | $E37 | $E38 | $E39 | $E3A | $E3B | $E3C | $E3D | $E3E | $E3F |
| $E40 | $E41 | $E42 | $E43 | $E44 | $E45 | $E46 | $E47 | $E48 | $E49 | $E4A | $E4B | $E4C | $E4D | $E4E | $E4F |
| $E50 | $E51 | $E52 | $E53 | $E54 | $E55 | $E56 | $E57 | $E58 | $E59 | $E5A | $E5B | $E5C | $E5D | $E5E | $E5F |
| $E60 | $E61 | $E62 | $E63 | $E64 | $E65 | $E66 | $E67 | $E68 | $E69 | $E6A | $E6B | $E6C | $E6D | $E6E | $E6F |
| $E70 | $E71 | $E72 | $E73 | $E74 | $E75 | $E76 | $E77 | $E78 | $E79 | $E7A | $E7B | $E7C | $E7D | $E7E | $E7F |
| $E80 | $E81 | $E82 | $E83 | $E84 | $E85 | $E86 | $E87 | $E88 | $E89 | $E8A | $E8B | $E8C | $E8D | $E8E | $E8F |
| $E90 | $E91 | $E92 | $E93 | $E94 | $E95 | $E96 | $E97 | $E98 | $E99 | $E9A | $E9B | $E9C | $E9D | $E9E | $E9F |
| $EA0 | $EA1 | $EA2 | $EA3 | $EA4 | $EA5 | $EA6 | $EA7 | $EA8 | $EA9 | $EAA | $EAB | $EAC | $EAD | $EAE | $EAF |
| $EB0 | $EB1 | $EB2 | $EB3 | $EB4 | $EB5 | $EB6 | $EB7 | $EB8 | $EB9 | $EBA | $EBB | $EBC | $EBD | $EBE | $EBF |
| $EC0 | $EC1 | $EC2 | $EC3 | $EC4 | $EC5 | $EC6 | $EC7 | $EC8 | $EC9 | $ECA | $ECB | $ECC | $ECD | $ECE | $ECF |
| $ED0 | $ED1 | $ED2 | $ED3 | $ED4 | $ED5 | $ED6 | $ED7 | $ED8 | $ED9 | $EDA | $EDB | $EDC | $EDD | $EDE | $EDF |
| $EE0 | $EE1 | $EE2 | $EE3 | $EE4 | $EE5 | $EE6 | $EE7 | $EE8 | $EE9 | $EEA | $EEB | $EEC | $EED | $EEE | $EEF |
| $EF0 | $EF1 | $EF2 | $EF3 | $EF4 | $EF5 | $EF6 | $EF7 | $EF8 | $EF9 | $EFA | $EFB | $EFC | $EFD | $EFE | $EFF |
| Saturation level $F |
| $F00 | $F01 | $F02 | $F03 | $F04 | $F05 | $F06 | $F07 | $F08 | $F09 | $F0A | $F0B | $F0C | $F0D | $F0E | $F0F |
| $F10 | $F11 | $F12 | $F13 | $F14 | $F15 | $F16 | $F17 | $F18 | $F19 | $F1A | $F1B | $F1C | $F1D | $F1E | $F1F |
| $F20 | $F21 | $F22 | $F23 | $F24 | $F25 | $F26 | $F27 | $F28 | $F29 | $F2A | $F2B | $F2C | $F2D | $F2E | $F2F |
| $F30 | $F31 | $F32 | $F33 | $F34 | $F35 | $F36 | $F37 | $F38 | $F39 | $F3A | $F3B | $F3C | $F3D | $F3E | $F3F |
| $F40 | $F41 | $F42 | $F43 | $F44 | $F45 | $F46 | $F47 | $F48 | $F49 | $F4A | $F4B | $F4C | $F4D | $F4E | $F4F |
| $F50 | $F51 | $F52 | $F53 | $F54 | $F55 | $F56 | $F57 | $F58 | $F59 | $F5A | $F5B | $F5C | $F5D | $F5E | $F5F |
| $F60 | $F61 | $F62 | $F63 | $F64 | $F65 | $F66 | $F67 | $F68 | $F69 | $F6A | $F6B | $F6C | $F6D | $F6E | $F6F |
| $F70 | $F71 | $F72 | $F73 | $F74 | $F75 | $F76 | $F77 | $F78 | $F79 | $F7A | $F7B | $F7C | $F7D | $F7E | $F7F |
| $F80 | $F81 | $F82 | $F83 | $F84 | $F85 | $F86 | $F87 | $F88 | $F89 | $F8A | $F8B | $F8C | $F8D | $F8E | $F8F |
| $F90 | $F91 | $F92 | $F93 | $F94 | $F95 | $F96 | $F97 | $F98 | $F99 | $F9A | $F9B | $F9C | $F9D | $F9E | $F9F |
| $FA0 | $FA1 | $FA2 | $FA3 | $FA4 | $FA5 | $FA6 | $FA7 | $FA8 | $FA9 | $FAA | $FAB | $FAC | $FAD | $FAE | $FAF |
| $FB0 | $FB1 | $FB2 | $FB3 | $FB4 | $FB5 | $FB6 | $FB7 | $FB8 | $FB9 | $FBA | $FBB | $FBC | $FBD | $FBE | $FBF |
| $FC0 | $FC1 | $FC2 | $FC3 | $FC4 | $FC5 | $FC6 | $FC7 | $FC8 | $FC9 | $FCA | $FCB | $FCC | $FCD | $FCE | $FCF |
| $FD0 | $FD1 | $FD2 | $FD3 | $FD4 | $FD5 | $FD6 | $FD7 | $FD8 | $FD9 | $FDA | $FDB | $FDC | $FDD | $FDE | $FDF |
| $FE0 | $FE1 | $FE2 | $FE3 | $FE4 | $FE5 | $FE6 | $FE7 | $FE8 | $FE9 | $FEA | $FEB | $FEC | $FED | $FEE | $FEF |
| $FF0 | $FF1 | $FF2 | $FF3 | $FF4 | $FF5 | $FF6 | $FF7 | $FF8 | $FF9 | $FFA | $FFB | $FFC | $FFD | $FFE | $FFF |
