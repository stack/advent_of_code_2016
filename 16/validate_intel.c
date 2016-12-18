#include <stdlib.h>
#include <stdio.h>

#include <emmintrin.h>
#include <immintrin.h>
#include <tmmintrin.h>
#include <xmmintrin.h>

static void printData(const char *tag, uint8_t *data, size_t size);
static void printHeader(int count);
static void printRegister128(const char *tag, __m128i reg);
static void printRegister256(const char *tag, __m256i reg);

static void validate_avx2();
static void validate_sse3();

int main(int argc, char **argv)
{
    printHeader(32);
    validate_avx2();

    printf("\n");

    printHeader(16);
    validate_sse3();

    return 0;
}

static void validate_avx2()
{
    // Shuffle Test
    uint8_t shuffleData[] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        0x1f, 0x1e, 0x1d, 0x1c, 0x1b, 0x1a, 0x19, 0x18,
        0x17, 0x16, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10,
    };

    __m256i shuffleSource = _mm256_loadu_si256((__m256i *)shuffleData);

    printRegister256("ORIGINAL", shuffleSource);

    // __m256i shuffleTestMask = _mm256_set_epi8(31, 29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0);
    // __m256i shuffleTestMask = _mm256_set_epi8(30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0);
    __m256i shuffleTestMask = _mm256_set_epi8(30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0);

    printRegister256("SHUFFLE ", shuffleTestMask);

    __m256i shuffleResult = _mm256_shuffle_epi8(shuffleSource, shuffleTestMask);

    printRegister256("RESULT  ", shuffleResult);

    __m128i shuffleExtract0 = _mm256_extracti128_si256(shuffleResult, 0);
    __m128i shuffleExtract1 = _mm256_extracti128_si256(shuffleResult, 1);

    printRegister128("EXTRACT0", shuffleExtract0);
    printRegister128("EXTRACT1", shuffleExtract1);

    // Start with a decent test set
    uint8_t data[] = {
        0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00,
        0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x01, 0x00,
        0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00,
    };

    printf("\n");

    printData("ORIGINAL", data, 32);

    // Load the data in to the register
    __m256i source = _mm256_loadu_si256((__m256i *)data);

    // Build the masks for comparison
    __m256i oneMask = _mm256_set1_epi16(0x0101);
    __m256i zeroMask = _mm256_set1_epi16(0x0000);

    printRegister256("ONE     ", oneMask);
    printRegister256("ZERO    ", zeroMask);

    // Find the matching pairs
    __m256i oneCmp = _mm256_cmpeq_epi16(source, oneMask);
    __m256i zeroCmp = _mm256_cmpeq_epi16(source, zeroMask);

    printRegister256("ONE CMP ", oneCmp);
    printRegister256("ZERO CMP", zeroCmp);

    // Add the matching pairs
    source = _mm256_add_epi16(oneCmp, zeroCmp);

    printRegister256("SUM     ", source);

    // Build a shuffle mast
    __m256i shuffleMask = _mm256_set_epi8(31, 29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0);

    printRegister256("MASK    ", shuffleMask);

    // Perform the shuffle
    source = _mm256_shuffle_epi8(source, shuffleMask);

    printRegister256("SHUFFLE ", source);

    // Convert the full bytes back to 1s
    __m256i reduce = _mm256_set1_epi8(0x01);

    printRegister256("REDUCE  ", reduce);

    source = _mm256_and_si256(source, reduce);

    // Dump out the data
    uint8_t result[32];
    _mm256_storeu_si256((__m256i *)result, source);

    printData("RESULT  ", result, 32);
}

static void validate_sse3()
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

    printRegister128("ONE     ", oneMask);
    printRegister128("ZERO    ", zeroMask);

    // Find the matching pairs
    __m128i oneCmp = _mm_cmpeq_epi16(source, oneMask);
    __m128i zeroCmp = _mm_cmpeq_epi16(source, zeroMask);

    printRegister128("ONE CMP ", oneCmp);
    printRegister128("ZERO CMP", zeroCmp);

    // Add the matching pairs
    source = _mm_add_epi16(oneCmp, zeroCmp);

    printRegister128("SUM     ", source);

    // Build a shuffle mast
    __m128i shuffleMask = _mm_set_epi8(15, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 0);

    printRegister128("MASK    ", shuffleMask);

    // Perform the shuffle
    source = _mm_shuffle_epi8(source, shuffleMask);

    printRegister128("SHUFFLE ", source);

    // Convert the full bytes back to 1s
    __m128i reduce = _mm_set1_epi8(0x01);

    printRegister128("REDUCE  ", reduce);

    source = _mm_and_si128(source, reduce);

    // Dump out the data
    uint8_t result[16];
    _mm_storeu_si128((__m128i *)result, source);

    printData("RESULT  ", result, 16);
}

static void printData(const char *tag, uint8_t *data, size_t size)
{
    printf("%s: [", tag);

    for (size_t idx = 0; idx < size; idx++) {
        printf(" 0x%02x", data[idx]);
    }

    printf(" ]\n");
}

static void printHeader(int count)
{
    printf("           ");

    for (int idx = 0; idx < count; idx++) {
        if (idx < 10) {
            printf("    %i", idx);
        } else {
            printf("   %i", idx);
        }
    }

    printf("\n");
    printf("           ");

    for (int idx = 0; idx < count; idx++) {
        printf("-----");
    }

    printf("\n");
}

static void printRegister128(const char *tag, __m128i reg)
{
    uint8_t buffer[16];
    _mm_storeu_si128((__m128i *)buffer, reg);

    printData(tag, buffer, 16);
}

static void printRegister256(const char *tag, __m256i reg)
{
    uint8_t buffer[32];
    _mm256_storeu_si256((__m256i *)buffer, reg);

    printData(tag, buffer, 32);
}
