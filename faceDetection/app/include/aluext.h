#ifndef __aluext_h__
#define __aluext_h__

#include "drivers.h"

#define ALUEXT_BASE 		(0xFFFFFE80)

#define ALUEXT_R	(*(volatile uint8_t *const)(ALUEXT_BASE+4))
#define ALUEXT_G	(*(volatile uint8_t *const)(ALUEXT_BASE+5))
#define ALUEXT_B	(*(volatile uint8_t *const)(ALUEXT_BASE+6))
#define ALUEXT_Y	(*(volatile int32_t *const)(ALUEXT_BASE+8))
#define ALUEXT_CB	(*(volatile int32_t *const)(ALUEXT_BASE+12))
#define ALUEXT_CR	(*(volatile int32_t *const)(ALUEXT_BASE+16))

//#define ALUEXT_MULT 0x01

//inline int32_t mult(int32_t a,int32_t b) __attribute__((always_inline));


#endif // __aluext_h__

