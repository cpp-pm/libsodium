#ifdef __native_client__
# error NativeClient detected - Avoiding AVX opcodes
#endif

#pragma GCC target("avx")

#include <immintrin.h>

int main(void)
{
  _mm256_zeroall();
}
