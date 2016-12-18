.PHONY: all clean intel

CFLAGS += -std=gnu11 -Wall -Werror
AVX2_CFLAGS := -mavx2

all: simple validate

intel: all intel_avx2 intel_sse3 validate_intel
	
intel_avx2: main.o checksum_intel_avx2.o common.o
	$(CC) -o $@ $^ $(CFLAGS) $(AVX2_CFLAGS)

intel_sse3: main.o checksum_intel_sse3.o common.o
	$(CC) -o $@ $^ $(CFLAGS)

simple: main.o checksum_simple.o common.o
	$(CC) -o $@ $^ $(CFLAGS)

validate: validate.o common.o
	$(CC) -o $@ $^ $(CFLAGS)
	
validate_intel: validate_intel.o
	$(CC) -o $@ $^ $(CFLAGS) $(AVX2_CFLAGS)

checksum_intel_avx2.o: checksum_intel_avx2.c
	$(CC) -c $< $(CFLAGS) $(AVX2_CFLAGS)

validate_intel.o: validate_intel.c
	$(CC) -c $< $(CFLAGS) $(AVX2_CFLAGS)

%.o: %.c
	$(CC) -c $< $(CFLAGS)

clean:
	rm -rf *.o
	rm -rf intel_avx2
	rm -rf intel_sse3
	rm -rf simple
	rm -rf validate


