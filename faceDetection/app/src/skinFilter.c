#include "utils.h"
#include "filters.h"
#include "image.h"
#include <machine/modules.h>
#include <drivers/counter.h>

#define Y_LOW   0.10f
#define CB_LOW -0.15f
#define CR_LOW  0.05f

#define Y_HIGH  1.00f
#define CB_HIGH 0.05f
#define CR_HIGH 0.20f

extern module_handle_t counterHandle[COUNTER_COUNT];

void skinFilter(image_t *inputImage, image_t *outputImage)
{
	int x, y;
	for (y = 0; y < inputImage->height; ++y) {
		for (x = 0; x < inputImage->width; ++x) {
			
			counter_start(&counterHandle[6]);
			counter_start(&counterHandle[7]);
			ycbcr_color_t ycbcr = getYCbCrColorValue(inputImage, x, y);
			counter_stop(&counterHandle[7]);
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
			counter_stop(&counterHandle[6]);
		}
	}
}


