#include "pacman.h"

// Global variable definitions
unsigned char byte_40;
unsigned char byte_41;
unsigned char byte_42;
unsigned char byte_43;
unsigned char byte_45;
unsigned char byte_46;
unsigned char byte_47;
unsigned char byte_48;
unsigned char byte_49;
unsigned char byte_4A;
unsigned char byte_4B;
unsigned char byte_4C;
unsigned char byte_4D;
unsigned char byte_4E;
unsigned char byte_4F;
unsigned char byte_50;
unsigned char byte_51;
unsigned char byte_52;
unsigned char byte_53;
unsigned char byte_54;
unsigned char byte_55;
unsigned char byte_56;
unsigned char byte_57;
unsigned char byte_58;
unsigned char byte_59;
unsigned char byte_5A;
unsigned char byte_5B;
unsigned char byte_5C;
unsigned char byte_5D;
unsigned char byte_5E;
unsigned char byte_5F;
unsigned char byte_60;
unsigned char byte_61;
unsigned char byte_62;
unsigned char byte_63;
unsigned char byte_64;
unsigned char byte_67;
unsigned char byte_68;
unsigned char byte_69;
unsigned char byte_6A;
unsigned char byte_6B;
unsigned char byte_6C;
unsigned char byte_6D;
unsigned char byte_6E;
unsigned char byte_6F;
unsigned char byte_3F;
unsigned char byte_23F;
unsigned char byte_24D;
unsigned char byte_251;
unsigned char byte_2A7;
unsigned char byte_B1;
unsigned char byte_B2;
unsigned char byte_B3;
unsigned char byte_B5;
unsigned char byte_B6;
unsigned char byte_B7;
unsigned char byte_B8;
unsigned char byte_B9_ram[4]; // For 4 ghosts
unsigned char byte_BC;
unsigned char byte_BD;
unsigned char byte_AC;
unsigned char byte_AD;
unsigned char byte_AE;
unsigned char byte_AF;
unsigned char byte_DE;
unsigned char byte_DD;
unsigned int  word_87;
unsigned int  word_88;
unsigned char byte_89;
unsigned char byte_8A;
unsigned char byte_91;
unsigned char byte_93;
unsigned char byte_92;
unsigned char byte_94;

// Global arrays
unsigned char ram_oam[256];
unsigned char ram_sprite_data[256];
unsigned char ram_ppu_buffer_main[256];
unsigned char ram_reset_check[15];
unsigned char ram_data_p1[16];
unsigned char ram_data_p2[16];
unsigned char byte_1E_ram[20];
unsigned char byte_1F_ram[20];
unsigned char byte_22_ram[20];
unsigned char byte_23_ram[20];
unsigned char byte_278[20];
unsigned char byte_27A[20];
unsigned char byte_28D[4];
unsigned char byte_293[4];
unsigned char byte_292_arr[5];
unsigned char byte_2A8[45];
unsigned char byte_2D5[45];
unsigned char byte_302[45];
unsigned char byte_32F[8];
unsigned char byte_A2[16];
unsigned char byte_9A[4];
unsigned char byte_337[8];
unsigned char byte_33F[4];
unsigned char byte_357[4];
unsigned char byte_367[4];
unsigned char byte_377[4];
unsigned char byte_387[4];
unsigned char byte_397[4];
unsigned char byte_3A7[4];
unsigned char byte_37[4];

// Misc global variables that were not bytes
unsigned char byte_28C;
unsigned char byte_292;
unsigned char byte_294;
unsigned char byte_295;
unsigned char byte_296;

// Data tables from ROM
const unsigned char tbl_C395_background_palette[16] = {
#include "../assets/generated/c/ec25cd088056307b.inc"
};

const unsigned char tbl_C29F_pacman_logo[144] = {
#include "../assets/generated/c/42099a7bf62e02a5.inc"
};

