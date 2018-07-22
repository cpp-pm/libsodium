#ifdef __native_client__
# error NativeClient detected - Avoiding AVX2 opcodes
#endif

#pragma GCC target("avx2")

#include <immintrin.h>

int main(void)
{
  __m256 x = _mm256_set1_ps(3.14);
  __m256 y = _mm256_permutevar8x32_ps(x, _mm256_set1_epi32(42));
  return _mm256_movemask_ps(_mm256_cmp_ps(x, y, _CMP_NEQ_OQ));
}
