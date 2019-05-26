#! /usr/bin/env bash
mkdir -p "build"

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
