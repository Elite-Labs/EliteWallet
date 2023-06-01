#!/bin/bash

. ./config.sh

EXPAT_SRC_DIR=$WORKDIR/libexpat

for arch in "aarch" "aarch64" "i686" "x86_64"
do
PREFIX=$WORKDIR/prefix_${arch}
TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
PATH="${TOOLCHAIN_BASE_DIR}_${arch}/bin:${ORIGINAL_PATH}"

cd $EXPAT_SRC_DIR
git submodule update --init --force
git checkout .
git clean -fdx

cd $EXPAT_SRC_DIR/expat

case $arch in
	"aarch")   HOST="arm-linux-androideabi";;
	"i686")    HOST="x86-linux-android";;
	*)	       HOST="${arch}-linux-android";;
esac 

./buildconf.sh
CC=clang CXX=clang++ ./configure --enable-static --disable-shared --prefix=${PREFIX} --host=${HOST}
make -j$THREADS
make -j$THREADS install
done

UNBOUND_SRC_DIR=$WORKDIR/unbound-1.16.2

for arch in "aarch" "aarch64" "i686" "x86_64"
do
PREFIX=$WORKDIR/prefix_${arch}
TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64

case $arch in
	"aarch")   TOOLCHAIN_BIN_PATH=${TOOLCHAIN_BASE_DIR}_${arch}/arm-linux-androideabi/bin;;
	*)	       TOOLCHAIN_BIN_PATH=${TOOLCHAIN_BASE_DIR}_${arch}/${arch}-linux-android/bin;;
esac 

PATH="${TOOLCHAIN_BIN_PATH}:${TOOLCHAIN_BASE_DIR}_${arch}/bin:${ORIGINAL_PATH}"
cd $UNBOUND_SRC_DIR
git submodule update --init --force
git checkout .
git clean -fdx
rm -rf contrib/unbound_smf23.tar.gz
rm -rf contrib/libunbound.so.conf
rm -rf contrib/unbound_cacti.tar.gz
rm -rf winrc/gen_msg.bin

case $arch in
	"aarch")   HOST="arm-linux-androideabi";;
	"i686")    HOST="x86-linux-android";;
	*)	       HOST="${arch}-linux-android";;
esac

CC=clang CXX=clang++ ./configure --prefix=${PREFIX} --host=${HOST} --enable-static --disable-shared --disable-flto --with-ssl=${PREFIX} --with-libexpat=${PREFIX}
make -j$THREADS
make -j$THREADS install
done
