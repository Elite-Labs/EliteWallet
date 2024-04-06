#!/bin/sh

. ./config.sh

ZMQ_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libzmq"

echo "============================ ZMQ ============================"

cd $ZMQ_PATH
git checkout .
git clean -fdx
git cherry-pick 438d5d88

mkdir cmake-build
cd cmake-build
cmake ..
make


cp ${ZMQ_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp ${ZMQ_PATH}/cmake-build/lib/libzmq.a $EXTERNAL_IOS_LIB_DIR
