#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "filters.h"
#include "dis7seg.h"
#include "test.h"

#define WINDOW_LENGTH 5
#define WINDOW_OFFSET ((WINDOW_LENGTH-1)/2)

#define Y_LOW    100000000
#define CB_LOW  -150000000
#define CR_LOW    50000000

#define Y_HIGH  1000000000
#define CB_HIGH   50000000
#define CR_HIGH  200000000

uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare);
void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y, uint8_t color);

void skinFilter(image_t *inputImage, bwimage_t *outputImage) {
	int x, y;
		
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			rgb_color_t result;
			int pIndex;
			ycbcr_color_t ycbcr;
			uint32_t p,pp;
			
			p = outputImage->width * y + x;
			pIndex = p*3;
			result.b = inputImage->data[pIndex];
			result.g = inputImage->data[pIndex+1];
			result.r = inputImage->data[pIndex+2];
			
			ycbcr = convertToYCbCrColor(result);
			
			pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;
			
			if (ycbcr.y >= Y_LOW && ycbcr.y <= Y_HIGH
				&& ycbcr.cb >= CB_LOW && ycbcr.cb <= CB_HIGH
				&& ycbcr.cr >= CR_LOW && ycbcr.cr <= CR_HIGH) {
					outputImage->data[p] |= pp; // set pixel
					outputImage->fg_color_cnt++;
			}
		}
	}
}

void erodeDilateFilter(bwimage_t *inputImage, bwimage_t *outputImage, uint8_t op) {
	int x, y;
	uint8_t c;
	uint8_t c1 = op == FILTER_ERODE ? color_black : color_white;
	uint8_t c2 = op == FILTER_ERODE ? color_white : color_black;
	uint32_t thres = (inputImage->width*inputImage->height) >> 1;
	
	if ((op == FILTER_ERODE && inputImage->fg_color_cnt < thres) || (op == FILTER_DILATE && inputImage->fg_color_cnt > thres)) {
		// erode: look for neighbor pixels in background color
		// dilate: look for neighbor pixels in foreground color
		for (y = 0; y < inputImage->height; ++y) {
			for (x = 0; x < inputImage->width; ++x) {
				c = c1;
				if (bwimage_getPixelValue(inputImage, x, y) == c2) {
					if (!findInWindow(inputImage, x, y, c1))
						c = c2;
				}
				bwimage_setPixelValue(outputImage, x, y, c);
			}
		}
	} else {
		bwimage_t flags;
		flags.width = inputImage->width;
		flags.height = inputImage->height;
		flags.fg_color_cnt = 0;
		flags.dataLength = inputImage->dataLength;
		flags.data = (typeof(flags.data))malloc(flags.dataLength);
		memset((void *)flags.data, 0, flags.dataLength);
		
		for (y = 0; y < inputImage->height; ++y) {
			for (x = 0; x < inputImage->width; ++x) {
				if (bwimage_getPixelValue(&flags, x, y) == color_white)
					continue;
				
				if (bwimage_getPixelValue(inputImage, x, y) == c2) {
					bwimage_setPixelValue(outputImage, x, y, c2);
					bwimage_setPixelValue(&flags, x, y, color_white);
				} else {
					fillWindow(outputImage, &flags, x, y, c1);
				}				
			}
		}
		bwimage_free(&flags);
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

void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y, uint8_t color) {
	int dx, dy, wx, wy;
	
	for (dy = 1-WINDOW_LENGTH; dy <= WINDOW_LENGTH-1; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = 1-WINDOW_LENGTH; dx <= WINDOW_LENGTH-1; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					bwimage_setPixelValue(i, wx, wy, color);
					bwimage_setPixelValue(flags, wx, wy, color_white);
				}
			}
		}
	}
}
