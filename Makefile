CC	= gcc
LD	= gcc
OPT 	= -O1 -s 
CFLAGS 	= $(OPT) -c -I/usr/include/libusb-1.0
LDFLAGS	= -DPTW32_STATIC_LIB $(OPT)
LIBS	= -lrt -lusb-1.0

all:
	$(CC) $(CFLAGS) elanfp.c -o elanfp.o
	$(LD) $(LDFLAGS) elanfp.o $(LIBS) -o elanfp

clean: 
	rm -f *.o elanfp
	