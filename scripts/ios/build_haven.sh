#!/bin/sh

. ./config.sh

HAVEN_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/haven"
BUILD_TYPE=release
PREFIX=${EXTERNAL_IOS_DIR}
DEST_LIB_DIR=${EXTERNAL_IOS_LIB_DIR}/haven
DEST_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR}/haven

cd $HAVEN_DIR_PATH
git submodule update --init --force
git checkout .
git clean -fdx

mkdir -p build
sed -i -e 's/ifdef TARGET_OS_OSX/ifndef TARGET_OS_OSX/g' external/randomx/src/virtual_memory.cpp
cd ..

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/haven
fi

for arch in "arm64" #"armv7" "arm64"
do

echo "Building IOS ${arch}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib"

case $arch in
	"armv7"	)
		DEST_LIB=../../lib-armv7;;
	"arm64"	)
		DEST_LIB=../../lib-armv8-a;;
esac

rm -rf haven/build > /dev/null

mkdir -p haven/build/${BUILD_TYPE}
pushd haven/build/${BUILD_TYPE}
cmake -D IOS=ON \
	-DARCH=${arch} \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DSTATIC=ON \
	-DBUILD_GUI_DEPS=ON \
	-DINSTALL_VENDORED_LIBUNBOUND=ON \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}  \
    -DUSE_DEVICE_TREZOR=OFF \
	../..
make -j4 && make install
cp src/cryptonote_basic/libcryptonote_basic.a ${DEST_LIB}
cp src/offshore/liboffshore.a ${DEST_LIB}
popd

done

#only for arm64
mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR
cp ${HAVEN_DIR_PATH}/lib-armv8-a/* $DEST_LIB_DIR
cp ${HAVEN_DIR_PATH}/include/wallet/api/* $DEST_INCLUDE_DIR