const unsigned char tbl_C329_logo_text_0[] = {
    0x20, 0x65, 0xB0, 0xB3, 0xB2, 0x20, 0x20, 0x20, 0x20, 0xB4, 0xB5, 0xB6,
    0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0x20, 0x20, 0x20, 0xB1, 0xB3, 0xB2, 0xFF,
    0x22, 0x0A, 0x5C, '-', '1', ' ', 'P', 'L', 'A', 'Y', 'E', 'R', 0xFF,
    0x22, 0x4C, '2', ' ', 'P', 'L', 'A', 'Y', 'E', 'R', 'S', 0xFF,
    0x22, 0xAC, '#', '$', '%', '&', '\'', '(', ')', '*', '+', 0xFF,
    0x23, 0x05, ']', ' ', '1', '9', '8', '0', ' ', '1', '9', '8', '4', ' ',
    'N', 'A', 'M', 'C', 'O', ' ', 'L', 'T', 'D', '[', 0xFF,
    0x23, 0x47, 'A', 'L', 'L', ' ', 'R', 'I', 'G', 'H', 'T', 'S', ' ',
    'R', 'E', 'S', 'E', 'R', 'V', 'E', 'D', 0xFF
};

const unsigned char tbl_C3A5_background_attributes_0[24] = {
    0x80, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0x00,
    0x00, 0x66, 0x55, 0x55, 0x55, 0x55, 0xDD, 0x00,
    0x08, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x00
};

const unsigned char tbl_C44D[] = { 0x22, 0x0A, 0x5C, 0x00, 0x22, 0x4A, 0x20, 0xFF };
const unsigned char tbl_C455[] = { 0x5C, 0x20, 0x5C };

const unsigned char tbl_C5B3_palette[] = {
#include "../assets/generated/c/2ea21de027701c59.inc"
};

const unsigned char tbl_C90E[] = {
    0x22, 0xAD, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D,
    0x00, 0x22, 0xED, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0xFF
};

const unsigned char tbl_C928[] = { 0x22, 0xC7, 0x20, 0xFF, 0x22, 0xC7, 0x01, 0xFF };
const unsigned char tbl_C924[] = { 0x2D, 0x2F, 0x32, 0x34 };

const unsigned char tbl_C976[] = {
    4, 4, 4, 5, 5, 4, 1, 1,
    0x0C, 0x0D, 8, 8, 8, 9, 9, 8,
    1, 1, 0x1E, 0x1F
};

const unsigned char tbl_CA91[] = {
    0x50, 0x41, 0x55, 0x53, 0x45, 0xFF,
    0x2D, 0x2D, 0x2D, 0x2D, 0x2D, 0xFF
};

const unsigned char tbl_CBD2_spr_T[] = {
    0xC6, 0xC3, 0xC1, 0xBA, 0xC7, 0xBB, 0xB0, 0xB1,
    0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB4, 0xB8,
    0xB9, 0xB6
};

const unsigned char tbl_CBE4_spr_A[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02,
    0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02,
    0x02, 0x02
};

const unsigned char tbl_CBF6_spr_pos[] = {
    0x44, 0x88, 0x44, 0x60, 0x50, 0x70
};

const unsigned char tbl_CBFC_spr_counter[] = {
    0x06, 0x06, 0x03
};

const unsigned char tbl_CC07[] = {
    0x23, 0x17, 0x23, 0x19, 0x23, 0x1B, 0x23, 0x57
};

const unsigned char tbl_CD59[] = {
    0xFF, 0x11, 0x05, 0x3F,
    0xFF, 0x20, 0x05, 0x3F
};

const unsigned char tbl_CE01_spr_T[] = {
    0xBC, 0xB2, 0xBD, 0xB4, 0xB6, 0xBE, 0xB4, 0xB5, 0xB0, 0xB1,
    0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB4, 0xB8, 0xB9, 0xB6
};

const unsigned char tbl_CE15_spr_A[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02,
    0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
};

const unsigned char tbl_CE29_spr_pos[] = {
    0x38, 0x88, 0x60, 0x88, 0x44, 0x60, 0x50, 0x70
};

const unsigned char tbl_CE31_spr_counter[] = {
    0x04, 0x04, 0x06, 0x03
};

