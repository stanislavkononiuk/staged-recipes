#!/bin/bash

set -ex

mkdir build
pushd build
cmake ${CMAKE_ARGS} -GNinja \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  ..
ninja install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  ninja test
fi
popd
