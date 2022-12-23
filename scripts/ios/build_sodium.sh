#!/bin/sh

. ./config.sh

SODIUM_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libsodium"
SODIUM_URL="${LOCAL_GIT_REPOS}/libsodium"

echo "============================ SODIUM ============================"

echo "Cloning SODIUM from - $SODIUM_URL"
git clone $SODIUM_URL $SODIUM_PATH --branch stable
cd $SODIUM_PATH
git fetch
git checkout .
git reset --hard HEAD
./dist-build/ios.sh

cp -r ${SODIUM_PATH}/libsodium-ios/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp -r ${SODIUM_PATH}/libsodium-ios/lib/* $EXTERNAL_IOS_LIB_DIR