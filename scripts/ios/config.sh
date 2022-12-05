#!/bin/sh

export IOS_SCRIPTS_DIR=`pwd`
export CW_ROOT=${IOS_SCRIPTS_DIR}/../..
export EXTERNAL_DIR=${CW_ROOT}/cw_shared_external/ios/External
export EXTERNAL_IOS_DIR=${EXTERNAL_DIR}/ios
export EXTERNAL_IOS_SOURCE_DIR=${EXTERNAL_IOS_DIR}/sources
export EXTERNAL_IOS_LIB_DIR=${EXTERNAL_IOS_DIR}/lib
export EXTERNAL_IOS_INCLUDE_DIR=${EXTERNAL_IOS_DIR}/include
export LOCAL_GIT_REPOS=~/local_repos

mkdir -p $EXTERNAL_IOS_LIB_DIR
mkdir -p $EXTERNAL_IOS_INCLUDE_DIR