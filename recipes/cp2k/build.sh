#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
cd makefiles
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
ls 
ls ..
ls ../exe
cp ../exe/cp2k.* ${PREFIX}/bin
