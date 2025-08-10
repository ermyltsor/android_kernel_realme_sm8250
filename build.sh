#!/bin/bash

#
# Download zyc clang-10.0.1, if needed
# download link: https://github.com/ZyCromerZ/Clang/releases/download/10.0.1-20220724-release/Clang-10.0.1-20220724.tar.gz
#

# This is my work environment, for reference only.
# debian-stable
# sudo apt install -y build-essential binutils-aarch64-linux-gnu bc bison flex libssl-dev libelf-dev python3 python3-distutils git wget curl ca-certificates gcc make rsync libncurses-dev gcc-aarch64-linux-gnu cpio unzip

export ARCH=arm64
export SUBARCH=arm64

# Custom Clang Path
export CLANG_PATH=$HOME/clang-10.0.1/bin
export PATH=$CLANG_PATH:$PATH

export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Fake username
#export KBUILD_BUILD_USER= 

# Fake Hostname
export KBUILD_BUILD_HOST=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# Create output directory
mkdir -p $PWD/out

KERNEL_DEFCONFIG=vendor/kona-perf_defconfig

echo
echo "Kernel is going to be built using $KERNEL_DEFCONFIG"
echo

make $KERNEL_DEFCONFIG \
    AR=llvm-ar \
    CC=clang \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    LLVM=1 \
    O=$PWD/out

make -j$(nproc) \
    AR=llvm-ar \
    CC=clang \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    LLVM=1 \
    O=$PWD/out
