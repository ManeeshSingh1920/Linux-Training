export these values before running make

export KDIR=</path/to/Telechip_kernel/source>
export CROSS_COMPILE=</path/to/Telechip_Toolchain/bin/aarch64-none-linux-gnu->
make


example ->
export KDIR := /home/maneesh/Telechip_AOSP_10/mydroid/maincore/kernel
export CROSS_COMPILE := /home/maneesh/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

if u want to uset then ->
unset KDIR
unset CROSS_COMPILE 
