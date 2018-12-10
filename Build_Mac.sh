#!/bin/bash

CUR_DIR=$(dirname $0)
if [ "${CUR_DIR}" = "." ]; then
    CUR_DIR=`pwd`
fi

CORE_COUNT=$(sysctl -n machdep.cpu.core_count)

changesource(){
    sed -i "" 's:define LUA_IDSIZE:define LUA_IDSIZE    256  // :' luaconf.h
    ADD_NUMBER_LINE=$(sed -n -e "/without modifying the main part of the file./=" luaconf.h)
    if [ -n ${ADD_NUMBER_LINE} ]; then
        ADD_NUMBER_LINE=$(( ${ADD_NUMBER_LINE} + 2 ))
        sed -i '' "${ADD_NUMBER_LINE} a\ 
        #define system(s) ((s)==NULL ? 0 : -1)
        " luaconf.h
    fi
}

if [ -z "${LUA_UE4_VERSION}" ]; then
    echo "LUA_UE4_VERSION is not set, exit."
    exit 1
else
    echo "LUA_UE4_VERSION: $LUA_UE4_VERSION"
fi

if [ -z "${LUA_UE4_PREFIX}" ]; then
    echo "LUA_UE4_PREFIX is not set, exit."
    exit 1
else
    echo "LUA_UE4_PREFIX: $LUA_UE4_PREFIX"
fi

LUA_UE4_URL=http://www.lua.org/ftp/lua-${LUA_UE4_VERSION}.tar.gz
LUA_UE4_DIR=lua-${LUA_UE4_VERSION}
LUA_UE4_TAR=${LUA_UE4_DIR}.tar.gz

wget -q -O ${LUA_UE4_TAR} ${LUA_UE4_URL}
tar zxf ${LUA_UE4_TAR}
mv ./${LUA_UE4_DIR}/* .
rm -rf ${LUA_UE4_DIR}

cd src
changesource

cd ..

rm -rf $LUA_UE4_PREFIX
mkdir -p $LUA_UE4_PREFIX

cmake -DCMAKE_INSTALL_PREFIX=$LUA_UE4_PREFIX/mac -DCMAKE_OSX_DEPLOYMENT_TARGET=$LUA_UE4_MAC_DEPLOYMENT_TARGET . -G "Xcode"
xcodebuild -project "lua.xcodeproj" -target "ALL_BUILD" -configuration Release -jobs ${CORE_COUNT} build
xcodebuild -target install build

