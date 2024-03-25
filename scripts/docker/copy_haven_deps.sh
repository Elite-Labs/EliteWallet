#!/bin/bash

WORKDIR=/opt/android
EW_DIR=${WORKDIR}/elite_wallet
EW_EXRTERNAL_DIR=${EW_DIR}/ew_shared_external/ios/External/android
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
LIBANBOUND_PATH=${PREFIX}/lib/libunbound.a

mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR

cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR

if [ -f "$LIBANBOUND_PATH" ]; then
 cp $LIBANBOUND_PATH ${LIB_DIR}/monero
fi

done

mkdir -p ${EW_HAVEN_EXTERNAL_DIR}/include
mkdir -p ${EW_MONERO_EXTERNAL_DIR}/include

cp $EW_EXRTERNAL_DIR/x86/include/monero/wallet2_api.h ${EW_MONERO_EXTERNAL_DIR}/include
cp $EW_EXRTERNAL_DIR/x86/include/haven/wallet2_api.h ${EW_HAVEN_EXTERNAL_DIR}/include
