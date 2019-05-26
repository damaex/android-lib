#! /usr/bin/env bash

ANDROID_API=16
ANDROID_API_64=21
OPENSSL_FULL_VERSION="openssl-1.1.1b"

#create output dir
OUTPUT_DIR="build"
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}
ANDROID_LIB_ROOT=../${OUTPUT_DIR}

#configure options
OPENSSL_CONFIGURE_OPTIONS="no-pic no-idea no-camellia \
        no-seed no-bf no-cast no-rc2 no-rc4 no-rc5 no-md2 \
        no-md4 no-sock no-ssl3 \
        no-dsa no-tls1 \
        no-rfc3779 no-whirlpool no-srp \
        no-mdc2 no-engine \
        no-comp no-hw no-srtp -fPIC"

#Download
if [ ! -f "${OPENSSL_FULL_VERSION}.tar.gz" ]; then
    wget https://www.openssl.org/source/${OPENSSL_FULL_VERSION}.tar.gz
fi

#check Android NDK
if [ ! ${ANDROID_NDK} ]; then
	echo "ANDROID_NDK environment variable not set, set and rerun"
	exit 1
fi

#set ndk to path
#export PATH=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

echo "FUll Path: ${PATH}"

for ANDROID_TARGET_PLATFORM in android-arm android-arm64 android-x86 android-x86_64
do
	#extract (every run empty)
	tar -xzf ${OPENSSL_FULL_VERSION}.tar.gz
	
	#move to openssl folder
	cd ${OPENSSL_FULL_VERSION};
	
	echo "Building libcrypto.a and libssl.a for ${ANDROID_TARGET_PLATFORM}"
     case "${ANDROID_TARGET_PLATFORM}" in
         android-arm)
             PLATFORM_OUTPUT_DIR=armeabi-v7a
             ANDROID_API_VERSION=${ANDROID_API}
             ;;
         android-arm64)
             PLATFORM_OUTPUT_DIR=arm64-v8a
             ANDROID_API_VERSION=${ANDROID_API_64}
             ;;
         android-x86)
             PLATFORM_OUTPUT_DIR=x86
             ANDROID_API_VERSION=${ANDROID_API}
             ;;
         android-x86_64)
             PLATFORM_OUTPUT_DIR=x86_64
             ANDROID_API_VERSION=${ANDROID_API_64}
             ;;
         *)
             echo "Unsupported build platform:${ANDROID_TARGET_PLATFORM}"
             exit 1
     esac
	
	#run configuration for target platform
	./Configure ${ANDROID_TARGET_PLATFORM} -D__ANDROID_API__=${ANDROID_API_VERSION} ${OPENSSL_CONFIGURE_OPTIONS}
	
	if [ $? -ne 0 ]; then
		echo "Error executing:./Configure ${ANDROID_TARGET_PLATFORM} ${OPENSSL_CONFIGURE_OPTIONS}"
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
	mkdir -p "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/include/openssl"
	
	#move created librarys
	mv libcrypto.a "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/bin"
    mv libssl.a "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/bin"
	
	#copy headers
    cp -r "include/openssl" "${ANDROID_LIB_ROOT}/${PLATFORM_OUTPUT_DIR}/include/"
	
	#move out again
	cd ..
	
	#remove build folder for empty start
	rm -rf ${OPENSSL_FULL_VERSION}
done

#compress
cd ${OUTPUT_DIR}
tar -czvf ../../build/${OPENSSL_FULL_VERSION}-android.tar.gz *
cd ..

#remove archive
rm ${OPENSSL_FULL_VERSION}.tar.gz
