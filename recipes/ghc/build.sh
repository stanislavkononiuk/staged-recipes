#!/bin/bash

export CFLAGS="-I$PREFIX/include" 
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
echo "V=1\nHADDOCK_DOCS=NO\nLATEX_DOCS=NO\nHSCOLOUR_SRCS=NO\nBUILD_DOCBOOK_HTML=NO\nBeConservative=YES\nBUILD_DOCBOOK_PDF=NO\n" > mk/build.mk
./configure --prefix $PREFIX --with-gmp-includes=$PREFIX/include --with-gmp-libraries=$PREFIX/lib
make install
#Small test
echo "main = putStr \"smalltest\"" > Main.hs
ghc -fasm -v5 -o smalltest Main.hs 
./smalltest
