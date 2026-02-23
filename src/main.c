#include "pacman.h"
#include "game.h"
#include <string.h>
#include <stdlib.h>
#include <neslib.h>

// Function Prototypes
void sub_C821(void);
void sub_C930(void);

static unsigned char btn_select_pressed(unsigned char p) {
    return (unsigned char)((p & (0x04 | 0x20)) != 0);
}

static unsigned char btn_start_pressed(unsigned char p) {
    return (unsigned char)((p & (0x08 | 0x10)) != 0);
}

void sub_E2FF(void) {
    /* Basic reset-like init used by the main setup path. */
    byte_40 = 0;
    byte_41 = 0;
    byte_42 = 0;
    byte_4A = 0;
    byte_4B = 0;
    byte_4C = 0;
    byte_4D = 0;
    byte_4E = 0;
    byte_4F = 0;
    byte_50 = 0;
    byte_51 = 0;
    word_87 = 0;
    word_88 = 0;
    memset(ram_ppu_buffer_main, 0, sizeof(ram_ppu_buffer_main));
    memset(ram_sprite_data, 0, sizeof(ram_sprite_data));
    ram_ppu_buffer_main[0] = 0xFF;
}

void sub_E393(void) {
    /* Keep scroll/latch state deterministic at startup. */
    (void)PPU_STATUS;
    PPU_SCROLL = 0;
    PPU_SCROLL = 0;
    byte_41 = 0;
    byte_42 = 0;
}
void sub_C51E(void) {
    unsigned char i, j;

    // Reset PPU address latch, and set the address to 0x20C0
    (void)PPU_STATUS;
    PPU_ADDR = 0x20;
    PPU_ADDR = 0xC0;

    // This loop runs 24 times for 24 rows of the playfield.
    for (i = 0; i < 24; ++i) {
        // Write the left border characters '--'
        PPU_DATA = '-';
        PPU_DATA = '-';

        // Write 28 space characters ' '
        for (j = 0; j < 28; ++j) {
            PPU_DATA = ' ';
        }

        // Write the right border characters '--'
        PPU_DATA = '-';
        PPU_DATA = '-';
    }
}
void sub_C54E(void) {
    unsigned char i, j;
    unsigned char attr_val;

    // --- Part 1: Clear first half of attribute table ---
    (void)PPU_STATUS;
    PPU_ADDR = 0x23;
    PPU_ADDR = 0xC0;
    for (i = 0; i < 32; ++i) {
        PPU_DATA = 0x00;
    }

    // --- Part 2: Fill second half of attribute table ---
    // PPU address continues to 0x23D0
    attr_val = 0x55;
    for (i = 0; i < 3; ++i) {
        for (j = 0; j < 8; ++j) {
            PPU_DATA = attr_val;
        }
        attr_val += 0x55;
    }

    // --- Part 3: Load palette data ---
    (void)PPU_STATUS;
    PPU_ADDR = 0x3F;
    PPU_ADDR = 0x00;
    for (i = 0; i < PALETTE_SIZE; ++i) {
        PPU_DATA = tbl_C5B3_palette[i];
    }

    // --- Part 4: Write final attribute bytes ---
    (void)PPU_STATUS;
    PPU_ADDR = 0x23;
    PPU_ADDR = 0xE8;
    PPU_DATA = 0xAA;
    PPU_DATA = 0xAA;
    PPU_DATA = 0xAA;
    PPU_DATA = 0x22;
}

void sub_C284(void) {
    unsigned char i;
    (void)PPU_STATUS;
    PPU_ADDR = 0x23;
    PPU_ADDR = 0xC8;
    for (i = 0; i < 24; ++i) {
        PPU_DATA = tbl_C3A5_background_attributes_0[i];
    }
}

// State function declarations
int sub_C6DD(void);
int sub_C728(void);
int sub_C78D(void);

int sub_C6C8(void) {
    static int (* const anim_state_table[])(void) = {
        sub_C6DD, // state 0
        NULL,     // state 1 (unused)
        sub_C728, // state 2
        NULL,
        sub_C78D  // state 4
    };
    unsigned char state_idx = (unsigned char)word_88;
    if (state_idx < 5 && anim_state_table[state_idx]) {
        return anim_state_table[state_idx]();
    }
    return 0; // Default case, continue loop
}
void init_game(void);
int sub_C98A(void);

// Updates PPU buffer and sprite data based on current animation frame
void sub_C4EC(void) {
    unsigned char state_idx = (unsigned char)word_87;
    unsigned char i;
    const unsigned char* data_ptr;

    if ((state_idx >> 1) >= 10) {
        ram_ppu_buffer_main[0] = 0xFF;
        return;
    }

    data_ptr = tbl_C5D3_ptrs[state_idx >> 1];

    // Copy tokenized PPU command stream until 0xFF.
    i = 0;
    while (data_ptr[i] != 0xFF) {
        ram_ppu_buffer_main[i] = data_ptr[i];
        ++i;
    }
    ram_ppu_buffer_main[i] = 0xFF;

    // If the byte after 0xFF is 0, update OAM window like the original routine.
    if (data_ptr[i + 1] == 0) {
        unsigned char spr_idx;
        spr_idx = (state_idx - 2) * 4;
        memcpy(&ram_oam[0x60 + spr_idx], &tbl_C688_spr_data_0[spr_idx], 16);
    }
}

// Animation state: initial setup
int sub_C48C(void) {
    ppu_wait_nmi();
    PPU_CTRL = 0x08; // NMI off, sprites disabled
    byte_43 = 0x08;
    PPU_MASK = 0x00; // Rendering off

    word_87 &= 0xFF00; // Clear low byte of counter (byte_87=0)

    sub_C51E();
    sub_C54E();
    sub_C4EC();

    word_87 += 2; // Advance to next animation state

    PPU_CTRL = 0x88; // NMI on
    byte_43 = 0x88;
    ppu_on_all();    // Ensure rendering returns after transition setup.

    return 0; // Continue loop
}

