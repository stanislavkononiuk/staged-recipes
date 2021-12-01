#!/bin/bash

set -ex

autoreconf -fiv

./configure --prefix=$PREFIX
make

if [[ $(uname) == Linux ]]; then
    # The tests only run on Linux (executables must be ELF files)
    make check || { cat test-suite.log; exit 1; }
fi

make install
