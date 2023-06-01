#!/bin/sh

. ./config.sh
export ICONV_SRC_DIR=$WORKDIR/libiconv-1.17

for arch in aarch aarch64 i686 x86_64
do

PREFIX=${WORKDIR}/prefix_${arch}
PATH="${TOOLCHAIN_BASE_DIR}_${arch}/bin:${ORIGINAL_PATH}"

case $arch in
	"aarch"	)
		CLANG=arm-linux-androideabi-clang
        CXXLANG=arm-linux-androideabi-clang++
        HOST="arm-linux-android";;
	*		)
		CLANG=${arch}-linux-android-clang
		CXXLANG=${arch}-linux-android-clang++
		HOST="${arch}-linux-android";;
esac 

cd $ICONV_SRC_DIR
git checkout .
git clean -fdx
rm -rf tests/UCS*snippet
rm -rf tests/UTF*snippet
rm -rf tests/ISO*snippet

./gitsub.sh pull
sh autogen.sh
CC=${CLANG} CXX=${CXXLANG} ./configure --build=x86_64-linux-gnu --host=${HOST} --prefix=${PREFIX} --disable-rpath
make -j$THREADS
make install

done