// Animation state: wait for a short duration
int sub_C4B9(void) {
    word_87 += 0x0100; // Increment high byte of counter
    if ((word_87 >> 8) == 0x30) { // Check if high byte is 0x30
        word_87 &= 0x00FF; // Clear high byte
        sub_C4EC();
        word_87 += 2; // Advance to next animation state
    }
    return 0;
}

// Animation state: wait for a longer duration
int sub_C4CF(void) {
    word_87 += 0x0100; // Increment high byte of counter
    if ((word_87 >> 8) == 0x80) { // Check if high byte is 0x80
        word_87 += 2; // Advance to next animation state
        word_87 &= 0x00FF; // Clear high byte
    }
    return 0;
}

// Jumps to game start logic for 2 players
int sub_C4E5(void) {
    byte_47 = 1;
    sub_C98A();
    return 0;
}

// Animation state dispatcher.
// It calls one of the above subroutines based on the current state.
int sub_C458(void) {
    // This table maps animation state index to a function.
    // The index is the low byte of word_87.
    static int (* const anim_state_table[])(void) = {
        sub_C48C, // state 0
        NULL,     // state 1 (unused)
        sub_C4B9, // state 2
        NULL,
        sub_C4B9, // state 4
        NULL,
        sub_C4B9, // state 6
        NULL,
        sub_C4B9, // state 8
        NULL,
        sub_C4B9, // state 10
        NULL,
        sub_C4CF, // state 12
        NULL,
        sub_C6C8  // state 14
    };
    unsigned char state_idx = (unsigned char)word_87;
    if (state_idx < 15 && anim_state_table[state_idx]) {
        return anim_state_table[state_idx]();
    }
    return 0; // Default case, continue loop
}

// The IRQ routine is empty in the assembly, it just returns.
void irq_routine(void) {
}

void loc_DA5C(void) {
    static const unsigned char k_spr_offset_xy[8] = {
        0x03, 0xF4, 0x03, 0xFC, 0x0B, 0xF4, 0x0B, 0xFC
    };
    unsigned char obj;
    unsigned char spr;
    unsigned char oam_idx = 0;

    for (obj = 0; obj < 6; ++obj) {
        unsigned char base = (unsigned char)(obj << 2);
        unsigned char pos_x;
        unsigned char pos_y;
        unsigned char anim;
        unsigned char attr_base;

        if (obj == 0) {
            pos_x = ram_spr_pos_X_hi[0];
            pos_y = ram_spr_pos_Y_hi[0];
            anim = byte_28C;
            attr_base = byte_292;
        } else {
            pos_x = byte_278[base];
            pos_y = byte_27A[base];
            anim = byte_28D[(obj - 1) & 3];
            attr_base = byte_292_arr[(obj - 1) & 3];
        }

        for (spr = 0; spr < 4; ++spr) {
            unsigned char tile_idx = (unsigned char)((anim << 2) + spr);
            unsigned char yy;
            unsigned char xx;

            if (pos_y == 0) {
                yy = 0xFF;
            } else {
                yy = (unsigned char)(pos_y + k_spr_offset_xy[spr << 1]);
            }
            xx = (unsigned char)(pos_x + k_spr_offset_xy[(spr << 1) + 1]);

            ram_oam[oam_idx + 0] = yy;
            ram_oam[oam_idx + 1] = (unsigned char)(0x4C + (tile_idx & 0x03));
            ram_oam[oam_idx + 2] = attr_base;
            ram_oam[oam_idx + 3] = xx;
            oam_idx = (unsigned char)(oam_idx + 4);
        }
    }
}

void sub_C8EE(void) {
    unsigned char y_offset = 0;
    if ((byte_4B & 7) != 0) {
        return;
    }
    if ((byte_4B & 8) != 0) {
        y_offset = 4;
    }
    memcpy(&ram_ppu_buffer_main[0], &tbl_C928[y_offset], 4);
}
void sub_C7DE(void) {
    unsigned char y_base;
    unsigned char ghost_idx;

    ghost_idx = 0;
    for (y_base = 0; y_base < 16; y_base += 4) {
        if (byte_278[y_base] == 0) {
            break;
        }
        ++ghost_idx;
    }

    byte_278[y_base] = 0xF4;
    byte_27A[y_base] = 0xA8;
    byte_1E_ram[y_base] = 0xFF;
    byte_1F_ram[y_base] = 0x00;

    byte_293[ghost_idx] = byte_89;
    byte_28D[ghost_idx] = 0x0C;
    ++byte_89;
}
void sub_C864(void) {
    unsigned char i;
    unsigned char temp_obj_hi;
    unsigned char temp_obj_lo;
    unsigned char temp_spr_x;
    unsigned char temp_spr_y;
    unsigned char temp_28D;
    unsigned char temp_293;

    temp_obj_hi = byte_1E_ram[0];
    temp_obj_lo = byte_1F_ram[0];
    for (i = 0; i < 12; i += 4) {
        byte_1E_ram[i] = byte_22_ram[i];
        byte_1F_ram[i] = byte_23_ram[i];
    }
    byte_1E_ram[16] = temp_obj_hi;
    byte_1F_ram[16] = temp_obj_lo;

    temp_spr_x = byte_278[0];
    temp_spr_y = byte_27A[0];
    for (i = 0; i < 12; ++i) {
        byte_278[i] = byte_278[i + 4];
        byte_27A[i] = byte_27A[i + 4];
    }
    byte_278[16] = temp_spr_x;
    byte_27A[16] = temp_spr_y;

    temp_28D = byte_28D[0];
    for (i = 0; i < 3; ++i) {
        byte_28D[i] = byte_28D[i + 1];
    }
    byte_28D[3] = temp_28D;

    temp_293 = byte_293[0];
    for (i = 0; i < 3; ++i) {
        byte_293[i] = byte_293[i + 1];
    }
    byte_293[3] = temp_293;

    byte_294 = byte_293[1];
    byte_295 = byte_293[2];
    byte_296 = byte_293[3];
}

