#!/bin/sh

. ./config.sh

for arch in "aarch" "aarch64" "i686" "x86_64"
do
PREFIX=$WORKDIR/prefix_${arch}
mkdir -p $CURRENT_DEPS
cp -r $PREFIX $CURRENT_DEPS/
done