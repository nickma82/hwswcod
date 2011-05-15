#include "writeframe.h"

uint8_t getFrame() {
	volatile uint8_t *reg = (uint8_t *)(WRITEFRAME_BASE+WRITEFRAME_CMD_BOFF);
	WRITEFRAME_CMD = 1;
	
	while (WRITEFRAME_CMD) {
		asm("nop")
	}
	return WRITEFRAME_CMD;
}