#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "filters.h"
#include "aluext.h"
#include "dis7seg.h"
#include "test.h"

#define WINDOW_LENGTH 3
#define WINDOW_OFFSET ((WINDOW_LENGTH-1)/2)

extern int *histX;
extern int *histY;

inline uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare);
inline void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y, uint8_t color);

void skinFilter(image_t *inputImage, bwimage_t *outputImage) {
	int x, y;
		
	for (y = 0; y < inputImage->height; y+=SCALE) {
		for (x = 0; x < inputImage->width; x+=SCALE) {
			int pIndex;
			uint32_t p,pp;
			
			pIndex = (inputImage->width * y + x)*3;
			ALUEXT_RGB = (inputImage->data[pIndex] << 16) | (inputImage->data[pIndex+1] << 8) | inputImage->data[pIndex+2];
			
			p = outputImage->width * (y >> SCALE_SHIFT) + (x >> SCALE_SHIFT);
			pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
			p >>= IMAGE_DATA_BITS;
			
			if (ALUEXT_SKIN) {
					outputImage->data[p] |= pp; // set pixel
					outputImage->fg_color_cnt++;
			}
		}
	}
}

void erodeDilateFilter(bwimage_t *inputImage, bwimage_t *outputImage, uint8_t op) {
	int x, y;
	uint8_t c;
	uint8_t c1 = op == FILTER_ERODE ? color_black : color_white;
	uint8_t c2 = op == FILTER_ERODE ? color_white : color_black;
	uint32_t thres = (inputImage->width*inputImage->height) >> 1;
	
	if ((op == FILTER_ERODE && inputImage->fg_color_cnt < thres) || (op == FILTER_DILATE && inputImage->fg_color_cnt > thres)) {
		// erode: look for neighbor pixels in background color
		// dilate: look for neighbor pixels in foreground color
		for (y = 0; y < inputImage->height; ++y) {
			for (x = 0; x < inputImage->width; ++x) {
				uint32_t p = inputImage->width * y + x;
				uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
				p >>= IMAGE_DATA_BITS;
				
				c = c1;
				if ((inputImage->data[p] & pp ? color_white : color_black) == c2) {
					if (!findInWindow(inputImage, x, y, c1))
						c = c2;
				}
				
				if (outputImage->data[p] & pp) {
					if (c == color_black) {
						outputImage->data[p] &= ~pp; // mask pixel
						outputImage->fg_color_cnt--;
					}
				} else {
					if (c == color_white) {
						outputImage->data[p] |= pp; // set pixel
						outputImage->fg_color_cnt++;
					}
				}
				
				if (outputImage->data[p] & pp) {
					histX[x]++;
					histY[y]++;
				}
			}
		}
	} else {
		bwimage_t flags;
		flags.width = inputImage->width;
		flags.height = inputImage->height;
		flags.fg_color_cnt = 0;
		flags.dataLength = inputImage->dataLength;
		flags.data = (typeof(flags.data))malloc(flags.dataLength);
		memset((void *)flags.data, 0, flags.dataLength);
		
		for (y = 0; y < inputImage->height; ++y) {
			for (x = 0; x < inputImage->width; ++x) {
				uint32_t p = inputImage->width * y + x;
				uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
				p >>= IMAGE_DATA_BITS;
				c = flags.data[p] & pp ? color_white : color_black;
				if (c == color_white)
					continue;
				
				c = inputImage->data[p] & pp ? color_white : color_black;
				if (c == c2) {
					if (outputImage->data[p] & pp) {
						if (c2 == color_black) {
							outputImage->data[p] &= ~pp; // mask pixel
							outputImage->fg_color_cnt--;
						}
					} else {
						if (c2 == color_white) {
							outputImage->data[p] |= pp; // set pixel
							outputImage->fg_color_cnt++;
						}
					}
					
					if (outputImage->data[p] & pp) {
						histX[x]++;
						histY[y]++;
					}
					
					if (!(flags.data[p] & pp)) {
						flags.data[p] |= pp; // set pixel
						flags.fg_color_cnt++;
					}
				} else {
					fillWindow(outputImage, &flags, x, y, c1);
				}				
			}
		}
		bwimage_free(&flags);
	}
}

inline uint8_t findInWindow(bwimage_t *i, int x, int y, uint8_t compare) {
	int dx, dy, wx, wy;
	uint8_t foundMatch = 0;
	
	for (dy = -WINDOW_OFFSET; dy <= WINDOW_OFFSET; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = -WINDOW_OFFSET; dx <= WINDOW_OFFSET; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					uint32_t p = i->width * wy + wx;
					uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
					p >>= IMAGE_DATA_BITS;
					if ((i->data[p] & pp ? color_white : color_black) == compare) {
						foundMatch = 1;
						break;
					}
				}
			}
		}
		if (foundMatch) {
			break;
		}
	}
	return foundMatch;
}

inline void fillWindow(bwimage_t *i, bwimage_t *flags, int x, int y, uint8_t color) {
	int dx, dy, wx, wy;
	
	for (dy = 1-WINDOW_LENGTH; dy <= WINDOW_LENGTH-1; ++dy) {
		wy = y+dy;
		if (wy >= 0 && wy < i->height) {
			for (dx = 1-WINDOW_LENGTH; dx <= WINDOW_LENGTH-1; ++dx) {
				wx = x+dx;
				if (wx >= 0 && wx < i->width) {
					uint32_t p = flags->width * wy + wx;
					uint32_t pp = 1 << (IMAGE_DATA_MAXVAL - (p & IMAGE_DATA_MAXVAL)); // pixelposition
					p >>= IMAGE_DATA_BITS;
					
					if (i->data[p] & pp) {
						if (color == color_black) {
							i->data[p] &= ~pp; // mask pixel
							i->fg_color_cnt--;
						}
					} else {
						if (color == color_white) {
							i->data[p] |= pp; // set pixel
							i->fg_color_cnt++;
						}
					}
					
					if (i->data[p] & pp) {
						histX[wx]++;
						histY[wy]++;
					}
					
					if (!(flags->data[p] & pp)) {
						flags->data[p] |= pp; // set pixel
						flags->fg_color_cnt++;
					}
				}
			}
		}
	}
}
