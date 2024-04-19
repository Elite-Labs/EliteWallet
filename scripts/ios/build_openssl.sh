#!/bin/sh

. ./config.sh

OPEN_SSL_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/openssl-ios"

echo "============================ OpenSSL ============================"

cd $OPEN_SSL_DIR_PATH
git checkout .
git clean -fdx

./build-libssl.sh --version=1.1.1q --targets="ios-cross-arm64" --deprecated

cp -r ${OPEN_SSL_DIR_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp -r ${OPEN_SSL_DIR_PATH}/lib/libcrypto-iOS.a ${EXTERNAL_IOS_LIB_DIR}/libcrypto.a
cp -r ${OPEN_SSL_DIR_PATH}/lib/libssl-iOS.a ${EXTERNAL_IOS_LIB_DIR}/libssl.a