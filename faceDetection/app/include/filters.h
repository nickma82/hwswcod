#ifndef _filters_h_
#define _filters_h_

#include "image.h"

#define FILTER_ERODE  0
#define FILTER_DILATE 1

void skinFilter(image_t *inputImage, bwimage_t *outputImage);
void erodeDilateFilter(bwimage_t *inputImage, bwimage_t *outputImage, uint8_t op);

#endif // _filters_h_
