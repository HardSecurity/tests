#include <stdio.h>
#include <pthread.h>
#include <sys/time.h>
#include <sys/resource.h>

static void *start(void *str)
{
  void *arr[2] = {(void*) 1, (void*) 2};
  void *val = arr[((int)str) % 2];
  printf("%p\n", val);
  return val;
}

int main(int argc, char **argv)
{
  int           i;
  pthread_t     thread;
  struct rlimit rlim;

  rlim.rlim_cur = 1024 * 1024;
  rlim.rlim_max = 1024 * 1024;
  setrlimit(RLIMIT_STACK, &rlim);

  rlim.rlim_cur = 70 * 1024 * 1024;
  rlim.rlim_max = 70 * 1024 * 1024;
  setrlimit(RLIMIT_AS, &rlim);

  for (i = 0; i < 100000; ++i) {
    if (pthread_create(&thread, NULL, start, argv[0])) {
      fprintf(stderr, "pthread_create(): %m\n");
      return 1;
    }
    pthread_join(thread, NULL);
  }

  printf("Hello %s\n", argv[0]);
  return 0;
}
