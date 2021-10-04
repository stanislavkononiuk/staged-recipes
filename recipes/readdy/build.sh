#!/bin/bash

mkdir -p build
cd build || true
rm -rf ./*

export HDF5_ROOT=${PREFIX}

cmake .. \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_EXECUTABLE="${PYTHON}" \
  -DPYTHON_PREFIX="${PREFIX}" \
  -DHDF5_INCLUDE_DIRS="${PREFIX}/include" \
  -DREADDY_CREATE_TEST_TARGET:BOOL=OFF \
  -DREADDY_INSTALL_UNIT_TEST_EXECUTABLE:BOOL=OFF \
  -DREADDY_VERSION=${PKG_VERSION} \
  -DREADDY_BUILD_STRING=${PKG_BUILDNUM} \
  -DSP_DIR="${SP_DIR}" \
  -GNinja

ninja -j${CPU_COUNT}
ninja install

exit ${ret_code}

