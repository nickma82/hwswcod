#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "filters.h"
#include "aluext.h"
#include "dis7seg.h"
#include "test.h"
#include "svga.h"

#define WINDOW_LENGTH 3
#define WINDOW_OFFSET ((WINDOW_LENGTH-1)/2)

inline uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare);
inline void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y);

void skinFilter(image_t *inputImage, bwimage_t *outputImage) {
	int x, y;
		
	for (y = 0; y < inputImage->height; y+=SCALE) {
		for (x = 0; x < inputImage->width; x+=SCALE) {
			uint32_t p,pp;
			
			#ifdef TEST
				int pIndex = (inputImage->width * y + x)*3;
				//				red										green								blue
				ALUEXT_RGB = (inputImage->data[pIndex+2] << 16) | (inputImage->data[pIndex+1] << 8) | (inputImage->data[pIndex]);
			#else
			
/*				rgb_color_t c;
				c.r = (screenData[SCREEN_WIDTH * y + x] & 0x00ff00 ) >> 8;
				c.g = (screenData[SCREEN_WIDTH * y + x] & 0xff0000 ) >> 16;
				c.b = (screenData[SCREEN_WIDTH * y + x] & 0x0000ff );
				ALUEXT_RGB = (c.r << 16) | (c.g << 8) | (c.b);*/
				ALUEXT_RGB = screenData[SCREEN_WIDTH * y + x];
				//printf("%8X\n",(unsigned int)screenData[SCREEN_WIDTH * y + x]);
			#endif
			
			p = x >> SCALE_SHIFT;
			pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;
			
			if (ALUEXT_SKIN)
				outputImage->data[y >> SCALE_SHIFT][p] |= pp; // set pixel
		}
	}
}

void erodeFilter(bwimage_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	uint32_t p,pp;

	// erode: look for neighbor pixels in background color
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			p = x;
			pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;
			
			if (inputImage->data[y][p] & pp && !findInWindow(inputImage, x, y, color_black))
				outputImage->data[y][p] |= pp; // set pixel
		}
	}
}

void dilateFilter(bwimage_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	
	// init flag bitmap
	bwimage_t flags;
	flags.width = inputImage->width;
	flags.height = inputImage->height;
	memset((void *)flags.data, 0, sizeof(flags.data));
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			uint32_t p = x;
			uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;

			if (flags.data[y][p] & pp)
				continue;
			
			if (inputImage->data[y][p] & pp) {
				fillWindow(outputImage, &flags, x, y);
			} else {
				outputImage->data[y][p] &= ~pp; // mask pixel
				flags.data[y][p] |= pp; // set pixel flag
			}
		}
	}
}

inline uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare) {
	int dx, dy, wx, wy;
	uint8_t foundMatch = 0;
	
	for (dy = -WINDOW_OFFSET; dy <= WINDOW_OFFSET; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = -WINDOW_OFFSET; dx <= WINDOW_OFFSET; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					uint32_t p = wx;
					uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
					p >>= IMAGE_DATA_BITS;
					if ((i->data[wy][p] & pp ? color_white : color_black) == compare) {
						foundMatch = 1;
						break;
					}
				}
			}
		}
		if (foundMatch) {
			break;
		}
	}
	return foundMatch;
}

inline void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y) {
	int dx, dy, wx, wy;
	
	for (dy = 1-WINDOW_LENGTH; dy <= WINDOW_LENGTH-1; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = 1-WINDOW_LENGTH; dx <= WINDOW_LENGTH-1; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					uint32_t p = wx;
					uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
					p >>= IMAGE_DATA_BITS;
					
					i->data[wy][p] |= pp; // set pixel
					flags->data[wy][p] |= pp; // set pixel
				}
			}
		}
	}
}
