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

ew_haven_EXTERNAL_LIB=../../../../../ew_haven/ios/External/ios/lib
ew_haven_EXTERNAL_INCLUDE=../../../../../ew_haven/ios/External/ios/include
ew_wownero_EXTERNAL_LIB=../../../../../ew_wownero/ios/External/ios/lib
ew_wownero_EXTERNAL_INCLUDE=../../../../../ew_wownero/ios/External/ios/include
ew_monero_EXTERNAL_LIB=../../../../../ew_monero/ios/External/ios/lib
ew_monero_EXTERNAL_INCLUDE=../../../../../ew_monero/ios/External/ios/include

mkdir -p $ew_haven_EXTERNAL_INCLUDE
mkdir -p $ew_wownero_EXTERNAL_INCLUDE
mkdir -p $ew_monero_EXTERNAL_INCLUDE
mkdir -p $ew_haven_EXTERNAL_LIB
mkdir -p $ew_wownero_EXTERNAL_LIB
mkdir -p $ew_monero_EXTERNAL_LIB

ln -f ./libboost.a ${ew_haven_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${ew_haven_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${ew_haven_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${ew_haven_EXTERNAL_LIB}/libsodium.a
cp ./libhaven.a $ew_haven_EXTERNAL_LIB
cp ../include/haven/* $ew_haven_EXTERNAL_INCLUDE

ln -f ./libboost.a ${ew_wownero_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${ew_wownero_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${ew_wownero_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${ew_wownero_EXTERNAL_LIB}/libsodium.a
cp ./libwownero.a $ew_wownero_EXTERNAL_LIB
cp ../include/wownero/* $ew_wownero_EXTERNAL_INCLUDE
ln -f ./libwownero-seed.a ${ew_wownero_EXTERNAL_LIB}/libwownero-seed.a
cp -R ../include/wownero_seed $ew_wownero_EXTERNAL_INCLUDE

ln -f ./libboost.a ${ew_monero_EXTERNAL_LIB}/libboost.a
ln -f ./libcrypto.a ${ew_monero_EXTERNAL_LIB}/libcrypto.a
ln -f ./libssl.a ${ew_monero_EXTERNAL_LIB}/libssl.a
ln -f ./libsodium.a ${ew_monero_EXTERNAL_LIB}/libsodium.a
ln -f ./libunbound.a ${ew_monero_EXTERNAL_LIB}/libunbound.a
cp ./libmonero.a $ew_monero_EXTERNAL_LIB
cp ../include/monero/* $ew_monero_EXTERNAL_INCLUDE