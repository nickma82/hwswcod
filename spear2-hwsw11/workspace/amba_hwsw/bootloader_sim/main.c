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

#define ALUEXT_R	(*(volatile uint8_t *const)(ALUEXT_BASE+4))
#define ALUEXT_G	(*(volatile uint8_t *const)(ALUEXT_BASE+5))
#define ALUEXT_B	(*(volatile uint8_t *const)(ALUEXT_BASE+6))
#define ALUEXT_Y	(*(volatile int32_t *const)(ALUEXT_BASE+8))
#define ALUEXT_CB	(*(volatile int32_t *const)(ALUEXT_BASE+12))
#define ALUEXT_CR	(*(volatile int32_t *const)(ALUEXT_BASE+16))



int main (int argc, char *argv[])
{
	ALUEXT_R = 100;
	ALUEXT_G = 255;
	ALUEXT_B = 10;
	/*int32_t rf = (mult(1000,cl.r)) >> 8;
	int32_t gf = (mult(1000,cl.g)) >> 8;
	int32_t bf = (mult(1000,cl.b)) >> 8;
	
	result.y = mult(299000,rf) + mult(587000,gf) + mult(114000,bf);
	result.cb = mult(-168736,rf) + mult(-331264,gf) + mult(500000,bf);
	result.cr = mult(500000, rf) + -mult(418688,gf) + mult(-81312, bf);*/
	int32_t tmp;
	tmp = ALUEXT_Y;
	tmp = ALUEXT_CB;
	tmp = ALUEXT_CR;
	return 0;
}

