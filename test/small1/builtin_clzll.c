struct S1 {
    int x : __builtin_choose_expr(__builtin_clzll(1) == 63, 1, -1),
          : __builtin_choose_expr(__builtin_clzll(2) == 62, 1, -1),
          : __builtin_choose_expr(__builtin_clzll(4) == 61, 1, -1),
          : __builtin_choose_expr(__builtin_clzll(1024) == 53, 1, -1),
          : __builtin_choose_expr(__builtin_clzll(1024 * 1024) == 43, 1, -1);
} s1 = {0};

int main() {
    return 0;
}