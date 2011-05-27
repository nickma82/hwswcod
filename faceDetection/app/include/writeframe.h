
#ifndef __writeframe_h__
#define __writeframe_h__

#include "drivers.h"

#define WRITEFRAME_BASE 	(0xFFFFFEA0)
#define WRITEFRAME_CMD		(*(volatile uint8_t *const)(WRITEFRAME_BASE+4))
#define WRITEFRAME_COLOR	(*(volatile uint32_t *const)(WRITEFRAME_BASE+8))

uint8_t getFrame(uint32_t color);

#endif // __writeframe_h__

