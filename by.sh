#! /bin/bash

# Copyright (C) 2021-2022 rk134
# Thanks to eun0115, starlight5234 and ghostmaster69-dev
export DEVICE="Vince"
export CONFIG="vince-perf_defconfig"
export TC_PATH="/workspace/q/toolchains"
export CHANNEL_ID=""
export TELEGRAM_TOKEN=""
export ZIP_DIR="$(pwd)/Anykernel3"
export KERNEL_DIR=$(pwd)
export GCC_COMPILE="yes"
export KBUILD_BUILD_USER="wastingmylife"
export KBUILD_BUILD_HOST="noidea"

# FUNCTIONS

# Upload buildlog to group
tg_erlog()
{
	ERLOG=$HOME/build/build${BUILD}.txt
	curl -F document=@"$ERLOG"  "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
			-F chat_id=$CHANNEL_ID \
			-F caption="Build ran into errors after $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds, plox check logs"
}

# Upload zip to channel
tg_pushzip() 
{
	FZIP=$ZIP_DIR/$ZIP
	curl -F document=@"$FZIP"  "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
			-F chat_id=$CHANNEL_ID 
}

# Send Updates
function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id="${CHANNEL_ID}" \
		-d "disable_web_page_preview=true"
}

# Clone the toolchains and export required information
function clone_tc() {
[ -d ${TC_PATH} ] || mkdir ${TC_PATH}

if [ "$GCC_COMPILE" == "no" ]; then
	git clone --depth=1 https://github.com/kdrag0n/proton-clang.git ${TC_PATH}/clang
	export PATH="${TC_PATH}/clang/bin:$PATH"
	export STRIP="${TC_PATH}/clang/aarch64-linux-gnu/bin/strip"
	export COMPILER="Clang 14.0.0"
else
    git clone --depth=1 https://github.com/wastingmylife/gcc64 ${TC_PATH}/gcc64
	git clone --depth=1 https://github.com/wastingmylife/gcc32 ${TC_PATH}/gcc32
	export PATH="${TC_PATH}/gcc64/bin:${TC_PATH}/gcc32/bin:$PATH"
	export STRIP="${TC_PATH}/gcc64/aarch64-elf/bin/strip"
	export COMPILER="Arter97's GCC Compiler" 
fi
}
# Send Updates
function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id="${CHANNEL_ID}" \
		-d "disable_web_page_preview=true"
}

# Send a sticker
function start_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker" \
        -d sticker="CAACAgQAAxkBAAEDIYdhctPrAm1Ydl3sFori9vNNnjAoigAC9AkAAl79YVHW7zfYKT9-XyEE" \
        -d chat_id=$CHANNEL_ID
}

function error_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker" \
        -d sticker="$STICKER" \
        -d chat_id=$CHANNEL_ID
}

# Compile this kernel
function compile() {
DATE=`date`
BUILD_START=$(date +"%s")
make O=out ARCH=arm64 vince-perf_defconfig
make -j$(nproc --all) O=out \
                ARCH=arm64 \
			    CROSS_COMPILE=aarch64-elf- \
			    CROSS_COMPILE_ARM32=arm-eabi- |& tee -a $HOME/build/build${BUILD}.txt

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
}

# Zip this kernel
function make_flashable() {
    
cd $ZIP_DIR
dir
rm -rf zIm*
rm -rf Winds*
cp $KERN_IMG $ZIP_DIR/zImage
if [ "$BRANCH" == "windstorm" ]; then
    zip -r9 Windstorm-kernel-[Rivalist].zip * -x .git README.md *placeholder
elif [ "$BRANCH" == "beta" ]; then
    zip -r9 Windstorm-kernel-[Test].zip * -x .git README.md *placeholder
else
    zip -r9 Windstorm-kernel-[unavailable].zip * -x .git README.md *placeholder
fi
ZIP=$(echo *.zip)
tg_pushzip

}

# Credits: @madeofgreat
BTXT="$HOME/build/buildno.txt" #BTXT is Build number TeXT
if ! [ -a "$BTXT" ]; then
	mkdir $HOME/build
	touch $HOME/build/buildno.txt
	echo $RANDOM > $BTXT
fi

BUILD=$(cat $BTXT)
BUILD=$(($BUILD + 1))
echo ${BUILD} > $BTXT

# Sticker selection
stick=$(($RANDOM % 5))

if [ "$stick" == "0" ]; then
	STICKER="CAACAgIAAxkBAAEDIWhhcssHSMR1HTAHtKOby21tVafvWgAC_gADVp29CtoEYTAu-df_IQQ"
elif [ "$stick" == "1" ];then
	STICKER="CAACAgIAAxkBAAEDIXlhcsvK31evc58huNXRZnSWf62R2AAC_w4AAhSUAAFL2_NFL9rIYIAhBA"
elif [ "$stick" == "2" ];then
	STICKER="CAACAgUAAxkBAAEDIXthcsvYV4zwNP0ousx1ULwkKGRdygACIAADYOojP1RURqxGbEhrIQQ"
elif [ "$stick" == "3" ];then
	STICKER="CAACAgUAAxkBAAEDIX1hcsvr8e6DUr1J4KmHCtI98gx1xwACNgADP9jqMxV1oXRlrlnXIQQ"
elif [ "$stick" == "4" ];then
	STICKER="CAACAgEAAxkBAAEDIYFhcswQNqw8ZPubg7zGQkNhaYGTBAACKwIAAvx0QESn-U6NZyYYfSEE"
fi

#-----------------------------------------------------------------------------------------------------------#
clone_tc
COMMIT=$(git log --pretty=format:'"%h : %s"' -1)
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
KERNEL_DIR=$(pwd)
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
CONFIG_PATH=$KERNEL_DIR/arch/arm64/configs/$CONFIG
VENDOR_MODULEDIR="$ZIP_DIR/modules/vendor/lib/modules"
export KERN_VER=$(echo "$(make kernelversion --no-print-directory)")
make mrproper && rm -rf out
start_sticker
tg_sendinfo "$(echo -e "======= <b>$DEVICE</b> =======\n
Build-Host   :- <code>$KBUILD_BUILD_HOST</code>
Build-User   :- <code>$KBUILD_BUILD_USER</code>\n 
Version      :- <u><code>$KERN_VER</code></u>
Compiler     :- <code>$COMPILER</code>\n
on Branch    :- <code>$BRANCH</code>
Commit       :- <code>$COMMIT</code>\n")"

compile
if ! [ -a "$KERN_IMG" ]; then
	tg_erlog && error_sticker
	exit 1
else
	make_flashable
	tg_pushlink
fi

cd $ZIP_DIR
rm -rf zIm*
rm -rf Winds*
cd ../
rm -rf out