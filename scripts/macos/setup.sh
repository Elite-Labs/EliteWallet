#!/bin/sh

. ./config.sh

cd $EXTERNAL_MACOS_LIB_DIR


# LIBRANDOMX_PATH=${EXTERNAL_MACOS_LIB_DIR}/monero/librandomx.a

# if [ -f "$LIBRANDOMX_PATH" ]; then
#     cp $LIBRANDOMX_PATH ./haven
# fi

libtool -static -o libboost.a ./libboost_*.a
libtool -static -o libmonero.a ./monero/*.a

# EW_HAVEN_EXTERNAL_LIB=../../../../../ew_haven/macos/External/macos/lib
# EW_HAVEN_EXTERNAL_INCLUDE=../../../../../ew_haven/macos/External/macos/include
EW_MONERO_EXTERNAL_LIB=../../../../../ew_monero/macos/External/macos/lib
EW_MONERO_EXTERNAL_INCLUDE=../../../../../ew_monero/macos/External/macos/include

# mkdir -p $EW_HAVEN_EXTERNAL_INCLUDE
mkdir -p $EW_MONERO_EXTERNAL_INCLUDE
# mkdir -p $EW_HAVEN_EXTERNAL_LIB
mkdir -p $EW_MONERO_EXTERNAL_LIB

# ln ./libboost.a ${EW_HAVEN_EXTERNAL_LIB}/libboost.a
# ln ./libcrypto.a ${EW_HAVEN_EXTERNAL_LIB}/libcrypto.a
# ln ./libssl.a ${EW_HAVEN_EXTERNAL_LIB}/libssl.a
# ln ./libsodium.a ${EW_HAVEN_EXTERNAL_LIB}/libsodium.a
# cp ./libhaven.a $EW_HAVEN_EXTERNAL_LIB
# cp ../include/haven/* $EW_HAVEN_EXTERNAL_INCLUDE

ln ./libboost.a ${EW_MONERO_EXTERNAL_LIB}/libboost.a
ln ./libcrypto.a ${EW_MONERO_EXTERNAL_LIB}/libcrypto.a
ln ./libssl.a ${EW_MONERO_EXTERNAL_LIB}/libssl.a
ln ./libsodium.a ${EW_MONERO_EXTERNAL_LIB}/libsodium.a
ln ./libunbound.a ${EW_MONERO_EXTERNAL_LIB}/libunbound.a
cp ./libmonero.a $EW_MONERO_EXTERNAL_LIB
cp ../include/monero/* $EW_MONERO_EXTERNAL_INCLUDE