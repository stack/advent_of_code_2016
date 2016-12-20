#include "checksum.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <emmintrin.h>
#include <immintrin.h>
#include <tmmintrin.h>
#include <xmmintrin.h>

#ifndef DEBUG
#define DEBUG 0
#endif

void checksumData(uint8_t *data, size_t dataSize, uint8_t **checksum, size_t *checksumSize)
{
    // Build the constant data needed for comparison / shuffling
    const __m256i oneMask = _mm256_set1_epi16(0x0101);
    const __m256i zeroMask = _mm256_set1_epi16(0x0000);
    const __m256i shuffleMask = _mm256_set_epi8(31, 29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0);
    const __m256i reduce = _mm256_set1_epi8(0x01);

    size_t outputSize = (dataSize + 31) / 32 * 32;
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
            __m256i source = _mm256_load_si256((__m256i *)(output + inputIdx));
            __m256i oneBuffer = _mm256_cmpeq_epi16(source, oneMask);
            __m256i zeroBuffer = _mm256_cmpeq_epi16(source, zeroMask);

            source = _mm256_add_epi16(oneBuffer, zeroBuffer);
            source = _mm256_shuffle_epi8(source, shuffleMask);
            source = _mm256_and_si256(source, reduce);

            __m128i left = _mm256_extracti128_si256(source, 0);
            __m128i right = _mm256_extracti128_si256(source, 1);
            __m128i unpacked = _mm_unpackhi_epi64(left, right);

            _mm_storeu_si128((__m128i *)(output + outputIdx), unpacked);

            outputIdx += 16;
            inputIdx += 32;
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
