#!/bin/sh

. ./config.sh
SODIUM_SRC_DIR=${WORKDIR}/libsodium
SODIUM_BRANCH=1.0.16

for arch in "aarch" "aarch64" "i686" "x86_64"
do

PREFIX=${WORKDIR}/prefix_${arch}
PATH="${TOOLCHAIN_BASE_DIR}_${arch}/bin:${ORIGINAL_PATH}"

case $arch in
	"aarch"	) TARGET="arm";;
	"i686"		) TARGET="x86";;
	*		) TARGET="${arch}";;
esac  

HOST="${TARGET}-linux-android"
cd $WORKDIR
rm -rf $SODIUM_SRC_DIR
git clone ${LOCAL_GIT_REPOS}/libsodium $SODIUM_SRC_DIR -b $SODIUM_BRANCH
cd $SODIUM_SRC_DIR
git fetch
git reset --hard $SODIUM_BRANCH
./autogen.sh
CC=clang CXX=clang++ ./configure --prefix=${PREFIX} --host=${HOST} --enable-static --disable-shared
make -j$THREADS
make install

done

