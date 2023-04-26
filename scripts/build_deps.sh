
BUILD_PLATFORM="ios"

if [[ " $@ " =~ " android " ]]; then
  BUILD_PLATFORM="android"
else
  if [[ " $@ " =~ " ios " ]]; then
    BUILD_PLATFORM="ios"
  else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      BUILD_PLATFORM="android"
    else
      BUILD_PLATFORM="ios"
    fi
  fi
fi

TYPES=("android" "ios")
if ! [[ " ${TYPES[*]} " =~ " ${BUILD_PLATFORM} " ]]; then
    echo "Platform type must be 'android' or 'ios'."
    exit 1
fi

if [[ ! " $@ " =~ " --skip_other_deps " ]]; then
  if [[ "$BUILD_PLATFORM" == "android" ]]; then
    sudo apt-get install -y curl unzip automake build-essential file pkg-config git python2 libtool libtinfo5 cmake openjdk-8-jre-headless clang bison byacc
  else
    brew install autoconf cmake pkg-config cocoapods
  fi
fi

if [[ ! " $@ " =~ " --skip_flutter " ]]; then
  if [ ! -d ~/flutter ]; then
      git clone https://github.com/flutter/flutter.git ~/flutter
  fi

  cd ~/flutter
  git fetch
  git checkout -f 3.7.11
  cd -

  if [[ ! "$PATH" == *"flutter"* ]]; then

      if [[ "$BUILD_PLATFORM" == "android" ]]; then
          echo "export PATH=~/flutter/bin:\$PATH" >> ~/.bashrc
          source ~/.bashrc
          keytool -genkey -v -keystore $HOME/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key -noprompt -dname "CN=EliteWallet, OU=EliteWallet, O=EliteWallet, L=California, S=America, C=USA" -keypass adminadmin -storepass adminadmin
      else
          echo "export PATH=~/flutter/bin:\$PATH" >> ~/.zshenv
          source ~/.zshenv
      fi
  fi
fi

git config --global protocol.file.allow always

#./scripts/get_repos.sh

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

if [[ "$BUILD_PLATFORM" == "android" ]]; then
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
