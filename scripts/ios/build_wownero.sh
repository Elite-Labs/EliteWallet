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
git clone $WOWNERO_URL $WOWNERO_DIR_PATH
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
mkdir -p build
sed -i -e 's/bool expand_transaction_1(transaction &tx, bool base_only)/void get_transaction_prefix_hash(const transaction_prefix\& tx, crypto::hash\& h)\n  {\n    std::ostringstream s;\n    binary_archive<true> a(s);\n    ::serialization::serialize(a, const_cast<transaction_prefix\&>(tx));\n    crypto::cn_fast_hash(s.str().data(), s.str().size(), h);\n  }\n\n  crypto::hash get_transaction_prefix_hash(const transaction_prefix\& tx)\n  {\n    crypto::hash h = crypto::null_hash;\n    get_transaction_prefix_hash(tx, h);\n    return h;\n  }\n\n  bool expand_transaction_1(transaction \&tx, bool base_only)/g' src/cryptonote_basic/cryptonote_format_utils.cpp
cd ..

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
make wallet_api -j4
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \;
cp -r ./lib/* $DEST_LIB_DIR
cp ../../src/wallet/api/wallet2_api.h  $DEST_INCLUDE_DIR
popd

done