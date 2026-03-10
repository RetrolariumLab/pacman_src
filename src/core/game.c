#include "demo.h"
#include "game.h"
#include "ghosts.h"
#include "neslib.h"
#include "pellets.h"
#include "player.h"
#include "render.h"
#include "title.h"

enum {
    STATE_TITLE = 0,
    STATE_DEMO = 1,
    STATE_GAMEPLAY = 2
};

static unsigned char game_state;
static unsigned char players_2p;

static void gameplay_enter(void) {
    game_state = STATE_GAMEPLAY;
    player_reset();
    pellets_init();
    ghosts_init();
    render_gameplay_frame();
}

static void title_reenter(void) {
    ppu_off();
    ppu_wait_vblank();
    PPU_CTRL_REG = 0x08;
    oam_clear();
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = 0;
    title_init();
}

void game_init(void) {
    game_state = STATE_TITLE;
    players_2p = 0;
    ppu_off();
    ppu_wait_vblank();
    PPU_CTRL_REG = 0x08;
    oam_clear();
    PPU_SCROLL_REG = 0;
    PPU_SCROLL_REG = 0;
    title_init();
}

void game_frame(void) {
    unsigned char pad;
    pad = pad_poll(0);

    if (game_state == STATE_TITLE) {
        unsigned char start_game;
        unsigned char start_demo;
        title_update(pad, &start_game, &start_demo, &players_2p);
        if (start_game != 0) {
            gameplay_enter();
        } else if (start_demo != 0) {
            game_state = STATE_DEMO;
            demo_init();
        }
    } else if (game_state == STATE_DEMO) {
        demo_update(pad);
        if (demo_should_exit_to_title() != 0) {
            game_state = STATE_TITLE;
            title_reenter();
            return;
        }
    } else {
        (void)players_2p;
        player_update(pad);
        pellets_update();
        ghosts_update();
        render_gameplay_frame();
    }

    if (game_state == STATE_DEMO && demo_chase_transition_pending() != 0) {
        demo_commit_chase_transition();
        return;
    }

    ppu_wait_vblank();
    if (game_state == STATE_TITLE) {
        title_vblank();
    } else if (game_state == STATE_DEMO) {
        demo_vblank();
    }
}
