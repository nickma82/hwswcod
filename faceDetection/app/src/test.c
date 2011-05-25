#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __SPEAR32__
	#include <machine/UART.h>
	#include "sdram.h"
#endif

#include "image.h"
#include "test.h"

#define COUNTER_BADDR ((uint32_t)-320)

void test_init(void) {
	#ifdef __SPEAR32__
		int i;
		UART_Cfg cfg;
		// UART
		cfg.fclk = 50000000;
		cfg.baud = UART_CFG_BAUD_115200;
		cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
		cfg.frame.parity = UART_CFG_PARITY_EVEN;
		cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
		UART_init (cfg);
		
		counterSize = 0;
		for(i = 0; i < COUNTER_COUNT; i++)
			counterValues[i] = 0;
		
		counter_initHandle(&counterHandle, COUNTER_BADDR);
		counter_setPrescaler(&counterHandle, 3);
	#endif // __SPEAR32__
}

void test_release(void) {
	#ifdef __SPEAR32__
		counter_releaseHandle(&counterHandle);
	#endif // __SPEAR32__
}

void test_sendImage(image_t *inputImage, const char *targetPath) {
	uint32_t imageLen;
	char tgaHeader[18];
	
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
		int i;
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
		FILE *f = fopen(targetPath, "w");
		if (!f) {
			printf("Image file <%s> couldn't be opened", targetPath);
			exit(1);
		}
		
		fwrite(tgaHeader, 1, sizeof(tgaHeader), f);
		fwrite(inputImage->data, 1, inputImage->dataLength, f);
		fclose(f);
	#endif
	
	free(inputImage->data);
	#ifdef __SPEAR32__
		sdramBytesAllocated -= inputImage->dataLength;
	#endif
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
