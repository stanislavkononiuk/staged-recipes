export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC"
export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

cmake . -DCMAKE_INSTALL_PREFIX=${PREFIX}
make
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
cp  SRC/liblapack.a ${PREFIX}/lib
cp  BLAS/SRC/libblas.a ${PREFIX}/lib
cp  F2CLIBS/libf2c/libf2c.a ${PREFIX}/lib
cp  -r INCLUDE/ ${PREFIX}/include/
