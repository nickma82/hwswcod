#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "image.h"

const uint8_t color_white = FOREGROUND_COLOR;
const uint8_t color_black = BACKGROUND_COLOR;

void bwimage_init(image_t *template, bwimage_t *image) {
	image->width = template->width/SCALE;
	image->height = template->height/SCALE;
	//image->fg_color_cnt = 0;
	image->dataLength = sizeof(*(image->data))*(template->dataLength / (3*SCALE*SCALE) + IMAGE_DATA_MAXVAL) >> IMAGE_DATA_BITS;
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

void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl) {
	int pIndex = (y*i->width+x)*3;
	i->data[pIndex] = cl.b;
	i->data[pIndex+1] = cl.g;
	i->data[pIndex+2] = cl.r;
}

void image_paintRectangle(image_t *image, rect_t rectangle) {
	int i;
	rgb_color_t cl = {0,0xFF,0};
	
	rectangle.bottomRightX *= SCALE;
	rectangle.bottomRightY *= SCALE;
	rectangle.topLeftX *= SCALE;
	rectangle.topLeftY *= SCALE;
	
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
