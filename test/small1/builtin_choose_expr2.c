// Both bitfield widths shall be evaluated constantly
struct S1 {
    int x : __builtin_choose_expr(sizeof(long) > sizeof(int) || sizeof(int) > sizeof(short), 1, 2),
        y : __builtin_choose_expr(sizeof(char) > sizeof(short) && sizeof(char) == sizeof(char), 3, 4);
} s1;
