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


#define CAMCONFIG_WRITE		(*(volatile uint32_t *const)(CAMCONFIG_BASE+4))
#define CAMCONFIG_READ		(*(volatile uint32_t *const)(CAMCONFIG_BASE+8))
#define CAMCONFIG_RESULT	(*(volatile uint32_t *const)(CAMCONFIG_BASE+12))
#define CAMCONFIG_STATUS	(*(volatile uint8_t *const)(CAMCONFIG_BASE+16))

#define CAM_ID_READ		(0xBB)
//#define CAM_ID_READ		(0xAB000000)
#define CAM_ID_WRITE 	(0xBA)

int main (int argc, char *argv[])
{
	CAMCONFIG_READ = (CAM_ID_WRITE << 24) | (CAM_ID_READ<<16) | (0x06 << 8);
	
	while (!CAMCONFIG_STATUS){
		asm("nop");
	}
	return CAMCONFIG_RESULT;
}

