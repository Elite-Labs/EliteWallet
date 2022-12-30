
if [ ! -d ~/flutter ]; then
    git clone https://github.com/flutter/flutter.git ~/flutter
fi

cd ~/flutter
git fetch
git checkout -f 2.0.4
cd -


if [[ ! "$PATH" == *"flutter"* ]]; then

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.bashrc
        source ~/.bashrc
        sudo apt-get install -y curl unzip automake build-essential file pkg-config git python libtool libtinfo5 cmake openjdk-8-jre-headless clang bison byacc
        keytool -genkey -v -keystore $HOME/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key -keypass adminadmin -storepass adminadmin
    else
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.zshenv
        source ~/.zshenv
        brew install autoconf cmake pkg-config cocoapods wget
    fi
fi

cd scripts/android

configure_and_download_deps () {
  source ./app_env.sh elitewallet
  ./app_config.sh
  . ./config.sh
  DEPS_URL=https://elitewallet.sc/archive/${1}/${BUILD_TYPE}/${LAST_DEPS_CHANGE_GITHASH}.tar.gz
  if [ ! -d $CURRENT_DEPS ]; then
    wget $DEPS_URL -P $LOCAL_GIT_DEPS_SUBDIR
    cd $LOCAL_GIT_DEPS_SUBDIR
    tar -xvf ${LAST_DEPS_CHANGE_GITHASH}.tar.gz
    rm ${LAST_DEPS_CHANGE_GITHASH}.tar.gz
    cd -
  fi
  ./copy_cached_deps.sh
}

if [[ "$1" == "android"* ]]; then
  configure_and_download_deps $1
  ./copy_monero_deps.sh
  cd ../..
else
  ./manifest.sh
  cd ../ios
  configure_and_download_deps $1
  ./setup.sh
  cd ../android
  cd ../..
  cd ios
  flutter precache --ios
  pod install
  cd ..
fi
