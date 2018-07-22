#include <string.h>

int main(void)
{
  char dummy[42];
  (void) memset_s(dummy, (rsize_t) sizeof dummy, 0, (rsize_t) sizeof dummy);
}
