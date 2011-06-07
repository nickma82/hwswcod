#include <string.h>
#include <stdio.h>
#include <machine/modules.h>
#include <machine/interrupts.h>

#include "sdram.h"
#include "svga.h"
#include "image.h"

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
	//memset((void *)screenData, 0, (SCREEN_WIDTH*SCREEN_HEIGHT*4));
}

void svga_outputImage(image_t *image) {
	int x, y;
	int pIndex;
	rgb_color_t color;
	
	// output image on touchscreen
	for (y = 0; y < SCREEN_HEIGHT; y++) {
		for (x = 0; x < SCREEN_WIDTH; x++) {
			if (x < image->width && y < image->height) {
				pIndex = (y*image->width+x)*3;
				color.b = image->data[pIndex];
				color.g = image->data[pIndex+1];
				color.r = image->data[pIndex+2];
			} else {
				color.b = 0;
				color.g = 0;
				color.r = 0;
			}
			screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
		}
	}
}

void svga_outputBwImage(bwimage_t *image) {
	int x, y;
	rgb_color_t color;
	
	// output image on touchscreen
	for (y = 0; y < SCREEN_HEIGHT; y++) {
		for (x = 0; x < SCREEN_WIDTH; x++) {
			color.b = 0;
			color.g = 0;
			color.r = 0;
			if (x < image->width && y < image->height && bwimage_getPixelValue(image, x, y) == color_white) {
				color.b = 0xFF;
				color.g = 0xFF;
				color.r = 0xFF;
			}
			screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
		}
	}
}

