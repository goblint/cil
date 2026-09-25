/* Test for typedef and variable name conflict (issue #114).
   A variable with the same name as a typedef should shadow it in its initializer,
   per C11 6.2.1.7: "Any other identifier has scope that begins just after the
   completion of its declarator." */
#include "testharness.h"
#include <stdint.h>
#include <stdlib.h>

typedef struct raxNode {
    uint32_t iskey:1;
    uint32_t isnull:1;
    uint32_t iscompr:1;
    uint32_t size:29;
    unsigned char data[];
} raxNode;

typedef struct rax {
    raxNode *head;
    uint64_t numele;
    uint64_t numnodes;
} rax;

typedef int mytype;
typedef int T;

int main() {
  rax *rax = malloc(sizeof(*rax)); /* variable rax shadows typedef rax in initializer */
  if (rax == 0) E(1);
  free(rax);

  /* NO_INIT variable in the middle of a declaration list shadows a typedef.
     After "mytype a = 1, mytype", the name "mytype" is an identifier (variable).
     So "b = sizeof mytype" (without parens) is only valid when mytype is a variable
     (types require parens: "sizeof(type)").  This fails to parse without the fix. */
  {
    mytype a = 1, mytype, b = sizeof mytype;
    mytype = 5;
    if (a != 1) E(2);
    if (mytype != 5) E(3);
    if (b != sizeof(int)) E(4);
  }

  /* Chain initialization: after "T T = 1", T is registered as a variable by the
     lexer hack, so the subsequent initializer "U = T + 1" sees T as a variable
     (value 1), not as a type name.  This fails to parse without the fix because
     "T + 1" would be a syntax error when T is a NAMED_TYPE. */
  {
    T T = 1, U = T + 1;
    if (T != 1) E(5);
    if (U != 2) E(6);
  }

  SUCCESS;
}
