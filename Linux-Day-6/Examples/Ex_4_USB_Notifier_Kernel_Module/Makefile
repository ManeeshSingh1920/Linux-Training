obj-m += kernel_module-usb-notifier.o

KDIR := /home/maneesh/Telechip_AOSP_10/mydroid/maincore/kernel
CROSS_COMPILE := /home/maneesh/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
ARCH := arm64

all:
	make -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	make -C $(KDIR) M=$(PWD) clean
