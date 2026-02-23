#ifndef NESLIB_H
#define NESLIB_H

/* Minimal local replacement for external neslib dependency.
 * Enough to compile/run basic code paths in this repository. */

#define PPU_CTRL_REG   (*(volatile unsigned char*)0x2000)
#define PPU_MASK_REG   (*(volatile unsigned char*)0x2001)
#define PPU_STATUS_REG (*(volatile unsigned char*)0x2002)
#define PPU_ADDR_REG   (*(volatile unsigned char*)0x2006)
#define PPU_DATA_REG   (*(volatile unsigned char*)0x2007)
#define JOYPAD1_REG    (*(volatile unsigned char*)0x4016)
#define OAM_DMA_REG    (*(volatile unsigned char*)0x4014)

#define NTADR_A(x, y) (0x2000u + (((unsigned int)(y)) << 5) + (unsigned int)(x))
#define NTADR_B(x, y) (0x2400u + (((unsigned int)(y)) << 5) + (unsigned int)(x))

void pal_col(unsigned char idx, unsigned char color);
void vram_adr(unsigned int addr);
void vram_put(unsigned char value);
void ppu_puts(const char* s, unsigned char len);
void ppu_on_all(void);
void ppu_off(void);
void ppu_wait_nmi(void);
unsigned char pad_poll(unsigned char pad);

#endif
