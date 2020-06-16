#!/usr/bin/env bash
set -exo pipefail

chmod +x configure

./configure --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX --with-flint=$PREFIX --disable-static
make -j${CPU_COUNT}
make install
make check -j${CPU_COUNT}
