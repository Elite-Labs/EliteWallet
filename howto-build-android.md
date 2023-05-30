# Building EliteWallet for Android

## Requirements and Setup

The following are the system requirements to build EliteWallet for your Android device.

```
Ubuntu >= 16.04 
Android SDK 28
Android NDK 17c
Flutter 2 or above
```

## Building EliteWallet on Android (Automatic build)

Automatic builds on MAC OSX will create 2 new directories in the home directory 'local_deps' and 'local_repos'.
These will be used for storing dependencies and repositories necessary for building a project.

To build Elite Wallet automatically:

```
$ git clone https://github.com/Elite-Labs/EliteWallet.git elite_wallet --branch master
$ cd elite_wallet
$ ./scripts/build_deps.sh
$ ./scripts/build.sh
```

## Building EliteWallet on Android with prebuilt dependencies (Automatic build)

Instead of building dependencies, it will be downloaded from elite wallet github repository.

Automatic builds on MAC OSX will create 1 new directory in the home directory 'local_deps'.
It will be used for storing dependencies necessary for building a project.

To build Elite Wallet:

```
$ git clone https://github.com/Elite-Labs/EliteWallet.git elite_wallet --branch master
$ cd elite_wallet
$ ./scripts/download_deps.sh
$ ./scripts/build.sh
```

## Building EliteWallet on Android (Manual build)

These steps will help you configure and execute a build of EliteWallet from its source code.

### 1. Installing Package Dependencies

EliteWallet cannot be built without the following packages installed on your build system.

- curl

- unzip

- automake

- build-essential

- file

- pkg-config

- git

- python

- libtool

- libtinfo5

- cmake

- openjdk-8-jre-headless

- clang

You may easily install them on your build system with the following command:

`$ sudo apt-get install -y curl unzip automake build-essential file pkg-config git python libtool libtinfo5 cmake openjdk-8-jre-headless clang bison byacc`

### 2. Installing Android Studio and Android toolchain

You may download and install the latest version of Android Studio [here](https://developer.android.com/studio#downloads). After installing, start Android Studio, and go through the "Setup Wizard." This installs the latest Android SDK, Android SDK Command-line Tools, and Android SDK Build-Tools, which are required by EliteWallet. **Be sure you are installing SDK version 28 or later when stepping through the wizard**

### 3. Installing Flutter

Need to install flutter with version `3.7.x`. For this please check section [Install Flutter manually](https://docs.flutter.dev/get-started/install/linux#install-flutter-manually).

### 4. Verify Installations

Verify that the Android toolchain, Flutter, and Android Studio have been correctly installed on your system with the following command:

`$ flutter doctor`

The output of this command will appear like this, indicating successful installations. If there are problems with your installation, they **must** be corrected before proceeding.
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Linux, locale en_US.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 28)
[✓] Android Studio (version 4.0)
```

### 5. Generate a secure keystore for Android

`$ keytool -genkey -v -keystore $HOME/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`

You will be prompted to create two passwords. First you will be prompted for the "store password", followed by a "key password" towards the end of the creation process. **TAKE NOTE OF THESE PASSWORDS!** You will need them in later steps. 

### 6. Acquiring the EliteWallet Source Code

Download the source code.

`$ git clone https://github.com/Elite-Labs/EliteWallet.git elite_wallet --branch master`

Proceed into the source code before proceeding with the next steps:
`$ cd elite_wallet`

### 7. Init submodules

`$ git submodule update --init --force`

### 7. Installing Android NDK

`$ cd scripts/android/`
`$ ./install_ndk.sh`

### 8. Execute Build & Setup Commands for EliteWallet

We need to generate project settings like app name, app icon, package name, etc. For this need to setup environment variables and configure project files. 

`$ source ./app_env.sh elitewallet`

Then run configuration script for setup app name, app icon and etc:

`$ ./app_config.sh`  

Build the Monero libraries and their dependencies:

`$ ./build_all.sh`

Now the dependencies need to be copied into the EliteWallet project with this command:

`$ ./copy_monero_deps.sh`

It is now time to change back to the base directory of the EliteWallet source code:

`$ cd ../../`

Install Flutter package dependencies with this command:

`$ .flutter/bin/flutter pub get`

Your EliteWallet binary will be built with cryptographic salts, which are used for secure encryption of your data. You may generate these secret salts with the following command:

`$ .flutter/bin/flutter packages pub run tool/generate_new_secrets.dart`

Next, we must generate key properties based on the secure keystore you generated for Android (in step 5). **MODIFY THE FOLLOWING COMMAND** with the "store password" and "key password" you assigned when creating your keystore (in step 5).

`$ .flutter/bin/flutter packages pub run tool/generate_android_key_properties.dart keyAlias=key storeFile=$HOME/key.jks storePassword=<store password> keyPassword=<key password>`

**REMINDER:** The *above* command will **not** succeed unless you replaced the `storePassword` and `keyPassword` variables with the correct passwords for your keystore.

Then we need to generate localization files.

`$ .flutter/bin/flutter packages pub run tool/generate_localization.dart`

Lastly, we will generate mobx models for the project.

Generate mobx models for `ew_core`:

`cd ew_core && .flutter/bin/flutter pub get && .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..`

Generate mobx models for `ew_monero`:

`cd ew_monero && .flutter/bin/flutter pub get && .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..`

Generate mobx models for `ew_bitcoin`:

`cd ew_bitcoin && .flutter/bin/flutter pub get && .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..`

Generate mobx models for `ew_haven`:

`cd ew_haven ; .flutter/bin/flutter pub get ; .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs ; cd ..`

Generate mobx models for `ew_wownero`:

`cd ew_wownero && .flutter/bin/flutter pub get && .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs && cd ..`

Finally build mobx models for the app:

`$ .flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs`

### 9. Build!

`$ .flutter/bin/flutter build apk --release`

Copyright (c) 2023 Elite Technologies.
