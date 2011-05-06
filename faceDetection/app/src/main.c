#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "image.h"
#include "filters.h"
#include "detectFace.h"


#ifdef __SPEAR32__
  #include "sdram.h"
  #include <machine/modules.h>
  #include <machine/interrupts.h>
  #include <machine/UART.h>
  #include <drivers/counter.h>
  #include <drivers/dis7seg.h>
  #include "svga.h"

  #define COUNTER_BADDR ((uint32_t)-320)
  #define DISP_BADDR    ((uint32_t)-288)

  #define SCREEN_WIDTH  800
  #define SCREEN_HEIGHT 480

  #define COUNTER_COUNT 5

static uint32_t sdramBytesAllocated;
static module_handle_t counterHandle[COUNTER_COUNT];
static dis7seg_handle_t dispHandle;
static volatile uint32_t *screenData;
#endif

void computeSingleImage(const char *sourcePath, const char *targetPath);
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
  for(i=0; i<COUNTER_COUNT; i++) {
	  counter_initHandle(&counterHandle[i], COUNTER_BADDR);
	  counter_setPrescaler(&counterHandle[i], 3);
  }
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
              SDRAM_CMD_LOAD_CMD_REG | 
              389;

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
  computeSingleImage(argv[1], argv[2]);
#else
  while (1) {
    // TODO:
    // get picture from camera
    // perform face detection
    // outout result image on screen
  }  
#endif


#ifdef __SPEAR32__
  for(i=0; i<COUNTER_COUNT; i++) {
	  counter_releaseHandle(&counterHandle[i]);
  }
  dis7seg_releaseHandle(&dispHandle);
#endif

  return 0;
}


void computeSingleImage(const char *sourcePath, const char *targetPath)
{
  uint32_t imageLen;
  image_t inputImage;
  image_t skinFilterImage;
  image_t erodeFilterImage;
  image_t dilateFilterImage;
  char tgaHeader[18];
  int x, y, i;

#ifndef __SPEAR32__
  FILE *f;
#else
  uint32_t cycles;
#endif

#ifndef __SPEAR32__
  f = fopen(sourcePath, "r");
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

  inputImage.width = (tgaHeader[13] << 8) | (tgaHeader[12] & 0xFF);
  inputImage.height = (tgaHeader[15] << 8) | (tgaHeader[14] & 0xFF);
  inputImage.dataLength = imageLen - sizeof(tgaHeader);


#ifndef __SPEAR32__
  // allocate memory on heap
  inputImage.data = (unsigned char *)malloc(inputImage.dataLength);    
  fread(inputImage.data, 1, inputImage.dataLength, f);
  fclose(f);
#else

  // allocate memory in external SDRAM
  inputImage.data = (unsigned char *)(SDRAM_BASE+sdramBytesAllocated);
  sdramBytesAllocated += inputImage.dataLength;

  // read image data
  UART_read(0, (char *)inputImage.data, inputImage.dataLength);
  
  printf("Images received, starting computation.\n");
#endif

  initializeImage(&inputImage, &skinFilterImage);
  initializeImage(&inputImage, &erodeFilterImage);
  initializeImage(&inputImage, &dilateFilterImage);


#ifdef __SPEAR32__
  
  counter_reset(&counterHandle[0]);
  counter_start(&counterHandle[0]);

#endif 

  // perform face detection
  counter_reset(&counterHandle[1]);
  counter_start(&counterHandle[1]);
  skinFilter(&inputImage, &skinFilterImage);
  counter_stop(&counterHandle[1]);

  erodeDilateFilter(&skinFilterImage, &erodeFilterImage, FILTER_ERODE);
  erodeDilateFilter(&erodeFilterImage, &dilateFilterImage, FILTER_DILATE);
  detectFace(&dilateFilterImage, &inputImage);
  // output image on touchscreen
  for (y=0; y<SCREEN_HEIGHT; y++) {
    for (x=0; x<SCREEN_WIDTH; x++) {
      if (x < inputImage.width && y < inputImage.height) {
	int pIndex;
	rgb_color_t color;
	pIndex = (y*inputImage.width+x)*3;
	color.b = inputImage.data[pIndex];
	color.g = inputImage.data[pIndex+1];
	color.r = inputImage.data[pIndex+2];
	screenData[y*SCREEN_WIDTH+x] = (color.r << 16) | (color.g << 8) | color.b;
      }
      else {
	screenData[y*SCREEN_WIDTH+x] = 0;
      }
    }
  }

#ifdef __SPEAR32__
  counter_stop(&counterHandle[0]);
#endif 

  // send output
  memset(tgaHeader,0,sizeof(tgaHeader));
  tgaHeader[12] = (unsigned char) (inputImage.width & 0xFF);
  tgaHeader[13] = (unsigned char) (inputImage.width >> 8);
  tgaHeader[14] = (unsigned char) (inputImage.height & 0xFF);
  tgaHeader[15] = (unsigned char) (inputImage.height >> 8);
  tgaHeader[17] = 0x20;    // Top-down, non-interlaced
  tgaHeader[2]  = 2;       // image type = uncompressed RGB
  tgaHeader[16] = 24;

  imageLen = sizeof(tgaHeader) + inputImage.dataLength;

#ifndef __SPEAR32__
  f = fopen(targetPath, "w");
  if (!f) {
    printf("Image file <%s> couldn't be opened", targetPath);
    exit(1);
  }
    
  fwrite(tgaHeader, 1, sizeof(tgaHeader), f);
  fwrite(inputImage.data, 1, inputImage.dataLength, f);
  fclose(f);
#else
  // send signal to PC client that output data will be sent
  printf("\x04\n");

  // send elapsed time for computation
  for(i=0; i<COUNTER_COUNT; i++) {
	  cycles = counter_getValue(&counterHandle[i]);
	  UART_write(1, (char *)&cycles, sizeof(cycles));

  }
  // send length of whole image file
  UART_write(1, (char *)&imageLen, sizeof(imageLen));
  // send image header
  UART_write(1, tgaHeader, sizeof(tgaHeader));
  // send image data
  UART_write(1, (char *)inputImage.data, inputImage.dataLength);
#endif

  freeImage(&inputImage);
  freeImage(&skinFilterImage);
  freeImage(&erodeFilterImage);
  freeImage(&dilateFilterImage);
  
}
