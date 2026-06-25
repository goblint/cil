#include "testharness.h"

struct S {
    int x;
    _Static_assert (2 > 18, "blubb");
};

int main() {
    SUCCESS;
}
