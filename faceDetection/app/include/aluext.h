#ifndef __aluext_h__
#define __aluext_h__

#include "drivers.h"

#define ALUEXT_BASE 		(0xFFFFFE80)

#define ALUEXT_RGB	(*(volatile uint32_t *const)(ALUEXT_BASE+4))
#define ALUEXT_SKIN	(*(volatile uint8_t *const)(ALUEXT_BASE+8))

#define ALUEXT_OPA		(*(volatile uint32_t *const)(ALUEXT_BASE+12))
#define ALUEXT_OPB		(*(volatile uint32_t *const)(ALUEXT_BASE+16))
#define ALUEXT_RESMULT	(*(volatile uint32_t *const)(ALUEXT_BASE+20))
#define ALUEXT_RESDIV	(*(volatile uint32_t *const)(ALUEXT_BASE+24))
/*
#define ALUEXT_R	(*(volatile uint8_t *const)(ALUEXT_BASE+4))
#define ALUEXT_G	(*(volatile uint8_t *const)(ALUEXT_BASE+5))
#define ALUEXT_B	(*(volatile uint8_t *const)(ALUEXT_BASE+6))
#define ALUEXT_Y	(*(volatile int32_t *const)(ALUEXT_BASE+8))
#define ALUEXT_CB	(*(volatile int32_t *const)(ALUEXT_BASE+12))
#define ALUEXT_CR	(*(volatile int32_t *const)(ALUEXT_BASE+16))
*/

#endif // __aluext_h__