const unsigned char tbl_C5D3[] = {0};

const unsigned char word_C5E7_00[] = {
    0x20, 0xE6, 'C', 'H', 'R', 'A', 'C', 'T', 'E', 'R', ' ', ';', ' ', ' ', 'N', 'I', 'C', 'K', 'N', 'A', 'M', 'E', 0xFF, 0x01
};
const unsigned char word_C5FF_02[] = {
    0x21, 0x48, 'O', 'I', 'K', 'A', 'K', 'E', '.', '.', '.', '.', '.', 0xFF, 0x00
};
const unsigned char word_C60E_04[] = {
    0x21, 0x53, '_', 'A', 'K', 'A', 'B', 'E', 'I', '_', 0xFF, 0x01
};
const unsigned char word_C619_06[] = {
    0x21, 0xA8, 'M', 'A', 'C', 'H', 'I', 'B', 'U', 'S', 'E', '.', '.', 0xFF, 0x00
};
const unsigned char word_C628_08[] = {
    0x21, 0xB3, '_', 'P', 'I', 'N', 'K', 'Y', '_', 0xFF, 0x01
};
const unsigned char word_C632_0A[] = {
    0x22, 0x08, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0x03, 0x03, 0x03, 0xFF, 0x00
};
const unsigned char word_C641_0C[] = {
    0x22, 0x13, 0xC8, 0xC3, 0xC9, 0xCA, 0xC5, 0xC0, 0xC7, 0xC8, 0xFF, 0x01
};
const unsigned char word_C64C_0E[] = {
    0x22, 0x68, 'O', 'T', 'O', 'B', 'O', 'K', 'E', '.', '.', '.', '.', 0xFF, 0x00
};
const unsigned char word_C65B_10[] = {
    0x22, 0x73, '_', 'G', 'U', 'Z', 'U', 'T', 'A', '_', 0xFF, 0x01
};
const unsigned char word_C666_12[] = {
    0x22, 0xAD, 0x03, 0x20, '1', '0', ' ', 'P', 'T', 'S', 0x00,
    0x22, 0xED, 0x01, 0x20, '5', '0', ' ', 'P', 'T', 'S', 0x00,
    0x23, 0x4C, '#', '$', '%', '&', '\'', '(', ')', '*', '+', 0xFF, 0x01
};

const unsigned char* const tbl_C5D3_ptrs[] = {
    word_C5E7_00,
    word_C5FF_02,
    word_C60E_04,
    word_C619_06,
    word_C628_08,
    word_C632_0A,
    word_C641_0C,
    word_C64C_0E,
    word_C65B_10,
    word_C666_12
};

const unsigned char tbl_C688_spr_data_0[] = {
    0x48, 0x1C, 0x40, 0x26, 0x48, 0x1B, 0x40, 0x2E, 0x50, 0x1F, 0x40, 0x26, 0x50, 0x1D, 0x40, 0x2E,
    0x60, 0x1C, 0x41, 0x26, 0x60, 0x1B, 0x41, 0x2E, 0x68, 0x1F, 0x41, 0x26, 0x68, 0x1D, 0x41, 0x2E,
    0x78, 0x1C, 0x42, 0x26, 0x78, 0x1B, 0x42, 0x2E, 0x80, 0x1F, 0x42, 0x26, 0x80, 0x1D, 0x42, 0x2E,
    0x90, 0x1C, 0x43, 0x26, 0x90, 0x1B, 0x43, 0x2E, 0x98, 0x1F, 0x43, 0x26, 0x98, 0x1D, 0x43, 0x2E
};

unsigned char byte_760[0xA0];
unsigned char byte_778[0x24];

