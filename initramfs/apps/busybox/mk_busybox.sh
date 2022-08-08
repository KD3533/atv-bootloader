#!/bin/bash

VERSION="1.35.0"

if [ ! -f busybox-"${VERSION}".tar.bz2 ] ; then
	wget http://busybox.net/downloads/busybox-${VERSION}.tar.bz2
fi

tar -xjf busybox-"${VERSION}".tar.bz2
# cd busybox.config busybox-"${VERSION}"
# cp busybox.config busybox-"${VERSION}"/.config

cd busybox-"${VERSION}"
# make oldconfig
make defconfig
make
make install

cd ..

if [ ! -d build/ ] ; then
	mkdir build
fi

rm -rf build/*
cp -arp busybox-"${VERSION}"/_install/* build/

rm -rf busybox-"${VERSION}"
