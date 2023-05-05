#!/bin/bash

. ./config.sh

EW_WOWNERO_EXTERNAL_DIR=${EW_DIR}/ew_wownero/ios/External/android
EW_HAVEN_EXTERNAL_DIR=${EW_DIR}/ew_haven/ios/External/android
EW_MONERO_EXTERNAL_DIR=${EW_DIR}/ew_monero/ios/External/android
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
LIBUNBOUND_PATH=${PREFIX}/lib/libunbound.a

mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR

cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR

if [ -f "$LIBUNBOUND_PATH" ]; then
 cp $LIBUNBOUND_PATH ${LIB_DIR}/monero
 cp $LIBUNBOUND_PATH ${LIB_DIR}/wownero
fi

done

mkdir -p ${EW_HAVEN_EXTERNAL_DIR}/include
mkdir -p ${EW_MONERO_EXTERNAL_DIR}/include
mkdir -p ${EW_WOWNERO_EXTERNAL_DIR}/include

cp $EW_EXRTERNAL_DIR/x86/include/monero/wallet2_api.h ${EW_MONERO_EXTERNAL_DIR}/include
cp $EW_EXRTERNAL_DIR/x86/include/haven/wallet2_api.h ${EW_HAVEN_EXTERNAL_DIR}/include
cp $EW_EXRTERNAL_DIR/x86/include/wownero/wallet2_api.h ${EW_WOWNERO_EXTERNAL_DIR}/include
cp -R $EW_EXRTERNAL_DIR/x86/include/wownero_seed ${EW_WOWNERO_EXTERNAL_DIR}/include