// ROM data tables ported to C
const unsigned char byte_EB42[] = {0, 7, 0, 0, 0, 4, 1, 6};
const unsigned char byte_EBCC[] = {0xD0, 0, 0xC0, 0, 0xA0, 0, 0xB0, 0};
const unsigned char byte_EC3A[] = {7, 0x14, 7, 0x14, 5, 0x14, 5, 0xFF};
const unsigned char byte_EC5A[] = {0x14, 0xA, 0x1E, 0xF, 0x28, 0x14, 0x32, 0x19};
const unsigned char byte_EC68[] = {2, 0x1E, 0x5A, 0, 3, 0x32, 0, 0, 4, 0, 0, 0, 1, 7, 0x11, 0x20};
const unsigned char tbl_D04E_ppu[] = {0x21, 0x36}; // .WORD $3621 is stored little-endian
const unsigned char tbl_D042_spr_data[] = {4, 0x0C, 0x0A};

const unsigned char byte_D205[] = { 0x00, 0x3F, 0x15, 0x11, 0xFF, 0x00, 0x3F, 0x15, 0x20, 0xFF };

const unsigned char byte_D2D7[] = { 0x2D, 0x2F, 0x32, 0x34 };
const unsigned char byte_D2DB[] = { 0x2C, 0x2E, 0x30, 0x31, 0x33, 0x35, 0x36, 0x37 };
const unsigned char byte_D2E3[] = { 0, 0, 0, 1 };
const unsigned char byte_D2E7[] = { 2, 4, 8, 6 };
const unsigned char byte_D2EB[] = { 1, 3, 5, 7, 0, 0, 0, 0 };
const unsigned char byte_D2F3[] = { 0, 0, 0, 0, 1, 2, 3, 5 };

const unsigned char byte_D46D[] = { 3, 1, 2, 0 };

unsigned char byte_D9;
unsigned char byte_DA;
unsigned char byte_DB;
unsigned char byte_DC;
unsigned char byte_D7;
unsigned char byte_D8;
unsigned char byte_DD;
unsigned char byte_DE;

unsigned char byte_22A;
unsigned char byte_23F;
unsigned char byte_23F_ram[6];
unsigned char byte_245;
unsigned char byte_245_ram[6];
unsigned char byte_26B;
unsigned char byte_26C;
unsigned char byte_26D;
unsigned char byte_26E;
unsigned char byte_26F[3];
unsigned char byte_272;
unsigned char byte_273;

unsigned char unk_604[2];

// Pointers to cartridge RAM (WRAM/SRAM)
// ... existing code ...

unsigned char byte_2;
unsigned char byte_3;
unsigned char byte_4;
unsigned char byte_5;

// ... existing code ...

// Global arrays
unsigned char byte_200_ram[256]; // Represents RAM at $0200-$02FF
unsigned char byte_22A_ram[0x2A]; // Size based on sub_E21C loop

// Sizes are tentative and should be refined as code analysis progresses.
unsigned char ram_obj_pos_X_hi[16];
unsigned char ram_obj_pos_X_lo[16];
unsigned char ram_obj_pos_Y_hi[16];
unsigned char ram_spr_pos_X_hi[16];
unsigned char ram_spr_pos_Y_hi[16];
unsigned char byte_15;

unsigned char byte_0;
unsigned char byte_1;
unsigned char byte_FFF8;
unsigned char byte_FFF9;

// Data arrays
const unsigned char byte_E2FC[] = {0x2D, 4, 0x2D};

// Score arrays (size 6 for 6 BCD digits)
unsigned char ram_score_hi[6];
unsigned char ram_score_p1[6];
unsigned char ram_score_p2[6];

// Table of pointers to score arrays
const unsigned char* const off_E419[] = {
    ram_score_hi,
    ram_score_p1,
    ram_score_p2,
    ram_score_hi,
    ram_score_p2,
    ram_score_p1,
    ram_score_p1,
    ram_score_hi,
    ram_score_p2
};

const unsigned char word_E4B6[] = {
    0x20, 0x76, 0x08, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB,
    0x20, 0xF7, 0x03, 0xB0, 0xB3, 0xB2,
    0x21, 0x77, 0x03, 0xB1, 0xB3, 0xB2
};

unsigned char byte_A;
unsigned char byte_B;
unsigned char byte_C;
unsigned char byte_D;
unsigned char byte_E;
unsigned char byte_F;

