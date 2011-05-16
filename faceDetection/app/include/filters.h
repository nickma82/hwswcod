#ifndef _filters_h_
#define _filters_h_

#include "image.h"

void skinFilter(image_t *inputImage, bwimage_t *outputImage);
void erodeFilter(bwimage_t *inputImage, bwimage_t *outputImage);
void dilateFilter(bwimage_t *inputImage, bwimage_t *outputImage);
void dummyFilter(bwimage_t *inputImage, bwimage_t *outputImage);

#endif // _filters_h_
