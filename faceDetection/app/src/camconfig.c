#include "camconfig.h"

uint32_t read_cam(uint8_t address) {
	CAMCONFIG_READ = (CAM_ID_WRITE << 24) | (CAM_ID_READ<<16) | (address << 8);
	
	while (!CAMCONFIG_STATUS){
		asm("nop");
	}
	return CAMCONFIG_RESULT;
}


uint8_t write_cam(uint8_t address, uint16_t data){
	CAMCONFIG_WRITE = (CAM_ID_WRITE << 24) | (address << 16) | data;
	while (!CAMCONFIG_STATUS){
		asm("nop");
	}
	return 0;
}
