g#!/bin/sh

. ./config.sh

ZMQ_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libzmq"
ZMQ_URL="${LOCAL_GIT_REPOS}/libzmq"

echo "============================ ZMQ ============================"

echo "Cloning ZMQ from - $ZMQ_URL"
git clone $ZMQ_URL $ZMQ_PATH
cd $ZMQ_PATH
git fetch
git checkout .
git reset --hard HEAD
mkdir cmake-build
cd cmake-build
cmake ..
make


cp ${ZMQ_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp ${ZMQ_PATH}/cmake-build/lib/libzmq.a $EXTERNAL_IOS_LIB_DIR
