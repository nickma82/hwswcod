#ifndef _detectFace_h_
#define _detectFace_h_

#include "image.h"

typedef struct {
	int topLeftX;
	int topLeftY;
	int bottomRightX;
	int bottomRightY;
} rect_t;

rect_t faceDetection(image_t *inputImage);

#endif // _detectFace_h_
