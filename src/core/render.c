#include "ghosts.h"
#include "maze.h"
#include "neslib.h"
#include "pellets.h"
#include "player.h"
#include "ppu_queue.h"
#include "render.h"

static const unsigned char k_title_bg_palette[16] = {
#include "../../assets/generated/c/ec25cd088056307b.inc"
};

static const unsigned char k_title_hi_score[] = {
    0xB0, 0xB3, 0xB2, 0x20, 0x20, 0x20, 0x20, 0xB4, 0xB5, 0xB6, 0xB7,
    0xB8, 0xB9, 0xBA, 0xBB, 0x20, 0x20, 0x20, 0xB1, 0xB3, 0xB2
};

static const unsigned char k_title_attr_23c8[24] = {
    0x80, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0x00,
    0x00, 0x66, 0x55, 0x55, 0x55, 0x55, 0xDD, 0x00,
    0x08, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x00
};

static const unsigned char k_pacman_logo_tiles[144] = {
#include "../../assets/generated/c/42099a7bf62e02a5.inc"
};

static const unsigned char k_title_p1[] = {0x5C, '-', '1', ' ', 'P', 'L', 'A', 'Y', 'E', 'R'};
static const unsigned char k_title_p2[] = {'2', ' ', 'P', 'L', 'A', 'Y', 'E', 'R', 'S'};
static const unsigned char k_title_namcot[] = {'#', '$', '%', '&', '\'', '(', ')', '*', '+'};

static const unsigned char k_title_copyright[] = {
    ']', ' ', '1', '9', '8', '0', ' ', '1', '9', '8', '4', ' ',
    'N', 'A', 'M', 'C', 'O', ' ', 'L', 'T', 'D', '['
};

static const unsigned char k_title_all_rights[] = {
    'A', 'L', 'L', ' ', 'R', 'I', 'G', 'H', 'T', 'S', ' ',
    'R', 'E', 'S', 'E', 'R', 'V', 'E', 'D'
};

static const unsigned char k_attract_palette_32[32] = {
#include "../../assets/generated/c/2ea21de027701c59.inc"
};

static const unsigned char k_demo_pkt00_text[] = {
    'C', 'H', 'R', 'A', 'C', 'T', 'E', 'R', ' ', ' ', ';', ' ', ' ', 'N', 'I', 'C', 'K', 'N', 'A', 'M', 'E'
};
static const unsigned char k_demo_pkt02_text[] = {
    'O', 'I', 'K', 'A', 'K', 'E', '.', '.', '.', '.', '.'
};
static const unsigned char k_demo_pkt04_text[] = {'_', 'A', 'K', 'A', 'B', 'E', 'I', '_'};
static const unsigned char k_demo_pkt06_text[] = {'M', 'A', 'C', 'H', 'I', 'B', 'U', 'S', 'E', '.', '.'};
static const unsigned char k_demo_pkt08_text[] = {'_', 'P', 'I', 'N', 'K', 'Y', '_'};
static const unsigned char k_demo_pkt0A_text[] = {0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0x03, 0x03, 0x03};
static const unsigned char k_demo_pkt0C_text[] = {0xC8, 0xC3, 0xC9, 0xCA, 0xC5, 0xC0, 0xC7, 0xC8};
static const unsigned char k_demo_pkt0E_text[] = {'O', 'T', 'O', 'B', 'O', 'K', 'E', '.', '.', '.', '.'};
static const unsigned char k_demo_pkt10_text[] = {'_', 'G', 'U', 'Z', 'U', 'T', 'A', '_'};

static const unsigned char k_demo_sprite_strip_data[64] = {
    0x48, 0x1C, 0x40, 0x26, 0x48, 0x1B, 0x40, 0x2E, 0x50, 0x1F, 0x40, 0x26, 0x50, 0x1D, 0x40, 0x2E,
    0x60, 0x1C, 0x41, 0x26, 0x60, 0x1B, 0x41, 0x2E, 0x68, 0x1F, 0x41, 0x26, 0x68, 0x1D, 0x41, 0x2E,
    0x78, 0x1C, 0x42, 0x26, 0x78, 0x1B, 0x42, 0x2E, 0x80, 0x1F, 0x42, 0x26, 0x80, 0x1D, 0x42, 0x2E,
    0x90, 0x1C, 0x43, 0x26, 0x90, 0x1B, 0x43, 0x2E, 0x98, 0x1F, 0x43, 0x26, 0x98, 0x1D, 0x43, 0x2E
};

