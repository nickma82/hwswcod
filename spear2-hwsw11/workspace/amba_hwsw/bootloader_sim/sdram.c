#if defined __SPEAR16__
  #include "gdb/sim-spear16.h"
  #define SPEAR2_ADDR_CTYPE  uint16_t
#elif defined __SPEAR32__
  #include "gdb/sim-spear32.h"
  #define SPEAR2_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

#include <machine/modules.h>
#include <machine/interrupts.h>

#include "sdram.h"

void sdram_init(void) {
	SDRAM_CFG = SDRAM_REFRESH_EN | 
	SDRAM_TRFC(2) | 
	SDRAM_BANKSIZE_128MB | 
	SDRAM_COLSIZE_1024 | 
	SDRAM_CMD_LOAD_CMD_REG | 389;
	
	sdramBytesAllocated = 0;
}
