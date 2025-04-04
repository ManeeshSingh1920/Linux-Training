#!/bin/bash

echo -e '#include <stdio.h>\nint global_var;\nint main(){static int x; return 0;}' > newtest.c
# 1. Compile
arm-linux-gnueabi-gcc -g -o newtest.elf newtest.c

# 2. Show ELF structure
echo "=== ELF Header ==="
arm-linux-gnueabi-readelf -h newtest.elf | grep -E 'Magic|Class|Machine'

# 3. Show sections
echo -e "\n=== Sections ==="
arm-linux-gnueabi-size newtest.elf

# 4. Disassemble main()
echo -e "\n=== Disassembly ==="
arm-linux-gnueabi-objdump -d -j .text newtest.elf | grep -A20 "<main>:"

# 5. Show variables
echo -e "\n=== Variables ==="
arm-linux-gnueabi-objdump -t newtest.elf | grep -E 'global_var|x'
# 5. Cleanup
rm newtest.o newtest
