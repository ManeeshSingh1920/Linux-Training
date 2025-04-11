#include <stdio.h>
#include <stdlib.h>

void memory_leak() {
    int *arr = (int *)malloc(10 * sizeof(int));  // Allocate memory for 10 integers
    if (arr == NULL) {
        printf("Memory allocation failed!\n");
        return;
    }

    arr[0] = 5;  // Use the allocated memory
    // Forgot to free the memory - memory leak occurs here
}

void invalid_access() {
    int *arr = (int *)malloc(10 * sizeof(int));  // Allocate memory for 10 integers
    if (arr == NULL) {
        printf("Memory allocation failed!\n");
        return;
    }

    arr[0] = 10;  // Use the allocated memory
    free(arr);     // Free the memory

    // Accessing the memory after free - invalid memory access
    arr[1] = 20;   // This will be detected as invalid memory access
}

int main() {
    memory_leak();   // Calling memory leak function
    invalid_access();  // Calling invalid memory access function

    return 0;
}

