#ifndef __camconfig_h__
#define __camconfig_h__

#include "drivers.h"
#include "image.h"

#define CAMCONFIG_BASE 		(0xFFFFFE60)


#define CAMCONFIG_WRITE		(*(volatile uint32_t *const)(CAMCONFIG_BASE+4))
#define CAMCONFIG_READ		(*(volatile uint32_t *const)(CAMCONFIG_BASE+8))
#define CAMCONFIG_RESULT	(*(volatile uint32_t *const)(CAMCONFIG_BASE+12))
#define CAMCONFIG_STATUS	(*(volatile uint8_t *const)(CAMCONFIG_BASE+16))

#define CAM_ID_READ		(0xBB)
//#define CAM_ID_READ		(0xAB000000)
#define CAM_ID_WRITE 	(0xBA)

uint32_t read_cam(uint8_t address);
uint8_t write_cam(uint8_t address, uint16_t data);
void setup_cam();
void calibrate_cam();

#define CAM_CAL_WINDOW	25

#define CAM_CAL_START_X	(IMAGE_WIDTH/2-CAM_CAL_WINDOW)
#define CAM_CAL_START_Y	(IMAGE_HEIGHT/2-CAM_CAL_WINDOW)
#define CAM_CAL_END_X	(IMAGE_WIDTH/2+CAM_CAL_WINDOW)
#define CAM_CAL_END_Y	(IMAGE_HEIGHT/2+CAM_CAL_WINDOW)


typedef struct {
	uint8_t ag;
	uint8_t am;
	uint8_t dg;
} gain_t;

#endif // __camconfig_h__

