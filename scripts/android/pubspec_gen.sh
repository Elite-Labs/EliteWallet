#!/bin/bash

MONERO_SC=monero.sc
ELITEWALLET=elitewallet
HAVEN=haven
WOWNERO=wownero
CONFIG_ARGS=""

case $APP_ANDROID_TYPE in
        $MONERO_SC)
                CONFIG_ARGS="--monero"
                ;;
        $ELITEWALLET)
                CONFIG_ARGS="--monero --bitcoin --haven --wownero --ethereum --polygon --nano --bitcoinCash"
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
.flutter/bin/flutter pub get
.flutter/bin/flutter pub run tool/generate_pubspec.dart
.flutter/bin/flutter pub get
.flutter/bin/flutter packages pub run tool/configure.dart $CONFIG_ARGS
cd scripts/android