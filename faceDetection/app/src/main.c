#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "detectFace.h"
#include "test.h"

#include "sdram.h"
#include "svga.h"
#include "dis7seg.h"
#include "aluext.h"
#include "getframe.h"
#include "camconfig.h"

#define CLKPERIOD 20
#define PRESCALER 1

int main(int argc, char **argv)
{
	image_t image;
	bwimage_t temp,temp2;

	// initialize HW modules
	dis7seg_init();
	sdram_init();
	svga_init();
	test_init();

	#ifdef TEST
		test_receiveImage(&image, argv[1]);

		bwimage_init(&image, &temp);
		bwimage_init(&image, &temp2);
		memset((void *)temp.data, 0, sizeof(temp.data));
		memset((void *)temp2.data, 0, sizeof(temp2.data));

		svga_outputImage(&image);

		printf("Starting computation.\n");

		svga_paintRectangle(faceDetection(&image, &temp, &temp2));

		printf("Computation completed.\n");

		test_sendImage(&image, argv[2]);
	#else
		uint32_t fps_c,i,y,fps_mean;

		dis7seg_hex(0x01);

		setup_cam();

		y = 0;
		i = 0;
		fps_mean = 0;
		image.width = IMAGE_WIDTH;
		image.height = IMAGE_HEIGHT;
		image.dataLength = 4 * IMAGE_WIDTH * IMAGE_HEIGHT;
		image.data = (unsigned char *)(SDRAM_BASE);
		bwimage_init(&image, &temp);
		bwimage_init(&image, &temp2);
		rect_t face;
		//GETFRAME_CLEAR=1;
		while (i < 100) {

			*reg = (1 << COUNTER_CLEAR_BIT);
			*reg = (1 << COUNTER_COUNT_BIT);

			memset((void *)temp.data, 0, sizeof(temp.data));
			memset((void *)temp2.data, 0, sizeof(temp2.data));

			GETFRAME_START = 1;
			getframe_wait_return();

			face = faceDetection(&image, &temp, &temp2);

			GETFRAME_R1 = (face.topLeftX << 16) | face.topLeftY;
			GETFRAME_R2 = (face.bottomRightX << 16) | face.bottomRightY;

			//getframe_wait_return();

			*reg = 0;

			fps_c = counter_getValue(&counterHandle);
			fps_c *= CLKPERIOD * PRESCALER;
			fps_c = 1000000000 / fps_c;
			dis7seg_uint32(fps_c);
			//printf("%i\n",fps_c);

			//for(y = 0; y < 1000000; y++)
			//	asm("nop");

			#ifdef SENDIMG
				i++;
			#endif // SENDIMG
		}
		#ifdef SENDIMG
			sendFrameBuffer(argv[2]);
		#endif // SENDIMG
	#endif

	dis7seg_hex(0xEEEEEEEE);

	test_release();
	dis7seg_release();

	return 0;
}
