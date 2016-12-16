#ifndef CHECKSUM_H
#define CHECKSUM_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

void checksumData(uint8_t *data, size_t dataSize, uint8_t **checksum, size_t *checksumSize);

#ifdef __cplusplus
}
#endif

#endif /* CHECKSUM_H */
