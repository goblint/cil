#include "testharness.h"

void code() {
  asm goto ("nop" : : : );
  E(1);
}