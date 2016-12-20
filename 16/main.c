#include "checksum.h"
#include "common.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <time.h>

#ifndef DEBUG
#define DEBUG 0
#endif

#ifndef RUNS
#define RUNS 100
#endif

#define MIN(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

#define MAX(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

static int durationUsCompare(const void *lhsPointer, const void *rhsPointer);

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
    char nameBuffer[64];

    uint64_t *durationsUs = (uint64_t *)malloc(sizeof(uint64_t) * RUNS);
    int durationsUsIndex = 0;

    uint64_t minDurationUs = UINT64_MAX;
    uint64_t maxDurationUs = 0;
    uint64_t totalDurationsUs = 0;

    for (int run = 0; run < RUNS; run++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        checksumData(data, diskSize, &checksum, &checksumSize);
        clock_gettime(CLOCK_MONOTONIC, &stop);

        snprintf(nameBuffer, 64, "CHECKSUM %i", run);
        printData("Checksum", checksum, checksumSize);

        uint64_t durationUs = timespecDiff(stop, start);
        printf("Duration %i: %llu μs\n", run, durationUs);

        minDurationUs = MIN(minDurationUs, durationUs);
        maxDurationUs = MAX(maxDurationUs, durationUs);
        totalDurationsUs += durationUs;

        durationsUs[durationsUsIndex] = durationUs;
        durationsUsIndex += 1;

        free(checksum);
    }

    printf("-------\n");
    printf("Min Duration: %" PRIu64 " μs\n", minDurationUs);
    printf("Max Duration: %" PRIu64 " μs\n", maxDurationUs);

    qsort(durationsUs, RUNS, sizeof(uint64_t), durationUsCompare);
    printf("Median Duration: %" PRIu64 " μs\n", durationsUs[RUNS / 2]);

    double averageDurationUs = (double)totalDurationsUs / (double)RUNS;
    printf("Mean Duration: %f\n", averageDurationUs);

    free(durationsUs);
    free(input);
    free(data);

    return 0;
}

static int durationUsCompare(const void *lhs, const void *rhs)
{
    return (*(uint64_t *)lhs - *(uint64_t *)rhs);
}
