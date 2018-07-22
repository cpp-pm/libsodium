#pragma GCC target("ssse3")

#include <tmmintrin.h>

int main(void)
{
  __m64 x = _mm_abs_pi32(_m_from_int(0));
}
