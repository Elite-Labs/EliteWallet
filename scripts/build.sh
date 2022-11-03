flutter pub get
flutter packages pub run tool/generate_new_secrets.dart
flutter packages pub run tool/generate_localization.dart

cd cw_core && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd cw_monero && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd cw_bitcoin && flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..
cd cw_haven && flutter pub get; flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
cd cw_wownero ; flutter pub get; flutter packages pub run build_runner build --delete-conflicting-outputs; cd ..
flutter packages pub run build_runner build --delete-conflicting-outputs

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  flutter build appbundle --release
else
  flutter run
fi
