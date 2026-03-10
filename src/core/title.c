#include "neslib.h"
#include "render.h"
#include "title.h"

enum {
    TITLE_STATE_SLIDE = 0,
    TITLE_STATE_MENU = 1
};

/* Target frame alignment for title->attract handoff in current C loop. */
#define TITLE_DEMO_TIMEOUT_FRAMES 0x01ECu
#define TITLE_SLIDE_START_DELAY 0u

static unsigned char title_state;
static unsigned char title_scroll_y;
static unsigned int title_menu_timer;
static unsigned char title_players_2p;
static unsigned char title_cursor_dirty;
static unsigned char select_latch;
static unsigned char start_latch;

static void title_apply_roll_scroll(unsigned char y) {
    (void)PPU_STATUS_REG;
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = y;
    PPU_CTRL_REG = 0x8A;
}

void title_init(void) {
    title_state = TITLE_STATE_SLIDE;
    /* Original rollout counter: grows from 0 to 0xF0, then snaps to 0. */
    title_scroll_y = 0x01;
    title_menu_timer = TITLE_SLIDE_START_DELAY;
    title_players_2p = 0;
    title_cursor_dirty = 0;
    select_latch = 0;
    start_latch = 0;
    render_title_full(title_scroll_y, title_players_2p, 1);
}

void title_vblank(void) {
    if (title_state == TITLE_STATE_SLIDE) {
        title_apply_roll_scroll(title_scroll_y);
    } else {
        if (title_cursor_dirty != 0) {
            render_title_cursor(title_players_2p);
            title_cursor_dirty = 0;
        }
        /* Keep scroll/control latched every frame after any VRAM writes. */
        render_title_scroll(0);
    }
}

void title_update(unsigned char pad, unsigned char* start_game, unsigned char* start_demo, unsigned char* players_2p) {
    unsigned char start_now = (unsigned char)((pad & PAD_START) != 0);
    unsigned char select_now = (unsigned char)((pad & PAD_SELECT) != 0);
    unsigned char start_edge = (unsigned char)(start_now && !start_latch);
    unsigned char select_edge = (unsigned char)(select_now && !select_latch);

    *start_game = 0;
    *start_demo = 0;
    *players_2p = title_players_2p;

    if (title_state == TITLE_STATE_SLIDE) {
        if ((pad & (PAD_START | PAD_SELECT)) != 0) {
            title_scroll_y = 0;
            title_menu_timer = 0u;
            title_state = TITLE_STATE_MENU;
            title_cursor_dirty = 1;
        } else if (title_menu_timer != 0u) {
            --title_menu_timer;
        } else if (title_scroll_y < 0xEF) {
            ++title_scroll_y;
        } else {
            title_scroll_y = 0x00;
            title_state = TITLE_STATE_MENU;
            title_menu_timer = 0u;
            title_cursor_dirty = 1;
        }
    } else {
        ++title_menu_timer;

        /* 16-bit title idle timer, aligned to reference handoff timing. */
        if (title_menu_timer >= TITLE_DEMO_TIMEOUT_FRAMES) {
            *start_demo = 1;
            title_menu_timer = 0u;
        } else {
            if (select_edge) {
                title_players_2p ^= 1;
                *players_2p = title_players_2p;
                title_cursor_dirty = 1;
                /* Original resets timer to 0x0001 on select edge. */
                title_menu_timer = 1u;
            }

            if (start_edge) {
                *players_2p = title_players_2p;
                *start_game = 1;
            }
        }
    }

    start_latch = start_now;
    select_latch = select_now;
}
