#ifndef __camconfig_h__
#define __camconfig_h__

#include "drivers.h"

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

#endif // __camconfig_h__

