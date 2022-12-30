#!/bin/sh

. ./config.sh

OPEN_SSL_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/openssl-ios"

echo "============================ OpenSSL ============================"

cd $OPEN_SSL_DIR_PATH
git checkout .
git reset --hard HEAD
git pull
./build-libssl.sh --version=1.1.1q --targets="ios-sim-cross-x86_64" --deprecated

cp -r ${OPEN_SSL_DIR_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp -r ${OPEN_SSL_DIR_PATH}/lib/libcrypto-iOS-Sim.a ${EXTERNAL_IOS_LIB_DIR}/libcrypto.a
cp -r ${OPEN_SSL_DIR_PATH}/lib/libssl-iOS-Sim.a ${EXTERNAL_IOS_LIB_DIR}/libssl.a