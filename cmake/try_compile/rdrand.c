#ifdef __native_client__
# error NativeClient detected - Avoiding RDRAND opcodes
#endif

#pragma GCC target("rdrnd")

#include <immintrin.h>

int main(void)
{
  unsigned long long x;
  _rdrand64_step(&x);
}
