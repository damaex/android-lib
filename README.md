# android-lib
![Build Status](https://github.com/damaex/android-lib/actions/workflows/build.yml/badge.svg)

prebuild some libs for android (unix based)

architectures: `android-arm`, `android-arm64`, `android-x86`, `android-x86_64`

## libraries

| library | version |
| ------- | ------- |
| openssl | 3.0.1   |
| opus    | 1.3.1   |
| libzip  | 1.8.0   |

## requirements
- Android NDK (https://developer.android.com/ndk/downloads/)
- make & cmake
	- `sudo apt install make cmake`

## build
```bash
export ANDROID_NDK="/home/user/android-ndk-r23b" #path to android ndk
./build.sh
```
