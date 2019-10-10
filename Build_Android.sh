#!/bin/bash

set -ex

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

wget -q -O ${LUA_UE4_TAR} ${LUA_UE4_URL}

function change_source {
  sed -i 's:define LUA_IDSIZE:define LUA_IDSIZE    256  // :' luaconf.h
}

function build_android {
  MYARCH=$1
  MYABI=$1

  tar zxf ${LUA_UE4_TAR}

  mkdir -p "${LUA_UE4_PREFIX}/${MYARCH}"

  pushd ${LUA_UE4_DIR}/src
    change_source
  popd

  cp CMakeLists.txt ./${LUA_UE4_DIR}
  
  pushd ${LUA_UE4_DIR}
    cmake .                                                \
      -DCMAKE_INSTALL_PREFIX="${LUA_UE4_PREFIX}/${MYARCH}" \
      -DCMAKE_TOOLCHAIN_FILE=../android.toolchain.cmake    \
      -DANDROID_NDK="${NDKROOT}"                           \
      -DCMAKE_BUILD_TYPE=Release                           \
      -DANDROID_ABI="${MYABI}"                             \
      -DANDROID_NATIVE_API_LEVEL="android-24"
    make
    make install
    objdump -h "${LUA_UE4_PREFIX}/${MYARCH}/lib/liblua.a" | head -n 25
  popd
}

build_android armeabi-v7a

rm -rfv ${LUA_UE4_DIR}
build_android arm64-v8a
