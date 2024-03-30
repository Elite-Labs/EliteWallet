#!/bin/sh

. ./config.sh

WOWNERO_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/wownero"

BUILD_TYPE=release
PREFIX=${EXTERNAL_IOS_DIR}
DEST_LIB_DIR=${EXTERNAL_IOS_LIB_DIR}/wownero
DEST_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR}/wownero

cd $WOWNERO_DIR_PATH
git submodule update --init --force
git checkout .
git clean -fdx

git apply --stat --apply ${EW_ROOT}/patches/wownero/refresh_thread.patch
git apply --stat --apply ${EW_ROOT}/patches/wownero/bugfix.patch
git apply --stat --apply ${EW_ROOT}/patches/wownero/wow-ios-sim.patch

mkdir -p build
cd ..

echo $DEST_LIB_DIR
mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/wownero
fi

for arch in "x86_64" #"armv7" "arm64"
do

echo "Building IOS ${arch}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib"

case $arch in
	"x86_64")
		DEST_LIB=../../lib-x86_64;;
	"armv7"	)
		DEST_LIB=../../lib-armv7;;
	"arm64"	)
		DEST_LIB=../../lib-armv8-a;;
esac

rm -rf wownero/build > /dev/null

mkdir -p wownero/build/${BUILD_TYPE}
pushd wownero/build/${BUILD_TYPE}
cmake -D IOS=ON \
	-DIOS_PLATFORM=SIMULATOR64 \
	-DARCH=${arch} \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DSTATIC=ON \
	-DBUILD_GUI_DEPS=ON \
	-DUNBOUND_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR} \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}  \
    -DUSE_DEVICE_TREZOR=OFF \
	../..
make wallet_api -j$(nproc) && make install
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \;
cp -r ./lib/* $DEST_LIB_DIR
cp src/cryptonote_basic/libcryptonote_basic.a ${DEST_LIB}
cp src/offshore/liboffshore.a ${DEST_LIB}
popd

done

#only for arm64
mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR
cp ${WOWNERO_DIR_PATH}/lib-x86_64/* $DEST_LIB_DIR
cp ${WOWNERO_DIR_PATH}/include/wallet/api/* $DEST_INCLUDE_DIR
