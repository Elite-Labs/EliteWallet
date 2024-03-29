#!/bin/sh

if [ -z "$APP_IOS_TYPE" ]; then
	echo "Please set APP_IOS_TYPE"
	exit 1
fi

DIR=$(dirname "$0")

case $APP_IOS_TYPE in
	"monero.sc") $DIR/build_monero_all.sh ;;
	"elitewallet") $DIR/build_monero_all.sh && $DIR/build_haven.sh && $DIR/build_wownero.sh && $DIR/build_wownero_seed.sh ;;
	"haven")      $DIR/build_haven_all.sh ;;
	"wownero")      $DIR/build_wownero_all.sh ;;
esac
