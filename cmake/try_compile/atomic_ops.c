int main(void)
{
  static volatile int _sodium_lock;
  __sync_lock_test_and_set(&_sodium_lock, 1);
  __sync_lock_release(&_sodium_lock);
}
