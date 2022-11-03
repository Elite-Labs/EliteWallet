rm .gitignore
git clean -fdx
rm -rf cw_shared_external/ios/External
git reset --hard HEAD
git checkout .
