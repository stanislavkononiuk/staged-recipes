#!/bin/bash
./configure --prefix="${PREFIX}" --libdir="${PREFIX}/lib/" --with-lib-path="${PREFIX}/lib/"
make
make install
if [[ `uname` == 'Linux' ]];
then
    make check
fi




