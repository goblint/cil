#include "testharness.h"
#include <stdnoreturn.h>

_Static_assert (2 <= 18);
_Static_assert (2 <= 18, "blubb");

struct S {
    int x;
    _Static_assert (2 <= 18);
    _Static_assert (2 <= 18, "blubb");
};

int main() {
    _Static_assert (2 <= 18);
    _Static_assert (2 <= 18, "blubb");
    SUCCESS;
}
