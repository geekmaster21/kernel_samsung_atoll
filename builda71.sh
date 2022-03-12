#!/bin/bash

# Check if have toolchain/llvm folder
if [ ! -d "$(pwd)/gcc/" ]; then
   git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --single-branch -b lineage-18.0 gcc
fi

if [ ! -d "$(pwd)/llvm-sdclang/" ]; then
   git clone --depth=1 https://github.com/kdrag0n/proton-clang.git llvm-sdclang
fi

# Export KBUILD flags
export KBUILD_BUILD_USER="Geekmaster21"
export KBUILD_BUILD_HOST="OVH"

# Export ARCH/SUBARCH flags
export ARCH="arm64"
export SUBARCH="arm64"

# Export ANDROID VERSION
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"
# Export CCACHE

# Export toolchain/clang/llvm flags
export CROSS_COMPILE="$(pwd)/gcc/bin/aarch64-linux-androidkernel-"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CC="$(pwd)/llvm-sdclang/bin/clang"

# Export if/else outdir var
export WITH_OUTDIR=true

# Clear the console
clear

# Build time
if [ "${WITH_OUTDIR}" == true ]; then
   if [ ! -d "$(pwd)/a71" ]; then
      mkdir a71
   fi
fi

if [ "${WITH_OUTDIR}" == true ]; then
   make -j$(nproc --all) O=a71 a71_defconfig $KERNEL_MAKE_ENV CC=clang
   make -j$(nproc --all) O=a71 $KERNEL_MAKE_ENV CC=clang
   tools/mkdtimg create a71/arch/arm64/boot/dtbo.img --page_size=4096 $(find a71/arch -name "*.dtbo")
fi
