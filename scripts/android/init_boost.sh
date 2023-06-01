#!/bin/sh

ARCH=$1
PREFIX=$2
BOOST_SRC_DIR=$3

cd $WORKDIR
rm -rf $PREFIX/include/boost
cd $BOOST_SRC_DIR
git checkout .
git clean -fdx
git submodule update --init --force
./bootstrap.sh --prefix=${PREFIX}
