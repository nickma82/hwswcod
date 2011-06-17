#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "sdram.h"
#include "svga.h"
#include "image.h"
#include "test.h"

const uint8_t color_white = FOREGROUND_COLOR;
const uint8_t color_black = BACKGROUND_COLOR;

void bwimage_init(image_t *template, bwimage_t *image) {
	image->width = template->width/SCALE;
	image->height = template->height/SCALE;
}

void image_setPixelValue(image_t *i, int x, int y, rgb_color_t cl) {
	int pIndex = (y*i->width+x)*3;
	i->data[pIndex] = cl.b;
	i->data[pIndex+1] = cl.g;
	i->data[pIndex+2] = cl.r;
}

void image_paintRectangle(image_t *image, rect_t rectangle) {
	int i;
	rgb_color_t cl = {0,0xFF,0};
	
	rectangle.bottomRightX *= SCALE;
	rectangle.bottomRightY *= SCALE;
	rectangle.topLeftX *= SCALE;
	rectangle.topLeftY *= SCALE;
	
	// paint rectangle on original image
	// horizontal lines
	for (i = rectangle.topLeftX; i < rectangle.bottomRightX; i++) {
		image_setPixelValue(image, i, rectangle.topLeftY, cl);
		image_setPixelValue(image, i, rectangle.bottomRightY, cl);
	}
	// vertical lines
	for (i = rectangle.topLeftY; i < rectangle.bottomRightY; i++) {
		image_setPixelValue(image, rectangle.topLeftX, i, cl);
		image_setPixelValue(image, rectangle.bottomRightX, i, cl);
	}
}

void printFrameBuffer(const char *targetPath) {
	uint32_t x,y;
	rgb_color_t col;	
	image_t outImg;
	
	outImg.width = SCREEN_WIDTH;
	outImg.height = SCREEN_HEIGHT;
	outImg.dataLength = SCREEN_WIDTH*SCREEN_HEIGHT*3;
	outImg.data = (unsigned char *)(SDRAM_BASE+sdramBytesAllocated);
	
	sdramBytesAllocated += outImg.dataLength;
	
	
	for (y = 0; y < SCREEN_HEIGHT; y++) {
		for (x = 0; x < SCREEN_WIDTH; x++) {
			col.r = (uint8_t)((screenData[y*SCREEN_WIDTH+x] & 0x00FF0000)>>16);
			col.g = (uint8_t)((screenData[y*SCREEN_WIDTH+x] & 0x0000FF00)>>8);
			col.b = (uint8_t)(screenData[y*SCREEN_WIDTH+x] & 0x000000FF);
			image_setPixelValue(&outImg,x,y,col);
			//printf("(%3u,%2u): %8X \n",(unsigned int)x,(unsigned int)y,(unsigned int));
		}
	}	
	test_sendImage(&outImg, targetPath);
}
