
if [ ! -d ~/flutter ]; then
    git clone https://github.com/flutter/flutter.git ~/flutter
fi

cd ~/flutter
git fetch
git checkout -f 3.3.9
cd -


if [[ ! "$PATH" == *"flutter"* ]]; then

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.bashrc
        source ~/.bashrc
        sudo apt-get install -y curl unzip automake build-essential file pkg-config git python libtool libtinfo5 cmake openjdk-8-jre-headless clang bison byacc
        keytool -genkey -v -keystore $HOME/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key -noprompt -dname "CN=EliteWallet, OU=EliteWallet, O=EliteWallet, L=California, S=America, C=USA" -keypass adminadmin -storepass adminadmin
    else
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.zshenv
        source ~/.zshenv
        brew install autoconf cmake pkg-config cocoapods
    fi
fi

./scripts/get_repos.sh

cd scripts/android

configure_and_build_deps () {
  source ./app_env.sh elitewallet
  ./app_config.sh
  . ./config.sh
  if [ ! -d $CURRENT_DEPS ]; then
    ./build_all.sh
    mkdir -p $CURRENT_DEPS
    ./cache_deps.sh
  else
    ./copy_cached_deps.sh
  fi
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ./install_ndk.sh
  configure_and_build_deps
  ./copy_monero_deps.sh
  cd ../..
else
  ./manifest.sh
  cd ../ios
  configure_and_build_deps
  ./setup.sh
  cd ../android
  cd ../..
  cd ios
  flutter precache --ios
  pod install
  cd ..
fi
