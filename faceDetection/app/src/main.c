#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "utils.h"
#include "image.h"
#include "filters.h"
#include "detectFace.h"


#ifdef __SPEAR32__
#include "sdram.h"
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <drivers/dis7seg.h>
#include <drivers/counter.h>
#include "svga.h"

#define COUNTER_BADDR ((uint32_t)-320)
#define DISP_BADDR    ((uint32_t)-288)

static uint32_t sdramBytesAllocated;

static dis7seg_handle_t dispHandle;
static volatile uint32_t *screenData;

#define COUNTER_COUNT 5
static uint32_t counterValues[COUNTER_COUNT];
static module_handle_t counterHandle;
static unsigned short counterSize = 0;

#define benchmark_messure(callable) \
	do { \
	counter_start(&counterHandle); \
	callable; \
	counter_stop(&counterHandle); \
	if (counterSize < COUNTER_COUNT) { \
		counterValues[counterSize] = counter_getValue(&counterHandle); \
		counterSize++; \
	} \
	} while (0)

#endif

// prototypes
void test_receiveImage(image_t *inputImage, const char *sourcePath);
void test_sendImage(image_t *inputImage, const char *targetPath);
void faceDetection(image_t *inputImage);
void outputImage(image_t *image);

void initializeImage(image_t *template, image_t *image);
void freeImage(image_t *image);


void initializeImage(image_t *template, image_t *image)
{
	image->width = template->width;
	image->height = template->height;
	image->dataLength = template->dataLength;
	#ifdef __SPEAR32__
		// allocate memory in external SDRAM
		image->data = (unsigned char *)(SDRAM_BASE+sdramBytesAllocated);
		sdramBytesAllocated += template->dataLength;
	#else
		// allocate memory on heap
		image->data = (unsigned char *)malloc(template->dataLength);    
	#endif
}

void freeImage(image_t *image) 
{
	free(image->data);
}

int main(int argc, char **argv)
{	
	#ifdef __SPEAR32__
	UART_Cfg cfg;
	int i;
	
	// initialize HW modules
	
	// Cycle counter
	for(i = 0; i < COUNTER_COUNT; i++)
		counterValues[i] = 0;
	
	counter_initHandle(&counterHandle, COUNTER_BADDR);
	counter_setPrescaler(&counterHandle, 3);


	// UART
	cfg.fclk = 50000000;
	cfg.baud = UART_CFG_BAUD_115200;
	cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
	cfg.frame.parity = UART_CFG_PARITY_EVEN;
	cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
	UART_init (cfg);
	
	// 7-Seg Display
	dis7seg_initHandle(&dispHandle, DISP_BADDR, 8);
	dis7seg_displayHexUInt32(&dispHandle, 0, 0x42);
	
	// SDRAM initialization
	SDRAM_CFG = SDRAM_REFRESH_EN | 
	SDRAM_TRFC(2) | 
	SDRAM_BANKSIZE_128MB | 
	SDRAM_COLSIZE_1024 | 
	SDRAM_CMD_LOAD_CMD_REG | 389;
	
	// SVGA initialization (touchscreen)
	SVGA_VIDEO_LENGTH = ((SCREEN_HEIGHT-1)<<16) | (SCREEN_WIDTH-1);
	SVGA_FRONT_PORCH = (10<<16) | 40;
	SVGA_SYNC_LENGTH = (1<<16) | 1;
	SVGA_LINE_LENGTH = (526<<16) | 1056;
	SVGA_FRAME_BUFFER = SDRAM_BASE;
	SVGA_DYN_CLOCK0 = 30000;
	SVGA_STATUS = (1<<0) | (3<<4);
	sdramBytesAllocated += SCREEN_WIDTH*SCREEN_HEIGHT*4;
	screenData = (volatile uint32_t *)SDRAM_BASE;
	memset((void *)screenData, 0, (SCREEN_WIDTH*SCREEN_HEIGHT*4));
	#endif
	
	#ifdef TEST
	{
		image_t image;
		test_receiveImage(&image, argv[1]);
		faceDetection(&image);
		test_sendImage(&image, argv[2]);
	}
	#else
		while (1) {
			// TODO:
			// get picture from camera
			//faceDetection();
			// outout result image on screen
		}  
	#endif
	
	
	#ifdef __SPEAR32__
	counter_releaseHandle(&counterHandle);
	dis7seg_releaseHandle(&dispHandle);
	#endif
	
	return 0;
}

