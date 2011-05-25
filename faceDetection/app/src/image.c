#include <stdlib.h>
#include <stdio.h>

#include "image.h"

const uint8_t color_white = FOREGROUND_COLOR;
const uint8_t color_black = BACKGROUND_COLOR;

void bwimage_init(image_t *template, bwimage_t *image) {
	image->width = template->width;
	image->height = template->height;
	image->dataLength = sizeof(*(image->data))*(template->dataLength / 3 + 31) >> 5;
	image->data = (typeof(image->data))malloc(image->dataLength);
	// Print memory addresses
	/*printf("Template: %ux%u, %u; Bw: %X, %u\n",
		(unsigned int)image->width, (unsigned int)image->height,
		(unsigned int)template->dataLength, (unsigned int)image->data,
		(unsigned int)image->dataLength); */
}

void bwimage_free(bwimage_t *image) {
	free(image->data);
}

uint8_t bwimage_getPixelValue(bwimage_t* image, int x, int y) {
	uint32_t p = image->width * y + x;
	uint8_t pp = (31 - (p & 31)); // pixelposition
	typeof(image->data) b = &image->data[p >> 5];
	p = (typeof(*b))1 << pp;
	return *b & p ? color_white : color_black;
}

void bwimage_setPixelValue(bwimage_t* image, int x, int y, uint8_t color) {
	uint32_t p = image->width * y + x;
	uint8_t pp = (31 - (p & 31)); // pixelposition
	uint32_t i = p >> 5;
	typeof(image->data) b = &image->data[i];
	//printf("%.4X,%d\n",(unsigned)b,(int)i);
	*b &= ~(1 << pp); // mask pixel
	if (color == color_white)
		*b |= (1 << pp); // set color
}


ycbcr_color_t convertToYCbCrColor(rgb_color_t cl) {
	ycbcr_color_t result;
	
	int32_t rf = (1000 * cl.r) >> 8;
	int32_t gf = (1000 * cl.g) >> 8;
	int32_t bf = (1000 * cl.b) >> 8;
	
	result.y = 299000 * rf + 587000 * gf + 114000 * bf;
	result.cb = -168736 * rf + -331264 * gf + 500000 * bf;
	result.cr = 500000 * rf + -418688 * gf + -81312 * bf;
	
	return result;
}

rgb_color_t image_getPixelValue(image_t *i, int x, int y) {
	rgb_color_t result;
	int pIndex = (y*i->width+x)*3;
	result.b = i->data[pIndex];
	result.g = i->data[pIndex+1];
	result.r = i->data[pIndex+2];
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
