#!/bin/bash

MONERO_COM=monero.com
ELITEWALLET=elitewallet
HAVEN=haven
WOWNERO=wownero
CONFIG_ARGS=""

case $APP_ANDROID_TYPE in
        $MONERO_COM)
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

cd ../..
cp -rf pubspec_description.yaml pubspec.yaml
flutter pub get
flutter pub run tool/generate_pubspec.dart
flutter pub get
flutter packages pub run tool/configure.dart $CONFIG_ARGS
cd scripts/android