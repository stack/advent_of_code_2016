#include <stdlib.h>
#include <stdio.h>

#include <emmintrin.h>
#include <tmmintrin.h>
#include <xmmintrin.h>

static void printData(const char *tag, uint8_t *data, size_t size);
static void printRegister(const char *tag, __m128i reg);

int main(int argc, char **argv)
{
    // Start with a decent test set
    uint8_t data[] = {
        0x00, 0x00, 0xff, 0xff, 0x00, 0xff, 0xff, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x00, 0xff, 0xff, 0x00,
    };

    printData("ORIGINAL", data, 16);

    // Load the data in to the register
    __m128i source = _mm_loadu_si128((__m128i *)data);

    // Build the masks for comparison
    __m128i oneMask = _mm_set1_epi16(0xffff);
    __m128i zeroMask = _mm_set1_epi16(0x0000);

    printRegister("ONE     ", oneMask);
    printRegister("ZERO    ", zeroMask);

    // Find the matching pairs
    __m128i oneCmp = _mm_cmpeq_epi16(source, oneMask);
    __m128i zeroCmp = _mm_cmpeq_epi16(source, zeroMask);

    printRegister("ONE CMP ", oneCmp);
    printRegister("ZERO CMP", zeroCmp);

    // Add the matching pairs
    source = _mm_add_epi16(oneCmp, zeroCmp);

    printRegister("SUM     ", source);

    // Build a shuffle mast
    __m128i shuffleMask = _mm_set_epi8(15, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 0);

    printRegister("MASK    ", shuffleMask);

    // Perform the shuffle
    source = _mm_shuffle_epi8(source, shuffleMask);

    printRegister("SHUFFLE ", source);

    // Dump out the data
    uint8_t result[16];
    _mm_storeu_si128((__m128i *)result, source);

    printData("RESULT  ", result, 16);

    return 0;
}

static void printData(const char *tag, uint8_t *data, size_t size)
{
    printf("%s: [", tag);

    for (size_t idx = 0; idx < size; idx++) {
        printf(" 0x%02x", data[idx]);
    }

    printf(" ]\n");
}

static void printRegister(const char *tag, __m128i reg)
{
    uint8_t buffer[16];
    _mm_storeu_si128((__m128i *)buffer, reg);

    printData(tag, buffer, 16);
}
