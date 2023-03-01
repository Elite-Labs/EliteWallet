rm .gitignore
git clean -fdx
rm -rf ew_shared_external/ios/External
git reset --hard HEAD
git checkout .