void sub_C812(void) {
    sub_E9A5();
    sub_C864();
    sub_C930();
    sub_C821();
    loc_DA5C();
}

void sub_C930(void) {
    unsigned char y;
    unsigned char temp_val;
    unsigned char offset = 0;

    if ((ram_obj_pos_X_hi[0] & 0x80) == 0) { // BMI checks for bit 7 == 1. We act if bit 7 is 0.
        offset = 0x0A;
    }

    ++byte_B7;
    y = (byte_B7 & 7) + offset;
    byte_28C = tbl_C976[y];

    if ((byte_4B & 7) != 0) {
        return;
    }

    temp_val = (byte_4B & 8) ? 1 : 0;
    temp_val += offset + 8;
    temp_val = tbl_C976[temp_val];

    for (y = 0; y < 4; ++y) {
        if (byte_28D[y] != 0) {
            byte_28D[y] = temp_val;
        }
    }
}

void sub_C821(void) {
    unsigned char y_base;
    unsigned char ghost_idx;
    unsigned char limit_x;
    unsigned char ghost_anim;

    if ((ram_obj_pos_X_hi[0] & 0x80) != 0) {
        return;
    }

    limit_x = ram_spr_pos_X_hi[0] + 8;
    ghost_idx = 0;

    for (y_base = 0; y_base < 16; y_base += 4) {
        if (byte_278[y_base] != 0 && byte_278[y_base] < limit_x) {
            ghost_anim = tbl_C924[byte_89];
            ++byte_89;
            byte_8A = 0x40;
            byte_28D[ghost_idx] = ghost_anim;
            byte_293[ghost_idx] = 0;
            byte_28C = 0;
            ram_spr_pos_Y_hi[0] = 0;
            return;
        }
        ++ghost_idx;
    }
}

// Game state 0: Title screen animation
int sub_C1FB(void) {
    // Check for Up/Down on D-Pad
    if (btn_select_pressed(byte_4D) || btn_start_pressed(byte_4D)) {
        byte_3F = 2; // Change to state 2
        return 0;    // continue loop in next state
    }

    // After a delay (240 frames), change state
    if (++byte_42 == 0xF0) {
        byte_42 = 0;
        byte_43 = 0x88;
        byte_3F = 2; // Change to state 2
    }

    return 0; // Continue in this state
}

// This function draws the Pac-Man logo on the screen.
void sub_C21F(void) {
    unsigned char vram_addr_hi = 0x20;
    unsigned char vram_addr_lo = 0xE5;
    unsigned char rows = 6;
    unsigned char data_idx = 0;

    do {
        unsigned char columns = 0x17;

        (void)PPU_STATUS; // Reset PPU address latch
        PPU_ADDR = vram_addr_hi;
        PPU_ADDR = vram_addr_lo;

        do {
            PPU_DATA = tbl_C29F_pacman_logo[data_idx++];
        } while(--columns);

        vram_addr_lo += 0x20;
        if (vram_addr_lo < 0x20) { // Check for carry
            ++vram_addr_hi;
        }

    } while(--rows);

    rows = 6;
    data_idx = 0;
    do {
        // Here, the assembly reads a VRAM address from a table, then writes data.
        // We'll simulate by reading address and then data until a terminator.
        unsigned char addr_hi = tbl_C329_logo_text_0[data_idx++];
        unsigned char addr_lo = tbl_C329_logo_text_0[data_idx++];

        (void)PPU_STATUS;
        PPU_ADDR = addr_hi;
        PPU_ADDR = addr_lo;

        while(tbl_C329_logo_text_0[data_idx] != 0xFF) {
            PPU_DATA = tbl_C329_logo_text_0[data_idx++];
        }
        ++data_idx; // Skip the 0xFF terminator
    } while(--rows);
}

// Game state 2: Player select screen
int sub_C3BD(void) {
    unsigned char select_now;
    unsigned char start_now;

    if (word_87 == 0) {
        unsigned char i = 0;
        do {
            ram_ppu_buffer_main[i] = tbl_C44D[i];
        } while (tbl_C44D[i++] != 0xFF);

        // Store initial button states
        byte_50 = btn_select_pressed(byte_4D);
        byte_51 = btn_start_pressed(byte_4D);
    }

    // This is a 16-bit counter that runs for 512 frames (about 8.5 seconds)
    // before timing out and moving to the next state.
    if (++word_87 == 0x0200) {
        word_87 = 0;
        byte_3F = 4; // This state isn't defined yet
        return 0;    // Continue to next state
    }

    // SELECT toggles 1P/2P.
    select_now = btn_select_pressed(byte_4D);
    if (select_now != byte_50) {
        byte_50 = select_now; // Update last state
        word_87 = 1;              // Reset timer
        if (byte_50 != 0) { // If pressed (not released)
            unsigned char cur_top;
            unsigned char cur_bot;
            byte_47 = (byte_47 + 1) & 1; // Toggle between 0 and 1
            cur_top = (byte_47 == 0) ? 0x5C : 0x20;
            cur_bot = (byte_47 == 0) ? 0x20 : 0x5C;
            ram_ppu_buffer_main[0] = 0x22;
            ram_ppu_buffer_main[1] = 0x0A;
            ram_ppu_buffer_main[2] = cur_top;
            ram_ppu_buffer_main[3] = 0x00;
            ram_ppu_buffer_main[4] = 0x22;
            ram_ppu_buffer_main[5] = 0x4A;
            ram_ppu_buffer_main[6] = cur_bot;
            ram_ppu_buffer_main[7] = 0xFF;
            return 0;
        }
    }

    // START enters game flow.
    start_now = btn_start_pressed(byte_4D);
    if (start_now != byte_51) {
        byte_51 = start_now; // Update last state
        if (byte_51 != 0) { // If pressed
            byte_48 = 0; // Reset some timer
            sub_EE40();  // Play a sound
            byte_3F = 6; /* Enter gameplay state machine (sub_C98A). */
            word_87 = 0;
            byte_4E = 0;
            byte_69 = 0;
            return 0;
        }
    }

    return 0; // No change, continue in this state
}

