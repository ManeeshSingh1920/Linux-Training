#include <stdio.h>
#include <unistd.h>  // for getpid()

int main() {
    printf("Hello from user space!\n");

    // This system call enters kernel space to fetch the process ID
    pid_t pid = getpid();
    printf("My process ID (from kernel): %d\n", pid);

    return 0;
}
