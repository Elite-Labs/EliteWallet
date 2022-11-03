if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  cd scripts/android
  . ./config.sh
  cd ../../
else
  cd scripts/ios
  . ./config.sh
  cd ../../
fi

git clone --mirror https://github.com/NLnetLabs/unbound.git ${LOCAL_GIT_REPOS}/unbound
cd ${LOCAL_GIT_REPOS}/unbound
git remote update

git clone --mirror https://github.com/libexpat/libexpat.git ${LOCAL_GIT_REPOS}/libexpat
cd ${LOCAL_GIT_REPOS}/libexpat
git remote update

git clone --mirror https://github.com/cake-tech/monero.git ${LOCAL_GIT_REPOS}/monero
cd ${LOCAL_GIT_REPOS}/monero
git remote update

git clone --mirror https://github.com/haven-protocol-org/haven-main.git ${LOCAL_GIT_REPOS}/haven
cd ${LOCAL_GIT_REPOS}/haven
git remote update

git clone --mirror https://github.com/madler/zlib ${LOCAL_GIT_REPOS}/zlib
cd ${LOCAL_GIT_REPOS}/zlib
git remote update

git clone --mirror https://github.com/jedisct1/libsodium.git ${LOCAL_GIT_REPOS}/libsodium
cd ${LOCAL_GIT_REPOS}/libsodium
git remote update

git clone --mirror https://github.com/zeromq/libzmq.git ${LOCAL_GIT_REPOS}/libzmq
cd ${LOCAL_GIT_REPOS}/libzmq
git remote update

git clone --mirror https://github.com/miniupnp/miniupnp ${LOCAL_GIT_REPOS}/miniupnp
cd ${LOCAL_GIT_REPOS}/miniupnp
git remote update

git clone --mirror https://github.com/tevador/RandomX ${LOCAL_GIT_REPOS}/RandomX
cd ${LOCAL_GIT_REPOS}/RandomX
git remote update

git clone --mirror https://github.com/Tencent/rapidjson ${LOCAL_GIT_REPOS}/rapidjson
cd ${LOCAL_GIT_REPOS}/rapidjson
git remote update

git clone --mirror https://github.com/monero-project/supercop ${LOCAL_GIT_REPOS}/supercop
cd ${LOCAL_GIT_REPOS}/supercop
git remote update

git clone --mirror https://github.com/trezor/trezor-common.git ${LOCAL_GIT_REPOS}/trezor-common
cd ${LOCAL_GIT_REPOS}/trezor-common
git remote update

git clone --mirror https://github.com/monero-project/unbound ${LOCAL_GIT_REPOS}/unbound-haven
cd ${LOCAL_GIT_REPOS}/unbound-haven
git remote update

git clone --mirror https://github.com/monero-project/miniupnp ${LOCAL_GIT_REPOS}/miniupnp-haven
cd ${LOCAL_GIT_REPOS}/miniupnp-haven
git remote update

git clone --mirror https://github.com/haven-protocol-org/haven-blockchain-explorer.git ${LOCAL_GIT_REPOS}/haven-blockchain-explorer
cd ${LOCAL_GIT_REPOS}/haven-blockchain-explorer
git remote update

git clone --mirror https://git.wownero.com/wownero/wownero.git ${LOCAL_GIT_REPOS}/wownero
cd ${LOCAL_GIT_REPOS}/wownero
git remote update

git clone --mirror https://git.wownero.com/wowlet/wownero-seed.git ${LOCAL_GIT_REPOS}/wownero-seed
cd ${LOCAL_GIT_REPOS}/wownero-seed
git remote update

git clone --mirror https://github.com/cake-tech/Apple-Boost-BuildScript.git ${LOCAL_GIT_REPOS}/boost-ios
cd ${LOCAL_GIT_REPOS}/boost-ios
git remote update

git clone --mirror https://github.com/x2on/OpenSSL-for-iPhone.git ${LOCAL_GIT_REPOS}/openssl-ios
cd ${LOCAL_GIT_REPOS}/openssl-ios
git remote update

git clone --mirror https://git.wownero.com/wownero/RandomWOW ${LOCAL_GIT_REPOS}/RandomWOW
cd ${LOCAL_GIT_REPOS}/RandomWOW
git remote update
