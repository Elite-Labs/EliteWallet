#!/bin/sh

APP_IOS_NAME=""
APP_IOS_VERSION=""
APP_IOS_BUILD_VERSION=""
APP_IOS_BUNDLE_ID=""

MONERO_SC="monero.sc"
ELITEWALLET="elitewallet"
HAVEN="haven"
WOWNERO="wownero"

TYPES=($MONERO_SC $ELITEWALLET $HAVEN $WOWNERO)
APP_IOS_TYPE=$1

MONERO_SC_NAME="Monero.sc"
MONERO_SC_VERSION="1.0.0"
MONERO_SC_BUILD_NUMBER=1
MONERO_SC_BUNDLE_ID="sc.elitewallet.monero"

ELITEWALLET_NAME="Elite Wallet"
ELITEWALLET_VERSION="1.3.1"
ELITEWALLET_BUILD_NUMBER=16
ELITEWALLET_BUNDLE_ID="sc.elitewallet.elite-wallet"

HAVEN_NAME="Haven"
HAVEN_VERSION="1.0.0"
HAVEN_BUILD_NUMBER=1
HAVEN_BUNDLE_ID="sc.haven.app"

WOWNERO_NAME="Wownero"
WOWNERO_VERSION="1.0.0"
WOWNERO_BUILD_NUMBER=1
WOWNERO_BUNDLE_ID="sc.wownero.app"

if ! [[ " ${TYPES[*]} " =~ " ${APP_IOS_TYPE} " ]]; then
    echo "Wrong app type."
    exit 1
fi

case $APP_IOS_TYPE in
	$MONERO_SC)
		APP_IOS_NAME=$MONERO_SC_NAME
		APP_IOS_VERSION=$MONERO_SC_VERSION
		APP_IOS_BUILD_NUMBER=$MONERO_SC_BUILD_NUMBER
		APP_IOS_BUNDLE_ID=$MONERO_SC_BUNDLE_ID
		;;
	$ELITEWALLET)
		APP_IOS_NAME=$ELITEWALLET_NAME
		APP_IOS_VERSION=$ELITEWALLET_VERSION
		APP_IOS_BUILD_NUMBER=$ELITEWALLET_BUILD_NUMBER
		APP_IOS_BUNDLE_ID=$ELITEWALLET_BUNDLE_ID
		;;
	$HAVEN)
		APP_IOS_NAME=$HAVEN_NAME
		APP_IOS_VERSION=$HAVEN_VERSION
		APP_IOS_BUILD_NUMBER=$HAVEN_BUILD_NUMBER
		APP_IOS_BUNDLE_ID=$HAVEN_BUNDLE_ID
		;;
	$WOWNERO)
		APP_IOS_NAME=$WOWNERO_NAME
		APP_IOS_VERSION=$WOWNERO_VERSION
		APP_IOS_BUILD_NUMBER=$WOWNERO_BUILD_NUMBER
		APP_IOS_BUNDLE_ID=$WOWNERO_BUNDLE_ID
		;;
esac

export APP_IOS_TYPE
export APP_IOS_NAME
export APP_IOS_VERSION
export APP_IOS_BUILD_NUMBER
export APP_IOS_BUNDLE_ID
