#!/bin/sh

. ./config.sh

MIN_IOS_VERSION=10.0
BOOST_URL="${LOCAL_GIT_REPOS}/boost-ios"
BOOST_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/Apple-Boost-BuildScript"
BOOST_VERSION=1.72.0
BOOST_LIBS="random regex graph random chrono thread filesystem system date_time locale serialization program_options"

echo "============================ Boost ============================"

echo "Cloning Apple-Boost-BuildScript from - $BOOST_URL"
git clone -b build $BOOST_URL $BOOST_DIR_PATH
cd $BOOST_DIR_PATH
git fetch
git checkout .
git reset --hard HEAD
./boost.sh -ios \
	--min-ios-version ${MIN_IOS_VERSION} \
	--boost-libs "${BOOST_LIBS}" \
	--boost-version ${BOOST_VERSION} \
	--no-framework

cp -r ${BOOST_DIR_PATH}/build/boost/${BOOST_VERSION}/ios/release/prefix/include/*  $EXTERNAL_IOS_INCLUDE_DIR
cp -r ${BOOST_DIR_PATH}/build/boost/${BOOST_VERSION}/ios/release/prefix/lib/*  $EXTERNAL_IOS_LIB_DIR
