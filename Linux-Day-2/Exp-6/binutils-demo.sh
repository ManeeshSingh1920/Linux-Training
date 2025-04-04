# List all ARM tools
ls /usr/bin/arm-linux-gnueabi-*

# Verify objdump (shows ARM architecture)
arm-linux-gnueabi-objdump --version | head -n1

# Example: Disassemble a file
echo 'int main(){return 0;}' > test.c
arm-linux-gnueabi-gcc -c test.c
arm-linux-gnueabi-objdump -d test.o

# 5. Cleanup
rm test.o 
