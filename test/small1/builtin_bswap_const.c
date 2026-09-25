#include "testharness.h"

int main (void)
{
  switch (1) {
    case (__builtin_bswap16(256)):
      break;
    default:
      E(1);
  }

  SUCCESS;
}
