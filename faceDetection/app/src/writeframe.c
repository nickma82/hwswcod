#include "writeframe.h"

uint8_t getFrame(uint32_t color) {
	WRITEFRAME_CMD = 1;
	WRITEFRAME_COLOR = color;
	
	while (WRITEFRAME_CMD) {
		asm("nop");
	}
	return WRITEFRAME_CMD;
}
