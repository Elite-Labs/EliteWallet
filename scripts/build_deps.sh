
if [ ! -d ~/flutter ]; then
    git clone https://github.com/flutter/flutter.git ~/flutter
fi

cd ~/flutter
git fetch
git checkout 2.0.4
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
        brew install autoconf cmake pkg-config cocoapods
    fi
fi

./scripts/get_repos.sh

cd scripts/android

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source ./app_env.sh elitewallet
  ./install_ndk.sh
  ./app_config.sh
  ./build_all.sh
  ./copy_monero_deps.sh
  cd ../..
else
  ./manifest.sh
  cd ../ios
  source app_env.sh elitewallet
  ./app_config.sh
  ./build_all.sh
  ./setup.sh
  cd ../android
  cd ../..
  cd ios
  pod install
  cd ..
fi
