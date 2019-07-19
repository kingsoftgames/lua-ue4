#!/bin/bash

if [[ -z "${LUA_UE4_VERSION}" ]]; then
  echo "LUA_UE4_VERSION is not set, exit."
  exit 1
else
  echo "LUA_UE4_VERSION: ${LUA_UE4_VERSION}"
fi

if [[ -z "${LUA_UE4_PREFIX}" ]]; then
  echo "LUA_UE4_PREFIX is not set, exit."
  exit 1
else
  echo "LUA_UE4_PREFIX: ${LUA_UE4_PREFIX}"
fi

readonly LUA_UE4_URL=http://www.lua.org/ftp/lua-${LUA_UE4_VERSION}.tar.gz
readonly LUA_UE4_DIR=lua-${LUA_UE4_VERSION}
readonly LUA_UE4_TAR=${LUA_UE4_DIR}.tar.gz

function change_source {
  sed -i 's:define LUA_IDSIZE:define LUA_IDSIZE    256  // :' luaconf.h
}

wget -q -O ${LUA_UE4_TAR} ${LUA_UE4_URL}
tar zxf ${LUA_UE4_TAR}
mv ./${LUA_UE4_DIR}/* .
rm -rf ${LUA_UE4_DIR}

cd src
change_source
cd ..

rm -rf ${LUA_UE4_PREFIX}
mkdir -p ${LUA_UE4_PREFIX}

cmake .                                                \
  -DCMAKE_INSTALL_PREFIX=${LUA_UE4_PREFIX}/android     \
  -DCMAKE_TOOLCHAIN_FILE=android.toolchain.cmake       \
  -DANDROID_NDK="${NDKROOT}"                           \
  -DCMAKE_BUILD_TYPE=Release                           \
  -DANDROID_ABI="arm64-v8a"                            \
  -DANDROID_NATIVE_API_LEVEL="android-24"
make
make install
