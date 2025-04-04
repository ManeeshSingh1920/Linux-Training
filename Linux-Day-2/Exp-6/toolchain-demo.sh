#!/bin/bash
# 1. Show toolchain structure
echo "=== Toolchain Binaries ==="
ls /usr/bin/arm-linux-gnueabi-* | column

# 2. Demonstrate compilation pipeline
echo -e "\n=== Compilation Test ==="
echo 'int main(){return 0;}' > test.c
arm-linux-gnueabi-gcc -v test.c -o test 2>&1 | grep "COLLECT_GCC_OPTIONS"

# 3. Show library linking
echo -e "\n=== Library Paths ==="
arm-linux-gnueabi-gcc -print-search-dirs | grep libraries

# 4. Verify architecture
echo -e "\n=== File Verification ==="
file test

# 5. Cleanup
rm test.o test
