// threads.c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

void* thread_func(void* arg) {
    while (1) {
        printf("Thread %ld is running...\n", (long)arg);
        sleep(2);
    }
    return NULL;
}

int main() {
    pthread_t t1, t2;
    pthread_create(&t1, NULL, thread_func, (void*)1);
    pthread_create(&t2, NULL, thread_func, (void*)2);

    while (1) {
        printf("Main thread is running...\n");
        sleep(2);
    }
}

