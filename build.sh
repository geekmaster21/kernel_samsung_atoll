#!/bin/bash

echo "Setting Up Environment"
echo ""
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=neel0210
export KBUILD_BUILD_HOST=Catelina

# Variables
export TC="/home/neel/Desktop/toolchain/"
export VMTC="$(pwd)/clang"

# Enforcing
A52="a52_defconfig"
A72="a72_defconfig"
clear
echo "---------------------------"
echo checking if bulding offline
echo "---------------------------"
if [ -d "$TC" ]; then
	echo "building offline; thus exporting paths"
	export CROSS_COMPILE=/home/neel/Desktop/toolchain/19/bin/aarch64-linux-android-
	export CLANG_TRIPLE=/home/neel/Desktop/toolchain/14/bin/aarch64-linux-gnu-
	export CC=/home/neel/Desktop/toolchain/14/clang
	export CCACHE_EXEC="/usr/bin/ccache"
	export USE_CCACHE=1
	ccache -M 50G
	export CCACHE_COMPRESS=1
	export CCACHE_DIR="/home/neel/Desktop/ccache/.ccache"
else
	echo "Not finding Toolchains at Home/toolchains; thus clonning them; would take some couple of minutes"
	if [ -d "$VMTC" ]; then
		echo exporting paths
		export CROSS_COMPILE=$(pwd)/linaro/bin/aarch64-linux-android-
		export CLANG_TRIPLE=$(pwd)/clang/bin/aarch64-linux-gnu-
		export CC=$(pwd)/clang/bin/clang
	else
		git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --single-branch -b lineage-19.0 linaro
		git clone --depth=1 https://github.com/xiangfeidexiaohuo/Snapdragon-LLVM.git clang
		export CROSS_COMPILE=$(pwd)/linaro/bin/aarch64-linux-android-	
		export CROSS_COMPILE_ARM32=$(pwd)/gcc32/bin/arm-linux-androideabi-		
		export CLANG_TRIPLE=$(pwd)/clang/bin/aarch64-linux-gnu-
		export CC=$(pwd)/clang/bin/clang
	fi
fi
clear
echo "========================="
echo "Remove old Kernel Build"
echo "========================="
rm -rf CORE/*.zip
############################################
# If other device make change here
############################################
clear
echo "==============="
echo "Building Clean"
echo "==============="
# Clean build leftovers
make clean && make mrproper
rm -rf A52
rm -rf A72
clear
echo "======================="
echo "Building Clean for A52"
echo "======================="
make $A52 O=A52 CC=clang
make -j$(nproc --all) O=A52 CC=clang
echo
Image5="$(pwd)/A52/arch/arm64/boot/Image"
if [ -f "$Image5" ]; then
	echo "Image compiled; packing it"
	cp -r ./A52/arch/arm64/boot/Image ./CORE/Image
	rm -rf CORE/*.zip
	cd CORE
	. zip5.sh
	cd ..
	changelog=`cat CORE/changelog5.txt`
	cd CORE
	for i in KakarotKernel*.zip
	do
	curl -F "document=@$i" --form-string "caption=$changelog" "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument?chat_id=${CHAT_ID}&parse_mode=HTML"
	done
	echo ""
	cd ..
	rm -rf CORE/*.zip
else
    echo "Kernel isnt compiled, letting Neel know"
    curl -F text="Samsung A52: Kernel is not compiled, come and check @neel0210" "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&parse_mode=Markdown"
fi
echo "======================="
echo "Building Clean for A72"
echo "======================="
make $A72 O=A72 CC=clang
make -j$(nproc --all) O=A72 CC=clang
echo
Image7="$(pwd)/A72/arch/arm64/boot/Image"
if [ -f "$Image7" ]; then
	echo "Image compiled; packing it"
	cp -r ./A72/arch/arm64/boot/Image ./CORE/Image
	rm -rf CORE/*.zip
	cd CORE
	. zip7.sh
	cd ..
	changelog=`cat CORE/changelog7.txt`
	cd CORE
	for i in KakarotKernel*.zip
	do
	curl -F "document=@$i" --form-string "caption=$changelog" "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument?chat_id=${CHAT_ID}&parse_mode=HTML"
	done
	echo ""
	cd ..
	rm -rf CORE/*.zip
else
    echo "Kernel isnt compiled, letting Neel know"
    curl -F text="Samsung A72: Kernel is not compiled, come and check @neel0210" "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&parse_mode=Markdown"
fi
# End