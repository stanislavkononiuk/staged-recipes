#!/bin/bash

set -e
set -x
mkdir build
cd build

cmake \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
    -DPYTHON_EXECUTABLE:FILEPATH=${PREFIX}/bin/python \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}m/ \
    -DPYTHON_LIBRARY=${PREFIX}/lib \
    ..
make -j ${CPU_COUNT}

${PYTHON} -m pip install --no-deps --ignore-installed ../
