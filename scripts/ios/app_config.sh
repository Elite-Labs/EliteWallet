#!/bin/bash

MONERO_SO="monero.so"
ELITEWALLET="elitewallet"
HAVEN="haven"
WOWNERO="wownero"
DIR=`pwd`

if [ -z "$APP_IOS_TYPE" ]; then
        echo "Please set APP_IOS_TYPE"
        exit 1
fi

cd ../.. # go to root
cp -rf ./ios/Runner/InfoBase.plist ./ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${APP_IOS_NAME}" ./ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${APP_IOS_BUNDLE_ID}" ./ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${APP_IOS_VERSION}" ./ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${APP_IOS_BUILD_NUMBER}" ./ios/Runner/Info.plist
CONFIG_ARGS=""

case $APP_IOS_TYPE in
        $MONERO_SO)
		CONFIG_ARGS="--monero"
		;;
        $ELITEWALLET)
		CONFIG_ARGS="--monero --bitcoin --haven --wownero"
		;;
	$HAVEN)
		CONFIG_ARGS="--haven"
		;;
	$WOWNERO)
		CONFIG_ARGS="--wownero"
		;;
esac

cp -rf pubspec_description.yaml pubspec.yaml
flutter pub get
flutter pub run tool/generate_pubspec.dart
flutter pub get
flutter packages pub run tool/configure.dart $CONFIG_ARGS
cd $DIR
$DIR/app_icon.sh
