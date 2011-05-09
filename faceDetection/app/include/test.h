#ifndef _test_h_
#define _test_h_

#include <drivers/counter.h>

#define COUNTER_COUNT 5

extern uint32_t *counterValues;
extern module_handle_t counterHandle;
extern unsigned short counterSize;

void test_init(void);
void test_release(void);
void test_receiveImage(image_t *inputImage, const char *sourcePath);
void test_sendImage(image_t *inputImage, const char *targetPath);

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

#endif // _test_h_