int sub_C78D(void) {
    unsigned char i;
    unsigned char index;
    unsigned char found;

    if (byte_8A == 0) {
        sub_C812();
        return 0;
    }

    sub_C864();
    --byte_8A;
    if (byte_8A != 0) {
        return 0;
    }

    found = 0;
    for (i = 0; i < 4; ++i) {
        if ((byte_28D[i] & 0xE0) != 0) {
            found = 1;
            break;
        }
    }
    if (!found) {
        i = 0;
    }

    byte_28D[i] = 0;
    byte_293[i] = 0;
    index = i << 2;
    byte_278[index] = 0;
    byte_27A[index] = 0;
    byte_1E_ram[index] = 0;
    byte_1F_ram[index] = 0;

    ram_spr_pos_Y_hi[0] = 0xA8;

    if (byte_89 == 4) {
        byte_47 = 1;
        sub_C98A();
    }
    return 0;
}

static int dispatch_game_state(void) {
    switch (byte_3F) {
        case 0x00: return sub_C1FB();
        case 0x02: return sub_C3BD();
        case 0x04: return sub_C458();
        case 0x06: return sub_C98A();
        default:
            /* Fallback to a known state instead of out-of-bounds jump. */
            byte_3F = 0x00;
            return 1;
    }
}

static void flush_aux_ppu_buffers(void) {
    static const unsigned int k_power_pellet_addr[8] = {
        0x20B4, 0x20A2, 0x22D4, 0x22C2, 0x28B4, 0x28A2, 0x2AD4, 0x2AC2
    };
    unsigned char* power_tiles;
    unsigned char i;
    unsigned char y;

    if (byte_23F != 0xFF) {
        (void)PPU_STATUS;
        PPU_ADDR = byte_26B;
        PPU_ADDR = byte_26C;
        for (i = 0; i < 6; ++i) {
            PPU_DATA = byte_23F_ram[i];
        }
        PPU_DATA = 0x30;
        byte_23F = 0xFF;
    }

    if (byte_245 != 0xFF) {
        (void)PPU_STATUS;
        PPU_ADDR = byte_272;
        PPU_ADDR = byte_273;
        for (i = 0; i < 6; ++i) {
            PPU_DATA = byte_245_ram[i];
        }
        PPU_DATA = 0x30;
        byte_245 = 0xFF;
    }

    /* Keep top-line white counters updated like original DE7E block. */
    if ((byte_4B & 7) == 0) {
        y = 0;
        power_tiles = &byte_6C;
        if ((byte_46 & byte_47) != 0) {
            y = 4;
        }
        for (i = 0; i < 4; ++i) {
            (void)PPU_STATUS;
            PPU_ADDR = (unsigned char)(k_power_pellet_addr[y + i] >> 8);
            PPU_ADDR = (unsigned char)(k_power_pellet_addr[y + i] & 0xFF);
            PPU_DATA = power_tiles[i];
        }
    }
}

static void draw_title_score_row(void) {
    static const unsigned char score_l[] = { '0', '0' };
    static const unsigned char score_h[] = { '1', '0', '0', '0', '0' };
    static const unsigned char score_r[] = { '0', '0' };

    (void)PPU_STATUS;
    PPU_ADDR = 0x20;
    PPU_ADDR = 0x88;
    PPU_DATA = score_l[0];
    PPU_DATA = score_l[1];

    (void)PPU_STATUS;
    PPU_ADDR = 0x20;
    PPU_ADDR = 0x8E;
    PPU_DATA = score_h[0];
    PPU_DATA = score_h[1];
    PPU_DATA = score_h[2];
    PPU_DATA = score_h[3];
    PPU_DATA = score_h[4];

    (void)PPU_STATUS;
    PPU_ADDR = 0x20;
    PPU_ADDR = 0x9A;
    PPU_DATA = score_r[0];
    PPU_DATA = score_r[1];
}

static void flush_ppu_main_buffer(void) {
    unsigned char y;
    unsigned char addr_hi;
    unsigned char addr_lo;
    unsigned char a;

    if (ram_ppu_buffer_main[0] == 0xFF) {
        return;
    }

    y = 0;
    while (1) {
        addr_hi = ram_ppu_buffer_main[y++];

        if (addr_hi == 0xFF) {
            break;
        }

        addr_lo = ram_ppu_buffer_main[y++];
        (void)PPU_STATUS;
        PPU_ADDR = addr_hi;
        PPU_ADDR = addr_lo;

        while (1) {
            a = ram_ppu_buffer_main[y++];
            if (a == 0x00) {
                break;
            }
            if (a == 0xFF) {
                ram_ppu_buffer_main[0] = 0xFF;
                return;
            }
            PPU_DATA = a;
        }
    }

    ram_ppu_buffer_main[0] = 0xFF;
}

static void apply_scroll_and_ctrl(void) {
    (void)PPU_STATUS;
    PPU_SCROLL = byte_41;
    PPU_SCROLL = byte_42;
    PPU_CTRL = byte_43;
}

static void clear_title_nametable(void) {
    unsigned int addr;
    unsigned char i;

    (void)PPU_STATUS;
    PPU_ADDR = 0x20;
    PPU_ADDR = 0x00;
    for (addr = 0; addr < 0x03C0; ++addr) {
        PPU_DATA = 0x20;
    }

    (void)PPU_STATUS;
    PPU_ADDR = 0x23;
    PPU_ADDR = 0xC0;
    for (i = 0; i < 0x40; ++i) {
        PPU_DATA = 0x00;
    }
}

