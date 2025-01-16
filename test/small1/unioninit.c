typedef union
{
    struct
    {
        short leaf;
    };
    int raw;
} un;


un v = { .leaf = 0 };

int main(int i) {
  return 5;
}
