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

int main(int i) {
  return 5;
}
