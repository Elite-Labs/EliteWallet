#!/bin/sh

export API=21
export ANDROID_SCRIPTS_DIR=`pwd`
export EW_DIR=${ANDROID_SCRIPTS_DIR}/../..
export EW_EXRTERNAL_DIR=${EW_DIR}/ew_shared_external/ios/External/android

export WORKDIR=${EW_EXRTERNAL_DIR}/../sources
export ANDROID_NDK_ZIP=${WORKDIR}/android-ndk-r17c.zip
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-$WORKDIR/android-ndk-r17c}"
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export TOOLCHAIN_DIR="${WORKDIR}/toolchain"
export TOOLCHAIN_BASE_DIR=$TOOLCHAIN_DIR
export ORIGINAL_PATH=$PATH
export THREADS=4
export ELITEWALLET_DATA_DIR=${WORKDIR}/elite_wallet_data
export LOCAL_GIT_DEPS=${ELITEWALLET_DATA_DIR}/local_deps
export BUILD_TYPE="release"
export LOCAL_GIT_DEPS_SUBDIR=${LOCAL_GIT_DEPS}/${BUILD_TYPE}
contents=$(cat "$ANDROID_SCRIPTS_DIR"/*)
export LAST_DEPS_CHANGE_GITHASH=$(echo -n "$contents" | sha256sum | cut -c1-6)
echo "Combined hash: $LAST_DEPS_CHANGE_GITHASH"
export CURRENT_DEPS=${LOCAL_GIT_DEPS_SUBDIR}/${LAST_DEPS_CHANGE_GITHASH}

mkdir -p $EW_EXRTERNAL_DIR
mkdir -p $WORKDIR
mkdir -p $ELITEWALLET_DATA_DIR
mkdir -p $LOCAL_GIT_DEPS
mkdir -p $LOCAL_GIT_DEPS_SUBDIR
