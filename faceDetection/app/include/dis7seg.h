#ifndef _dis7seg_h_
#define _dis7seg_h_

dis7seg_handle_t dispHandle;
void dis7seg_init(void);
void dis7seg_release(void);
void dis7seg_hex(uint32_t value);

#endif // _dis7seg_h_
