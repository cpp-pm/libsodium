#pragma GCC target("sse2")

#include <emmintrin.h>

int main(void)
{
  __m128d x = _mm_setzero_pd();
}
