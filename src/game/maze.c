#include "neslib.h"
#include "maze.h"

static unsigned char is_vertical_bar(unsigned char x, unsigned char y) {
    if ((x == 6 || x == 21) && y > 3 && y < 20 && (y < 10 || y > 13)) {
        return 1;
    }
    return 0;
}

static unsigned char is_horizontal_bar(unsigned char x, unsigned char y) {
    if ((y == 6 || y == 12 || y == 18) && x > 2 && x < 25 && (x < 12 || x > 15)) {
        return 1;
    }
    return 0;
}

unsigned char maze_is_wall(unsigned char x, unsigned char y) {
    if (x >= MAZE_WIDTH || y >= MAZE_HEIGHT) {
        return 1;
    }

    if (x == 0 || x == (MAZE_WIDTH - 1) || y == 0 || y == (MAZE_HEIGHT - 1)) {
        return 1;
    }

    if (is_vertical_bar(x, y) || is_horizontal_bar(x, y)) {
        return 1;
    }

    return 0;
}

void maze_draw(void) {
    unsigned char x;
    unsigned char y;

    for (y = 0; y < MAZE_HEIGHT; ++y) {
        vram_adr(NTADR_A(MAZE_ORIGIN_X, (unsigned char)(MAZE_ORIGIN_Y + y)));
        for (x = 0; x < MAZE_WIDTH; ++x) {
            if (maze_is_wall(x, y)) {
                vram_put(0x5C);
            } else {
                vram_put(0x20);
            }
        }
    }
}
