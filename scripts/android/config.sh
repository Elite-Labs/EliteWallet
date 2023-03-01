#!/bin/sh

export API=21
export WORKDIR=/opt/android
export ANDROID_NDK_ZIP=${WORKDIR}/android-ndk-r17c.zip
export ANDROID_NDK_ROOT=${WORKDIR}/android-ndk-r17c
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export TOOLCHAIN_DIR="${WORKDIR}/toolchain"
export TOOLCHAIN_BASE_DIR=$TOOLCHAIN_DIR
export ORIGINAL_PATH=$PATH
export THREADS=4
export EW_DIR=${WORKDIR}/elite_wallet
export EW_EXRTERNAL_DIR=${EW_DIR}/ew_shared_external/ios/External/android
export ELITEWALLET_DATA_DIR=~/elite_wallet_data
export LOCAL_GIT_REPOS=${WORKDIR}/local_repos
export LOCAL_GIT_DEPS=${WORKDIR}/local_deps
export BUILD_TYPE="release"
export LOCAL_GIT_DEPS_SUBDIR=${LOCAL_GIT_DEPS}/${BUILD_TYPE}
export LAST_DEPS_CHANGE_GITHASH="cac696"
export CURRENT_DEPS=${LOCAL_GIT_DEPS_SUBDIR}/${LAST_DEPS_CHANGE_GITHASH}

mkdir -p $EW_EXRTERNAL_DIR
mkdir -p $ELITEWALLET_DATA_DIR
mkdir -p $LOCAL_GIT_REPOS
mkdir -p $LOCAL_GIT_DEPS
mkdir -p $LOCAL_GIT_DEPS_SUBDIR
