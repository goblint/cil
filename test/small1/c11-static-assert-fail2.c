#include "testharness.h"

int main() {
    _Static_assert (2 > 18, "blubb");
    SUCCESS;
}
