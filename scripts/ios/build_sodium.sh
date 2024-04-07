#!/bin/sh

. ./config.sh

SODIUM_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libsodium"

echo "============================ SODIUM ============================"

cd $SODIUM_PATH
git checkout .
git clean -fdx
./dist-build/ios.sh

cp -r ${SODIUM_PATH}/libsodium-ios/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp -r ${SODIUM_PATH}/libsodium-ios/lib/* $EXTERNAL_IOS_LIB_DIR
