#include "checksum.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#ifndef DEBUG
#define DEBUG 0
#endif

void checksumData(uint8_t *data, size_t dataSize, uint8_t **checksum, size_t *checksumSize)
{
    size_t outputSize = (dataSize + 15) / 16 * 16;
    uint8_t *output = NULL;

    int result = posix_memalign((void **)&output, 64, outputSize);
    if (result != 0) {
        fprintf(stderr, "Failed to allocate output buffer: %i\n", result);
        exit(1);
    }

    memcpy(output, data, dataSize);

#if DEBUG
    printf("CHECKSUM SIZES: %zu", outputSize);
#endif

    do {
        size_t outputIdx = 0;
        size_t inputIdx = 0;

        while (inputIdx < outputSize) {
            output[outputIdx] = (output[inputIdx] == output[inputIdx + 1]) ? 1 : 0;
            outputIdx += 1;
            inputIdx += 2;
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
