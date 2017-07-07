#!/bin/bash

mkdir build_release
cd build_release


OPENCL_ROOT_FLAG="-DOPENCL_ROOT=${PREFIX}"
if [[ "`uname`" == "Darwin" ]] && [[ "${OSX_VARIANT}" == "native" ]]
then
    OPENCL_ROOT_FLAG="";
fi

cmake \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DSUFFIX_BIN="" \
    -DSUFFIX_LIB="" \
    -DBUILD_TEST=0 \
    -DBUILD_CLIENT=0 \
    "${OPENCL_ROOT_FLAG}" \
    "${SRC_DIR}/src"
make
make install