static void write_abs_direct(unsigned int addr, const unsigned char* data, unsigned char len) {
    unsigned char i;
    vram_adr(addr);
    for (i = 0; i < len; ++i) {
        vram_put(data[i]);
    }
}

static void draw_demo_packet9_fast(void) {
    /* Final attract packet: big pellet + 10 PTS, 50 PTS, and NAMCO logo.
       Kept as direct PPU writes because helper-based writes missed vblank. */
    (void)PPU_STATUS_REG;

    PPU_ADDR_REG = 0x22;
    PPU_ADDR_REG = 0xAD;
    PPU_DATA_REG = 0x03;
    PPU_DATA_REG = 0x20;
    PPU_DATA_REG = '1';
    PPU_DATA_REG = '0';
    PPU_DATA_REG = 0x20;
    PPU_DATA_REG = 'P';
    PPU_DATA_REG = 'T';
    PPU_DATA_REG = 'S';

    PPU_ADDR_REG = 0x22;
    PPU_ADDR_REG = 0xED;
    PPU_DATA_REG = 0x01;
    PPU_DATA_REG = 0x20;
    PPU_DATA_REG = '5';
    PPU_DATA_REG = '0';
    PPU_DATA_REG = 0x20;
    PPU_DATA_REG = 'P';
    PPU_DATA_REG = 'T';
    PPU_DATA_REG = 'S';

    PPU_ADDR_REG = 0x23;
    PPU_ADDR_REG = 0x4C;
    PPU_DATA_REG = '#';
    PPU_DATA_REG = '$';
    PPU_DATA_REG = '%';
    PPU_DATA_REG = '&';
    PPU_DATA_REG = '\'';
    PPU_DATA_REG = '(';
    PPU_DATA_REG = ')';
    PPU_DATA_REG = '*';
    PPU_DATA_REG = '+';
}

static void write_abs_direct_offset(unsigned int addr, unsigned int nt_offset, const unsigned char* data, unsigned char len) {
    write_abs_direct((unsigned int)(addr + nt_offset), data, len);
}

static void upload_palettes(void) {
    static const unsigned char pal[16] = {
        0x0F, 0x00, 0x10, 0x30,
        0x0F, 0x12, 0x22, 0x30,
        0x0F, 0x06, 0x16, 0x26,
        0x0F, 0x0F, 0x0F, 0x0F
    };
    unsigned char i;

    vram_adr(0x3F00);
    for (i = 0; i < 16; ++i) {
        vram_put(pal[i]);
    }
}

static void upload_attract_palette_32(void) {
    unsigned char i;
    vram_adr(0x3F00);
    for (i = 0; i < 32; ++i) {
        vram_put(k_attract_palette_32[i]);
    }
}

static void upload_title_palette(void) {
    unsigned char i;
    vram_adr(0x3F00);
    for (i = 0; i < 16; ++i) {
        vram_put(k_title_bg_palette[i]);
    }
    for (i = 0; i < 16; ++i) {
        vram_put(0x0F);
    }
}

static void oam_write_strip(unsigned char strip_idx) {
    unsigned char i;
    unsigned char base = (unsigned char)(strip_idx << 4);
    OAM_ADDR_REG = (unsigned char)(0x60 + (strip_idx << 4));
    for (i = 0; i < 16; ++i) {
        OAM_DATA_REG = k_demo_sprite_strip_data[(unsigned char)(base + i)];
    }
}

static void oam_write_strip_at(unsigned char strip_idx, unsigned char oam_base, unsigned char* dst_buf) {
    unsigned char i;
    unsigned char base = (unsigned char)(strip_idx << 4);
    for (i = 0; i < 16; ++i) {
        dst_buf[(unsigned char)(oam_base + i)] = k_demo_sprite_strip_data[(unsigned char)(base + i)];
    }
}

static void draw_attract_playfield_frame(void) {
    unsigned char row;
    unsigned char col;
    vram_adr(0x20C0);
    for (row = 0; row < 24; ++row) {
        vram_put(0x2D);
        vram_put(0x2D);
        for (col = 0; col < 28; ++col) {
            vram_put(0x20);
        }
        vram_put(0x2D);
        vram_put(0x2D);
    }
}

static void draw_attract_attr_and_palette(void) {
    unsigned char i;
    unsigned char rep;
    unsigned char val;

    vram_adr(0x23C0);
    for (i = 0; i < 0x20; ++i) {
        vram_put(0x00);
    }

    vram_adr(0x23D0);
    val = 0x55;
    for (rep = 0; rep < 3; ++rep) {
        for (i = 0; i < 8; ++i) {
            vram_put(val);
        }
        val = (unsigned char)(val + 0x55);
    }

    upload_attract_palette_32();

    vram_adr(0x23E8);
    vram_put(0xAA);
    vram_put(0xAA);
    vram_put(0xAA);
    vram_put(0x22);
}