// This function is the entry point to the main game logic.
// It sets up the screen, palette, and variables for the game,
// then enters the main game loop.
void game_main_loop(void) {
setup_loop:
    // Wait for vertical blank using neslib helper.
    ppu_wait_nmi();
    ppu_wait_nmi();

    // Setup PPU: NMI off, sprites off, background from $1000
    PPU_CTRL = 0x08;
    byte_43 = 0x08;

    // Reset PPU address latch
    (void)PPU_STATUS;
    // Turn off rendering
    PPU_MASK = 0x00;

    // Clear OAM (sprite memory)
    memset(ram_oam, 0, sizeof(ram_oam));
    byte_46 = 0; // The original code only sets the last byte to 0, but memset is safer

    // Call setup subroutines
    sub_E2FF();
    sub_E393();
    clear_title_nametable();

    // Reset PPU address latch
    (void)PPU_STATUS;
    // Set PPU address to $3F00 (palette memory)
    PPU_ADDR = 0x3F;
    PPU_ADDR = 0x00;

    // Write deterministic full palette:
    // first half matches title colors, second half is cleared to prevent soft-reset leftovers.
    {
        unsigned char i;
        for (i = 0; i < 16; ++i) {
            PPU_DATA = tbl_C395_background_palette[i];
        }
        for (i = 0; i < 16; ++i) {
            PPU_DATA = 0x0F;
        }
    }

    // Draw basic title screen primitives like original reset flow.
    sub_C284();
    sub_C21F();
    draw_title_score_row();

    // Initialize game variables
    byte_6C = 0x2D;
    byte_6D = 0x2D;
    byte_6E = 0x2D;
    byte_6F = 0x2D;
    byte_23F = 0xFF;
    byte_245 = 0xFF;
    byte_48 = 0xFF;
    byte_47 = 0;
    byte_46 = 0;
    byte_42 = 0;
    byte_41 = 0;
    byte_4C = 0;
    byte_49 = 0;
    byte_4A = 0;
    byte_60F = 0;
    word_87 = 0;

    // Set initial PPU control value based on game mode (byte_3F)
    if (byte_3F != 0) {
        PPU_CTRL = 0x88;
        byte_43 = 0x88;
    } else {
        PPU_CTRL = 0x8A;
        byte_43 = 0x8A;
    }
    /* Stabilize first visible frame: latch scroll/ctrl on a fresh vblank
       before enabling rendering. */
    ppu_wait_nmi();
    apply_scroll_and_ctrl();
    ppu_on_all();

    // Main game loop
    while(1) {
        // Wait for NMI
        ppu_wait_nmi();
        flush_ppu_main_buffer();
        apply_scroll_and_ctrl();
        ++byte_4B;
        byte_4D = pad_poll(0);
        byte_4F = byte_4D;

        // Call the current game state function.
        // If it returns a non-zero value, restart the setup.
        if (dispatch_game_state()) {
            goto setup_loop;
        }
    }
}

int sub_C6DD(void) {
    unsigned char i;

    i = 0;
    do {
        ram_ppu_buffer_main[i] = tbl_C90E[i];
    } while (tbl_C90E[i++] != 0xFF);

    ram_obj_pos_X_hi[0] = 0xFF;
    ram_obj_pos_X_lo[0] = 0x00;
    byte_89 = 0x00;
    byte_8A = 0x00;
    ram_spr_pos_X_hi[0] = 0xF4;
    ram_spr_pos_Y_hi[0] = 0xA8;
    byte_28C = 0x01;
    byte_292 = 0x20;

    for (i = 0; i < 20; ++i) {
        byte_1E_ram[i] = 0;
    }
    for (i = 0; i < 20; ++i) {
        byte_278[i] = 0;
    }

    loc_DA5C();
    word_88 += 2;
    return 0;
}

int sub_C728(void) {
    unsigned char i;

    sub_C812();
    sub_C8EE();

    if (ram_spr_pos_X_hi[0] == 0xE0 || ram_spr_pos_X_hi[0] == 0xD1 ||
        ram_spr_pos_X_hi[0] == 0xC2 || ram_spr_pos_X_hi[0] == 0xB3) {
        sub_C7DE();
    }

    if (ram_spr_pos_X_hi[0] != 0x40) {
        return 0;
    }

    for (i = 0; i < 16; i += 4) {
        byte_1E_ram[i] = 0x00;
        byte_1F_ram[i] = 0xC0;
    }

    ram_obj_pos_X_hi[0] = 0x01;
    ram_obj_pos_X_lo[0] = 0x50;
    byte_293[0] = 0x01;
    byte_294 = 0x01;
    byte_295 = 0x01;
    byte_296 = 0x01;
    byte_89 = 0x00;
    ram_ppu_buffer_main[0] = 0x22;
    ram_ppu_buffer_main[2] = 0x20;
    word_88 += 2;
    return 0;
}

// Array of function pointers for the main loop state machine
void (*const tbl_CA0D[])(void) = {
    sub_CE35,
    sub_CA9D,
    sub_CA1F,
    sub_CC0F,
    sub_CC3C,
    sub_CD61,
    sub_CCE6,
    sub_E655,
    sub_E74B
};

int sub_C98A(void) {
    // This is the main game state machine.
    // It calls a subroutine from tbl_CA0D based on the value of byte_4E.
    if (byte_4E < (sizeof(tbl_CA0D) / sizeof(tbl_CA0D[0]))) {
        tbl_CA0D[byte_4E]();
    }
    return 0;
}

// Main function
void main(void) {
    init_game();
    while (1) {
        ppu_wait_nmi();
        byte_4D = pad_poll(0);
        byte_4F = byte_4D;
        game_main_loop();
    }
}

void init_game(void) {
    ppu_off();
    byte_43 = 0x08;
    byte_41 = 0;
    byte_42 = 0;
}

void sub_CE35(void) {
    /* Phase 0: round/bootstrap init */
    word_87 = 0;
    byte_89 = 0x20;
    byte_4B = 0;
    byte_4E = 1;
}

