#!/bin/sh

set -e

. ./config.sh
OPENSSL_SRC_DIR=$WORKDIR/openssl-1.1.1q
ZLIB_DIR=$WORKDIR/zlib

cd $ZLIB_DIR
git checkout .
git clean -fdx
rm -rf boringssl/fuzz
rm -rf fuzz

CC=clang CXX=clang++ ./configure --static
make

for arch in "aarch" "aarch64" "i686" "x86_64"
do
PREFIX=$WORKDIR/prefix_${arch}
TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
PATH="${TOOLCHAIN}/bin:${ORIGINAL_PATH}"

case $arch in
	"aarch")   X_ARCH="android-arm";;
	"aarch64") X_ARCH="android-arm64";;
	"i686")    X_ARCH="android-x86";;
	"x86_64")  X_ARCH="android-x86_64";;
	*)	   X_ARCH="android-${arch}";;
esac 	

cd $OPENSSL_SRC_DIR

git submodule update --init --force
git checkout .
git clean -fdx

CC=clang ANDROID_NDK=$TOOLCHAIN \
	./Configure ${X_ARCH} \
	no-shared no-tests \
	--with-zlib-include=${PREFIX}/include \
	--with-zlib-lib=${PREFIX}/lib \
	--prefix=${PREFIX} \
	--openssldir=${PREFIX} \
	-D__ANDROID_API__=$API 
make -j$THREADS
make -j$THREADS install_sw

done

