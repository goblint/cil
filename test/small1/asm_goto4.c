#include "testharness.h"

void code() {
start:
  asm("nop" : : : : start, exit);
exit:
  E(1);
}