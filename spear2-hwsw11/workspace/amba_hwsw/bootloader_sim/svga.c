#if defined __SPEAR16__
  #include "gdb/sim-spear16.h"
  #define SPEAR2_ADDR_CTYPE  uint16_t
#elif defined __SPEAR32__
  #include "gdb/sim-spear32.h"
  #define SPEAR2_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

#include <string.h>
#include <stdio.h>
//#include <machine/modules.h>
//#include <machine/interrupts.h>

#include "sdram.h"
#include "svga.h"

volatile uint32_t *screenData;

void svga_init(void) {
	SVGA_VIDEO_LENGTH = ((SCREEN_HEIGHT-1)<<16) | (SCREEN_WIDTH-1);
	SVGA_FRONT_PORCH = (10<<16) | 40;
	SVGA_SYNC_LENGTH = (1<<16) | 1;
	SVGA_LINE_LENGTH = (526<<16) | 1056;
	SVGA_FRAME_BUFFER = SDRAM_BASE;
	SVGA_DYN_CLOCK0 = 30000;
	SVGA_STATUS = (1<<0) | (3<<4);
	sdramBytesAllocated += SCREEN_WIDTH*SCREEN_HEIGHT*4;
	screenData = (volatile uint32_t *)SDRAM_BASE;
	memset((void *)screenData, 0, (SCREEN_WIDTH*SCREEN_HEIGHT*4));
}


