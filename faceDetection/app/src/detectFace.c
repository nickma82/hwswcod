#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "detectFace.h"
#include "filters.h"
#include "test.h"
#include "getframe.h"
#include "svga.h"

#define STEP_SIZE 10

int getIndexBelowThreshold(int *hist, int histLen, int start, int step, int threshold);
rect_t detectFace(bwimage_t *faceMask);

rect_t faceDetection(image_t* inputImage, bwimage_t* temp, bwimage_t* temp2) {
	rect_t face;
	
	// perform face detection
	skinFilter(inputImage, temp);
	
	// nächste frame von der kamera holen
	#ifndef TEST
		GETFRAME_START = 1;
	#endif
	
	erodeFilter(temp, temp2);
	dilateFilter(temp2, temp);
	face = detectFace(temp);
	
	face.bottomRightX *= SCALE;
	face.bottomRightY *= SCALE;
	face.topLeftX *= SCALE;
	face.topLeftY *= SCALE;
	
	return face;
}

rect_t detectFace(bwimage_t *faceMask)
{
	int i, j, x, y;
	int width, height;
	int maxHistX, maxHistY;
	int faceX, faceY;
	
	int *histX;
	int *histY;
	int histXLen, histYLen;
	int *aboveThresholdX;
	int *aboveThresholdY;
	int aboveThresholdXLen;
	int aboveThresholdYLen;
	
	rect_t resultRect = {0, 0, 0, 0};
	int maxArea;
	
	// compute histogramm
	histXLen = faceMask->width;
	histYLen = faceMask->height;
	histX = (int *)malloc(histXLen*sizeof(int));
	histY = (int *)malloc(histYLen*sizeof(int));
	
	memset(histX, 0, faceMask->width*sizeof(int));
	memset(histY, 0, faceMask->height*sizeof(int));
	
	for (y = 0; y < faceMask->height; y++) {
		for (x = 0; x < faceMask->width; x++) {
			uint32_t p = x;
			uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;	
			if (faceMask->data[y][p] & pp) {
				histX[x]++;
				histY[y]++;
			}
		}
	}
	
	// find maximum histgram value and related xy-coordinate
	maxHistX = 0;
	for (i = 0; i < faceMask->width; i++) {
		if (histX[i] > maxHistX) {
			maxHistX = histX[i];
			faceX = i;
		}
	}
	maxHistY = 0;
	for (i = 0; i < faceMask->height; i++) {
		if (histY[i] > maxHistY) {
			maxHistY = histY[i];
			faceY = i;
		}
	}
	
	// select coordinates where histogram value is above half 
	// of max hist value
	aboveThresholdX = (int *)malloc(histXLen*sizeof(int));
	aboveThresholdY = (int *)malloc(histYLen*sizeof(int));
	j = 0;
	for (i=0; i < histXLen; i+=STEP_SIZE) {
		if (histX[i] > maxHistX/2) {
			aboveThresholdX[j] = i;
			j++;
		}
	}
	aboveThresholdXLen = j;
	
	j = 0;
	for (i=0; i < histYLen; i+=STEP_SIZE) {
		if (histY[i] > maxHistY/2) {
			aboveThresholdY[j] = i;
			j++;
		}
	}
	aboveThresholdYLen = j;
	
	// compute candidate face regions and pick the
	// one with the largest area
	maxArea=0;
	for (i=0; i<aboveThresholdYLen; i++) {
		for (j=0; j<aboveThresholdXLen; j++) {
			rect_t r;
			int area;      
			
			r.topLeftX = getIndexBelowThreshold(histX, histXLen, aboveThresholdX[j], -1, maxHistX/6);
			r.bottomRightX = getIndexBelowThreshold(histX, histXLen, aboveThresholdX[j], 1, maxHistX/6);
			r.topLeftY = getIndexBelowThreshold(histY, histYLen, aboveThresholdY[i], -1, maxHistY/9);
			r.bottomRightY = getIndexBelowThreshold(histY, histYLen, aboveThresholdY[i], 1, maxHistY/9);
			
			width = r.bottomRightX-r.topLeftX;
			height = r.bottomRightY-r.topLeftY;
			area = width*height;
			
			if (area > maxArea) {
				resultRect = r;	
				maxArea = area;
			}
		}
	}
	
	free(aboveThresholdX);
	free(aboveThresholdY);
	free(histX);
	free(histY);
	
	if (maxArea > 0) {
		// adjust face proportions, assume upright faces
		// typical face proportions: width:height = 2:3
		width = resultRect.bottomRightX-resultRect.topLeftX;
		height = resultRect.bottomRightY-resultRect.topLeftY;
		if (width < height) {
			width = (3*width) >> 1;
			if (width < height) {
				resultRect.bottomRightY = resultRect.topLeftY + width;
			}
		} else {
			resultRect.bottomRightX = resultRect.topLeftX + height;
		}
		//printf("Selected rect: topLeft=(%d, %d), bottomRight=(%d, %d)\n", resultRect.topLeftX, resultRect.topLeftY, resultRect.bottomRightX, resultRect.bottomRightY);
	}
	
	return resultRect;
}

int getIndexBelowThreshold(int *hist, int histLen, int start, int step, int threshold) {
	int i;
	int result = start;
	for (i=start; i>0 && i<histLen; i+=step) {
		if (hist[i] < threshold) {
			result = i;
			break;
		}
	}
	
	return result;
}
