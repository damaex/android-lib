# android-lib
[![Build Status](https://travis-ci.org/damaex/android-lib.svg?branch=master)](https://travis-ci.org/damaex/android-lib)

prebuild some libs for android (unix based)

## libraries
- openssl 1.1.1c
- opus 1.3.1
- libzip 1.5.2

## requirements
- Android NDK (https://developer.android.com/ndk/downloads/)
- make & cmake
	- `sudo apt install make cmake`

## build
```bash
export ANDROID_NDK="/home/user/android-ndk-r19c" #path to android ndk
./build.sh
```