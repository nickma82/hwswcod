#include "camconfig.h"

uint32_t read_cam(uint8_t address) {
	CAMCONFIG_CMD = CAM_ID_READ | (address << 16);
	
	while (!CAMCONFIG_RESULT){
		asm("nop");
	}
	return CAMCONFIG_CMD;
}


uint8_t write_cam(uint8_t address, uint16_t data){
	CAMCONFIG_CMD = CAM_ID_WRITE | (address << 16) | data;
	while (CAMCONFIG_RESULT){
		asm("nop");
	}
	return 0;
}
