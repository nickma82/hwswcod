#include <inttypes.h>
#include <machine/UART.h>
#include <machine/modules.h>
#include <drivers/dis7seg.h>

#if defined __SPEAR16__
  #include "gdb/sim-spear16.h"
  #define SPEAR2_ADDR_CTYPE  uint16_t
#elif defined __SPEAR32__
  #include "gdb/sim-spear32.h"
  #define SPEAR2_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

#define SPEAR2_INSN_SIZE 2

#define NUM_HEX_CHARS_PER_BYTE     2
#define SREC_MAX_LINE_LEN         80
#define SREC_FIELD_TYPE_OFFSET     1
#define SREC_FIELD_LENGTH_LEN      2
#define SREC_FIELD_LENGTH_OFFSET   2
#define SREC_FIELD_ADDRESS_OFFSET  4
#define SREC_FIELD_CHECKSUM_LEN    2
#define SREC_TYPE_HEADER           0
#define SREC_TYPE_DATA2            1
#define SREC_TYPE_DATA2_TERM       9
#define SREC_TYPE_DATA4            3
#define SREC_TYPE_DATA4_TERM       7

typedef struct
{
  uint8_t           type;
  uint8_t           length;
  uint8_t           address_length;
  SPEAR2_ADDR_CTYPE address;
  uint8_t           payload_num_bytes;
  uint8_t           payload_offset;
  uint8_t           size;
} srecord_t;

static uint8_t
char_to_int (char c)
{
  if (c >= '0' && c <= '9')
    return c - 48;
  else if (c >= 'A' && c <= 'F')
    return c - 55;
  else
    return 0;
}

static void
program_codemem (srecord_t *srec, char *buffer)
{
  int8_t i;

  srec->address -= SPEAR2_CODEMEM_LMA;
  srec->address /= SPEAR2_INSN_SIZE;

  /* Iterate over the number of codewords in the current srecord. */
  for (i = 0; i < srec->payload_num_bytes / SPEAR2_INSN_SIZE; ++i)
  {
    /* Write the address of the current codeword to
     * the address register of the programmer module. */
    PROGRAMMER_ADDRESS = srec->address + i;

    /* Prepare the characters in the buffer to form a proper codeword
     * and write this to the data register of the programmer module. */
    PROGRAMMER_DATA = (char_to_int (buffer[srec->payload_offset + 2]) << 12)
                    + (char_to_int (buffer[srec->payload_offset + 3]) << 8)
                    + (char_to_int (buffer[srec->payload_offset + 0]) << 4)
                    + (char_to_int (buffer[srec->payload_offset + 1]));

    /* Advance the payload offset pointer to point to the next codeword. */
    srec->payload_offset += (SPEAR2_INSN_SIZE * NUM_HEX_CHARS_PER_BYTE);

    /* Tell the programmer module to perform the download. */
    PROGRAMMER_CONFIG_C |= (1 << PROGRAMMER_CONFIG_C_PREXE);
  }
}

static void
program_datamem (srecord_t *srec, char *buffer)
{
  int8_t i;
  uint8_t data;
  volatile uint8_t *address;

  /* Iterate over the number of data bytes in the current srecord. */
  for (i = 0; i < srec->payload_num_bytes; ++i)
  {
    /* Write the address of the current data byte to
     * the address register of the programmer module. */
    address = (uint8_t *) srec->address + i;

    /* Prepare the characters in the buffer to form a proper data byte. */
    data = (char_to_int (buffer[srec->payload_offset + 0]) << 4)
         + (char_to_int (buffer[srec->payload_offset + 1]));

    /* Advance the payload offset pointer to point to the next datum. */
    srec->payload_offset += NUM_HEX_CHARS_PER_BYTE;

    *address = data;
  }
}

int main (int argc, char *argv[])
{
  char buffer[SREC_MAX_LINE_LEN+1];
  int8_t i, j;
  srecord_t srec;
  UART_Cfg cfg;
  dis7seg_handle_t display_handle;
  
  /* Define the UART settings. */
  cfg.fclk = 50000000;
  cfg.baud = UART_CFG_BAUD_115200;
  cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
  cfg.frame.parity = UART_CFG_PARITY_EVEN;
  cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
  UART_init (cfg);
  
  dis7seg_initHandle(&display_handle, -288, 8);
  dis7seg_displayHexUInt32(&display_handle, 0, 0x01234567);

  while (1)
  {
    srec.size = UART_read_line (0, buffer, SREC_MAX_LINE_LEN);
    if (srec.size == 0)
      continue;

    /* Check if the line starts with an 'S'. */
    if (buffer[0] != 'S')
      continue;

    /* Extract the srecord type. */
    srec.type = char_to_int (buffer[SREC_FIELD_TYPE_OFFSET]);

    /* Extract the srecord length. */
    srec.length = (char_to_int (buffer[SREC_FIELD_LENGTH_OFFSET]) << 4)
                 + char_to_int (buffer[SREC_FIELD_LENGTH_OFFSET + 1]);

    
    /* Process the current srecord. */
    switch (srec.type)
    {
      case SREC_TYPE_DATA4:
      {
        /* Deduce the address field length from the srecord type. */
        srec.address_length = 8;

        /* Extract the address at which the payload is to be loaded. */
        srec.address = 0;
        for (i = 0; i < srec.address_length; ++i)
        {
          j = srec.address_length - 1 - i;
          srec.address += char_to_int (buffer[SREC_FIELD_ADDRESS_OFFSET + i]) << 4 * j;
        }

        /* Compute the offset and length (bytes) of the payload field. */
        srec.payload_offset = SREC_FIELD_ADDRESS_OFFSET + srec.address_length;
        srec.payload_num_bytes = (srec.size - srec.payload_offset - SREC_FIELD_CHECKSUM_LEN) / NUM_HEX_CHARS_PER_BYTE;

        if (srec.address >= SPEAR2_CODEMEM_LMA)	  
          program_codemem (&srec, buffer);
        else
          program_datamem (&srec, buffer);

        break;
      }
      case SREC_TYPE_DATA4_TERM:
      {
        /* Set the program counter to SPEAR2_CODEMEM_LMA. */
#if defined __SPEAR16__
        asm ("ldhi r13, 0");
#elif defined __SPEAR32__
        asm ("ldhi r13, 0");
        asm ("ldliu r13, 0");
        asm ("sli r13, 0x8");
        asm ("ldliu r13, 0");
        asm ("sli r13, 0x8");
#endif
        asm ("ldliu r13, 0");
        asm ("jmp r13");
      }
      default:
      {
        continue;
      }
    }
  }

  return 0;
}

