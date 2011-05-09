#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "utils.h"
#include "detectFace.h"

#ifdef __SPEAR32__
	#include <machine/modules.h>
	#include <machine/interrupts.h>
	#include <drivers/dis7seg.h>
	#include "sdram.h"
	#include "svga.h"
	#include "test.h"
	
	#define DISP_BADDR    ((uint32_t)-288)
	static dis7seg_handle_t dispHandle;
	
	uint32_t sdramBytesAllocated;
	
	static volatile uint32_t *screenData;
#endif // __SPEAR32__

// prototypes
void outputImage(image_t *image);

void outputImage(image_t *image) {
	int x, y;
	
	printf("Image -> VGA.\n");
	
	// output image on touchscreen
	for (y=0; y<SCREEN_HEIGHT; y++) {
		for (x=0; x<SCREEN_WIDTH; x++) {
			if (x < image->width && y < image->height) {
				int pIndex;
				rgb_color_t color;
				pIndex = (y*image->width+x)*3;
				color.b = image->data[pIndex];
				color.g = image->data[pIndex+1];
				color.r = image->data[pIndex+2];
				screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
			}
			else {
				screenData[y*SCREEN_WIDTH+x] = 0;
			}
		}
	}
}

int main(int argc, char **argv)
{	
	#ifdef __SPEAR32__
	
	// initialize HW modules
	
	test_init();

	// 7-Seg Display
	dis7seg_initHandle(&dispHandle, DISP_BADDR, 8);
	dis7seg_displayHexUInt32(&dispHandle, 0, 0x42);
	
	// SDRAM initialization
	SDRAM_CFG = SDRAM_REFRESH_EN | 
	SDRAM_TRFC(2) | 
	SDRAM_BANKSIZE_128MB | 
	SDRAM_COLSIZE_1024 | 
	SDRAM_CMD_LOAD_CMD_REG | 389;
	
	// SVGA initialization (touchscreen)
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
	#endif
	
	#ifdef TEST
	{
		image_t image;
		test_receiveImage(&image, argv[1]);
		faceDetection(&image);
		outputImage(&image);
		test_sendImage(&image, argv[2]);
		freeImage(&image);
	}
	#else
		while (1) {
			// TODO:
			// get picture from camera
			//faceDetection();
			// outout result image on screen
		}  
	#endif
	
	#ifdef __SPEAR32__
	test_release();
	dis7seg_releaseHandle(&dispHandle);
	#endif
	
	return 0;
}
