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
#endif // __SPEAR32__

int main(int argc, char **argv)
{	
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
			
			//dis7seg_hex(mult(10,20));
			benchmark_messure(getFrame());
			test_receiveImage(&image, argv[1]);
			face = faceDetection(&image);
			image_paintRectangle(&image, face);
			//svga_outputImage(&image);
			test_sendImage(&image, argv[2]);
		}
	#else
		dis7seg_hex(0x00);
		read_cam(0x00);
		dis7seg_hex(0x01);
		getFrame();
		while (1) {
			
			//getFrame();
			// TODO:
			// get picture from camera
			//faceDetection();
			// outout result image on screen
		}  
	#endif
	
	#ifdef __SPEAR32__
		test_release();
		dis7seg_release();
	#endif
	
	return 0;
}
