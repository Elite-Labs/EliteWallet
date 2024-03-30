#!/bin/sh

export IOS_SCRIPTS_DIR=`pwd`
export EW_ROOT=${IOS_SCRIPTS_DIR}/../..
export EXTERNAL_DIR=${EW_ROOT}/ew_shared_external/ios/External
export EXTERNAL_IOS_DIR=${EXTERNAL_DIR}/ios
export EXTERNAL_IOS_SOURCE_DIR=${EXTERNAL_DIR}/sources
export EXTERNAL_IOS_LIB_DIR=${EXTERNAL_IOS_DIR}/lib
export EXTERNAL_IOS_INCLUDE_DIR=${EXTERNAL_IOS_DIR}/include
export ELITEWALLET_DATA_DIR=${EXTERNAL_IOS_SOURCE_DIR}/elite_wallet_data
export LOCAL_GIT_DEPS=${ELITEWALLET_DATA_DIR}/deps
export BUILD_TYPE="simulator"
export LOCAL_GIT_DEPS_SUBDIR=${LOCAL_GIT_DEPS}/${BUILD_TYPE}

LAST_DEPS_CHANGE_GITHASH=$(find "$IOS_SCRIPTS_DIR" -type f -exec shasum -a 256 {} + | shasum -a 256 | cut -c1-6)

SUBMODULE_HASHES=""

# Loop through each submodule
git submodule foreach |
while IFS= read -r line; do
    submodule_path=$(echo "$line" | awk '{ print $2 }')
    submodule_hash=$(git -C "$submodule_path" rev-parse HEAD)
    
    if [ -n "$submodule_hash" ]; then
        SUBMODULE_HASHES="$SUBMODULE_HASHES$submodule_hash\n"
    else
        echo "Error: Unable to get hash for submodule: $submodule_path"
        exit 1
    fi
done

# Calculate the combined hash of all submodule hashes
export LAST_DEPS_CHANGE_GITHASH=$(echo -e "$LAST_DEPS_CHANGE_GITHASH$SUBMODULE_HASHES" | shasum -a 256 | cut -c1-6)
echo "Combined hash: $LAST_DEPS_CHANGE_GITHASH"
export CURRENT_DEPS=${LOCAL_GIT_DEPS_SUBDIR}/${LAST_DEPS_CHANGE_GITHASH}

mkdir -p $EXTERNAL_IOS_LIB_DIR
mkdir -p $EXTERNAL_IOS_INCLUDE_DIR
mkdir -p $ELITEWALLET_DATA_DIR
mkdir -p $LOCAL_GIT_DEPS
mkdir -p $LOCAL_GIT_DEPS_SUBDIR
