#include "filters.h"
#include "aluext.h"

#define WINDOW_LENGTH 5
#define WINDOW_OFFSET ((WINDOW_LENGTH-1)/2)

#define Y_LOW    100000000
#define CB_LOW  -150000000
#define CR_LOW    50000000

#define Y_HIGH  1000000000
#define CB_HIGH   50000000
#define CR_HIGH  200000000

uint8_t findInWindow(image_t *i, int x, int y, rgb_color_t compare);

void skinFilter(image_t *inputImage, image_t *outputImage) {
	int x, y;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			/*ycbcr_color_t ycbcr = convertToYCbCrColor(image_getPixelValue(inputImage, x, y));
			if (ycbcr.y >= Y_LOW && ycbcr.y <= Y_HIGH
				&& ycbcr.cb >= CB_LOW && ycbcr.cb <= CB_HIGH
				&& ycbcr.cr >= CR_LOW && ycbcr.cr <= CR_HIGH) {
				image_setPixelValue(outputImage, x, y, color_white); 
			} else {
				image_setPixelValue(outputImage, x, y, color_black);
			}*/
			ALUEXT_RGB = 0;//(uint32_t)image_getPixelValue(inputImage, x, y);
			if (ALUEXT_SKIN) {
				image_setPixelValue(outputImage, x, y, color_white); 
			} else {
				image_setPixelValue(outputImage, x, y, color_black);
			}
		}
	}
}

void erodeDilateFilter(image_t *inputImage, image_t *outputImage, uint8_t op)
{// TODO: Split in two functions for seperate optimization.
	int x, y;
	rgb_color_t c, compare;
	
	// erode: look for neighbor pixels in background color
	// dilate: look for neighbor pixels in foreground color
	compare = op == FILTER_ERODE ? color_black : color_white;  
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			c = color_black;
			if (findInWindow(inputImage, x, y, compare)) {
				if (op == FILTER_DILATE)
					c = color_white;
			} else {
				if (op == FILTER_ERODE)
					c = color_white;
			}
			image_setPixelValue(outputImage, x, y, c);
		}
	}
}

uint8_t findInWindow(image_t *i, int x, int y, rgb_color_t compare) {
	int dx, dy, wx, wy;
	rgb_color_t c;
	uint8_t foundMatch = 0;
	
	for (dy = -WINDOW_OFFSET; dy <= WINDOW_OFFSET; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = -WINDOW_OFFSET; dx <= WINDOW_OFFSET; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					c = image_getPixelValue(i, wx, wy);
					if (c.r == compare.r && c.g == compare.g && c.b == compare.b) {
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
