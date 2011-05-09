#ifndef _image_h_
#define _image_h_

#include <stdint.h>

typedef struct {
	uint8_t r;
	uint8_t g;
	uint8_t b;
} rgb_color_t;

typedef struct {
	int32_t y;
	int32_t cb;
	int32_t cr;
} ycbcr_color_t;

typedef struct {
	uint32_t width;
	uint32_t height;
	uint32_t dataLength;
	unsigned char *data;
} image_t;

void initializeImage(image_t *template, image_t *image);
void freeImage(image_t *image);
rgb_color_t getRGBColorValue(image_t *i, int x, int y);
ycbcr_color_t getYCbCrColorValue(image_t *i, int x, int y);

#endif // _image_h_
