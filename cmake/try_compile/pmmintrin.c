#pragma GCC target("sse3")

#include <pmmintrin.h>

int main(void)
{
  __m128 x = _mm_addsub_ps(
      _mm_cvtpd_ps(_mm_setzero_pd()), _mm_cvtpd_ps(_mm_setzero_pd())
  );
}
