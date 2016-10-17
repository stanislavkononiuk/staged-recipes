#!/bin/bash

if [ `uname` == "Darwin" ]; then
  cp $RECIPE_DIR/Makefile.debian.SEQ_mac Makefile.inc
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
else
  cp $RECIPE_DIR/Makefile.debian.SEQ Makefile.inc
  export LDFLAGS="${LDFLAGS} -Wl,-rpath=$PREFIX/lib"
fi

make all
cp lib/*.a $PREFIX/lib
cp libseq/*.a $PREFIX/lib
cp include/*.h $PREFIX/include

cd examples
./ssimpletest < input_simpletest_real
./dsimpletest < input_simpletest_real
./csimpletest < input_simpletest_cmplx
./zsimpletest < input_simpletest_cmplx