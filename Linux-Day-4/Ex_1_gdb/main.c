#include <stdio.h>
#include "math_utils.h"

int main() {
    int a = 10;
    int b = 0;  // Intentional bug: will cause divide by zero
    int result;

    printf("Calling divide(%d, %d)\n", a, b);
    result = divide(a, b);  // This will crash
    printf("Result: %d\n", result);

    return 0;
}

