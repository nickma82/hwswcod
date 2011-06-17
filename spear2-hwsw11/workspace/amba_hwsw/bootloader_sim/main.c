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

#include "svga.h"

#define GETFRAME_BASE 		(0xFFFFFEA0)
#define GETFRAME_START		(*(volatile uint8_t *const)(GETFRAME_BASE+4))
#define GETFRAME_RETURN		(*(volatile uint8_t *const)(GETFRAME_BASE+5))
#define GETFRAME_DONE		(*(volatile uint8_t *const)(GETFRAME_BASE+6))

#define GETFRAME_CLEAR		(*(volatile uint8_t *const)(GETFRAME_BASE+12))

#define getframe_wait_return() while(!GETFRAME_RETURN) asm("nop")

#define ALUEXT_BASE 		(0xFFFFFE80)


#define ALUEXT_RGB	(*(volatile uint32_t *const)(ALUEXT_BASE+4))
#define ALUEXT_SKIN	(*(volatile uint8_t *const)(ALUEXT_BASE+8))

#define SCREEN_WIDTH  800
#define SCREEN_HEIGHT 480

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

#define SDRAM_BASE      (0xE0000000)
#define SDRAM_BASE_IO   (0xFFF00000)

int main (int argc, char *argv[])
{
	int i;
	/*SVGA_VIDEO_LENGTH = ((SCREEN_HEIGHT-1)<<16) | (SCREEN_WIDTH-1);
	SVGA_FRONT_PORCH = (10<<16) | 40;
	SVGA_SYNC_LENGTH = (1<<16) | 1;
	SVGA_LINE_LENGTH = (526<<16) | 1056;
	SVGA_FRAME_BUFFER = SDRAM_BASE;
	SVGA_DYN_CLOCK0 = 30000;
	SVGA_STATUS = (1<<0) | (3<<4);*/
	
	sdram_init();
	svga_init();
	
	while (1) {
		GETFRAME_START = 1;
		//i = 0;	
		while(!GETFRAME_RETURN ) {
			//dis7seg_uint32(GETFRAME_COUNTER);
			asm("nop");
		}	
	}
	
	/*while (1) {
		GETFRAME_START = 1;
		getframe_wait_return();
		i = 0;
		while(i < 100)
			i++;
	}*/
	//}
	//return WRITEFRAME_CMD;
	/*ALUEXT_RGB = (74 << 16) | (112 << 8) |  194;
	asm("nop");
	return ALUEXT_SKIN;*/
	return 0;
}



