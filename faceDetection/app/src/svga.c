#include <string.h>
#include <stdio.h>
#include <machine/modules.h>
#include <machine/interrupts.h>

#include "sdram.h"
#include "svga.h"
#include "image.h"

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

#ifdef TEST
	void svga_paintRectangle(rect_t rectangle) {
		int i;
		uint32_t cl = 0x0000FF00;
	
		// paint rectangle on original image
		// horizontal lines
		int y1 = rectangle.topLeftY*SCREEN_WIDTH;
		int y2 = rectangle.bottomRightY*SCREEN_WIDTH;
		for (i = rectangle.topLeftX; i < rectangle.bottomRightX; i++) {
			screenData[y1+i] = screenData[y2+i] = cl;
		}
		// vertical lines
		for (i = rectangle.topLeftY; i < rectangle.bottomRightY; i++) {
			screenData[i*SCREEN_WIDTH + rectangle.topLeftX] = cl;
			screenData[i*SCREEN_WIDTH + rectangle.bottomRightX] = cl;
		}
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
					color.b = 0xff;
					color.g = 0;
					color.r = 0xff;
				}
				screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
			}
		}
	}
#endif // TEST

void svga_outputBwImage(bwimage_t *image,uint32_t x_off,uint32_t y_off) {
	int x, y;
	rgb_color_t color;
	uint32_t p,pp;

	// output image on touchscreen
	for (y = 0; y < image->height; y++) {
		for (x = 0; x < image->width; x++) {
			p = x;
			pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;

			color.b = 0;
			color.g = 0;
			color.r = 0;
			if (image->data[y][p] & pp) {
				color.b = 0xFF;
				color.g = 0xFF;
				color.r = 0xFF;
			}
			screenData[(y+y_off)*SCREEN_WIDTH+(x+x_off)] = (color.r << 16) | (color.g << 8) | color.b;
		}
	}
}

