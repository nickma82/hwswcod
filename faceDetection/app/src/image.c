#include <stdlib.h>
#include "image.h"
#include "sdram.h"

void image_init(image_t *template, image_t *image) {
	image->width = template->width;
	image->height = template->height;
	image->dataLength = template->dataLength;
	#ifdef __SPEAR32__
		// allocate memory in external SDRAM
		image->data = (unsigned char *)(SDRAM_BASE+sdramBytesAllocated);
		sdramBytesAllocated += template->dataLength;
	#else
		// allocate memory on heap
		image->data = (unsigned char *)malloc(template->dataLength);    
	#endif
}

void image_free(image_t *image) {
	free(image->data);
	#ifdef __SPEAR32__
		sdramBytesAllocated -= template->dataLength;
	#endif
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

ycbcr_color_t convertToYCbCrColor(rgb_color_t cl) {
	ycbcr_color_t result;
	
	int32_t rf = (1000 * c1.r) >> 8;
	int32_t gf = (1000 * c1.g) >> 8;
	int32_t bf = (1000 * c1.b) >> 8;
	
	result.y = 299000 * rf + 587000 * gf + 114000 * bf;
	result.cb = -168736 * rf + -331264 * gf + 500000 * bf;
	result.cr = 500000 * rf + -418688 * gf + -81312 * bf;
	
	return result;
}

void image_paintRectangle(image_t *image, rect_t rectangle) {
	int i;
	rbg_color_t cl = {0,FOREGROUND_COLOR_G,0};
	
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
