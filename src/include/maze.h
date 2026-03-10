#ifndef MAZE_H
#define MAZE_H

#define MAZE_WIDTH 28
#define MAZE_HEIGHT 24
#define MAZE_ORIGIN_X 2
#define MAZE_ORIGIN_Y 4

unsigned char maze_is_wall(unsigned char x, unsigned char y);
void maze_draw(void);

#endif
