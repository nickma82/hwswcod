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
	#include "getframe.h"
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
		
		// invert pixe clock
		write_cam(0x0A, 0x8000);
		
		// column size
		write_cam(0x04, 2559);
		
		// row size
		write_cam(0x03, 1919);
		
		// shutter width lower
		//write_cam(0x09, 470);
		
		// row and column skiping => 640x480 res
		write_cam(0x22, 0x33);
		write_cam(0x23, 0x33);
		
		// testbild
		//write_cam(0xA0,0x20);
		
		// restart cam
		write_cam(0x0b, 0x01);		
		
		// wait for restart finished
		while(read_cam(0x0b)&0x01)
			asm("nop");
				
		dis7seg_hex(read_cam(0x04));
		i = 0;		
		
		GETFRAME_CLEAR = 1;
		while (!GETFRAME_CLEAR)
			asm("nop");
		
		/*while (1) {

			*reg = (1 << COUNTER_CLEAR_BIT);
			*reg = (1 << COUNTER_COUNT_BIT);
			
			GETFRAME_START = 1;
			
			while(!GETFRAME_RETURN) {
				//dis7seg_hex((*(volatile uint32_t *const)(GETFRAME_BASE+4)));
				dis7seg_uint32(GETFRAME_COUNTER);
				//asm("nop");
			}
			for(i = 0; i < 10000000; i++)
				asm("nop");
			
			//dis7seg_uint32(GETFRAME_COUNTER);
			
			printf("%d\n",(int)fps_c);
			fps_c = counter_getValue(&counterHandle);
			
			fps_c *= CLKPERIOD * PRESCALER;
			fps_c /= 1000000;
			//dis7seg_uint32(1000 / fps_c);
			i++;
		}*/
	#endif
	dis7seg_hex(0xEEEEEEEE);
	#ifdef __SPEAR32__
		test_release();
		dis7seg_release();
	#endif
	
	return 0;
}
