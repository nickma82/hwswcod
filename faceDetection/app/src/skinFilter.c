#include "utils.h"
#include "filters.h"
#include "image.h"
#include <machine/modules.h>
#include <drivers/counter.h>

#define Y_LOW   100000000
#define CB_LOW -150000000
#define CR_LOW   50000000

#define Y_HIGH  1000000000
#define CB_HIGH   50000000
#define CR_HIGH  200000000

void skinFilter(image_t *inputImage, image_t *outputImage)
{
	int x, y;
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			
			ycbcr_color_t ycbcr = getYCbCrColorValue(inputImage, x, y);
			int pIndex = (y*inputImage->width+x)*3;
			
			if (ycbcr.y >= Y_LOW && ycbcr.y <= Y_HIGH
				&& ycbcr.cb >= CB_LOW && ycbcr.cb <= CB_HIGH
				&& ycbcr.cr >= CR_LOW && ycbcr.cr <= CR_HIGH) {
				// set output pixel white
				outputImage->data[pIndex] = 0xFF;
				outputImage->data[pIndex+1] = 0xFF;
				outputImage->data[pIndex+2] = 0xFF;
			}
			else {
				// set output pixel black
				outputImage->data[pIndex] = 0x00;
				outputImage->data[pIndex+1] = 0x00;
				outputImage->data[pIndex+2] = 0x00;
			}
		}
	}
}


