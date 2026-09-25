#include "testharness.h"

int main() {
  asm goto ("nop");
  E(1);
}