#include "testharness.h"

/* Test that integer promotions for bit-fields correctly account for the
   bit-field width (c.f. ISO 6.3.1.1).
   A bit-field whose values fit in int shall be promoted to int,
   regardless of the declared base type. */

struct X {
  long x : 7;   /* signed 7-bit: range fits in int -> promote to int */
} sx;

struct UX {
  unsigned long y : 7;  /* unsigned 7-bit: range [0,127] fits in int -> promote to int */
} usx;

int main() {
  /* _Generic selects based on type after integer promotion (ISO 6.5.1.1).
     For long : 7 bit-field, the promoted type should be int. */
  int r1 = _Generic(sx.x + 0, int : 1, default : -1);
  if (r1 != 1) E(1);

  /* Unary + also triggers integer promotion */
  int r2 = _Generic(+sx.x, int : 1, default : -1);
  if (r2 != 1) E(2);

  /* Unary - also triggers integer promotion */
  int r3 = _Generic(-sx.x, int : 1, default : -1);
  if (r3 != 1) E(3);

  /* Unary ~ also triggers integer promotion */
  int r4 = _Generic(~sx.x, int : 1, default : -1);
  if (r4 != 1) E(4);

  /* unsigned long : 7 should also promote to int (7-bit range [0,127] fits) */
  int r5 = _Generic(usx.y + 0, int : 1, default : -1);
  if (r5 != 1) E(5);

  /* Direct bit-field access as _Generic controlling expression */
  int r6 = _Generic(sx.x, int : 1, default : -1);
  if (r6 != 1) E(6);

  SUCCESS;
}
