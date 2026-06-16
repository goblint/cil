#define ASSERT_TYPE3(_expr, _type, _c) \
    struct assertType##_c { \
        int x: _Generic(_expr, _type : 1, default : -1); \
    } assertValue##_c = {0}
#define ASSERT_TYPE2(_expr, _type, _c) ASSERT_TYPE3(_expr, _type, _c)
#define ASSERT_TYPE(_expr, _type) ASSERT_TYPE2(_expr, _type, __COUNTER__)

void fn1(const int arg[128]) {
    const int local[128] = {0};

    typeof(arg) ptr4;
    typeof(local) ptr5 = {0};
    __auto_type ptr6 = arg;
    __auto_type ptr7 = local;

    ASSERT_TYPE(&ptr4, const int **);
    ASSERT_TYPE(&ptr5, const int (*)[128]);
    ASSERT_TYPE(&ptr6, const int **);
    ASSERT_TYPE(&ptr7, const int **);
}

int main() {
    int arg[128] = {0};
    fn1(arg);
    return 0;
}