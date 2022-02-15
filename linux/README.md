# Building the Linux Kernel
mk_linux.sh builds the atv-bootloader kernel and copies it up one directory.

Typically you only need to run this scripts once, 
then for further kernel builds, do the make and copy directly.

This could be fancer using Makefiles but sometimes simplicity is better.

# Building 2.6.39 on a modern system

I modified the build script in this directory so that this old kernel will compile on a new system. I tested this on Ubuntu 18.04, but since it's dockerized it should work on anything.

* The build environment is dockerized. Maybe it didn't have to be, but I didn't want an ancient version of GCC (4.8) kicking around on my host system.
* `atv-kernel.patch` patches the kernel so that it can be built without error.

When running `mk_linux.sh`, it'll ask you config questions. I accept the default on all of them.

As mentioned before, you should only run `mk_linux.sh` once, and further kernel rebuilds should use regular Makefiles. In the kernel source directory:

```
docker run --rm -it -v $(pwd):/build atv-kernel-builder make -j$(nproc --all)
```

