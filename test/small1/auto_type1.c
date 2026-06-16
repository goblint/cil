struct dummmy {
    char arr[0x0bad];
};

extern volatile struct dummmy side_effect1;
struct dummmy side_effect2(struct dummmy);

void *fn() {
    __auto_type x = side_effect2(side_effect1);
    static struct S1 {
        int a : __builtin_choose_expr(sizeof(x) == 0x0bad, 1, -1);
    } s1 = {0};
    return &s1;
}
