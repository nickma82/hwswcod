#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utils.h"
#include "detectFace.h"
#include "test.h"

#ifdef __SPEAR32__
	#include "sdram.h"
	#include "svga.h"
	#include "dis7seg.h"
	#include "aluext.h"
	#include "writeframe.h"
	#include "camconfig.h"
	
	extern uint8_t *reg;
	extern module_handle_t counterHandle;
#endif // __SPEAR32__

#define CLKPERIOD 20
#define PRESCALER 1

int main(int argc, char **argv)
{	
	uint32_t fps_c,i;
	
	#ifdef __SPEAR32__
		// initialize HW modules
		dis7seg_init();
		sdram_init();
		svga_init();
		test_init();
		
	#endif
	
	#ifdef TEST
		{
			image_t image;
			rect_t face;
			
			test_receiveImage(&image, argv[1]);
						
			face = faceDetection(&image);
			image_paintRectangle(&image, face);
			svga_outputImage(&image);
			test_sendImage(&image, argv[2]);
			
		}
	#else
				
		dis7seg_hex(0x01);
		
		write_cam(0x04, 2559);
		write_cam(0x03, 1919);
		write_cam(0x09, 470);
		write_cam(0x22, 3);
		write_cam(0x23, 3);
		
		dis7seg_hex(read_cam(0x04));
		
		uint32_t color = 0x00FF000F;
		i = 0;
		while (i < 100000) {

			*reg = (1 << COUNTER_CLEAR_BIT);
			*reg = (1 << COUNTER_COUNT_BIT);
			
			getFrame(color);
			color += 50;
			
			fps_c = counter_getValue(&counterHandle);
			
			fps_c *= CLKPERIOD * PRESCALER;
			fps_c /= 1000000;
			dis7seg_uint32(1000 / fps_c);
			i++;
		}
	#endif
	dis7seg_hex(0xEEEEEEEE);
	#ifdef __SPEAR32__
		test_release();
		dis7seg_release();
	#endif
	
	return 0;
}
