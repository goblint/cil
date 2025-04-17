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
