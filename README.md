# android-lib
[![Build Status](https://travis-ci.org/damaex/android-lib.svg?branch=master)](https://travis-ci.org/damaex/android-lib)

prebuild some libs for android (unix based)

architectures: `android-arm`, `android-arm64`, `android-x86`, `android-x86_64`

## libraries

| library | version |
| ------- | ------- |
| openssl | 1.1.1g  |
| opus    | 1.3.1   |
| libzip  | 1.6.1   |

## requirements
- Android NDK (https://developer.android.com/ndk/downloads/)
- make & cmake
	- `sudo apt install make cmake`

## build
```bash
export ANDROID_NDK="/home/user/android-ndk-r21" #path to android ndk
./build.sh
```
