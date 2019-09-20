#!/usr/bin/env bash
set -ex

make CC=$CC prefix=$PREFIX \
     lib=lib
make prefix=$PREFIX \
     lib=lib \
     SBINDIR=$PREFIX/sbin \
     PAM_LIBDIR=$PREFIX/lib \
     RAISE_SETFCAP=no \
     install
