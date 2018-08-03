#!/bin/bash

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DWITH_SASL=${PREFIX} \
    -DWITH_GSSAPI=no \
    -DPYTHON=false \
    -DPYTHON_EXECUTABLE=false \
    -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1

cmake --build . --config Release -- -j${CPU_COUNT}
ctest -V
cmake --build . -- install
