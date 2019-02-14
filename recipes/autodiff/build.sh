#!/bin/bash

export CPATH=$PREFIX/include

mkdir build
cd build

# Configure step
cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INCLUDE_PATH=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
ninja install
