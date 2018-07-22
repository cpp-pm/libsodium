#ifdef __native_client__
# error NativeClient detected - Avoiding AESNI opcodes
#endif

#pragma GCC target("aes")
#pragma GCC target("pclmul")

#include <wmmintrin.h>

int main(void)
{
  __m128i x = _mm_aesimc_si128(_mm_setzero_si128());
  __m128i y = _mm_clmulepi64_si128(_mm_setzero_si128(), _mm_setzero_si128(), 0);
}
