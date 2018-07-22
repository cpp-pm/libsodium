#pragma GCC target("sse4.1")

#include <smmintrin.h>

int main(void)
{
  __m128i x = _mm_minpos_epu16(_mm_setzero_si128());
}
