#include <inttypes.h>

#if defined __SPEAR16__
  #include "gdb/sim-spear16.h"
  #define SPEAR2_ADDR_CTYPE  uint16_t
#elif defined __SPEAR32__
  #include "gdb/sim-spear32.h"
  #define SPEAR2_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

#define ALUEXT_BASE 		(0xFFFFFE80)

#define ALUEXT_OP_A	(*(volatile int *const)(ALUEXT_BASE+4))
#define ALUEXT_OP_B	(*(volatile int *const)(ALUEXT_BASE+8))
#define ALUEXT_RES	(*(volatile int *const)(ALUEXT_BASE+12))
#define ALUEXT_CMD	(*(volatile int *const)(ALUEXT_BASE+16))

#define ALUEXT_MULT 0x01

/*
int mult(int a,int b) {
	volatile int *reg = (int *)(ALUEXT_BASE +12);
	volatile uint32_t *reg1 = (uint32_t *)(ALUEXT_BASE+4);
	volatile uint32_t *reg2 = (uint32_t *)(ALUEXT_BASE+8);
	*reg1 = a;
	*reg2 = b;
	//ALUEXT_CMD  = ALUEXT_MULT;
	asm("nop");
	return *reg;
}*/
//#define COUNTER_BADDR ((uint32_t)-320)

int main (int argc, char *argv[])
{
  //int tmp = mult(10,10);
  //volatile uint32_t *reg = (uint32_t *)(COUNTER_BADDR+8);
  //return *reg;
  volatile uint32_t *reg1 = (uint32_t *)(ALUEXT_BASE+4);
  volatile uint32_t *reg2 = (uint32_t *)(ALUEXT_BASE+12);
  *reg1 = 10;
  int asdf = *reg2;
  return asdf;
}

