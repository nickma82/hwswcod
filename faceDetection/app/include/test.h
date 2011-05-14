#ifndef _test_h_
#define _test_h_

#ifdef __SPEAR32__
	#include <drivers/counter.h>
	#define COUNTER_COUNT 5

	uint32_t counterValues[COUNTER_COUNT];
	module_handle_t counterHandle;
	unsigned short counterSize;
	
	#define benchmark_messure(callable) \
	do { \
	counter_start(&counterHandle); \
	callable; \
	counter_stop(&counterHandle); \
	if (counterSize < COUNTER_COUNT) { \
		counterValues[counterSize] = counter_getValue(&counterHandle); \
		if (!counterValues[counterSize]) \
			counterValues[counterSize] = 1; \
		counterSize++; \
	} \
	} while (0)
#else
	#define benchmark_messure(callable) callable
#endif // __SPEAR32__

void test_init(void);
void test_release(void);
void test_receiveImage(image_t *inputImage, const char *sourcePath);
void test_sendImage(image_t *inputImage, const char *targetPath);

#endif // _test_h_
