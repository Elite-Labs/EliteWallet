#!/bin/sh

. ./config.sh

MONERO_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/monero"
BUILD_TYPE=release
PREFIX=${EXTERNAL_IOS_DIR}
DEST_LIB_DIR=${EXTERNAL_IOS_LIB_DIR}/monero
DEST_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR}/monero

cd $MONERO_DIR_PATH
git submodule update --init --force
git checkout .
git clean -fdx
git revert eff4dc2be6d8bd1cb565141bbfce66e2bf697a4c --no-edit
git reset HEAD~1

mkdir -p build
sed -i -e 's/elseif(IOS AND ARCH STREQUAL "arm64")/elseif(IOS AND ARCH STREQUAL "x86_64")\n     message(STATUS "IOS: Changing arch from x86_64 to x86-64")\n     set(ARCH_FLAG "-march=x86-64")\n  elseif(IOS AND ARCH STREQUAL "arm64")/g' CMakeLists.txt
cd ..

mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/monero
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

rm -r monero/build > /dev/null

mkdir -p monero/build/${BUILD_TYPE}
pushd monero/build/${BUILD_TYPE}
cmake -D IOS=ON \
	-DIOS_PLATFORM=SIMULATOR64 \
	-DARCH=${arch} \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DSTATIC=ON \
	-DBUILD_GUI_DEPS=ON \
	-DUNBOUND_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR} \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}  \
    -DUSE_DEVICE_TREZOR=OFF \
    -DMANUAL_SUBMODULES=1 \
	../..
make wallet_api -j4
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \;
cp -r ./lib/* $DEST_LIB_DIR
cp ../../src/wallet/api/wallet2_api.h  $DEST_INCLUDE_DIR
popd

done
