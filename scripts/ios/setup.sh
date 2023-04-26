#!/bin/sh

. ./config.sh

cd $EXTERNAL_IOS_LIB_DIR

LIBRANDOMX_PATH=${EXTERNAL_IOS_LIB_DIR}/monero/librandomx.a

if [ -f "$LIBRANDOMX_PATH" ]; then
    cp $LIBRANDOMX_PATH ./haven
    cp $LIBRANDOMX_PATH ./wownero
fi

libtool -static -o libboost.a ./libboost_*.a
libtool -static -o libhaven.a ./haven/*.a
libtool -static -o libwownero.a ./wownero/*.a
libtool -static -o libmonero.a ./monero/*.a

EW_HAVEN_EXTERNAL_LIB=../../../../../ew_haven/ios/External/ios/lib
EW_HAVEN_EXTERNAL_INCLUDE=../../../../../ew_haven/ios/External/ios/include
EW_WOWNERO_EXTERNAL_LIB=../../../../../ew_wownero/ios/External/ios/lib
EW_WOWNERO_EXTERNAL_INCLUDE=../../../../../ew_wownero/ios/External/ios/include
EW_MONERO_EXTERNAL_LIB=../../../../../ew_monero/ios/External/ios/lib
EW_MONERO_EXTERNAL_INCLUDE=../../../../../ew_monero/ios/External/ios/include

mkdir -p $EW_HAVEN_EXTERNAL_INCLUDE
mkdir -p $EW_WOWNERO_EXTERNAL_INCLUDE
mkdir -p $EW_MONERO_EXTERNAL_INCLUDE
mkdir -p $EW_HAVEN_EXTERNAL_LIB
mkdir -p $EW_WOWNERO_EXTERNAL_LIB
mkdir -p $EW_MONERO_EXTERNAL_LIB

ln -f ./libboost.a ${EW_HAVEN_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${EW_HAVEN_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${EW_HAVEN_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${EW_HAVEN_EXTERNAL_LIB}/libsodium.a
cp ./libhaven.a $EW_HAVEN_EXTERNAL_LIB
cp ../include/haven/* $EW_HAVEN_EXTERNAL_INCLUDE

ln -f ./libboost.a ${EW_WOWNERO_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${EW_WOWNERO_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${EW_WOWNERO_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${EW_WOWNERO_EXTERNAL_LIB}/libsodium.a
ln -f ./libunbound.a ${EW_WOWNERO_EXTERNAL_LIB}/libunbound.a
cp ./libwownero.a $EW_WOWNERO_EXTERNAL_LIB
cp ../include/wownero/* $EW_WOWNERO_EXTERNAL_INCLUDE
ln -f ./libwownero-seed.a ${EW_WOWNERO_EXTERNAL_LIB}/libwownero-seed.a
cp -R ../include/wownero_seed $EW_WOWNERO_EXTERNAL_INCLUDE

ln -f ./libboost.a ${EW_MONERO_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${EW_MONERO_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${EW_MONERO_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${EW_MONERO_EXTERNAL_LIB}/libsodium.a
ln -f ./libunbound.a ${EW_MONERO_EXTERNAL_LIB}/libunbound.a
cp ./libmonero.a $EW_MONERO_EXTERNAL_LIB
cp ../include/monero/* $EW_MONERO_EXTERNAL_INCLUDE