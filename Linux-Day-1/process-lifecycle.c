#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>

int main() {
    printf("Process started\n");

    pid_t pid = fork();

    if (pid < 0) {
        perror("Fork failed");
        return 1;
    } else if (pid == 0) {
        // Child process
        printf("Child Process:\n");
        printf("  PID: %d\n", getpid());
        printf("  PPID: %d\n", getppid());
        sleep(2);  // Simulate some work
        printf("Child exiting...\n");
        exit(0);
    } else {
        // Parent process
        printf("Parent Process:\n");
        printf("  PID: %d\n", getpid());
        printf("  Child PID: %d\n", pid);
        wait(NULL);  // Wait for child to exit
        printf("Parent exiting after child.\n");
    }

    return 0;
}
