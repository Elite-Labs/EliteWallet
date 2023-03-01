flutter pub get
flutter packages pub run tool/generate_new_secrets.dart
cp ~/.secrets.g.dart lib
flutter packages pub run tool/generate_localization.dart
flutter packages pub run tool/generate_android_key_properties.dart keyAlias=key storeFile=$HOME/key.jks storePassword=adminadmin keyPassword=adminadmin

cd ew_core && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_monero && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_bitcoin && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd ew_haven && flutter pub get; flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
cd ew_wownero ; flutter pub get; flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
flutter packages pub run build_runner build --delete-conflicting-outputs

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  flutter build appbundle --release
else
  flutter run
fi
