#!/bin/bash

. ./config.sh

WORKDIR=/opt/android
ew_wownero_EXTERNAL_DIR=${EW_DIR}/ew_wownero/ios/External/android
ew_haven_EXTERNAL_DIR=${EW_DIR}/ew_haven/ios/External/android
ew_monero_EXTERNAL_DIR=${EW_DIR}/ew_monero/ios/External/android
for arch in "aarch" "aarch64" "i686" "x86_64"
do

PREFIX=${WORKDIR}/prefix_${arch}
ABI=""

case $arch in
	"aarch"	)
		ABI="armeabi-v7a";;
	"aarch64"	)
		ABI="arm64-v8a";;
	"i686"		)
		ABI="x86";;
	"x86_64"	)
		ABI="x86_64";;
esac

LIB_DIR=${EW_EXRTERNAL_DIR}/${ABI}/lib
INCLUDE_DIR=${EW_EXRTERNAL_DIR}/${ABI}/include
LIBANBOUND_PATH=${PREFIX}/lib/libunbound.a

mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR

cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR

if [ -f "$LIBANBOUND_PATH" ]; then
 cp $LIBANBOUND_PATH ${LIB_DIR}/monero
fi

done

mkdir -p ${ew_haven_EXTERNAL_DIR}/include
mkdir -p ${ew_monero_EXTERNAL_DIR}/include
mkdir -p ${ew_wownero_EXTERNAL_DIR}/include

cp $EW_EXRTERNAL_DIR/x86/include/monero/wallet2_api.h ${ew_monero_EXTERNAL_DIR}/include
cp $EW_EXRTERNAL_DIR/x86/include/haven/wallet2_api.h ${ew_haven_EXTERNAL_DIR}/include
cp $EW_EXRTERNAL_DIR/x86/include/wownero/wallet2_api.h ${ew_wownero_EXTERNAL_DIR}/include
cp -R $EW_EXRTERNAL_DIR/x86/include/wownero_seed ${ew_wownero_EXTERNAL_DIR}/include
