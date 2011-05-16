#include "aluext.h"
 
/*inline int32_t mult(int32_t a,int32_t b) {
	/*volatile int *reg = (int *)(ALUEXT_BASE +12);
	volatile uint32_t *reg1 = (uint32_t *)(ALUEXT_BASE+4);
	volatile uint32_t *reg2 = (uint32_t *)(ALUEXT_BASE+8);
	*reg1 = a;
	*reg2 = b;
	//ALUEXT_CMD  = ALUEXT_MULT;
	asm("nop");*/
	
	/*volatile uint32_t *reg1 = (uint32_t *)(ALUEXT_BASE+4);
	volatile uint32_t *reg2 = (uint32_t *)(ALUEXT_BASE+8);
	volatile uint32_t *reg3 = (uint32_t *)(ALUEXT_BASE+12);
	
	*reg1 = a;
	*reg2 = b;
	return *reg3;*/
	
	/*ALUEXT_OP_A = a;
	ALUEXT_OP_B = b;
	return ALUEXT_RES;
}*/
