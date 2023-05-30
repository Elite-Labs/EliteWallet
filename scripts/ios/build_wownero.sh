#!/bin/sh

. ./config.sh

WOWNERO_URL="${LOCAL_GIT_REPOS}/wownero"
WOWNERO_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/wownero"
WOWNERO_VERSION=v0.11.0.3
WOWNERO_SHA_HEAD="e921c3b8a35bc497ef92c4735e778e918b4c4f99"

BUILD_TYPE=release
PREFIX=${EXTERNAL_IOS_DIR}
DEST_LIB_DIR=${EXTERNAL_IOS_LIB_DIR}/wownero
DEST_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR}/wownero

echo "Cloning wownero from - $WOWNERO_URL to - $WOWNERO_DIR_PATH"		
git clone ${WOWNERO_URL} ${WOWNERO_DIR_PATH} --branch ${WOWNERO_VERSION}
cd $WOWNERO_DIR_PATH
git reset --hard $WOWNERO_SHA_HEAD
git fetch
git checkout .
git reset --hard HEAD
git checkout $WOWNERO_VERSION

LOCAL_GIT_REPOS_FORMATTED=$(echo $LOCAL_GIT_REPOS | sed -e "s/\//\\\\\//g")
sed -i -e "s/https:\/\/github.com\/miniupnp\/miniupnp/${LOCAL_GIT_REPOS_FORMATTED}\/miniupnp/g" .gitmodules
sed -i -e "s/https:\/\/github.com\/Tencent\/rapidjson/${LOCAL_GIT_REPOS_FORMATTED}\/rapidjson/g" .gitmodules
sed -i -e "s/https:\/\/github.com\/trezor\/trezor-common.git/${LOCAL_GIT_REPOS_FORMATTED}\/trezor-common/g" .gitmodules
sed -i -e "s/https:\/\/github.com\/monero-project\/supercop/${LOCAL_GIT_REPOS_FORMATTED}\/supercop/g" .gitmodules
sed -i -e "s/https:\/\/git.wownero.com\/wownero\/RandomWOW/${LOCAL_GIT_REPOS_FORMATTED}\/RandomWOW/g" .gitmodules

git submodule update --init --force
git apply --stat --apply ${CW_ROOT}/patches/wownero/refresh_thread.patch
mkdir -p build
cd ..

echo $DEST_LIB_DIR
mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/wownero
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

rm -rf wownero/build > /dev/null

mkdir -p wownero/build/${BUILD_TYPE}
pushd wownero/build/${BUILD_TYPE}
cmake -D IOS=ON \
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
cp ${WOWNERO_DIR_PATH}/lib-armv8-a/* $DEST_LIB_DIR
cp ${WOWNERO_DIR_PATH}/include/wallet/api/* $DEST_INCLUDE_DIR