static void swap_player_data(void) {
    signed char x;
    for (x = 0x0F; x >= 0; --x) {
        unsigned char tmp = ram_data_p1[(unsigned char)x];
        ram_data_p1[(unsigned char)x] = ram_data_p2[(unsigned char)x];
        ram_data_p2[(unsigned char)x] = tmp;
    }
}

static void loc_CC94(void) {
    byte_4E = 0;
    byte_69 = 1;

    if (byte_47 != 0 && ram_data_p2[0] != 0) {
        swap_player_data();
        ++byte_46;
        byte_46 &= 1;
        return;
    }

    if (ram_data_p1[0] == 0) {
        byte_69 = 0;
        if (byte_46 != 0) {
            swap_player_data();
        }
        byte_46 = 0;
        byte_4E = 0;
    }
}

void sub_CA9D(void) {
    unsigned char phase = (unsigned char)word_87;
    unsigned char y;
    unsigned char x;
    unsigned char groups;
    unsigned char tile_idx;
    unsigned char pos_idx;
    unsigned char ctr_idx;

    if (phase == 0) {
        if (byte_48 == 0) {
            groups = 2;
            y = 0;
            tile_idx = 0;
            pos_idx = 0;
            ctr_idx = 0;
            while (1) {
                unsigned char spr_x = tbl_CBF6_spr_pos[pos_idx];
                unsigned char spr_y = tbl_CBF6_spr_pos[pos_idx + 1];
                unsigned char ctr = tbl_CBFC_spr_counter[ctr_idx];
                while (ctr != 0) {
                    ram_oam[0x60 + y + 0] = spr_y;
                    ram_oam[0x60 + y + 1] = tbl_CBD2_spr_T[tile_idx];
                    ram_oam[0x60 + y + 2] = tbl_CBE4_spr_A[tile_idx];
                    ram_oam[0x60 + y + 3] = spr_x;
                    spr_x += 8;
                    y += 4;
                    ++tile_idx;
                    --ctr;
                }

                pos_idx += 2;
                ++ctr_idx;

                if (byte_69 == 0 && byte_68 != 0) {
                    break;
                }

                --groups;
                if (groups == 0) {
                    if (byte_47 != 0 && byte_46 != 0) {
                        tile_idx += 3;
                        groups = 1;
                    } else {
                        break;
                    }
                }
            }
        }
    }

    if (phase == 0xC0) {
        if ((byte_600 | byte_601) == 0) {
            if (byte_48 == 0) {
                memset(&ram_oam[0x60], 0, 0xA0);
            }
            byte_4E = 2;
        }
    } else {
        ++phase;
        word_87 = (word_87 & 0xFF00) | phase;
        if (phase == 0x78) {
            ram_obj_pos_Y_hi[0] = 0xA8;
            ram_obj_pos_X_hi[0] = 0x60;
            ram_obj_pos_X_hi[1] = 0x60;
            ram_obj_pos_X_hi[2] = 0x60;
            ram_obj_pos_X_hi[3] = 0x58;
            ram_obj_pos_Y_hi[1] = 0x58;
            ram_obj_pos_X_hi[4] = 0x68;
            ram_obj_pos_Y_hi[2] = 0x70;
            ram_obj_pos_Y_hi[3] = 0x70;
            ram_obj_pos_Y_hi[4] = 0x70;
            memset(&ram_oam[0x78], 0, 0x24);

            x = 0;
            if ((byte_47 & byte_46) != 0) {
                x = 8;
            }
            y = (unsigned char)((ram_data_p1[0] - 1) << 1);
            ram_ppu_buffer_main[0] = (unsigned char)(tbl_CC07[y] + x);
            ram_ppu_buffer_main[1] = tbl_CC07[y + 1];
            ram_ppu_buffer_main[2] = 0x2D;
            ram_ppu_buffer_main[3] = 0x2D;
            ram_ppu_buffer_main[4] = 0x00;
            ram_ppu_buffer_main[5] = ram_ppu_buffer_main[0];
            ram_ppu_buffer_main[6] = (unsigned char)(ram_ppu_buffer_main[1] + 0x20);
            ram_ppu_buffer_main[7] = 0x2D;
            ram_ppu_buffer_main[8] = 0x2D;
            ram_ppu_buffer_main[9] = 0xFF;

            sub_D8F9();
            sub_D937();
            sub_D9AB();
        }
    }
}

void sub_CA1F(void) {
    unsigned char a;
    unsigned char i;
    unsigned char x;

    if (byte_60F != 0) {
        return;
    }

    a = btn_start_pressed(byte_4D);
    if (a != byte_49) {
        byte_49 = a;
        if (byte_49 != 0) {
            ++byte_4A;
            x = 0x22;
            if ((byte_47 & byte_46) != 0) {
                x = 0x2A;
            }
            ram_ppu_buffer_main[0] = x;
            ram_ppu_buffer_main[1] = 0x37;
            x = 6;
            if ((byte_4A & 1) != 0) {
                x = 0;
                byte_60F = byte_4A;
            }
            for (i = 0; i < 6; ++i) {
                ram_ppu_buffer_main[2 + i] = tbl_CA91[x + i];
            }
            ram_ppu_buffer_main[8] = 0xFF;
            return;
        }
    }

    if ((byte_4A & 1) != 0) {
        return;
    }

    sub_D0EF();
    sub_DEDF();
    sub_D2FB();
    sub_D8F9();
    sub_D4C2();
    sub_D937();
    sub_D8C9();
    sub_DDC9();
    sub_D20F();
    sub_D9AB();
}

void sub_CC0F(void) {
    ++byte_DA;
    if (byte_DA == 0x28) {
        byte_DA = 0x02;
        byte_4E = 2;
        if (byte_B8 == 0x08) {
            byte_B8 = 0x06;
        }
    }
    sub_DDC9();
    sub_D87F();
    sub_D937();
    sub_D9AB();
}

