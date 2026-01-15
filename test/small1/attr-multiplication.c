struct S1 {
    char a;
} __attribute__((aligned(sizeof(short) * sizeof(int))));


struct S2 {
    int x: __builtin_choose_expr(__alignof__ (struct S1) == sizeof(short) * sizeof(int), 1, -1);
} s2;