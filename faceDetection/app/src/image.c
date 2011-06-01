#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "image.h"

const uint8_t color_white = FOREGROUND_COLOR;
const uint8_t color_black = BACKGROUND_COLOR;

void bwimage_init(image_t *template, bwimage_t *image) {
	image->width = template->width;
	image->height = template->height;
	image->fg_color_cnt = 0;
	image->dataLength = sizeof(*(image->data))*(template->dataLength / 3 + IMAGE_DATA_MAXVAL) >> IMAGE_DATA_BITS;
	image->data = (typeof(image->data))malloc(image->dataLength);
	memset((void *)image->data, 0, image->dataLength);
}

void bwimage_free(bwimage_t *image) {
	free(image->data);
}

inline uint8_t bwimage_getPixelValue(bwimage_t* image, int x, int y) {
	uint32_t p = image->width * y + x;
	uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
	p >>= IMAGE_DATA_BITS;
	return image->data[p] & pp ? color_white : color_black;
}

inline void bwimage_setPixelValue(bwimage_t* image, int x, int y, uint8_t color) {
	uint32_t p = image->width * y + x;
	uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
	p >>= IMAGE_DATA_BITS;
	if (image->data[p] & pp) {
		if (color == color_black) {
			image->data[p] &= ~pp; // mask pixel
			image->fg_color_cnt--;
		}
	} else {
		if (color == color_white) {
			image->data[p] |= pp; // set pixel
			image->fg_color_cnt++;
		}
	}
}


inline ycbcr_color_t convertToYCbCrColor(rgb_color_t cl) {
	ycbcr_color_t result;
	
	int32_t rf = (1000 * cl.r) >> 8;
	int32_t gf = (1000 * cl.g) >> 8;
	int32_t bf = (1000 * cl.b) >> 8;
	
	result.y = 299000 * rf + 587000 * gf + 114000 * bf;
	result.cb = -168736 * rf + -331264 * gf + 500000 * bf;
	result.cr = 500000 * rf + -418688 * gf + -81312 * bf;
	
	return result;
}

void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl) {
	int pIndex = (y*i->width+x)*3;
	i->data[pIndex] = cl.b;
	i->data[pIndex+1] = cl.g;
	i->data[pIndex+2] = cl.r;
}

void image_paintRectangle(image_t *image, rect_t rectangle) {
	int i;
	rgb_color_t cl = {0,0xFF,0};
	
	// paint rectangle on original image
	// horizontal lines
	for (i = rectangle.topLeftX; i < rectangle.bottomRightX; i++) {
		image_setPixelValue(image, i, rectangle.topLeftY, cl);
		image_setPixelValue(image, i, rectangle.bottomRightY, cl);
	}
	// vertical lines
	for (i = rectangle.topLeftY; i < rectangle.bottomRightY; i++) {
		image_setPixelValue(image, rectangle.topLeftX, i, cl);
		image_setPixelValue(image, rectangle.bottomRightX, i, cl);
	}
}
