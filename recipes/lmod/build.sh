#!/usr/bin/env bash

set -x -e

./configure --prefix=$PREFIX
make
make install
