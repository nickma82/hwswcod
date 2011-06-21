#ifndef __SVGA_H__
#define __SVGA_H__

#include "image.h"

#define SCREEN_WIDTH  800
#define SCREEN_HEIGHT 480

extern volatile uint32_t *screenData;

void svga_init(void);
void svga_outputBwImage(bwimage_t *image, uint32_t x_off, uint32_t y_off);

#ifdef TEST
	void svga_outputImage(image_t *image);
	void svga_paintRectangle(rect_t rectangle);
#endif // TEST

#endif // __SVGA_H__

