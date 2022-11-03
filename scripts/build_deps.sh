
if [ ! -d ~/flutter ]; then
    git clone https://github.com/flutter/flutter.git ~/flutter
fi

cd ~/flutter
git checkout 2.0.4
cd -


if [[ ! "$PATH" == *"flutter"* ]]; then

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.bashrc
        source ~/.bashrc
    else
        echo "export PATH=~/flutter/bin:\$PATH" >> ~/.zshenv
        source ~/.zshenv
        brew install autoconf cmake pkg-config cocoapods
    fi
fi

sh scripts/get_repos.sh

cd scripts/android

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source ./app_env.sh elitewallet
  ./app_config.sh
  ./build_all.sh
  ./copy_monero_deps.sh
  cd ../..
else
  sh manifest.sh
  cd ../ios
  source app_env.sh elitewallet
  sh app_config.sh
  sh build_all.sh
  sh setup.sh
  cd ../android
  cd ../..
  cd ios
  pod install
  cd ..
fi
