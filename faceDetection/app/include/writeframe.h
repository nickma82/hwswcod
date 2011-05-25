
#ifndef __writeframe_h__
#define __writeframe_h__

#include "drivers.h"

#define WRITEFRAME_BASE 	(0xFFFFFEA0)
#define WRITEFRAME_CMD		(*(volatile uint8_t *const)(WRITEFRAME_BASE+4))

uint8_t getFrame();

#endif // __writeframe_h__

