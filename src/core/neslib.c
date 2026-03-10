#include "neslib.h"

void ppu_wait_vblank(void) {
    while ((PPU_STATUS_REG & 0x80) != 0) {
    }
    while ((PPU_STATUS_REG & 0x80) == 0) {
    }
}

void ppu_off(void) {
    PPU_MASK_REG = 0x00;
}

void ppu_on_all(void) {
    PPU_MASK_REG = 0x1E;
}

void ppu_on_bg(void) {
    PPU_MASK_REG = 0x0A;
}

void oam_clear(void) {
    unsigned int i;
    OAM_ADDR_REG = 0x00;
    for (i = 0; i < 256; ++i) {
        OAM_DATA_REG = 0xFF;
    }
}

void vram_adr(unsigned int addr) {
    (void)PPU_STATUS_REG;
    PPU_ADDR_REG = (unsigned char)(addr >> 8);
    PPU_ADDR_REG = (unsigned char)(addr & 0xFF);
}

void vram_put(unsigned char v) {
    PPU_DATA_REG = v;
}

void vram_fill(unsigned char value, unsigned int len) {
    while (len--) {
        PPU_DATA_REG = value;
    }
}

void ppu_clear_nt(unsigned int nt_base, unsigned char tile) {
    unsigned char row;
    unsigned char col;

    vram_adr(nt_base);
    for (row = 0; row < 30; ++row) {
        for (col = 0; col < 32; ++col) {
            PPU_DATA_REG = tile;
        }
    }

    vram_adr(nt_base + 0x03C0u);
    vram_fill(0x00, 64);
}

unsigned char pad_poll(unsigned char pad) {
    unsigned char i;
    unsigned char out = 0;
    unsigned char mask = 1;
    volatile unsigned char* reg = (pad == 0) ? &JOYPAD1_REG : &JOYPAD2_REG;

    JOYPAD1_REG = 1;
    JOYPAD1_REG = 0;

    for (i = 0; i < 8; ++i) {
        if ((*reg & 1) != 0) {
            out |= mask;
        }
        mask <<= 1;
    }
    return out;
}
