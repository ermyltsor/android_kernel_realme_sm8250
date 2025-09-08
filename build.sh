#!/bin/bash

# Fake build username
# export KBUILD_BUILD_USER= 

# Fake build hostname
export KBUILD_BUILD_HOST=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# Clean up the last build output
if [ -d out ]; then
    rm -rf out
fi

export ARCH=arm64

# Catch the Google clang tools we needed
if [ -d clang-r383902 ]; then
    echo "the clang tools is existing!"
else
    mkdir clang-r383902
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android-gs-raviole-5.10-android12-d1/clang-r383902.tar.gz
    tar -xzf clang-r383902.tar.gz -C clang-r383902
    rm clang-r383902.tar.gz
fi

export CLANG_PATH=$PWD/clang-r383902/bin
export CLANG_TRIPLE=aarch64-linux-gnu-

# Catch the Google gcc tools we needed
if [ -d gcc64-tools ]; then
    echo "the gcc tools is existing!"
else
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc64-tools
fi

export GCC64_PATH=$PWD/gcc64-tools/bin
export CROSS_COMPILE=aarch64-linux-android-

export PATH=$CLANG_PATH:$GCC64_PATH:$PATH

# Create output directory
mkdir out

# The defconfig we needed
KERNEL_DEFCONFIG=vendor/kona-perf_defconfig

echo
echo "Kernel is going to be built using $KERNEL_DEFCONFIG."
echo

MAKE_FLAGS="CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 \
    AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    O=out"

make $MAKE_FLAGS $KERNEL_DEFCONFIG

make $MAKE_FLAGS -j$(nproc)

echo "Build Complete."
echo
echo "The kernel build for realme GT Exp. Master Edition(RMX3366) and realme GT Neo2(RMX3370), base on Android 11 with realme UI 2.0"