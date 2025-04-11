obj-m += panic_mod.o

KDIR ?= ../../kernel

# Cross-compile toolchain for ARM
ARCH := arm
CROSS_COMPILE := arm-linux-gnueabi-
	
all:
	# Building the kernel module using ARM toolchain and kernel source
	make -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	# Clean up the build
	make -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

	
