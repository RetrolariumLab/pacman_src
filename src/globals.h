#ifndef GLOBALS_H
#define GLOBALS_H

extern unsigned char byte_A;
extern unsigned char byte_B;
extern unsigned char byte_C;
extern unsigned char byte_D;
extern unsigned char byte_E;
extern unsigned char byte_F;
extern unsigned char byte_B9_ram[];

extern unsigned char byte_BC;
extern unsigned char byte_BD;
extern unsigned char byte_D9;
extern unsigned char byte_DA;
extern unsigned char byte_DB;
extern unsigned char byte_DC;
extern unsigned char byte_DD;
extern unsigned char byte_DE;

extern unsigned char byte_2;
extern unsigned char byte_3;
extern unsigned char byte_4;
extern unsigned char byte_5;
extern unsigned char byte_46;
extern unsigned char byte_47;

extern unsigned char ram_obj_pos_X_hi[];
extern unsigned char byte_1A_ram[];
extern unsigned char byte_1C_ram[];
extern unsigned char byte_12;
extern unsigned char byte_13;
extern unsigned char byte_14;
extern unsigned char byte_15;

extern unsigned char byte_0;
extern unsigned char byte_1;
extern unsigned char byte_FFF8;
extern unsigned char byte_FFF9;

// PPU Registers (memory-mapped)
#define PPU_SR      (*(volatile unsigned char*)0x2002)
#define VRAM_AR_2   (*(volatile unsigned char*)0x2006)
#define VRAM_IOR    (*(volatile unsigned char*)0x2007)

// Pointers to cartridge RAM (WRAM/SRAM)
#define byte_608 (*(unsigned char*)0x6008)
#define byte_609 (*(unsigned char*)0x6009)
#define byte_60A (*(unsigned char*)0x600A)

// Global arrays
extern unsigned char byte_200_ram[256]; // Represents RAM from $0200
extern unsigned char ram_oam[256];

extern unsigned char byte_22A_ram[];
extern unsigned char byte_23F;
extern unsigned char byte_23F_ram[];
extern unsigned char byte_245;
extern unsigned char byte_245_ram[];
extern unsigned char byte_26B;
extern unsigned char byte_26C;
extern unsigned char byte_26D;
extern unsigned char byte_26E;
extern unsigned char byte_26F[];
extern unsigned char byte_272;
extern unsigned char byte_273;

extern unsigned char unk_604[];

// Data arrays
extern const unsigned char byte_E2FC[];
extern const unsigned char* const off_E419[]; // Array of pointers
extern const unsigned char word_E4B6[];

// Score arrays
extern unsigned char ram_score_hi[];
extern unsigned char ram_score_p1[];
extern unsigned char ram_score_p2[];

extern unsigned char ram_data_p1[16];

#endif // GLOBALS_H
