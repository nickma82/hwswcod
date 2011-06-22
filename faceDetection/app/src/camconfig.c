#include <stdio.h>
#include "camconfig.h"
#include "svga.h"
#include "image.h"
#include "getframe.h"
#include "dis7seg.h"
#include "drivers.h"
#include "image.h"

#ifdef __SPEAR32__
	#define CAMCONFIG_BASE 		(0xFFFFFE60)

	#define CAMCONFIG_WRITE		(*(volatile uint32_t *const)(CAMCONFIG_BASE+4))
	#define CAMCONFIG_READ		(*(volatile uint32_t *const)(CAMCONFIG_BASE+8))
	#define CAMCONFIG_RESULT	(*(volatile uint32_t *const)(CAMCONFIG_BASE+12))
	#define CAMCONFIG_STATUS	(*(volatile  uint8_t *const)(CAMCONFIG_BASE+16))

	#define CAM_ID_READ		(0xBB)
	//#define CAM_ID_READ		(0xAB000000)
	#define CAM_ID_WRITE 	(0xBA)

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
#endif // __SPEAR32__

uint32_t read_cam(uint8_t address);
uint8_t write_cam(uint8_t address, uint16_t data);
void restart_cam(void);
void calibrate_cam(void);
void write_gain(void);
void adjust_gain(gain_t *current_gain, uint8_t current_color, uint8_t desired_color);

gain_t gain_r, gain_g, gain_b;

uint32_t read_cam(uint8_t address) {
	CAMCONFIG_READ = (CAM_ID_WRITE << 24) | (CAM_ID_READ<<16) | (address << 8);

	while (!CAMCONFIG_STATUS){
		asm("nop");
	}
	return CAMCONFIG_RESULT;
}

uint8_t write_cam(uint8_t address, uint16_t data) {
	CAMCONFIG_WRITE = (CAM_ID_WRITE << 24) | (address << 16) | data;
	while (!CAMCONFIG_STATUS) {
		asm("nop");
	}
	return 0;
}

void restart_cam() {
	// restart cam
	write_cam(0x0b, 1);

	// wait for restart finished
	while (read_cam(0x0b) & 0x01)
		asm("nop");
}

void write_gain() {
	write_cam(0x2B, (gain_g.dg<<8) | (gain_g.am<<6) | (gain_g.ag)); //Green1 GAIN
	write_cam(0x2E, (gain_g.dg<<8) | (gain_g.am<<6) | (gain_g.ag)); //Green2 GAIN
	write_cam(0x2D, (gain_r.dg<<8) | (gain_r.am<<6) | (gain_r.ag)); //Red GAIN
	write_cam(0x2C, (gain_b.dg<<8) | (gain_b.am<<6) | (gain_b.ag)); //Blue GAIN
}

void adjust_gain(gain_t *current_gain, uint8_t current_color, uint8_t desired_color) {
	// Gain Faktoren anpassen
 	float new_gain = ((float)desired_color/current_color);

	// Werte laut Empfehlungen von Tabelle im Datenblatt Seite 47
	if (new_gain <= 4.0f) {
		current_gain->am = 0;
		current_gain->dg = 0;
		current_gain->ag = (uint8_t)(new_gain*8.0f);
	}
	else if (new_gain > 4.0f && new_gain <= 8.0f) {
		current_gain->dg = 0;
		current_gain->am = 1;
		current_gain->ag = (uint8_t)(new_gain/2.0f*8.0f);
	}
	else {
		current_gain->dg = (uint8_t)(((new_gain/8.0f)-1)*8.0f);
		current_gain->am = 1;
		current_gain->ag = 32;
	}
}

void calibrate_cam() {
	int x,y,i;
	uint32_t rgb,r= 0,g = 0,b = 0;
	uint8_t white = 255;

	GETFRAME_R1 = (CAM_CAL_START_X << 16) | CAM_CAL_START_Y;
	GETFRAME_R2 = (CAM_CAL_END_X << 16) | CAM_CAL_END_Y;

	// 100 Frames einlesen
	for (i = 0; i < 100; i++) {
		dis7seg_uint32(i);
		GETFRAME_START = 1;
		getframe_wait_return();
	}

	i = 0;
	// Für 50x50 Pixel großes Feld durchschnittliche Farbe pro Kanal berechnen
	for (y = CAM_CAL_START_Y; y <= CAM_CAL_END_Y; y++) {
		for(x = CAM_CAL_START_X; x <= CAM_CAL_END_X; x++) {
			i++;
			rgb = screenData[y*SCREEN_WIDTH+x];
			r += (rgb & 0x00FF0000) >> 16;
			g += (rgb & 0x0000FF00) >> 8;
			b += (rgb & 0x000000FF);
		}
	}

	// Farbgain anpassen
	adjust_gain(&gain_r, (uint8_t)(r/i), white);
	adjust_gain(&gain_g, (uint8_t)(g/i), white);
	adjust_gain(&gain_b, (uint8_t)(b/i), white);

	write_gain();
	restart_cam();
}

void setup_cam() {
	gain_r.am = 0;
	gain_r.ag = 26;
	gain_r.dg = 0;

	gain_g.am = 0;
	gain_g.ag = 19;
	gain_g.dg = 0;

	gain_b.am = 0;
	gain_b.ag = 24;
	gain_b.dg = 0;

	//pause mode
	write_cam(0x0B, (1 << 1) | 1);
	// invert pixe clock
	write_cam(0x0A, (1 << 15) | 0);
	// column size
	write_cam(0x04, 2559);
	// row size
	write_cam(0x03, 1919);

	// shutter width lower
	//write_cam(0x09, 1000);

	// row and column skiping => 640x480 res
	write_cam(0x22, 0x03);
	write_cam(0x23, 0x03);

	// mirror der rows
	write_cam(0x20, 1 << 15);

	restart_cam();

	calibrate_cam();
}
