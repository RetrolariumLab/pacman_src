#include "neslib.h"

void pal_col(unsigned char idx, unsigned char color) {
    (void)PPU_STATUS_REG;
    PPU_ADDR_REG = 0x3F;
    PPU_ADDR_REG = idx & 0x1F;
    PPU_DATA_REG = color;
}

void vram_adr(unsigned int addr) {
    (void)PPU_STATUS_REG;
    PPU_ADDR_REG = (unsigned char)(addr >> 8);
    PPU_ADDR_REG = (unsigned char)(addr & 0xFF);
}

void vram_put(unsigned char value) {
    PPU_DATA_REG = value;
}

void ppu_puts(const char* s, unsigned char len) {
    while (len--) {
        PPU_DATA_REG = (unsigned char)*s++;
    }
}

void ppu_on_all(void) {
    PPU_MASK_REG = 0x1E;
}

void ppu_off(void) {
    PPU_MASK_REG = 0x00;
}

void ppu_wait_nmi(void) {
    while (PPU_STATUS_REG & 0x80) {
    }
    while ((PPU_STATUS_REG & 0x80) == 0) {
    }
}

unsigned char pad_poll(unsigned char pad) {
    unsigned char i;
    unsigned char value = 0;
    unsigned char mask = 1;
    volatile unsigned char* joy;

    joy = (volatile unsigned char*)(pad == 0 ? 0x4016 : 0x4017);
    JOYPAD1_REG = 1;
    JOYPAD1_REG = 0;

    for (i = 0; i < 8; ++i) {
        /* D0 is the latched joypad bit for each button.
           Bit order: A, B, Select, Start, Up, Down, Left, Right. */
        if ((*joy & 1) != 0) {
            value |= mask;
        }
        mask <<= 1;
    }

    return value;
}
