#include <stdlib.h>
#include "image.h"
#include "sdram.h"

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
	
	int32_t rf = (1000 * c1.r) >> 8;
	int32_t gf = (1000 * c1.g) >> 8;
	int32_t bf = (1000 * c1.b) >> 8;
	
	result.y = 299000 * rf + 587000 * gf + 114000 * bf;
	result.cb = -168736 * rf + -331264 * gf + 500000 * bf;
	result.cr = 500000 * rf + -418688 * gf + -81312 * bf;
	
	return result;
}

void initializeImage(image_t *template, image_t *image)
{
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

void freeImage(image_t *image) 
{
	free(image->data);
}
