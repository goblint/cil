void infinite_loop()
{
label1:
  asm goto (
    "jmp %l0"
    : /* No outputs. */
    : /* No inputs */
    : /* No clobbers */
    : label1);
}

void conditionally_infinite_loop(int x) {
label1:
  asm goto (
    "test %0, %0\n"
    "jz %l1\n"
    "jmp %l2"
    : /* No outputs. */
    : "r"(x)
    : /* No clobbers */
    : label1, label2);
label2: ;
}
