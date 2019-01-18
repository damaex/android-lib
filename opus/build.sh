#! /usr/bin/env bash

ANDROID_API=16
ANDROID_API_64=21
OPUS_FULL_VERSION="opus-1.3"

#create output dir
OUTPUT_DIR="build"
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}
ANDROID_LIB_ROOT=../${OUTPUT_DIR}

#configure options
OPUS_CONFIGURE_OPTIONS="--enable-float-approx --disable-shared --enable-static --with-pic --disable-extra-programs --disable-doc"

#Download
if [ ! -f "${OPUS_FULL_VERSION}.tar.gz" ]; then
    wget https://archive.mozilla.org/pub/opus/${OPUS_FULL_VERSION}.tar.gz
fi

#check Android NDK
if [ ! ${ANDROID_NDK} ]; then
	echo "ANDROID_NDK environment variable not set, set and rerun"
	exit 1
fi

#set ndk to path
export PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

echo "FUll Path: ${PATH}"

for ANDROID_TARGET_PLATFORM in arm arm64 x86 x86_64
do
	#extract (every run empty)
	tar -xzf ${OPUS_FULL_VERSION}.tar.gz
	
	#move to opus folder
	cd ${OPUS_FULL_VERSION};
	
	echo "Building libopus.a for ${ANDROID_TARGET_PLATFORM}"
     case "${ANDROID_TARGET_PLATFORM}" in
         arm)
             PLATFORM_OUTPUT_DIR=armeabi-v7a
             PRE_COMPILER=armv7a
			 COMPILER_API=eabi${ANDROID_API}
             ;;
         arm64)
             PLATFORM_OUTPUT_DIR=arm64-v8a
             PRE_COMPILER=aarch64
			 COMPILER_API=${ANDROID_API_64}
             ;;
         x86)
             PLATFORM_OUTPUT_DIR=x86
             PRE_COMPILER=i686
			 COMPILER_API=${ANDROID_API}
             ;;
         x86_64)
             PLATFORM_OUTPUT_DIR=x86_64
             PRE_COMPILER=x86_64
			 COMPILER_API=${ANDROID_API_64}
             ;;
         *)
             echo "Unsupported build platform:${ANDROID_TARGET_PLATFORM}"
             exit 1
     esac
	
	export CC=${PRE_COMPILER}-linux-android${COMPILER_API}-clang
	export CXX=${PRE_COMPILER}-linux-android${COMPILER_API}-clang++
	
	#run configuration for target platform
	./configure --host=${PRE_COMPILER}-linux-android${COMPILER_API} ${OPUS_CONFIGURE_OPTIONS}
	
	if [ $? -ne 0 ]; then
		echo "Error executing: ./configure --host=${PRE_COMPILER}-linux-android${COMPILER_API} ${OPUS_CONFIGURE_OPTIONS}"
		exit 1
	fi
	
	#run make with all system threads
    make -s -j$(nproc --all)
	
	if [ $? -ne 0 ]; then
		echo "Error executing make for platform:${ANDROID_TARGET_PLATFORM}"
		exit 1
	fi
	
	#create target folder
	mkdir -p "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/bin"
	mkdir -p "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/include"
	
	#move created library
	mv .libs/libopus.a "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/bin"
	
	#copy headers
    cp -r "include" "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/"
	
	#move out again
	cd ..
	
	#remove build folder and toolchain for empty start
	rm -rf ${OPUS_FULL_VERSION}
done

#compress
cd ${OUTPUT_DIR}
tar -czvf ../opus-android.tar.gz *
cd ..

#remove archive
rm ${OPUS_FULL_VERSION}.tar.gz
