#! /usr/bin/env bash

ANDROID_API=16
ANDROID_API_64=21
ZIP_FULL_VERSION="libzip-1.8.0"

#create output dir
OUTPUT_DIR="$(pwd)/build"
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

#Download
if [ ! -f "${ZIP_FULL_VERSION}.tar.gz" ]; then
    wget https://libzip.org/download/${ZIP_FULL_VERSION}.tar.gz
fi

#check Android NDK
if [ ! ${ANDROID_NDK} ]; then
	echo "ANDROID_NDK environment variable not set, set and rerun"
	exit 1
fi

#extract
tar -xzf ${ZIP_FULL_VERSION}.tar.gz

#move to zip folder
cd ${ZIP_FULL_VERSION};

for ANDROID_TARGET_PLATFORM in armeabi-v7a arm64-v8a x86 x86_64
do
	mkdir -p "build-${ANDROID_TARGET_PLATFORM}"
	cd "build-${ANDROID_TARGET_PLATFORM}"
	
	if [ "$ANDROID_TARGET_PLATFORM" == "armeabi-v7a" ] || [ "$ANDROID_TARGET_PLATFORM" == "x86" ] ; then
		ANDROID_API_VERSION=${ANDROID_API}
	else
		ANDROID_API_VERSION=${ANDROID_API_64}
	fi
	
	echo "Building libzip.a for ${ANDROID_TARGET_PLATFORM}"
	echo "using API-Level ${ANDROID_API_VERSION}"
	
	#run configuration for target platform
	cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
		-DCMAKE_INSTALL_PREFIX:PATH=${OUTPUT_DIR}/${ANDROID_TARGET_PLATFORM} \
		-DANDROID_ABI=${ANDROID_TARGET_PLATFORM} \
		-DANDROID_PLATFORM=${ANDROID_API_VERSION} \
		-DENABLE_OPENSSL:BOOL=OFF \
		-DENABLE_COMMONCRYPTO:BOOL=OFF \
		-DENABLE_GNUTLS:BOOL=OFF \
		-DENABLE_MBEDTLS:BOOL=OFF \
		-DENABLE_WINDOWS_CRYPTO:BOOL=OFF \
		-DBUILD_TOOLS:BOOL=OFF \
		-DBUILD_REGRESS:BOOL=OFF \
		-DBUILD_EXAMPLES:BOOL=OFF \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DBUILD_DOC:BOOL=OFF \
		-DANDROID_TOOLCHAIN=clang ..
	
	if [ $? -ne 0 ]; then
		echo "Error executing: cmake"
		exit 1
	fi
	
	#run make with all system threads and install to output dir
	make install -j$(nproc --all)
	
	if [ $? -ne 0 ]; then
		echo "Error executing make install for platform: ${ANDROID_TARGET_PLATFORM}"
		exit 1
	fi
	
	#move out again
	cd ..
done

cd ..

#compress
cd ${OUTPUT_DIR}
tar -czf ../../build/${ZIP_FULL_VERSION}-android.tar.gz *
cd ..

#remove folder
rm -rf ${ZIP_FULL_VERSION}
rm -rf ${OUTPUT_DIR}

#remove archive
rm ${ZIP_FULL_VERSION}.tar.gz
