#!/bin/bash

# Step 1: Create a C file with hello world code
echo 'Creating hello_telechip.c...'
cat <<EOF > hello_telechip.c
#include <stdio.h>
int main() {
   // printf() displays the string inside quotation
   printf("Hello, Telechip!\n");
   return 0;
}
EOF
echo 'C file created.'

# Step 2: Set the path to your GCC toolchain
export PATH=~/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:\$PATH
echo "Toolchain path set to: ~/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin"

#export PATH=~/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin:\$PATH
#echo "Toolchain path set to: ~/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin"


# Step 3: Compile the code using the cross-compiler
echo 'Compiling hello_telechip.c...'
aarch64-none-linux-gnu-gcc -static hello_telechip.c -o hello_telechip

# Step 4: Confirm the result
if [ -f "hello_telechip" ]; then
    echo 'Compilation successful! Executable: hello_telechip'
else
    echo 'Compilation failed.'
fi

