#!/bin/sh
set -ex

cmake . \
  -DUSE_PYTHON=ON \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j${CPU_COUNT}
ctest --output-on-failure -j${CPU_COUNT}
make install -j${CPU_COUNT}
