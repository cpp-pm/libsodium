#ifdef __native_client__
# error NativeClient detected - Avoiding AVX512F opcodes
#endif

#pragma GCC target("avx512f")

#include <immintrin.h>

int main(void)
{
  __m512i x = _mm512_setzero_epi32();
  __m512i y = _mm512_permutexvar_epi64(_mm512_setr_epi64(0, 1, 4, 5, 2, 3, 6, 7), x);
}
