#include "checksum.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <emmintrin.h>
#include <tmmintrin.h>
#include <xmmintrin.h>

#ifndef DEBUG
#define DEBUG 0
#endif

void checksumData(uint8_t *data, size_t dataSize, uint8_t **checksum, size_t *checksumSize)
{
    // Build the constant data needed for comparison / shuffling
    const __m128i oneMask = _mm_set1_epi16(0x0101);
    const __m128i zeroMask = _mm_set1_epi16(0x0000);
    const __m128i shuffleMask = _mm_set_epi8(15, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 0);
    const __m128i reduce = _mm_set1_epi8(0x01);

    size_t outputSize = (dataSize + 15) / 16 * 16;
    uint8_t *output = NULL;
    posix_memalign((void **)&output, 64, outputSize);
    memcpy(output, data, dataSize);

    outputSize = dataSize;

#if DEBUG
    printf("CHECKSUM SIZES: %zu", outputSize);
#endif

    do {
        size_t outputIdx = 0;
        size_t inputIdx = 0;

        while (inputIdx < outputSize) {
            __m128i source = _mm_load_si128((__m128i *)(output + inputIdx));

            __m128i oneBuffer = _mm_cmpeq_epi16(source, oneMask);
            __m128i zeroBuffer = _mm_cmpeq_epi16(source, zeroMask);
            source = _mm_add_epi16(oneBuffer, zeroBuffer);
            source = _mm_shuffle_epi8(source, shuffleMask);
            source = _mm_and_si128(source, reduce);

            _mm_storeu_si128((__m128i *)(output + outputIdx), source);

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
