#include "testharness.h"

int main(int argc, char **argv)
{
  int i = 0;
  int k = 0;

  do {
    i++;
    if(i == 1) { continue; }
    k = 8;
  } while ( i < 1);

  printf("i is: %i\n", i);
  if(i != 1) E(1);
  if(k != 0) E(2);
  SUCCESS;
}
