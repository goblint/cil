#include "testharness.h"

void code() {
  asm goto ("nop" : : : : start, exit);
  E(1);
}