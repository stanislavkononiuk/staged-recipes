export CFLAGS=-I${PREFIX}/include
./configure \
	--prefix=$PREFIX 
make -j $CPU_COUNT
make check
make install
