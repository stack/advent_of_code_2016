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
    // Build the constant data needed for shuffling / manipulating
    const __m128i threes = _mm_set1_epi8(3);
    const __m128i ones = _mm_set1_epi8(1);
    const __m128i swapShuffle = _mm_set_epi8(14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3, 0, 1);
    const __m128i orderShuffle = _mm_set_epi8(15, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 0);

    // Build the container for the final memory

    size_t outputSize = (dataSize + 15) / 16 * 16;
    uint8_t *output = NULL;
    posix_memalign((void **)&output, 64, outputSize);
    memcpy(output, data, dataSize);

    outputSize = dataSize;

    do {
        size_t outputIdx = 0;
        size_t inputIdx = 0;

        while (inputIdx < outputSize) {
            // Make two copies of the data, one with the pairs swapped
            __m128i source = _mm_load_si128((__m128i *)(output + inputIdx));
            __m128i copy = _mm_shuffle_epi8(source, swapShuffle);

            // Add the values and twiddle them to get back to 1s and 0s
            source = _mm_add_epi8(source, copy);
            source = _mm_xor_si128(source, threes);
            source = _mm_and_si128(source, ones);

            // Shuffle the data so single values are up front
            source = _mm_shuffle_epi8(source, orderShuffle);

            // Write back to memory and advance
            _mm_storeu_si128((__m128i *)(output + outputIdx), source);

            outputIdx += 8;
            inputIdx += 16;
        }

        outputSize /= 2;

#if DEBUG
        printf(" -> %zu", outputSize);
#endif
    } while (outputSize % 2 == 0);

    /*
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
    */

#if DEBUG
    printf("\n");
#endif

    *checksum = output;
    *checksumSize = outputSize;
}
