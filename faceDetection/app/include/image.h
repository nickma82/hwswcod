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

#define BACKGROUND_COLOR_R   0
#define BACKGROUND_COLOR_G   0
#define BACKGROUND_COLOR_B   0
#define FOREGROUND_COLOR_R   0xff
#define FOREGROUND_COLOR_G   0xff
#define FOREGROUND_COLOR_B   0xff

const rgb_color_t color_white = {FOREGROUND_COLOR_R,FOREGROUND_COLOR_G,FOREGROUND_COLOR_B}
const rgb_color_t color_black = {BACKGROUND_COLOR_R,BACKGROUND_COLOR_G,BACKGROUND_COLOR_B}

void image_init(image_t *template, image_t *image);
void image_free(image_t *image);
void image_paintRectangle(image_t *image, rect_t rectangle);
rgb_color_t image_getPixelValue(image_t *i, int x, int y);
void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl);
ycbcr_color_t convertToYCbCrColor(rgb_color_t cl);

#endif // _image_h_
