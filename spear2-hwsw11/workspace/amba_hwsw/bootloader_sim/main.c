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

#define SCREEN_WIDTH  800
#define SCREEN_HEIGHT 480

#define SDRAM_BASE      (0xE0000000)
#define SDRAM_BASE_IO   (0xFFF00000)

#define SVGA_BASE (0xF0000100)
#define SVGA_STATUS (*(volatile int *const) (SVGA_BASE))
#define SVGA_VIDEO_LENGTH (*(volatile int *const) (SVGA_BASE+4))
#define SVGA_FRONT_PORCH (*(volatile int *const) (SVGA_BASE+8))
#define SVGA_SYNC_LENGTH (*(volatile int *const) (SVGA_BASE+12))
#define SVGA_LINE_LENGTH (*(volatile int *const) (SVGA_BASE+16))
#define SVGA_FRAME_BUFFER (*(volatile int *const) (SVGA_BASE+20))
#define SVGA_DYN_CLOCK0 (*(volatile int *const) (SVGA_BASE+24))
#define SVGA_DYN_CLOCK1 (*(volatile int *const) (SVGA_BASE+28))
#define SVGA_DYN_CLOCK2 (*(volatile int *const) (SVGA_BASE+32))
#define SVGA_DYN_CLOCK3 (*(volatile int *const) (SVGA_BASE+36))
#define SVGA_CLUT (*(volatile int *const) (SVGA_BASE+40))


#define SVGA_VVIDEOLEN(x) (x<<16)
#define SVGA_HVIDEOLEN(x) (x)

#define SVGA_VPORCH(x)	(x<<16)
#define SVGA_HPORCH(x)	(x)

#define SVGA_VLINELEN(x)	(x<<16)
#define SVGA_HLINELEN(x)	(x)

int main (int argc, char *argv[])
{
	WRITEFRAME_CMD = 1;
	
	while (WRITEFRAME_CMD) {
		asm("nop");
	}
	
	/*SVGA_VIDEO_LENGTH = ((SCREEN_HEIGHT-1)<<16) | (SCREEN_WIDTH-1);
	SVGA_FRONT_PORCH = (10<<16) | 40;
	SVGA_SYNC_LENGTH = (1<<16) | 1;
	SVGA_LINE_LENGTH = (526<<16) | 1056;
	SVGA_FRAME_BUFFER = SDRAM_BASE;
	SVGA_DYN_CLOCK0 = 30000;
	SVGA_STATUS = (1<<0) | (3<<4);*/
	
	
	return 0;
}

