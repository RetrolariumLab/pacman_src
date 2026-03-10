#ifndef NESLIB_H
#define NESLIB_H

#define PPU_CTRL_REG   (*(volatile unsigned char*)0x2000)
#define PPU_MASK_REG   (*(volatile unsigned char*)0x2001)
#define PPU_STATUS_REG (*(volatile unsigned char*)0x2002)
#define OAM_ADDR_REG   (*(volatile unsigned char*)0x2003)
#define OAM_DATA_REG   (*(volatile unsigned char*)0x2004)
#define PPU_SCROLL_REG (*(volatile unsigned char*)0x2005)
#define PPU_ADDR_REG   (*(volatile unsigned char*)0x2006)
#define PPU_DATA_REG   (*(volatile unsigned char*)0x2007)
#define OAM_DMA_REG    (*(volatile unsigned char*)0x4014)
#define JOYPAD1_REG    (*(volatile unsigned char*)0x4016)
#define JOYPAD2_REG    (*(volatile unsigned char*)0x4017)

#define PAD_A      0x01
#define PAD_B      0x02
#define PAD_SELECT 0x04
#define PAD_START  0x08
#define PAD_UP     0x10
#define PAD_DOWN   0x20
#define PAD_LEFT   0x40
#define PAD_RIGHT  0x80

#define NTADR_A(x, y) (0x2000u + (((unsigned int)(y)) << 5) + (unsigned int)(x))
#define NTADR_B(x, y) (0x2400u + (((unsigned int)(y)) << 5) + (unsigned int)(x))

void ppu_wait_vblank(void);
void ppu_off(void);
void ppu_on_all(void);
void ppu_on_bg(void);
void oam_clear(void);
void ppu_clear_nt(unsigned int nt_base, unsigned char tile);
void vram_adr(unsigned int addr);
void vram_put(unsigned char v);
void vram_fill(unsigned char value, unsigned int len);
unsigned char pad_poll(unsigned char pad);

#endif
