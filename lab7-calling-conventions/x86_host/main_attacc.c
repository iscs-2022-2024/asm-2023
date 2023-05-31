#include <stdio.h>

int main() {
  int i = 0;

  for (i = 0; i < 8; ++i)
    printf("%s", "\x4c\x92\x04\x08");

  return 0;
}
