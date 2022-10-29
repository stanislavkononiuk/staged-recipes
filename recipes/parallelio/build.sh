#!/bin/bash

export NETCDF_C_PATH=$(dirname $(dirname $(which nc-config)))
export NETCDF_FORTRAN_PATH=$(dirname $(dirname $(which nf-config)))

mkdir build
cd build
FC=mpifort CC=mpicc cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPIO_USE_MALLOC:BOOL=ON \
    -DPIO_ENABLE_TOOLS:BOOL=OFF \
    -DPIO_ENABLE_TESTS:BOOL=OFF \
    -DPIO_ENABLE_EXAMPLES:BOOL=OFF \
    -DPIO_ENABLE_TIMING:BOOL=OFF \
    -DNetCDF_C_PATH=$NETCDF_C_PATH \
    -DNetCDF_Fortran_PATH=$NETCDF_FORTRAN_PATH \
    -DWITH_PNETCDF:BOOL=OFF \
    ..

cmake --build .

# make tests
# ctest

cmake --install .
