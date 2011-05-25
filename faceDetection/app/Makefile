CC=spear32-gcc
OBJCOPY=spear32-objcopy
OBJDUMP=spear32-objdump
CFLAGS=-c -Wall -O2
LDFLAGS=-Wl,--nmagic,--no-check-sections,--strip-all,-Tspear32-de2-115.ld
LIBS=-lspeardrivers

SOURCES=src/main.c \
	src/detectFace.c \
	src/dis7seg.c \
	src/filters.c \
	src/image.c \
	src/sdram.c \
	src/svga.c \
	src/writeframe.c \
	src/test.c 

OBJECTS=$(SOURCES:.c=.o)
PROGRAM=main
INCLUDE=-Iinclude

CFLAGS+=$(INCLUDE)

ifeq ($(DEBUG), 1)
  CFLAGS+=-g
endif

ifeq ($(TEST), 1)
  CFLAGS+=-DTEST
endif

all: $(SOURCES) $(PROGRAM)

$(PROGRAM): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@
	$(OBJCOPY) -O srec $(PROGRAM) $(PROGRAM).srec
	$(OBJDUMP) -DGlrswxz $(PROGRAM) > $(PROGRAM).txt

.c.o:
	$(CC) $(CFLAGS) $< -o $@


clean:
	rm -rf $(OBJECTS) $(PROGRAM) $(PROGRAM).txt $(PROGRAM).srec
