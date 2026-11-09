# Out-of-tree build of the btusb.c that prepare-source leaves in this
# directory. The object list lives in Kbuild because DKMS passes
# KERNELRELEASE to make, which would hide an obj-m set here.
KERNEL_BUILD_DIRECTORY ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KERNEL_BUILD_DIRECTORY) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KERNEL_BUILD_DIRECTORY) M=$(CURDIR) clean
