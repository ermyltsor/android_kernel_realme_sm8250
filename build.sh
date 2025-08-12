#!/bin/bash

#
# Download zyc clang-10.0.1, if needed
# download link: https://github.com/ZyCromerZ/Clang/releases/download/10.0.1-20220724-release/Clang-10.0.1-20220724.tar.gz
#

# This is my work environment, for reference only.
# debian-stable
# sudo apt install -y build-essential binutils-aarch64-linux-gnu bc bison flex libssl-dev libelf-dev python3 python3-distutils git wget curl ca-certificates gcc make rsync libncurses-dev gcc-aarch64-linux-gnu cpio unzip

# history build output
if [ -d out ]; then
    echo "Delete the existing out folder."
    rm -rf out
else
    echo "Not found out folder."
fi

# find history anykernel.zip
if find anykernel -maxdepth 1 -type f -name "*.zip" | grep -q .; then
    echo "Delete the history anykernel.zip file."
    find anykernel -maxdepth 1 -type f -name "*.zip" -delete
else
    echo "No history exists anykernel.zip."
fi

echo "The kernel will be built in 5 seconds."

sleep 5

# Fake username
#export KBUILD_BUILD_USER= 

# Fake Hostname
export KBUILD_BUILD_HOST=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# Custom Clang-tools
export CLANG_PATH=$HOME/clang-10.0.1/bin
export PATH=$CLANG_PATH:$PATH
export CROSS_COMPILE=aarch64-linux-gnu-

# Create output directory
mkdir -p out

KERNEL_DEFCONFIG=vendor/kona-perf_defconfig
ANYKERNEL_NAME=rui5.0-stock

echo
echo "Kernel is going to be built using $KERNEL_DEFCONFIG."
echo

MAKE_FLAGS="ARCH=arm64 AR=llvm-ar CC=clang NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LLVM=1 O=out"

make $MAKE_FLAGS $KERNEL_DEFCONFIG

make $MAKE_FLAGS -j$(nproc)

echo "Build Complete."

echo "Enter the anykernel directory after 5 seconds."
sleep 5
cd anykernel

echo "Copy Image, dtb, dtbo.img from output to the anykernel folder."

cp ../out/arch/arm64/boot/Image .
cp ../out/arch/arm64/boot/dtb .
cp ../out/arch/arm64/boot/dtbo.img .

echo "Compress everything in the anykernel folder into a zip file."
zip -qr "$ANYKERNEL_NAME.zip" *

echo "Return to the root directory of the kernel tree."
cd ..

sleep 2
echo "Delete Image, dtb, and dtbo.img from the anykernel folder"
rm anykernel/Image
rm anykernel/dtb
rm anykernel/dtbo.img

echo "You can find the $ANYKERNEL_NAME.zip in anykernel folder."
