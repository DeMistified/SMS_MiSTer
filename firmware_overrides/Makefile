832DIR=../DeMiSTify/EightThirtyTwo
FWDIR=../DeMiSTify/firmware/
AS=$(832DIR)/832a/832a
LD=$(832DIR)/832a/832l
CC=$(832DIR)/vbcc/bin/vbcc832
COPT = -O=1343
CFLAGS = -+ -unsigned-char $(COPT) -I$(832DIR)/include/ -I$(FWDIR)
TIME=2ms

OBJDIR=832dir

all: overrides.a

OBJ=overrides.o

clean :
	-rm *.asm
	-rm *.o
	-rm *.a

overrides.a : $(OBJ)
	cat >$@ $+

%.o : %.asm Makefile
	$(AS) -o $@ $*.asm

%.asm : %.c Makefile
	$(CC) $(CFLAGS) $*.c

%.o : %.c Makefile
	$(CC) $(CFLAGS) $*.c
	$(AS) -o $@ $*.asm

