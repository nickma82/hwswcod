#ifndef _image_h_
#define _image_h_

#include <stdint.h>

#define IMAGE_DATA_MAXVAL	31
#define IMAGE_DATA_BITS		5

#define SCALE_SHIFT 3
#define SCALE 8

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
	uint16_t width;
	uint16_t height;
	uint32_t dataLength;
	unsigned char *data;
} image_t;

typedef struct {
	uint16_t width;
	uint16_t height;
	uint32_t fg_color_cnt;
	uint32_t dataLength;
	uint32_t *data;
} bwimage_t;

#define BACKGROUND_COLOR 0
#define FOREGROUND_COLOR 1

extern const uint8_t color_white;
extern const uint8_t color_black;

void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl);
void image_paintRectangle(image_t *image, rect_t rectangle);

void bwimage_init(image_t *template, bwimage_t *image);
void bwimage_free(bwimage_t *image);

void printFrameBuffer(const char *targetPath);

inline uint8_t bwimage_getPixelValue(bwimage_t *i, int x, int y) __attribute__((always_inline));

#endif // _image_h_
