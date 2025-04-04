#!/bin/bash
echo "=== ARM Toolchain Demo ==="

# 1. Show compiler info
echo -e "\n[1] Compiler Version:"
arm-linux-gnueabi-gcc --version

# 2. Show include paths 
echo -e "\n[2] Include Paths:"
arm-linux-gnueabi-gcc -xc -E -v /dev/null 2>&1 | grep -A5 "#include <...> search" | grep -v "search starts"

# 3. Compile test program
echo -e "\n[3] Compiling test.c:"
cat <<EOF > test.c
#include <stdio.h>
int main() { printf("ARM test\\n"); return 0; }
EOF
arm-linux-gnueabi-gcc test.c -o test_arm

# 4. Verify output
echo -e "\n[4] File Verification:"
file test_arm
echo -e "\n[5] Library Dependencies:"
arm-linux-gnueabi-readelf -d test_arm | grep "Shared library"

# 5. Cleanup
rm test.o test_arm
