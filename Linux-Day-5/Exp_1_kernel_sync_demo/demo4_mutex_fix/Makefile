obj-m += main.o

# Default: build without Synchronization method (i.e., use plain counter)
USE_SYNC ?= 0

ccflags-y += $(if $(filter 1,$(USE_SYNC)),-DUSE_SYNC,)

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
	



