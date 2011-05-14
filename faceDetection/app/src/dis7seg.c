#include <drivers/dis7seg.h>

#include "dis7seg.h"

#define DISP_BADDR    ((uint32_t)-288)
static dis7seg_handle_t dispHandle;

void dis7seg_init(void) {
	
	dis7seg_initHandle(&dispHandle, DISP_BADDR, 8);
}

void dis7seg_release(void) {
	dis7seg_releaseHandle(&dispHandle);
}

void dis7seg_hex(uint32_t value) {
	dis7seg_displayHexUInt32(&dispHandle, 0, value);
}
