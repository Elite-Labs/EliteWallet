
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
    echo "Platform type must be 'android' or 'ios'"
    exit 1
fi

if [[ " $@ " =~ " --skip-all-if-deps-exist " ]]; then
  if [[ "$BUILD_PLATFORM" == "android" ]]; then
    cd scripts/android
  else
    cd scripts/ios
  fi
  . ./config.sh
  if [-d $CURRENT_DEPS ]; then
    echo "Exiting script as --skip-all-if-deps-exist is present"
    exit 0
  fi
  cd ../..
fi

if [[ ! " $@ " =~ " --skip-other-deps " ]]; then
  if [[ "$BUILD_PLATFORM" == "android" ]]; then
    sudo apt-get install -y curl unzip automake build-essential file pkg-config git python2 libtool libtinfo5 cmake openjdk-11-jre-headless clang bison byacc gperf groff
  else
    brew install autoconf cmake pkg-config cocoapods
  fi
else
  echo "Skipping as --skip-other-deps is present"
fi

git config --global protocol.file.allow always

git submodule update --init --force

if [[ " $@ " =~ " --skip-main-deps " ]]; then
    echo "Exiting script as --skip-main-deps is present"
    exit 0
fi

cd scripts/android

configure_and_build_deps () {
  source ./app_env.sh elitewallet
  ./app_config.sh
  . ./config.sh
  if [ ! -d $CURRENT_DEPS ]; then
    echo "Building deps"
    ./build_all.sh
    mkdir -p $CURRENT_DEPS
    ./cache_deps.sh
  else
    echo "Copying cached deps"
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
  cd ../..
fi
