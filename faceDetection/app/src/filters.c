#include "filters.h"
<<<<<<< HEAD
=======
#include "aluext.h"
>>>>>>> c4416e010c5619456cbd848016a6ee478555bcc2
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
<<<<<<< HEAD
			ycbcr_color_t ycbcr = convertToYCbCrColor(image_getPixelValue(inputImage, x, y));
			if (ycbcr.y >= Y_LOW && ycbcr.y <= Y_HIGH
				&& ycbcr.cb >= CB_LOW && ycbcr.cb <= CB_HIGH
				&& ycbcr.cr >= CR_LOW && ycbcr.cr <= CR_HIGH) {
=======
			rgb_color_t tmp = image_getPixelValue(inputImage, x, y);
			ALUEXT_RGB = (tmp.b << 16) | (tmp.g << 8) |  tmp.r;
			if (ALUEXT_SKIN) {
>>>>>>> c4416e010c5619456cbd848016a6ee478555bcc2
				bwimage_setPixelValue(outputImage, x, y, color_white); 
			} else {
				bwimage_setPixelValue(outputImage, x, y, color_black);
			}
		}
	}
}

void erodeDilateFilter(bwimage_t *inputImage, bwimage_t *outputImage, uint8_t op) {
	int x, y;
	uint8_t c;
	uint8_t c1 = op == FILTER_ERODE ? color_black : color_white;
	uint8_t c2 = op == FILTER_ERODE ? color_white : color_black;
	
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			// erode: look for neighbor pixels in background color
			c = c1;
			if (bwimage_getPixelValue(inputImage, x, y) == c2) {
				if (!findInWindow(inputImage, x, y, c1))
					c = c2;
			}
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
			/*for (dx = -WINDOW_OFFSET; dx <= WINDOW_OFFSET; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					c = bwimage_getPixelValue(i, wx, wy);
					if (c == compare) {
						foundMatch = 1;
						break;
					}
				}
			}*/
			c = bwimage_getPixelValue(i, x, wy);
			if (c == compare) {
				foundMatch = 1;
				break;
			}
		}
		/*if (foundMatch) {
			break;
		}*/
	}
	return foundMatch;
}
