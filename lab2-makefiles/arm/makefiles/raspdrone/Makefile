# Toolchain configuration

TOOL_PREFIX := arm-linux-gnueabihf

AR      = $(TOOL_PREFIX)-ar
LD      = $(TOOL_PREFIX)-ld
CC      = $(TOOL_PREFIX)-gcc
OBJCOPY	= $(TOOL_PREFIX)-objcopy

################################################


TARGET			= raspdrone
TARGET_LIB 		= libdriver.a

LDFLAGS 		+= -L. -ldriver -T asm.lds
CFLAGS 			+= -I. -marm

OBJS_LIB 		= motor.o navigation.o camera.o 
OBJS 			= autopilot.o engine.o gyroscope.o pwm.o

OBJS 			+= crt0.o

.PHONY: all checklib clean
all: $(TARGET)
checklib: $(TARGET_LIB)
clean:
	rm -f *.o *.a *.bin *.su
	rm -f $(TARGET)

%.o: %.S
	$(CC) $(CFLAGS) -g -c $<
%.o: %.c
	$(CC) $(CFLAGS) -g -c $<

$(TARGET_LIB): $(OBJS_LIB)
	$(AR) -r $@ $^

$(TARGET): $(TARGET_LIB)
$(TARGET): $(OBJS)
	$(LD) $^ -o $@ $(LDFLAGS)
	$(OBJCOPY) -O binary $@ $@.bin 2>/dev/null

autopilot.o: autopilot.h gyroscope.h navigation.h
camera.o: camera.h
gyroscope.o: gyroscope.h
motor.o: motor.h
navigation.o: navigation.h gyroscope.h camera.h
pwm.o: pwm.h
engine.o: motor.h autopilot.h camera.h gyroscope.h