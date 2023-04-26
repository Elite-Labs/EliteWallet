mv ew_shared_external/ios/External/android/sources ..
rm .gitignore
git clean -fdx
rm -rf ew_shared_external/ios/External
mkdir -p ew_shared_external/ios/External/android
mv ../sources ew_shared_external/ios/External/android/
git reset --hard HEAD
git checkout .