void sub_CC3C(void) {
    unsigned char phase = (unsigned char)word_87;

    if (phase == 0) {
        --byte_DB;
        if (byte_DB == 0xFF) {
            phase = 1;
            word_87 = (word_87 & 0xFF00) | phase;
            byte_DB = 0x0A;
            memset(&ram_obj_pos_X_hi[1], 0, 0x14);
        }
        sub_DDC9();
        sub_D937();
        sub_D9AB();
        return;
    }

    --byte_DB;
    if ((signed char)byte_DB < 0) {
        byte_DB = 0x0A;
        ++byte_32F[0];
        if (byte_32F[0] == 0x1E) {
            if (byte_48 == 0) {
                --ram_data_p1[0];
                if (ram_data_p1[0] == 0) {
                    word_87 = (word_87 & 0xFF00);
                    byte_69 = 0;
                    byte_4E = 5;
                    return;
                }
                loc_CC94();
                return;
            }
            byte_46 = 0;
            byte_4E = 0;
            return;
        }
    }
    sub_DDC9();
    sub_D9AB();
}

void sub_CD61(void) {
    unsigned char phase = (unsigned char)word_87;
    unsigned char y;
    unsigned char tile_idx;
    unsigned char pos_idx;
    unsigned char ctr_idx;
    unsigned char groups;

    if (phase == 0) {
        memset(ram_oam, 0xFF, 0x60);
        groups = 3;
        y = 0;
        tile_idx = 0;
        pos_idx = 0;
        ctr_idx = 0;
        while (1) {
            unsigned char spr_x = tbl_CE29_spr_pos[pos_idx];
            unsigned char spr_y = tbl_CE29_spr_pos[pos_idx + 1];
            unsigned char ctr = tbl_CE31_spr_counter[ctr_idx];

            while (ctr != 0) {
                ram_oam[0x60 + y + 0] = spr_y;
                ram_oam[0x60 + y + 1] = tbl_CE01_spr_T[tile_idx];
                ram_oam[0x60 + y + 2] = tbl_CE15_spr_A[tile_idx];
                ram_oam[0x60 + y + 3] = spr_x;
                spr_x += 8;
                y += 4;
                ++tile_idx;
                --ctr;
            }

            pos_idx += 2;
            ++ctr_idx;

            if (byte_47 != 0 && ram_data_p2[0] == 0 && groups != 2) {
                /* follow assembly branch layout */
            }

            --groups;
            if (groups == 0) {
                if (byte_47 != 0 && byte_46 != 0) {
                    tile_idx += 3;
                    groups = 1;
                } else {
                    break;
                }
            } else if ((signed char)groups < 0) {
                break;
            }
        }
    }

    ++phase;
    word_87 = (word_87 & 0xFF00) | phase;
    if (phase == 0) {
        memset(&ram_oam[0x60], 0, 0xA0);
        loc_CC94();
    }
}

void sub_CCE6(void) {
    unsigned char phase = (unsigned char)word_87;

    if (phase == 0) {
        memset(&ram_obj_pos_X_hi[1], 0, 0x14);
        phase = 1;
        word_87 = (word_87 & 0xFF00) | phase;
        byte_32F[0] = 1;
    } else if ((byte_4B & 7) == 0) {
        unsigned char table_idx = 0;
        unsigned char i;
        if ((phase & 1) == 0) {
            table_idx = 4;
        }
        for (i = 0; i < 4; ++i) {
            ram_ppu_buffer_main[i] = tbl_CD59[table_idx + i];
        }
        ++phase;
        word_87 = (word_87 & 0xFF00) | phase;
        if (phase == 0x10) {
            ram_obj_pos_X_hi[0] = 0;
            ram_obj_pos_Y_hi[0] = 0;
            phase = 0;
            word_87 = (word_87 & 0xFF00) | phase;
            if (byte_68 == 1 || byte_68 == 4 || byte_68 == 8 || byte_68 == 0x0C || byte_68 == 0x10) {
                byte_4E = 7;
            } else {
                byte_4E = 0;
            }
        }
    }

    sub_DDC9();
    sub_D9AB();
}

void sub_E655(void) {
    unsigned char i;

    /* Phase 7: initialize gameplay presentation */
    ppu_off();
    byte_41 = 0;
    byte_42 = 0;
    (void)PPU_STATUS;
    PPU_ADDR = 0x3F;
    PPU_ADDR = 0x00;
    for (i = 0; i < PALETTE_SIZE; ++i) {
        PPU_DATA = tbl_C5B3_palette[i];
    }

    /* Draw base playfield so we don't fall into a black frame. */
    sub_C51E();
    sub_C54E();

    byte_28D[0] = 1;
    byte_293[0] = 0x21;
    byte_278[0] = 0x40;
    byte_27A[0] = 0x78;
    byte_1E_ram[0] = 0x40;
    ram_obj_pos_X_hi[0] = 0x78;
    ram_obj_pos_X_lo[0] = 0;

    byte_43 = 0x88;
    apply_scroll_and_ctrl();
    ppu_on_all();
    byte_4E = 8;
}

void sub_E74B(void) {
    sub_E9A5();
    loc_DA5C();
    sub_D0EF();
    sub_D2FB();
    sub_DEDF();
    sub_D4C2();
    sub_D20F();
    sub_D8C9();
    sub_D8F9();
    sub_D937();
    sub_D9AB();
    sub_DDC9();
}

