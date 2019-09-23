#!/bin/bash

set -e

if [[ -z "${LUA_UE4_VERSION}" ]]; then
  echo "LUA_UE4_VERSION is not set, exit."
  exit 1
fi

if [[ -z "${LUA_UE4_PREFIX}" ]]; then
  echo "LUA_UE4_PREFIX is not set, exit."
  exit 1
fi

# Custom C compiler
if [[ -z "${CC}" ]]; then
  CC="gcc -std=gnu99"
fi

echo "LUA_UE4_VERSION: ${LUA_UE4_VERSION}"
echo "LUA_UE4_PREFIX: ${LUA_UE4_PREFIX}"
echo "CC: ${CC}"
# Custom compiler/linker flags, see src/Makefile in lua source code
echo "MYCFLAGS: ${MYCFLAGS}"
echo "MYLDFLAGS: ${MYLDFLAGS}"

readonly LUA_UE4_URL=http://www.lua.org/ftp/lua-${LUA_UE4_VERSION}.tar.gz
readonly LUA_UE4_DIR=lua-${LUA_UE4_VERSION}
readonly LUA_UE4_TAR=${LUA_UE4_DIR}.tar.gz

mkdir -p ${LUA_UE4_PREFIX}

echo "Downloading: ${LUA_UE4_URL}"
wget -q -O ${LUA_UE4_TAR} ${LUA_UE4_URL}
tar zxf ${LUA_UE4_TAR}

pushd "${LUA_UE4_DIR}"
  # Increase LUA_IDSIZE from 60 to 256
  sed -i 's:define LUA_IDSIZE:define LUA_IDSIZE    256  // :' src/luaconf.h

  # Patch Makefile to the compilation of a shared library (liblua.so)
  # See: http://www.linuxfromscratch.org/blfs/view/stable/general/lua.html
  # Note: This patch file has been modified from original!
  patch -Np1 -i ../lua-5.3.5-shared_library-1.patch

  make linux CC="${CC}" MYCFLAGS="${MYCFLAGS}" MYLDFLAGS="${MYLDFLAGS}"
  make install INSTALL_TOP="${LUA_UE4_PREFIX}/linux"
popd
