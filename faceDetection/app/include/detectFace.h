#ifndef _detectFace_h_
#define _detectFace_h_

#include "image.h"

typedef struct {
	int topLeftX;
	int topLeftY;
	int bottomRightX;
	int bottomRightY;
} rect_t;

void detectFace(image_t *faceMask, image_t *rawImage);

#endif // _detectFace_h_
