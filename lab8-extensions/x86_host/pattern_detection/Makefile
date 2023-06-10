CC=gcc
CFLAGS= -m32 -msse2 -O0 -std=c11 -Wall -Wextra -pedantic -Wno-misleading-indentation -g -fverbose-asm -I.
ASMFLAGS= -m32 -msse2
DEBUGFLAGS= -std=c11 -Wall -Wextra -pedantic -g -I.
LDFLAGS= -m32 -lm

SRC_C=$(wildcard *.c)
SRC_ASM=$(wildcard *.S)
OBJC=$(SRC_C:%.c=%.o)
OBJ_ASM=$(SRC_ASM:%.S=%.o)
BIN=pattern_detection

all: $(BIN)

debug: $(SRC_C)
	$(CC) $(DEBUGFLAGS) -o $(BIN) $^ ${LDFLAGS}

$(BIN): $(OBJC) $(OBJ_ASM)
	$(CC) -o $(BIN) $^ ${LDFLAGS} 

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $< 

%.o: %.S
	$(CC) $(ASMFLAGS) -g -c $<


clean:
	rm -f *.o
	rm $(BIN)

.PHONY : all
.PHONY : debug
.PHONY : clean