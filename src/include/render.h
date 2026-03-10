#ifndef RENDER_H
#define RENDER_H

void render_title_full(unsigned char scroll_y, unsigned char players_2p, unsigned char slide_mode);
void render_title_scroll(unsigned char scroll_y);
void render_title_scroll_roll(unsigned char scroll_y);
void render_demo_scroll(unsigned char scroll_y);
void render_title_cursor(unsigned char players_2p);
void render_demo_names_screen(void);
void render_demo_names_packet(unsigned char packet_idx);
void render_demo_names_packet_vblank(unsigned char packet_idx);
void render_demo_names_ghost_vblank(unsigned char strip_idx, unsigned char* oam_buf);
void render_demo_names_oam_flush(const unsigned char* oam_buf);
void render_chase_init(void);
void render_gameplay_frame(void);

#endif