const unsigned char byte_E619[] = {
    0, 1, 2, 2, 3, 3, 4, 4, 5, 5,
    6, 6, 7, 7, 7, 7, 7, 7, 7, 7
};

const unsigned char byte_E62D[] = {
    0, 3, 1, 2, 1, 3, 2, 2, 3, 1, 4, 0, 4, 1, 5, 0
};

const unsigned char byte_E63D[] = {
    2, 2, 2, 2, 3, 3, 3, 3
};

const unsigned char byte_E645[] = {
    0x16, 0x16, 0x26, 0x26, 0x06, 0x06, 0x19, 0x19,
    0x17, 0x17, 0x17, 0x17, 0x12, 0x12, 0x12, 0x12
};

const unsigned char byte_E73B[] = {
#include "../assets/generated/c/b42defaad586242c.inc"
};

unsigned char byte_60D;
unsigned char byte_60E;

// Sound engine variables
unsigned char byte_F0_ram[16];
unsigned char byte_F1_ram[16];
unsigned char byte_F2_ram[16];
unsigned char byte_F3_ram[16];
unsigned char byte_F4_ram[16];
unsigned char byte_F5_ram[16];
unsigned char byte_F6_ram[16];
unsigned char byte_F7_ram[16];
unsigned char byte_F8_ram[16];
unsigned char byte_F9_ram[16];
unsigned char byte_FA_ram[16];
unsigned char byte_FB_ram[16];
unsigned char byte_FC;
unsigned char byte_FD;
unsigned char byte_FE;
unsigned char byte_FF;

