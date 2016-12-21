#include "checksum.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <arm_neon.h>

#ifndef DEBUG
#define DEBUG 0
#endif

void checksumData(uint8_t *data, size_t dataSize, uint8_t **checksum, size_t *checksumSize)
{
    // Initialize constants
    uint8x8_t threes = { 3, 3, 3, 3, 3, 3, 3, 3 };
    uint8x8_t ones   = { 1, 1, 1, 1, 1, 1, 1, 1 };

    size_t outputSize = (dataSize + 15) / 16 * 16;
    uint8_t *output = NULL;

    int result = posix_memalign((void **)&output, 64, outputSize);
    if (result != 0) {
        fprintf(stderr, "Failed to allocate output buffer: %i\n", result);
        exit(1);
    }

    memcpy(output, data, dataSize);

    outputSize = dataSize;

#if DEBUG
    printf("CHECKSUM SIZES: %zu", outputSize);
#endif

    do {
        size_t outputIdx = 0;
        size_t inputIdx = 0;

        while (inputIdx < outputSize) {
            uint8x16_t source = vld1q_u8(output + inputIdx);
            uint8x8_t low = vget_low_u8(source);
            uint8x8_t high = vget_high_u8(source);
            uint8x8_t values = vpadd_u8(low, high);

            values = veor_u8(values, threes);
            values = vand_u8(values, ones);

            vst1_u8(output + outputIdx, values);

            outputIdx += 8;
            inputIdx += 16;
        }

        outputSize /= 2;

#if DEBUG
        printf(" -> %zu", outputSize);
#endif
    } while (outputSize % 2 == 0);

#if DEBUG
    printf("\n");
#endif

    *checksum = output;
    *checksumSize = outputSize;
}
