autoreconf -fi
./configure
make -j 8
make check
make install
