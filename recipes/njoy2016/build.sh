#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release
make -j "${CPU_COUNT}"
make install