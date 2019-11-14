#!/usr/bin/env bash

NOCONFIGURE=1 ./bootstrap.sh
./configure --prefix=${PREFIX} \
  --disable-systemd-daemon \
  --disable-systemd-login \
  --disable-systemd-login
make -j ${CPU_COUNT}
XFAIL_TESTS="core-util-test thread-mainloop-test" make check
make install
