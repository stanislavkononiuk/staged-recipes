#!/bin/bash

mkdir -p build
pushd build

# configure
cmake ${SRC_DIR} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release \

# build
cmake --build . -- -j ${CPU_COUNT}

# check
ctest -VV

# install
cmake --build . --target install
