#include "writeframe.h"

uint8_t getFrame() {
	volatile uint8_t *reg = (uint8_t *)(WRITEFRAME_BASE+WRITEFRAME_CMD_BOFF);
	*reg = 1;
	
	while (*reg) {
		asm("nop")
	}
	return *reg;
}