void sub_E9A5(void) {
    unsigned char obj;
    unsigned char idx;

    idx = 0;
    for (obj = 0; obj < 5; ++obj, idx += 4) {
        unsigned int acc;
        unsigned char hi;

        if (byte_278[idx] == 0) {
            continue;
        }

        /* 16-bit add: sprite position += object delta */
        acc = (unsigned int)byte_27A[idx] + (unsigned int)byte_1F_ram[idx];
        byte_27A[idx] = (unsigned char)acc;
        acc = (unsigned int)byte_278[idx] + (unsigned int)byte_1E_ram[idx] + ((acc >> 8) & 1);
        byte_278[idx] = (unsigned char)acc;
        hi = byte_278[idx];

        if (hi >= 0xC0 || hi < 0x40) {
            byte_292_arr[obj] |= 0x20;
        } else {
            byte_292_arr[obj] &= 0xDF;
        }

        if (hi >= 0xFC || hi < 0x04) {
            byte_278[idx] = 0;
            byte_27A[idx] = 0;
            byte_1E_ram[idx] = 0;
            byte_1F_ram[idx] = 0;
        }
    }
}

void sub_EE40(void) {
    /* Tiny click/beep on pulse channel 1 */
    APU_CTRL_4000 = 0x30;
    APU_TUNE_4002 = 0xFF;
    APU_LEN_4003 = 0x08;
}

static unsigned char abs_diff_u8(unsigned char a, unsigned char b) {
    return (a >= b) ? (a - b) : (b - a);
}

void sub_D0EF(void) {
    /* Timers/small effects driver: keep it deterministic and frame-bound. */
    if ((signed char)byte_89 >= 0) {
        ++byte_8A;
        if (byte_8A == 0x3C) {
            byte_8A = 0;
            if (byte_89 != 0) {
                --byte_89;
            } else {
                byte_89 = 0xFF;
            }
        }
    }

    if ((byte_D7 | byte_D8) != 0) {
        if (byte_D8 != 0) {
            --byte_D8;
        } else if (byte_D7 != 0) {
            --byte_D7;
            byte_D8 = 0x3C;
        }
    }
}

void sub_DEDF(void) {
    /* Pellet consume approximation: eat one pellet on tile centers. */
    if (((ram_spr_pos_X_hi[0] | ram_spr_pos_Y_hi[0]) & 7) != 0) {
        return;
    }

    if (byte_6A == 0) {
        return;
    }

    --byte_6A;
    if (byte_6A == 0) {
        byte_4E = 6;
        word_87 &= 0xFF00;
        byte_4C = 0x48;
    }
}

void sub_D2FB(void) {
    unsigned char input = byte_4F & 0xF0;
    unsigned char dir = byte_51 & 3;

    /* Decode direction from high nibble like original flow. */
    if (input != 0) {
        if ((input & 0x80) != 0) dir = 0;
        else if ((input & 0x40) != 0) dir = 1;
        else if ((input & 0x20) != 0) dir = 2;
        else if ((input & 0x10) != 0) dir = 3;
        byte_50 = dir;
        byte_51 = dir;
    }

    /* Apply a simple 1px movement per frame. */
    if (byte_48 == 0) {
        switch (dir) {
            case 0: ram_spr_pos_X_hi[0] = (unsigned char)(ram_spr_pos_X_hi[0] + 1); break;
            case 1: ram_spr_pos_X_hi[0] = (unsigned char)(ram_spr_pos_X_hi[0] - 1); break;
            case 2: ram_spr_pos_Y_hi[0] = (unsigned char)(ram_spr_pos_Y_hi[0] + 1); break;
            default: ram_spr_pos_Y_hi[0] = (unsigned char)(ram_spr_pos_Y_hi[0] - 1); break;
        }
    }
}

void sub_D4C2(void) {
    /* Ghost movement step; uses already-ported object integrator. */
    sub_E9A5();
}

void sub_D8C9(void) {
    /* Event sound latch approximation. */
    if (byte_6A < 0x42) {
        (*(volatile unsigned char*)0x600C) = 1;
    } else if (byte_6A < 0x88) {
        (*(volatile unsigned char*)0x600B) = 1;
    } else {
        byte_60A = 1;
    }
}

void sub_D8F9(void) {
    unsigned char f;
    ++byte_B7;
    f = byte_B7 & 7;
    if (f < 6) {
        /* Tie pac-man tile phase to facing direction. */
        byte_28C = (unsigned char)(2 + ((byte_51 & 3) << 1) + (f >> 1));
    } else {
        byte_28C = 1;
    }
}

void sub_D937(void) {
    unsigned char i;
    for (i = 0; i < 4; ++i) {
        if (byte_278[i << 2] != 0) {
            byte_28D[i] = (unsigned char)(8 + ((byte_B7 >> 2) & 1));
        }
    }
}

void sub_D9AB(void) {
    /* OAM compose from current object state. */
    loc_DA5C();
}

void sub_DDC9(void) {
    if ((byte_4B & 0x0F) != 0) {
        return;
    }

    if (byte_6C == 1) byte_6C = 2; else if (byte_6C == 2) byte_6C = 1;
    if (byte_6D == 1) byte_6D = 2; else if (byte_6D == 2) byte_6D = 1;
    if (byte_6E == 1) byte_6E = 2; else if (byte_6E == 2) byte_6E = 1;
    if (byte_6F == 1) byte_6F = 2; else if (byte_6F == 2) byte_6F = 1;
}

void sub_D20F(void) {
    unsigned char i;
    unsigned char px = ram_spr_pos_X_hi[0];
    unsigned char py = ram_spr_pos_Y_hi[0];

    if (byte_48 != 0) {
        return;
    }

    for (i = 0; i < 4; ++i) {
        unsigned char idx = (unsigned char)(i << 2);
        unsigned char gx = byte_278[idx];
        unsigned char gy = byte_27A[idx];
        if (gx == 0) {
            continue;
        }
        if (abs_diff_u8(px, gx) < 6 && abs_diff_u8(py, gy) < 6) {
            /* Collision -> death sequence script. */
            byte_DB = 0x80;
            word_87 &= 0xFF00;
            byte_32F[0] = 0;
            byte_4E = 4;
            break;
        }
    }
}

void sub_D87F(void) {
    /* Ghost state ticker with deterministic timing. */
    if ((byte_4B & 7) == 0) {
        byte_B8 = (unsigned char)((byte_B8 + 2) & 0x0E);
    }
}
