/* Check side-effect order and targets across assembled statement chunks. */
static int order;

static int step(int digit) {
  order = order * 10 + digit;
  return digit;
}

static int run(int x) {
  int a = step(1);
  {
    int b = step(2);
    a += b;
  }
  goto entry;
  a = 100;
entry:
  a += step(3);
  switch (x) {
  case 0:
  case 1:
    a += step(4);
    break;
  case 2: {
    a += step(5);
    goto done;
  }
  default:
    a += step(6);
  }
  a += step(7);
done:
  while (a < 20) {
    a += step(8);
    break;
  }
  return a;
}

int main(void) {
  int x;
  for (x = 0; x < 4; ++x) {
    int result;
    order = 0;
    result = run(x);
    if (x < 2) {
      if (result != 25 || order != 123478) return 1;
    } else if (x == 2) {
      if (result != 19 || order != 12358) return 2;
    } else {
      if (result != 27 || order != 123678) return 3;
    }
  }
  return 0;
}
