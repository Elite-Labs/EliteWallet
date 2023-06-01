#!/bin/sh

. ./config.sh

UNBOUND_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/unbound-1.16.2"

echo "============================ Unbound ============================"
cd $UNBOUND_DIR_PATH
git checkout .
git clean -fdx

export IOS_SDK=iPhone
export IOS_CPU=arm64
export IOS_PREFIX=$EXTERNAL_IOS_DIR
export AUTOTOOLS_HOST=aarch64-apple-ios
export AUTOTOOLS_BUILD="$(./config.guess)"
source ./contrib/ios/setenv_ios.sh
./contrib/ios/install_tools.sh
./contrib/ios/install_expat.sh
./configure --build="$AUTOTOOLS_BUILD" --host="$AUTOTOOLS_HOST" --prefix="$IOS_PREFIX" --with-ssl="$IOS_PREFIX" --with-libexpat="$IOS_PREFIX"
make
make install