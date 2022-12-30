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

mkdir -p build
sed -i -e 's/elseif(IOS AND ARCH STREQUAL "arm64")/elseif(IOS AND ARCH STREQUAL "x86_64")\n     message(STATUS "IOS: Changing arch from x86_64 to x86-64")\n     set(ARCH_FLAG "-march=x86-64")\n  elseif(IOS AND ARCH STREQUAL "arm64")/g' CMakeLists.txt
sed -i -e 's/bool expand_transaction_1(transaction &tx, bool base_only)/void get_transaction_prefix_hash(const transaction_prefix\& tx, crypto::hash\& h)\n  {\n    std::ostringstream s;\n    binary_archive<true> a(s);\n    ::serialization::serialize(a, const_cast<transaction_prefix\&>(tx));\n    crypto::cn_fast_hash(s.str().data(), s.str().size(), h);\n  }\n\n  crypto::hash get_transaction_prefix_hash(const transaction_prefix\& tx)\n  {\n    crypto::hash h = crypto::null_hash;\n    get_transaction_prefix_hash(tx, h);\n    return h;\n  }\n\n  bool expand_transaction_1(transaction \&tx, bool base_only)/g' src/cryptonote_basic/cryptonote_format_utils.cpp
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
