#!/bin/bash

LDFLAGS="-rpath $PREFIX/lib $LDFLAGS"

./configure \
    --prefix=$PREFIX \
    --with-readline \
    --with-libraries=$PREFIX/lib \
    --with-includes=$PREFIX/include \
    --with-openssl \
    --without-python \
    --with-uuid=e2fs \
    --with-libxml \
    --with-libxslt \
    --with-gssapi

make -j $CPU_COUNT
make -j $CPU_COUNT -C contrib

export MAX_CONNECTIONS=1
make check || (cat src/test/regress/regression.diffs && exit 1)
make check -C src/pl
make check -C src/interfaces/ecpg
make check -C contrib || (cat contrib/btree_gin/regression.diffs && exit 1)

make install
make install -C contrib
