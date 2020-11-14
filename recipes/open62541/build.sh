#!/bin/sh

mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DUA_ENABLE_ENCRYPTION_OPENSSL=ON \
      -DUA_ENABLE_HISTORIZING=ON \
      -DOPEN62541_VERSION=v${PKG_VERSION} \
      -DUA_ARCH_REMOVE_FLAGS="-Werror" \
      $SRC_DIR

make -j${CPU_COUNT}
make install