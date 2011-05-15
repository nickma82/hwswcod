
#ifndef __writeframe_h__
#define __writeframe_h__

#include "drivers.h"

#define WRITEFRAME_BASE 	((uint32_t)-352)
#define WRITEFRAME_CMD		(*(volatile uint_8 *const)(WRITEFRAME_BASE+4))

uint8_t getFrame();

#endif // __writeframe_h__

