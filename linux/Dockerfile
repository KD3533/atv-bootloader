FROM ubuntu:bionic

WORKDIR /build

RUN apt-get update && apt-get -y install libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf gcc-4.8
RUN ln -fs $(which gcc-4.8) /usr/bin/gcc

