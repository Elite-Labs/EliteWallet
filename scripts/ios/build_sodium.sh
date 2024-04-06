#!/bin/sh

. ./config.sh

SODIUM_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libsodium"

echo "============================ SODIUM ============================"

cd $SODIUM_PATH
git checkout .
git clean -fdx
./dist-build/apple-xcframework.sh

mv ${SODIUM_PATH}/libsodium-apple/ios-simulators/include/* $EXTERNAL_IOS_INCLUDE_DIR
mv ${SODIUM_PATH}/libsodium-apple/ios-simulators/lib/* $EXTERNAL_IOS_LIB_DIR
