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

#define CAMCONFIG_BASE 		(0xFFFFFE60)

#define CAMCONFIG_CMD		(*(volatile uint32_t *const)(CAMCONFIG_BASE+4))
#define CAMCONFIG_RESULT	(*(volatile uint8_t *const)(CAMCONFIG_BASE+8))

#define CAM_ID_READ		(0xBB000000)
#define CAM_ID_WRITE 	(0xBA000000)

int main (int argc, char *argv[])
{
	CAMCONFIG_CMD = CAM_ID_READ | (0x06 << 16);
	
	while (!CAMCONFIG_RESULT){
		asm("nop");
	}	
	
	return 0;
}

