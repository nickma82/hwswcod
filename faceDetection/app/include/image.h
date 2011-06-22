#ifndef _image_h_
#define _image_h_

#include <stdint.h>

#define IMAGE_WIDTH		640
#define IMAGE_HEIGHT	480

#define IMAGE_DATA_MAXVAL	31
#define IMAGE_DATA_BITS		5

#define SCALE_SHIFT 3
#define SCALE 8

typedef struct {
	uint16_t topLeftX;
	uint16_t topLeftY;
	uint16_t bottomRightX;
	uint16_t bottomRightY;
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
	uint32_t data[480][20];
} bwimage_t;

#define BACKGROUND_COLOR 0
#define FOREGROUND_COLOR 1

extern const uint8_t color_white;
extern const uint8_t color_black;

void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl);
void image_paintRectangle(image_t *image, rect_t rectangle);

void bwimage_init(image_t *template, bwimage_t *image);

#ifdef SENDIMG
	void sendFrameBuffer(const char *targetPath);
#endif

#endif // _image_h_

