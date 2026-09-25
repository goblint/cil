#include "testharness.h"

int main(void) {
start:
  asm goto ("nop" : : : : start, exit);
exit:
  SUCCESS;
}