static void draw_title_attr(unsigned int nt_offset) {
    unsigned char i;
    vram_adr((unsigned int)(0x23C8 + nt_offset));
    for (i = 0; i < 24; ++i) {
        vram_put(k_title_attr_23c8[i]);
    }
}

static void draw_title_logo_graphics(unsigned int nt_offset) {
    unsigned char row;
    unsigned char col;
    unsigned char idx = 0;
    unsigned int addr = (unsigned int)(0x20E5 + nt_offset);

    for (row = 0; row < 6; ++row) {
        vram_adr(addr);
        for (col = 0; col < 23; ++col) {
            vram_put(k_pacman_logo_tiles[idx++]);
        }
        addr += 0x20;
    }
}

static void draw_title_score_row(unsigned int nt_offset) {
    static const unsigned char score_l[] = { '0', '0' };
    static const unsigned char score_h[] = { '1', '0', '0', '0', '0' };
    static const unsigned char score_r[] = { '0', '0' };

    vram_adr((unsigned int)(0x2088 + nt_offset));
    vram_put(score_l[0]);
    vram_put(score_l[1]);

    vram_adr((unsigned int)(0x208E + nt_offset));
    vram_put(score_h[0]);
    vram_put(score_h[1]);
    vram_put(score_h[2]);
    vram_put(score_h[3]);
    vram_put(score_h[4]);

    vram_adr((unsigned int)(0x209A + nt_offset));
    vram_put(score_r[0]);
    vram_put(score_r[1]);
}

void render_title_scroll(unsigned char scroll_y) {
    (void)PPU_STATUS_REG;
    PPU_CTRL_REG = 0x88;
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = scroll_y;
}

static void draw_demo_packet_text(unsigned char packet_idx) {
    PPU_CTRL_REG = 0x88;
    switch (packet_idx) {
        case 0:
            write_abs_direct(0x20E6, k_demo_pkt00_text, sizeof(k_demo_pkt00_text));
            break;
        case 1:
            write_abs_direct(0x2148, k_demo_pkt02_text, sizeof(k_demo_pkt02_text));
            break;
        case 2:
            write_abs_direct(0x2153, k_demo_pkt04_text, sizeof(k_demo_pkt04_text));
            break;
        case 3:
            write_abs_direct(0x21A8, k_demo_pkt06_text, sizeof(k_demo_pkt06_text));
            break;
        case 4:
            write_abs_direct(0x21B3, k_demo_pkt08_text, sizeof(k_demo_pkt08_text));
            break;
        case 5:
            write_abs_direct(0x2208, k_demo_pkt0A_text, sizeof(k_demo_pkt0A_text));
            break;
        case 6:
            write_abs_direct(0x2213, k_demo_pkt0C_text, sizeof(k_demo_pkt0C_text));
            break;
        case 7:
            write_abs_direct(0x2268, k_demo_pkt0E_text, sizeof(k_demo_pkt0E_text));
            break;
        case 8:
            write_abs_direct(0x2273, k_demo_pkt10_text, sizeof(k_demo_pkt10_text));
            break;
        case 9:
            draw_demo_packet9_fast();
            break;
        default:
            break;
    }
}


void render_title_scroll_roll(unsigned char scroll_y) {
    (void)PPU_STATUS_REG;
    PPU_CTRL_REG = 0x8A;
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = scroll_y;
}

void render_demo_scroll(unsigned char scroll_y) {
    (void)PPU_STATUS_REG;
    PPU_CTRL_REG = 0x88;
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = scroll_y;
}

void render_title_cursor(unsigned char players_2p) {
    unsigned char top = players_2p ? 0x20 : 0x5C;
    unsigned char bot = players_2p ? 0x5C : 0x20;

    /* Called from game loop after ppu_wait_vblank(); keep this update tiny
       and avoid toggling rendering to prevent visible flicker. */
    vram_adr(NTADR_A(10, 16));
    vram_put(top);
    vram_adr(NTADR_A(10, 18));
    vram_put(bot);
}

