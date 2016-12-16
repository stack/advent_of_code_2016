#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

void generate(uint8_t *input, size_t inputSize, size_t targetSize, uint8_t **output, size_t *outputSize);
void printData(const char *tag, uint8_t *data, size_t dataSize);
uint64_t timespecDiff(struct timespec lhs, struct timespec rhs);

#ifdef __cplusplus
}
#endif

#endif /* COMMON_H */
