#include "checksum.h"
#include "common.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#ifndef DEBUG
#define DEBUG 0
#endif

int main(int argc, char **argv)
{
    // Ensure proper input
    if (argc != 3) {
        fprintf(stderr, "You must supply an initial state and disk size\n");
        exit(1);
    }

    // Parse the initial state
    char *stateString = argv[1];

    size_t inputSize = strlen(stateString);
    uint8_t *input = (uint8_t *)malloc(sizeof(uint8_t) * inputSize);
    for (size_t idx = 0; idx < inputSize; idx++) {
        input[idx] = (stateString[idx] == '0') ? 0 : 1;
    }

#if DEBUG
    printData("INPUT", input, inputSize);
#endif

    // Generate the data
    size_t diskSize = atoi(argv[2]);

    uint8_t *data = NULL;
    size_t dataSize = 0;

    generate(input, inputSize, diskSize, &data, &dataSize);

#if DEBUG
    if (diskSize <= 100) {
        printData("OUTPUT", data, dataSize);
        printData("DATA", data, diskSize);
    } else {
        printf("Skipping disk data because it is too large\n");
    }
#endif

    uint8_t *checksum = NULL;
    size_t checksumSize = 0;
    struct timespec start, stop;

    clock_gettime(CLOCK_MONOTONIC, &start);
    checksumData(data, diskSize, &checksum, &checksumSize);
    clock_gettime(CLOCK_MONOTONIC, &stop);

    printData("CHECK", checksum, checksumSize);

    uint64_t durationUs = timespecDiff(stop, start);
    printf("Duration: %llu μs\n", durationUs);

    free(input);
    free(data);
    free(checksum);

    return 0;
}