void render_title_full(unsigned char scroll_y, unsigned char players_2p, unsigned char slide_mode) {
    ppu_off();
    ppu_wait_vblank();
    ppu_clear_nt(0x2000, 0x20);
    ppu_clear_nt(0x2400, 0x20);
    ppu_clear_nt(0x2800, 0x20);
    ppu_clear_nt(0x2C00, 0x20);
    upload_title_palette();
    draw_title_attr(0x0000);
    draw_title_logo_graphics(0x0000);

    write_abs_direct_offset(0x2065, 0x0000, k_title_hi_score, sizeof(k_title_hi_score));
    write_abs_direct_offset(0x220A, 0x0000, k_title_p1, sizeof(k_title_p1));
    write_abs_direct_offset(0x224C, 0x0000, k_title_p2, sizeof(k_title_p2));
    write_abs_direct_offset(0x22AC, 0x0000, k_title_namcot, sizeof(k_title_namcot));
    write_abs_direct_offset(0x2305, 0x0000, k_title_copyright, sizeof(k_title_copyright));
    write_abs_direct_offset(0x2347, 0x0000, k_title_all_rights, sizeof(k_title_all_rights));
    render_title_cursor(players_2p);

    draw_title_score_row(0x0000);
    /* Latch scroll/ctrl once after VRAM writes, then enable rendering
       at the next vblank to avoid startup seam artifacts. */
    if (slide_mode != 0) {
        render_title_scroll_roll(scroll_y);
    } else {
        render_title_scroll(scroll_y);
    }
    ppu_wait_vblank();
    if (slide_mode != 0) {
        render_title_scroll_roll(scroll_y);
    } else {
        render_title_scroll(scroll_y);
    }
    ppu_on_bg();
}

static void draw_demo_names_base(void) {
    static const unsigned char k_blank32[32] = {
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
    };
    static const unsigned char k_blank19[19] = {
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
        0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
    };

    ppu_clear_nt(0x2000, 0x20);
    ppu_clear_nt(0x2400, 0x20);
    ppu_clear_nt(0x2800, 0x20);
    ppu_clear_nt(0x2C00, 0x20);
    write_abs_direct(0x2000, k_blank32, 32);
    write_abs_direct(0x2020, k_blank32, 32);
    write_abs_direct(0x2040, k_blank32, 32);
    write_abs_direct(0x2347, k_blank19, 19);
    draw_attract_playfield_frame();
    draw_attract_attr_and_palette();
    write_abs_direct_offset(0x2065, 0x0000, k_title_hi_score, sizeof(k_title_hi_score));
    draw_title_score_row(0x0000);
}

void render_demo_names_screen(void) {
    ppu_off();
    ppu_wait_vblank();
    draw_demo_names_base();
    draw_demo_packet_text(0);
    oam_clear();
    render_demo_scroll(0);
    ppu_on_all();
}

void render_demo_names_packet_vblank(unsigned char packet_idx) {
    if (packet_idx >= 10) {
        return;
    }

    /* Called strictly from demo_vblank(): incremental text-only update. */
    draw_demo_packet_text(packet_idx);
}

void render_demo_names_ghost_vblank(unsigned char strip_idx, unsigned char* oam_buf) {
    oam_write_strip_at(strip_idx, (unsigned char)(strip_idx << 4), oam_buf);
}

void render_demo_names_oam_flush(const unsigned char* oam_buf) {
    unsigned char i;
    OAM_ADDR_REG = 0x60;
    for (i = 0; i < 64; ++i) {
        OAM_DATA_REG = oam_buf[i];
    }
}

void render_demo_names_packet(unsigned char packet_idx) {
    /* Backward-compatible wrapper; demo path should call _vblank variant. */
    render_demo_names_packet_vblank(packet_idx);
    if ((packet_idx & 1) != 0) {
        oam_write_strip((unsigned char)((packet_idx - 1) >> 1));
    }
}

void render_chase_init(void) {
    unsigned char i;

    /* Original chase setup only clears the 10/50 PTS text area and keeps the
       rest of the names screen intact. */
    ppu_wait_vblank();
    (void)PPU_STATUS_REG;

    PPU_ADDR_REG = 0x22;
    PPU_ADDR_REG = 0xAD;
    for (i = 0; i < 8; ++i) {
        PPU_DATA_REG = 0x2D;
    }

    PPU_ADDR_REG = 0x22;
    PPU_ADDR_REG = 0xED;
    for (i = 0; i < 8; ++i) {
        PPU_DATA_REG = 0x2D;
    }

    render_demo_scroll(0);
}

void render_gameplay_frame(void) {
    ppu_off();
    ppu_wait_vblank();
    render_title_scroll(0);
    upload_palettes();
    ppu_clear_nt(0x2000, 0x20);
    ppu_clear_nt(0x2400, 0x20);
    maze_draw();
    pellets_draw();
    player_draw();
    ghosts_draw();
    ppu_on_bg();
}
