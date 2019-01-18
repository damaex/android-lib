# android-lib
[![Build Status](https://travis-ci.org/damaex/android-lib.svg?branch=master)](https://travis-ci.org/damaex/android-lib)

build all external libs for android (unix based)

## libraries
- openssl 1.1.1a
- opus-1.3
- libzip (ff55682b2cb85f3bd53813cddc7c6afb94c7572c)

## requirements
- Android NDK (https://developer.android.com/ndk/downloads/)
- make & cmake
	- `sudo apt install make cmake`

## build
```bash
export ANDROID_NDK="/home/user/android-ndk-r19" #path to android ndk
./build.sh
```