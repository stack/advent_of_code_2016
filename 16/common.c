#include "common.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void generate(uint8_t *input, size_t inputSize, size_t targetSize, uint8_t **output, size_t *outputSize)
{
    // Determine the final size of the data
    size_t finalSize = inputSize;
    while (finalSize < targetSize) {
        finalSize = (finalSize * 2) + 1;
    }

    // Generate the final output buffer
    size_t alignedFinalSize = (finalSize + 15) / 16 * 16;
    uint8_t *finalOutput = NULL;
    int result = posix_memalign((void **)&finalOutput, 16, alignedFinalSize);

    if (result != 0) {
        fprintf(stderr, "Failed to create generation buffer: %i\n", result);
        exit(1);
    }

    // Copy the original input into the final output buffer
    memcpy(finalOutput, input, inputSize);

    // Generate all of the data
    size_t currentSize = inputSize;
    while (currentSize < finalSize) {
        // Append the 0
        finalOutput[currentSize] = 0;

        // Append the reversed, inverted data
        size_t currentIndex = 0;
        size_t reversedIndex = currentSize * 2;

        while (currentIndex < currentSize) {
            finalOutput[reversedIndex] = (finalOutput[currentIndex] == 0) ? 1 : 0;
            currentIndex += 1;
            reversedIndex -= 1;
        }

        // Increment
        currentSize = (currentSize * 2) + 1; 
    }

    // Set the output
    *output = finalOutput;
    *outputSize = finalSize;
}

void printData(const char *tag, uint8_t *data, size_t dataSize)
{
    printf("%s:", tag);

    for (size_t idx = 0; idx < dataSize; idx++) {
        printf(" %i", data[idx]);
    }

    printf(" (%zu)\n", dataSize);
}

uint64_t timespecDiff(struct timespec lhs, struct timespec rhs)
{
    struct timespec delta;

    if (lhs.tv_nsec < rhs.tv_nsec) {
        delta.tv_sec = lhs.tv_sec - rhs.tv_sec - 1;
        delta.tv_nsec = 1000000000L + lhs.tv_nsec - rhs.tv_nsec;
    } else {
        delta.tv_sec = lhs.tv_sec - rhs.tv_sec;
        delta.tv_nsec = lhs.tv_nsec - rhs.tv_nsec;
    }

    return (delta.tv_sec * 1000000L) + (delta.tv_nsec / 1000L);
}

