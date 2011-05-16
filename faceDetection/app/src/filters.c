#include "filters.h"
#include "dis7seg.h"

#define WINDOW_LENGTH 5
#define WINDOW_OFFSET ((WINDOW_LENGTH-1)/2)

#define Y_LOW    100000000
#define CB_LOW  -150000000
#define CR_LOW    50000000

#define Y_HIGH  1000000000
#define CB_HIGH   50000000
#define CR_HIGH  200000000

uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare);

void skinFilter(image_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			ycbcr_color_t ycbcr = convertToYCbCrColor(image_getPixelValue(inputImage, x, y));
			if (ycbcr.y >= Y_LOW && ycbcr.y <= Y_HIGH
				&& ycbcr.cb >= CB_LOW && ycbcr.cb <= CB_HIGH
				&& ycbcr.cr >= CR_LOW && ycbcr.cr <= CR_HIGH) {
				bwimage_setPixelValue(outputImage, x, y, color_white); 
			} else {
				bwimage_setPixelValue(outputImage, x, y, color_black);
			}
		}
	}
}

void dummyFilter(bwimage_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	uint8_t c;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			c = bwimage_getPixelValue(inputImage, x, y);
			bwimage_setPixelValue(outputImage, x, y, c); 
		}
	}
}

void erodeFilter(bwimage_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	uint8_t c;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			dis7seg_hex(0xE0000000 | y << 16 | x);
			
			// erode: look for neighbor pixels in background color
			if (findInWindow(inputImage, x, y, color_black))
				c = color_black;
			else
				c = color_white;
			bwimage_setPixelValue(outputImage, x, y, c);
		}
	}
}

void dilateFilter(bwimage_t *inputImage, bwimage_t *outputImage) {
	int x, y;
	uint8_t c;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			dis7seg_hex(0xD0000000 | y << 16 | x);
			
			// dilate: look for neighbor pixels in foreground color
			if (findInWindow(inputImage, x, y, color_white))
				c = color_white;
			else
				c = color_black;
			bwimage_setPixelValue(outputImage, x, y, c);
		}
	}
}

uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare) {
	int dx, dy, wx, wy;
	uint8_t c;
	uint8_t foundMatch = 0;
	
	for (dy = -WINDOW_OFFSET; dy <= WINDOW_OFFSET; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = -WINDOW_OFFSET; dx <= WINDOW_OFFSET; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					c = bwimage_getPixelValue(i, wx, wy);
					if (c == compare) {
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
