if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  cd scripts/android
  source ./app_env.sh elitewallet
  ./app_config.sh
  cd ../..
fi

.flutter/bin/flutter pub get
.flutter/bin/flutter packages pub run tool/generate_new_secrets.dart --force salt=4aa0b8fb5e19ee6d3fcf6e90e99c9e5c keychainSalt=d888accc8e705ae6d1d9dfa7 key=a32a26265cbad3c23697ad72acb0a91c walletSalt=273c706f shortKey=c6ba9689234007756732924b backupSalt=d02e148d2cdee557 backupKeychainSalt=20b1dfaeee715e786e7c570d etherScanApiKey=WAC32G83K9SYB9E4PCRCICRI4YS74JC3E8

.flutter/bin/flutter packages pub run tool/generate_localization.dart
.flutter/bin/flutter packages pub run tool/generate_android_key_properties.dart keyAlias=key storeFile=$HOME/key.jks storePassword=adminadmin keyPassword=adminadmin

cd ew_core && ../.flutter/bin/flutter pub get && ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_monero && ../.flutter/bin/flutter pub get && ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_bitcoin && ../.flutter/bin/flutter pub get && ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_haven && ../.flutter/bin/flutter pub get; ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
cd ew_wownero ; ../.flutter/bin/flutter pub get; ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
cd ew_ethereum && ../.flutter/bin/flutter pub get && ../.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
.flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  .flutter/bin/flutter build appbundle --release
else
  .flutter/bin/flutter run
fi
