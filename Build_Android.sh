#!/bin/bash

function changesource {
    sed -i 's:define LUA_IDSIZE:define LUA_IDSIZE    256  // :' luaconf.h
}

if [ -z "$LUA_UE4_VERSION" ]; then
    echo "LUA_UE4_VERSION is not set, exit."
    exit 1
else
    echo "LUA_UE4_VERSION: $LUA_UE4_VERSION"
fi

if [ -z "$LUA_UE4_PREFIX" ]; then
    echo "LUA_UE4_PREFIX is not set, exit."
    exit 1
else
    echo "LUA_UE4_PREFIX: $LUA_UE4_PREFIX"
fi

CUR_DIR=$(dirname $0)
if [ "${CUR_DIR}" = "." ]; then
    CUR_DIR=`pwd`
fi

LUA_UE4_URL=http://www.lua.org/ftp/lua-${LUA_UE4_VERSION}.tar.gz
LUA_UE4_DIR=lua-$LUA_UE4_VERSION
LUA_UE4_TAR=$LUA_UE4_DIR.tar.gz

wget -q -O $LUA_UE4_TAR $LUA_UE4_URL

tar zxf $LUA_UE4_TAR
mv ./$LUA_UE4_DIR/* .
rm -rf $LUA_UE4_DIR

cd src
changesource

cd ..

rm -rf $LUA_UE4_PREFIX
mkdir -p $LUA_UE4_PREFIX

cmake -DCMAKE_INSTALL_PREFIX=$LUA_UE4_PREFIX/android . -DCMAKE_TOOLCHAIN_FILE=android.toolchain.cmake -DANDROID_NDK="${NDKROOT}" -DCMAKE_BUILD_TYPE=Release -DANDROID_ABI="armeabi-v7a"
make
make install
