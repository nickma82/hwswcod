
#include <stdio.h>   
#include <string.h>  
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h> 
#include <errno.h> 
#include <termios.h> 
#include <signal.h>

int main(int argc, char **argv)
{
	int x,y;
	FILE *f;
	uint32_t filesize = 0;
	unsigned char *imageData, *readData,*outputImage,*outputData;
	f = fopen(argv[1], "r");
	
	fseek(f, 0, SEEK_END);
	
	filesize = ftell(f);
	fseek(f, 0, SEEK_SET);
	imageData = (unsigned char *)malloc(filesize);
	fread(imageData, 1, filesize, f);
	fclose(f);

	readData = imageData + 18;
	
	outputImage = (unsigned char *)malloc(filesize);
	memcpy(outputImage,imageData,18);
	
	outputData = outputImage + 18;
	for(
	
	return 0;	
}
