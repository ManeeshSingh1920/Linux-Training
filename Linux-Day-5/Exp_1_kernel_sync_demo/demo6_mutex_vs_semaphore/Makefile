obj-m += main.o

MODE ?= mutex

ifeq ($(MODE),mutex)
    ccflags-y += -DUSE_MUTEX
else ifeq ($(MODE),semaphore)
    ccflags-y += -DUSE_SEMAPHORE
endif

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

