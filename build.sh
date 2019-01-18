#! /usr/bin/env bash

cd openssl
bash build.sh
if [ $? -ne 0 ]; then
	echo "Error: Build openssl"
	exit 1
fi

cd ../opus
bash build.sh
if [ $? -ne 0 ]; then
	echo "Error: Build opus"
	exit 1
fi

cd ../zip
bash build.sh
if [ $? -ne 0 ]; then
	echo "Error: Build zip"
	exit 1
fi

cd ..

mkdir -p "build"
mv openssl/openssl-android.tar.gz build/
mv opus/opus-android.tar.gz build/
mv zip/zip-android.tar.gz build/