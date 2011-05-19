#ifndef _image_h_
#define _image_h_

#include <stdint.h>

typedef struct {
	int topLeftX;
	int topLeftY;
	int bottomRightX;
	int bottomRightY;
} rect_t;

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

typedef struct {
	uint32_t width;
	uint32_t height;
	uint32_t dataLength;
	uint32_t *data;
} bwimage_t;

#define BACKGROUND_COLOR 0
#define FOREGROUND_COLOR 1

extern const uint8_t color_white;
extern const uint8_t color_black;

rgb_color_t image_getPixelValue(image_t *i, int x, int y);
void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl);
void image_paintRectangle(image_t *image, rect_t rectangle);

void bwimage_init(image_t *template, bwimage_t *image);
void bwimage_free(bwimage_t *image);
uint8_t bwimage_getPixelValue(bwimage_t *i, int x, int y);
void bwimage_setPixelValue(bwimage_t *i, int x, int y, uint8_t cl);

ycbcr_color_t convertToYCbCrColor(rgb_color_t cl);

#endif // _image_h_
