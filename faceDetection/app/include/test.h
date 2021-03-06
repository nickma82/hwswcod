#ifndef _test_h_
#define _test_h_

#ifdef __SPEAR32__
	#include <drivers/counter.h>

	#define COUNTER_COUNT 11

	extern uint8_t *reg;
	int32_t counterValues[COUNTER_COUNT];
	module_handle_t counterHandle;
	unsigned short counterSize;
	int cnt;

	#define benchmark_messure(callable) \
	do { \
	*reg = (1 << COUNTER_CLEAR_BIT); \
	*reg = (1 << COUNTER_COUNT_BIT); \
	callable; \
	*reg = 0; \
	if (counterSize < COUNTER_COUNT) { \
		counterValues[counterSize] = counter_getValue(&counterHandle); \
		counterSize++; \
	} \
	} while (0)

	#define benchmark_messure2(callable) \
	do { \
	*reg = (1 << COUNTER_CLEAR_BIT); \
	*reg = (1 << COUNTER_COUNT_BIT); \
	callable; \
	*reg = 0; \
	if (cnt < 5 && counterSize < COUNTER_COUNT) { \
		counterValues[counterSize] = counter_getValue(&counterHandle); \
		counterSize++; \
		cnt++; \
	} \
	} while (0)
#endif // __SPEAR32__

#ifndef TEST
	#undef benchmark_messure
	#undef benchmark_messure2
	#define benchmark_messure(callable) callable
	#define benchmark_messure2(callable) callable
#endif

void test_init(void);
void test_release(void);
void test_receiveImage(image_t *inputImage, const char *sourcePath);
void test_sendImage(image_t *inputImage, const char *targetPath);

#endif // _test_h_

