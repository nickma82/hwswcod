#ifndef __aluext_h__
#define __aluext_h__

#include "drivers.h"

#define ALUEXT_BASE 		((uint32_t)-396)

#define ALUEXT_OP_A	(*(volatile int *const)(ALUEXT_BASE+4))
#define ALUEXT_OP_B	(*(volatile int *const)(ALUEXT_BASE+8))
#define ALUEXT_RES	(*(volatile int *const)(ALUEXT_BASE+12))
#define ALUEXT_CMD	(*(volatile int *const)(ALUEXT_BASE+16))

#define ALUEXT_MULT 0x01

int mult(int a,int b);

#endif // __aluext_h__

