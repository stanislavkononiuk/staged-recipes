#!/bin/bash

if [[ $(uname) == Linux ]]; then
  ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
  ln -s "${FC}" "${BUILD_PREFIX}/bin/gfortran"
fi

export F_MASTER=$(pwd)
# export FC=gfortran
export FC_EXE=${FC}
export FC_ENV=$(uname)
export NCDF_PATH=${PREFIX}
export LIBLAPACK="-L${PREFIX}/lib -llapack -lblas"

export FLAGS_NOAH="-p -g -ffree-form -fdefault-real-8 -ffree-line-length-none -fmax-errors=0 -fbacktrace -Wno-unused -Wno-unused-dummy-argument"
export FLAGS_COMM="-p -g -Wall -ffree-line-length-none -fmax-errors=0 -fbacktrace -fcheck=bounds"
export FLAGS_SUMMA=${FLAGS_COMM}

make -C ${F_MASTER}/build/ -f Makefile
