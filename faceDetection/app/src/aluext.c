#include "aluext.h"
 
int mult(int a,int b) {
	ALUEXT_OP_A = a;
	ALUEXT_OP_B = b;
	ALUEXT_CMD  = ALUEXT_MULT;
	asm("nop");
	return ALUEXT_RES;
}