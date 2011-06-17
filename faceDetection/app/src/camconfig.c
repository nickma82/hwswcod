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
	
	/*if (read_cam(address) != data )
		printf("%d falscher wert\n",address);*/
	
	return 0;
}


void setup_cam() {
	//pause mode
	write_cam(0x0B,1<<1|1);
	// invert pixe clock
	write_cam(0x0A, (1<<15)|0);
	// column size
	write_cam(0x04, 2559);
	// row size
	write_cam(0x03, 1919);
		
	// shutter width lower
	write_cam(0x09, 1100);
	
	// GAIN

	//write_cam(0x2C,0x9A);
	//write_cam(0x2D,0x19C);
	//write_cam(0x2B,0x13);
	//write_cam(0x2E,0x13);
	
	write_cam(0x2B, (0<<8)|(0<<6)|(0x13)); //Green
	write_cam(0x2E, (0<<8)|(0<<6)|(0x13)); //Green Reset
	write_cam(0x2D, (6<<8)|(0<<6)|(0xF)); //Red Reset
	write_cam(0x2C, (5<<8)|(0<<6)|(0xF)); //Blue Reset
	
	// ganz gut: write_cam(0x2B, (0<<8)|(0<<6)|(0x13)); //Green
	// ganz gut: write_cam(0x2E, (0<<8)|(0<<6)|(0x13)); //Green Reset
	// ganz gut: write_cam(0x2D, (6<<8)|(0<<6)|(0xF)); //Red Reset
	// ganz gut: write_cam(0x2C, (5<<8)|(0<<6)|(0xF)); //Blue Reset
		
	// row and column skiping => 640x480 res
	write_cam(0x22, 0x03);
	write_cam(0x23, 0x03);
	/*
	// testbild
	write_cam(0xA1,0x0); // Grün
	write_cam(0xA2,0xFFF); // Rot
	write_cam(0xA3,0x0); // Blau
	write_cam(0xA0,(0<<4)|(1));
	*/
	//write_cam(0xA4,123);
	write_cam(0xA0,0); //Test pattern contrl
					
	// mirror der rows
	write_cam(0x20, (1<<15));
	//write_cam(0x20, 0);
	
	
	write_cam(0x06,500);
	// restart cam		
	write_cam(0x0b,1);
	
	// wait for restart finished
	while(read_cam(0x0b)&0x01)
		asm("nop");
	
	return;
}
