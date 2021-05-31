#!/usr/bin/env bash

mkdir build
cd build

export CFLAGS="${CFLAGS} -I ${PREFIX}/include/eigen3"
export CXXFLAGS="${CXXFLAGS} -I ${PREFIX}/include/eigen3"

cmake $CMAKE_ARGS -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    ..

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
