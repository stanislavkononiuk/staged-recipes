#!/bin/bash
export FFLAGS=${FFLAGS}" -ffree-line-length-none"
cd src

make
make enum.x
make polya.x

cp enum.x $PREFIX/bin
cp polya.x $PREFIX/bin
