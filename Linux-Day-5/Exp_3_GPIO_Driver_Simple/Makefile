obj-m += simple-gpio-driver.o

KDIR ?= ../../kernel  
CROSS_COMPILE ?= aarch64-none-linux-gnu-

# Get current working directory
PWD := $(shell pwd)

all:
	make -C $(KDIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) modules

clean:
	make -C $(KDIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) clean
