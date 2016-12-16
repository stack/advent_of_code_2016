#include "common.h"

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static uint8_t generateInput[] = { 1, 0, 0, 0, 0 };
size_t generateInputSize = 5;

static uint8_t generateOutput11[] = { 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0 };
size_t generateOutput11Size = 11;

static uint8_t generateOutput23[] = { 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0 };
size_t generateOutput23Size = 23;

int main(int argc, char **argv)
{
    uint8_t *output;
    size_t outputSize;

    printf("Testing `generate`... ");

    generate(generateInput, generateInputSize, 11, &output, &outputSize);

    assert(output != NULL);
    assert(outputSize == generateOutput11Size);
    assert(memcmp(output, generateOutput11, generateOutput11Size) == 0);

    free(output);

    generate(generateInput, generateInputSize, 20, &output, &outputSize);

    assert(output != NULL);
    assert(outputSize == generateOutput23Size);
    assert(memcmp(output, generateOutput23, generateOutput23Size) == 0);

    free(output);

    printf("Success!\n");

    return 0;
}
