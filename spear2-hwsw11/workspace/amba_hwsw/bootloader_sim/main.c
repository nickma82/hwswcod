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

#define WRITEFRAME_BASE 	(0xFFFFFEA0)
#define WRITEFRAME_CMD		(*(volatile uint8_t *const)(WRITEFRAME_BASE+4))
#define WRITEFRAME_COLOR	(*(volatile uint32_t *const)(WRITEFRAME_BASE+8))
int main (int argc, char *argv[])
{
	WRITEFRAME_CMD = 1;
	
	while (WRITEFRAME_CMD) {
		asm("nop");
	}
	return WRITEFRAME_CMD;
}

