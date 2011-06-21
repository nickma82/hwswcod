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

