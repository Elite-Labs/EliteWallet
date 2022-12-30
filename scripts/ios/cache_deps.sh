#!/bin/sh

. ./config.sh

mv $EXTERNAL_IOS_DIR/sources $EXTERNAL_IOS_DIR/.. 
cp -r $EXTERNAL_IOS_DIR/. $CURRENT_DEPS
mv $EXTERNAL_IOS_DIR/../sources $EXTERNAL_IOS_DIR