void test_receiveImage(image_t *inputImage, const char *sourcePath) {
	uint32_t imageLen;
	char tgaHeader[18];
	
	#ifndef __SPEAR32__
		FILE *f = fopen(sourcePath, "r");
		if (!f) {
			printf("Image file <%s> not found\n", sourcePath);
			exit(1);
		}
		fseek(f, 0, SEEK_END);
		imageLen = ftell(f);
		fseek(f, 0, SEEK_SET);
		
		fread(tgaHeader, 1, sizeof(tgaHeader), f);
	#else
		UART_read(0, (char *)&imageLen, sizeof(imageLen));
		
		// read header
		UART_read(0, (char *)tgaHeader, sizeof(tgaHeader));
	#endif
	
	inputImage->width = (tgaHeader[13] << 8) | (tgaHeader[12] & 0xFF);
	inputImage->height = (tgaHeader[15] << 8) | (tgaHeader[14] & 0xFF);
	inputImage->dataLength = imageLen - sizeof(tgaHeader);
	
	#ifndef __SPEAR32__
		// allocate memory on heap
		inputImage->data = (unsigned char *)malloc(inputImage->dataLength);    
		fread(inputImage->data, 1, inputImage->dataLength, f);
		fclose(f);
	#else
		// allocate memory in external SDRAM
		inputImage->data = (unsigned char *)(SDRAM_BASE+sdramBytesAllocated);
		sdramBytesAllocated += inputImage->dataLength;
		
		// read image data
		UART_read(0, (char *)inputImage->data, inputImage->dataLength);
		
		printf("TEST: Image received.\n\n");
	#endif
}

void test_sendImage(image_t *inputImage, const char *targetPath) {
	uint32_t imageLen;
	char tgaHeader[18];
	int i;
	
	memset(tgaHeader,0,sizeof(tgaHeader));
	tgaHeader[12] = (unsigned char) (inputImage->width & 0xFF);
	tgaHeader[13] = (unsigned char) (inputImage->width >> 8);
	tgaHeader[14] = (unsigned char) (inputImage->height & 0xFF);
	tgaHeader[15] = (unsigned char) (inputImage->height >> 8);
	tgaHeader[17] = 0x20;    // Top-down, non-interlaced
	tgaHeader[2]  = 2;       // image type = uncompressed RGB
	tgaHeader[16] = 24;
	
	imageLen = sizeof(tgaHeader) + inputImage->dataLength;
	
	#ifdef __SPEAR32__
		printf("\nTEST: Sending image.\n");
		
		// send signal to PC client that output data will be sent
		printf("\x04\n");
		
		// send elapsed time for computation
		UART_write(1, (char *)&counterSize, sizeof(counterSize));
		for(i = 0; i < counterSize; i++) {
			uint32_t cycles = counterValues[i];
			UART_write(1, (char *)&cycles, sizeof(cycles));
		}
		/*
		// send length of whole image file
		UART_write(1, (char *)&imageLen, sizeof(imageLen));
		// send image header
		UART_write(1, tgaHeader, sizeof(tgaHeader));
		// send image data
		UART_write(1, (char *)inputImage->data, inputImage->dataLength); */	
	#else
		f = fopen(targetPath, "w");
		if (!f) {
			printf("Image file <%s> couldn't be opened", targetPath);
			exit(1);
		}
		
		fwrite(tgaHeader, 1, sizeof(tgaHeader), f);
		fwrite(inputImage->data, 1, inputImage->dataLength, f);
		fclose(f);
	#endif
}

void faceDetection(image_t* inputImage)
{
	image_t temp,temp2;
	
	printf("Starting computation.\n");
	
	initializeImage(inputImage, &temp);
	initializeImage(inputImage, &temp2);
	
	// perform face detection
	benchmark_messure(skinFilter(inputImage, &temp));
	benchmark_messure(erodeDilateFilter(&temp, &temp2, FILTER_ERODE));
	benchmark_messure(erodeDilateFilter(&temp2, &temp, FILTER_DILATE));
	benchmark_messure(detectFace(&temp, inputImage));
	
	printf("Computation completed.\n");
	
	outputImage(inputImage);
	
	freeImage(inputImage);	 
}

void outputImage(image_t *image) {
	int x, y;
	
	printf("Image -> VGA.\n");
	
	// output image on touchscreen
	for (y=0; y<SCREEN_HEIGHT; y++) {
		for (x=0; x<SCREEN_WIDTH; x++) {
			if (x < image->width && y < image->height) {
				int pIndex;
				rgb_color_t color;
				pIndex = (y*image->width+x)*3;
				color.b = image->data[pIndex];
				color.g = image->data[pIndex+1];
				color.r = image->data[pIndex+2];
				screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
			}
			else {
				screenData[y*SCREEN_WIDTH+x] = 0;
			}
		}
	}
}