// Sound engine data tables
const unsigned char byte_F074[] = {0, 1, 2, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0, 1, 2, 3};
const unsigned char off_F08C[] = {0x00, 0x0C, 0x18, 0x24, 0x30, 0x3C, 0x48, 0x54, 0x60, 0x6C, 0x78, 0x84};
const unsigned char off_F08E[] = {0x0C, 0x18, 0x24, 0x30, 0x3C, 0x48, 0x54, 0x60, 0x6C, 0x78, 0x84, 0x90};
const unsigned char byte_F0B6[] = {0x80, 0x40, 0x20, 0x10, 8, 4, 2, 1};
const unsigned char byte_F2C0[] = {0, 1, 2, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0, 1, 2, 3};
const unsigned char byte_F307[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};
const unsigned char off_F319[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1};
const unsigned char off_F329[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};
const unsigned char byte_F446[] = {0x2C, 0x42, 0x6C, 0x82, 0xAC, 0xC2, 0xEC, 0xF2, 0};
const unsigned char byte_F531[] = {0x2C, 0x42, 0x6C, 0x82, 0xAC, 0xC2, 0xEC, 0xF2, 0};
const unsigned char byte_F55B[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};
const unsigned char byte_F59D[] = {0x10, 0x12, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, 0, 0, 0, 0, 0, 0, 0, 0};
const unsigned char off_F64F[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
const unsigned char byte_F67B[] = {1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80};
const unsigned char byte_F685[] = {0xFF, 0xFE, 0xFC, 0xF8, 0xF0, 0xE0, 0xC0, 0x80};
const unsigned char off_F6A3[] = {0, 1, 2, 3, 4, 5, 6, 7};
const unsigned char byte_F77B[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};
const unsigned char byte_F7F8[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};
const unsigned char byte_F82E[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF};
const unsigned char byte_F992[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0, 1, 2, 3};

// Sound data for channels
const unsigned char Ch1_8bit_ptr_lo[] = {
    0x90, 0x9C, 0xA8, 0xB4, 0xC0, 0xCC, 0xD8, 0xE4, 0xF0, 0xFC, 0x08, 0x14
};
const unsigned char Ch1_8bit_ptr_hi[] = {
    0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF1, 0xF1
};
const unsigned char Ch2_8bit_ptr_lo[] = {
    0x20, 0x2C, 0x38, 0x44, 0x50, 0x5C, 0x68, 0x74, 0x80, 0x8C, 0x98, 0xA4
};
const unsigned char Ch2_8bit_ptr_hi[] = {
    0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1
};
const unsigned char Ch3_8bit_ptr_lo[] = {
    0xB0, 0xBC, 0xC8, 0xD4, 0xE0, 0xEC, 0xF8, 0x04, 0x10, 0x1C, 0x28, 0x34
};
const unsigned char Ch3_8bit_ptr_hi[] = {
    0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF1, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2
};
const unsigned char Ch4_8bit_ptr_lo[] = {
    0x40, 0x4C, 0x58, 0x64, 0x70, 0x7C, 0x88, 0x94, 0xA0, 0xAC, 0xB8, 0xC4
};
const unsigned char Ch4_8bit_ptr_hi[] = {
    0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2, 0xF2
};
const unsigned char Ch5_8bit_ptr_lo[] = {
    0xD0, 0xDC, 0xE8, 0xF4, 0x00, 0x0C, 0x18, 0x24
};
const unsigned char Ch5_8bit_ptr_hi[] = {
    0xF2, 0xF2, 0xF2, 0xF2, 0xF3, 0xF3, 0xF3, 0xF3
};
const unsigned char Ch6_8bit_ptr_lo[] = {
    0x3C, 0x48, 0x54, 0x60, 0x6C, 0x78, 0x84, 0x90
};
const unsigned char Ch6_8bit_ptr_hi[] = {
    0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3
};
const unsigned char Ch7_8bit_ptr_lo[] = {
    0x9C, 0xA8, 0xB4, 0xC0, 0xCC, 0xD8, 0xE4, 0xF0, 0xFC, 0x08, 0x14, 0x20
};
const unsigned char Ch7_8bit_ptr_hi[] = {
    0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF3, 0xF4, 0xF4, 0xF4
};
const unsigned char Ch8_8bit_ptr_lo[] = {
    0x3A, 0x4A, 0x5A, 0x6A, 0x7A, 0x8A, 0x9A, 0xAA, 0xBA, 0xCA, 0xDA, 0xEA,
    0xFA, 0x0A, 0x1A, 0x2A
};
const unsigned char Ch8_8bit_ptr_hi[] = {
    0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5, 0xF5,
    0xF5, 0xF6, 0xF6, 0xF6
};
const unsigned char Ch9_8bit_ptr_lo[] = {
    0x83, 0x8F, 0x9B, 0xA7, 0xB3, 0xBF, 0xCB, 0xD7
};
const unsigned char Ch9_8bit_ptr_hi[] = {
    0xF6, 0xF6, 0xF6, 0xF6, 0xF6, 0xF6, 0xF6, 0xF6
};
const unsigned char Ch10_8bit_ptr_lo[] = {
    0xAB, 0xB8, 0xC5, 0xD2, 0xDF, 0xEC, 0xF9, 0x06, 0x13, 0x20, 0x2D, 0x3A,
    0x47, 0x54, 0x61, 0x6E
};
const unsigned char Ch10_8bit_ptr_hi[] = {
    0xF7, 0xF7, 0xF7, 0xF7, 0xF7, 0xF7, 0xF7, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8,
    0xF8, 0xF8, 0xF8, 0xF8
};
const unsigned char Ch11_8bit_ptr_lo[] = {
    0x7B, 0x88, 0x95, 0xA2, 0xAF, 0xBC, 0xC9, 0xD6, 0xE3, 0xF0, 0xFD, 0x0A,
    0x17, 0x24
};
const unsigned char Ch11_8bit_ptr_hi[] = {
    0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF9,
    0xF9, 0xF9
};
const unsigned char Ch12_8bit_ptr_lo[] = {
    0x3E, 0x4B, 0x58, 0x65, 0x72, 0x7F, 0x8C, 0x99, 0xA6, 0xB3, 0xC0, 0xCD,
    0xDA, 0xE7, 0xF4, 0x01
};
const unsigned char Ch12_8bit_ptr_hi[] = {
    0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9, 0xF9,
    0xF9, 0xF9, 0xF9, 0xFA
};
