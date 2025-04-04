#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

void* thread_func(void *arg) {
    printf("Thread: PID = %d, TID = %ld\n", getpid(), pthread_self());
    return NULL;
}

int main() {
    pthread_t tid;
    pthread_create(&tid, NULL, thread_func, NULL);
    pthread_join(tid, NULL);
    printf("Main thread: PID = %d\n", getpid());
    return 0;
}
