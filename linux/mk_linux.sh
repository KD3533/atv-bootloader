#!/bin/bash -x

SCRIPT_DIR=$(dirname `readlink -f "$0"`)
cd "${SCRIPT_DIR}"

VERSION="5.15.41"
CONFIG="linux-${VERSION}.config"

if [ ! -f linux-${VERSION}.tar.xz ] ; then
	wget http://www.kernel.org/pub/linux/kernel/v5.x/linux-${VERSION}.tar.xz
fi

tar -xvf linux-${VERSION}.tar.xz

if [ -f "${CONFIG}" ] ; then
	cp "${CONFIG}"  linux-${VERSION}/.config
else
	cp linux.config  linux-${VERSION}/.config
fi
#
cd  linux-${VERSION}
make olddefconfig && make prepare
make

#
cd "${SCRIPT_DIR}"
cp linux-${VERSION}/arch/x86/boot/bzImage ../vmlinuz
