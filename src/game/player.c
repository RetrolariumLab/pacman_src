#include "neslib.h"
#include "maze.h"
#include "player.h"

static unsigned char player_x;
static unsigned char player_y;
static unsigned char move_cooldown;

void player_reset(void) {
    player_x = 1;
    player_y = 1;
    move_cooldown = 0;
}

void player_update(unsigned char pad) {
    unsigned char nx = player_x;
    unsigned char ny = player_y;

    if (move_cooldown != 0) {
        --move_cooldown;
        return;
    }

    if (pad & PAD_LEFT) {
        if (nx > 0) {
            --nx;
        }
    } else if (pad & PAD_RIGHT) {
        ++nx;
    } else if (pad & PAD_UP) {
        if (ny > 0) {
            --ny;
        }
    } else if (pad & PAD_DOWN) {
        ++ny;
    } else {
        return;
    }

    if (!maze_is_wall(nx, ny)) {
        player_x = nx;
        player_y = ny;
        move_cooldown = 4;
    }
}

void player_draw(void) {
    vram_adr(NTADR_A((unsigned char)(MAZE_ORIGIN_X + player_x), (unsigned char)(MAZE_ORIGIN_Y + player_y)));
    vram_put(0x5E);
}
