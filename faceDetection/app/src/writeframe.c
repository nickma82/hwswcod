#include "writeframe.h"

void getFrame(uint32_t color) {
	
	WRITEFRAME_COLOR = color;
	WRITEFRAME_CMD = 1;	
	while (WRITEFRAME_CMD) {
		asm("nop");
	}
}
