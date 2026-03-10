#include "neslib.h"
#include "ppu_queue.h"

enum {
    CMD_SET_ADDR = 0,
    CMD_WRITE = 1,
    CMD_FILL = 2,
    CMD_WRITE_BLOCK = 3,
    CMD_END = 0xFF,
    QUEUE_CAPACITY = 448
};

static unsigned char queue_buf[QUEUE_CAPACITY];
static unsigned int queue_len;

static unsigned char reserve_bytes(unsigned int n) {
    return (unsigned char)((queue_len + n) <= QUEUE_CAPACITY);
}

void ppu_queue_reset(void) {
    queue_len = 0;
}

unsigned char ppu_queue_set_addr(unsigned int addr) {
    if (!reserve_bytes(3)) {
        return 0;
    }
    queue_buf[queue_len++] = CMD_SET_ADDR;
    queue_buf[queue_len++] = (unsigned char)(addr >> 8);
    queue_buf[queue_len++] = (unsigned char)(addr & 0xFF);
    return 1;
}

unsigned char ppu_queue_put(unsigned char v) {
    if (!reserve_bytes(2)) {
        return 0;
    }
    queue_buf[queue_len++] = CMD_WRITE;
    queue_buf[queue_len++] = v;
    return 1;
}

unsigned char ppu_queue_write(const unsigned char* data, unsigned char len) {
    unsigned char i;
    if (!reserve_bytes((unsigned int)len + 2u)) {
        return 0;
    }
    queue_buf[queue_len++] = CMD_WRITE_BLOCK;
    queue_buf[queue_len++] = len;
    for (i = 0; i < len; ++i) {
        queue_buf[queue_len++] = data[i];
    }
    return 1;
}

unsigned char ppu_queue_fill(unsigned char v, unsigned char len) {
    if (!reserve_bytes(3)) {
        return 0;
    }
    queue_buf[queue_len++] = CMD_FILL;
    queue_buf[queue_len++] = len;
    queue_buf[queue_len++] = v;
    return 1;
}

void ppu_queue_flush(void) {
    unsigned int i = 0;
    (void)PPU_STATUS_REG;
    while (i < queue_len) {
        unsigned char cmd = queue_buf[i++];
        if (cmd == CMD_SET_ADDR) {
            if ((i + 1u) >= queue_len) {
                break;
            }
            PPU_ADDR_REG = queue_buf[i++];
            PPU_ADDR_REG = queue_buf[i++];
        } else if (cmd == CMD_WRITE) {
            if (i >= queue_len) {
                break;
            }
            PPU_DATA_REG = queue_buf[i++];
        } else if (cmd == CMD_FILL) {
            unsigned char count;
            unsigned char v;
            if ((i + 1u) >= queue_len) {
                break;
            }
            count = queue_buf[i++];
            v = queue_buf[i++];
            while (count--) {
                PPU_DATA_REG = v;
            }
        } else if (cmd == CMD_WRITE_BLOCK) {
            unsigned char count;
            if (i >= queue_len) {
                break;
            }
            count = queue_buf[i++];
            if ((i + (unsigned int)count) > queue_len) {
                break;
            }
            while (count--) {
                PPU_DATA_REG = queue_buf[i++];
            }
        } else if (cmd == CMD_END) {
            break;
        } else {
            break;
        }
    }
    queue_len = 0;
}
