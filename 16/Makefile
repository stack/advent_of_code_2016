.PHONY: all arm clean info intel

# Determine the architecture we are building on
ARCH := $(shell cc -v 2>&1 | grep Target | awk '{ split($$2,a,"-"); print a[1]; }')

TARGETS := simple validate

CFLAGS += -std=gnu11 -Wall -Werror

AVX2_CFLAGS := -mavx2
SSE3_CFLAGS := -msse3
NEON_CFLAGS := -mfpu=neon


ifeq ($(ARCH),aarch64)
    TARGETS += arm_neon
    NEON_CFLAGS :=
endif

ifeq ($(ARCH),arm)
    TARGETS += arm_neon
    NEON_CFLAGS := -mfpu=neon
endif

ifeq ($(ARCH),x86_64)
    TARGETS += intel_avx2 intel_sse3 validate_intel
endif


all: $(TARGETS)

info:
	@echo ARCH:    $(ARCH)
	@echo CFLAGS:  $(CFLAGS)
	@echo TARGETS: $(TARGETS)

arm_neon: main.o checksum_arm_neon.o common.o
	$(CC) -o $@ $^ $(CFLAGS) $(NEON_CFLAGS)

intel_avx2: main.o checksum_intel_avx2.o common.o
	$(CC) -o $@ $^ $(CFLAGS) $(AVX2_CFLAGS)

intel_sse3: main.o checksum_intel_sse3.o common.o
	$(CC) -o $@ $^ $(CFLAGS) $(SSE3_CFLAGS)

simple: main.o checksum_simple.o common.o
	$(CC) -o $@ $^ $(CFLAGS)

validate: validate.o common.o
	$(CC) -o $@ $^ $(CFLAGS)
	
validate_intel: validate_intel.o
	$(CC) -o $@ $^ $(CFLAGS) $(AVX2_CFLAGS)

checksum_arm_neon.o: checksum_arm_neon.c
	$(CC) -c $< $(CFLAGS) $(NEON_CFLAGS)

checksum_intel_sse3.o: checksum_intel_sse3.c
	$(CC) -c $< $(CFLAGS) $(SSE3_CFLAGS)

checksum_intel_avx2.o: checksum_intel_avx2.c
	$(CC) -c $< $(CFLAGS) $(AVX2_CFLAGS)

validate_intel.o: validate_intel.c
	$(CC) -c $< $(CFLAGS) $(AVX2_CFLAGS)

%.o: %.c
	$(CC) -c $< $(CFLAGS)

clean:
	rm -rf *.o
	rm -rf arm_neon
	rm -rf intel_avx2
	rm -rf intel_sse3
	rm -rf simple
	rm -rf validate


