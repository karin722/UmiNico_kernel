#!/bin/bash

#set -e

DATE_POSTFIX=$(date +"%Y%m%d")

## Copy this script inside the kernel directory
KERNEL_DIR=$PWD
KERNEL_TOOLCHAIN=$ANDROIDDIR/kernel/prebuilts/aarch64-elf-gcc-9.2.0/bin/aarch64-elf-
ARM32_TOOLCHAIN=$ANDROIDDIR/kernel/prebuilts/arm-eabi-gcc-9.2.0/bin/arm-eabi-
KERNEL_DEFCONFIG=beryllium_defconfig
ANY_KERNEL3_DIR=$KERNEL_DIR/AnyKernel3/
FINAL_KERNEL_ZIP=Optimus_Drunk_Beryllium-$DATE_POSTFIX.zip
# Speed up build process
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

echo "**** Setting Toolchain ****"
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
export CROSS_COMPILE_ARM32=$ARM32_TOOLCHAIN
export ARCH=arm64
export SUBARCH=arm64

# Clean build always lol
echo "**** Cleaning ****"
mkdir -p out
make O=out clean

echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
echo -e "$blue***********************************************"
echo "          BUILDING KERNEL          "
echo -e "***********************************************$nocol"
make $KERNEL_DEFCONFIG O=out
make -j$(nproc --all) O=out

echo "**** Verify Image.gz-dtb ****"
ls $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb

#Anykernel 2 time!!
echo "**** Verifying AnyKernel3 Directory ****"
ls $ANY_KERNEL3_DIR
echo "**** Removing leftovers ****"
rm -rf $ANY_KERNEL3_DIR/Image.gz-dtb
rm -rf $ANY_KERNEL3_DIR/$FINAL_KERNEL_ZIP

echo "**** Copying Image.gz-dtb ****"
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANY_KERNEL3_DIR/

echo "**** Time to zip up! ****"
cd $ANY_KERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $KERNEL_DIR/AnyKernel3/$FINAL_KERNEL_ZIP $ANDROIDDIR/kernel/$FINAL_KERNEL_ZIP

echo "**** Good Bye!! ****"
cd $KERNEL_DIR
rm -rf $ANY_KERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf AnyKernel3/Image.gz-dtb
rm -rf $KERNEL_DIR/out/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
