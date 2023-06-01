rm .gitignore
git clean -fdx
rm -rf ew_shared_external/ios/External/android
rm -rf ew_shared_external/ios/External/ios
git reset --hard HEAD
git checkout .
