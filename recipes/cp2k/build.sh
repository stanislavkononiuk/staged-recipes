#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
cd makefiles
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
cp ../exe/Linux-x86-64-conda/cp2k.sopt ${PREFIX}/bin/cp2k.sopt
