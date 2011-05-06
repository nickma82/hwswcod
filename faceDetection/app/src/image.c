#include "image.h"

rgb_color_t getRGBColorValue(image_t *i, int x, int y)
{
	rgb_color_t result;
	int pIndex = (y*i->width+x)*3;
	result.b = i->data[pIndex];
	result.g = i->data[pIndex+1];
	result.r = i->data[pIndex+2];
	return result;
}

ycbcr_color_t getYCbCrColorValue(image_t *i, int x, int y)
{  
	rgb_color_t c1 = getRGBColorValue(i, x, y);
	ycbcr_color_t result;
	
	uint32_t rf = (1000 * c1.r) >> 8;
	uint32_t gf = (1000 * c1.g) >> 8;
	uint32_t bf = (1000 * c1.b) >> 8;
	
	result.y = 299000 * rf + 587000 * gf + 114000 * bf;
	result.cb = -168736 * rf + -331264 * gf + 500000 * bf;
	result.cr = 500000 * rf + -418688 * gf + -81312 * bf;
	
	return result;
}
