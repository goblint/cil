#include "testharness.h"
typedef union
{
    struct
    {
        short leaf;
    };
    int raw;
} un;

typedef unsigned int uint32_t;
typedef unsigned long long int uint64_t;
typedef union
{
    struct
    {
        uint32_t leaf;
        uint32_t subleaf;
    };
    uint64_t raw;
} cpuid_config_leaf_subleaf_t;
typedef struct
{
    cpuid_config_leaf_subleaf_t leaf_subleaf;
} cpuid_lookup_t;
extern const cpuid_lookup_t cpuid_lookup[68];
const cpuid_lookup_t cpuid_lookup[68] = {
 [10] = { .leaf_subleaf = {.leaf = 0x0, .subleaf = 0xffffffff}}
};


un v = { .leaf = 13 };

typedef struct {
  struct {};
  struct {
    long a;
  };
} b;

b c = { .a = 0 };

struct S1 {
    struct {
        int a;
        int x;
    };

    struct {
        int b;
        int y;
    };

    struct {
        int c;
        int z;
    };
} s1 = {
    .a = 1,
    .b = 2,
    .c = 3,
    .x = 100,
    .y = 101,
    .z = 102
};

struct S2 {
    union {
        int a;
        int b;
    };

    union {
        struct {
            int c;
            int d;
        };

        struct {
            int e;
            int f;
        };
    };
} s2 = {
    .b = 100,
    .c = 500,
    .d = 600
};

struct S2 s2_2 = {
    .a = 1,
    .e = 2,
    .f = 3
};


struct Complicated {
    struct {
        int a;
    } s1;
    struct {
        int a;
    };
} c1 = {
    .s1 = { .a = 1 },
    .a = 2
};



int main() {
  if(s2.b != 100 || s2.c != 500 || s2.d != 600) {
    E(1);
  }
  if(s2_2.a != 1 || s2_2.e != 2 || s2_2.f != 3) {
    E(2);
  }
  if(s1.a != 1 || s1.b != 2 || s1.c != 3 || s1.x != 100 || s1.y != 101 || s1.z != 102) {
    E(3);
  }
  if(c.a != 0) {
    E(4);
  }
  if(v.leaf != 13) {
    E(5);
  }
  if(c1.a != 2 || c1.s1.a != 1) {
    E(6);
  }
  SUCCESS;
}
