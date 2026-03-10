#ifndef PPU_QUEUE_H
#define PPU_QUEUE_H

void ppu_queue_reset(void);
unsigned char ppu_queue_set_addr(unsigned int addr);
unsigned char ppu_queue_put(unsigned char v);
unsigned char ppu_queue_write(const unsigned char* data, unsigned char len);
unsigned char ppu_queue_fill(unsigned char v, unsigned char len);
void ppu_queue_flush(void);

#endif
