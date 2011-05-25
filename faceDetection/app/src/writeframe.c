#include "writeframe.h"

uint8_t getFrame() {
	WRITEFRAME_CMD = 1;
	
	while (WRITEFRAME_CMD) {
		asm("nop");
	}
	return WRITEFRAME_CMD;
}
