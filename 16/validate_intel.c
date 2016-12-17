#include <stdlib.h>
#include <stdio.h>

#include <emmintrin.h>
#include <xmmintrin.h>

static void printData(const char *tag, uint8_t *data, size_t size);
static void printRegister(const char *tag, __m128i reg);

int main(int argc, char **argv)
{
    // Start with a decent test set
    uint8_t data[] = {
        0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00,
        0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00,
    };

    printData("ORIGINAL", data, 16);

    // Load the data in to the register
    __m128i source = _mm_loadu_si128((__m128i *)data);

    // Build the masks for comparison
    __m128i oneMask = _mm_set1_epi16(0x0101);
    __m128i zeroMask = _mm_set1_epi16(0x0000);

    printRegister("ONE", oneMask);
    printRegister("ZERO", zeroMask);

    // Get the fields that are properly setup
    __m128i oneCmp = _mm_cmpeq_epi16(source, oneMask);
    __m128i zeroCmp = _mm_cmpeq_epi16(source, zeroMask);

    printRegister("ONE CMP", oneCmp);
    printRegister("ZERO CMP", zeroCmp);

    // Dump out the data
    uint8_t result[16];
    _mm_storeu_si128((__m128i *)result, source);

    printData("RESULT", result, 16);

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
