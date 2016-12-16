.PHONY: all clean

CFLAGS += -std=gnu11 -Wall -Werror

all: validate
	
simple: main.o checksum_simple.o common.o
	$(CC) -o $@ $^ $(CFLAGS)

validate: validate.o common.o
	$(CC) -o $@ $^ $(CFLAGS)

%.o: %.c
	$(CC) -c $< $(CFLAGS)

clean:
	rm -rf *.o
	rm -rf simple
	rm -rf validate


