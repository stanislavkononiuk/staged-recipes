#!/bin/bash
make -j${CPU_COUNT} PREFIX=${PREFIX}
make -j${CPU_COUNT} PREFIX=${PREFIX} install
