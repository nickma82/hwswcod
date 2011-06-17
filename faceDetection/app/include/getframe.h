#ifndef __getframe_h__
#define __getframe_h__

#include "drivers.h"

#define GETFRAME_BASE 		(0xFFFFFEA0)
#define GETFRAME_START		(*(volatile uint8_t *const)(GETFRAME_BASE+4))
#define GETFRAME_RETURN		(*(volatile uint8_t *const)(GETFRAME_BASE+5))
#define GETFRAME_DONE		(*(volatile uint8_t *const)(GETFRAME_BASE+6))

#define GETFRAME_R1			(*(volatile uint32_t *const)(GETFRAME_BASE+8))
#define GETFRAME_CLEAR		(*(volatile uint8_t *const)(GETFRAME_BASE+12))
#define GETFRAME_R2			(*(volatile uint32_t *const)(GETFRAME_BASE+16))

#define getframe_wait_return() while(!GETFRAME_RETURN) asm("nop")
#endif // __getframe_h__

