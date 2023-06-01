#!/bin/bash

. ./config.sh

EXPAT_SRC_DIR=${EXTERNAL_MACOS_SOURCE_DIR}/libexpat

cd $EXPAT_SRC_DIR/expat

./buildconf.sh
./configure --enable-static --disable-shared --prefix=${EXTERNAL_MACOS_DIR}
make
make install