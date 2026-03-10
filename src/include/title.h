#ifndef TITLE_H
#define TITLE_H

void title_init(void);
void title_vblank(void);
void title_update(unsigned char pad, unsigned char* start_game, unsigned char* start_demo, unsigned char* players_2p);

#endif
